#!/usr/bin/env bash
# comp-incr-compile.sh — COMP-007 增量编译共享辅助
#
# 二次编译计时、ratio 计算、native shux 探测。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# 判断本机能否执行指定编译器二进制。
comp_incr_compile_native_shu() {
  local f="${1:-./compiler/shux-c}"
  [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# 从 SHUX_COMPILE_PHASE_TIMING 汇总行解析 total_ms；失败返回空。
comp_incr_compile_parse_total_ms() {
  local log="$1"
  local ms=""
  ms="$(printf '%s' "$log" | grep -E 'SHUX_COMPILE_PHASE_TIMING.*total_ms=' | tail -1 \
    | sed -E 's/.*total_ms=([0-9.]+).*/\1/' 2>/dev/null || true)"
  printf '%s' "$ms"
}

# 用 /usr/bin/time 或 date 测量命令 wall ms（兜底无 phase timing 时）。
comp_incr_compile_wall_ms() {
  local start end
  start="$(python3 -c 'import time; print(time.perf_counter())')"
  # shellcheck disable=SC2068
  "$@" >/dev/null 2>&1
  end="$(python3 -c 'import time; print(time.perf_counter())')"
  python3 -c "print(int(($end - $start) * 1000))"
}

# 计算 second/first ratio（保留两位小数）；first=0 时返回 1.0。
comp_incr_compile_ratio() {
  local first="$1"
  local second="$2"
  awk -v a="$first" -v b="$second" 'BEGIN {
    if (a+0 <= 0) { printf "1.00"; exit }
    printf "%.2f", b/a
  }'
}

# 校验原型符号在源码中存在。
comp_incr_compile_proto_present() {
  local src="$1"
  local sym="$2"
  [ -f "$ROOT/$src" ] || return 1
  grep -qF "$sym" "$ROOT/$src" 2>/dev/null
}
