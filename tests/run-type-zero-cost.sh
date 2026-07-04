#!/usr/bin/env bash
# TYPE-005：零成本抽象 compile/typeck 烟测
#
# 用法：./tests/run-type-zero-cost.sh
set -e
cd "$(dirname "$0")/.."

BENCH="${SHUX_TYPE_ZC_BENCH:-tests/baseline/type-zero-cost-bench.tsv}"

# shellcheck source=tests/lib/type-zero-cost.sh
. tests/lib/type-zero-cost.sh

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if type_zero_cost_native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHUX_BIN" ] || ! type_zero_cost_native_shu "$SHUX_BIN"; then
  echo "type-zero-cost SKIP (no native shux, host=$(uname -s)/$(uname -m 2>/dev/null))"
  echo "type-zero-cost OK"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler

echo "=== TYPE-005: zero-cost smoke (SHUX=$SHUX_BIN) ==="
FAILS=0
while IFS=$'\t' read -r bench_id su_file _c_ref policy notes; do
  [ -z "${bench_id:-}" ] && continue
  case "$bench_id" in \#*|min_*) continue ;; esac
  src=$(type_zero_cost_bench_x "$su_file") || {
    echo "type-zero-cost FAIL: missing $su_file" >&2
    FAILS=$((FAILS + 1))
    continue
  }
  case "$policy" in
    typeck)
      if "$SHUX_BIN" check "$src" >/dev/null 2>&1; then
        echo "type-zero-cost OK $bench_id (typeck)"
      else
        echo "type-zero-cost FAIL: typeck $src" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
    compile)
      exe="/tmp/shux_zc_${bench_id}"
      if "$SHUX_BIN" "$src" -o "$exe" >/dev/null 2>&1; then
        rm -f "$exe"
        echo "type-zero-cost OK $bench_id (compile)"
      else
        echo "type-zero-cost FAIL: compile $src" >&2
        FAILS=$((FAILS + 1))
      fi
      ;;
    bcmp)
      echo "type-zero-cost SKIP $bench_id (bcmp via run-bcmp-gate.sh)"
      ;;
    *)
      echo "type-zero-cost WARN: unknown policy $policy" >&2
      ;;
  esac
done < "$BENCH"

# region 正例（Z4 无 runtime 标签）
if "$SHUX_BIN" check tests/typeck/slice_lifetime/region_same_ok.x >/dev/null 2>&1; then
  echo "type-zero-cost OK region_same"
else
  echo "type-zero-cost FAIL: region_same_ok.x" >&2
  FAILS=$((FAILS + 1))
fi

if [ "$FAILS" -gt 0 ]; then
  echo "type-zero-cost FAIL: ${FAILS} case(s)" >&2
  exit 1
fi

echo "type-zero-cost OK"
