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
// C 尾：g_diag 上下文静态、g_diag_code_table 数据、stdio 桥、va_list reportf/vreportf。
// G-02f-181：P0-1 闭合登记；code 表+reportf 仍属语言/ABI 限制，当前总进度见 analysis/自举进度.md。
// 注意：va_list 入口仍留 C（语言/ABI 限制）。

export extern "C" function diag_json_get_state(): i32;
export extern "C" function diag_json_set_state(v: i32): void;
export extern "C" function diag_ctx_get_use_color(): i32;
export extern "C" function diag_ctx_get_file(): *u8;
export extern "C" function diag_ctx_get_source(): *u8;
export extern "C" function diag_ctx_get_source_len(): i64;
export extern "C" function diag_ctx_set_all(path: *u8, source: *u8, source_len: i64, use_color: i32): void;
export extern "C" function diag_code_table_has(code: *u8): i32;
export extern "C" function diag_code_table_len(): i64;
export extern "C" function diag_code_table_code_at(i: i64): *u8;
export extern "C" function diag_code_table_kind_at(i: i64): *u8;
export extern "C" function diag_code_table_summary_at(i: i64): *u8;
export extern "C" function diag_code_table_details_at(i: i64): *u8;
export extern "C" function diag_entry_code(code: *u8): *u8;
export extern "C" function diag_entry_kind(code: *u8): *u8;
export extern "C" function diag_entry_summary(code: *u8): *u8;
export extern "C" function diag_entry_details(code: *u8): *u8;
export extern "C" function getenv(name: *u8): *u8;
export extern "C" function isatty(fd: i32): i32;
export extern "C" function diag_code_eq_impl(lhs: *u8, rhs: *u8): i32;
export extern "C" function diag_kind_is_exact_impl(kind: *u8, needle: *u8): i32;
export extern "C" function diag_line_digits_impl(line: i32): i32;

// G-02f-156 / G-02f-157：stdio 冷路径桥
export extern "C" function diag_stderr(): *u8;
export extern "C" function diag_stdout(): *u8;
export extern "C" function diag_io_fputc(o: *u8, c: i32): i32;
export extern "C" function diag_io_fputs(s: *u8, o: *u8): i32;
export extern "C" function diag_io_fputs_u04x(o: *u8, c: i32): void;
export extern "C" function diag_io_fflush(o: *u8): void;
export extern "C" function diag_io_fprint_line_col(o: *u8, line: i32, col: i32): void;
export extern "C" function diag_io_fprint_unknown_code(o: *u8, code: *u8): void;
export extern "C" function diag_io_fprint_code_table_hdr(o: *u8): void;
export extern "C" function diag_io_fprint_code_table_row(o: *u8, code: *u8, kind: *u8, summary: *u8): void;
export extern "C" function diag_io_fprint_loc_file_line_col(o: *u8, pc: *u8, file: *u8, line: i32, col: i32, rs: *u8): void;
export extern "C" function diag_io_fprint_loc_file_line(o: *u8, pc: *u8, file: *u8, line: i32, rs: *u8): void;
export extern "C" function diag_io_fprint_loc_file(o: *u8, pc: *u8, file: *u8, rs: *u8): void;
export extern "C" function diag_io_fprint_loc_line_col(o: *u8, pc: *u8, line: i32, col: i32, rs: *u8): void;
export extern "C" function diag_io_fprint_gutter_blank(o: *u8, width: i32): void;
export extern "C" function diag_io_fprint_src_line(o: *u8, line: i32, start: *u8, len: i32): void;
export extern "C" function diag_io_fprint_gutter_bar(o: *u8, width: i32): void;
export extern "C" function diag_io_fprint_caret_mark(o: *u8, cc: *u8, rs: *u8, detail: *u8): void;

