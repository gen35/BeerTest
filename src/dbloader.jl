using DataFrames, SQLite, LinearAlgebra

include("database.jl")
include("utils.jl")

struct Coordinates
    longitudes::Vector{Float64}
    latitudes::Vector{Float64}
    pairwise::Matrix{Float64}
    dim::Int
end

struct LocationInfo
    beers::GroupedDataFrame
    locations::DataFrame
end

function loaddata()
    db = SQLite.DB(path_database)
    beers = DBInterface.execute(db, "select * from $path_db_beers") |> DataFrame
    locations = DBInterface.execute(db, "select * from $path_db_locations") |> DataFrame
    return beers, locations
end

function preprocess(beers, locations)
    produce = innerjoin(locations, beers, on = :id => :brewery_id, renamecols = "" => "_beer")
    beer_by_loc = groupby(produce, :id)
    loc_aligned = combine(beer_by_loc, first)
    return beer_by_loc, loc_aligned
end

function get_coord_in_radians(locations)
    long = locations[!, :longitude]::Vector{Float64}
    lat = locations[!, :latitude]::Vector{Float64}
    long = degtorad.(long)
    lat = degtorad.(lat)
    return long, lat
end

function get_mapinfo()
    beers, locations = preprocess(loaddata()...)

    long, lat = get_coord_in_radians(locations)
    pairwise = dist_pairwise(long, lat)

    coordinates = Coordinates(long, lat, pairwise, size(long, 1))
    locationinfo = LocationInfo(beers, locations)
    return coordinates, locationinfo
end
