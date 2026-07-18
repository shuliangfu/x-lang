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

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.

export const CTX_VALUE_SLOTS: i32 = 8;
/* See implementation. */
export const CTX_NODE_MEM_SIZE: usize = 152;

/* See implementation. */
allow(padding) struct CtxValueSlot {
  key_hash: u32;
  value: i64;
  used: i32;
}

/* See implementation. */
allow(padding) struct CtxNode {
  parent: i64;
  cancelled: i32;
  deadline_ns: i64;
  values: CtxValueSlot[8];
}

/* See implementation. */
export const CTX_OK: i32 = 0;
/* See implementation. */
export const CTX_ERR_NULL: i32 = -1;

/* See implementation. */
let g_ctx_background_bytes: u8[152] = [];
let g_ctx_background_init: i32 = 0;

extern function time_now_monotonic_ns_c(): i64;
extern function atomic_load_i32_c(ptr: *i32): i32;
extern function atomic_store_i32_c(ptr: *i32, val: i32): void;
extern "C" function memset(s: *u8, c: i32, n: usize): *u8;
extern "C" function calloc(nmemb: usize, size: usize): *u8;
extern "C" function free(ptr: *u8): void;

/** Exported function `ctx_f_context_v1_marker_c`.
 * Implements `ctx_f_context_v1_marker_c`.
 * @return i32
 */
export function ctx_f_context_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `ctx_f_context_v2_marker_c`.
 * Implements `ctx_f_context_v2_marker_c`.
 * @return i32
 */
export function ctx_f_context_v2_marker_c(): i32 {
  return 1;
}

/** Exported function `ctx_ptr`.
 * Implements `ctx_ptr`.
 * @param handle i64
 * @return *CtxNode
 */
export function ctx_ptr(handle: i64): *CtxNode {
  if (handle == 0) { return 0 as *CtxNode; }
  return handle as *CtxNode;
}

/** Exported function `ctx_glue_background_c`.
 * Implements `ctx_glue_background_c`.
 * @return i64
 */
export function ctx_glue_background_c(): i64 {
  let bg: *CtxNode = 0 as *CtxNode;
  if (g_ctx_background_init == 0) {
    bg = &g_ctx_background_bytes[0] as *CtxNode;
    unsafe { memset(&g_ctx_background_bytes[0], 0, CTX_NODE_MEM_SIZE); }
    unsafe { atomic_store_i32_c(&bg.cancelled, 0); }
    bg.deadline_ns = 0;
    bg.parent = 0;
    g_ctx_background_init = 1;
  }
  return &g_ctx_background_bytes[0] as i64;
}

/** Exported function `ctx_glue_is_background_c`.
 * Implements `ctx_glue_is_background_c`.
 * @param handle i64
 * @return i32
 */
export function ctx_glue_is_background_c(handle: i64): i32 {
  let bg: i64 = ctx_glue_background_c();
  if (handle == 0) { return 0; }
  if (handle == bg) { return 1; }
  return 0;
}

/** Exported function `ctx_glue_alloc_c`.
 * Memory management helper `ctx_glue_alloc_c`.
 * @param parent_handle i64
 * @param deadline_ns i64
 * @return i64
 */
export function ctx_glue_alloc_c(parent_handle: i64, deadline_ns: i64): i64 {
  let parent: *CtxNode = ctx_ptr(parent_handle);
  let child: *CtxNode = 0;
  if (parent == 0) { return 0; }
  unsafe { child = calloc(1, CTX_NODE_MEM_SIZE) as *CtxNode; }
  if (child == 0) { return 0; }
  child.parent = parent_handle;
  unsafe { atomic_store_i32_c(&child.cancelled, 0); }
  if (deadline_ns > 0) {
    child.deadline_ns = deadline_ns;
  } else {
    child.deadline_ns = 0;
  }
  return child as i64;
}

/** Exported function `ctx_glue_free_c`.
 * Memory management helper `ctx_glue_free_c`.
 * @param handle i64
 * @return void
 */
export function ctx_glue_free_c(handle: i64): void {
  let n: *CtxNode = ctx_ptr(handle);
  if (n == 0) { return; }
  if (ctx_glue_is_background_c(handle) != 0) { return; }
  unsafe { free(n as *u8); }
}

/** Exported function `ctx_glue_parent_c`.
 * Implements `ctx_glue_parent_c`.
 * @param handle i64
 * @return i64
 */
export function ctx_glue_parent_c(handle: i64): i64 {
  let n: *CtxNode = ctx_ptr(handle);
  if (n == 0) { return 0; }
  return n.parent;
}

/** Exported function `ctx_glue_deadline_c`.
 * Implements `ctx_glue_deadline_c`.
 * @param handle i64
 * @return i64
 */
export function ctx_glue_deadline_c(handle: i64): i64 {
  let n: *CtxNode = ctx_ptr(handle);
  if (n == 0) { return 0; }
  return n.deadline_ns;
}

/** Exported function `ctx_glue_cancelled_load_c`.
 * Implements `ctx_glue_cancelled_load_c`.
 * @param handle i64
 * @return i32
 */