// G-02f-159：palette 颜色（use_color 经 color_prefix）
export function diag_palette_kind_color(kind: *u8): *u8 {
  unsafe {
    if (kind == 0) { return diag_color_prefix("", "\x1b[1;37m"); }
    if (kind[0] == 0) { return diag_color_prefix("", "\x1b[1;37m"); }
    if (diag_kind_contains(kind, "error") != 0) { return diag_color_prefix("", "\x1b[1;31m"); }
    if (diag_kind_contains(kind, "warning") != 0) { return diag_color_prefix("", "\x1b[1;33m"); }
    if (diag_kind_is_exact(kind, "info") != 0) { return diag_color_prefix("", "\x1b[1;36m"); }
    if (diag_kind_is_exact(kind, "note") != 0) { return diag_color_prefix("", "\x1b[1;34m"); }
    if (diag_kind_is_exact(kind, "help") != 0) { return diag_color_prefix("", "\x1b[1;32m"); }
    if (diag_kind_is_exact(kind, "hint") != 0) { return diag_color_prefix("", "\x1b[1;32m"); }
    return diag_color_prefix("", "\x1b[1;37m");
  }
  return "";
}

export function diag_palette_caret_color(kind: *u8): *u8 {
  unsafe {
    if (kind == 0) { return diag_color_prefix("", "\x1b[37m"); }
    if (kind[0] == 0) { return diag_color_prefix("", "\x1b[37m"); }
    if (diag_kind_contains(kind, "error") != 0) { return diag_color_prefix("", "\x1b[31m"); }
    if (diag_kind_contains(kind, "warning") != 0) { return diag_color_prefix("", "\x1b[33m"); }
    if (diag_kind_is_exact(kind, "info") != 0) { return diag_color_prefix("", "\x1b[36m"); }
    if (diag_kind_is_exact(kind, "note") != 0) { return diag_color_prefix("", "\x1b[34m"); }
    if (diag_kind_is_exact(kind, "help") != 0) { return diag_color_prefix("", "\x1b[32m"); }
    if (diag_kind_is_exact(kind, "hint") != 0) { return diag_color_prefix("", "\x1b[32m"); }
    return diag_color_prefix("", "\x1b[37m");
  }
  return "";
}

// G-02f-159：人类可读 caret / 位置渲染
#[no_mangle]
export function diag_report_human(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    let err: *u8 = diag_stderr();
    let actual_file: *u8 = file;
    if (actual_file == 0) { actual_file = diag_ctx_get_file(); }
    let kind_color: *u8 = diag_palette_kind_color(kind);
    let path_color: *u8 = diag_color_prefix("", "\x1b[34m");
    let caret_color: *u8 = diag_palette_caret_color(kind);
    let reset: *u8 = diag_color_reset();
    let line_start_slot: u8[8] = [];
    let line_len_slot: u8[8] = [];
    let have_line: i32 = 0;
    if (line > 0) {
      if (diag_extract_line(line, &line_start_slot[0], &line_len_slot[0]) == 0) {
        have_line = 1;
      }
    }
    diag_print_header(kind, code, msg, kind_color, reset);
    if (actual_file != 0) {
      if (line > 0) {
        if (col > 0) {
          diag_io_fprint_loc_file_line_col(err, path_color, actual_file, line, col, reset);
        } else {
          diag_io_fprint_loc_file_line(err, path_color, actual_file, line, reset);
        }
      } else {
        diag_io_fprint_loc_file(err, path_color, actual_file, reset);
      }
    } else {
      if (line > 0) {
        if (col > 0) {
          diag_io_fprint_loc_line_col(err, path_color, line, col, reset);
        }
      }
    }
    if (have_line == 0) {
      diag_io_fflush(err);
      return;
    }
    if (line <= 0) {
      diag_io_fflush(err);
      return;
    }
    if (col <= 0) {
      diag_io_fflush(err);
      return;
    }
    let line_start: *u8 = diag_snap_load_ptr(&line_start_slot[0], 0);
    let line_len_u: usize = diag_snap_load_usize(&line_len_slot[0], 0);
    let line_len: i32 = line_len_u as i32;
    let width: i32 = diag_line_digits(line);
    diag_io_fprint_gutter_blank(err, width);
    diag_io_fprint_src_line(err, line, line_start, line_len);
    diag_io_fprint_gutter_bar(err, width);
    let caret_col: i32 = 0;
    if (col > 1) { caret_col = col - 1; }
    let i: i32 = 0;
    while (i < caret_col) {
      if (i < line_len) {
        if (line_start != 0) {
          if (line_start[i] == 9) {
            diag_io_fputc(9, err);
          } else {
            diag_io_fputc(32, err);
          }
        } else {
          diag_io_fputc(32, err);
        }
      } else {
        diag_io_fputc(32, err);
      }
      i = i + 1;
    }
    diag_io_fprint_caret_mark(err, caret_color, reset, detail);
    diag_io_fflush(err);
  }
}

