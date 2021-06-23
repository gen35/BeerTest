using BeerTest
using Test, SQLite

@testset "BeerTest.jl" begin
    @testset "database.jl" begin     
        @test isfile(BeerTest.path_beers)
        @test isfile(BeerTest.path_breweries)
        @test isfile(BeerTest.path_geocodes)

        @test isfile(BeerTest.path_database)
        @test issetequal(first(SQLite.tables(SQLite.DB(BeerTest.path_database))), ["beers", "locations"]) 
    end

    @testset "dbloader.jl" begin     
        coord, locinfo = BeerTest.get_mapinfo()
        @test size(coord.longitudes) == size(coord.latitudes)
        @test size(coord.longitudes, 1) == coord.dim
        @test size(coord.pairwise, 1) == coord.dim
        @test size(coord.pairwise, 2) == coord.dim
        @test length(locinfo.beers) == coord.dim
        @test size(locinfo.locations, 1) == coord.dim
        @test size(locinfo.locations[!, :name], 1) == coord.dim
    end

    @testset "features.jl" begin 
        coord, locinfo = BeerTest.get_mapinfo()
        feat = BeerTest.Features(coord, locinfo)
        @test size(coord.pairwise) == size(feat.pairwise_distance)
        @test coord.dim == size(feat.home_distance, 1)
        @test coord.dim == size(feat.beer_count, 1)
        @test coord.dim == size(feat.scores, 1)

        @test sum(feat.pairwise_distance[:, 1].^2) ≈ 1.      
        @test sum(feat.beer_count.^2) ≈ 1.          
    end

    @testset "main.jl" begin 
        state = initialize()
        output = false
        beer_counts = collect(1:3) .|> _ -> main(;state, output)
        @test all(first(beer_counts) .== beer_counts)
    end
end
