#!/usr/bin/env bash
# PLATFORM: WINDOWS — parser_x.o from src/parser/parser.x.
# w1812: this helper no longer host-ccs parser_gen.c. The body is
# build_parser_x via ensure_gen_x_o.sh. $1 is the output object.
# $2 is ignored; the source is src/parser/parser.x.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
OUT="${1:-parser_x.o}"
exec bash scripts/ensure_gen_x_o.sh parser_x "$OUT"
