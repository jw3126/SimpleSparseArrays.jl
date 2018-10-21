export SimpleSparseArray
export eachstoredindex
export sparsify

using SparseArrays

"""
    SimpleSparseArray{T,N} <: AbstractArray{T,N}

`SimpleSparseArray` is a sparse array backed by a `Dict`
that works in arbitrary dimension.
"""
struct SimpleSparseArray{Tv,Ti,N} <: AbstractSparseArray{Tv,Ti,N}
    data::Dict{Ti,Tv}
    size::NTuple{N,Int}
end

function (::Type{SimpleSparseArray})(args...)
    SimpleSparseArray{Float64}(args...)
end

function (::Type{SimpleSparseArray{Tv}})(dims::Vararg{Integer,N}) where {Tv,N}
    Ti = Int
    data = Dict{Ti,Tv}()
    SimpleSparseArray{Tv,Ti,N}(data, dims)
end

function (::Type{SimpleSparseArray{Tv,Ti}})(dims::Vararg{Integer,N}) where {Tv,Ti,N}
    data = Dict{Ti,Tv}()
    SimpleSparseArray{Tv,Ti,N}(data, dims)
end

function SparseArrays.nonzeroinds(arr::SimpleSparseArray)
    eachstoredindex(arr)
end
function SparseArrays.nonzeros(arr::SimpleSparseArray)
    values(arr.data)
end

Base.size(arr::SimpleSparseArray) = arr.size
function Base.getindex(arr::SimpleSparseArray, i::Integer)
    @boundscheck checkbounds(arr, i)
    z = zero(eltype(arr))
    get(arr.data,i, z)
end
function Base.getindex(arr::SimpleSparseArray, inds...)
    i = LinearIndices(arr)[inds...]
    arr[i]
end

function Base.setindex!(arr::SimpleSparseArray, val, i::Integer)
    @boundscheck checkbounds(arr, i)
    arr.data[i] = val
end
function Base.setindex!(arr::SimpleSparseArray, val, inds::Integer...)
    i = LinearIndices(arr)[inds...]
    arr[i] = val
end
Base.iterate(arr::SimpleSparseArray)   = iterate(values(arr.data))
Base.iterate(arr::SimpleSparseArray,s) = iterate(values(arr.data),s)

function mapstored!(f,out, arrs::SimpleSparseArray...)
    for arr in arrs
        @assert size(out) == size(arr)
    end
    for I in eachstoredindex(arrs...)
        args = map(arrs) do arr
            arr[I]
        end
        out[I] = f(args...)
    end
    out
end

function Base.map(f, arrs::SimpleSparseArray...)
    argsz = map(arrs) do arr
        zero(eltype(arr))
    end
    fz = f(argsz...)
    T = typeof(fz)
    out = similar(first(arrs), T)
    if iszero(fz)
        mapstored!(f, out, arrs...)
    else
        map!(f, out, arrs...)
    end
    out
end

eachstoredindex(arr::SimpleSparseArray) = keys(arr.data)

function eachstoredindex(arr1::SimpleSparseArray, arr2::SimpleSparseArray)
    inds1 = eachstoredindex(arr1)
    inds2 = filter(eachstoredindex(arr2)) do index
        index in inds1
    end
    Iterators.flatten((inds1, inds2))
end

function eachstoredindex(arr1::SimpleSparseArray, arrs::SimpleSparseArray...)
    ret = Set(eachstoredindex(arr1))
    for arr in arrs
        union!(ret, eachstoredindex(arr))
    end
    ret
end

eachstoredindex(arrs...) = eachindex(arrs...)

function Base.similar(arr::SimpleSparseArray,
        ::Type{T}=eltype(arr),
        dims::NTuple{N,Int}=size(arr)) where {T,N}
    SimpleSparseArray{T}(dims...)
end

for op in [:+,:-]
    @eval function Base.$op(arr1::SimpleSparseArray, arr2::SimpleSparseArray)
        map($op, arr1, arr2)
    end
end

for op in [:*]
    @eval function Base.$op(s::Number, arr::SimpleSparseArray)
        map(x -> $op(s,x), arr)
    end
end

function sparsify(arr; threshold=zero(eltype(arr)))
    out = SimpleSparseArray{eltype(arr)}(size(arr)...)
    for i in LinearIndices(arr)
        val = arr[i]
        if abs(val) > threshold
            out[i] = val
        end
    end
    out
end
