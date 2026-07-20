/**
 * typeck_f64_bits_x86_64_mingw.s — Windows MinGW x86_64 PE/COFF assembly for
 * typeck_float64_bits_lo/hi (provides typeck_float64_bits_lo/hi symbols).
 *
 * Why: PE/COFF doesn't support ELF-style `.type symbol,@function` directive
 *      (MinGW GAS rejects it with "junk at end of line, first unrecognized
 *      character is `t'"). Use this file on Windows MSYS/MINGW x86_64
 *      instead of typeck_f64_bits_x86_64.s (which targets ELF).
 *
 * Invariant: x64 PE/COFF doesn't add leading underscore to C symbols
 *            (only 32-bit Windows cdecl does). So symbol names match the
 *            SysV (Linux) variant exactly: typeck_float64_bits_lo/hi
 *            (no underscore prefix).
 *
 * Asm/Perf: ABI-equivalent to SysV AMD64 for this specific function
 *           (input xmm0, output eax, no calls, no callee-saved regs).
 *           Windows x64 calling convention uses xmm0 for double param
 *           and eax for i32 return — same as SysV AMD64 here, so the
 *           instructions are identical to the Linux variant.
 *
 * PLATFORM: WINDOWS | MSYS | MINGW (x86_64 only)
 */

	.text
	.globl typeck_float64_bits_lo
typeck_float64_bits_lo:
	movq	%xmm0, %rax
	ret

	.globl typeck_float64_bits_hi
typeck_float64_bits_hi:
	movq	%xmm0, %rax
	shr	$32, %rax
	ret
