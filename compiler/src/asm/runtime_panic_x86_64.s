/**
 * runtime_panic_x86_64.s — Linux x86_64 无 libc panic 桩（S4 freestanding）
 *
 * 提供 xlang_panic_(has_msg, msg_val)；asm 后端 EXPR_PANIC / 除零检查 call 此符号。
 * 实现：直接 syscall exit(134)（与 abort 常见退出码一致），不依赖 glibc。
 * 链接用户程序或 crt0 自举链时与 runtime_panic.o 一并链入即可替代 runtime_panic.c。
 */
	.text
	/* 弱默认：无 backtrace.o 时不收集证据；与 runtime_panic.c 一致，供 std/runtime/runtime.o 链接。 */
	.weak	xlang_crash_evidence_collect_c
	.globl	xlang_crash_evidence_collect_c
	.type	xlang_crash_evidence_collect_c, @function
xlang_crash_evidence_collect_c:
	ret
	.size	xlang_crash_evidence_collect_c, .-xlang_crash_evidence_collect_c

	.weak	io_register_buffers_buf_c
	.globl	io_register_buffers_buf_c
	.type	io_register_buffers_buf_c, @function
io_register_buffers_buf_c:
	mov	$-1, %eax
	ret
	.size	io_register_buffers_buf_c, .-io_register_buffers_buf_c

	.globl	xlang_panic_
	.type	xlang_panic_, @function
xlang_panic_:
	/* void xlang_panic_(int has_msg, intptr_t msg_val)
	 * PLATFORM: LINUX x86_64 freestanding — no libc.
	 * SysV: edi=has_msg, rsi=msg_val. has_msg==2 → write(2, cstr, len) then exit(134).
	 * wave386: cstr full print without truncating the pointer. */
	cmpl	$2, %edi
	jne	.Lpanic_exit
	testq	%rsi, %rsi
	jz	.Lpanic_exit
	/* strlen: rax = 0; scan [rsi+rax] until NUL */
	xorq	%rax, %rax
.Lpanic_strlen:
	cmpb	$0, (%rsi,%rax)
	je	.Lpanic_write
	incq	%rax
	jmp	.Lpanic_strlen
.Lpanic_write:
	/* write(stderr=2, buf=rsi, len=rax) — preserve msg in r8 across syscall */
	movq	%rsi, %r8
	movq	%rax, %rdx
	movl	$2, %edi
	movq	%r8, %rsi
	movl	$1, %eax
	syscall
	/* trailing newline */
	leaq	.Lpanic_nl(%rip), %rsi
	movl	$2, %edi
	movl	$1, %edx
	movl	$1, %eax
	syscall
.Lpanic_exit:
	movl	$134, %edi
	movl	$60, %eax
	syscall
1:	jmp	1b
	.size	xlang_panic_, .-xlang_panic_

	.section	.rodata
.Lpanic_nl:
	.byte	10
	.text
