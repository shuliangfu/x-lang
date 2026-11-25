/* Host-gcc twin of typool parser_asm_stretch_skip_ws_and_comments_c
 * (pthin_stretch.x). typool first-wins W (fromsrc_s96 0x1404a6524)
 * typool-wrongs the inner `if (not ws) break;` as jmp typool 0x1404a65d1
 * (inner while-head) at typool writer RIP 0x1404a6702, so a non-ws byte
 * never leaves the p < len loop. The same typool body also typool-wrongs
 * the outer `if (moved == 0) break;` so both arms jmp typool 0x1404a65b2
 * (writer RIPs typool 0x1404a677f / typool 0x1404a678e); that outer
 * typool-wrong is not reached on this hang. Live GDB on
 * fromsrc_s96_noaslr check examples/hello.x (repo cwd): two clean 6s
 * timed runs still alive, no output (real hang, not an alarm artifact).
 * SKIP_ENTER n=1 data=hello.x len=233 pos=0; WRONG_BREAK_JMP n=1..79
 * p=0 c=47 ('/'); INNER_HEAD n=80 p still 0; CONT=0; SKIP_COMMENT_CALL=0;
 * SKIP_RET=0. typool tip / skip_function / append_i32 / fputc /
 * try_keyword_c / typool rec / typool body_into / typool
 * skip_comment_at wholesale are not in this thin. typool
 * parser_asm_stretch_skip_comment_at_c is called as extern (not reached
 * on this hang). docs-only .x, do not idx8. Do not JMP typool rec T
 * 0x140087de4. */
#include <stdint.h>

extern uint64_t parser_asm_stretch_skip_comment_at_c(uint8_t *data,
                                                     uint64_t len,
                                                     uint64_t pos);

uint64_t parser_asm_stretch_skip_ws_and_comments_c(uint8_t *data,
                                                   uint64_t len,
                                                   uint64_t pos) {
  uint64_t p;
  uint64_t np;
  int32_t moved;
  uint8_t c;

  if (data == 0 || len == 0)
    return pos;
  p = pos;
  while (1) {
    moved = 0;
    while (p < len) {
      c = data[p];
      if (c == 32 || c == 9 || c == 10 || c == 13) {
        p = p + 1;
        moved = 1;
        continue;
      }
      break;
    }
    np = parser_asm_stretch_skip_comment_at_c(data, len, p);
    if (np != p) {
      p = np;
      moved = 1;
    }
    if (moved == 0)
      break;
  }
  return p;
}
