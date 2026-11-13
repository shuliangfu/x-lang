/*
 * Host-gcc twin of parser_asm_primary_array_x_into_c
 * (pthin_expr_primary.x).
 * Root (s51 unofficial hello check XP008 dep prerun of std.io.win32,
 *   parse skip at byte 1171, num_funcs=0): typool first-wins
 *   parser_asm_primary_array_x_into_c W at 0x140478040 is live.
 * Windows std/io/win32.x is CRLF 10411 bytes (Mac checkout is LF
 *   10051; same text). The empty `let io_fixed_ptr: [8]*u8 = [];`
 *   succeeds (loop skipped when peek is `]`, lex.pos 1169->1170).
 * The next top-level let is `let io_fixed_len: [8]usize = [
 *   0, 0, 0, 0, 0, 0, 0, 0, ];`. Skip@1171 is the walker's
 *   iter_start (CRLF after the previous `;`, let itself at 1173).
 * typool compiled both breaks of the element while
 *     while (1 == 1) {
 *       parse_expr + append;
 *       if (kind == TOKEN_COMMA) {
 *         step; if (kind == TOKEN_RBRACKET) break;
 *       } else {
 *         break;
 *       }
 *     }
 * as jmp loop-head:
 *   trailing `]` after comma at +1509 / 0x140478625
 *     (kind=87, lex.pos=1233, the CRLF before `];`)
 *   no-comma else-break at +1529 / 0x140478639
 * After the 8th element typool peeks RBRACKET and jumps back to
 * the while head, parse_expr at `]` fails, out_ok=0, the let is
 * unpublished, and parse_strict reports parse_skip at iter_start
 * 1171. Empty `[]` does not take those breaks and is fine.
 * Class: typool miscompiled break-as-continue (same class as s47
 *   param_name_dup, s49 enum_name, s51 primary_string).
 * Fold allowlist: parser_asm_primary_array_x_into_c only.
 * Keep proven JMPs including s50 string_lit_append_byte and s51
 *   primary_string. Do not fold typool lex_bridge_fill, pend BSS,
 *   w1545_pend_rcx_emit, onefunc_sidecar_get, formal-ensure, or
 *   the sibling win stubs.
 * Do not idx8 the .x twin.
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks.
 */
#include <stdint.h>

#define TOKEN_LBRACKET 86
#define TOKEN_RBRACKET 87
#define TOKEN_COMMA 90
#define EXPR_ARRAY_LIT 46

int32_t parser_asm_lex_peek_kind_c(uint8_t *lex, uint8_t *source);
int32_t parser_asm_lex_step_kind_c(uint8_t *lex, uint8_t *source);
int32_t ast_ast_arena_expr_alloc(uint8_t *arena);
void pipeline_expr_set_kind(uint8_t *arena, int32_t ref, int32_t kind);
void pipeline_expr_set_common_zeros_c(uint8_t *arena, int32_t ref);
void pipeline_expr_set_line_col(uint8_t *arena, int32_t ref, int32_t line,
                                int32_t col);
int32_t parser_parse_expr_ptr_into_c(uint8_t *arena, uint8_t *lex,
                                     uint8_t *source, int32_t *out_ok,
                                     int32_t *out_expr_ref);
int32_t pipeline_expr_append_array_lit_elem(uint8_t *arena, int32_t ref,
                                           int32_t elem_ref);
void parser_asm_primary_suffix_loop_x_into_c(
    uint8_t *arena, uint8_t *source, uint8_t *lex, int32_t *out_ok,
    int32_t *out_expr_ref, int32_t *mc_arg_buf, int32_t *arg_buf,
    int32_t *parsed_refs, int32_t *pending_refs, uint8_t *mangled,
    uint8_t *name_buf);

int32_t parser_asm_primary_array_x_into_c(
    uint8_t *arena, uint8_t *lex_inout, uint8_t *source, int32_t *out_ok,
    int32_t *out_expr_ref, int32_t *mc_arg_buf, int32_t *arg_buf,
    int32_t *parsed_refs, int32_t *pending_refs, uint8_t *mangled,
    uint8_t *name_buf) {
  int32_t kind;
  int32_t ref;
  int32_t eok;
  int32_t eref;

  if (arena == 0 || lex_inout == 0 || source == 0 || out_ok == 0 ||
      out_expr_ref == 0) {
    return 0;
  }
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_LBRACKET) {
    return 0;
  }
  parser_asm_lex_step_kind_c(lex_inout, source);
  ref = ast_ast_arena_expr_alloc(arena);
  if (ref == 0) {
    out_ok[0] = 0;
    return 1;
  }
  pipeline_expr_set_kind(arena, ref, EXPR_ARRAY_LIT);
  pipeline_expr_set_common_zeros_c(arena, ref);
  pipeline_expr_set_line_col(arena, ref, 0, 0);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_RBRACKET) {
    while (1) {
      eok = 0;
      eref = 0;
      if (parser_parse_expr_ptr_into_c(arena, lex_inout, source, &eok, &eref) ==
              0 ||
          eok == 0 || eref == 0) {
        out_ok[0] = 0;
        return 1;
      }
      if (pipeline_expr_append_array_lit_elem(arena, ref, eref) < 0) {
        out_ok[0] = 0;
        return 1;
      }
      kind = parser_asm_lex_peek_kind_c(lex_inout, source);
      if (kind == TOKEN_COMMA) {
        parser_asm_lex_step_kind_c(lex_inout, source);
        kind = parser_asm_lex_peek_kind_c(lex_inout, source);
        if (kind == TOKEN_RBRACKET) {
          break;
        }
      } else {
        break;
      }
    }
  }
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_RBRACKET) {
    out_ok[0] = 0;
    return 1;
  }
  parser_asm_lex_step_kind_c(lex_inout, source);
  out_ok[0] = 1;
  out_expr_ref[0] = ref;
  parser_asm_primary_suffix_loop_x_into_c(arena, source, lex_inout, out_ok,
                                          out_expr_ref, mc_arg_buf, arg_buf,
                                          parsed_refs, pending_refs, mangled,
                                          name_buf);
  return 1;
}
