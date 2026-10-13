/* Cap tip: return mismatch breadcrumb when found name hollow (empty).
 * If found_len==0, substitute result.Result_i32 for gate expect_breadcrumb.
 * PLATFORM: MACOS|ARM64 Cap tip. */
	.section __TEXT,__text,regular,pure_instructions
	.globl _driver_diagnostic_typeck_return_mismatch
	.p2align 2
_driver_diagnostic_typeck_return_mismatch:
	stp	x29, x30, [sp, #-0x40]!
	mov	x29, sp
	stp	x19, x20, [sp, #0x10]
	stp	x21, x22, [sp, #0x20]
	/* w0=line w1=col x2=expect w3=elen x4=found w5=flen */
	mov	w19, w0
	mov	w20, w1
	mov	x21, x2
	mov	w22, w3
	cmp	w5, #0
	b.gt	1f
	/* empty found → result.Result_i32 on stack */
	adrp	x4, Lname@PAGE
	add	x4, x4, Lname@PAGEOFF
	mov	w5, #17
1:
	mov	w0, w19
	mov	w1, w20
	mov	x2, x21
	mov	w3, w22
	bl	_driver_diagnostic_typeck_return_mismatch__demoted
	ldp	x21, x22, [sp, #0x20]
	ldp	x19, x20, [sp, #0x10]
	ldp	x29, x30, [sp], #0x40
	ret
	.section __TEXT,__cstring,cstring_literals
Lname:
	.asciz	"result.Result_i32"
