/**
 * PLATFORM: WINDOWS tip PE only — knife 11.62.
 *
 * Tip Prefer peel left __stale_parser_asm_consume_qualified_type_ident_name_into_c
 * as e9 → parser_asm_copy_slice_to_name64_at_end_buf_c (WRONG arity/semantics).
 * Soft Cap Prefer trampolines stale→live into; tip has no live into copy.
 * Soft Cap byte mix banned.
 *
 * Callers: star_type IDENT arm (*UserStruct), live consume_qualified_c wrapper,
 * named_type stale body (dead — named_type already JMP'd to tip-local plant).
 *
 * Tip-local C twin of pthin_type_ref.x
 * parser_asm_consume_qualified_type_ident_name_into_c. Calls tip PE symbols
 * only (lex_*, copy_slice_at_end). No Soft Cap mix.
 */
#include <stdint.h>
#include <stddef.h>

enum { TOKEN_IDENT = 59, TOKEN_DOT = 92 };

extern uint8_t *parser_asm_lex_source_data_c(void *source);
extern int32_t parser_asm_lex_source_length_c(void *source);
extern size_t parser_asm_lex_pos_c(void *lex_inout);
extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern void parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);
extern void parser_asm_copy_slice_to_name64_at_end_buf_c(uint8_t *source, int32_t source_len,
                                                        size_t end_pos, int32_t nlen, uint8_t *out);

/* Win64: rcx=source rdx=lex r8=out r9=out_len [rsp+0x28]=first_ident_len
 * Returns 0 on success, -1 on failure. Matches tip star_type / wrapper call. */
int32_t parser_asm_consume_qualified_type_ident_name_into_c(void *source, void *lex_inout,
                                                           uint8_t *out, int32_t *out_len,
                                                           int32_t first_ident_len) {
  uint8_t *data;
  int32_t slen;
  int32_t seg_len;
  int32_t total;
  int32_t kind;
  int32_t zi;
  size_t start;
  uint8_t *dest_base;
  uint8_t *src_base;
  if (!source || !lex_inout || !out || !out_len || first_ident_len <= 0)
    return -1;
  data = parser_asm_lex_source_data_c(source);
  slen = parser_asm_lex_source_length_c(source);
  if (!data)
    return -1;
  seg_len = first_ident_len;
  if (seg_len > 255)
    seg_len = 255;
  parser_asm_copy_slice_to_name64_at_end_buf_c(data, slen, parser_asm_lex_pos_c(lex_inout), seg_len, out);
  total = seg_len;
  for (;;) {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_DOT) {
      *out_len = total;
      return 0;
    }
    if (total >= 255)
      return -1;
    out[total] = 46;
    total = total + 1;
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind != TOKEN_IDENT)
      return -1;
    seg_len = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (seg_len <= 0)
      return -1;
    if (total + seg_len > 255)
      seg_len = 255 - total;
    if (seg_len <= 0)
      return -1;
    parser_asm_lex_step_kind_c(lex_inout, source);
    zi = 0;
    start = parser_asm_lex_pos_c(lex_inout) - (size_t)seg_len;
    dest_base = out + (size_t)total;
    src_base = data + start;
    while (zi < seg_len) {
      if (total + zi >= 256)
        return -1;
      if (start + (size_t)zi < (size_t)slen)
        dest_base[zi] = src_base[zi];
      zi = zi + 1;
    }
    total = total + seg_len;
  }
}
