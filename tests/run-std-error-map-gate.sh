#!/usr/bin/env bash
# STD-020: std.error code map / last_error gate — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … || true`) + soft XLANG
# fallthrough (explicit-bad still picks another binary) + check=/run=/skip=
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
# Product error_map_smoke.x + cookbook error_module_base.x -o exit0 = hard run
# (run=2). check = obs (paused 2026-08-05; leave ensure_std family alone).
# Report: run=/obs=/skip=.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-error-map-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_ERROR_MAP_DOC:-analysis/archive/std/std-error-map-v1.md}"
UNIFY_DOC="${XLANG_STD_ERROR_UNIFY_DOC:-analysis/archive/std/std-error-unify-v1.md}"
MANIFEST="${XLANG_STD_ERROR_MAP_TSV:-tests/baseline/std-error-map.tsv}"
ERR_MOD="${XLANG_STD_ERROR_MOD:-std/error/mod.x}"
LIB="tests/lib/std-error-map.sh"
SMOKE="tests/std/error_map_smoke.x"
COOKBOOK="examples/cookbook/error_module_base.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-error-map.sh
. tests/lib/std-error-map.sh

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-error-map gate FAIL: $*" >&2
  std_error_map_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-020: error map manifest ==="
for f in "$DOC" "$UNIFY_DOC" "$MANIFEST" "$LIB" "$ERR_MOD" "$SMOKE" "$COOKBOOK"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in code_to_module_base last_error fs_last_error sidecar_db_struct; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF -- 'std-error-map.tsv' "$DOC" 2>/dev/null || die "doc missing matrix ref"

map_miss="$(std_error_map_manifest_ok "$ERR_MOD" "$MANIFEST" || true)"
[ "${map_miss:-0}" -eq 0 ] || die "manifest_miss=${map_miss}"
echo "std-error-map manifest OK"

if [ "${XLANG_STD_ERROR_MAP_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_error_map_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-error-map gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-020: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std_error_map_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-error-map OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make of mod.o / xlang-c; leave ensure_std family alone.
# PLATFORM: SHARED archaeology.

for pair in "smoke:$SMOKE" "cookbook:$COOKBOOK"; do
  tag="${pair%%:*}"
  src="${pair#*:}"
  OUT="/tmp/xlang_std_error_map_${tag}_$$"
  LOG="/tmp/xlang_std_error_map_${tag}_build_$$.log"
  rm -f "$OUT" "$LOG"
  set +e
  "$XLANG_BIN" -L . "$src" -o "$OUT" >"$LOG" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
    tail -n 20 "$LOG" 2>/dev/null || true
    rm -f "$OUT"
    die "product -o $src failed (ec=$o_ec; refuse soft SKIP→OK)"
  fi
  set +e
  "$OUT" >/dev/null 2>&1
  exitcode=$?
  set -e
  rm -f "$OUT"
  [ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable $src exit=$exitcode (expect $SMOKE_EXPECT)"
  RUN_OK=$((RUN_OK + 1))
  echo "std-error-map OK: product -o $tag"
done

std_error_map_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-error-map gate OK"
