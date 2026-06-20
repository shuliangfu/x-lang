#!/usr/bin/env bash
# std-math-fenv.sh — STD-059 manifest 与烟测辅助

STD_MATH_FENV_PREFIX="${SHUX_STD_MATH_FENV_PREFIX:-shux: [SHUX_STD_MATH_FENV]}"

# 遍历 manifest TSV，校验 api/const/symbol/file/smoke。
std_math_fenv_symbols_ok() {
  local mod_su="$1"
  local math_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-math-fenv FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_su" 2>/dev/null; then
          echo "std-math-fenv FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/math/math.c" ]; then path="$math_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-math-fenv FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-math-fenv FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# C 烟测：fenv_smoke_ok.c + math.o + -lm。
std_math_fenv_run_c_smoke() {
  local math_c="$1"
  local src="tests/std-math/fenv_smoke_ok.c"
  local out="/tmp/shux_std_math_fenv_$$"
  local math_o
  math_o="$(dirname "$math_c")/math.o"
  if [ ! -f "$math_o" ]; then
    echo "std-math-fenv FAIL: missing $math_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$math_o" -lm 2>/dev/null; then
    echo "std-math-fenv FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-math-fenv FAIL: c smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# .sx 烟测。
std_math_fenv_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-fenv}"
  local exe="/tmp/shux_std_math_fenv_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-math-fenv FAIL: compile $src" >&2
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
    echo "std-math-fenv FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出门禁报告。
std_math_fenv_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_MATH_FENV_PREFIX} status=${status} c_smoke=${c_ok} su=${su_ok} skip=${skip}"
}
