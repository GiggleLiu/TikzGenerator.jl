export mesh, circle, rectangle, edge, vertex

function mesh(xmin, xmax, ymin, ymax)
    return Path(MoveTo(xmin-1e-3, ymin-1e-3), Grid(xstep=step, ystep=step), MoveTo(xmax, ymax))
end
function circle(x, y, radius; annotate="", id=autoid!(), kwargs...)
    Path(MoveTo(x, y), Circle(radius), Node(annotate=annotate, id=id); minimum_size=radius, inner_sep=0, kwargs...)
end
function rectangle(x, y, width, height; annotate="", id=autoid!(), kwargs...)
    Path(MoveTo(x, y), shape, Node(annotate=annotate, id=id), MoveTo(x+width, y+height); inner_sep=0, kwargs...)
end
function vertex(x, y; shape, annotate="", id=autoid!(), kwargs...)
    Path(MoveTo(x, y), Node(annotate=annotate, id=id; shape=shape, kwargs...))
end
function edge(a, b; annotate="", kwargs...)
    if isempty(annotate)
        Path(a, Edg(;kwargs...), b)
    else
        Path(a, Edg(;kwargs...), Node(annotate=annotate), b)
    end
end

function vizgraph!(c::Canvas, locations::AbstractVector, edges; fills=fill("black", length(locations)),
        texts=fill("", length(locations)), ids=[autoid!() for i=1:length(locations)], minimum_size=0.4,
        draw="", line_width=0.03, edgecolors=fill("black", length(edges)))
    nodes = Node[]
    lines = Line[]
    for i=1:length(locations)
        n = Node(locations[i]...; fill=fills[i], minimum_size=minimum_size, draw=draw, id=ids[i], text=texts[i]) >> c
        push!(nodes, n)
    end
    for (k, (i, j)) in enumerate(edges)
        l = Line(nodes[i], nodes[j], line_width=line_width, draw=edgecolors[k]) >> c
        push!(lines, l)
    end
    return nodes, lines
end
