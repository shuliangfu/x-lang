#!/usr/bin/env bash
# perf-coldstart.sh — PERF-010 冷启动共享辅助
#
# 读取 coldstart-perf.tsv cap、判断 native shux。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
CAP_FILE="${SHUX_PERF_COLDSTART_CAP:-$ROOT/tests/baseline/coldstart-perf.tsv}"

# 本机可执行 shux（与 perf-compile-dogfood gate 一致）。
perf_coldstart_native_shu() {
  local f="${1:-./compiler/shux}"
  [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 0 ;;
  esac
}

# 从 coldstart-perf.tsv 读取 metric 上限。
perf_coldstart_cap() {
  local key="$1"
  [ -f "$CAP_FILE" ] || return 1
  awk -F'\t' -v k="$key" '$1==k { print $2; exit }' "$CAP_FILE"
}

# 统计 coldstart-perf.tsv 中有效 metric 行数。
perf_coldstart_metric_count() {
  local n=0
  while IFS=$'\t' read -r k v _rest; do
    [ -z "${k:-}" ] && continue
    case "$k" in \#*) continue ;; esac
    [ -n "${v:-}" ] || continue
    n=$((n + 1))
  done < "$CAP_FILE"
  echo "$n"
}
