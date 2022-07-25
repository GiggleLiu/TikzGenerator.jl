# Run examples

## Setup
1. You need to have a latex environment as requires by [`TikzPictures`](https://github.com/JuliaTeX/TikzPictures.jl),
2. Install [`Pluto` notebook](https://github.com/fonsp/Pluto.jl).

## Run

Open a julia REPL and type

```julia
julia> using Pluto

julia> Pluto.run(; notebook="examples/blockQCA.jl")
```