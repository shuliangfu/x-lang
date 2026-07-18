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

/* See implementation. */
export const SELECT_DIR_RECV: i32 = 0;
/* See implementation. */
export const SELECT_DIR_SEND: i32 = 1;

extern function channel_i32_bounded_c(cap: i32): *u8;
extern function channel_i32_unbounded_c(): *u8;
extern function channel_i32_send_c(ch: *u8, val: i32): i32;
extern function channel_i32_recv_c(ch: *u8, out: *i32): i32;
extern function channel_i32_try_send_c(ch: *u8, val: i32): i32;
extern function channel_i32_try_recv_c(ch: *u8, out: *i32): i32;
extern function channel_i32_close_c(ch: *u8): void;
extern function channel_i32_free_c(ch: *u8): void;
extern function channel_i32_is_closed_c(ch: *u8): i32;

extern function channel_select_chs_set_c(slots: *i64, idx: i32, ch: *u8): void;
extern function channel_select_dirs_set_c(dirs: *i32, idx: i32, dir: i32): void;
extern function channel_select_try_recv_2_c(ch0: *u8, ch1: *u8, out_val: *i32, out_index: *i32): i32;
extern function channel_select_recv_2_c(ch0: *u8, ch1: *u8, out_val: *i32, out_index: *i32): i32;
extern function channel_select_try_recv_n_c(chs_slots: *i64, n: i32, out_val: *i32, out_index: *i32): i32;
extern function channel_select_recv_n_c(chs_slots: *i64, n: i32, out_val: *i32, out_index: *i32): i32;
extern function channel_select_try_send_2_c(ch0: *u8, ch1: *u8, val: i32, out_index: *i32): i32;
extern function channel_select_send_2_c(ch0: *u8, ch1: *u8, val: i32, out_index: *i32): i32;
extern function channel_select_try_send_n_c(chs_slots: *i64, n: i32, val: i32, out_index: *i32): i32;
extern function channel_select_send_n_c(chs_slots: *i64, n: i32, val: i32, out_index: *i32): i32;
extern function channel_select_try_mixed_2_c(recv_ch: *u8, send_ch: *u8, send_val: i32, out_val: *i32, out_is_send: *i32): i32;
extern function channel_select_mixed_2_c(recv_ch: *u8, send_ch: *u8, send_val: i32, out_val: *i32, out_is_send: *i32): i32;
extern function channel_select_try_mixed_n_c(chs_slots: *i64, dirs: *i32, n: i32, send_val: i32, out_val: *i32, out_index: *i32, out_is_send: *i32): i32;
extern function channel_select_mixed_n_c(chs_slots: *i64, dirs: *i32, n: i32, send_val: i32, out_val: *i32, out_index: *i32, out_is_send: *i32): i32;

/** Exported function `bounded`.
 * Implements `bounded`.
 * @param cap i32
 * @return *u8
 */
export function bounded(cap: i32): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = channel_i32_bounded_c(cap); }
  return _rc;
}

/** Exported function `unbounded`.
 * Implements `unbounded`.
 * @return *u8
 */
export function unbounded(): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = channel_i32_unbounded_c(); }
  return _rc;
}

/** Exported function `send`.
 * Implements `send`.
 * @param ch *u8
 * @param val i32
 * @return i32
 */
export function send(ch: *u8, val: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_i32_send_c(ch, val); }
  return _rc;
}

/** Exported function `recv`.
 * Implements `recv`.
 * @param ch *u8
 * @param out *i32
 * @return i32
 */
export function recv(ch: *u8, out: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_i32_recv_c(ch, out); }
  return _rc;
}

/** Exported function `try_send`.
 * Implements `try_send`.
 * @param ch *u8
 * @param val i32
 * @return i32
 */
export function try_send(ch: *u8, val: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_i32_try_send_c(ch, val); }
  return _rc;
}

/** Exported function `try_recv`.
 * Implements `try_recv`.
 * @param ch *u8
 * @param out *i32
 * @return i32
 */
