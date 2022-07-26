"""
    mesh!(canvas::Canvas, xmin, xmax, ymin, ymax, step; draw="black", kwargs...)

Draw a mesh.
Check [`Path`](@ref) for `kwargs`.
"""
function mesh!(canvas::Canvas, xmin, xmax, ymin, ymax, step; draw="black", kwargs...)
    element = Path((xmin-1e-3, ymin-1e-3), Grid(xstep=step, ystep=step), (xmax, ymax); draw, kwargs...)
    push!(canvas, element); element
end

"""
    circle!(canvas::Canvas, x::Real, y::Real, radius; kwargs...)
    circle!(canvas::Canvas, xy, radius; annotate="", id=autoid!(), kwargs...)

Draw a circle.
Check [`Path`](@ref) for `kwargs`.
"""
circle!(canvas::Canvas, x::Real, y::Real, radius; kwargs...) = circle!(canvas, Point(x, y), radius; kwargs...)
function circle!(canvas::Canvas, xy, radius; annotate="", id=autoid!(), kwargs...)
    element = Path(xy, Circle(radius), Node(annotate=annotate, id=id); minimum_size=radius, inner_sep=0, kwargs...)
    push!(canvas, element); element
end

"""
    rectangle!(canvas::Canvas, x::Real, y::Real, width, height; kwargs...)
    rectangle!(canvas::Canvas, xy, xy2; annotate="", id=autoid!(), kwargs...)

Draw a rectangle.
Check [`Path`](@ref) for `kwargs`.
"""
rectangle!(canvas::Canvas, x::Real, y::Real, width, height; kwargs...) = rectangle!(canvas, Point(x, y), Point(x+width, y+height); kwargs...)
function rectangle!(canvas::Canvas, xy, xy2; annotate="", id=autoid!(), kwargs...)
    element = Path(xy, Rectangle(), Node(annotate=annotate, id=id), xy2; inner_sep=0, kwargs...)
    push!(canvas, element); element
end

"""
    vertex!(canvas::Canvas, x::Real, y::Real; kwargs...) = vertex!(canvas, Point(x, y); kwargs...)
    vertex!(canvas::Canvas, xy; shape="", annotate="", id=autoid!(), kwargs...)

Draw a vertex.
Check [`Node`](@ref) for `kwargs`.
"""
vertex!(canvas::Canvas, x::Real, y::Real; kwargs...) = vertex!(canvas, Point(x, y); kwargs...)
function vertex!(canvas::Canvas, xy; shape="", annotate="", id=autoid!(), kwargs...)
    element = Path(xy, Node(annotate=annotate, id=id; shape=shape, kwargs...))
    push!(canvas, element); element
end

"""
    edge!(canvas::Canvas, a, b; annotate="", kwargs...)

Draw an edge.
Check [`Edg`](@ref) for `kwargs`.
"""
function edge!(canvas::Canvas, a, b; annotate="", kwargs...)
    element = if isempty(annotate)
        Path(a, Edg(;kwargs...), b)
    else
        Path(a, Edg(;kwargs...), Node(annotate=annotate), b)
    end
    push!(canvas, element); element
end

"""
    curve!(canvas::Canvas, locs...; annotate="", kwargs...)

Draw a curve.
Check [`Path`](@ref) for `kwargs`.
"""
function curve!(canvas::Canvas, locs...; annotate="", kwargs...)
    element = if isempty(annotate)
        Path(locs[1], Controls(locs[2:end-1]...), locs[end]; kwargs...)
    else
        Path(locs[1], Controls(locs[2:end-1]...), locs[end], Node(annotate=annotate); kwargs...)
    end
    push!(canvas, element); element
end

"""
    line!(canvas::Canvas, a, b; annotate="", out=0, in=0, bend_right=0, bend_left=0, kwargs...)

Draw a line.
Check [`Path`](@ref) for `kwargs`.
"""
function line!(canvas::Canvas, a, b; annotate="", out=0, in=0, bend_right=0, bend_left=0, kwargs...)
    element = if isempty(annotate)
        Path(a, Line(; in, out, bend_left, bend_right), b; kwargs...)
    else
        Path(a, Line(; in, out, bend_left, bend_right), Node(annotate=annotate), b; kwargs...)
    end
    push!(canvas, element); element
