#!/usr/bin/env bash
# std-bytes.sh — STD-072 manifest 与烟测辅助

STD_BYTES_PREFIX="${SHU_STD_BYTES_PREFIX:-shu: [SHU_STD_BYTES]}"

# 遍历 manifest 校验 api/file/smoke。
std_bytes_symbols_ok() {
  local mod_su="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-bytes FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors)
        if [ ! -f "$anchor" ]; then
          echo "std-bytes FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .su round-trip 烟测。
std_bytes_run_smoke() {
  local shu="$1"
  local src="$2"
  local tag="${3:-bytes}"
  local exe="/tmp/shu_std_bytes_${tag}_$$"
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-bytes FAIL: compile $src" >&2
    "$shu" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-bytes FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_bytes_emit_report() {
  local status="$1"
  local su_ok="$2"
  local skip="$3"
  echo "${STD_BYTES_PREFIX} status=${status} su=${su_ok} skip=${skip}"
}
