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

const bytes = import("std.bytes");
const encoding = import("std.encoding");
const base64 = import("std.base64");
const compress = import("std.compress");
const json = import("std.json");
const csv = import("std.csv");

/** Exported function `err_ok`.
 * Implements `err_ok`.
 * @return i32
 */
export function err_ok(): i32 { return 0; }
/** Exported function `err_buffer`.
 * Implements `err_buffer`.
 * @return i32
 */
export function err_buffer(): i32 { return -1; }
/** Exported function `err_input`.
 * Implements `err_input`.
 * @return i32
 */
export function err_input(): i32 { return -2; }
/** Exported function `err_unsupported`.
 * Implements `err_unsupported`.
 * @return i32
 */
export function err_unsupported(): i32 { return -9; }

/** Exported function `kind_hex`.
 * Implements `kind_hex`.
 * @return i32
 */
export function kind_hex(): i32 { return 1; }
/** Exported function `kind_base64_standard`.
 * Implements `kind_base64_standard`.
 * @return i32
 */
export function kind_base64_standard(): i32 { return 2; }
/** Exported function `kind_gzip`.
 * Implements `kind_gzip`.
 * @return i32
 */
export function kind_gzip(): i32 { return 3; }
/** Exported function `kind_json_escape`.
 * Implements `kind_json_escape`.
 * @return i32
 */
export function kind_json_escape(): i32 { return 4; }
/** Exported function `kind_csv_escape`.
 * Implements `kind_csv_escape`.
 * @return i32
 */
export function kind_csv_escape(): i32 { return 5; }
/** Exported function `kind_base64_stream`.
 * Implements `kind_base64_stream`.
 * @return i32
 */
export function kind_base64_stream(): i32 { return 6; }

/* See implementation. */
allow(padding) struct BlockCodec {
  kind: i32;
}

/* See implementation. */
allow(padding) struct Encoder {
  kind: i32;
}

/* See implementation. */
allow(padding) struct Decoder {
  kind: i32;
}

/* See implementation. */
allow(padding) struct StreamCodec {
  kind: i32;
  mode: i32;
  state: *u8;
  state_cap: i32;
}

/** Exported function `mode_compress`.
 * Implements `mode_compress`.
 * @return i32
 */
export function mode_compress(): i32 { return 0; }
/** Exported function `mode_decompress`.
 * Implements `mode_decompress`.
 * @return i32
 */
export function mode_decompress(): i32 { return 1; }

/** Exported function `block_codec_new`.
 * Implements `block_codec_new`.
 * @param kind i32
 * @return BlockCodec
 */
export function block_codec_new(kind: i32): BlockCodec {
  return BlockCodec { kind: kind };
}

/** Exported function `encoder_new`.
 * Implements `encoder_new`.
 * @param kind i32
 * @return Encoder
 */
export function encoder_new(kind: i32): Encoder {
  return Encoder { kind: kind };
}

/** Exported function `decoder_new`.
 * Implements `decoder_new`.
 * @param kind i32
 * @return Decoder
 */
export function decoder_new(kind: i32): Decoder {
  return Decoder { kind: kind };
}

/** Exported function `block_encode`.
 * Implements `block_encode`.
 * @param c BlockCodec
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function block_encode(c: BlockCodec, src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  if (c.kind == kind_hex()) {
    let n: i32 = encoding.hex_encode(src, src_len, out, out_cap);
    if (n < 0) { return err_buffer(); }
    return n;
  }
  if (c.kind == kind_base64_standard()) {
    let n: i32 = base64.encode_standard(src, src_len, out, out_cap);
    if (n < 0) { return err_input(); }
    return n;
  }
  if (c.kind == kind_gzip()) {
    let n: i32 = compress.gzip_compress(src, src_len, out, out_cap);
    if (n < 0) { return err_unsupported(); }
    return n;
  }
  if (c.kind == kind_json_escape()) {
    let n: i32 = json.escape(src, src_len, out, out_cap);
    if (n < 0) { return err_buffer(); }
    return n;
  }
  if (c.kind == kind_csv_escape()) {
    let n: i32 = csv.escape(src, src_len, out, out_cap);
    if (n < 0) { return err_buffer(); }
    return n;
  }
  return err_unsupported();
}

/** Exported function `block_decode`.
 * Implements `block_decode`.
 * @param c BlockCodec
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function block_decode(c: BlockCodec, src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  if (c.kind == kind_hex()) {
    let n: i32 = encoding.hex_decode(src, src_len, out, out_cap);
    if (n < 0) { return err_input(); }
    return n;
  }
  if (c.kind == kind_base64_standard()) {
    let n: i32 = base64.decode_standard(src, src_len, out, out_cap);
    if (n < 0) { return err_input(); }
    return n;
  }
  if (c.kind == kind_gzip()) {
    let n: i32 = compress.gzip_decompress(src, src_len, out, out_cap);
    if (n < 0) { return err_unsupported(); }
    return n;
  }
  return err_unsupported();
}

/** Exported function `encoder_encode`.
 * Implements `encoder_encode`.
 * @param e Encoder
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function encoder_encode(e: Encoder, src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let c: BlockCodec = BlockCodec { kind: e.kind };
  return block_encode(c, src, src_len, out, out_cap);
}

/** Exported function `decoder_decode`.
 * Implements `decoder_decode`.
 * @param d Decoder
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function decoder_decode(d: Decoder, src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let c: BlockCodec = BlockCodec { kind: d.kind };
  return block_decode(c, src, src_len, out, out_cap);
}

/** Exported function `encode_upper_bound`.
 * Implements `encode_upper_bound`.
 * @param kind i32
 * @param src_len i32
 * @return i32
 */
