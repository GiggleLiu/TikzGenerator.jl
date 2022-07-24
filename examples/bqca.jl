using TikzGenerator

@enum Σ σ₀ σ₁ □ ■ σₛ sx sy

function draw_state!(c, x, y, config::AbstractMatrix; gridsize)
    m, n = size(config)
    draw_grid!(c, x, y, config; gridsize)
    x_ = x - 0.2
    y += gridsize
    line!(c, (x_, y), (x_, y-n*gridsize); draw="black")
    x_ = x + 0.2 + m*gridsize
    line!(c, (x_, y), (x_+0.2, y-n*gridsize/2); draw="black")
    line!(c, (x_+0.2, y-n*gridsize/2), (x_, y-n*gridsize); draw="black")
end
function draw_grid!(c, x, y, config::AbstractMatrix; gridsize)
    for i=1:size(config,1)
        for j=1:size(config,2)
            cij = config[i, j]
            color = if cij == ■
                "orange"
            else
                "white"
            end
            text = if cij == σ₀
                "0"
            elseif cij == σ₁
                "1"
            elseif cij == σₛ
                "s"
            elseif cij == sx
                "x"
            elseif cij == sy
                "y"
            else
                ""
            end
            rectangle!(c, x+gridsize*(j-1), y-(i-1)*gridsize,
                gridsize, gridsize, annotate=text, fill=color, draw="black", line_width=0.04)
        end
    end
end

function hadamard()
    writesvg("_local/bqca-hadamard.svg", canvas() do c
        gridsize = 0.5
        # the first line
        y0 = 0
        draw_state!(c, 0, y0, [■ □;
                              σ₀ ■]; gridsize)
        text!(c, 2.1, y0, raw"$\mapsto$")
        text!(c, 2.9, y0, raw"{\Large$\frac{1}{\sqrt{2}}$}")
        draw_state!(c, 3.5, y0, [■ σ₀;
                              □ ■]; gridsize)
        text!(c, 5.3, y0, raw"$+$")
        text!(c, 5.9, y0, raw"{\Large $\frac{1}{\sqrt{2}}$}")
        draw_state!(c, 6.5, y0, [■ σ₁;
                            □ ■]; gridsize)
        # the second line
        y0 = -2
        draw_state!(c, 0, y0, [■ □;
                              σ₁ ■]; gridsize)
        text!(c, 2.1, y0, raw"$\mapsto$")
        text!(c, 2.9, y0, raw"{\Large$\frac{1}{\sqrt{2}}$}")
        draw_state!(c, 3.5, y0, [■ σ₀;
                              □ ■]; gridsize)
        text!(c, 5.3, y0, raw"$-$")
        text!(c, 5.9, y0, raw"{\Large $\frac{1}{\sqrt{2}}$}")
        draw_state!(c, 6.5, y0, [■ σ₁;
                            □ ■]; gridsize)
        end
    )
end

function signal()
    writesvg("_local/bqca-signal.svg", canvas() do c
        gridsize = 0.5
        # the first line
        y0 = 0
        x = 0
        draw_state!(c, x, y0, [□ □;
                               σₛ □]; gridsize)
        x += 2.0
        text!(c, x, y0, raw"$\mapsto$")
        x += 1.0
        draw_state!(c, x, y0, [□ σₛ;
                               □ □]; gridsize)
        end
    )
end

function bouncing()
    writesvg("_local/bqca-bouncing.svg", canvas() do c
        gridsize = 0.5
        # the first line
        y0 = 0
        x = 0
        draw_state!(c, x, y0, [■ σₛ;
                               ■ □]; gridsize)
        x += 2.0
        text!(c, x, y0, raw"$\mapsto$")
        x += 1.0
        draw_state!(c, x, y0, [■ □;
                               ■ σₛ]; gridsize)
        end
    )
end

function signal1()
    writesvg("_local/bqca-signal1.svg", canvas() do c
        gridsize = 0.5
        # the first line
        y0 = 0
        x = 0
        draw_state!(c, x, y0, [■ □;
                               σₛ □]; gridsize)
        x += 2.0
        text!(c, x, y0, raw"$\mapsto$")
        x += 1.0
        draw_state!(c, x, y0, [■ σₛ;
                               □ □]; gridsize)
        end
    )
end

function cphase()
    writesvg("_local/bqca-cphase.svg", canvas() do c
        gridsize = 0.5
        # the first line
        y0 = 0
        x = 0
        draw_state!(c, x, y0, [σ₁ □;
                               σ₁ □]; gridsize)
        x += 2.0
        text!(c, x, y0, raw"$\mapsto$")
        x += 1.0
        text!(c, x, y0, raw"{\Large $e^{\frac{i\pi}{4}}$}")
        x += 0.7
        draw_state!(c, x, y0, [□ σ₁;
                               □ σ₁]; gridsize)
        x += 1.7
        text!(c, x, y0, raw", ")

        x += 1.3
        draw_state!(c, x, y0, [sx □;
                               sy □]; gridsize)
        x += 2.0
        text!(c, x, y0, raw"$\mapsto$")
        x += 1.0
        draw_state!(c, x, y0, [□ sy;
                               □ sx]; gridsize)
        x += 2.4
        text!(c, x, y0, raw"$, otherwise$")
        end
    )
end

function circles(m::Int, n::Int)
    writesvg("_local/bqca-circles.svg", canvas(; libs=["arrows.meta"]) do c
        draw_circles!(c, (0, 0), m, n, 0)
        for i=1:2:m
            for j=1:2:n
                text!(c, i-0.5, j-0.5, "U")
            end
        end
        text!(c, n/2-0.5, -1, "(a) even time step")

        x0 = n+1
        draw_circles!(c, (x0, 0), m, n, π)
        for i=2:2:m-1
            for j=2:2:n-1
                text!(c, x0+i-0.5, j-0.5, "U")
            end
        end
        text!(c, x0+n/2-0.5, -1, "(b) odd time step")
    end)
end

function draw_circles!(c, origin, m::Int, n::Int, θ)
    radius = 0.3
    for i=1:m
        for j=1:n
            center = origin .+ ((i-1), (j-1))
            θ_ = θ + atan(j % 2-0.5, i % 2-0.5)
            circle!(c, center..., radius; draw="black", line_width=0.03)
            # arrow
            p0 = center .+ (radius, 0.1)
            line!(c, p0, p0 .+ (0.0, 0.001); draw="black", line_width=0.03, arrow="-latex")
            circle!(c, center .+ (radius * cos(θ_), radius * sin(θ_))..., radius * 0.2; fill="red")
        end
    end
end