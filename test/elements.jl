using TikzGenerator, Test

@testset "commands" begin
    n = Node(0.2, 0.5)
    @test command(n) isa String
    m = Node(0.6, 0.5)
    @test command(n) isa String
    l = Path(m, Controls(m, (0.3, 0.4), n), Controls(m, (0.2, 0.3), (0.3, 0.4), n), n, segment, Cycle(); arrow="->", annotate="A")
    @test command(n) isa String
    g = Mesh(0, 10, 0, 10)
    @test command(g) isa String
    s = StringElement("jajaja")
    @test command(s) == "jajaja"
    s = PlainText(20.0, 3.0, "jajaja")
    @test command(s) isa String
    e = Edg("a", "b")
    @test command(e) isa String
    a = annotate(n, "jajaja"; offsetx=0.1, offsety=0.2)
    @test command(a) isa String
end

