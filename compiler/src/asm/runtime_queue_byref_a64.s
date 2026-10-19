/* Cap tip: Queue_i32 (>16B) by-value at/get/length hollow; push_* call
 * at(*q) and SEGV on leftover run-queue. Hand-asm ptr/byref leaf.
 * Layout: data@0 cap@8 length@12 head@16. Prefer asm; no FORCE_CC.
 * PLATFORM: MACOS|ARM64 Cap tip. */
	.section __TEXT,__text,regular,pure_instructions

/* x0=*Queue, w1=i → ring index (Cap tip at is hollow by-value). */
	.globl	_std_queue_at_Queue_i32_i32
	.p2align	2
_std_queue_at_Queue_i32_i32:
	ldr	w2, [x0, #16]		/* head */
	ldr	w3, [x0, #8]		/* cap */
	add	w0, w2, w1
	cbz	w3, 1f
	cmp	w0, w3
	b.lt	1f
	sub	w0, w0, w3
1:	ret

/* Cap tip mangling: _std_queue_get (not get_Queue_i32_i32).
 * x0=*Queue, w1=i → element (0 if OOB). */
	.globl	_std_queue_get
	.p2align	2
_std_queue_get:
	stp	x29, x30, [sp, #-0x30]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	str	x21, [sp, #0x20]
	mov	x19, x0
	mov	w20, w1
	cmp	w20, #0
	b.lt	.Lget0
	ldr	w0, [x19, #12]
	cmp	w20, w0
	b.ge	.Lget0
	mov	x0, x19
	mov	w1, w20
	bl	_std_queue_at_Queue_i32_i32
	mov	w21, w0
	ldr	x0, [x19]
	cbz	x0, .Lget0
	ldr	w0, [x0, w21, uxtw #2]
	b	.Lgetd
.Lget0:	mov	w0, #0
.Lgetd:	ldr	x21, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x30
	ret

	.globl	_std_queue_length_Queue_i32
	.p2align	2
_std_queue_length_Queue_i32:
	ldr	w0, [x0, #12]
	ret

	.globl	_std_queue_is_empty_Queue_i32
	.p2align	2
_std_queue_is_empty_Queue_i32:
	ldr	w0, [x0, #12]
	cmp	w0, #0
	cset	w0, eq
	ret

/* grow: Cap tip — if cap<=0 → 8 else cap*2; alloc i32 count; copy; free.
 * x0=*Queue → 0/-1 */
	.globl	_std_queue_grow_Queue_i32_ptr
	.p2align	2
_std_queue_grow_Queue_i32_ptr:
	stp	x29, x30, [sp, #-0x50]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	stp	x23, x24, [sp, #0x30]
	str	x25, [sp, #0x40]
	mov	x19, x0
	ldr	w20, [x19, #8]		/* old cap */
	cmp	w20, #0
	b.gt	.Lgr_dbl
	mov	w21, #8			/* Cap tip: empty → 8 */
	b	.Lgr_nc
.Lgr_dbl:
	lsl	w21, w20, #1		/* new_cap = cap*2 */
.Lgr_nc:
	cmp	w21, w20
	b.gt	.Lgr_do
	mov	w0, #0			/* Cap tip: no growth → ok */
	b	.Lgr_ret
.Lgr_do:
	mov	w0, w21
	bl	_std_heap_libc_heap_alloc_i32_c
	cbz	x0, .Lgr_fail
	mov	x22, x0			/* new data */
	ldr	x23, [x19]		/* old data */
	ldr	w24, [x19, #12]		/* length */
	ldr	w25, [x19, #16]		/* head */
	mov	w9, #0
.Lgr_copy:
	cmp	w9, w24
	b.ge	.Lgr_done_copy
	add	w10, w25, w9		/* ring idx without calling hollow at */
	cbz	w20, 2f
	cmp	w10, w20
	b.lt	2f
	sub	w10, w10, w20
2:	cbz	x23, 3f
	ldr	w0, [x23, w10, uxtw #2]
	str	w0, [x22, w9, uxtw #2]
3:	add	w9, w9, #1
	b	.Lgr_copy
.Lgr_done_copy:
	cbz	x23, 4f
	mov	x0, x23
	bl	_std_heap_libc_heap_free_i32_c
4:	str	x22, [x19]
	str	w21, [x19, #8]
	str	wzr, [x19, #16]		/* head=0 after linearize */
	mov	w0, #0
	b	.Lgr_ret
.Lgr_fail:
	mov	w0, #-1
.Lgr_ret:
	ldr	x25, [sp, #0x40]
	ldp	x23, x24, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x50
	ret

/* x0=*Queue, w1=x → 0/-1 */
	.globl	_std_queue_push_back_Queue_i32_ptr_i32
	.p2align	2
_std_queue_push_back_Queue_i32_ptr_i32:
	stp	x29, x30, [sp, #-0x30]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	str	x21, [sp, #0x20]
	mov	x19, x0
	mov	w20, w1
.Lpb_retry:
	ldr	w0, [x19, #12]
	ldr	w1, [x19, #8]
	cmp	w0, w1
	b.lt	.Lpb_space
	mov	x0, x19
	bl	_std_queue_grow_Queue_i32_ptr
	cbnz	w0, .Lpb_fail
	b	.Lpb_retry
.Lpb_space:
	ldr	w21, [x19, #12]		/* length as logical index */
	mov	x0, x19
	mov	w1, w21
	bl	_std_queue_at_Queue_i32_i32
	ldr	x1, [x19]
	cbz	x1, .Lpb_fail
	str	w20, [x1, w0, uxtw #2]
	add	w21, w21, #1
	str	w21, [x19, #12]
	mov	w0, #0
	b	.Lpb_done
.Lpb_fail:
	mov	w0, #-1
.Lpb_done:
	ldr	x21, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x30
	ret

/* Cap tip mangling: _std_queue_push_front */
	.globl	_std_queue_push_front
	.p2align	2
_std_queue_push_front:
	stp	x29, x30, [sp, #-0x30]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	mov	x19, x0
	mov	w20, w1
.Lpf_retry:
	ldr	w0, [x19, #12]
	ldr	w1, [x19, #8]
	cmp	w0, w1
	b.lt	.Lpf_space
	mov	x0, x19
	bl	_std_queue_grow_Queue_i32_ptr
	cbnz	w0, .Lpf_fail
	b	.Lpf_retry
.Lpf_space:
	ldr	w0, [x19, #16]
	sub	w0, w0, #1
	ldr	w1, [x19, #8]
	cmp	w0, #0
	b.ge	5f
	add	w0, w0, w1
5:	str	w0, [x19, #16]
	ldr	x1, [x19]
	cbz	x1, .Lpf_fail
	str	w20, [x1, w0, uxtw #2]
	ldr	w0, [x19, #12]
	add	w0, w0, #1
	str	w0, [x19, #12]
	mov	w0, #0
	b	.Lpf_done
.Lpf_fail:
	mov	w0, #-1
.Lpf_done:
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x30
	ret

/* Cap tip mangling: _std_queue_pop_back */
	.globl	_std_queue_pop_back
	.p2align	2
_std_queue_pop_back:
	stp	x29, x30, [sp, #-0x20]!
	mov	x29, sp
	str	x19, [sp, #0x10]
	mov	x19, x0
	ldr	w0, [x19, #12]
	cmp	w0, #0
	b.le	.Lpbk0
	sub	w1, w0, #1
	str	w1, [x19, #12]
	mov	x0, x19
	bl	_std_queue_at_Queue_i32_i32
	ldr	x1, [x19]
	cbz	x1, .Lpbk0
	ldr	w0, [x1, w0, uxtw #2]
	b	.Lpbkd
.Lpbk0:	mov	w0, #0
.Lpbkd:	ldr	x19, [sp, #0x10]
	ldp	x29, x30, [sp], #0x20
	ret

	.globl	_std_queue_pop_front_Queue_i32_ptr
	.p2align	2
_std_queue_pop_front_Queue_i32_ptr:
	mov	x9, x0
	ldr	w0, [x9, #12]
	cmp	w0, #0
	b.le	.Lpfr0
	ldr	w1, [x9, #16]		/* head */
	ldr	x2, [x9]
	cbz	x2, .Lpfr0
	ldr	w0, [x2, w1, uxtw #2]
	add	w1, w1, #1
	ldr	w3, [x9, #8]
	cmp	w3, #0
	b.eq	6f
	cmp	w1, w3
	b.lt	6f
	mov	w1, #0
6:	str	w1, [x9, #16]
	ldr	w1, [x9, #12]
	sub	w1, w1, #1
	str	w1, [x9, #12]
	ret
.Lpfr0:	mov	w0, #0
	ret
