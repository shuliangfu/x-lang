/* Host-gcc twin of fmt_path_ends_with_dot_x (fmt_check_cmd_thin.x).
 * typool first-wins W 0x140249918 compiles path[i] / path[i-2] /
 * path[i-1] as scale-8 qword loads through &path:
 *   lea rax,[rbp-0x10]; lea rax,[rax+rbx*8]; mov rax,QWORD PTR [rax]
 * Writer sites typool 0x140249978 / 0x1402499e6 / 0x140249a1c (s74
 * VAs; s74 typool W 0x140249918). GDB: typool returns eax=0 twice
 * on the real abs .../examples/hello.x (should be 1), so typool
 * file_list_push skips the store and check reports CHK002
 * "no .x files found". Host-gcc twin indexes *u8 directly.
 * docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

int32_t fmt_path_ends_with_dot_x(uint8_t *path) {
  int32_t i;

  if (path == 0)
    return 0;
  i = 0;
  while (i < 4096) {
    if (path[i] == 0) {
      if (i < 2)
        return 0;
      if (path[i - 2] == 46) {
        if (path[i - 1] == 120)
          return 1;
      }
      return 0;
    }
    i = i + 1;
  }
  return 0;
}
