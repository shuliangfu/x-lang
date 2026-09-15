/* seeds/pthin_ctrl.from_x.c — G-02f-286 P2 parser thin P5 ctrl
 * Logic source: src/asm/pthin_ctrl.x
 * Hybrid: XLANG_PTHIN_CTRL_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Bodies: if_stmt + match_subject + if_expr slice.inc（顺序同 mega）
 *
 * Hybrid P5b/P5c/P5d/P5e/P5f/P5g/P5h (XLANG_PTHIN_CTRL_BODIES_FROM_X): portable buf-path
 * comment-aware brace skip + kw_at_pos + scan_sync pos plus the P5d
 * six-stage realign walk, the P5e dest-typed enum-tag scan, the P5f
 * parse_if_expr dest-buffer, the P5g match wrap-family dest-buffer, and
 * the P5h parse_match_subject dest-buffer come from pthin_ctrl.x
 * (realign/parse over the P9a bridge peek family; dest-tag trampoline
 * holds ename[256]; if_expr trampoline holds parse_expr_result; VAR wrap
 * trampoline holds name[256] and is called by P5h). this TU keeps the
 * slice trampolines plus parse_match. Cold: no BODIES define, full
 * .inc. Do not reuse XLANG_PTHIN_CTRL_FROM_X for P5b/P5c/P5d/P5e/P5f/P5g/P5h
 * bodies.
 * PLATFORM: SHARED — do not assemble parser.x.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"

/* PLATFORM: SHARED — 7.2.1 P5d B-minus (2026-09-13).
 * pthin_ctrl.x TOKEN_* are pin copies of this enum.
 * token.h remains the authority; fire if the pin drifts. */
_Static_assert((int)TOKEN_LET == 2, "ctrl.x TOKEN_LET pin");
_Static_assert((int)TOKEN_CONST == 3, "ctrl.x TOKEN_CONST pin");
_Static_assert((int)TOKEN_IF == 4, "ctrl.x TOKEN_IF pin");
_Static_assert((int)TOKEN_ELSE == 5, "ctrl.x TOKEN_ELSE pin");
_Static_assert((int)TOKEN_WHILE == 6, "ctrl.x TOKEN_WHILE pin");
_Static_assert((int)TOKEN_FOR == 8, "ctrl.x TOKEN_FOR pin");
_Static_assert((int)TOKEN_RETURN == 11, "ctrl.x TOKEN_RETURN pin");
_Static_assert((int)TOKEN_MATCH == 18, "ctrl.x TOKEN_MATCH pin");
_Static_assert((int)TOKEN_IDENT == 59, "ctrl.x TOKEN_IDENT pin");
_Static_assert((int)TOKEN_LPAREN == 82, "ctrl.x TOKEN_LPAREN pin");
_Static_assert((int)TOKEN_LBRACE == 84, "ctrl.x TOKEN_LBRACE pin");
_Static_assert((int)TOKEN_RBRACE == 85, "ctrl.x TOKEN_RBRACE pin");
_Static_assert((int)TOKEN_LBRACKET == 86, "ctrl.x TOKEN_LBRACKET pin");
_Static_assert((int)TOKEN_DOT == 92, "ctrl.x TOKEN_DOT pin");

