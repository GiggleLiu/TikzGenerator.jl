using TikzGenerator, Test

@testset "canvas" begin
    res = canvas() do c
        circle!(c, 0.3, 0.2, 0.1; shape="circle", draw=rgbcolor!(c, 21, 42, 36))
        push!(c, "jajaja")
    end
    @test res isa Canvas
    @test generate_standalone(res) isa String
    write("test.tex", res)
    @test isfile("test.tex")
    rm("test.tex")
end