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

// std/base64/base64.x — Base64 编解码与流式 API（F-base64 v1；替代 base64.c）
//
// 【文件职责】
// encode/decode standard 与 URL 变体；STD-109 流式编解码与烟测。
// 单遍、无堆分配；对标 Zig std.base64。
//
// 【依赖】libc memcpy/memset（流状态清零与 pending 拷贝）。

const types = import("core.types");

/** 流状态魔数 'B4ST'。 */
const SHU_B64_STREAM_MAGIC: u32 = 0x42345354;

extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern "C" function memset(s: *u8, c: i32, n: usize): *u8;

/** 标准 Base64 编码字符（0..63）；seed asm 不支持全局 const u8[] 下标。 */
function b64_std_enc_char(idx: i32): u8 {
  let r: u8 = 0 as u8;
  if (idx >= 0 && idx < 26) { r = (65 + idx) as u8; }
  else if (idx >= 26 && idx < 52) { r = (97 + idx - 26) as u8; }
  else if (idx >= 52 && idx < 62) { r = (48 + idx - 52) as u8; }
  else if (idx == 62) { r = 43 as u8; }
  else if (idx == 63) { r = 47 as u8; }
  return r;
}

/** URL 安全 Base64 编码字符（0..63）。 */
function b64_url_enc_char(idx: i32): u8 {
  let r: u8 = 0 as u8;
  if (idx >= 0 && idx < 26) { r = (65 + idx) as u8; }
  else if (idx >= 26 && idx < 52) { r = (97 + idx - 26) as u8; }
  else if (idx >= 52 && idx < 62) { r = (48 + idx - 52) as u8; }
  else if (idx == 62) { r = 45 as u8; }
  else if (idx == 63) { r = 95 as u8; }
  return r;
}

/** 按 URL/标准变体选取编码字符。 */
function b64_pick_enc_char(is_url: i32, idx: i32): u8 {
  if (is_url != 0) { return b64_url_enc_char(idx); }
  return b64_std_enc_char(idx);
}

/** 流式编解码状态（与 C shu_b64_stream_t 布局一致）。 */
allow(padding) struct B64Stream {
  magic: u32
  is_url: i32
  is_enc: i32
  pending_len: i32
  pending: u8[3]
  dec_len: i32
  dec_pending: u8[4]
}

/** B64Stream 布局字节数（allow(padding)；与 types.size_of<B64Stream>() 一致为 28）。 */
const B64_STREAM_STATE_BYTES: i32 = 28;

/** 标准表字符 → 6-bit 值；非法 255，`=` 为 254。 */
function b64_decode_char_std(c: u8): u32 {
  if (c >= 65 && c <= 90) { return (c - 65) as u32; }
  if (c >= 97 && c <= 122) { return (c - 97 + 26) as u32; }
  if (c >= 48 && c <= 57) { return (c - 48 + 52) as u32; }
  if (c == 43) { return 62; }
  if (c == 47) { return 63; }
  if (c == 61) { return 254; }
  return 255;
}

/** URL 表字符 → 6-bit 值；非法 255。 */
function b64_decode_char_url(c: u8): u32 {
  if (c >= 65 && c <= 90) { return (c - 65) as u32; }
  if (c >= 97 && c <= 122) { return (c - 97 + 26) as u32; }
  if (c >= 48 && c <= 57) { return (c - 48 + 52) as u32; }
  if (c == 45) { return 62; }
  if (c == 95) { return 63; }
  return 255;
}

/** 校验并返回流状态指针；无效返回 0。 */
function b64_stream_cast(state: *u8, state_cap: i32): *B64Stream {
  let need: i32 = B64_STREAM_STATE_BYTES;
  if (state == 0 || state_cap < need) { return 0 as *B64Stream; }
  let s: *B64Stream = state as *B64Stream;
  if (s.magic != 0x42345354) { return 0 as *B64Stream; }
  return s;
}