// G-02f-158 / G-02f-159：report 分流 JSON / human
#[no_mangle]
export function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void {
  diag_report_with_code(file, line, col, kind, 0 as *u8, msg, detail);
}

/* ---- G-02f-74 / G-02f-82 / G-02f-158 / G-02f-159 diag gates ---- */

#[no_mangle]
export function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void {
  unsafe {
    if (diag_json_enabled() != 0) {
      let f: *u8 = file;
      if (f == 0) { f = diag_ctx_get_file(); }
      diag_report_json(f, line, col, kind, code, msg);
      return;
    }
    diag_report_human(file, line, col, kind, code, msg, detail);
  }
}

// G-02f-155：上下文 getter 真迁
#[no_mangle]
export function diag_get_file(): *u8 {
  unsafe {
    return diag_ctx_get_file();
  }
  return 0 as *u8;
}

#[no_mangle]
export function diag_get_source(): *u8 {
  unsafe {
    return diag_ctx_get_source();
  }
  return 0 as *u8;
}

#[no_mangle]
export function diag_get_source_len(): i64 {
  unsafe {
    return diag_ctx_get_source_len();
  }
  return 0;
}

// G-02f-156：set_file / push_file / restore 真迁
#[no_mangle]
export function diag_set_file(path: *u8, source: *u8, source_len: i64): void {
  let c: i32 = diag_should_color();
  unsafe {
    diag_ctx_set_all(path, source, source_len, c);
  }
}

// DiagContextSnapshot：file_path@0 source@8 source_len@16 use_color@24
export function diag_snap_store_ptr(snap: *u8, off: i32, val: *u8): void {
  if (snap == 0) { return; }
  let q: *u8 = snap;
  let i: i32 = 0;
  while (i < off) {
    q = q + 1;
    i = i + 1;
  }
  diag_store_ptr_le(q, val);
}

export function diag_snap_store_usize(snap: *u8, off: i32, val: usize): void {
  if (snap == 0) { return; }
  let q: *u8 = snap;
  let i: i32 = 0;
  while (i < off) {
    q = q + 1;
    i = i + 1;
  }
  diag_store_usize_le(q, val);
}

export function diag_snap_store_i32(snap: *u8, off: i32, val: i32): void {
  if (snap == 0) { return; }
  let q: *u8 = snap;
  let i: i32 = 0;
  while (i < off) {
    q = q + 1;
    i = i + 1;
  }
  let a: i32 = val;
  let m: i32 = 256;
  if (a < 0) { a = 0; }
  q[0] = (a % m) as u8;
  a = a / m;
  q[1] = (a % m) as u8;
  a = a / m;
  q[2] = (a % m) as u8;
  a = a / m;
  q[3] = (a % m) as u8;
}

export function diag_snap_load_ptr(snap: *u8, off: i32): *u8 {
  if (snap == 0) { return 0 as *u8; }
  let q: *u8 = snap;
  let i: i32 = 0;
  while (i < off) {
    q = q + 1;
    i = i + 1;
  }
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  let a: usize = q[0] as usize;
  a = a + (q[1] as usize) * m;
  a = a + (q[2] as usize) * m2;
  a = a + (q[3] as usize) * (m2 * m);
  a = a + (q[4] as usize) * m4;
  a = a + (q[5] as usize) * (m4 * m);
  a = a + (q[6] as usize) * (m4 * m2);
  a = a + (q[7] as usize) * (m4 * m2 * m);
  return a as *u8;
}

