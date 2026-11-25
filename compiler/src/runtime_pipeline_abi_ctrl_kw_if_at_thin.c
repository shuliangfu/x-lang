/* Host-gcc twin of typool parser_asm_ctrl_kw_if_at
 * (pthin_ctrl.x 605-622). typool leftover W (fromsrc_s115_noaslr
 * 0x14048cb00) typool-wrongs data[i] / data[i+1] as scale-8 through
 * &data (lea rax,[rbp-0x10]; lea rax,[rax+i*8]), so a genuine `if`
 * never matches 105/102 and typool leftover kw_at_pos_buf_c is never
 * called. Live GDB on fromsrc_s115_noaslr check examples/hello.x
 * (repo cwd): first-wins scan_sync thin start=5204 (`if (cap < 4)`
 * in core.fmt fmt_bool_to_buf) calls typool leftover kw_if_at 513
 * times, every leave eax=0, thin returns 5204; typool leftover
 * scan_ptr then returns 0 and typool leftover realign rewinds lex
 * from 5231 to 5219 (parse skip at byte 5231). typool leftover
 * kw_at_pos_buf_c / typool leftover ctrl_kw_else_at / typool leftover
 * realign / typool leftover if_stmt_x / typool leftover
 * find_then_lbrace / typool leftover skip_braces / typool rec /
 * typool fputc wholesale are not in this thin (kw_at_pos stays
 * extern). docs-only .x, do not idx8. Do not JMP typool rec T
 * 0x140087de4. */
#include <stdint.h>

extern int32_t parser_asm_kw_at_pos_buf_c(uint8_t *data, uint64_t len,
                                          uint64_t i, uint8_t *kw,
                                          int32_t klen);

int32_t parser_asm_ctrl_kw_if_at(uint8_t *data, uint64_t len, uint64_t i) {
  uint8_t a;
  uint8_t b;

  if (data == 0 || i + 2 > len) {
    return 0;
  }
  a = data[i];
  b = data[i + 1];
  if (a != 105 || b != 102) {
    return 0;
  }
  return parser_asm_kw_at_pos_buf_c(data, len, i, data + i, 2);
}
