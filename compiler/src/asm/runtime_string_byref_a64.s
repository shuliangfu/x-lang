/* knife256/10.2: Cap tip String AAPCS64 byref callees. x0=*String (data@0,len@0x100). */
	.align 2
	.globl _std_string_length_String
_std_string_length_String:
	ldrsw	x0, [x0, #0x100]
	ret
	.globl _std_string_is_empty_String
_std_string_is_empty_String:
	ldrsw	x8, [x0, #0x100]
	cmp	x8, #0
	cset	w0, le
	ret
	.globl _std_string_string_get
_std_string_string_get:
	sxtw	x1, w1
	ldrb	w0, [x0, x1]
	ret
	.globl _std_string_string_eq
_std_string_string_eq:
	stp	x29, x30, [sp, #-0x30]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	str	x21, [sp, #0x20]
	mov	x19, x0
	mov	x20, x1
	ldrsw	x8, [x19, #0x100]
	ldrsw	x9, [x20, #0x100]
	cmp	x8, x9
	b.ne	.Leq0
	mov	x21, x8
	cbz	x21, .Leq1
	mov	x0, x19
	mov	x1, x20
	mov	x2, x21
	bl	_memcmp
	cmp	w0, #0
	cset	w0, eq
	b	.Leq2
.Leq0:	mov	w0, #0
	b	.Leq2
.Leq1:	mov	w0, #1
.Leq2:	ldr	x21, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x30
	ret
	.globl _std_string_string_compare
_std_string_string_compare:
	stp	x29, x30, [sp, #-0x30]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	mov	x19, x0
	mov	x20, x1
	ldrsw	x21, [x19, #0x100]
	ldrsw	x22, [x20, #0x100]
	cmp	x21, x22
	csel	x2, x21, x22, lt
	cbz	x2, .Lcmp_len
	mov	x0, x19
	mov	x1, x20
	bl	_memcmp
	cbnz	w0, .Lcmp_done
.Lcmp_len:
	cmp	x21, x22
	b.eq	.Lcmp_eq
	cset	w0, gt
	mov	w1, #-1
	csel	w0, w1, w0, lt
	b	.Lcmp_done
.Lcmp_eq:
	mov	w0, #0
.Lcmp_done:
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x30
	ret
	.globl _std_string_string_find_char
_std_string_string_find_char:
	stp	x29, x30, [sp, #-0x20]!
	mov	x29, sp
	str	x19, [sp, #0x10]
	mov	x19, x0
	uxtb	w1, w1
	ldrsw	x2, [x19, #0x100]
	mov	x0, x19
	bl	_memchr
	cbz	x0, .Lfc0
	sub	x0, x0, x19
	b	.Lfc1
.Lfc0:	mov	x0, #-1
.Lfc1:	ldr	x19, [sp, #0x10]
	ldp	x29, x30, [sp], #0x20
	ret
	/* rfind: no memrchr on Darwin — scan backward */
	.globl _std_string_string_rfind_char
_std_string_string_rfind_char:
	uxtb	w1, w1
	ldrsw	x2, [x0, #0x100]
	cbz	x2, .Lrf_miss
	sub	x2, x2, #1
.Lrf_loop:
	ldrb	w3, [x0, x2]
	cmp	w3, w1
	b.eq	.Lrf_hit
	cbz	x2, .Lrf_miss
	sub	x2, x2, #1
	b	.Lrf_loop
.Lrf_hit:
	mov	x0, x2
	ret
.Lrf_miss:
	mov	x0, #-1
	ret
	.globl _std_string_string_starts_with
_std_string_string_starts_with:
	stp	x29, x30, [sp, #-0x30]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	str	x21, [sp, #0x20]
	mov	x19, x0
	mov	x20, x1
	sxtw	x21, w2
	cmp	x21, #0
	b.le	.Lsw1
	ldrsw	x8, [x19, #0x100]
	cmp	x8, x21
	b.lt	.Lsw0
	mov	x0, x19
	mov	x1, x20
	mov	x2, x21
	bl	_memcmp
	cmp	w0, #0
	cset	w0, eq
	b	.Lsw2
.Lsw1:	mov	w0, #1
	b	.Lsw2
.Lsw0:	mov	w0, #0
.Lsw2:	ldr	x21, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x30
	ret
	.globl _std_string_string_ends_with
_std_string_string_ends_with:
	stp	x29, x30, [sp, #-0x30]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	str	x21, [sp, #0x20]
	mov	x19, x0
	mov	x20, x1
	sxtw	x21, w2
	cmp	x21, #0
	b.le	.Lew1
	ldrsw	x8, [x19, #0x100]
	cmp	x8, x21
	b.lt	.Lew0
	sub	x8, x8, x21
	add	x0, x19, x8
	mov	x1, x20
	mov	x2, x21
	bl	_memcmp
	cmp	w0, #0
	cset	w0, eq
	b	.Lew2
.Lew1:	mov	w0, #1
	b	.Lew2
.Lew0:	mov	w0, #0
.Lew2:	ldr	x21, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x30
	ret
	.globl _std_string_string_find_slice
_std_string_string_find_slice:
	stp	x29, x30, [sp, #-0x40]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	mov	x19, x0
	mov	x20, x1
	sxtw	x21, w2
	cmp	x21, #0
	b.le	.Lfs0
	ldrsw	x22, [x19, #0x100]
	cmp	x22, x21
	b.lt	.Lfs1
	mov	x0, x19
	mov	x1, x22
	mov	x2, x20
	mov	x3, x21
	bl	_memmem
	cbz	x0, .Lfs1
	sub	x0, x0, x19
	b	.Lfs2
.Lfs0:	mov	x0, #0
	b	.Lfs2
.Lfs1:	mov	x0, #-1
.Lfs2:	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x40
	ret
	.globl _std_string_string_contains
_std_string_string_contains:
	stp	x29, x30, [sp, #-0x10]!
	mov	x29, sp
	bl	_std_string_string_find_slice
	cmp	x0, #0
	cset	w0, ge
	ldp	x29, x30, [sp], #0x10
	ret
	.globl _std_string_string_copy_to
_std_string_string_copy_to:
	stp	x29, x30, [sp, #-0x30]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	str	x21, [sp, #0x20]
	mov	x19, x0
	mov	x20, x1
	sxtw	x21, w2
	ldrsw	x8, [x19, #0x100]
	cmp	x21, x8
	b.lt	.Lct0
	cbz	x8, .Lct1
	mov	x0, x20
	mov	x1, x19
	mov	x2, x8
	bl	_memcpy
.Lct1:	ldrsw	x0, [x19, #0x100]
	b	.Lct2
.Lct0:	mov	x0, #-1
.Lct2:	ldr	x21, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x30
	ret
	/* eq_view: Cap tip passes StrView as dual-GP (x1=ptr, x2=len) after *String */
	.globl _std_string_string_eq_view
_std_string_string_eq_view:
	stp	x29, x30, [sp, #-0x30]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	str	x21, [sp, #0x20]
	mov	x19, x0
	mov	x20, x1
	sxtw	x21, w2
	ldrsw	x8, [x19, #0x100]
	cmp	x8, x21
	b.ne	.Lev0
	cbz	x21, .Lev1
	mov	x0, x19
	mov	x1, x20
	mov	x2, x21
	bl	_memcmp
	cmp	w0, #0
	cset	w0, eq
	b	.Lev2
.Lev0:	mov	w0, #0
	b	.Lev2
.Lev1:	mov	w0, #1
.Lev2:	ldr	x21, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x30
	ret

	/* trim(s, out, out_max) — skip space/tab both ends, copy */
	.globl _std_string_trim
_std_string_trim:
	stp	x29, x30, [sp, #-0x40]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	str	x23, [sp, #0x30]
	mov	x19, x0			/* *String */
	mov	x20, x1			/* out */
	sxtw	x21, w2			/* out_max */
	ldrsw	x22, [x19, #0x100]	/* len */
	cmp	x22, #0
	b.le	.Ltr_zero
	cmp	x21, #0
	b.le	.Ltr_zero
	mov	x23, #0			/* start */
.Ltr_ss:
	cmp	x23, x22
	b.ge	.Ltr_zero
	ldrb	w8, [x19, x23]
	cmp	w8, #32
	b.eq	.Ltr_ss1
	cmp	w8, #9
	b.ne	.Ltr_se
.Ltr_ss1:
	add	x23, x23, #1
	b	.Ltr_ss
.Ltr_se:
	sub	x8, x22, #1		/* end = len-1 */
.Ltr_se1:
	cmp	x8, x23
	b.lt	.Ltr_zero
	ldrb	w9, [x19, x8]
	cmp	w9, #32
	b.eq	.Ltr_se2
	cmp	w9, #9
	b.ne	.Ltr_copy
.Ltr_se2:
	sub	x8, x8, #1
	b	.Ltr_se1
.Ltr_copy:
	sub	x2, x8, x23
	add	x2, x2, #1		/* n */
	cmp	x2, x21
	b.gt	.Ltr_fail
	add	x1, x19, x23		/* src */
	mov	x0, x20
	mov	x9, x2			/* save n */
	bl	_memcpy
	mov	x0, x9
	b	.Ltr_done
.Ltr_zero:
	mov	x0, #0
	b	.Ltr_done
.Ltr_fail:
	mov	x0, #-1
.Ltr_done:
	ldr	x23, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x40
	ret

	.globl _std_string_string_compare_view
_std_string_string_compare_view:
	/* x0=*String, x1=view.ptr, w2=view.len */
	stp	x29, x30, [sp, #-0x30]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	mov	x19, x0
	mov	x20, x1
	sxtw	x21, w2			/* v.len */
	ldrsw	x22, [x19, #0x100]	/* s.len */
	cmp	x22, x21
	csel	x2, x22, x21, lt	/* n = min */
	cbz	x2, .Lcv_len
	mov	x0, x19
	mov	x1, x20
	bl	_memcmp
	cbnz	w0, .Lcv_done
.Lcv_len:
	cmp	x22, x21
	b.eq	.Lcv_eq
	cset	w0, gt
	mov	w1, #-1
	csel	w0, w1, w0, lt
	b	.Lcv_done
.Lcv_eq:
	mov	w0, #0
.Lcv_done:
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x30
	ret

/* Cap tip leftover: string.o keeps string_view_concat_arena → U
 * _std_heap_arena64_alloc. Ondemand scans user.o only, so encoding -o
 * never pulls heap.o. Weak stub (null); real heap.o strong wins.
 * PLATFORM: MACOS|ARM64. Prefer asm; no FORCE_CC. */
	.globl	_std_heap_arena64_alloc
	.weak_definition _std_heap_arena64_alloc
	.p2align	2
_std_heap_arena64_alloc:
	mov	x0, xzr
	ret
