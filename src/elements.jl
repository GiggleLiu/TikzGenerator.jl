# inject a string directly
struct StringElement <: AbstractTikzElement
    str::String
end
command(s::StringElement) = s.str

struct Node <: AbstractTikzElement
    x::Float64
    y::Float64
    shape::String
    id::String
    annotate::String
    use_as_bounding_box::Bool
    clip::Bool
    props::Dict{String,String}
end

# serve for node id
const instance_counter = Ref(0)
autoid!() = string((instance_counter[] += 1; instance_counter[]))

@interface function Node(x, y;
        shape::String ∈ ["rectangle", "circle", "diamond", "coordinate", "",
            # from package automata
            "initial, state", "state",
        ] = "",
        id::String = autoid!(),

        # text
        annotate::String = "",
        text::String = "black",

        # fill
        fill::String = "",
        fill_opacity::Real = 1,

        # draw
        draw::String = "",
        draw_opacity::Real = 1,
        line_width::Real >= 0 = 0.014,   # in cm, equals to 0.4pt

        # other styles
        clip::Bool = false,
        use_as_bounding_box::Bool = false,
        pattern::String ∈ ["dots", "fivepointed stars", "bricks", ""] = "",
        pattern_color::String = "",

        # snake
        snake::String ∈ ["snake", "saw", "coil", "brace", "bumps", ""] = "",
        segment_aspect::Real=0,
        segment_length::Real=0.2,
        segment_amplitude::Real=0.04,
        line_after_snake::Real=0,

        # transformation
        # we do not introduce shift because this can be done in Julia
        rotate::Real=0,

        inner_sep::Real >= 0 = @not_tikz_default(0),       # in cm
        minimum_size::Real >= 0 = 0,  # in cm
        top_color::String="",           # shading
        bottom_color::String="",
        left_color::String="",
        right_color::String="",
        kwargs...)

    _properties = _remove(_properties, :shape, :id, :annotate)
    return Node(x, y, shape, id, annotate, use_as_bounding_box, clip, build_props(:Node; _properties...))
end
function _remove(props::NamedTuple, args...)
    NamedTuple([k=>getfield(props, k) for k in fieldnames(typeof(props)) if k ∉ args])
end

function command(node::Node)
    return "\\node[$(parse_args([string(node.shape), ifelse(node.clip, "clip", ""), ifelse(node.use_as_bounding_box, "use_as_bounding_box", "")], node.props))] at ($(node.x), $(node.y)) ($(node.id)) {$(node.annotate)};"
end

struct Mesh <: AbstractTikzElement
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64
    props::Dict{String,String}
end

@interface function Mesh(xmin, xmax, ymin, ymax;
        step::Real=1.0,
        draw::String="gray",
        line_width::Real>=0=0.014,
        kwargs...)
    @show _properties
    Mesh(xmin, xmax, ymin, ymax, build_props(:Mesh; _properties...))
end
function command(grid::Mesh)
    return "\\draw[$(parse_args(String[], grid.props))] ($(grid.xmin-1e-3),$(grid.ymin-1e-3)) grid ($(grid.xmax),$(grid.ymax));"
end

struct Cycle end
struct Controls
    start::String
    controls::Vector{String}
    stop::String
    Controls(start, c1, stop) = new(parse_path(start), [parse_path(c1)], parse_path(stop))
    Controls(start, c1, c2, stop) = new(parse_path(start), [parse_path(c1), parse_path(c2)], parse_path(stop))
end

struct Annotate
    anchor::String
    placement::String
    sloped::Bool
    id::String
    text::String
end

@interface function Annotate(;
        anchor::String ∈ ["midway", "near end", "at end", "very near end", "near start", "very near start", "at start"]="midway",
        placement::String ∈ ["above left, above, above right, left, right, below left, below, below right", ""] ="",
        sloped=false,
        id::String=autoid!(),
        text::String=""
    )
    return Annotate(anchor, placement, sloped, id, text)
end
Base.isempty(ann::Annotate) = isempty(ann.text)
function command(ann::Annotate)
    default_values = TIKZ_DEFAULT_VALUES[:Annotate]
    annargs = parse_args([@nodefault(ann.anchor, default_values[:anchor]), @nodefault(ann.placement, default_values[:placement]), ifelse(ann.sloped==default_values[:sloped], "", "sloped")], Dict{String,String}())
    return "node [$annargs] ($(ann.id)) {$(ann.text)}"
end

struct Edg <: AbstractTikzElement
    a::String
    b::String
    arrow::String
    line_style::String
    annotate::Annotate
    loop::String
    props::Dict{String,String}
end

