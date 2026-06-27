/**
 * typeck_f64_bits_x86_64.s — Linux x86_64 汇编实现 typeck_float64_bits_lo/hi
 *
 * 供 asm/crt0 链接路径使用，替代 typeck_f64_bits.c（G-03 no-libc 方向零 C 桩）。
 * SysV AMD64：double 实参在 xmm0；i32 返回值在 eax。
 */

	.text
	.globl typeck_float64_bits_lo
	.type typeck_float64_bits_lo, @function
typeck_float64_bits_lo:
	movq %xmm0, %rax
	ret

	.globl typeck_float64_bits_hi
	.type typeck_float64_bits_hi, @function
typeck_float64_bits_hi:
	movq %xmm0, %rax
	shr $32, %rax
	ret
