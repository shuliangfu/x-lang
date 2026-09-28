// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Runtime parse diagnostics helpers (G.9 English; body is authoritative).
// w846: runtime_report_precise_parse_failure_if_known lives only in this
// file. Its C twin and the PRECISE_BRIDGE wrapper were deleted from
// seeds/rt_parse_diag.from_x.c.
// w860: labi_rt_parse_diag_slice_marker lives here too. It returns 1.
// w1494 (终局待办 5.4): runtime_report_parse_recovery_diagnostics and its
// rt_rec_* scanner live here too; seeds/rt_parse_diag.from_x.c is deleted.
// The product installer pure-asm's this file only. There is no seed or
// host cc, and XLANG_G05_PREFER_X_O is ignored.
// Windows takes the same path. Do not gcc -E this TU. Do not pass
// XLANG_RT_PARSE_DIAG_PRECISE_BRIDGE. Product PREFER_X_O temps must not
// replace this .o.
// PLATFORM: SHARED.

export extern "C" function parser_diag_fail_at_token_kind_buf(data: *u8, len: i32): i32;
export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

/* See signature and body for contracts. */
export const RT_PARSE_TOKEN_STRING: i32 = 130;

/* See signature and body for contracts. */
#[no_mangle]
export function runtime_report_precise_parse_failure_if_known(
  input_path: *u8, src: *u8, src_len: usize): i32 {
  let fail_tok: i32 = 0;
  let n: i32 = 0;
  let kind: u8[16] = [];
  let code: u8[8] = [];
  let msg: u8[140] = [];
  if (src == 0 as *u8) {
    return 0;
  }
  if (src_len == 0 as usize) {
    return 0;
  }
  /* See signature and body for contracts. */
  n = src_len as i32;
  if (n <= 0) {
    return 0;
  }
  unsafe {
    fail_tok = parser_diag_fail_at_token_kind_buf(src, n);
  }
  if (fail_tok != RT_PARSE_TOKEN_STRING) {
    return 0;
  }
  /* "parse error" */
  kind[0] = 112;
  kind[1] = 97;
  kind[2] = 114;
  kind[3] = 115;
  kind[4] = 101;
  kind[5] = 32;
  kind[6] = 101;
  kind[7] = 114;
  kind[8] = 114;
  kind[9] = 111;
  kind[10] = 114;
  kind[11] = 0;
  /* "P001" */
  code[0] = 80;
  code[1] = 48;
  code[2] = 48;
  code[3] = 49;
  code[4] = 0;
  /* expected integer literal, float literal, identifier, 'true', 'false', 'if',
     'break', 'continue', 'return', 'panic', 'match', or '(' */
  msg[0] = 101;
  msg[1] = 120;
  msg[2] = 112;
  msg[3] = 101;
  msg[4] = 99;
  msg[5] = 116;
  msg[6] = 101;
  msg[7] = 100;
  msg[8] = 32;
  msg[9] = 105;
  msg[10] = 110;
  msg[11] = 116;
  msg[12] = 101;
  msg[13] = 103;
  msg[14] = 101;
  msg[15] = 114;
  msg[16] = 32;
  msg[17] = 108;
  msg[18] = 105;
  msg[19] = 116;
  msg[20] = 101;
  msg[21] = 114;
  msg[22] = 97;
  msg[23] = 108;
  msg[24] = 44;
  msg[25] = 32;
  msg[26] = 102;
  msg[27] = 108;
  msg[28] = 111;
  msg[29] = 97;
  msg[30] = 116;
  msg[31] = 32;
  msg[32] = 108;
  msg[33] = 105;
  msg[34] = 116;
  msg[35] = 101;
  msg[36] = 114;
  msg[37] = 97;
  msg[38] = 108;
  msg[39] = 44;
  msg[40] = 32;
  msg[41] = 105;
  msg[42] = 100;
  msg[43] = 101;
  msg[44] = 110;
  msg[45] = 116;
  msg[46] = 105;
  msg[47] = 102;
  msg[48] = 105;
  msg[49] = 101;
  msg[50] = 114;
  msg[51] = 44;
  msg[52] = 32;
  msg[53] = 39;
  msg[54] = 116;
  msg[55] = 114;
  msg[56] = 117;
  msg[57] = 101;
  msg[58] = 39;
  msg[59] = 44;
  msg[60] = 32;
  msg[61] = 39;
  msg[62] = 102;
  msg[63] = 97;
  msg[64] = 108;
  msg[65] = 115;
  msg[66] = 101;
  msg[67] = 39;
  msg[68] = 44;
  msg[69] = 32;
  msg[70] = 39;
  msg[71] = 105;
  msg[72] = 102;
  msg[73] = 39;
  msg[74] = 44;
  msg[75] = 32;
  msg[76] = 39;
  msg[77] = 98;
  msg[78] = 114;
  msg[79] = 101;
  msg[80] = 97;
  msg[81] = 107;
  msg[82] = 39;
  msg[83] = 44;
  msg[84] = 32;
  msg[85] = 39;
  msg[86] = 99;
  msg[87] = 111;
  msg[88] = 110;
  msg[89] = 116;
  msg[90] = 105;
  msg[91] = 110;
  msg[92] = 117;
  msg[93] = 101;
  msg[94] = 39;
  msg[95] = 44;
  msg[96] = 32;
  msg[97] = 39;
  msg[98] = 114;
  msg[99] = 101;
  msg[100] = 116;
  msg[101] = 117;
  msg[102] = 114;
  msg[103] = 110;
  msg[104] = 39;
  msg[105] = 44;
  msg[106] = 32;
  msg[107] = 39;
  msg[108] = 112;
  msg[109] = 97;
  msg[110] = 110;
  msg[111] = 105;
  msg[112] = 99;
  msg[113] = 39;
  msg[114] = 44;
  msg[115] = 32;
  msg[116] = 39;
  msg[117] = 109;
  msg[118] = 97;
  msg[119] = 116;
  msg[120] = 99;
  msg[121] = 104;
  msg[122] = 39;
  msg[123] = 44;
  msg[124] = 32;
  msg[125] = 111;
  msg[126] = 114;
  msg[127] = 32;
  msg[128] = 39;
  msg[129] = 40;
  msg[130] = 39;
  msg[131] = 0;
  unsafe {
    diag_report_with_code(input_path, 0, 0, &kind[0], &code[0], &msg[0], 0 as *u8);
  }
  return 1;
}

