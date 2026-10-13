/* Cap tip diag ctx/snap/restore soft (knife256/10.2).
 * Cap tip diag.x hollows snap byte-rebuild; same-TU calls ignore first-wins
 * soft. Soft the ctx getters/setters + restore/push that check uses.
 * PLATFORM: MACOS|ARM64 Cap tip. */
	.section __TEXT,__text,regular,pure_instructions

	.globl _diag_snap_load_ptr
	.p2align 2
_diag_snap_load_ptr:
	cbz	x0, 1f
	add	x0, x0, w1, sxtw
	ldr	x0, [x0]
	ret
1:	mov	x0, #0
	ret

	.globl _diag_snap_load_usize
	.p2align 2
_diag_snap_load_usize:
	cbz	x0, 1f
	add	x0, x0, w1, sxtw
	ldr	x0, [x0]
	ret
1:	mov	x0, #0
	ret

	.globl _diag_snap_load_i32
	.p2align 2
_diag_snap_load_i32:
	cbz	x0, 1f
	add	x0, x0, w1, sxtw
	ldr	w0, [x0]
	ret
1:	mov	w0, #0
	ret

	.globl _diag_snap_store_ptr
	.p2align 2
_diag_snap_store_ptr:
	cbz	x0, 1f
	add	x0, x0, w1, sxtw
	str	x2, [x0]
1:	ret

	.globl _diag_snap_store_usize
	.p2align 2
_diag_snap_store_usize:
	cbz	x0, 1f
	add	x0, x0, w1, sxtw
	str	x2, [x0]
1:	ret

	.globl _diag_snap_store_i32
	.p2align 2
_diag_snap_store_i32:
	cbz	x0, 1f
	add	x0, x0, w1, sxtw
	str	w2, [x0]
1:	ret

	.globl _diag_ctx_get_file
	.p2align 2
_diag_ctx_get_file:
	stp	x29, x30, [sp, #-0x10]!
	bl	_diag_ctx_base
	cbz	x0, 1f
	ldr	x0, [x0]
1:	ldp	x29, x30, [sp], #0x10
	ret

	.globl _diag_ctx_get_source
	.p2align 2
_diag_ctx_get_source:
	stp	x29, x30, [sp, #-0x10]!
	bl	_diag_ctx_base
	cbz	x0, 1f
	ldr	x0, [x0, #8]
1:	ldp	x29, x30, [sp], #0x10
	ret

	.globl _diag_ctx_get_source_len
	.p2align 2
_diag_ctx_get_source_len:
	stp	x29, x30, [sp, #-0x10]!
	bl	_diag_ctx_base
	cbz	x0, 1f
	ldr	x0, [x0, #16]
1:	ldp	x29, x30, [sp], #0x10
	ret

	.globl _diag_ctx_get_use_color
	.p2align 2
_diag_ctx_get_use_color:
	stp	x29, x30, [sp, #-0x10]!
	bl	_diag_ctx_base
	cbz	x0, 1f
	ldr	w0, [x0, #24]
	ldp	x29, x30, [sp], #0x10
	ret
1:	mov	w0, #0
	ldp	x29, x30, [sp], #0x10
	ret

	.globl _diag_ctx_set_all
	.p2align 2
_diag_ctx_set_all:
	/* x0=path x1=source x2=len w3=color */
	stp	x29, x30, [sp, #-0x40]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	mov	x19, x0
	mov	x20, x1
	mov	x21, x2
	mov	w22, w3
	bl	_diag_ctx_base
	cbz	x0, 1f
	str	x19, [x0]
	str	x20, [x0, #8]
	str	x21, [x0, #16]
	str	w22, [x0, #24]
1:	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x40
	ret

	.globl _diag_restore
	.p2align 2
_diag_restore:
	cbz	x0, 9f
	stp	x29, x30, [sp, #-0x20]!
	mov	x29, sp
	str	x19, [sp, #0x10]
	mov	x19, x0
	ldr	x0, [x19]
	ldr	x1, [x19, #8]
	ldr	x2, [x19, #16]
	ldr	w3, [x19, #24]
	bl	_diag_ctx_set_all
	ldr	x19, [sp, #0x10]
	ldp	x29, x30, [sp], #0x20
9:	ret

	.globl _diag_push_file
	.p2align 2
_diag_push_file:
	stp	x29, x30, [sp, #-0x50]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	str	x23, [sp, #0x30]
	mov	x19, x0
	mov	x20, x1
	mov	x21, x2
	mov	x22, x3
	cbz	x19, 2f
	bl	_diag_ctx_get_file
	str	x0, [x19]
	bl	_diag_ctx_get_source
	str	x0, [x19, #8]
	bl	_diag_ctx_get_source_len
	str	x0, [x19, #16]
	bl	_diag_ctx_get_use_color
	str	w0, [x19, #24]
2:
	mov	x23, x20
	cbnz	x23, 3f
	bl	_diag_ctx_get_file
	mov	x23, x0
3:
	cbnz	x21, 4f
	bl	_diag_ctx_get_source
	mov	x21, x0
	bl	_diag_ctx_get_source_len
	mov	x22, x0
4:
	bl	_diag_should_color
	mov	w3, w0
	mov	x0, x23
	mov	x1, x21
	mov	x2, x22
	bl	_diag_ctx_set_all
	ldr	x23, [sp, #0x30]
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x50
	ret
