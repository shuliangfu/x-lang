#!/usr/bin/env bash
# V6 §7 / P0#1: fresh bootstrap seed smoke — leftover fossil DOC + leftover
# catalog no Honesty + leftover SKIP→OK + leftover Darwin docker wrap →硬绿.
#
# Honesty: leftover top-level `analysis/自举前必须清单.md` as live DOC
# (file already archived to analysis/archive/narrative/; gate still
# hard-required the missing top-level path → V6 / bootstrap-min red) +
# leftover catalog no Honesty / missing run=/obs=/skip= + leftover
# SKIP→OK (`XLANG_BOOTSTRAP_FRESH_SEED_SKIP=1` still OK without skip
# count) retired as counted skip=1. leftover Darwin docker wrap skip=1
# N/A (refuse leftover docker as Darwin success). Live =
# analysis/archive/narrative/. Refuse top-level resurrect. Nested leftover
# seed smoke / leftover prefer-c TARGET (`xlang-c` then `xlang` then
# `bootstrap_xlangc`) / leftover auto-make BUILD=1 stay (do not rewrite
# leftover V6 product path). G.7: complete existing `dod_native_exe` on
# explicit XLANG; do not fork a third resolver. Explicit XLANG not native
# hard-dies. Keep `bootstrap-fresh-seed-gate OK`. Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology / LINUX x86_64 gold for leftover nested
# seed smoke; Darwin skip=1 N/A.
# Usage: ./tests/run-bootstrap-fresh-seed-gate.sh
# Env:   XLANG_BOOTSTRAP_FRESH_SEED_SKIP=1   → skip=1 status=ok
#        XLANG_BOOTSTRAP_FRESH_SEED_BUILD=1  → leftover nested auto-make
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

DOC="${XLANG_BOOTSTRAP_V6_DOC:-analysis/archive/narrative/自举前必须清单.md}"
SMOKE="compiler/scripts/bootstrap_driver_seed_smoke.sh"
PREFIX="${XLANG_BOOTSTRAP_V6_PREFIX:-xlang: [XLANG_BOOTSTRAP_V6]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "bootstrap-fresh-seed-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

