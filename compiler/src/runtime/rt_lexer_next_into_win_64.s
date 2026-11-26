/* Win tip Soft Cap: lexer_next_into dual-ABI shim (DIG 2026-11-09; s245).
 *
 * Tip PE parser_parse_one_function_impl (~110 call sites) passes:
 *   rcx=out, rdx=*Lexer, r8=*Fat{ptr,len}   (pointer ABI)
 * Tip PE lexer_next_buf_into / correct callers pass:
 *   rcx=out, rdx=lex.pos, r8=line|col, r9=*Fat  (by-value ABI)
 *
 * Heuristic: rdx >= 0x10000 => pointer ABI (source pos is always smaller
 * for practical inputs); else by-value.
 *
 * DIG s245: tipU lexer_next_impl (tipU-compiled) DEFERENCES rdx as
 * *Lexer (mov (%rdx),…) even though lexer.x says by-value Lexer. Soft Cap
 * must feed tipU next_impl POINTER ABI. Prior shim unpacked pointer→
 * by-value then jmp next_impl → SEGV on mov (%pos). Soft Cap now:
 *   pointer path: pass-through jmp next_impl
 *   by-value path: spill Lexer{pos,line|col} on stack, call next_impl
 *                 with rdx=&spill, r8=*Fat (from r9)
 * PLATFORM: WINDOWS|X86_64
 */
	.text
	.globl lexer_next_into
	.def lexer_next_into; .scl 2; .type 32; .endef
	.extern lexer_next_impl

	.p2align 4
lexer_next_into:
	cmpq	$0x10000, %rdx
	jae	.Lptr
	/* by-value → stack Lexer, then tipU pointer ABI into next_impl */
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$0x40, %rsp
	movq	%rdx, -0x20(%rbp)
	movq	%r8, -0x18(%rbp)
	leaq	-0x20(%rbp), %rdx
	movq	%r9, %r8
	subq	$0x20, %rsp
	call	lexer_next_impl
	leave
	ret
.Lptr:
	/* pointer ABI already matches tipU next_impl */
	jmp	lexer_next_impl
