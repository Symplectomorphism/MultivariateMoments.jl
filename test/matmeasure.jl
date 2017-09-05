@testset "MatMeasure" begin
    Mod.@polyvar x y
    @test_throws ArgumentError matmeasure(Measure([1], [x]), [y])
end

# [HL05] Henrion, D. & Lasserre, J-B.
# Detecting Global Optimality and Extracting Solutions of GloptiPoly 2005

@testset "[HL05] Section 2.3" begin
    Mod.@polyvar x y
    η = AtomicMeasure([x, y], [0.4132, 0.3391, 0.2477], [[1, 2], [2, 2], [2, 3]])
    μ = Measure(η, [x^4, x^3*y, x^2*y^2, x*y^3, y^4, x^3, x^2*y, x*y^2, y^3, x^2, x*y, y^2, x, y, 1])
    ν = matmeasure(μ, [1, x, y, x^2, x*y, y^2])
    for lrc in (SVDChol(), ShiftChol(1e-14))
        atoms = extractatoms(ν, 1e-4, lrc)
        @test !isnull(atoms)
        @test get(atoms) ≈ η
    end
end

function testelements(X, Y, atol)
    @test length(X) == length(Y)
    for y in Y
        @test any(x -> isapprox(x, y, atol=atol), X)
    end
end
@testset "[HL05] Section 3.3.1" begin
    Mod.@polyvar x y z
    U = [1 0 0 0 0 0;
         0 1 0 0 0 0;
         0 0 1 0 0 0;
         2 0 0 0 0 0; # z^2 = 2z
         0 0 0 1 0 0;
         0 2 0 0 0 0; # y^2 = 2y
         0 0 0 0 1 0;
         0 0 0 0 0 1;
         0 0 2 0 0 0] # x^2 = 2x
    # β will be [z, y, x, y*z, x*z, x*y]
    x = monovec([z, y, x, z^2, y*z, y^2, x*z, x*y, x^2])
    # x*β contains x*y*z, x^2*z, x^2*y which are not present so it show fail
    V = MultivariateMoments.build_system(U', x, sqrt(eps(Float64)))
    @test iszerodimensional(V)
    testelements(V, [[2.0, 2.0, 2.0], [2.0, 2.0, 0.0], [2.0, 0.0, 2.0], [0.0, 2.0, 2.0], [2.0, 0.0, 0.0], [0.0, 2.0, 0.0], [0.0, 0.0, 2.0], [0.0, 0.0, 0.0]], 1e-11)
end

@testset "[HL05] Section 4" begin
    Mod.@polyvar x y
    s3 = sqrt(1/3)
    η = AtomicMeasure([x, y], [0.25, 0.25, 0.25, 0.25], [[-s3, -s3], [-s3, s3], [s3, -s3], [s3, s3]])
    μ = Measure([1/9,     0,     1/9,     0, 1/9,   0,     0,     0,   0, 1/3,   0, 1/3, 0, 0, 1],
                [x^4, x^3*y, x^2*y^2, x*y^3, y^4, x^3, x^2*y, x*y^2, y^3, x^2, x*y, y^2, x, y, 1])
    ν = matmeasure(μ, [1, x, y, x^2, x*y, y^2])
    for lrc in (SVDChol(), ShiftChol(1e-16))
        atoms = extractatoms(ν, 1e-16, lrc)
        @test !isnull(atoms)
        @test get(atoms) ≈ η
    end
end

@testset "[LJP17] Example ?" begin
    Mod.@polyvar x[1:2]
    η = AtomicMeasure(x, [2.], [[1., 0.]])
    μ = Measure([2., 0.0, 1e-6],
                monomials(x, 2))
    ν = matmeasure(μ, monomials(x, 1))
    atoms = extractatoms(ν, 1e-5)
    @test !isnull(atoms)
    @test get(atoms) ≈ η
end

@testset "[LJP17] Example ?" begin
    Mod.@polyvar x[1:2]
    η = AtomicMeasure(x, [2.53267], [[1., 0.]])
    ν = matmeasure([2.53267 -0.0 -5.36283e-19; -0.0 -5.36283e-19 -0.0; -5.36283e-19 -0.0 7.44133e-6], monomials(x, 2))
    atoms = extractatoms(ν, 1e-5)
    @test !isnull(atoms)
    @test get(atoms) ≈ η
end

@testset "[LJP17] Example ?" begin
    Mod.@polyvar x[1:2]
    # η1 is slightly closer to ν than η2
    η1 = AtomicMeasure(x, [14.81069999810012], [[1., 0.2278331868065880]])
    η2 = AtomicMeasure(x, [14.81065219789812], [[1., 0.2278466167919198]])
    η3 = AtomicMeasure(x, [14.81062406873638], [[1., 0.2278545192047005]])
    η4 = AtomicMeasure(x, [14.81063587727590], [[1., 0.2278512018654204]])
    η5 = AtomicMeasure(x, [6.038060135782876e-19,
                            8.48980575400066e-6,
                            0.0011737977570447154,
                            9.72284626287903e-5,
                            14.781765717198045,
                            0.02765476684449834],
                        [[1., 11.15240711893039],
                         [1., 0.991590438508714],
                         [1., 0.5482585022039119],
                         [1., -0.2808541188399676],
                         [1., 0.22799858558381308],
                         [1., 0.12343866254667915]])
    ν = matmeasure([14.8107 3.37426 0.769196 0.175447 0.0400656 0.00917416 0.00211654; 3.37426 0.769196 0.175447 0.0400656 0.00917416 0.00211654 0.000498924; 0.769196 0.175447 0.0400656 0.00917416 0.00211654 0.000498924 0.000125543; 0.175447 0.0400656 0.00917416 0.00211654 0.000498924 0.000125543 3.76638e-5; 0.0400656 0.00917416 0.00211654 0.000498924 0.000125543 3.76638e-5 1.62883e-5; 0.00917416 0.00211654 0.000498924 0.000125543 3.76638e-5 1.62883e-5 1.07817e-5; 0.00211654 0.000498924 0.000125543 3.76638e-5 1.62883e-5 1.07817e-5 1.10658e-5], monomials(x, 6))
    for (ranktol, η) in ((1e-3, η1), (1e-4, η1), (1e-5, η2), (1e-6, η3), (1e-7, η4), (1e-8, η5))
        # With 1e-3 and 1e-4, the rank is detected to be 1
        # With 1e-5, the rank is detected to be 2
        # With 1e-6, the rank is detected to be 3
        # With 1e-7, the rank is detected to be 5
        # With 1e-8, the rank is detected to be 6
        atoms = extractatoms(ν, ranktol)
        @test !isnull(atoms)
        @test get(atoms) ≈ η
    end
    # With 1e-9, the rank is detected to be 7
    atoms = extractatoms(ν, 1e-9)
    @test isnull(atoms)
end

@testset "[LJP17] applied to [JCG14] Example 6.1" begin
    Mod.@polyvar x[1:4]
    η = AtomicMeasure(x, [0.039112791390926646], [[1.0, 4.78736282579504, 1.24375738760842, -1.4231836829978]])
    ν = matmeasure([0.0397951 0.187094 0.0489553 -0.0551816; 0.187094 0.896353 0.232962 -0.265564; 0.0489553 0.232962 0.0614682 -0.0676226; -0.0551816 -0.265564 -0.0676226 0.0837186], monomials(x, 1))
    atoms = extractatoms(ν, 6e-3)
    @test !isnull(atoms)
    @test get(atoms) ≈ η
    atoms = extractatoms(ν, 8e-4)
    @test isnull(atoms)
end