export function ctx_glue_cancelled_load_c(handle: i64): i32 {
  let n: *CtxNode = ctx_ptr(handle);
  if (n == 0) { return 1; }
  unsafe { return atomic_load_i32_c(&n.cancelled); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `ctx_glue_cancelled_store_c`.
 * Implements `ctx_glue_cancelled_store_c`.
 * @param handle i64
 * @param v i32
 * @return void
 */
export function ctx_glue_cancelled_store_c(handle: i64, v: i32): void {
  let n: *CtxNode = ctx_ptr(handle);
  if (n == 0) { return; }
  if (v != 0) {
    unsafe { atomic_store_i32_c(&n.cancelled, 1); }
  } else {
    unsafe { atomic_store_i32_c(&n.cancelled, 0); }
  }
}

/** Exported function `ctx_glue_value_set_c`.
 * Implements `ctx_glue_value_set_c`.
 * @param handle i64
 * @param key_hash u32
 * @param value i64
 * @return i32
 */
export function ctx_glue_value_set_c(handle: i64, key_hash: u32, value: i64): i32 {
  let n: *CtxNode = ctx_ptr(handle);
  let i: i32 = 0;
  let free_slot: i32 = -1;
  if (n == 0) { return -1; }
  while (i < CTX_VALUE_SLOTS) {
    if (n.values[i].used != 0 && n.values[i].key_hash == key_hash) {
      n.values[i].value = value;
      return 0;
    }
    if (n.values[i].used == 0 && free_slot < 0) {
      free_slot = i;
    }
    i = i + 1;
  }
  if (free_slot < 0) { return -1; }
  n.values[free_slot].key_hash = key_hash;
  n.values[free_slot].value = value;
  n.values[free_slot].used = 1;
  return 0;
}

/** Exported function `ctx_glue_value_get_c`.
 * Implements `ctx_glue_value_get_c`.
 * @param handle i64
 * @param key_hash u32
 * @param out *i64
 * @return i32
 */
export function ctx_glue_value_get_c(handle: i64, key_hash: u32, out: *i64): i32 {
  let n: *CtxNode = ctx_ptr(handle);
  let i: i32 = 0;
  if (n == 0 || out == 0) { return 0; }
  while (i < CTX_VALUE_SLOTS) {
    if (n.values[i].used != 0 && n.values[i].key_hash == key_hash) {
      out[0] = n.values[i].value;
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `ctx_key_hash`.
 * Implements `ctx_key_hash`.
 * @param key *u8
 * @return u32
 */
export function ctx_key_hash(key: *u8): u32 {
  /* See implementation. */
  let h: u32 = 2166136261 as u32;
  let i: i32 = 0;
  if (key == 0) { return 0 as u32; }
  while (key[i] != 0) {
    h = h ^ (key[i] as u32);
    h = h * (16777619 as u32);
    i = i + 1;
  }
  return h;
}

/** Exported function `ctx_effective_deadline`.
 * Implements `ctx_effective_deadline`.
 * @param handle i64
 * @return i64
 */
export function ctx_effective_deadline(handle: i64): i64 {
  let dl: i64 = 0;
  let cur: i64 = handle;
  while (cur != 0) {
    dl = ctx_glue_deadline_c(cur);
    if (dl > 0) { return dl; }
    cur = ctx_glue_parent_c(cur);
  }
  return 0;
}

/** Exported function `ctx_chain_cancelled`.
 * Implements `ctx_chain_cancelled`.
 * @param handle i64
 * @return i32
 */
export function ctx_chain_cancelled(handle: i64): i32 {
  let cur: i64 = handle;
  while (cur != 0) {
    if (ctx_glue_cancelled_load_c(cur) != 0) { return 1; }
    cur = ctx_glue_parent_c(cur);
  }
  return 0;
}

/** Exported function `ctx_background_c`.
 * Implements `ctx_background_c`.
 * @return i64
 */
export function ctx_background_c(): i64 {
  return ctx_glue_background_c();
}

/** Exported function `ctx_with_cancel_c`.
 * Implements `ctx_with_cancel_c`.
 * @param parent_handle i64
 * @return i64
 */
export function ctx_with_cancel_c(parent_handle: i64): i64 {
  if (parent_handle == 0) { return 0; }
  return ctx_glue_alloc_c(parent_handle, 0);
}

/** Exported function `ctx_with_deadline_c`.
 * Implements `ctx_with_deadline_c`.
 * @param parent_handle i64
 * @param deadline_ns i64
 * @return i64
 */
export function ctx_with_deadline_c(parent_handle: i64, deadline_ns: i64): i64 {
  let dl: i64 = 0;
  if (parent_handle == 0) { return 0; }
  if (deadline_ns > 0) { dl = deadline_ns; }
  return ctx_glue_alloc_c(parent_handle, dl);
}

/** Exported function `ctx_with_timeout_c`.
 * Implements `ctx_with_timeout_c`.
 * @param parent_handle i64
 * @param timeout_ns i64
 * @return i64
 */
export function ctx_with_timeout_c(parent_handle: i64, timeout_ns: i64): i64 {
  let now: i64 = 0;
  let dl: i64 = 0;
  if (timeout_ns <= 0) { return ctx_with_deadline_c(parent_handle, 0); }
  unsafe { now = time_now_monotonic_ns_c(); }
  if (now <= 0) { return 0; }
  dl = now + timeout_ns;
  if (dl < now) { return 0; }
  return ctx_with_deadline_c(parent_handle, dl);
}

/** Exported function `ctx_cancel_c`.
 * Implements `ctx_cancel_c`.
 * @param handle i64
 * @return void
 */
export function ctx_cancel_c(handle: i64): void {
  ctx_glue_cancelled_store_c(handle, 1);
}

/** Exported function `ctx_is_cancelled_c`.
 * Implements `ctx_is_cancelled_c`.
 * @param handle i64
 * @return i32
 */
#[no_mangle]
export function ctx_is_cancelled_c(handle: i64): i32 {
  if (handle == 0) { return 1; }
  return ctx_chain_cancelled(handle);
}

/** Exported function `ctx_deadline_ns_c`.
 * Implements `ctx_deadline_ns_c`.
 * @param handle i64
 * @return i64
 */
export function ctx_deadline_ns_c(handle: i64): i64 {
  if (handle == 0) { return 0; }
  return ctx_effective_deadline(handle);
}

/** Exported function `ctx_remaining_ns_c`.
 * Implements `ctx_remaining_ns_c`.
 * @param handle i64
 * @return i64
 */
export function ctx_remaining_ns_c(handle: i64): i64 {
  let dl: i64 = 0;
  let now: i64 = 0;
  let rem: i64 = 0;
  if (handle == 0) { return 0; }
  if (ctx_chain_cancelled(handle) != 0) { return 0; }
  dl = ctx_effective_deadline(handle);
  if (dl <= 0) { return 0; }
  unsafe { now = time_now_monotonic_ns_c(); }
  if (now <= 0) { return 0; }
  rem = dl - now;
  if (rem > 0) { return rem; }
  return 0;
}

/** Exported function `ctx_set_value_c`.
 * Implements `ctx_set_value_c`.
 * @param handle i64
 * @param key *u8
 * @param value i64
 * @return i32
 */
export function ctx_set_value_c(handle: i64, key: *u8, value: i64): i32 {
  let h: u32 = 0;
  if (handle == 0 || key == 0) { return CTX_ERR_NULL; }
  h = ctx_key_hash(key);
  return ctx_glue_value_set_c(handle, h, value);
}

/** Exported function `ctx_get_value_c`.
 * Implements `ctx_get_value_c`.
 * @param handle i64
 * @param key *u8
 * @param out *i64
 * @return i32
 */
export function ctx_get_value_c(handle: i64, key: *u8, out: *i64): i32 {
  let h: u32 = 0;
  if (handle == 0 || key == 0 || out == 0) { return 0; }
  h = ctx_key_hash(key);
  return ctx_glue_value_get_c(handle, h, out);
}

/** Exported function `ctx_free_c`.
 * Memory management helper `ctx_free_c`.
 * @param handle i64
 * @return void
 */
export function ctx_free_c(handle: i64): void {
  if (handle == 0) { return; }
  if (ctx_glue_is_background_c(handle) != 0) { return; }
  ctx_glue_free_c(handle);
}

/** Exported function `ctx_smoke_c`.
 * Implements `ctx_smoke_c`.
 * @return i32
 */
export function ctx_smoke_c(): i32 {
  let bg: i64 = 0;
  let child: i64 = 0;
  let dl_child: i64 = 0;
  let rem: i64 = 0;
  let got: i64 = 0;
  let trace_key: u8[6] = [116, 114, 97, 99, 101, 0];
  bg = ctx_background_c();
  if (bg == 0) { return 1; }
  if (ctx_is_cancelled_c(bg) != 0) { return 2; }
  child = ctx_with_cancel_c(bg);
  if (child == 0) { return 3; }
  if (ctx_is_cancelled_c(child) != 0) { return 4; }
  ctx_cancel_c(child);
  if (ctx_is_cancelled_c(child) == 0) { return 5; }
  ctx_free_c(child);
  child = ctx_with_timeout_c(bg, 2000000000);
  if (child == 0) { return 6; }
  if (ctx_deadline_ns_c(child) <= 0) { return 7; }
  rem = ctx_remaining_ns_c(child);
  if (rem <= 0 || rem > 2000000000) { return 8; }
  if (ctx_set_value_c(child, &trace_key[0], 42) != CTX_OK) { return 9; }
  if (ctx_get_value_c(child, &trace_key[0], &got) == 0 || got != 42) { return 10; }
  ctx_free_c(child);
  dl_child = ctx_with_deadline_c(bg, 1);
  if (dl_child == 0) { return 11; }
  if (ctx_remaining_ns_c(dl_child) != 0) { return 12; }
  ctx_free_c(dl_child);
  return 0;
}
