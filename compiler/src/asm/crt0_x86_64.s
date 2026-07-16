# crt0_x86_64.s - freestanding / hybrid entry: _start (x86_64 Linux)
# PLATFORM: LINUX — Linux x86_64 SysV; not used on Darwin (see crt0_darwin_x86_64.s / arm64).
# E-04 v19: _start calls main_entry (driver_x.o / bridge weak stub); replaces main.c.
# NL-07 v5: bootstrap_init_static_tls (%fs:0x28 stack canary) then bootstrap_init_environ.
# NL-07 v6: argc/argv live in r12/r13; bootstrap stubs clobber rdi/rsi — restore before each call.
# NL-07 v7: keep SysV 16B stack alignment before C calls (do not extra sub $8).
#
# Exit path (2026-07-16, fixed Stage2):
#   Hosted/dynamic g05 product links real glibc stdout; -E large output needs fflush before
#   SYS_exit or glibc buffers drop the tail (~24KiB false truncate on udp cold path).
#   Freestanding Stage2 gen2 also links bootstrap_nostdlib_stubs FILE* {int fd} for stdout
#   while a static glibc _IO_fflush may still be in the image — calling fflush on the stub
#   FILE* SIGSEGVs. Authority: bootstrap_flush_stdio_and_exit (null/stub-safe, then exit).

	.text
	.globl	_start
	.type	_start, @function
_start:
	mov	(%rsp), %r12d
	lea	8(%rsp), %r13
	and	$~15, %rsp
	mov	%r12d, %edi
	mov	%r13, %rsi
	call	bootstrap_init_static_tls
	mov	%r12d, %edi
	mov	%r13, %rsi
	call	bootstrap_init_environ
	mov	%r12d, %edi
	mov	%r13, %rsi
	call	main_entry
	/* main_entry return → edi; helper never returns. */
	mov	%eax, %edi
	call	bootstrap_flush_stdio_and_exit
1:	jmp	1b
	.size	_start, .-_start
