using TikzGenerator

function state_machine()
    #circle!(c, x, y, text) = circle(x, y; radius=0.1 annotate=text, fill="red", draw="none", text="white", line_width=0.03) >> c
    node!(c, shape, x, y, text; kwargs...) = vertex(x, y; shape=shape, radius=0.1, annotate=text, fill="red", draw="none", text="white", line_width=0.03) >> c
    edge!(c, a, b, text; kwargs...) = edge(a, b; arrow="-stealth", annotate=text, kwargs...) >> c
    node_distance = 5.6
    image = canvas(libs=["automata", "positioning"], args=["auto"]) do c
        A = node!(c, "initial, state", 0, 0, raw"$q_a$")
        B = node!(c, "state", node_distance/2, node_distance/2, raw"$q_b$")
        C = node!(c, "state", node_distance, 0, raw"$q_c$")
        D = node!(c, "state", node_distance/2, -node_distance/2, raw"$q_d$")
        E = node!(c, "state", node_distance/2, D.path[1].y - node_distance/1.5, raw"$q_e$")
        edge!(c, A, B, "0,1,L")
        edge!(c, A, C, "1,1,R")
        edge!(c, B, B, "1,1,L"; loop="loop above")
        edge!(c, B, C, "0,1,L")
        edge!(c, C, D, "0,1,L")
        edge!(c, C, E, "1,0,R"; bend_left=30)
        edge!(c, D, D, "1,1,R"; loop="loop below")
        edge!(c, D, A, "0,1,R")
        edge!(c, E, A, "1,0,R"; bend_left=30)
    end
    #writepdf(joinpath(dirname(@__DIR__), "_local", "page53.pdf"), image)
    write(joinpath(dirname(@__DIR__), "_local", "page53.tex"), image)
end

state_machine()