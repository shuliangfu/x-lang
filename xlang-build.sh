#!/bin/sh
# xlang-build.sh — 仓库根统一构建入口（G-05）
#
# 分层：
#   1) 日常编译器：build.x + compiler/build_tool
#      → scripts/g05_build_xlang_asm.sh → g05 relink（产品 0-make）
#   2) 测试 / 内核 / gate：仍委托 compiler/Makefile 或 tests/*.sh
#   3) compiler/Makefile：冷启动依赖图 / 对象清单 — 实现层兜底
#   4) 根 Makefile：薄包装，委托本脚本（勿再直调 compiler/ 作日常入口）
#
# wave718 (11.0.3)：build-tool / clean 直调 shell 权威，不再 make -C 这两项。
#
# 用法: ./xlang-build.sh <target>
# 例:   ./xlang-build.sh build
#       ./xlang-build.sh xlang-asm
#       XLANG_BUILD_TOOL_FULL=1 ./xlang-build.sh full

set -e
cd "$(dirname "$0")"

TARGET="${1:-all}"

# G.7: scripts/build_tool.sh is the only build_tool body (Makefile thin leaf).
run_build_tool_host() {
  (cd compiler && sh scripts/build_tool.sh)
}

ensure_build_tool() {
  if [ ! -x compiler/build_tool ]; then
    echo "xlang-build: compiler/build_tool missing → scripts/build_tool.sh"
    run_build_tool_host
  fi
}

run_build_tool() {
  ensure_build_tool
  # shellcheck disable=SC2086
  (cd compiler && ./build_tool ./xlang $1)
}

case "$TARGET" in
  # === 编译器（G-05 日常）===
  all|build|xlang)
    # 默认路径：build_tool → g05 relink；见 build_tool_libc_bridge
    run_build_tool
    ;;
  xlang-asm|asm)
    # 显式 asm 子命令（与 ./build_tool ./xlang asm 相同）
    run_build_tool asm
    ;;
  full|bstrict)
    # 全量 B-strict（脚本 + refresh）；较慢；FULL 仍可能 make bstrict（非日常）
    ensure_build_tool
    (cd compiler && XLANG_BUILD_TOOL_FULL=1 ./build_tool ./xlang asm)
    ;;
  legacy)
    # 逐步 -E 路径（依赖现有 *_x.o / seed；非默认）
    run_build_tool legacy
    ;;
  build-tool)
    run_build_tool_host
    ;;
  first-time|bootstrap)
    # pinned seeds → build_tool shell，再日常 relink
    run_build_tool_host
    run_build_tool
    ;;
  clean)
    # G.7: scripts/clean_compiler.sh（Makefile clean 同调）
    (cd compiler && sh scripts/clean_compiler.sh)
    ;;

  # === 编译器测试（Makefile 兜底 — 仍 make：依赖图 + 历史目标）===
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
    : "${X:?Usage: xlang-build.sh kernel-build X=file.x [ELF=out.elf]}"
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
    XLANG=./compiler/xlang bash tests/run-codegen-semantic-debt-gate.sh
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
xlang-build.sh — 统一构建入口（G-05）

编译器（推荐日常）:
  all / build / xlang   增量构建（build_tool → make xlang_asm / relink 金标准）
  xlang-asm / asm       同上，显式 asm 子命令
  full / bstrict       全量 B-strict（XLANG_BUILD_TOOL_FULL=1）
  legacy               build_tool legacy 逐步路径
  build-tool           scripts/build_tool.sh（pinned seeds；无 make）
  first-time           build_tool.sh + 日常构建
  clean                scripts/clean_compiler.sh（无 make）

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
  XLANG_BUILD_TOOL_FULL=1   full 目标走 bootstrap-driver-bstrict
  XLANG_G05_LEGACY_SMOKE=1  c08 gate 额外跑 ./build_tool ./xlang legacy（默认跳过）

实现层（用户勿直接依赖）:
  compiler/scripts/g05_build_xlang_asm.sh  — build_tool 唯一 asm 出口
  compiler/Makefile                         — relink 依赖图 / 冷启动

日常优先本脚本或:
  cd compiler && ./build_tool ./xlang
EOF
    ;;
  *)
    echo "Unknown target: $TARGET (try: ./xlang-build.sh help)" >&2
    exit 1
    ;;
esac