export function diag_snap_load_usize(snap: *u8, off: i32): usize {
  if (snap == 0) { return 0; }
  let q: *u8 = snap;
  let i: i32 = 0;
  while (i < off) {
    q = q + 1;
    i = i + 1;
  }
  let m: usize = 256;
  let m2: usize = m * m;
  let m4: usize = m2 * m2;
  let a: usize = q[0] as usize;
  a = a + (q[1] as usize) * m;
  a = a + (q[2] as usize) * m2;
  a = a + (q[3] as usize) * (m2 * m);
  a = a + (q[4] as usize) * m4;
  a = a + (q[5] as usize) * (m4 * m);
  a = a + (q[6] as usize) * (m4 * m2);
  a = a + (q[7] as usize) * (m4 * m2 * m);
  return a;
}

export function diag_snap_load_i32(snap: *u8, off: i32): i32 {
  if (snap == 0) { return 0; }
  let q: *u8 = snap;
  let i: i32 = 0;
  while (i < off) {
    q = q + 1;
    i = i + 1;
  }
  let m: i32 = 256;
  let a: i32 = q[0] as i32;
  a = a + (q[1] as i32) * m;
  a = a + (q[2] as i32) * m * m;
  a = a + (q[3] as i32) * m * m * m;
  return a;
}

#[no_mangle]
export function diag_push_file(snapshot: *u8, path: *u8, source: *u8, source_len: i64): void {
  unsafe {
    if (snapshot != 0) {
      diag_snap_store_ptr(snapshot, 0, diag_ctx_get_file());
      diag_snap_store_ptr(snapshot, 8, diag_ctx_get_source());
      let sl0: i64 = diag_ctx_get_source_len();
      diag_snap_store_usize(snapshot, 16, sl0 as usize);
      diag_snap_store_i32(snapshot, 24, diag_ctx_get_use_color());
    }
    let p: *u8 = path;
    if (p == 0) { p = diag_ctx_get_file(); }
    let s: *u8 = source;
    let sl: i64 = source_len;
    if (s == 0) {
      s = diag_ctx_get_source();
      sl = diag_ctx_get_source_len();
    }
    let c: i32 = diag_should_color();
    diag_ctx_set_all(p, s, sl, c);
  }
}

#[no_mangle]
export function diag_restore(snapshot: *u8): void {
  if (snapshot == 0) { return; }
  unsafe {
    let p: *u8 = diag_snap_load_ptr(snapshot, 0);
    let s: *u8 = diag_snap_load_ptr(snapshot, 8);
    let sl: usize = diag_snap_load_usize(snapshot, 16);
    let c: i32 = diag_snap_load_i32(snapshot, 24);
    diag_ctx_set_all(p, s, sl as i64, c);
  }
}

// G-02f-155 / G-02f-157：code 表
#[no_mangle]
export function diag_code_is_known(code: *u8): i32 {
  unsafe {
    return diag_code_table_has(code);
  }
  return 0;
}

#[no_mangle]
export function diag_code_kind(code: *u8): *u8 {
  unsafe {
    return diag_entry_kind(code);
  }
  return 0 as *u8;
}

#[no_mangle]
export function diag_code_summary(code: *u8): *u8 {
  unsafe {
    return diag_entry_summary(code);
  }
  return 0 as *u8;
}

#[no_mangle]
export function diag_code_details(code: *u8): *u8 {
  unsafe {
    return diag_entry_details(code);
  }
  return 0 as *u8;
}

// G-02f-157：已知码列表（comma 分隔）
#[no_mangle]
export function diag_print_known_codes(out: *u8): void {
  unsafe {
    let o: *u8 = out;
    if (o == 0) { o = diag_stdout(); }
    let n: i64 = diag_code_table_len();
    let i: i64 = 0;
    while (i < n) {
      let c: *u8 = diag_code_table_code_at(i);
      if (i != 0) {
        diag_io_fputs(", ", o);
      }
      if (c != 0) {
        diag_io_fputs(c, o);
      }
      i = i + 1;
    }
    diag_io_fputc(10, o);
  }
}

