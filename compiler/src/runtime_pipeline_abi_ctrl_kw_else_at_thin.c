/* Host-gcc twin of typool parser_asm_ctrl_kw_else_at
 * (pthin_ctrl.x 633-655). typool leftover W (s122_noaslr
 * 0x14048db28, no first-wins T) typool-wrongs data[i] /
 * data[i+1] / data[i+2] / data[i+3] as qword *(&local_data +
 * index) (lea rax,[rbp-0x10]; lea rax,[rax+rbx*8];
 * mov rax,[rax] into [rbp-0x30] and the following n slots)
 * instead of byte data[i] (mov rax,[rbp-0x10]; movzx eax,
 * byte [rax+rbx]). On examples/hello.x after skip_comment and
 * skip_braces thins are JMP'd, typool leftover is reached at
 * i=8332 (`i` of `if (x == 0.0)` in core.fmt, after skip_braces
 * correctly crossed the is_nan then-block) and the first load
 * computes (rbp-0x10)+8332*8, which sometimes AVs
 * (RIP 0x14048dbe5, AVADDR 0x10404f30) and sometimes reads
 * stack garbage so a later parse skip regresses (e.g. 3685).
 * host-cc and the typool source must load the four real source
 * bytes, reject anything other than `else`, and otherwise call
 * parser_asm_kw_at_pos_buf_c (already a first-wins thin) with
 * klen=4. typool leftover ident_continue / typool leftover
 * realign / typool leftover if_stmt_x / typool leftover
 * parse_block / typool leftover parse_one_function_impl /
 * typool leftover scan_sync_pos wholesale / typool leftover
 * find_then / typool leftover kw_if_at / typool leftover
 * bytes_eq / typool leftover kw_at_pos wholesale / typool rec
 * / typool fputc are not in this thin (kw_at_pos stays
 * extern). docs-only .x, do not idx8. Do not JMP typool rec T
 * 0x140087de4. */
#include <stdint.h>

extern int32_t parser_asm_kw_at_pos_buf_c(uint8_t *data, uint64_t len,
                                          uint64_t i, uint8_t *kw,
                                          int32_t klen);

int32_t parser_asm_ctrl_kw_else_at(uint8_t *data, uint64_t len, uint64_t i) {
  uint8_t a;
  uint8_t b;
  uint8_t c;
  uint8_t d;

  if (data == 0 || i + 4 > len) {
    return 0;
  }
  a = data[i];
  b = data[i + 1];
  c = data[i + 2];
  d = data[i + 3];
  if (a != 101 || b != 108 || c != 115 || d != 101) {
    return 0;
  }
  return parser_asm_kw_at_pos_buf_c(data, len, i, data + i, 4);
}
