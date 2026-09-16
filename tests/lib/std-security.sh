#!/usr/bin/env bash
# std-security.sh — STD-079 std.security helpers (honesty prefer-asm).
#
# Usage (after source):
#   std_security_symbols_ok MOD_X SEC_X TSV [DOC]
#   std_security_host_c_obs SMOKE_C
#   std_security_run_smoke XLANG SRC [TAG]
#   std_security_emit_report status run obs skip
# Honesty: refuse soft auto-make / soft SKIP→OK / soft ensure; report run=/obs=/skip=.
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_SECURITY_PREFIX="${XLANG_STD_SECURITY_PREFIX:-xlang: [XLANG_STD_SECURITY]}"

# Validate manifest api/symbol/file/smoke/script/section/vectors anchors.
# Echo miss count; return 0 when miss=0.
# Optional DOC overrides archive path for section checks (default archived RFC).
std_security_symbols_ok() {
  local mod_x="$1"
  local sec_x="$2"
  local tsv="$3"
  local doc="${4:-analysis/archive/std/std-security-v1.md}"
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
      script|gate)
        if [ -n "$anchor" ] && [ -f "$anchor" ]; then
          :
        elif [ -n "$mod_path" ] && [ -f "$mod_path" ]; then
          :
        else
          echo "std-security FAIL: missing script '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if [ ! -f "$doc" ] || ! grep -qF "$anchor" "$doc" 2>/dev/null; then
          echo "std-security FAIL: missing section '$anchor' in $doc" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Host-C archaeology: prebuilt security.o + crypto.o only.
# Refuse soft xlang_compiler_make / soft ensure_std_c_o.
# C harness tests/std-security/security_smoke_ok.c calls security_smoke_c.
# Do not invent a second crypto ABI; do not rebuild missing objects;
# do not expand companions (random / argv / hmac-sha256 seeds) to fake a C pass.
# Returns 0 C smoke linked+ran on existing objects, 1 link/run fail, 2 missing prebuilt.
# PLATFORM: SHARED — do not toggle set -e (leaks make return 1 kill the gate).
std_security_host_c_obs() {
  local smoke_c="${1:-tests/std-security/security_smoke_ok.c}"
  local sec_o="std/security/security.o"
  local crypto_o="std/crypto/crypto.o"
  local o
  for o in "$sec_o" "$crypto_o"; do
    if [ ! -f "$o" ]; then
      echo "std-security OBS host-C (missing prebuilt $o; refuse soft auto-make)" >&2
      return 2
    fi
  done
  if [ ! -f "$smoke_c" ]; then
    echo "std-security OBS host-C (missing $smoke_c)" >&2
    return 2
  fi
  local out="/tmp/xlang_security_smoke_$$"
  local log="/tmp/xlang_security_smoke_link_$$.err"
  if ! cc -std=c11 -O1 -o "$out" "$smoke_c" "$sec_o" "$crypto_o" 2>"$log"; then
    echo "std-security OBS host-C link (existing .o only; refuse soft auto-make)" >&2
    tail -n 10 "$log" 2>/dev/null || true
    rm -f "$out" "$log"
    return 1
  fi
  # Do not restore set -e here: return 1 must not trip the gate's set +e window.
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  rm -f "$out" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-security OBS host-C run exit=$ec" >&2
    return 1
  fi
  return 0
}

# Product -o smoke. Return 0 exit0, 1 compile/run fail.
# Do not restore set -e before return 1.
std_security_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-security}"
  local exe="/tmp/xlang_std_security_${tag}_$$"
  local log="/tmp/xlang_std_security_${tag}_build_$$.log"
  if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
    echo "std-security FAIL: compile $src" >&2
    tail -n 12 "$log" >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  rm -f "$exe" "$log"
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
