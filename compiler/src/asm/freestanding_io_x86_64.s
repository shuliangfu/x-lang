/**
 * freestanding_io_x86_64.s — Linux x86_64 无 libc syscall I/O（S4 freestanding / B-14 v1）
 *
 * xlang_sys_write/read/close/exit → Linux write/read/close/exit syscalls。
 * System V AMD64 ABI：rax=nr；args 依次 rdi, rsi, rdx, r10, r8, r9。
 */
	.text
	.globl	xlang_sys_write
	.type	xlang_sys_write, @function
xlang_sys_write:
	mov	%edi, %edi
	mov	$1, %eax
	syscall
	ret
	.size	xlang_sys_write, .-xlang_sys_write

	.globl	xlang_sys_read
	.type	xlang_sys_read, @function
xlang_sys_read:
	mov	%edi, %edi
	mov	$0, %eax
	syscall
	ret
	.size	xlang_sys_read, .-xlang_sys_read

	.globl	xlang_sys_close
	.type	xlang_sys_close, @function
xlang_sys_close:
	mov	%edi, %edi
	mov	$3, %eax
	syscall
	ret
	.size	xlang_sys_close, .-xlang_sys_close

	.globl	xlang_sys_exit
	.type	xlang_sys_exit, @function
xlang_sys_exit:
	mov	%edi, %edi
	mov	$60, %eax
	syscall
	hlt
	.size	xlang_sys_exit, .-xlang_sys_exit

	.globl	xlang_sys_open
	.type	xlang_sys_open, @function
xlang_sys_open:
	# 【Why 不做 mov %edi,%edi】open 首参是 path: *u8（64 位指针），
	# mov %edi,%edi 会将高 32 位清零导致 EFAULT。其他 stub 的首参是 fd:i32，
	# mov %edi,%edi 用于零扩展 32 位整数，此处不适用。
	mov	$2, %eax
	syscall
	ret
	.size	xlang_sys_open, .-xlang_sys_open

	.globl	xlang_sys_openat
	.type	xlang_sys_openat, @function
xlang_sys_openat:
	mov	%rcx, %r10
	mov	$257, %eax
	syscall
	ret
	.size	xlang_sys_openat, .-xlang_sys_openat

	.globl	xlang_sys_mmap
	.type	xlang_sys_mmap, @function
xlang_sys_mmap:
	mov	%rcx, %r10
	mov	$9, %eax
	syscall
	ret
	.size	xlang_sys_mmap, .-xlang_sys_mmap

	.globl	xlang_sys_munmap
	.type	xlang_sys_munmap, @function
xlang_sys_munmap:
	mov	$11, %eax
	syscall
	ret
	.size	xlang_sys_munmap, .-xlang_sys_munmap

	.globl	xlang_sys_socket
	.type	xlang_sys_socket, @function
xlang_sys_socket:
	mov	%edi, %edi
	mov	$41, %eax
	syscall
	ret
	.size	xlang_sys_socket, .-xlang_sys_socket

	.globl	xlang_sys_connect
	.type	xlang_sys_connect, @function
xlang_sys_connect:
	mov	%edi, %edi
	mov	$42, %eax
	syscall
	ret
	.size	xlang_sys_connect, .-xlang_sys_connect

	.globl	xlang_sys_accept
	.type	xlang_sys_accept, @function
xlang_sys_accept:
	mov	%edi, %edi
	mov	$43, %eax
	syscall
	ret
	.size	xlang_sys_accept, .-xlang_sys_accept

	.globl	xlang_sys_bind
	.type	xlang_sys_bind, @function
xlang_sys_bind:
	mov	%edi, %edi
	mov	$49, %eax
	syscall
	ret
	.size	xlang_sys_bind, .-xlang_sys_bind

	.globl	xlang_sys_listen
	.type	xlang_sys_listen, @function
xlang_sys_listen:
	mov	%edi, %edi
	mov	$50, %eax
	syscall
	ret
	.size	xlang_sys_listen, .-xlang_sys_listen
