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

// std.compress — 压缩封装门面（P4 可选；zlib / gzip / Brotli / zstd）
//
// 【文件职责】聚合 std.compress.zlib / gzip / brotli / zstd，保持 import("std.compress") 兼容。
// 【目录】zlib/、gzip/、brotli/、zstd/ 各格式独立；共用类型见 common.x；F-04 v7 无 compress.o。
const zlib_m = import("std.compress.zlib");
const gzip_m = import("std.compress.gzip");
const brotli_m = import("std.compress.brotli");
const zstd_m = import("std.compress.zstd");

/** 压缩为 zlib 格式，返回写入字节数，失败 -1。 */
function deflate(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return zlib_m.deflate(in, in_len, out, out_cap);
}

/** 解压 zlib 流，返回写入字节数，失败 -1。 */
function inflate(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return zlib_m.inflate(in, in_len, out, out_cap);
}

/** 压缩为 gzip 格式（.gz），返回写入字节数，失败 -1。 */
function gzip_compress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return gzip_m.gzip_compress(in, in_len, out, out_cap);
}

/** 解压 gzip 流，返回写入字节数，失败 -1。 */
function gzip_decompress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return gzip_m.gzip_decompress(in, in_len, out, out_cap);
}

/** 压缩为 Brotli 格式（.br），返回写入字节数，失败 -1。 */
function brotli_compress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return brotli_m.brotli_compress(in, in_len, out, out_cap);
}

/** 解压 Brotli 流，返回写入字节数，失败 -1。 */
function brotli_decompress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return brotli_m.brotli_decompress(in, in_len, out, out_cap);
}

/** 探测 Brotli 是否已在编译期启用；1=可用，0=占位 stub。 */
function brotli_available(): i32 {
  return brotli_m.brotli_available();
}

/** Brotli 往返烟测；未启用时返回 0（skip）。 */
function brotli_smoke(): i32 {
  return brotli_m.brotli_smoke();
}

/** 压缩为 zstd 帧，返回写入字节数，失败 -1。 */
function zstd_compress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return zstd_m.zstd_compress(in, in_len, out, out_cap);
}

/** 解压 zstd 帧，返回写入字节数，失败 -1。 */
function zstd_decompress(in: *u8, in_len: i32, out: *u8, out_cap: i32): i32 {
  return zstd_m.zstd_decompress(in, in_len, out, out_cap);
}

/** 探测 zstd 是否已在编译期启用；1=可用，0=占位 stub。 */
function zstd_available(): i32 {
  return zstd_m.zstd_available();
}

/** zstd 往返烟测；未启用时返回 0（skip）。 */
function zstd_smoke(): i32 {
  return zstd_m.zstd_smoke();
}

/** zstd 流状态缓冲最小字节数。 */
function zstd_stream_state_bytes(): i32 {
  return zstd_m.zstd_stream_state_bytes();
}

/** 初始化 zstd 压缩流；成功 0。 */
function zstd_stream_init_compress(state: *u8, state_cap: i32): i32 {
  return zstd_m.zstd_stream_init_compress(state, state_cap);
}

/** 初始化 zstd 解压流；成功 0。 */
function zstd_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  return zstd_m.zstd_stream_init_decompress(state, state_cap);
}

/** 分块 zstd 压缩。 */
function zstd_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  return zstd_m.zstd_stream_compress(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
}

/** 分块 zstd 解压。 */
function zstd_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  in_consumed: *i32): i32 {
  return zstd_m.zstd_stream_decompress(state, state_cap, inp, in_len, out, out_cap, in_consumed);
}

/** 释放 zstd 流。 */
function zstd_stream_end(state: *u8, state_cap: i32): i32 {
  return zstd_m.zstd_stream_end(state, state_cap);
}

/** brotli 流状态缓冲最小字节数。 */
function brotli_stream_state_bytes(): i32 {
  return brotli_m.brotli_stream_state_bytes();
}

/** 初始化 brotli 压缩流；成功 0。 */
function brotli_stream_init_compress(state: *u8, state_cap: i32): i32 {
  return brotli_m.brotli_stream_init_compress(state, state_cap);
}

