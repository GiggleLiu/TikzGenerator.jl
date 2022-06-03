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
    id::String
    annotate::String
    args::Vector{String}
    props::Dict{String, String}
end
@interface function Node(;
        shape::String = "",
        anchor::String ="midway",
        placement::String ="",
        sloped=false,
        id::String=autoid!(),
        annotate::String="",
        fill::String="",
        draw::String="",
        text::String="",
        line_width::Real=0.014,
        minimum_size::Real=0,
        line_style::String="solid",
        opacity::Real=1,
        align::String="center",
        text_width::Real=0,
        use_as_bounding_box::Bool=false,
        inner_sep::Real = 0.140584,  # in cm, 0.3333em
        #radius::Real=0.0   #
    )
    @check begin
        anchor ∈ anchor_styles
        line_style ∈ line_styles
        placement ∈ placement_styles
        align ∈ align_styles
    end
    args = build_args(:Node; anchor, placement, sloped, shape, line_style, use_as_bounding_box)
    props = build_props(:Node; fill, draw, text, line_width, minimum_size, opacity, align, text_width, inner_sep)
    return Node(id, annotate, args, props)
end

function operation_command(node::Node)
    annargs = parse_args(node.args, node.props)
    return "node($(node.id)) [$annargs] {$(node.annotate)}"
end

struct Cycle <: AbstractOperation end
operation_command(s::Cycle) = "cycle"

struct Grid <: AbstractOperation
    props::Dict{String, String}
end
# style "help lines" is equal to "gray, verythin"
@interface function Grid(; xstep::Real, ystep::Real)
    Grid(build_props(:Grid; xstep, ystep))
end
operation_command(g::Grid) = "grid [$(parse_args(String[], g.props))]"

struct Edg <: AbstractOperation
    args::Vector{String}
    props::Dict{String,String}
end
@interface function Edg(;
        arrow::String ="-",
        line_style::String ="solid",
        loop::String = "",
        draw::String="black",
        line_width::Real = 0.014,
        bend_left::Real=0,
        bend_right::Real=0,
    )
    @check begin
        arrow ∈ arrow_styles
        line_style ∈ line_styles
        loop ∈ loop_styles
    end
    Edg(build_args(:Edg; arrow, line_style, loop, draw), build_props(:Edg; line_width, bend_left, bend_right))
end
function operation_command(edge::Edg)
    edgeargs = parse_args(edge.args, edge.props)
    return "edge [$edgeargs]"
end

struct Line <: AbstractOperation
    args::Vector{String}
    props::Dict{String,String}
end

@interface function Line(; out::Real=0, in::Real=0, bend_right::Real=0, bend_left::Real=0)
    Line(String[], build_props(:Line; out, in, bend_right, bend_left))
end
operation_command(s::Line) = "to [$(parse_args(String[], s.props))]"

struct Controls <: AbstractOperation
    controls::NTuple{M,AbstractOperation} where M
    Controls(c1) = new((render_id(c1),))
    Controls(c1, c2) = new((render_id(c1), render_id(c2)))
end

struct Path <: AbstractTikzElement
    path::NTuple{M,AbstractOperation} where M
    args::Vector{String}
    props::Dict{String,String}
    function Path(path::NTuple{M,AbstractOperation} where M, args::Vector{String}, props::Dict{String, String})
        new(path, args, props)
    end
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
        arrow::String ="-",
        line_width::Real = 0.014,   # in cm, equals to 0.4pt
        line_style::String = "solid",
        miter_limit::Real=10,
        shape::String="",
        shorten_left::Real = 0.0,
        shorten_right::Real = 0.0,
        join::String ="miter",
        cap::String ="butt",
        rounded_corners::Real=0,

        # fill
        fill::String = "",
        fill_opacity::Real = 1,

        # draw
        draw::String = "",
        draw_opacity::Real = 1,
        bend_left::Real = 0,
        bend_right::Real = 0,

        # other styles
        clip::Bool = false,
        use_as_bounding_box::Bool = false,
        pattern::String = "",
        pattern_color::String = "",

        # snake
        snake::String = "",
        segment_aspect::Real=0,
        segment_length::Real=0.2,
        segment_amplitude::Real=0.04,
        line_after_snake::Real=0,

        # transformation
        # we do not introduce shift because this can be done in Julia
        rotate::Real=0,

        inner_sep::Real = 0.140584,  # in cm, 0.3333em
        minimum_size::Real = 0,  # in cm
        top_color::String="",           # shading
        bottom_color::String="",
        left_color::String="",
        right_color::String=""
        )
    @check begin
        arrow ∈ arrow_styles
        line_style ∈ line_styles
        join ∈ join_styles
        snake ∈ snake_styles
        pattern ∈ pattern_styles
    end
    args = build_args(:Path; arrow, shape, clip, line_style, use_as_bounding_box)
    props = build_props(:Path;
        miter_limit, shorten_right, shorten_left, line_width,  # positional
        cap, rounded_corners, bend_left, bend_right,
        fill, fill_opacity, draw, draw_opacity, pattern_color,
        snake, segment_amplitude, segment_aspect, segment_length, line_after_snake,
        rotate,
        inner_sep, minimum_size, top_color, bottom_color, left_color, right_color,
    )
    Path(render_id.(path), args, props)
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
    ".. controls $(join([operation_command(c) for c in c.controls], " and ")) .."
end
function command(path::Path)
    default_values = TIKZ_DEFAULT_VALUES[:Path]
    props = copy(path.props)

    # replace special names
    if haskey(props, "shorten_right")
        props["shorten >"] = pop!(props, "shorten_right")
    end
    if haskey(props, "shorten_left")
        props["shorten <"] = pop!(props, "shorten_left")
    end

    head = "\\path[$(parse_args(path.args, props))]"
    args = join(operation_command.(path.path), " ")
    return "$head $args;"
end
nodefault(a, b) = ifelse(a == b, "", a)

# TODO
# arc: \draw (3mm,0mm) arc (0:30:3mm);  0deg-30deg, radius=3mm
# arc, ellipse: \tikz \draw (0,0) arc (0:315:1.75cm and 1cm);
# parabola: \tikz \draw (0,0) rectangle (1,1) (0,0) parabola (1,1);
# parabola bend: \tikz \draw[x=1pt,y=1pt] (0,0) parabola bend (4,16) (6,12);
# cos, sin: \tikz \draw[x=1.57ex,y=1ex] (0,0) sin (1,1) cos (2,0) sin (3,-1) cos (4,0) (0,1) cos (1,0) sin (2,-1) cos (3,0) sin (4,1);
