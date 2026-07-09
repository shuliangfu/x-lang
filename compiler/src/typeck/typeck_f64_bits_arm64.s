/* typeck_f64_bits_arm64.s — Darwin arm64 Mach-O (leading _ symbols).
 * ABI: AAPCS64 — f64 in d0; i32 return in w0.
 * Linux aarch64: see typeck_f64_bits_aarch64_elf.s
 */
	.globl	_typeck_float64_bits_lo
	.globl	_typeck_float64_bits_hi
	.text
	.align	2

_typeck_float64_bits_lo:
	fmov	x0, d0
	ret

_typeck_float64_bits_hi:
	fmov	x0, d0
	lsr	x0, x0, #32
	ret