end

"""
    arc!(canvas::Canvas, center, radius, start, stop; kwargs...)

Draw an arc.
Check [`Path`](@ref) for `kwargs`.
"""
function arc!(canvas::Canvas, center, radius, start, stop; kwargs...)
    element = Path(center, Plus(Polar(radius, start)), Arc(radius, start, stop); kwargs...)
    push!(canvas, element); element
end

"""
    text!(canvas::Canvas, x::Real, y::Real, str::String; kwargs...)
    text!(canvas::Canvas, xy, str::String; offset=(0.0, 0.0), id=autoid!(), kwargs...)

Draw a string.
Check [`Node`](@ref) for `kwargs`.
"""
function text!(canvas::Canvas, x::Real, y::Real, str::String; kwargs...)
    text!(canvas, Point(x, y), str; kwargs...)
end
function text!(canvas::Canvas, xy, str::String; offset=(0.0, 0.0), id=autoid!(), kwargs...)
    if offset == (0.0, 0.0)
        element = Path(xy, Node(annotate=str, id=id; kwargs...))
    else
        element = Path(xy, Plus(Point(offset...)), Node(annotate=str, id=id; kwargs...))
    end
    push!(canvas, element); element
end

function Base.push!(canvas::Canvas, element)
    push!(canvas.contents, element)
    return canvas
end
function Base.push!(canvas::Canvas, str::String)
    push!(canvas.contents, StringElement(str))
    return canvas
end

"""
    vizgraph!(c::Canvas, locations::AbstractVector, edges; fills=fill("black", length(locations)),
        texts=fill("", length(locations)), ids=[autoid!() for i=1:length(locations)], minimum_size=0.4,
        draws=fill("", length(locations)), line_width=0.03, edgecolors=fill("black", length(edges)),
        vertex_line_width=0.03,
       )

Draw a graph.
"""
function vizgraph!(c::Canvas, locations::AbstractVector, edges; fills=fill("black", length(locations)),
        texts=fill("", length(locations)), ids=[autoid!() for i=1:length(locations)], minimum_size=0.4,
        draws=fill("", length(locations)), line_width=0.03, edgecolors=fill("black", length(edges)),
        vertex_line_width=0.03,
       )
    nodes = Path[]
    lines = Path[]
    for i=1:length(locations)
        n = vertex!(c, locations[i]...; shape="circle", fill=fills[i], minimum_size=minimum_size, draw=draws[i], id=ids[i], annotate=texts[i], line_width=vertex_line_width)
        push!(nodes, n)
    end
    for (k, (i, j)) in enumerate(edges)
        l = edge!(c, nodes[i], nodes[j], line_width=line_width, draw=edgecolors[k])
        push!(lines, l)
    end
    return nodes, lines
end

function rotate(vec::Tuple, angle::Real)
    s, c = sincos(angle)
    (c * vec[1] - s * vec[2], s * vec[1] + c * vec[2])
end

function normalize(vec::Tuple)
    n = vec[1]^2 + vec[2]^2
    vec ./ sqrt(n)
end

function midway(start::Tuple, stop::Tuple)
    (start .+ stop) ./ 2
end

"""
    brace!(c::Canvas, start::Tuple, stop::Tuple, text::String=""; mirror::Bool=false, draw="black", thick::Bool=true, raise::Real=0.5, text_offset::Real=0.5)

Draw a curly brace.
"""
function brace!(c::Canvas, start::Tuple, stop::Tuple, text::String=""; mirror::Bool=false, draw="black", thick::Bool=true, raise::Real=0.5, text_offset::Real=0.5)
    vec = rotate(normalize(stop .- start), π/2)
    text!(c, midway(start, stop) .+ (mirror ? (-).(vec) : vec) .* (raise + text_offset)..., text)
    edge!(c, start, stop; decoration="{brace,$(mirror ? "mirror," : "")raise=$(raise)cm}",decorate=true, thick, draw)
end
