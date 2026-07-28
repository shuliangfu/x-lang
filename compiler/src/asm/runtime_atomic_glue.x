// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_atomic_glue.x — OS atomic glue public API
// R2 migration: all public API functions defined here with #[no_mangle]
// OS bridge implementations (_impl) are in seeds/runtime_atomic_glue.from_x.c

export extern "C" function atomic_load_i32_impl(ptr: *i32): i32;
export extern "C" function atomic_store_i32_impl(ptr: *i32, val: i32): void;
export extern "C" function atomic_compare_exchange_i32_impl(ptr: *i32, expected: *i32, desired: i32): i32;
export extern "C" function atomic_fetch_add_i32_impl(ptr: *i32, delta: i32): i32;
export extern "C" function atomic_fetch_sub_i32_impl(ptr: *i32, delta: i32): i32;

export extern "C" function atomic_load_u32_impl(ptr: *u32): u32;
export extern "C" function atomic_store_u32_impl(ptr: *u32, val: u32): void;
export extern "C" function atomic_compare_exchange_u32_impl(ptr: *u32, expected: *u32, desired: u32): i32;
export extern "C" function atomic_fetch_add_u32_impl(ptr: *u32, delta: u32): u32;

export extern "C" function atomic_load_i64_impl(ptr: *i64): i64;
export extern "C" function atomic_store_i64_impl(ptr: *i64, val: i64): void;
export extern "C" function atomic_fetch_add_i64_impl(ptr: *i64, delta: i64): i64;
export extern "C" function atomic_fetch_sub_i64_impl(ptr: *i64, delta: i64): i64;
export extern "C" function atomic_compare_exchange_i64_impl(ptr: *i64, expected: *i64, desired: i64): i32;

export extern "C" function atomic_load_u64_impl(ptr: *u64): u64;
export extern "C" function atomic_store_u64_impl(ptr: *u64, val: u64): void;
export extern "C" function atomic_fetch_add_u64_impl(ptr: *u64, delta: u64): u64;
export extern "C" function atomic_fetch_sub_u64_impl(ptr: *u64, delta: u64): u64;
export extern "C" function atomic_compare_exchange_u64_impl(ptr: *u64, expected: *u64, desired: u64): i32;

export extern "C" function atomic_fence_seq_cst_impl(): void;
export extern "C" function atomic_fence_acquire_impl(): void;
export extern "C" function atomic_fence_release_impl(): void;

export extern "C" function atomic_load_i16_impl(ptr: *i16): i16;
export extern "C" function atomic_store_i16_impl(ptr: *i16, val: i16): void;
export extern "C" function atomic_fetch_add_i16_impl(ptr: *i16, delta: i16): i16;
export extern "C" function atomic_compare_exchange_i16_impl(ptr: *i16, expected: *i16, desired: i16): i32;

export extern "C" function atomic_load_u16_impl(ptr: *u16): u16;
export extern "C" function atomic_store_u16_impl(ptr: *u16, val: u16): void;
export extern "C" function atomic_fetch_add_u16_impl(ptr: *u16, delta: u16): u16;
export extern "C" function atomic_compare_exchange_u16_impl(ptr: *u16, expected: *u16, desired: u16): i32;

export function runtime_atomic_glue_x_doc_anchor(): i32 {
  return 0;
}

#[no_mangle]
export function atomic_load_i32_c(ptr: *i32): i32 {
  unsafe { return atomic_load_i32_impl(ptr); }
}

#[no_mangle]
export function atomic_store_i32_c(ptr: *i32, val: i32): void {
  unsafe { atomic_store_i32_impl(ptr, val); }
}

#[no_mangle]
export function atomic_compare_exchange_i32_c(ptr: *i32, expected: *i32, desired: i32): i32 {
  unsafe { return atomic_compare_exchange_i32_impl(ptr, expected, desired); }
}

#[no_mangle]
export function atomic_fetch_add_i32_c(ptr: *i32, delta: i32): i32 {
  unsafe { return atomic_fetch_add_i32_impl(ptr, delta); }
}

#[no_mangle]
export function atomic_fetch_sub_i32_c(ptr: *i32, delta: i32): i32 {
  unsafe { return atomic_fetch_sub_i32_impl(ptr, delta); }
}

#[no_mangle]
export function atomic_load_u32_c(ptr: *u32): u32 {
  unsafe { return atomic_load_u32_impl(ptr); }
}

