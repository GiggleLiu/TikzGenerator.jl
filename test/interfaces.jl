using Test, TikzGenerator

@testset "interfaces" begin
    can = canvas() do c
        x = vertex!(c, 0.2, 0.5)
        y = vertex!(c, 0.2, 0.9)
        curve!(c, x, (0.3, 0.6), y)
        edge!(c, x, y)
    end
    @test can isa Canvas
end