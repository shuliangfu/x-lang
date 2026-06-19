#!/usr/bin/env bash
# WPO A/B 快路径：build_asm 已有压缩 .o 时用 baseline proxy 作 dce_off，免重复 EMIT_HEAVY 重编。
# 被 run-perf-wpo-dce-compiler-self-text.sh / run-perf-wpo-dce-shux-asm-text.sh source。
# 关闭：SHUX_WPO_FAST_AB=0

wpo_ab_proxy_from_baseline() {
  local key="$1"
  local baseline="${2:-tests/baseline/wpo-dce-compiler-self-text.tsv}"
  awk -F'\t' -v k="$key" '$1==k && $1 !~ /^#/ { print $2; exit }' "$baseline"
}

# 读 .o 的 .text/__text 段字节数（Mach-O 与 ELF；macOS size 无法读 Linux ELF）。
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

# main.sx：MON=树内 main.o；MOFF=baseline proxy（生产 WPO 链）。
wpo_ab_try_main_fast() {
  local build_main="$1"
  local baseline="$2"
  local max_on="${3:-768}"
  local off_proxy on_txt
  [ "${SHUX_WPO_FAST_AB:-1}" = "1" ] || return 1
  [ -f "$build_main" ] || return 1
  off_proxy=$(wpo_ab_proxy_from_baseline "main_dce_off_text" "$baseline")
  off_proxy=${off_proxy:-1304}
  on_txt=$(wpo_ab_text_bytes "$build_main") || return 1
  [ "$on_txt" -le "$max_on" ] 2>/dev/null || return 1
  nm "$build_main" 2>/dev/null | grep -q ' entry$' || return 1
  echo "$off_proxy $on_txt"
  return 0
}

# driver/compile.sx：DON=树内 driver_compile.o；DOFF=baseline proxy。
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
  nm "$build_drv" 2>/dev/null | grep -qE ' T (compile_dispatch_asm_backend|run_compiler_full_su|entry)$' || return 1
  echo "$off_proxy $on_txt"
  return 0
}

# pipeline.sx：PON=树内 pipeline.o 或 pipeline_wpo.o；POFF=baseline proxy（须 < emit_heavy min）。
wpo_ab_try_pipeline_fast() {
  local build_pipe="$1"
  local baseline="$2"
  local emit_heavy_min="${3:-2048}"
  local off_proxy on_txt
  [ "${SHUX_WPO_FAST_AB:-1}" = "1" ] || return 1
  [ -f "$build_pipe" ] || return 1
  off_proxy=$(wpo_ab_proxy_from_baseline "pipeline_dce_off_text" "$baseline")
  off_proxy=${off_proxy:-11588}
  on_txt=$(wpo_ab_text_bytes "$build_pipe") || return 1
  [ "$on_txt" -lt "$emit_heavy_min" ] 2>/dev/null || return 1
  nm "$build_pipe" 2>/dev/null | grep -q 'run_sx_pipeline_impl' || return 1
  echo "$off_proxy $on_txt"
  return 0
}

# typeck.sx：TON=树内 typeck_wpo.o；TOFF=baseline proxy（须 < emit_heavy min）。
wpo_ab_try_typeck_fast() {
  local build_tck="$1"
  local baseline="$2"
  local emit_heavy_min="${3:-2048}"
  local off_proxy on_txt
  [ "${SHUX_WPO_FAST_AB:-1}" = "1" ] || return 1
  [ -f "$build_tck" ] || return 1
  off_proxy=$(wpo_ab_proxy_from_baseline "typeck_dce_off_text" "$baseline")
  off_proxy=${off_proxy:-79397}
  on_txt=$(wpo_ab_text_bytes "$build_tck") || return 1
  [ "$on_txt" -lt "$emit_heavy_min" ] 2>/dev/null || return 1
  nm "$build_tck" 2>/dev/null | grep -q 'typeck_su_ast' || return 1
  nm "$build_tck" 2>/dev/null | grep -q 'check_block' || return 1
  echo "$off_proxy $on_txt"
  return 0
}

# backend.sx：BON=树内 backend_wpo.o；BOFF=baseline proxy（须 < emit_heavy min）。
wpo_ab_try_backend_fast() {
  local build_be="$1"
  local baseline="$2"
  local emit_heavy_min="${3:-4096}"
  local off_proxy on_txt
  [ "${SHUX_WPO_FAST_AB:-1}" = "1" ] || return 1
  [ -f "$build_be" ] || return 1
  off_proxy=$(wpo_ab_proxy_from_baseline "backend_dce_off_text" "$baseline")
  off_proxy=${off_proxy:-4677}
  on_txt=$(wpo_ab_text_bytes "$build_be") || return 1
  [ "$on_txt" -lt "$emit_heavy_min" ] 2>/dev/null || return 1
  nm "$build_be" 2>/dev/null | grep -q 'asm_codegen_ast' || return 1
  echo "$off_proxy $on_txt"
  return 0
}