#[no_mangle]
export function atomic_store_u32_c(ptr: *u32, val: u32): void {
  unsafe { atomic_store_u32_impl(ptr, val); }
}

#[no_mangle]
export function atomic_compare_exchange_u32_c(ptr: *u32, expected: *u32, desired: u32): i32 {
  unsafe { return atomic_compare_exchange_u32_impl(ptr, expected, desired); }
}

#[no_mangle]
export function atomic_fetch_add_u32_c(ptr: *u32, delta: u32): u32 {
  unsafe { return atomic_fetch_add_u32_impl(ptr, delta); }
}

#[no_mangle]
export function atomic_load_i64_c(ptr: *i64): i64 {
  unsafe { return atomic_load_i64_impl(ptr); }
}

#[no_mangle]
export function atomic_store_i64_c(ptr: *i64, val: i64): void {
  unsafe { atomic_store_i64_impl(ptr, val); }
}

#[no_mangle]
export function atomic_fetch_add_i64_c(ptr: *i64, delta: i64): i64 {
  unsafe { return atomic_fetch_add_i64_impl(ptr, delta); }
}

#[no_mangle]
export function atomic_fetch_sub_i64_c(ptr: *i64, delta: i64): i64 {
  unsafe { return atomic_fetch_sub_i64_impl(ptr, delta); }
}

#[no_mangle]
export function atomic_compare_exchange_i64_c(ptr: *i64, expected: *i64, desired: i64): i32 {
  unsafe { return atomic_compare_exchange_i64_impl(ptr, expected, desired); }
}

#[no_mangle]
export function atomic_load_u64_c(ptr: *u64): u64 {
  unsafe { return atomic_load_u64_impl(ptr); }
}

#[no_mangle]
export function atomic_store_u64_c(ptr: *u64, val: u64): void {
  unsafe { atomic_store_u64_impl(ptr, val); }
}

#[no_mangle]
export function atomic_fetch_add_u64_c(ptr: *u64, delta: u64): u64 {
  unsafe { return atomic_fetch_add_u64_impl(ptr, delta); }
}

#[no_mangle]
export function atomic_fetch_sub_u64_c(ptr: *u64, delta: u64): u64 {
  unsafe { return atomic_fetch_sub_u64_impl(ptr, delta); }
}

#[no_mangle]
export function atomic_compare_exchange_u64_c(ptr: *u64, expected: *u64, desired: u64): i32 {
  unsafe { return atomic_compare_exchange_u64_impl(ptr, expected, desired); }
}

#[no_mangle]
export function atomic_fence_seq_cst_c(): void {
  unsafe { atomic_fence_seq_cst_impl(); }
}

#[no_mangle]
export function atomic_fence_acquire_c(): void {
  unsafe { atomic_fence_acquire_impl(); }
}

#[no_mangle]
export function atomic_fence_release_c(): void {
  unsafe { atomic_fence_release_impl(); }
}

#[no_mangle]
export function atomic_load_i16_c(ptr: *i16): i16 {
  unsafe { return atomic_load_i16_impl(ptr); }
}

#[no_mangle]
export function atomic_store_i16_c(ptr: *i16, val: i16): void {
  unsafe { atomic_store_i16_impl(ptr, val); }
}

#[no_mangle]
export function atomic_fetch_add_i16_c(ptr: *i16, delta: i16): i16 {
  unsafe { return atomic_fetch_add_i16_impl(ptr, delta); }
}

#[no_mangle]
export function atomic_compare_exchange_i16_c(ptr: *i16, expected: *i16, desired: i16): i32 {
  unsafe { return atomic_compare_exchange_i16_impl(ptr, expected, desired); }
}

#[no_mangle]
export function atomic_load_u16_c(ptr: *u16): u16 {
  unsafe { return atomic_load_u16_impl(ptr); }
}

#[no_mangle]
export function atomic_store_u16_c(ptr: *u16, val: u16): void {
  unsafe { atomic_store_u16_impl(ptr, val); }
}

#[no_mangle]
export function atomic_fetch_add_u16_c(ptr: *u16, delta: u16): u16 {
  unsafe { return atomic_fetch_add_u16_impl(ptr, delta); }
}

#[no_mangle]
export function atomic_compare_exchange_u16_c(ptr: *u16, expected: *u16, desired: u16): i32 {
  unsafe { return atomic_compare_exchange_u16_impl(ptr, expected, desired); }
}
