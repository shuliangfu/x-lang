/* Generated from x_frontend_link_alias.x (G-02f-26 true .x + C tail).
 * Regen: ./shux-c -E -L .. x_frontend_link_alias.x > /tmp/xfla.c
 *         then re-apply weak polish + lexer C tail (see G-02f-26).
 * lexer_* struct returns remain C; other forwards are .x.
 */
#include <stdint.h>
#include <stddef.h>
extern int32_t typeck_x_ast(uint8_t * module, uint8_t * arena, uint8_t * ctx);
extern int32_t typeck_x_ast_library(uint8_t * module, uint8_t * arena, uint8_t * ctx);
extern void typeck_merge_dep_struct_layouts_into_entry(uint8_t * mod, uint8_t * arena, uint8_t * ctx);
extern void typeck_wpo_unify_soa_layouts(uint8_t * entry, uint8_t * ctx);
extern int32_t pipeline_typeck_check_block_impl_c(uint8_t * module, uint8_t * arena, int32_t block_ref, int32_t return_type_ref, uint8_t * ctx);
extern int32_t pipeline_typeck_check_expr_impl_c(uint8_t * module, uint8_t * arena, int32_t expr_ref, int32_t return_type_ref, uint8_t * ctx);
extern int32_t typeck_find_or_alloc_ptr_type_ref(uint8_t * arena, int32_t elem_ref);
extern int32_t pipeline_module_num_funcs(uint8_t * module);
extern int32_t pipeline_module_main_func_index(uint8_t * module);
extern void pipeline_module_struct_layout_set_soa(uint8_t * m, int32_t idx, int32_t v);
extern int32_t pipeline_module_struct_layout_soa_at(uint8_t * m, int32_t idx);
extern int32_t pipeline_module_struct_layout_packed_at(uint8_t * m, int32_t idx);
extern int32_t pipeline_module_struct_layout_field_align_at(uint8_t * m, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_set_field_align(uint8_t * m, int32_t li, int32_t j, int32_t al);
extern int32_t codegen_x_ast_emit_header(uint8_t * out);
extern int32_t codegen_x_ast(uint8_t * module, uint8_t * arena, uint8_t * out, uint8_t * ctx, int32_t dep_index);
int32_t typeck_pipeline_module_num_funcs(uint8_t * module) {
  (void)(({   {
    int32_t r = pipeline_module_num_funcs(module);
    return r;
  }
 }));
  return 0;
}
int32_t typeck_pipeline_module_main_func_index(uint8_t * module) {
  (void)(({   {
    int32_t r = pipeline_module_main_func_index(module);
    return r;
  }
 }));
  return 0;
}
int32_t typeck_typeck_x_ast(uint8_t * module, uint8_t * arena, uint8_t * ctx) {
  (void)(({   {
    int32_t r = typeck_x_ast(module, arena, ctx);
    return r;
  }
 }));
  return 0;
}
int32_t typeck_typeck_x_ast_library(uint8_t * module, uint8_t * arena, uint8_t * ctx) {
  (void)(({   {
    int32_t r = typeck_x_ast_library(module, arena, ctx);
    return r;
  }
 }));
  return 0;
}
void typeck_typeck_merge_dep_struct_layouts_into_entry(uint8_t * mod, uint8_t * arena, uint8_t * ctx) {
  (void)(({   {
    (void)(typeck_merge_dep_struct_layouts_into_entry(mod, arena, ctx));
  }
 }));
}
void typeck_typeck_wpo_unify_soa_layouts(uint8_t * entry, uint8_t * ctx) {
  (void)(({   {
    (void)(typeck_wpo_unify_soa_layouts(entry, ctx));
  }
 }));
}
__attribute__((weak)) int32_t check_block_impl(uint8_t * module, uint8_t * arena, int32_t block_ref, int32_t return_type_ref, uint8_t * ctx) {
  (void)(({   {
    int32_t r = pipeline_typeck_check_block_impl_c(module, arena, block_ref, return_type_ref, ctx);
    return r;
  }
 }));
  return 0;
}
__attribute__((weak)) int32_t check_expr_impl(uint8_t * module, uint8_t * arena, int32_t expr_ref, int32_t return_type_ref, uint8_t * ctx) {
  (void)(({   {
    int32_t r = pipeline_typeck_check_expr_impl_c(module, arena, expr_ref, return_type_ref, ctx);
    return r;
  }
 }));
  return 0;
}
__attribute__((weak)) int32_t find_or_alloc_ptr_type_ref(uint8_t * arena, int32_t elem_ref) {
  (void)(({   {
    int32_t r = typeck_find_or_alloc_ptr_type_ref(arena, elem_ref);
    return r;
  }
 }));
  return 0;
}
__attribute__((weak)) void pipeline_typeck_set_active_ctx_c(uint8_t * module, uint8_t * ctx) {
  (void)(0);
}
__attribute__((weak)) int32_t pipeline_typeck_ptr_for_addr_of_operand_c(uint8_t * arena, int32_t op_ref, int32_t elem_ty, uint8_t * module, uint8_t * ctx) {
  return 0;
}
void ast_pipeline_module_struct_layout_set_soa(uint8_t * m, int32_t idx, int32_t v) {
  (void)(({   {
    (void)(pipeline_module_struct_layout_set_soa(m, idx, v));
  }
 }));
}
int32_t ast_pipeline_module_struct_layout_soa_at(uint8_t * m, int32_t idx) {
  (void)(({   {
    int32_t r = pipeline_module_struct_layout_soa_at(m, idx);
    return r;
  }
 }));
  return 0;
}
int32_t ast_pipeline_module_struct_layout_packed_at(uint8_t * m, int32_t idx) {
  (void)(({   {
    int32_t r = pipeline_module_struct_layout_packed_at(m, idx);
    return r;
  }
 }));
  return 0;
}
int32_t ast_pipeline_module_struct_layout_field_align_at(uint8_t * m, int32_t li, int32_t j) {
  (void)(({   {
    int32_t r = pipeline_module_struct_layout_field_align_at(m, li, j);
    return r;
  }
 }));
  return 0;
}
void ast_pipeline_module_struct_layout_set_field_align(uint8_t * m, int32_t li, int32_t j, int32_t al) {
  (void)(({   {
    (void)(pipeline_module_struct_layout_set_field_align(m, li, j, al));
  }
 }));
}
int32_t codegen_codegen_x_ast_emit_header(uint8_t * out) {
  (void)(({   {
    int32_t r = codegen_x_ast_emit_header(out);
    return r;
  }
 }));
  return 0;
}
int32_t codegen_codegen_x_ast(uint8_t * module, uint8_t * arena, uint8_t * out, uint8_t * ctx, int32_t dep_index) {
  (void)(({   {
    int32_t r = codegen_x_ast(module, arena, out, ctx, dep_index);
    return r;
  }
 }));
  return 0;
}

/* ---- lexer C tail (G-02f-26): struct-return ABI not yet from .x ---- */
struct lexer_Lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};
struct lexer_LexerResult {
  int32_t tok;
  int32_t int_val;
  double float_val;
  struct lexer_Lexer next_lex;
};
struct shux_slice_uint8_t;
extern struct lexer_Lexer lexer_init(void);
extern void lexer_next_into(struct lexer_LexerResult *out, struct lexer_Lexer lex,
                            struct shux_slice_uint8_t *data);
extern struct lexer_LexerResult lexer_next_buf(struct lexer_Lexer lex,
                                               struct shux_slice_uint8_t *data);

struct lexer_Lexer lexer_lexer_init(void) {
  return lexer_init();
}
void lexer_lexer_next_into(struct lexer_LexerResult *out, struct lexer_Lexer lex,
                         struct shux_slice_uint8_t *data) {
  lexer_next_into(out, lex, data);
}
struct lexer_LexerResult lexer_lexer_next_buf(struct lexer_Lexer lex,
                                            struct shux_slice_uint8_t *data) {
  return lexer_next_buf(lex, data);
}
