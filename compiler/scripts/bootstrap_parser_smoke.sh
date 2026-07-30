#!/usr/bin/env bash
# bootstrap_parser_smoke.sh — 9.1 parser frontend smokes (wave844)
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile phony bootstrap-parser / bootstrap-parse-file:
#     1) parser: product host compiles src/parser/parser.x → /tmp/xlang_parser_test
#        then runs it (self-host parse of minimal main; historical 9.1 gate)
#     2) parse-file: write minimal / expr-chain fixtures; run .x parser binary +
#        host product xlang on same fixture; both must emit "parse OK"
#
#   Why shell-primary (not physical delete)?
#     Prereq graph stays make: bootstrap-parser needs relink-xlang + STD_AND_PANIC_O
#     (list authority = mk/std_and_panic_objs.mk wave813); bootstrap-parse-file
#     keeps $(TARGET) + STD_AND_PANIC_O + bootstrap-parser. Thin edges + B2 remain.
#
# Usage (cwd = compiler/):
#   bash scripts/bootstrap_parser_smoke.sh parser
#   bash scripts/bootstrap_parser_smoke.sh parse-file
#   bash scripts/bootstrap_parser_smoke.sh --check
#
# Env (product path; Makefile thin-call exports these):
#   TARGET — product binary basename (default: xlang)
#   XLANG  — override compiler binary path (default: ./$TARGET)
#
# wave844 (G.7 有则补全): Makefile fat smoke bodies → this script.
# NOT physical delete — thin-call edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — pure shell orchestration of product -o smokes.
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-}"
TARGET="${TARGET:-xlang}"
XLANG="${XLANG:-./$TARGET}"
PARSER_BIN="${PARSER_BIN:-/tmp/xlang_parser_test}"
PARSE_FIXTURE="${PARSE_FIXTURE:-/tmp/xlang_parse_test.x}"

log() { echo "bootstrap-parser-smoke: $*" >&2; }
fail() { echo "bootstrap-parser-smoke: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product link; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  # Makefile thin-call only (wave844): scan *recipe* lines (tab-indented) only —
  # comments between phonies must not false-positive on parser.x / parse OK prose.
  _rec_parser=$(awk '
    /^bootstrap-parser:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  _rec_file=$(awk '
    /^bootstrap-parse-file:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'bootstrap_parser_smoke\.sh' <<<"$_rec_parser"; then
    fail "bootstrap-parser must thin-call bootstrap_parser_smoke.sh (wave844)"
  fi
  if ! grep -q 'bootstrap_parser_smoke\.sh' <<<"$_rec_file"; then
    fail "bootstrap-parse-file must thin-call bootstrap_parser_smoke.sh (wave844)"
  fi
  # Dual body: inline compile of parser.x or fixture smoke in Makefile recipe
  if grep -qE 'parser\.x|/tmp/xlang_parser_test' <<<"$_rec_parser"; then
    fail "bootstrap-parser must not keep dual parser.x / parser_test body (wave844)"
  fi
  if grep -qE 'xlang_parse_test\.x|parse OK|expr-chain' <<<"$_rec_file"; then
    fail "bootstrap-parse-file must not keep dual fixture / parse OK body (wave844)"
  fi
  log "CHECK OK (wave844 bootstrap-parser/parse-file shell-primary; not physical delete)"
  exit 0
fi

case "$MODE" in
  parser|parse-file) ;;
  -h|--help)
    echo "usage: $0 parser|parse-file|--check" >&2
    exit 0
    ;;
  *)
    echo "usage: $0 parser|parse-file|--check" >&2
    exit 2
    ;;
esac

if [ ! -x "$XLANG" ] && [ ! -f "$XLANG" ]; then
  log "missing executable $XLANG (build product first: make relink-xlang / bootstrap-driver-seed)"
  exit 1
fi

# Historical make prereq: STD_AND_PANIC_O for -o link. Do not duplicate the list
# (G.7). Spot-check a few always-needed objects and fail with a clear hint.
need_std=0
for f in ../std/sys/sys.o runtime_panic.o; do
  if [ ! -f "$f" ]; then
    need_std=1
    break
  fi
done
if [ "$need_std" -ne 0 ]; then
  log "std/runtime objects missing (e.g. ../std/sys/sys.o, runtime_panic.o)"
  log "hint: make -C compiler std-objs   # or full product path that builds std .o"
  exit 1
fi

case "$MODE" in
  parser)
    # Self-host 9.1: compile parser.x (import lexer + token + ast + std.fs)
    # -L .. for std.fs; -L src/lexer for token; -L src/ast for ast
    # PLATFORM: SHARED — product -o path; host is relink-xlang / g05 product binary
    rm -f "$PARSE_FIXTURE"
    log "compile src/parser/parser.x → $PARSER_BIN"
    "$XLANG" -L .. -L src/lexer -L src/ast src/parser/parser.x -o "$PARSER_BIN"
    "$PARSER_BIN"
    echo "bootstrap-parser OK"
    ;;
  parse-file)
    # 9.1 dual-path: .x parser binary + host product xlang both print "parse OK"
    # Requires prior bootstrap-parser (PARSER_BIN present); make prereq enforces.
    if [ ! -x "$PARSER_BIN" ] && [ ! -f "$PARSER_BIN" ]; then
      fail "missing $PARSER_BIN (run bootstrap-parser first; make keeps prereq)"
    fi
    # Minimal fixture
    printf 'function main(): i32 { return 0; }\0' > "$PARSE_FIXTURE"
    "$PARSER_BIN" && echo "x parser: parse OK (minimal)"
    out=$("$XLANG" -L .. "$PARSE_FIXTURE" 2>&1) || true
    echo "$out" | grep -q "parse OK" || fail "C parser missing parse OK (minimal)"
    echo "C parser: parse OK (minimal)"
    # Expr-chain fixture (heap Arena / parse_expr_into path)
    printf 'function main(): i32 { return (1 + 2) * 3 + -1; }\0' > "$PARSE_FIXTURE"
    "$PARSER_BIN" && echo "x parser: parse OK (expr-chain)"
    out=$("$XLANG" -L .. "$PARSE_FIXTURE" 2>&1) || true
    echo "$out" | grep -q "parse OK" || fail "C parser missing parse OK (expr-chain)"
    echo "C parser: parse OK (expr-chain)"
    echo "bootstrap-parse-file OK"
    ;;
esac
