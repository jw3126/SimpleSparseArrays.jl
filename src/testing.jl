module Testing
using SimpleSparseArrays
export isapprox_full

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

end#module
