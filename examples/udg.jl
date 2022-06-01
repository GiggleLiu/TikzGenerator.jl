using TikzGenerator

function udg()
    function node!(c, x, y, style; kwargs...)
        vertex!(c, x, y; shape="circle", radius=0.5, annotate=text, fill="#FFCCCC", draw="#FFAAAA", line_width=0.01, dashed=true)
        vertex!(c, x, y; shape="circle", radius=0.1, annotate=text, fill="red", draw="none", line_width=0.03)
    end
    canvas() do c
    end
end

udg()