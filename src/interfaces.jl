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