/** 标准 Base64 编码；返回写入字节数，缓冲区不足 -1。 */
function base64_encode_standard_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let need: i32 = 0;
  let si: i32 = 0;
  let oi: i32 = 0;
  let rem: i32 = 0;
  let v: u32 = 0;
  if (src == 0 || out == 0 || out_cap < 0) { return -1; }
  need = (src_len + 2) / 3 * 4;
  if (out_cap < need) { return -1; }
  while (si + 3 <= src_len) {
    v = (src[si] as u32) << 16 | (src[si + 1] as u32) << 8 | (src[si + 2] as u32);
    out[oi] = b64_std_enc_char(((v >> 18) & 63) as i32);
    out[oi + 1] = b64_std_enc_char(((v >> 12) & 63) as i32);
    out[oi + 2] = b64_std_enc_char(((v >> 6) & 63) as i32);
    out[oi + 3] = b64_std_enc_char((v & 63) as i32);
    si = si + 3;
    oi = oi + 4;
  }
  rem = src_len - si;
  if (rem == 1) {
    v = (src[si] as u32) << 16;
    out[oi] = b64_std_enc_char(((v >> 18) & 63) as i32);
    out[oi + 1] = b64_std_enc_char(((v >> 12) & 63) as i32);
    out[oi + 2] = 61;
    out[oi + 3] = 61;
    oi = oi + 4;
  } else if (rem == 2) {
    v = (src[si] as u32) << 16 | (src[si + 1] as u32) << 8;
    out[oi] = b64_std_enc_char(((v >> 18) & 63) as i32);
    out[oi + 1] = b64_std_enc_char(((v >> 12) & 63) as i32);
    out[oi + 2] = b64_std_enc_char(((v >> 6) & 63) as i32);
    out[oi + 3] = 61;
    oi = oi + 4;
  }
  return oi;
}

/** URL 安全 Base64 编码（无 padding）；返回写入字节数。 */
function base64_encode_url_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let need: i32 = 0;
  let si: i32 = 0;
  let oi: i32 = 0;
  let rem: i32 = 0;
  let v: u32 = 0;
  if (src == 0 || out == 0 || out_cap < 0) { return -1; }
  need = (src_len + 2) / 3 * 4;
  if (src_len % 3 != 0) { need = need - (3 - (src_len % 3)); }
  if (out_cap < need) { return -1; }
  while (si + 3 <= src_len) {
    v = (src[si] as u32) << 16 | (src[si + 1] as u32) << 8 | (src[si + 2] as u32);
    out[oi] = b64_url_enc_char(((v >> 18) & 63) as i32);
    out[oi + 1] = b64_url_enc_char(((v >> 12) & 63) as i32);
    out[oi + 2] = b64_url_enc_char(((v >> 6) & 63) as i32);
    out[oi + 3] = b64_url_enc_char((v & 63) as i32);
    si = si + 3;
    oi = oi + 4;
  }
  rem = src_len - si;
  if (rem == 1) {
    v = (src[si] as u32) << 16;
    out[oi] = b64_url_enc_char(((v >> 18) & 63) as i32);
    out[oi + 1] = b64_url_enc_char(((v >> 12) & 63) as i32);
    oi = oi + 2;
  } else if (rem == 2) {
    v = (src[si] as u32) << 16 | (src[si + 1] as u32) << 8;
    out[oi] = b64_url_enc_char(((v >> 18) & 63) as i32);
    out[oi + 1] = b64_url_enc_char(((v >> 12) & 63) as i32);
    out[oi + 2] = b64_url_enc_char(((v >> 6) & 63) as i32);
    oi = oi + 3;
  }
  return oi;
}

