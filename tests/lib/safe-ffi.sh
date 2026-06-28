#!/usr/bin/env bash
# safe-ffi.sh — SAFE-004 共享：FFI 契约用例编译运行
#
# 用法（source 后）：
#   safe_ffi_contract_count [manifest_tsv]
#   safe_ffi_run_case SHUX_BIN src expect_rc [tag]

# 统计 manifest 中 case 行数（case_id 以 case_ 开头）。
safe_ffi_contract_count() {
  local man="${1:-tests/baseline/safe-ffi-contract.tsv}"
  awk -F'\t' '$1 ~ /^case_/ { n++ } END { print n+0 }' "$man"
}

# 编译并运行单个契约 .sx；校验退出码。
safe_ffi_run_case() {
  local shux="$1"
  local src="$2"
  local expect="${3:-0}"
  local tag="${4:-case}"
  local exe="/tmp/shux_safe_ffi_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "safe-ffi FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -backend c -L . "$src" -o "$exe" >/dev/null 2>&1; then
    "$shux" -backend c -L . "$src" -o "$exe" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  local ec=0
  "$exe" >/dev/null 2>&1 || ec=$?
  rm -f "$exe"
  if [ "$ec" -ne "$expect" ]; then
    echo "safe-ffi FAIL: $tag exit=$ec expect=$expect ($src)" >&2
    return 1
  fi
  return 0
}
