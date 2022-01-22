# inject a string directly
struct StringElement <: AbstractTikzElement
    str::String
end
command(s::StringElement) = s.str

# serve for node id
const instance_counter = Ref(0)
autoid!() = string((instance_counter[] += 1; instance_counter[]))

function _remove(props::NamedTuple, args...)
    NamedTuple([k=>getfield(props, k) for k in fieldnames(typeof(props)) if k ∉ args])
end
#=
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
=#

abstract type AbstractOperation end
abstract type AbstractShapeOperation <: AbstractOperation end

struct Circle  <: AbstractShapeOperation
    radius::Float64
end
function command(c::Circle)
    "circle ($(c.radius)cm)"
end

struct Ellipse  <: AbstractShapeOperation
    a::Float64
    b::Float64
end
function command(el::Ellipse)
    "ellipse ($(el.a)cm and $(el.b)cm)"
end

struct Rectangle <: AbstractShapeOperation
end
function command(r::Rectangle)
    "rectangle"
end

struct Coordinate <: AbstractOperation
    @interface function Coordinate(id::String = autoid!())
    end
end
function command(c::Coordinate)
    "coordinate ($(c.id))"
end

struct Node <: AbstractOperation
    anchor::String
    placement::String
    sloped::Bool
    id::String
    text::String
end
@interface function Node(;
        anchor::String ∈ ["midway", "near end", "at end", "very near end", "near start", "very near start", "at start"]="midway",
        placement::String ∈ ["above left, above, above right, left, right, below left, below, below right", ""] ="",
        sloped=false,
        id::String=autoid!(),
        text::String=""
    )
    return Node(anchor, placement, sloped, id, text)
end
Base.isempty(ann::Node) = isempty(ann.text)
function command(ann::Node)
    default_values = TIKZ_DEFAULT_VALUES[:Annotate]
    annargs = parse_args([@nodefault(ann.anchor, default_values[:anchor]), @nodefault(ann.placement, default_values[:placement]), ifelse(ann.sloped==default_values[:sloped], "", "sloped")], Dict{String,String}())
    return "node [$annargs] ($(ann.id)) {$(ann.text)}"
end

struct Cycle <: AbstractOperation end
command(s::Cycle) = "cycle"

struct Grid <: AbstractOperation
    props::Dict{String, String}
end
# style "help lines" is equal to "gray, verythin"
@interface function Grid(; xstep::Real, ystep::Real)
    Grid(build_props(:Grid, _properties...))
end
command(s::Grid) = "grid"

struct Edg <: AbstractOperation
    arrow::String
    color::String
    line_style::String
    loop::String
    props::Dict{String,String}
end
@interface function Edg(;
        arrow::String ∈ ["->", "<-","<->", "->>", "<<-", 
            "-stealth", "stealth-", "stealth-stealth",
            "-latex", "latex-", "latex-latex",
            "->|", "|<-", "|<->|",
            "-"] ="-",
        line_style::String ∈ ["solid",
            "dashed", "densely dashed", "loosely dashed",
            "dotted", "densely dotted", "loosely dotted",
            "dash dot", "dash dot dot"] ="solid",
        loop::String ∈ ["", "loop", "loop above", "loop below", "loop left", "loop right", "every loop"] = "",
        color::String="black",
        0<=line_width::Real<Inf = 0.014,
        bend_left::Real=0,
        bend_right::Real=0,
    )
    _properties = _remove(_properties, :arrow, :line_style, :loop, :color)
    Edg(arrow, color, line_style, loop, build_props(:Edg; _properties...))
end
function command(edge::Edg)
    default_values = TIKZ_DEFAULT_VALUES[:Edg]
    edgeargs = parse_args([@nodefault(edge.arrow, default_values[:arrow]),
                            @nodefault(edge.color, default_values[:color]),
                            @nodefault(edge.line_style, default_values[:line_style]),
                            @nodefault(edge.loop, default_values[:loop])],
                            edge.props)
    return "edge [$edgeargs]"
end

struct Line <: AbstractOperation
    props::Dict{String,String}
end

@interface function Line(; out::Real=0, in::Real=0, bend_right::Real=0, bend_left::Real=0)
    Line(build_props(_properties))
end
command(s::Line) = "to [$(parse_args(String[], s.props))]"

struct Controls <: AbstractOperation
    controls::Vector{String}
    Controls(c1) = new([command(c1)])
    Controls(c1, c2) = new([command(c1), command(c2)])
end

struct Path <: AbstractTikzElement
    path::Vector{String}
    arrow::String
    line_style::String
    use_as_bounding_box::Bool
    clip::Bool
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
@interface function Path(path...;
        arrow::String ∈ ["->", "<-","<->", "->>", "<<-", 
            "-stealth", "stealth-", "stealth-stealth",
            "-latex", "latex-", "latex-latex",
            "->|", "|<-", "|<->|",
            "-"] ="-",
        line_width::Real >= 0 = 0.014,   # in cm, equals to 0.4pt
        line_style::String ∈ ["solid",
            "dashed", "densely dashed", "loosely dashed",
            "dotted", "densely dotted", "loosely dotted",
            "dash dot", "dash dot dot"] ="solid",
        miter_limit::Real>0=10,
        shorten::Tuple{Real, Real} = (0.0, 0.0),
        join::String ∈ ["round", "bevel", "miter"]="miter",
        cap::String ∈ ["rect", "butt", "round"]="butt",
        rounded_corners::Real>=0=0,

        # fill
        fill::String = "",
        fill_opacity::Real = 1,

        # draw
        draw::String = "",
        draw_opacity::Real = 1,

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
    ann = annotate isa String ? Annotate(; anchor="midway", placement="", sloped=false, text=annotate) : annotate
    _properties = _remove(_properties, :arrow, :line_style, :shorten, :clip, :use_as_bounding_box)
    props = build_props(:Path; _properties...)
    props["shorten <"] = "$(shorten[1])cm"
    props["shorten >"] = "$(shorten[2])cm"
    Path(collect(command.(path)), arrow, line_style, use_as_bounding_box, clip, props)
end
command(t::Tuple) = "$(t)"
command(s::String) = "($s)"
function command(c::Controls)
    ".. controls $(join(["$c" for c in c.controls], " and ")) .."
end
function command(path::Path)
    default_values = TIKZ_DEFAULT_VALUES[:Path]
    head = "\\path[$(parse_args([@nodefault(path.arrow, default_values[:arrow]),
                    ifelse(node.clip, "clip", ""),
                    ifelse(node.use_as_bounding_box, "use_as_bounding_box", ""),
                    @nodefault(path.line_style, default_values[:line_style])],
                    path.props))]"
    args = join(path.path, " ")
    return "$head $args;"
end

# TODO
# arc: \draw (3mm,0mm) arc (0:30:3mm);  0deg-30deg, radius=3mm
# arc, ellipse: \tikz \draw (0,0) arc (0:315:1.75cm and 1cm);
# parabola: \tikz \draw (0,0) rectangle (1,1) (0,0) parabola (1,1);
# parabola bend: \tikz \draw[x=1pt,y=1pt] (0,0) parabola bend (4,16) (6,12);
# cos, sin: \tikz \draw[x=1.57ex,y=1ex] (0,0) sin (1,1) cos (2,0) sin (3,-1) cos (4,0) (0,1) cos (1,0) sin (2,-1) cos (3,0) sin (4,1);