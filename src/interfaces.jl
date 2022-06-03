function mesh!(canvas::Canvas, xmin, xmax, ymin, ymax, step; draw="black", kwargs...)
    element = Path(MoveTo(xmin-1e-3, ymin-1e-3), Grid(xstep=step, ystep=step), MoveTo(xmax, ymax); draw, kwargs...)
    push!(canvas, element); element
end
function circle!(canvas::Canvas, x, y, radius; annotate="", id=autoid!(), kwargs...)
    element = Path(MoveTo(x, y), Circle(radius), Node(annotate=annotate, id=id); minimum_size=radius, inner_sep=0, kwargs...)
    push!(canvas, element); element
end
function rectangle!(canvas::Canvas, x, y, width, height; annotate="", id=autoid!(), kwargs...)
    element = Path(MoveTo(x, y), Rectangle(), Node(annotate=annotate, id=id), MoveTo(x+width, y+height); inner_sep=0, kwargs...)
    push!(canvas, element); element
end
function vertex!(canvas::Canvas, x, y; shape="", annotate="", id=autoid!(), kwargs...)
    element = Path(MoveTo(x, y), Node(annotate=annotate, id=id; shape=shape, kwargs...))
    push!(canvas, element); element
end
function edge!(canvas::Canvas, a, b; annotate="", kwargs...)
    element = if isempty(annotate)
        Path(a, Edg(;kwargs...), b)
    else
        Path(a, Edg(;kwargs...), Node(annotate=annotate), b)
    end
    push!(canvas, element); element
end

function curve!(canvas::Canvas, locs...; annotate="", kwargs...)
    element = if isempty(annotate)
        Path(locs[1], Controls(locs[2:end-1]...), locs[end]; kwargs...)
    else
        Path(locs[1], Controls(locs[2:end-1]...), locs[end], Node(annotate=annotate); kwargs...)
    end
    push!(canvas, element); element
end

function line!(canvas::Canvas, a, b; annotate="", kwargs...)
    element = if isempty(annotate)
        Path(a, Line(;kwargs...), b)
    else
        Path(a, Line(;kwargs...), Node(annotate=annotate), b)
    end
    push!(canvas, element); element
end
function text!(canvas::Canvas, x, y, str::String; kwargs...)
    vertex!(canvas, x, y; annotate=str, kwargs...)
end

function Base.push!(canvas::Canvas, element)
    push!(canvas.contents, element)
    return canvas
end
function Base.push!(canvas::Canvas, str::String)
    push!(canvas.contents, StringElement(str))
    return canvas
end

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

function brace!(c::Canvas, start::Tuple, stop::Tuple, text::String=""; mirror::Bool=false, draw="black", thick::Bool=true, raise::Real=0.5, text_offset::Real=0.5)
    vec = rotate(normalize(stop .- start), π/2)
    text!(c, midway(start, stop) .+ (mirror ? (-).(vec) : vec) .* (raise + text_offset)..., text)
    edge!(c, start, stop; decoration="{brace,$(mirror ? "mirror," : "")raise=$(raise)cm}",decorate=true, thick, draw)
end
