// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_atomic_glue_darwin.x — Darwin arm64 body of runtime_atomic_glue.o.
//
// Clang inlines __atomic_* on arm64, and this compiler cannot emit those
// instructions. libSystem exports the same compiler-rt helpers. The extern
// names carry three leading underscores because that is the Mach-O spelling
// of C __atomic_load_4 (and the same pattern for the other widths).
// __ATOMIC_SEQ_CST is 5. compare_exchange weak is 0, both orders are 5.
// __atomic_thread_fence is not exported, so every fence calls
// OSMemoryBarrier, a full barrier. A full barrier still orders acquire
// and release. Linux and Windows keep the C seed.
// PLATFORM: MACOS|DARWIN arm64.

extern function ___atomic_load_2(ptr: *u8, model: i32): u32;
extern function ___atomic_store_2(ptr: *u8, val: u32, model: i32): void;
extern function ___atomic_fetch_add_2(ptr: *u8, val: u32, model: i32): u32;
extern function ___atomic_compare_exchange_2(ptr: *u8, expected: *u8, desired: u32, weak: i32, success: i32, failure: i32): i32;
extern function ___atomic_load_4(ptr: *u8, model: i32): u32;
extern function ___atomic_store_4(ptr: *u8, val: u32, model: i32): void;
extern function ___atomic_fetch_add_4(ptr: *u8, val: u32, model: i32): u32;
extern function ___atomic_fetch_sub_4(ptr: *u8, val: u32, model: i32): u32;
extern function ___atomic_compare_exchange_4(ptr: *u8, expected: *u8, desired: u32, weak: i32, success: i32, failure: i32): i32;
extern function ___atomic_load_8(ptr: *u8, model: i32): u64;
extern function ___atomic_store_8(ptr: *u8, val: u64, model: i32): void;
extern function ___atomic_fetch_add_8(ptr: *u8, val: u64, model: i32): u64;
extern function ___atomic_fetch_sub_8(ptr: *u8, val: u64, model: i32): u64;
extern function ___atomic_compare_exchange_8(ptr: *u8, expected: *u8, desired: u64, weak: i32, success: i32, failure: i32): i32;
extern function OSMemoryBarrier(): void;

