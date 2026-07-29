#!/bin/sh
# xlang-build.sh — 仓库根统一构建入口体（G-05 · G.7 权威实现）
#
# 对外首选名：./xbuild（薄转调本脚本；禁止在 xbuild 再写目标体）。
#
# 分层：
#   1) 日常编译器：build.x + compiler/build_tool
#      → scripts/g05_build_xlang_asm.sh → g05 relink（产品 0-make）
#   2) 测试 / 内核 / gate：委托 compiler/scripts 或 tests/*.sh
#   3) compiler/Makefile：冷启动依赖图 / 对象清单 — 实现层兜底（至 11.3）
#   4) 根 Makefile：help-only（11.0.4）；兼容转发 ./xbuild，勿加厚
#
# 产品入口 0× make -C（build-tool/clean/test*/bootstrap-* 均 shell 权威）。
#
# 用法: ./xbuild <target>   或   ./xlang-build.sh <target>
# 例:   ./xbuild build
#       ./xbuild xlang-asm
#       XLANG_BUILD_TOOL_FULL=1 ./xbuild full

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

# Residual make hub for CI / cold-start / leaf .o (wave730 · wave733 G.7).
# Outer workflows/docker must call ./xbuild — never raw `make -C compiler`.
# G.7 single body: tests/lib/compiler-make.sh (same as tests xlang_compiler_make).
# Dependency graph still lives in compiler/Makefile until 11.3.
# PLATFORM: SHARED
run_compiler_make() {
  bash tests/lib/compiler-make.sh "$@"
}

# g05 product chain — direct shell (wave733 · 11.1.6 first slice).
# No Makefile: prepare/ensure/env/link already live under compiler/scripts/g05_*.sh.
# PLATFORM: SHARED
run_g05_ensure() {
  (cd compiler && sh scripts/g05_ensure_relink_prereqs.sh)
}
run_g05_link_env() {
  (cd compiler && sh scripts/g05_relink_env.sh)
}
run_g05_prepare_and_relink() {
  # $1 = G05_SYNC_ASM (0 = xlang only; 1 = also sync xlang_asm)
  (cd compiler && G05_SYNC_ASM="${1:-1}" sh scripts/g05_prepare_and_relink.sh)
}

case "$TARGET" in
  # === 编译器（G-05 日常）===
  all|build|xlang)
    # 默认路径：build_tool → g05 relink；见 build_tool_libc_bridge
    # NOTE: product `all` ≠ Makefile `all`. CI host-cc/seed path = compiler-all.
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

  # === g05 产品链一等目标（wave733 · 11.1.6；零 make）===
  ensure|g05-ensure|g05-ensure-relink-prereqs)
    run_g05_ensure
    ;;
  link-env|g05-export|g05-export-relink)
    run_g05_link_env
    ;;
  link-product|relink|relink-xlang)
    # Like `make relink-xlang`: final link only (no xlang_asm sync)
    run_g05_prepare_and_relink 0
    ;;
  link-product-asm|prepare-and-relink)
    # Like `make xlang_asm`: ensure+link+sync xlang_asm (no build_tool rebuild)
    run_g05_prepare_and_relink 1
    ;;

  # === CI / 冷启动 / 叶 .o（wave730：外层 0× make -C；图仍 Makefile 至 11.3）===
  compiler-all|ci-all)
    # Historical CI: `make -C compiler OPT=1 all` (host-cc xlang + xlang-c / seed).
    # Distinct from product `./xbuild all` (g05 relink). OPT defaults to 1.
    run_compiler_make OPT="${OPT:-1}" all
    ;;
  bootstrap-driver-seed)
    # Cold-start orchestration still via Makefile prereqs → bootstrap_driver_seed.sh
    run_compiler_make bootstrap-driver-seed
    ;;
  compiler-make)
    # Passthrough for residual leaves: std .o, CFLAGS=…, ASan rebuild, etc.
    # Usage: ./xbuild compiler-make <make-args...>
    shift
    if [ "$#" -eq 0 ]; then
      echo "Usage: ./xbuild compiler-make <make-args...>" >&2
      echo "  e.g. ./xbuild compiler-make ../std/io/io.o" >&2
      echo "       ./xbuild compiler-make all CFLAGS='-O0 -g'" >&2
      exit 1
    fi
    run_compiler_make "$@"
    ;;

  # === 编译器测试（wave720：test* / bootstrap-verify 全 shell；无 make -C）===
  test)
    (cd compiler && sh scripts/run_compiler_tests.sh all)
    ;;
  test_c)
    (cd compiler && sh scripts/run_compiler_tests.sh c)
    ;;
  test_x)
    (cd compiler && sh scripts/run_compiler_tests.sh x)
    ;;
  bootstrap-lexer)
    (cd compiler && sh scripts/bootstrap_token_lexer_smoke.sh lexer)
    ;;
  bootstrap-token)
    (cd compiler && sh scripts/bootstrap_token_lexer_smoke.sh token)
    ;;
  bootstrap-verify)
    (cd compiler && sh scripts/bootstrap_verify_bstrict.sh)
    ;;
  bootstrap-driver-bstrict)
    (cd compiler && sh scripts/bootstrap_driver_bstrict.sh)
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
xbuild / xlang-build.sh — 统一构建入口（G-05 · G.7 同体）

