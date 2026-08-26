#!/usr/bin/env bash
# std-tar-extended.sh — STD-152 manifest + smoke helpers
#
# Usage (after source):
#   std_tar_extended_symbols_ok MOD_X TAR_X TSV
#   std_tar_extended_run_c_smoke
#   std_tar_extended_run_x_smoke XLANG_BIN X TAR_O
#   std_tar_extended_emit_report status check_ok c_ok x_ok skip
# 2026-08-26: report check=/c=/x=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_TAR_EXTENDED_PREFIX="${XLANG_STD_TAR_EXTENDED_PREFIX:-xlang: [XLANG_STD_TAR_EXTENDED]}"

# Validate manifest; echo miss count; return 0 iff miss==0.
std_tar_extended_symbols_ok() {
  local mod_x="$1"
  local tar_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-tar-extended FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol|impl_prefix|impl_pax)
        case "$mod_path" in
          std/tar/tar.x) mod_path="$tar_x" ;;
          std/tar/tar_glue.c) mod_path="$tar_x" ;;
          std/tar/mod.x) mod_path="$mod_x" ;;
          *) mod_path="$mod_x" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-tar-extended FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-tar-extended FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script|gate|anchor|hook_script)
        # DOC ## 4. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run C smoke (tar.o + extended_ok.c; ensure tar.o first).
# Observational under honesty gate (hard-green = .x runnable).
std_tar_extended_run_c_smoke() {
  local smoke_c="tests/std-tar/extended_ok.c"
  local exe="/tmp/xlang_std_tar_extended_c_$$"
  if [ ! -f "$smoke_c" ]; then
    echo "std-tar-extended FAIL: missing $smoke_c" >&2
    return 1
  fi
  # shellcheck source=tests/lib/build-std-c-o.sh
  . tests/lib/build-std-c-o.sh
  ensure_std_c_o ../std/tar/tar.o
  local tar_o
  tar_o="$(cd compiler && pwd)/../std/tar/tar.o"
  if ! cc -std=c11 -Wall -Wextra -o "$exe" "$smoke_c" "$tar_o" 2>/dev/null; then
    echo "std-tar-extended FAIL: compile C smoke" >&2
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-tar-extended FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# Compile and run .x smoke (must link tar.o). Hard-green under honesty gate.
std_tar_extended_run_x_smoke() {
  local xlang="$1"
  local src="$2"
  local tar_o="$3"
  local exe="/tmp/xlang_std_tar_extended_x_$$"
  if [ ! -f "$src" ]; then
    echo "std-tar-extended FAIL: missing $src" >&2
    return 1
  fi
  if ! "$xlang" -L . "$src" -o "$exe" "$tar_o" >/dev/null 2>&1; then
    echo "std-tar-extended FAIL: compile $src" >&2
    "$xlang" -L . "$src" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-tar-extended FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: check=/c=/x=/skip=).
# Hard-green signal = x=; check + c observational.
std_tar_extended_emit_report() {
  local status="$1"
  local check_ok="$2"
  local c_ok="$3"
  local x_ok="$4"
  local skip="$5"
  echo "${STD_TAR_EXTENDED_PREFIX} status=${status} check=${check_ok} c=${c_ok} x=${x_ok} skip=${skip}"
}
