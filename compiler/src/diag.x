// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-30：真迁 .x — diag_report 无 code 入口薄转发到 with_code。
// G-02f-74：+ remaining diag_* gates.
// G-02f-82：+ diag_get_source / diag_get_source_len / diag_report_with_code 门闩。
// G-02f-96：+ color/kind/code_eq/line_digits 薄 helper 门闩。
// G-02f-97：+ print_header / extract_line / json_write_str / json_severity 门闩。
// G-02f-98：+ diag_levenshtein_ci 门闩。
// 产品：./shux-c -E → seeds/diag.from_x.c（+ C 尾段）。
// C 尾：上下文静态、code 表、JSON/颜色、va_list reportf/vreportf、lookup。
// 注意：va_list 入口仍留 C（语言/ABI 限制）。

extern "C" function diag_report_with_code_impl(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8,
                                          detail: *u8): void;

extern "C" function diag_set_file_impl(path: *u8, source: *u8, source_len: i64): void;
extern "C" function diag_push_file_impl(snapshot: *u8, path: *u8, source: *u8, source_len: i64): void;
extern "C" function diag_restore_impl(snapshot: *u8): void;
extern "C" function diag_print_known_codes_impl(out: *u8): void;
extern "C" function diag_print_code_explain_impl(out: *u8, code: *u8): void;
extern "C" function diag_print_code_table_impl(out: *u8): void;
extern "C" function diag_json_get_state(): i32;
extern "C" function diag_json_set_state(v: i32): void;
extern "C" function diag_ctx_get_use_color(): i32;
extern "C" function diag_ctx_get_file(): *u8;
extern "C" function diag_ctx_get_source(): *u8;
extern "C" function diag_ctx_get_source_len(): i64;
extern "C" function diag_code_table_has(code: *u8): i32;
extern "C" function getenv(name: *u8): *u8;
extern "C" function isatty(fd: i32): i32;
extern "C" function diag_code_eq_impl(lhs: *u8, rhs: *u8): i32;
extern "C" function diag_kind_is_exact_impl(kind: *u8, needle: *u8): i32;
extern "C" function diag_line_digits_impl(line: i32): i32;

extern "C" function diag_print_header_impl(kind: *u8, code: *u8, msg: *u8, kind_color: *u8, reset: *u8): void;
extern "C" function diag_json_write_str_impl(out: *u8, s: *u8): void;

#[no_mangle]
function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    diag_report_with_code_impl(file, line, col, kind, 0 as *u8, msg, detail);
  }
}

/* ---- G-02f-74 / G-02f-82 diag gates ---- */

#[no_mangle]
function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    diag_report_with_code_impl(file, line, col, kind, code, msg, detail);
  }
}

// G-02f-155：上下文 getter 真迁
#[no_mangle]
function diag_get_file(): *u8 {
  unsafe {
    return diag_ctx_get_file();
  }
  return 0 as *u8;
}

#[no_mangle]
function diag_get_source(): *u8 {
  unsafe {
    return diag_ctx_get_source();
  }
  return 0 as *u8;
}

#[no_mangle]
function diag_get_source_len(): i64 {
  unsafe {
    return diag_ctx_get_source_len();
  }
  return 0;
}

#[no_mangle]
function diag_set_file(path: *u8, source: *u8, source_len: i64): void {
  unsafe {
    diag_set_file_impl(path, source, source_len);
  }
}

#[no_mangle]
function diag_push_file(snapshot: *u8, path: *u8, source: *u8, source_len: i64): void {
  unsafe {
    diag_push_file_impl(snapshot, path, source, source_len);
  }
}

#[no_mangle]
function diag_restore(snapshot: *u8): void {
  unsafe {
    diag_restore_impl(snapshot);
  }
}

// G-02f-155：code 表存在性
#[no_mangle]
function diag_code_is_known(code: *u8): i32 {
  unsafe {
    return diag_code_table_has(code);
  }
  return 0;
}

