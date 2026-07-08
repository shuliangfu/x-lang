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

// std/url/url.x — F-url v2 + F-ZC：URL 解析/构建/query/resolve（纯 .x，无 .c/.h）
//
// 【文件职责】
// RFC 3986 parse/build、query percent 编解码、相对 resolve、IPv6 host 转换与烟测。
// IPv6 文本转换经 libc inet_pton/inet_ntop；编译为 url.o；对外 API 在 mod.x。
//
// 【对标】Go net/url、Rust url crate。

const URL_STRUCT_SIZE: usize = 1600;

/** POSIX AF_INET6（与 std.net 一致）。 */
const AF_INET6: i32 = 10;

/** IPv6 文本缓冲上限（含 NUL）。 */
const INET6_ADDRSTRLEN: i32 = 46;

/** percent 编码用大写 hex 表。 */
const URL_HEX: u8[16] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70];

/** 与 mod.x Url 布局一致（字段顺序须匹配）。 */
allow(padding) struct Url {
  scheme_len: i32;
  host_len: i32;
  port_len: i32;
  path_len: i32;
  query_len: i32;
  fragment_len: i32;
  scheme: u8[32];
  host: u8[256];
  port: u8[8];
  path: u8[512];
  query: u8[512];
  fragment: u8[256];
}

extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern "C" function memset(s: *u8, c: i32, n: usize): *u8;
extern "C" function strlen(s: *u8): usize;
extern "C" function inet_pton(af: i32, src: *u8, dst: *u8): i32;
extern "C" function inet_ntop(af: i32, src: *u8, dst: *u8, size: usize): *u8;

/** F-url v1 版本标记。 */
function url_f_url_v1_marker_c(): i32 {
  return 1;
}

/** F-url v2 逻辑下沉标记。 */
function url_f_url_v2_marker_c(): i32 {
  return 1;
}

/** F-std-zero-c：url_glue.c 已删除，IPv6 转换在 .x 内。 */
function url_f_zero_c_marker_c(): i32 {
  return 1;
}

/**
 * IPv6 文本 → 16 字节；成功 0，失败 -1。
 * 经 libc 的 IPv6 文本解析接口。
 */
function url_inet_pton6_c(src: *u8, out_16: *u8): i32 {
  if (src == 0 || out_16 == 0) { return -1; }
  unsafe { if (inet_pton(AF_INET6, src, out_16) != 1) { return -1; } }
  return 0;
}

/**
 * 16 字节 IPv6 → 文本；返回写入长度（不含 NUL），失败 -1。
 * 经 libc 的 IPv6 文本格式化接口。
 */
function url_inet_ntop6_c(addr_16: *u8, out: *u8, out_cap: i32): i32 {
  let buf: u8[46] = [];
  let p: *u8 = 0;
  let len: usize = 0;
  if (addr_16 == 0 || out == 0 || out_cap <= 0) { return -1; }
  unsafe { p = inet_ntop(AF_INET6, addr_16, &buf[0], INET6_ADDRSTRLEN); }
  if (p == 0) { return -1; }
  unsafe { len = strlen(&buf[0]); }
  if ((len as i32) + 1 > out_cap) { return -1; }
  unsafe { memcpy(out, &buf[0], (len + 1)); }
  return len as i32;
}

/** 拷贝片段到 buf；成功 0。 */
function url_copy_part(src: *u8, len: i32, dst: *u8, cap: i32, out_len: *i32): i32 {
  if (len < 0 || len >= cap) { return -1; }
  if (len > 0) { unsafe { memcpy(dst, src, len); } }
  dst[len] = 0;
  out_len[0] = len;
  return 0;
}

/** host 是否需 IPv6 方括号。 */
function url_host_needs_brackets(host: *u8, host_len: i32): i32 {
  let i: i32 = 0;
  if (host_len <= 0) { return 0; }
  if (host[0] == 91) { return 0; }
  while (i < host_len) {
    if (host[i] == 58) { return 1; }
    i = i + 1;
  }
  return 0;
}