/**
 * Slice presence marker for this translation unit.
 * Returns 1, the same value the former host-cc marker returned.
 * No product caller reads it. The ensure nm gate only checks the symbol exists.
 * @return i32 — always 1
 * PLATFORM: SHARED — pure asm. Recovery diagnostics stay in the C seed.
 */
#[no_mangle]
export function labi_rt_parse_diag_slice_marker(): i32 {
  return 1;
}

/* ---- multi-error recovery diagnostics (w1494: moved from the C seed) ----
 * Lexical scanner that reports the multi-error recovery messages the deleted
 * C parser used to print, for `xlang check` and the run-parser gate.
 * Scanner state is an i32[4]: [0]=pos [1]=line [2]=col [3]=length.
 * A token is an i32[6]: [0]=kind [1]=punct char [2]=line [3]=col [4]=pos [5]=end.
 * Kind codes match the former C enum RtKw (0 none .. 25 punct).
 * PLATFORM: SHARED — pure asm, no host cc. */

export extern "C" function lsp_diag_get_enabled(): i32;
export extern "C" function lsp_diag_add_code(line: i32, col: i32, severity: i32, code: *u8, msg: *u8): void;
export extern "C" function driver_check_only_get(): i32;
export extern "C" function driver_check_diag_emitted_note(): void;
export extern "C" function driver_diag_append_cstr(dst: *u8, cap: i32, at: i32, src: *u8): i32;
export extern "C" function driver_diag_append_i32(dst: *u8, cap: i32, at: i32, val: i32): i32;

export const RT_REC_NONE: i32 = 0;
export const RT_REC_LET: i32 = 1;
export const RT_REC_CONST: i32 = 2;
export const RT_REC_IF: i32 = 3;
export const RT_REC_ELSE: i32 = 4;
export const RT_REC_WHILE: i32 = 5;
export const RT_REC_FOR: i32 = 6;
export const RT_REC_LOOP: i32 = 7;
export const RT_REC_RETURN: i32 = 8;
export const RT_REC_DEFER: i32 = 9;
export const RT_REC_REGION: i32 = 10;
export const RT_REC_UNSAFE: i32 = 11;
export const RT_REC_FUNCTION: i32 = 12;
export const RT_REC_STRUCT: i32 = 13;
export const RT_REC_ENUM: i32 = 14;
export const RT_REC_IMPORT: i32 = 15;
export const RT_REC_EXTERN: i32 = 16;
export const RT_REC_MATCH: i32 = 17;
export const RT_REC_BREAK: i32 = 18;
export const RT_REC_CONTINUE: i32 = 19;
export const RT_REC_TRUE: i32 = 20;
export const RT_REC_IDENT: i32 = 22;
export const RT_REC_INT: i32 = 23;
export const RT_REC_STRING: i32 = 24;
export const RT_REC_PUNCT: i32 = 25;

