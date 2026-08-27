#!/usr/bin/env bash
# boot-017-stdlib-dogfood.sh — BOOT-017 helpers for std/core per-module check timing.
#
# Honesty (2026-08-27): soft FAIL_ON_REGRESSION / prefer-xlang-c retired in
# runner+gate. Prefer product asm via callers; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology.
#
# Usage (source):
#   boot017_resolve_shu
#   boot017_list_modules MATRIX_TSV
#   boot017_emit_report status modules slow p50 p95 skip [run] [obs]

BOOT017_PREFIX="${XLANG_BOOT017_PREFIX:-xlang: [XLANG_BOOT017_STDLIB_DOGFOOD]}"

# Return 0 if path is a native executable for this host.
boot017_native_xlang() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

# Resolve check/timing compiler. Prefer product asm (honesty).
boot017_resolve_shu() {
  local cand
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    if boot017_native_xlang "$cand"; then
      echo "$cand"
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
