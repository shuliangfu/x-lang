/* Cap tip leftover: guarantee the two run-net UNDEFs without host-cc.
 * Prefer asm. Strong Cap tip pure glue wins when linked first. */
	.globl	_thread_set_qos_class_self_c
	.weak_definition _thread_set_qos_class_self_c
	.p2align	2
_thread_set_qos_class_self_c:
	mov	w0, #-1
	ret

	.globl	_xlang_net_worker_accept_entry_ptr_c
	.weak_definition _xlang_net_worker_accept_entry_ptr_c
	.p2align	2
_xlang_net_worker_accept_entry_ptr_c:
	mov	x0, xzr
	ret
