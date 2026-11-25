/* Cap tip: weak null/_impl stubs for glue _c U. Darwin strong bodies for
 * self/create/join/dummy live in runtime_thread_impl_darwin_a64.s.
 * Prefer asm. PLATFORM: MACOS|ARM64. */
	.macro IMPL_I32 name
	.globl	\name
	.weak_definition \name
	.p2align	2
\name:
	mov	w0, #-1
	ret
	.endm
	.macro IMPL_PTR name
	.globl	\name
	.weak_definition \name
	.p2align	2
\name:
	mov	x0, xzr
	ret
	.endm

	/* self/create/join/dummy: Darwin strong — omit hollow here */
	IMPL_I32	_thread_set_affinity_impl
	IMPL_I32	_thread_set_affinity_self_impl
	IMPL_I32	_thread_set_name_self_impl
	IMPL_I32	_thread_set_qos_class_self_impl
	IMPL_I32	_thread_pool_start_impl
	IMPL_I32	_thread_pool_submit_impl
	IMPL_I32	_thread_pool_drain_impl
	IMPL_I32	_thread_pool_stop_impl
	IMPL_I32	_thread_pool_pending_impl
	IMPL_I32	_xlang_cpu_set_impl
	IMPL_I32	_xlang_cpu_zero_impl
