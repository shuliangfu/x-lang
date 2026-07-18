// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

const io = import("std.io");
const heap = import("std.heap");

/* See implementation. */
export extern function lsp_diag_invalidate_cache(): void;

/* See implementation. */
let LSP_BODY_SAFETY_CAP: i32 = 1048576;

/** See implementation for details. */
let LSP_STATE_LEFTOVER_OFF: i32 = 0;
let LSP_STATE_LEFTOVER_MAX: i32 = 8192 * 2;
let LSP_STATE_LEN_OFF: i32 = 8192 * 2;

/* See implementation. */
export extern function lsp_debug_u32(n: u32): void;
/* See implementation. */
export extern function lsp_debug_ptr(p: *u8): void;

/**
 * Read one LSP message from fd (0=stdin) into body_out; return body length or -1.
 * state_buf layout: [0..LEFTOVER_MAX) leftover bytes; [LEN_OFF..LEN_OFF+3] LE i32 length.
 * Index only via state_buf[i] / &state_buf[expr] — no pointer arithmetic.
 * PLATFORM: SHARED — Cap-T001 whole-body unsafe (debug externs + std.io.read).
 */
export function read_message(fd: i32, body_out: *u8, body_cap: i32, state_buf: *u8): isize {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // Covers export-extern debug/diag and std.io/std.heap import surface calls.
  unsafe {
  let h: usize = 0 as usize;
  /* See implementation. */
  if (fd != 0) { return (-1) as isize; }
  let b0: u8 = state_buf[LSP_STATE_LEN_OFF];
  let b1: u8 = state_buf[LSP_STATE_LEN_OFF + 1];
  let b2: u8 = state_buf[LSP_STATE_LEN_OFF + 2];
  let b3: u8 = state_buf[LSP_STATE_LEN_OFF + 3];
  /* Assemble LE i32 from 4 bytes; avoid C << vs + precedence bugs after codegen. */
  let n0: i32 = b0 as i32;
  let n1: i32 = (b1 as i32) << 8;
  let n2: i32 = (b2 as i32) << 16;
  let n3: i32 = (b3 as i32) << 24;
  let n: i32 = n0 + n1 + n2 + n3;
  if (n < 0 || n > LSP_STATE_LEFTOVER_MAX) {
    n = 0;
  }
  lsp_debug_ptr(state_buf);
  if (n > 0) {
    lsp_debug_u32(n as u32);
  }
  /* On buffer EOF/error: returning only first message length makes later n=0 and exits. */
  if (n < LSP_STATE_LEFTOVER_MAX) {
    while (n < LSP_STATE_LEFTOVER_MAX) {
      let got: i32 = io.read(h, &state_buf[n], (LSP_STATE_LEFTOVER_MAX - n) as usize, 0 as u32);
      if (got > 0) {
        n = n + got;
      } else {
        break;
      }
    }
  }
  if (n <= 0) {
    return (-1) as isize;
  }
  let i: i32 = 0;
  while (i + 4 <= n) {
    if (state_buf[i] == 13 && state_buf[i + 1] == 10 && state_buf[i + 2] == 13 && state_buf[i + 3]
    == 10) {
      break;
    }
    i = i + 1;
  }
  if (i + 4 > n) {
    return (-1) as isize;
  }
  let header_end: i32 = i + 4;
  let content_len: i32 = parse_content_length_in_buf(state_buf, 0, header_end);
  if (content_len <= 0 || content_len > body_cap || content_len > LSP_BODY_SAFETY_CAP) {
    return (-1) as isize;
  }
  let body_in_buf: i32 = n - header_end;
  let to_copy: i32 = if (body_in_buf > content_len) { content_len } else { body_in_buf };
  let j: i32 = 0;
  while (j < to_copy) {
    body_out[j] = state_buf[header_end + j];
    j = j + 1;
  }
  if (content_len > to_copy) {
    let remain: i32 = content_len - to_copy;
    /* See implementation. */
    let r: i32 = io.read(h, &body_out[to_copy], remain as usize, 0 as u32);
    if (r != remain) {
      return (-1) as isize;
    }
  }
  let consumed: i32 = header_end + content_len;
  let new_n: i32 = n - consumed;
  if (new_n > 0) {
    let k: i32 = 0;
    while (k < new_n) {
      state_buf[k] = state_buf[consumed + k];
      k = k + 1;
    }
    state_buf[LSP_STATE_LEN_OFF] = (new_n & 255) as u8;
    state_buf[LSP_STATE_LEN_OFF + 1] = ((new_n >> 8) & 255) as u8;
    state_buf[LSP_STATE_LEN_OFF + 2] = ((new_n >> 16) & 255) as u8;
    state_buf[LSP_STATE_LEN_OFF + 3] = ((new_n >> 24) & 255) as u8;
    "leftover n=821" */
  } else {
    state_buf[LSP_STATE_LEN_OFF] = 0;
    state_buf[LSP_STATE_LEN_OFF + 1] = 0;
    state_buf[LSP_STATE_LEN_OFF + 2] = 0;
    state_buf[LSP_STATE_LEN_OFF + 3] = 0;
  }
  return content_len as isize;
  }
  return 0 as isize;
}