/** 查找 "://" 位置；无则 -1。 */
function url_find_scheme_end(url: *u8, len: i32): i32 {
  let i: i32 = 0;
  while (i + 2 < len) {
    if (url[i] == 58 && url[i + 1] == 47 && url[i + 2] == 47) {
      return i;
    }
    i = i + 1;
  }
  return -1;
}

/** 解析绝对/相对 URL；成功 0。 */
function url_parse_c(url: *u8, len: i32, out: *Url): i32 {
  let i: i32 = 0;
  let scheme_end: i32 = 0;
  let host_start: i32 = 0;
  let authority_end: i32 = 0;
  if (url == 0 || len <= 0 || out == 0) { return -1; }
  unsafe { memset(out as *u8, 0, URL_STRUCT_SIZE); }
  scheme_end = url_find_scheme_end(url, len);
  if (scheme_end >= 0) {
    if (url_copy_part(url, scheme_end, &out.scheme[0], 32, &out.scheme_len) != 0) { return -1; }
    i = scheme_end + 3;
    host_start = i;
    if (i < len && url[i] == 91) {
      i = i + 1;
      while (i < len && url[i] != 93) { i = i + 1; }
      if (i >= len || url[i] != 93) { return -1; }
      i = i + 1;
      if (url_copy_part(url + (host_start + 1), i - host_start - 2, &out.host[0], 256, &out.host_len) != 0) {
        return -1;
      }
    } else {
      while (i < len && url[i] != 58 && url[i] != 47 && url[i] != 63 && url[i] != 35) {
        i = i + 1;
      }
      if (url_copy_part(url + host_start, i - host_start, &out.host[0], 256, &out.host_len) != 0) { return -1; }
    }
    if (i < len && url[i] == 58) {
      let ps: i32 = i + 1;
      i = ps;
      while (i < len && url[i] >= 48 && url[i] <= 57) { i = i + 1; }
      if (url_copy_part(url + ps, i - ps, &out.port[0], 8, &out.port_len) != 0) { return -1; }
    }
    authority_end = i;
    if (i >= len || url[i] != 47) {
      out.path[0] = 47;
      out.path[1] = 0;
      out.path_len = 1;
      i = authority_end;
    }
  } else {
    i = 0;
  }
  if (i < len && url[i] == 47) {
    let ps: i32 = i;
    while (i < len && url[i] != 63 && url[i] != 35) { i = i + 1; }
    if (url_copy_part(url + ps, i - ps, &out.path[0], 512, &out.path_len) != 0) { return -1; }
  } else if (out.path_len == 0) {
    if (scheme_end >= 0) {
      out.path[0] = 47;
      out.path[1] = 0;
      out.path_len = 1;
    } else if (i < len) {
      let ps: i32 = i;
      while (i < len && url[i] != 63 && url[i] != 35) { i = i + 1; }
      if (url_copy_part(url + ps, i - ps, &out.path[0], 512, &out.path_len) != 0) { return -1; }
    }
  }
  if (i < len && url[i] == 63) {
    let qs: i32 = i + 1;
    i = qs;
    while (i < len && url[i] != 35) { i = i + 1; }
    if (url_copy_part(url + qs, i - qs, &out.query[0], 512, &out.query_len) != 0) { return -1; }
  }
  if (i < len && url[i] == 35) {
    let fs: i32 = i + 1;
    i = fs;
    while (i < len) { i = i + 1; }
    if (url_copy_part(url + fs, i - fs, &out.fragment[0], 256, &out.fragment_len) != 0) { return -1; }
  }
  return 0;
}

