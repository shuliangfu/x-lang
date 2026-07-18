// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-423/424/425/426/427：L2 hybrid thin — lsp_fmt 19 functions.
// PREFER_X_O: thin.o + seed-rest (-DSHUX_L2_LSP_FMT_THIN_FROM_X) ld -r -> runtime_lsp_glue.o
// 逻辑对照: src/asm/runtime_lsp_glue.x; 产品默认仍整 seed.
//
// f-423: 5 pure leaf（无 libc 依赖、无全局状态、无跨函数调用）:
//   lsp_fmt_is_atom_tail / lsp_fmt_is_atom_head / lsp_fmt_unary_lhs
//   lsp_fmt_last_out / lsp_fmt_prev_src
// f-424: 5 中层（依赖上述叶函数，无 libc 依赖）:
//   lsp_fmt_src_ws_before / lsp_fmt_src_ws_after
//   lsp_fmt_space_before / lsp_fmt_space_after
//   lsp_json_escape_ident
// f-425: 5 LSP helper（含 JSON 解析 + 块注释检测；lsp_parse_bool_after 依赖 lsp_find_key_after）:
//   col_in_ident_span / lsp_find_key_after / lsp_parse_bool_after
//   lsp_line_has_block_comment_end / lsp_line_is_block_comment
// f-426: 3 ASTFunc 辅助（func_name_covers + 2 byte-offset helper；.x 用 usize 替代 struct 成员访问）:
//   lsp_load_i32_at / lsp_load_ptr_at / func_name_covers
// f-427: lsp_hash_source（usize FNV hash；大常量 0x9e3779b97f4a7c15 / 2^32 用字节构造绕过 -E 截断；
//   Ubuntu shux -E 不支持 u64，改用 usize 替代）

export function lsp_char_in_range(c: u8, lo: u8, hi: u8): i32 {
  if (c < lo) { return 0; }
  if (c > hi) { return 0; }
  return 1;
}

export function lsp_fmt_is_inline_ws(c: u8): i32 {
  if (c == 32) { return 1; }
  if (c == 9) { return 1; }
  return 0;
}

export function lsp_fmt_is_src_ws(c: u8): i32 {
  if (lsp_fmt_is_inline_ws(c) != 0) { return 1; }
  if (c == 13) { return 1; }
  return 0;
}

export function lsp_store_i32(dst: *i32, value: i32): void {
  if (dst == 0) { return; }
  unsafe {
    dst[0] = value;
  }
}

export function lsp_match_bytes_at(buf: *u8, off: i32, lit: *u8, lit_len: i32): i32 {
  let j: i32 = 0;
  while (j < lit_len) {
    if (buf[off + j] != lit[j]) {
      return 0;
    }
    j = j + 1;
  }
  return 1;
}

#[no_mangle]
export function lsp_fmt_is_atom_tail(c: u8): i32 {
  if (lsp_char_in_range(c, 97 as u8, 122 as u8) != 0) { return 1; }
  if (lsp_char_in_range(c, 65 as u8, 90 as u8) != 0) { return 1; }
  if (lsp_char_in_range(c, 48 as u8, 57 as u8) != 0) { return 1; }
  if (c == 95) { return 1; }
  if (c == 41) { return 1; }
  if (c == 93) { return 1; }
  if (c == 125) { return 1; }
  return 0;
}

#[no_mangle]
export function lsp_fmt_is_atom_head(c: u8): i32 {
  if (lsp_char_in_range(c, 97 as u8, 122 as u8) != 0) { return 1; }
  if (lsp_char_in_range(c, 65 as u8, 90 as u8) != 0) { return 1; }
  if (lsp_char_in_range(c, 48 as u8, 57 as u8) != 0) { return 1; }
  if (c == 95) { return 1; }
  if (c == 40) { return 1; }
  if (c == 91) { return 1; }
  if (c == 123) { return 1; }
  return 0;
}

