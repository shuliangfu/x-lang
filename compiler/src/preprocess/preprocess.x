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

// preprocess.x — 条件编译预处理（#if / #else / #elseif / #endif）纯 .x 实现
//
// 职责：按行扫描源码，识别 #if COND、#else、#elseif、#endif，根据 defines / target_os 保留或跳过块；被跳过行输出换行以保持行号。
// 约定：与 preprocess.c 一致；COND 可为 -D 宏或 target_os == "linux" 等（经 preprocess_eval_condition_c）；嵌套栈在 ast_pool grow 池。

/** #if/#else 嵌套栈 grow 池（ast_pool.c）。 */
extern function preprocess_if_stack_reset(): void;
extern function preprocess_if_stack_len(): i32;
extern function preprocess_if_stack_push(v: i32): i32;
extern function preprocess_if_stack_pop(): void;
extern function preprocess_if_stack_at(i: i32): i32;
extern function preprocess_if_stack_set_at(i: i32, v: i32): void;

/** 求值 #if COND（C bridge：-D 宏 + target_os/target_arch，与 #[cfg] 对齐）。 */
extern function preprocess_eval_condition_c(cond: *u8, cond_len: i32): i32;

/**
 * 全局解析结果（替代 *ParseDirectiveResult 指针参数）。
 * 【Why】shux -E 丢弃含 *Struct 指针参数 + 字段写入的函数体；用全局变量绕过。
 */
let g_pp_kind: i32 = 0;
let g_pp_sym_len: i32 = 0;

/** 全局行缓冲和条件缓冲（替代局部 u8[512]/u8[256]，避免 -E hoisting 问题）。 */
let g_pp_line_buf: u8[512] = [];
let g_pp_cond: u8[256] = [];

/**
 * -E unsafe wrappers：typeck 要求 extern 调用须在 unsafe 块内。
 * helper 函数内 unsafe 块仅含单条 extern 调用 + return，无 let+if 组合，
 * 避免 shux -E 丢弃函数体。
 */
function pp_if_stack_reset(): void {
  unsafe {
    preprocess_if_stack_reset();
  }
}
function pp_if_stack_len(): i32 {
  unsafe {
    return preprocess_if_stack_len();
  }
  return 0;
}
function pp_if_stack_push(v: i32): i32 {
  unsafe {
    return preprocess_if_stack_push(v);
  }
  return 0;
}
function pp_if_stack_at(i: i32): i32 {
  unsafe {
    return preprocess_if_stack_at(i);
  }
  return 0;
}
function pp_if_stack_set_at(i: i32, v: i32): void {
  unsafe {
    preprocess_if_stack_set_at(i, v);
  }
}
function pp_if_stack_pop(): void {
  unsafe {
    preprocess_if_stack_pop();
  }
}
function pp_eval_condition(cond: *u8, cond_len: i32): i32 {
  unsafe {
    return preprocess_eval_condition_c(cond, cond_len);
  }
  return 0;
}

/**
 * pp_if_stack_reset 的 i32 包装。
 * 【Why】void 函数调用在函数体顶层会导致 shux -E 丢弃后续所有语句；
 * 包装为 i32 返回 + let 赋值可避免此问题。
 */
function pp_reset_i32(): i32 {
  unsafe {
    preprocess_if_stack_reset();
  }
  return 0;
}

/** kind == 1 (#if) 或 kind == 4 (#elseif) 需求值 COND；消除 || 的 helper。 */
function pp_kind_needs_cond(kind: i32): bool {
  if (kind == 1) { return true; }
  if (kind == 4) { return true; }
  return false;
}

/** ch 是否为空白（空格 32 / 制表符 9）。 */
function pp_is_ws(ch: u8): bool {
  if (ch == 32) { return true; }
  if (ch == 9) { return true; }
  return false;
}

/** ch 是否为行尾（LF 10 / CR 13）。 */
function pp_is_eol(ch: u8): bool {
  if (ch == 10) { return true; }
  if (ch == 13) { return true; }
  return false;
}

/** ch 是否为空白/行尾/NUL（词边界终止符）。 */
function pp_is_token_end(ch: u8): bool {
  if (ch == 32) { return true; }
  if (ch == 9) { return true; }
  if (ch == 10) { return true; }
  if (ch == 13) { return true; }
  if (ch == 0) { return true; }
  return false;
}

