#!/bin/sh
# shux-build.sh — 统一构建入口（G-05: 替代 Makefile）
# 用法: ./shux-build.sh <target>
# 目标: all, clean, test, test_c, test_sx, kernel, kernel-*, bootstrap-*
#
# build.sx + build_tool 处理编译器构建；本脚本处理测试与内核 gate。
# 最终目标：Makefile 可删除，本脚本 + build.sx 为唯一入口。

set -e
cd "$(dirname "$0")"

TARGET="${1:-all}"

case "$TARGET" in
  # === 编译器构建（委托 build_tool）===
  all|build)
    cd compiler && ./build_tool ./shux && cd ..
    ;;
  clean)
    make -C compiler clean
    ;;
  
  # === 编译器测试 ===
  test)
    make -C compiler test
    ;;
  test_c)
    make -C compiler test_c
    ;;
  test_sx)
    make -C compiler test_sx
    ;;
  bootstrap-lexer)
    make -C compiler bootstrap-lexer
    ;;
  bootstrap-token)
    make -C compiler bootstrap-token
    ;;
  
  # === 内核 QEMU 测试 ===
  kernel)
    sh tests/kernel/run-kernel-gate.sh
    ;;
  kernel-build)
    : ${SX:?Usage: shux-build.sh kernel-build SX=file.sx [ELF=out.elf]}
    : ${ELF:=kernel.elf}
    sh tests/kernel/build-kernel.sh "$SX" "$ELF"
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
  
  # === 自举前必须清单 gate ===
  checklist)
    SHUX=./compiler/shux-c bash tests/run-codegen-semantic-debt-gate.sh
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
  
  # === 帮助 ===
  help|--help|-h)
    echo "shux-build.sh — 统一构建入口"
    echo ""
    echo "编译器:"
    echo "  all / build      构建编译器 (build_tool)"
    echo "  clean            清理构建产物"
    echo "  test             全量测试"
    echo "  test_c           C 前端测试"
    echo "  test_sx          .sx 自举测试"
    echo ""
    echo "内核 (QEMU):"
    echo "  kernel           跑全部 30 个 QEMU 内核测试"
    echo "  kernel-build SX= 构建单个内核 ELF"
    echo "  kernel-check     ELF 静态检查"
    echo "  kernel-longmode  x86_64 长模式启动"
    echo "  kernel-multiboot2 Multiboot2 头验证"
    echo "  kernel-uefi-app  UEFI PE32+ 应用"
    echo "  kernel-ist       IST 结构验证"
    echo ""
    echo "自举:"
    echo "  checklist        §9.1 语义债 gate"
    echo "  struct-layout    X5 结构体布局断言"
    echo "  ffi-deep         X8 FFI 深递归"
    echo "  compiler-rt-audit G-03-rt compiler-rt 审计"
    ;;
  *)
    echo "Unknown target: $TARGET (try: ./shux-build.sh help)"
    exit 1
    ;;
esac
