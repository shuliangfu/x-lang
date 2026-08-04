#!/usr/bin/env bash
# resolve_host_cc.sh — single authority for default host C compiler name
#
# G.7: scripts must not each invent CC defaults. Source this file (or run it)
# so CC is set when unset.
#
# Policy:
#   1) Honor existing CC from the environment / caller.
#   2) Prefer `cc` when present (POSIX / macOS / Linux toolchains).
#   3) Else `gcc` when present (typical MinGW-w64 on Windows — no `cc` alias).
#   4) Else leave CC=cc so the failure is "cc: not found" at compile time.
#
# Usage:
#   # shell (from compiler/scripts or any dir):
#   # shellcheck source=scripts/resolve_host_cc.sh
#   . "$(dirname "$0")/resolve_host_cc.sh"
#   # then use $CC
#
#   # print only:
#   bash scripts/resolve_host_cc.sh --print
#
# PLATFORM: SHARED — Windows/MinGW commonly has gcc.exe only; do not require
# a binary literally named `cc` for seed / host-cc paths.
#
# Wave: Windows hybrid min-gate residual (no endless hang on missing cc).

set -euo pipefail

xlang_resolve_host_cc() {
  if [ -n "${CC:-}" ]; then
    printf '%s\n' "$CC"
    return 0
  fi
  if command -v cc >/dev/null 2>&1; then
    printf '%s\n' "cc"
    return 0
  fi
  if command -v gcc >/dev/null 2>&1; then
    printf '%s\n' "gcc"
    return 0
  fi
  printf '%s\n' "cc"
}

# When sourced: export CC if unset.
if [ "${1:-}" = "--print" ]; then
  xlang_resolve_host_cc
  exit 0
fi

# Sourced path (or executed without --print): set CC in current shell.
if [ -z "${CC:-}" ]; then
  CC="$(xlang_resolve_host_cc)"
  export CC
fi
