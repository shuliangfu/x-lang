#!/usr/bin/env bash
# bootstrap_token_lexer_smoke.sh — 9.1 frontend module smokes (11.0.3 · wave719)
#
# Authority (G.7):
#   Single implementation for bootstrap-token / bootstrap-lexer bodies.
#   Makefile targets keep $(TARGET) + $(STD_AND_PANIC_O) as prereqs only;
#   xlang-build.sh calls this script directly (no make -C for those targets).
#   Does NOT re-list STD_AND_PANIC_O (object authority = mk/std_and_panic_objs.mk wave813).
#
# Usage (cwd = compiler/):
#   ./scripts/bootstrap_token_lexer_smoke.sh token
#   ./scripts/bootstrap_token_lexer_smoke.sh lexer
#
# Env:
#   TARGET — product binary name (default: xlang)
#   XLANG  — override compiler binary path (default: ./$TARGET)
#
# PLATFORM: SHARED — pure shell orchestration of product -o smokes.
# Wave: 719 Track MG · pairs with Makefile thin leaves + xlang-build direct call.

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-}"
TARGET="${TARGET:-xlang}"
XLANG="${XLANG:-./$TARGET}"

log() { echo "bootstrap-${MODE}: $*" >&2; }

case "$MODE" in
  token|lexer) ;;
  *)
    echo "usage: $0 token|lexer" >&2
    exit 2
    ;;
esac

if [ ! -x "$XLANG" ]; then
  log "missing executable $XLANG (build product first: make bootstrap-driver-seed / g05 relink)"
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
  token)
    # Self-host 9.1: compile token module + token_standalone entry
    "$XLANG" -L src/lexer src/lexer/token_standalone.x -o /tmp/xlang_token_test
    /tmp/xlang_token_test
    echo "bootstrap-token OK"
    ;;
  lexer)
    # Self-host 9.1: compile lexer.x (import token); multi-file + cross-module enum
    "$XLANG" -L src/lexer src/lexer/lexer.x -o /tmp/xlang_lexer_test
    /tmp/xlang_lexer_test
    echo "bootstrap-lexer OK"
    ;;
esac
