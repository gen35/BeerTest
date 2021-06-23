using Random, Optim

Base.@kwdef struct Config
    fuel_dist::Float64 = 2.e6
    rng::MersenneTwister = MersenneTwister(1234)
    optimizer::Optim.AbstractOptimizer = NelderMead()
    models::Int = 20
end

struct BookKeep
    mask::BitArray
    betas::Vector{Float64}
    pointwise::Vector{Float64}
    function BookKeep(dim, feature_count)
        new(trues(dim), Vector{Float64}(undef, feature_count), Vector{Float64}(undef, dim))
    end
end

function travel(id, groups)
    beer_count = size(groups[id], 1)
    return beer_count
end

function masked_weighted_argmax(mask, scores)
    id = 1
    m = floatmax(Float64) * -1
    @inbounds for i ∈ eachindex(mask)
        if mask[i] && scores[i] > m
            id = i
            m = scores[i]
        end
    end
    return id
end

function find_betas(coord, locinfo, config, bookkeep, feat, betas)
    beer_count, traveled = 0, 0.
    bookkeep.mask .= true
    
    calc_scores!(feat, betas)
    id = masked_weighted_argmax(bookkeep.mask, feat.scores)
    beer_count += travel(id, locinfo.beers)
    traveled += bookkeep.pointwise[id]
    bookkeep.mask[id] = false

    while true
        calc_scores!(feat, betas, id)
        id_new = masked_weighted_argmax(bookkeep.mask, feat.scores)
        bookkeep.pointwise[id_new] + coord.pairwise[id, id_new] + traveled > config.fuel_dist && break
        beer_count += travel(id_new, locinfo.beers)
        traveled += coord.pairwise[id, id_new]
        id = id_new
        bookkeep.mask[id] = false
    end

    return -beer_count
end

function run_optimization(coord, locinfo, config, bookkeep, feat)
    minimum = 1.
    minimizer = []
    for _ ∈ 1:config.models
        rand!(config.rng, bookkeep.betas)
        res = optimize(betas -> find_betas(coord, locinfo, config, bookkeep, feat, betas), bookkeep.betas, config.optimizer)
        if Optim.minimum(res) < minimum 
            minimum = Optim.minimum(res)
            minimizer = Optim.minimizer(res)
        end
    end

    @show minimum
    @show minimizer
    return
end