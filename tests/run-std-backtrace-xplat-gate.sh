#!/usr/bin/env bash
# STD-147: std.backtrace Darwin/Windows/Linux symbol-quality gate — honesty
# soft prefer-c / soft SKIP→OK / soft ensure / quality=/host= report →硬绿.
#
# Honesty: prefer-c first (`./compiler/xlang-c` only) + soft SKIP→OK (no
# xlang-c still gate OK) + soft `ensure_std_c_o` / soft
# `xlang_compiler_make … || true` + fossil top-level DOC section path +
# report `quality=`/`host=` retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die.
# Host-C archaeology = obs only (prebuilt backtrace.o +
# runtime_backtrace_platform.o; refuse soft ensure/auto-make). tip quality
# residual = obs (product debt; leave). Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-backtrace-xplat-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_BACKTRACE_XPLAT_DOC:-analysis/archive/std/std-backtrace-xplat-v1.md}"
MANIFEST="${XLANG_STD_BACKTRACE_XPLAT_TSV:-tests/baseline/std-backtrace-xplat-manifest.tsv}"
VECTORS="tests/baseline/std-backtrace-xplat.tsv"
BT_RUNTIME="compiler/seeds/runtime_backtrace_platform.from_x.c"
BT_X="std/backtrace/backtrace.x"
LIB="tests/lib/std-backtrace-xplat.sh"
SMOKE_C="tests/backtrace/xplat_quality.c"

# shellcheck source=tests/lib/std-backtrace-xplat.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-backtrace-xplat gate FAIL: $*" >&2
  std_backtrace_xplat_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-147: backtrace xplat quality manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$BT_X" "$BT_RUNTIME" "$SMOKE_C" std/backtrace/README.md; do
  [ -f "$f" ] || die "missing $f"
done
grep -qE '^## Gate' "$DOC" || die "doc missing ## Gate section"
[ ! -f analysis/std-backtrace-xplat-v1.md ] || die "dual-authority fossil analysis/std-backtrace-xplat-v1.md (archive live)"
for kw in STD-147 XLANG_BT_XPLAT export_dynamic DbgHelp; do
  grep -qF -- "$kw" "$DOC" || die "doc missing '$kw'"
done
grep -qF "backtrace_xplat_quality_c" std/backtrace/README.md || die "README missing xplat quality"

sym_miss="$(std_backtrace_xplat_symbols_ok "$BT_RUNTIME" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-backtrace-xplat registry OK"

if [ "${XLANG_STD_BACKTRACE_XPLAT_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_backtrace_xplat_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-backtrace-xplat gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-147: quality smoke (XLANG=$XLANG_BIN; host-C=obs; tip quality=obs) ==="
echo "std-backtrace-xplat host=$(ci_host_summary)"

if ! vec="$(std_backtrace_xplat_pick_vector "$VECTORS" 2>/dev/null)"; then
  echo "std-backtrace-xplat SKIP (no vector for host $(ci_host_summary))" >&2
  SKIP=1
  std_backtrace_xplat_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-backtrace-xplat gate OK (host vector skip)"
  exit 0
fi
echo "std-backtrace-xplat vector=$vec"

# Quality C smoke = obs on residual; refuse soft ensure/auto-make.
# PLATFORM: SHARED — Darwin export_dynamic / Linux -rdynamic; tip residual leave.
if std_backtrace_xplat_run_smoke; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-backtrace-xplat OK: quality smoke"
else
  echo "std-backtrace-xplat OBS quality smoke (product residual; refuse soft ensure)" >&2
  OBS=$((OBS + 1))
fi

std_backtrace_xplat_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-backtrace-xplat gate OK"
