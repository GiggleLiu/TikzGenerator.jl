using TikzGenerator, Test

@testset "canvas" begin
    res = canvas() do c
        Node(0.2, 0.5; draw=rgbcolor!(c, 21, 42, 36)) >> c
        "jajaja" >> c
    end
    @test res isa Canvas
    @test generate_standalone(res) isa String
    write("test.tex", res)
    @test isfile("test.tex")
    rm("test.tex")
end