/** 初始化 brotli 解压流；成功 0。 */
function brotli_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  return brotli_m.brotli_stream_init_decompress(state, state_cap);
}

/** 分块 brotli 压缩。 */
function brotli_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  return brotli_m.brotli_stream_compress(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
}

/** 分块 brotli 解压。 */
function brotli_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  in_consumed: *i32): i32 {
  return brotli_m.brotli_stream_decompress(state, state_cap, inp, in_len, out, out_cap, in_consumed);
}

/** 释放 brotli 流。 */
function brotli_stream_end(state: *u8, state_cap: i32): i32 {
  return brotli_m.brotli_stream_end(state, state_cap);
}

/** gzip 流状态缓冲最小字节数（STD-039）。 */
function gzip_stream_state_bytes(): i32 {
  return gzip_m.gzip_stream_state_bytes();
}

/** 初始化 gzip 压缩流；成功 0，未链 zlib 时 -1。 */
function gzip_stream_init_compress(state: *u8, state_cap: i32): i32 {
  return gzip_m.gzip_stream_init_compress(state, state_cap);
}

/** 初始化 gzip 解压流；成功 0，未链 zlib 时 -1。 */
function gzip_stream_init_decompress(state: *u8, state_cap: i32): i32 {
  return gzip_m.gzip_stream_init_decompress(state, state_cap);
}

/** 分块 gzip 压缩；is_last≠0 时对末块 Z_FINISH。 */
function gzip_stream_compress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  is_last: i32, in_consumed: *i32): i32 {
  return gzip_m.gzip_stream_compress(state, state_cap, inp, in_len, out, out_cap, is_last, in_consumed);
}

/** 分块 gzip 解压。 */
function gzip_stream_decompress(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
  in_consumed: *i32): i32 {
  return gzip_m.gzip_stream_decompress(state, state_cap, inp, in_len, out, out_cap, in_consumed);
}

/** 释放 gzip 流底层 z_stream。 */
function gzip_stream_end(state: *u8, state_cap: i32): i32 {
  return gzip_m.gzip_stream_end(state, state_cap);
}

/* ---------- STD-122 / #81：统一流式 API（gzip / brotli / zstd） ---------- */

/** 流格式：gzip。 */
function format_gzip(): i32 {
  return 0;
}

/** 流格式：brotli。 */
function format_brotli(): i32 {
  return 1;
}

/** 流格式：zstd。 */
function format_zstd(): i32 {
  return 2;
}

/** 流模式：压缩。 */
function mode_compress(): i32 {
  return 0;
}

/** 流模式：解压。 */
function mode_decompress(): i32 {
  return 1;
}

/** 统一流状态（绑定外置 state 缓冲 + format/mode）。 */
allow(padding) struct StreamCompress {
  format: i32;
  mode: i32;
  state: *u8;
  state_cap: i32;
}

/** 指定格式的流状态缓冲最小字节数。 */
function compress_state_bytes_for(format: i32): i32 {
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

/** 统一流状态缓冲最小字节数（取 gzip/brotli/zstd 最大值，便于通用缓冲）。 */
function compress_state_bytes(): i32 {
  let gz: i32 = gzip_stream_state_bytes();
  let br: i32 = brotli_stream_state_bytes();
  let zs: i32 = zstd_stream_state_bytes();
  let max: i32 = gz;
  if (br > max) { max = br; }
  if (zs > max) { max = zs; }
  return max;
}

/**
 * 初始化 StreamCompress；format 为 format_* 之一。
 * 成功 0；未链对应库或格式不支持时非 0。
 */
function compress_init(sc: *StreamCompress, state: *u8, state_cap: i32, format: i32, mode: i32): i32 {
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
 * 分块 compress/decompress；is_last≠0 为压缩末块（Z_FINISH）。
 * 返回写入 out 字节数，失败 -1；in_consumed 写入已消费输入字节数。
 */
function compress_process(sc: StreamCompress, inp: *u8, in_len: i32, out: *u8, out_cap: i32,
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

/** 结束流并释放底层状态；成功 0。 */
function compress_end(sc: StreamCompress): i32 {
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
