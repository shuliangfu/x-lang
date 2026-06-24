#!/usr/bin/env bash
# std-heap-allocator.sh — STD-112 manifest 与烟测辅助

STD_HEAP_ALLOC_PREFIX="${SHUX_STD112_HEAP_ALLOC_PREFIX:-shux: [SHUX_STD112_HEAP_ALLOC]}"

# 校验 manifest 中 api/file/smoke。
std_heap_alloc_symbols_ok() {
  local heap_sx="$1"
  local vec_sx="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        local path="$heap_sx"
        if [ "$mod_path" = "std/vec/mod.sx" ]; then path="$vec_sx"; fi
        if ! grep -qE "function ${anchor}\\(" "$path" 2>/dev/null; then
          echo "std-heap-allocator FAIL: missing api '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-heap-allocator FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测。
std_heap_alloc_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-alloc}"
  local exe="/tmp/shux_std_heap_alloc_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-heap-allocator FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-heap-allocator FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_heap_alloc_emit_report() {
  local status="$1"
  local su_ok="$2"
  local skip="$3"
  echo "${STD_HEAP_ALLOC_PREFIX} status=${status} sx=${su_ok} skip=${skip}"
}
