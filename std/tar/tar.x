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
/** UStar prefix field offset (POSIX 345). PLATFORM: SHARED */
export const TAR_PREFIX_OFF: i32 = 345;
/** UStar prefix field width. PLATFORM: SHARED */
export const TAR_PREFIX_LEN: i32 = 155;
/** Longest path that still uses prefix+name (not Pax). PLATFORM: SHARED */
export const TAR_MAX_PATH_USTAR: i32 = 256;
/** Pax extended-header typeflag `'x'`. PLATFORM: SHARED */
export const TAR_TYPE_PAX: i32 = 120;

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

/**
 * Concatenate UStar prefix (offset 345) and name (offset 0) into name_out.
 * Empty prefix is a no-op join (STD-038 short path).
 * @param hdr *u8 — 512-byte header
 * @param name_out *u8 — NUL-terminated destination; caller owns
 * @param name_cap i32 — capacity of name_out; must be > prefix_len+name_len
 * @return i32 — 0 success, -1 null/overflow
 * PLATFORM: SHARED — in-memory UStar; no OS I/O
 */
function tar_read_full_name(hdr: *u8, name_out: *u8, name_cap: i32): i32 {
  if (hdr == 0 || name_out == 0 || name_cap <= 0) { return -1; }
  let name_len: i32 = 0;
  let prefix_len: i32 = 0;
  while (name_len < 100 && hdr[name_len] != 0) {
    name_len = name_len + 1;
  }
  while (prefix_len < TAR_PREFIX_LEN && hdr[TAR_PREFIX_OFF + prefix_len] != 0) {
    prefix_len = prefix_len + 1;
  }
  let off: i32 = 0;
  if (prefix_len > 0) {
    if (prefix_len + name_len >= name_cap) { return -1; }
    let i: i32 = 0;
    while (i < prefix_len) {
      name_out[i] = hdr[TAR_PREFIX_OFF + i];
      i = i + 1;
    }
    off = prefix_len;
  }
  if (name_len + off >= name_cap) { return -1; }
  let j: i32 = 0;
  while (j < name_len) {
    name_out[off + j] = hdr[j];
    j = j + 1;
  }
  name_out[off + name_len] = 0;
  return 0;
}

/** Exported function `tar_read_header_c`.
 * Read a UStar header: full path (prefix+name) and octal size.
 * @param buf *u8 — archive bytes; first 512 is the header
 * @param len i32 — valid length of buf; must be >= 512
 * @param name_out *u8 — NUL-terminated path; caller owns
 * @param name_cap i32 — capacity of name_out
 * @param size_out *i32 — file size from the header
 * @return i32 — 0 success, -1 null/range
 * PLATFORM: SHARED — in-memory UStar; no OS I/O
 */
