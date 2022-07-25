using TikzGenerator
using Test

@testset "macros" begin
    include("macros.jl")
end

@testset "Core" begin
    include("Core.jl")
end

@testset "elements" begin
    include("elements.jl")
end

# @testset "alghub" begin
#     include("alghub.jl")
# end