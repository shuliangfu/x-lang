#!/bin/sh
# shux-build.sh — 仓库根统一构建入口（G-05）
#
# 分层：
#   1) 日常编译器：build.x + compiler/build_tool（默认 = make shux_asm / relink 金标准）
#   2) 测试 / 内核 / gate：仍委托 compiler/Makefile 或 tests/*.sh
#   3) Makefile：冷启动、CI 历史目标、兜底；非日常首选
#
# 用法: ./shux-build.sh <target>
# 例:   ./shux-build.sh build
#       ./shux-build.sh shux-asm
#       SHUX_BUILD_TOOL_FULL=1 ./shux-build.sh full

set -e
cd "$(dirname "$0")"

TARGET="${1:-all}"

ensure_build_tool() {
  if [ ! -x compiler/build_tool ]; then
    echo "shux-build: compiler/build_tool missing → make -C compiler build-tool"
    make -C compiler build-tool
  fi
}

run_build_tool() {
  ensure_build_tool
  # shellcheck disable=SC2086
  (cd compiler && ./build_tool ./shux $1)
}

case "$TARGET" in
  # === 编译器（G-05 日常）===
  all|build|shux)
    # 默认路径：make shux_asm（relink 定稿）；见 build_tool_libc_bridge.c
    run_build_tool
    ;;
  shux-asm|asm)
    # 显式 asm 子命令（与 ./build_tool ./shux asm 相同）
    run_build_tool asm
    ;;
  full|bstrict)
    # 全量 B-strict（脚本 + refresh）；较慢
    ensure_build_tool
    (cd compiler && SHUX_BUILD_TOOL_FULL=1 ./build_tool ./shux asm)
    ;;
  legacy)
    # 逐步 -E 路径（依赖现有 *_x.o / seed；非默认）
    run_build_tool legacy
    ;;
  build-tool)
    make -C compiler build-tool
    ;;
  first-time|bootstrap)
    # 冷启动：pinned seeds → build_tool，再日常 relink
    make -C compiler build-tool
    run_build_tool
    ;;
  clean)
    make -C compiler clean
    ;;

  # === 编译器测试（Makefile 兜底）===
  test)
    make -C compiler test
    ;;
  test_c)
    make -C compiler test_c
    ;;
  test_x)
    make -C compiler test_x
    ;;
  bootstrap-lexer)
    make -C compiler bootstrap-lexer
    ;;
  bootstrap-token)
    make -C compiler bootstrap-token
    ;;
  bootstrap-verify)
    make -C compiler bootstrap-verify
    ;;
  bootstrap-driver-bstrict)
    make -C compiler bootstrap-driver-bstrict
    ;;

  # === 内核 QEMU 测试 ===
  kernel)
    sh tests/kernel/run-kernel-gate.sh
    ;;
  kernel-build)
    : "${X:?Usage: shux-build.sh kernel-build X=file.x [ELF=out.elf]}"
    : "${ELF:=kernel.elf}"
    sh tests/kernel/build-kernel.sh "$X" "$ELF"
    ;;
  kernel-check)
    sh tests/kernel/static-check-gate.sh
    ;;
  kernel64-check)
    sh tests/kernel/kernel64-gate.sh
    ;;
  kernel-longmode)
    sh tests/kernel/longmode-gate.sh
    ;;
  kernel-multiboot2)
    sh tests/kernel/multiboot2-gate.sh
    ;;
  kernel-uefi-app)
    sh tests/kernel/uefi-app-gate.sh
    ;;
  kernel-ist)
    sh tests/kernel/ist-gate.sh
    ;;
  kernel-smp)
    sh tests/kernel/smp-gate.sh
    ;;
  kernel-send-sync)
    sh tests/kernel/send_sync_gate.sh
    ;;
  kernel-cross-arch)
    sh tests/kernel/cross-arch-gate.sh
    ;;
  kernel-uefi)
    sh tests/kernel/uefi-gate.sh
    ;;
  kernel-host-test)
    sh tests/kernel/host-test-gate.sh
    ;;
  kernel-stack-check)
    sh tests/kernel/stack-check-gate.sh
    ;;
  kernel-repro)
    sh tests/kernel/reproducible-gate.sh
    ;;

  # === 自举前 gate ===
  checklist)
    SHUX=./compiler/shux bash tests/run-codegen-semantic-debt-gate.sh
    ;;
  struct-layout)
    sh tests/run-struct-layout-assert-gate.sh
    ;;
  ffi-deep)
    sh tests/run-ffi-deep-recursion-gate.sh
    ;;
  compiler-rt-audit)
    sh tests/run-compiler-rt-audit-gate.sh
    ;;
  c08)
    sh tests/run-c08-build-x-gate.sh
    ;;

  help|--help|-h)
    cat <<'EOF'
shux-build.sh — 统一构建入口（G-05）

编译器（推荐日常）:
  all / build / shux   增量构建（build_tool → make shux_asm / relink 金标准）
  shux-asm / asm       同上，显式 asm 子命令
  full / bstrict       全量 B-strict（SHUX_BUILD_TOOL_FULL=1）
  legacy               build_tool legacy 逐步路径
  build-tool           仅重建 compiler/build_tool（pinned seeds）
  first-time           make build-tool + 日常构建
  clean                make -C compiler clean

测试 / 自举（Makefile 兜底）:
  test / test_c / test_x
  bootstrap-verify
  bootstrap-driver-bstrict

内核 (QEMU):
  kernel               全部内核 gate
  kernel-build X=      构建单个内核 ELF
  …（kernel-* 与 tests/kernel 一致）

其它 gate:
  checklist / struct-layout / ffi-deep / compiler-rt-audit / c08

环境:
  SHUX_BUILD_TOOL_FULL=1   full 目标走 bootstrap-driver-bstrict

Makefile 仍用于冷启动细节、CI 历史目标；日常优先本脚本或:
  cd compiler && ./build_tool ./shux
EOF
    ;;
  *)
    echo "Unknown target: $TARGET (try: ./shux-build.sh help)" >&2
    exit 1
    ;;
esac
