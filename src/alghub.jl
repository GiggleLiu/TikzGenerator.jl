function application(dict)
    data = dict["tex"]
    filename = tempname()
    tex = filename * ".tex"
    pdf = filename * ".pdf"
    svg = filename * ".svg"
    write(tex, data)
    run(`latexmk -pdf $tex -output-directory=$(dirname(tex))`)
    run(`pdf2svg $pdf $svg`)
    Dict("svg"=>read(svg, String))
end
