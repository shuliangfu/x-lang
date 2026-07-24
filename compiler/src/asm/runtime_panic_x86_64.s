/**
 * runtime_panic_x86_64.s — Linux x86_64 freestanding panic (no libc)
 *
 * Provides xlang_panic_(has_msg, msg_val) for asm-backend EXPR_PANIC / div0.
 * PLATFORM: LINUX x86_64 — product pin when UNAME_S=Linux && x86_64 (not Darwin C seed).
 * ABI: SysV edi=has_msg, rsi=msg_val (intptr_t full width).
 *   has_msg==0 bare  → exit(134)
 *   has_msg==1 int   → write(2,"panic: <n>\n") then exit(134)  (wave389)
 *   has_msg==2 cstr  → write(2,"panic: <msg>\n") then exit(134) (wave386)
 * Exit code 134 matches abort(); does not call glibc.
 */
	.text
	/* Weak default: no-op evidence when backtrace.o absent (match C seed). */
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
	/* void xlang_panic_(int has_msg, intptr_t msg_val) — noreturn.
	 * PLATFORM: LINUX x86_64 freestanding. */
	cmpl	$2, %edi
	je	.Lpanic_cstr
	cmpl	$1, %edi
	je	.Lpanic_int
	jmp	.Lpanic_exit

.Lpanic_cstr:
	testq	%rsi, %rsi
	jz	.Lpanic_exit
	/* save cstr in r8; write "panic: " then body then NL (match host-C face). */
	movq	%rsi, %r8
	leaq	.Lpanic_pfx(%rip), %rsi
	movl	$2, %edi
	movl	$7, %edx
	movl	$1, %eax
	syscall
	/* strlen: rax = 0; scan [r8+rax] until NUL */
	xorq	%rax, %rax
.Lpanic_strlen:
	cmpb	$0, (%r8,%rax)
	je	.Lpanic_write
	incq	%rax
	jmp	.Lpanic_strlen
.Lpanic_write:
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
	jmp	.Lpanic_exit

	/* wave389: has_msg==1 — print signed decimal like C fprintf("panic: %ld\n").
	 * Noreturn: free to clobber caller-saved regs. Stack buffer for digits. */
.Lpanic_int:
	movq	%rsi, %r9			/* r9 = signed value */
	/* "panic: " prefix */
	leaq	.Lpanic_pfx(%rip), %rsi
	movl	$2, %edi
	movl	$7, %edx
	movl	$1, %eax
	syscall
	/* 32-byte digit scratch (max 20 digits + sign headroom) */
	subq	$32, %rsp
	/* optional leading '-' ; then treat magnitude as unsigned (INT64_MIN safe) */
	testq	%r9, %r9
	jns	.Lpanic_int_abs
	leaq	.Lpanic_minus(%rip), %rsi
	movl	$2, %edi
	movl	$1, %edx
	movl	$1, %eax
	syscall
	negq	%r9				/* two's complement; INT64_MIN stays 2^63 as u64 */
.Lpanic_int_abs:
	testq	%r9, %r9
	jnz	.Lpanic_int_digits
	/* zero → single '0' */
	movb	$48, (%rsp)			/* '0' */
	movq	%rsp, %rsi
	movl	$2, %edi
	movl	$1, %edx
	movl	$1, %eax
	syscall
	jmp	.Lpanic_int_nl
.Lpanic_int_digits:
	/* reverse-digit loop: write from end of buffer toward lower addresses */
	movq	%r9, %rax			/* remaining magnitude */
	leaq	31(%rsp), %r8			/* r8 = write cursor (end) */
	movq	%r8, %r10			/* r10 = last digit address */
	movl	$10, %ecx
.Lpanic_int_div:
	xorl	%edx, %edx
	divq	%rcx				/* rdx:rax / 10 → quot rax, rem rdx */
	addb	$48, %dl			/* '0' + rem */
	movb	%dl, (%r8)
	decq	%r8
	testq	%rax, %rax
	jnz	.Lpanic_int_div
	incq	%r8				/* first digit */
	movq	%r8, %rsi
	movq	%r10, %rdx
	subq	%r8, %rdx
	incq	%rdx				/* len = end - first + 1 */
	movl	$2, %edi
	movl	$1, %eax
	syscall
.Lpanic_int_nl:
	leaq	.Lpanic_nl(%rip), %rsi
	movl	$2, %edi
	movl	$1, %edx
	movl	$1, %eax
	syscall
	addq	$32, %rsp
	/* fall through to exit */

.Lpanic_exit:
	movl	$134, %edi
	movl	$60, %eax			/* sys_exit */
	syscall
1:	jmp	1b
	.size	xlang_panic_, .-xlang_panic_

	.section	.rodata
.Lpanic_pfx:
	.ascii	"panic: "
.Lpanic_nl:
	.byte	10
.Lpanic_minus:
	.byte	45				/* '-' */
	.text