/** 组装 URL 字符串；返回写入长度，失败 -1。 */
function url_build_c(u: *Url, out: *u8, out_cap: i32): i32 {
  let n: i32 = 0;
  let rem: i32 = 0;
  if (u == 0 || out == 0 || out_cap <= 0) { return -1; }
  rem = out_cap;
  if (u.scheme_len > 0) {
    if (u.scheme_len + 3 >= rem) { return -1; }
    unsafe { memcpy(out + n, &u.scheme[0], u.scheme_len); }
    n = n + u.scheme_len;
    out[n] = 58;
    n = n + 1;
    out[n] = 47;
    n = n + 1;
    out[n] = 47;
    n = n + 1;
    rem = out_cap - n;
  }
  if (u.host_len > 0) {
    if (url_host_needs_brackets(&u.host[0], u.host_len) != 0) {
      if (u.host_len + 2 > rem) { return -1; }
      out[n] = 91;
      n = n + 1;
      unsafe { memcpy(out + n, &u.host[0], u.host_len); }
      n = n + u.host_len;
      out[n] = 93;
      n = n + 1;
    } else {
      if (u.host_len > rem) { return -1; }
      unsafe { memcpy(out + n, &u.host[0], u.host_len); }
      n = n + u.host_len;
    }
    rem = out_cap - n;
  }
  if (u.port_len > 0) {
    if (1 + u.port_len > rem) { return -1; }
    out[n] = 58;
    n = n + 1;
    unsafe { memcpy(out + n, &u.port[0], u.port_len); }
    n = n + u.port_len;
    rem = out_cap - n;
  }
  if (u.path_len > 0) {
    if (u.path_len > rem) { return -1; }
    unsafe { memcpy(out + n, &u.path[0], u.path_len); }
    n = n + u.path_len;
    rem = out_cap - n;
  }
  if (u.query_len > 0) {
    if (1 + u.query_len > rem) { return -1; }
    out[n] = 63;
    n = n + 1;
    unsafe { memcpy(out + n, &u.query[0], u.query_len); }
    n = n + u.query_len;
    rem = out_cap - n;
  }
  if (u.fragment_len > 0) {
    if (1 + u.fragment_len > rem) { return -1; }
    out[n] = 35;
    n = n + 1;
    unsafe { memcpy(out + n, &u.fragment[0], u.fragment_len); }
    n = n + u.fragment_len;
  }
  if (n >= out_cap) { return -1; }
  out[n] = 0;
  return n;
}

/** query 未编码字符判定。 */
function url_query_unreserved(c: u8): i32 {
  if ((c >= 97 && c <= 122) || (c >= 65 && c <= 90)) { return 1; }
  if (c >= 48 && c <= 57) { return 1; }
  if (c == 45 || c == 95 || c == 46 || c == 126) { return 1; }
  return 0;
}

/** hex 字符值；非法 -1。 */
function url_hex_val(c: u8): i32 {
  if (c >= 48 && c <= 57) { return (c - 48) as i32; }
  if (c >= 97 && c <= 102) { return (c - 97 + 10) as i32; }
  if (c >= 65 && c <= 70) { return (c - 65 + 10) as i32; }
  return -1;
}

/** query percent 编码；返回写入长度。 */
function url_query_encode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let i: i32 = 0;
  let n: i32 = 0;
  let c: u8 = 0;
  if (src == 0 || out == 0 || out_cap <= 0) { return -1; }
  if (src_len <= 0) { return 0; }
  while (i < src_len) {
    c = src[i];
    if (url_query_unreserved(c) != 0) {
      if (n + 1 >= out_cap) { return -1; }
      out[n] = c;
      n = n + 1;
    } else {
      if (n + 3 >= out_cap) { return -1; }
      out[n] = 37;
      out[(n + 1)] = URL_HEX[((c as i32) >> 4)];
      out[(n + 2)] = URL_HEX[(c & 15)];
      n = n + 3;
    }
    i = i + 1;
  }
  return n;
}

