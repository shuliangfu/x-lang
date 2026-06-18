#!/usr/bin/env bash
# std-regex-perf.sh — STD-062 regex perf 共享辅助
#
# 用法（source 后）：
#   std_regex_perf_has_cc
#   std_regex_perf_emit_report status bench_ok bench_skip skip ratio host

STD_REGEX_PERF_PREFIX="${SHU_STD062_PREFIX:-shu: [SHU_STD062_REGEX_PERF]}"

# 本机是否有 C 编译器可跑 bench。
std_regex_perf_has_cc() {
  command -v cc >/dev/null 2>&1
}

# 输出结构化报告行。
std_regex_perf_emit_report() {
  local status="$1"
  local bench_ok="$2"
  local bench_skip="$3"
  local skip="$4"
  local ratio="${5:-}"
  local host="${6:-}"
  if [ -n "$ratio" ]; then
    echo "${STD_REGEX_PERF_PREFIX} status=${status} bench_ok=${bench_ok} bench_skip=${bench_skip} skip=${skip} ratio=${ratio} host=${host}"
  else
    echo "${STD_REGEX_PERF_PREFIX} status=${status} bench_ok=${bench_ok} bench_skip=${bench_skip} skip=${skip} host=${host}"
  fi
}
