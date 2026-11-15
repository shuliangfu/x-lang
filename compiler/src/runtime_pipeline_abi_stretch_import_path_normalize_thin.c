/* Host-gcc twin of typool parser_asm_stretch_import_path_normalize_c
 * (pthin_stretch.x). typool first-wins W (fromsrc_s95 T/W 0x1404a5d40)
 * copies "std.fmt" correctly (out_len=7, i=7) then typool-wrongs the
 * trailing-dot trim: `if (last != 46) break;` is compiled as
 * jmp typool 0x1404a5f79 (while-head) at typool writer RIP 0x1404a5fe5
 * instead of breaking to typool 0x1404a6008 / ret typool 0x1404a6019.
 * Live GDB on fromsrc_s95_noaslr check examples/hello.x (repo cwd):
 * two clean 6s timed runs still alive, no output (real hang, not an
 * alarm artifact). NORM_ENTER n=1 buf="std.fmt" len=7; TRAIL_TEST eax=1
 * last=116 ('t') out_len=7; WRONG_JMP n=1..11 out_len stays 7; TRAIL_DEC=0;
 * NORM_RET=0. typool tip / skip_function / append_i32 / fputc /
 * try_keyword_c / typool rec / typool body_into wholesale are not in
 * this thin. ident_continue_ok is inlined. typool
 * parser_asm_stretch_import_path_validate_c is called as extern (already
 * returned nonzero on this path). docs-only .x, do not idx8. Do not JMP
 * typool rec T 0x140087de4. */
#include <stdint.h>

extern int32_t parser_asm_stretch_import_path_validate_c(uint8_t *path_buf,
                                                         int32_t path_len);

static int32_t stretch_ident_continue_ok(uint8_t c) {
  if (c == 95)
    return 1;
  if (c >= 48 && c <= 57)
    return 1;
  if (c >= 65 && c <= 90)
    return 1;
  if (c >= 97 && c <= 122)
    return 1;
  return 0;
}

int32_t parser_asm_stretch_import_path_normalize_c(uint8_t *path_buf,
                                                   int32_t path_len) {
  int32_t i;
  int32_t out_len;
  uint8_t c;
  uint8_t last;

  if (path_buf == 0 || path_len <= 0)
    return 0;
  if (path_len > 63)
    path_len = 63;
  if (parser_asm_stretch_import_path_validate_c(path_buf, path_len) == 0)
    return 0;
  i = 0;
  out_len = 0;
  while (i < path_len) {
    c = path_buf[i];
    if (c == 0)
      break;
    if (c == 46) {
      path_buf[out_len] = c;
      out_len++;
    } else if (stretch_ident_continue_ok(c) != 0) {
      path_buf[out_len] = c;
      out_len++;
    }
    i++;
  }
  while (out_len > 0) {
    last = path_buf[out_len - 1];
    if (last != 46)
      break;
    out_len--;
  }
  return out_len;
}