#[no_mangle]
export function lsp_fmt_unary_lhs(prev: u8): i32 {
  if (prev == 0) { return 1; }
  if (prev == 40) { return 1; }
  if (prev == 91) { return 1; }
  if (prev == 123) { return 1; }
  if (prev == 44) { return 1; }
  if (prev == 58) { return 1; }
  if (prev == 59) { return 1; }
  if (prev == 61) { return 1; }
  if (prev == 43) { return 1; }
  if (prev == 45) { return 1; }
  if (prev == 42) { return 1; }
  if (prev == 47) { return 1; }
  if (prev == 37) { return 1; }
  if (prev == 38) { return 1; }
  if (prev == 124) { return 1; }
  if (prev == 94) { return 1; }
  if (prev == 33) { return 1; }
  if (prev == 126) { return 1; }
  if (prev == 60) { return 1; }
  if (prev == 62) { return 1; }
  return 0;
}

#[no_mangle]
export function lsp_fmt_last_out(out_buf: *u8, out_len: i32): u8 {
  let k: i32 = out_len - 1;
  while (k >= 0) {
    let c: u8 = out_buf[k];
    if (lsp_fmt_is_inline_ws(c) == 0) { return c; }
    k = k - 1;
  }
  return 0 as u8;
}

#[no_mangle]
export function lsp_fmt_prev_src(doc: *u8, start: i32, j: i32): u8 {
  let k: i32 = j - 1;
  while (k >= 0) {
    let c: u8 = doc[start + k];
    if (lsp_fmt_is_src_ws(c) == 0) { return c; }
    k = k - 1;
  }
  return 0 as u8;
}

#[no_mangle]
export function lsp_fmt_src_ws_before(doc: *u8, start: i32, j: i32): i32 {
  let k: i32 = j - 1;
  if (k < 0) { return 0; }
  let c: u8 = doc[start + k];
  return lsp_fmt_is_inline_ws(c);
}

#[no_mangle]
export function lsp_fmt_src_ws_after(doc: *u8, start: i32, len: i32, j: i32): i32 {
  let k: i32 = j + 1;
  if (k >= len) { return 0; }
  let c: u8 = doc[start + k];
  return lsp_fmt_is_inline_ws(c);
}

#[no_mangle]
export function lsp_fmt_space_before(doc: *u8, start: i32, j: i32, out_buf: *u8, out_len: *i32, out_cap: i32): i32 {
  if (out_buf == 0) { return 0; }
  if (out_len == 0) { return 0; }
  if (lsp_fmt_src_ws_before(doc, start, j) != 0) { return 0; }
  unsafe {
    let olen: i32 = out_len[0];
    let last: u8 = lsp_fmt_last_out(out_buf, olen);
    if (last == 0) { return 0; }
    if (lsp_fmt_is_inline_ws(last) != 0) { return 0; }
    if (olen >= out_cap - 1) { return 0; }
    out_buf[olen] = 32;
    out_len[0] = olen + 1;
    return 1;
  }
  return 0;
}