推荐: ./xbuild <target>   （根 Makefile 仅 help→本入口）
别名: ./build.sh [target]  （wave731 · 11.4.1 薄转发本入口；默认 build）

编译器（推荐日常）:
  all / build / xlang   增量构建（build_tool → g05 relink 金标准）
  xlang-asm / asm       同上，显式 asm 子命令
  full / bstrict       全量 B-strict（XLANG_BUILD_TOOL_FULL=1）
  legacy               build_tool legacy 逐步路径
  build-tool           scripts/build_tool.sh（pinned seeds；无 make）
  first-time           build_tool.sh + 日常构建
  clean                scripts/clean_compiler.sh（无 make）

g05 产品链（wave733 · 11.1.6；零 make；已有 .o 时直链）:
  ensure / g05-ensure           g05_ensure_relink_prereqs.sh
  link-env / g05-export         g05_relink_env.sh（打印/导出链接清单）
  link-product / relink         g05_prepare_and_relink（G05_SYNC_ASM=0）
  link-product-asm              g05_prepare_and_relink（G05_SYNC_ASM=1 → xlang_asm）

CI / 冷启动（外层 0× make -C；图仍 Makefile 至 11.3）:
  compiler-all / ci-all      make OPT=1 all（host-cc/seed；≠ 产品 all）
  bootstrap-driver-seed      冷启动（prereq 图 → shell 编排）
  compiler-make <args…>      残余叶透传（std .o / CFLAGS / ASan）
                             体 = tests/lib/compiler-make.sh（G.7 单 hub）

测试 / 自举:
  test / test_c / test_x     scripts/run_compiler_tests.sh
  bootstrap-token / lexer    scripts/bootstrap_token_lexer_smoke.sh
  bootstrap-driver-bstrict   scripts/bootstrap_driver_bstrict.sh
  bootstrap-verify           scripts/bootstrap_verify_bstrict.sh

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
  tests/lib/compiler-make.sh               — 残余 make -C 唯一体（tests + xbuild）
  compiler/scripts/g05_build_xlang_asm.sh  — build_tool 唯一 asm 出口
  compiler/scripts/g05_prepare_and_relink.sh — ensure+env+link 编排
  compiler/Makefile                         — 冷启动 / 叶 .o 图（至 11.3）
  根 Makefile                               — help-only；勿再加厚

日常优先:
  ./xbuild build
  cd compiler && ./build_tool ./xlang
EOF
    ;;
  *)
    echo "Unknown target: $TARGET (try: ./xbuild help)" >&2
    exit 1
    ;;
esac