/** query percent 解码；返回写入长度。 */
function url_query_decode_c(src: *u8, src_len: i32, out: *u8, out_cap: i32): i32 {
  let i: i32 = 0;
  let n: i32 = 0;
  let hi: i32 = 0;
  let lo: i32 = 0;
  if (src == 0 || out == 0 || out_cap <= 0) { return -1; }
  while (i < src_len) {
    if (src[i] == 37 && i + 2 < src_len) {
      hi = url_hex_val(src[i + 1]);
      lo = url_hex_val(src[i + 2]);
      if (hi < 0 || lo < 0) { return -1; }
      if (n + 1 >= out_cap) { return -1; }
      out[n] = ((hi << 4) | lo) as u8;
      n = n + 1;
      i = i + 3;
    } else {
      if (n + 1 >= out_cap) { return -1; }
      out[n] = src[i];
      n = n + 1;
      i = i + 1;
    }
  }
  return n;
}

/** 路径段 pop。 */
function url_path_pop_segment(path: *u8, path_len: *i32): void {
  let len: i32 = *path_len;
  while (len > 0 && path[len - 1] == 47) { len = len - 1; }
  while (len > 0 && path[len - 1] != 47) { len = len - 1; }
  if (len <= 0) {
    path[0] = 47;
    path[1] = 0;
    *path_len = 1;
    return;
  }
  path[len] = 0;
  *path_len = len;
}

/** 合并 base path 与相对 ref path。 */
function url_merge_paths(base_path: *u8, base_len: i32, ref_path: *u8, ref_len: i32, out: *u8, out_cap: i32, out_len: *i32): i32 {
  let i: i32 = 0;
  let n: i32 = 0;
  let bl: i32 = base_len;
  if (base_path == 0 || ref_path == 0 || out == 0 || out_len == 0) { return -1; }
  if (ref_len > 0 && ref_path[0] == 47) {
    return url_copy_part(ref_path, ref_len, out, out_cap, out_len);
  }
  while (bl > 0 && base_path[(bl - 1)] == 47) { bl = bl - 1; }
  if (bl <= 0) {
    out[0] = 47;
    n = 1;
  } else {
    if (bl >= out_cap) { return -1; }
    unsafe { memcpy(out, base_path, bl); }
    n = bl;
    if (out[(n - 1)] != 47) {
      if (n + 1 >= out_cap) { return -1; }
      out[n] = 47;
      n = n + 1;
    }
  }
  while (i < ref_len) {
    if (ref_path[i] == 47) {
      i = i + 1;
      continue;
    }
    if (i + 2 < ref_len && ref_path[i] == 46 && ref_path[i + 1] == 46 &&
        (i + 2 == ref_len || ref_path[i + 2] == 47)) {
      url_path_pop_segment(out, &n);
      i = i + 2;
      if (i < ref_len && ref_path[i] == 47) { i = i + 1; }
      continue;
    }
    if (ref_path[i] == 46 && (i + 1 == ref_len || ref_path[i + 1] == 47)) {
      i = i + 1;
      if (i < ref_len && ref_path[i] == 47) { i = i + 1; }
      continue;
    }
    while (i < ref_len && ref_path[i] != 47) {
      if (n + 1 >= out_cap) { return -1; }
      out[n] = ref_path[i];
      n = n + 1;
      i = i + 1;
    }
    if (i < ref_len && ref_path[i] == 47) {
      if (n + 1 >= out_cap) { return -1; }
      out[n] = 47;
      n = n + 1;
      i = i + 1;
    }
  }
  if (n <= 0) {
    out[0] = 47;
    n = 1;
  }
  out[n] = 0;
  out_len[0] = n;
  return 0;
}

