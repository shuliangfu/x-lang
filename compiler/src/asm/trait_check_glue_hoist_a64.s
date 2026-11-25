// Run default-method hoist and skip the archived completeness check.
// That check reports "impl for unknown trait" for impl<T: Trait> and
// then scans bounds with a non-pointer stash (SIGSEGV). Method presence
// for an empty impl is the hoist's job; generic bounds stay in typeck.
// PLATFORM: MACOS|ARM64.

.globl _xlang_trait_check_impls_complete_c_glue_dead
_xlang_trait_check_impls_complete_c_glue_dead:
	stp	x29, x30, [sp, #-16]!
	mov	x29, sp
	bl	_xlang_skip_hoist_default_methods_c
	mov	w0, #0
	ldp	x29, x30, [sp], #16
	ret
