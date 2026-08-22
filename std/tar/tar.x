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

export const TAR_PATH_MAX: i32 = 512;

/** Exported function `tar_f_tar_v1_marker_c`.
 * Implements `tar_f_tar_v1_marker_c`.
 * @return i32
 */
export function tar_f_tar_v1_marker_c(): i32 {
  return 1;
}

/** Exported function `tar_f_tar_v2_marker_c`.
 * Implements `tar_f_tar_v2_marker_c`.
 * @return i32
 */
export function tar_f_tar_v2_marker_c(): i32 {
  return 1;
}

/** Exported function `tar_path_max_c`.
 * Implements `tar_path_max_c`.
 * @return i32
 */
export function tar_path_max_c(): i32 {
  return TAR_PATH_MAX;
}

/** Exported function `tar_read_octal`.
 * Read path helper `tar_read_octal`.
 * @param buf *u8
 * @param off i32
 * @param width i32
 * @return i32
 */
export function tar_read_octal(buf: *u8, off: i32, width: i32): i32 {
  let v: i32 = 0;
  let i: i32 = 0;
  while (i < width) {
    let c: u8 = buf[off + i];
    if (c < 48 || c > 55) { return v; }
    v = (v << 3) + ((c - 48) as i32);
    i = i + 1;
  }
  return v;
}

/** Exported function `tar_read_header_c`.
 * Read path helper `tar_read_header_c`.
 * @param buf *u8
 * @param len i32
 * @param name_out *u8
 * @param name_cap i32
 * @param size_out *i32
 * @return i32
 */
export function tar_read_header_c(buf: *u8, len: i32, name_out: *u8, name_cap: i32, size_out: *i32): i32 {
  if (buf == 0 || len < 512 || name_out == 0 || name_cap <= 0 || size_out == 0) {
    return -1;
  }
  let i: i32 = 0;
  while (i < name_cap - 1 && i < 100 && buf[i] != 0) {
    name_out[i] = buf[i];
    i = i + 1;
  }
  name_out[i] = 0;
  size_out[0] = tar_read_octal(buf, 124, 12);
  return 0;
}

/** Exported function `tar_write_octal`.
 * Write path helper `tar_write_octal`.
 * @param buf *u8
 * @param off i32
 * @param width i32
 * @param v i32
 * @return void
 */
export function tar_write_octal(buf: *u8, off: i32, width: i32, v: i32): void {
  let w: i32 = width - 1;
  let n: i32 = v;
  if (n < 0) { n = 0; }
  let i: i32 = off + w - 1;
  while (i > off) {
    buf[i] = (48 + (n & 7)) as u8;
    n = n >> 3;
    i = i - 1;
  }
  buf[off] = 48;
  buf[off + width - 1] = 0;
}

/** Exported function `tar_header_chksum`.
 * Implements `tar_header_chksum`.
 * @param buf *u8
 * @return i32
 */
export function tar_header_chksum(buf: *u8): i32 {
  let sum: i32 = 0;
  let i: i32 = 0;
  while (i < 512) {
    let c: i32 = buf[i] as i32;
    if (i >= 148 && i < 156) { c = 32; }
    sum = sum + c;
    i = i + 1;
  }
  return sum;
}

/** Exported function `tar_write_header_c`.
 * Write path helper `tar_write_header_c`.
 * @param buf *u8
 * @param buf_cap i32
 * @param name *u8
 * @param name_len i32
 * @param file_size i32
 * @return i32
 */
