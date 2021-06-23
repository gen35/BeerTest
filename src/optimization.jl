using Random, Optim

Base.@kwdef struct Config
    fuel_dist::Float64 = 2.e6
    seed::Int = 1234
    rng::MersenneTwister = MersenneTwister(seed)
    optimizer::Optim.AbstractOptimizer = NelderMead()
    models::Int = 20
end

struct BookKeep
    mask::BitArray # keeps visited locations
    betas::Vector{Float64} # optimization weights
    pointwise::Vector{Float64}
    function BookKeep(dim, feature_count)
        new(trues(dim), Vector{Float64}(undef, feature_count), Vector{Float64}(undef, dim))
    end
end

# finds most desirable location (local maximum) 
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

function find_betas!(coord, locinfo, config, bookkeep, feat, betas; output=false)
    beer_count, traveled = 0, 0.
    bookkeep.mask .= true
    
    calc_scores!(feat, betas)
    id = masked_weighted_argmax(bookkeep.mask, feat.scores)
    beer_count += size(locinfo.beers[id], 1)
    traveled += bookkeep.pointwise[id]
    bookkeep.mask[id] = false  
    output && println("$(Int(traveled÷1000))km $(locinfo.locations[id, :name]) +$(size(locinfo.beers[id], 1))")

    while true 
        calc_scores!(feat, betas, id)
        id_new = masked_weighted_argmax(bookkeep.mask, feat.scores)
        bookkeep.pointwise[id_new] + coord.pairwise[id, id_new] + traveled > config.fuel_dist && break
        beer_count += size(locinfo.beers[id], 1)
        traveled += coord.pairwise[id, id_new]
        id = id_new
        bookkeep.mask[id] = false
        output && println("$(Int(traveled÷1000))km $(locinfo.locations[id, :name]) +$(size(locinfo.beers[id], 1))")
    end
    
    return -beer_count # only beer count is optimized since task is ambiguous 
end

function run_optimization(coord, locinfo, config, bookkeep, feat, output=true)
    minimum = 1.
    minimizer = []
    for _ ∈ 1:config.models # few models are run with different betas initializations
        rand!(config.rng, bookkeep.betas)
        res = optimize(betas -> find_betas!(coord, locinfo, config, bookkeep, feat, betas), bookkeep.betas, config.optimizer)
        if Optim.minimum(res) < minimum 
            minimum = Optim.minimum(res)
            minimizer = Optim.minimizer(res)
        end
    end

    find_betas!(coord, locinfo, config, bookkeep, feat, minimizer; output=output)
    output && println("Beer count: $(Int(-minimum))")
    return (Int(-minimum))
end