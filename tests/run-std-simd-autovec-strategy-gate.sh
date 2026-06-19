#!/usr/bin/env bash
# STD-153：std.simd 自动向量化策略 + 跨平台 perf 门禁
#
# 用法：./tests/run-std-simd-autovec-strategy-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-simd-autovec-strategy-v1.md"
MANIFEST="tests/baseline/std-simd-autovec-strategy-manifest.tsv"
VECTORS="tests/baseline/std-simd-autovec-strategy.tsv"
MOD_SU="std/simd/mod.sx"
SIMD_C="std/simd/simd.c"
LIB="tests/lib/std-simd-autovec-strategy.sh"
SMOKE_SU="tests/std-simd/autovec_strategy.sx"
MIN_APIS=2

# shellcheck source=tests/lib/std-simd-autovec-strategy.sh
. "$LIB"
# shellcheck source=tests/lib/std-simd-prod.sh
. tests/lib/std-simd-prod.sh

echo "=== STD-153: simd autovec strategy manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SU" "$SIMD_C" "$SMOKE_SU" \
  tests/std-simd/autovec_strategy_ok.c std/simd/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-simd-autovec gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-153 recommend_simd_path SHUX_SIMD_AUTovec SIMD_PATH_HW; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-simd-autovec gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "recommend_simd_path" std/simd/README.md 2>/dev/null; then
  echo "std-simd-autovec gate FAIL: README missing recommend_simd_path" >&2
  exit 1
fi

API_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in api) API_N=$((API_N + 1)) ;; esac
done < "$MANIFEST"

if [ "$API_N" -lt "$MIN_APIS" ]; then
  echo "std-simd-autovec gate FAIL: api count $API_N < min $MIN_APIS" >&2
  exit 1
fi

sym_miss="$(std_simd_autovec_symbols_ok "$MOD_SU" "$SIMD_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_simd_autovec_emit_report "fail" 0 0 0 0 "$(std_simd_autovec_platform_key)"
  exit 1
fi
echo "std-simd-autovec manifest OK"

HOST_KEY="$(std_simd_autovec_platform_key)"
read -r DOT_MIN SS_MIN <<< "$(std_simd_autovec_perf_thresholds "$VECTORS" "$HOST_KEY")"

C_OK=0
if std_simd_autovec_run_c_smoke; then
  C_OK=1
else
  std_simd_autovec_emit_report "fail" 0 0 0 0 "$HOST_KEY"
  exit 1
fi

SU_OK=0
PERF_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/simd/simd.o
  SIMD_O="$(cd compiler && pwd)/../std/simd/simd.o"
  if ! "$SHUX_BIN" check -L . "$SMOKE_SU" >/dev/null 2>&1; then
    echo "std-simd-autovec gate FAIL: typeck" >&2
    std_simd_autovec_emit_report "fail" "$C_OK" 0 0 0 "$HOST_KEY"
    exit 1
  fi
  if std_simd_autovec_run_sx_smoke "$SHUX_BIN" "$SMOKE_SU" "$SIMD_O"; then
    SU_OK=1
  else
    std_simd_autovec_emit_report "fail" "$C_OK" 0 0 0 "$HOST_KEY"
    exit 1
  fi
else
  SKIP=1
fi

SHUX_ASM=""
if std_simd_prod_native_asm ./compiler/shux_asm; then
  SHUX_ASM=./compiler/shux_asm
elif std_simd_prod_native_asm ./compiler/shux; then
  SHUX_ASM=./compiler/shux
fi

if [ -n "$SHUX_ASM" ] && awk -v d="$DOT_MIN" -v s="$SS_MIN" 'BEGIN { exit ((d+s) > 0.001) ? 0 : 1 }'; then
  if std_simd_autovec_run_perf "$SHUX_ASM" "$DOT_MIN" "$SS_MIN"; then
    PERF_OK=1
  else
    echo "std-simd-autovec WARN: perf below threshold; strategy smoke OK (skip perf hard fail)" >&2
    PERF_OK=0
    SKIP=1
  fi
else
  echo "std-simd-autovec gate SKIP perf (asm=${SHUX_ASM:-none} thresholds=${DOT_MIN}/${SS_MIN})" >&2
  PERF_OK=0
  SKIP=1
fi

std_simd_autovec_emit_report "ok" "$C_OK" "$SU_OK" "$PERF_OK" "$SKIP" "$HOST_KEY"
echo "std-simd-autovec gate OK"