@interface function Edg(a, b; annotate::Union{String,Annotate}="",
        arrow::String ∈ ["->", "<-","<->", "->>", "<<-", 
            "-stealth", "stealth-", "stealth-stealth",
            "-latex", "latex-", "latex-latex",
            "->|", "|<-", "|<->|",
            "-"] ="-",
        0<=line_width::Real<Inf = 0.014,
        line_style::String ∈ ["solid",
            "dashed", "densely dashed", "loosely dashed",
            "dotted", "densely dotted", "loosely dotted",
            "dash dot", "dash dot dot"] ="solid",
        loop::String ∈ ["", "loop", "loop above", "loop below", "loop left", "loop right", "every loop"] = "",
        bend_left::Real=0,
        bend_right::Real=0,
        cap::String ∈ ["rect", "butt", "round"]="butt",
        kwargs...)
    ann = annotate isa String ? Annotate(; anchor="midway", placement="", sloped=false, text=annotate) : annotate
    _properties = _remove(_properties, :arrow, :line_style, :annotate, :loop)
    Edg(parse_path(a), parse_path(b), arrow, line_style, ann, loop, build_props(:Edg; _properties...))
end

function command(edge::Edg)
    default_values = TIKZ_DEFAULT_VALUES[:Edg]
    edgeargs = parse_args([@nodefault(edge.arrow, default_values[:arrow]), @nodefault(edge.loop, default_values[:loop]), @nodefault(edge.line_style, default_values[:line_style])], edge.props)
    isempty(edge.annotate) && return "\\path $(edge.a) edge [$edgeargs] $(edge.b);"
    annotate = command(edge.annotate)
    return "\\path $(edge.a) edge [$edgeargs] $annotate $(edge.b);"
end

struct Line <: AbstractTikzElement
    path::Vector{String}
    arrow::String
    line_style::String
    annotate::Annotate
    props::Dict{String,String}
end

# line width map
# * ultra thin, 0.1pt
# * very thin, 0.2pt
# * thin, 0.4pt
# * semithick, 0.6pt
# * thick, 0.8pt
# * very thick, 1.2pt
# * ultra thick, 1.6pt
# arrow styles: https://latexdraw.com/exploring-tikz-arrows/
# line styles: https://stex.stackexchange.com/questions/45275/tikz-get-values-for-predefined-dash-patterns
# TODO:
# * `dash_phase` and `dash pattern`
@interface function Line(path...; annotate::Union{String,Annotate}="",
        arrow::String ∈ ["->", "<-","<->", "->>", "<<-", 
            "-stealth", "stealth-", "stealth-stealth",
            "-latex", "latex-", "latex-latex",
            "->|", "|<-", "|<->|",
            "-"] ="-",
        0<=line_width::Real<Inf = 0.014,
        line_style::String ∈ ["solid",
            "dashed", "densely dashed", "loosely dashed",
            "dotted", "densely dotted", "loosely dotted",
            "dash dot", "dash dot dot"] ="solid",
        miter_limit::Real>0=10,
        join::String ∈ ["round", "bevel", "miter"]="miter",
        cap::String ∈ ["rect", "butt", "round"]="butt",
        rounded_corners::Real>=0=0,
        kwargs...)
    ann = annotate isa String ? Annotate(; anchor="midway", placement="", sloped=false, text=annotate) : annotate
    _properties = _remove(_properties, :arrow, :line_style, :annotate)
    Line(collect(parse_path.(path)), arrow, line_style, ann, build_props(:Line; _properties...))
end
parse_path(t::Tuple) = "$(t)"
parse_path(n::Node) = "($(n.id))"
parse_path(s::String) = "($s)"
parse_path(s::Cycle) = "cycle"
function parse_path(c::Controls)
    "$(c.start) .. controls $(join(["$c" for c in c.controls], " and ")) .. $(c.stop)"
end
function command(edge::Line)
    default_values = TIKZ_DEFAULT_VALUES[:Line]
    head = "\\draw[$(parse_args([@nodefault(edge.arrow, default_values[:arrow]), @nodefault(edge.line_style, default_values[:line_style])], edge.props))]"
    path = join(edge.path, " -- ")
    annotate = command(edge.annotate)
    isempty(ann) && return "$head $path;"
    return "$head $path $annotate;"
end

struct PlainText <: AbstractTikzElement
    x::Float64
    y::Float64
    text::String
    props::Dict{String,String}
end
@interface function PlainText(x::Real, y::Real, text::String; kwargs...)
    PlainText(x, y, text, build_props(:PlainText; _properties...))
end
function command(text::PlainText)
    "\\node[$(parse_args(String[], text.props))] at ($(text.x), $(text.y)) {$(text.text)};"
end

annotate(node::Node, text; offsetx=0, offsety=0, kwargs...) = PlainText(node.x+offsetx, node.y+offsety, text; kwargs...)

# TODO
# arc: \draw (3mm,0mm) arc (0:30:3mm);  0deg-30deg, radius=3mm
# arc, ellipse: \tikz \draw (0,0) arc (0:315:1.75cm and 1cm);
# parabola: \tikz \draw (0,0) rectangle (1,1) (0,0) parabola (1,1);
# parabola bend: \tikz \draw[x=1pt,y=1pt] (0,0) parabola bend (4,16) (6,12);
# cos, sin: \tikz \draw[x=1.57ex,y=1ex] (0,0) sin (1,1) cos (2,0) sin (3,-1) cos (4,0) (0,1) cos (1,0) sin (2,-1) cos (3,0) sin (4,1);