/** Byte at the scan position, or 0 at end. */
#[no_mangle]
export function rt_rec_peek(src: *u8, s: *i32): i32 {
  let pi: i32 = s[0];
  if (pi >= s[3]) {
    return 0;
  }
  return src[pi as usize] as i32;
}

/** Consume one byte and advance line/col; 0 at end. */
#[no_mangle]
export function rt_rec_get(src: *u8, s: *i32): i32 {
  let gi: i32 = s[0];
  let gc: i32 = 0;
  if (gi >= s[3]) {
    return 0;
  }
  gc = src[gi as usize] as i32;
  s[0] = gi + 1;
  if (gc == 10) {
    s[1] = s[1] + 1;
    s[2] = 1;
  } else {
    s[2] = s[2] + 1;
  }
  return gc;
}

/** Skip spaces, line comments, and non-nested block comments. */
#[no_mangle]
export function rt_rec_skip_ws_comment(src: *u8, s: *i32): void {
  let wc: i32 = 0;
  let wn: i32 = 0;
  let wi: i32 = 0;
  let wd: i32 = 0;
  while (true) {
    wc = rt_rec_peek(src, s);
    if (wc == 0) {
      return;
    }
    if (wc == 32 || wc == 9 || wc == 13 || wc == 10) {
      wd = rt_rec_get(src, s);
      continue;
    }
    wi = s[0];
    if (wc == 47 && wi + 1 < s[3]) {
      wn = src[(wi + 1) as usize] as i32;
      if (wn == 47) {
        while (true) {
          wd = rt_rec_peek(src, s);
          if (wd == 0 || wd == 10) {
            break;
          }
          wd = rt_rec_get(src, s);
        }
        continue;
      }
      if (wn == 42) {
        wd = rt_rec_get(src, s);
        wd = rt_rec_get(src, s);
        while (s[0] < s[3]) {
          wd = rt_rec_get(src, s);
          if (wd == 0) {
            break;
          }
          if (wd == 42 && rt_rec_peek(src, s) == 47) {
            wd = rt_rec_get(src, s);
            break;
          }
        }
        continue;
      }
    }
    return;
  }
}

/** 1 when p[0..n) equals lit[0..ln). */
#[no_mangle]
export function rt_rec_kw_eq(p: *u8, n: i32, lit: *u8, ln: i32): i32 {
  let ki: i32 = 0;
  if (n != ln) {
    return 0;
  }
  while (ki < n) {
    if (p[ki as usize] != lit[ki as usize]) {
      return 0;
    }
    ki = ki + 1;
  }
  return 1;
}

