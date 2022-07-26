using Pkg
Pkg.activate(@__DIR__)
using TikzGenerator
using Documenter
using DocThemeIndigo
using PlutoStaticHTML

example_pages = let
    """Run all Pluto notebooks (".jl" files) in `notebook_dir` and write outputs to HTML files."""
    notebook_dir = joinpath(pkgdir(TikzGenerator), "examples")
    target_dir = joinpath(pkgdir(TikzGenerator), "docs", "src", "examples")
    cp(notebook_dir, target_dir; force=true)
    # instantiate copied notebook dir
    Pkg.activate(target_dir)
    Pkg.develop(; path=dirname(@__DIR__))
    Pkg.instantiate()
    @info "Building examples"
    # Evaluate notebooks in the same process to avoid having to recompile from scratch each time.
    # This is similar to how Documenter and Franklin evaluate code.
    # Note that things like method overrides and other global changes may leak between notebooks!
    use_distributed = true
    output_format = documenter_output
    bopts = BuildOptions(target_dir; use_distributed, output_format)
    build_notebooks(bopts)
    Pkg.activate(@__DIR__)
    pages = String[]
    for page in readdir(target_dir)
        if endswith(page, ".md")
            push!(pages, joinpath("examples", page))
        end
    end
    pages
end

indigo = DocThemeIndigo.install(TikzGenerator)
DocMeta.setdocmeta!(TikzGenerator, :DocTestSetup, :(using TikzGenerator); recursive=true)

makedocs(;
    modules=[TikzGenerator],
    authors="Jinguo Liu",
    repo="https://github.com/GiggleLiu/TikzGenerator.jl/blob/{commit}{path}#{line}",
    sitename="TikzGenerator.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://GiggleLiu.github.io/TikzGenerator.jl",
        assets=String[indigo],
    ),
    pages=[
        "Home" => "index.md",
        "Examples" => example_pages,
        "References" => "ref.md",
    ],
    doctest=false,
)

deploydocs(;
    repo="github.com/GiggleLiu/TikzGenerator.jl",
)
