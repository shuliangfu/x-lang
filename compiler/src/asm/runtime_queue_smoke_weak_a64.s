/* Cap tip leftover: queue.o keeps U sync_queue_contention_smoke_c (SyncQueue
 * path in monofile). Ondemand may miss contention.o or pull OS mutex UNDEFs.
 * Weak stub return 0; real contention.o strong wins. Prefer asm.
 * PLATFORM: MACOS|ARM64. */
	.globl	_sync_queue_contention_smoke_c
	.weak_definition _sync_queue_contention_smoke_c
	.p2align	2
_sync_queue_contention_smoke_c:
	mov	w0, #0
	ret