/** 标准 Base64 解码；返回写入字节数，非法 -1。 */
function base64_decode_standard_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let out_len: i32 = 0;
  let si: i32 = 0;
  let oi: i32 = 0;
  let a: u32 = 0;
  let b: u32 = 0;
  let c: u32 = 0;
  let d: u32 = 0;
  if (src == 0 || out == 0) { return -1; }
  if (src_len % 4 != 0) { return -1; }
  out_len = (src_len / 4) * 3;
  if (src_len >= 1 && src[src_len - 1] == 61) {
    out_len = out_len - 1;
    if (src_len >= 2 && src[src_len - 2] == 61) { out_len = out_len - 1; }
  }
  if (out_cap < out_len) { return -1; }
  while (si + 4 <= src_len) {
    a = b64_decode_char_std(src[si]);
    b = b64_decode_char_std(src[si + 1]);
    c = b64_decode_char_std(src[si + 2]);
    d = b64_decode_char_std(src[si + 3]);
    if (a == 255 || b == 255) { return -1; }
    if (c == 254) { c = 0; }
    if (d == 254) { d = 0; }
    if (c == 255 || d == 255) { return -1; }
    out[oi] = ((a << 2) | (b >> 4)) as u8;
    if (src[si + 2] == 61) { return out_len; }
    out[oi + 1] = ((b << 4) | (c >> 2)) as u8;
    if (src[si + 3] == 61) { return out_len; }
    out[oi + 2] = ((c << 6) | d) as u8;
    si = si + 4;
    oi = oi + 3;
  }
  return oi;
}

/** URL 变体解码；返回写入字节数，非法 -1。 */
function base64_decode_url_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let out_len: i32 = 0;
  let si: i32 = 0;
  let oi: i32 = 0;
  let rem: i32 = 0;
  let a: u32 = 0;
  let b: u32 = 0;
  let c: u32 = 0;
  let d: u32 = 0;
  if (src == 0 || out == 0) { return -1; }
  out_len = (src_len * 3) / 4;
  if (src_len % 4 == 1) { return -1; }
  if (src_len % 4 != 0) { out_len = (src_len * 3) / 4 + (src_len % 4) - 1; }
  if (out_len < 0 || out_cap < out_len) { return -1; }
  while (si + 4 <= src_len) {
    a = b64_decode_char_url(src[si]);
    b = b64_decode_char_url(src[si + 1]);
    c = b64_decode_char_url(src[si + 2]);
    d = b64_decode_char_url(src[si + 3]);
    if (a == 255 || b == 255) { return -1; }
    if (c == 255) { c = 0; }
    if (d == 255) { d = 0; }
    out[oi] = ((a << 2) | (b >> 4)) as u8;
    out[oi + 1] = ((b << 4) | (c >> 2)) as u8;
    out[oi + 2] = ((c << 6) | d) as u8;
    si = si + 4;
    oi = oi + 3;
  }
  rem = src_len - si;
  if (rem == 2) {
    a = b64_decode_char_url(src[si]);
    b = b64_decode_char_url(src[si + 1]);
    if (a == 255 || b == 255) { return -1; }
    out[oi] = ((a << 2) | (b >> 4)) as u8;
    oi = oi + 1;
  } else if (rem == 3) {
    a = b64_decode_char_url(src[si]);
    b = b64_decode_char_url(src[si + 1]);
    c = b64_decode_char_url(src[si + 2]);
    if (a == 255 || b == 255 || c == 255) { return -1; }
    out[oi] = ((a << 2) | (b >> 4)) as u8;
    out[oi + 1] = ((b << 4) | (c >> 2)) as u8;
    oi = oi + 2;
  } else if (rem != 0) {
    return -1;
  }
  return oi;
}

/** 返回流状态缓冲最小字节数。 */
function base64_stream_state_bytes_c(): i32 {
  return B64_STREAM_STATE_BYTES;
}

/** 初始化 Base64 编码流；url 非 0 为 URL 变体；成功 0。 */
function base64_stream_enc_init_c(state: *u8, state_cap: i32, url: i32): i32 {
  let need: i32 = B64_STREAM_STATE_BYTES;
  let s: *B64Stream = 0 as *B64Stream;
  if (state == 0 || state_cap < need) { return -1; }
  unsafe { memset(state, 0, need); }
  s = state as *B64Stream;
  s.magic = 0x42345354;
  s.is_url = (url != 0) ? 1 : 0;
  s.is_enc = 1;
  return 0;
}

