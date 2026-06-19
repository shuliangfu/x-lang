#!/usr/bin/env bash
# perf-sqlite.sh — PERF-170 SQLite stub/loop 烟测辅助
#
# 用法（source 后）：
#   perf_sqlite_native_shu
#   perf_sqlite_median_real exe runs
#   perf_sqlite_emit_report status check_ok run_ok skip

PERF_SQL_PREFIX="${SHUX_PERF_SQL_PREFIX:-shux: [SHUX_PERF_SQL]}"

# 判断 shux 是否可在本机执行。
perf_sqlite_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# 从 time 输出提取 real 秒数。
perf_sqlite_extract_real_sec() {
  sed -n 's/^real[[:space:]]*\([0-9]*\)m\([0-9.]*\)s.*/\1 \2/p; s/^real[[:space:]]*\([0-9.]*\)s.*/0 \1/p' \
    | awk 'NF==2 { print $1*60+$2; next } NF==1 { print $1 }'
}

# 多次运行取 real 中位数。
perf_sqlite_median_real() {
  local exe="$1"
  local runs="${2:-3}"
  local i vals med
  vals=""
  for i in $(seq 1 "$runs"); do
    vals=$( ( time "$exe" >/dev/null ) 2>&1 | perf_sqlite_extract_real_sec; printf '\n%s' "$vals" )
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

# 输出结构化报告行。
perf_sqlite_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${PERF_SQL_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
