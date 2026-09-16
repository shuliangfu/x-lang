#!/usr/bin/env bash
# IO-A6 Windows IOCP pipe batch perf (aligns with io_batch_readv scale).
#
# Honesty: soft XLANG_PERF_FAIL_ON_IOCP_REGRESSION:-0 previously left
# over-cap unchecked (silent OK = portable false-green). Soft SKIP on
# link-fail (Windows) retired → hard die. Non-Windows MSYS2 = skip with
# status report (platform N/A, not soft FAIL swallow). Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-iocp.sh [--bench]
# Env:
#   XLANG_PERF_FAIL_ON_IOCP_REGRESSION=1 — median ≤ iocp-perf.tsv hard
#   XLANG_PERF_UPDATE_IOCP_BASELINE=1 — refresh iocp-perf.tsv
# PLATFORM: WINDOWS (MSYS2) — live bench; other hosts skip=1.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DO_BENCH=0
[ "${1:-}" = "--bench" ] && DO_BENCH=1
[ "${XLANG_PERF_FAIL_ON_IOCP_REGRESSION:-0}" = "1" ] && PERF_FAIL=1 || PERF_FAIL=0
RUNS="${XLANG_IOCP_RUNS:-3}"
[ "${CI:-0}" = "1" ] && RUNS="${XLANG_IOCP_RUNS:-1}"
ROUNDS="${XLANG_IOCP_BENCH_ROUNDS:-65536}"
BASELINE="${XLANG_PERF_IOCP_BASELINE:-tests/baseline/iocp-perf.tsv}"

PREFIX="xlang: [XLANG_PERF_IOCP]"
OBS=0
RUN_OK=0
SKIP=0

die() {
  echo "iocp perf FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

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

# Wall-time via date delta; MSYS2 bash time often lacks a real line → nan.
iocp_bench_wall_sec() {
  local start end
  start=$(date +%s.%N 2>/dev/null || date +%s)
  XLANG_IOCP_BENCH_ROUNDS="$ROUNDS" "$OUT" >/dev/null
  end=$(date +%s.%N 2>/dev/null || date +%s)
  awk -v s="$start" -v e="$end" 'BEGIN { if (e > s) print e - s; else print "nan" }'
}

iocp_baseline_cap() {
  local name="$1"
  awk -F'\t' -v c="$name" '$1==c && NF>=2 { print $2; exit }' "$BASELINE" 2>/dev/null || true
}

# Cap check: always compare when measured. Over-cap / nan = obs when PERF_FAIL=0.
check_iocp_regress() {
  local name="$1"
  local med="$2"
  local cap
  if [ "$med" = "nan" ]; then
    echo "iocp perf OBS: $name median nan" >&2
    OBS=$((OBS + 1))
    if [ "$PERF_FAIL" -eq 1 ]; then
      die "$name median nan (XLANG_PERF_FAIL_ON_IOCP_REGRESSION=1)"
    fi
    return 0
  fi
  cap=$(iocp_baseline_cap "$name")
  [ -z "$cap" ] && return 0
  if awk -v m="$med" -v c="$cap" 'BEGIN { exit (m+0 <= c+0) ? 0 : 1 }'; then
    echo "iocp perf OK: $name median ${med}s ≤ cap ${cap}s"
  else
    echo "iocp perf OBS: $name median ${med}s > cap ${cap}s" >&2
    OBS=$((OBS + 1))
    if [ "$PERF_FAIL" -eq 1 ]; then
      die "$name median ${med}s > cap ${cap}s (XLANG_PERF_FAIL_ON_IOCP_REGRESSION=1)"
    fi
  fi
}

if ! _is_windows_msys; then
  echo "run-perf-iocp: SKIP (non-Windows MSYS2; platform N/A)"
  SKIP=1
  echo "${PREFIX} status=ok run=0 obs=0 skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ "$DO_BENCH" -eq 0 ]; then
  echo "run-perf-iocp: use --bench to run iocp_pipe_batch"
  echo "${PREFIX} status=ok run=0 obs=0 skip=1 host=$(ci_host_summary)"
  exit 0
fi

# PLATFORM: WINDOWS — need std/io.o for IOCP pipe batch link.
if [ ! -f std/io/io.o ]; then
  die "missing std/io/io.o (refuse soft auto-make / soft SKIP→OK)"
fi

OUT="/tmp/xlang_iocp_pipe_loop"
if ! cc -O2 -Wall bench/iocp_pipe_loop.c std/io/io.o -o "$OUT" 2>/tmp/iocp_link.log; then
  cat /tmp/iocp_link.log >&2
  die "iocp link failed (refuse soft SKIP→OK on Windows)"
fi

echo "=== bench/iocp_pipe_loop (${ROUNDS} rounds 2×64B batch @ IOCP) ==="
vals=""
i=0
while [ "$i" -lt "$RUNS" ]; do
  i=$((i + 1))
  v=$( ( XLANG_IOCP_BENCH_ROUNDS="$ROUNDS" time "$OUT" >/dev/null ) 2>&1 | extract_real_sec)
  if [ -z "$v" ] || [ "$v" = "nan" ]; then
    v=$(iocp_bench_wall_sec)
  fi
  vals=$(printf '%s\n%s' "$vals" "$v")
done
med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
  a[NR]=$1
} END {
  if (NR==0) { print "nan"; exit }
  if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
}')
echo "Xlang IOCP pipe batch median real: ${med}s"
printf '\n| iocp_pipe_batch | real (s) 中位数 |\n|---|----------------|\n| Xlang (IOCP batch) | %s |\n\n' "$med"
RUN_OK=1

check_iocp_regress iocp_pipe_batch "$med"

if [ "${XLANG_PERF_UPDATE_IOCP_BASELINE:-0}" = "1" ] && [ "$med" != "nan" ]; then
  {
    echo "# xlang IOCP pipe batch bench 中位数上限（秒）；门禁：实测 median ≤ 本列值"
    echo "# 更新：XLANG_PERF_UPDATE_IOCP_BASELINE=1 ./tests/run-perf-iocp.sh --bench"
    echo "# 仅 Windows MSYS2；65536 轮 2×64B write_batch + read_batch"
    printf 'iocp_pipe_batch\t%s\n' "$med"
  } >"$BASELINE"
  echo "run-perf-iocp: updated $BASELINE"
fi

echo "iocp perf OK"
echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
exit 0
