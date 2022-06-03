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
    @interface function f(x=2)
        x
    end
    @test f(2.2) == 2.2
    @interface function f(x::Real=2, y=4; z=4)
        z
    end
    @test f(1, z=2) == 2
    @interface function f(x::Real=2,
        y=4, args...; z=4, j::Int, kwargs...)
        z
    end
end