/**
 * crt0_arm64.s — Darwin arm64 Mach-O：无 C 自举入口（Phase E-04 v20）
 *
 * 文件职责：提供 _start；dyld 调用 _start 时 x0=argc、x1=argv（非 Linux 栈布局）。
 * driver_get_argv_i 由 runtime_abi.o 提供。
 * 重要约定：_start 调 main_entry（driver_sx.o）；链接须 -e _start -nostartfiles。
 */

	.section __TEXT,__text,regular,pure_instructions

	.globl _start
_start:
	/* Darwin dyld：x0=argc, x1=argv, x2=envp；勿读 sp（与 Linux crt0 不同）。 */
	bl _main_entry
	b _exit
