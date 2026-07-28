// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// R2 migration of runtime_test_fn_invoke: test function pointer invoke glue.
//
// Architecture (thin + rest):
//   - thin (.x): public test_call_i32_void_c wrapper. Receives the function
//     address as usize (Xlang cannot express void* → fnptr cast), validates
//     non-null, and forwards to the C-side _impl_c bridge that performs the
//     actual indirect call.
//   - rest (.from_x.c): test_call_i32_void_impl_c bridge that casts the
//     uintptr_t back to `int32_t (*)(void)` and invokes it.
//
// Why thin+rest (not DIRECT): Xlang cannot express the C cast
// `((int32_t (*)(void))fn)()` from a usize/void* to a function pointer and
// invoke it. The indirect call must stay in C. Only the public wrapper is
// exposed from .x.
//
// PLATFORM: SHARED — no OS dependencies; pure computation wrapper.
// Build: standalone .o (not embedded in composite rule).

// runtime_test_fn_invoke_x_doc_anchor: see function docblock below.

/** Exported function `runtime_test_fn_invoke_x_doc_anchor`.
 * Anchor for codegen discovery of this TU. Returns 0.
 * @return i32 always 0
 */
export function runtime_test_fn_invoke_x_doc_anchor(): i32 {
  return 0;
}

// ---------------------------------------------------------------------------
// Bridge declaration for the rest-side _impl function. The rest side casts
// the uintptr_t back to a function pointer and invokes it.
// ---------------------------------------------------------------------------

export extern "C" function test_call_i32_void_impl_c(fn: u64): i32;

/**
 * Invokes a no-argument test function returning i32 via its address.
 *
 * Validates that the function address is non-null, then forwards to the
 * C-side _impl_c bridge that performs the actual indirect call
 * (`((int32_t (*)(void))fn)()`). The cast from usize to function pointer
 * cannot be expressed in .x, so it stays in C.
 *
 * @param fn function address as u64 (0 is invalid)
 * @return the i32 return value of fn(); -1 if fn is 0
 */
#[no_mangle]
export function test_call_i32_void_c(fn: u64): i32 {
  if (fn == 0) { return 0 - 1; }
  unsafe { return test_call_i32_void_impl_c(fn); }
}
