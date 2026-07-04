/**
 * crt0_darwin_x86_64.s — Darwin x86_64 Mach-O：无 C 自举入口（Phase E-04 v20）
 *
 * 文件职责：提供 _start 与 driver_get_argv_i，替代 main.c / main_driver.o。
 * 所属模块：compiler asm 运行时；bootstrap-driver-seed 在 Darwin x86_64 默认链入。
 * 重要约定：_start 调 main_entry（driver_x.o）；链接须 -e _start -nostartfiles。
 */

	.section __TEXT,__text,regular,pure_instructions

	.globl _start
_start:
	movl (%rsp), %edi
	leaq 8(%rsp), %rsi
	andq $-16, %rsp
	call _main_entry
	movq %rax, %rdi
	call _exit

	.globl _driver_get_argv_i
_driver_get_argv_i:
	testq %rsi, %rsi
	jz .Largv_fail
	testq %rcx, %rcx
	jz .Largv_fail
	cmpl $1, %r8d
	jl .Largv_fail
	testl %edx, %edx
	js .Largv_fail
	cmpl %edi, %edx
	jge .Largv_fail
	movl %edx, %eax
	shlq $3, %rax
	addq %rax, %rsi
	movq (%rsi), %rsi
	testq %rsi, %rsi
	jz .Largv_fail
	leal -1(%r8), %r8d
	xorl %eax, %eax
.Lcopy:
	cmpl %r8d, %eax
	jge .Lcopy_done
	movb (%rsi,%rax), %r9b
	testb %r9b, %r9b
	jz .Lcopy_done
	movb %r9b, (%rcx,%rax)
	incl %eax
	jmp .Lcopy
.Lcopy_done:
	movb $0, (%rcx,%rax)
	ret
.Largv_fail:
	movl $-1, %eax
	ret
