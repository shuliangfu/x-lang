// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// note
// note
// note

const option = import("core.option");

// PLATFORM: SHARED — the glue writes the 16-byte slice through out.
// The installed product cannot asm-emit a struct return.
extern function core_slice_i32_from_ptr_c(out: *[]i32, data: *i32, len: usize): void;
extern function core_subslice_i32_c(out: *[]i32, data: *i32, total_len: usize, start: usize, len: usize): void;
extern function core_slice_u8_from_ptr_c(out: *[]u8, data: *u8, len: usize): void;
extern function core_subslice_u8_c(out: *[]u8, data: *u8, total_len: usize, start: usize, len: usize): void;
extern function core_slice_u64_from_ptr_c(out: *[]u64, data: *u64, len: usize): void;
extern function core_subslice_u64_c(out: *[]u64, data: *u64, total_len: usize, start: usize, len: usize): void;

/* note */
export struct Split_i32 {
  left: []i32;
  right: []i32;
}

/* note */
export struct Split_u8 {
  left: []u8;
  right: []u8;
}

/* note */
export struct Split_u64 {
  left: []u64;
  right: []u64;
}

// ——— []i32 ———
/** `len_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function len_i32(s: []i32): usize { return s.length; }

/** `get_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function get_i32(s: []i32, i: usize): Option_i32 {
  let r: Option_i32 = { is_some: false, value: 0 };
  if (i >= s.length) {
    option.none_i32(&r);
    return r;
  }
  option.some_i32(&r, s.data[i]);
  return r;
}

/** `get_i32_unchecked`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function get_i32_unchecked(s: []i32, i: usize): i32 { return s.data[i]; }

/** `is_empty_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function is_empty_i32(s: []i32): i32 {
  if (s.length == 0 as usize) { return 1; }
  return 0;
}

/** `first_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function first_i32(s: []i32): Option_i32 {
  return get_i32(s, 0 as usize);
}

/** `last_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function last_i32(s: []i32): Option_i32 {
  if (s.length == 0 as usize) {
    let n: Option_i32 = { is_some: false, value: 0 };
    option.none_i32(&n);
    return n;
  }
  return get_i32(s, s.length - 1 as usize);
}

/** `subslice_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function subslice_i32(s: []i32, start: usize, len: usize): []i32 {
  let r: []i32;
  unsafe { core_subslice_i32_c(&r, s.data, s.length, start, len); }
  return r;
}

/** `split_at_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function split_at_i32(s: []i32, at: usize): Split_i32 {
  let at_clamped: usize = at;
  if (at_clamped > s.length) { at_clamped = s.length; }
  return {
    left: subslice_i32(s, 0 as usize, at_clamped),
    right: subslice_i32(s, at_clamped, s.length - at_clamped),
  };
}

/** `chunks_len_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function chunks_len_i32(s: []i32, chunk_size: usize): usize {
  if (chunk_size == 0 as usize) { return 0 as usize; }
  if (s.length == 0 as usize) { return 0 as usize; }
  return (s.length + chunk_size - 1 as usize) / chunk_size;
}

/** `chunk_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function chunk_i32(s: []i32, chunk_size: usize, index: usize): []i32 {
  if (chunk_size == 0 as usize) {
    let empty0: []i32;
    unsafe { core_slice_i32_from_ptr_c(&empty0, s.data, 0 as usize); }
    return empty0;
  }
  let off: usize = index * chunk_size;
  if (off >= s.length) {
    let empty1: []i32;
    unsafe { core_slice_i32_from_ptr_c(&empty1, s.data, 0 as usize); }
    return empty1;
  }
  let n: usize = chunk_size;
  if (off + n > s.length) { n = s.length - off; }
  return subslice_i32(s, off, n);
}

// ——— []u8 ———
/** `len_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function len_u8(s: []u8): usize { return s.length; }

/** `get_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function get_u8(s: []u8, i: usize): Option_u8 {
  let r: Option_u8 = { is_some: false, value: 0 };
  if (i >= s.length) {
    option.none_u8(&r);
    return r;
  }
  option.some_u8(&r, s.data[i]);
  return r;
}

/** `get_u8_unchecked`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function get_u8_unchecked(s: []u8, i: usize): u8 { return s.data[i]; }

/** `is_empty_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function is_empty_u8(s: []u8): i32 {
  if (s.length == 0 as usize) { return 1; }
  return 0;
}

/**
 * First u8 of a slice, or a missing option when the slice is empty.
 * A second function that returns Option_u8 does not asm-emit. get_u8
 * keeps that return. This one writes the same option through out.
 * @param s []u8 — source slice
 * @param out *Option_u8 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED
 */
export function first_u8(s: []u8, out: *Option_u8): i32 {
  if (s.length == 0 as usize) {
    return option.none_u8(out);
  }
  return option.some_u8(out, s.data[0]);
}

/**
 * Write a u8 subslice through out.
 * @param s []u8 — source slice
 * @param start usize — first index
 * @param len usize — element count
 * @param out *[]u8 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit this []u8 return.
 */
export function subslice_u8(s: []u8, start: usize, len: usize, out: *[]u8): i32 {
  unsafe { core_subslice_u8_c(out, s.data, s.length, start, len); }
  return 0;
}

