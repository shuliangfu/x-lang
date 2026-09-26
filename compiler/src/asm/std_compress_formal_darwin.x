// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// std_compress_formal_darwin.x — Darwin arm64 body of std/compress/compress.o.
//
// One-shot and stream names forward to the submodule symbols. The stream
// record is 24 bytes: format at 0, mode at 4, state at 8, state_cap at 16.
// On arm64 a by-value record larger than 16 bytes arrives as a pointer.
// compress_init already takes a pointer. Caps are gzip 128, brotli 32,
// zstd 32. Each forward makes one extern call. Linux and Windows keep
// the C face. The brotli-lib init extern is longer than this compiler
// accepts, so the object spells it cz_brotli_lib_init_d_c and ensure
// renames that undefined symbol to the real submodule name.
// PLATFORM: MACOS|DARWIN arm64.

extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;
extern function std_compress_gzip_gzip_compress(inp: *u8, in_len: i32, out: *u8, out_cap: i32): i32;
extern function std_compress_gzip_gzip_decompress(inp: *u8, in_len: i32, out: *u8, out_cap: i32): i32;
extern function std_compress_brotli_brotli_compress(inp: *u8, in_len: i32, out: *u8, out_cap: i32): i32;
extern function std_compress_brotli_brotli_decompress(inp: *u8, in_len: i32, out: *u8, out_cap: i32): i32;
extern function std_compress_zstd_zstd_compress(inp: *u8, in_len: i32, out: *u8, out_cap: i32): i32;
extern function std_compress_zstd_zstd_decompress(inp: *u8, in_len: i32, out: *u8, out_cap: i32): i32;
extern function std_compress_gzip_gzip_stream_init_compress(state: *u8, state_cap: i32): i32;
extern function std_compress_gzip_gzip_stream_init_decompress(state: *u8, state_cap: i32): i32;
extern function std_compress_gzip_gzip_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32;
extern function std_compress_gzip_gzip_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, in_consumed: *i32): i32;
extern function std_compress_gzip_gzip_stream_end(state: *u8, state_cap: i32): i32;
extern function std_compress_brotli_brotli_stream_init_compress(state: *u8, state_cap: i32): i32;
extern function std_compress_brotli_brotli_stream_init_decompress(state: *u8, state_cap: i32): i32;
extern function std_compress_brotli_brotli_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32;
extern function std_compress_brotli_brotli_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, in_consumed: *i32): i32;
extern function std_compress_brotli_brotli_stream_end(state: *u8, state_cap: i32): i32;
extern function std_compress_zstd_zstd_stream_init_compress(state: *u8, state_cap: i32): i32;
extern function std_compress_zstd_zstd_stream_init_decompress(state: *u8, state_cap: i32): i32;
extern function std_compress_zstd_zstd_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32;
extern function std_compress_zstd_zstd_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, in_consumed: *i32): i32;
extern function std_compress_zstd_zstd_stream_end(state: *u8, state_cap: i32): i32;
extern function cz_brotli_lib_init_d_c(state: *u8, state_cap: i32): i32;

/**
 * Anchor for this Darwin compress object.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_formal_darwin_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Address of a field inside the 24-byte stream record.
 * @param p record address
 * @param off byte offset
 * @return *u8 — field address
 * PLATFORM: MACOS|DARWIN
 */
function cz_at(p: *u8, off: i32): *u8 {
  return p + off;
}

/**
 * Store an i32 through a pointer.
 * @param p destination
 * @param v value
 * PLATFORM: MACOS|DARWIN
 */
function cz_store_i32(p: *u8, v: i32): void {
  let x: i32 = v;
  unsafe {
    let src: *u8 = &x as *u8;
    memcpy(p, src, 4);
  }
}

/**
 * Load an i32 through a pointer.
 * @param p source
 * @return i32 — stored value
 * PLATFORM: MACOS|DARWIN
 */
function cz_load_i32(p: *u8): i32 {
  let v: i32 = 0;
  unsafe {
    let dst: *u8 = &v as *u8;
    memcpy(dst, p, 4);
  }
  return v;
}

/**
 * Store a pointer through a pointer.
 * @param p destination
 * @param v pointer value
 * PLATFORM: MACOS|DARWIN
 */
function cz_store_ptr(p: *u8, v: *u8): void {
  let x: *u8 = v;
  unsafe {
    let src: *u8 = &x as *u8;
    memcpy(p, src, 8);
  }
}

/**
 * Load a pointer through a pointer.
 * @param p source
 * @return *u8 — stored pointer
 * PLATFORM: MACOS|DARWIN
 */
