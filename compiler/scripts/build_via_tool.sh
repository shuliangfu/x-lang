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
# Wave: 954 post_ship --check when Makefile absent (wave941 phys-del); shell is
#   sole build-via-tool authority (run ./build_tool → TARGET + OK). MF thin-call
#   inventory only applies when Makefile still present (pre_ship archaeology).
# NOT physical delete of build_tool C (BC) — orchestration only.
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
  # wave954 post_ship: Makefile physically deleted (wave941). Shell owns
  # invoke + OK; require product path authority in this script, not MF recipe.
  if [ ! -f "$MF" ]; then
    # Product path must still invoke host ./build_tool (not a second body).
    if ! grep -qE '\./build_tool|build_tool "' "$0"; then
      fail "build_via_tool must invoke ./build_tool (wave874/954 post_ship)"
    fi
    if ! grep -q 'build-via-tool OK' "$0"; then
      fail "build_via_tool must print historic OK line (wave874/954 post_ship)"
    fi
    # Default TARGET and asm|legacy passthrough remain shell-owned.
    if ! grep -q 'TARGET:-xlang' "$0"; then
      fail "build_via_tool must default TARGET=xlang (wave874/954)"
    fi
    if ! grep -q 'asm|legacy' "$0"; then
      fail "build_via_tool must accept asm|legacy subcmd (wave874/954)"
    fi
    if ! grep -q 'wave954\|wave874' "$0"; then
      fail "build_via_tool must document wave874/954 shell-primary"
    fi
    # Host compile of build_tool stays build_tool.sh (G.7: not reimplemented here).
    if [ ! -f scripts/build_tool.sh ]; then
      fail "missing scripts/build_tool.sh (wave874/954; host build_tool authority)"
    fi
    echo "build_via_tool: --check OK (wave954 post_ship; shell-primary; 0-make)"
    exit 0
  fi
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
  echo "build_via_tool: --check OK (wave874/954; shell-primary; not physical delete)"
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
