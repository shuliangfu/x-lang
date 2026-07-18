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
// See implementation.
//
// See implementation.

export const SHUX_POLL_PENDING: i32 = 0;
export const SHUX_POLL_READY: i32 = 1;

export const FUT_OK: i32 = 0;
export const FUT_ERR_NULL: i32 = -1;
export const FUT_ERR_INVALID: i32 = -2;
export const FUT_ERR_PENDING: i32 = -3;
export const FUT_ERR_FULL: i32 = -4;

export const SHUX_FUTURE_MAX: i32 = 64;

/* See implementation. */
allow(padding) struct ShuxFutureSlot {
  state: i32;
  value: i32;
}

/* See implementation. */
extern function shux_async_run_drain_until_idle(): i32;
extern function shux_io_poll_async_completions(timeout_ms: u32): u32;

/* See implementation. */
let g_shux_futures: ShuxFutureSlot[64] = [];
let g_shux_future_count: i32 = 0;

/** Exported function `future_f_async_future_v1_marker_c`.
 * Implements `future_f_async_future_v1_marker_c`.
 * @return i32
 */
export function future_f_async_future_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `future_f_async_future_v2_marker_c`.
 * Implements `future_f_async_future_v2_marker_c`.
 * @return i32
 */
export function future_f_async_future_v2_marker_c(): i32 {
  return 1;
}

/** Exported function `shux_future_slot_from_handle`.
 * Implements `shux_future_slot_from_handle`.
 * @param handle i64
 * @return *ShuxFutureSlot
 */
export function shux_future_slot_from_handle(handle: i64): *ShuxFutureSlot {
  let idx: i32 = 0;
  if (handle <= 0) { return 0 as *ShuxFutureSlot; }
  idx = (handle - 1) as i32;
  if (idx < 0 || idx >= g_shux_future_count) { return 0 as *ShuxFutureSlot; }
  return &g_shux_futures[idx] as *ShuxFutureSlot;
}

/**
 * See implementation.
 */
export function shux_async_future_create_c(): i64 {
  let s: *ShuxFutureSlot = 0 as *ShuxFutureSlot;
  if (g_shux_future_count >= SHUX_FUTURE_MAX) { return 0; }
  s = &g_shux_futures[g_shux_future_count] as *ShuxFutureSlot;
  s.state = SHUX_POLL_PENDING;
  s.value = 0;
  g_shux_future_count = g_shux_future_count + 1;
  return g_shux_future_count as i64;
}

/**
 * See implementation.
 */
export function shux_async_future_poll_c(handle: i64): i32 {
  let s: *ShuxFutureSlot = shux_future_slot_from_handle(handle);
  if (s == 0) { return FUT_ERR_INVALID; }
  if (s.state == SHUX_POLL_READY) { return SHUX_POLL_READY; }
  return SHUX_POLL_PENDING;
}

/**
 * See implementation.
 */
export function shux_async_future_complete_c(handle: i64, value: i32): void {
  let s: *ShuxFutureSlot = shux_future_slot_from_handle(handle);
  if (s == 0) { return; }
  s.value = value;
  s.state = SHUX_POLL_READY;
}

/**
 * See implementation.
 */
export function shux_async_future_take_c(handle: i64, out: *i32): i32 {
  let s: *ShuxFutureSlot = shux_future_slot_from_handle(handle);
  if (out == 0) { return FUT_ERR_NULL; }
  if (s == 0) { return FUT_ERR_INVALID; }
  if (s.state != SHUX_POLL_READY) { return FUT_ERR_PENDING; }
  out[0] = s.value;
  s.state = SHUX_POLL_PENDING;
  s.value = 0;
  return FUT_OK;
}

/** Exported function `shux_async_future_reset_c`.
 * Implements `shux_async_future_reset_c`.
 * @return void
 */
export function shux_async_future_reset_c(): void {
  let i: i32 = 0;
  g_shux_future_count = 0;
  while (i < SHUX_FUTURE_MAX) {
    g_shux_futures[i].state = 0;
    g_shux_futures[i].value = 0;
    i = i + 1;
  }
}

/**
 * See implementation.
 * See implementation.
 */
export function shux_async_future_wait_c(handle: i64, max_rounds: i32): i32 {
  let round: i32 = 0;
  let pr: i32 = 0;
  let mr: i32 = max_rounds;
  if (mr < 0) { mr = 0; }
  while (round < mr) {
    pr = shux_async_future_poll_c(handle);
    if (pr == SHUX_POLL_READY) { return SHUX_POLL_READY; }
    if (pr < 0) { return pr; }
    unsafe { shux_io_poll_async_completions(0); }
    unsafe { shux_async_run_drain_until_idle(); }
    round = round + 1;
  }
  return shux_async_future_poll_c(handle);
}

/** Exported function `shux_async_future_smoke_c`.
 * Implements `shux_async_future_smoke_c`.
 * @return i32
 */
export function shux_async_future_smoke_c(): i32 {
  let h: i64 = 0;
  let v: i32 = 0;
  let pr: i32 = 0;
  shux_async_future_reset_c();
  h = shux_async_future_create_c();
  if (h == 0) { return 1; }
  pr = shux_async_future_poll_c(h);
  if (pr != SHUX_POLL_PENDING) { return 2; }
  shux_async_future_complete_c(h, 42);
  pr = shux_async_future_poll_c(h);
  if (pr != SHUX_POLL_READY) { return 3; }
  if (shux_async_future_take_c(h, &v) != FUT_OK || v != 42) { return 4; }
  pr = shux_async_future_poll_c(h);
  if (pr != SHUX_POLL_PENDING) { return 5; }
  if (shux_async_future_wait_c(h, 0) != SHUX_POLL_PENDING) { return 6; }
  shux_async_future_complete_c(h, 55);
  if (shux_async_future_wait_c(h, 4) != SHUX_POLL_READY) { return 7; }
  if (shux_async_future_take_c(h, &v) != FUT_OK || v != 55) { return 8; }
  shux_async_future_reset_c();
  return 0;
}
