/* Cap tip leftover: compress algos U core_mem_mem_zero/compare; ondemand
 * scans user.o only. Weak stubs → memset/memcmp; strong mem.o wins if linked.
 * Prefer asm. PLATFORM: MACOS|ARM64 Cap tip. */
	.section __TEXT,__text,regular,pure_instructions

	.globl	_core_mem_mem_zero
	.weak_definition _core_mem_mem_zero
	.p2align	2
_core_mem_mem_zero:
	mov	x2, x1
	mov	w1, #0
	b	_memset

	.globl	_core_mem_mem_compare
	.weak_definition _core_mem_mem_compare
	.p2align	2
_core_mem_mem_compare:
	b	_memcmp