/** 初始化 Base64 解码流；成功 0。 */
function base64_stream_dec_init_c(state: *u8, state_cap: i32, url: i32): i32 {
  let need: i32 = B64_STREAM_STATE_BYTES;
  let s: *B64Stream = 0 as *B64Stream;
  if (state == 0 || state_cap < need) { return -1; }
  unsafe { memset(state, 0, need); }
  s = state as *B64Stream;
  s.magic = 0x42345354;
  s.is_url = (url != 0) ? 1 : 0;
  s.is_enc = 0;
  return 0;
}

/** 将 1–3 字节编码为 Base64 字符写入 out；返回写入字节数。 */
function b64_stream_emit_triplet(s: *B64Stream, tri: *u8, n: i32, is_last: i32, out: *u8, out_cap: i32): i32 {
  let v: u32 = 0;
  let need: i32 = 0;
  if (s == 0 || tri == 0 || out == 0 || n <= 0 || n > 3) { return -1; }
  v = (tri[0] as u32) << 16;
  if (n > 1) { v = v | ((tri[1] as u32) << 8); }
  if (n > 2) { v = v | (tri[2] as u32); }
  if (n == 3) {
    if (out_cap < 4) { return -1; }
    out[0] = b64_pick_enc_char(s.is_url, ((v >> 18) & 63) as i32);
    out[1] = b64_pick_enc_char(s.is_url, ((v >> 12) & 63) as i32);
    out[2] = b64_pick_enc_char(s.is_url, ((v >> 6) & 63) as i32);
    out[3] = b64_pick_enc_char(s.is_url, (v & 63) as i32);
    return 4;
  }
  if (is_last == 0) {
    if (n == 1) { need = 2; } else { need = 3; }
    if (out_cap < need) { return -1; }
    out[0] = b64_pick_enc_char(s.is_url, ((v >> 18) & 63) as i32);
    out[1] = b64_pick_enc_char(s.is_url, ((v >> 12) & 63) as i32);
    if (n == 2) {
      out[2] = b64_pick_enc_char(s.is_url, ((v >> 6) & 63) as i32);
      return 3;
    }
    return 2;
  }
  if (s.is_url != 0) {
    if (n == 1) { need = 2; } else { need = 3; }
    if (out_cap < need) { return -1; }
    out[0] = b64_pick_enc_char(s.is_url, ((v >> 18) & 63) as i32);
    out[1] = b64_pick_enc_char(s.is_url, ((v >> 12) & 63) as i32);
    if (n == 2) {
      out[2] = b64_pick_enc_char(s.is_url, ((v >> 6) & 63) as i32);
      return 3;
    }
    return 2;
  }
  if (out_cap < 4) { return -1; }
  out[0] = b64_pick_enc_char(s.is_url, ((v >> 18) & 63) as i32);
  out[1] = b64_pick_enc_char(s.is_url, ((v >> 12) & 63) as i32);
  out[2] = b64_pick_enc_char(s.is_url, ((v >> 6) & 63) as i32);
  out[3] = 61;
  if (n == 1) { out[2] = 61; }
  return 4;
}

