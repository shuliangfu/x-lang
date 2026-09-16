#!/usr/bin/env bash
# SIMD-S1 gate: -target-cpu parse + host feature probe (--print-target-cpu).
#
# Honesty: soft SKIP→OK when no native xlang retired. Prefer product
# xlang_asm via dod_native_exe; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die. Report run=/obs=/skip=.
#
# Usage: ./tests/run-simd-s1-gate.sh
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_SIMD_S1_PREFIX:-xlang: [XLANG_SIMD_S1]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "simd-s1 gate FAIL: $*" >&2
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
    return 1
  fi
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

echo "=== SIMD-S1: --print-target-cpu (host probe) ==="
XLANG_ABS="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_ABS"
export XLANG_LINK_XLANG="$XLANG_ABS"

OUT="$(mktemp)"
GEN_OUT="$(mktemp)"
trap 'rm -f "$OUT" "$GEN_OUT"' EXIT

if ! "$XLANG_ABS" --print-target-cpu >"$OUT" 2>&1; then
  die "--print-target-cpu exit non-zero"
fi

if ! grep -q '^target_cpu_features=0x' "$OUT"; then
  die "missing target_cpu_features line"
fi

if ! grep -q '^target_cpu_host_features=0x' "$OUT"; then
  die "missing target_cpu_host_features line"
fi

ARCH="$(uname -m 2>/dev/null || echo unknown)"
FEAT_LINE="$(grep '^target_cpu_features=' "$OUT" | head -1)"
FEAT_HEX="${FEAT_LINE#target_cpu_features=0x}"
FEAT_VAL=$((16#$FEAT_HEX))

echo "simd-s1: host arch=$ARCH features=$FEAT_LINE"

case "$ARCH" in
  x86_64|amd64)
    if [ "$FEAT_VAL" -eq 0 ]; then
      die "x86_64 host features=0 (expect at least SSE2)"
    fi
    ;;
  aarch64|arm64)
    NEON_MASK=256
    if [ $((FEAT_VAL & NEON_MASK)) -eq 0 ]; then
      die "arm64 host missing NEON bit"
    fi
    ;;
esac
RUN_OK=$((RUN_OK + 1))

echo "=== SIMD-S1: -target-cpu generic (baseline subset) ==="
if ! "$XLANG_ABS" --print-target-cpu -target-cpu generic >"$GEN_OUT" 2>&1; then
  die "--print-target-cpu -target-cpu generic"
fi

GEN_LINE="$(grep '^target_cpu_features=' "$GEN_OUT" | head -1)"
GEN_HEX="${GEN_LINE#target_cpu_features=0x}"
GEN_VAL=$((16#$GEN_HEX))

if [ "$GEN_VAL" -gt "$FEAT_VAL" ]; then
  die "generic ($GEN_LINE) > native ($FEAT_LINE)"
fi

echo "simd-s1: generic baseline OK ($GEN_LINE <= $FEAT_LINE)"
RUN_OK=$((RUN_OK + 1))
echo "simd-s1 gate OK"
ok_report
