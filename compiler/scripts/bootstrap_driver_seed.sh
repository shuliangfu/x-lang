#!/usr/bin/env bash
# bootstrap_driver_seed.sh — cold-start orchestration for bootstrap-driver-seed (11.0.3)
#
# Authority (G.7):
#   This script owns the *step sequence* of cold bootstrap. wave744: prereq
#   *edge satisfaction* is scripts/driver_seed_ensure_prereqs.sh (catalog
#   DRIVER_SEED_PREREQS + glue companion) — Makefile no longer lists
#   $(DRIVER_SEED_PREREQS) as make-graph deps on this phony. Leaf .o builds
#   still use Make pattern rules. phase1/final link *body* is
#   scripts/bootstrap_driver_seed_link.sh (wave721); sat/lsp +
#   bridge/panic/user-asm/glue/pipeline-x rebuild *body* is
#   scripts/bootstrap_driver_seed_rebuild_leaves.sh (wave722/724/725);
#   host-stubs *body* is scripts/bootstrap_driver_seed_host_stubs.sh (wave723);
#   check-abi *body* is scripts/check_pipeline_gen_expr_i64_abi.sh (wave725);
#   asm-host *body* is scripts/build_seed_asm_host.sh via thin leaf (wave725).
#   OBJS/CFLAGS expand only via Makefile export leaves (no dual .o list).
#   Whitelist §5b.
#
# Usage (compiler directory, normally from Makefile):
#   ./scripts/bootstrap_driver_seed.sh
#
# Env:
#   MAKE — make binary (default: make)
#   XLANG_SKIP_SEED_SMOKE=1 — skip post-link smoke
#   XLANG_SKIP_DRIVER_SEED_PREREQS=1 — skip ensure_prereqs (nested/agent hatch)
#   TARGET — product binary name (default: xlang); must match Makefile TARGET
#   XLANG_CATALOG_CACHE_FILE — optional pre-warmed catalog KEY= blob (parent may set);
#     this script warms one session file when unset so ensure_prereqs + rebuild_leaves
#     + every try-r1/try-heat share one mk parse (Windows MinGW: multi-minute stalls
#     without it — ensure_prereqs alone is not enough; its EXIT deleted the cache).
#
# PLATFORM: SHARED — orchestration identical; leaf recipes carry platform ABI.
# Wave: 717 orchestration · 721 phase1/final link · 722 sat/lsp · 723 host-stubs ·
#       724 bridge/panic/user-asm/glue · 725 check-abi/pipeline-x FORCE/asm-host ·
#       744 DRIVER_SEED_PREREQS edge swallow (shell ensure).
#       891 SKIP_SUBSCRIPT soft-skip / nested-make body → this script (G.7 有则补全).
#
# Env (wave891):
#   XLANG_SKIP_SUBSCRIPT_MAKE=1 — if TARGET already executable, soft-skip full
#     cold sequence (run-all entry already linked seed). If TARGET missing,
#     re-invoke make bootstrap-driver-seed with SKIP cleared + RUN_ALL=1 so
#     composites/export leaves load (historic nested $(MAKE) body).

set -euo pipefail
cd "$(dirname "$0")/.."

MAKE="${MAKE:-make}"
TARGET="${TARGET:-xlang}"
XLANG_C="${XLANG_C:-xlang-c}"

log() { echo "bootstrap-driver-seed: $*" >&2; }

