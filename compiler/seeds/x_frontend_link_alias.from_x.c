/* seeds/x_frontend_link_alias.from_x.c
 * w847: the 18 alias functions live only in x_frontend_link_alias.x.
 * Their C bodies and the XLANG_XFLA_ASM gate were deleted. A seed-only
 * cc does not define those symbols.
 * w863: pipeline_type_kind_ord_at_u8_ptr_i32_reti32 also lives only in
 * that .x. It still forwards to pipeline_type_kind_ord_at and stays strong.
 * w864: glue_asm_build_func_export_sym_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_reti32
 * also lives only in that .x. It still forwards to
 * glue_asm_build_func_export_sym_c and stays strong.
 * w865: glue_asm_build_import_binding_call_sym_u8_ptr_i32_u8_ptr_i32_u8_ptr_reti32
 * also lives only in that .x. It still forwards to
 * glue_asm_build_import_binding_call_sym and stays strong.
 * w866: glue_try_std_heap_redirect_sym_local_u8_ptr_i32_u8_ptr_i32_reti32
 * also lives only in that .x. It still forwards to
 * glue_try_std_heap_redirect_sym_local and stays strong.
 * w867: glue_codegen_import_path_to_c_prefix_into_u8_ptr_u8_ptr_i32
 * also lives only in that .x. It still forwards to
 * glue_codegen_import_path_to_c_prefix_into and stays strong.
 * The unsuffixed body returns void.
 * w868: pipeline_expr_field_access_name_len_u8_ptr_i32_reti32 also
 * lives only in that .x. It still forwards to
 * pipeline_expr_field_access_name_len and stays weak.
 * The unsuffixed body stays in the pipeline object.
 * This file remains for the lexer struct-return tail and the
 * remaining XLANG_WEAK cluster, which are not in .x.
 * Product install is pure-asm of the .x plus cc of this rest, then a
 * partial merge. There is no full-seed fallback. -DXLANG_XFLA_ASM is
 * now a no-op. Six aliases stay weak via G05_X_O_WEAK_FUNCS on the
 * asm object: check_block_impl, check_expr_impl,
 * find_or_alloc_ptr_type_ref, pipeline_typeck_set_active_ctx_c,
 * pipeline_typeck_ptr_for_addr_of_operand_c, and the w868
 * pipeline_expr_field_access_name_len_u8_ptr_i32_reti32.
 * PLATFORM: SHARED.
 */
#include <xlang_weak.h>
#include <stdint.h>
#include <stddef.h>

/* Lexer struct-return tail (G-02f-26). Not yet in the .x. */
struct lexer_Lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};
struct lexer_LexerResult {
  int32_t tok;
  int64_t int_val;
  double float_val;
  struct lexer_Lexer next_lex;
};
struct xlang_slice_uint8_t;
extern struct lexer_Lexer lexer_init(void);
extern void lexer_next_into(struct lexer_LexerResult *out, struct lexer_Lexer lex,
                            struct xlang_slice_uint8_t *data);
extern struct lexer_LexerResult lexer_next_buf(struct lexer_Lexer lex,
                                               struct xlang_slice_uint8_t *data);

struct lexer_Lexer lexer_lexer_init(void) {
  return lexer_init();
}
void lexer_lexer_next_into(struct lexer_LexerResult *out, struct lexer_Lexer lex,
                         struct xlang_slice_uint8_t *data) {
  lexer_next_into(out, lex, data);
}
struct lexer_LexerResult lexer_lexer_next_buf(struct lexer_Lexer lex,
                                            struct xlang_slice_uint8_t *data) {
  return lexer_next_buf(lex, data);
}

/* R2 full try_inline/call_dispatch：.x -E 对 extern "C" 仍发 ABI 后缀名；
 * 产品 pipeline 导出无后缀符号。弱别名桥接（非业务双权威）。 */
