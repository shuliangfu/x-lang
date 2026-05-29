#!/usr/bin/env bash
# 本地用 Docker 复现 CI：Alpine/Debian（docker-distro）、Ubuntu（linux job 同环境）
# 用法：在仓库根目录执行 ./scripts/docker-ci-local.sh [alpine|debian|ubuntu|all]
# Mac 上跑 ubuntu 即可复现 CI 的 linux (Ubuntu) job；先本地通过再推 CI。

set -e
cd "$(dirname "$0")/.."
SRC="$(pwd)"
IMAGE="${1:-all}"

run_one() {
  local img="$1"
  echo "===== Docker CI: $img ====="
  docker run --rm -e CI=1 -e SHU_CC_EXTRA="-std=gnu11" \
    -v "$SRC:/src" -w /src \
    "$img" \
    sh -c '
      if command -v apk >/dev/null 2>&1; then
        apk add --no-cache build-base bash diffutils python3 gawk linux-headers liburing-dev zlib-dev brotli-dev
      else
        apt-get update -qq && apt-get install -y -qq build-essential bash diffutils python3 liburing-dev zlib1g-dev libbrotli-dev
      fi &&
      export SHU_CC_EXTRA="-std=gnu11" &&
      make -C compiler clean &&
      make -C compiler OPT=1 all &&
      make -C compiler test_c &&
      make -C compiler test_su &&
      chmod +x tests/run-bootstrap-bstrict-ci.sh &&
      ./tests/run-bootstrap-bstrict-ci.sh &&
      make -C compiler bootstrap-verify
    '
}

case "$IMAGE" in
  alpine)
    run_one alpine:3.23
    ;;
  debian)
    run_one debian:bookworm-slim
    ;;
  ubuntu)
    # 与 CI linux job (ubuntu-22.04 / ubuntu-latest) 同环境，Mac 上可测
    run_one ubuntu:22.04
    ;;
  all|"")
    run_one alpine:3.23
    run_one debian:bookworm-slim
    run_one ubuntu:22.04
    ;;
  *)
    echo "Usage: $0 [alpine|debian|ubuntu|all]" >&2
    exit 1
    ;;
esac

echo "===== Docker CI local: all selected jobs OK ====="