/** Keyword code for an identifier, or RT_REC_IDENT. */
#[no_mangle]
export function rt_rec_classify_ident(p: *u8, n: i32): i32 {
  if (rt_rec_kw_eq(p, n, "let", 3) != 0) { return RT_REC_LET; }
  if (rt_rec_kw_eq(p, n, "const", 5) != 0) { return RT_REC_CONST; }
  if (rt_rec_kw_eq(p, n, "if", 2) != 0) { return RT_REC_IF; }
  if (rt_rec_kw_eq(p, n, "else", 4) != 0) { return RT_REC_ELSE; }
  if (rt_rec_kw_eq(p, n, "while", 5) != 0) { return RT_REC_WHILE; }
  if (rt_rec_kw_eq(p, n, "for", 3) != 0) { return RT_REC_FOR; }
  if (rt_rec_kw_eq(p, n, "loop", 4) != 0) { return RT_REC_LOOP; }
  if (rt_rec_kw_eq(p, n, "return", 6) != 0) { return RT_REC_RETURN; }
  if (rt_rec_kw_eq(p, n, "defer", 5) != 0) { return RT_REC_DEFER; }
  if (rt_rec_kw_eq(p, n, "region", 6) != 0) { return RT_REC_REGION; }
  if (rt_rec_kw_eq(p, n, "unsafe", 6) != 0) { return RT_REC_UNSAFE; }
  if (rt_rec_kw_eq(p, n, "function", 8) != 0) { return RT_REC_FUNCTION; }
  if (rt_rec_kw_eq(p, n, "struct", 6) != 0) { return RT_REC_STRUCT; }
  if (rt_rec_kw_eq(p, n, "enum", 4) != 0) { return RT_REC_ENUM; }
  if (rt_rec_kw_eq(p, n, "import", 6) != 0) { return RT_REC_IMPORT; }
  if (rt_rec_kw_eq(p, n, "extern", 6) != 0) { return RT_REC_EXTERN; }
  if (rt_rec_kw_eq(p, n, "match", 5) != 0) { return RT_REC_MATCH; }
  if (rt_rec_kw_eq(p, n, "break", 5) != 0) { return RT_REC_BREAK; }
  if (rt_rec_kw_eq(p, n, "continue", 8) != 0) { return RT_REC_CONTINUE; }
  if (rt_rec_kw_eq(p, n, "true", 4) != 0) { return RT_REC_TRUE; }
  if (rt_rec_kw_eq(p, n, "false", 5) != 0) { return RT_REC_TRUE; }
  return RT_REC_IDENT;
}

/** C-locale isalpha. */
#[no_mangle]
export function rt_rec_is_alpha(c: i32): i32 {
  if (c >= 65 && c <= 90) {
    return 1;
  }
  if (c >= 97 && c <= 122) {
    return 1;
  }
  return 0;
}

/** C-locale isdigit. */
#[no_mangle]
export function rt_rec_is_digit(c: i32): i32 {
  if (c >= 48 && c <= 57) {
    return 1;
  }
  return 0;
}

/** Scan the next token into t. Returns 0 at end of input. */
#[no_mangle]
export function rt_rec_next_tok(src: *u8, s: *i32, t: *i32): i32 {
  let nc: i32 = 0;
  let nn: i32 = 0;
  let nstart: i32 = 0;
  let nd: i32 = 0;
  rt_rec_skip_ws_comment(src, s);
  if (s[0] >= s[3]) {
    t[0] = RT_REC_NONE;
    t[1] = 0;
    t[2] = s[1];
    t[3] = s[2];
    t[4] = s[0];
    t[5] = s[0];
    return 0;
  }
  t[2] = s[1];
  t[3] = s[2];
  nstart = s[0];
  t[4] = nstart;
  nc = rt_rec_get(src, s);
  if (rt_rec_is_alpha(nc) != 0 || nc == 95) {
    while (s[0] < s[3]) {
      nn = rt_rec_peek(src, s);
      if (rt_rec_is_alpha(nn) == 0 && rt_rec_is_digit(nn) == 0 && nn != 95) {
        break;
      }
      nd = rt_rec_get(src, s);
    }
    t[5] = s[0];
    t[0] = rt_rec_classify_ident(&src[nstart as usize], s[0] - nstart);
    t[1] = 0;
    return 1;
  }
  if (rt_rec_is_digit(nc) != 0) {
    while (rt_rec_is_digit(rt_rec_peek(src, s)) != 0) {
      nd = rt_rec_get(src, s);
    }
    t[5] = s[0];
    t[0] = RT_REC_INT;
    t[1] = 0;
    return 1;
  }
  if (nc == 34) {
    while (s[0] < s[3]) {
      nn = rt_rec_get(src, s);
      if (nn == 92 && s[0] < s[3]) {
        nd = rt_rec_get(src, s);
      } else {
        if (nn == 34 || nn == 0) {
          break;
        }
      }
    }
    t[5] = s[0];
    t[0] = RT_REC_STRING;
    t[1] = 0;
    return 1;
  }
  t[0] = RT_REC_PUNCT;
  t[1] = nc;
  t[5] = s[0];
  return 1;
}

/** Rewind the scanner to the start of token t. */
#[no_mangle]
export function rt_rec_rewind(s: *i32, t: *i32): void {
  s[0] = t[4];
  s[1] = t[2];
  s[2] = t[3];
}

