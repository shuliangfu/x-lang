/**
 * PLATFORM: WINDOWS tip PE only — knife 11.73.
 *
 * Tip parser_asm_skip_one_trait_header_into_c @0x1406087c4 is a stale e9
 * onto p12g_store_i32 @0x140622780. Callers pass (lex, source, ent_img);
 * store interprets them as (base, off, val) → SEGV on hello/std.io traits.
 *
 * Host-gcc tip-local twin of pthin_skip_tl.x header (TOKEN_TRAIT path).
 * Calls tip PE lex/copy/p12g_store symbols only. No Soft Cap body copy.
 * No 11.67 wrap rollback. No pin raise.
 */
#include <stdint.h>

enum {
  TOKEN_TRAIT = 49,
  TOKEN_IDENT = 59,
  TOKEN_LBRACE = 84,
  P12G_OFF_NAME = 0,
  P12G_OFF_NAME_LEN = 64
};

extern uint64_t parser_asm_lex_pos_c(void *lex);
extern int32_t parser_asm_lex_line_c(void *lex);
extern int32_t parser_asm_lex_col_c(void *lex);
extern void *parser_asm_lex_source_data_c(void *source);
extern uint64_t parser_asm_lex_source_length_c(void *source);
extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern void parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);
extern uint64_t parser_asm_lex_peek_token_start_c(void *lex_inout, void *source);
extern void parser_asm_copy_slice_to_name64_buf_c(void *source, int32_t source_len, uint64_t start,
                                                 int32_t nlen, void *out);
extern void p12g_store_i32(void *base, int32_t off, int32_t v);

/**
 * ABI twin of parser_asm_skip_one_trait_header_into_c.
 * @return 1 header consumed through opening `{`; 0 not TRAIT; -1 malformed.
 */
int32_t parser_asm_skip_one_trait_header_into_c(void *lex_inout, void *source, void *ent_img) {
  uint64_t pos0;
  int32_t kind;
  int32_t nlen;
  uint64_t ts;
  uint8_t *data;
  int32_t slen;
  int32_t k;

  if (!lex_inout || !source || !ent_img)
    return 0;

  pos0 = parser_asm_lex_pos_c(lex_inout);
  (void)parser_asm_lex_line_c(lex_inout);
  (void)parser_asm_lex_col_c(lex_inout);
  data = (uint8_t *)parser_asm_lex_source_data_c(source);
  slen = (int32_t)parser_asm_lex_source_length_c(source);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_TRAIT)
    return 0;

  parser_asm_lex_step_kind_c(lex_inout, source);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_IDENT)
    return -1;

  nlen = parser_asm_lex_peek_ident_len_c(lex_inout, source);
  ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
  if (ts == 0)
    ts = pos0;
  if (nlen > 64)
    nlen = 64;

  for (k = 0; k < 64; k++)
    ((uint8_t *)ent_img)[P12G_OFF_NAME + k] = 0;

  if (nlen > 0 && data != 0)
    parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, nlen, ent_img);

  p12g_store_i32(ent_img, P12G_OFF_NAME_LEN, nlen);
  parser_asm_lex_step_kind_c(lex_inout, source);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_LBRACE)
    return -1;
  parser_asm_lex_step_kind_c(lex_inout, source);
  return 1;
}