export function tar_read_header_c(buf: *u8, len: i32, name_out: *u8, name_cap: i32, size_out: *i32): i32 {
  if (buf == 0 || len < 512 || name_out == 0 || name_cap <= 0 || size_out == 0) {
    return -1;
  }
  if (tar_read_full_name(buf, name_out, name_cap) != 0) { return -1; }
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
 * Decimal digit count of n (n<=0 → 1). Used to size a Pax `LEN path=…` record.
 * @param n i32 — non-negative integer; negatives treated as 0
 * @return i32 — number of base-10 digits
 * PLATFORM: SHARED
 */
function tar_decimal_width(n: i32): i32 {
  if (n <= 0) { return 1; }
  let d: i32 = 0;
  let x: i32 = n;
  while (x > 0) {
    d = d + 1;
    x = x / 10;
  }
  return d;
}

/**
 * Write n as `width` decimal digits at buf[off..], most-significant first.
 * @param buf *u8 — destination
 * @param off i32 — first byte index
 * @param n i32 — value; negatives stored as 0
 * @param width i32 — digit count; caller guarantees width>=1
 * @return void
 * PLATFORM: SHARED
 */
function tar_write_decimal(buf: *u8, off: i32, n: i32, width: i32): void {
  let v: i32 = n;
  if (v < 0) { v = 0; }
  let i: i32 = off + width - 1;
  while (i >= off) {
    buf[i] = (48 + (v % 10)) as u8;
    v = v / 10;
    i = i - 1;
  }
}

/**
 * Split a 101..256-byte path at the last '/' into UStar prefix + name.
 * Prefix includes the slash (historical tar.c). name is the last component.
 * @param path *u8 — full path bytes
 * @param path_len i32 — byte count; caller already checked 101..256
 * @param prefix_len_out *i32 — bytes of prefix = path[0..prefix_len)
 * @param name_off_out *i32 — index of the name component in path
 * @param name_len_out *i32 — name component length; must be 0..100
 * @return i32 — 0 split ok, -1 no usable slash / prefix>155 / name>100
 * PLATFORM: SHARED — UStar prefix field is 155 bytes
 */
function tar_split_path(path: *u8, path_len: i32, prefix_len_out: *i32, name_off_out: *i32,
  name_len_out: *i32): i32 {
  if (path == 0 || prefix_len_out == 0 || name_off_out == 0 || name_len_out == 0) {
    return -1;
  }
  let split: i32 = -1;
  let i: i32 = path_len - 1;
  while (i >= 0) {
    if (path[i] == 47) {
      split = i;
      break;
    }
    i = i - 1;
  }
  // split<=0: no slash, or only a leading slash (prefix would be "/").
  // split>=155: prefix_len = split+1 would exceed TAR_PREFIX_LEN.
  if (split <= 0 || split >= TAR_PREFIX_LEN) { return -1; }
  let pfx: i32 = split + 1;
  let nm_off: i32 = split + 1;
  let nm_len: i32 = path_len - split - 1;
  if (nm_len < 0 || nm_len > 100) { return -1; }
  prefix_len_out[0] = pfx;
  name_off_out[0] = nm_off;
  name_len_out[0] = nm_len;
  return 0;
}

/**
 * Write a 512-byte UStar header with optional prefix and a caller typeflag.
 * @param buf *u8 — destination; first 512 bytes overwritten
 * @param buf_cap i32 — capacity; must be >= 512
 * @param prefix *u8 — prefix bytes; ignored when prefix_len==0 (may be null)
 * @param prefix_len i32 — 0..155
 * @param name *u8 — name-field bytes; ignored when name_len==0 (may be null)
 * @param name_len i32 — 0..100
 * @param file_size i32 — payload size stored in the octal size field
 * @param typeflag i32 — ASCII typeflag ('0'=48, '5'=53, 'x'=120)
 * @return i32 — 0 success, -1 null/cap/field overflow
 * PLATFORM: SHARED
 */
function tar_write_header_split(buf: *u8, buf_cap: i32, prefix: *u8, prefix_len: i32, name: *u8,
  name_len: i32, file_size: i32, typeflag: i32): i32 {
  if (buf == 0 || buf_cap < 512) { return -1; }
  if (prefix_len < 0 || prefix_len > TAR_PREFIX_LEN) { return -1; }
  if (name_len < 0 || name_len > 100) { return -1; }
  if (prefix_len > 0 && prefix == 0) { return -1; }
  if (name_len > 0 && name == 0) { return -1; }
  let i: i32 = 0;
  while (i < 512) { buf[i] = 0; i = i + 1; }
  i = 0;
  while (i < name_len) { buf[i] = name[i]; i = i + 1; }
  i = 0;
  while (i < prefix_len) {
    buf[TAR_PREFIX_OFF + i] = prefix[i];
    i = i + 1;
  }
  tar_write_octal(buf, 100, 8, 420);
  tar_write_octal(buf, 108, 8, 0);
  tar_write_octal(buf, 116, 8, 0);
  tar_write_octal(buf, 124, 12, file_size);
  tar_write_octal(buf, 136, 12, 0);
  i = 148;
  while (i < 156) { buf[i] = 32; i = i + 1; }
  buf[156] = typeflag as u8;
  buf[257] = 117; buf[258] = 115; buf[259] = 116; buf[260] = 97; buf[261] = 114;
  buf[262] = 0;
  buf[263] = 48; buf[264] = 48;
  let chk: i32 = tar_header_chksum(buf);
  tar_write_octal(buf, 148, 7, chk);
  buf[155] = 32;
  return 0;
}

/**
 * Write a Pax typeflag-'x' header plus a `LEN path=…\n` record, 512-aligned.
 * Updates *off_io past the padded Pax body. The following file/dir header is
 * written by the caller.
 * @param buf *u8 — archive buffer
 * @param buf_cap i32 — capacity
 * @param off_io *i32 — in/out offset
 * @param path *u8 — full path bytes
 * @param path_len i32 — 1..512
 * @return i32 — 0 success, -1 null/cap/record overflow
 * PLATFORM: SHARED — Pax 'x' extended header; no GNU @LongLink
 */
function tar_write_pax_header(buf: *u8, buf_cap: i32, off_io: *i32, path: *u8, path_len: i32): i32 {
  if (buf == 0 || off_io == 0 || path == 0 || path_len <= 0 || path_len > TAR_PATH_MAX) {
    return -1;
  }
  // Record layout: decimal(LEN) + " path=" + path + "\n". LEN includes the digits.
  let rest: i32 = 7 + path_len;
  let digits: i32 = 1;
  let t: i32 = 0;
  let rec_len: i32 = 0;
  while (t < 8) {
    rec_len = digits + rest;
    let d2: i32 = tar_decimal_width(rec_len);
    if (d2 == digits) { break; }
    digits = d2;
    t = t + 1;
  }
  if (digits <= 0 || rec_len <= 0 || rec_len > 640) { return -1; }
  let rec: u8[640] = [];
  tar_write_decimal(&rec[0], 0, rec_len, digits);
  rec[digits] = 32;
  rec[digits + 1] = 112;
  rec[digits + 2] = 97;
  rec[digits + 3] = 116;
  rec[digits + 4] = 104;
  rec[digits + 5] = 61;
  let i: i32 = 0;
  while (i < path_len) {
    rec[digits + 6 + i] = path[i];
    i = i + 1;
  }
  rec[digits + 6 + path_len] = 10;
  let off: i32 = off_io[0];
  if (off < 0) { return -1; }
  let span: i32 = tar_padded_span(rec_len);
  if (off + 512 + span > buf_cap) { return -1; }
  if (tar_write_header_split(buf + off, buf_cap - off, 0 as *u8, 0, 0 as *u8, 0, rec_len, TAR_TYPE_PAX) != 0) {
    return -1;
  }
  off = off + 512;
  i = 0;
  while (i < rec_len) {
    buf[off + i] = rec[i];
    i = i + 1;
  }
  off = off + rec_len;
  let pad: i32 = span - rec_len;
  i = 0;
  while (i < pad) {
    buf[off + i] = 0;
    i = i + 1;
  }
  off_io[0] = off + pad;
  return 0;
}

/**
 * Parse the `path=` key from a Pax record body into out.
 * @param body *u8 — Pax payload (not including the 512-byte header)
 * @param body_len i32 — payload size from the Pax header
 * @param out *u8 — NUL-terminated destination; caller owns
 * @param out_cap i32 — capacity of out
 * @return i32 — path byte count, or -1 if `path=` is missing/overflow
 * PLATFORM: SHARED
 */
function tar_parse_pax_path(body: *u8, body_len: i32, out: *u8, out_cap: i32): i32 {
  if (body == 0 || out == 0 || out_cap <= 0) { return -1; }
  let i: i32 = 0;
  while (i < body_len) {
    while (i < body_len && body[i] != 32) { i = i + 1; }
    if (i >= body_len) { break; }
    i = i + 1;
    if (i + 5 <= body_len && body[i] == 112 && body[i + 1] == 97 && body[i + 2] == 116 &&
      body[i + 3] == 104 && body[i + 4] == 61) {
      let j: i32 = i + 5;
      let n: i32 = 0;
      while (j < body_len && body[j] != 10) {
        if (n + 1 >= out_cap) { return -1; }
        out[n] = body[j];
        n = n + 1;
        j = j + 1;
      }
      out[n] = 0;
      return n;
    }
    while (i < body_len && body[i] != 10) { i = i + 1; }
    if (i < body_len) { i = i + 1; }
  }
  return -1;
}

/**
 * Append one UStar/Pax entry at *off_io (STD-038 short path + STD-152 long path).
 * name_len<=100: UStar name field. 101–256: prefix+name at last '/'. >256: Pax 'x'
 * plus a truncated name header. Directories (is_dir!=0) use typeflag '5', size 0.
 * @param buf *u8 — archive buffer; caller owns
 * @param buf_cap i32 — capacity of buf in bytes
 * @param off_io *i32 — in/out byte offset of the next free byte; updated on success
 * @param name *u8 — entry path bytes (not required to be NUL-terminated)
 * @param name_len i32 — path byte count; must be 0..512
 * @param data *u8 — file payload; ignored when is_dir!=0 or data_len<=0; null rejected when copying
 * @param data_len i32 — payload size; ignored when is_dir!=0
 * @param is_dir i32 — non-zero → directory typeflag '5'
 * @return i32 — 0 success, -1 null/cap/name_len/overflow
 * PLATFORM: SHARED — in-memory archive; no GNU @LongLink
 */
export function tar_append_entry_c(buf: *u8, buf_cap: i32, off_io: *i32, name: *u8, name_len: i32, data: *u8,
  data_len: i32, is_dir: i32): i32 {
  if (buf == 0 || off_io == 0 || name == 0 || name_len < 0 || name_len > TAR_PATH_MAX) {
    return -1;
  }
  let off: i32 = off_io[0];
  if (off < 0 || data_len < 0) { return -1; }
  let file_size: i32 = data_len;
  if (is_dir != 0) { file_size = 0; }
  let typeflag: i32 = 48;
  if (is_dir != 0) { typeflag = 53; }
  let span: i32 = 0;
  if (is_dir == 0) { span = tar_padded_span(file_size); }
  if (name_len > TAR_MAX_PATH_USTAR) {
    // 257..512: Pax extended header, then a truncated UStar name header.
    if (tar_write_pax_header(buf, buf_cap, off_io, name, name_len) != 0) { return -1; }
    off = off_io[0];
    let nm_len: i32 = name_len;
    if (nm_len > 100) { nm_len = 100; }
    if (off + 512 + span > buf_cap) { return -1; }
    if (tar_write_header_split(buf + off, buf_cap - off, 0 as *u8, 0, name, nm_len, file_size, typeflag) != 0) {
      return -1;
    }
    off = off + 512;
  } else if (name_len > 100) {
    // 101..256: last-'/' split into prefix (345) + name (0).
    let pfx_len: i32 = 0;
    let nm_off: i32 = 0;
    let nm_len: i32 = 0;
    if (tar_split_path(name, name_len, &pfx_len, &nm_off, &nm_len) != 0) { return -1; }
    if (off + 512 + span > buf_cap) { return -1; }
    if (tar_write_header_split(buf + off, buf_cap - off, name, pfx_len, name + nm_off, nm_len, file_size,
      typeflag) != 0) {
      return -1;
    }
    off = off + 512;
  } else {
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
  }
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
 * Iterate the next UStar header in a memory archive (STD-038 + STD-152).
 * Zero-filled 512-byte blocks or running past buf_len end the walk (return 1).
 * Pax typeflag `'x'` is skipped: `path=` is returned as the following entry's name.
 * Non-Pax names are prefix+name (empty prefix = short path).
 * @param buf *u8 — archive bytes
 * @param buf_len i32 — valid length of buf
 * @param pos_io *i32 — in/out header offset; advanced past header+payload on success
 * @param name_out *u8 — NUL-terminated name; caller owns
 * @param name_cap i32 — capacity of name_out; must be >0
 * @param size_out *i32 — file size from the (post-Pax) header octal field
 * @param type_out *i32 — ASCII typeflag of the real entry ('0'=48 file, '5'=53 directory)
 * @return i32 — 0 entry, 1 end, -1 null/bad offset
 * PLATFORM: SHARED — in-memory walk; GNU @LongLink is out of scope
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
  let sz: i32 = tar_read_octal(hdr, 124, 12);
  if (sz < 0) { return -1; }
  let tf: i32 = hdr[156] as i32;
  let pax_n: i32 = 0;
  let pax_path: u8[513] = [];
  if (tf == TAR_TYPE_PAX) {
    let data_off: i32 = pos + 512;
    if (data_off + sz > buf_len) { return -1; }
    pax_n = tar_parse_pax_path(buf + data_off, sz, &pax_path[0], 513);
    pos = data_off + tar_padded_span(sz);
    if (pos + 512 > buf_len) { return -1; }
    hdr = buf + pos;
    sz = tar_read_octal(hdr, 124, 12);
    if (sz < 0) { return -1; }
    tf = hdr[156] as i32;
  }
  if (pax_n > 0) {
    if (pax_n >= name_cap) { return -1; }
    i = 0;
    while (i < pax_n) {
      name_out[i] = pax_path[i];
      i = i + 1;
    }
    name_out[pax_n] = 0;
  } else {
    if (tar_read_full_name(hdr, name_out, name_cap) != 0) { return -1; }
  }
  size_out[0] = sz;
  type_out[0] = tf;
  pos_io[0] = pos + 512 + tar_padded_span(sz);
  return 0;
}

/**
 * Copy the file payload that follows the header at entry_off.
 * If entry_off points at a Pax `'x'` header (callers snapshot pos before next_entry),
 * skip the Pax block and read the following file header's payload.
 * Directories and empty files return 0. Truncates to out_cap.
 * @param buf *u8 — archive bytes
 * @param buf_len i32 — valid length of buf
 * @param entry_off i32 — byte offset of the UStar/Pax header (not the data)
 * @param out *u8 — destination; caller owns
 * @param out_cap i32 — capacity of out
 * @return i32 — bytes copied, 0 for dir/empty, -1 on null/range error
 * PLATFORM: SHARED — in-memory extract
 */
export function tar_read_entry_data_c(buf: *u8, buf_len: i32, entry_off: i32, out: *u8, out_cap: i32): i32 {
  if (buf == 0 || out == 0 || entry_off < 0 || out_cap < 0) { return -1; }
  if (entry_off + 512 > buf_len) { return -1; }
  let hdr: *u8 = buf + entry_off;
  let tf: i32 = hdr[156] as i32;
  let sz: i32 = tar_read_octal(hdr, 124, 12);
  if (sz < 0) { return -1; }
  let data_off: i32 = entry_off + 512;
  if (tf == TAR_TYPE_PAX) {
    let next_off: i32 = data_off + tar_padded_span(sz);
    if (next_off + 512 > buf_len) { return -1; }
    hdr = buf + next_off;
    tf = hdr[156] as i32;
    sz = tar_read_octal(hdr, 124, 12);
    if (sz < 0) { return -1; }
    data_off = next_off + 512;
  }
  if (tf == 53 || sz == 0) { return 0; }
  let n: i32 = sz;
  if (n > out_cap) { n = out_cap; }
  if (data_off + n > buf_len) { return -1; }
  let i: i32 = 0;
  while (i < n) {
    out[i] = buf[data_off + i];
    i = i + 1;
  }
  return n;
}

/**
 * STD-152 C-gate smoke: prefix-length file, directory, and 270-byte Pax path.
 * Mirrors tests/tar/long_path_dir.x (without the extra path_max/prefix_eq checks).
 * @return i32 — 0 success; 1/2/3 append fail; 4 walk fail; 5/6 payload; 7 unknown; 8 counts
 * PLATFORM: SHARED — in-memory only
 */
export function tar_extended_smoke_c(): i32 {
  let arc: u8[8192] = [];
  let off: i32 = 0;
  let path: u8[128] = [];
  let i: i32 = 0;
  while (i < 60) {
    path[i] = 97;
    i = i + 1;
  }
  // "/nested/file.su" — byte stores, not ARRAY_LIT (library TU locals).
  path[i] = 47; i = i + 1;
  path[i] = 110; i = i + 1;
  path[i] = 101; i = i + 1;
  path[i] = 115; i = i + 1;
  path[i] = 116; i = i + 1;
  path[i] = 101; i = i + 1;
  path[i] = 100; i = i + 1;
  path[i] = 47; i = i + 1;
  path[i] = 102; i = i + 1;
  path[i] = 105; i = i + 1;
  path[i] = 108; i = i + 1;
  path[i] = 101; i = i + 1;
  path[i] = 46; i = i + 1;
  path[i] = 115; i = i + 1;
  path[i] = 117; i = i + 1;
  let data: u8[1] = [];
  data[0] = 88;
  if (tar_append_entry_c(&arc[0], 8192, &off, &path[0], i, &data[0], 1, 0) != 0) { return 1; }
  let dir: u8[64] = [];
  i = 0;
  while (i < 40) {
    dir[i] = 100;
    i = i + 1;
  }
  // "/deep/"
  dir[i] = 47; i = i + 1;
  dir[i] = 100; i = i + 1;
  dir[i] = 101; i = i + 1;
  dir[i] = 101; i = i + 1;
  dir[i] = 112; i = i + 1;
  dir[i] = 47; i = i + 1;
  if (tar_append_entry_c(&arc[0], 8192, &off, &dir[0], i, 0 as *u8, 0, 1) != 0) { return 2; }
  let pax: u8[280] = [];
  i = 0;
  while (i < 270) {
    pax[i] = 112;
    i = i + 1;
  }
  data[0] = 81;
  if (tar_append_entry_c(&arc[0], 8192, &off, &pax[0], 270, &data[0], 1, 0) != 0) { return 3; }
  let pos: i32 = 0;
  let name_out: u8[520] = [];
  let sz: i32 = 0;
  let typ: i32 = 0;
  let got_file: i32 = 0;
  let got_dir: i32 = 0;
  let got_pax: i32 = 0;
  while (pos < off) {
    let entry_off: i32 = pos;
    let nr: i32 = tar_next_entry_c(&arc[0], off, &pos, &name_out[0], 520, &sz, &typ);
    if (nr == 1) { break; }
    if (nr != 0) { return 4; }
    if (typ == 53) {
      got_dir = got_dir + 1;
    } else if (typ == 48) {
      let outb: u8[4] = [];
      let n: i32 = tar_read_entry_data_c(&arc[0], off, entry_off, &outb[0], 4);
      if (name_out[0] == 97 && name_out[60] == 47) {
        got_file = got_file + 1;
        if (n != 1 || outb[0] != 88) { return 5; }
      } else if (name_out[0] == 112 && name_out[269] == 112) {
        got_pax = got_pax + 1;
        if (n != 1 || outb[0] != 81) { return 6; }
      } else {
        return 7;
      }
    }
  }
  if (got_file != 1 || got_dir != 1 || got_pax != 1) { return 8; }
  return 0;
}