#[no_mangle]
function diag_print_known_codes(out: *u8): void {
  unsafe {
    diag_print_known_codes_impl(out);
  }
}

#[no_mangle]
function diag_print_code_explain(out: *u8, code: *u8): void {
  unsafe {
    diag_print_code_explain_impl(out, code);
  }
}

#[no_mangle]
function diag_print_code_table(out: *u8): void {
  unsafe {
    diag_print_code_table_impl(out);
  }
}

// G-02f-153：JSON 模式与颜色探测
#[no_mangle]
function diag_set_json_mode(enable: i32): void {
  unsafe {
    if (enable != 0) {
      diag_json_set_state(1);
    } else {
      diag_json_set_state(0);
    }
  }
}

#[no_mangle]
function diag_json_enabled(): i32 {
  unsafe {
    let s: i32 = diag_json_get_state();
    // -2 = unset
    if (s == 0 - 2) {
      let k: u8[16] = [];
      // SHUX_DIAG_JSON
      k[0]=83;k[1]=72;k[2]=85;k[3]=88;k[4]=95;k[5]=68;k[6]=73;k[7]=65;k[8]=71;k[9]=95;
      k[10]=74;k[11]=83;k[12]=79;k[13]=78;k[14]=0;
      let e: *u8 = getenv(&k[0]);
      let v: i32 = 0;
      if (e != 0) {
        if (e[0] != 0) {
          if (e[0] != 48) { v = 1; }
        }
      }
      diag_json_set_state(v);
      s = v;
    }
    if (s == 1) { return 1; }
    return 0;
  }
  return 0;
}

/* ---- G-02f-96 / G-02f-153 / G-02f-154：color ---- */

#[no_mangle]
function diag_should_color(): i32 {
  unsafe {
    let k: u8[16] = [];
    // SHUX_NO_COLOR
    k[0]=83;k[1]=72;k[2]=85;k[3]=88;k[4]=95;k[5]=78;k[6]=79;k[7]=95;
    k[8]=67;k[9]=79;k[10]=76;k[11]=79;k[12]=82;k[13]=0;
    if (getenv(&k[0]) != 0) { return 0; }
    // fileno(stderr) — 用 2 as STDERR_FILENO 跨平台简化
    if (isatty(2) != 0) { return 1; }
  }
  return 0;
}

// G-02f-154：use_color ? color : plain
#[no_mangle]
function diag_color_prefix(plain: *u8, color: *u8): *u8 {
  unsafe {
    if (diag_ctx_get_use_color() != 0) {
      return color;
    }
    return plain;
  }
  return plain;
}

// G-02f-154：use_color ? ANSI reset : ""
#[no_mangle]
function diag_color_reset(): *u8 {
  unsafe {
    if (diag_ctx_get_use_color() != 0) {
      // "\x1b[0m"
      return "\x1b[0m";
    }
    return "";
  }
  return "";
}

// G-02f-154：64 位 LE 写指针 / size_t（**out / *size_t 语义）
function diag_store_ptr_le(p: *u8, val: *u8): void {
  if (p == 0) { return; }
  let a: usize = val as usize;
  let m: usize = 256;
  p[0] = (a % m) as u8;
  a = a / m;
  p[1] = (a % m) as u8;
  a = a / m;
  p[2] = (a % m) as u8;
  a = a / m;
  p[3] = (a % m) as u8;
  a = a / m;
  p[4] = (a % m) as u8;
  a = a / m;
  p[5] = (a % m) as u8;
  a = a / m;
  p[6] = (a % m) as u8;
  a = a / m;
  p[7] = (a % m) as u8;
}

function diag_store_usize_le(p: *u8, val: usize): void {
  if (p == 0) { return; }
  let a: usize = val;
  let m: usize = 256;
  p[0] = (a % m) as u8;
  a = a / m;
  p[1] = (a % m) as u8;
  a = a / m;
  p[2] = (a % m) as u8;
  a = a / m;
  p[3] = (a % m) as u8;
  a = a / m;
  p[4] = (a % m) as u8;
  a = a / m;
  p[5] = (a % m) as u8;
  a = a / m;
  p[6] = (a % m) as u8;
  a = a / m;
  p[7] = (a % m) as u8;
}

