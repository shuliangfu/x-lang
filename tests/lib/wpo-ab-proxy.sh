#!/usr/bin/env bash
# WPO A/B 快路径：build_asm 已有压缩 .o 时用 baseline proxy 作 dce_off，免重复 EMIT_HEAVY 重编。
# 被 run-perf-wpo-dce-compiler-self-text.sh / run-perf-wpo-dce-shux-asm-text.sh source。
# 关闭：SHUX_WPO_FAST_AB=0
#
# PLATFORM: SHARED (helpers) / LINUX (binary proxy dogfood 金标)
# Authority for max_on / dce_off:
#   o-gate baselines (wpo-main-o / pipeline-o / typeck-o / backend-o) +
#   shared proxy table tests/baseline/wpo-dce-compiler-self-text.tsv
# Do not hardcode stale 768/2048 caps that reject production WPO .o accepted by chain gates.

wpo_ab_proxy_from_baseline() {
  local key="$1"
  local baseline="${2:-tests/baseline/wpo-dce-compiler-self-text.tsv}"
  awk -F'\t' -v k="$key" '$1==k && $1 !~ /^#/ { print $2; exit }' "$baseline"
}

# Read .text/__text size (Mach-O + ELF; macOS size cannot read Linux ELF).
wpo_ab_text_bytes() {
  local obj="$1"
  local hex n
  hex=$(objdump -h "$obj" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
  if [ -z "$hex" ]; then
    hex=$(objdump -h "$obj" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
  fi
  if [ -n "$hex" ]; then
    n=$(perl -e 'print hex(shift)' "$hex" 2>/dev/null || echo 0)
    if [ -n "$n" ] && [ "$n" -gt 0 ] 2>/dev/null; then
      echo "$n"
      return 0
    fi
  fi
  n=$(size -A "$obj" 2>/dev/null | awk '/\.text/ { print $2; exit }')
  if [ -n "$n" ] && [ "$n" -gt 0 ] 2>/dev/null; then
    echo "$n"
    return 0
  fi
  n=$(size -x "$obj" 2>/dev/null | awk 'NR==2 { print $1; exit }')
  if [ -n "$n" ] && [ "$n" -gt 0 ] 2>/dev/null; then
    echo "$n"
    return 0
  fi
  return 1
}

# Prefer module o-gate baseline key, then shared proxy table, then default.
wpo_ab_proxy_prefer() {
  local key="$1"
  local module_baseline="$2"
  local shared_baseline="$3"
  local default="$4"
  local v
  v=$(wpo_ab_proxy_from_baseline "$key" "$module_baseline")
  if [ -n "$v" ]; then
    echo "$v"
    return 0
  fi
  v=$(wpo_ab_proxy_from_baseline "$key" "$shared_baseline")
  if [ -n "$v" ]; then
    echo "$v"
    return 0
  fi
  echo "$default"
}

# main.x：MON=树内 main.o；MOFF=baseline proxy（生产 WPO 链）。
# max_on 权威：tests/baseline/wpo-main-o.tsv main_o_max_text_bytes（默认 2048）。
wpo_ab_try_main_fast() {
  local build_main="$1"
  local baseline="$2"
  local max_on="${3:-}"
  local off_proxy on_txt
  [ "${SHUX_WPO_FAST_AB:-1}" = "1" ] || return 1
  [ -f "$build_main" ] || return 1
  if [ -z "$max_on" ]; then
    max_on=$(wpo_ab_proxy_prefer "main_o_max_text_bytes" \
      "tests/baseline/wpo-main-o.tsv" "$baseline" "2048")
  fi
  off_proxy=$(wpo_ab_proxy_from_baseline "main_dce_off_text" "$baseline")
  off_proxy=${off_proxy:-1304}
  on_txt=$(wpo_ab_text_bytes "$build_main") || return 1
  [ "$on_txt" -le "$max_on" ] 2>/dev/null || return 1
  nm "$build_main" 2>/dev/null | grep -q ' entry$' || return 1
  echo "$off_proxy $on_txt"
  return 0
}

# driver/compile.x：DON=树内 driver_compile.o；DOFF=baseline proxy。
wpo_ab_try_driver_fast() {
  local build_drv="$1"
  local baseline="$2"
  local max_on="${3:-768}"
  local off_proxy on_txt
  [ "${SHUX_WPO_FAST_AB:-1}" = "1" ] || return 1
  [ -f "$build_drv" ] || return 1
  off_proxy=$(wpo_ab_proxy_from_baseline "driver_dce_off_text" "$baseline")
  off_proxy=${off_proxy:-7637}
  on_txt=$(wpo_ab_text_bytes "$build_drv") || return 1
  [ "$on_txt" -le "$max_on" ] 2>/dev/null || return 1
  nm "$build_drv" 2>/dev/null | grep -qE ' T (compile_dispatch_asm_backend|run_compiler_full_x|entry)$' || return 1
  echo "$off_proxy $on_txt"
  return 0
}

# pipeline.x：PON=树内 pipeline_wpo.o；POFF=baseline proxy。
# max_on 权威：wpo-pipeline-o.tsv pipeline_wpo_max_text_bytes（默认 12288）。
# 历史第 3 参误作 emit_heavy_min=2048 会拒绝 reach 修复后合法的 ~7KiB pipeline_wpo。
wpo_ab_try_pipeline_fast() {
  local build_pipe="$1"
  local baseline="$2"
  local max_on="${3:-}"
  local off_proxy on_txt
  [ "${SHUX_WPO_FAST_AB:-1}" = "1" ] || return 1
  [ -f "$build_pipe" ] || return 1
  if [ -z "$max_on" ]; then
    max_on=$(wpo_ab_proxy_prefer "pipeline_wpo_max_text_bytes" \
      "tests/baseline/wpo-pipeline-o.tsv" "$baseline" "12288")
  fi
  off_proxy=$(wpo_ab_proxy_prefer "pipeline_dce_off_text" \
    "tests/baseline/wpo-pipeline-o.tsv" "$baseline" "11588")
  on_txt=$(wpo_ab_text_bytes "$build_pipe") || return 1
  [ "$on_txt" -le "$max_on" ] 2>/dev/null || return 1
  # WPO-on must still beat dce_off proxy (positive eligible save).
  [ "$on_txt" -lt "$off_proxy" ] 2>/dev/null || return 1
  nm "$build_pipe" 2>/dev/null | grep -q 'run_x_pipeline_impl' || return 1
  echo "$off_proxy $on_txt"
  return 0
}

# typeck.x：TON=树内 typeck_wpo.o；TOFF=baseline proxy。
# max_on / dce_off 权威：wpo-typeck-o.tsv（默认 max 6144 / off 105821）。
wpo_ab_try_typeck_fast() {
  local build_tck="$1"
  local baseline="$2"
  local max_on="${3:-}"
  local off_proxy on_txt
  [ "${SHUX_WPO_FAST_AB:-1}" = "1" ] || return 1
  [ -f "$build_tck" ] || return 1
  if [ -z "$max_on" ]; then
    max_on=$(wpo_ab_proxy_prefer "typeck_wpo_max_text_bytes" \
      "tests/baseline/wpo-typeck-o.tsv" "$baseline" "6144")
  fi
  off_proxy=$(wpo_ab_proxy_prefer "typeck_dce_off_text" \
    "tests/baseline/wpo-typeck-o.tsv" "$baseline" "105821")
  on_txt=$(wpo_ab_text_bytes "$build_tck") || return 1
  [ "$on_txt" -le "$max_on" ] 2>/dev/null || return 1
  [ "$on_txt" -lt "$off_proxy" ] 2>/dev/null || return 1
  nm "$build_tck" 2>/dev/null | grep -q 'typeck_x_ast' || return 1
  nm "$build_tck" 2>/dev/null | grep -q 'check_block' || return 1
  echo "$off_proxy $on_txt"
  return 0
}

# backend.x：BON=树内 backend_wpo.o；BOFF=baseline proxy。
# max_on 权威：wpo-backend-o.tsv backend_wpo_max_text_bytes（默认 512）。
wpo_ab_try_backend_fast() {
  local build_be="$1"
  local baseline="$2"
  local max_on="${3:-}"
  local off_proxy on_txt
  [ "${SHUX_WPO_FAST_AB:-1}" = "1" ] || return 1
  [ -f "$build_be" ] || return 1
  if [ -z "$max_on" ]; then
    max_on=$(wpo_ab_proxy_prefer "backend_wpo_max_text_bytes" \
      "tests/baseline/wpo-backend-o.tsv" "$baseline" "512")
  fi
  off_proxy=$(wpo_ab_proxy_prefer "backend_dce_off_text" \
    "tests/baseline/wpo-backend-o.tsv" "$baseline" "4677")
  on_txt=$(wpo_ab_text_bytes "$build_be") || return 1
  [ "$on_txt" -le "$max_on" ] 2>/dev/null || return 1
  [ "$on_txt" -lt "$off_proxy" ] 2>/dev/null || return 1
  nm "$build_be" 2>/dev/null | grep -q 'asm_codegen_ast' || return 1
  echo "$off_proxy $on_txt"
  return 0
}