// G-02f-157：单码解释 / 未知时列已知码
#[no_mangle]
export function diag_print_code_explain(out: *u8, code: *u8): void {
  unsafe {
    let o: *u8 = out;
    if (o == 0) { o = diag_stdout(); }
    let ec: *u8 = diag_entry_code(code);
    if (ec == 0) {
      diag_io_fprint_unknown_code(o, code);
      diag_io_fputs("Known codes: ", o);
      diag_print_known_codes(o);
      return;
    }
    diag_io_fputs(ec, o);
    diag_io_fputc(10, o);
    diag_io_fputs("Kind: ", o);
    let k: *u8 = diag_entry_kind(code);
    if (k != 0) { diag_io_fputs(k, o); }
    diag_io_fputc(10, o);
    diag_io_fputs("Summary: ", o);
    let s: *u8 = diag_entry_summary(code);
    if (s != 0) { diag_io_fputs(s, o); }
    diag_io_fputc(10, o);
    diag_io_fputs("Details: ", o);
    let d: *u8 = diag_entry_details(code);
    if (d != 0) { diag_io_fputs(d, o); }
    diag_io_fputc(10, o);
  }
}

// G-02f-157：完整 code 表
#[no_mangle]
export function diag_print_code_table(out: *u8): void {
  unsafe {
    let o: *u8 = out;
    if (o == 0) { o = diag_stdout(); }
    diag_io_fprint_code_table_hdr(o);
    let n: i64 = diag_code_table_len();
    let i: i64 = 0;
    while (i < n) {
      let c: *u8 = diag_code_table_code_at(i);
      let k: *u8 = diag_code_table_kind_at(i);
      let s: *u8 = diag_code_table_summary_at(i);
      diag_io_fprint_code_table_row(o, c, k, s);
      i = i + 1;
    }
  }
}

// G-02f-153：JSON 模式与颜色探测
#[no_mangle]
export function diag_set_json_mode(enable: i32): void {
  unsafe {
    if (enable != 0) {
      diag_json_set_state(1);
    } else {
      diag_json_set_state(0);
    }
  }
}

