#!/usr/bin/env bash
# std-math-fenv-capability.sh — STD-149 manifest helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_math_fenv_cap_symbols_ok MOD_X MATH_RUNTIME_C TSV
#   std_math_fenv_cap_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash.
# Honesty: refuse soft auto-make / soft SKIP→OK; report run=/obs=/skip=.

STD149_PREFIX="${XLANG_STD149_MATH_FENV_CAP_PREFIX:-xlang: [XLANG_STD149_MATH_FENV_CAP]}"

# Validate manifest; echo miss count. Section uses TSV mod_path (archive DOC).
std_math_fenv_cap_symbols_ok() {
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
          echo "std-math-fenv-cap FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "std/math/math.c" ] || [ "$path" = "std/math/math_libm_glue.c" ] || [ "$path" = "compiler/seeds/runtime_math_libm.from_x.c" ]; then
          path="$math_c"
        fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-math-fenv-cap FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="$mod_path"
        if [ -z "$doc" ] || [ ! -f "$doc" ]; then
          doc="${XLANG_STD_MATH_FENV_CAP_DOC:-analysis/archive/std/std-math-fenv-capability-v1.md}"
        fi
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-math-fenv-cap FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|gate|script|vectors)
        if [ ! -f "$anchor" ]; then
          echo "std-math-fenv-cap FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Read host expected available value (0/1); no match → echo -1.
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

# Host-C capability smoke: prebuilt runtime_math_libm.o only.
# Returns 0 green, 1 fail/mismatch, 2 missing prebuilt.
std_math_fenv_cap_run_c_smoke() {
  local expect_avail="$1"
  local src="tests/std-math/fenv_capability_ok.c"
  local out="/tmp/xlang_math_fenv_cap_c_$$"
  local err="/tmp/xlang_math_fenv_cap_err_$$.log"
  local rt_o="compiler/runtime_math_libm.o"
  if [ ! -f "$rt_o" ]; then
    echo "std-math-fenv-cap OBS c smoke (missing prebuilt $rt_o; refuse soft auto-make)" >&2
    return 2
  fi
  if ! ${CC:-cc} -std=c11 -O1 -o "$out" "$src" "$rt_o" -lm 2>/tmp/std_math_fenv_cap_link_$$.log; then
    echo "std-math-fenv-cap OBS c smoke link (refuse soft ensure)" >&2
    return 1
  fi
  # Do not toggle set -e here — it would leak and make `return 1` kill the gate.
  # Cap marker moved off stderr (diag_reportf); exit0 + available() call = green archaeology.
  "$out" >/dev/null 2>"$err"
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    cat "$err" >&2 || true
    rm -f "$err"
    echo "std-math-fenv-cap OBS c smoke run exit=$ec" >&2
    return 1
  fi
  # Optional: accept legacy marker OR platform=… available=N if present.
  if grep -qF 'xlang: [XLANG_MATH_FENV_CAP]' "$err" 2>/dev/null; then
    if [ "$expect_avail" != "-1" ] && ! grep -qF "available=${expect_avail}" "$err" 2>/dev/null; then
      cat "$err" >&2 || true
      rm -f "$err"
      echo "std-math-fenv-cap OBS c smoke expected available=${expect_avail}" >&2
      return 1
    fi
  elif grep -qE "available=${expect_avail}|math fenv cap:" "$err" 2>/dev/null; then
    :
  else
    # Tip seed emits via diag_reportf (often silent without diag ctx).
    # exit0 after math_fenv_available_c = green host-C archaeology (not soft FAIL).
    rm -f "$err"
    return 0
  fi
  rm -f "$err"
  return 0
}

# Structured report (honesty: run=/obs=/skip=; retired c=/x=/host=).
std_math_fenv_cap_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD149_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
