using DataFrames
import CSV 
using LoopVectorization
using LinearAlgebra

const path_beers = "./data/beers.csv"
const path_breweries = "./data/breweries.csv"
const path_geocodes = "./data/geocodes.csv"

function readdata()
    beers = DataFrame(CSV.File(path_beers))[!, [:brewery_id, :name]]
    breweries = DataFrame(CSV.File(path_breweries))[!, [:id, :name]]
    geocodes = DataFrame(CSV.File(path_geocodes))[!, [:brewery_id, :latitude, :longitude]]

    locations = innerjoin(breweries, geocodes, on = :id => :brewery_id)
    produce = innerjoin(locations, beers, on = :id => :brewery_id, renamecols = "" => "_beer")

    # assume identically named beers from different breweries are distinct
    #@show length(produce[!, :name_beer]), length(unique(produce[!, :name_beer]))

    groups = groupby(produce, :id)
    loc_aligned = combine(groups, first)

    return loc_aligned, groups
end

get_geocoords(df) = df[!, :longitude]::Vector{Float64}, df[!, :latitude]::Vector{Float64}

degtorad(deg) = deg*π/180

@inline function haversine(λ₁, φ₁, λ₂, φ₂)
    Δλ = λ₂ - λ₁  # longitudes
    Δφ = φ₂ - φ₁  # latitudes

    # haversine formula
    a = sin(Δφ/2)^2 + cos(φ₁)*cos(φ₂)*sin(Δλ/2)^2
    
    # # distance on the sphere
    2 * 6_371_000 * asin( min(√a, one(a)) ) # take care of floating point errors
end

# optimze to use Symetric
function calcdists(loc)
    s = size(loc, 1)
    x = Array{Float64}(undef, s, s)
    λ, ϕ = get_geocoords(loc)
    λ = @turbo degtorad.(λ)
    ϕ = @turbo degtorad.(ϕ)
    @inbounds @fastmath for i ∈ axes(x, 1), j ∈ axes(x, 2)
        x[i, j] = haversine(λ[i], ϕ[i], λ[j], ϕ[j])
    end
    return x
end

function travel(id, loc, groups, traveled)
    brewery = loc[id, :]
    beer_count = size(groups[id], 1)
    println("$(Int(traveled ÷ 1000))km -> [$(brewery.id)]$(brewery.name) +$beer_count")
    return beer_count
end

function masked_argmin(itr, mask)
    id = -1
    m = floatmax(Float64, )
    for i ∈ eachindex(itr)
        if mask[i] && itr[i] < m
            id = i
            m = itr[i]
        end
    end
    return id
end

function fp_naive(loc, groups, dist, long, lat, fuel_dist=2_000_000.)
    traveled, beer_count, brewery_count = 0., 0, 0
    mask = BitArray(undef, size(loc, 1))
    mask .= true
    λ, ϕ = get_geocoords(loc)
    λ = @turbo degtorad.(λ)
    ϕ = @turbo degtorad.(ϕ)

    # first choice
    s = size(loc, 1)
    x = Vector{Float64}(undef, s)
    @inbounds @fastmath for i ∈ eachindex(x)
        x[i] = haversine(long, lat, λ[i], ϕ[i])
    end

    foreach(i -> dist[i, i] = floatmax(Float64), 1:size(dist, 1)) 

    id = masked_argmin(x, mask)
    beer_count += travel(id, loc, groups, traveled)
    traveled += x[id]
    mask[id] = false

    while true
        id_new = masked_argmin(dist[id, :], mask)
        x[id_new] + dist[id, id_new] + traveled > fuel_dist && break
        beer_count += travel(id, loc, groups, traveled)
        traveled += dist[id, id_new]
        id = id_new
        mask[id] = false
        brewery_count += 1
    end

    traveled += x[id]
    println("traveled = $(Int(traveled ÷ 1000))km")
    @show brewery_count
    @show beer_count
    return
end

function masked_weighted_argmax(itr, mask, n_home, n_brew, n_count)
    @inbounds α , β, γ = [0.08611111111111111, 0.7055555555555556, 0.12777777777777777]
    id = 1
    m = -Inf
    @inbounds for i ∈ eachindex(mask)
        score = γ*n_count[i] - β*n_brew[i] - α*n_home[i]
        if mask[i] && score > m
            id = i
            m = score
        end
    end
    return id
end

function fp_3param(loc, groups, dist, long, lat, fuel_dist=2_000_000.)
    traveled, beer_count, brewery_count = 0., 0, 1 # check if no travel available
    mask = BitArray(undef, size(loc, 1))
    mask .= true
    λ, ϕ = get_geocoords(loc)
    λ = @turbo degtorad.(λ)
    ϕ = @turbo degtorad.(ϕ)

    # first choice
    s = size(loc, 1)
    x = Vector{Float64}(undef, s)
    @inbounds @fastmath for i ∈ eachindex(x)
        x[i] = haversine(long, lat, λ[i], ϕ[i])
    end

    #calc l2-norm parameters
    n_home = normalize(x)
    n_brew = mapslices(normalize, dist; dims=1)
    n_count = normalize(size.(collect(groups), 1))

    foreach(i -> dist[i, i] = floatmax(Float64), 1:size(dist, 1)) 

    id = masked_weighted_argmax(x, mask, n_home, n_home, n_count)
    beer_count += travel(id, loc, groups, traveled)
    traveled += x[id]
    mask[id] = false

    while true
        id_new = masked_weighted_argmax(dist[id, :], mask, n_home, n_brew[id, :], n_count)
        x[id_new] + dist[id, id_new] + traveled > fuel_dist && break
        beer_count += travel(id_new, loc, groups, traveled)
        traveled += dist[id, id_new]
        id = id_new
        mask[id] = false
        brewery_count += 1
    end

    traveled += x[id]
    println("traveled = $(Int(traveled ÷ 1000))km")
    @show brewery_count
    @show beer_count
    return
end

function main()
    loc, groups = readdata()
    dist = calcdists(loc)
    # fp_3param(loc, groups, dist, degtorad(11.100790), degtorad(51.355468))
    fp_3param(loc, groups, dist, degtorad(19.43956), degtorad(51.742503))
end

function main2()
    loc, groups = readdata()
    dist = calcdists(loc)
    fp_naive(loc, groups, dist, degtorad(11.100790), degtorad(51.355468))
end