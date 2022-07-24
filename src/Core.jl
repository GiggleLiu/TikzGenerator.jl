abstract type AbstractTikzElement end

abstract type AbstractCoordinate end

struct Point <: AbstractCoordinate
    x::Float64
    y::Float64
end
Base.iterate(p::Point, args...) = iterate((p.x, p.y), args...)

struct Polar <: AbstractCoordinate
    radius::Float64
    angle::Float64
end
struct NodeID <: AbstractCoordinate
    id::String
end

struct Canvas
    header::String
    libs::Vector{String}
    colors::Dict{String, Tuple{Int,Int,Int}}
    contents::Vector{AbstractTikzElement}
    args::Vector{String}
    props::Dict{String,String}
end

function canvas(f; header="", libs=String[], colors=Dict{String,Tuple{Int,Int,Int}}(), args=String[], props=Dict{String,String}())
    canvas = Canvas(header, libs, colors, AbstractTikzElement[], args, props)
    f(canvas)
    return canvas
end

function canvas(f, filename::String; kwargs...)
    obj = canvas(f; kwargs...)
    if endswith(filename, ".pdf")
        writepdf(filename, obj)
    elseif endswith(filename, ".svg")
        writesvg(filename, obj)
    else
        write(filename, obj)
    end
end

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

function generate_standalone(libs::Vector, header::String, args::Vector, props::Dict, content::String)
    return """
\\documentclass[crop,tikz]{standalone}
$(join(["\\usetikzlibrary{$lib}" for lib in libs], "\n"))
$(header)
\\begin{document}
\\begin{tikzpicture}[$(parse_args(args, props))]
$content
\\end{tikzpicture}
\\end{document}
"""
end
generate_standalone(canvas::Canvas) = generate_standalone(canvas.libs, canvas.header, canvas.args, canvas.props, join([[generate_rgbcolor(k,v...) for (k,v) in canvas.colors]..., command.(canvas.contents)...], "\n"))

function Base.write(io::IO, canvas::Canvas)
    write(io, generate_standalone(canvas))
end

function writepdf(filename::AbstractString, canvas::Canvas)
    tex = filename[1:end-4]*".tex"
    write(tex, canvas)
    run(`latexmk -pdf $tex -output-directory=$(dirname(filename))`)
end

function writesvg(filename::AbstractString, canvas)
    pdf = filename[1:end-4]*".pdf"
    writepdf(pdf, canvas)
    run(`pdf2svg $pdf $filename`)
end

build_props(fname::Symbol; kwargs...) = update_props!(fname, Dict{String,String}(); kwargs...)
function update_props!(fname::Symbol, dict::Dict; kwargs...)
    default_values = TIKZ_DEFAULT_VALUES[fname]
    for (k,v) in kwargs
        if !(haskey(default_values, k) && default_values[k] == v)
            dict[replace(string(k), "_"=>" ")] = _render_val(k, v)
        end
    end
    return dict
end

build_args(fname::Symbol; kwargs...) = update_args!(fname, String[]; kwargs...)
function update_args!(fname::Symbol, args::AbstractVector{String}; kwargs...)
    default_values = TIKZ_DEFAULT_VALUES[fname]
    for (k,v) in kwargs
        # boolean variables are signals
        if v isa Bool && v
            push!(args, replace(string(k), "_"=>" "))
        elseif !(haskey(default_values, k) && default_values[k] == v)
            push!(args, string(v))
        end
    end
    return args
end

function parse_args(args::Vector, kwargs::Dict)  # properties
    # NOTE: booleans are flag
    return join([filter(!isempty, args)..., [v isa Bool ? "$k" : "$k=$(_render_val(k, v))" for (k,v) in kwargs if !isempty(v)]...], ", ")
end
function _render_val(k, v::Real)
    if k ∈ [:line_width, :minimum_size, :inner_sep, :text_width, :radius]
        "$(v)cm"  # default unit is `cm`
    else
        string(v)
    end
end
_render_val(k, v::String) = v