/* ---- G-02f-97 / G-02f-154：print_header / extract_line / json ---- */

#[no_mangle]
function diag_print_header(kind: *u8, code: *u8, msg: *u8, kind_color: *u8, reset: *u8): void {
  unsafe {
    diag_print_header_impl(kind, code, msg, kind_color, reset);
  }
}

// G-02f-154：按行号从 diag 源缓冲取一行
#[no_mangle]
function diag_extract_line(line_no: i32, line_start_out: *u8, line_len_out: *u8): i32 {
  if (line_no <= 0) { return 0 - 1; }
  if (line_start_out == 0) { return 0 - 1; }
  if (line_len_out == 0) { return 0 - 1; }
  unsafe {
    let src: *u8 = diag_ctx_get_source();
    let len64: i64 = diag_ctx_get_source_len();
    if (src == 0) { return 0 - 1; }
    if (len64 <= 0) { return 0 - 1; }
    let len: i32 = len64 as i32;
    if (len64 > 2147483647) { len = 2147483647; }
    let line: i32 = 1;
    let i: i32 = 0;
    let start: i32 = 0;
    while (i < len) {
      if (line == line_no) { break; }
      if (src[i] == 10) {
        line = line + 1;
        start = i + 1;
      }
      i = i + 1;
    }
    if (line != line_no) { return 0 - 1; }
    while (i < len) {
      let c: u8 = src[i];
      if (c == 10) { break; }
      if (c == 13) { break; }
      i = i + 1;
    }
    // src + start via byte walk
    let p: *u8 = src;
    let k: i32 = 0;
    while (k < start) {
      p = p + 1;
      k = k + 1;
    }
    diag_store_ptr_le(line_start_out, p);
    let ln: usize = (i - start) as usize;
    diag_store_usize_le(line_len_out, ln);
    return 0;
  }
  return 0 - 1;
}

#[no_mangle]
function diag_json_write_str(out: *u8, s: *u8): void {
  unsafe {
    diag_json_write_str_impl(out, s);
  }
}



/* ---- G-02f-98 / G-02f-152：levenshtein 真迁 ---- */

// G-02f-152：有界 Levenshtein（大小写不敏感）；码长 <64
#[no_mangle]
function diag_levenshtein_ci(a: *u8, b: *u8): i32 {
  if (a == 0) { return 999; }
  if (b == 0) { return 999; }
  let la: i32 = 0;
  while (la < 64) {
    if (a[la] == 0) { break; }
    la = la + 1;
  }
  let lb: i32 = 0;
  while (lb < 64) {
    if (b[lb] == 0) { break; }
    lb = lb + 1;
  }
  if (la >= 64) { return 999; }
  if (lb >= 64) { return 999; }
  if (la == 0) { return lb; }
  if (lb == 0) { return la; }
  let prev: i32[64] = [];
  let cur: i32[64] = [];
  let j: i32 = 0;
  while (j <= lb) {
    prev[j] = j;
    j = j + 1;
  }
  let i: i32 = 1;
  while (i <= la) {
    cur[0] = i;
    j = 1;
    while (j <= lb) {
      let ca: u8 = a[i - 1];
      let cb: u8 = b[j - 1];
      // to upper: a-z 97-122
      if (ca >= 97) {
        if (ca <= 122) { ca = ca - 32; }
      }
      if (cb >= 97) {
        if (cb <= 122) { cb = cb - 32; }
      }
      let cost: i32 = 1;
      if (ca == cb) { cost = 0; }
      let del: i32 = prev[j] + 1;
      let ins: i32 = cur[j - 1] + 1;
      let sub: i32 = prev[j - 1] + cost;
      let m: i32 = del;
      if (ins < m) { m = ins; }
      if (sub < m) { m = sub; }
      cur[j] = m;
      j = j + 1;
    }
    j = 0;
    while (j <= lb) {
      prev[j] = cur[j];
      j = j + 1;
    }
    i = i + 1;
  }
  return prev[lb];
}

