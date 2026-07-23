// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
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

// See implementation.
//
// See implementation.
// See implementation.

/* See implementation. */
export extern function preprocess_if_stack_reset(): void;
export extern function preprocess_if_stack_len(): i32;
export extern function preprocess_if_stack_push(v: i32): i32;
export extern function preprocess_if_stack_pop(): void;
export extern function preprocess_if_stack_at(i: i32): i32;
export extern function preprocess_if_stack_set_at(i: i32, v: i32): void;

/* See implementation. */
export extern function preprocess_eval_condition_c(cond: *u8, cond_len: i32): i32;

/**
 * See implementation.
 * See implementation.
 */
let g_pp_kind: i32 = 0;
let g_pp_sym_len: i32 = 0;

/* See implementation. */
/* wave265: line-oriented buffer 512→4096 (silent truncate at 511 → P001).
 * wave266: non-directive overflow streams; cap still 4096 for directive parse.
 * wave267: known directive on buffer-full → early apply + drain (no silent drop).
 * wave268: #if/#elseif cond buffer 256→4096 (silent truncate at 255 after long
 *   line support left conditions mis-copied / kind=0 when leading ws ate the cap). */
let g_pp_line_buf: u8[4096] = [];
let g_pp_cond: u8[4096] = [];

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function pp_if_stack_reset(): void {
  unsafe {
    preprocess_if_stack_reset();
  }
}
/** Exported function `pp_if_stack_len`.
 * Query helper `pp_if_stack_len`.
 * @return i32
 */
export function pp_if_stack_len(): i32 {
  unsafe {
    return preprocess_if_stack_len();
  }
  return 0;
}
/** Exported function `pp_if_stack_push`.
 * Implements `pp_if_stack_push`.
 * @param v i32
 * @return i32
 */
export function pp_if_stack_push(v: i32): i32 {
  unsafe {
    return preprocess_if_stack_push(v);
  }
  return 0;
}
/** Exported function `pp_if_stack_at`.
 * Implements `pp_if_stack_at`.
 * @param i i32
 * @return i32
 */
export function pp_if_stack_at(i: i32): i32 {
  unsafe {
    return preprocess_if_stack_at(i);
  }
  return 0;
}
/** Exported function `pp_if_stack_set_at`.
 * Implements `pp_if_stack_set_at`.
 * @param i i32
 * @param v i32
 * @return void
 */
export function pp_if_stack_set_at(i: i32, v: i32): void {
  unsafe {
    preprocess_if_stack_set_at(i, v);
  }
}
/** Exported function `pp_if_stack_pop`.
 * Implements `pp_if_stack_pop`.
 * @return void
 */
export function pp_if_stack_pop(): void {
  unsafe {
    preprocess_if_stack_pop();
  }
}
/** Exported function `pp_eval_condition`.
 * Implements `pp_eval_condition`.
 * @param cond *u8
 * @param cond_len i32
 * @return i32
 */
