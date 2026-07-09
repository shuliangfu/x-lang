/* typeck_f64_bits_aarch64_elf.s — Linux aarch64 ELF (no leading _).
 * ABI: AAPCS64 — f64 in d0; i32 return in w0.
 */
	.globl	typeck_float64_bits_lo
	.globl	typeck_float64_bits_hi
	.text
	.align	2

typeck_float64_bits_lo:
	fmov	x0, d0
	ret

typeck_float64_bits_hi:
	fmov	x0, d0
	lsr	x0, x0, #32
	ret
