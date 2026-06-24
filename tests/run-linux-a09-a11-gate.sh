#!/usr/bin/env bash
# A-09 + A-10 + A-11 + A-12：Linux x86_64 Docker 内 Stage2 全链 + SHA256 + L5 bstrict + typeck + arch 符号。
# 用法（仓库根）：./tests/run-linux-a09-a11-gate.sh
# 环境：SHUX_DOCKER_PLATFORM=linux/amd64（默认 Darwin/ARM64 宿主自动选 amd64）
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v docker >/dev/null 2>&1; then
  echo "run-linux-a09-a11-gate FAIL: docker not found" >&2
  exit 1
fi

DOCKER_PLATFORM="${SHUX_DOCKER_PLATFORM:-}"
if [ -z "$DOCKER_PLATFORM" ]; then
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64|Linux-aarch64|Linux-arm64)
      DOCKER_PLATFORM="linux/amd64"
      ;;
  esac
fi
DOCKER_PLATFORM_ARGS=""
if [ -n "$DOCKER_PLATFORM" ]; then
  DOCKER_PLATFORM_ARGS="--platform $DOCKER_PLATFORM"
fi

LOG="${SHUX_LINUX_A09_A11_LOG:-/tmp/shux-linux-a09-a11.log}"
echo "run-linux-a09-a11-gate: log=$LOG platform=${DOCKER_PLATFORM:-default}"

LINUX_DEV_IMAGE="${SHUX_LINUX_DEV_IMAGE:-shux-linux-dev:22.04-amd64}"
USE_DEV_IMAGE=0
if docker image inspect "$LINUX_DEV_IMAGE" >/dev/null 2>&1; then
  USE_DEV_IMAGE=1
  echo "run-linux-a09-a11-gate: using prebuilt image $LINUX_DEV_IMAGE (no apt-get)"
else
  echo "run-linux-a09-a11-gate: image $LINUX_DEV_IMAGE missing; using ubuntu:22.04 + apt-get (run ./tests/docker/build-linux-dev-image.sh once to skip apt)"
fi

echo "run-linux-a09-a11-gate: streaming to $LOG (watch: tail -f $LOG)"

INNER='
set -e
progress() { echo "[$(date +%H:%M:%S)] $*"; }
progress "make clean ..."
make -C compiler clean >/dev/null 2>&1 || true
progress "purge host core/std .o (Docker Linux must relink native objects) ..."
find ../core ../std -name '"'"'*.o'"'"' -delete 2>/dev/null || true
chmod +x tests/run-linux-a09-a11-gate-inner.sh
./tests/run-linux-a09-a11-gate-inner.sh
'

if [ "$USE_DEV_IMAGE" -eq 1 ]; then
  # shellcheck disable=SC2086
  docker run --rm $DOCKER_PLATFORM_ARGS \
    --memory=8g --shm-size=2g \
    -v "$(pwd):/src" \
    -w /src \
    -e SHUX_CI_DOCKER=1 \
    "$LINUX_DEV_IMAGE" \
    bash -lc "$INNER" 2>&1 | tee "$LOG"
else
  # shellcheck disable=SC2086
  docker run --rm $DOCKER_PLATFORM_ARGS \
    --memory=8g --shm-size=2g \
    -v "$(pwd):/src" \
    -w /src \
    ubuntu:22.04 \
    bash -lc '
set -e
progress() { echo "[$(date +%H:%M:%S)] $*"; }
progress "apt-get install ..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq gcc make liburing-dev zlib1g-dev libzstd-dev libbrotli-dev libsqlite3-dev curl xz-utils file python3 binutils >/dev/null
'"$INNER" 2>&1 | tee "$LOG"
fi

grep -q 'LINUX A-09/A-10/A-11/A-12 DONE' "$LOG"
echo "run-linux-a09-a11-gate OK (A-09 + A-10 + A-11 + A-12; log: $LOG)"
