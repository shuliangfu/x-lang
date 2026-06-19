/**
 * runtime_panic_x86_64.s — Linux x86_64 无 libc panic 桩（S4 freestanding）
 *
 * 提供 shux_panic_(has_msg, msg_val)；asm 后端 EXPR_PANIC / 除零检查 call 此符号。
 * 实现：直接 syscall exit(134)（与 abort 常见退出码一致），不依赖 glibc。
 * 链接用户程序或 crt0 自举链时与 runtime_panic.o 一并链入即可替代 runtime_panic.c。
 */
	.text
	.globl	shux_panic_
	.type	shux_panic_, @function
shux_panic_:
	/* void shux_panic_(int has_msg, int msg_val) — 参数忽略，统一异常退出 */
	mov	$134, %edi
	mov	$60, %eax
	syscall
1:	jmp	1b
	.size	shux_panic_, .-shux_panic_
