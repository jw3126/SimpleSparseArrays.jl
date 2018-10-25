module Testing
using SimpleSparseArrays
export isapprox_full, memory_ratio, storage_ratio

function isapprox_full(f, args_sparse...; kw...)
    args_full = map(args_sparse) do arg
        if arg isa SimpleSparseArray
            Array(arg)
        else
            arg
        end
    end
    ret_full = f(args_full...)
    ret_sparse = f(args_sparse...)
    isapprox(ret_full, ret_sparse; kw...)
end

function memory_ratio(arr::SimpleSparseArray)
    @assert isbitstype(eltype(arr))
    mem_full = length(arr) * sizeof(eltype(arr))
    Base.summarysize(arr) / mem_full
end

function storage_ratio(arr::SimpleSparseArray)
    length(eachstoredindex(arr)) / length(arr)
end

end#module
