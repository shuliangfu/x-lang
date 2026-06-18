#!/usr/bin/env bash
# 本地用 Docker 复现 CI：Alpine/Debian（docker-distro）、Ubuntu（linux job 同环境）
# 用法：在仓库根目录执行 ./scripts/docker-ci-local.sh [alpine|debian|ubuntu|ubuntu-gates|ubuntu-zc-gates|ubuntu-wpo-s2|...]
# Mac 上跑 ubuntu / ubuntu-gates 即可复现 CI 的 linux (Ubuntu) job；先本地通过再推 CI。

set -e
cd "$(dirname "$0")/.."
SRC="$(pwd)"
IMAGE="${1:-all}"

run_one() {
  local img="$1"
  echo "===== Docker CI: $img ====="
  docker run --rm -e CI=1 -e SHU_CI_DOCKER=1 -e SHU_CC_EXTRA="-std=gnu11" \
    -v "$SRC:/src" -w /src \
    "$img" \
    sh -c '
      if command -v apk >/dev/null 2>&1; then
        apk add --no-cache build-base bash diffutils python3 gawk linux-headers liburing-dev zlib-dev brotli-dev perl
      else
        apt-get update -qq && apt-get install -y -qq build-essential bash diffutils python3 liburing-dev zlib1g-dev libbrotli-dev perl
      fi &&
      export SHU_CC_EXTRA="-std=gnu11" &&
      make -C compiler clean &&
      make -C compiler OPT=1 all &&
      make -C compiler test_c &&
      make -C compiler test_su &&
      chmod +x tests/run-bootstrap-bstrict-ci.sh tests/run-freestanding-hello.sh &&
      ./tests/run-bootstrap-bstrict-ci.sh &&
      make -C compiler bootstrap-verify &&
      ./tests/run-freestanding-hello.sh
    '
}

# P5 + refresh shu_asm（Mac 复现 Linux SU 路径 region/linear/asm）
run_ubuntu_gates() {
  echo "===== Docker CI: ubuntu-gates (P5 + refresh shu_asm, linux/amd64) ====="
  docker run --rm --platform linux/amd64 -e CI=1 -e SHU_CC_EXTRA="-std=gnu11" \
    -v "$SRC:/src" -w /src \
    ubuntu:22.04 \
    sh -c '
      apt-get update -qq && apt-get install -y -qq build-essential bash perl python3 liburing-dev zlib1g-dev libbrotli-dev lsof file pkg-config >/dev/null &&
      export SHU_CC_EXTRA="-std=gnu11" &&
      make -C compiler clean &&
      make -C compiler OPT=1 all &&
      make -C compiler bootstrap-driver-seed &&
      cd compiler && SHU=./shu ./scripts/build_shu_asm.sh &&
      cd .. &&
      chmod +x tests/run-pre-push-p5.sh tests/run-refresh-shu-asm-gate.sh tests/run-f32-xmm-gates.sh tests/lib/dod-native-exe.sh &&
      ./tests/run-pre-push-p5.sh
    '
}

# ZC-1/2/3/4/5 统一门禁（Linux shu_asm 运行时实锤；比 ubuntu-gates 轻）
run_ubuntu_zc_gates() {
  echo "===== Docker CI: ubuntu-zc-gates (ZC-1/2/3/4/5 + shu_asm, linux/amd64) ====="
  docker run --rm --platform linux/amd64 -e CI=1 -e SHU_CC_EXTRA="-std=gnu11" \
    -v "$SRC:/src" -w /src \
    ubuntu:22.04 \
    sh -c '
      apt-get update -qq && apt-get install -y -qq build-essential bash perl python3 liburing-dev zlib1g-dev libbrotli-dev strace lsof file pkg-config >/dev/null &&
      export SHU_CC_EXTRA="-std=gnu11" &&
      make -C compiler clean &&
      make -C compiler OPT=1 all &&
      make -C compiler bootstrap-driver-seed &&
      cd compiler && SHU=./shu ./scripts/build_shu_asm.sh &&
      cd .. &&
      test -x ./compiler/shu_asm || { echo "ubuntu-zc-gates: shu_asm missing after build" >&2; exit 1; } &&
      make -C compiler ../std/process/process.o ../std/io/io.o ../std/fs/fs.o ../std/net/net.o ../std/heap/heap.o ../std/string/string.o -q 2>/dev/null \
        || make -C compiler ../std/process/process.o ../std/io/io.o ../std/fs/fs.o ../std/net/net.o ../std/heap/heap.o ../std/string/string.o &&
      chmod +x tests/run-zc-gates.sh &&
      SHU=./compiler/shu_asm ./tests/run-zc-gates.sh
    '
}

