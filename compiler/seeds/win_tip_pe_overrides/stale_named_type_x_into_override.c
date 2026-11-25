/**
 * PLATFORM: WINDOWS tip PE only — knife 11.59.
 *
 * Tip-peel left __stale_parser_asm_parse_named_type_x_into_c as a hollow
 * push-rbp body (no e9). Soft Cap Prefer trampolines stale→live
 * parser_asm_parse_named_type_x_into_c; tip has no live copy. Soft Cap
 * mix banned.
 *
 * Tip-local C twin (host-gcc -Os) of compiler/src/asm/pthin_type_ref.x
 * parser_asm_parse_named_type_x_into_c + static consume_qualified helper.
 * Calls tip PE symbols only (lex_*, copy_slice_at_end, type_alloc,
 * pipeline_type_init_named_at).
 */
#include <stdint.h>
#include <stddef.h>

enum { TOKEN_IDENT = 59, TOKEN_DOT = 92 };

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern void parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_pos_c(void *lex_inout);
extern int32_t parser_asm_lex_line_c(void *lex_inout);
extern int32_t parser_asm_lex_col_c(void *lex_inout);
extern void parser_asm_lex_set_pos_c(void *lex_inout, size_t pos);
extern void parser_asm_lex_set_line_c(void *lex_inout, int32_t line);
extern void parser_asm_lex_set_col_c(void *lex_inout, int32_t col);
extern uint8_t *parser_asm_lex_source_data_c(void *source);
extern int32_t parser_asm_lex_source_length_c(void *source);
extern void parser_asm_copy_slice_to_name64_at_end_buf_c(uint8_t *source, int32_t source_len,
                                                        size_t end_pos, int32_t nlen, uint8_t *out);
extern int32_t ast_ast_arena_type_alloc(void *arena);
extern int32_t pipeline_type_init_named_at(void *arena, int32_t ref, uint8_t *name, int32_t name_len);

/* Static twin of parser_asm_consume_qualified_type_ident_name_into_c (.x).
 * Kept file-local so PE inject has no U reloc to the tip miswired stale. */
static int32_t consume_qualified_type_ident_name_into(void *source, void *lex_inout, uint8_t *out,
                                                     int32_t *out_len, int32_t first_ident_len) {
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

static void restore_lex(void *lex_inout, size_t pos0, int32_t line0, int32_t col0) {
  parser_asm_lex_set_pos_c(lex_inout, pos0);
  parser_asm_lex_set_line_c(lex_inout, line0);
  parser_asm_lex_set_col_c(lex_inout, col0);
}

/* Win64: rcx=arena rdx=lex r8=source r9=name_scratch [rsp+0x28]=qn_len_slot
 * Returns TYPE_NAMED type_ref, or 0. Matches tip parse_named_type_ref_c call. */
int32_t parser_asm_parse_named_type_x_into_c(void *arena, void *lex_inout, void *source,
                                            uint8_t *name_scratch, int32_t *qn_len_slot) {
  int32_t kind;
  int32_t first;
  int32_t nlen;
  int32_t rc;
  int32_t ok;
  int32_t type_ref;
  size_t pos0;
  int32_t line0;
  int32_t col0;
  if (!arena || !lex_inout || !source || !name_scratch || !qn_len_slot)
    return 0;
  pos0 = parser_asm_lex_pos_c(lex_inout);
  line0 = parser_asm_lex_line_c(lex_inout);
  col0 = parser_asm_lex_col_c(lex_inout);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_IDENT)
    return 0;
  first = parser_asm_lex_peek_ident_len_c(lex_inout, source);
  if (first <= 0)
    return 0;
  parser_asm_lex_step_kind_c(lex_inout, source);
  *qn_len_slot = 0;
  rc = consume_qualified_type_ident_name_into(source, lex_inout, name_scratch, qn_len_slot, first);
  if (rc != 0) {
    restore_lex(lex_inout, pos0, line0, col0);
    return 0;
  }
  nlen = *qn_len_slot;
  if (nlen <= 0) {
    restore_lex(lex_inout, pos0, line0, col0);
    return 0;
  }
  type_ref = ast_ast_arena_type_alloc(arena);
  if (type_ref == 0) {
    restore_lex(lex_inout, pos0, line0, col0);
    return 0;
  }
  ok = pipeline_type_init_named_at(arena, type_ref, name_scratch, nlen);
  if (ok == 0) {
    restore_lex(lex_inout, pos0, line0, col0);
    return 0;
  }
  return type_ref;
}
