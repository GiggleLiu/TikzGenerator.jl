using TikzGenerator, Test
using TikzGenerator: generate_function, match_function, @interface

@testset "function" begin
    mc, fname, args, ts, body = match_function(:(function f(x)
            x
    end))
    gf = generate_function(mc, fname, args, ts, body)
    @test gf isa Expr
end


@testset "interface" begin
    @interface function f(0<x<3=2)
        x
    end
    @test_throws ArgumentError f(6)
    @test f(2.2) == 2.2
    @interface function f(0<x::Real<3=2, y=4; z>0=4)
        z
    end
    @test_throws ArgumentError f(2, z=-1)
    @test f(1, z=2) == 2
    @interface function f(0<x::Real<3=2,
        y=4, args...; z>0=4, j::Int, kwargs...)
        z
    end
    @test_throws ArgumentError f(2, z=-1)
    @interface function f(x::Real>3, z::Real ∈ [2,3])
        z
    end
    @test_throws ArgumentError f(2, z=-1)
    @test f(2, z=2) == 2
end