/** 流式 Base64 编码 update；is_last=1 时 flush padding。 */
function base64_stream_enc_update_c(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8,
  out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
  let s: *B64Stream = b64_stream_cast(state, state_cap);
  let used_in: i32 = 0;
  let written: i32 = 0;
  let work: u8[3];
  let wi: i32 = 0;
  let n: i32 = 0;
  work[0] = 0;
  work[1] = 0;
  work[2] = 0;
  if (s == 0) { return -1; }
  if (s.is_enc == 0) { return -1; }
  if (out == 0) { return -1; }
  if (out_cap <= 0) { return -1; }
  if (in_len > 0) {
    if (inp == 0) { return -1; }
  }
  if (in_consumed != 0) { in_consumed[0] = 0; }
  while (s.pending_len > 0 || used_in < in_len) {
    while (wi < 3 && s.pending_len > 0) {
      work[wi] = s.pending[0];
      s.pending[0] = s.pending[1];
      s.pending[1] = s.pending[2];
      s.pending_len = s.pending_len - 1;
      wi = wi + 1;
    }
    while (wi < 3 && used_in < in_len) {
      work[wi] = inp[used_in];
      used_in = used_in + 1;
      wi = wi + 1;
    }
    if (wi < 3) {
      if (is_last == 0) { break; }
      if (wi == 0) { break; }
      n = b64_stream_emit_triplet(s, &work[0], wi, 1, out + written, out_cap - written);
      if (n < 0) {
        if (in_consumed != 0) { in_consumed[0] = used_in; }
        return -1;
      }
      written = written + n;
      wi = 0;
      break;
    }
    n = b64_stream_emit_triplet(s, &work[0], 3, 0, out + written, out_cap - written);
    if (n < 0) {
      if (in_consumed != 0) { in_consumed[0] = used_in; }
      return -1;
    }
    written = written + n;
    wi = 0;
  }
  if (wi > 0 && is_last == 0) {
    s.pending[0] = work[0];
    if (wi > 1) { s.pending[1] = work[1]; }
    s.pending_len = wi;
  }
  if (in_consumed != 0) { in_consumed[0] = used_in; }
  return written;
}

/** 将 4 个 Base64 字符解码为最多 3 字节。 */
function b64_stream_decode_quad(s: *B64Stream, quad: *u8, n: i32, is_last: i32, out: *u8, out_cap: i32): i32 {
  let a: u32 = 0;
  let b: u32 = 0;
  let c: u32 = 0;
  let d: u32 = 0;
  let out_len: i32 = 0;
  if (s == 0 || quad == 0 || out == 0 || n <= 0 || n > 4) { return -1; }
  if (s.is_url != 0) {
    a = b64_decode_char_url(quad[0]);
    b = b64_decode_char_url(quad[1]);
  } else {
    a = b64_decode_char_std(quad[0]);
    b = b64_decode_char_std(quad[1]);
  }
  if (a == 255 || b == 255) { return -1; }
  if (n == 2 && is_last != 0) {
    if (out_cap < 1) { return -1; }
    out[0] = ((a << 2) | (b >> 4)) as u8;
    return 1;
  }
  if (n == 3 && is_last != 0) {
    if (s.is_url != 0) { c = b64_decode_char_url(quad[2]); } else { c = b64_decode_char_std(quad[2]); }
    if (c == 255) { return -1; }
    if (out_cap < 2) { return -1; }
    out[0] = ((a << 2) | (b >> 4)) as u8;
    out[1] = ((b << 4) | (c >> 2)) as u8;
    return 2;
  }
  if (n < 4 && is_last == 0) { return 0; }
  if (s.is_url != 0) {
    c = b64_decode_char_url(quad[2]);
    d = b64_decode_char_url(quad[3]);
    if (c == 255) { c = 0; }
    if (d == 255) { d = 0; }
  } else {
    c = b64_decode_char_std(quad[2]);
    d = b64_decode_char_std(quad[3]);
    if (c == 254) { c = 0; }
    if (d == 254) { d = 0; }
  }
  if (c == 255 || d == 255) { return -1; }
  out_len = 3;
  if (quad[2] == 61) { out_len = 1; } else if (quad[3] == 61) { out_len = 2; }
  if (out_cap < out_len) { return -1; }
  out[0] = ((a << 2) | (b >> 4)) as u8;
  if (out_len >= 2) { out[1] = ((b << 4) | (c >> 2)) as u8; }
  if (out_len >= 3) { out[2] = ((c << 6) | d) as u8; }
  return out_len;
}

