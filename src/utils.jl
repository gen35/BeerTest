
degtorad(deg) = deg*π/180
#degtorad(deg) = @fastmath deg*π/180

@inline function haversine(λ₁, φ₁, λ₂, φ₂)
    Δλ = λ₂ - λ₁  # longitudes
    Δφ = φ₂ - φ₁  # latitudes

    # haversine formula
    a = sin(Δφ/2)^2 + cos(φ₁)*cos(φ₂)*sin(Δλ/2)^2
    
    # # distance on the sphere
    2 * 6_371_000 * asin( min(√a, one(a)) ) # take care of floating point errors
end

function dist_pairwise(long, lat)
    dim = size(long, 1)
    dist = Array{Float64}(undef, dim, dim)
    @fastmath @inbounds for i ∈ axes(dist, 1), j ∈ 1:i
        dist[i, j] = haversine(long[i], lat[i], long[j], lat[j])
    end
    return Symmetric(dist, :L)
end

function dist_pointwise!(out, long_point, lat_point, long_vec, lat_vec)
    @fastmath @inbounds for i ∈ eachindex(out)
        out[i] = haversine(long_point, lat_point, long_vec[i], lat_vec[i])
    end
    return out
end

function fill_diag!(matrix, value)
    foreach(i -> matrix[i, i] = value, 1:size(matrix, 1))
end
