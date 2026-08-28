#!/usr/bin/env bash
# STD-047: std.simd shuffle/select gate — honesty soft fallthrough →硬绿.
#
# Honesty: soft XLANG fallthrough (explicit-bad still picks another binary) +
# soft auto-make + check=/shuffle=/select=/s4=/skip= retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native asm =
# hard die (refuse soft SKIP→OK / soft auto-make / prefer-c). Product
# shuffle_select_roundtrip.x -o exit0 = hard run (run=1). check = obs.
# simd-s4: hard on x86_64 (counts toward run=); observational elsewhere (obs+=1).
# Report: run=/obs=/skip=.
# SIMD Vec bodies need asm backend (skip xlang-c).
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-simd-shuffle-select-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_SIMD_SHUFFLE_SELECT_DOC:-analysis/archive/std/std-simd-shuffle-select-v1.md}"
MANIFEST="${XLANG_STD_SIMD_SHUFFLE_SELECT_TSV:-tests/baseline/std-simd-shuffle-select.tsv}"
MOD_X="std/simd/mod.x"
LIB="tests/lib/std-simd-shuffle-select.sh"
SMOKE_X="tests/simd/shuffle_select_roundtrip.x"
MIN_APIS=7

# shellcheck source=tests/lib/std-simd-shuffle-select.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-simd-shuffle-select gate FAIL: $*" >&2
  std_simd_ss_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
if [ -f analysis/std-simd-shuffle-select-v1.md ]; then
  die "top-level DOC resurrected (live = archive/std/)"
fi

echo "=== STD-047: simd shuffle/select manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SMOKE_X"; do
  [ -f "$f" ] || die "missing $f"
done

# Product names are overload shuffle/select/select_lane.
for kw in STD-047 shuffle select select_lane lane-scalar XLANG_SIMD_HW; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done
grep -qF '## 4. Gate' "$DOC" 2>/dev/null || die "doc missing '## 4. Gate'"

# mod.x must contain lane-scalar impl (non-zero stub)
grep -qF 'v[mask[0]]' "$MOD_X" 2>/dev/null || die "missing lane-scalar shuffle in $MOD_X"
# Product API is select_lane (mod.x); legacy vec8i_select_lane drifted.
grep -qE 'function select_lane\(' "$MOD_X" 2>/dev/null || die "missing select_lane helper in $MOD_X"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_apis) MIN_APIS="$c2" ;;
  esac
done < "$MANIFEST"

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    api)
      API_N=$((API_N + 1))
      grep -qE "function ${anchor}\\(" "$MOD_X" 2>/dev/null || die "missing api $anchor"
      ;;
    section)
      grep -qF "$anchor" "$DOC" 2>/dev/null || die "doc missing section $anchor"
      ;;
  esac
done < "$MANIFEST"

[ "$API_N" -ge "$MIN_APIS" ] || die "api count $API_N < min $MIN_APIS"

sym_miss="$(std_simd_ss_symbols_ok "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-simd-shuffle-select manifest OK"

if [ "${XLANG_STD_SIMD_SHUFFLE_SELECT_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_simd_ss_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-simd-shuffle-select gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native asm xlang/xlang_asm (refuse soft SKIP→OK / soft auto-make / prefer-c)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-047: smoke (XLANG=$XLANG_BIN; check/s4-non-x86 obs; roundtrip product hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_simd_ss_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-simd-shuffle-select OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

# Refuse soft auto-make (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave ensure_std family alone.
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. tests/lib/bootstrap-link-xlang.sh

if std_simd_ss_run_smoke "$XLANG_BIN" "$SMOKE_X" "roundtrip"; then
  RUN_OK=$((RUN_OK + 1))
  echo "std-simd-shuffle-select OK: shuffle_select_roundtrip"
else
  die "shuffle_select_roundtrip.x exit!=0 (refuse soft SKIP→OK)"
fi

# simd-s4: hard on x86_64 (HW objdump); observational elsewhere.
# PLATFORM: LINUX x86_64 hard; MACOS/ARM observational.
if [ -x tests/run-simd-s4-gate.sh ]; then
  S4_STRICT=""
  case "$(uname -m 2>/dev/null)" in
    x86_64|amd64) S4_STRICT=1 ;;
  esac
  S4_LOG="/tmp/std_simd_s4_$$.log"
  if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
    XLANG_SIMD_HW_STRICT="${S4_STRICT}" \
    ./tests/run-simd-s4-gate.sh >"$S4_LOG" 2>&1; then
    RUN_OK=$((RUN_OK + 1))
    echo "std-simd-shuffle-select OK: simd-s4"
  elif [ -n "$S4_STRICT" ]; then
    echo "std-simd-shuffle-select gate FAIL: simd-s4 strict HW check" >&2
    tail -8 "$S4_LOG" >&2 || true
    rm -f "$S4_LOG"
    die "simd-s4 strict HW failed (refuse soft SKIP→OK)"
  else
    echo "std-simd-shuffle-select OBS simd-s4 (non-x86; refuse soft SKIP→OK)" >&2
    tail -5 "$S4_LOG" >&2 || true
    OBS=$((OBS + 1))
  fi
  rm -f "$S4_LOG"
fi

std_simd_ss_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-simd-shuffle-select gate OK"
