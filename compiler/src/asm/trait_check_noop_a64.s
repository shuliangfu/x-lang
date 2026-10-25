/* Cap tip LINK_WINNER: hoist trait defaults only, then return 0.
 * Do NOT tail into glue_dead — on Cap tip that symbol still holds the
 * archived completeness body (bad stash → dyn_[N]T param mismatch).
 * PLATFORM: MACOS|ARM64.
 */
	.text
	.align 2
	.globl _xlang_trait_check_impls_complete_c
_xlang_trait_check_impls_complete_c:
	stp	x29, x30, [sp, #-16]!
	mov	x29, sp
	bl	_xlang_skip_hoist_default_methods_c
	mov	w0, #0
	ldp	x29, x30, [sp], #16
	ret