extern void pipeline_expr_field_access_name_into(uint8_t *a, int32_t er, uint8_t *dst);
extern int32_t pipeline_expr_field_access_base_ref(uint8_t *a, int32_t er);
extern int32_t pipeline_expr_binop_left_ref_at(uint8_t *a, int32_t er);
extern int32_t pipeline_expr_binop_right_ref_at(uint8_t *a, int32_t er);
extern int32_t pipeline_dep_ctx_ndep(uint8_t *ctx);
extern uint8_t *pipeline_dep_ctx_module_at(uint8_t *ctx, int32_t i);
extern uint8_t *pipeline_asm_emit_dep_pipe_c(void);
extern uint8_t pipeline_module_import_path_byte_at(uint8_t *m, int32_t i, int32_t j);

/* w868: pipeline_expr_field_access_name_len_u8_ptr_i32_reti32
 * lives in x_frontend_link_alias.x and still forwards to
 * pipeline_expr_field_access_name_len. The symbol stays weak.
 * The unsuffixed body stays in the pipeline object.
 * PLATFORM: SHARED. */
XLANG_WEAK void pipeline_expr_field_access_name_into_u8_ptr_i32_u8_ptr(uint8_t *a, int32_t er, uint8_t *dst) {
  pipeline_expr_field_access_name_into(a, er, dst);
}
XLANG_WEAK int32_t pipeline_expr_field_access_base_ref_u8_ptr_i32_reti32(uint8_t *a, int32_t er) {
  return pipeline_expr_field_access_base_ref(a, er);
}
XLANG_WEAK int32_t pipeline_expr_binop_left_ref_at_u8_ptr_i32_reti32(uint8_t *a, int32_t er) {
  return pipeline_expr_binop_left_ref_at(a, er);
}
XLANG_WEAK int32_t pipeline_expr_binop_right_ref_at_u8_ptr_i32_reti32(uint8_t *a, int32_t er) {
  return pipeline_expr_binop_right_ref_at(a, er);
}
XLANG_WEAK int32_t pipeline_dep_ctx_ndep_u8_ptr_reti32(uint8_t *ctx) {
  return pipeline_dep_ctx_ndep(ctx);
}
XLANG_WEAK uint8_t *pipeline_dep_ctx_module_at_u8_ptr_i32_retu8_ptr(uint8_t *ctx, int32_t i) {
  return pipeline_dep_ctx_module_at(ctx, i);
}
XLANG_WEAK uint8_t *pipeline_asm_emit_dep_pipe_c_retu8_ptr(void) {
  return pipeline_asm_emit_dep_pipe_c();
}
XLANG_WEAK uint8_t pipeline_module_import_path_byte_at_u8_ptr_i32_i32_retu8(uint8_t *m, int32_t i, int32_t j) {
  return pipeline_module_import_path_byte_at(m, i, j);
}

/* wave L7-check residual: backend_call_dispatch X-ABI mangled faces → C product symbols.
 * Needed when call_dispatch.o expects mangled names not produced by host-cc seed path.
 * PLATFORM: SHARED link residual (G.7 alias face; not dual implementation). */
/* w864: glue_asm_build_func_export_sym_c_u8_ptr_u8_ptr_i32_u8_ptr_i32_reti32
 * lives in x_frontend_link_alias.x and still forwards to
 * glue_asm_build_func_export_sym_c. The symbol stays strong.
 * PLATFORM: SHARED. */
/* w865: glue_asm_build_import_binding_call_sym_u8_ptr_i32_u8_ptr_i32_u8_ptr_reti32
 * lives in x_frontend_link_alias.x and still forwards to
 * glue_asm_build_import_binding_call_sym. The symbol stays strong.
 * PLATFORM: SHARED. */
/* w867: glue_codegen_import_path_to_c_prefix_into_u8_ptr_u8_ptr_i32
 * lives in x_frontend_link_alias.x and still forwards to
 * glue_codegen_import_path_to_c_prefix_into. The symbol stays strong.
 * The unsuffixed body returns void.
 * PLATFORM: SHARED. */
/* w863: pipeline_type_kind_ord_at_u8_ptr_i32_reti32 lives in
 * x_frontend_link_alias.x and still forwards to pipeline_type_kind_ord_at.
 * PLATFORM: SHARED. */
/* w866: glue_try_std_heap_redirect_sym_local_u8_ptr_i32_u8_ptr_i32_reti32
 * lives in x_frontend_link_alias.x and still forwards to
 * glue_try_std_heap_redirect_sym_local. The symbol stays strong.
 * PLATFORM: SHARED. */
