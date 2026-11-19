/* Host-gcc twin of typool parser_asm_ident_pre_dispatch_ptr_c
 * (pthin_expr_primary_tramp.x 998-1017). typool first-wins T
 * (fromsrc_s112_noaslr 0x140476130) typool-wrongs the 7-arg Win64
 * call to parser_asm_ident_pre_dispatch_x_into_c: it pushes 0 and
 * out_expr_ref (typool 0x140476326 / 0x140476330), then writes only
 * regs and out_ok at 0x20(%rsp)/0x28(%rsp) on that shifted rsp, and
 * never stores arg7 at the ABI slot. Live GDB on fromsrc_s112_noaslr
 * check examples/hello.x (repo cwd): callee [rbp+0x40] is sometimes a
 * real out_expr pointer, sometimes 0, and on the crashing call 0x50a;
 * typool ident_pre_dispatch_x_into_c+426 then does mov %eax,(%rbx)
 * with rbx=0x50a (out_expr_ref[0]=0). typool rec / typool fputc /
 * typool ident_pre_dispatch_x_into_c wholesale are not in this thin
 * (the 7-arg body stays extern). docs-only .x, do not idx8. Do not
 * JMP typool rec T 0x140087de4. */
#include <stdint.h>

extern int32_t parser_asm_ident_pre_dispatch_x_into_c(uint8_t *arena,
                                                      uint8_t *lex_inout,
                                                      uint8_t *source,
                                                      uint8_t *tmpl_buf,
                                                      uint8_t *regs_buf,
                                                      int32_t *out_ok,
                                                      int32_t *out_expr_ref);

int32_t parser_asm_ident_pre_dispatch_ptr_c(uint8_t *arena,
                                            uint8_t *lex_inout,
                                            uint8_t *source,
                                            int32_t *out_ok,
                                            int32_t *out_expr_ref) {
  uint8_t tmpl[256];
  uint8_t regs[128];
  uint32_t i;

  if (arena == 0 || lex_inout == 0 || source == 0 || out_ok == 0 || out_expr_ref == 0) {
    return 0;
  }
  i = 0;
  while (i < 256) {
    tmpl[i] = 0;
    i = i + 1;
  }
  i = 0;
  while (i < 128) {
    regs[i] = 0;
    i = i + 1;
  }
  out_ok[0] = 0;
  out_expr_ref[0] = 0;
  return parser_asm_ident_pre_dispatch_x_into_c(arena, lex_inout, source,
                                                &tmpl[0], &regs[0],
                                                out_ok, out_expr_ref);
}
