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
const zlib_m = import("std.compress.zlib");
const gzip_m = import("std.compress.gzip");
const brotli_m = import("std.compress.brotli");
const zstd_m = import("std.compress.zstd");

/** Exported function `deflate`.
 * Implements `deflate`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function deflate(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return zlib_m.deflate(in, in_len, out, out_cap);
}

/** Exported function `inflate`.
 * Implements `inflate`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function inflate(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return zlib_m.inflate(in, in_len, out, out_cap);
}

/** Exported function `gzip_compress`.
 * Implements `gzip_compress`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function gzip_compress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return gzip_m.gzip_compress(in, in_len, out, out_cap);
}

/** Exported function `gzip_decompress`.
 * Implements `gzip_decompress`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function gzip_decompress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return gzip_m.gzip_decompress(in, in_len, out, out_cap);
}

/** Exported function `brotli_compress`.
 * Implements `brotli_compress`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function brotli_compress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return brotli_m.brotli_compress(in, in_len, out, out_cap);
}

/** Exported function `brotli_decompress`.
 * Implements `brotli_decompress`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function brotli_decompress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return brotli_m.brotli_decompress(in, in_len, out, out_cap);
}

/** Exported function `brotli_available`.
 * Implements `brotli_available`.
 * @return i32
 */
export function brotli_available(): i32 {
  return brotli_m.brotli_available();
}

/** Exported function `brotli_smoke`.
 * Implements `brotli_smoke`.
 * @return i32
 */
export function brotli_smoke(): i32 {
  return brotli_m.brotli_smoke();
}

/** Exported function `zstd_compress`.
 * Implements `zstd_compress`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function zstd_compress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return zstd_m.zstd_compress(in, in_len, out, out_cap);
}

/** Exported function `zstd_decompress`.
 * Implements `zstd_decompress`.
 * @param in *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function zstd_decompress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return zstd_m.zstd_decompress(in, in_len, out, out_cap);
}

/** Exported function `zstd_available`.
 * Implements `zstd_available`.
 * @return i32
 */
export function zstd_available(): i32 {
  return zstd_m.zstd_available();
}

/** Exported function `zstd_smoke`.
 * Implements `zstd_smoke`.
 * @return i32
 */
export function zstd_smoke(): i32 {
  return zstd_m.zstd_smoke();
}

/** Exported function `zstd_stream_state_bytes`.
 * Implements `zstd_stream_state_bytes`.
 * @return i32
 */
export function zstd_stream_state_bytes(): i32 {
  return zstd_m.zstd_stream_state_bytes();
}

/** Exported function `zstd_stream_init_compress`.
 * Implements `zstd_stream_init_compress`.
 * @param state *u8
 * @param state_cap i32
 * @return i32
 */
export function zstd_stream_init_compress(state: *u8, state_cap: i32): i32 {
  return zstd_m.zstd_stream_init_compress(state, state_cap);
}

/** Exported function `zstd_stream_init_decompress`.
 * Implements `zstd_stream_init_decompress`.
 * @param state *u8
 * @param state_cap i32
 * @return i32
 */
export function zstd_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  return zstd_m.zstd_stream_init_decompress(state, state_cap);
}

/* See implementation. */
export function zstd_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  return zstd_m.zstd_stream_compress(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
}

/* See implementation. */
export function zstd_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  in_consumed: *i32): i32 {
  return zstd_m.zstd_stream_decompress(state, state_cap, inp, in_len, out, out_cap, in_consumed);
}

/** Exported function `zstd_stream_end`.
 * Implements `zstd_stream_end`.
 * @param state *u8
 * @param state_cap i32
 * @return i32
 */
export function zstd_stream_end(state: *u8, state_cap: i32): i32 {
  return zstd_m.zstd_stream_end(state, state_cap);
}

/** Exported function `brotli_stream_state_bytes`.
 * Implements `brotli_stream_state_bytes`.
 * @return i32
 */
export function brotli_stream_state_bytes(): i32 {
  return brotli_m.brotli_stream_state_bytes();
}

/** Exported function `brotli_stream_init_compress`.
 * Implements `brotli_stream_init_compress`.
 * @param state *u8
 * @param state_cap i32
 * @return i32
 */
export function brotli_stream_init_compress(state: *u8, state_cap: i32): i32 {
  return brotli_m.brotli_stream_init_compress(state, state_cap);
}

/** Exported function `brotli_stream_init_decompress`.
 * Implements `brotli_stream_init_decompress`.
 * @param state *u8
 * @param state_cap i32
 * @return i32
 */
export function brotli_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  return brotli_m.brotli_stream_init_decompress(state, state_cap);
}

/* See implementation. */
export function brotli_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  return brotli_m.brotli_stream_compress(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
}

/* See implementation. */
export function brotli_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  in_consumed: *i32): i32 {
  return brotli_m.brotli_stream_decompress(state, state_cap, inp, in_len, out, out_cap, in_consumed);
}

/** Exported function `brotli_stream_end`.
 * Implements `brotli_stream_end`.
 * @param state *u8
 * @param state_cap i32
 * @return i32
 */
export function brotli_stream_end(state: *u8, state_cap: i32): i32 {
  return brotli_m.brotli_stream_end(state, state_cap);
}

/** Exported function `gzip_stream_state_bytes`.
 * Implements `gzip_stream_state_bytes`.
 * @return i32
 */
export function gzip_stream_state_bytes(): i32 {
  return gzip_m.gzip_stream_state_bytes();
}

/** Exported function `gzip_stream_init_compress`.
 * Implements `gzip_stream_init_compress`.
 * @param state *u8
 * @param state_cap i32
 * @return i32
 */
