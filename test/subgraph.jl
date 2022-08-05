@testset "subgraph" begin
    T = Float64
    V = 5
    vdim = 3
    nf = rand(vdim, V)
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
        adjm = T[0 1 0 1 0; # symmetric
                1 0 1 0 0;
                0 1 0 1 0;
                1 0 1 0 0;
                0 0 0 0 1]
        fg = FeaturedGraph(adjm, nf=nf, ef=ef, gf=gf)

        subg = FeaturedSubgraph(fg, nodes)
        @test graph(subg) === graph(fg)
        @test subgraph(fg, nodes) == subg
        @test is_directed(subg) == is_directed(fg)
        @test adjacency_matrix(subg) == view(adjm, nodes, nodes)
        @test adjacency_matrix(subg) isa SubArray
        @test node_feature(subg) == nf[:, Graphs.vertices(subg)]
        @test edge_feature(subg) == ef[:, Graphs.edges(subg)]
        @test global_feature(subg) == gf

        new_nf = rand(vdim, V)
        new_subg = ConcreteFeaturedGraph(subg, nf=new_nf)
        @test node_feature(new_subg) == new_nf[:, Graphs.vertices(new_subg)]
        @test edge_feature(new_subg) == ef[:, Graphs.edges(new_subg)]
        @test global_feature(new_subg) == gf

        @test vertices(subg) == nodes
        @test edges(subg) == [1,2,5]
        @test neighbors(subg) == [2, 4, 1, 3, 2, 4, 5]
        @test incident_edges(subg) == [1, 3, 1, 2, 2, 4, 5]

        @test GraphSignals.degrees(subg) == [2, 2, 2, 1]
        @test GraphSignals.degree_matrix(subg) == diagm([2, 2, 2, 1])
        @test GraphSignals.normalized_adjacency_matrix(subg) ≈ [0 .5 0 0;
                                                                .5 0 .5 0;
                                                                0 .5 0 0;
                                                                0 0 0 1]
        @test GraphSignals.laplacian_matrix(subg) == [2 -1 0 0;
                                                     -1 2 -1 0;
                                                      0 -1 2 0;
                                                      0 0 0 0]
        @test GraphSignals.normalized_laplacian(subg) ≈ [1 -.5 0 0;
                                                        -.5 1 -.5 0;
                                                         0 -.5 1 0;
                                                         0 0 0 0]
        @test GraphSignals.scaled_laplacian(subg) ≈ [0 -.5 0 0;
                                                     -.5 0 -.5 0;
                                                     0 -.5 0 0;
                                                     0 0 0 -1]

        rand_subgraph = sample(subg, 3)
        @test rand_subgraph isa FeaturedSubgraph
        @test length(rand_subgraph.nodes) == 3
        @test rand_subgraph.nodes ⊆ subg.nodes
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
        @test graph(subg) === graph(fg)
        @test subgraph(fg, nodes) == subg
        @test is_directed(subg) == is_directed(fg)
        @test adjacency_matrix(subg) == view(adjm, nodes, nodes)
        @test adjacency_matrix(subg) isa SubArray
        @test node_feature(subg) == nf[:, Graphs.vertices(subg)]
        @test edge_feature(subg) == ef[:, Graphs.edges(subg)]
        @test global_feature(subg) == gf
        @test parent(subg) === subg.fg

        @test vertices(subg) == nodes
        @test edges(subg) == [1,2,4,5,6,7,8,9,11,15,16]
        @test neighbors(subg) == [1, 2, 4, 5, 1, 2, 3, 2, 3, 4, 5, 3, 5]
        @test incident_edges(subg) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 15, 16]

        rand_subgraph = sample(subg, 3)
        @test rand_subgraph isa FeaturedSubgraph
        @test length(rand_subgraph.nodes) == 3
        @test rand_subgraph.nodes ⊆ subg.nodes
    end

    @testset "mask" begin
        adj1 = [0 1 0 1; # symmetric
                1 0 1 0;
                0 1 0 1;
                1 0 1 0]
        adj2 = [1 1 0 1 0; # asymmetric
                1 1 1 0 0;
                0 1 1 1 1;
                1 0 1 1 0;
                1 0 1 0 1]
        mask1 = [2, 3, 4]
        mask2 = [1, 2, 3, 4]
    
        fg1 = FeaturedGraph(adj1)
        fg2 = FeaturedGraph(adj2)
        gm1 = mask(fg1, mask1)
        gm2 = mask(fg2, mask2)
    
        @test subgraph(fg1, mask1) == gm1
        @test subgraph(fg2, mask2) == gm2
        @test adjacency_matrix(gm1) == [0 1 0;
                                        1 0 1;
                                        0 1 0]
        @test adjacency_matrix(gm2) == [1 1 0 1;
                                        1 1 1 0;
                                        0 1 1 1;
                                        1 0 1 1]
    end    
end
