#!/usr/bin/env bash
# relink_xlang_asm_bstrict_runtime_objs.sh — B-strict fast relink of xlang_asm
#
# Authority (G.7 有则补全):
#   Single implementation for Makefile phony bootstrap-driver-bstrict-relink
#   and the historic direct-invoke path:
#     ./scripts/relink_xlang_asm_bstrict_runtime_objs.sh
#
#   What this owns:
#     1) Require prior bootstrap objects (build_asm/pipeline.o present)
#     2) Set XLANG_ASM_* skip flags for strict relink-only (~30s path)
#     3) Invoke build_xlang_asm.sh with XLANG (default ./xlang_asm)
#     4) Require xlang_asm exists after relink; print OK line for make consumers
#
#   Why shell-primary (not physical delete)?
#     build_asm leaf graph + cold bootstrap still make/g05 residual; this is only
#     the daily "relink after glue/runtime edit" orchestration body.
#
# Usage (cwd = compiler/):
#   bash scripts/relink_xlang_asm_bstrict_runtime_objs.sh
#   bash scripts/relink_xlang_asm_bstrict_runtime_objs.sh --check
#
# Env:
#   XLANG   — driver for build_xlang_asm (default: ./xlang_asm; fallback stage1)
#   (XLANG_ASM_* flags defaulted below; caller override wins)
#
# wave868 (G.7 有则补全): Makefile fat dual body → this script (thin-call only).
# Historic comment already named this script as equivalent; dual body was residual.
# NOT physical delete — thin edges + B2 + mk lists remain residual.
# PLATFORM: SHARED — orchestration only; ABI stays in build_xlang_asm.

set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-run}"

log() { echo "bootstrap-driver-bstrict-relink: $*" >&2; }
fail() { echo "bootstrap-driver-bstrict-relink: FAIL: $*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# --check: structural honesty (no product relink; dual-end L2 safe)
# ---------------------------------------------------------------------------
if [ "$MODE" = "--check" ] || [ "$MODE" = "check" ]; then
  MF=Makefile
  [ -f "$MF" ] || fail "missing $MF"
  _rec=$(awk '
    /^bootstrap-driver-bstrict-relink:/ { hit=1; next }
    hit && /^[^[:space:]#]/ { exit }
    hit && /^\t/ { print }
  ' "$MF")
  if ! grep -q 'relink_xlang_asm_bstrict_runtime_objs\.sh' <<<"$_rec"; then
    fail "bootstrap-driver-bstrict-relink must thin-call relink_xlang_asm_bstrict_runtime_objs.sh (wave868)"
  fi
  # Dual body: inline XLANG_ASM_* + build_xlang_asm, or inline build_asm prereq gate
  if grep -qE 'XLANG_ASM_BSTRICT_RELINK_ONLY|XLANG_ASM_EXPERIMENTAL_SKIP_GEN' <<<"$_rec"; then
    fail "bootstrap-driver-bstrict-relink must not keep dual XLANG_ASM_* body (wave868; shell owns flags)"
  fi
  if grep -qE 'build_xlang_asm\.sh' <<<"$_rec"; then
    fail "bootstrap-driver-bstrict-relink must not keep dual build_xlang_asm.sh body (wave868)"
  fi
  if grep -qE 'build_asm/pipeline\.o|need prior bootstrap' <<<"$_rec"; then
    fail "bootstrap-driver-bstrict-relink must not keep dual build_asm prereq gate (wave868; shell owns gate)"
  fi
  echo "relink_xlang_asm_bstrict_runtime_objs: --check OK (wave868; shell-primary; not physical delete)"
  exit 0
fi

if [ "$MODE" != "run" ] && [ -n "$MODE" ] && [ "$MODE" != "--run" ]; then
  echo "usage: $0 [--check]" >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Product path
# ---------------------------------------------------------------------------
ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

if [ ! -d build_asm ] || [ ! -f build_asm/pipeline.o ]; then
  fail "need prior bootstrap (make bootstrap-driver-bstrict) — missing build_asm/pipeline.o"
fi

# Skip flags: strict relink-only. Caller env override wins when already set.
export XLANG_ASM_EXPERIMENTAL_SKIP_GEN="${XLANG_ASM_EXPERIMENTAL_SKIP_GEN:-1}"
export XLANG_ASM_BSTRICT_RELINK_ONLY="${XLANG_ASM_BSTRICT_RELINK_ONLY:-1}"
export XLANG_ASM_SKIP_STRICT_SMOKE="${XLANG_ASM_SKIP_STRICT_SMOKE:-1}"
export XLANG_ASM_SKIP_MAIN_O_REBUILD="${XLANG_ASM_SKIP_MAIN_O_REBUILD:-1}"
export XLANG_ASM_SKIP_WPO_DOGFOOD="${XLANG_ASM_SKIP_WPO_DOGFOOD:-1}"
export XLANG_ASM_SKIP_ENTRY_SMOKE="${XLANG_ASM_SKIP_ENTRY_SMOKE:-1}"

# Makefile path preferred ./xlang_asm; standalone historically tried stage1 first.
if [ -z "${XLANG:-}" ]; then
  if [ -x ./xlang_asm ]; then
    XLANG=./xlang_asm
  elif [ -x ./xlang_asm_stage1 ]; then
    XLANG=./xlang_asm_stage1
  else
    fail "need ./xlang_asm or ./xlang_asm_stage1"
  fi
fi
export XLANG
[ -x "$XLANG" ] || fail "XLANG not executable: $XLANG"

log "strict relink-only via $XLANG (build_xlang_asm BSTRICT_RELINK_ONLY=1)"
./scripts/build_xlang_asm.sh

if [ ! -f xlang_asm ]; then
  fail "xlang_asm relink failed (missing after build_xlang_asm)"
fi
echo "bootstrap-driver-bstrict-relink OK (strict relink only; xlang_asm updated)"
