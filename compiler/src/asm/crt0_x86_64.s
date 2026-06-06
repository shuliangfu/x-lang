# crt0_x86_64.s - 无 C 自举: _start 与 driver_get_argv_i (x86_64 Linux)
# 替代 main.c / runtime_asm_build.c; 链接时用本 .o + main.su 等 .o + -lc

	.text
	.globl	_start
	.type	_start, @function
_start:
	mov	(%rsp), %edi
	lea	8(%rsp), %rsi
	and	$~15, %rsp
	sub	$8, %rsp
	call	entry
	mov	%eax, %edi
	mov	$60, %eax
	syscall
1:	jmp	1b
	.size	_start, .-_start

	.globl	driver_get_argv_i
	.type	driver_get_argv_i, @function
driver_get_argv_i:
	test	%rsi, %rsi
	jz	.Largv_fail
	test	%rcx, %rcx
	jz	.Largv_fail
	cmp	$1, %r8d
	jl	.Largv_fail
	test	%edx, %edx
	js	.Largv_fail
	cmp	%edi, %edx
	jge	.Largv_fail
	mov	%edx, %eax
	shl	$3, %rax
	add	%rax, %rsi
	mov	(%rsi), %rsi
	test	%rsi, %rsi
	jz	.Largv_fail
	lea	-1(%r8), %r8d
	xor	%eax, %eax
.Lcopy:
	cmp	%r8d, %eax
	jge	.Lcopy_done
	mov	(%rsi,%rax), %r9b
	test	%r9b, %r9b
	jz	.Lcopy_done
	mov	%r9b, (%rcx,%rax)
	inc	%eax
	jmp	.Lcopy
.Lcopy_done:
	movb	$0, (%rcx,%rax)
	ret
.Largv_fail:
	mov	$-1, %eax
	ret
	.size	driver_get_argv_i, .-driver_get_argv_i
