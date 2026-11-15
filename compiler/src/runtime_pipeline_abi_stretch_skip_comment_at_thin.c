/* Host-gcc twin of typool parser_asm_stretch_skip_comment_at_c
 * (pthin_stretch.x). typool first-wins W (fromsrc_s97 0x1404a625c)
 * typool-wrongs the line-comment `if (data[i] == 10 || data[i] == 13)
 * break;` as jmp typool 0x1404a638c (while-head) at typool writer RIP
 * 0x1404a6414, so i sticks on the newline and never returns.
 * Live GDB on fromsrc_s97_noaslr check examples/hello.x (repo cwd):
 * two clean 6s timed runs still alive, no output (real hang, not an
 * alarm artifact). CMT_ENTER n=1 pos=0 data="// H..."; LINE_HEAD i
 * advances 2..61 (INC=61); WRONG_BREAK_JMP n=1..18 i=63 c=10 (first
 * newline of hello.x); LINE_HEAD n=80 i still 63; CMT_RET=0. typool tip
 * / skip_function / append_i32 / fputc / try_keyword_c / typool rec /
 * typool body_into / typool skip_ws wholesale are not in this thin.
 * docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

uint64_t parser_asm_stretch_skip_comment_at_c(uint8_t *data, uint64_t len,
                                              uint64_t pos) {
  uint64_t i;

  if (data == 0)
    return pos;
  if (pos + 1 >= len)
    return pos;
  if (data[pos] == 47 && data[pos + 1] == 47) {
    i = pos + 2;
    while (i < len) {
      if (data[i] == 10 || data[i] == 13)
        break;
      i = i + 1;
    }
    return i;
  }
  if (data[pos] == 47 && data[pos + 1] == 42) {
    i = pos + 2;
    while (i + 1 < len) {
      if (data[i] == 42 && data[i + 1] == 47)
        return i + 2;
      i = i + 1;
    }
    return len;
  }
  return pos;
}
