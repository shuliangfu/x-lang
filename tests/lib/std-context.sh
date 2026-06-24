#!/usr/bin/env bash
# std-context.sh — STD-071 manifest 与烟测辅助（F-context v2：纯 context.sx）

STD_CONTEXT_PREFIX="${SHUX_STD_CONTEXT_PREFIX:-shux: [SHUX_STD_CONTEXT]}"

# 遍历 manifest 校验 symbol/file/smoke；symbol 在 context.sx。
std_context_symbols_ok() {
  local mod_sx="$1"
  local ctx_sx="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-context FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/context/context.c|std/context/context.sx|std/context/context_node_glue.c) path="$ctx_sx" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-context FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-context FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# C 烟测：context.o + time.o（需 shux-c 产出 context.o）。
std_context_run_c_smoke() {
  local ctx_sx="$1"
  local src="tests/std-context/context_smoke_ok.c"
  local out="/tmp/shux_std_context_$$"
  local ctx_o time_o
  ctx_o="$(dirname "$ctx_sx")/context.o"
  time_o="std/time/time.o"
  if [ ! -f "$ctx_o" ]; then
    echo "std-context FAIL: missing $ctx_o" >&2
    return 1
  fi
  if [ ! -f "$time_o" ]; then
    make -C compiler ../std/time/time.o >/dev/null 2>&1 || true
  fi
  make -C compiler runtime_time_os.o >/dev/null 2>&1 || true
  if ! cc -std=c11 -O1 -o "$out" "$src" "$ctx_o" "$time_o" compiler/runtime_time_os.o 2>/dev/null; then
    echo "std-context FAIL: compile c smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-context FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 编译并运行 .sx 烟测。
std_context_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-ctx}"
  local exe="/tmp/shux_std_context_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-context FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-context FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_context_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_CONTEXT_PREFIX} status=${status} c_smoke=${c_ok} sx=${su_ok} skip=${skip}"
}