export function gzip_stream_init_compress(state: *u8, state_cap: i32): i32 {
  return gzip_m.gzip_stream_init_compress(state, state_cap);
}

/** Exported function `gzip_stream_init_decompress`.
 * Implements `gzip_stream_init_decompress`.
 * @param state *u8
 * @param state_cap i32
 * @return i32
 */
export function gzip_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  return gzip_m.gzip_stream_init_decompress(state, state_cap);
}

/* See implementation. */
export function gzip_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  return gzip_m.gzip_stream_compress(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
}

/* See implementation. */
export function gzip_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  in_consumed: *i32): i32 {
  return gzip_m.gzip_stream_decompress(state, state_cap, inp, in_len, out, out_cap, in_consumed);
}

/** Exported function `gzip_stream_end`.
 * Implements `gzip_stream_end`.
 * @param state *u8
 * @param state_cap i32
 * @return i32
 */
export function gzip_stream_end(state: *u8, state_cap: i32): i32 {
  return gzip_m.gzip_stream_end(state, state_cap);
}

/* See implementation. */

/** Exported function `format_gzip`.
 * Implements `format_gzip`.
 * @return i32
 */
export function format_gzip(): i32 {
  return 0;
}

/** Exported function `format_brotli`.
 * Implements `format_brotli`.
 * @return i32
 */
export function format_brotli(): i32 {
  return 1;
}

/** Exported function `format_zstd`.
 * Implements `format_zstd`.
 * @return i32
 */
export function format_zstd(): i32 {
  return 2;
}

/** Exported function `mode_compress`.
 * Implements `mode_compress`.
 * @return i32
 */
export function mode_compress(): i32 {
  return 0;
}

/** Exported function `mode_decompress`.
 * Implements `mode_decompress`.
 * @return i32
 */
export function mode_decompress(): i32 {
  return 1;
}

/* See implementation. */
allow(padding) struct StreamCompress {
  format: i32;
  mode: i32;
  state: *u8;
  state_cap: i32;
}

/** Exported function `compress_state_bytes_for`.
 * Implements `compress_state_bytes_for`.
 * @param format i32
 * @return i32
 */
export function compress_state_bytes_for(format: i32): i32 {
  if (format == format_gzip()) {
    return gzip_stream_state_bytes();
  }
  if (format == format_brotli()) {
    return brotli_stream_state_bytes();
  }
  if (format == format_zstd()) {
    return zstd_stream_state_bytes();
  }
  return -1;
}

/** Exported function `compress_state_bytes`.
 * Implements `compress_state_bytes`.
 * @return i32
 */
export function compress_state_bytes(): i32 {
  let gz: i32 = gzip_stream_state_bytes();
  let br: i32 = brotli_stream_state_bytes();
  let zs: i32 = zstd_stream_state_bytes();
  let max: i32 = gz;
  if (br > max) { max = br; }
  if (zs > max) { max = zs; }
  return max;
}

/**
 * See implementation.
 * See implementation.
 */
export function compress_init(sc: *StreamCompress, state: *u8, state_cap: i32, format: i32, mode: i32): i32 {
  sc.format = format;
  sc.mode = mode;
  sc.state = state;
  sc.state_cap = state_cap;
  if (format == format_gzip()) {
    if (mode == mode_compress()) {
      return gzip_stream_init_compress(state, state_cap);
    }
    if (mode == mode_decompress()) {
      return gzip_stream_init_decompress(state, state_cap);
    }
    return -2;
  }
  if (format == format_brotli()) {
    if (mode == mode_compress()) {
      return brotli_stream_init_compress(state, state_cap);
    }
    if (mode == mode_decompress()) {
      return brotli_stream_init_decompress(state, state_cap);
    }
    return -2;
  }
  if (format == format_zstd()) {
    if (mode == mode_compress()) {
      return zstd_stream_init_compress(state, state_cap);
    }
    if (mode == mode_decompress()) {
      return zstd_stream_init_decompress(state, state_cap);
    }
    return -2;
  }
  return -9;
}

/**
 * See implementation.
 * See implementation.
 */
export function compress_process(sc: StreamCompress, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  if (sc.format == format_gzip()) {
    if (sc.mode == mode_compress()) {
      return gzip_stream_compress(sc.state, sc.state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
    }
    if (sc.mode == mode_decompress()) {
      return gzip_stream_decompress(sc.state, sc.state_cap, inp, in_len, out, out_cap, in_consumed);
    }
    return -9;
  }
  if (sc.format == format_brotli()) {
    if (sc.mode == mode_compress()) {
      return brotli_stream_compress(sc.state, sc.state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
    }
    if (sc.mode == mode_decompress()) {
      return brotli_stream_decompress(sc.state, sc.state_cap, inp, in_len, out, out_cap, in_consumed);
    }
    return -9;
  }
  if (sc.format == format_zstd()) {
    if (sc.mode == mode_compress()) {
      return zstd_stream_compress(sc.state, sc.state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
    }
    if (sc.mode == mode_decompress()) {
      return zstd_stream_decompress(sc.state, sc.state_cap, inp, in_len, out, out_cap, in_consumed);
    }
    return -9;
  }
  return -9;
}

/** Exported function `compress_end`.
 * Implements `compress_end`.
 * @param sc StreamCompress
 * @return i32
 */
export function compress_end(sc: StreamCompress): i32 {
  if (sc.format == format_gzip()) {
    return gzip_stream_end(sc.state, sc.state_cap);
  }
  if (sc.format == format_brotli()) {
    return brotli_stream_end(sc.state, sc.state_cap);
  }
  if (sc.format == format_zstd()) {
    return zstd_stream_end(sc.state, sc.state_cap);
  }
  return -9;
}