// G-02f-109：+ diag_report_json 薄门闩。

extern "C" function diag_report_json_impl(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8): void;

/* ---- G-02f-109：diag JSON report 门闩 ---- */

#[no_mangle]
function diag_report_json(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8): void {
  unsafe { diag_report_json_impl(file, line, col, kind, code, msg); }
}

// G-02f-116：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

// G-02f-130：diag_kind_contains 真迁 .x（子串探测）
#[no_mangle]
function diag_kind_contains(kind: *u8, needle: *u8): i32 {
  if (kind == 0) { return 0; }
  if (needle == 0) { return 0; }
  if (needle[0] == 0) { return 0; }
  let nlen: i32 = 0;
  while (nlen < 4096) {
    if (needle[nlen] == 0) { break; }
    nlen = nlen + 1;
  }
  if (nlen <= 0) { return 0; }
  let klen: i32 = 0;
  while (klen < 4096) {
    if (kind[klen] == 0) { break; }
    klen = klen + 1;
  }
  if (klen < nlen) { return 0; }
  let s: i32 = 0;
  while (s + nlen <= klen) {
    let j: i32 = 0;
    let ok: i32 = 1;
    while (j < nlen) {
      if (kind[s + j] != needle[j]) { ok = 0; break; }
      j = j + 1;
    }
    if (ok != 0) { return 1; }
    s = s + 1;
  }
  return 0;
}

#[no_mangle]
function diag_line_digits(line: i32): i32 {
  let width: i32 = 1;
  while (line >= 10) {
    line = line / 10;
    width = width + 1;
  }
  return width;
}

#[no_mangle]
function diag_kind_is_exact(kind: *u8, needle: *u8): i32 {
  if (kind == 0) { return 0; }
  if (needle == 0) { return 0; }
  let i: i32 = 0;
  while (i < 4096) {
    let a: u8 = kind[i];
    let b: u8 = needle[i];
    if (a != b) { return 0; }
    if (a == 0) { return 1; }
    i = i + 1;
  }
  return 0;
}

// Case-insensitive code equality (ASCII a-z).
#[no_mangle]
function diag_code_eq(lhs: *u8, rhs: *u8): i32 {
  if (lhs == 0) { return 0; }
  if (rhs == 0) { return 0; }
  let i: i32 = 0;
  while (i < 4096) {
    let a: u8 = lhs[i];
    let b: u8 = rhs[i];
    if (a >= 97) {
      if (a <= 122) { a = a - 32; }
    }
    if (b >= 97) {
      if (b <= 122) { b = b - 32; }
    }
    if (a != b) { return 0; }
    if (a == 0) { return 1; }
    i = i + 1;
  }
  return 0;
}

// G-02f-124：diag_json_severity 真迁 .x

#[no_mangle]
function diag_json_severity(kind: *u8): *u8 {
  if (kind == 0) { return "error"; }
  if (kind[0] == 0) { return "error"; }
  // contains "warning"
  let i: i32 = 0;
  while (i < 256) {
    if (kind[i] == 0) { break; }
    if (kind[i]==119 && kind[i+1]==97 && kind[i+2]==114 && kind[i+3]==110 && kind[i+4]==105 && kind[i+5]==110 && kind[i+6]==103) {
      return "warning";
    }
    i = i + 1;
  }
  // exact info
  if (kind[0]==105 && kind[1]==110 && kind[2]==102 && kind[3]==111 && kind[4]==0) { return "info"; }
  if (kind[0]==110 && kind[1]==111 && kind[2]==116 && kind[3]==101 && kind[4]==0) { return "note"; }
  if (kind[0]==104 && kind[1]==101 && kind[2]==108 && kind[3]==112 && kind[4]==0) { return "help"; }
  if (kind[0]==104 && kind[1]==105 && kind[2]==110 && kind[3]==116 && kind[4]==0) { return "help"; }
  return "error";
}

