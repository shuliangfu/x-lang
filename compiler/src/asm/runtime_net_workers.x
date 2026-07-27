// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// R2 migration of runtime_net_workers: accept worker thread entry glue.
//
// Architecture (thin + rest):
//   - thin (.x): public xlang_net_worker_accept_entry_ptr_c wrapper +
//     weak thread_set_affinity_self_c stub. The wrapper forwards to a C-side
//     _impl_c bridge that returns the address of the thread entry function.
//   - rest (.from_x.c): xlang_net_worker_accept_loop (the void *(*)(void *)
//     thread body) + xlang_net_worker_accept_entry_ptr_impl_c (returns the
//     function pointer as uintptr_t).
//
// Why thin+rest (not DIRECT): the thread entry function has C ABI signature
// `void *(*)(void *)` which .x cannot express (no variadic void* cast). The
// loop body calls net_accept_many_c / net_close_socket_c in an infinite loop
// and must stay in C. Only the public ptr-returning wrapper is exposed from
// .x; the actual function pointer is obtained via the _impl_c bridge.
//
// PLATFORM: SHARED net — accept loop uses POSIX sockets via
// net_accept_many_c / net_close_socket_c (already platform-abstracted).
// Build: standalone .o (not embedded in net.o composite rule).

// runtime_net_workers_x_doc_anchor: see function docblock below.

/** Exported function `runtime_net_workers_x_doc_anchor`.
 * Anchor for codegen discovery of this TU. Returns 0.
 * @return i32 always 0
 */
export function runtime_net_workers_x_doc_anchor(): i32 {
  return 0;
}

// ---------------------------------------------------------------------------
// Weak stub for optional thread affinity binding. When a user links
// std/thread/thread.o, the strong #[no_mangle] thread_set_affinity_self_c
// there overrides this weak default. Mirrors XLANG_WEAK semantics in C seed.
// ---------------------------------------------------------------------------

/**
 * Weak default for thread CPU affinity binding. Returns 0 (no-op success)
 * unless overridden by std.thread's strong #[no_mangle] definition at link
 * time.
 * @param cpu_index CPU index to pin the calling thread to
 * @return 0 on success (weak default always succeeds with no-op);
 *         negative on error from strong override
 */
#[no_mangle]
export function thread_set_affinity_self_c(cpu_index: i32): i32 {
  // Weak default: no-op success. Strong override in std.thread wins at link.
  return 0;
}

// ---------------------------------------------------------------------------
// Bridge declaration for the rest-side _impl function. The rest side keeps
// the thread entry function pointer in C (void* ABI) and returns it as
// uintptr_t so .x can pass it to thread_create_c.
// ---------------------------------------------------------------------------

export extern "C" function xlang_net_worker_accept_entry_ptr_impl_c(): u64;

/**
 * Returns the address of the accept worker thread entry function
 * (xlang_net_worker_accept_loop) as uintptr_t. Called by std.net.workers to
 * obtain the thread entry point for thread_create_c.
 *
 * The actual thread body (infinite accept_many + close loop) lives in the C
 * rest side because .x cannot express the `void *(*)(void *)` C ABI signature.
 *
 * @return function pointer to xlang_net_worker_accept_loop, as uintptr_t
 */
#[no_mangle]
export function xlang_net_worker_accept_entry_ptr_c(): u64 {
  unsafe { return xlang_net_worker_accept_entry_ptr_impl_c(); }
}
