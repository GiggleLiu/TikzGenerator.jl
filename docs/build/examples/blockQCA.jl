### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 21d9466e-7c11-48bb-beea-a50d9c374d7f
# ╠═╡ show_logs = false
using Pkg; Pkg.activate(@__DIR__)

# ╔═╡ 0f03e740-ab67-4319-b53f-d3b31964f004
using Revise, TikzGenerator

# ╔═╡ a284def0-733b-4d39-bb6a-8ee0139823a4
md"# Block Quantum Celluar Automata"

# ╔═╡ 02456437-df3d-4092-bfea-403a1177283b
@enum Σ σ₀ σ₁ □ ■ σₛ sx sy

# ╔═╡ a3101b8d-d832-42db-9468-c8a3d85795bb
function draw_grid!(c, x, y, config::AbstractMatrix; gridsize)
    for i=1:size(config,1)
        for j=1:size(config,2)
            cij = config[i, j]
            color = if cij == ■
                "black"
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

# ╔═╡ e3e0162a-a1c4-48f4-9a90-980323c29cc7
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

# ╔═╡ 799f855a-29f4-4f21-857f-b50bfd3ab3a7
function hadamard()
    canvas() do c
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
end

# ╔═╡ ac97ebe6-fa35-4ad5-a4a4-d352aa4394bd
hadamard()

# ╔═╡ fbfcd394-f11d-4a79-8317-9a59531ad01e
function signal()
    canvas() do c
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
end

# ╔═╡ 1412db39-0450-4b1a-95ff-4fc1f9e5680e
signal()

# ╔═╡ 6f4185fc-875f-457a-8756-a3bd4ef46bc5
function bouncing()
    canvas() do c
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
end

# ╔═╡ 1f389e10-f173-4dbe-8f92-c953d950b5e2
bouncing()

# ╔═╡ 3c844b60-ddab-43e7-8c86-dbe7361251f8
function signal1()
    canvas() do c
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
end

# ╔═╡ ee4e3e9e-ec29-4910-9df4-101d00e895f0
signal1()

# ╔═╡ 9076f502-bdff-4578-9b6a-ef2fd5f6caa1
function cphase()
    canvas() do c
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
end

# ╔═╡ e128f87d-7e1c-4c74-a575-47ade76dbfb2
cphase()

# ╔═╡ 8212cad4-1aa3-4f0b-a504-8255f018ff9b
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

# ╔═╡ cbcaa5c2-40ef-4e10-b5ef-4f85e8143409
function circles(m::Int, n::Int)
    canvas(; libs=["arrows.meta"]) do c
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
    end
end

# ╔═╡ 20deaa55-e28c-4fe5-937f-fc32b5ef1692
circles(6, 6)

# ╔═╡ Cell order:
# ╟─a284def0-733b-4d39-bb6a-8ee0139823a4
# ╠═21d9466e-7c11-48bb-beea-a50d9c374d7f
# ╠═0f03e740-ab67-4319-b53f-d3b31964f004
# ╠═02456437-df3d-4092-bfea-403a1177283b
# ╠═e3e0162a-a1c4-48f4-9a90-980323c29cc7
# ╠═a3101b8d-d832-42db-9468-c8a3d85795bb
# ╠═799f855a-29f4-4f21-857f-b50bfd3ab3a7
# ╠═ac97ebe6-fa35-4ad5-a4a4-d352aa4394bd
# ╠═fbfcd394-f11d-4a79-8317-9a59531ad01e
# ╠═1412db39-0450-4b1a-95ff-4fc1f9e5680e
# ╠═6f4185fc-875f-457a-8756-a3bd4ef46bc5
# ╠═1f389e10-f173-4dbe-8f92-c953d950b5e2
# ╠═3c844b60-ddab-43e7-8c86-dbe7361251f8
# ╠═ee4e3e9e-ec29-4910-9df4-101d00e895f0
# ╠═9076f502-bdff-4578-9b6a-ef2fd5f6caa1
# ╠═e128f87d-7e1c-4c74-a575-47ade76dbfb2
# ╠═cbcaa5c2-40ef-4e10-b5ef-4f85e8143409
# ╠═8212cad4-1aa3-4f0b-a504-8255f018ff9b
# ╠═20deaa55-e28c-4fe5-937f-fc32b5ef1692