export function encode_upper_bound(kind: i32, src_len: i32): i32 {
  if (src_len < 0) { return -1; }
  if (kind == kind_hex()) {
    return encoding.hex_encoded_len(src_len);
  }
  if (kind == kind_base64_standard()) {
    return (src_len + 2) / 3 * 4;
  }
  if (kind == kind_gzip()) {
    return src_len + 64;
  }
  if (kind == kind_json_escape()) {
    return src_len * 2 + 4;
  }
  if (kind == kind_csv_escape()) {
    return src_len + 2;
  }
  return -1;
}

/** Exported function `encode_into_bytes`.
 * Implements `encode_into_bytes`.
 * @param e Encoder
 * @param src *u8
 * @param src_len i32
 * @param b *Bytes
 * @return i32
 */
export function encode_into_bytes(e: Encoder, src: *u8, src_len: i32, b: *Bytes): i32 {
  let need: i32 = encode_upper_bound(e.kind, src_len);
  if (need < 0) { return err_unsupported(); }
  bytes.clear(b);
  if (bytes.grow(b, need) != 0) { return err_buffer(); }
  let n: i32 = encoder_encode(e, src, src_len, b.ptr, b.cap);
  if (n < 0) { return n; }
  b.length = n;
  return n;
}

/** Exported function `decode_from_bytes`.
 * Implements `decode_from_bytes`.
 * @param d Decoder
 * @param src Bytes
 * @param b *Bytes
 * @return i32
 */
export function decode_from_bytes(d: Decoder, src: Bytes, b: *Bytes): i32 {
  bytes.clear(b);
  if (bytes.grow(b, src.length) != 0) { return err_buffer(); }
  let n: i32 = decoder_decode(d, src.ptr, src.length, b.ptr, b.cap);
  if (n < 0) { return n; }
  b.length = n;
  return n;
}

/** Exported function `codec_state_bytes`.
 * Implements `codec_state_bytes`.
 * @return i32
 */
export function codec_state_bytes(): i32 {
  let gz: i32 = compress.gzip_stream_state_bytes();
  let b64: i32 = base64.state_bytes();
  if (gz > b64) {
    return gz;
  }
  return b64;
}

/** Exported function `codec_init_gzip`.
 * Implements `codec_init_gzip`.
 * @param sc *StreamCodec
 * @param state *u8
 * @param state_cap i32
 * @param mode i32
 * @return i32
 */
export function codec_init_gzip(sc: *StreamCodec, state: *u8, state_cap: i32, mode: i32): i32 {
  sc.kind = kind_gzip();
  sc.mode = mode;
  sc.state = state;
  sc.state_cap = state_cap;
  if (mode == mode_compress()) {
    return compress.gzip_stream_init_compress(state, state_cap);
  }
  if (mode == mode_decompress()) {
    return compress.gzip_stream_init_decompress(state, state_cap);
  }
  return err_input();
}

/**
 * See implementation.
 * See implementation.
 */
export function codec_init_base64(sc: *StreamCodec, state: *u8, state_cap: i32, url: i32, mode: i32): i32 {
  sc.kind = kind_base64_stream();
  sc.mode = mode;
  sc.state = state;
  sc.state_cap = state_cap;
  if (mode == mode_compress()) {
    return base64.enc_init(state, state_cap, url);
  }
  if (mode == mode_decompress()) {
    return base64.dec_init(state, state_cap, url);
  }
  return err_input();
}

/** Exported function `codec_process`.
 * Implements `codec_process`.
 * @param sc StreamCodec
 * @param inp *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @param is_last i32
 * @param in_consumed *i32
 * @return i32
 */