export function try_recv(ch: *u8, out: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_i32_try_recv_c(ch, out); }
  return _rc;
}

/** Exported function `close`.
 * Implements `close`.
 * @param ch *u8
 * @return void
 */
export function close(ch: *u8): void {
  unsafe {
    channel_i32_close_c(ch);
  }
}

/** Exported function `free`.
 * Memory management helper `free`.
 * @param ch *u8
 * @return void
 */
export function free(ch: *u8): void {
  unsafe {
    channel_i32_free_c(ch);
  }
}

/** Exported function `is_closed`.
 * Query helper `is_closed`.
 * @param ch *u8
 * @return i32
 */
export function is_closed(ch: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_i32_is_closed_c(ch); }
  return _rc;
}

/** Exported function `send_unbounded`.
 * Implements `send_unbounded`.
 * @param ch *u8
 * @param val i32
 * @return i32
 */
export function send_unbounded(ch: *u8, val: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_i32_send_c(ch, val); }
  return _rc;
}

/** Exported function `try_recv_unbounded`.
 * Implements `try_recv_unbounded`.
 * @param ch *u8
 * @param out *i32
 * @return i32
 */
export function try_recv_unbounded(ch: *u8, out: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_i32_try_recv_c(ch, out); }
  return _rc;
}

/** Exported function `unbounded_close`.
 * Implements `unbounded_close`.
 * @param ch *u8
 * @return void
 */
export function unbounded_close(ch: *u8): void {
  unsafe {
    channel_i32_close_c(ch);
  }
}

/** Exported function `unbounded_is_closed`.
 * Implements `unbounded_is_closed`.
 * @param ch *u8
 * @return i32
 */
export function unbounded_is_closed(ch: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_i32_is_closed_c(ch); }
  return _rc;
}

/** Exported function `select_max`.
 * Implements `select_max`.
 * @return i32
 */
export function select_max(): i32 {
  return 8;
}

/** Exported function `select_chs_set`.
 * Implements `select_chs_set`.
 * @param slots *i64
 * @param idx i32
 * @param ch *u8
 * @return void
 */
export function select_chs_set(slots: *i64, idx: i32, ch: *u8): void {
  unsafe {
    channel_select_chs_set_c(slots, idx, ch);
  }
}

/** Exported function `select_dirs_set`.
 * Implements `select_dirs_set`.
 * @param dirs *i32
 * @param idx i32
 * @param dir i32
 * @return void
 */
export function select_dirs_set(dirs: *i32, idx: i32, dir: i32): void {
  unsafe {
    channel_select_dirs_set_c(dirs, idx, dir);
  }
}

/** Exported function `select_try_recv`.
 * Implements `select_try_recv`.
 * @param ch0 *u8
 * @param ch1 *u8
 * @param out_val *i32
 * @param out_index *i32
 * @return i32
 */
export function select_try_recv(ch0: *u8, ch1: *u8, out_val: *i32, out_index: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_select_try_recv_2_c(ch0, ch1, out_val, out_index); }
  return _rc;
}

/** Exported function `select_recv`.
 * Implements `select_recv`.
 * @param ch0 *u8
 * @param ch1 *u8
 * @param out_val *i32
 * @param out_index *i32
 * @return i32
 */
export function select_recv(ch0: *u8, ch1: *u8, out_val: *i32, out_index: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_select_recv_2_c(ch0, ch1, out_val, out_index); }
  return _rc;
}

/** Exported function `select_try_recv_n`.
 * Implements `select_try_recv_n`.
 * @param chs_slots *i64
 * @param n i32
 * @param out_val *i32
 * @param out_index *i32
 * @return i32
 */
export function select_try_recv_n(chs_slots: *i64, n: i32, out_val: *i32, out_index: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_select_try_recv_n_c(chs_slots, n, out_val, out_index); }
  return _rc;
}

/** Exported function `select_recv_n`.
 * Implements `select_recv_n`.
 * @param chs_slots *i64
 * @param n i32
 * @param out_val *i32
 * @param out_index *i32
 * @return i32
 */
