#!/bin/sh
# shux-build.sh — 统一构建入口（G-05: 替代 Makefile）
# 用法: ./shux-build.sh <target>
# 目标: all, clean, test, test_c, test_x, kernel, kernel-*, bootstrap-*
#
# build.x + build_tool 处理编译器构建；本脚本处理测试与内核 gate。
# 最终目标：Makefile 可删除，本脚本 + build.x 为唯一入口。

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
  test_x)
    make -C compiler test_x
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
    : ${X:?Usage: shux-build.sh kernel-build X=file.x [ELF=out.elf]}
    : ${ELF:=kernel.elf}
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
    echo "  test_x          .x 自举测试"
    echo ""
    echo "内核 (QEMU):"
    echo "  kernel           跑全部 30 个 QEMU 内核测试"
    echo "  kernel-build X= 构建单个内核 ELF"
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

  # === Windows 编译（MinGW gcc + win32_compat）===
  win-build)
    cd compiler
    # 编译所有 .o（用 MinGW gcc）
    for f in src/main.c src/runtime.c src/diag.c src/driver/fmt_check_cmd.c src/preprocess.c src/lexer/lexer.c src/ast/ast.c src/parser/parser.c src/typeck/typeck.c src/codegen/codegen.c src/async/async_liveness.c src/async/async_cps_codegen.c src/lsp/lsp_codegen_extern.c src/lsp/lsp_diag.c src/lsp/lsp_diag_pipeline_sizes.c src/runtime_driver_abi.c src/runtime_driver_diagnostic.c src/runtime_c_import.c src/runtime_abi.c src/runtime_io_abi.c src/runtime_proc_abi.c src/runtime_link_abi.c src/runtime_pipeline_abi.c src/runtime_pipeline_abi_shux_c_stubs.c src/runtime_driver_strict_glue_stubs.c src/lexer/cfg_eval_bootstrap_stub.c src/codegen/codegen_pipeline_stubs.c; do
      gcc -Wall -Wextra -I. -Iinclude -Isrc -c -o ${f%.c}.o $f 2>/dev/null
    done
    gcc -c -o _stubs_driver.o _stubs_driver.c -I. -Iinclude -Isrc 2>/dev/null
    gcc -c -o win32_pipeline_stubs.o src/win32_pipeline_stubs.c -I. -Iinclude -Isrc 2>/dev/null
    # 链接
    gcc -Wl,--allow-multiple-definition -o shux-c.exe src/main.o src/runtime.o src/diag.o src/driver/fmt_check_cmd.o src/preprocess_legacy.o src/lexer/lexer.o src/ast/ast.o src/parser/parser.o src/typeck/typeck.o src/codegen/codegen.o src/async/async_liveness.o src/async/async_cps_codegen.o src/lsp/lsp_codegen_extern.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_c_import.o src/runtime_abi.o src/runtime_io_abi.o src/runtime_proc_abi.o src/runtime_link_abi.o src/runtime_pipeline_abi.o src/runtime_pipeline_abi_shux_c_stubs.o src/runtime_driver_strict_glue_stubs.o _stubs_driver.o src/lexer/cfg_eval_bootstrap_stub.o src/codegen/codegen_pipeline_stubs.o win32_pipeline_stubs.o -lpthread
    echo "Windows shux-c.exe built"
    cd ..
    ;;