/** 1 when t is the punct character ch. */
#[no_mangle]
export function rt_rec_is_punct(t: *i32, ch: i32): i32 {
  if (t[0] == RT_REC_PUNCT && t[1] == ch) {
    return 1;
  }
  return 0;
}

/** Report one recovery diagnostic (P001) to lsp_diag or stderr. */
#[no_mangle]
export function rt_rec_fail(line: i32, col: i32, msg: *u8): void {
  let fl: i32 = line;
  let fc: i32 = col;
  unsafe {
    if (lsp_diag_get_enabled() != 0) {
      if (fl <= 0) {
        fl = 1;
      }
      if (fc <= 0) {
        fc = 1;
      }
      lsp_diag_add_code(fl, fc, 1, "P001", msg);
      return;
    }
    if (driver_check_only_get() != 0) {
      driver_check_diag_emitted_note();
    }
    diag_report_with_code(0 as *u8, line, col, "parse error", "P001", msg, msg);
  }
}

/** Statement start: keyword heads plus '{' and '}'. */
#[no_mangle]
export function rt_rec_is_stmt_start(t: *i32): i32 {
  let sk: i32 = t[0];
  if (sk == RT_REC_NONE) {
    return 0;
  }
  if (sk == RT_REC_LET || sk == RT_REC_CONST || sk == RT_REC_IF || sk == RT_REC_WHILE
      || sk == RT_REC_FOR || sk == RT_REC_LOOP || sk == RT_REC_RETURN || sk == RT_REC_DEFER
      || sk == RT_REC_REGION || sk == RT_REC_UNSAFE || sk == RT_REC_BREAK
      || sk == RT_REC_CONTINUE || sk == RT_REC_MATCH || sk == RT_REC_FUNCTION) {
    return 1;
  }
  if (sk == RT_REC_PUNCT && (t[1] == 125 || t[1] == 123)) {
    return 1;
  }
  return 0;
}

/** Top-level declaration start. */
#[no_mangle]
export function rt_rec_is_top_start(t: *i32): i32 {
  let tk: i32 = t[0];
  if (tk == RT_REC_FUNCTION || tk == RT_REC_CONST || tk == RT_REC_STRUCT || tk == RT_REC_ENUM
      || tk == RT_REC_IMPORT || tk == RT_REC_EXTERN || tk == RT_REC_LET) {
    return 1;
  }
  return 0;
}

/** Advance to the next top-level declaration and rewind onto it. */
#[no_mangle]
export function rt_rec_recover_to_top_start(src: *u8, s: *i32): void {
  let rn: i32[6] = [];
  while (rt_rec_next_tok(src, s, &rn[0]) != 0) {
    if (rt_rec_is_top_start(&rn[0]) != 0) {
      rt_rec_rewind(s, &rn[0]);
      return;
    }
  }
}

/** Top-level `const` handling. Returns the number of errors reported and
 * adds 1 to *depth when a '{' is consumed. Returns -1 when input ended
 * early (the caller stops scanning, like the C `break`). */
#[no_mangle]
export function rt_rec_top_const(src: *u8, s: *i32, depth: *i32): i32 {
  let cn: i32[6] = [];
  let ce: i32[6] = [];
  let cr: i32[6] = [];
  let cx: i32[6] = [];
  let cerr: i32 = 0;
  if (rt_rec_next_tok(src, s, &cn[0]) == 0) {
    return -1;
  }
  if (cn[0] == RT_REC_IDENT) {
    if (rt_rec_next_tok(src, s, &ce[0]) == 0) {
      return -1;
    }
    if (rt_rec_is_punct(&ce[0], 61) != 0) {
      if (rt_rec_next_tok(src, s, &cr[0]) == 0) {
        return -1;
      }
      if (cr[0] != RT_REC_IMPORT) {
        rt_rec_fail(cr[2], cr[3], "expected const x = import(\"path\")");
        rt_rec_rewind(s, &cr[0]);
        rt_rec_recover_to_top_start(src, s);
        return 1;
      }
      while (rt_rec_next_tok(src, s, &cx[0]) != 0) {
        if (rt_rec_is_punct(&cx[0], 59) != 0) {
          break;
        }
        if (rt_rec_is_top_start(&cx[0]) != 0) {
          rt_rec_fail(cx[2], cx[3], "expected ';' after const x = import(\"path\")");
          rt_rec_rewind(s, &cx[0]);
          return 1;
        }
      }
      return 0;
    }
    rt_rec_rewind(s, &ce[0]);
  } else {
    rt_rec_rewind(s, &cn[0]);
  }
  while (rt_rec_next_tok(src, s, &cx[0]) != 0) {
    if (rt_rec_is_punct(&cx[0], 59) != 0) {
      break;
    }
    if (rt_rec_is_punct(&cx[0], 123) != 0) {
      depth[0] = depth[0] + 1;
      break;
    }
    if (rt_rec_is_top_start(&cx[0]) != 0) {
      rt_rec_fail(cx[2], cx[3], "expected ';' after top-level const");
      rt_rec_rewind(s, &cx[0]);
      cerr = 1;
      break;
    }
  }
  return cerr;
}

