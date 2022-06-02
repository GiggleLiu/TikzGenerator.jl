using TikzGenerator

function udg(filename="_local/udg.svg")
    function node!(c, x, y, style; kwargs...)
        if style == 1
            v = vertex!(c, x, y; shape="circle", minimum_size=0.3, fill="red", draw="none")
            vertex!(c, x, y; shape="circle", minimum_size=3, fill=rgbcolor!(c, 255, 200, 200), draw=rgbcolor!(c, 160, 100, 100), line_width=0.01, dashed=true, opacity=0.4)
        else
            v = vertex!(c, x, y; shape="circle", minimum_size=0.2, fill="white", draw="black", line_width=0.03)
        end
        return v
    end
    locs = [(0, 0), (1, 1), (1, 4), (1,5), (2, 1), (2, 2), (2,3), (2,4),
    (3,0), (3,1), (3,4), (3,5), (4, 0), (4,1), (4,2), (4,3), (4,4), (4,5),
    (5,1), (5,2), (5,5)]
    configs = [1, 0, 0, 1, 0, 1, 0, 0, 0,0,1,0, 
    1,0,0,0,0,0, 0,1,1]
    @assert length(locs) == length(configs)
    n = length(locs)
    can = canvas() do c
        nodelist = []
        for (loc, config) in zip(locs, configs)
            push!(nodelist, node!(c, loc[2], -loc[1], config))
        end
        for i=1:n, j=1:n
            if sum(abs2, locs[i] .- locs[j]) < 1.5^2
                edge!(c, nodelist[i], nodelist[j], line_width=0.03)
            end
        end
        edge!(c, nodelist[1], (1.05, 1.05), arrow="-stealth", line_width=0.03)
        text!(c, 0.2, 0.7, raw"{\Large $r_B$}")
    end
    writesvg(filename, can)
end

udg()