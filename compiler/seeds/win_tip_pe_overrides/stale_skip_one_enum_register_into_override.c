/**
 * PLATFORM: WINDOWS tip PE only — knife 11.75.
 *
 * Tip parser_asm_skip_one_enum_register_into_c @0x140618898 is a stale e9
 * onto parser_asm_module_append_enum_variants_and_skip_body_into_c
 * @0x140618374. Callers pass (lex, source, module, name_buf, var_buf);
 * append interprets r9=name_buf as enum_idx and never consumes `enum Name`
 * → subsequent top-level `export function` invisible to import.dot lookup
 * → T001 "no impl for type with method".
 *
 * Host-gcc tip-local twin of pthin_skip_tl.x skip_one_enum_register.
 * Calls tip PE lex/copy/try_register/append symbols only. No Soft Cap body
 * copy. No 11.67 wrap rollback. No pin raise. No delete-enum fake green.
 */
#include <stdint.h>

enum {
  TOKEN_ENUM = 47,
  TOKEN_IDENT = 59,
  TOKEN_LBRACE = 84,
  ENUM_NAME_CAP = 128
};

extern uint64_t parser_asm_lex_pos_c(void *lex);
extern void *parser_asm_lex_source_data_c(void *source);
extern uint64_t parser_asm_lex_source_length_c(void *source);
extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern void parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);
extern uint64_t parser_asm_lex_peek_token_start_c(void *lex_inout, void *source);
extern void parser_asm_copy_slice_to_name64_buf_c(void *source, int32_t source_len, uint64_t start,
                                                 int32_t nlen, void *out);
extern int32_t parser_asm_module_try_register_enum_name_c(void *module, void *name, int32_t name_len);
extern int32_t parser_asm_module_append_enum_variants_and_skip_body_into_c(void *lex_inout, void *source,
                                                                          void *module, int32_t enum_idx,
                                                                          void *var_buf);

/**
 * ABI twin of parser_asm_skip_one_enum_register_into_c.
 * @return 1 success/fail-leave; 0 null lex/source/bufs.
 */
int32_t parser_asm_skip_one_enum_register_into_c(void *lex_inout, void *source, void *module,
                                                 void *name_buf, void *var_buf) {
  int32_t kind;
  int32_t pl;
  uint64_t ts;
  uint8_t *data;
  int32_t slen;
  int32_t zi;
  int32_t enum_idx;

  if (!lex_inout || !source || !name_buf || !var_buf)
    return 0;

  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_ENUM)
    return 1;

  parser_asm_lex_step_kind_c(lex_inout, source);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_IDENT)
    return 1;

  pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
  if (pl > 127)
    pl = 127;
  ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
  if (ts == 0)
    ts = parser_asm_lex_pos_c(lex_inout);

  for (zi = 0; zi < ENUM_NAME_CAP; zi++)
    ((uint8_t *)name_buf)[zi] = 0;

  data = (uint8_t *)parser_asm_lex_source_data_c(source);
  slen = (int32_t)parser_asm_lex_source_length_c(source);
  if (pl > 0 && data != 0)
    parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, name_buf);

  parser_asm_lex_step_kind_c(lex_inout, source);
  enum_idx = -1;
  if (module != 0 && pl > 0)
    enum_idx = parser_asm_module_try_register_enum_name_c(module, name_buf, pl);

  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_LBRACE)
    return 1;
  parser_asm_lex_step_kind_c(lex_inout, source);
  parser_asm_module_append_enum_variants_and_skip_body_into_c(lex_inout, source, module, enum_idx,
                                                              var_buf);
  return 1;
}
