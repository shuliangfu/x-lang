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

// Parser self-test entry. Kept out of parser.x so the product parser_x.o
// pure-asm emit has no main and no main-rooted dead-code drop.
// Same split as lexer_standalone.x. PLATFORM: SHARED.

const parser = import("parser");

/**
 * Open a NUL-terminated path read-only.
 * @param path *u8 — NUL-terminated path; caller owns the bytes
 * @return i32 — file descriptor, or a negative value when open fails
 * PLATFORM: SHARED — no_mangle FS surface in runtime_io_abi.x.
 */
export extern "C" function fs_open_read_c(path: *u8): i32;

/**
 * Read up to count bytes into buf.
 * @param fd i32 — descriptor from fs_open_read_c
 * @param buf *u8 — destination; caller owns; capacity >= count
 * @param count usize — maximum bytes to read
 * @return isize — bytes read, or a negative value on failure
 * PLATFORM: SHARED
 */
export extern "C" function fs_posix_read_c(fd: i32, buf: *u8, count: usize): isize;

/**
 * Close a descriptor opened by fs_open_read_c.
 * @param fd i32 — descriptor to close
 * @return i32 — 0 on success, negative on failure
 * PLATFORM: SHARED
 */
export extern "C" function fs_posix_close_c(fd: i32): i32;

/**
 * Parser smoke entry. Reads /tmp/shu_parse_test.su when that file exists.
 * Otherwise parses the embedded `function main(): i32 { return 0; }`.
 * @return i32 — 0 when parse succeeds and return_val is 0, 1 on parse
 *   failure, 2 when the embedded program's return_val is not 0
 * PLATFORM: SHARED
 */
export function main(): i32 {
  // Whole-body unsafe: the three FS calls are extern "C".
  // PLATFORM: SHARED.
  unsafe {
    let path: u8[32] = [
      47, 116, 109, 112, 47, 115, 104, 117, 95, 112, 97, 114, 115, 101, 95, 116,
      101, 115, 116, 46, 115, 117, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    let fd: i32 = fs_open_read_c(path);
    if (fd >= 0) {
      let buf: u8[128] = [];
      let n: isize = fs_posix_read_c(fd, buf, 128);
      fs_posix_close_c(fd);
      if (n > 0) {
        let sl: u8[] = parser.parser_slice_from_buf(&buf[0], (n as i32));
        let res: parser.ParseResult = parser.parse(sl);
        if (res.ok) {
          return 0;
        }
        return 1;
      }
    }
    // Embedded source: function main(): i32 { return 0; }
    let src: u8[128] = [
      102, 117, 110, 99, 116, 105, 111, 110, 32, 109, 97, 105, 110, 40, 41, 58,
      32, 105, 51, 50, 32, 123, 32, 114, 101, 116, 117, 114, 110, 32, 48, 59,
      32, 125, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ];
    let sl: u8[] = parser.parser_slice_from_buf(&src[0], 35);
    let res: parser.ParseResult = parser.parse(sl);
    if (!res.ok) {
      return 1;
    }
    if (res.return_val != 0) {
      return 2;
    }
    return 0;
  }
}
