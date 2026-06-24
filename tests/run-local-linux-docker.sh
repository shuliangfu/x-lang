#!/usr/bin/env bash
# 在 Linux Docker 容器内跑全量 run-all + CI 套件（Mac 宿主无 liburing / ld -r 差异时用）。
# 用法（仓库根）：./tests/run-local-linux-docker.sh [run-all|ci-full|both]
set -euo pipefail
cd "$(dirname "$0")/.."

MODE="${1:-both}"
LOG_DIR="${SHUX_LOCAL_TEST_LOG_DIR:-/tmp/shux-local-test}"
mkdir -p "$LOG_DIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "run-local-linux-docker FAIL: docker not found" >&2
  exit 1
fi

# Apple Silicon / Linux ARM 宿主默认拉 aarch64 镜像，会误用 aarch64 汇编器编 x86_64 crt0；A-09～A-12 须 linux/amd64。
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

run_in_container() {
  local inner="$1"
  local image="${SHUX_LINUX_DEV_IMAGE:-shux-linux-dev:22.04-amd64}"
  if docker image inspect "$image" >/dev/null 2>&1; then
    # shellcheck disable=SC2086
    docker run --rm $DOCKER_PLATFORM_ARGS \
      -v "$(pwd):/src" \
      -w /src \
      -e CI=1 \
      -e SHUX_CI_DOCKER=1 \
      -e SHUX_CI_NO_SKIP=1 \
      "$image" \
      bash -lc "$inner"
    return
  fi
  echo "run-local-linux-docker: dev image $image missing; apt-get each run (build once: ./tests/docker/build-linux-dev-image.sh)" >&2
  # shellcheck disable=SC2086
  docker run --rm $DOCKER_PLATFORM_ARGS \
    -v "$(pwd):/src" \
    -w /src \
    -e CI=1 \
    -e SHUX_CI_DOCKER=1 \
    -e SHUX_CI_NO_SKIP=1 \
    ubuntu:22.04 \
    bash -lc "$inner"
}

DEPS='apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq gcc make liburing-dev zlib1g-dev libzstd-dev libbrotli-dev libsqlite3-dev curl xz-utils file python3 >/dev/null'

BUILD='find . -name "*.o" -delete 2>/dev/null || true; make -C compiler clean >/dev/null 2>&1 || true; make -C compiler -j4 all'

case "$MODE" in
  portable)
    echo "=== Docker local: run-portable-suite.sh (CI Tier P) ===" | tee "$LOG_DIR/portable.log"
    run_in_container "$DEPS && $BUILD && chmod +x tests/run-portable-suite.sh tests/run-*.sh tests/lib/*.sh 2>/dev/null || true && ./tests/run-portable-suite.sh" 2>&1 | tee -a "$LOG_DIR/portable.log"
    grep -q 'run-portable-suite OK' "$LOG_DIR/portable.log"
    echo "portable-suite OK (log: $LOG_DIR/portable.log)"
    ;;
  run-all)
    echo "=== Docker local: run-all.sh ===" | tee "$LOG_DIR/run-all.log"
    run_in_container "$DEPS && $BUILD && chmod +x tests/run-all.sh tests/run-*.sh tests/lib/*.sh 2>/dev/null || true && ./tests/run-all.sh" 2>&1 | tee -a "$LOG_DIR/run-all.log"
    grep -q 'all tests OK' "$LOG_DIR/run-all.log"
    echo "run-all OK (log: $LOG_DIR/run-all.log)"
    ;;
  ci-full)
    echo "=== Docker local: run-ci-full-suite.sh ===" | tee "$LOG_DIR/ci-full.log"
    run_in_container "$DEPS && $BUILD && chmod +x tests/run-ci-full-suite.sh tests/run-portable-suite.sh tests/run-portable-c.sh tests/run-*.sh tests/lib/*.sh 2>/dev/null || true && CI=1 SHUX_CI_NO_SKIP=1 ./tests/run-ci-full-suite.sh" 2>&1 | tee -a "$LOG_DIR/ci-full.log"
    grep -q 'ci-full-suite OK' "$LOG_DIR/ci-full.log"
    echo "ci-full-suite OK (log: $LOG_DIR/ci-full.log)"
    ;;
  both)
    "$0" run-all
    "$0" portable
    "$0" ci-full
    ;;
  *)
    echo "usage: $0 [run-all|portable|ci-full|both]" >&2
    exit 2
    ;;
esac