/** Top-level `function` handling: missing '{' before the next item.
 * `extern function f(): T;` ends at ';' and is not an error. */
#[no_mangle]
export function rt_rec_top_function(src: *u8, s: *i32, depth: *i32): i32 {
  let fx: i32[6] = [];
  let saw_rparen: i32 = 0;
  while (rt_rec_next_tok(src, s, &fx[0]) != 0) {
    if (rt_rec_is_punct(&fx[0], 40) != 0) {
      continue;
    }
    if (rt_rec_is_punct(&fx[0], 41) != 0) {
      saw_rparen = 1;
      continue;
    }
    if (rt_rec_is_punct(&fx[0], 123) != 0) {
      depth[0] = depth[0] + 1;
      break;
    }
    if (saw_rparen != 0 && rt_rec_is_punct(&fx[0], 59) != 0) {
      break;
    }
    if (saw_rparen != 0 && rt_rec_is_top_start(&fx[0]) != 0) {
      rt_rec_fail(fx[2], fx[3], "expected '{' before function body");
      rt_rec_rewind(s, &fx[0]);
      return 1;
    }
    if (fx[0] == RT_REC_NONE) {
      break;
    }
  }
  return 0;
}

/** In-body `let` without ';'. Initializer heads after '=' (unsafe, if,
 * match, region, loop, for, while, '{') are not statement boundaries. */
#[no_mangle]
export function rt_rec_body_let(src: *u8, s: *i32): i32 {
  let lx: i32[6] = [];
  let saw_eq: i32 = 0;
  let nest: i32 = 0;
  let lk: i32 = 0;
  let lch: i32 = 0;
  while (rt_rec_next_tok(src, s, &lx[0]) != 0) {
    lk = lx[0];
    lch = lx[1];
    if (lk == RT_REC_PUNCT && lch == 59 && nest == 0) {
      break;
    }
    if (lk == RT_REC_PUNCT && (lch == 40 || lch == 91 || lch == 123)) {
      nest = nest + 1;
      continue;
    }
    if (lk == RT_REC_PUNCT && (lch == 41 || lch == 93 || lch == 125)) {
      if (nest > 0) {
        nest = nest - 1;
        continue;
      }
      if (lch == 125) {
        rt_rec_fail(lx[2], lx[3], "expected ';' after let");
        rt_rec_rewind(s, &lx[0]);
        return 1;
      }
      continue;
    }
    if (lk == RT_REC_PUNCT && lch == 61 && nest == 0) {
      saw_eq = 1;
      continue;
    }
    if (nest == 0 && rt_rec_is_stmt_start(&lx[0]) != 0 && lk != RT_REC_LET) {
      if (saw_eq != 0
          && (lk == RT_REC_IF || lk == RT_REC_MATCH || lk == RT_REC_UNSAFE
              || lk == RT_REC_REGION || lk == RT_REC_LOOP || lk == RT_REC_FOR
              || lk == RT_REC_WHILE || (lk == RT_REC_PUNCT && lch == 123))) {
        continue;
      }
      rt_rec_fail(lx[2], lx[3], "expected ';' after let");
      rt_rec_rewind(s, &lx[0]);
      return 1;
    }
    if (lk == RT_REC_NONE) {
      break;
    }
  }
  return 0;
}

/**
 * Lexical multi-error recovery diagnostics, matching the deleted C parser's
 * failure text, for the check / run-parser gate.
 * Returns the number of diagnostics written; 0 means no recoverable error.
 * PLATFORM: SHARED — pure asm (w1494; the C seed tail is deleted).
 */
