using DataFrames
import CSV, SQLite

include("paths.jl")

function readdata()
    beers = DataFrame(CSV.File(path_beers))[!, [:brewery_id, :name]]
    breweries = DataFrame(CSV.File(path_breweries))[!, [:id, :name]]
    geocodes = DataFrame(CSV.File(path_geocodes))[!, [:brewery_id, :latitude, :longitude]]

    locations = innerjoin(breweries, geocodes, on = :id => :brewery_id)
    return beers, locations
end

function createDB()
    beers, locations = readdata()
    db = SQLite.DB(path_database)
    beers |> SQLite.load!(db, path_db_beers)
    locations |> SQLite.load!(db, path_db_locations)
    return
end