export function tar_write_header_c(buf: *u8, buf_cap: i32, name: *u8, name_len: i32, file_size: i32): i32 {
  if (buf == 0 || buf_cap < 512 || name == 0 || name_len < 0 || name_len > 100) {
    return -1;
  }
  let i: i32 = 0;
  while (i < 512) { buf[i] = 0; i = i + 1; }
  i = 0;
  while (i < name_len) { buf[i] = name[i]; i = i + 1; }
  tar_write_octal(buf, 100, 8, 420);    /* mode 0644 */
  tar_write_octal(buf, 108, 8, 0);      /* uid */
  tar_write_octal(buf, 116, 8, 0);     /* gid */
  tar_write_octal(buf, 124, 12, file_size);
  tar_write_octal(buf, 136, 12, 0);     /* mtime */
  i = 148;
  // Chksum field placeholder spaces (ustar layout bytes 148..155).
  while (i < 156) { buf[i] = 32; i = i + 1; }
  buf[156] = 48;                          /* typeflag '0' = regular file */
  buf[257] = 117; buf[258] = 115; buf[259] = 116; buf[260] = 97; buf[261] = 114;  /* "ustar" */
  buf[262] = 0;
  buf[263] = 48; buf[264] = 48;           /* version "00" */
  let chk: i32 = tar_header_chksum(buf);
  tar_write_octal(buf, 148, 7, chk);       /* 6-digit octal + NUL */
  buf[155] = 32;                           /* chksum trailing space */
  return 0;
}

/**
 * Bytes occupied by a file payload including 512-byte padding (0 when n<=0).
 * @param n i32 — payload size in bytes; n<=0 → 0
 * @return i32 — n rounded up to a multiple of 512
 * PLATFORM: SHARED — UStar block size; no OS I/O
 */
function tar_padded_span(n: i32): i32 {
  if (n <= 0) { return 0; }
  let rem: i32 = n % 512;
  if (rem == 0) { return n; }
  return n + (512 - rem);
}

/**
 * Append one UStar entry at *off_io (STD-038 short path, name_len<=100).
 * Writes a 512-byte header via tar_write_header_c, then file data padded to 512.
 * Directories (is_dir!=0) use typeflag '5', size 0, and no data block.
 * @param buf *u8 — archive buffer; caller owns
 * @param buf_cap i32 — capacity of buf in bytes
 * @param off_io *i32 — in/out byte offset of the next free byte; updated on success
 * @param name *u8 — entry name bytes (not required to be NUL-terminated)
 * @param name_len i32 — name byte count; must be 0..100 (UStar name field)
 * @param data *u8 — file payload; ignored when is_dir!=0 or data_len<=0; null rejected when copying
 * @param data_len i32 — payload size; ignored when is_dir!=0
 * @param is_dir i32 — non-zero → directory typeflag '5'
 * @return i32 — 0 success, -1 null/cap/name_len/overflow
 * PLATFORM: SHARED — in-memory archive; prefix/Pax (STD-152) is a later leaf
 */
export function tar_append_entry_c(buf: *u8, buf_cap: i32, off_io: *i32, name: *u8, name_len: i32, data: *u8,
  data_len: i32, is_dir: i32): i32 {
  if (buf == 0 || off_io == 0 || name == 0 || name_len < 0 || name_len > 100) {
    return -1;
  }
  let off: i32 = off_io[0];
  if (off < 0 || data_len < 0) { return -1; }
  let file_size: i32 = data_len;
  if (is_dir != 0) { file_size = 0; }
  let span: i32 = 0;
  if (is_dir == 0) { span = tar_padded_span(file_size); }
  if (off + 512 + span > buf_cap) { return -1; }
  let hdr: *u8 = buf + off;
  if (tar_write_header_c(hdr, buf_cap - off, name, name_len, file_size) != 0) {
    return -1;
  }
  // Directories overwrite typeflag '0' from write_header and recompute chksum.
  if (is_dir != 0) {
    hdr[156] = 53;
    let chk: i32 = tar_header_chksum(hdr);
    tar_write_octal(hdr, 148, 7, chk);
    hdr[155] = 32;
  }
  off = off + 512;
  if (is_dir == 0 && file_size > 0) {
    if (data == 0) { return -1; }
    let i: i32 = 0;
    while (i < file_size) {
      buf[off + i] = data[i];
      i = i + 1;
    }
    off = off + file_size;
    let pad: i32 = span - file_size;
    i = 0;
    while (i < pad) {
      buf[off + i] = 0;
      i = i + 1;
    }
    off = off + pad;
  }
  off_io[0] = off;
  return 0;
}

