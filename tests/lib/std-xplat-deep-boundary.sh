#!/usr/bin/env bash
# std-xplat-deep-boundary.sh — STD-138 三平台深度边界 manifest 与烟测辅助

STD_XPLAT_DEEP_PREFIX="${SHU_STD138_XPLAT_DEEP_BOUNDARY_PREFIX:-shu: [SHU_STD138_XPLAT_DEEP_BOUNDARY]}"

# 按当前宿主返回 linux/macos/windows 列策略。
xplat_deep_platform_policy() {
  # shellcheck source=tests/lib/ci-host.sh
  . "$(dirname "${BASH_SOURCE[0]}")/ci-host.sh"
  local linux="$1"
  local macos="$2"
  local windows="$3"
  if ci_is_linux; then
    echo "$linux"
  elif ci_is_darwin; then
    echo "$macos"
  elif ci_is_windows_msys; then
    echo "$windows"
  else
    echo "must"
  fi
}

# 校验 manifest 路径存在；echo 缺失数。
xplat_deep_verify_paths() {
  local tsv="$1"
  local min_rows="$2"
  local miss=0
  local rows=0
  local item_id kind path _l _m _w _notes
  while IFS=$'\t' read -r item_id kind path _l _m _w _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    rows=$((rows + 1))
    if [ ! -f "$path" ]; then
      echo "xplat-deep FAIL: missing $path ($item_id)" >&2
      miss=$((miss + 1))
    fi
  done < "$tsv"
  if [ "$rows" -lt "$min_rows" ]; then
    echo "xplat-deep FAIL: rows=${rows} < min ${min_rows}" >&2
    miss=$((miss + 1))
  fi
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 统计 matrix TSV 数据行（不含 # 与 min_）。
xplat_deep_matrix_rows() {
  local tsv="$1"
  local n=0
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|\#*) continue ;;
      min_*) continue ;;
    esac
    n=$((n + 1))
  done < "$tsv"
  echo "$n"
}

# 编译并运行 .su 烟测。
xplat_deep_run_smoke() {
  local shu="$1"
  local src="$2"
  local exe="/tmp/shu_xplat_deep_$$"
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "xplat-deep FAIL: compile $src" >&2
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

# 输出 gate 报告。
xplat_deep_emit_report() {
  echo "${STD_XPLAT_DEEP_PREFIX} status=$1 smoke=$2 skip=$3 host=$4"
}