abs_of() {
  case "$1" in
    /*) echo "$1" ;;
    *) echo "$(pwd)/$1" ;;
  esac
}

echo "=== V6: fresh seed smoke (archive DOC; leftover nested seed smoke keep) ==="

# Refuse leftover fossil top-level DOC as live path (c6 / stdlib-check-matrix).
# PLATFORM: SHARED archaeology — live = archive/narrative/.
if [ -f analysis/自举前必须清单.md ]; then
  die "top-level DOC resurrected (live = archive/narrative/)"
fi
[ -f "$DOC" ] || die "missing $DOC"
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
grep -qF "V6" "$DOC" || die "doc missing V6"
[ -x "$SMOKE" ] || die "missing $SMOKE"

# Explicit XLANG that is missing/non-native hard-dies BEFORE Darwin skip
# (refuse leftover SKIP→OK / leftover ignore of explicit-bad / leftover
# XLANG fallthrough as Darwin N/A). leftover nested prefer-c TARGET stays
# when XLANG is unset (do not rewrite leftover V6 product path).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  abs="$(abs_of "$XLANG")"
  if ! dod_native_exe "$abs"; then
    die "explicit XLANG not native (refuse leftover SKIP→OK / leftover XLANG fallthrough / leftover prefer-c)"
  fi
fi

# leftover SKIP→OK retired: SKIP=1 is counted skip=1, still ok.
# PLATFORM: SHARED archaeology — refuse leftover SKIP→OK without skip=.
if [ "${XLANG_BOOTSTRAP_FRESH_SEED_SKIP:-0}" = "1" ]; then
  SKIP=$((SKIP + 1))
  gate_progress "bootstrap-fresh-seed-gate: SKIP (XLANG_BOOTSTRAP_FRESH_SEED_SKIP=1)"
  echo "bootstrap-fresh-seed-gate OK"
  ok_report
  exit 0
fi

# leftover Darwin docker wrap skip=1 N/A (refuse leftover docker as Darwin
# success). leftover nested seed smoke stays Linux x86_64 gold.
# PLATFORM: LINUX — leftover nested seed smoke; Darwin skip=1 N/A.
if [ "${XLANG_CI_DOCKER:-0}" != "1" ]; then
  os="$(uname -s 2>/dev/null || true)"
  arch="$(uname -m 2>/dev/null || true)"
  case "$arch" in x86_64|amd64) : ;; *) arch="non-x86_64" ;; esac
  case "$os" in
    MINGW*|MSYS*|CYGWIN*)
      SKIP=$((SKIP + 1))
      gate_progress "V6: Windows N/A skip=1 (refuse leftover docker wrap)"
      echo "bootstrap-fresh-seed-gate OK"
      ok_report
      exit 0
      ;;
    Darwin)
      SKIP=$((SKIP + 1))
      gate_progress "V6: Darwin N/A skip=1 (refuse leftover docker wrap)"
      echo "bootstrap-fresh-seed-gate OK"
      ok_report
      exit 0
      ;;
    *)
      if [ "$os" != "Linux" ] || [ "$arch" = "non-x86_64" ]; then
        SKIP=$((SKIP + 1))
        gate_progress "V6: non-Linux-x86_64 N/A skip=1 (refuse leftover docker wrap)"
        echo "bootstrap-fresh-seed-gate OK"
        ok_report
        exit 0
      fi
      ;;
  esac
fi

# leftover nested auto-make BUILD=1 stays (do not rewrite leftover V6
# product path). Default BUILD=0 does not auto-make.
# PLATFORM: LINUX — leftover nested auto-make opt-in.
if [ "${XLANG_BOOTSTRAP_FRESH_SEED_BUILD:-0}" = "1" ]; then
  gate_progress "V6: leftover nested xlang_compiler_make bootstrap-driver-seed ..."
  gate_progress_run "bootstrap-driver-seed" xlang_compiler_make bootstrap-driver-seed XLANG_FORCE_REGEN_GEN=1
fi

# leftover nested prefer-c TARGET stays (V6 seed smoke product path).
# PLATFORM: LINUX — leftover nested prefer-c; do not rewrite.
TARGET="${XLANG_BOOTSTRAP_FRESH_SEED_BIN:-./compiler/xlang-c}"
if [ ! -x "$TARGET" ]; then
  TARGET="./compiler/xlang"
fi
if [ ! -x "$TARGET" ]; then
  TARGET="./compiler/bootstrap_xlangc"
fi
if [ ! -x "$TARGET" ]; then
  die "no executable seed (xlang-c/xlang/bootstrap_xlangc; refuse leftover SKIP→OK)"
fi

if [ -f compiler/seeds/runtime_process_argv.from_x.c ]; then
  if [ ! -f compiler/runtime_process_argv.o ] \
     || [ compiler/seeds/runtime_process_argv.from_x.c -nt compiler/runtime_process_argv.o ]; then
    gate_progress "V6: leftover nested remake runtime_process_argv.o ..."
    gate_progress_run "runtime_process_argv.o" xlang_compiler_make runtime_process_argv.o
  fi
fi

TARGET_ABS="$(cd "$(dirname "$TARGET")" && pwd)/$(basename "$TARGET")"
gate_progress "V6: leftover nested seed smoke (TARGET=$TARGET_ABS)"
gate_progress "V6: leftover nested seed smoke 1–3 min (heartbeat 15s) ..."

if gate_progress_run_heartbeat "V6 seed smoke" 15 \
    bash -c "cd compiler && XLANG_BOOTSTRAP_NO_PINNED_FALLBACK=1 ./scripts/bootstrap_driver_seed_smoke.sh \"$TARGET_ABS\""; then
  RUN_OK=$((RUN_OK + 1))
  gate_progress "bootstrap-fresh-seed-gate OK"
  echo "bootstrap-fresh-seed-gate OK"
  ok_report
  exit 0
fi

die "leftover nested seed smoke failed (refuse leftover SKIP→OK)"