/** pos 是否越界或 buf[pos] 为指定字节；消除 || 的 helper。 */
function pp_at_end_or_not_byte(buf: *u8, pos: i32, line_len: i32, target: u8): bool {
  if (pos >= line_len) { return true; }
  if (buf[pos] != target) { return true; }
  return false;
}

/** pos 是否在行内且 buf[pos] 非词边界终止符（词边界检查）。消除 && 的 helper。 */
function pp_is_word_boundary(buf: *u8, pos: i32, line_len: i32): bool {
  if (pos >= line_len) { return false; }
  let ch: u8 = buf[pos];
  if (pp_is_token_end(ch)) { return false; }
  return true;
}

/** pos 是否越界或 buf[pos] 为词边界终止符。消除 || 的 helper。 */
function pp_at_end_or_token_end(buf: *u8, pos: i32, line_len: i32): bool {
  if (pos >= line_len) { return true; }
  let ch: u8 = buf[pos];
  if (pp_is_token_end(ch)) { return true; }
  return false;
}

/** buf[pos..] 是否匹配 "if" (105,102)，且 pos+2 <= line_len。 */
function pp_match_if(buf: *u8, pos: i32, line_len: i32): bool {
  if (pos + 2 > line_len) { return false; }
  if (buf[pos] != 105) { return false; }
  if (buf[pos + 1] != 102) { return false; }
  return true;
}

/** buf[pos..] 是否匹配 "elseif" (101,108,115,101,105,102)，且 pos+6 <= line_len。 */
function pp_match_elseif(buf: *u8, pos: i32, line_len: i32): bool {
  if (pos + 6 > line_len) { return false; }
  if (buf[pos] != 101) { return false; }
  if (buf[pos + 1] != 108) { return false; }
  if (buf[pos + 2] != 115) { return false; }
  if (buf[pos + 3] != 101) { return false; }
  if (buf[pos + 4] != 105) { return false; }
  if (buf[pos + 5] != 102) { return false; }
  return true;
}

/** buf[pos..] 是否匹配 "else" (101,108,115,101)，且 pos+4 <= line_len。 */
function pp_match_else(buf: *u8, pos: i32, line_len: i32): bool {
  if (pos + 4 > line_len) { return false; }
  if (buf[pos] != 101) { return false; }
  if (buf[pos + 1] != 108) { return false; }
  if (buf[pos + 2] != 115) { return false; }
  if (buf[pos + 3] != 101) { return false; }
  return true;
}

/** buf[pos..] 是否匹配 "endif" (101,110,100,105,102)，且 pos+5 <= line_len。 */
function pp_match_endif(buf: *u8, pos: i32, line_len: i32): bool {
  if (pos + 5 > line_len) { return false; }
  if (buf[pos] != 101) { return false; }
  if (buf[pos + 1] != 110) { return false; }
  if (buf[pos + 2] != 100) { return false; }
  if (buf[pos + 3] != 105) { return false; }
  if (buf[pos + 4] != 102) { return false; }
  return true;
}

/**
 * 处理一条预处理指令对嵌套栈的影响；cond_val 为 #if/#elseif 条件真值（0/1）。
 * 成功 0，失败 -1。
 */
function preprocess_apply_directive_kind(kind: i32, cond_val: i32): i32 {
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
    return pp_if_stack_push(v);
  }
  if (kind == 2) {
    if (depth == 0) {
      return -1;
    }
    let di: i32 = depth - 1;
    let top: i32 = pp_if_stack_at(di);
    if (top == 1) {
      pp_if_stack_set_at(di, 0);
    } else if (top == 0) {
      pp_if_stack_set_at(di, 2);
    }
    return 0;
  }
  if (kind == 4) {
    if (depth == 0) {
      return -1;
    }
    let di2: i32 = depth - 1;
    let top2: i32 = pp_if_stack_at(di2);
    if (top2 == 2) {
      return -1;
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
    return -1;
  }
  pp_if_stack_pop();
  return 0;
}

/** 当前嵌套栈顶是否应保留源码行（非指令行）。 */
function preprocess_line_keeping(): bool {
  let depth: i32 = pp_if_stack_len();
  if (depth == 0) {
    return true;
  }
  let top: i32 = pp_if_stack_at(depth - 1);
  // 消除 ||：shux -E 会丢弃含 || 的函数体
  if (top == 1) {
    return true;
  }
  if (top == 2) {
    return true;
  }
  return false;
}

