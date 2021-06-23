include("features.jl")
include("optimization.jl")

function initialize()
    coord, locinfo = get_mapinfo()
    config = Config()
    feat = Features(coord, locinfo)
    bookkeep = BookKeep(coord.dim, feat.dim)

    fill_diag!(coord.pairwise, floatmax(Float64))

    return coord, locinfo, config, bookkeep, feat
end

function main(latitude=51.355468, longitude=11.100790; state=nothing)
    coord, locinfo, config, bookkeep, feat = isnothing(state) ? initialize() : state

    dist_pointwise!(bookkeep.pointwise, degtorad(longitude), degtorad(latitude), coord.longitudes, coord.latitudes)
    update!(feat, bookkeep.pointwise)
    Random.seed!(config.rng, 1234)

    run_optimization(coord, locinfo, config, bookkeep, feat)
end