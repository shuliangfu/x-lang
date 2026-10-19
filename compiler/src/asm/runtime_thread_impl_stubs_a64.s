/* Cap tip leftover: Cap tip pure runtime_thread_glue.x emits _c wrappers that
 * U on *_impl. Provide weak null/_impl stubs (prefer asm; no host-cc seed).
 * Real seed rest strong wins when present. PLATFORM: MACOS|ARM64. */
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

	IMPL_PTR	_thread_create_impl
	IMPL_PTR	_thread_create_with_stack_impl
	IMPL_I32	_thread_join_impl
	IMPL_PTR	_thread_self_impl
	IMPL_I32	_thread_set_affinity_impl
	IMPL_I32	_thread_set_affinity_self_impl
	IMPL_I32	_thread_set_name_self_impl
	IMPL_I32	_thread_set_qos_class_self_impl
	IMPL_PTR	_thread_dummy_entry_ptr_impl
	IMPL_I32	_thread_pool_start_impl
	IMPL_I32	_thread_pool_submit_impl
	IMPL_I32	_thread_pool_drain_impl
	IMPL_I32	_thread_pool_stop_impl
	IMPL_I32	_thread_pool_pending_impl
	IMPL_I32	_xlang_cpu_set_impl
	IMPL_I32	_xlang_cpu_zero_impl
