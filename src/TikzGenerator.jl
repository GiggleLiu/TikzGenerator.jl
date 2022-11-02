module TikzGenerator

using MLStyle
using TikzPictures: TikzPicture

export rgbcolor!, Node, Line, Mesh, Edg, Canvas, Path, command, canvas, generate_standalone, StringElement, PlainText, uselib!
export Cycle, Controls, annotate, Annotate, autoid!, vizgraph!, writepdf, writesvg
export mesh!, circle!, rectangle!, edge!, vertex!, text!, line!, brace!, curve!, arc!, elbow!
export show_canvas

include("constants.jl")
include("macros.jl")
include("Core.jl")
include("elements.jl")
include("interfaces.jl")
include("alghub.jl")

end
