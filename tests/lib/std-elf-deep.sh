#!/usr/bin/env bash
# std-elf-deep.sh — STD-063 manifest helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_elf_deep_symbols_ok MOD_X ELF_X TSV
#   std_elf_deep_run_c_smoke   # prebuilt std/elf/elf.o only
#   std_elf_deep_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash.
# Honesty: refuse soft auto-make / soft SKIP→OK; report run=/obs=/skip=.

STD_ELF_DEEP_PREFIX="${XLANG_STD063_PREFIX:-xlang: [XLANG_STD063_ELF_DEEP]}"

# Validate deepen manifest api/const/symbol/file/smoke/section/script anchors.
std_elf_deep_symbols_ok() {
  local mod_x="$1"
  local elf_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-elf-deep FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      const)
        if ! grep -qE "const ${anchor}:" "$mod_x" 2>/dev/null; then
          echo "std-elf-deep FAIL: missing const '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/elf/elf.x|std/elf/elf_glue.c) path="$elf_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-elf-deep FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        local doc="${XLANG_STD063_DOC:-analysis/archive/std/std-elf-deep-v1.md}"
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-elf-deep FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|fixture|vectors|script|cross_ref)
        if [ ! -f "$anchor" ]; then
          echo "std-elf-deep FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology smoke: prebuilt std/elf/elf.o only (refuse soft auto-make).
# Returns 0 on green run, 1 on link/run fail, 2 on missing prebuilt .o.
std_elf_deep_run_c_smoke() {
  local src="tests/std-elf/parse_sections_smoke_ok.c"
  local out="/tmp/xlang_std_elf_deep_c_$$"
  local elf_o="std/elf/elf.o"
  if [ ! -f "$elf_o" ]; then
    echo "std-elf-deep OBS c smoke (missing prebuilt $elf_o; refuse soft auto-make)" >&2
    return 2
  fi
  if ! ${CC:-cc} -std=c11 -O1 -o "$out" "$src" "$elf_o" 2>/tmp/std_elf_deep_c_$$.log; then
    echo "std-elf-deep OBS c smoke link (refuse soft ensure)" >&2
    return 1
  fi
  # Do not toggle set -e here — it would leak and make `return 1` kill the gate.
  "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-elf-deep OBS c smoke run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; retired deep_c=/deep_x=).
std_elf_deep_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_ELF_DEEP_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
