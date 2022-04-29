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

abstract type AbstractOperation end
abstract type AbstractShapeOperation <: AbstractOperation end

struct MoveTo  <: AbstractOperation
    x::Float64
    y::Float64
end
operation_command(t::MoveTo) = "$((t.x,t.y))"
struct MoveToId  <: AbstractOperation
    id::String
end
function operation_command(c::MoveToId)
    "($(c.id))"
end
struct Circle  <: AbstractShapeOperation
    radius::Float64
end
function operation_command(c::Circle)
    "circle ($(c.radius)cm)"
end

struct Ellipse  <: AbstractShapeOperation
    a::Float64
    b::Float64
end
function operation_command(el::Ellipse)
    "ellipse ($(el.a)cm and $(el.b)cm)"
end

struct Rectangle <: AbstractShapeOperation
end
function operation_command(r::Rectangle)
    "rectangle"
end

struct Coordinate <: AbstractShapeOperation
    @interface function Coordinate(id::String = autoid!())
    end
end
function operation_command(c::Coordinate)
    "coordinate ($(c.id))"
end

struct Node <: AbstractOperation
    shape::String
    anchor::String
    placement::String
    sloped::Bool
    id::String
    annotate::String
    props::Dict{String, String}
end
@interface function Node(;
        shape::String = "",
        anchor::String ∈ ["midway", "near end", "at end", "very near end", "near start", "very near start", "at start"]="midway",
        placement::String ∈ ["above left, above, above right, left, right, below left, below, below right", ""] ="",
        sloped=false,
        id::String=autoid!(),
        annotate::String="",
        kwargs...
    )
    _properties = _remove(_properties, :shape, :annotate, :id, :anchor, :placement, sloped)
    props = build_props(:Node; _properties...)
    return Node(shape, anchor, placement, sloped, id, annotate, props)
end
function operation_command(node::Node)
    default_values = TIKZ_DEFAULT_VALUES[:Node]
    annargs = parse_args([@nodefault(node.anchor, default_values[:anchor]),
            @nodefault(node.placement, default_values[:placement]),
            @nodefault(node.shape, default_values[:shape]),
            ifelse(node.sloped==default_values[:sloped], "", "sloped")],
            node.props)
    return "node($(node.id)) [$annargs] {$(node.annotate)}"
end

struct Cycle <: AbstractOperation end
operation_command(s::Cycle) = "cycle"

struct Grid <: AbstractOperation
    props::Dict{String, String}
end
# style "help lines" is equal to "gray, verythin"
@interface function Grid(; xstep::Real, ystep::Real)
    Grid(build_props(:Grid, _properties...))
end
operation_command(g::Grid) = "grid [$(parse_args(String[], g.props))]"

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
function operation_command(edge::Edg)
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
    Line(build_props(:Line; _properties...))
end
operation_command(s::Line) = "to [$(parse_args(String[], s.props))]"

struct Controls <: AbstractOperation
    controls::Vector{String}
    Controls(c1::AbstractOperation) = new([operation_command(c1)])
    Controls(c1::AbstractOperation, c2::AbstractOperation) = new([operation_command(c1), operation_command(c2)])
end

struct Path <: AbstractTikzElement
    path::NTuple{M,AbstractOperation} where M
    shape::String
    arrow::String
    line_style::String
    use_as_bounding_box::Bool
    clip::Bool
    shorten_right::Float64
    shorten_left::Float64
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
        shape::String="",
        shorten_left::Real = 0.0,
        shorten_right::Real = 0.0,
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
    _properties = _remove(_properties, :arrow, :line_style, :shorten_left, :shorten_right, :clip, :use_as_bounding_box, :shape)
    props = build_props(:Path; _properties...)
    Path(render_id.(path), shape, arrow, line_style, use_as_bounding_box, clip, shorten_left, shorten_right, props)
end
render_id(x) = x
render_id(x::String) = MoveToId(x)
render_id(x::Tuple) = MoveTo(x...)
function render_id(x::Path)
    for seg in x.path
        if hasfield(typeof(seg), :id)
            return MoveToId(seg.id)
        end
    end
    error("can not find any id in path: $(x)")
end
function operation_command(c::Controls)
    ".. controls $(join(["$c" for c in c.controls], " and ")) .."
end
function command(path::Path)
    default_values = TIKZ_DEFAULT_VALUES[:Path]
    props = copy(path.props)
    if path.shorten_right !== default_values[:shorten_right]
        props["shorten >"] = path.shorten_right
    end
    if path.shorten_left !== default_values[:shorten_left]
        props["shorten <"] = path.shorten_left
    end
    @show props
    head = "\\path[$(parse_args([@nodefault(path.arrow, default_values[:arrow]),
                    @nodefault(path.shape, default_values[:shape]),
                    ifelse(path.clip, "clip", ""),
                    ifelse(path.use_as_bounding_box, "use_as_bounding_box", ""),
                    @nodefault(path.line_style, default_values[:line_style])],
                    props))]"
    args = join(operation_command.(path.path), " ")
    return "$head $args;"
end

# TODO
# arc: \draw (3mm,0mm) arc (0:30:3mm);  0deg-30deg, radius=3mm
# arc, ellipse: \tikz \draw (0,0) arc (0:315:1.75cm and 1cm);
# parabola: \tikz \draw (0,0) rectangle (1,1) (0,0) parabola (1,1);
# parabola bend: \tikz \draw[x=1pt,y=1pt] (0,0) parabola bend (4,16) (6,12);
# cos, sin: \tikz \draw[x=1.57ex,y=1ex] (0,0) sin (1,1) cos (2,0) sin (3,-1) cos (4,0) (0,1) cos (1,0) sin (2,-1) cos (3,0) sin (4,1);
