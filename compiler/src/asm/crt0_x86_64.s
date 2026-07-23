# crt0_x86_64.s - freestanding / hybrid entry: _start (x86_64 Linux)
# PLATFORM: LINUX — Linux x86_64 SysV; not used on Darwin (see crt0_darwin_x86_64.s / arm64).
# E-04 v19: _start calls main_entry (driver_x.o / bridge weak stub); replaces main.c.
# NL-07 v5: bootstrap_init_static_tls (%fs:0x28 stack canary) then bootstrap_init_environ.
# NL-07 v6: argc/argv live in r12/r13; bootstrap stubs clobber rdi/rsi — restore before each call.
# NL-07 v7: keep SysV 16B stack alignment before C calls (do not extra sub $8).
#
# Exit path (2026-07-16, Stage2 + g05 dual topology):
#   Freestanding (build_xlang_asm / Stage2 gen2): links bootstrap_nostdlib_stubs — call
#   bootstrap_flush_stdio_and_exit (skips fflush on stub FILE*{fd}; static glibc _IO_fflush
#   on that stub SIGSEGVs).
#   Hosted/dynamic g05 product: does NOT link bootstrap_nostdlib_stubs (would hijack
#   stdout/malloc). Weak ref resolves to 0 → fflush@PLT real glibc streams then SYS_exit
#   (keeps -E buffer tail; historical 24KiB udp cold truncate).
#   PLATFORM: LINUX x86_64 only.

	.weak	bootstrap_flush_stdio_and_exit

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
	mov	%eax, %r12d
	/* Weak: non-zero only when bootstrap_nostdlib_stubs is in the link. */
	movabs	$bootstrap_flush_stdio_and_exit, %rax
	test	%rax, %rax
	jz	.Lhosted_fflush_exit
	mov	%r12d, %edi
	call	bootstrap_flush_stdio_and_exit
	/* noreturn; keep fallthrough safe */
	jmp	1f
.Lhosted_fflush_exit:
	/* g05 dynamic: real glibc stdout/stderr */
	mov	stdout(%rip), %rdi
	call	fflush@PLT
	mov	stderr(%rip), %rdi
	call	fflush@PLT
	mov	%r12d, %edi
	mov	$60, %eax
	syscall
1:	jmp	1b
	.size	_start, .-_start
