#!/usr/bin/env bash
# run-l1-relink-fast.sh — L1 语义 gate 高效路径（parser/typeck 迭代用）
#
# 用法（仓库根）：
# ./tests/run-l1-relink-fast.sh # Docker 内 relink + 4 条 L1 gate
# ./tests/run-l1-relink-fast.sh --smoke-only # 仅 slice 单文件烟测（最快）
# ./tests/run-l1-relink-fast.sh --relink-only
#
# 环境：
# SHUX_DOCKER_PERSIST=1 默认开启（常驻容器，二次 ~1min）
# SHUX_DOCKER_MEMORY=16g 默认 16g
# SHUX_FORCE_FULL_BOOTSTRAP=1 无 shux 时跑完整 bootstrap-driver-seed（慢，仅首次）

set -euo pipefail
cd "$(dirname "$0")/.."

SMOKE_ONLY=0
RELINK_ONLY=0
for arg in "$@"; do
  case "$arg" in
  --smoke-only) SMOKE_ONLY=1 ;;
  --relink-only) RELINK_ONLY=1 ;;
  -h|--help)
  sed -n '2,16p' "$0"
  exit 0
  ;;
  *) echo "run-l1-relink-fast: unknown arg $arg" >&2; exit 1 ;;
  esac
done

export SHUX_DOCKER_PERSIST="${SHUX_DOCKER_PERSIST:-1}"
export SHUX_DOCKER_MEMORY="${SHUX_DOCKER_MEMORY:-16g}"
export SHUX_DOCKER_SHM="${SHUX_DOCKER_SHM:-4g}"

DOCKER="./tests/lib/docker-linux-run.sh"
chmod +x "$DOCKER" 2>/dev/null || true

INNER='
set -e
progress(){ echo "[$(date +%H:%M:%S)] l1-fast $*"; }

cd /src/compiler
chmod +x scripts/*.sh 2>/dev/null || true

# 恢复 pinned gen（免 shux-c -E 再生）
copy_seed() { [ -f "$1" ] && cat "$1" > "$2"; }
for f in lexer_gen parser_gen typeck_gen codegen_gen pipeline_gen driver_gen preprocess_gen \
  lsp_io_gen lsp_gen lsp_diag_gen lsp_io_std_heap_gen \
  driver_fmt_gen driver_check_gen driver_test_gen driver_compile_gen driver_build_gen driver_run_gen driver_emit_gen; do
  copy_seed "seeds/${f}.linux.x86_64.c" "${f}.c"
done

progress "rebuild parser_asm_thin_glue.o (slice T[] fix)"
touch src/asm/parser_asm_type_ref_slice.inc
make -j"$(nproc 2>/dev/null || echo 4)" parser_asm_thin_glue.o

progress "rebuild parser_x.o (region { parse fix)"
touch parser_gen.c
make -j"$(nproc 2>/dev/null || echo 4)" parser_x.o 2>&1 | tail -3 || true

progress "rebuild pipeline_x.o + typeck_x.o (region parent link + assign final_expr)"
touch ast_pool.c pipeline_glue.c typeck_gen.c
make -j"$(nproc 2>/dev/null || echo 4)" pipeline_x.o typeck_x.o 2>&1 | tail -8 || true

final_link_shux() {
  local line
  line=$(make -n bootstrap-driver-seed 2>/dev/null | grep " -o shux " | grep -v shux-seed-phase1 | tail -1)
  if [ -z "$line" ]; then
  echo "l1-fast FAIL: cannot extract final link line from make -n" >&2
  exit 1
  fi
  progress "final link shux (skip asm.x -E)"
  eval "$line"
  cp -f shux shux-c
  cp -f shux bootstrap_shuxc
}

if [ -x ./shux ] && [ "${SHUX_FORCE_FULL_BOOTSTRAP:-}" != "1" ]; then
  progress "incremental: existing shux -> relink final only"
  final_link_shux
else
  progress "cold: build DRIVER_SEED prereqs (parallel, no asm -E yet)"
  # cfg_eval.x 的 asm 编译极慢；冷启动直接用 stub
  cc -Wall -Wextra -I. -Iinclude -Isrc -c -o src/lexer/cfg_eval_bootstrap_stub.o src/lexer/cfg_eval_bootstrap_stub.c
  cp -f src/lexer/cfg_eval_bootstrap_stub.o src/lexer/cfg_eval.o
  make -j"$(nproc 2>/dev/null || echo 4)" \
  parser_x.o typeck_x.o codegen_x.o driver_x.o pipeline_x.o lexer_x.o x_frontend_link_alias.o \
  preprocess_x.o pipeline_bootstrap_orchestration.o \
  lsp_x.o lsp_diag_x.o lsp_io_x.o lsp_io_std_heap_x.o \
  driver_fmt_x.o driver_check_x.o driver_test_x.o driver_compile_x.o driver_build_x.o driver_run_x.o driver_emit_x.o \
  src/main_driver.o src/runtime_driver.o src/runtime_abi.o src/runtime_io_abi.o src/runtime_proc_abi.o \
  src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o \
  src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o \
  src/x_seed_bridge.o src/std_fs_shim.o src/std_sys_shim.o \
  src/ast_pool_l5_bridge.o src/lsp/lsp_codegen_extern.o src/lsp/lsp_diag_pipeline_sizes_nostub.o \
  src/lsp/lsp_diag_pipeline_ctx.o \
  typeck_c_module_stubs.o src/runtime_pipeline_abi_shux_c_stubs.o \
  src/runtime_heap_user.o src/runtime_heap_user.o \
  2>&1 | while IFS= read -r line; do echo "$line"; done
  progress "gen phase1 stub partial (avoid long asm -E)"
  ./scripts/gen_g06_phase1_backend_stub.sh
  final_link_shux
fi

progress "smoke: i32[] parse (expect num_funcs=2)"
cat >/tmp/l1_slice_smoke.x <<EOF
function f(): i32[] { return 0; }
function main(): i32 { return 0; }
EOF
out=$(SHUX_DEBUG_PIPE=1 ./shux-c check /tmp/l1_slice_smoke.x 2>&1) || true
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
SHUX=./compiler/shux-c
progress "run-typeck-region.sh"
"$SHUX" >/dev/null 2>&1 || true
chmod +x tests/run-typeck-region.sh tests/run-typeck-linear.sh \
  tests/run-type-borrow-conflict-gate.sh tests/run-scope-borrow-gate.sh
SHUX="$SHUX" ./tests/run-typeck-region.sh
SHUX="$SHUX" ./tests/run-typeck-linear.sh
SHUX="$SHUX" SHUX_TYPE_BORROW_FAIL=1 ./tests/run-type-borrow-conflict-gate.sh
SHUX="$SHUX" ./tests/run-scope-borrow-gate.sh
progress "OK L1 gates"
'

SMOKE_ONLY="${SMOKE_ONLY:-0}" RELINK_ONLY="${RELINK_ONLY:-0}" \
  "$DOCKER" compiler "export SMOKE_ONLY=${SMOKE_ONLY:-0} RELINK_ONLY=${RELINK_ONLY:-0}; ${INNER}"