/** 相对 URL resolve；成功 0。 */
function url_resolve_c(base: *Url, ref: *u8, ref_len: i32, out: *Url): i32 {
  let rel: Url = Url {
    scheme_len: 0, host_len: 0, port_len: 0, path_len: 0, query_len: 0, fragment_len: 0,
    scheme: [], host: [], port: [], path: [], query: [], fragment: []
  };
  let rel_ptr: *Url = 0 as *Url;
  let merged: u8[512] = [];
  let merged_len: i32 = 0;
  if (base == 0 || ref == 0 || out == 0) { return -1; }
  if (url_parse_c(ref, ref_len, &rel) != 0) { return -1; }
  if (rel.scheme_len > 0) {
    rel_ptr = &rel;
    unsafe { memcpy(out as *u8, rel_ptr as *u8, URL_STRUCT_SIZE); }
    return 0;
  }
  unsafe { memcpy(out as *u8, base as *u8, URL_STRUCT_SIZE); }
  if (rel.host_len > 0) {
    out.host_len = rel.host_len;
    unsafe { memcpy(&out.host[0], &rel.host[0], rel.host_len); }
    out.host[out.host_len] = 0;
    out.port_len = rel.port_len;
    unsafe { memcpy(&out.port[0], &rel.port[0], rel.port_len); }
    out.port[out.port_len] = 0;
  }
  if (rel.path_len > 0) {
    if (url_merge_paths(&base.path[0], base.path_len, &rel.path[0], rel.path_len, &merged[0], 512, &merged_len) != 0) {
      return -1;
    }
    if (url_copy_part(&merged[0], merged_len, &out.path[0], 512, &out.path_len) != 0) { return -1; }
  }
  if (rel.query_len > 0) {
    if (url_copy_part(&rel.query[0], rel.query_len, &out.query[0], 512, &out.query_len) != 0) { return -1; }
  }
  if (rel.fragment_len > 0) {
    if (url_copy_part(&rel.fragment[0], rel.fragment_len, &out.fragment[0], 256, &out.fragment_len) != 0) {
      return -1;
    }
  }
  return 0;
}

/** host 片段拷贝为 NUL 结尾 C 串；成功 0。 */
function url_host_to_nul(host: *u8, host_len: i32, dst: *u8, cap: i32): i32 {
  if (host == 0 || dst == 0 || host_len <= 0 || host_len >= cap) { return -1; }
  unsafe { memcpy(dst, host, host_len); }
  dst[host_len] = 0;
  return 0;
}

/** 解析 host 为 16 字节 IPv6；成功 0。 */
function url_host_to_ipv6_c(host: *u8, host_len: i32, out_16: *u8): i32 {
  let buf: u8[256] = [];
  if (host == 0 || out_16 == 0) { return -1; }
  if (url_host_to_nul(host, host_len, &buf[0], 256) != 0) { return -1; }
  return url_inet_pton6_c(&buf[0], out_16);
}

/** 16 字节 IPv6 格式化为 host 文本；返回长度，失败 -1。 */
function url_format_ipv6_host_c(addr_16: *u8, out: *u8, out_cap: i32): i32 {
  return url_inet_ntop6_c(addr_16, out, out_cap);
}

/** host 是否为合法 IPv6 文本。 */
function url_host_is_ipv6_c(host: *u8, host_len: i32): i32 {
  let tmp: u8[16] = [];
  if (url_host_to_ipv6_c(host, host_len, &tmp[0]) == 0) { return 1; }
  return 0;
}