#[no_mangle]
export function lsp_fmt_space_after(doc: *u8, start: i32, len: i32, j: i32, out_buf: *u8, out_len: *i32, out_cap: i32): i32 {
  if (out_buf == 0) { return 0; }
  if (out_len == 0) { return 0; }
  if (lsp_fmt_src_ws_after(doc, start, len, j) != 0) { return 0; }
  let k: i32 = j + 1;
  while (k < len) {
    let n: u8 = doc[start + k];
    if (lsp_fmt_is_src_ws(n) != 0) { k = k + 1; continue; }
    if (lsp_fmt_is_atom_head(n) != 0) {
      unsafe {
        let olen: i32 = out_len[0];
        if (olen < out_cap - 1) {
          out_buf[olen] = 32;
          out_len[0] = olen + 1;
          return 1;
        }
      }
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
export function lsp_json_escape_ident(s: *u8, esc: *u8, esc_cap: i32): i32 {
  if (s == 0) { return 0; }
  if (esc == 0) { return 0; }
  if (esc_cap < 4) { return 0; }
  let e: i32 = 0;
  let i: i32 = 0;
  while (s[i] != 0) {
    if (e >= esc_cap - 3) { break; }
    let c: u8 = s[i];
    if (c == 34) {
      esc[e] = 92;
      e = e + 1;
      if (e >= esc_cap - 1) { break; }
      esc[e] = c;
      e = e + 1;
    } else if (c == 92) {
      esc[e] = 92;
      e = e + 1;
      if (e >= esc_cap - 1) { break; }
      esc[e] = c;
      e = e + 1;
    } else {
      esc[e] = c;
      e = e + 1;
    }
    i = i + 1;
  }
  esc[e] = 0;
  return e;
}

// ---- f-425: LSP helpers（JSON 解析 + 块注释检测）----

// G-02f-118：标识符列区间匹配（1-based，含首列）
#[no_mangle]
export function col_in_ident_span(line: i32, col: i32, sl: i32, sc: i32, name: *u8): i32 {
  if (name == 0) { return 0; }
  if (sl != line) { return 0; }
  if (sc <= 0) { return 0; }
  let len: i32 = 0;
  while (len < 512) {
    if (name[len] == 0) { break; }
    len = len + 1;
  }
  if (len <= 0) { return 0; }
  if (col < sc) { return 0; }
  if (col >= sc + len) { return 0; }
  return 1;
}

// G-02f-122/255：在 body[0..len) 中从 start 起找 key，返回 key 结束后偏移，未找到 -1
#[no_mangle]
export function lsp_find_key_after(body: *u8, len: i32, start: i32, key: *u8): i32 {
  if (body == 0) { return 0 - 1; }
  if (key == 0) { return 0 - 1; }
  if (len < 0) { return 0 - 1; }
  if (start < 0) { return 0 - 1; }
  let key_len: i32 = 0;
  while (key_len < 256) {
    if (key[key_len] == 0) { break; }
    key_len = key_len + 1;
  }
  if (key_len <= 0) { return 0 - 1; }
  let s: i32 = start;
  while (s + key_len <= len) {
    let is_match: i32 = 1;
    let j: i32 = 0;
    while (j < key_len) {
      if (body[s + j] != key[j]) {
        is_match = 0;
        break;
      }
      j = j + 1;
    }
    if (is_match != 0) {
      return s + key_len;
    }
    s = s + 1;
  }
  return 0 - 1;
}

// G-02f-122：解析 key 对应的布尔值；1=true，0=false，未找到 -1
#[no_mangle]
export function lsp_parse_bool_after(body: *u8, len: i32, start: i32, key: *u8, out_val: *i32): i32 {
  if (out_val == 0) { return 0 - 1; }
  let k: i32 = lsp_find_key_after(body, len, start, key);
  if (k < 0) { return 0 - 1; }
  let lit_true: u8[5] = [116, 114, 117, 101, 0];
  let lit_false: u8[6] = [102, 97, 108, 115, 101, 0];
  if (k + 4 <= len) {
    if (lsp_match_bytes_at(body, k, &lit_true[0], 4) != 0) {
      lsp_store_i32(out_val, 1);
      return 0;
    }
  }
  if (k + 5 <= len) {
    if (lsp_match_bytes_at(body, k, &lit_false[0], 5) != 0) {
      lsp_store_i32(out_val, 0);
      return 0;
    }
  }
  return 0 - 1;
}

// G-02f-118：行 [start, start+len) 内是否出现块注释结束符 */
#[no_mangle]
export function lsp_line_has_block_comment_end(doc: *u8, start: i32, len: i32): i32 {
  let i: i32 = 0;
  while (i + 1 < len) {
    if (doc[start + i] == 42) {
      if (doc[start + i + 1] == 47) { return 1; }
    }
    i = i + 1;
  }
  return 0;
}

// G-02f-122：是否为块注释行（/** 、* 续行，或处于未闭合块注释内）
#[no_mangle]
export function lsp_line_is_block_comment(doc: *u8, content_start: i32, content_len: i32, in_block: i32): i32 {
  if (doc == 0) { return 0; }
  if (content_len >= 2) {
    if (doc[content_start] == 47) {
      if (doc[content_start + 1] == 42) { return 1; }
    }
  }
  if (in_block == 0) { return 0; }
  if (content_len < 1) { return 0; }
  if (doc[content_start] == 42) { return 1; }
  return 0;
}

// ---- f-426: ASTFunc byte-offset helpers + func_name_covers ----
// .x 不支持 C struct 成员访问，用字节偏移读取 ASTFunc 字段：
//   line@+0 (i32) / col@+4 (i32) / name@+8 (*u8)

// G-02f-133：从 *u8 偏移 off 处读取 4 字节小端 i32
export function lsp_load_i32_at(p: *u8, off: i32): i32 {
  let m: i32 = 256;
  let a: i32 = p[off] as i32;
  a = a + (p[off + 1] as i32) * m;
  a = a + (p[off + 2] as i32) * (m * m);
  a = a + (p[off + 3] as i32) * (m * m * m);
  return a;
}

// G-02f-133：从 *u8 偏移 off 处读取 8 字节小端指针
export function lsp_load_ptr_at(p: *u8, off: i32): *u8 {
  if (p == 0) { return 0 as *u8; }
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  let a: usize = p[off] as usize;
  a = a + (p[off + 1] as usize) * m;
  a = a + (p[off + 2] as usize) * m2;
  a = a + (p[off + 3] as usize) * (m2 * m);
  a = a + (p[off + 4] as usize) * m4;
  a = a + (p[off + 5] as usize) * (m4 * m);
  a = a + (p[off + 6] as usize) * (m4 * m2);
  a = a + (p[off + 7] as usize) * (m4 * m2 * m);
  return a as *u8;
}

// G-02f-133：函数名是否覆盖光标（ASTFunc: line@0 col@4 name@+8）
#[no_mangle]
export function func_name_covers(f: *u8, line: i32, col: i32): i32 {
  if (f == 0) { return 0; }
  let name: *u8 = lsp_load_ptr_at(f, 8);
  if (name == 0) { return 0; }
  let sl: i32 = lsp_load_i32_at(f, 0);
  let sc: i32 = lsp_load_i32_at(f, 4);
  return col_in_ident_span(line, col, sl, sc, name);
}

// ---- f-427: lsp_hash_source（usize FNV-like hash）----
// 【Why】shux -E 截断 > 2^32 的整数字面量到 32 位，故 0x9e3779b97f4a7c15 和
//   4294967296 (2^32) 必须从单字节构造。Ubuntu shux -E 不支持 u64 类型（静默跳过
//   含 u64 的函数），改用 usize（64 位平台等价于 uint64_t，已在 lsp_load_ptr_at
//   等函数中验证 -E 正确）。
// 【Invariant】所有中间值 ≤ 256^8 = 2^64，usize 乘法不溢出绕回（mod 2^64 即 C 语义）。
// 【Perf】常量构造在函数入口一次，循环内仅 usize 乘加；final fold 用 / two32
//   （等价 >> 32，但 SHUX .x 未见 >> 用于 usize，除法已验证 -E 正确）。
//   字节序列 LE: 0x15, 0x7c, 0x4a, 0x7f, 0xb9, 0x79, 0x37, 0x9e
#[no_mangle]
export function lsp_hash_source(src: *u8, len: i32): u32 {
  if (src == 0) { return 0 as u32; }
  let b256: usize = 256;
  let b256_2: usize = b256 * b256;
  let b256_3: usize = b256_2 * b256;
  let b256_4: usize = b256_3 * b256;
  let b256_5: usize = b256_4 * b256;
  let b256_6: usize = b256_5 * b256;
  let b256_7: usize = b256_6 * b256;
  let prime: usize = 21;
  prime = prime + 124 * b256;
  prime = prime + 74 * b256_2;
  prime = prime + 127 * b256_3;
  prime = prime + 185 * b256_4;
  prime = prime + 121 * b256_5;
  prime = prime + 55 * b256_6;
  prime = prime + 158 * b256_7;
  let two32: usize = b256_4;
  let h: usize = len as usize;
  let i: i32 = 0;
  while (i + 8 <= len) {
    let x: usize = 0;
    let k: i32 = 0;
    while (k < 8) {
      let b: usize = src[i + k] as usize;
      let shift: usize = 1;
      let s: i32 = 0;
      while (s < k) { shift = shift * 256; s = s + 1; }
      x = x + b * shift;
      k = k + 1;
    }
    h = h * prime + x;
    i = i + 8;
  }
  while (i < len) {
    h = h * prime + (src[i] as usize);
    i = i + 1;
  }
  return (h ^ (h / two32)) as u32;
}
