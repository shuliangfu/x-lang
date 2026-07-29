#!/usr/bin/env bash
# compiler_all_ci.sh — R5 CI / compiler-all shell body (wave784 · B6)
#
# Authority (G.7):
#   Owns the *policy and sequence* of historical
#   `make -C compiler OPT=1 all` (host-cc `xlang` + `xlang-c` / seed path).
#   Distinct from product `./xbuild all` (g05 relink via build_tool).
#
#   Residual after this wave (honest):
#     - Leaf .o builds and host-cc link still use the Makefile graph (B7)
#     - Physical delete of compiler/Makefile still blocked (Windows gate + B7)
#   This wave is NOT physical delete and does NOT re-list .o paths.
#
# Entry points (single body):
#   ./xbuild compiler-all | ci-all   → this script (OPT default 1)
#   make -C compiler [OPT=1] all     → thin-call this script
#   bash compiler/scripts/compiler_all_ci.sh [--check]
#
# Env:
#   OPT — when unset, defaults to 1 (historical CI). Empty OPT= (from bare
#         `make all`) stays empty so Makefile does not force -O2.
#   MAKE — make binary (default: make)
#   TARGET — product host-cc binary name (default: xlang)
#   XLANG_C — C frontend name (default: xlang-c)
#   XLANG_RUN_ALL_BOOTSTRAP_XLANG=1 — alternate: bootstrap-driver-seed only
#         (run-all seed path; do not overwrite with C-only all)
#   XLANG_SKIP_SUBSCRIPT_MAKE — forwarded to make for xlang-c preserve rules
#
# PLATFORM: SHARED — orchestration identical; leaf recipes keep platform ABI.
# Wave: 784 B6 R5 body swallow (Makefile thin-call only).

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
COMPILER_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
cd "$COMPILER_DIR"

MODE="run"
if [ "${1:-}" = "--check" ] || [ "${1:-}" = "check" ]; then
  MODE="check"
fi

note() { echo "compiler_all_ci: $*" >&2; }
bad() { echo "compiler_all_ci: FAIL: $*" >&2; fail=1; }

if [ "$MODE" = "check" ]; then
  fail=0
  ROOT="$(CDPATH= cd -- "$COMPILER_DIR/.." && pwd)"
  XBUILD="$ROOT/xlang-build.sh"
  MF="$COMPILER_DIR/Makefile"

  if [ ! -f "$XBUILD" ]; then
    bad "missing xlang-build.sh"
  else
    # Outer entry must call this script (not bare run_compiler_make OPT=1 all only).
    if ! grep -q 'compiler_all_ci\.sh' "$XBUILD"; then
      bad "xlang-build.sh must wire compiler-all → compiler_all_ci.sh (wave784)"
    else
      note "xbuild compiler-all wires compiler_all_ci.sh"
    fi
    if grep -nE 'compiler-all\|ci-all\)' -A6 "$XBUILD" 2>/dev/null \
      | grep -q 'run_compiler_make.*OPT=.*all' \
      && ! grep -nE 'compiler-all\|ci-all\)' -A8 "$XBUILD" 2>/dev/null \
        | grep -q 'compiler_all_ci\.sh'; then
      bad "xbuild compiler-all still bare run_compiler_make OPT all without shell body"
    fi
  fi

  if [ ! -f "$MF" ]; then
    bad "missing Makefile (unexpected early delete; 11.3.1 not closed)"
  else
    # all: must thin-call this script (not make-deps graph only).
    if ! awk '
      /^all:/ { in_all=1; body=""; next }
      in_all && /^[^[:space:]#]/ { exit (body ~ /compiler_all_ci\.sh/) ? 0 : 1 }
      in_all { body = body $0 "\n" }
      END { exit (body ~ /compiler_all_ci\.sh/) ? 0 : 1 }
    ' "$MF"; then
      bad "Makefile all must thin-call scripts/compiler_all_ci.sh (wave784)"
    else
      note "Makefile all thin-calls compiler_all_ci.sh"
    fi
    # Must not keep old dependency-style all: TARGET XLANG_C as the only body.
    if grep -E '^all:.*\$\(TARGET\)|all:.*bootstrap-driver-seed' "$MF" \
      | grep -vq 'compiler_all_ci'; then
      # dependency-only all: lines are residual if still present without recipe body
      if grep -qE '^all:[[:space:]]*(\$\(TARGET\)|bootstrap-driver-seed)' "$MF"; then
        bad "Makefile still has dependency-only all: graph (must be thin shell wave784)"
      fi
    fi
  fi

  # Policy markers present in this body (absolute path: we already cd'ed to compiler/)
  _self="$SCRIPT_DIR/compiler_all_ci.sh"
  if ! grep -q 'XLANG_RUN_ALL_BOOTSTRAP_XLANG' "$_self"; then
    bad "body must honor XLANG_RUN_ALL_BOOTSTRAP_XLANG alternate path"
  fi
  if ! grep -qE 'OPT|TARGET|XLANG_C' "$_self"; then
    bad "body must name OPT/TARGET/XLANG_C policy"
  fi
  unset _self

  if [ "$fail" -ne 0 ]; then
    echo "compiler_all_ci: CHECK FAILED" >&2
    exit 1
  fi
  echo "compiler_all_ci: CHECK OK (wave784 B6 R5 shell body)"
  exit 0
fi

# --- run mode ---
# OPT: unset → default 1 (CI). Empty string preserved (bare make all).
if [ -z "${OPT+set}" ]; then
  OPT=1
fi
MAKE="${MAKE:-make}"
TARGET="${TARGET:-xlang}"
XLANG_C="${XLANG_C:-xlang-c}"

export MAKE TARGET XLANG_C
# Forward optional flags make recipes still consume.
if [ -n "${XLANG_SKIP_SUBSCRIPT_MAKE+set}" ]; then
  export XLANG_SKIP_SUBSCRIPT_MAKE
fi
if [ -n "${XLANG_RUN_ALL_BOOTSTRAP_XLANG+set}" ]; then
  export XLANG_RUN_ALL_BOOTSTRAP_XLANG
fi

mk() {
  # shellcheck disable=SC2086
  "$MAKE" "$@"
}

if [ "${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-}" = "1" ]; then
  # Alternate CI / run-all seed path: full cold bootstrap only.
  # PLATFORM: SHARED — same policy as pre-wave784 Makefile all branch.
  note "XLANG_RUN_ALL_BOOTSTRAP_XLANG=1 → bootstrap-driver-seed"
  mk bootstrap-driver-seed
else
  # Default CI host-cc path: produce xlang + xlang-c with OPT (historical OPT=1).
  # Leaf .o + link recipes remain Makefile residual (B7).
  note "host-cc CI → OPT=${OPT:-} $TARGET $XLANG_C (B7 leaf graph still make)"
  # Pass OPT on the make command line so Makefile ifeq ($(OPT),1) CFLAGS+=-O2 applies.
  if [ -n "${OPT}" ]; then
    mk OPT="$OPT" "$TARGET" "$XLANG_C"
  else
    mk "$TARGET" "$XLANG_C"
  fi
fi

note "done (xlang host-cc CI path; not product g05)"