function cz_load_ptr(p: *u8): *u8 {
  let v: *u8 = 0;
  unsafe {
    let dst: *u8 = &v as *u8;
    memcpy(dst, p, 8);
  }
  return v;
}

/**
 * Gzip format id.
 * @return i32 — 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_format_gzip(): i32 {
  return 0;
}

/**
 * Brotli format id.
 * @return i32 — 1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_format_brotli(): i32 {
  return 1;
}

/**
 * Zstd format id.
 * @return i32 — 2
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_format_zstd(): i32 {
  return 2;
}

/**
 * Compress mode id.
 * @return i32 — 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_mode_compress(): i32 {
  return 0;
}

/**
 * Decompress mode id.
 * @return i32 — 1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_mode_decompress(): i32 {
  return 1;
}

/**
 * State bytes for one format. Unknown formats return -1.
 * @param format 0 gzip, 1 brotli, 2 zstd
 * @return i32 — 128, 32, 32, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_compress_state_bytes_for(format: i32): i32 {
  if (format == 0) {
    return 128;
  }
  if (format == 1) {
    return 32;
  }
  if (format == 2) {
    return 32;
  }
  return 0 - 1;
}

/**
 * Largest stream state, which is the gzip cap.
 * @return i32 — 128
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_compress_state_bytes(): i32 {
  return 128;
}

/**
 * Gzip stream state cap.
 * @return i32 — 128
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_gzip_stream_state_bytes(): i32 {
  return 128;
}

/**
 * Brotli stream state cap.
 * @return i32 — 32
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_brotli_stream_state_bytes(): i32 {
  return 32;
}

/**
 * Zstd stream state cap.
 * @return i32 — 32
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_zstd_stream_state_bytes(): i32 {
  return 32;
}

/**
 * Forward a one-shot gzip compress.
 * @param inp input
 * @param in_len input length
 * @param out output
 * @param out_cap output capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_gzip_compress(inp: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_gzip_gzip_compress(inp, in_len, out, out_cap);
  }
  return n;
}

/**
 * Forward a one-shot gzip decompress.
 * @param inp input
 * @param in_len input length
 * @param out output
 * @param out_cap output capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_gzip_decompress(inp: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_gzip_gzip_decompress(inp, in_len, out, out_cap);
  }
  return n;
}

/**
 * Forward a one-shot brotli compress.
 * @param inp input
 * @param in_len input length
 * @param out output
 * @param out_cap output capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_brotli_compress(inp: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_brotli_brotli_compress(inp, in_len, out, out_cap);
  }
  return n;
}

/**
 * Forward a one-shot brotli decompress.
 * @param inp input
 * @param in_len input length
 * @param out output
 * @param out_cap output capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_brotli_decompress(inp: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_brotli_brotli_decompress(inp, in_len, out, out_cap);
  }
  return n;
}

/**
 * Forward a one-shot zstd compress.
 * @param inp input
 * @param in_len input length
 * @param out output
 * @param out_cap output capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_zstd_compress(inp: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_zstd_zstd_compress(inp, in_len, out, out_cap);
  }
  return n;
}

/**
 * Forward a one-shot zstd decompress.
 * @param inp input
 * @param in_len input length
 * @param out output
 * @param out_cap output capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_zstd_decompress(inp: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_zstd_zstd_decompress(inp, in_len, out, out_cap);
  }
  return n;
}

/**
 * Forward gzip stream compress init.
 * @param state state buffer
 * @param state_cap capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_gzip_stream_init_compress(state: *u8, state_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_gzip_gzip_stream_init_compress(state, state_cap);
  }
  return n;
}

/**
 * Forward gzip stream decompress init.
 * @param state state buffer
 * @param state_cap capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_gzip_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_gzip_gzip_stream_init_decompress(state, state_cap);
  }
  return n;
}

/**
 * Forward one gzip stream compress step. Eight arguments stay in registers.
 * @param state state buffer
 * @param state_cap capacity
 * @param inp input
 * @param in_len input length
 * @param out output
 * @param out_cap output capacity
 * @param is_last last-chunk flag
 * @param in_consumed consumed-byte slot
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_gzip_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
  let s: *u8 = state;
  let cap: i32 = state_cap;
  let ip: *u8 = inp;
  let il: i32 = in_len;
  let op: *u8 = out;
  let oc: i32 = out_cap;
  let last: i32 = is_last;
  let got: *i32 = in_consumed;
  let n: i32 = 0;
  unsafe {
    n = std_compress_gzip_gzip_stream_compress(s, cap, ip, il, op, oc, last, got);
  }
  return n;
}

/**
 * Forward one gzip stream decompress step.
 * @param state state buffer
 * @param state_cap capacity
 * @param inp input
 * @param in_len input length
 * @param out output
 * @param out_cap output capacity
 * @param in_consumed consumed-byte slot
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_gzip_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, in_consumed: *i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_gzip_gzip_stream_decompress(state, state_cap, inp, in_len, out, out_cap, in_consumed);
  }
  return n;
}

/**
 * Forward gzip stream end.
 * @param state state buffer
 * @param state_cap capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_gzip_stream_end(state: *u8, state_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_gzip_gzip_stream_end(state, state_cap);
  }
  return n;
}

/**
 * Forward brotli stream compress init.
 * @param state state buffer
 * @param state_cap capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_brotli_stream_init_compress(state: *u8, state_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_brotli_brotli_stream_init_compress(state, state_cap);
  }
  return n;
}

/**
 * Forward brotli stream decompress init.
 * @param state state buffer
 * @param state_cap capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_brotli_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_brotli_brotli_stream_init_decompress(state, state_cap);
  }
  return n;
}

/**
 * Forward one brotli stream compress step.
 * @param state state buffer
 * @param state_cap capacity
 * @param inp input
 * @param in_len input length
 * @param out output
 * @param out_cap output capacity
 * @param is_last last-chunk flag
 * @param in_consumed consumed-byte slot
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_brotli_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
  let s: *u8 = state;
  let cap: i32 = state_cap;
  let ip: *u8 = inp;
  let il: i32 = in_len;
  let op: *u8 = out;
  let oc: i32 = out_cap;
  let last: i32 = is_last;
  let got: *i32 = in_consumed;
  let n: i32 = 0;
  unsafe {
    n = std_compress_brotli_brotli_stream_compress(s, cap, ip, il, op, oc, last, got);
  }
  return n;
}

/**
 * Forward one brotli stream decompress step.
 * @param state state buffer
 * @param state_cap capacity
 * @param inp input
 * @param in_len input length
 * @param out output
 * @param out_cap output capacity
 * @param in_consumed consumed-byte slot
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_brotli_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, in_consumed: *i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_brotli_brotli_stream_decompress(state, state_cap, inp, in_len, out, out_cap, in_consumed);
  }
  return n;
}

/**
 * Forward brotli stream end.
 * @param state state buffer
 * @param state_cap capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_brotli_stream_end(state: *u8, state_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_brotli_brotli_stream_end(state, state_cap);
  }
  return n;
}

/**
 * Forward zstd stream compress init.
 * @param state state buffer
 * @param state_cap capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_zstd_stream_init_compress(state: *u8, state_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_zstd_zstd_stream_init_compress(state, state_cap);
  }
  return n;
}

/**
 * Forward zstd stream decompress init.
 * @param state state buffer
 * @param state_cap capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_zstd_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_zstd_zstd_stream_init_decompress(state, state_cap);
  }
  return n;
}

/**
 * Forward one zstd stream compress step.
 * @param state state buffer
 * @param state_cap capacity
 * @param inp input
 * @param in_len input length
 * @param out output
 * @param out_cap output capacity
 * @param is_last last-chunk flag
 * @param in_consumed consumed-byte slot
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_zstd_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
  let s: *u8 = state;
  let cap: i32 = state_cap;
  let ip: *u8 = inp;
  let il: i32 = in_len;
  let op: *u8 = out;
  let oc: i32 = out_cap;
  let last: i32 = is_last;
  let got: *i32 = in_consumed;
  let n: i32 = 0;
  unsafe {
    n = std_compress_zstd_zstd_stream_compress(s, cap, ip, il, op, oc, last, got);
  }
  return n;
}

/**
 * Forward one zstd stream decompress step.
 * @param state state buffer
 * @param state_cap capacity
 * @param inp input
 * @param in_len input length
 * @param out output
 * @param out_cap output capacity
 * @param in_consumed consumed-byte slot
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_zstd_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32, in_consumed: *i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_zstd_zstd_stream_decompress(state, state_cap, inp, in_len, out, out_cap, in_consumed);
  }
  return n;
}

/**
 * Forward zstd stream end.
 * @param state state buffer
 * @param state_cap capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_zstd_stream_end(state: *u8, state_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = std_compress_zstd_zstd_stream_end(state, state_cap);
  }
  return n;
}

/**
 * Forward the brotli-lib decompress init name.
 * @param state state buffer
 * @param state_cap capacity
 * @return i32 — submodule result
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_brotli_lib_compress_brotli_stream_init_decompress_(state: *u8, state_cap: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = cz_brotli_lib_init_d_c(state, state_cap);
  }
  return n;
}

/**
 * Fill a stream record and init the matching submodule.
 * A null record returns -1. A known format with a bad mode returns -2.
 * An unknown format returns -9.
 * @param sc record pointer
 * @param state state buffer
 * @param state_cap capacity
 * @param format 0 gzip, 1 brotli, 2 zstd
 * @param mode 0 compress, 1 decompress
 * @return i32 — submodule result or an error code
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_compress_init(sc: *u8, state: *u8, state_cap: i32, format: i32, mode: i32): i32 {
  if (sc == 0) {
    return 0 - 1;
  }
  let p0: *u8 = cz_at(sc, 0);
  cz_store_i32(p0, format);
  let p4: *u8 = cz_at(sc, 4);
  cz_store_i32(p4, mode);
  let p8: *u8 = cz_at(sc, 8);
  cz_store_ptr(p8, state);
  let p16: *u8 = cz_at(sc, 16);
  cz_store_i32(p16, state_cap);
  if (format == 0) {
    if (mode == 0) {
      return std_compress_gzip_stream_init_compress(state, state_cap);
    }
    if (mode == 1) {
      return std_compress_gzip_stream_init_decompress(state, state_cap);
    }
    return 0 - 2;
  }
  if (format == 1) {
    if (mode == 0) {
      return std_compress_brotli_stream_init_compress(state, state_cap);
    }
    if (mode == 1) {
      return std_compress_brotli_stream_init_decompress(state, state_cap);
    }
    return 0 - 2;
  }
  if (format == 2) {
    if (mode == 0) {
      return std_compress_zstd_stream_init_compress(state, state_cap);
    }
    if (mode == 1) {
      return std_compress_zstd_stream_init_decompress(state, state_cap);
    }
    return 0 - 2;
  }
  return 0 - 9;
}

/**
 * Read a by-value stream record and run one compress step.
 * @param sc address of the 24-byte record
 * @param inp input
 * @param in_len input length
 * @param out output
 * @param out_cap output capacity
 * @param is_last last-chunk flag
 * @param in_consumed consumed-byte slot
 * @return i32 — submodule result, or -9
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_compress_process(sc: *u8, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
  let p0: *u8 = cz_at(sc, 0);
  let fmt: i32 = cz_load_i32(p0);
  let p4: *u8 = cz_at(sc, 4);
  let mode: i32 = cz_load_i32(p4);
  let p8: *u8 = cz_at(sc, 8);
  let state: *u8 = cz_load_ptr(p8);
  let p16: *u8 = cz_at(sc, 16);
  let cap: i32 = cz_load_i32(p16);
  if (fmt == 0) {
    if (mode == 0) {
      return std_compress_gzip_stream_compress(state, cap, inp, in_len, out, out_cap, is_last, in_consumed);
    }
    if (mode == 1) {
      return std_compress_gzip_stream_decompress(state, cap, inp, in_len, out, out_cap, in_consumed);
    }
    return 0 - 9;
  }
  if (fmt == 1) {
    if (mode == 0) {
      return std_compress_brotli_stream_compress(state, cap, inp, in_len, out, out_cap, is_last, in_consumed);
    }
    if (mode == 1) {
      return std_compress_brotli_stream_decompress(state, cap, inp, in_len, out, out_cap, in_consumed);
    }
    return 0 - 9;
  }
  if (fmt == 2) {
    if (mode == 0) {
      return std_compress_zstd_stream_compress(state, cap, inp, in_len, out, out_cap, is_last, in_consumed);
    }
    if (mode == 1) {
      return std_compress_zstd_stream_decompress(state, cap, inp, in_len, out, out_cap, in_consumed);
    }
    return 0 - 9;
  }
  return 0 - 9;
}

/**
 * Read a by-value stream record and end that stream.
 * @param sc address of the 24-byte record
 * @return i32 — submodule result, or -9
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_compress_compress_end(sc: *u8): i32 {
  let p0: *u8 = cz_at(sc, 0);
  let fmt: i32 = cz_load_i32(p0);
  let p8: *u8 = cz_at(sc, 8);
  let state: *u8 = cz_load_ptr(p8);
  let p16: *u8 = cz_at(sc, 16);
  let cap: i32 = cz_load_i32(p16);
  if (fmt == 0) {
    return std_compress_gzip_stream_end(state, cap);
  }
  if (fmt == 1) {
    return std_compress_brotli_stream_end(state, cap);
  }
  if (fmt == 2) {
    return std_compress_zstd_stream_end(state, cap);
  }
  return 0 - 9;
}
