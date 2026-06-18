#!/usr/bin/env bash
# std-math-fenv-capability.sh — STD-149 manifest 与烟测辅助

STD149_PREFIX="${SHU_STD149_MATH_FENV_CAP_PREFIX:-shu: [SHU_STD149_MATH_FENV_CAP]}"

# 校验 manifest；echo 缺失数。
std_math_fenv_cap_symbols_ok() {
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
          echo "std-math-fenv-cap FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/math/math.c" ]; then path="$math_c"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-math-fenv-cap FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-math-fenv-cap FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      script)
        if [ ! -f "$anchor" ]; then
          echo "std-math-fenv-cap FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "analysis/std-math-fenv-capability-v1.md" 2>/dev/null; then
          echo "std-math-fenv-cap FAIL: missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 读取当前宿主期望 available 值（0/1）；无匹配 echo -1。
std_math_fenv_cap_expect_available() {
  local tsv="$1"
  local os
  os="$(uname -s 2>/dev/null || echo Unknown)"
  while IFS=$'\t' read -r pat expect _notes; do
    [ -z "${pat:-}" ] && continue
    case "$pat" in \#*) continue ;; esac
    case "$os" in
      Darwin)
        if [ "$pat" = "Darwin" ]; then echo "$expect"; return 0; fi
        ;;
      Linux)
        if [ "$pat" = "Linux" ]; then echo "$expect"; return 0; fi
        ;;
      MINGW*|MSYS*|CYGWIN*)
        if [ "$pat" = "Windows" ]; then echo "$expect"; return 0; fi
        ;;
    esac
  done < "$tsv"
  echo "-1"
  return 1
}

# C 能力烟测；校验 stderr 含 SHU_MATH_FENV_CAP。
std_math_fenv_cap_run_c_smoke() {
  local math_c="$1"
  local expect_avail="$2"
  local src="tests/std-math/fenv_capability_ok.c"
  local out="/tmp/shu_math_fenv_cap_c_$$"
  local err="/tmp/shu_math_fenv_cap_err_$$.log"
  local math_o
  math_o="$(dirname "$math_c")/math.o"
  if [ ! -f "$math_o" ]; then
    echo "std-math-fenv-cap FAIL: missing $math_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$math_o" -lm 2>/dev/null; then
    echo "std-math-fenv-cap FAIL: compile $src" >&2
    return 1
  fi
  set +e
  "$out" 2>"$err"
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "std-math-fenv-cap FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  if ! grep -qF 'shu: [SHU_MATH_FENV_CAP]' "$err" 2>/dev/null; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "std-math-fenv-cap FAIL: missing cap line" >&2
    return 1
  fi
  if [ "$expect_avail" != "-1" ]; then
    if ! grep -qF "available=${expect_avail}" "$err" 2>/dev/null; then
      cat "$err" >&2 || true
      rm -f "$err"
      echo "std-math-fenv-cap FAIL: expected available=${expect_avail}" >&2
      return 1
    fi
  fi
  rm -f "$err"
  return 0
}

# .su 烟测（需 math.o + -lm）。
std_math_fenv_cap_run_su_smoke() {
  local shu="$1"
  local src="$2"
  local exe="/tmp/shu_math_fenv_cap_su_$$"
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-math-fenv-cap FAIL: compile $src" >&2
    "$shu" -L . "$src" -o "$exe" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-math-fenv-cap FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_math_fenv_cap_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  local host="$5"
  echo "${STD149_PREFIX} status=${status} c=${c_ok} su=${su_ok} skip=${skip} host=${host}"
}
