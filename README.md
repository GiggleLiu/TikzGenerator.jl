# TikzGenerator

A work in progress Julia package for generating [Tikz](https://en.m.wikipedia.org/wiki/PGF/TikZ) scripts.

(You can star, watch or contribute to this repo (issue or code), but please do not use it before this line has been removed to save your time)

[![Build Status](https://github.com/GiggleLiu/TikzGenerator.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/GiggleLiu/TikzGenerator.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://giggleliu.github.io/TikzGenerator.jl/build/index.html)

Tikz is a professional tool for creating production quality vector graphs in papers.
But its error information is not helpful, its control flows is obscure and very slow.
Hence I wrap the tikz library with the following design principles

* completeness, can do everything allowed in tikz.
* early error, try best to error or warn users at function inputs.
* unitless, always in `cm`.
* Julia control flow instead of slow tikz control flow.
