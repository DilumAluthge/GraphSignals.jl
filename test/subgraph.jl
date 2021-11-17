@testset "subgraph" begin
    V = 5
    nf = rand(3, V)
    gf = rand(7)

    nodes = [1,2,3,5]

    @testset "null graph" begin
        fg = NullGraph()

        subg = FeaturedSubgraph(fg, nodes)
        @test subg === fg
        @test subgraph(fg, nodes) === fg
    end

    @testset "undirected graph" begin
        E = 5
        ef = rand(5, E)
        adjm = [0 1 0 1 0; # symmetric
                1 0 1 0 0;
                0 1 0 1 0;
                1 0 1 0 0;
                0 0 0 0 1]
        fg = FeaturedGraph(adjm, nf=nf, ef=ef, gf=gf)

        subg = FeaturedSubgraph(fg, nodes)
        @test subgraph(fg, nodes) == subg
        @test is_directed(subg) == is_directed(fg)
        @test adjacency_matrix(subg) == view(adjm, nodes, nodes)
        @test adjacency_matrix(subg) isa SubArray
        @test node_feature(subg) == view(nf, :, nodes)
        @test edge_feature(subg) == view(ef, :, [1,2,5])
        @test global_feature(subg) == gf
    end

    @testset "directed graph" begin
        E = 16
        ef = rand(5, E)
        adjm = [1 1 0 1 0; # asymmetric
                1 1 1 0 0;
                0 1 1 1 1;
                1 0 1 1 0;
                1 0 1 0 1]
        fg = FeaturedGraph(adjm, nf=nf, ef=ef, gf=gf)

        subg = FeaturedSubgraph(fg, nodes)
        @test subgraph(fg, nodes) == subg
        @test is_directed(subg) == is_directed(fg)
        @test adjacency_matrix(subg) == view(adjm, nodes, nodes)
        @test adjacency_matrix(subg) isa SubArray
        @test node_feature(subg) == view(nf, :, nodes)
        @test edge_feature(subg) == view(ef, :, [1,2,4,5,6,7,8,9,11,15,16])
        @test global_feature(subg) == gf
    end
end