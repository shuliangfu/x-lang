#!/usr/bin/env bash
# build_via_tool.sh — run host build_tool to produce product TARGET (build-via-tool)
#
# Authority (G.7 有则补全 / 无才新增):
#   Single implementation for Makefile phony build-via-tool and for the
#   xlang-build.sh run_build_tool product path (default / asm / legacy).
#   Historic dual body lived inline in Makefile:
#     ./build_tool ./$(TARGET)
#     echo build-via-tool OK
#   xlang-build.sh also inlined `./build_tool ./xlang $1` — same authority;
#   wave874 consolidates both onto this script (no second body).
#
#   What this owns:
#     1) Require executable ./build_tool (Makefile prereq build-tool stays make
#        graph; xbuild ensure_build_tool builds it via build_tool.sh first)
#     2) Invoke ./build_tool ./$TARGET [subcmd]  (subcmd empty | asm | legacy)
#     3) Print historic OK line for make / CI consumers
#
#   Why shell-primary (not physical delete)?
#     build-tool prereq + g05/relink graph still make residual; this is only the
#     "run build_tool → product binary" orchestration body.
#
#   Related but NOT the same as:
#     - build_tool.sh (host compile of build_tool binary itself; wave718/866)
#     - bootstrap-driver-bstrict / hybrid (asm seed paths; different phonies)
#     - g05_build_xlang_asm.sh (product 0-make asm/relink after build_tool)
#   Do not reimplement build_tool host compile or g05 here.
#
# Usage (cwd = compiler/):
#   bash scripts/build_via_tool.sh
#   bash scripts/build_via_tool.sh asm
#   bash scripts/build_via_tool.sh legacy
#   bash scripts/build_via_tool.sh --check
#
# Env:
#   TARGET — product binary name (default: xlang)
#
# wave874 (G.7 有则补全): Makefile fat body + xlang-build dual invoke → this script.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — orchestration only; ABI stays in build_tool / g05.

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
TARGET="${TARGET:-xlang}"

log() { echo "build-via-tool: $*" >&2; }
fail() { echo "build-via-tool: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product build; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  _rec=$(awk '
    /^build-via-tool:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'build_via_tool\.sh' <<<"$_rec"; then
    fail "build-via-tool must thin-call build_via_tool.sh (wave874)"
  fi
  # Dual body: inline ./build_tool invoke + OK line (shell owns both).
  if grep -qE '\./build_tool|build_tool \./' <<<"$_rec"; then
    fail "build-via-tool must not keep dual ./build_tool body (wave874; shell owns)"
  fi
  if grep -qE 'build-via-tool OK' <<<"$_rec"; then
    fail "build-via-tool must not keep dual OK body (wave874; shell owns)"
  fi
  echo "build_via_tool: --check OK (wave874; shell-primary; not physical delete)"
  exit 0
fi

# Subcommands: run | --run | empty product path; or asm | legacy passthrough.
SUBCMD=""
case "$MODE" in
  run|--run|"")
    SUBCMD=""
    ;;
  asm|legacy)
    SUBCMD="$MODE"
    ;;
  *)
    echo "usage: $0 [--check|run|asm|legacy]" >&2
    exit 2
    ;;
esac

# ---------------------------------------------------------------------------
# Product path (run host build_tool → ./$TARGET)
# ---------------------------------------------------------------------------
if [ ! -x ./build_tool ]; then
  fail "missing executable ./build_tool (run make build-tool or ./xbuild build-tool first)"
fi

# Historic: ./build_tool ./$(TARGET) [subcmd]
# shellcheck disable=SC2086 # SUBCMD may be empty (default product path)
./build_tool "./$TARGET" $SUBCMD

echo "build-via-tool OK ($TARGET produced by build_tool${SUBCMD:+; subcmd=$SUBCMD})"
