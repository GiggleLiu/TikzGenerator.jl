using TikzGenerator, Test

@testset "alghub" begin
    c = canvas() do c
        vertex!(c, 0.2, 0.3; shape="circle")
        vertex!(c, 0.2, 0.3; use_as_bounding_box=true)
    end
    dict = Dict("tex"=>generate_standalone(c))
    println(dict["tex"])
    svg = TikzGenerator.application(dict)["svg"]
    @test svg isa String
end