# WPO-S2 asm fold/mono + perf compile-only + WPO-S3 disasm gate
run_ubuntu_wpo_s2() {
  echo "===== Docker CI: ubuntu-wpo-s2 (bootstrap + build_shu_asm + wpo-s2 smoke/perf, linux/amd64) ====="
  docker run --rm --platform linux/amd64 -e CI=1 -e SHU_CC_EXTRA="-std=gnu11" \
    -v "$SRC:/src" -w /src \
    ubuntu:22.04 \
    sh -c '
      apt-get update -qq && apt-get install -y -qq build-essential bash perl python3 liburing-dev zlib1g-dev libbrotli-dev &&
      export SHU_CC_EXTRA="-std=gnu11" &&
      make -C compiler clean &&
      make -C compiler OPT=1 all &&
      make -C compiler bootstrap-driver-seed &&
      cd compiler && SHU=./shu ./scripts/build_shu_asm.sh &&
      cd .. &&
      chmod +x tests/run-wpo-s2.sh tests/run-perf-wpo-s2.sh tests/lib/wpo-main-disasm.sh tests/run-wpo-s3-gate.sh tests/lib/wpo-s3-disasm.sh tests/run-wpo-s3-cross-bisect.sh &&
      ./tests/run-wpo-s2.sh &&
      SHU=./compiler/shu_asm SHU_WPO_S2_COMPILE_ONLY=1 ./tests/run-perf-wpo-s2.sh --bench &&
      SHU=./compiler/shu_asm ./tests/run-wpo-s3-gate.sh &&
      SHU=./compiler/shu_asm ./tests/run-wpo-s3-cross-bisect.sh
    '
}

# WPO-S3 asm 门禁（bootstrap + build_shu_asm + await/yield 实锤；比 ubuntu-wpo-s2 轻，无 perf）
run_ubuntu_wpo_s3_full() {
  echo "===== Docker CI: ubuntu-wpo-s3-full (build_shu_asm + WPO-S3 await/yield, linux/amd64) ====="
  docker run --rm --platform linux/amd64 -e CI=1 -e SHU_CC_EXTRA="-std=gnu11" \
    -v "$SRC:/src" -w /src \
    ubuntu:22.04 \
    sh -c '
      apt-get update -qq && apt-get install -y -qq build-essential bash perl python3 liburing-dev zlib1g-dev libbrotli-dev binutils >/dev/null &&
      export SHU_CC_EXTRA="-std=gnu11" &&
      make -C compiler clean &&
      make -C compiler OPT=1 all &&
      make -C compiler bootstrap-driver-seed &&
      cd compiler && SHU=./shu ./scripts/build_shu_asm.sh &&
      cd .. &&
      make -C compiler ../std/async/scheduler.o &&
      chmod +x tests/run-wpo-s3-gate.sh tests/lib/wpo-s3-disasm.sh tests/lib/wpo-main-disasm.sh &&
      SHU=./compiler/shu_asm ./tests/run-wpo-s3-gate.sh
    '
}