# ---------------------------------------------------------------------------
# wave891: XLANG_SKIP_SUBSCRIPT_MAKE soft-skip (G.7 有则补全; was Makefile body)
# PLATFORM: SHARED — same gate on mac/Ubuntu/Windows host.
# ---------------------------------------------------------------------------
if [ -n "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  if [ -x "./${TARGET}" ]; then
    log "SKIP: XLANG_SKIP_SUBSCRIPT_MAKE=${XLANG_SKIP_SUBSCRIPT_MAKE} and ./${TARGET} already executable"
    exit 0
  fi
  # TARGET missing: full cold needs composites.mk / export leaves → re-enter make
  # with SKIP cleared (parse-time ifeq) + RUN_ALL so all-path preserves seed.
  log "TARGET ./${TARGET} not executable under SKIP_SUBSCRIPT; full bootstrap via make"
  # Unset so nested make takes the full-body branch (include composites).
  env -u XLANG_SKIP_SUBSCRIPT_MAKE \
    XLANG_RUN_ALL_BOOTSTRAP_XLANG="${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-1}" \
    MAKEFLAGS= "${MAKE}" bootstrap-driver-seed \
    XLANG_SKIP_SUBSCRIPT_MAKE= \
    XLANG_RUN_ALL_BOOTSTRAP_XLANG="${XLANG_RUN_ALL_BOOTSTRAP_XLANG:-1}"
  exit $?
fi

# Session catalog cache: one shell mk parse for the whole cold seed wave.
# PLATFORM: SHARED — required for Windows hybrid min-gate (Git Bash/MinGW);
# macOS/Linux also benefit (avoids N× catalog in rebuild ladders).
_bootstrap_cat_owned=0
_bootstrap_cat_cache="${XLANG_CATALOG_CACHE_FILE:-}"
if [ -n "${_bootstrap_cat_cache}" ] && [ -s "${_bootstrap_cat_cache}" ]; then
  export XLANG_CATALOG_CACHE_FILE="${_bootstrap_cat_cache}"
  log "catalog cache reuse OK (${XLANG_CATALOG_CACHE_FILE})"
else
  _bootstrap_cat_cache="${TMPDIR:-/tmp}/xlang_bootstrap_catalog_$$.txt"
  if bash scripts/driver_seed_obj_catalog.sh --shell >"${_bootstrap_cat_cache}" \
    2>/tmp/xlang_bootstrap_cat_err_$$.txt; then
    export XLANG_CATALOG_CACHE_FILE="${_bootstrap_cat_cache}"
    _bootstrap_cat_owned=1
    log "catalog cache warm OK (${XLANG_CATALOG_CACHE_FILE})"
  else
    log "WARN catalog warm failed (ensure/rebuild will re-expand)"
    cat /tmp/xlang_bootstrap_cat_err_$$.txt 2>/dev/null || true
    rm -f "${_bootstrap_cat_cache}" /tmp/xlang_bootstrap_cat_err_$$.txt
    unset XLANG_CATALOG_CACHE_FILE || true
    _bootstrap_cat_cache=""
    _bootstrap_cat_owned=0
  fi
fi
# shellcheck disable=SC2064
trap 'if [ "${_bootstrap_cat_owned:-0}" = "1" ]; then rm -f "${_bootstrap_cat_cache:-}" /tmp/xlang_bootstrap_cat_err_$$.txt; fi' EXIT HUP INT TERM

# --- §5b whitelist make helper (only named leaves; no free-form recipes) ---
# wave934: 10 phony thin-call targets migrated to direct shell invocation.
# mk() retained for 3 targets with .o dependencies (asm-host, filtered-objs,
# and ensure_prereqs --run which compiles 53 .o/.c leaves via make).
mk() {
  # shellcheck disable=SC2086
  "$MAKE" "$@"
}

# 0) wave744: satisfy DRIVER_SEED_PREREQS edges via catalog (G.7 single list).
# Makefile phony no longer carries $(DRIVER_SEED_PREREQS) as make-graph deps.
chmod +x scripts/driver_seed_ensure_prereqs.sh 2>/dev/null || true
MAKE="$MAKE" ./scripts/driver_seed_ensure_prereqs.sh --run

# 1) P0-4: refuse stale int32_t Expr.int_val before any pipeline_x / glue link
# §5b #1 wave725: pure shell body (no Makefile-inline restore/fail logic).
chmod +x scripts/check_pipeline_gen_expr_i64_abi.sh 2>/dev/null || true
./scripts/check_pipeline_gen_expr_i64_abi.sh

# Keep committed ast_gen2.c; avoid old seed re -E of ast.x
if [ -f ast_gen2.c ] && [ -s ast_gen2.c ]; then
  touch -r ast_gen2.c src/ast/ast.x 2>/dev/null || true
fi

# 2) Force pipeline_x.o recompile on cold start (§5b #2 export + rebuild_leaves)
# wave934: direct shell invocation (was mk bootstrap-driver-seed-pipeline-x).
bash scripts/bootstrap_driver_seed_rebuild_leaves.sh pipeline-x

# 3) Satellite runtime/diag/simd .o forced seed path (PREFER=0)
# wave934: direct shell invocation (was mk bootstrap-driver-seed-sat-rebuild).
bash scripts/bootstrap_driver_seed_rebuild_leaves.sh sat

# 4) lsp / frontend alias objs
# wave934: direct shell invocation (was mk bootstrap-driver-seed-lsp-x-objs).
bash scripts/bootstrap_driver_seed_rebuild_leaves.sh lsp

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

# 5) bridge (export + shell; §5b #5)
# wave934: direct shell invocation (was mk bootstrap-driver-seed-bridge).
bash scripts/bootstrap_driver_seed_rebuild_leaves.sh bridge

# 6) USER_ASM seed objs (list only in Makefile export; §5b #6)
# wave934: direct shell invocation (was mk bootstrap-driver-seed-user-asm-seed-objs).
bash scripts/bootstrap_driver_seed_rebuild_leaves.sh user-asm

# 7) pipeline_glue_standalone.o (arch_*_enc weak stubs provider; §5b #7)
# wave934: direct shell invocation (was mk bootstrap-driver-seed-asm-glue-standalone).
bash scripts/bootstrap_driver_seed_rebuild_leaves.sh glue

# 8) build-seed-asm-host (§5b #8 thin leaf → build_seed_asm_host.sh)
mk bootstrap-driver-seed-asm-host

if [ ! -s build_asm/seed_host/asm_backend_partial.o ]; then
  log "no seed partial, gen phase1 backend stub ..."
  ./scripts/gen_g06_phase1_backend_stub.sh
fi

mkdir -p build_asm/seed_host
rm -f build_asm/seed_host/asm_full_link_stubs.o build_asm/seed_host/asm_full_link_stubs.c

# 9) host stubs (after partial exists)
# wave934: direct shell invocation (was mk bootstrap-driver-seed-host-stubs).
bash scripts/bootstrap_driver_seed_host_stubs.sh

# 10) class-G filtered.o (Darwin product chain; empty on Linux)
# wave934: retained as mk call — target has $(BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS)
# dependency (.o compile rules still in Makefile; Darwin non-empty, Linux empty).
mk bootstrap-driver-seed-filtered-objs

# 11a) phase1 link → xlang-seed-phase1
# wave934: direct shell invocation (was mk bootstrap-driver-seed-phase1-link).
bash scripts/bootstrap_driver_seed_link.sh phase1

# Build real USER_ASM partial via phase1 binary
log "build-seed-asm-host via xlang-seed-phase1 ..."
if ! XLANG_E=./xlang-seed-phase1 ./scripts/build_seed_asm_host.sh; then
  ./scripts/gen_g06_phase1_backend_stub.sh
  log "WARN asm.x -E failed, final link uses phase1 stub partial"
fi

# refresh stubs against new partial
# wave934: direct shell invocation (was mk bootstrap-driver-seed-host-stubs).
bash scripts/bootstrap_driver_seed_host_stubs.sh

# 11b) final link → xlang
# wave934: direct shell invocation (was mk bootstrap-driver-seed-final-link).
bash scripts/bootstrap_driver_seed_link.sh final

# 12) runtime_panic.o (post-link satellite; export + shell; §5b #12)
# wave934: direct shell invocation (was mk bootstrap-driver-seed-panic).
bash scripts/bootstrap_driver_seed_rebuild_leaves.sh panic

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
