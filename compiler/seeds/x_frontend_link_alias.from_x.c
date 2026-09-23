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
 * This file remains for the lexer struct-return tail and the other
 * mangled ABI aliases, which are not in .x.
 * Product install is pure-asm of the .x plus cc of this rest, then a
 * partial merge. There is no full-seed fallback. -DXLANG_XFLA_ASM is
 * now a no-op. Five aliases stay weak via G05_X_O_WEAK_FUNCS on the
 * asm object: check_block_impl, check_expr_impl,
 * find_or_alloc_ptr_type_ref, pipeline_typeck_set_active_ctx_c,
 * pipeline_typeck_ptr_for_addr_of_operand_c.
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
extern int32_t pipeline_expr_field_access_name_len(uint8_t *a, int32_t er);
extern void pipeline_expr_field_access_name_into(uint8_t *a, int32_t er, uint8_t *dst);
extern int32_t pipeline_expr_field_access_base_ref(uint8_t *a, int32_t er);
extern int32_t pipeline_expr_binop_left_ref_at(uint8_t *a, int32_t er);
extern int32_t pipeline_expr_binop_right_ref_at(uint8_t *a, int32_t er);
extern int32_t pipeline_dep_ctx_ndep(uint8_t *ctx);
extern uint8_t *pipeline_dep_ctx_module_at(uint8_t *ctx, int32_t i);
extern uint8_t *pipeline_asm_emit_dep_pipe_c(void);
extern uint8_t pipeline_module_import_path_byte_at(uint8_t *m, int32_t i, int32_t j);

XLANG_WEAK int32_t pipeline_expr_field_access_name_len_u8_ptr_i32_reti32(uint8_t *a, int32_t er) {
  return pipeline_expr_field_access_name_len(a, er);
}
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
extern void glue_codegen_import_path_to_c_prefix_into(void *a, void *b, int32_t c);
void glue_codegen_import_path_to_c_prefix_into_u8_ptr_u8_ptr_i32(void *a, void *b, int32_t c) {
  glue_codegen_import_path_to_c_prefix_into(a, b, c);
}
/* w863: pipeline_type_kind_ord_at_u8_ptr_i32_reti32 lives in
 * x_frontend_link_alias.x and still forwards to pipeline_type_kind_ord_at.
 * PLATFORM: SHARED. */
/* X-ABI mangled face for the 4-param heap-redirect local (name, nlen, out,
 * out_cap): the -E'd backend_call_dispatch.x emits signature-suffixed calls
 * to it, and the strong plain-name body lives in backend_call_dispatch.o
 * (seed + prefer lanes alike). Replaces the stale pre-cap 3-param weak stub
 * (fossil of the old signature, satisfied nobody). Without this face the
 * seed-phase1 / g05 pure-ld links fail on
 * glue_try_std_heap_redirect_sym_local_u8_ptr_i32_u8_ptr_i32_reti32 unless
 * the generated asm_full_link_stubs scan happens to cover the gap.
 * PLATFORM: SHARED. */
extern int32_t glue_try_std_heap_redirect_sym_local(void *name, int32_t nlen, void *out, int32_t out_cap);
int32_t glue_try_std_heap_redirect_sym_local_u8_ptr_i32_u8_ptr_i32_reti32(
    void *name, int32_t nlen, void *out, int32_t out_cap) {
  return glue_try_std_heap_redirect_sym_local(name, nlen, out, out_cap);
}