# WPO-S3 asm disasm 快速门禁（需已有 Linux shu_asm；不重建 bootstrap）
run_ubuntu_wpo_s3() {
  echo "===== Docker CI: ubuntu-wpo-s3 (asm disasm gate only, linux/amd64) ====="
  docker run --rm --platform linux/amd64 -e CI=1 \
    -v "$SRC:/src" -w /src \
    ubuntu:22.04 \
    sh -c '
      apt-get update -qq && apt-get install -y -qq build-essential binutils liburing-dev >/dev/null &&
      test -x ./compiler/shu_asm || test -x ./compiler/shu_asm.experimental || { echo "missing shu_asm; run ubuntu-wpo-s3-full first" >&2; exit 1; } &&
      if [ ! -x ./compiler/shu_asm ] && [ -x ./compiler/shu_asm.experimental ]; then cp ./compiler/shu_asm.experimental ./compiler/shu_asm; fi &&
      make -C compiler ../std/async/scheduler.o -q 2>/dev/null || make -C compiler ../std/async/scheduler.o &&
      chmod +x tests/run-wpo-s3-gate.sh tests/lib/wpo-s3-disasm.sh tests/lib/wpo-main-disasm.sh tests/run-wpo-s3-cross-bisect.sh &&
      SHU=./compiler/shu_asm ./tests/run-wpo-s3-gate.sh &&
      SHU=./compiler/shu_asm ./tests/run-wpo-s3-cross-bisect.sh
    '
}

# WPO-S4 PGO-Lite 门禁（bootstrap + build_shu_asm + .text.hot/unlikely + call-depth emit）
run_ubuntu_wpo_s4_full() {
  echo "===== Docker CI: ubuntu-wpo-s4-full (build_shu_asm + WPO-S4 PGO-Lite, linux/amd64) ====="
  docker run --rm --platform linux/amd64 -e CI=1 -e SHU_CC_EXTRA="-std=gnu11" \
    -v "$SRC:/src" -w /src \
    ubuntu:22.04 \
    sh -c '
      apt-get update -qq && apt-get install -y -qq build-essential bash perl python3 liburing-dev zlib1g-dev libbrotli-dev binutils >/dev/null &&
      export SHU_CC_EXTRA="-std=gnu11" &&
      make -C compiler clean &&
      make -C compiler OPT=1 all &&
      make -C compiler bootstrap-driver-seed &&
      cd compiler && SHU_ASM_SKIP_STRICT_SMOKE=1 SHU=./shu ./scripts/build_shu_asm.sh &&
      cd .. &&
      chmod +x tests/run-wpo-s4-gate.sh tests/run-perf-wpo-dce-shu-asm-text.sh tests/lib/wpo-ab-proxy.sh &&
      SHU_WPO_PGO_HOT=1 SHU=./compiler/shu_asm ./tests/run-wpo-s4-gate.sh
    '
}

# WPO-S4 快速门禁（需已有 Linux shu_asm；不重建 bootstrap）
run_ubuntu_wpo_s4() {
  echo "===== Docker CI: ubuntu-wpo-s4 (PGO-Lite gate only, linux/amd64) ====="
  docker run --rm --platform linux/amd64 -e CI=1 \
    -v "$SRC:/src" -w /src \
    ubuntu:22.04 \
    sh -c '
      apt-get update -qq && apt-get install -y -qq binutils liburing-dev >/dev/null &&
      test -x ./compiler/shu_asm || { echo "missing shu_asm; run ubuntu-wpo-s4-full first" >&2; exit 1; } &&
      chmod +x tests/run-wpo-s4-gate.sh tests/run-perf-wpo-dce-shu-asm-text.sh tests/lib/wpo-ab-proxy.sh &&
      SHU_WPO_PGO_HOT=1 SHU=./compiler/shu_asm ./tests/run-wpo-s4-gate.sh
    '
}

