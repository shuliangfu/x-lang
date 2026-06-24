#!/usr/bin/env bash
# build-linux-dev-image.sh — 构建 Shux Linux amd64 开发镜像（仅需在 Dockerfile 变更或首次使用时执行）
#
# 用法（仓库根）：
#   ./tests/docker/build-linux-dev-image.sh
#
# 实时输出：使用 --progress=plain；勿 pipe 到 tail（会看起来像卡住）。
# 日志：SHUX_DOCKER_BUILD_LOG=/tmp/shux-docker-build.log（可选 tee）

set -euo pipefail
cd "$(dirname "$0")/../.."

progress() { echo "[$(date +%H:%M:%S)] $*"; }

IMAGE="${SHUX_LINUX_DEV_IMAGE:-shux-linux-dev:22.04-amd64}"
PLATFORM="${SHUX_DOCKER_PLATFORM:-linux/amd64}"
LOG="${SHUX_DOCKER_BUILD_LOG:-}"

progress "build-linux-dev-image: START $IMAGE platform=$PLATFORM"
if [ -n "$LOG" ]; then
  progress "build-linux-dev-image: LOG $LOG (tail -f $LOG)"
fi

build_cmd() {
  # plain：逐步输出 RUN 层进度，避免 BuildKit 静默数分钟
  DOCKER_BUILDKIT=1 docker build --progress=plain --platform "$PLATFORM" \
    -f tests/docker/linux-dev.Dockerfile \
    -t "$IMAGE" \
    .
}

if [ -n "$LOG" ]; then
  if command -v stdbuf >/dev/null 2>&1; then
    stdbuf -oL -eL build_cmd 2>&1 | tee "$LOG"
  else
    build_cmd 2>&1 | tee "$LOG"
  fi
else
  build_cmd
fi

progress "build-linux-dev-image OK: $IMAGE"
echo "  快验: ./tests/run-g06-preflight-docker.sh"
echo "  通用: ./tests/lib/docker-linux-run.sh compiler './scripts/preflight_g06_coldstart.sh'"
