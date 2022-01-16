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
    text::String
    use_as_bounding_box::Bool
    clip::Bool
    props::Dict{String,String}
end

# serve for node id
const instance_counter = Ref(0)
autoid!() = string((instance_counter[] += 1; instance_counter[]))

@interface function Node(x, y;
        shape::String = "",
        id::String = autoid!(),
        text::String = "",

        # fill
        fill::String = "",
        fill_opacity::Real = 1,

        # draw
        draw::String = "",
        draw_opacity::Real = 1,
        line_width::Real >= 0 = @not_tikz_default(0.03),   # in cm

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

        inner_sep::Real >= 0 = @not_tikz_default(0),       # in cm
        minimum_size::Real >= 0 = 0,  # in cm
        top_color::String="",           # shading
        bottom_color::String="",
        left_color::String="",
        right_color::String="",
        kwargs...)

    _remove!(_properties, :shape, :id, :text)
    return Node(x, y, shape, id, text, use_as_bounding_box, clip, build_props(:Node, _properties))
end
function _remove!(props:: Dict, args...)
    for arg in args
        delete!(props, arg)
    end
end

function command(node::Node)
    return "\\node[$(parse_args([string(node.shape), ifelse(node.clip, "clip", ""), ifelse(node.use_as_bounding_box, "use_as_bounding_box", "")], node.props))] at ($(node.x), $(node.y)) ($(node.id)) {$(node.text)};"
end

struct Mesh <: AbstractTikzElement
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64
    props::Dict{String,String}
end

function Mesh(xmin, xmax, ymin, ymax; step=1.0, draw="gray", line_width=0.03, kwargs...)
    Mesh(xmin, xmax, ymin, ymax, build_props("Mesh"; step="$(step)cm", draw=draw, line_width=line_width, kwargs...))
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
    args::Vector{String}   # e.g. "[midway, above]"
    id::String
    text::String
end
Base.isempty(ann::Annotate) = isempty(ann.text)

struct Line <: AbstractTikzElement
    path::Vector{String}
    arrow::String
    line_style::String
    annotate::Annotate
    props::Dict{String,String}
end
# arrow styles: https://latexdraw.com/exploring-tikz-arrows/
# line styles: https://stex.stackexchange.com/questions/45275/tikz-get-values-for-predefined-dash-patterns
# TODO:
# * `dash_phase` and `dash pattern`
# * `snake=snake`
@interface function Line(path...; annotate::Union{String,Annotate}="",
        arrow::String ∈ ["->", "<-","<->", "->>", "<<-", 
            "-stealth", "stealth-", "stealth-stealth",
            "-latex", "latex-", "latex-latex",
            "->|", "|<-", "|<->|",
            "-"] ="-",
        0<=line_width::Real<Inf = @not_tikz_default(0.03),
        line_style::String ∈ ["solid",
            "dashed", "densely dashed", "loosely dashed",
            "dotted", "densely dotted", "loosely dotted",
            "dash dot", "dash dot dot"] ="solid",
        miter_limit::Real>0=10,
        join::String ∈ ["round", "bevel", "miter"]="miter",
        cap::String ∈ ["rect", "butt", "round"]="butt",
        rounded_corners::Real>=0=0,
        kwargs...)
    ann = annotate isa String ? Annotate(["midway", "above", "sloped"], "", annotate) : annotate
    #props = build_props("Line"; line_width=line_width,
    #        join=join, cap=cap,
    #        miter_limit=miter_limit, rounded_corners=rounded_corners,
    #        kwargs...)
    Line(collect(parse_path.(path)), arrow, line_style, ann, build_props(:Line, _properties))
end
parse_path(t::Tuple) = "$(t)"
parse_path(n::Node) = "($(n.id))"
parse_path(s::String) = "($s)"
parse_path(s::Cycle) = "cycle"
function parse_path(c::Controls)
    "$(c.start) .. controls $(join(["$c" for c in c.controls], " and ")) .. $(c.stop)"
end
function command(edge::Line)
    head = "\\draw[$(parse_args([edge.arrow, edge.line_style], edge.props))]"
    path = join(edge.path, " -- ")
    ann = edge.annotate
    isempty(ann) && return "$head $path;"
    annotate = "node [$(parse_args(ann.args, Dict{String,String}()))] ($(ann.id)) {$(ann.text)}"
    return "$head $path $annotate;"
end

struct PlainText <: AbstractTikzElement
    x::Float64
    y::Float64
    text::String
    props::Dict{String,String}
end
@interface function PlainText(x::Real, y::Real, text::String; kwargs...)
    PlainText(x, y, text, build_props(:PlainText, _properties))
end
function command(text::PlainText)
    "\\node[$(parse_args(String[], text.props))] at ($(text.x), $(text.y)) {$(text.text)};"
end

annotate(node::Node, text; offsetx=0, offsety=0, kwargs...) = PlainText(node.x+offsetx, node.y+offsety, text; kwargs...)