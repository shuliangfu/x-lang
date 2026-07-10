/* seeds/pthin_helpers.from_x.c — G-02f-328 P2 parser thin helpers
 * Logic source: src/asm/pthin_helpers.x
 * Hybrid: SHUX_PTHIN_HELPERS_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_helpers_slice.inc (~1170)
 * import_path/label/struct_field + lex rewind/advance/peek + align_lex + first_token
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"

struct parser_asm_token {
  int32_t kind;
  int32_t line;
  int32_t col;
  int32_t int_val;
  double float_val;
  uint8_t *ident;
  int32_t ident_len;
};

struct parser_asm_lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

struct parser_asm_lexer_result {
  struct parser_asm_lexer next_lex;
  struct parser_asm_token tok;
  size_t token_start;
};

struct parser_asm_slice_u8 {
  uint8_t *data;
  size_t length;
};

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);
extern struct parser_asm_lexer_result lexer_next_buf(struct parser_asm_lexer lex, uint8_t *data, int32_t len);
extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern struct parser_asm_lexer parser_asm_lexer_init_c(void);
extern void parser_asm_copy_slice_to_name64_buf_c(uint8_t *source, int32_t source_len, size_t start, int32_t nlen,
                                                  uint8_t *out);
extern void parser_asm_copy_slice_to_name64_at_end_slice_c(struct parser_asm_slice_u8 *source, size_t end_pos,
                                                            int32_t nlen, uint8_t *out);
extern int32_t parser_asm_stretch_token_run_len_c(int32_t kind);
extern size_t parser_asm_stretch_skip_ws_and_comments_c(const uint8_t *data, size_t len, size_t pos);
extern int32_t parser_asm_stretch_struct_field_name_kind_c(int32_t kind);
extern int32_t parser_asm_stretch_struct_field_continues_kind_c(int32_t kind);
extern int32_t parser_asm_stretch_token_is_label_start_c(int32_t cur_kind, int32_t next_kind);

/* slice 内 glue 先于实现定义调用 */
void parser_asm_import_path_dot_segment_copy_slice_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                     int32_t seg_len, uint8_t *path_buf, int32_t path_len);
int32_t parser_asm_parser_token_is_label_start_slice_c(struct parser_asm_lexer_result r,
                                                        struct parser_asm_slice_u8 *source);

#include "parser_asm_helpers_slice.inc"

int labi_pthin_helpers_slice_marker(void) {
  return 1;
}
