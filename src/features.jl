
include("dbloader.jl")

struct Features 
    pairwise_distance::Matrix{Float64}
    beer_count::Vector{Float64}
    home_distance::Vector{Float64}
    scores::Vector{Float64}
    dim::Int
    function Features(coord::Coordinates, locinfo::LocationInfo)
        pairwise_distance = mapslices(normalize, coord.pairwise; dims=1) * -1
        beer_count = normalize(size.(collect(locinfo.beers), 1))
        home_distance = Vector{Float64}(undef, coord.dim)
        scores = Vector{Float64}(undef, coord.dim)
        new(pairwise_distance, beer_count, home_distance, scores, 3)
    end
end

function update!(feat::Features, pointwise)
    copy!(feat.home_distance, pointwise)
    normalize!(feat.home_distance)
    feat.home_distance .*= -1
end

function calc_scores!(f::Features, betas, id)
    @inbounds for i ∈ eachindex(f.scores)
        f.scores[i] = f.home_distance[i]*betas[1] + f.pairwise_distance[id, i]*betas[2] + f.beer_count[i]*betas[3]   
    end
end

function calc_scores!(f::Features, betas)
    @inbounds for i ∈ eachindex(f.scores)
        f.scores[i] = f.home_distance[i]*betas[1] + f.home_distance[i]*betas[2] + f.beer_count[i]*betas[3]   
    end
end