#!/usr/bin/env bash
# std-math-special.sh — STD-115 manifest 与烟测辅助

STD_MATH_SPECIAL_PREFIX="${SHUX_STD115_MATH_SPECIAL_PREFIX:-shux: [SHUX_STD115_MATH_SPECIAL]}"

# 校验 manifest 中 api/symbol/file/smoke。
std_math_special_symbols_ok() {
  local mod_sx="$1"
  local math_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-math-special FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/math/math.c|std/math/math_libm_glue.c|compiler/src/asm/runtime_math_libm.c) path="$math_c" ;;
          std/math/math.sx) path="std/math/math.sx" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-math-special FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors)
        if [ ! -f "$anchor" ]; then
          echo "std-math-special FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测。
std_math_special_run_sx_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_math_special_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-math-special FAIL: compile $src" >&2
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

# C 烟测：special_smoke_ok.c + math.o + runtime_math_libm.o + -lm。
std_math_special_run_c_smoke() {
  local math_o="$1"
  local src="tests/std-math/special_smoke_ok.c"
  local out="/tmp/shux_std_math_special_c_$$"
  local rt_o="compiler/runtime_math_libm.o"
  if [ ! -f "$rt_o" ]; then
    make -C compiler -q runtime_math_libm.o 2>/dev/null || make -C compiler runtime_math_libm.o >/dev/null 2>&1 || true
  fi
  if [ ! -f "$rt_o" ]; then
    echo "std-math-special FAIL: missing $rt_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$math_o" "$rt_o" -lm 2>/dev/null; then
    echo "std-math-special FAIL: compile C smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  [ "$ec" -eq 0 ]
}

std_math_special_emit_report() {
  echo "${STD_MATH_SPECIAL_PREFIX} status=$1 c=$2 sx=$3 skip=$4"
}
