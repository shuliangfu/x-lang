// knife256/10.2: pure-asm 4-byte store — Cap tip .x store_i32 mislinked / smashed.
	.globl	_parser_asm_lex_bridge_store_i32
	.p2align	2
_parser_asm_lex_bridge_store_i32:
	// x0 = dst *u8, w1 = i32 value
	cbz	x0, 1f
	str	w1, [x0]
1:	ret