# ZC-1 Provided Buffers perf + 全栈 ZC gates（Linux io_uring；Mac Docker linuxkit 无 io_uring → ZC-1 SKIP）
# WPO stretch -3%（bootstrap-driver-bstrict + build_asm 齐全后）
run_ubuntu_wpo_stretch() {
  echo "===== Docker CI: ubuntu-wpo-stretch (bstrict + WPO 3% + B-CMP-ASM, linux/amd64) ====="
  docker run --rm --platform linux/amd64 -e CI=1 -e SHU_CI_DOCKER=1 -e SHU_CC_EXTRA="-std=gnu11" \
    -v "$SRC:/src" -w /src \
    ubuntu:22.04 \
    sh -c '
      apt-get update -qq && apt-get install -y -qq build-essential bash perl python3 liburing-dev zlib1g-dev libbrotli-dev lsof file pkg-config binutils >/dev/null &&
      export SHU_CC_EXTRA="-std=gnu11" &&
      ulimit -s 65532 2>/dev/null || true &&
      make -C compiler OPT=1 all &&
      test -x compiler/shu_asm || make -C compiler bootstrap-driver-bstrict &&
      chmod +x tests/run-wpo-full-chain-gate.sh tests/run-bcmp-gate.sh tests/run-wpo-strict-glue-text-gate.sh &&
      ./tests/run-wpo-full-chain-gate.sh &&
      chmod +x tests/run-wpo-stretch-gate.sh tests/run-bcmp-gate.sh &&
      SHU=./compiler/shu_asm SHU_PERF_FAIL_ON_WPO_SHU_ASM_TEXT=1 ./tests/run-perf-wpo-dce-shu-asm-text.sh &&
      ./tests/run-wpo-stretch-gate.sh &&
      ./tests/run-bcmp-gate.sh &&
      SHU_PERF_BCMP_ASM=1 ./tests/run-bcmp-gate.sh || true
    '
}

run_ubuntu_net_zc1() {
  echo "===== Docker CI: ubuntu-net-zc1 (run-zc-gates --perf, linux/amd64) ====="
  docker run --rm --platform linux/amd64 -e CI=1 -e SHU_CC_EXTRA="-std=gnu11" \
    -v "$SRC:/src" -w /src \
    ubuntu:22.04 \
    sh -c '
      apt-get update -qq && apt-get install -y -qq build-essential bash perl liburing-dev zlib1g-dev libbrotli-dev python3 lsof strace file pkg-config >/dev/null &&
      export SHU_CC_EXTRA="-std=gnu11" &&
      make -C compiler clean &&
      make -C compiler OPT=1 all &&
      make -C compiler bootstrap-driver-seed &&
      cd compiler && SHU=./shu ./scripts/build_shu_asm.sh &&
      cd .. &&
      test -x ./compiler/shu_asm || { echo "ubuntu-net-zc1: shu_asm missing after build" >&2; exit 1; } &&
      make -C compiler ../std/net/net.o ../std/thread/thread.o ../std/io/io.o ../std/fs/fs.o ../std/process/process.o -q 2>/dev/null \
        || make -C compiler ../std/net/net.o ../std/thread/thread.o ../std/io/io.o ../std/fs/fs.o ../std/process/process.o &&
      chmod +x tests/run-zc-gates.sh &&
      SHU=./compiler/shu_asm ./tests/run-zc-gates.sh --perf
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
    run_one ubuntu:22.04
    ;;
  ubuntu-gates)
    run_ubuntu_gates
    ;;
  ubuntu-zc-gates)
    run_ubuntu_zc_gates
    ;;
  ubuntu-wpo-s2)
    run_ubuntu_wpo_s2
    ;;
  ubuntu-wpo-s3)
    run_ubuntu_wpo_s3
    ;;
  ubuntu-wpo-s3-full)
    run_ubuntu_wpo_s3_full
    ;;
  ubuntu-wpo-s4)
    run_ubuntu_wpo_s4
    ;;
  ubuntu-wpo-s4-full)
    run_ubuntu_wpo_s4_full
    ;;
  ubuntu-wpo-stretch)
    run_ubuntu_wpo_stretch
    ;;
  ubuntu-net-zc1)
    run_ubuntu_net_zc1
    ;;
  all|"")
    run_one alpine:3.23
    run_one debian:bookworm-slim
    run_one ubuntu:22.04
    ;;
  *)
    echo "Usage: $0 [alpine|debian|ubuntu|ubuntu-gates|ubuntu-zc-gates|ubuntu-wpo-s2|ubuntu-wpo-s3|ubuntu-wpo-s3-full|ubuntu-wpo-s4|ubuntu-wpo-s4-full|ubuntu-wpo-stretch|ubuntu-net-zc1|all]" >&2
    exit 1
    ;;
esac

echo "===== Docker CI local: $IMAGE OK ====="