/** 解析指令结果：kind 0=非指令 1=#if 2=#else 3=#endif 4=#elseif；sym_len 为 COND 字节数。 */
struct ParseDirectiveResult {
  kind: i32;
  sym_len: i32;
}

/**
 * 从 line_buf[pos..line_len) 拷贝条件到 cond，返回写入长度。
 */
function parse_copy_cond_from_line(cond: u8[256], line_buf: u8[512], pos: i32, line_len: i32): i32 {
  let s: i32 = 0;
  while (pos < line_len) {
    if (s >= 255) {
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
 * 解析一行是否为指令；结果写入全局 g_pp_kind / g_pp_sym_len。
 * 【Why】shux -E 丢弃含 *ParseDirectiveResult 指针参数 + 字段写入的函数体；
 * 改用全局变量绕过。消除所有 &&/||，用 helper 函数替代。
 */
function parse_directive_into(line_buf: u8[512], line_len: i32, cond: u8[256]): void {
  let pos: i32 = 0;
  g_pp_kind = 0;
  g_pp_sym_len = 0;
  // 跳过行首空白
  while (pos < line_len) {
    let ws0: u8 = line_buf[pos];
    if (pp_is_ws(ws0)) {
      pos = pos + 1;
    } else {
      break;
    }
  }
  // 检查 # (35)
  if (pp_at_end_or_not_byte(line_buf, pos, line_len, 35 as u8)) {
    return;
  }
  pos = pos + 1;
  // 跳过 # 后空白
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

/** 主入口：对 source 做条件编译，结果写入 out_buf，返回输出长度，失败返回 -1。 */
function preprocess_x(source: u8[], out_buf: u8[]): i32 {
  if (out_buf.length <= 0) {
    return -1;
  }
  let _r: i32 = pp_reset_i32();
  let out_len: i32 = 0;
  let line_len: i32 = 0;
  let pos: i32 = 0;
  while (pos < source.length) {
    let ch: u8 = source[pos];
    if (ch == 10) {
        parse_directive_into(g_pp_line_buf, line_len, g_pp_cond);
        let kind: i32 = g_pp_kind;
        if (kind != 0) {
          let cond_val: i32 = 0;
          if (pp_kind_needs_cond(kind)) {
            cond_val = pp_eval_condition(&g_pp_cond[0], g_pp_sym_len);
          }
          if (preprocess_apply_directive_kind(kind, cond_val) != 0) {
            return -1;
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
    } else {
      if (line_len < 511) {
        g_pp_line_buf[line_len] = ch;
        line_len = line_len + 1;
      }
      pos = pos + 1;
    }
  }
  if (pp_if_stack_len() != 0) {
    return -1;
  }
  return out_len;
}

/** 6.1 完全自举：用固定数组+长度调用预处理逻辑，不依赖 slice 构造；供 pipeline.x 在 read_file_x 后调用。与 runtime PIPELINE_CTX_BUF_SIZE 一致（4MiB）。 */
function preprocess_x_buf(source_buf: u8[4194304], source_len: isize, out_buf: u8[4194304], out_cap: i32): i32 {
  if (out_cap <= 0) {
    return -1;
  }
  let _r: i32 = pp_reset_i32();
  let out_len: i32 = 0;
  let line_len: i32 = 0;
  let pos: i32 = 0;
  while (pos < source_len) {
    if (pos >= 4194304) {
      break;
    }
    let ch: u8 = source_buf[pos];
    if (ch == 10) {
        parse_directive_into(g_pp_line_buf, line_len, g_pp_cond);
        let kind: i32 = g_pp_kind;
        if (kind != 0) {
          let cond_val: i32 = 0;
          if (pp_kind_needs_cond(kind)) {
            cond_val = pp_eval_condition(&g_pp_cond[0], g_pp_sym_len);
          }
          if (preprocess_apply_directive_kind(kind, cond_val) != 0) {
            return -1;
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
    } else {
      if (line_len < 511) {
        g_pp_line_buf[line_len] = ch;
        line_len = line_len + 1;
      }
      pos = pos + 1;
    }
  }
  if (pp_if_stack_len() != 0) {
    return -1;
  }
  return out_len;
}
