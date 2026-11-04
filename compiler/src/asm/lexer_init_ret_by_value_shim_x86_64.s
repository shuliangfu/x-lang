/* knife256 / 10.2 + note743y.4 + note743y.5 + dual-ABI:
 * - Ret-by-value callers (parser_parse archaeology): expect Lexer in rax+rdx.
 * - Out-ptr callers (pipeline_source_slice tip peel): pass &Lex in rdi and
 *   read the stack slot after the call (ignore rax).
 * Always return empty Lexer in rax+rdx. If rdi!=0, also store 16 bytes to
 * *rdi — EXCEPT when rdi equals g_lex_src_data (parked source). Ret-by-value
 * callers leave the source pointer in rdi; storing empty Lexer there smashed
 * the first 16 source bytes ("export function ") → P001 / missing main.
 * A prior rsp-only guard skipped legitimate stack out-ptrs and SEGV'd in
 * lexer_next_body_into. PLATFORM: LINUX/MACOS x86_64
 */
#if defined(__APPLE__)
	.globl	_lexer_init
_lexer_init:
#else
	.globl	lexer_init
lexer_init:
#endif
	xorq	%rax, %rax
	movq	$0x100000001, %rdx
	testq	%rdi, %rdi
	jz	1f
	cmpq	g_lex_src_data(%rip), %rdi
	je	1f
	movq	%rax, (%rdi)
	movq	%rdx, 8(%rdi)
1:
	ret