/**
 * Anchor for this Darwin atomic object.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function runtime_atomic_glue_darwin_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Seq-cst load of an i32.
 * @param ptr address of the cell; must be naturally aligned
 * @return i32 — value before any later store in this thread
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_load_i32_c(ptr: *i32): i32 {
  unsafe { return ___atomic_load_4(ptr as *u8, 5) as i32; }
  return 0;
}

/**
 * Seq-cst store of an i32.
 * @param ptr address of the cell
 * @param val value to store
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_store_i32_c(ptr: *i32, val: i32): void {
  unsafe { ___atomic_store_4(ptr as *u8, val as u32, 5); }
}

/**
 * Seq-cst strong compare-exchange of an i32.
 * On failure the libcall writes the observed value through expected.
 * @param ptr address of the cell
 * @param expected in/out expected value
 * @param desired value stored when the cell matches expected
 * @return i32 — 1 on success, 0 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_compare_exchange_i32_c(ptr: *i32, expected: *i32, desired: i32): i32 {
  unsafe {
    let p: *u8 = ptr as *u8;
    let e: *u8 = expected as *u8;
    let d: u32 = desired as u32;
    return ___atomic_compare_exchange_4(p, e, d, 0, 5, 5);
  }
  return 0;
}

/**
 * Seq-cst fetch-add of an i32. Returns the value before the add.
 * @param ptr address of the cell
 * @param delta addend, two's complement
 * @return i32 — previous value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_fetch_add_i32_c(ptr: *i32, delta: i32): i32 {
  unsafe { return ___atomic_fetch_add_4(ptr as *u8, delta as u32, 5) as i32; }
  return 0;
}

/**
 * Seq-cst fetch-sub of an i32. Returns the value before the subtract.
 * @param ptr address of the cell
 * @param delta subtrahend
 * @return i32 — previous value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_fetch_sub_i32_c(ptr: *i32, delta: i32): i32 {
  unsafe { return ___atomic_fetch_sub_4(ptr as *u8, delta as u32, 5) as i32; }
  return 0;
}

/**
 * Seq-cst load of a u32.
 * @param ptr address of the cell
 * @return u32 — loaded value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_load_u32_c(ptr: *u32): u32 {
  unsafe { return ___atomic_load_4(ptr as *u8, 5); }
  return 0;
}

/**
 * Seq-cst store of a u32.
 * @param ptr address of the cell
 * @param val value to store
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_store_u32_c(ptr: *u32, val: u32): void {
  unsafe { ___atomic_store_4(ptr as *u8, val, 5); }
}

/**
 * Seq-cst strong compare-exchange of a u32.
 * @param ptr address of the cell
 * @param expected in/out expected value
 * @param desired value stored on match
 * @return i32 — 1 on success, 0 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_compare_exchange_u32_c(ptr: *u32, expected: *u32, desired: u32): i32 {
  unsafe {
    let p: *u8 = ptr as *u8;
    let e: *u8 = expected as *u8;
    return ___atomic_compare_exchange_4(p, e, desired, 0, 5, 5);
  }
  return 0;
}

/**
 * Seq-cst fetch-add of a u32.
 * @param ptr address of the cell
 * @param delta addend
 * @return u32 — previous value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_fetch_add_u32_c(ptr: *u32, delta: u32): u32 {
  unsafe { return ___atomic_fetch_add_4(ptr as *u8, delta, 5); }
  return 0;
}

/**
 * Seq-cst load of an i64.
 * @param ptr address of the cell; must be 8-byte aligned
 * @return i64 — loaded value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_load_i64_c(ptr: *i64): i64 {
  unsafe { return ___atomic_load_8(ptr as *u8, 5) as i64; }
  return 0;
}

/**
 * Seq-cst store of an i64.
 * @param ptr address of the cell
 * @param val value to store
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_store_i64_c(ptr: *i64, val: i64): void {
  unsafe { ___atomic_store_8(ptr as *u8, val as u64, 5); }
}

/**
 * Seq-cst fetch-add of an i64.
 * @param ptr address of the cell
 * @param delta addend
 * @return i64 — previous value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_fetch_add_i64_c(ptr: *i64, delta: i64): i64 {
  unsafe { return ___atomic_fetch_add_8(ptr as *u8, delta as u64, 5) as i64; }
  return 0;
}

/**
 * Seq-cst fetch-sub of an i64.
 * @param ptr address of the cell
 * @param delta subtrahend
 * @return i64 — previous value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_fetch_sub_i64_c(ptr: *i64, delta: i64): i64 {
  unsafe { return ___atomic_fetch_sub_8(ptr as *u8, delta as u64, 5) as i64; }
  return 0;
}

/**
 * Seq-cst strong compare-exchange of an i64.
 * @param ptr address of the cell
 * @param expected in/out expected value
 * @param desired value stored on match
 * @return i32 — 1 on success, 0 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_compare_exchange_i64_c(ptr: *i64, expected: *i64, desired: i64): i32 {
  unsafe {
    let p: *u8 = ptr as *u8;
    let e: *u8 = expected as *u8;
    let d: u64 = desired as u64;
    return ___atomic_compare_exchange_8(p, e, d, 0, 5, 5);
  }
  return 0;
}

/**
 * Seq-cst load of a u64.
 * @param ptr address of the cell
 * @return u64 — loaded value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_load_u64_c(ptr: *u64): u64 {
  unsafe { return ___atomic_load_8(ptr as *u8, 5); }
  return 0;
}

/**
 * Seq-cst store of a u64.
 * @param ptr address of the cell
 * @param val value to store
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_store_u64_c(ptr: *u64, val: u64): void {
  unsafe { ___atomic_store_8(ptr as *u8, val, 5); }
}

/**
 * Seq-cst fetch-add of a u64.
 * @param ptr address of the cell
 * @param delta addend
 * @return u64 — previous value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_fetch_add_u64_c(ptr: *u64, delta: u64): u64 {
  unsafe { return ___atomic_fetch_add_8(ptr as *u8, delta, 5); }
  return 0;
}

/**
 * Seq-cst fetch-sub of a u64.
 * @param ptr address of the cell
 * @param delta subtrahend
 * @return u64 — previous value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_fetch_sub_u64_c(ptr: *u64, delta: u64): u64 {
  unsafe { return ___atomic_fetch_sub_8(ptr as *u8, delta, 5); }
  return 0;
}

/**
 * Seq-cst strong compare-exchange of a u64.
 * @param ptr address of the cell
 * @param expected in/out expected value
 * @param desired value stored on match
 * @return i32 — 1 on success, 0 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_compare_exchange_u64_c(ptr: *u64, expected: *u64, desired: u64): i32 {
  unsafe {
    let p: *u8 = ptr as *u8;
    let e: *u8 = expected as *u8;
    return ___atomic_compare_exchange_8(p, e, desired, 0, 5, 5);
  }
  return 0;
}

/**
 * Seq-cst thread fence. libSystem has no __atomic_thread_fence, so this
 * is OSMemoryBarrier.
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_fence_seq_cst_c(): void {
  unsafe { OSMemoryBarrier(); }
}

/**
 * Acquire fence. The barrier is the full OSMemoryBarrier.
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_fence_acquire_c(): void {
  unsafe { OSMemoryBarrier(); }
}

/**
 * Release fence. The barrier is the full OSMemoryBarrier.
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_fence_release_c(): void {
  unsafe { OSMemoryBarrier(); }
}

/**
 * Seq-cst load of an i16. The helper returns a zero-extended u32, so
 * values at or above 32768 are signed back into the i16 range.
 * @param ptr address of the cell; must be 2-byte aligned
 * @return i16 — loaded value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_load_i16_c(ptr: *i16): i16 {
  unsafe {
    let raw: u32 = ___atomic_load_2(ptr as *u8, 5);
    let wide: i32 = raw as i32;
    if wide >= 32768 {
      return (wide - 65536) as i16;
    }
    return wide as i16;
  }
  return 0;
}

/**
 * Seq-cst store of an i16. The helper keeps the low 16 bits.
 * @param ptr address of the cell
 * @param val value to store
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_store_i16_c(ptr: *i16, val: i16): void {
  unsafe { ___atomic_store_2(ptr as *u8, val as u32, 5); }
}

/**
 * Seq-cst fetch-add of an i16. Returns the previous value, sign-extended.
 * @param ptr address of the cell
 * @param delta addend
 * @return i16 — previous value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_fetch_add_i16_c(ptr: *i16, delta: i16): i16 {
  unsafe {
    let raw: u32 = ___atomic_fetch_add_2(ptr as *u8, delta as u32, 5);
    let wide: i32 = raw as i32;
    if wide >= 32768 {
      return (wide - 65536) as i16;
    }
    return wide as i16;
  }
  return 0;
}

/**
 * Seq-cst strong compare-exchange of an i16.
 * @param ptr address of the cell
 * @param expected in/out expected value
 * @param desired value stored on match
 * @return i32 — 1 on success, 0 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_compare_exchange_i16_c(ptr: *i16, expected: *i16, desired: i16): i32 {
  unsafe {
    let p: *u8 = ptr as *u8;
    let e: *u8 = expected as *u8;
    let d: u32 = desired as u32;
    return ___atomic_compare_exchange_2(p, e, d, 0, 5, 5);
  }
  return 0;
}

/**
 * Seq-cst load of a u16.
 * @param ptr address of the cell
 * @return u16 — loaded value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_load_u16_c(ptr: *u16): u16 {
  unsafe { return ___atomic_load_2(ptr as *u8, 5) as u16; }
  return 0;
}

/**
 * Seq-cst store of a u16.
 * @param ptr address of the cell
 * @param val value to store
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_store_u16_c(ptr: *u16, val: u16): void {
  unsafe { ___atomic_store_2(ptr as *u8, val as u32, 5); }
}

/**
 * Seq-cst fetch-add of a u16.
 * @param ptr address of the cell
 * @param delta addend
 * @return u16 — previous value
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_fetch_add_u16_c(ptr: *u16, delta: u16): u16 {
  unsafe { return ___atomic_fetch_add_2(ptr as *u8, delta as u32, 5) as u16; }
  return 0;
}

/**
 * Seq-cst strong compare-exchange of a u16.
 * @param ptr address of the cell
 * @param expected in/out expected value
 * @param desired value stored on match
 * @return i32 — 1 on success, 0 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function atomic_compare_exchange_u16_c(ptr: *u16, expected: *u16, desired: u16): i32 {
  unsafe {
    let p: *u8 = ptr as *u8;
    let e: *u8 = expected as *u8;
    let d: u32 = desired as u32;
    return ___atomic_compare_exchange_2(p, e, d, 0, 5, 5);
  }
  return 0;
}
