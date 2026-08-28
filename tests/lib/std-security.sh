#!/usr/bin/env bash
# std-security.sh — STD-079 manifest helpers (F-security v1 + F-ZC: pure security.x).
#
# Usage (after source):
#   std_security_symbols_ok MOD_X SEC_X TSV
#   std_security_run_c_smoke SEC_X
#   std_security_run_smoke XLANG SRC [TAG]
#   std_security_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

# shellcheck source=compiler-make.sh
. "$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/compiler-make.sh"
STD_SECURITY_PREFIX="${XLANG_STD_SECURITY_PREFIX:-xlang: [XLANG_STD_SECURITY]}"

# Validate manifest api/symbol/file/smoke/vectors anchors.
# Echo miss count; return 0 when miss=0.
std_security_symbols_ok() {
  local mod_x="$1"
  local sec_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-security FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        case "$path" in
          std/security/security.c|std/security/security.x|std/security/security_os_glue.c) path="$sec_x" ;;
        esac
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-security FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors)
        if [ ! -f "$anchor" ]; then
          echo "std-security FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology smoke (observational only; not hard green).
# Prefer callers rebuild security.o best-effort; refuse soft SKIP→OK on fail.
std_security_run_c_smoke() {
  local sec_x="$1"
  local src="tests/std-security/security_smoke_ok.c"
  local out="/tmp/xlang_std_security_$$"
  local sec_o crypto_o
  sec_o="$(dirname "$sec_x")/security.o"
  crypto_o="std/crypto/crypto.o"
  if [ ! -f "$sec_o" ]; then
    echo "std-security OBS c smoke: missing $sec_o" >&2
    return 1
  fi
  if [ ! -f "$crypto_o" ]; then
    xlang_compiler_make ../std/crypto/crypto.o >/dev/null 2>&1 || true
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$sec_o" "$crypto_o" 2>/dev/null; then
    echo "std-security OBS c smoke: link failed" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-security OBS c smoke: exit=$ec" >&2
    return 1
  fi
  return 0
}

# Compile and run .x round-trip smoke; exit 0 required.
# Prefer callers pin XLANG_LINK_XLANG to product asm before invoke.
std_security_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-security}"
  local exe="/tmp/xlang_std_security_${tag}_$$"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-security FAIL: compile $src" >&2
    "$xlang" -L . "$src" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-security FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=; check residual = obs).
std_security_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_SECURITY_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
