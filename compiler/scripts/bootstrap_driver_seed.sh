#!/usr/bin/env bash
# bootstrap_driver_seed.sh — cold-start orchestration for bootstrap-driver-seed (11.0.3)
#
# Authority (G.7):
#   This script owns the *step sequence* of cold bootstrap after Make has
#   satisfied DRIVER_SEED_PREREQS. Leaf .o builds stay Make targets. phase1/final
#   link *body* is scripts/bootstrap_driver_seed_link.sh (wave721); OBJS/CFLAGS
#   expand only via Makefile export leaves (no dual .o list). Whitelist §5b.
#
# Usage (compiler directory, normally from Makefile):
#   ./scripts/bootstrap_driver_seed.sh
#
# Env:
#   MAKE — make binary (default: make)
#   XLANG_SKIP_SEED_SMOKE=1 — skip post-link smoke
#   TARGET — product binary name (default: xlang); must match Makefile TARGET
#
# PLATFORM: SHARED — orchestration identical; leaf recipes carry platform ABI.
# Wave: 717 orchestration · 721 phase1/final link body via export+shell.

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
TARGET="${TARGET:-xlang}"
XLANG_C="${XLANG_C:-xlang-c}"

log() { echo "bootstrap-driver-seed: $*" >&2; }

# --- §5b whitelist make helper (only named leaves; no free-form recipes) ---
mk() {
  # shellcheck disable=SC2086
  "$MAKE" "$@"
}

# 1) P0-4: refuse stale int32_t Expr.int_val before any pipeline_x / glue link
mk check-pipeline-gen-expr-i64-abi

# Keep committed ast_gen2.c; avoid old seed re -E of ast.x
if [ -f ast_gen2.c ] && [ -s ast_gen2.c ]; then
  touch -r ast_gen2.c src/ast/ast.x 2>/dev/null || true
fi

# 2) Force pipeline_x.o recompile on cold start
mk pipeline_x.o PIPELINE_X_FORCE_COMPILE=1

# 3) Satellite runtime/diag/simd .o forced seed path (PREFER=0)
mk bootstrap-driver-seed-sat-rebuild

# 4) lsp / frontend alias objs
mk bootstrap-driver-seed-lsp-x-objs

# Seed partial: prefer pinned platform partial if host partial missing/non-real
chmod +x scripts/build_seed_asm_host.sh scripts/gen_g06_phase1_backend_stub.sh 2>/dev/null || true
os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m 2>/dev/null | tr '[:upper:]' '[:lower:]')
case "$arch" in x86_64|amd64) arch=x86_64 ;; aarch64|arm64) arch=arm64 ;; esac
case "$os" in
  darwin) os=darwin ;;
  linux) os=linux ;;
  msys_nt*|mingw*_nt*|mingw*|cygwin*) os=windows ;;
esac
seed_partial="seeds/asm_backend_partial.${os}.${arch}.o"
if [ ! -s build_asm/seed_host/asm_backend_partial.o ] && [ -f "$seed_partial" ] && [ -s "$seed_partial" ]; then
  if nm "$seed_partial" 2>/dev/null | awk '/ T / { s=$3; sub(/^_/, "", s); if (s=="backend_asm_codegen_ast_seed_mega") found=1 } END { exit !found }'; then
    mkdir -p build_asm/seed_host
    cp -f "$seed_partial" build_asm/seed_host/asm_backend_partial.o
    log "seed partial <- $seed_partial"
  else
    log "ignore non-real seed partial $seed_partial (missing strong seed_mega)"
  fi
fi

# 5) bridge
mk src/x_seed_bridge.o

# 6) USER_ASM seed objs (platform list stays in Makefile)
mk bootstrap-driver-seed-user-asm-seed-objs

# 7) pipeline_glue_standalone.o (arch_*_enc weak stubs provider)
mk bootstrap-driver-seed-asm-glue-standalone

# 8) build-seed-asm-host (half shell already)
mk build-seed-asm-host

if [ ! -s build_asm/seed_host/asm_backend_partial.o ]; then
  log "no seed partial, gen phase1 backend stub ..."
  ./scripts/gen_g06_phase1_backend_stub.sh
fi

mkdir -p build_asm/seed_host
rm -f build_asm/seed_host/asm_full_link_stubs.o build_asm/seed_host/asm_full_link_stubs.c

# 9) host stubs (after partial exists)
mk bootstrap-driver-seed-host-stubs

# 10) class-G filtered.o (Darwin product chain; empty on Linux)
mk bootstrap-driver-seed-filtered-objs

# 11a) phase1 link → xlang-seed-phase1
mk bootstrap-driver-seed-phase1-link

# Build real USER_ASM partial via phase1 binary
log "build-seed-asm-host via xlang-seed-phase1 ..."
if ! XLANG_E=./xlang-seed-phase1 ./scripts/build_seed_asm_host.sh; then
  ./scripts/gen_g06_phase1_backend_stub.sh
  log "WARN asm.x -E failed, final link uses phase1 stub partial"
fi

# refresh stubs against new partial
mk bootstrap-driver-seed-host-stubs

# 11b) final link → xlang
mk bootstrap-driver-seed-final-link

# 12) runtime_panic.o (post-link satellite)
mk runtime_panic.o

# 13) smoke + product binary aliases
if [ "${XLANG_SKIP_SEED_SMOKE:-}" = "1" ]; then
  log "skip seed smoke (XLANG_SKIP_SEED_SMOKE=1)"
else
  chmod +x scripts/bootstrap_driver_seed_smoke.sh 2>/dev/null || true
  ./scripts/bootstrap_driver_seed_smoke.sh "./$TARGET"
fi

cp -f "$TARGET" xlang-x
cp -f "$TARGET" "$XLANG_C"
cp -f "$TARGET" bootstrap_xlangc
chmod +x scripts/bootstrap_xlangc_create.sh scripts/capture_bootstrap_seeds.sh 2>/dev/null || true
./scripts/bootstrap_xlangc_create.sh "./$TARGET" 2>/dev/null || cp -f "$TARGET" bootstrap_xlangc

echo "bootstrap-driver-seed OK (C-06 *_x.o; G-06 two-phase seed + USER_ASM partial; xlang-c synced)"
