#!/usr/bin/env bash
# IO-A6 Windows IOCP pipe 批量 perf（对齐 io_batch_readv 规模感）
# 用法：./tests/run-perf-iocp.sh [--bench]
# 门禁（可选）：
#   SHU_PERF_FAIL_ON_IOCP_REGRESSION=1 — median ≤ tests/baseline/iocp-perf.tsv
#   SHU_PERF_UPDATE_IOCP_BASELINE=1 — 刷新 iocp-perf.tsv
# 非 Windows MSYS2：SKIP exit 0
set -e
cd "$(dirname "$0")/.."

DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
[ "${SHU_PERF_FAIL_ON_IOCP_REGRESSION:-0}" = "1" ] && PERF_FAIL=1 || PERF_FAIL=0
RUNS="${SHU_IOCP_RUNS:-3}"
[ "${CI:-0}" = "1" ] && RUNS="${SHU_IOCP_RUNS:-1}"
ROUNDS="${SHU_IOCP_BENCH_ROUNDS:-65536}"
BASELINE="${SHU_PERF_IOCP_BASELINE:-tests/baseline/iocp-perf.tsv}"

_is_windows_msys() {
  case "$(uname -s 2>/dev/null)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
  esac
  case "$(uname -o 2>/dev/null)" in
    Msys|Cygwin) return 0 ;;
  esac
  return 1
}

extract_real_sec() {
  sed -n 's/^real[[:space:]]*\([0-9]*\)m\([0-9.]*\)s.*/\1 \2/p; s/^real[[:space:]]*\([0-9.]*\)s.*/0 \1/p' \
    | awk 'NF==2 { print $1*60+$2; next } NF==1 { print $1 }'
}

iocp_baseline_cap() {
  local name="$1"
  awk -F'\t' -v c="$name" '$1==c && NF>=2 { print $2; exit }' "$BASELINE" 2>/dev/null || true
}

check_iocp_regress() {
  local name="$1"
  local med="$2"
  local cap
  cap=$(iocp_baseline_cap "$name")
  [ -z "$cap" ] && return 0
  if awk -v m="$med" -v c="$cap" 'BEGIN { exit (m != "nan" && m+0 <= c+0) ? 0 : 1 }'; then
    echo "iocp perf OK: $name median ${med}s ≤ cap ${cap}s"
  else
    echo "iocp perf FAIL: $name median ${med}s > cap ${cap}s" >&2
    [ "$PERF_FAIL" -eq 1 ] && exit 1
  fi
}

if ! _is_windows_msys; then
  echo "run-perf-iocp: SKIP (non-Windows MSYS2)"
  exit 0
fi

if [ "$DO_BENCH" -eq 0 ]; then
  echo "run-perf-iocp: use --bench to run iocp_pipe_batch"
  exit 0
fi

make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler ../std/io/io.o -q 2>/dev/null || make -C compiler ../std/io/io.o

OUT="/tmp/shu_iocp_pipe_loop"
if ! cc -O2 -Wall tests/bench/iocp_pipe_loop.c std/io/io.o -o "$OUT" 2>/dev/null; then
  echo "run-perf-iocp: SKIP (link failed)"
  exit 0
fi

echo "=== tests/bench/iocp_pipe_loop (${ROUNDS} rounds 2×64B batch @ IOCP) ==="
vals=""
i=0
while [ "$i" -lt "$RUNS" ]; do
  i=$((i + 1))
  v=$( ( SHU_IOCP_BENCH_ROUNDS="$ROUNDS" time "$OUT" >/dev/null ) 2>&1 | extract_real_sec)
  vals=$(printf '%s\n%s' "$vals" "$v")
done
med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
  a[NR]=$1
} END {
  if (NR==0) { print "nan"; exit }
  if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
}')
echo "Shu IOCP pipe batch median real: ${med}s"
printf '\n| iocp_pipe_batch | real (s) 中位数 |\n|---|----------------|\n| Shu (IOCP batch) | %s |\n\n' "$med"

check_iocp_regress iocp_pipe_batch "$med"

if [ "${SHU_PERF_UPDATE_IOCP_BASELINE:-0}" = "1" ] && [ "$med" != "nan" ]; then
  {
    echo "# shu IOCP pipe batch bench 中位数上限（秒）；门禁：实测 median ≤ 本列值"
    echo "# 更新：SHU_PERF_UPDATE_IOCP_BASELINE=1 ./tests/run-perf-iocp.sh --bench"
    echo "# 仅 Windows MSYS2；65536 轮 2×64B write_batch + read_batch"
    printf 'iocp_pipe_batch\t%s\n' "$med"
  } >"$BASELINE"
  echo "run-perf-iocp: updated $BASELINE"
fi

echo "iocp perf OK"
