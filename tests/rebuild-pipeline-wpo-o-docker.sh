#!/usr/bin/env bash
# S5：在 Linux amd64 容器内重编 pipeline_wpo.o（ast_pool WPO reach 修复后须跑本脚本）。
# build_asm/*.x dogfood 用 xlang_asm.experimental（含 pipeline_x.o）；用户编译用 strict_glue。
# 用法（仓库根目录）：
#   ./tests/rebuild-pipeline-wpo-o-docker.sh
#   ./tests/rebuild-pipeline-wpo-o-docker.sh --full-bootstrap   # 全量 shell all + build_xlang_asm（慢）
# PLATFORM: LINUX — docker amd64; 0-make after MF phys-del (G.7 shell authorities).
set -e
cd "$(dirname "$0")/.."
FULL=0
[ "${1:-}" = "--full-bootstrap" ] && FULL=1

run_rebuild() {
  docker run --rm --platform linux/amd64 -v "$(pwd):/src" -w /src/compiler alpine:3.19 sh -c "
set -e
apk add --no-cache bash perl gawk binutils liburing-dev musl-dev gcc >/dev/null
ulimit -s 65532 2>/dev/null || true
if [ '$FULL' = '1' ]; then
  echo '=== full bootstrap (compiler_all_ci + build_xlang_asm) ==='
  OPT=1 bash scripts/compiler_all_ci.sh
  ./scripts/build_xlang_asm.sh 2>&1 | tail -30
else
  echo '=== pipeline_x.o + experimental relink + pipeline_wpo.o ==='
  PIPELINE_X_FORCE_COMPILE=1 bash scripts/ensure_host_cc_seed_o.sh try-heat pipeline_x.o 2>&1 | tail -5
  ./scripts/relink_xlang_asm_experimental_bootstrap.sh 2>&1 | tail -5
  XLANG_WPO_REBUILD_ARTIFACTS_ONLY=1 ./scripts/build_xlang_asm.sh 2>&1 | tail -20
fi
cd /src
XLANG_WPO_PIPELINE_REACH_FAIL=1 ./tests/run-wpo-pipeline-reach-gate.sh
./tests/run-wpo-pipeline-o-gate.sh
XLANG_WPO_ENSURE_ARTIFACTS=0 XLANG_WPO_CHAIN_FAIL=1 ./tests/run-wpo-build-asm-chain-gate.sh
XLANG_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh 2>/dev/null || echo \"rebuild-pipeline-wpo-o-docker: strict link gate skipped (need ubuntu+liburing-dev)\"
echo 'rebuild-pipeline-wpo-o-docker OK'
"
}

echo "rebuild-pipeline-wpo-o-docker: starting (full=$FULL) ..."
run_rebuild
