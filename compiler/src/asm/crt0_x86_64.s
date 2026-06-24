# crt0_x86_64.s - 无 C 自举: _start（x86_64 Linux）
# E-04 v19：_start 调 main_entry（driver_sx.o / bridge 弱桩）；替代 main.c / runtime_asm_build.c
# NL-07 v5：_start 先 bootstrap_init_static_tls（%fs:0x28 栈保护；见 bootstrap_nostdlib_stubs.c）
# NL-07 v5：再 bootstrap_init_environ（getenv/SHUX_* 环境变量）
# NL-07 v6：argc/argv 存 r12/r13；bootstrap 桩会 clobber rdi/rsi，每次 call 前须恢复。

	.text
	.globl	_start
	.type	_start, @function
_start:
	mov	(%rsp), %r12d
	lea	8(%rsp), %r13
	and	$~15, %rsp
	sub	$8, %rsp
	mov	%r12d, %edi
	mov	%r13, %rsi
	call	bootstrap_init_static_tls
	mov	%r12d, %edi
	mov	%r13, %rsi
	call	bootstrap_init_environ
	mov	%r12d, %edi
	mov	%r13, %rsi
	call	main_entry
	mov	%eax, %edi
	mov	$60, %eax
	syscall
1:	jmp	1b
	.size	_start, .-_start
