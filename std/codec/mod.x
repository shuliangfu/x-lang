// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
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

// std.codec — 统一块/流编解码抽象（STD-073）
//
// 【文件职责】
// Encoder / Decoder 块编解码门面；hex / base64 / gzip / json / csv 适配；
// gzip 流式编解码；STD-110 base64/compress 流式适配。
// 【错误语义】0=成功写入字节数；负值=err_*。
//
// 【对标】Zig 各 format 模块的统一入口、Go encoding 包组合风格。

const bytes = import("std.bytes");
const encoding = import("std.encoding");
const base64 = import("std.base64");
const compress = import("std.compress");
const json = import("std.json");
const csv = import("std.csv");

/** 成功（块操作返回值为写入字节数，非本常量）。 */
function err_ok(): i32 { return 0; }
/** 输出缓冲不足或分配失败。 */
function err_buffer(): i32 { return -1; }
/** 输入非法或校验失败。 */
function err_input(): i32 { return -2; }
/** 后端未链入或格式不支持。 */
function err_unsupported(): i32 { return -9; }

/** 十六进制（小写 ASCII）。 */
function kind_hex(): i32 { return 1; }
/** 标准 Base64（含填充）。 */
function kind_base64_standard(): i32 { return 2; }
/** gzip 块压缩（依赖 zlib）。 */
function kind_gzip(): i32 { return 3; }
/** JSON 字符串转义（encode-only）。 */
function kind_json_escape(): i32 { return 4; }
/** CSV 字段引号转义（encode-only）。 */
function kind_csv_escape(): i32 { return 5; }
/** STD-110：Base64 流式编解码（standard/url 由 init 参数 url 选择）。 */
function kind_base64_stream(): i32 { return 6; }

/** 块编解码描述符（kind 选择后端）。 */
allow(padding) struct BlockCodec {
  kind: i32;
}

/** 编码器：与 BlockCodec 同布局，语义别名。 */
allow(padding) struct Encoder {
  kind: i32;
}

/** 解码器：与 BlockCodec 同布局，语义别名。 */
allow(padding) struct Decoder {
  kind: i32;
}

/** 流编解码状态（gzip / base64 stream）。 */
allow(padding) struct StreamCodec {
  kind: i32;
  mode: i32;
  state: *u8;
  state_cap: i32;
}

/** 流模式：压缩。 */
function mode_compress(): i32 { return 0; }
/** 流模式：解压。 */
function mode_decompress(): i32 { return 1; }

/** 构造块 codec。 */
function block_codec_new(kind: i32): BlockCodec {
  return BlockCodec { kind: kind };
}

/** 构造编码器。 */
function encoder_new(kind: i32): Encoder {
  return Encoder { kind: kind };
}

/** 构造解码器。 */
function decoder_new(kind: i32): Decoder {
  return Decoder { kind: kind };
}