/**
 * Iterate the next UStar header in a memory archive (STD-038 short path).
 * Zero-filled 512-byte blocks or running past buf_len end the walk (return 1).
 * Does not parse Pax / GNU longname; name is the 100-byte UStar name field.
 * @param buf *u8 — archive bytes
 * @param buf_len i32 — valid length of buf
 * @param pos_io *i32 — in/out header offset; advanced past header+payload on success
 * @param name_out *u8 — NUL-terminated name; caller owns
 * @param name_cap i32 — capacity of name_out; must be >0
 * @param size_out *i32 — file size from the header octal field
 * @param type_out *i32 — ASCII typeflag ('0'=48 file, '5'=53 directory)
 * @return i32 — 0 entry, 1 end, -1 null/bad offset
 * PLATFORM: SHARED — in-memory walk; Pax skip is a later leaf
 */
export function tar_next_entry_c(buf: *u8, buf_len: i32, pos_io: *i32, name_out: *u8, name_cap: i32,
  size_out: *i32, type_out: *i32): i32 {
  if (buf == 0 || pos_io == 0 || name_out == 0 || name_cap <= 0 || size_out == 0 || type_out == 0) {
    return -1;
  }
  let pos: i32 = pos_io[0];
  if (pos < 0) { return -1; }
  if (pos + 512 > buf_len) { return 1; }
  let hdr: *u8 = buf + pos;
  let all_zero: i32 = 1;
  let i: i32 = 0;
  while (i < 512) {
    if (hdr[i] != 0) { all_zero = 0; }
    i = i + 1;
  }
  if (all_zero != 0) { return 1; }
  i = 0;
  while (i < name_cap - 1 && i < 100 && hdr[i] != 0) {
    name_out[i] = hdr[i];
    i = i + 1;
  }
  name_out[i] = 0;
  let sz: i32 = tar_read_octal(hdr, 124, 12);
  if (sz < 0) { return -1; }
  size_out[0] = sz;
  type_out[0] = hdr[156] as i32;
  pos_io[0] = pos + 512 + tar_padded_span(sz);
  return 0;
}

/**
 * Copy the file payload that follows the header at entry_off.
 * Directories and empty files return 0. Truncates to out_cap.
 * @param buf *u8 — archive bytes
 * @param buf_len i32 — valid length of buf
 * @param entry_off i32 — byte offset of the UStar header (not the data)
 * @param out *u8 — destination; caller owns
 * @param out_cap i32 — capacity of out
 * @return i32 — bytes copied, 0 for dir/empty, -1 on null/range error
 * PLATFORM: SHARED — in-memory extract; Pax header skip is a later leaf
 */
export function tar_read_entry_data_c(buf: *u8, buf_len: i32, entry_off: i32, out: *u8, out_cap: i32): i32 {
  if (buf == 0 || out == 0 || entry_off < 0 || out_cap < 0) { return -1; }
  if (entry_off + 512 > buf_len) { return -1; }
  let hdr: *u8 = buf + entry_off;
  let tf: i32 = hdr[156] as i32;
  let sz: i32 = tar_read_octal(hdr, 124, 12);
  if (sz < 0) { return -1; }
  if (tf == 53 || sz == 0) { return 0; }
  let n: i32 = sz;
  if (n > out_cap) { n = out_cap; }
  let data_off: i32 = entry_off + 512;
  if (data_off + n > buf_len) { return -1; }
  let i: i32 = 0;
  while (i < n) {
    out[i] = buf[data_off + i];
    i = i + 1;
  }
  return n;
}

/** Exported function `tar_extended_smoke_c`.
 * Implements `tar_extended_smoke_c`.
 * @return i32
 */
export function tar_extended_smoke_c(): i32 {
  return -1;
}
