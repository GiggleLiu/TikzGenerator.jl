using TikzGenerator, Test
using TikzGenerator: operation_command

@testset "commands" begin
    n = TikzGenerator.Node()
    @test operation_command(n) isa String
    m1 = TikzGenerator.MoveTo(0.6, 0.5)
    @test operation_command(m1) isa String
    m2 = TikzGenerator.MoveToId("1")
    @test operation_command(m2) isa String
    circle = TikzGenerator.Circle(0.3)
    @test operation_command(circle) isa String
    edge = TikzGenerator.Edg()
    @test operation_command(edge) isa String
    line = TikzGenerator.Line()
    @test operation_command(line) isa String
    grid = TikzGenerator.Grid(; xstep=0.1, ystep=0.1)
    @test operation_command(grid) isa String
    controls = TikzGenerator.Controls(TikzGenerator.MoveTo(0.3, 0.4))
    @test operation_command(controls) isa String

    @test_throws AssertionError Node(line_style="soli")
end