/** 流式 Base64 解码 update；is_last=1 时 flush 尾部。 */
function base64_stream_dec_update_c(state: *u8, state_cap: i32, inp: *u8, in_len: i32, out: *u8,
  out_cap: i32, is_last: i32, in_consumed: *i32): i32 {
  let s: *B64Stream = b64_stream_cast(state, state_cap);
  let used_in: i32 = 0;
  let written: i32 = 0;
  let quad: u8[4];
  let qi: i32 = 0;
  let n: i32 = 0;
  quad[0] = 0;
  quad[1] = 0;
  quad[2] = 0;
  quad[3] = 0;
  if (s == 0) { return -1; }
  if (s.is_enc != 0) { return -1; }
  if (out == 0) { return -1; }
  if (out_cap <= 0) { return -1; }
  if (in_len > 0) {
    if (inp == 0) { return -1; }
  }
  if (in_consumed != 0) { in_consumed[0] = 0; }
  qi = s.dec_len;
  if (qi > 0) { unsafe { memcpy(&quad[0], &s.dec_pending[0], qi); } }
  while (qi > 0 || used_in < in_len) {
    while (qi < 4 && used_in < in_len) {
      quad[qi] = inp[used_in];
      used_in = used_in + 1;
      qi = qi + 1;
    }
    if (qi < 4) {
      if (is_last == 0) { break; }
      n = b64_stream_decode_quad(s, &quad[0], qi, 1, out + written, out_cap - written);
      if (n < 0) {
        if (in_consumed != 0) { in_consumed[0] = used_in; }
        return -1;
      }
      written = written + n;
      qi = 0;
      break;
    }
    n = b64_stream_decode_quad(s, &quad[0], 4, 0, out + written, out_cap - written);
    if (n < 0) {
      if (in_consumed != 0) { in_consumed[0] = used_in; }
      return -1;
    }
    written = written + n;
    qi = 0;
  }
  s.dec_len = qi;
  if (qi > 0) { unsafe { memcpy(&s.dec_pending[0], &quad[0], qi); } }
  if (in_consumed != 0) { in_consumed[0] = used_in; }
  return written;
}

/** STD-109：流式 base64 烟测（hello 分块 ≡ 块 API）；0 成功。 */
function base64_stream_smoke_c(): i32 {
  let plain: u8[5];
  let st: u8[32];
  let enc: u8[16];
  let dec: u8[8];
  let block: u8[16];
  let consumed: i32 = 0;
  let n1: i32 = 0;
  let n2: i32 = 0;
  let dn: i32 = 0;
  let i: i32 = 0;
  plain[0] = 104;
  plain[1] = 101;
  plain[2] = 108;
  plain[3] = 108;
  plain[4] = 111;
  unsafe { memset(&st[0], 0, 32); }
  unsafe { memset(&enc[0], 0, 16); }
  unsafe { memset(&dec[0], 0, 8); }
  unsafe { memset(&block[0], 0, 16); }
  if (base64_encode_standard_c(&plain[0], 5, &block[0], 16) != 8) { return -1; }
  if (base64_stream_enc_init_c(&st[0], 32, 0) != 0) { return -1; }
  n1 = base64_stream_enc_update_c(&st[0], 32, &plain[0], 2, &enc[0], 16, 0, &consumed);
  if (n1 < 0 || consumed != 2) { return -1; }
  n2 = base64_stream_enc_update_c(&st[0], 32, &plain[2], 3, &enc[n1], 16 - n1, 1, &consumed);
  if (n2 < 0 || consumed != 3 || n1 + n2 != 8) { return -1; }
  i = 0;
  while (i < 8) {
    if (enc[i] != block[i]) { return -1; }
    i = i + 1;
  }
  if (base64_stream_dec_init_c(&st[0], 32, 0) != 0) { return -1; }
  dn = base64_stream_dec_update_c(&st[0], 32, &enc[0], 4, &dec[0], 8, 0, &consumed);
  if (dn < 0 || consumed != 4) { return -1; }
  dn = dn + base64_stream_dec_update_c(&st[0], 32, &enc[4], 4, &dec[dn], 8 - dn, 1, &consumed);
  if (dn != 5) { return -1; }
  i = 0;
  while (i < 5) {
    if (dec[i] != plain[i]) { return -1; }
    i = i + 1;
  }
  return 0;
}
