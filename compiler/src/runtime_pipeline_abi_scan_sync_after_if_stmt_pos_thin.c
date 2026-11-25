/* Host-gcc twin of typool parser_asm_scan_sync_after_if_stmt_pos_c
 * (pthin_ctrl.x 781-882). typool leftover W (fromsrc_s111_noaslr
 * 0x14048cfd8) typool-wrongs both inner-loop breaks as jmp typool
 * 0x14048d0e5 (inner while-head): writer typool 0x14048d1a9 after
 * found=1 / cond_start=probe, and typool 0x14048d1d6 after
 * if_pos == lo. Live GDB attach on fromsrc_s111_noaslr check
 * examples/hello.x (repo cwd) at ~5s: still alive, empty log, main
 * thread RIP typool 0x14048d11e (if_hit check, rdx=len=13093 =
 * core/fmt/mod.x). typool rec / typool fputc / typool
 * lexer_next_body_into / typool ctrl_kw_if_at / typool
 * find_then_lbrace / typool skip_balanced_braces / typool
 * ctrl_kw_else_at wholesale are not in this thin (helpers stay
 * extern). docs-only .x, do not idx8. Do not JMP typool rec T
 * 0x140087de4. */
#include <stdint.h>

extern int32_t parser_asm_ctrl_kw_if_at(uint8_t *data, uint64_t len, uint64_t i);
extern int32_t parser_asm_ctrl_kw_else_at(uint8_t *data, uint64_t len, uint64_t i);
extern uint64_t parser_asm_ctrl_find_then_lbrace(uint8_t *data, uint64_t len, uint64_t start);
extern uint64_t parser_asm_skip_balanced_braces_bytes_comment_aware_c(uint8_t *data, uint64_t len, uint64_t start);
extern uint64_t parser_asm_stretch_skip_ws_and_comments_c(uint8_t *data, uint64_t len, uint64_t pos);

uint64_t parser_asm_scan_sync_after_if_stmt_pos_c(uint8_t *data,
                                                  uint64_t len,
                                                  uint64_t start_pos) {
  uint64_t cur;
  uint64_t if_pos;
  uint64_t lo;
  uint64_t cond_start;
  uint64_t probe;
  uint64_t i;
  int32_t found;
  int32_t if_hit;
  int32_t else_hit;
  int32_t nested_if;
  uint8_t c;

  if (data == 0) {
    return start_pos;
  }
  cur = start_pos;
  while (1) {
    if_pos = cur;
    lo = 0;
    if (if_pos > 512) {
      lo = if_pos - 512;
    }
    found = 0;
    cond_start = 0;
    while (1) {
      if_hit = parser_asm_ctrl_kw_if_at(data, len, if_pos);
      if (if_hit != 0) {
        probe = parser_asm_stretch_skip_ws_and_comments_c(data, len, if_pos + 2);
        if (probe < len) {
          found = 1;
          cond_start = probe;
          break;
        }
      }
      if (if_pos == lo) {
        break;
      }
      if_pos = if_pos - 1;
    }
    if (found == 0) {
      return cur;
    }
    i = parser_asm_ctrl_find_then_lbrace(data, len, cond_start);
    i = parser_asm_stretch_skip_ws_and_comments_c(data, len, i);
    if (i >= len) {
      return cur;
    }
    c = data[i];
    if (c != 123) {
      return cur;
    }
    i = parser_asm_skip_balanced_braces_bytes_comment_aware_c(data, len, i);
    i = parser_asm_stretch_skip_ws_and_comments_c(data, len, i);
    else_hit = 0;
    if (i + 4 <= len) {
      else_hit = parser_asm_ctrl_kw_else_at(data, len, i);
    }
    if (else_hit != 0) {
      i = parser_asm_stretch_skip_ws_and_comments_c(data, len, i + 4);
      if (i < len) {
        c = data[i];
        if (c == 123) {
          i = parser_asm_skip_balanced_braces_bytes_comment_aware_c(data, len, i);
        } else {
          nested_if = 0;
          if (i + 2 <= len) {
            nested_if = parser_asm_ctrl_kw_if_at(data, len, i);
          }
          if (nested_if != 0) {
            cur = i;
            continue;
          }
        }
      }
    }
    i = parser_asm_stretch_skip_ws_and_comments_c(data, len, i);
    return i;
  }
  return cur;
}
