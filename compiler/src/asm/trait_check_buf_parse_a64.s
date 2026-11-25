// While the default-method hoist allows bare self, parse with the live
// impl. It takes the source as a slice {data, length}. Every other call
// keeps the archived buf parser.
// PLATFORM: MACOS|ARM64.

.globl _parser_asm_parse_one_function_buf_into_c
_parser_asm_parse_one_function_buf_into_c:
	stp	x29, x30, [sp, #-80]!
	mov	x29, sp
	stp	x0, x1, [sp, #16]
	stp	x2, x3, [sp, #32]
	str	x4, [sp, #48]
	str	w5, [sp, #56]
	bl	_parser_allow_bare_self_pending_c
	cbz	w0, Lmega
	ldr	x4, [sp, #48]
	ldrsw	x5, [sp, #56]
	stp	x4, x5, [sp, #64]
	add	x4, sp, #64
	ldp	x0, x1, [sp, #16]
	ldp	x2, x3, [sp, #32]
	bl	_parser_parse_one_function_impl
	b	Ldone
Lmega:
	ldp	x0, x1, [sp, #16]
	ldp	x2, x3, [sp, #32]
	ldr	x4, [sp, #48]
	ldr	w5, [sp, #56]
	bl	_parser_asm_parse_one_function_buf_into_c_mega
Ldone:
	ldp	x29, x30, [sp], #80
	ret
