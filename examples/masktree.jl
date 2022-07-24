using TikzGenerator

function masktree()  # mask tree
    filename = joinpath(dirname(@__DIR__), "_local", "masktree.tex")
    LW = 0.03
    graph = canvas(props=Dict("scale"=>"1.5")) do c
        node!(x, y) = vertex!(c, x, y; minimum_size=0.3, draw="black", shape="circle")
        dx1 = 0.8
        dx2 = 0.5
        dx3 = 0.3
        locs = [(0, 0), (-dx1, 0.6), (dx1, 0.6), (-dx1-dx2, 1.2), (-dx1+dx2, 1.2), (dx1+dx2, 1.2), (dx1-dx2, 1.2), (-dx1-dx2-dx3, 1.8), (-dx1-dx2+dx3, 1.8)]
        dx = dy = 0.0
        nodes = []
        for (x,y) in locs
            push!(nodes, node!(x+dx, -y-dy))
        end
        for (i, j) in [(1, 2), (1,3), (2,4), (2,5), (3,6), (3,7), (4,8), (4,9)]
            line!(c, nodes[i], nodes[j]; arrow="latex-", line_width=LW, draw="black")
        end
        text!(c, nodes[1], raw"$p(\mathbf{e})^*$", offset=(0.0, 0.3))
        text!(c, nodes[4], "\$A\$", offset=(-0.3, 0.0))
        text!(c, nodes[5], "\$B\$", offset=(0.0, -0.3))
        text!(c, nodes[2], "\$C\$", offset=(0.0, 0.3))
        text!(c, nodes[2], "\$*\$", offset=(0.0, -0.3))
        text!(c, dx, -2.2, "\\large (a)")

        dx += 3.6
        nodes = []
        for (x,y) in locs
            push!(nodes, node!(x+dx, -y-dy))
        end
        for (i, j) in [(1, 2), (1,3), (2,4), (2,5), (3,6), (3,7), (4,8), (4,9)]
            line!(c, nodes[i], nodes[j], arrow="-latex", line_width=LW, draw="red")
        end
        text!(c, nodes[1], raw"$\overline{p(\mathbf{e})^*} = 1$", offset=(0.0, 0.3))
        text!(c, nodes[4], "\$\\overline{A}\$", offset=(-0.3, 0.0))
        text!(c, nodes[5], "\$\\overline{B}\$", offset=(0.0, -0.3))
        text!(c, nodes[2], "\$\\overline{C}\$", offset=(0.0, 0.3))
        text!(c, dx, -2.2, "\\large (b)")
    end
    writepdf(filename, graph)
end

masktree()
