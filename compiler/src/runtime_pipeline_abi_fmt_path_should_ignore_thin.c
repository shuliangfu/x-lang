/* Host-gcc twin of path_should_ignore (fmt_check_cmd_thin.x).
 * typool first-wins W 0x14024be08 compiles `if (b == 0) break` as
 * `jmp 0x14024be6d` (the while-head) instead of the loop exit at
 * 0x14024bf78. Writer RIP typool 0x14024beba. After the already-
 * folded thin fmt_path_resolve_abs, `check examples/hello.x` enters
 * typool path_should_ignore with the abs path in g_fmt_check_path_bss
 * slot 1; i=0..8 are fine, then fmt_builtin_ignore_at(9) returns
 * NULL and typool "break" spins at i=9 (~100% CPU). Prior smashed
 * sample inside typool fmt_builtin_ignore_at 0x1402490cd was mid-
 * dispatch of that spinning call, not the writer. Host-gcc twin
 * breaks out of the loop. docs-only .x, do not idx8. Do not JMP
 * typool rec T 0x140087de4. */
#include <stdint.h>
#include <string.h>

extern int32_t fmt_path_ends_with_dot_x(uint8_t *path);
extern uint8_t *fmt_builtin_ignore_at(int32_t i);
extern int32_t fmt_user_ignore_count(void);
extern uint8_t *fmt_user_ignore_at(int32_t i);

int32_t path_should_ignore(uint8_t *path) {
  int32_t is_dot_x, i, n, j;
  uint8_t *b, *u;

  if (path == 0)
    return 1;
  is_dot_x = fmt_path_ends_with_dot_x(path);
  i = 0;
  while (i < 32) {
    b = fmt_builtin_ignore_at(i);
    if (b == 0)
      break;
    if (strstr((char *)path, (char *)b) != 0) {
      if (i == 8) {
        if (is_dot_x != 0) {
          i = i + 1;
          continue;
        }
      }
      return 1;
    }
    i = i + 1;
  }
  n = fmt_user_ignore_count();
  j = 0;
  while (j < n) {
    u = fmt_user_ignore_at(j);
    if (u != 0) {
      if (u[0] != 0) {
        if (strstr((char *)path, (char *)u) != 0)
          return 1;
      }
    }
    j = j + 1;
  }
  return 0;
}