/** STD-134：IPv6 host 解析/格式化与 bracket URL 金样。 */
function url_ipv6_host_smoke_c(): i32 {
  let u: Url = Url {
    scheme_len: 0, host_len: 0, port_len: 0, path_len: 0, query_len: 0, fragment_len: 0,
    scheme: [], host: [], port: [], path: [], query: [], fragment: []
  };
  let addr: u8[16] = [];
  let host_buf: u8[64] = [];
  let url_buf: u8[128] = [];
  let n: i32 = 0;
  let s_loop: u8[24] = [104, 116, 116, 112, 58, 47, 47, 91, 58, 58, 49, 93, 58, 56, 48, 56, 48, 47, 112, 97, 116, 104, 0, 0];
  let s_db8: u8[28] = [104, 116, 116, 112, 58, 47, 47, 91, 50, 48, 48, 49, 58, 100, 98, 56, 58, 58, 49, 93, 58, 52, 52, 51, 47, 0, 0, 0];
  if (url_parse_c(&s_loop[0], 22, &u) != 0) { return 1; }
  if (u.host_len != 3 || u.host[0] != 58 || u.host[1] != 58 || u.host[2] != 49) { return 2; }
  if (url_host_to_ipv6_c(&u.host[0], u.host_len, &addr[0]) != 0) { return 3; }
  if (addr[15] != 1) { return 4; }
  n = url_format_ipv6_host_c(&addr[0], &host_buf[0], 64);
  if (n != 3 || host_buf[0] != 58) { return 5; }
  if (url_host_is_ipv6_c(&u.host[0], u.host_len) != 1) { return 6; }
  let ex: u8[11] = [101, 120, 97, 109, 112, 108, 101, 46, 99, 111, 109];
  if (url_host_is_ipv6_c(&ex[0], 11) != 0) { return 7; }
  if (url_parse_c(&s_db8[0], 26, &u) != 0) { return 8; }
  if (url_host_to_ipv6_c(&u.host[0], u.host_len, &addr[0]) != 0) { return 9; }
  if (url_build_c(&u, &url_buf[0], 128) <= 0) { return 10; }
  if (url_buf[7] != 91 || url_buf[8] != 50) { return 11; }
  return 0;
}

/** C 烟测。 */
function url_smoke_c(): i32 {
  let u: Url = Url {
    scheme_len: 0, host_len: 0, port_len: 0, path_len: 0, query_len: 0, fragment_len: 0,
    scheme: [], host: [], port: [], path: [], query: [], fragment: []
  };
  let out: Url = Url {
    scheme_len: 0, host_len: 0, port_len: 0, path_len: 0, query_len: 0, fragment_len: 0,
    scheme: [], host: [], port: [], path: [], query: [], fragment: []
  };
  let buf: u8[512] = [];
  let enc: u8[64] = [];
  let dec: u8[64] = [];
  let n: i32 = 0;
  let s1: u8[38] = [104, 116, 116, 112, 58, 47, 47, 101, 120, 97, 109, 112, 108, 101, 46, 99, 111, 109, 58, 56, 48, 56, 48, 47, 112, 97, 116, 104, 63, 113, 61, 49, 35, 102, 114, 97, 103, 0];
  let s2: u8[20] = [104, 116, 116, 112, 58, 47, 47, 91, 58, 58, 49, 93, 58, 56, 48, 56, 48, 47, 0, 0];
  let ab: u8[3] = [97, 32, 98];
  let base_url: u8[20] = [104, 116, 116, 112, 58, 47, 47, 97, 46, 99, 111, 109, 47, 102, 111, 111, 47, 98, 97, 114];
  let ref_rel: u8[6] = [46, 46, 47, 98, 97, 122];
  if (url_parse_c(&s1[0], 37, &u) != 0) { return 1; }
  if (u.scheme_len != 4 || u.host_len != 11 || u.port_len != 4) { return 2; }
  if (url_build_c(&u, &buf[0], 512) <= 0) { return 3; }
  if (url_parse_c(&s2[0], 19, &u) != 0) { return 4; }
  if (u.host_len != 3) { return 5; }
  n = url_query_encode_c(&ab[0], 3, &enc[0], 64);
  if (n != 5) { return 6; }
  if (enc[0] != 97 || enc[1] != 37) { return 7; }
  n = url_query_decode_c(&enc[0], n, &dec[0], 64);
  if (n != 3 || dec[0] != 97 || dec[1] != 32 || dec[2] != 98) { return 8; }
  if (url_parse_c(&base_url[0], 20, &u) != 0) { return 9; }
  if (url_resolve_c(&u, &ref_rel[0], 6, &out) != 0) { return 10; }
  if (out.path_len < 8) { return 11; }
  if (url_ipv6_host_smoke_c() != 0) { return 12; }
  return 0;
}
