/* Cap tip leftover: need_net misses std/io/driver.o push. Weak submit (-1).
 * PLATFORM: MACOS|ARM64. Prefer asm; real driver.o strong wins. */
	.section __TEXT,__text,regular,pure_instructions
	.globl	_std_io_driver_submit_read
	.weak_definition	_std_io_driver_submit_read
	.p2align	2
_std_io_driver_submit_read:
	mov	w0, #-1
	ret

	.globl	_std_io_driver_submit_write
	.weak_definition	_std_io_driver_submit_write
	.p2align	2
_std_io_driver_submit_write:
	mov	w0, #-1
	ret
