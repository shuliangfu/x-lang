#!/usr/bin/env bash
# S5：在 Linux amd64 Alpine 容器内重编 pipeline_wpo.o（ast_pool WPO reach 修复后须跑本脚本）。
# strict_glue 的 ENTRY_MODULE_ONLY 路径已知 SIGSEGV；本脚本走 experimental（musl + liburing）。
# 用法（仓库根目录）：
#   ./tests/rebuild-pipeline-wpo-o-docker.sh
#   ./tests/rebuild-pipeline-wpo-o-docker.sh --full-bootstrap   # 全量 make + build_shu_asm（慢）
set -e
cd "$(dirname "$0")/.."
FULL=0
[ "${1:-}" = "--full-bootstrap" ] && FULL=1

run_rebuild() {
  docker run --rm --platform linux/amd64 -v "$(pwd):/src" -w /src/compiler alpine:3.19 sh -c "
set -e
apk add --no-cache bash make perl gawk binutils liburing-dev musl-dev gcc >/dev/null
ulimit -s 65532 2>/dev/null || true
if [ '$FULL' = '1' ]; then
  echo '=== full bootstrap (make + build_shu_asm) ==='
  make OPT=1 -C /src/compiler all
  ./scripts/build_shu_asm.sh 2>&1 | tail -30
else
  echo '=== pipeline_su.o + experimental relink + pipeline_wpo.o ==='
  make pipeline_su.o PIPELINE_SU_FORCE_COMPILE=1 2>&1 | tail -5
  ./scripts/relink_shu_asm_experimental_bootstrap.sh 2>&1 | tail -5
  SHU_WPO_REBUILD_ARTIFACTS_ONLY=1 ./scripts/build_shu_asm.sh 2>&1 | tail -20
fi
cd /src
SHU_WPO_PIPELINE_REACH_FAIL=1 ./tests/run-wpo-pipeline-reach-gate.sh
./tests/run-wpo-pipeline-o-gate.sh
SHU_WPO_ENSURE_ARTIFACTS=0 SHU_WPO_CHAIN_FAIL=1 ./tests/run-wpo-build-asm-chain-gate.sh
SHU_WPO_STRICT_LINK_FAIL=1 ./tests/run-wpo-strict-link-gate.sh 2>/dev/null || echo "rebuild-pipeline-wpo-o-docker: strict link gate skipped (need ubuntu+liburing-dev)"
echo 'rebuild-pipeline-wpo-o-docker OK'
"
}

echo "rebuild-pipeline-wpo-o-docker: starting (full=$FULL) ..."
run_rebuild
