/* Host-gcc twin of typool parser_asm_ctrl_bytes_eq
 * (pthin_ctrl.x 348-371). typool leftover W (fromsrc_s116_noaslr
 * 0x14048bac4) typool-wrongs data[i+j] as scale-8 through &data
 * (lea rax,[rbp-0x10]; lea rax,[rax+(i+j)*8]) and kw[j] as scale-8
 * through &kw, so an equal slice never compares equal. Live GDB on
 * fromsrc_s116_noaslr check examples/hello.x (repo cwd): typool leftover
 * kw_at_pos_buf_c (W 0x14048c378) at i=5204 / klen=2 / kw=data+i
 * (`if` in core.fmt fmt_bool_to_buf) returns 0 on the bytes_eq-fail
 * path (eax from typool leftover bytes_eq was 0). typool leftover
 * kw_at_pos_buf_c / typool leftover ident_continue / typool leftover
 * realign / typool leftover ctrl_kw_else_at / typool rec / typool
 * fputc wholesale are not in this thin. docs-only .x, do not idx8. Do not
 * JMP typool rec T 0x140087de4. */
#include <stdint.h>

int32_t parser_asm_ctrl_bytes_eq(uint8_t *data, uint64_t len, uint64_t i,
                                 uint8_t *kw, int32_t klen) {
  uint64_t n;
  int32_t j;
  uint8_t a;
  uint8_t b;

  if (data == 0 || kw == 0 || klen <= 0) {
    return 0;
  }
  n = (uint64_t)klen;
  if (i + n > len) {
    return 0;
  }
  j = 0;
  while (j < klen) {
    a = data[i + (uint64_t)j];
    b = kw[j];
    if (a != b) {
      return 0;
    }
    j = j + 1;
  }
  return 1;
}
