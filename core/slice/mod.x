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

extern function core_slice_i32_from_ptr_c(data: *i32, len: usize): []i32;
extern function core_subslice_i32_c(data: *i32, total_len: usize, start: usize, len: usize): []i32;
extern function core_slice_u8_from_ptr_c(data: *u8, len: usize): []u8;
extern function core_subslice_u8_c(data: *u8, total_len: usize, start: usize, len: usize): []u8;
extern function core_slice_u64_from_ptr_c(data: *u64, len: usize): []u64;
extern function core_subslice_u64_c(data: *u64, total_len: usize, start: usize, len: usize): []u64;

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
  if (i >= s.length) {
    return option.none_i32();
  }
  return option.some_i32(s.data[i]);
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
  if (s.length == 0 as usize) { return option.none_i32(); }
  return get_i32(s, s.length - 1 as usize);
}

/** `subslice_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function subslice_i32(s: []i32, start: usize, len: usize): []i32 {
  let r: []i32;
  unsafe { r = core_subslice_i32_c(s.data, s.length, start, len); }
  return r;
}

/** `split_at_i32`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function split_at_i32(s: []i32, at: usize): Split_i32 {
  let at_clamped: usize = at;
  if (at_clamped > s.length) { at_clamped = s.length; }
  return Split_i32 {
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
    unsafe { empty0 = core_slice_i32_from_ptr_c(s.data, 0 as usize); }
    return empty0;
  }
  let off: usize = index * chunk_size;
  if (off >= s.length) {
    let empty1: []i32;
    unsafe { empty1 = core_slice_i32_from_ptr_c(s.data, 0 as usize); }
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
  if (i >= s.length) {
    return option.none_u8();
  }
  return option.some_u8(s.data[i]);
}

/** `get_u8_unchecked`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function get_u8_unchecked(s: []u8, i: usize): u8 { return s.data[i]; }

/** `is_empty_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function is_empty_u8(s: []u8): i32 {
  if (s.length == 0 as usize) { return 1; }
  return 0;
}

/** `first_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function first_u8(s: []u8): Option_u8 {
  return get_u8(s, 0 as usize);
}

/** `subslice_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function subslice_u8(s: []u8, start: usize, len: usize): []u8 {
  let r: []u8;
  unsafe { r = core_subslice_u8_c(s.data, s.length, start, len); }
  return r;
}

/** `split_at_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function split_at_u8(s: []u8, at: usize): Split_u8 {
  let at_clamped: usize = at;
  if (at_clamped > s.length) { at_clamped = s.length; }
  return Split_u8 {
    left: subslice_u8(s, 0 as usize, at_clamped),
    right: subslice_u8(s, at_clamped, s.length - at_clamped),
  };
}

/** `chunks_len_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function chunks_len_u8(s: []u8, chunk_size: usize): usize {
  if (chunk_size == 0 as usize) { return 0 as usize; }
  if (s.length == 0 as usize) { return 0 as usize; }
  return (s.length + chunk_size - 1 as usize) / chunk_size;
}

/** `chunk_u8`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function chunk_u8(s: []u8, chunk_size: usize, index: usize): []u8 {
  if (chunk_size == 0 as usize) {
    let empty0: []u8;
    unsafe { empty0 = core_slice_u8_from_ptr_c(s.data, 0 as usize); }
    return empty0;
  }
  let off: usize = index * chunk_size;
  if (off >= s.length) {
    let empty1: []u8;
    unsafe { empty1 = core_slice_u8_from_ptr_c(s.data, 0 as usize); }
    return empty1;
  }
  let n: usize = chunk_size;
  if (off + n > s.length) { n = s.length - off; }
  return subslice_u8(s, off, n);
}

// ——— []u64（CORE-157） ———
/** `len_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function len_u64(s: []u64): usize { return s.length; }

/** `get_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function get_u64(s: []u64, i: usize): Option_u64 {
  if (i >= s.length) {
    return option.none_u64();
  }
  return option.some_u64(s.data[i]);
}

/** `is_empty_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function is_empty_u64(s: []u64): i32 {
  if (s.length == 0 as usize) { return 1; }
  return 0;
}

/** `first_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function first_u64(s: []u64): Option_u64 {
  return get_u64(s, 0 as usize);
}

/** `last_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function last_u64(s: []u64): Option_u64 {
  if (s.length == 0 as usize) { return option.none_u64(); }
  return get_u64(s, s.length - 1 as usize);
}

/** `subslice_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function subslice_u64(s: []u64, start: usize, len: usize): []u64 {
  let r: []u64;
  unsafe { r = core_subslice_u64_c(s.data, s.length, start, len); }
  return r;
}

/** `split_at_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function split_at_u64(s: []u64, at: usize): Split_u64 {
  let at_clamped: usize = at;
  if (at_clamped > s.length) { at_clamped = s.length; }
  return Split_u64 {
    left: subslice_u64(s, 0 as usize, at_clamped),
    right: subslice_u64(s, at_clamped, s.length - at_clamped),
  };
}

/** `chunks_len_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function chunks_len_u64(s: []u64, chunk_size: usize): usize {
  if (chunk_size == 0 as usize) { return 0 as usize; }
  if (s.length == 0 as usize) { return 0 as usize; }
  return (s.length + chunk_size - 1 as usize) / chunk_size;
}

/** `chunk_u64`: purpose/params/returns per signature; panics or error codes follow local contracts. */
export function chunk_u64(s: []u64, chunk_size: usize, index: usize): []u64 {
  if (chunk_size == 0 as usize) {
    let empty0: []u64;
    unsafe { empty0 = core_slice_u64_from_ptr_c(s.data, 0 as usize); }
    return empty0;
  }
  let off: usize = index * chunk_size;
  if (off >= s.length) {
    let empty1: []u64;
    unsafe { empty1 = core_slice_u64_from_ptr_c(s.data, 0 as usize); }
    return empty1;
  }
  let n: usize = chunk_size;
  if (off + n > s.length) { n = s.length - off; }
  return subslice_u64(s, off, n);
}
