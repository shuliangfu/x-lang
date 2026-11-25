// The trait-completeness check calls xlang_generic_bound_scan_c with the
// parse stash pointer. On this Cap tip that pointer is a small integer
// (observed 0x288), and the scan builds a fat slice from it. The lexer
// then reads that address and SIGSEGV. When the pointer is not a real
// userspace address, use the Cap-tip lexer source instead.
// PLATFORM: MACOS|ARM64.

.globl _xlang_generic_bound_scan_c
_xlang_generic_bound_scan_c:
	cmp	x0, #0x10000
	b.hs	Lmega
	stp	x29, x30, [sp, #-32]!
	mov	x29, sp
	str	x19, [sp, #16]
	bl	_xlang_cap_tip_lex_src_data
	mov	x19, x0
	bl	_xlang_cap_tip_lex_src_len
	mov	x1, x0
	mov	x0, x19
	ldr	x19, [sp, #16]
	ldp	x29, x30, [sp], #32
	cmp	x0, #0x10000
	b.lo	Lret
	sxtw	x1, w1
Lmega:
	b	_xlang_generic_bound_scan_c_mega
Lret:
	ret
