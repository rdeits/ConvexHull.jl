using JuMP

function homogeneous_system(model::JuMP.Model)
    A = full(JuMP.prepConstrMatrix(model))
    c, lb, ub = JuMP.prepProblemBounds(model)
    l, u = model.colLower, model.colUpper

    m, n = size(A)
    @assert m == length(lb) == length(ub)
    @assert model.nlpdata == nothing
    @assert isempty(model.quadconstr)
    @assert isempty(model.sosconstr)

    C = Array(Float64, 0, n)
    b = Float64[]
    for i in 1:m
        if !isinf(lb[i])
            C = [C, A[i,:]]
            push!(b, -lb[i])
        end
        if !isinf(ub[i])
            C = [C; -A[i,:]]
            push!(b, ub[i])
        end
    end

    F = eye(n, n)
    B = Array(Float64, 0, n)
    d = Float64[]
    for i in 1:n
        if !isinf(l[i])
            B = [B; F[i,:]]
            push!(d, -l[i])
        end
        if !isinf(u[i])
            B = [B; -F[i,:]]
            push!(d, u[i])
        end
    end

    return [C;B], [b;d]
end

function write_ine(model::JuMP.Model, fname::String)
    A, b = homogeneous_system(model)
    try
        write_ine(fname, convert(Matrix{Int},A), convert(Matrix{Int},b))
    catch InexactError
        write_ine(fname, A, b)
    end
end

