# Shux 顶层 Makefile
#
# 【G-05】日常编译器构建优先委托 ./shux-build.sh（→ build_tool → g05_build_shux_asm.sh）。
# 本文件其余目标：测试 / 内核 gate / 冷启动细节的薄包装。
# compiler/Makefile 仍为实现层（relink 依赖图、CI 历史目标），非用户日常入口。

.PHONY: all build shux shux-asm full clean test test_c test_x bootstrap-lexer bootstrap-token \
	help build-tool first-time c08

# 默认目标：G-05 统一入口（build_tool → make shux_asm 金标准）
all build shux:
	./shux-build.sh build

shux-asm asm:
	./shux-build.sh asm

full bstrict:
	./shux-build.sh full

build-tool:
	./shux-build.sh build-tool

first-time:
	./shux-build.sh first-time

c08:
	./shux-build.sh c08

help:
	./shux-build.sh help

# 清理构建产物
clean:
	./shux-build.sh clean

# 测试（仍走 compiler/Makefile 兜底）
test:
	./shux-build.sh test

test_c:
	./shux-build.sh test_c

test_x:
	./shux-build.sh test_x

# 自举：用当前 shux 编译 .x 词法分析器并运行
bootstrap-lexer:
	./shux-build.sh bootstrap-lexer

bootstrap-token:
	./shux-build.sh bootstrap-token

# 内核：构建并 QEMU 测试所有 tests/kernel/*.x 内核
kernel:
	./shux-build.sh kernel

# 内核构建链 K9：一键出 multiboot1 ELF 镜像
# 用法: make kernel-build X=tests/kernel/timer_isr.x ELF=/tmp/kernel.elf
kernel-build:
	@test -n "$(X)" || (echo "Usage: make kernel-build X=file.x [ELF=out.elf]" && exit 1)
	X="$(X)" ELF="$(ELF)" ./shux-build.sh kernel-build

# G3+G4: 静态检查 + 纯净度 gate
kernel-check:
	./shux-build.sh kernel-check

# G7: 可复现构建 gate
kernel-repro:
	./shux-build.sh kernel-repro

# G1: host 单测 gate
kernel-host-test:
	./shux-build.sh kernel-host-test

# L4: 栈用量分析 gate
kernel-stack-check:
	./shux-build.sh kernel-stack-check

# K11/L10: 64-bit kernel code model gate
kernel64-check:
	./shux-build.sh kernel64-check

# G5: QEMU SMP gate
kernel-smp:
	./shux-build.sh kernel-smp

# L6: Send/Sync contract gate
kernel-send-sync:
	./shux-build.sh kernel-send-sync

# A3: cross-architecture gate
kernel-cross-arch:
	./shux-build.sh kernel-cross-arch

# A4: UEFI boot path gate
kernel-uefi:
	./shux-build.sh kernel-uefi

# x86_64 long mode boot gate (32-bit -> 64-bit transition in QEMU)
kernel-longmode:
	./shux-build.sh kernel-longmode

# Multiboot2 header gate (end tag + alignment, T1 static)
kernel-multiboot2:
	./shux-build.sh kernel-multiboot2

# UEFI application gate (PE32+ skeleton with efi_main)
kernel-uefi-app:
	./shux-build.sh kernel-uefi-app

# IST (Interrupt Stack Table) gate (TSS64 + IDTGate64 structs)
kernel-ist:
	./shux-build.sh kernel-ist
