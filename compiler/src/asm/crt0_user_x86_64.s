/**
 * crt0_user_x86_64.s — Linux x86_64 用户程序 freestanding 入口（S4）
 *
 * 提供 _start：保存 argc/argv → call main → syscall exit(status)。
 * 与编译器自举用 crt0_x86_64.s（call entry）分离；用户 .x 经 asm 后端产出 main（Linux ELF 裸名）。
 * 链接示例：ld -nostdlib -static crt0_user.o runtime_panic.o prog.o -o prog
 */
	.text
	.globl	_start
	.type	_start, @function
_start:
	xor	%rbp, %rbp
	mov	(%rsp), %edi
	lea	8(%rsp), %rsi
	and	$~15, %rsp
	call	main
	mov	%eax, %edi
	mov	$60, %eax
	syscall
1:	jmp	1b
	.size	_start, .-_start
