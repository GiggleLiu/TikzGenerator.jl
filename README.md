# TikzGenerator

[![Build Status](https://github.com/GiggleLiu/TikzGenerator.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/GiggleLiu/TikzGenerator.jl/actions/workflows/CI.yml?query=branch%3Amain)

Tikz is very powerful in generating graphs in production quality.
But we also notice it does not provide helpful error information, while its control flows is obscure and very slow.
Hence I wrap the tikz library with the following design principles

* not restricting every possibility.
* error/warn user at early stage.
* truncate the feature to minimum, then increase it  gradually, e.g. we can custom many fancy arrows in Tikz, however, we decide to warn user on inputs that not known by us.
* unitless (always in `cm`).