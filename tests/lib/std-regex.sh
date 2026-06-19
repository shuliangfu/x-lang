#!/usr/bin/env bash
# std-regex.sh — STD-051 manifest 与三平台烟测辅助

STD_REGEX_PREFIX="${SHUX_STD_REGEX_PREFIX:-shux: [SHUX_STD_REGEX]}"

# 遍历 manifest TSV，校验 api/file/symbol/smoke 锚点。
std_regex_symbols_ok() {
  local mod_su="$1"
  local regex_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-regex FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-regex FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/regex/regex.c) path="$regex_c" ;;
          std/regex/regex_min.inc.c) path="$(dirname "$regex_c")/regex_min.inc.c" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-regex FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测。
std_regex_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_regex_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-regex FAIL: compile $src" >&2
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
    echo "std-regex FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# C 烟测：regex_min_ok.c + regex.o。
std_regex_run_c_smoke() {
  local regex_c="$1"
  local src="tests/regex/regex_min_ok.c"
  local out="/tmp/shux_regex_min_ok_$$"
  local regex_o
  regex_o="$(dirname "$regex_c")/regex.o"
  if [ ! -f "$regex_o" ]; then
    echo "std-regex FAIL: missing $regex_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$regex_o" 2>/dev/null; then
    echo "std-regex FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-regex FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出门禁报告行。
std_regex_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  local host="$5"
  echo "${STD_REGEX_PREFIX} status=${status} c_smoke=${c_ok} su=${su_ok} skip=${skip} host=${host}"
}
