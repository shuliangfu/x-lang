#!/usr/bin/env bash
# bootstrap_driver_hybrid.sh — B-hybrid asm build path (bootstrap-driver-hybrid / -asm)
#
# Authority (G.7 有则补全 / 无才新增):
#   Single implementation for Makefile phony bootstrap-driver-hybrid
#   (alias: bootstrap-driver-asm). Historic dual body lived inline in Makefile:
#     XLANG=./TARGET ./scripts/build_xlang_asm.sh
#     if [ -f xlang_asm ]; then cp -f xlang_asm TARGET; else soft-skip message
#
#   What this owns:
#     1) Require executable TARGET (seed or prior product; Makefile keeps
#        $(TARGET) as prereq so TARGET should exist)
#     2) Invoke build_xlang_asm.sh with XLANG=./$TARGET and NO SKIP_GEN
#        (B-hybrid / B-partial track — distinct from bootstrap-driver-bstrict)
#     3) On success: if xlang_asm exists, replace TARGET (historic OK line)
#     4) Soft-skip path: if xlang_asm missing after build, leave TARGET as seed
#        and print historic skip guidance (does not hard-fail; matches Makefile)
#
#   Why shell-primary (not physical delete)?
#     $(TARGET) prereq + leaf .o graph still make residual; this is only the
#     B-hybrid orchestration + replace/soft-skip body.
#
#   Related but NOT the same as:
#     - bootstrap-driver-bstrict / bootstrap_driver_bstrict.sh (SKIP_GEN strict)
#     - bootstrap-driver-crt0 / bootstrap_driver_crt0.sh (crt0 log gates + hard require)
#     - bootstrap-driver-bstrict-relink (runtime-objs relink only)
#   Do not merge without deliberate redesign of phonies.
#
# Usage (cwd = compiler/):
#   bash scripts/bootstrap_driver_hybrid.sh
#   bash scripts/bootstrap_driver_hybrid.sh --check
#
# Env:
#   TARGET — product binary name (default: xlang); must already exist
#
# wave872 (G.7 有则补全): Makefile fat body → this script (thin-call only).
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — orchestration only; ABI stays in build_xlang_asm.

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"
TARGET="${TARGET:-xlang}"

log() { echo "bootstrap-driver-hybrid: $*" >&2; }
fail() { echo "bootstrap-driver-hybrid: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product build; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  # Combined target: bootstrap-driver-hybrid bootstrap-driver-asm: ...
  _rec=$(awk '
    /^bootstrap-driver-hybrid / { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'bootstrap_driver_hybrid\.sh' <<<"$_rec"; then
    fail "bootstrap-driver-hybrid must thin-call bootstrap_driver_hybrid.sh (wave872)"
  fi
  # Dual body: inline build_xlang_asm + cp/replace + OK/skip messages
  if grep -qE 'build_xlang_asm\.sh' <<<"$_rec"; then
    fail "bootstrap-driver-hybrid must not keep dual build_xlang_asm.sh body (wave872)"
  fi
  if grep -qE 'cp -f xlang_asm|bootstrap-driver-hybrid OK|asm build skipped' <<<"$_rec"; then
    fail "bootstrap-driver-hybrid must not keep dual replace/soft-skip body (wave872; shell owns)"
  fi
  echo "bootstrap_driver_hybrid: --check OK (wave872; shell-primary; not physical delete)"
  exit 0
fi

if [ "$MODE" != "run" ] && [ -n "$MODE" ] && [ "$MODE" != "--run" ]; then
  echo "usage: $0 [--check]" >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Product path (B-hybrid: no SKIP_GEN · replace TARGET if xlang_asm appears)
# ---------------------------------------------------------------------------
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

if [ ! -x "./$TARGET" ]; then
  fail "missing executable ./$TARGET (run bash scripts/bootstrap_driver_seed.sh / ./xbuild bootstrap-driver-seed first)"
fi

# Historic: full build_xlang_asm (no XLANG_ASM_EXPERIMENTAL_SKIP_GEN).
# B-hybrid is distinct from bootstrap-driver-bstrict (asm_only_strict + SKIP_GEN).
XLANG="./$TARGET" ./scripts/build_xlang_asm.sh

if [ -f xlang_asm ]; then
  cp -f xlang_asm "./$TARGET"
  echo "bootstrap-driver-hybrid OK: $TARGET from asm (B-hybrid)"
else
  echo "bootstrap-driver-hybrid: asm build skipped ($TARGET left as seed); run XLANG=./$TARGET ./scripts/build_xlang_asm.sh for details."
fi
