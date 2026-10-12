// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-308/452 / P2 runtime rest: path bytes → a NUL-terminated buffer.
// w1135: this file is only the copy. The open calls live in rt_fs_open_call.x.
// A while and a 512-byte stack buffer in one translation unit do not emit.
// The slice marker stays in the C rest of the runtime_driver_no_c merge.
// PLATFORM: SHARED — Linux and Windows use the same two files.

/**
 * Copy path[0..path_len) into path_buf and write a trailing NUL.
 * Params: path — source bytes; path_len — length; path_buf — dest (>=512).
 * Returns: 1 on success, 0 on failure.
 * Contracts: path non-null; path_len in (0, 512); path_buf holds path_len+1 bytes.
 * The index is a loop local. A parameter used as a subscript reads one extra level.
 * PLATFORM: SHARED — link-name contract.
 */
#[no_mangle]
export function rt_fs_path_copy_nul(path: *u8, path_len: i32, path_buf: *u8): i32 {
  let i: i32 = 0;
  if (path == 0 as *u8) {
    return 0;
  }
  if (path_len <= 0) {
    return 0;
  }
  if (path_len >= 512) {
    return 0;
  }
  let s: *u8 = path;
  let d: *u8 = path_buf;
  while (i < path_len) {
    let k: i32 = i;
    let c: u8 = s[k];
    d[k] = c;
    i = i + 1;
  }
  let n: i32 = path_len;
  d[n] = 0;
  return 1;
}
