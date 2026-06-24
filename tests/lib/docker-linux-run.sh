#!/usr/bin/env bash
# docker-linux-run.sh — 在预构建 Linux amd64 镜像内执行命令（默认免 apt-get）
#
# 用法（仓库根）：
#   ./tests/lib/docker-linux-run.sh 'make -C compiler bootstrap-verify'
#   ./tests/lib/docker-linux-run.sh compiler './scripts/preflight_g06_coldstart.sh --asm-e'
#
# 环境：
#   SHUX_LINUX_DEV_IMAGE     镜像 tag，默认 shux-linux-dev:22.04-amd64
#   SHUX_DOCKER_PLATFORM     默认 linux/amd64（Darwin arm64 宿主自动选）
#   SHUX_DOCKER_NO_AUTO_BUILD=1  镜像不存在时不自动 build
#   SHUX_DOCKER_PERSIST=1    使用常驻容器 shux-linux-dev-run（多次 exec，启动更快）
#   SHUX_DOCKER_MEMORY       默认 8g
#   SHUX_DOCKER_SHM          默认 2g
#   SHUX_DOCKER_TIMEOUT_SEC  容器内命令超时（秒）；超时 SIGTERM，+30s SIGKILL；避免 shux check 等卡死占满 CPU

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker-linux-run FAIL: docker not found" >&2
  exit 1
fi

WORKDIR="/src"
CMD=""
if [ "$#" -ge 2 ]; then
  case "$1" in
    compiler|tests|core|std|analysis|docs|examples)
      WORKDIR="/src/$1"
      shift
      ;;
    */*)
      if [ -d "$ROOT/$1" ]; then
        WORKDIR="/src/$1"
        shift
      fi
      ;;
  esac
fi
CMD="${*:-bash}"

IMAGE="${SHUX_LINUX_DEV_IMAGE:-shux-linux-dev:22.04-amd64}"
PLATFORM="${SHUX_DOCKER_PLATFORM:-}"
if [ -z "$PLATFORM" ]; then
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64|Linux-aarch64|Linux-arm64) PLATFORM="linux/amd64" ;;
  esac
fi
PLATFORM_ARGS=""
[ -n "$PLATFORM" ] && PLATFORM_ARGS="--platform $PLATFORM"

ensure_image() {
  if docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "[$(date +%H:%M:%S)] docker-linux-run: using image $IMAGE"
    return 0
  fi
  if [ "${SHUX_DOCKER_NO_AUTO_BUILD:-}" = "1" ]; then
    echo "docker-linux-run FAIL: missing image $IMAGE (run ./tests/docker/build-linux-dev-image.sh)" >&2
    exit 1
  fi
  echo "[$(date +%H:%M:%S)] docker-linux-run: image $IMAGE not found, building once (plain progress) ..."
  SHUX_LINUX_DEV_IMAGE="$IMAGE" SHUX_DOCKER_PLATFORM="${PLATFORM:-linux/amd64}" \
    "$ROOT/tests/docker/build-linux-dev-image.sh"
}

ensure_image

echo "[$(date +%H:%M:%S)] docker-linux-run: START workdir=$WORKDIR"

MEM="${SHUX_DOCKER_MEMORY:-8g}"
SHM="${SHUX_DOCKER_SHM:-2g}"
VOL="-v $(pwd):/src"

# 拼容器内 bash -lc 命令；SHUX_DOCKER_TIMEOUT_SEC 非空时包一层 timeout。
docker_inner_cmd() {
  local workdir="$1"
  local inner="$2"
  local full
  full="cd $(printf '%q' "$workdir") && ${inner}"
  if [ -n "${SHUX_DOCKER_TIMEOUT_SEC:-}" ]; then
    echo "[$(date +%H:%M:%S)] docker-linux-run: timeout=${SHUX_DOCKER_TIMEOUT_SEC}s" >&2
    printf 'timeout --signal=TERM --kill-after=30 %ss bash -lc %q' "$SHUX_DOCKER_TIMEOUT_SEC" "$full"
  else
    printf '%s' "$full"
  fi
}

run_ephemeral() {
  # -i：保持 stdout 连接；容器内长任务有心跳（preflight --asm-e）
  local inner
  inner="$(docker_inner_cmd "$WORKDIR" "$CMD")"
  # shellcheck disable=SC2086
  docker run --rm -i $PLATFORM_ARGS \
    --memory="$MEM" --shm-size="$SHM" \
    $VOL -w "$WORKDIR" \
    -e SHUX_CI_DOCKER=1 \
    "$IMAGE" \
    bash -lc "$inner"
}

run_persistent() {
  local cname="${SHUX_DOCKER_PERSIST_NAME:-shux-linux-dev-run}"
  if ! docker ps -a --format '{{.Names}}' | grep -qx "$cname"; then
    echo "docker-linux-run: create persistent container $cname"
    # shellcheck disable=SC2086
    docker create $PLATFORM_ARGS --name "$cname" \
      --memory="$MEM" --shm-size="$SHM" \
      $VOL -w /src \
      -e SHUX_CI_DOCKER=1 \
      "$IMAGE" sleep infinity >/dev/null
  fi
  docker start "$cname" >/dev/null 2>&1 || true
  local inner
  inner="$(docker_inner_cmd "$WORKDIR" "$CMD")"
  docker exec -i "$cname" bash -lc "$inner"
}

if [ "${SHUX_DOCKER_PERSIST:-}" = "1" ]; then
  run_persistent
else
  run_ephemeral
fi
