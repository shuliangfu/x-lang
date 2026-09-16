#!/usr/bin/env bash
# boot-017-stdlib-dogfood.sh — BOOT-017 helpers for std/core per-module check timing.
#
# Honesty (2026-08-27): soft FAIL_ON_REGRESSION / prefer-xlang-c retired.
# Honesty (2026-08-29): residual XLANG fallthrough retired — explicit-bad
# XLANG no longer continues to xlang_asm. Prefer product asm; pin
# XLANG_LINK_XLANG via callers. Report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).
#
# Usage (source):
#   boot017_resolve_shu
#   boot017_list_modules MATRIX_TSV
#   boot017_emit_report status modules slow p50 p95 skip [run] [obs]

BOOT017_PREFIX="${XLANG_BOOT017_PREFIX:-xlang: [XLANG_BOOT017_STDLIB_DOGFOOD]}"

# shellcheck source=tests/lib/dod-native-exe.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/dod-native-exe.sh"

# G.7: native exe check converges on dod_native_exe (single authority).
boot017_native_xlang() {
  dod_native_exe "$1"
}

# Prefer product asm; refuse prefer-c / soft auto-make / XLANG fallthrough.
# Explicit XLANG that is missing or non-native returns 1 (caller hard-dies).
# Do not restore set -e before return 1.
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
boot017_resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

# List module rows from BOOT-013 matrix (module_id\tlayer).
boot017_list_modules() {
  local tsv="$1"
  while IFS=$'\t' read -r item_id kind anchor layer _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*|read_path|matrix|report|lib|runner|gate) continue ;; esac
    [ "$kind" = "module" ] || continue
    printf '%s\t%s\n' "$anchor" "$layer"
  done < "$tsv"
}

# Emit structured report line (gate greps PREFIX).
boot017_emit_report() {
  local status="$1"
  local modules="$2"
  local slow="$3"
  local p50="$4"
  local p95="$5"
  local skip="$6"
  local run="${7:-0}"
  local obs="${8:-0}"
  echo "${BOOT017_PREFIX} status=${status} run=${run} obs=${obs} skip=${skip} modules=${modules} slow=${slow} p50=${p50} p95=${p95}"
}
