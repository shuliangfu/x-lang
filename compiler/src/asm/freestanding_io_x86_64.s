/**
 * freestanding_io_x86_64.s — Linux x86_64 无 libc syscall I/O（S4 freestanding / B-14 v1）
 *
 * shux_sys_write/read/close/exit → Linux write/read/close/exit syscalls。
 * System V AMD64 ABI：rax=nr；args 依次 rdi, rsi, rdx, r10, r8, r9。
 */
	.text
	.globl	shux_sys_write
	.type	shux_sys_write, @function
shux_sys_write:
	mov	%edi, %edi
	mov	$1, %eax
	syscall
	ret
	.size	shux_sys_write, .-shux_sys_write

	.globl	shux_sys_read
	.type	shux_sys_read, @function
shux_sys_read:
	mov	%edi, %edi
	mov	$0, %eax
	syscall
	ret
	.size	shux_sys_read, .-shux_sys_read

	.globl	shux_sys_close
	.type	shux_sys_close, @function
shux_sys_close:
	mov	%edi, %edi
	mov	$3, %eax
	syscall
	ret
	.size	shux_sys_close, .-shux_sys_close

	.globl	shux_sys_exit
	.type	shux_sys_exit, @function
shux_sys_exit:
	mov	%edi, %edi
	mov	$60, %eax
	syscall
	hlt
	.size	shux_sys_exit, .-shux_sys_exit

	.globl	shux_sys_open
	.type	shux_sys_open, @function
shux_sys_open:
	mov	%edi, %edi
	mov	$2, %eax
	syscall
	ret
	.size	shux_sys_open, .-shux_sys_open

	.globl	shux_sys_openat
	.type	shux_sys_openat, @function
shux_sys_openat:
	mov	%rcx, %r10
	mov	$257, %eax
	syscall
	ret
	.size	shux_sys_openat, .-shux_sys_openat

	.globl	shux_sys_mmap
	.type	shux_sys_mmap, @function
shux_sys_mmap:
	mov	%rcx, %r10
	mov	$9, %eax
	syscall
	ret
	.size	shux_sys_mmap, .-shux_sys_mmap

	.globl	shux_sys_munmap
	.type	shux_sys_munmap, @function
shux_sys_munmap:
	mov	$11, %eax
	syscall
	ret
	.size	shux_sys_munmap, .-shux_sys_munmap

	.globl	shux_sys_socket
	.type	shux_sys_socket, @function
shux_sys_socket:
	mov	%edi, %edi
	mov	$41, %eax
	syscall
	ret
	.size	shux_sys_socket, .-shux_sys_socket

	.globl	shux_sys_connect
	.type	shux_sys_connect, @function
shux_sys_connect:
	mov	%edi, %edi
	mov	$42, %eax
	syscall
	ret
	.size	shux_sys_connect, .-shux_sys_connect

	.globl	shux_sys_accept
	.type	shux_sys_accept, @function
shux_sys_accept:
	mov	%edi, %edi
	mov	$43, %eax
	syscall
	ret
	.size	shux_sys_accept, .-shux_sys_accept

	.globl	shux_sys_bind
	.type	shux_sys_bind, @function
shux_sys_bind:
	mov	%edi, %edi
	mov	$49, %eax
	syscall
	ret
	.size	shux_sys_bind, .-shux_sys_bind

	.globl	shux_sys_listen
	.type	shux_sys_listen, @function
shux_sys_listen:
	mov	%edi, %edi
	mov	$50, %eax
	syscall
	ret
	.size	shux_sys_listen, .-shux_sys_listen
