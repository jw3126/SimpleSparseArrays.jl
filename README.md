
# SimpleSparseArrays
[![Build Status](https://travis-ci.org/jw3126/SimpleSparseArrays.jl.svg?branch=master)](https://travis-ci.org/jw3126/SimpleSparseArrays.jl)
[![codecov.io](https://codecov.io/github/jw3126/SimpleSparseArrays.jl/coverage.svg?branch=master)](http://codecov.io/github/jw3126/SimpleSparseArrays.jl?branch=master)

Arbitrary dimension sparse arrays. See also
[here](https://discourse.julialang.org/t/sparse-3d-arrays/16488).

# Usage

`SimpleSparseArray` is a subtype of `AbstractArray` and
hence it should work as a drop in replacement for your arrays.
```julia
julia> using SimpleSparseArrays

julia> arr3d = SimpleSparseArray{Float64}(2,3,4)
2×3×4 SimpleSparseArray{Float64,3}:
[:, :, 1] =
 0.0  0.0  0.0
 0.0  0.0  0.0

[:, :, 2] =
 0.0  0.0  0.0
 0.0  0.0  0.0

[:, :, 3] =
 0.0  0.0  0.0
 0.0  0.0  0.0

[:, :, 4] =
 0.0  0.0  0.0
 0.0  0.0  0.0

julia> arr3d[1,1,1] = 10
10

julia> arr3d[1,1,2] = 20
20

julia> sum(arr3d)
30.0
```

# Design goals

Design goals ordered by priority:

* Must work in arbitrary dimensions
* Simple implementation
* Performance
