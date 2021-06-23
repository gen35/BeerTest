
include("dbloader.jl")

struct Features 
    pairwise_distance::Matrix{Float64}
    beer_count::Vector{Float64}
    home_distance::Vector{Float64}
    dim::Int
    function Features(coord::Coordinates, locinfo::LocationInfo)
        pairwise_distance = mapslices(normalize, coord.pairwise; dims=1) * -1
        beer_count = normalize(size.(collect(locinfo.beers), 1))
        home_distance = Vector{Float64}(undef, coord.dim)
        new(pairwise_distance, beer_count, home_distance, 3)
    end
end

function update!(feat::Features, pointwise)
    copy!(feat.home_distance, pointwise)
    normalize!(feat.home_distance)
    feat.home_distance .*= -1
end

function (f::Features)(col_id)
    # f.home_distance, (@view f.pairwise_distance[:, col_id]), f.beer_count
    f.home_distance, f.pairwise_distance[col_id, :], f.beer_count
end

function (f::Features)()
    f.home_distance, f.home_distance, f.beer_count
end
