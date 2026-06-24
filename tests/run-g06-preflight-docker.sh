#!/usr/bin/env bash
# run-g06-preflight-docker.sh — G-06 冷启动快验（预构建镜像，无 apt-get，fail-fast，实时输出）
#
# 用法（仓库根）：
#   ./tests/run-g06-preflight-docker.sh           # seed 清单（秒级）
#   ./tests/run-g06-preflight-docker.sh --asm-e   # + asm.sx -E 烟测（默认 300s timeout）
#
# 首次：./tests/docker/build-linux-dev-image.sh（一次，约 2～5 分钟，有逐步输出）
# 另开终端看日志：tail -f /tmp/shux-g06-preflight.log
# 高频：SHUX_DOCKER_PERSIST=1 ./tests/run-g06-preflight-docker.sh --asm-e

set -euo pipefail
cd "$(dirname "$0")/.."

progress() { echo "[$(date +%H:%M:%S)] $*"; }

ASM_FLAG=""
if [ "${1:-}" = "--asm-e" ]; then
  ASM_FLAG="--asm-e"
fi

TIMEOUT="${SHUX_G06_E_TIMEOUT:-300}"
LOG="${SHUX_G06_PREFLIGHT_LOG:-/tmp/shux-g06-preflight.log}"
INNER="cp -f seeds/bootstrap_shuxc.linux.x86_64 bootstrap_shuxc && chmod +x bootstrap_shuxc
ulimit -s 65532 2>/dev/null || true
SHUX_G06_E_TIMEOUT=${TIMEOUT} SHUX_E=./bootstrap_shuxc ./scripts/preflight_g06_coldstart.sh ${ASM_FLAG}"

progress "run-g06-preflight-docker: START timeout=${TIMEOUT}s persist=${SHUX_DOCKER_PERSIST:-0}"
progress "run-g06-preflight-docker: LOG $LOG  (另开终端: tail -f $LOG)"

chmod +x tests/lib/docker-linux-run.sh tests/lib/progress-run.sh \
  compiler/scripts/preflight_g06_coldstart.sh tests/docker/build-linux-dev-image.sh

# progress-run：stdout 行缓冲 + tee，终端与日志同步
./tests/lib/progress-run.sh "G-06 preflight docker ${ASM_FLAG:-seed-only}" "$LOG" -- \
  ./tests/lib/docker-linux-run.sh compiler "$INNER"

progress "run-g06-preflight-docker OK"
