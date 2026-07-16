# crt0_x86_64.s - 无 C 自举: _start（x86_64 Linux）
# E-04 v19：_start 调 main_entry（driver_x.o / bridge 弱桩）；替代 main.c / runtime_asm_build.c
# NL-07 v5：_start 先 bootstrap_init_static_tls（%fs:0x28 栈保护；见 bootstrap_nostdlib_stubs.c）
# NL-07 v5：再 bootstrap_init_environ（getenv/SHUX_* 环境变量）
# NL-07 v6：argc/argv 存 r12/r13；bootstrap 桩会 clobber rdi/rsi，每次 call 前须恢复。
# NL-07 v7：_start 对外部 C 符号发起 call 前保持 SysV 16B 栈对齐，勿再额外减 8。

	.text
	.globl	_start
	.type	_start, @function
_start:
	mov	(%rsp), %r12d
	lea	8(%rsp), %r13
	and	$~15, %rsp
	mov	%r12d, %edi
	mov	%r13, %rsi
	call	bootstrap_init_static_tls
	mov	%r12d, %edi
	mov	%r13, %rsi
	call	bootstrap_init_environ
	mov	%r12d, %edi
	mov	%r13, %rsi
	call	main_entry
	/* 【Why 2026-07-16】不可直接 SYS_exit：seed 动态链 glibc 时 fwrite(stdout)
	 * 走 glibc 缓冲；未 fflush 则 -E 等大输出在 ~缓冲边界截断（udp 冷链 24KiB 假截断）。
	 * bootstrap_flush_stdio_and_exit 先 fflush(stdout/stderr) 再 sys_exit。 */
	mov	%eax, %edi
	call	bootstrap_flush_stdio_and_exit
1:	jmp	1b
	.size	_start, .-_start
