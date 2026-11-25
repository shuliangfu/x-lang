/* Cap tip: Set_i32 (>16B) by-value callees hollow. Byref overlay + open-address
 * find (match std/heap/ops map_i32_i32_find_c / set.insert). Prefer asm.
 * Layout: keys@0 occupied@8 cap@16 length@20. PLATFORM: MACOS|ARM64. */
	.section __TEXT,__text,regular,pure_instructions

/* x0=*Set_i32, w1=key → index or -1 */
	.globl	_std_set_find_Set_i32_i32
	.p2align	2
_std_set_find_Set_i32_i32:
	stp	x29, x30, [sp, #-0x40]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	str	x23, [sp, #0x30]
	mov	x19, x0			/* set* */
	mov	w20, w1			/* key */
	ldr	x21, [x19]		/* keys */
	ldr	x22, [x19, #8]		/* occupied */
	ldr	w23, [x19, #16]		/* cap */
	cmp	w23, #0
	b.le	.Lfind_miss
	/* start = key % cap (handle neg) */
	sdiv	w0, w20, w23
	msub	w9, w0, w23, w20
	cmp	w9, #0
	b.ge	1f
	add	w9, w9, w23
1:	mov	w10, w9			/* i = start */
	mov	w11, #0			/* guard */
.Lfind_loop:
	cmp	w11, w23
	b.ge	.Lfind_miss
	ldrb	w0, [x22, w10, uxtw]
	cbz	w0, .Lfind_miss		/* empty → miss */
	ldr	w0, [x21, w10, uxtw #2]
	cmp	w0, w20
	b.eq	.Lfind_hit
	add	w10, w10, #1
	cmp	w10, w23
	b.lt	2f
	mov	w10, #0
2:	cmp	w10, w9
	b.eq	.Lfind_miss
	add	w11, w11, #1
	b	.Lfind_loop
.Lfind_hit:
	mov	w0, w10
	b	.Lfind_done
.Lfind_miss:
	mov	w0, #-1
.Lfind_done:
	ldr	x23, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x40
	ret

	.globl	_std_set_contains_key_Set_i32_i32
	.p2align	2
_std_set_contains_key_Set_i32_i32:
	stp	x29, x30, [sp, #-0x10]!
	mov	x29, sp
	bl	_std_set_find_Set_i32_i32
	cmp	w0, #0
	cset	w0, ge
	ldp	x29, x30, [sp], #0x10
	ret

	.globl	_std_set_length_Set_i32
	.p2align	2
_std_set_length_Set_i32:
	ldr	w0, [x0, #20]
	ret

	.globl	_std_set_is_empty
	.p2align	2
_std_set_is_empty:
	ldr	w0, [x0, #20]
	cmp	w0, #0
	cset	w0, eq
	ret

	.globl	_std_set_slot_Set_i32_i32
	.p2align	2
_std_set_slot_Set_i32_i32:
	ldr	w2, [x0, #16]
	cbz	w2, 1f
	sdiv	w3, w1, w2
	msub	w0, w3, w2, w1
	cmp	w0, #0
	b.ge	2f
	add	w0, w0, w2
2:	ret
1:	mov	w0, #0
	ret

/* x0=*Set_i32, w1=key → 0 ok, -1 fail. Assumes with_capacity done (cap>0). */
	.globl	_std_set_insert_Set_i32_ptr_i32
	.p2align	2
_std_set_insert_Set_i32_ptr_i32:
	stp	x29, x30, [sp, #-0x40]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	str	x23, [sp, #0x30]
	mov	x19, x0
	mov	w20, w1
	ldr	x21, [x19]		/* keys */
	ldr	x22, [x19, #8]		/* occupied */
	ldr	w23, [x19, #16]		/* cap */
	cbz	w23, .Lins_fail
	cbz	x21, .Lins_fail
	cbz	x22, .Lins_fail
	sdiv	w0, w20, w23
	msub	w9, w0, w23, w20
	cmp	w9, #0
	b.ge	1f
	add	w9, w9, w23
1:	mov	w10, w9
.Lins_loop:
	ldrb	w0, [x22, w10, uxtw]
	cbz	w0, .Lins_empty
	ldr	w0, [x21, w10, uxtw #2]
	cmp	w0, w20
	b.eq	.Lins_ok			/* already present */
	add	w10, w10, #1
	cmp	w10, w23
	b.lt	2f
	mov	w10, #0
2:	cmp	w10, w9
	b.eq	.Lins_fail			/* full — skip grow for leftover */
	b	.Lins_loop
.Lins_empty:
	str	w20, [x21, w10, uxtw #2]
	mov	w0, #1
	strb	w0, [x22, w10, uxtw]
	ldr	w0, [x19, #20]
	add	w0, w0, #1
	str	w0, [x19, #20]
.Lins_ok:
	mov	w0, #0
	b	.Lins_done
.Lins_fail:
	mov	w0, #-1
.Lins_done:
	ldr	x23, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x40
	ret

/* x0=*Set_i32, w1=key → 1 removed / 0 missing */
	.globl	_std_set_remove_Set_i32_ptr_i32
	.p2align	2
_std_set_remove_Set_i32_ptr_i32:
	stp	x29, x30, [sp, #-0x20]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	mov	x19, x0
	mov	w20, w1
	bl	_std_set_find_Set_i32_i32
	cmp	w0, #0
	b.lt	.Lrm_miss
	mov	w10, w0			/* idx */
	ldr	x1, [x19, #8]		/* occupied */
	strb	wzr, [x1, w10, uxtw]
	ldr	w0, [x19, #20]
	sub	w0, w0, #1
	str	w0, [x19, #20]
	mov	w0, #1
	b	.Lrm_done
.Lrm_miss:
	mov	w0, #0
.Lrm_done:
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x20
	ret
