#!/usr/bin/env bash
# Prefer-asm product -E-extern refuse helper (single authority).
#
# Product binaries ship with -DXLANG_NO_C_FRONTEND; -E-extern must refuse
# with BLD001 / NO_C_FRONTEND. Soft die→exit0 + swallowing FAIL_XLANGC while
# every product bin refuses the flag = prefer-c archaeology false-green.
#
# Usage (from repo root after sourcing dod-native-exe.sh):
#   source tests/lib/prefer-asm-e-extern-refuse.sh
#   bin="$(prefer_asm_resolve_xlang)" || die "no native xlang"
#   prefer_asm_assert_e_extern_refuse "$bin" "std/cli/mod.x" || die "…"
#
# PLATFORM: SHARED archaeology.
# shellcheck shell=bash

prefer_asm_resolve_xlang() {
  local cand abs
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$(pwd)/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

# Assert product refuses -E-extern with NO_C_FRONTEND / BLD001 marker.
# @param $1 absolute native XLANG binary
# @param $2 probe .x path relative to repo root (file must exist)
# @return 0 on honest refuse; 1 on accept or refuse without marker
prefer_asm_assert_e_extern_refuse() {
  local bin="$1"
  local probe="$2"
  local log gen rc
  [ -n "$bin" ] && [ -x "$bin" ] || return 1
  [ -n "$probe" ] && [ -f "$probe" ] || return 1
  log="/tmp/xlang_e_extern_refuse.$$.log"
  gen="/tmp/xlang_e_extern_refuse.$$.c"
  rm -f "$log" "$gen"
  set +e
  "$bin" build -E-extern -L . "$probe" >"$gen" 2>"$log"
  rc=$?
  set -e
  if [ "$rc" -eq 0 ]; then
    rm -f "$log" "$gen"
    echo "prefer-asm-e-extern-refuse: product $bin accepted -E-extern (NO_C_FRONTEND expected refuse)" >&2
    return 1
  fi
  if ! grep -qE 'NO_C_FRONTEND|-E-extern requires C parser/codegen|BLD001' "$log"; then
    echo "prefer-asm-e-extern-refuse: refuse without NO_C_FRONTEND/BLD001 marker:" >&2
    tail -n 20 "$log" >&2 || true
    rm -f "$log" "$gen"
    return 1
  fi
  rm -f "$log" "$gen"
  return 0
}
