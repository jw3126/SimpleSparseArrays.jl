using SimpleSparseArrays
using SimpleSparseArrays.Testing
using LinearAlgebra
using Test

@testset "basics" begin
    @test SimpleSparseArray(1,2,3) == SimpleSparseArray{Float64}(1,2,3)
    @test issparse(SimpleSparseArray(1,2,3))
end

@testset "no redundant zeros" begin
    arr = SimpleSparseArray{Float64}(10,10)
    @test isempty(eachstoredindex(arr))
    @test isempty(eachstoredindex(arr + arr))
    @test isempty(eachstoredindex(5 * arr))
    @test isempty(eachstoredindex(map(sin, arr)))
    @test isempty(eachstoredindex(map(+, arr, arr)))
    @test isempty(eachstoredindex(map(+, arr, arr, arr, arr)))
    @test isempty(eachstoredindex(sparsify(zeros(3))))

    @test_broken isempty(eachstoredindex(arr[:,1]))
    @test_broken isempty(eachstoredindex(arr[1:3, 2:4]))
    @test_broken isempty(eachstoredindex(sqrt.(arr)))
    @test_broken isempty(eachstoredindex(sin.(arr) .+ Ref(1) .* arr))
end

@testset "test against full" begin
    v1 = randn(3)
    v2 = randn(3)
    vs1  = sparsify(v1)
    vs2  = sparsify(v2)
    @test_broken vs1 == v1
    @test vs1 == vs1
    @test vs1 == deepcopy(vs1)
    @test vs1 ≈ v1
    @test !(vs1 ≈ vs2)
    @test !(v1 ≈ vs2)
    for i in eachindex(v1)
        @test v1[i] === vs1[i]
    end

    @test isapprox_full(+, vs1, vs2)
    @test isapprox_full(-, vs1, vs2)
    @test isapprox_full(norm, vs1)
    @test isapprox_full(sum, vs1)
    @test isapprox_full(map, +, vs1, vs2, vs1)
    @test isapprox_full(map, -, vs1, vs2)
    @test isapprox_full(map, sin, vs1)
    @test isapprox_full(map, cos, vs1)
    @test isapprox_full(broadcast, cos, vs1)
    @test isapprox_full(broadcast, +, vs1, Ref(1), sparsify(randn(3,1)))

end
