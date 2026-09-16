#!/usr/bin/env bash
# run-l1-relink-fast.sh — L1 semantic gate fast path (parser/typeck iteration)
#
# Usage (repo root):
#   ./tests/run-l1-relink-fast.sh              # Docker relink + 4 L1 gates
#   ./tests/run-l1-relink-fast.sh --smoke-only # slice single-file smoke only
#   ./tests/run-l1-relink-fast.sh --relink-only
#
# Env:
#   XLANG_DOCKER_PERSIST=1   default on (persistent container; ~1min on repeat)
#   XLANG_DOCKER_MEMORY=16g  default 16g
#   XLANG_FORCE_FULL_BOOTSTRAP=1  when set, always cold bootstrap_driver_seed
#
# Post-Makefile phys-del (wave941+): INNER is 0-make.
#   leaf .o  → scripts/ensure_host_cc_seed_o.sh try-heat (--force after touch)
#   final    → FULL=0 g05_prepare_and_relink.sh (syncs xlang / xlang_asm / xlang-c)
#   cold     → scripts/bootstrap_driver_seed.sh (G.7 single cold authority)
# Ban bare `make` / `make -n` link-line scrape (MF gone → sit-red).
# PLATFORM: SHARED orchestration; Docker host is Linux x86_64 gold path.

set -euo pipefail
cd "$(dirname "$0")/.."

SMOKE_ONLY=0
RELINK_ONLY=0
for arg in "$@"; do
  case "$arg" in
  --smoke-only) SMOKE_ONLY=1 ;;
  --relink-only) RELINK_ONLY=1 ;;
  -h|--help)
    sed -n '2,20p' "$0"
    exit 0
    ;;
  *) echo "run-l1-relink-fast: unknown arg $arg" >&2; exit 1 ;;
  esac
done

export XLANG_DOCKER_PERSIST="${XLANG_DOCKER_PERSIST:-1}"
export XLANG_DOCKER_MEMORY="${XLANG_DOCKER_MEMORY:-16g}"
export XLANG_DOCKER_SHM="${XLANG_DOCKER_SHM:-4g}"

DOCKER="./tests/lib/docker-linux-run.sh"
chmod +x "$DOCKER" 2>/dev/null || true

INNER='
set -e
progress(){ echo "[$(date +%H:%M:%S)] l1-fast $*"; }

cd /src/compiler
chmod +x scripts/*.sh 2>/dev/null || true

# Restore pinned gen (avoid xlang-c -E regen).
copy_seed() { [ -f "$1" ] && cat "$1" > "$2"; }
for f in lexer_gen parser_gen typeck_gen codegen_gen pipeline_gen driver_gen preprocess_gen \
  lsp_io_gen lsp_gen lsp_diag_gen lsp_io_std_heap_gen \
  driver_fmt_gen driver_check_gen driver_test_gen driver_compile_gen driver_build_gen driver_run_gen driver_emit_gen; do
  copy_seed "seeds/${f}.linux.x86_64.c" "${f}.c"
done

# Force-rebuild one leaf via heat ladder (G.7: ensure_host_cc_seed_o authority).
# PLATFORM: SHARED — same try-heat body as product g05 / bootstrap_driver_seed.
ensure_force_o() {
  XLANG_HOST_CC_SEED_FORCE=1 bash scripts/ensure_host_cc_seed_o.sh try-heat "$1"
}

progress "rebuild parser_asm_thin_glue.o (slice T[] fix)"
touch seeds/parser_asm/parser_asm_type_ref_slice.inc
ensure_force_o parser_asm_thin_glue.o

progress "rebuild parser_x.o (region { parse fix)"
touch parser_gen.c
ensure_force_o parser_x.o 2>&1 | tail -3 || true

# wave309: ast_pool.c / pipeline_glue.c left — do NOT touch-create fossils under
# /src/compiler (Docker INNER cwd). Live producers = pipeline.x + typeck.x /
# typeck_gen.c. PLATFORM: SHARED archaeology honesty.
progress "rebuild pipeline_x.o + typeck_x.o (region parent link + assign final_expr)"
touch src/pipeline/pipeline.x src/typeck/typeck.x typeck_gen.c
ensure_force_o pipeline_x.o 2>&1 | tail -4 || true
ensure_force_o typeck_x.o 2>&1 | tail -4 || true

final_link_xlang() {
  # G.7: product daily relink owns xlang + sync xlang_asm / xlang-c / bootstrap_xlangc.
  # Ban historic `make -n bootstrap-driver-seed` link-line scrape (MF phys-del).
  progress "final link xlang via g05 (0-make)"
  FULL=0 bash scripts/g05_prepare_and_relink.sh
  if [ ! -x ./xlang-c ]; then
    echo "l1-fast FAIL: g05 did not produce ./xlang-c" >&2
    exit 1
  fi
}

if [ -x ./xlang ] && [ "${XLANG_FORCE_FULL_BOOTSTRAP:-}" != "1" ]; then
  progress "incremental: existing xlang -> ensure leaves + g05 relink"
  final_link_xlang
else
  # G.7: cold seed is the single authority (no parallel make .o list / stub scrapes).
  progress "cold: bootstrap_driver_seed.sh (0-make)"
  bash scripts/bootstrap_driver_seed.sh
  if [ ! -x ./xlang-c ] && [ -x ./xlang ]; then
    cp -f xlang xlang-c
    cp -f xlang bootstrap_xlangc 2>/dev/null || true
  fi
fi

progress "smoke: i32[] parse (expect num_funcs=2)"
cat >/tmp/l1_slice_smoke.x <<EOF
function f(): i32[] { return 0; }
function main(): i32 { return 0; }
EOF
out=$(XLANG_DEBUG_PIPE=1 ./xlang-c check /tmp/l1_slice_smoke.x 2>&1) || true
echo "$out" | grep num_funcs || true
echo "$out" | grep -q "num_funcs=2" || {
  echo "l1-fast FAIL: i32[] still not parsed (want num_funcs=2)" >&2
  echo "$out" >&2
  exit 1
}

if [ "${SMOKE_ONLY:-0}" = "1" ]; then
  progress "OK smoke-only"
  exit 0
fi

if [ "${RELINK_ONLY:-0}" = "1" ]; then
  progress "OK relink-only"
  exit 0
fi

cd /src
XLANG=./compiler/xlang-c
progress "run-typeck-region.sh"
"$XLANG" >/dev/null 2>&1 || true
chmod +x tests/run-typeck-region.sh tests/run-typeck-linear.sh \
  tests/run-type-borrow-conflict-gate.sh tests/run-scope-borrow-gate.sh
XLANG="$XLANG" ./tests/run-typeck-region.sh
XLANG="$XLANG" ./tests/run-typeck-linear.sh
XLANG="$XLANG" XLANG_TYPE_BORROW_FAIL=1 ./tests/run-type-borrow-conflict-gate.sh
XLANG="$XLANG" ./tests/run-scope-borrow-gate.sh
progress "OK L1 gates"
'

SMOKE_ONLY="${SMOKE_ONLY:-0}" RELINK_ONLY="${RELINK_ONLY:-0}" \
  "$DOCKER" compiler "export SMOKE_ONLY=${SMOKE_ONLY:-0} RELINK_ONLY=${RELINK_ONLY:-0}; ${INNER}"
