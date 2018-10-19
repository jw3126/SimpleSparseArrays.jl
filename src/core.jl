export SimpleSparseArray
export eachstoredindex
export sparsify

"""
    SimpleSparseArray{T,N} <: AbstractArray{T,N}

`SimpleSparseArray` is a sparse array backed by a `Dict`
that works in arbitrary dimension.
"""
struct SimpleSparseArray{T,N} <: AbstractArray{T,N}
    data::Dict{CartesianIndex{N},T}
    size::NTuple{N,Int}
end

function _SimpleSparseArray(::Type{T}, dims::NTuple{N}) where {T,N}
    data = Dict{CartesianIndex{N},T}()
    SimpleSparseArray{T,N}(data, dims)
end
SimpleSparseArray{T}(dims...) where {T} = _SimpleSparseArray(T, dims)

Base.IndexStyle(::Type{<:SimpleSparseArray}) = IndexCartesian()

Base.size(arr::SimpleSparseArray) = arr.size
function Base.getindex(arr::SimpleSparseArray, I::CartesianIndex)
    @boundscheck checkbounds(arr, I)
    z = zero(eltype(arr))
    get(arr.data,I, z)
end
function Base.getindex(arr::SimpleSparseArray, inds::Integer...)
    ci = CartesianIndices(arr)[inds...]
    arr[ci]
end

function Base.setindex!(arr::SimpleSparseArray, val, I::CartesianIndex)
    @boundscheck checkbounds(arr, I)
    arr.data[I] = val
end
function Base.setindex!(arr::SimpleSparseArray, val, inds::Integer...)
    ci = CartesianIndices(arr)[inds...]
    arr[ci] = val
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
    for ci in CartesianIndices(arr)
        val = arr[ci]
        if abs(val) > threshold
            out[ci] = val
        end
    end
    out
end
