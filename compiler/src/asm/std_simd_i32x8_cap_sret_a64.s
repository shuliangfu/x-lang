/* knife256/10.2: Cap tip I32x8 MEMORY returns via Darwin sret x8; Cap tip
 * .x bodies omit sret stores. PLATFORM: MACOS Cap tip. */

	.globl	_std_simd_shuffle_i32x8_i32_a8
	.p2align	2
_std_simd_shuffle_i32x8_i32_a8:
	/* x8=out, x0=&v, x1=&mask */
	sub	sp, sp, #32
	stp	x19, x20, [sp, #16]
	mov	x19, x8
	mov	x20, x0
	mov	x9, x1
	mov	w10, #0
1:
	cmp	w10, #8
	b.ge	2f
	ldr	w11, [x9, w10, uxtw #2]
	and	w11, w11, #7
	ldr	w12, [x20, w11, uxtw #2]
	str	w12, [x19, w10, uxtw #2]
	add	w10, w10, #1
	b	1b
2:
	ldp	x19, x20, [sp, #16]
	add	sp, sp, #32
	ret

	.globl	_std_simd_select_i32x8_i32x8_i32x8
	.p2align	2
_std_simd_select_i32x8_i32x8_i32x8:
	/* x8=out, x0=&mask, x1=&a, x2=&b */
	sub	sp, sp, #48
	stp	x19, x20, [sp, #16]
	str	x21, [sp, #32]
	mov	x19, x8
	mov	x20, x0
	mov	x21, x1
	mov	x9, x2
	mov	w10, #0
3:
	cmp	w10, #8
	b.ge	4f
	ldr	w11, [x20, w10, uxtw #2]
	cbz	w11, 5f
	ldr	w12, [x21, w10, uxtw #2]
	b	6f
5:
	ldr	w12, [x9, w10, uxtw #2]
6:
	str	w12, [x19, w10, uxtw #2]
	add	w10, w10, #1
	b	3b
4:
	ldr	x21, [sp, #32]
	ldp	x19, x20, [sp, #16]
	add	sp, sp, #48
	ret
