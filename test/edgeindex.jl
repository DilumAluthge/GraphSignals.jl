# undirected simple graph
adjl1 = [
    [(2, 1), (4, 2), (5, 3)],
    [(1, 1)],
    [],
    [(1, 2), (5, 4)],
    [(1, 3), (4, 4)]
]

# directed graph with self loop and multiple edges
adjl2 = [
    [(2, 1), (5, 2), (5, 3)],
    [],
    [(1, 4), (4, 5)],
    [(4, 6)],
    [(1, 7), (4, 8)],
]

@testset "EdgeIndex" begin
    ei1 = EdgeIndex(adjl1)
    @test ei1.adjl isa Vector{Vector{NTuple{2}}}
    @test nv(ei1) == 5
    @test ne(ei1) == 4
    @test neighbors(ei1, 1) == [(2, 1), (4, 2), (5, 3)]
    @test neighbors(ei1, 3) == []
    @test get(ei1, (1, 5)) == 3
    @test isnothing(get(ei1, (2, 3)))

    ei2 = EdgeIndex(adjl2)
    @test nv(ei2) == 5
    @test ne(ei2) == 8
    @test neighbors(ei2, 1) == [(2, 1), (5, 2), (5, 3)]
    @test neighbors(ei2, 2) == []
    @test get(ei2, (3, 1)) == 4
    @test isnothing(get(ei2, (1, 3)))
end