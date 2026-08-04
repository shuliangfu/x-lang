#!/usr/bin/env bash
# bootstrap_driver_crt0.sh — M4 B-partial crt0 link path (bootstrap-driver-crt0)
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile phony bootstrap-driver-crt0.
#   Historic dual body lived inline in Makefile (build_xlang_asm + log gates).
#
#   What this owns:
#     1) Invoke build_xlang_asm.sh with XLANG=./$TARGET (no SKIP_GEN; crt0 track)
#     2) Gate log for B-partial / LINK_MODE=crt0 / no C runtime driver
#     3) Reject cc -c pipeline_gen.c on this path (M4 partial honesty)
#     4) Require xlang_asm after build; print OK line for make consumers
#
#   Why shell-primary (not physical delete)?
#     bootstrap-driver-seed prereq + leaf .o graph still make residual; this is
#     only the crt0 product orchestration + acceptance gates body.
#
# Usage (cwd = compiler/):
#   bash scripts/bootstrap_driver_crt0.sh
#   bash scripts/bootstrap_driver_crt0.sh --check
#
# Env:
#   TARGET          — product binary name (default: xlang); must already exist
#                     (Makefile keeps bootstrap-driver-seed prereq)
#   XLANG_CRT0_LOG  — log path (default: /tmp/build_xlang_crt0.log)
#
# wave869 (G.7 有则补全): Makefile fat body → this script (thin-call only).
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — orchestration + log gates only; ABI stays in build_xlang_asm.

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
TARGET="${TARGET:-xlang}"
LOG="${XLANG_CRT0_LOG:-/tmp/build_xlang_crt0.log}"

log() { echo "bootstrap-driver-crt0: $*" >&2; }
fail() { echo "bootstrap-driver-crt0: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product build; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  _rec=$(awk '
    /^bootstrap-driver-crt0:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'bootstrap_driver_crt0\.sh' <<<"$_rec"; then
    fail "bootstrap-driver-crt0 must thin-call bootstrap_driver_crt0.sh (wave869)"
  fi
  # Dual body: inline build_xlang_asm + tee/grep gates
  if grep -qE 'build_xlang_asm\.sh' <<<"$_rec"; then
    fail "bootstrap-driver-crt0 must not keep dual build_xlang_asm.sh body (wave869)"
  fi
  if grep -qE 'build_xlang_crt0\.log|Target-B-partial|LINK_MODE=crt0|pipeline_gen\.c' <<<"$_rec"; then
    fail "bootstrap-driver-crt0 must not keep dual crt0 log gates (wave869; shell owns gates)"
  fi
  echo "bootstrap_driver_crt0: --check OK (wave869; shell-primary; not physical delete)"
  exit 0
fi

if [ "$MODE" != "run" ] && [ -n "$MODE" ] && [ "$MODE" != "--run" ]; then
  echo "usage: $0 [--check]" >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Product path (M4 B-partial crt0)
# ---------------------------------------------------------------------------
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

if [ ! -x "./$TARGET" ]; then
  fail "missing executable ./$TARGET (run make bootstrap-driver-seed first)"
fi

# Historic: full build_xlang_asm (no XLANG_ASM_EXPERIMENTAL_SKIP_GEN).
# crt0 track is B-partial — distinct from bootstrap-driver-bstrict (asm_only_strict).
XLANG="./$TARGET" ./scripts/build_xlang_asm.sh 2>&1 | tee "$LOG"

if ! grep -qE 'Target-B-partial|LINK_MODE=crt0|no C runtime driver' "$LOG"; then
  fail "expected crt0 link in log ($LOG)"
fi
if grep -q 'cc -c pipeline_gen.c' "$LOG"; then
  fail "crt0 path must not cc -c pipeline_gen.c"
fi
if [ ! -f xlang_asm ]; then
  fail "xlang_asm missing after crt0 build"
fi

echo "bootstrap-driver-crt0 OK (xlang_asm via crt0 + build_asm/*.o)"
