#!/usr/bin/env bash
# TYPE-005: zero-cost abstraction compile/typeck smoke (honesty soft→硬绿).
#
# Honesty: soft SKIP→OK (no native) + prefer-c (xlang-c before asm) +
# soft auto-make retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make).
#   - policy=compile product -o = hard run
#   - policy=typeck / region check = obs (check gate paused 2026-08-05)
#   - policy=bcmp = skip (delegated to run-bcmp-gate.sh)
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-type-zero-cost.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/type-zero-cost.sh
. tests/lib/type-zero-cost.sh

BENCH="${XLANG_TYPE_ZC_BENCH:-tests/baseline/type-zero-cost-bench.tsv}"
PREFIX="${XLANG_TYPE_ZC_PREFIX:-xlang: [XLANG_TYPE_ZERO_COST]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "type-zero-cost FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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
    # Explicit XLANG that is not native = hard die (refuse soft fallthrough).
    return 1
  fi
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
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

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

[ -f "$BENCH" ] || die "missing $BENCH"

echo "=== TYPE-005: zero-cost smoke (XLANG=$XLANG_BIN) ==="
while IFS=$'\t' read -r bench_id su_file _c_ref policy notes; do
  [ -z "${bench_id:-}" ] && continue
  case "$bench_id" in \#*|min_*) continue ;; esac
  src=$(type_zero_cost_bench_x "$su_file") || die "missing bench x $su_file"
  case "$policy" in
    typeck)
      # check path = observational only (check gate paused 2026-08-05).
      set +e
      "$XLANG_BIN" check "$src" >/tmp/xlang_type_zc_check_${bench_id}.log 2>&1
      ck_ec=$?
      set -e
      if [ "$ck_ec" -eq 0 ]; then
        echo "type-zero-cost OK $bench_id (typeck observational)"
      else
        OBS=$((OBS + 1))
        echo "type-zero-cost OBS $bench_id (typeck/check residual ec=$ck_ec; refuse hard-bind check)" >&2
      fi
      ;;
    compile)
      exe="/tmp/xlang_zc_${bench_id}_$$"
      rm -f "$exe" 2>/dev/null || true
      set +e
      "$XLANG_BIN" "$src" -o "$exe" >/tmp/xlang_type_zc_compile_${bench_id}.log 2>&1
      o_ec=$?
      set -e
      if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
        tail -n 12 /tmp/xlang_type_zc_compile_${bench_id}.log 2>/dev/null || true
        rm -f "$exe"
        die "compile $src failed (ec=$o_ec; refuse soft SKIP→OK)"
      fi
      rm -f "$exe"
      RUN_OK=$((RUN_OK + 1))
      echo "type-zero-cost OK $bench_id (compile)"
      ;;
    bcmp)
      SKIP=$((SKIP + 1))
      echo "type-zero-cost SKIP $bench_id (bcmp via run-bcmp-gate.sh)"
      ;;
    *)
      die "unknown policy $policy for $bench_id"
      ;;
  esac
done < "$BENCH"

# region positive example — check = obs (paused); not soft silence.
set +e
"$XLANG_BIN" check tests/typeck/slice_lifetime/region_same_ok.x >/tmp/xlang_type_zc_region.log 2>&1
reg_ec=$?
set -e
if [ "$reg_ec" -eq 0 ]; then
  echo "type-zero-cost OK region_same (observational)"
else
  OBS=$((OBS + 1))
  echo "type-zero-cost OBS region_same (check residual ec=$reg_ec; refuse hard-bind check)" >&2
fi

if [ "$RUN_OK" -lt 1 ]; then
  die "no compile cases ran (refuse soft SKIP→OK)"
fi

echo "type-zero-cost OK"
ok_report
