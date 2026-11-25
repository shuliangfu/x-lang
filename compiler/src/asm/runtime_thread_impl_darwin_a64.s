/* Cap tip leftover: weak hollow *_impl in runtime_thread_impl_stubs return 0/-1;
 * thread.id() → 0 fails gate. Strong Darwin pthread bodies; weak stubs lose.
 * Prefer asm; no FORCE_CC. PLATFORM: MACOS|ARM64 Cap tip. */
	.section __TEXT,__text,regular,pure_instructions

	.globl	_thread_self_impl
	.p2align	2
_thread_self_impl:
	b	_pthread_self

/* x0=entry, x1=arg → pthread_t as i64, or 0 */
	.globl	_thread_create_impl
	.p2align	2
_thread_create_impl:
	stp	x29, x30, [sp, #-0x30]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	str	xzr, [sp, #0x20]		/* pthread_t slot */
	cbz	x0, .Lcr0
	mov	x19, x0
	mov	x20, x1
	add	x0, sp, #0x20
	mov	x1, xzr
	mov	x2, x19
	mov	x3, x20
	bl	_pthread_create
	cbnz	w0, .Lcr0
	ldr	x0, [sp, #0x20]
	b	.Lcrd
.Lcr0:	mov	x0, xzr
.Lcrd:	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x30
	ret

	.globl	_thread_create_with_stack_impl
	.p2align	2
_thread_create_with_stack_impl:
	/* ignore stack size for Cap tip smoke; same as create */
	b	_thread_create_impl

/* x0=tid → pthread_join; 0 ok */
	.globl	_thread_join_impl
	.p2align	2
_thread_join_impl:
	cbz	x0, 1f
	mov	x1, xzr
	b	_pthread_join
1:	mov	w0, #-1
	ret

	.globl	_thread_dummy_entry_ptr_impl
	.p2align	2
_thread_dummy_entry_ptr_impl:
	adrp	x0, _thread_dummy_entry_darwin@PAGE
	add	x0, x0, _thread_dummy_entry_darwin@PAGEOFF
	ret

	.globl	_thread_dummy_entry_darwin
	.p2align	2
_thread_dummy_entry_darwin:
	mov	x0, xzr
	ret