struct parser_asm_token {
  int32_t kind;
  int32_t line;
  int32_t col;
  int64_t int_val;
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

struct parser_asm_parse_expr_result {
  int32_t ok;
  int32_t expr_ref;
  struct parser_asm_lexer next_lex;
};

/* if_stmt_slice.inc 也会定义；须先于其 include 时由它定义。此处不重复。 */

/** 与 mega 扁平 ast_Expr 一致（match/if_expr 用 ast_Expr）。 */
struct ast_Expr {
  int32_t kind;
  int32_t resolved_type_ref;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t var_name[256];
  int32_t var_name_len;
  int32_t binop_left_ref;
  int32_t binop_right_ref;
  int32_t unary_operand_ref;
  int32_t if_cond_ref;
  int32_t if_then_ref;
  int32_t if_else_ref;
  int32_t block_ref;
  int32_t match_matched_ref;
  int32_t match_arm_base;
  int32_t match_num_arms;
  int32_t field_access_base_ref;
  uint8_t field_access_field_name[256];
  int32_t field_access_field_len;
  int32_t field_access_is_enum_variant;
  int32_t field_access_offset;
  int32_t field_access_soa_stride;
  int32_t index_base_ref;
  int32_t index_index_ref;
  int32_t index_base_is_slice;
  int32_t call_callee_ref;
  int32_t call_arg_base;
  int32_t call_num_args;
  int32_t call_num_type_args;
  int32_t method_call_base_ref;
  uint8_t method_call_name[256];
  int32_t method_call_name_len;
  int32_t method_call_arg_base;
  int32_t method_call_num_args;
  int32_t const_folded_val;
  int32_t const_folded_valid;
  int32_t index_proven_in_bounds;
  uint8_t struct_lit_struct_name[256];
  int32_t struct_lit_struct_name_len;
  int32_t struct_lit_field_base;
  int32_t struct_lit_num_fields;
  int32_t array_lit_elem_base;
  int32_t array_lit_num_elems;
  int32_t float_bits_lo;
  int32_t float_bits_hi;
  int32_t enum_variant_tag;
  int32_t as_operand_ref;
  int32_t as_target_type_ref;
  int32_t call_resolved_func_index;
  int32_t call_resolved_dep_index;
};

/* PLATFORM: SHARED — 7.2.1 P5f B-minus. ExprKind pins + consumer-wave
 * writers. pabi inject-only skips new rest symbols, so these T live in
 * the P5 seed (recompiled every g05). Pointer = pipeline_arena_expr_ptr.
 * Layout ≡ W278_Expr; P4uc already pinned unary_operand_ref==300. */
_Static_assert(offsetof(struct ast_Expr, unary_operand_ref) == 300, "P5f unary_operand_ref offset ≡ W278_Expr");
_Static_assert(offsetof(struct ast_Expr, if_cond_ref) == 304, "P5f if_cond_ref offset ≡ W278_Expr");
_Static_assert(offsetof(struct ast_Expr, if_then_ref) == 308, "P5f if_then_ref offset ≡ W278_Expr");
_Static_assert(offsetof(struct ast_Expr, if_else_ref) == 312, "P5f if_else_ref offset ≡ W278_Expr");
_Static_assert(offsetof(struct ast_Expr, block_ref) == 316, "P5f block_ref offset ≡ W278_Expr");
_Static_assert(offsetof(struct ast_Expr, match_matched_ref) == 320, "P5g match_matched_ref offset ≡ W278_Expr");
/* ExprKind pins ≡ pthin_ctrl.x P5g consts ≡ ast.x enum order. */
enum { P5G_EXPR_LIT = 0, P5G_EXPR_VAR = 3, P5G_EXPR_EQ = 14, P5G_EXPR_LOGAND = 20,
       P5G_EXPR_MATCH = 43, P5G_EXPR_FIELD_ACCESS = 44 };
_Static_assert(P5G_EXPR_LIT == 0, "ctrl.x EXPR_LIT pin");
_Static_assert(P5G_EXPR_VAR == 3, "ctrl.x EXPR_VAR pin");
_Static_assert(P5G_EXPR_EQ == 14, "ctrl.x EXPR_EQ pin");
_Static_assert(P5G_EXPR_LOGAND == 20, "ctrl.x EXPR_LOGAND pin");
_Static_assert(P5G_EXPR_MATCH == 43, "ctrl.x EXPR_MATCH pin");
_Static_assert(P5G_EXPR_FIELD_ACCESS == 44, "ctrl.x EXPR_FIELD_ACCESS pin");
extern void *pipeline_arena_expr_ptr(void *a, int32_t ref);
void pipeline_expr_set_block_ref_c(void *a, int32_t er, int32_t block_ref) {
  struct ast_Expr *ex;
  if (!a || er <= 0)
    return;
  ex = (struct ast_Expr *)pipeline_arena_expr_ptr(a, er);
  if (ex)
    ex->block_ref = block_ref;
}
void pipeline_expr_set_if_c(void *a, int32_t er, int32_t cond_ref, int32_t then_ref, int32_t else_ref) {
  struct ast_Expr *ex;
  if (!a || er <= 0)
    return;
  ex = (struct ast_Expr *)pipeline_arena_expr_ptr(a, er);
  if (!ex)
    return;
  ex->if_cond_ref = cond_ref;
  ex->if_then_ref = then_ref;
  ex->if_else_ref = else_ref;
}
/* PLATFORM: SHARED — 7.2.1 P5g B-minus. match_matched_ref has no pabi
 * setter (inject-only skips new rest symbols). Writer lives in this
 * seed (recompiled every g05). Do not FORCE pabi mega. */
void pipeline_expr_set_match_matched_c(void *a, int32_t er, int32_t matched_ref) {
  struct ast_Expr *ex;
  if (!a || er <= 0)
    return;
  ex = (struct ast_Expr *)pipeline_arena_expr_ptr(a, er);
  if (ex)
    ex->match_matched_ref = matched_ref;
}

struct ast_Module; /* opaque pointer only */

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *data);

#ifdef XLANG_PTHIN_CTRL_BODIES_FROM_X
/* .x product bodies (buf-path brace skip + kw_at_pos + scan_sync pos +
 * P5e dest-typed enum-tag scan + P5f parse_if_expr dest-buffer + P5g
 * match wrap-family dest-buffer). Same C name for skip_braces; kw_at_pos
 * keeps the slice+const char* trampoline because language has no C
 * string type; scan_sync keeps the by-value lexer trampoline because
 * language has no struct-by-value. dest-tag trampoline is in
 * match_subject.inc (holds ename[256]). if_expr trampoline is in
 * if_expr.inc (holds parse_expr_result). VAR wrap trampoline is in
 * match_subject.inc (holds name[256]). */
extern size_t parser_asm_skip_balanced_braces_bytes_comment_aware_c(const uint8_t *data, size_t len,
                                                                    size_t start);
extern int32_t parser_asm_kw_at_pos_buf_c(uint8_t *data, size_t len, size_t i, uint8_t *kw, int32_t klen);
extern size_t parser_asm_scan_sync_after_if_stmt_pos_c(uint8_t *data, size_t len, size_t start_pos);

static int32_t parser_asm_kw_at_pos_c(struct parser_asm_slice_u8 *source, size_t i, const char *kw, int32_t klen) {
  if (!source || !kw)
    return 0;
  return parser_asm_kw_at_pos_buf_c(source->data, source->length, i, (uint8_t *)(uintptr_t)kw, klen);
}

static struct parser_asm_lexer parser_asm_scan_sync_after_if_stmt_c(struct parser_asm_lexer lex_cur,
                                                                    struct parser_asm_slice_u8 *source) {
  size_t pos;
  if (!source || !source->data)
    return lex_cur;
  pos = parser_asm_scan_sync_after_if_stmt_pos_c(source->data, source->length, (size_t)lex_cur.pos);
  return (struct parser_asm_lexer){.pos = (size_t)(int32_t)pos, .line = lex_cur.line, .col = lex_cur.col};
}
#endif

#include "parser_asm_if_stmt_slice.inc"
#include "parser_asm_match_subject_slice.inc"
#include "parser_asm_if_expr_slice.inc"

int labi_pthin_ctrl_slice_marker(void) {
  return 3; /* if_stmt + match + if_expr */
}
