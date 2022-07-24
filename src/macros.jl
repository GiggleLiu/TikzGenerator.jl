const TIKZ_DEFAULT_VALUES = Dict{Symbol,Dict{Symbol, Any}}()
const ARG_EXTRA_DOCS = Dict{Symbol,String}()

"""
    match_function(ex)

Analyze a function expression, returns a tuple of `(macros, function name, arguments, type parameters (in where {...}), statements in the body)`
"""
function match_function(ex)
    @match ex begin
        :(function $(fname)($(args...)) $(body...) end) ||
        :($fname($(args...)) = $(body...)) => (nothing, fname, args, [], body)
        Expr(:function, :($fname($(args...)) where {$(ts...)}), xbody) => (nothing, fname, args, ts, xbody.args)
        Expr(:macrocall, mcname, line, fdef) => ([mcname, line], match_function(fdef)[2:end]...)
        _ => error("must input a function, got $ex")
    end
end

# generate the reversed function
function generate_function(mc, fname, args, ts, body)
    head = :($fname($(args...)) where {$(ts...)})
    fdef = Expr(:function, head, Expr(:block, body...))
    if mc !== nothing
        fdef = Expr(:macrocall, mc[1], mc[2], fdef)
    end
    return fdef
end

function inspect_arg!(arg, docstrings, kwdocstrings, default_values, argforward, iskw)
    _docstrings = iskw ? kwdocstrings : docstrings
    @match arg begin
        Expr(:parameters, kwargs...) => begin
            Expr(:parameters, [inspect_arg!(kwargs[i], docstrings, kwdocstrings, default_values, argforward, true) for i=1:length(kwargs)]...)
        end
        Expr(:kw, x, val) => begin
            xsym = argname(x)
            _val = unquote(val)
            __val = @match _val begin
                :(@not_tikz_default $line $vv) => vv
                ::Union{String, Number} => begin
                    default_values[xsym] = _val
                    _val
                end
                _ => _val
            end
            rt = Expr(:kw, inspect_arg!(x, docstrings, kwdocstrings, default_values, argforward, iskw), __val)
            # store default values
            _docstrings[end] *= ", default value is `$(_repr(__val))`"
            rt
        end
        Expr(:..., xs) => begin
            push!(_docstrings, "* ...")
            iskw && push!(argforward, arg)
            arg
        end
        :($x::$TYPE) => begin
            push!(_docstrings, "* `$arg`")
            iskw && push!(argforward, Expr(:(=), x, x))
            arg
        end
        ::Symbol => begin
            push!(_docstrings, "* `$arg`")
            iskw && push!(argforward, Expr(:(=), arg, arg))
            arg
        end
    end
end

# fix line break in argument list
unquote(ex) = @match ex begin
    Expr(:block, line, arg) => begin
        @assert line isa LineNumberNode
        unquote(arg)
    end
    _ => ex
end
# fix function call type input arguments
_repr(val) = @match val begin
    ::Expr => string(val)
    _ => repr(val)
end
argname(ex) = @match ex begin
    :($x::$TPYE) => x
    ::Symbol => ex
end

macro interface(ex)
    mc, fname, args, ts, body = match_function(ex)
    docstrings, kwdocstrings = String[], String[]

    # update default values and docstrings
    default_values, argforward = Dict{Symbol,Any}(), Any[]
    for arg in args
        inspect_arg!(arg, docstrings, kwdocstrings, default_values, argforward, false)
    end
    TIKZ_DEFAULT_VALUES[fname] = default_values
    docstring = "Arguments\n---------------\n" * join(docstrings, "\n") * "\n \nKeyword arguments\n-----------------\n" * join(kwdocstrings, "\n")

    fdef = generate_function(mc, fname, args, ts, body)
    return esc(Expr(:block, :(Base.@__doc__ $fdef), :(@doc $docstring $fname)))
end

macro check(ex)
    esc(check_iml(ex))
end

function check_iml(ex)
    @match ex begin
        :($x ∈ $y) ||
        :($x in $y) => :($x ∉ $y && @warn "value of `$($(QuoteNode(x)))`: `$($(x))` is not in $($(y))!")
        :(begin $(args...) end) => :(begin $(check_iml.(args)...) end)
        ::LineNumberNode => ex
    end
end