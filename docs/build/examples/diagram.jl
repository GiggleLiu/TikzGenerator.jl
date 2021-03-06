### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 82879d08-3ec6-4791-bd5f-8ded011af8df
# ╠═╡ show_logs = false
using Pkg; Pkg.activate(".")

# ╔═╡ 971be4a7-6a86-4f51-8a3f-2159fc8f29db
using Revise, TikzGenerator

# ╔═╡ 5faaf082-fa93-49d4-9ecc-9e59559c42ad
md"# State machine"

# ╔═╡ d342c309-8468-4109-8f70-9d884b72ed76
function state_machine()
    #circle!(c, x, y, text) = circle(x, y; radius=0.1 annotate=text, fill="red", draw="none", text="white", line_width=0.03) >> c
    node!(c, shape, x, y, text; kwargs...) = vertex!(c, x, y; shape=shape, annotate=text, fill="red", draw="none", text="white", line_width=0.03)
    bond!(c, a, b, text; kwargs...) = edge!(c, a, b; arrow="-stealth", annotate=text, kwargs...)
    node_distance = 5.6
    image = canvas(libs=["automata", "positioning"], args=["auto"]) do c
        A = node!(c, "initial, state", 0, 0, raw"$q_a$")
        B = node!(c, "state", node_distance/2, node_distance/2, raw"$q_b$")
        C = node!(c, "state", node_distance, 0, raw"$q_c$")
        D = node!(c, "state", node_distance/2, -node_distance/2, raw"$q_d$")
        E = node!(c, "state", node_distance/2, -node_distance/2 - node_distance/1.5, raw"$q_e$")
        bond!(c, A, B, "0,1,L")
        bond!(c, A, C, "1,1,R")
        bond!(c, B, B, "1,1,L"; loop="loop above")
        bond!(c, B, C, "0,1,L")
        bond!(c, C, D, "0,1,L")
        bond!(c, C, E, "1,0,R"; bend_left=30)
        bond!(c, D, D, "1,1,R"; loop="loop below")
        bond!(c, D, A, "0,1,R")
        bond!(c, E, A, "1,0,R"; bend_left=30)
    end
end

# ╔═╡ 229ef6c2-d284-4d31-a6e5-a8dd9d7dec12
state_machine()

# ╔═╡ Cell order:
# ╟─5faaf082-fa93-49d4-9ecc-9e59559c42ad
# ╠═82879d08-3ec6-4791-bd5f-8ded011af8df
# ╠═971be4a7-6a86-4f51-8a3f-2159fc8f29db
# ╠═d342c309-8468-4109-8f70-9d884b72ed76
# ╠═229ef6c2-d284-4d31-a6e5-a8dd9d7dec12
