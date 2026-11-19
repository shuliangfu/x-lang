/* Host-gcc twin of typool parser_asm_kw_at_pos_buf_c
 * (pthin_ctrl.x 505-593). typool leftover W (fromsrc_s117_noaslr
 * 0x14048c438) typool-wrongs nx=data[next_pos] as scale-8 through
 * &data (lea rax,[rbp-0x10]; lea rax,[rax+next_pos*8]) and typool-wrongs
 * kw[0]==105 as comparing the kw pointer itself to 0x69. Live GDB on
 * fromsrc_s117_noaslr check examples/hello.x (repo cwd): at i=5204
 * (`if (cap < 4)` in core.fmt fmt_bool_to_buf) first-wins skip_ws
 * correctly returns 5207, but nx slot is 0 (should be '('=40) and
 * is_if compares ebx=kw_ptr vs 0x69, so the non-if arm rejects nx
 * and typool leftover kw_at_pos returns 0.
 * typool leftover ident_continue / typool leftover realign / typool
 * leftover ctrl_kw_else_at / typool rec / typool fputc wholesale are
 * not in this thin (bytes_eq, ident_continue, skip_ws stay extern). docs-only .x, do not idx8. Do not JMP typool rec T
 * 0x140087de4. */
#include <stdint.h>

extern int32_t parser_asm_ctrl_bytes_eq(uint8_t *data, uint64_t len,
                                        uint64_t i, uint8_t *kw,
                                        int32_t klen);
extern int32_t parser_asm_ctrl_ident_continue(uint8_t c);
extern uint64_t parser_asm_stretch_skip_ws_and_comments_c(uint8_t *data,
                                                          uint64_t len,
                                                          uint64_t pos);

int32_t parser_asm_kw_at_pos_buf_c(uint8_t *data, uint64_t len, uint64_t i,
                                   uint8_t *kw, int32_t klen) {
  uint64_t next_pos;
  uint8_t prev;
  uint8_t nx;
  uint64_t nlen;
  int32_t is_if;
  int32_t is_else;
  uint8_t a;
  uint8_t b;

  if (data == 0 || kw == 0 || klen <= 0) {
    return 0;
  }
  nlen = (uint64_t)klen;
  if (i + nlen > len) {
    return 0;
  }
  if (parser_asm_ctrl_bytes_eq(data, len, i, kw, klen) == 0) {
    return 0;
  }
  if (i > 0) {
    prev = data[i - 1];
    if (parser_asm_ctrl_ident_continue(prev) != 0) {
      return 0;
    }
  }
  if (i + nlen < len) {
    next_pos = parser_asm_stretch_skip_ws_and_comments_c(data, len, i + nlen);
    if (next_pos < len) {
      nx = data[next_pos];
      if (klen == 2) {
        is_if = 0;
        if (kw[0] == 105 && kw[1] == 102) {
          is_if = 1;
        }
        if (is_if != 0) {
          if (nx == 125 || nx == 59 || nx == 44) {
            return 0;
          }
        } else {
          if (nx != 40 && nx != 123 && nx != 59) {
            return 0;
          }
        }
      } else {
        if (klen == 4) {
          is_else = 0;
          if (kw[0] == 101 && kw[1] == 108 && kw[2] == 115 && kw[3] == 101) {
            is_else = 1;
          }
          if (is_else != 0) {
            if (nx != 123 && nx != 59) {
              if (next_pos + 2 > len) {
                return 0;
              }
              a = data[next_pos];
              b = data[next_pos + 1];
              if (a != 105 || b != 102) {
                return 0;
              }
            }
          } else {
            if (nx != 40 && nx != 123 && nx != 59) {
              return 0;
            }
          }
        } else {
          if (nx != 40 && nx != 123 && nx != 59) {
            return 0;
          }
        }
      }
    }
  }
  return 1;
}
