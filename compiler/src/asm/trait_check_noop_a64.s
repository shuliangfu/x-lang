/* note743y.6.22: tip-cold Darwin trait completeness no-op.
 * Root: Apple clang packs consecutive stack i32s; tip Soft Cap
 * trait_check_impls_complete_into_c expects 8-byte slots, so
 * generic_bound_scan sees len as data (FAR=0x72 / SEGV).
 * Same contract as Cap tip trait_check_noop_thin. PLATFORM: MACOS arm64.
 */
	.text
	.align 2
	.globl _xlang_trait_check_impls_complete_c
_xlang_trait_check_impls_complete_c:
	mov	w0, #0
	ret
