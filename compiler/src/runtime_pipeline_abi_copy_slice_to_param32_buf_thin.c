/* Host-gcc twin of typool parser_asm_copy_slice_to_param32_buf_c
 * (pthin_lex_skip.x 355-379). typool leftover W (fromsrc_s109_noaslr
 * 0x140458270) typool-wrongs the 256-byte row fill as scale-8 through
 * the local slots &source and &out: lea rax,[rbp-0x10]/[rbp-0x30];
 * lea rax,[rax+i*8]; then movq load/store. Live GDB on
 * fromsrc_s109_noaslr check examples/hello.x (repo cwd): hello main
 * and core.fmt placeholder return 0 from library scan before this
 * copy (no param IDENT); fmt_i32 (x: i32) enters take_ident_param32
 * then this face with start=0x3c0 nlen=1, and the zero-tail store
 * at typool 0x1404583f5 writes 0 through &out+i*8 onto the return
 * slot (i=7 hits [rbp+8]), so the function returns to RIP=0.
 * Authority is the 256-byte row in pthin_lex_skip.x, not the
 * historical C twin that only filled 32 bytes. typool rec / typool
 * fputc / typool name64 copies / typool scan_into / typool
 * take_ident_param32 / typool param32_at_end are not in this thin.
 * docs-only .x, do not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>
#include <stddef.h>

void parser_asm_copy_slice_to_param32_buf_c(uint8_t *source,
                                            int32_t source_len,
                                            size_t start, int32_t nlen,
                                            uint8_t *out) {
  int32_t i;
  size_t off;
  size_t slen;

  if (out == 0) {
    return;
  }
  slen = (size_t)source_len;
  i = 0;
  while (i < 256) {
    if (i < nlen && source != 0) {
      off = start + (size_t)i;
      if (off < slen) {
        out[i] = source[off];
        i = i + 1;
        continue;
      }
    }
    out[i] = 0;
    i = i + 1;
  }
}
