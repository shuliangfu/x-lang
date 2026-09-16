#!/usr/bin/env bash
# std-math-fenv.sh — STD-059 manifest helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_math_fenv_symbols_ok MOD_X MATH_RUNTIME_C TSV
#   std_math_fenv_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash.
# Honesty: refuse soft auto-make / soft SKIP→OK; report run=/obs=/skip=.

STD_MATH_FENV_PREFIX="${XLANG_STD_MATH_FENV_PREFIX:-xlang: [XLANG_STD_MATH_FENV]}"

# Validate manifest api/const/symbol/file/smoke/section anchors. Echo miss count.
std_math_fenv_symbols_ok() {
  local mod_x="$1"
  local math_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-math-fenv FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_x" 2>/dev/null; then
          echo "std-math-fenv FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/math/math.c|std/math/math_libm_glue.c|compiler/seeds/runtime_math_libm.from_x.c) path="$math_c" ;;
          std/math/math.x) path="std/math/math.x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-math-fenv FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        # Prefer DOC path from env; refuse fossil top-level analysis/std-math-fenv-v1.md.
        local doc="${XLANG_STD_MATH_FENV_DOC:-analysis/archive/std/std-math-fenv-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-math-fenv FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors|script)
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

# Host-C archaeology smoke: prebuilt runtime_math_libm.o only (refuse soft auto-make).
# Returns 0 on green run, 1 on link/run fail, 2 on missing prebuilt .o.
std_math_fenv_run_c_smoke() {
  local src="tests/std-math/fenv_smoke_ok.c"
  local out="/tmp/xlang_std_math_fenv_$$"
  local rt_o="compiler/runtime_math_libm.o"
  if [ ! -f "$rt_o" ]; then
    echo "std-math-fenv OBS c smoke (missing prebuilt $rt_o; refuse soft auto-make)" >&2
    return 2
  fi
  if ! ${CC:-cc} -std=c11 -O1 -o "$out" "$src" "$rt_o" -lm 2>/tmp/std_math_fenv_c_$$.log; then
    echo "std-math-fenv OBS c smoke link (refuse soft ensure)" >&2
    return 1
  fi
  # Do not toggle set -e here — it would leak and make `return 1` kill the gate.
  "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-math-fenv OBS c smoke run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired c_smoke=/x=).
std_math_fenv_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_MATH_FENV_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
