/* Host-gcc twin of typool parser_asm_ctrl_skip_comment_or_quote
 * (pthin_ctrl.x 667-725). typool leftover W indexes data[i] as
 * qword *(&local_data + i) (lea [rbp-0x10]; lea [rax+rbx*8];
 * mov rax,[rax] into [rbp-0x30]) instead of byte data[i]
 * (mov rax,[rbp-0x10]; movzx eax, byte [rax+rbx]). The same
 * typool-wrong scale-8 load is used for data[i+1]. On
 * examples/hello.x pass-2 second cap<4, i=8767 (`(` of
 * `if (cap < 4) { return -1; }` in core.fmt) typool leftover
 * therefore reads caller stack at rbp+70120, mis-classifies a
 * comment or unclosed quote, and returns len=13093; host-cc and
 * the typool source must return i unchanged. Later typool comment
 * and quote loops already use correct scale-1+movzx; they are not
 * folded here. typool leftover skip_braces / typool leftover
 * else_at / typool leftover realign / typool leftover find_then
 * wholesale / typool rec / typool fputc are not in this thin.
 * docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

uint64_t parser_asm_ctrl_skip_comment_or_quote(uint8_t *data, uint64_t len,
                                               uint64_t i) {
  uint8_t c;
  uint8_t n;
  uint8_t q;

  c = 0;
  n = 0;
  q = 0;
  c = data[i];
  if (c == 47 && i + 1 < len) {
    n = data[i + 1];
    if (n == 47) {
      i = i + 2;
      while (i < len) {
        c = data[i];
        if (c == 10) {
          break;
        }
        i = i + 1;
      }
      return i;
    }
    if (n == 42) {
      i = i + 2;
      while (i + 1 < len) {
        c = data[i];
        n = data[i + 1];
        if (c == 42 && n == 47) {
          break;
        }
        i = i + 1;
      }
      if (i + 1 < len) {
        i = i + 2;
      } else {
        i = len;
      }
      return i;
    }
  }
  if (c == 34 || c == 39) {
    q = c;
    i = i + 1;
    while (i < len) {
      c = data[i];
      if (c == q) {
        break;
      }
      if (c == 92 && i + 1 < len) {
        i = i + 2;
        continue;
      }
      i = i + 1;
    }
    if (i < len) {
      i = i + 1;
    }
    return i;
  }
  return i;
}
