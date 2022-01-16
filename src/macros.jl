using MatchCore

const TIKZ_DEFAULT_VALUES = Dict{Symbol,Dict{Symbol, Any}}()
const ARG_EXTRA_DOCS = Dict{Symbol,String}()

"""
    match_function(ex)

Analyze a function expression, returns a tuple of `(macros, function name, arguments, type parameters (in where {...}), statements in the body)`
"""
function match_function(ex)
    @smatch ex begin
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

function checkarg(ex, exval, x, xval)
    if !exval
        throw(ArgumentError("Argument verification fail, expect `$(ex)`, got `$x = $xval`."))
    end
end

function inspect_arg!(arg, docstrings, kwdocstrings, verifiers, default_values, argnames)
    @smatch arg begin
        Expr(:parameters, kwargs...) => begin
            Expr(:parameters, [inspect_arg!(kwargs[i], kwdocstrings, docstrings, verifiers, default_values, argnames) for i=1:length(kwargs)]...)
        end
        Expr(:kw, x, val) => begin
            xsym = argname(x)
            push!(argnames, xsym)
            _val = unquote(val)
            __val = @smatch _val begin
                :(@not_tikz_default $line $vv) => vv
                ::Union{String, Number} => begin
                    default_values[xsym] = _val
                    _val
                end
                _ => _val
            end
            rt = Expr(:kw, inspect_arg!(x, docstrings, kwdocstrings, verifiers, default_values, argnames), __val)
            # store default values
            docstrings[end] *= ", default value is `$(_repr(__val))`"
            rt
        end
        #:($x=$val) => :($(inspect_arg!(x, docstrings, verifiers)) = $val)
        Expr(:comparison, a, op1, x, op2, b) ||
        :($x < $a) || :($x <= $a) || :($x > $a) || :($x >= $a) ||
        :($x ∈ $y) || :($x in $y) => begin
            xx = argname(x)
            aarg = comparename(arg)
            d = "* `$x` s.t. `$(aarg)`"
            # fetch extra docstrings
            if haskey(ARG_EXTRA_DOCS, xx)
                d *= ", $(ARG_EXTRA_DOCS[xx])"
            end
            push!(docstrings, d)
            push!(verifiers, :($checkarg($(QuoteNode(aarg)), $aarg, $(QuoteNode(xx)), $xx)))
            x
        end
        Expr(:..., xs) => begin
            push!(docstrings, "* ...")
            arg
        end
        :($x::$TYPE) => begin
            push!(docstrings, "* `$arg`")
            arg
        end
        ::Symbol => begin
            push!(docstrings, "* `$arg`")
            arg
        end
    end
end

# fix line break in argument list
unquote(ex) = @smatch ex begin
    Expr(:block, line, arg) => begin
        @assert line isa LineNumberNode
        unquote(arg)
    end
    _ => ex
end
# fix function call type input arguments
_repr(val) = @smatch val begin
    ::Expr => string(val)
    _ => repr(val)
end

argname(ex) = @smatch ex begin
    Expr(:comparison, a, op1, x, op2, b) || :($op($x, $a)) => argname(x)
    :($x::$TPYE) => x
    ::Symbol => ex
end
comparename(ex) = @smatch ex begin
    Expr(:comparison, a, op1, x, op2, b) => Expr(:comparison, a, op1, argname(x), op2, b)
    :($op($x, $a)) => :($op($(argname(x)), $a))
end

macro interface(ex)
    mc, fname, args, ts, body = match_function(ex)
    docstrings, kwdocstrings, verifiers = String[], String[], Expr[]
    default_values, argnames = Dict{Symbol,Any}(), Symbol[]
    new_args = [inspect_arg!(arg, docstrings, kwdocstrings, verifiers, default_values, argnames) for arg in args]
    TIKZ_DEFAULT_VALUES[fname] = default_values
    docstring = "Arguments\n---------------\n" * join(docstrings, "\n") * "\n \nKeyword arguments\n-----------------\n" * join(kwdocstrings, "\n")
    kwargs = Expr(:call, :Dict, [Expr(:call, :(=>), QuoteNode(argname), argname) for argname in argnames]...)
    new_body = [verifiers..., :(_properties = $kwargs), body...]
    fdef = generate_function(mc, fname, new_args, ts, new_body)
    return esc(Expr(:block, :(Base.@__doc__ $fdef), :(@doc $docstring $fname)))
end