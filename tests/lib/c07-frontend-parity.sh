#!/usr/bin/env bash
# C-07 frontend parity helpers: xlang-c (C frontend REF) vs xlang/xlang_asm
# (.x frontend CAND) same-input compare.
#
# Honesty: native exe check converges on dod_native_exe (single authority;
# c07_native_xlang retired as duplicate). Prefer CAND = xlang_asm → xlang.
# Usage: source tests/lib/c07-frontend-parity.sh
# PLATFORM: SHARED archaeology.

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "${BASH_SOURCE[0]:-$0}")/ci-host.sh"
# shellcheck source=tests/lib/dod-native-exe.sh
. "$(dirname "${BASH_SOURCE[0]:-$0}")/dod-native-exe.sh"

# Resolve REF/CAND compiler paths; CAND prefers xlang_asm → xlang.
# Sets C07_REF / C07_CAND. Missing/non-native REF → 1; missing CAND → 2.
# Explicit C07_REF / C07_CAND env overrides are fail-fast (no soft fallback).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
c07_resolve_compilers() {
  local root cand abs
  root=$(pwd)
  if [ -n "${C07_REF:-}" ]; then
    case "$C07_REF" in
      /*) abs="$C07_REF" ;;
      *) abs="$root/$C07_REF" ;;
    esac
    if ! dod_native_exe "$abs"; then
      return 1
    fi
    C07_REF="$abs"
  else
    C07_REF="${root}/compiler/xlang-c"
    if ! dod_native_exe "$C07_REF"; then
      return 1
    fi
  fi

  if [ -n "${C07_CAND:-}" ]; then
    case "$C07_CAND" in
      /*) abs="$C07_CAND" ;;
      *) abs="$root/$C07_CAND" ;;
    esac
    if ! dod_native_exe "$abs"; then
      return 2
    fi
    C07_CAND="$abs"
  else
    C07_CAND=""
    # Prefer product asm; refuse soft auto-make / prefer-c.
    for cand in compiler/xlang_asm compiler/xlang; do
      abs="$root/$cand"
      if dod_native_exe "$abs"; then
        C07_CAND="$abs"
        break
      fi
    done
    if [ -z "${C07_CAND}" ]; then
      return 2
    fi
  fi
  return 0
}

# typeck-only compile (no -o): CAND adds -backend c to align with xlang-c path.
# Args: $1=compiler $2=src $3=logfile; returns compiler exit code.
c07_typeck_x() {
  local bin="$1" src="$2" log="$3"
  local args=(-L .)
  if [ "${bin##*/}" != "xlang-c" ]; then
    args+=(-backend c)
  fi
  "$bin" "${args[@]}" "$src" >"$log" 2>&1
}

# Compile+link -o (optional run parity; needs full link env e.g. liburing).
# Args: $1=compiler $2=src $3=out-exe $4=logfile; returns compiler exit code.
c07_compile_x() {
  local bin="$1" src="$2" out="$3" log="$4"
  local args=(-L .)
  if [ "${bin##*/}" != "xlang-c" ]; then
    args+=(-backend c)
  fi
  rm -f "$out" 2>/dev/null || true
  "$bin" "${args[@]}" "$src" -o "$out" >"$log" 2>&1
}

# Run executable and echo process exit code (0..255).
# Args: $1=executable path.
c07_run_exit() {
  local exe="$1"
  local rc=0
  "$exe" >/dev/null 2>&1 || rc=$?
  echo "$rc"
}

# Log contains typeck OK (common success path for xlang-c / xlang).
# Args: $1=logfile.
c07_log_typeck_ok() {
  grep -q 'typeck OK' "$1" 2>/dev/null
}

# Log contains typeck error (negative-path cases).
# Args: $1=logfile.
c07_log_typeck_error() {
  grep -q 'typeck error' "$1" 2>/dev/null
}
