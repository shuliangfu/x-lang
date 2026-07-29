#!/usr/bin/env bash
# compiler-make.sh — wave727 · 11.2.3 start
#
# Single entry for tests/lib → `make -C compiler …`. Future xbuild can replace
# the body without touching every gate script (G.7 single call path).
#
# Usage (from repo root or after setting XLANG_REPO_ROOT):
#   . tests/lib/compiler-make.sh
#   xlang_compiler_make -q runtime_panic.o || xlang_compiler_make runtime_panic.o
#   xlang_compiler_make bootstrap-driver-bstrict
#
# PLATFORM: SHARED — thin make wrapper; no compile logic of its own.

# Resolve repo root once: prefer caller ROOT, else walk from this file.
if [ -z "${XLANG_REPO_ROOT:-}" ]; then
  _cm_here="$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
  XLANG_REPO_ROOT="$(CDPATH= cd -- "$_cm_here/../.." && pwd)"
  unset _cm_here
fi

# Make binary (override for gmake on some hosts).
XLANG_COMPILER_MAKE="${XLANG_COMPILER_MAKE:-make}"

# Run make in compiler/ with remaining args. cwd stays caller's cwd.
# Returns make's exit status.
xlang_compiler_make() {
  # Clear recursive MAKEFLAGS noise from agent/nested make (same as catalog).
  MAKEFLAGS= "$XLANG_COMPILER_MAKE" -C "${XLANG_REPO_ROOT}/compiler" "$@"
}
