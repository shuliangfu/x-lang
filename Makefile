# X language root Makefile — help-only (Track MG 11.0.4).
#
# Authority for product entry: ./xbuild  →  ./xlang-build.sh  (G.7 single body).
# This file must not grow build logic. Prefer:
#   ./xbuild build | test | clean | help
# Implementation-layer dep graph remains compiler/Makefile until 11.3.
# PLATFORM: SHARED

.DEFAULT_GOAL := help

.PHONY: help

help:
	@echo "X language: root make is help-only (Track MG 11.0.4)."
	@echo "  preferred:  ./xbuild <target>"
	@echo "  same body:  ./xlang-build.sh <target>   (G.7)"
	@echo "  example:    ./xbuild build"
	@echo "              ./xbuild test"
	@echo "              ./xbuild clean"
	@echo ""
	@./xbuild help

# Compatibility only: forward leftover goals so old muscle memory does not break.
# Not the product authority — prefer typing ./xbuild <target> directly.
# kernel-build still needs make-var passthrough (X= / ELF=).
%:
	@echo "note: root Makefile is help-only; forwarding 'make $@' → ./xbuild $@" >&2
	@echo "      prefer: ./xbuild $@" >&2
	@X="$(X)" ELF="$(ELF)" ./xbuild $@