/** 块编码：返回写入 out 字节数，失败为负错误码。 */
function block_encode(c: BlockCodec, src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
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

/** 块解码：返回写入 out 字节数，失败为负错误码。 */
function block_decode(c: BlockCodec, src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
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

/** 编码器块编码。 */
function encoder_encode(e: Encoder, src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let c: BlockCodec = BlockCodec { kind: e.kind };
  return block_encode(c, src, src_len, out, out_cap);
}

/** 解码器块解码。 */
function decoder_decode(d: Decoder, src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let c: BlockCodec = BlockCodec { kind: d.kind };
  return block_decode(c, src, src_len, out, out_cap);
}

/** 估算块编码输出上界（保守；失败 -1）。 */
function encode_upper_bound(kind: i32, src_len: i32): i32 {
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

/** 编码写入 Bytes（清空后填充）；成功返回写入字节数。 */
function encode_into_bytes(e: Encoder, src: *u8, src_len: i32, b: *Bytes): i32 {
  let need: i32 = encode_upper_bound(e.kind, src_len);
  if (need < 0) { return err_unsupported(); }
  bytes.clear(b);
  if (bytes.grow(b, need) != 0) { return err_buffer(); }
  let n: i32 = encoder_encode(e, src, src_len, b.ptr, b.cap);
  if (n < 0) { return n; }
  b.len = n;
  return n;
}

/** 从 Bytes 解码（清空后填充）；成功返回写入字节数。 */
function decode_from_bytes(d: Decoder, src: Bytes, b: *Bytes): i32 {
  bytes.clear(b);
  if (bytes.grow(b, src.len) != 0) { return err_buffer(); }
  let n: i32 = decoder_decode(d, src.ptr, src.len, b.ptr, b.cap);
  if (n < 0) { return n; }
  b.len = n;
  return n;
}

/** 流状态缓冲最小字节数（gzip 与 base64 stream 取较大值）。 */
function codec_state_bytes(): i32 {
  let gz: i32 = compress.gzip_stream_state_bytes();
  let b64: i32 = base64.state_bytes();
  if (gz > b64) {
    return gz;
  }
  return b64;
}

/** 绑定 gzip 流 codec；mode 为 compress/decompress；成功 0。 */
function codec_init_gzip(sc: *StreamCodec, state: *u8, state_cap: i32, mode: i32): i32 {
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
 * STD-110：绑定 base64 流 codec。
 * mode=mode_compress() 为编码，mode_decompress() 为解码；url 非 0 为 URL 变体。
 */
function codec_init_base64(sc: *StreamCodec, state: *u8, state_cap: i32, url: i32, mode: i32): i32 {
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

/** 流式处理一块；is_last 非 0 表示末块（压缩/编码 padding）；返回写入 out 字节数。 */
function codec_process(sc: StreamCodec, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
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

/** 结束流并释放底层状态（gzip）；base64 stream 无额外清理。 */
function codec_end(sc: StreamCodec): i32 {
  if (sc.kind == kind_gzip()) {
    return compress.gzip_stream_end(sc.state, sc.state_cap);
  }
  if (sc.kind == kind_base64_stream()) {
    return err_ok();
  }
  return err_unsupported();
}

/** hex 适配：编码。 */
function adapter_hex_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let e: Encoder = encoder_new(kind_hex());
  return encoder_encode(e, src, src_len, out, out_cap);
}

/** hex 适配：解码。 */
function adapter_hex_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let d: Decoder = decoder_new(kind_hex());
  return decoder_decode(d, src, src_len, out, out_cap);
}

/** base64 标准适配：编码。 */
function adapter_base64_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let e: Encoder = encoder_new(kind_base64_standard());
  return encoder_encode(e, src, src_len, out, out_cap);
}

/** base64 标准适配：解码。 */
function adapter_base64_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let d: Decoder = decoder_new(kind_base64_standard());
  return decoder_decode(d, src, src_len, out, out_cap);
}

/** gzip 块适配：压缩。 */
function adapter_gzip_encode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let e: Encoder = encoder_new(kind_gzip());
  return encoder_encode(e, src, src_len, out, out_cap);
}

/** gzip 块适配：解压。 */
function adapter_gzip_decode(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let d: Decoder = decoder_new(kind_gzip());
  return decoder_decode(d, src, src_len, out, out_cap);
}

// ——— STD-110：compress / base64 流式适配（块 + 流双路径） ———

/** STD-110：compress 流式 init（委托 codec_init_gzip）。 */
function adapter_compress_stream_init(sc: *StreamCodec, state: *u8, state_cap: i32, mode: i32): i32 {
  return codec_init_gzip(sc, state, state_cap, mode);
}

/** STD-110：compress/base64 流式 process（委托 codec_process）。 */
function adapter_compress_stream_process(sc: StreamCodec, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
  return codec_process(sc, inp, in_len, out, out_cap, is_last, in_consumed);
}

/** STD-110：流式 end（委托 codec_end）。 */
function adapter_compress_stream_end(sc: StreamCodec): i32 {
  return codec_end(sc);
}

/** STD-110：base64 流式 init；encode_mode 非 0 为编码，否则解码。 */
function adapter_base64_stream_init(sc: *StreamCodec, state: *u8, state_cap: i32, url: i32, encode_mode: i32): i32 {
  let mode: i32 = mode_decompress();
  if (encode_mode != 0) {
    mode = mode_compress();
  }
  return codec_init_base64(sc, state, state_cap, url, mode);
}

/** STD-110：base64 流式 process。 */
function adapter_base64_stream_process(sc: StreamCodec, inp: *u8, in_len: i32, out: *u8, out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
  return codec_process(sc, inp, in_len, out, out_cap, is_last, in_consumed);
}

/** STD-110：base64 流式 end。 */
function adapter_base64_stream_end(sc: StreamCodec): i32 {
  return codec_end(sc);
}

/** JSON 字符串转义适配（encode-only）。 */
function adapter_json_escape(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let e: Encoder = encoder_new(kind_json_escape());
  return encoder_encode(e, src, src_len, out, out_cap);
}

/** CSV 字段转义适配（encode-only）。 */
function adapter_csv_escape(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let e: Encoder = encoder_new(kind_csv_escape());
  return encoder_encode(e, src, src_len, out, out_cap);
}