#[no_mangle]
export function diag_json_enabled(): i32 {
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
export function diag_should_color(): i32 {
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
export function diag_color_prefix(plain: *u8, color: *u8): *u8 {
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
export function diag_color_reset(): *u8 {
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
export function diag_store_ptr_le(p: *u8, val: *u8): void {
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

export function diag_store_usize_le(p: *u8, val: usize): void {
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

/* ---- G-02f-97 / G-02f-154 / G-02f-156：print_header / extract_line / json ---- */

// G-02f-156：print_header 真迁（fputs 组合，避免 varargs）
#[no_mangle]
export function diag_print_header(kind: *u8, code: *u8, msg: *u8, kind_color: *u8, reset: *u8): void {
  unsafe {
    let err: *u8 = diag_stderr();
    let m: *u8 = msg;
    if (m == 0) { m = ""; }
    let k: *u8 = kind;
    if (k == 0) { k = ""; }
    let kc: *u8 = kind_color;
    if (kc == 0) { kc = ""; }
    let rs: *u8 = reset;
    if (rs == 0) { rs = ""; }
    if (k[0] == 0) {
      diag_io_fputs(m, err);
      diag_io_fputc(10, err);
      return;
    }
    diag_io_fputs(kc, err);
    diag_io_fputs(k, err);
    if (code != 0) {
      if (code[0] != 0) {
        diag_io_fputc(91, err);
        diag_io_fputs(code, err);
        diag_io_fputc(93, err);
      }
    }
    diag_io_fputs(rs, err);
    diag_io_fputs(": ", err);
    diag_io_fputs(m, err);
    diag_io_fputc(10, err);
  }
}

// G-02f-154：按行号从 diag 源缓冲取一行
#[no_mangle]
export function diag_extract_line(line_no: i32, line_start_out: *u8, line_len_out: *u8): i32 {
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

// G-02f-156：JSON 字符串转义写出
#[no_mangle]
export function diag_json_write_str(out: *u8, s: *u8): void {
  unsafe {
    let p: *u8 = s;
    if (p == 0) { p = ""; }
    diag_io_fputc(34, out);
    let i: i32 = 0;
    while (i < 1048576) {
      let c: u8 = p[i];
      if (c == 0) { break; }
      if (c == 34) {
        diag_io_fputs("\\\"", out);
      } else {
        if (c == 92) {
          diag_io_fputs("\\\\", out);
        } else {
          if (c == 8) {
            diag_io_fputs("\\b", out);
          } else {
            if (c == 12) {
              diag_io_fputs("\\f", out);
            } else {
              if (c == 10) {
                diag_io_fputs("\\n", out);
              } else {
                if (c == 13) {
                  diag_io_fputs("\\r", out);
                } else {
                  if (c == 9) {
                    diag_io_fputs("\\t", out);
                  } else {
                    if (c < 32) {
                      diag_io_fputs_u04x(out, c as i32);
                    } else {
                      diag_io_fputc(c as i32, out);
                    }
                  }
                }
              }
            }
          }
        }
      }
      i = i + 1;
    }
    diag_io_fputc(34, out);
  }
}

// G-02f-156：NDJSON 一行诊断
#[no_mangle]
export function diag_report_json(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8): void {
  unsafe {
    let err: *u8 = diag_stderr();
    let sev: *u8 = diag_json_severity(kind);
    diag_io_fputs("{\"severity\":", err);
    diag_json_write_str(err, sev);
    diag_io_fputs(",\"code\":", err);
    if (code != 0) {
      if (code[0] != 0) {
        diag_json_write_str(err, code);
      } else {
        diag_io_fputs("null", err);
      }
    } else {
      diag_io_fputs("null", err);
    }
    diag_io_fputs(",\"file\":", err);
    if (file != 0) {
      if (file[0] != 0) {
        diag_json_write_str(err, file);
      } else {
        diag_io_fputs("null", err);
      }
    } else {
      diag_io_fputs("null", err);
    }
    diag_io_fprint_line_col(err, line, col);
    let m: *u8 = msg;
    if (m == 0) { m = ""; }
    diag_json_write_str(err, m);
    diag_io_fputs("}\n", err);
    diag_io_fflush(err);
  }
}

/* ---- G-02f-98 / G-02f-152：levenshtein 真迁 ---- */

// G-02f-158：did-you-mean 建议码
#[no_mangle]
export function diag_code_suggest(code: *u8, out: *u8, out_cap: i64): *u8 {
  if (code == 0) { return 0 as *u8; }
  unsafe {
    let n: i64 = diag_code_table_len();
    if (n <= 0) { return 0 as *u8; }
    let code_len: i32 = 0;
    while (code_len < 256) {
      if (code[code_len] == 0) { break; }
      code_len = code_len + 1;
    }
    if (code_len <= 0) { return 0 as *u8; }
    let best_dist: i32 = 999;
    let best: *u8 = 0 as *u8;
    let i: i64 = 0;
    while (i < n) {
      let cand: *u8 = diag_code_table_code_at(i);
      if (cand != 0) {
        let d: i32 = diag_levenshtein_ci(code, cand);
        if (d < best_dist) {
          best_dist = d;
          best = cand;
        }
      }
      i = i + 1;
    }
    if (best == 0) { return 0 as *u8; }
    if (best_dist > 3) { return 0 as *u8; }
    if (best_dist > code_len + 1) { return 0 as *u8; }
    if (out != 0) {
      if (out_cap > 0) {
        let lim: i64 = out_cap - 1;
        let j: i64 = 0;
        while (j < lim) {
          let ch: u8 = best[j as i32];
          if (ch == 0) { break; }
          out[j as i32] = ch;
          j = j + 1;
        }
        out[j as i32] = 0;
        return out;
      }
    }
    return best;
  }
  return 0 as *u8;
}

// G-02f-152：有界 Levenshtein（大小写不敏感）；码长 <64
#[no_mangle]
export function diag_levenshtein_ci(a: *u8, b: *u8): i32 {
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

// G-02f-116 / G-02f-156：以下 helper 真迁 .x 函数体（产品 seed 同步折叠 _impl）

// G-02f-130：diag_kind_contains 真迁 .x（子串探测）
#[no_mangle]
export function diag_kind_contains(kind: *u8, needle: *u8): i32 {
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
export function diag_line_digits(line: i32): i32 {
  let width: i32 = 1;
  while (line >= 10) {
    line = line / 10;
    width = width + 1;
  }
  return width;
}

#[no_mangle]
export function diag_kind_is_exact(kind: *u8, needle: *u8): i32 {
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
export function diag_code_eq(lhs: *u8, rhs: *u8): i32 {
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
export function diag_json_severity(kind: *u8): *u8 {
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
