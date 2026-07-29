#!/usr/bin/env bash
# compiler-make.sh — wave727/728/732 · 11.2.3
#
# Single entry for tests/** → `make -C compiler …` (lib + run-*.sh). Future
# xbuild can replace the body without touching every gate script (G.7 single
# call path). wave732: all tests/run-*.sh use this hub (0 raw make -C outside).
#
# Usage (from repo root or after setting XLANG_REPO_ROOT):
#   . tests/lib/compiler-make.sh
#   xlang_compiler_make -q runtime_panic.o || xlang_compiler_make runtime_panic.o
#   xlang_compiler_make bootstrap-driver-bstrict
#   XLANG_COMPILER_DIR=/path/to/compiler xlang_compiler_make runtime_panic.o
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
# XLANG_COMPILER_DIR overrides the default ${XLANG_REPO_ROOT}/compiler (nolibc
# / out-of-tree smoke may pass an alternate compiler tree).
# Returns make's exit status.
xlang_compiler_make() {
  local _cm_dir="${XLANG_COMPILER_DIR:-${XLANG_REPO_ROOT}/compiler}"
  # Clear recursive MAKEFLAGS noise from agent/nested make (same as catalog).
  MAKEFLAGS= "$XLANG_COMPILER_MAKE" -C "$_cm_dir" "$@"
}
