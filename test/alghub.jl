using TikzGenerator, Test

@testset "alghub" begin
    c = canvas() do c
        vertex!(c, 0.2, 0.3; shape="circle")
    end
    dict = Dict("tex"=>generate_standalone(c))
    svg = TikzGenerator.application(dict)["svg"]
    @test svg isa String
end