/* 10.46: PE link stubs for faces Linux tip-peel provides but Win leftover
 * egg / provider thins leave U. No host-cc .c. PLATFORM: WINDOWS. */
	.text
	.globl	pipeline_asm_emit_return_elf_impl_prev
	.def	pipeline_asm_emit_return_elf_impl_prev;	.scl	2;	.type	32;	.endef
	.def	pipeline_asm_emit_return_elf_impl;	.scl	2;	.type	32;	.endef
pipeline_asm_emit_return_elf_impl_prev:
	jmp	pipeline_asm_emit_return_elf_impl

	.globl	glue_lane_f32_lit_dest_set
	.def	glue_lane_f32_lit_dest_set;	.scl	2;	.type	32;	.endef
glue_lane_f32_lit_dest_set:
	/* Win64: rcx = value */
	movq	%rcx, .L_lane_dest(%rip)
	ret

	.globl	glue_lane_f32_lit_dest_get
	.def	glue_lane_f32_lit_dest_get;	.scl	2;	.type	32;	.endef
glue_lane_f32_lit_dest_get:
	movq	.L_lane_dest(%rip), %rax
	ret

	.globl	pipe_modlet_float_expr_trunc_i32
	.def	pipe_modlet_float_expr_trunc_i32;	.scl	2;	.type	32;	.endef
pipe_modlet_float_expr_trunc_i32:
	xorl	%eax, %eax
	ret

	.globl	pipe_modlet_fold_f64_elem_bits
	.def	pipe_modlet_fold_f64_elem_bits;	.scl	2;	.type	32;	.endef
pipe_modlet_fold_f64_elem_bits:
	xorl	%eax, %eax
	ret

	.globl	pipeline_lane_shr_is_arith
	.def	pipeline_lane_shr_is_arith;	.scl	2;	.type	32;	.endef
pipeline_lane_shr_is_arith:
	xorl	%eax, %eax
	ret

	.data
	.align	8
.L_lane_dest:
	.quad	0

.text
/* 10.46: thin real driver_fs_open_* (not full runtime_driver.o).
 * Win64: rcx=path, edx=path_len. Copy to stack NUL buf; call open.
 * Flags match rt_fs_open_call.x WINDOWS + RIO_O_BINARY for byte-stable I/O.
 * O_WRONLY|O_CREAT|O_TRUNC|O_BINARY = 1|0x100|0x200|0x8000 = 0x8301.
 * O_RDONLY|O_BINARY = 0|0x8000 = 0x8000. mode 0644 = 420.
 * PLATFORM: WINDOWS. */
	.globl	driver_fs_open_write
	.def	driver_fs_open_write;	.scl	2;	.type	32;	.endef
	.def	open;	.scl	2;	.type	32;	.endef
driver_fs_open_write:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rbx
	pushq	%rsi
	pushq	%rdi
	subq	$0x228, %rsp
	movl	%edx, %ebx
	movq	%rcx, %rsi
	testl	%ebx, %ebx
	jle	.Lfs_ow_fail
	cmpl	$512, %ebx
	jge	.Lfs_ow_fail
	testq	%rsi, %rsi
	je	.Lfs_ow_fail
	leaq	-0x210(%rbp), %rdi
	movl	%ebx, %ecx
	/* byte copy path[0..len) → stack buf */
.Lfs_ow_copy:
	testl	%ecx, %ecx
	je	.Lfs_ow_nul
	movb	(%rsi), %al
	movb	%al, (%rdi)
	incq	%rsi
	incq	%rdi
	decl	%ecx
	jmp	.Lfs_ow_copy
.Lfs_ow_nul:
	movb	$0, (%rdi)
	leaq	-0x210(%rbp), %rcx
	movl	$0x8301, %edx
	movl	$420, %r8d
	subq	$0x20, %rsp
	call	open
	addq	$0x20, %rsp
	addq	$0x228, %rsp
	popq	%rdi
	popq	%rsi
	popq	%rbx
	popq	%rbp
	ret
.Lfs_ow_fail:
	movl	$-1, %eax
	addq	$0x228, %rsp
	popq	%rdi
	popq	%rsi
	popq	%rbx
	popq	%rbp
	ret

	.globl	driver_fs_open_read_path
	.def	driver_fs_open_read_path;	.scl	2;	.type	32;	.endef
driver_fs_open_read_path:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%rbx
	pushq	%rsi
	pushq	%rdi
	subq	$0x228, %rsp
	movl	%edx, %ebx
	movq	%rcx, %rsi
	testl	%ebx, %ebx
	jle	.Lfs_or_fail
	cmpl	$512, %ebx
	jge	.Lfs_or_fail
	testq	%rsi, %rsi
	je	.Lfs_or_fail
	leaq	-0x210(%rbp), %rdi
	movl	%ebx, %ecx
.Lfs_or_copy:
	testl	%ecx, %ecx
	je	.Lfs_or_nul
	movb	(%rsi), %al
	movb	%al, (%rdi)
	incq	%rsi
	incq	%rdi
	decl	%ecx
	jmp	.Lfs_or_copy
.Lfs_or_nul:
	movb	$0, (%rdi)
	leaq	-0x210(%rbp), %rcx
	movl	$0x8000, %edx
	xorl	%r8d, %r8d
	subq	$0x20, %rsp
	call	open
	addq	$0x20, %rsp
	addq	$0x228, %rsp
	popq	%rdi
	popq	%rsi
	popq	%rbx
	popq	%rbp
	ret
.Lfs_or_fail:
	movl	$-1, %eax
	addq	$0x228, %rsp
	popq	%rdi
	popq	%rsi
	popq	%rbx
	popq	%rbp
	ret
