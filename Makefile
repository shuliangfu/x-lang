# Shux 顶层 Makefile
# 委托 compiler 目录构建，产出 shux；测试等目标在此统一入口

.PHONY: all clean test test_c test_sx bootstrap-lexer bootstrap-token

# 默认目标：构建编译器 shux
all:
	$(MAKE) -C compiler

# 清理构建产物
clean:
	$(MAKE) -C compiler clean

# 测试（阶段 1：词法测试；后续接入 Parser 等）
test:
	$(MAKE) -C compiler test

# 仅 C 路径测试（run-*.sh，不含 sx 自举）
test_c:
	$(MAKE) -C compiler test_c

# 仅 sx 自举测试（bootstrap-driver-seed + run-lsp + run-all-sx 全量）
test_sx:
	$(MAKE) -C compiler test_sx

# 自举：用当前 shux 编译 .sx 词法分析器并运行，验证通过则打印 bootstrap-lexer OK
bootstrap-lexer:
	$(MAKE) -C compiler bootstrap-lexer

# 自举：用当前 shux 编译 token.sx 并运行（若 compiler 有该目标）
bootstrap-token:
	$(MAKE) -C compiler bootstrap-token

# 内核：构建并 QEMU 测试所有 tests/kernel/*.sx 内核
kernel:
	sh tests/kernel/run-kernel-gate.sh

# 内核构建链 K9：一键出 multiboot1 ELF 镜像
# 用法: make kernel-build SX=tests/kernel/timer_isr.sx ELF=/tmp/kernel.elf
kernel-build:
	@test -n "$(SX)" || (echo "Usage: make kernel-build SX=file.sx [ELF=out.elf]" && exit 1)
	sh tests/kernel/build-kernel.sh "$(SX)" "$(ELF)"

# G3+G4: 静态检查 + 纯净度 gate
kernel-check:
	sh tests/kernel/static-check-gate.sh

# G7: 可复现构建 gate
kernel-repro:
	sh tests/kernel/reproducible-gate.sh

# G1: host 单测 gate
kernel-host-test:
	sh tests/kernel/host-test-gate.sh

# L4: 栈用量分析 gate
kernel-stack-check:
	sh tests/kernel/stack-check-gate.sh

# K11/L10: 64-bit kernel code model gate
kernel64-check:
	sh tests/kernel/kernel64-gate.sh

# G5: QEMU SMP gate
kernel-smp:
	sh tests/kernel/smp-gate.sh

# L6: Send/Sync contract gate
kernel-send-sync:
	sh tests/kernel/send_sync_gate.sh

# A3: cross-architecture gate
kernel-cross-arch:
	sh tests/kernel/cross-arch-gate.sh

# A4: UEFI boot path gate
kernel-uefi:
	sh tests/kernel/uefi-gate.sh

# x86_64 long mode boot gate (32-bit -> 64-bit transition in QEMU)
kernel-longmode:
	sh tests/kernel/longmode-gate.sh

# Multiboot2 header gate (end tag + alignment, T1 static)
kernel-multiboot2:
	sh tests/kernel/multiboot2-gate.sh

# UEFI application gate (PE32+ skeleton with efi_main)
kernel-uefi-app:
	sh tests/kernel/uefi-app-gate.sh

# IST (Interrupt Stack Table) gate (TSS64 + IDTGate64 structs)
kernel-ist:
	sh tests/kernel/ist-gate.sh
