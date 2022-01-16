abstract type AbstractTikzElement end

struct Canvas
    header::String
    libs::Vector{String}
    colors::Dict{String, Tuple{Int,Int,Int}}
    contents::Vector{AbstractTikzElement}
    props::Dict{String,String}
end

function canvas(f; header="", libs=String[], colors=Dict{String,Tuple{Int,Int,Int}}(), props=Dict{String,String}())
    canvas = Canvas(header, libs, colors, AbstractTikzElement[], props)
    f(canvas)
    return canvas
end

Base.:(>>)(element::AbstractTikzElement, canvas::Canvas) = (push!(canvas.contents, element); element)
Base.:(>>)(element::String, canvas::Canvas) = (push!(canvas.contents, StringElement(element)); element)

function uselib!(canvas::Canvas, lib::String)
    push!(canvas.libs, lib)
    return lib
end
function rgbcolor!(canvas::Canvas, red::Int, green::Int, blue::Int)
    colorname = "color$(autoid!())"
    canvas.colors[colorname] = (red,green,blue)
    return colorname
end
function generate_rgbcolor(name, red, green, blue)
    return "\\definecolor{$name}{RGB}{$red,$green,$blue}"
end

function generate_standalone(libs::Vector, header::String, props::Dict, content::String)
    return """
\\documentclass[crop,tikz]{standalone}
$(join(["\\usepgflibrary{$lib}" for lib in libs], "\n"))
$(header)
\\begin{document}
\\begin{tikzpicture}[$(parse_args(String[], props))]
$content
\\end{tikzpicture}
\\end{document}
"""
end
generate_standalone(canvas::Canvas) = generate_standalone(canvas.libs, canvas.header, canvas.props, join([[generate_rgbcolor(k,v...) for (k,v) in canvas.colors]..., command.(canvas.contents)...], "\n"))

function Base.write(io::IO, canvas::Canvas)
    write(io, generate_standalone(canvas))
end

function writepdf(filename::AbstractString, canvas::Canvas)
    write(filename, canvas)
    run(`latexmk -pdf $filename -output-directory=$(dirname(filename))`)
end

build_props(fname::Symbol, kwargs) = update_props!(fname, Dict{String,String}(), kwargs)
function update_props!(fname::Symbol, dict::Dict, kwargs)
    default_values = TIKZ_DEFAULT_VALUES[fname]
    for (k,v) in kwargs
        if !(haskey(default_values, k) && default_values[k] == v)
            dict[replace(string(k), "_"=>" ")] = _render_val(v)
        end
    end
    return dict
end

function parse_args(args::Vector, kwargs::Dict)  # properties
    return join([filter(!isempty, args)..., ["$k=$(_render_val(v))" for (k,v) in kwargs if !isempty(v)]...], ", ")
end
_render_val(v::Real) = "$(v)cm"  # default unit is `cm`
_render_val(v::String) = v