export function select_recv_n(chs_slots: *i64, n: i32, out_val: *i32, out_index: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_select_recv_n_c(chs_slots, n, out_val, out_index); }
  return _rc;
}

/** Exported function `select_try_send`.
 * Implements `select_try_send`.
 * @param ch0 *u8
 * @param ch1 *u8
 * @param val i32
 * @param out_index *i32
 * @return i32
 */
export function select_try_send(ch0: *u8, ch1: *u8, val: i32, out_index: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_select_try_send_2_c(ch0, ch1, val, out_index); }
  return _rc;
}

/** Exported function `select_send`.
 * Implements `select_send`.
 * @param ch0 *u8
 * @param ch1 *u8
 * @param val i32
 * @param out_index *i32
 * @return i32
 */
export function select_send(ch0: *u8, ch1: *u8, val: i32, out_index: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_select_send_2_c(ch0, ch1, val, out_index); }
  return _rc;
}

/** Exported function `select_try_send_n`.
 * Implements `select_try_send_n`.
 * @param chs_slots *i64
 * @param n i32
 * @param val i32
 * @param out_index *i32
 * @return i32
 */
export function select_try_send_n(chs_slots: *i64, n: i32, val: i32, out_index: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_select_try_send_n_c(chs_slots, n, val, out_index); }
  return _rc;
}

/** Exported function `select_send_n`.
 * Implements `select_send_n`.
 * @param chs_slots *i64
 * @param n i32
 * @param val i32
 * @param out_index *i32
 * @return i32
 */
export function select_send_n(chs_slots: *i64, n: i32, val: i32, out_index: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_select_send_n_c(chs_slots, n, val, out_index); }
  return _rc;
}

/** Exported function `select_try_mixed`.
 * Implements `select_try_mixed`.
 * @param recv_ch *u8
 * @param send_ch *u8
 * @param send_val i32
 * @param out_val *i32
 * @param out_is_send *i32
 * @return i32
 */
export function select_try_mixed(recv_ch: *u8, send_ch: *u8, send_val: i32, out_val: *i32, out_is_send: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_select_try_mixed_2_c(recv_ch, send_ch, send_val, out_val, out_is_send); }
  return _rc;
}

/** Exported function `select_mixed`.
 * Implements `select_mixed`.
 * @param recv_ch *u8
 * @param send_ch *u8
 * @param send_val i32
 * @param out_val *i32
 * @param out_is_send *i32
 * @return i32
 */
export function select_mixed(recv_ch: *u8, send_ch: *u8, send_val: i32, out_val: *i32, out_is_send: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_select_mixed_2_c(recv_ch, send_ch, send_val, out_val, out_is_send); }
  return _rc;
}

/** Exported function `select_try_mixed_n`.
 * Implements `select_try_mixed_n`.
 * @param chs_slots *i64
 * @param dirs *i32
 * @param n i32
 * @param send_val i32
 * @param out_val *i32
 * @param out_index *i32
 * @param out_is_send *i32
 * @return i32
 */
export function select_try_mixed_n(chs_slots: *i64, dirs: *i32, n: i32, send_val: i32, out_val: *i32, out_index: *i32, out_is_send: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_select_try_mixed_n_c(chs_slots, dirs, n, send_val, out_val, out_index, out_is_send); }
  return _rc;
}

/** Exported function `select_mixed_n`.
 * Implements `select_mixed_n`.
 * @param chs_slots *i64
 * @param dirs *i32
 * @param n i32
 * @param send_val i32
 * @param out_val *i32
 * @param out_index *i32
 * @param out_is_send *i32
 * @return i32
 */
export function select_mixed_n(chs_slots: *i64, dirs: *i32, n: i32, send_val: i32, out_val: *i32, out_index: *i32, out_is_send: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = channel_select_mixed_n_c(chs_slots, dirs, n, send_val, out_val, out_index, out_is_send); }
  return _rc;
}
