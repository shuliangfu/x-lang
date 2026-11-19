/* Host-gcc twin of typool pthin_primary_face_primary
 * (pthin_expr_primary_tramp.x). typool first-wins T (fromsrc_s108
 * 0x1404745a0) typool-wrongs the 11-arg Win64 call to
 * parser_asm_parse_primary_x_into_c: it pushes six buffer addresses,
 * then only stores args 5-6 at 0x20/0x28(%rsp) and never writes
 * args 7-11 (arg_buf, parsed_refs, pending_refs, mangled, name_buf).
 * Those slots stay leftover stack, so typool parse_primary receives
 * pending_refs=0x30 and parsed_refs=0xe6. Live GDB on
 * fromsrc_s108_noaslr check examples/hello.x (repo cwd), third
 * parse_primary entry: incoming +0x50=0x30; first-wins
 * parser_asm_primary_suffix_loop_x_into_c+153 then does
 * pending_refs[0]=0 and SIGSEGVs at typool-wrong dest 0x30. typool
 * rec / typool fputc / typool parse_skip / typool parse_primary
 * wholesale / typool suffix_loop (already a correct first-wins thin)
 * are not in this thin. docs-only .x, do not idx8. Do not JMP typool
 * rec T 0x140087de4. */
#include <stdint.h>
#include <string.h>

extern int32_t parser_asm_parse_primary_x_into_c(
    void *arena, void *lex_inout, void *source, int32_t *out_ok,
    int32_t *out_expr_ref, int32_t *mc_arg_buf, int32_t *arg_buf,
    int32_t *parsed_refs, int32_t *pending_refs, uint8_t *mangled,
    uint8_t *name_buf);

void pthin_primary_face_primary(void *arena, void *lex, void *source,
                                void *out) {
  int32_t mc[256];
  int32_t args[256];
  int32_t pr[8];
  int32_t pend[8];
  uint8_t mangled[128];
  uint8_t name[256];
  uint8_t cur[16];
  int32_t ok;
  int32_t refv;
  int32_t rc;
  int32_t *op;

  if (out == 0 || source == 0) {
    return;
  }
  memset(mc, 0, sizeof(mc));
  memset(args, 0, sizeof(args));
  memset(pr, 0, sizeof(pr));
  memset(pend, 0, sizeof(pend));
  memset(mangled, 0, sizeof(mangled));
  memset(name, 0, sizeof(name));
  memset(cur, 0, sizeof(cur));
  ok = 0;
  refv = 0;
  op = (int32_t *)out;
  if (lex != 0) {
    memcpy(cur, lex, 16);
  }
  rc = parser_asm_parse_primary_x_into_c(arena, cur, source, &ok, &refv, mc,
                                         args, pr, pend, mangled, name);
  if (lex != 0) {
    memcpy(lex, cur, 16);
  }
  memcpy((uint8_t *)out + 8, cur, 16);
  if (rc == 0 || ok == 0) {
    op[0] = 0;
    return;
  }
  op[0] = 1;
  op[1] = refv;
}
