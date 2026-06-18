#!/usr/bin/env bash
# std-api.sh — STD-136：std 全模块 manifest/gate 注册表校验

STD_API_PREFIX="${SHU_STD136_STD_API_PREFIX:-shu: [SHU_STD136_STD_API]}"

# 校验 BOOT-013 矩阵含 60 个 std 模块行。
std_api_matrix_ok() {
  local matrix="$1"
  local miss=0
  local expect
  for expect in std_async std_atomic std_backtrace std_base64 std_bytes std_cache std_channel \
    std_cli std_config std_compress std_context std_codec std_crypto std_csv std_datetime \
    std_sqlite std_dynlib std_elf std_encoding std_env std_error std_ffi std_fmt std_fs \
    std_hash std_heap std_http std_io std_json std_log std_map std_math std_mem std_metrics \
    std_net std_option std_path std_process std_queue std_random std_regex std_result \
    std_runtime std_schema std_security std_set std_simd std_sort std_string std_sync \
    std_task std_tar std_test std_thread std_time std_trace std_unicode std_url std_uuid std_vec; do
    if ! grep -qF "$expect" "$matrix" 2>/dev/null; then
      echo "std-api FAIL: stdlib-check-matrix missing row '$expect'" >&2
      miss=$((miss + 1))
    fi
  done
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 输出结构化报告行。
std_api_emit_report() {
  local status="$1"
  local covered="$2"
  local miss="$3"
  echo "${STD_API_PREFIX} status=${status} covered=${covered} miss=${miss}"
}