export function pp_eval_condition(cond: *u8, cond_len: i32): i32 {
  unsafe {
    return preprocess_eval_condition_c(cond, cond_len);
  }
  return 0;
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 */
export function pp_reset_i32(): i32 {
  unsafe {
    preprocess_if_stack_reset();
  }
  return 0;
}

/** Exported function `pp_kind_needs_cond`.
 * Implements `pp_kind_needs_cond`.
 * @param kind i32
 * @return bool
 */
export function pp_kind_needs_cond(kind: i32): bool {
  if (kind == 1) { return true; }
  if (kind == 4) { return true; }
  return false;
}

/** Exported function `pp_is_ws`.
 * Implements `pp_is_ws`.
 * @param ch u8
 * @return bool
 */
export function pp_is_ws(ch: u8): bool {
  if (ch == 32) { return true; }
  if (ch == 9) { return true; }
  return false;
}

/** Exported function `pp_is_eol`.
 * Implements `pp_is_eol`.
 * @param ch u8
 * @return bool
 */
export function pp_is_eol(ch: u8): bool {
  if (ch == 10) { return true; }
  if (ch == 13) { return true; }
  return false;
}

/** Exported function `pp_is_token_end`.
 * Implements `pp_is_token_end`.
 * @param ch u8
 * @return bool
 */
export function pp_is_token_end(ch: u8): bool {
  if (ch == 32) { return true; }
  if (ch == 9) { return true; }
  if (ch == 10) { return true; }
  if (ch == 13) { return true; }
  if (ch == 0) { return true; }
  return false;
}

/** Exported function `pp_at_end_or_not_byte`.
 * Implements `pp_at_end_or_not_byte`.
 * @param buf *u8
 * @param pos i32
 * @param line_len i32
 * @param target u8
 * @return bool
 */
export function pp_at_end_or_not_byte(buf: *u8, pos: i32, line_len: i32, target: u8): bool {
  if (pos >= line_len) { return true; }
  if (buf[pos] != target) { return true; }
  return false;
}

/** Exported function `pp_is_word_boundary`.
 * Implements `pp_is_word_boundary`.
 * @param buf *u8
 * @param pos i32
 * @param line_len i32
 * @return bool
 */
export function pp_is_word_boundary(buf: *u8, pos: i32, line_len: i32): bool {
  if (pos >= line_len) { return false; }
  let ch: u8 = buf[pos];
  if (pp_is_token_end(ch)) { return false; }
  return true;
}

/** Exported function `pp_at_end_or_token_end`.
 * Implements `pp_at_end_or_token_end`.
 * @param buf *u8
 * @param pos i32
 * @param line_len i32
 * @return bool
 */
export function pp_at_end_or_token_end(buf: *u8, pos: i32, line_len: i32): bool {
  if (pos >= line_len) { return true; }
  let ch: u8 = buf[pos];
  if (pp_is_token_end(ch)) { return true; }
  return false;
}

/** Exported function `pp_match_if`.
 * Implements `pp_match_if`.
 * @param buf *u8
 * @param pos i32
 * @param line_len i32
 * @return bool
 */
export function pp_match_if(buf: *u8, pos: i32, line_len: i32): bool {
  if (pos + 2 > line_len) { return false; }
  if (buf[pos] != 105) { return false; }
  if (buf[pos + 1] != 102) { return false; }
  return true;
}

/** Exported function `pp_match_elseif`.
 * Implements `pp_match_elseif`.
 * @param buf *u8
 * @param pos i32
 * @param line_len i32
 * @return bool
 */
export function pp_match_elseif(buf: *u8, pos: i32, line_len: i32): bool {
  if (pos + 6 > line_len) { return false; }
  if (buf[pos] != 101) { return false; }
  if (buf[pos + 1] != 108) { return false; }
  if (buf[pos + 2] != 115) { return false; }
  if (buf[pos + 3] != 101) { return false; }
  if (buf[pos + 4] != 105) { return false; }
  if (buf[pos + 5] != 102) { return false; }
  return true;
}

/** Exported function `pp_match_else`.
 * Implements `pp_match_else`.
 * @param buf *u8
 * @param pos i32
 * @param line_len i32
 * @return bool
 */
export function pp_match_else(buf: *u8, pos: i32, line_len: i32): bool {
  if (pos + 4 > line_len) { return false; }
  if (buf[pos] != 101) { return false; }
  if (buf[pos + 1] != 108) { return false; }
  if (buf[pos + 2] != 115) { return false; }
  if (buf[pos + 3] != 101) { return false; }
  return true;
}

/** Exported function `pp_match_endif`.
 * Implements `pp_match_endif`.
 * @param buf *u8
 * @param pos i32
 * @param line_len i32
 * @return bool
 */
export function pp_match_endif(buf: *u8, pos: i32, line_len: i32): bool {
  if (pos + 5 > line_len) { return false; }
  if (buf[pos] != 101) { return false; }
  if (buf[pos + 1] != 110) { return false; }
  if (buf[pos + 2] != 100) { return false; }
  if (buf[pos + 3] != 105) { return false; }
  if (buf[pos + 4] != 102) { return false; }
  return true;
}

/**
 * See implementation.
 * See implementation.
 *  -2 #else without #if
 *  -3 #endif without #if
 *  -4 #elseif without #if
 *  -5 #elseif after #else
 *  -6 duplicate #else
 * See implementation.
 * See implementation.
 */
export function preprocess_apply_directive_kind(kind: i32, cond_val: i32): i32 {
  let depth: i32 = pp_if_stack_len();
  if (kind == 1) {
    let v: i32 = cond_val;
    if (depth > 0) {
      let parent: i32 = pp_if_stack_at(depth - 1);
      if (parent == 0) {
        v = 0;
      }
    }
    if (v != 0) {
      v = 1;
    }
    let pr: i32 = pp_if_stack_push(v);
    if (pr < 0) {
      return -7;
    }
    return 0;
  }
  if (kind == 2) {
    if (depth == 0) {
      return -2;
    }
    let di: i32 = depth - 1;
    let top: i32 = pp_if_stack_at(di);
    if (top == 1) {
      pp_if_stack_set_at(di, 0);
    } else if (top == 0) {
      pp_if_stack_set_at(di, 2);
    } else if (top == 3) {
      /* See implementation. */
    } else {
      return -6;
    }
    return 0;
  }
  if (kind == 4) {
    if (depth == 0) {
      return -4;
    }
    let di2: i32 = depth - 1;
    let top2: i32 = pp_if_stack_at(di2);
    if (top2 == 2) {
      return -5;
    }
    if (top2 == 1) {
      pp_if_stack_set_at(di2, 3);
    } else if (top2 == 0) {
      let cv: i32 = cond_val;
      if (cv != 0) {
        pp_if_stack_set_at(di2, 1);
      } else {
        pp_if_stack_set_at(di2, 0);
      }
    } else {
      pp_if_stack_set_at(di2, 3);
    }
    return 0;
  }
  if (depth == 0) {
    return -3;
  }
  pp_if_stack_pop();
  return 0;
}

/** Exported function `preprocess_line_keeping`.
 * Implements `preprocess_line_keeping`.
 * @return bool
 */
export function preprocess_line_keeping(): bool {
  let depth: i32 = pp_if_stack_len();
  if (depth == 0) {
    return true;
  }
  let top: i32 = pp_if_stack_at(depth - 1);
  // See implementation.
  if (top == 1) {
    return true;
  }
  if (top == 2) {
    return true;
  }
  return false;
}

/* See implementation. */
export struct ParseDirectiveResult {
  kind: i32;
  sym_len: i32;
}

/**
 * Copy the #if/#elseif condition bytes from line_buf[pos..) into cond.
 * @param cond u8[4096] — destination; max content length 4095 (wave268)
 * @param line_buf u8[4096] — full directive line (wave265 cap)
 * @param pos i32 — first condition byte (after keyword + ws)
 * @param line_len i32 — valid length of line_buf
 * @return i32 — condition length after trailing ws/CR strip; 0 if empty
 * PLATFORM: SHARED — cap must match g_pp_cond / line max so long conditions
 * after wave265 lines are not silently truncated mid-expression.
 */
export function parse_copy_cond_from_line(cond: u8[4096], line_buf: u8[4096], pos: i32, line_len: i32): i32 {
  let s: i32 = 0;
  while (pos < line_len) {
    // wave268: 255 → 4095 (align with line_buf content max).
    if (s >= 4095) {
      break;
    }
    let ch: u8 = line_buf[pos];
    if (pp_is_eol(ch)) {
      break;
    }
    cond[s] = ch;
    s = s + 1;
    pos = pos + 1;
  }
  while (s > 0) {
    let tail: u8 = cond[s - 1];
    if (pp_is_ws(tail)) {
      s = s - 1;
    } else {
      if (tail == 13) {
        s = s - 1;
      } else {
        break;
      }
    }
  }
  return s;
}

/**
 * Parse one directive line into g_pp_kind / g_pp_sym_len and cond bytes.
 * @param line_buf u8[4096] — line without requiring trailing LF
 * @param line_len i32 — valid prefix length
 * @param cond u8[4096] — out: condition text for #if/#elseif (wave268 cap)
 * @return void — sets module g_pp_kind (0=none) and g_pp_sym_len
 * PLATFORM: SHARED — kinds 1/4 need cond; empty cond after copy leaves kind=0.
 */
export function parse_directive_into(line_buf: u8[4096], line_len: i32, cond: u8[4096]): void {
  let pos: i32 = 0;
  g_pp_kind = 0;
  g_pp_sym_len = 0;
  // See implementation.
  while (pos < line_len) {
    let ws0: u8 = line_buf[pos];
    if (pp_is_ws(ws0)) {
      pos = pos + 1;
    } else {
      break;
    }
  }
  // See implementation.
  if (pp_at_end_or_not_byte(line_buf, pos, line_len, 35 as u8)) {
    return;
  }
  pos = pos + 1;
  // See implementation.
  while (pos < line_len) {
    let ws1: u8 = line_buf[pos];
    if (pp_is_ws(ws1)) {
      pos = pos + 1;
    } else {
      break;
    }
  }
  if (pos >= line_len) {
    return;
  }
  // #if (105,102)
  if (pp_match_if(line_buf, pos, line_len)) {
    pos = pos + 2;
    if (pp_is_word_boundary(line_buf, pos, line_len)) {
      return;
    }
    while (pos < line_len) {
      let ws_if: u8 = line_buf[pos];
      if (pp_is_ws(ws_if)) {
        pos = pos + 1;
      } else {
        break;
      }
    }
    if (pos >= line_len) {
      return;
    }
    let cl: i32 = parse_copy_cond_from_line(cond, line_buf, pos, line_len);
    if (cl <= 0) {
      return;
    }
    g_pp_kind = 1;
    g_pp_sym_len = cl;
    return;
  }
  // #elseif (101,108,115,101,105,102)
  if (pp_match_elseif(line_buf, pos, line_len)) {
    pos = pos + 6;
    if (pp_is_word_boundary(line_buf, pos, line_len)) {
      return;
    }
    while (pos < line_len) {
      let ws_elseif: u8 = line_buf[pos];
      if (pp_is_ws(ws_elseif)) {
        pos = pos + 1;
      } else {
        break;
      }
    }
    if (pos >= line_len) {
      return;
    }
    let cl2: i32 = parse_copy_cond_from_line(cond, line_buf, pos, line_len);
    if (cl2 <= 0) {
      return;
    }
    g_pp_kind = 4;
    g_pp_sym_len = cl2;
    return;
  }
  // #else (101,108,115,101)
  if (pp_match_else(line_buf, pos, line_len)) {
    pos = pos + 4;
    if (pp_at_end_or_token_end(line_buf, pos, line_len)) {
      g_pp_kind = 2;
      g_pp_sym_len = 0;
      return;
    }
    return;
  }
  // #endif (101,110,100,105,102)
  if (pp_match_endif(line_buf, pos, line_len)) {
    pos = pos + 5;
    if (pp_at_end_or_token_end(line_buf, pos, line_len)) {
      g_pp_kind = 3;
      g_pp_sym_len = 0;
      return;
    }
    return;
  }
}

/**
 * Run preprocess over a full source slice into out_buf.
 * Returns output length, or -1 on buffer overflow / unclosed #if.
 *
 * wave265 Cap residual: per-line buffer is 4096 bytes (max content 4095).
 * Prior 512/511 silently dropped tail bytes of long source lines → parser
 * saw truncated text → P001 / late-export silent-skip (product -E path).
 *
 * wave266 Cap residual: when a non-directive line exceeds 4095 bytes, the
 * filled prefix is flushed (if keeping) and the rest of the line streams
 * byte-by-byte into out_buf until LF — no silent drop for product source.
 *
 * wave268 Cap residual: #if/#elseif condition buffer is 4096 (max 4095),
 * matching the line cap. Prior cond[256] silently truncated at 255; long
 * leading whitespace before a token could yield empty cond → kind=0 and
 * the directive was treated as body (stack not pushed).
 *
 * wave267 Cap residual: when the buffer fills on a *known* directive
 * (#if/#elseif/#else/#endif), parse+apply immediately from the 4095-byte
 * prefix, emit the directive LF, then drain (skip) the rest of the line
 * until LF — no re-parse, no silent condition loss for realistic # lines.
 * Non-directive / unknown `#` prefixes use the same body stream as wave266.
 *
 * line_stream modes: 0 = buffering; 1 = body tail stream (emit if keeping);
 * 2 = directive overflow drain (skip until LF; LF already emitted on apply).
 *
 * PLATFORM: SHARED — line-oriented #if/#else/#endif. After the scan loop,
 * any partial last line (source not ending in LF) is flushed so a trailing
 * `}` or last statement is not dropped. Missing that flush historically
 * yielded parse num_funcs=0 / XP003 when files omitted a final newline.
 *
 * @param source Input source bytes (length = source.length)
 * @param out_buf Destination buffer; must have length > 0
 * @return Written byte count, or negative error
 */
export function preprocess_x(source: u8[], out_buf: u8[]): i32 {
  if (out_buf.length <= 0) {
    return -1;
  }
  let _r: i32 = pp_reset_i32();
  let out_len: i32 = 0;
  let line_len: i32 = 0;
  /* 0 = buffering; 1 = body stream (wave266); 2 = directive drain (wave267). */
  let line_stream: i32 = 0;
  let pos: i32 = 0;
  while (pos < source.length) {
    let ch: u8 = source[pos];
    if (ch == 10) {
      if (line_stream == 2) {
        /* Directive already applied + LF emitted; drain ends at this LF. */
        line_stream = 0;
        line_len = 0;
        pos = pos + 1;
      } else {
        if (line_stream == 1) {
          /* Body stream: trailing LF if keeping. */
          let keeping_st: bool = preprocess_line_keeping();
          if (keeping_st) {
            if (out_len >= out_buf.length) {
              return -1;
            }
            out_buf[out_len] = 10;
            out_len = out_len + 1;
          }
          line_stream = 0;
          line_len = 0;
          pos = pos + 1;
        } else {
          parse_directive_into(g_pp_line_buf, line_len, g_pp_cond);
          let kind: i32 = g_pp_kind;
          if (kind != 0) {
            let cond_val: i32 = 0;
            if (pp_kind_needs_cond(kind)) {
              cond_val = pp_eval_condition(&g_pp_cond[0], g_pp_sym_len);
            }
            let ar: i32 = preprocess_apply_directive_kind(kind, cond_val);
            if (ar != 0) {
              return ar;
            }
            if (out_len >= out_buf.length) {
              return -1;
            }
            out_buf[out_len] = 10;
            out_len = out_len + 1;
          } else {
            let keeping: bool = preprocess_line_keeping();
            if (keeping) {
              let i: i32 = 0;
              while (i < line_len) {
                if (out_len >= out_buf.length) {
                  return -1;
                }
                out_buf[out_len] = g_pp_line_buf[i];
                out_len = out_len + 1;
                i = i + 1;
              }
            }
            if (out_len >= out_buf.length) {
              return -1;
            }
            out_buf[out_len] = 10;
            out_len = out_len + 1;
          }
          line_len = 0;
          pos = pos + 1;
        }
      }
    } else {
      if (line_stream == 2) {
        /* Directive overflow drain: skip until LF. */
        pos = pos + 1;
      } else {
        if (line_stream == 1) {
          /* Body overflow tail: stream one byte if keeping. */
          let keeping_tail: bool = preprocess_line_keeping();
          if (keeping_tail) {
            if (out_len >= out_buf.length) {
              return -1;
            }
            out_buf[out_len] = ch;
            out_len = out_len + 1;
          }
          pos = pos + 1;
        } else {
          if (line_len < 4095) {
            g_pp_line_buf[line_len] = ch;
            line_len = line_len + 1;
            pos = pos + 1;
          } else {
            /* Buffer full: early-apply known directives; else body-stream. */
            parse_directive_into(g_pp_line_buf, line_len, g_pp_cond);
            let kind_ov: i32 = g_pp_kind;
            if (kind_ov != 0) {
              let cond_val_ov: i32 = 0;
              if (pp_kind_needs_cond(kind_ov)) {
                cond_val_ov = pp_eval_condition(&g_pp_cond[0], g_pp_sym_len);
              }
              let ar_ov: i32 = preprocess_apply_directive_kind(kind_ov, cond_val_ov);
              if (ar_ov != 0) {
                return ar_ov;
              }
              if (out_len >= out_buf.length) {
                return -1;
              }
              out_buf[out_len] = 10;
              out_len = out_len + 1;
              line_len = 0;
              line_stream = 2;
              pos = pos + 1;
            } else {
              let keeping_ov: bool = preprocess_line_keeping();
              if (keeping_ov) {
                let j: i32 = 0;
                while (j < line_len) {
                  if (out_len >= out_buf.length) {
                    return -1;
                  }
                  out_buf[out_len] = g_pp_line_buf[j];
                  out_len = out_len + 1;
                  j = j + 1;
                }
                if (out_len >= out_buf.length) {
                  return -1;
                }
                out_buf[out_len] = ch;
                out_len = out_len + 1;
              }
              line_len = 0;
              line_stream = 1;
              pos = pos + 1;
            }
          }
        }
      }
    }
  }
  /* PLATFORM: SHARED — flush last line when source omits trailing LF (POSIX text files may).
   * Same emit path as LF branch so #if directives and kept text stay consistent. */
  if (line_stream == 2) {
    /* Applied + LF already emitted; no synthetic second LF. */
    line_stream = 0;
    line_len = 0;
  } else {
    if (line_stream == 1) {
      /* Streamed body already in out; synthetic LF mirrors normal no-trailing-LF flush. */
      let keeping_st_eof: bool = preprocess_line_keeping();
      if (keeping_st_eof) {
        if (out_len >= out_buf.length) {
          return -1;
        }
        out_buf[out_len] = 10;
        out_len = out_len + 1;
      }
      line_stream = 0;
      line_len = 0;
    } else {
      if (line_len > 0) {
        parse_directive_into(g_pp_line_buf, line_len, g_pp_cond);
        let kind_eof: i32 = g_pp_kind;
        if (kind_eof != 0) {
          let cond_val_eof: i32 = 0;
          if (pp_kind_needs_cond(kind_eof)) {
            cond_val_eof = pp_eval_condition(&g_pp_cond[0], g_pp_sym_len);
          }
          let ar_eof: i32 = preprocess_apply_directive_kind(kind_eof, cond_val_eof);
          if (ar_eof != 0) {
            return ar_eof;
          }
          if (out_len >= out_buf.length) {
            return -1;
          }
          out_buf[out_len] = 10;
          out_len = out_len + 1;
        } else {
          let keeping_eof: bool = preprocess_line_keeping();
          if (keeping_eof) {
            let i_eof: i32 = 0;
            while (i_eof < line_len) {
              if (out_len >= out_buf.length) {
                return -1;
              }
              out_buf[out_len] = g_pp_line_buf[i_eof];
              out_len = out_len + 1;
              i_eof = i_eof + 1;
            }
          }
          if (out_len >= out_buf.length) {
            return -1;
          }
          out_buf[out_len] = 10;
          out_len = out_len + 1;
        }
        line_len = 0;
      }
    }
  }
  if (pp_if_stack_len() != 0) {
    return -1;
  }
  return out_len;
}

/**
 * Buf+len entry for preprocess (same semantics as preprocess_x).
 * PLATFORM: SHARED — flushes partial last line when source_len has no trailing LF.
 *
 * @param source_buf Fixed-cap input array (read only [0..source_len))
 * @param source_len Logical input length
 * @param out_buf Fixed-cap output array
 * @param out_cap Capacity of out_buf
 * @return Written byte count, or negative error
 */
export function preprocess_x_buf(source_buf: u8[4194304], source_len: isize, out_buf: u8[4194304], out_cap: i32): i32 {
  if (out_cap <= 0) {
    return -1;
  }
  let _r: i32 = pp_reset_i32();
  let out_len: i32 = 0;
  let line_len: i32 = 0;
  /* 0 = buffering; 1 = body stream; 2 = directive drain (mirror preprocess_x / wave267). */
  let line_stream: i32 = 0;
  let pos: i32 = 0;
  while (pos < source_len) {
    if (pos >= 4194304) {
      break;
    }
    let ch: u8 = source_buf[pos];
    if (ch == 10) {
      if (line_stream == 2) {
        line_stream = 0;
        line_len = 0;
        pos = pos + 1;
      } else {
        if (line_stream == 1) {
          let keeping_st_b: bool = preprocess_line_keeping();
          if (keeping_st_b) {
            if (out_len >= out_cap) {
              return -1;
            }
            out_buf[out_len] = 10;
            out_len = out_len + 1;
          }
          line_stream = 0;
          line_len = 0;
          pos = pos + 1;
        } else {
          parse_directive_into(g_pp_line_buf, line_len, g_pp_cond);
          let kind: i32 = g_pp_kind;
          if (kind != 0) {
            let cond_val: i32 = 0;
            if (pp_kind_needs_cond(kind)) {
              cond_val = pp_eval_condition(&g_pp_cond[0], g_pp_sym_len);
            }
            let ar: i32 = preprocess_apply_directive_kind(kind, cond_val);
            if (ar != 0) {
              return ar;
            }
            if (out_len >= out_cap) {
              return -1;
            }
            out_buf[out_len] = 10;
            out_len = out_len + 1;
          } else {
            let keeping: bool = preprocess_line_keeping();
            if (keeping) {
              let i: i32 = 0;
              while (i < line_len) {
                if (out_len >= out_cap) {
                  return -1;
                }
                out_buf[out_len] = g_pp_line_buf[i];
                out_len = out_len + 1;
                i = i + 1;
              }
            }
            if (out_len >= out_cap) {
              return -1;
            }
            out_buf[out_len] = 10;
            out_len = out_len + 1;
          }
          line_len = 0;
          pos = pos + 1;
        }
      }
    } else {
      if (line_stream == 2) {
        pos = pos + 1;
      } else {
        if (line_stream == 1) {
          let keeping_tail_b: bool = preprocess_line_keeping();
          if (keeping_tail_b) {
            if (out_len >= out_cap) {
              return -1;
            }
            out_buf[out_len] = ch;
            out_len = out_len + 1;
          }
          pos = pos + 1;
        } else {
          if (line_len < 4095) {
            g_pp_line_buf[line_len] = ch;
            line_len = line_len + 1;
            pos = pos + 1;
          } else {
            parse_directive_into(g_pp_line_buf, line_len, g_pp_cond);
            let kind_ov_b: i32 = g_pp_kind;
            if (kind_ov_b != 0) {
              let cond_val_ov_b: i32 = 0;
              if (pp_kind_needs_cond(kind_ov_b)) {
                cond_val_ov_b = pp_eval_condition(&g_pp_cond[0], g_pp_sym_len);
              }
              let ar_ov_b: i32 = preprocess_apply_directive_kind(kind_ov_b, cond_val_ov_b);
              if (ar_ov_b != 0) {
                return ar_ov_b;
              }
              if (out_len >= out_cap) {
                return -1;
              }
              out_buf[out_len] = 10;
              out_len = out_len + 1;
              line_len = 0;
              line_stream = 2;
              pos = pos + 1;
            } else {
              let keeping_ov_b: bool = preprocess_line_keeping();
              if (keeping_ov_b) {
                let j_b: i32 = 0;
                while (j_b < line_len) {
                  if (out_len >= out_cap) {
                    return -1;
                  }
                  out_buf[out_len] = g_pp_line_buf[j_b];
                  out_len = out_len + 1;
                  j_b = j_b + 1;
                }
                if (out_len >= out_cap) {
                  return -1;
                }
                out_buf[out_len] = ch;
                out_len = out_len + 1;
              }
              line_len = 0;
              line_stream = 1;
              pos = pos + 1;
            }
          }
        }
      }
    }
  }
  /* PLATFORM: SHARED — flush last line when buffer omits trailing LF (mirror preprocess_x). */
  if (line_stream == 2) {
    line_stream = 0;
    line_len = 0;
  } else {
    if (line_stream == 1) {
      let keeping_st_eof_b: bool = preprocess_line_keeping();
      if (keeping_st_eof_b) {
        if (out_len >= out_cap) {
          return -1;
        }
        out_buf[out_len] = 10;
        out_len = out_len + 1;
      }
      line_stream = 0;
      line_len = 0;
    } else {
      if (line_len > 0) {
        parse_directive_into(g_pp_line_buf, line_len, g_pp_cond);
        let kind_eof_b: i32 = g_pp_kind;
        if (kind_eof_b != 0) {
          let cond_val_eof_b: i32 = 0;
          if (pp_kind_needs_cond(kind_eof_b)) {
            cond_val_eof_b = pp_eval_condition(&g_pp_cond[0], g_pp_sym_len);
          }
          let ar_eof_b: i32 = preprocess_apply_directive_kind(kind_eof_b, cond_val_eof_b);
          if (ar_eof_b != 0) {
            return ar_eof_b;
          }
          if (out_len >= out_cap) {
            return -1;
          }
          out_buf[out_len] = 10;
          out_len = out_len + 1;
        } else {
          let keeping_eof_b: bool = preprocess_line_keeping();
          if (keeping_eof_b) {
            let i_eof_b: i32 = 0;
            while (i_eof_b < line_len) {
              if (out_len >= out_cap) {
                return -1;
              }
              out_buf[out_len] = g_pp_line_buf[i_eof_b];
              out_len = out_len + 1;
              i_eof_b = i_eof_b + 1;
            }
          }
          if (out_len >= out_cap) {
            return -1;
          }
          out_buf[out_len] = 10;
          out_len = out_len + 1;
        }
        line_len = 0;
      }
    }
  }
  if (pp_if_stack_len() != 0) {
    return -1;
  }
  return out_len;
}
