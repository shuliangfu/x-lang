/* Host-gcc twin of typool parser_asm_ctrl_find_then_lbrace
 * (pthin_ctrl.x 735-763). typool leftover W (fromsrc_s118_noaslr
 * 0x14048d7d4) typool-wrongs if (c == 123 && par == 0) break as
 * jmp typool 0x14048d818 (loop head) at typool 0x14048d998
 * (find_then+452). Live GDB on fromsrc_s118_noaslr check
 * examples/hello.x (repo cwd): typool leftover find_then entered at
 * start=1228 for `if (cap < 1) { return -1; }` in core.fmt; skip
 * advanced 1228/1229/1230 correctly; typool leftover skip later
 * stayed at i=1238 (`{`) while typool leftover find_then+452 fired
 * repeatedly and typool leftover find_then never left. typool leftover
 * skip_comment_or_quote / typool leftover skip_braces / typool leftover
 * ident_continue / typool leftover else_at / typool leftover realign /
 * typool rec / typool fputc wholesale are not in this thin (skip
 * stays extern). docs-only .x, do not idx8. Do not JMP typool rec T
 * 0x140087de4. */
#include <stdint.h>

extern uint64_t parser_asm_ctrl_skip_comment_or_quote(uint8_t *data,
                                                      uint64_t len,
                                                      uint64_t i);

uint64_t parser_asm_ctrl_find_then_lbrace(uint8_t *data, uint64_t len,
                                          uint64_t start) {
  uint64_t i;
  int32_t par;
  uint8_t c;
  uint64_t skipped;

  i = start;
  par = 0;
  c = 0;
  skipped = 0;
  while (i < len) {
    skipped = parser_asm_ctrl_skip_comment_or_quote(data, len, i);
    if (skipped != i) {
      i = skipped;
      continue;
    }
    c = data[i];
    if (c == 40) {
      par = par + 1;
    } else {
      if (c == 41 && par > 0) {
        par = par - 1;
      } else {
        if (c == 123 && par == 0) {
          break;
        }
      }
    }
    i = i + 1;
  }
  return i;
}