#[no_mangle]
export function runtime_report_parse_recovery_diagnostics(input_path: *u8, src: *u8, src_len: usize): i32 {
  let st: i32[4] = [];
  let tk: i32[6] = [];
  let nx: i32[6] = [];
  let dp: i32[1] = [];
  let errors: i32 = 0;
  let r: i32 = 0;
  let k: i32 = 0;
  let amsg: u8[96] = [];
  let at: i32 = 0;
  if (src == 0 as *u8) {
    return 0;
  }
  if (src_len == 0 as usize) {
    return 0;
  }
  st[0] = 0;
  st[1] = 1;
  st[2] = 1;
  st[3] = src_len as i32;
  if (st[3] <= 0) {
    return 0;
  }
  dp[0] = 0;
  while (rt_rec_next_tok(src, &st[0], &tk[0]) != 0) {
    k = tk[0];
    if (rt_rec_is_punct(&tk[0], 123) != 0) {
      dp[0] = dp[0] + 1;
      continue;
    }
    if (rt_rec_is_punct(&tk[0], 125) != 0) {
      if (dp[0] > 0) {
        dp[0] = dp[0] - 1;
      }
      continue;
    }
    if (dp[0] == 0 && k == RT_REC_CONST) {
      r = rt_rec_top_const(src, &st[0], &dp[0]);
      if (r < 0) {
        break;
      }
      errors = errors + r;
      continue;
    }
    if (dp[0] == 0 && k == RT_REC_FUNCTION) {
      errors = errors + rt_rec_top_function(src, &st[0], &dp[0]);
      continue;
    }
    if (dp[0] == 0) {
      continue;
    }
    if (k == RT_REC_LET) {
      errors = errors + rt_rec_body_let(src, &st[0]);
      continue;
    }
    if (k == RT_REC_IF) {
      /* `if cond {` without parentheses is valid (main parser parity):
       * rewind onto a condition start, never report here. */
      if (rt_rec_next_tok(src, &st[0], &nx[0]) == 0) {
        break;
      }
      if (rt_rec_is_punct(&nx[0], 40) == 0) {
        if (rt_rec_is_stmt_start(&nx[0]) != 0 || rt_rec_is_punct(&nx[0], 123) != 0
            || nx[0] == RT_REC_IDENT || nx[0] == RT_REC_INT || nx[0] == RT_REC_STRING
            || nx[0] == RT_REC_TRUE) {
          rt_rec_rewind(&st[0], &nx[0]);
        }
      }
      continue;
    }
    if (k == RT_REC_DEFER || k == RT_REC_UNSAFE) {
      if (rt_rec_next_tok(src, &st[0], &nx[0]) == 0) {
        break;
      }
      if (rt_rec_is_punct(&nx[0], 123) == 0) {
        if (k == RT_REC_DEFER) {
          rt_rec_fail(nx[2], nx[3], "expected '{' after defer");
        } else {
          rt_rec_fail(nx[2], nx[3], "expected '{' after unsafe");
        }
        errors = errors + 1;
        if (rt_rec_is_stmt_start(&nx[0]) != 0) {
          rt_rec_rewind(&st[0], &nx[0]);
        }
      } else {
        dp[0] = dp[0] + 1;
      }
      continue;
    }
    if (k == RT_REC_REGION) {
      if (rt_rec_next_tok(src, &st[0], &nx[0]) == 0) {
        break;
      }
      if (nx[0] != RT_REC_IDENT) {
        rt_rec_fail(nx[2], nx[3], "expected region label after region");
        errors = errors + 1;
        if (rt_rec_is_stmt_start(&nx[0]) != 0) {
          rt_rec_rewind(&st[0], &nx[0]);
        }
      }
      continue;
    }
  }
  unsafe {
    if (errors > 1 && lsp_diag_get_enabled() == 0) {
      at = driver_diag_append_cstr(&amsg[0], 96, 0, "aborting due to ");
      at = driver_diag_append_i32(&amsg[0], 96, at, errors);
      at = driver_diag_append_cstr(&amsg[0], 96, at, " previous errors");
      if (input_path != 0 as *u8) {
        diag_report_with_code(input_path, 0, 0, "error", 0 as *u8, &amsg[0], &amsg[0]);
      } else {
        diag_report_with_code("?", 0, 0, "error", 0 as *u8, &amsg[0], &amsg[0]);
      }
    }
  }
  return errors;
}