export function codec_process(sc: StreamCodec, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
  if (sc.kind == kind_gzip()) {
    if (sc.mode == mode_compress()) {
      return compress.gzip_stream_compress(sc.state, sc.state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
    }
    if (sc.mode == mode_decompress()) {
      return compress.gzip_stream_decompress(sc.state, sc.state_cap, inp, in_len, out, out_cap, in_consumed);
    }
    return err_unsupported();
  }
  if (sc.kind == kind_base64_stream()) {
    if (sc.mode == mode_compress()) {
      return base64.enc_update(sc.state, sc.state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
    }
    if (sc.mode == mode_decompress()) {
      return base64.dec_update(sc.state, sc.state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
    }
    return err_unsupported();
  }
  return err_unsupported();
}

/** Exported function `codec_end`.
 * Implements `codec_end`.
 * @param sc StreamCodec
 * @return i32
 */
export function codec_end(sc: StreamCodec): i32 {
  if (sc.kind == kind_gzip()) {
    return compress.gzip_stream_end(sc.state, sc.state_cap);
  }
  if (sc.kind == kind_base64_stream()) {
    return err_ok();
  }
  return err_unsupported();
}

/** Exported function `adapter_hex_encode`.
 * Implements `adapter_hex_encode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function adapter_hex_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let e: Encoder = encoder_new(kind_hex());
  return encoder_encode(e, src, src_len, out, out_cap);
}

/** Exported function `adapter_hex_decode`.
 * Implements `adapter_hex_decode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function adapter_hex_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let d: Decoder = decoder_new(kind_hex());
  return decoder_decode(d, src, src_len, out, out_cap);
}

/** Exported function `adapter_base64_encode`.
 * Implements `adapter_base64_encode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function adapter_base64_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let e: Encoder = encoder_new(kind_base64_standard());
  return encoder_encode(e, src, src_len, out, out_cap);
}

/** Exported function `adapter_base64_decode`.
 * Implements `adapter_base64_decode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function adapter_base64_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let d: Decoder = decoder_new(kind_base64_standard());
  return decoder_decode(d, src, src_len, out, out_cap);
}

/** Exported function `adapter_gzip_encode`.
 * Implements `adapter_gzip_encode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function adapter_gzip_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let e: Encoder = encoder_new(kind_gzip());
  return encoder_encode(e, src, src_len, out, out_cap);
}

/** Exported function `adapter_gzip_decode`.
 * Implements `adapter_gzip_decode`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function adapter_gzip_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let d: Decoder = decoder_new(kind_gzip());
  return decoder_decode(d, src, src_len, out, out_cap);
}

// See implementation.

/** Exported function `adapter_compress_stream_init`.
 * Implements `adapter_compress_stream_init`.
 * @param sc *StreamCodec
 * @param state *u8
 * @param state_cap i32
 * @param mode i32
 * @return i32
 */
export function adapter_compress_stream_init(sc: *StreamCodec, state: *u8, state_cap: i32, mode: i32): i32 {
  return codec_init_gzip(sc, state, state_cap, mode);
}

/** Exported function `adapter_compress_stream_process`.
 * Implements `adapter_compress_stream_process`.
 * @param sc StreamCodec
 * @param inp *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @param is_last i32
 * @param in_consumed *i32
 * @return i32
 */
export function adapter_compress_stream_process(sc: StreamCodec, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
  return codec_process(sc, inp, in_len, out, out_cap, is_last, in_consumed);
}

/** Exported function `adapter_compress_stream_end`.
 * Implements `adapter_compress_stream_end`.
 * @param sc StreamCodec
 * @return i32
 */
export function adapter_compress_stream_end(sc: StreamCodec): i32 {
  return codec_end(sc);
}

/** Exported function `adapter_base64_stream_init`.
 * Implements `adapter_base64_stream_init`.
 * @param sc *StreamCodec
 * @param state *u8
 * @param state_cap i32
 * @param url i32
 * @param encode_mode i32
 * @return i32
 */
export function adapter_base64_stream_init(sc: *StreamCodec, state: *u8, state_cap: i32, url: i32, encode_mode: i32): i32 {
  let mode: i32 = mode_decompress();
  if (encode_mode != 0) {
    mode = mode_compress();
  }
  return codec_init_base64(sc, state, state_cap, url, mode);
}

/** Exported function `adapter_base64_stream_process`.
 * Implements `adapter_base64_stream_process`.
 * @param sc StreamCodec
 * @param inp *u8
 * @param in_len i32
 * @param out *u8
 * @param out_cap i32
 * @param is_last i32
 * @param in_consumed *i32
 * @return i32
 */
export function adapter_base64_stream_process(sc: StreamCodec, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
  return codec_process(sc, inp, in_len, out, out_cap, is_last, in_consumed);
}

/** Exported function `adapter_base64_stream_end`.
 * Implements `adapter_base64_stream_end`.
 * @param sc StreamCodec
 * @return i32
 */
export function adapter_base64_stream_end(sc: StreamCodec): i32 {
  return codec_end(sc);
}

/** Exported function `adapter_json_escape`.
 * Implements `adapter_json_escape`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function adapter_json_escape(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let e: Encoder = encoder_new(kind_json_escape());
  return encoder_encode(e, src, src_len, out, out_cap);
}

/** Exported function `adapter_csv_escape`.
 * Implements `adapter_csv_escape`.
 * @param src *u8
 * @param src_len i32
 * @param out *u8
 * @param out_cap i32
 * @return i32
 */
export function adapter_csv_escape(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let e: Encoder = encoder_new(kind_csv_escape());
  return encoder_encode(e, src, src_len, out, out_cap);
}

