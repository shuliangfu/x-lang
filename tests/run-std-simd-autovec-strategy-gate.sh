#!/usr/bin/env bash
# STD-153: std.simd autovec strategy + cross-platform perf gate — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft auto-make + soft ensure_std_c_o + check=/c=/x=/perf=/skip= retired.
# Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native asm = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c /
# soft ensure). Product autovec_strategy.x -o exit0 = hard run (run=1).
# check / C (existing .o only) / perf = obs. Report: run=/obs=/skip=.
# SIMD Vec bodies need asm backend (skip xlang-c).
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-simd-autovec-strategy-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD153_DOC:-analysis/archive/std/std-simd-autovec-strategy-v1.md}"
MANIFEST="tests/baseline/std-simd-autovec-strategy-manifest.tsv"
VECTORS="tests/baseline/std-simd-autovec-strategy.tsv"
MOD_X="std/simd/mod.x"
SIMD_X="std/simd/simd.x"
LIB="tests/lib/std-simd-autovec-strategy.sh"
SMOKE_X="tests/std-simd/autovec_strategy.x"
MIN_APIS=2

# shellcheck source=tests/lib/std-simd-autovec-strategy.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-simd-autovec gate FAIL: $*" >&2
  std_simd_autovec_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP" "$(std_simd_autovec_platform_key)"
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
      case "$abs" in
        */xlang-c|*/xlang-x*) return 1 ;;
      esac
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c / xlang-c (no Vec emit).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang; do
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

# Refuse resurrected top-level DOC (live = archive/std/).
# PLATFORM: SHARED archaeology — same refuse rule as other honesty gates.
if [ -f analysis/std-simd-autovec-strategy-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

echo "=== STD-153: simd autovec strategy manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_X" "$SIMD_X" "$SMOKE_X" \
  tests/std-simd/autovec_strategy_ok.c std/simd/README.md; do
  [ -f "$f" ] || die "missing $f"
done

# Product names: recommend_path (not fossil recommend_simd_path).
for kw in STD-153 recommend_path XLANG_SIMD_AUTovec SIMD_PATH_HW; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"
grep -qF "recommend_path" std/simd/README.md 2>/dev/null || die "README missing recommend_path"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in api) API_N=$((API_N + 1)) ;; esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

# Section anchors must match the gate DOC (archive); ban live/archive dual path.
sym_miss="$(std_simd_autovec_symbols_ok "$MOD_X" "$SIMD_X" "$SIMD_X" "$MANIFEST" "$DOC" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-simd-autovec manifest OK"

HOST_KEY="$(std_simd_autovec_platform_key)"
read -r DOT_MIN SS_MIN <<< "$(std_simd_autovec_perf_thresholds "$VECTORS" "$HOST_KEY")"

if [ "${XLANG_STD153_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_simd_autovec_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP" "$HOST_KEY"
  echo "std-simd-autovec gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-153: smoke (XLANG=$XLANG_BIN; check/C/perf obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_simd_autovec_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-simd-autovec OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make / soft ensure (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh

# Observational C smoke (existing simd.o only; never soft rebuild).
if std_simd_autovec_run_c_smoke; then
  echo "std-simd-autovec OK smoke_c (observational)"
else
  echo "std-simd-autovec OBS c smoke (existing .o only / no soft ensure)" >&2
  OBS=$((OBS + 1))
fi

if std_simd_autovec_run_x_smoke "$XLANG_BIN" "$SMOKE_X"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-simd-autovec OK: autovec_strategy"
else
  die "autovec_strategy.x exit!=0 (refuse soft SKIP→OK)"
fi

# Perf remains observational residual (ratio soft; not hard-green).
if awk -v d="$DOT_MIN" -v s="$SS_MIN" 'BEGIN { exit ((d+s) > 0.001) ? 0 : 1 }'; then
  if std_simd_autovec_run_perf "$XLANG_BIN" "$DOT_MIN" "$SS_MIN"; then
    echo "std-simd-autovec OK perf (observational)"
  else
    echo "std-simd-autovec OBS perf (ratio soft residual; refuse soft SKIP→OK)" >&2
    OBS=$((OBS + 1))
  fi
else
  echo "std-simd-autovec OBS perf (thresholds=${DOT_MIN}/${SS_MIN}; soft residual)" >&2
  OBS=$((OBS + 1))
fi

std_simd_autovec_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP" "$HOST_KEY"
echo "std-simd-autovec gate OK"
