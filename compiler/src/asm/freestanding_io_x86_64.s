/**
 * freestanding_io_x86_64.s — Linux x86_64 无 libc syscall write（S4 freestanding）
 *
 * shulang_sys_write(fd, buf, len) → syscall write(2)；成功返回写入字节数（rax），失败返回负 errno。
 * System V AMD64：rdi=fd, rsi=buf, rdx=len。
 */
	.text
	.globl	shulang_sys_write
	.type	shulang_sys_write, @function
shulang_sys_write:
	mov	%edi, %edi
	mov	$1, %eax
	syscall
	ret
	.size	shulang_sys_write, .-shulang_sys_write