/** Exported function `parse_content_length_in_buf`.
 * Implements `parse_content_length_in_buf`.
 * @param state_buf *u8
 * @param off i32
 * @param header_end i32
 * @return i32
 */
export function parse_content_length_in_buf(state_buf: *u8, off: i32, header_end: i32): i32 {
  if (header_end < 16) { return -1; }
  let key: u8[16] = [67, 111, 110, 116, 101, 110, 116, 45, 76, 101, 110, 103, 116, 104, 58, 32];
  let ki: i32 = 0;
  while (ki < 16) {
    if (state_buf[off + ki] != key[ki]) { return -1; }
    ki = ki + 1;
  }
  let val: i32 = 0;
  let i: i32 = 16;
  /* Optional space/tab after Content-Length:; ensure i < header_end before reading bytes so
  post-codegen C &&/|| precedence cannot OOB. */
  while (i < header_end) {
    let c0: u8 = state_buf[off + i];
    if (c0 != 32 && c0 != 9) { break; }
    i = i + 1;
  }
  while (i < header_end) {
    let c: u8 = state_buf[off + i];
    if (c >= 48 && c <= 57) {
      val = val * 10 + (c as i32) - 48;
      i = i + 1;
    } else {
      break;
    }
  }
  return val;
}

/** Exported function `write_fd`.
 * Write path helper `write_fd`.
 * @param fd i32
 * @param ptr *u8
 * @param count usize
 * @return isize
 */
export function write_fd(fd: i32, ptr: *u8, count: usize): isize {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // Covers export-extern debug/diag and std.io/std.heap import surface calls.
  unsafe {
  let h: usize = 1 as usize;
  if (fd != 1) { return (-1) as isize; }
  let off: usize = 0 as usize;
  while (off < count) {
    let r: i32 = io.write(h, &ptr[off], count - off, 0 as u32);
    if (r <= 0) { return (-1) as isize; }
    off = off + (r as usize);
  }
  return count as isize;
  }
  return 0 as isize;
}

/** Exported function `extract_document_text`.
 * Implements `extract_document_text`.
 * @param body *u8
 * @param body_len i32
 * @param out_buf *u8
 * @param out_cap i32
 * @return i32
 */
export function extract_document_text(body: *u8, body_len: i32, out_buf: *u8, out_cap: i32): i32 {
  let key_len: i32 = 8;
  let key: u8[8] = [34, 116, 101, 120, 116, 34, 58, 34];
  let i: i32 = 0;
  while (i + key_len <= body_len) {
    let is_match: i32 = 1;
    let k: i32 = 0;
    while (k < key_len) {
      if (body[i + k] != key[k]) { is_match = 0; break; }
      k = k + 1;
    }
    if (is_match != 0) {
      let start: i32 = i + key_len;
      let out_len: i32 = 0;
      while (start < body_len && out_len < out_cap - 1) {
        let c: u8 = body[start];
        if (c == 34) {
          break;
        }
        if (c == 92 && start + 1 < body_len) {
          start = start + 1;
          let next: u8 = body[start];
          if (next == 110) { out_buf[out_len] = 10; out_len = out_len + 1; start = start + 1;
            continue; }
          if (next == 114) { out_buf[out_len] = 13; out_len = out_len + 1; start = start + 1;
            continue; }
          if (next == 116) { out_buf[out_len] = 9; out_len = out_len + 1; start = start + 1;
            continue; }
          if (next == 34 || next == 92) { out_buf[out_len] = next; out_len = out_len + 1; start =
            start + 1; continue; }
          out_buf[out_len] = next;
          out_len = out_len + 1;
          start = start + 1;
          continue;
        }
        out_buf[out_len] = c;
        out_len = out_len + 1;
        start = start + 1;
      }
      out_buf[out_len] = 0;
      return out_len;
    }
    i = i + 1;
  }
  return -1;
}

/** See implementation for details. */

/** Exported function `lsp_alloc`.
 * Memory management helper `lsp_alloc`.
 * @param size usize
 * @return *u8
 */
export function lsp_alloc(size: usize): *u8 {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // Covers export-extern debug/diag and std.io/std.heap import surface calls.
  unsafe {
  if (size == 0 || size > (LSP_BODY_SAFETY_CAP as usize)) { return 0 as *u8; }
  return heap.alloc_zero(size);
  }
  return 0 as *u8;
}

/** Exported function `lsp_free`.
 * Memory management helper `lsp_free`.
 * @param ptr *u8
 * @return void
 */
export function lsp_free(ptr: *u8): void {
  // PLATFORM: SHARED — LANG-007 S0: whole-body unsafe FFI gate (Cap-T001).
  // Covers export-extern debug/diag and std.io/std.heap import surface calls.
  unsafe {
  heap.free(ptr);
  }
}

/** Exported function `lsp_is_null`.
 * Implements `lsp_is_null`.
 * @param ptr *u8
 * @return i32
 */
export function lsp_is_null(ptr: *u8): i32 {
  if (ptr == 0 as *u8) { return 1; }
  return 0;
}