/**
 * Split a u8 slice at at, writing both sides through out.
 * @param s []u8 — source slice
 * @param at usize — split index; clamped to the length
 * @param out *Split_u8 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit this Split_u8 return.
 */
export function split_at_u8(s: []u8, at: usize, out: *Split_u8): i32 {
  let at_clamped: usize = at;
  if (at_clamped > s.length) { at_clamped = s.length; }
  subslice_u8(s, 0 as usize, at_clamped, &out.left);
  subslice_u8(s, at_clamped, s.length - at_clamped, &out.right);
  return 0;
}

/** `chunks_len_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function chunks_len_u8(s: []u8, chunk_size: usize): usize {
  if (chunk_size == 0 as usize) { return 0 as usize; }
  if (s.length == 0 as usize) { return 0 as usize; }
  return (s.length + chunk_size - 1 as usize) / chunk_size;
}

/**
 * Write u8 chunk index through out. A zero chunk size writes an empty slice.
 * @param s []u8 — source slice
 * @param chunk_size usize — elements per chunk
 * @param index usize — chunk index
 * @param out *[]u8 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit this []u8 return.
 */
export function chunk_u8(s: []u8, chunk_size: usize, index: usize, out: *[]u8): i32 {
  if (chunk_size == 0 as usize) {
    unsafe { core_slice_u8_from_ptr_c(out, s.data, 0 as usize); }
    return 0;
  }
  let off: usize = index * chunk_size;
  if (off >= s.length) {
    unsafe { core_slice_u8_from_ptr_c(out, s.data, 0 as usize); }
    return 0;
  }
  let n: usize = chunk_size;
  if (off + n > s.length) { n = s.length - off; }
  return subslice_u8(s, off, n, out);
}

// ——— []u64（CORE-157） ———
/** `len_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function len_u64(s: []u64): usize { return s.length; }

/** `get_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function get_u64(s: []u64, i: usize): Option_u64 {
  let r: Option_u64 = { is_some: false, value: 0 };
  if (i >= s.length) {
    option.none_u64(&r);
    return r;
  }
  option.some_u64(&r, s.data[i]);
  return r;
}

/** `is_empty_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function is_empty_u64(s: []u64): i32 {
  if (s.length == 0 as usize) { return 1; }
  return 0;
}

/**
 * First u64 of a slice, or a missing option when the slice is empty.
 * Writes through out so this TU does not return a second Option_u64.
 * @param s []u64 — source slice
 * @param out *Option_u64 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED
 */
export function first_u64(s: []u64, out: *Option_u64): i32 {
  if (s.length == 0 as usize) {
    return option.none_u64(out);
  }
  return option.some_u64(out, s.data[0]);
}

/** `last_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
/**
 * Last u64 of a slice, or a missing option when the slice is empty.
 * Writes through out so this TU does not return a second Option_u64.
 * @param s []u64 — source slice
 * @param out *Option_u64 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED
 */
export function last_u64(s: []u64, out: *Option_u64): i32 {
  if (s.length == 0 as usize) {
    return option.none_u64(out);
  }
  return option.some_u64(out, s.data[s.length - 1 as usize]);
}

/**
 * Write a u64 subslice through out.
 * @param s []u64 — source slice
 * @param start usize — first index
 * @param len usize — element count
 * @param out *[]u64 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit this []u64 return.
 */
export function subslice_u64(s: []u64, start: usize, len: usize, out: *[]u64): i32 {
  unsafe { core_subslice_u64_c(out, s.data, s.length, start, len); }
  return 0;
}

/**
 * Split a u64 slice at at, writing both sides through out.
 * @param s []u64 — source slice
 * @param at usize — split index; clamped to the length
 * @param out *Split_u64 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit this Split_u64 return.
 */
export function split_at_u64(s: []u64, at: usize, out: *Split_u64): i32 {
  let at_clamped: usize = at;
  if (at_clamped > s.length) { at_clamped = s.length; }
  subslice_u64(s, 0 as usize, at_clamped, &out.left);
  subslice_u64(s, at_clamped, s.length - at_clamped, &out.right);
  return 0;
}

/** `chunks_len_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function chunks_len_u64(s: []u64, chunk_size: usize): usize {
  if (chunk_size == 0 as usize) { return 0 as usize; }
  if (s.length == 0 as usize) { return 0 as usize; }
  return (s.length + chunk_size - 1 as usize) / chunk_size;
}

/**
 * Write u64 chunk index through out. A zero chunk size writes an empty slice.
 * @param s []u64 — source slice
 * @param chunk_size usize — elements per chunk
 * @param index usize — chunk index
 * @param out *[]u64 — destination; must not be null
 * @return i32 — always 0
 * PLATFORM: SHARED — the installed product cannot asm-emit this []u64 return.
 */
export function chunk_u64(s: []u64, chunk_size: usize, index: usize, out: *[]u64): i32 {
  if (chunk_size == 0 as usize) {
    unsafe { core_slice_u64_from_ptr_c(out, s.data, 0 as usize); }
    return 0;
  }
  let off: usize = index * chunk_size;
  if (off >= s.length) {
    unsafe { core_slice_u64_from_ptr_c(out, s.data, 0 as usize); }
    return 0;
  }
  let n: usize = chunk_size;
  if (off + n > s.length) { n = s.length - off; }
  return subslice_u64(s, off, n, out);
}
