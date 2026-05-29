/* generated (single-file with deps) */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
extern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *, struct ast_Module *, uint8_t *, int32_t);

static inline void shulang_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void shulang_panic_(int has_msg, int msg_val) {
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
extern int32_t shu_io_register(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shu_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
extern int32_t shu_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
typedef struct { void *ptr; size_t len; size_t handle; } shu_buffer_abi_t;
static inline int32_t shu_io_register_buf(intptr_t buf) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shu_io_register((uint8_t *)b->ptr, b->len, b->handle); }
static inline int32_t shu_io_submit_read_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shu_io_submit_read((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
static inline int32_t shu_io_submit_write_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shu_io_submit_write((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
typedef struct { uint8_t *ptr; size_t len; size_t handle; } shu_batch_buf_t;
extern int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr);
static inline int io_register_buffers_buf_i32(intptr_t bufs, int nr) { return io_register_buffers_buf_c((const shu_batch_buf_t *)(uintptr_t)bufs, nr); }
enum ast_TypeKind { ast_TypeKind_TYPE_I32, ast_TypeKind_TYPE_BOOL, ast_TypeKind_TYPE_U8, ast_TypeKind_TYPE_U32, ast_TypeKind_TYPE_U64, ast_TypeKind_TYPE_I64, ast_TypeKind_TYPE_USIZE, ast_TypeKind_TYPE_ISIZE, ast_TypeKind_TYPE_NAMED, ast_TypeKind_TYPE_PTR, ast_TypeKind_TYPE_ARRAY, ast_TypeKind_TYPE_SLICE, ast_TypeKind_TYPE_VECTOR, ast_TypeKind_TYPE_F32, ast_TypeKind_TYPE_F64, ast_TypeKind_TYPE_VOID };
enum ast_ExprKind { ast_ExprKind_EXPR_LIT, ast_ExprKind_EXPR_FLOAT_LIT, ast_ExprKind_EXPR_BOOL_LIT, ast_ExprKind_EXPR_VAR, ast_ExprKind_EXPR_ADD, ast_ExprKind_EXPR_SUB, ast_ExprKind_EXPR_MUL, ast_ExprKind_EXPR_DIV, ast_ExprKind_EXPR_MOD, ast_ExprKind_EXPR_SHL, ast_ExprKind_EXPR_SHR, ast_ExprKind_EXPR_BITAND, ast_ExprKind_EXPR_BITOR, ast_ExprKind_EXPR_BITXOR, ast_ExprKind_EXPR_EQ, ast_ExprKind_EXPR_NE, ast_ExprKind_EXPR_LT, ast_ExprKind_EXPR_LE, ast_ExprKind_EXPR_GT, ast_ExprKind_EXPR_GE, ast_ExprKind_EXPR_LOGAND, ast_ExprKind_EXPR_LOGOR, ast_ExprKind_EXPR_NEG, ast_ExprKind_EXPR_BITNOT, ast_ExprKind_EXPR_LOGNOT, ast_ExprKind_EXPR_IF, ast_ExprKind_EXPR_BLOCK, ast_ExprKind_EXPR_TERNARY, ast_ExprKind_EXPR_ASSIGN, ast_ExprKind_EXPR_ADD_ASSIGN, ast_ExprKind_EXPR_SUB_ASSIGN, ast_ExprKind_EXPR_MUL_ASSIGN, ast_ExprKind_EXPR_DIV_ASSIGN, ast_ExprKind_EXPR_MOD_ASSIGN, ast_ExprKind_EXPR_BITAND_ASSIGN, ast_ExprKind_EXPR_BITOR_ASSIGN, ast_ExprKind_EXPR_BITXOR_ASSIGN, ast_ExprKind_EXPR_SHL_ASSIGN, ast_ExprKind_EXPR_SHR_ASSIGN, ast_ExprKind_EXPR_BREAK, ast_ExprKind_EXPR_CONTINUE, ast_ExprKind_EXPR_RETURN, ast_ExprKind_EXPR_PANIC, ast_ExprKind_EXPR_MATCH, ast_ExprKind_EXPR_FIELD_ACCESS, ast_ExprKind_EXPR_STRUCT_LIT, ast_ExprKind_EXPR_ARRAY_LIT, ast_ExprKind_EXPR_INDEX, ast_ExprKind_EXPR_CALL, ast_ExprKind_EXPR_METHOD_CALL, ast_ExprKind_EXPR_ENUM_VARIANT, ast_ExprKind_EXPR_ADDR_OF, ast_ExprKind_EXPR_DEREF, ast_ExprKind_EXPR_BINOP, ast_ExprKind_EXPR_AS };
enum ast_ImportKind { ast_ImportKind_IMPORT_WHOLE, ast_ImportKind_IMPORT_BINDING, ast_ImportKind_IMPORT_SELECT };
struct ast_Type { enum ast_TypeKind kind; uint8_t name[64]; int32_t name_len; int32_t elem_type_ref; int32_t array_size; };
struct ast_Expr { enum ast_ExprKind kind; int32_t resolved_type_ref; int32_t line; int32_t col; int32_t int_val; double float_val; uint8_t var_name[64]; int32_t var_name_len; int32_t binop_left_ref; int32_t binop_right_ref; int32_t unary_operand_ref; int32_t if_cond_ref; int32_t if_then_ref; int32_t if_else_ref; int32_t block_ref; int32_t match_matched_ref; int32_t match_arm_base; int32_t match_num_arms; int32_t field_access_base_ref; uint8_t field_access_field_name[64]; int32_t field_access_field_len; int32_t field_access_is_enum_variant; int32_t field_access_offset; int32_t index_base_ref; int32_t index_index_ref; int32_t index_base_is_slice; int32_t call_callee_ref; int32_t call_arg_base; int32_t call_num_args; int32_t method_call_base_ref; uint8_t method_call_name[64]; int32_t method_call_name_len; int32_t method_call_arg_base; int32_t method_call_num_args; int32_t const_folded_val; int32_t const_folded_valid; int32_t index_proven_in_bounds; uint8_t struct_lit_struct_name[64]; int32_t struct_lit_struct_name_len; int32_t struct_lit_field_base; int32_t struct_lit_num_fields; int32_t array_lit_elem_base; int32_t array_lit_num_elems; int32_t float_bits_lo; int32_t float_bits_hi; int32_t enum_variant_tag; int32_t as_operand_ref; int32_t as_target_type_ref; int32_t call_resolved_func_index; int32_t call_resolved_dep_index; };
struct ast_ConstDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_LetDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_WhileLoop { int32_t cond_ref; int32_t body_ref; };
struct ast_ForLoop { int32_t init_ref; int32_t cond_ref; int32_t step_ref; int32_t body_ref; };
struct ast_IfStmt { int32_t cond_ref; int32_t then_body_ref; int32_t else_body_ref; };
struct ast_StmtOrderItem { uint8_t kind; int32_t idx; };
struct ast_LabeledStmt { uint8_t label[32]; int32_t label_len; int32_t is_goto; uint8_t goto_target[32]; int32_t goto_target_len; int32_t return_expr_ref; };
struct ast_Block { int32_t const_base; int32_t num_consts; int32_t let_base; int32_t num_lets; int32_t num_early_lets; int32_t loop_base; int32_t num_loops; int32_t for_loop_base; int32_t num_for_loops; int32_t if_base; int32_t num_if_stmts; int32_t defer_base; int32_t num_defers; int32_t labeled_base; int32_t num_labeled_stmts; int32_t expr_stmt_base; int32_t num_expr_stmts; int32_t final_expr_ref; int32_t stmt_order_base; int32_t num_stmt_order; int32_t parent_block_ref; };
struct ast_Param { uint8_t name[32]; int32_t name_len; int32_t type_ref; };
struct ast_Func { uint8_t name[64]; int32_t name_len; int32_t param_base; int32_t num_params; int32_t return_type_ref; int32_t body_ref; int32_t body_expr_ref; int32_t is_extern; };
struct ast_StructLayout { uint8_t name[64]; int32_t name_len; int32_t field_base; int32_t num_fields; int32_t allow_padding; };
struct ast_Module { int32_t num_funcs; int32_t main_func_index; int32_t num_imports; int32_t num_top_level_lets; int32_t num_struct_layouts; int32_t pending_allow_padding; int32_t num_module_enums; };
struct ast_ASTArena { int32_t num_types; int32_t num_exprs; int32_t num_blocks; int32_t num_funcs; };

/* slim arena grow pool glue (linked from pipeline/runtime) */
extern struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
extern void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
extern void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
extern void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);

struct ast_PipelineDepCtx { int32_t ndep; uint8_t entry_dir_buf[512]; int32_t entry_dir_len; int32_t num_lib_roots; uint8_t path_buf[512]; uint8_t loaded_buf[4194304]; ptrdiff_t loaded_len; uint8_t preprocess_buf[4194304]; int32_t preprocess_len; int32_t use_asm_backend; int32_t target_arch; int32_t use_macho_o; int32_t use_coff_o; int32_t current_block_ref; int32_t typeck_loop_depth; int32_t current_func_index; int32_t skip_codegen_dep_0; int32_t entry_already_parsed; int32_t current_func_single_empty_param_index; int32_t current_func_empty_param_count; int32_t current_emit_empty_var_next_index; int32_t emit_expr_as_callee; struct ast_Module * current_codegen_module; struct ast_ASTArena * current_codegen_arena; int32_t current_codegen_dep_index; uint8_t current_codegen_prefix_mirror[64]; int32_t current_codegen_prefix_len; int32_t asm_entry_module_only; uint8_t entry_module_import_path_mirror[64]; int32_t entry_module_import_path_len; };

/* pipeline pool extern decls (calls pipeline_*, defs in ast_pool.c) */
extern int32_t  pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx * ctx);
extern int32_t  pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx * ctx, int32_t i);
extern void  pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx * ctx, int32_t i, uint8_t * dst, int32_t cap);
extern int32_t  pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx * ctx);
extern void  pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx * ctx, int32_t idx, struct ast_Module * m);
extern void  pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx * ctx, int32_t idx, struct ast_ASTArena * a);
extern struct ast_ASTArena *  pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern struct ast_Module *  pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void  pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx * ctx, int32_t n);
extern int32_t  pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void  pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * bytes, int32_t len);
extern void  pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst);
extern void  pipeline_expr_ptr_init_call_resolve(struct ast_Expr *e);
extern void  pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern void  pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix,
                                         int32_t func_ix);
extern int32_t  pipeline_module_func_alloc_slot(struct ast_Module *m);
extern void  pipeline_module_func_ref_set(struct ast_Module *m, int32_t fi, int32_t func_ref);
extern void  pipeline_module_func_set_return_type(struct ast_Module *m, int32_t fi, int32_t type_ref);
extern void  pipeline_module_func_set_body_ref(struct ast_Module *m, int32_t fi, int32_t body_ref);
extern void  pipeline_module_func_set_body_expr_ref(struct ast_Module *m, int32_t fi, int32_t body_expr_ref);
extern void  pipeline_module_func_set_is_extern(struct ast_Module *m, int32_t fi, int32_t is_extern);
extern void  pipeline_module_func_set_num_params(struct ast_Module *m, int32_t fi, int32_t n);
extern int32_t  pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi);
extern int32_t  pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t fi, uint8_t *name, int32_t name_len);
extern uint8_t  pipeline_module_func_name_byte_at(struct ast_Module *m, int32_t fi, int32_t i);
extern int32_t  pipeline_module_func_body_expr_ref_at(struct ast_Module *m, int32_t fi);
extern int32_t  pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path, int32_t len);
extern void  pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx);
extern void  pipeline_dep_ctx_set_codegen_prefix_mirror(struct ast_PipelineDepCtx *ctx, uint8_t *bytes, int32_t len);
extern int32_t  pipeline_dep_ctx_codegen_prefix_len(struct ast_PipelineDepCtx *ctx);
extern uint8_t  pipeline_dep_ctx_codegen_prefix_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off);
extern void  pipeline_dep_ctx_codegen_prefix_copy(struct ast_PipelineDepCtx *ctx, uint8_t *dst, int32_t cap);
extern int32_t  pipeline_dep_ctx_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx);
extern int32_t  pipeline_dep_ctx_current_func_index(struct ast_PipelineDepCtx *ctx);
extern void  pipeline_dep_ctx_set_current_codegen_module(struct ast_PipelineDepCtx *ctx, struct ast_Module *m);
extern void  pipeline_dep_ctx_set_current_codegen_arena(struct ast_PipelineDepCtx *ctx, struct ast_ASTArena *a);
extern void  pipeline_dep_ctx_set_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx, int32_t ix);
extern void  pipeline_dep_ctx_set_current_func_index(struct ast_PipelineDepCtx *ctx, int32_t ix);
extern int32_t  pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
extern int32_t  pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx);
extern int32_t  pipeline_dep_ctx_check_only_mode(struct ast_PipelineDepCtx *ctx);
extern int32_t  pipeline_dep_ctx_use_asm_backend(struct ast_PipelineDepCtx *ctx);
extern uint8_t  pipeline_dep_ctx_entry_dir_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off);
extern int32_t  pipeline_codegen_type_kind_copy(uint8_t *dst, int32_t cap, int32_t kind);
extern int32_t  pipeline_codegen_type_kind_append(uint8_t *scratch, int32_t cap, int32_t w, int32_t kind);
extern int32_t  pipeline_codegen_vector_type_copy(uint8_t *dst, int32_t cap, int32_t elem_kind, int32_t lanes);
extern int32_t  pipeline_codegen_call_num_args_override_lookup(uint8_t *buf, int32_t full, int32_t num_args);
extern int32_t  pipeline_codegen_call_num_args_override(uint8_t *prefix, int32_t prefix_len, uint8_t *name,
                                                    int32_t name_len, int32_t num_args);
extern int32_t  pipeline_codegen_is_std_io_driver_bridge_name(uint8_t *name, int32_t name_len);
extern int32_t  pipeline_codegen_path_is_std_io_driver_bytes(uint8_t *path);
extern int32_t  pipeline_codegen_path_is_std_io_core_bytes(uint8_t *path);
extern int32_t  pipeline_codegen_should_skip_emit_std_io_core_io_dup(uint8_t *dep_path, uint8_t *name, int32_t name_len);
extern int32_t  pipeline_codegen_should_skip_emit_std_io_trivial_handle(uint8_t *dep_path, uint8_t *name,
                                                                    int32_t name_len);
extern int32_t  pipeline_codegen_should_skip_emit_func(uint8_t *dep_path, uint8_t *prefix, int32_t prefix_len,
                                                   uint8_t *name, int32_t name_len);
extern int32_t  pipeline_codegen_skip_emit_extern_io_batch_buf(uint8_t *name, int32_t name_len);
extern int32_t  pipeline_codegen_entry_is_lsp_io_module(struct ast_Module *module);
extern int32_t  pipeline_codegen_entry_is_lsp_main_module(struct ast_Module *module);
extern int32_t  pipeline_codegen_force_param_std_io_driver_prefix_ok(uint8_t *prefix, int32_t prefix_len);
extern int32_t  pipeline_codegen_force_param_size_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                int32_t param_index);
extern int32_t  pipeline_codegen_force_param_size_t_std_io_print_str_second(uint8_t *prefix, int32_t prefix_len,
                                                                        uint8_t *name, int32_t name_len,
                                                                        int32_t param_index);
extern int32_t  pipeline_codegen_force_param_ptrdiff_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                   int32_t param_index);
extern int32_t  pipeline_codegen_force_param_uint32_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                  int32_t param_index);
extern int32_t  pipeline_codegen_use_buf_wrapper(uint8_t *name, int32_t name_len, int32_t num_args);
extern int32_t  pipeline_codegen_should_skip_emit_func_by_name(uint8_t *name, int32_t name_len);
extern int32_t  pipeline_codegen_is_submit_batch_buf_call(uint8_t *name, int32_t name_len);
extern int32_t  pipeline_codegen_should_skip_emit_func_core_read_ptr(uint8_t *name, int32_t name_len);
extern int32_t  pipeline_codegen_io_driver_buf_call_sym(uint8_t *name, int32_t name_len, int32_t num_args,
                                                    uint8_t *sym_out, int32_t sym_cap);
extern int32_t  pipeline_codegen_std_io_fixed_fd_emit_impl(uint8_t *prefix, int32_t prefix_len, uint8_t *name,
                                                     int32_t name_len);
extern int32_t  pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name, int32_t name_len,
                                          int32_t imm_bits);
extern int32_t  pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len);
extern void  pipeline_dep_ctx_set_path_buf_byte(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t b);
extern int32_t  pipeline_dep_ctx_entry_dir_len(struct ast_PipelineDepCtx *ctx);
extern int32_t  pipeline_dep_ctx_ensure_source_buffers(struct ast_PipelineDepCtx *ctx);
extern void  pipeline_dep_ctx_free_source_buffers(struct ast_PipelineDepCtx *ctx);
extern void  pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx);
extern void  pipeline_dep_ctx_set_loaded_len(struct ast_PipelineDepCtx *ctx, ptrdiff_t n);
extern uint8_t  pipeline_ctx_lib_root_byte_at(struct ast_PipelineDepCtx *ctx, int32_t i, int32_t off);
extern int32_t  pipeline_block_append_const(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                        int32_t type_ref, int32_t init_ref);
extern int32_t  pipeline_block_append_let(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                      int32_t type_ref, int32_t init_ref);
extern int32_t  pipeline_block_append_if(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t then_ref,
                                     int32_t else_ref);
extern int32_t  pipeline_block_append_while(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t body_ref);
extern int32_t  pipeline_block_append_for(struct ast_ASTArena *a, int32_t br, int32_t init_ref, int32_t cond_ref,
                                      int32_t step_ref, int32_t body_ref);
extern int32_t  pipeline_module_import_alloc(struct ast_Module *m);
extern void  pipeline_module_import_set_path(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
extern void  pipeline_module_import_set_kind(struct ast_Module *m, int32_t idx, int32_t kind);
extern void  pipeline_module_import_set_binding_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
extern void  pipeline_module_import_set_select_count(struct ast_Module *m, int32_t idx, int32_t n);
extern void  pipeline_module_import_path_copy(struct ast_Module *m, int32_t idx, uint8_t *dst, int32_t dst_cap);
extern int32_t  pipeline_module_enum_alloc(struct ast_Module *m);
extern void  pipeline_module_enum_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
extern int32_t  pipeline_module_top_level_let_alloc(struct ast_Module *m);
extern void  pipeline_module_top_level_let_set(struct ast_Module *m, int32_t idx, uint8_t *name, int32_t name_len,
                                            int32_t type_ref, int32_t init_ref, int32_t is_const);
extern void  pipeline_module_hoist_top_level_lets_into_main(struct ast_Module *m, struct ast_ASTArena *a);
extern int32_t  pipeline_module_import_path_len(struct ast_Module *m, int32_t idx);
extern uint8_t  pipeline_module_import_path_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t  pipeline_module_import_kind_at(struct ast_Module *m, int32_t idx);
extern int32_t  pipeline_module_import_binding_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t  pipeline_module_import_binding_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t  pipeline_module_import_select_count_at(struct ast_Module *m, int32_t idx);
extern int32_t  pipeline_module_import_select_name_len(struct ast_Module *m, int32_t idx, int32_t sel);
extern uint8_t  pipeline_module_import_select_name_byte_at(struct ast_Module *m, int32_t idx, int32_t sel, int32_t off);
extern int32_t  pipeline_module_struct_layout_alloc(struct ast_Module *m);
extern void  pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx);
extern void  pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
extern void  pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                                 int32_t fname_len, int32_t ftype_ref, int32_t foff);
extern void  pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf);
extern int32_t  pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx);
extern void  pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64);
extern uint8_t  pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t  pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx);
extern int32_t  pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j);
extern void  pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64);
extern int32_t  pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j);
extern int32_t  pipeline_module_struct_layout_field_offset_at(struct ast_Module *m, int32_t li, int32_t j);
extern void  pipeline_module_struct_layout_set_allow_padding(struct ast_Module *m, int32_t idx, int32_t v);
extern int32_t  pipeline_module_struct_layout_allow_padding_at(struct ast_Module *m, int32_t idx);
extern int32_t  pipeline_module_top_level_let_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t  pipeline_module_top_level_let_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t  pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t idx);
extern int32_t  pipeline_module_top_level_let_init_ref(struct ast_Module *m, int32_t idx);
extern int32_t  pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t idx);
extern int32_t  pipeline_module_enum_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t  pipeline_module_enum_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t  pipeline_module_enum_append_variant(struct ast_Module *m, int32_t idx, uint8_t *bytes,
                                                int32_t len);
extern int32_t  pipeline_module_enum_variant_tag_for_names(struct ast_Module *m, uint8_t *enum_name,
                                                         int32_t enum_len, uint8_t *variant_name,
                                                         int32_t variant_len);
extern void  pipeline_expr_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a,
                                                  int32_t expr_ref);
extern int32_t  pipeline_onefunc_num_consts(uint8_t *out);
extern int32_t  pipeline_onefunc_num_lets(uint8_t *out);
extern int32_t  pipeline_onefunc_num_whiles(uint8_t *out);
extern int32_t  pipeline_onefunc_num_fors(uint8_t *out);
extern int32_t  pipeline_onefunc_const_name_len(uint8_t *out, int32_t i);
extern void  pipeline_onefunc_const_name_copy64(uint8_t *out, int32_t i, uint8_t *dst);
extern int32_t  pipeline_onefunc_const_init_val(uint8_t *out, int32_t i);
extern int32_t  pipeline_onefunc_let_name_len(uint8_t *out, int32_t i);
extern void  pipeline_onefunc_let_name_copy64(uint8_t *out, int32_t i, uint8_t *dst);
extern int32_t  pipeline_onefunc_let_init_val(uint8_t *out, int32_t i);
extern int32_t  pipeline_onefunc_let_init_ref(uint8_t *out, int32_t i);
extern int32_t  pipeline_onefunc_let_type_ref(uint8_t *out, int32_t i);
extern int32_t  pipeline_onefunc_append_let(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val, int32_t init_ref,
                                        int32_t type_ref);
extern int32_t  pipeline_onefunc_append_const(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val,
                                          int32_t init_ref, int32_t type_ref);
extern int32_t  pipeline_onefunc_const_init_ref(uint8_t *out, int32_t i);
extern int32_t  pipeline_onefunc_const_type_ref(uint8_t *out, int32_t i);
extern int32_t  pipeline_onefunc_append_while(uint8_t *out, int32_t cond_ref, int32_t body_ref);
extern int32_t  pipeline_onefunc_append_for(uint8_t *out, int32_t init_ref, int32_t cond_ref, int32_t step_ref,
                                        int32_t body_ref);
extern void  pipeline_onefunc_copy_sidecar(uint8_t *dst, uint8_t *src);
extern int32_t  pipeline_block_append_expr_stmt(struct ast_ASTArena *a, int32_t br, int32_t expr_ref);
extern int32_t  pipeline_block_append_stmt_order(struct ast_ASTArena *a, int32_t br, uint8_t kind, int32_t idx);
extern int32_t  pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                           int32_t goto_target_len, int32_t return_expr_ref);
extern int32_t  pipeline_block_labeled_return_expr_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern void  pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void  pipeline_block_fill_whiles_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void  pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void  pipeline_block_fill_stmt_order_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void  pipeline_block_fill_expr_stmts_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern int32_t  pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern int32_t  pipeline_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern int32_t  pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t  pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t  pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
extern uint8_t  pipeline_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si);
extern int32_t  pipeline_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si);
extern int32_t  pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t  pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t  pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t  pipeline_block_const_name_len(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern void  pipeline_block_const_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t ci, uint8_t *dst);
extern int32_t  pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
extern void  pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
extern int32_t  pipeline_block_resolve_var_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                                 int32_t vlen);
extern int32_t  pipeline_module_func_ref_at(struct ast_Module *m, int32_t func_index);
extern int32_t  pipeline_arena_type_cap(void);
extern int32_t  pipeline_arena_expr_cap(void);
extern int32_t  pipeline_arena_block_cap(void);
extern int32_t  pipeline_arena_func_cap(void);
extern int32_t  pipeline_arena_type_alloc(struct ast_ASTArena *a);
extern int32_t  pipeline_arena_expr_alloc(struct ast_ASTArena *a);
extern int32_t  pipeline_arena_block_alloc(struct ast_ASTArena *a);
extern int32_t  pipeline_arena_func_alloc(struct ast_ASTArena *a);
extern struct ast_Type  pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void  pipeline_arena_type_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
extern struct ast_Expr  pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void  pipeline_arena_expr_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
extern void  pipeline_arena_expr_write_var(struct ast_ASTArena *a, int32_t ref, uint8_t *name, int32_t name_len);
extern void  pipeline_arena_expr_write_binop(struct ast_ASTArena *a, int32_t ref, int32_t kind_ord, int32_t left_ref,
                                         int32_t right_ref);
extern struct ast_Block  pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void  pipeline_arena_block_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
extern struct ast_Func  pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void  pipeline_arena_func_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);
extern int32_t  pipeline_expr_append_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref);
extern void  pipeline_expr_on_call_created(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_prepare_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t  pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_append_method_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref);
extern int32_t  pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t  pipeline_expr_append_match_arm(struct ast_ASTArena *a, int32_t expr_ref, int32_t result_ref,
                                           int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                           int32_t variant_index);
extern int32_t  pipeline_expr_match_num_arms_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_match_arm_result_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t  pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t  pipeline_expr_match_arm_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t  pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t  pipeline_expr_match_arm_variant_index(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern void  pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v);
extern void  pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v);
extern void  pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i,
                                                  int32_t is_var, int32_t variant_index);
extern int32_t  pipeline_expr_append_struct_lit_field(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *name_bytes,
                                                  int32_t name_len, int32_t init_ref);
extern int32_t  pipeline_expr_append_array_lit_elem(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_ref);
extern int32_t  pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t  pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_float_bits_lo_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_float_bits_hi_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_method_call_name_len(struct ast_ASTArena *a, int32_t expr_ref);
extern void  pipeline_expr_method_call_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64);
extern int32_t  pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t  pipeline_expr_field_access_layout_offset(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref);
extern int32_t  pipeline_expr_field_access_load_byte_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref);
extern int32_t  pipeline_module_import_append_select_name(struct ast_Module *m, int32_t idx, uint8_t *bytes,
                                                      int32_t len);

/* hoisted ast_pipeline */
extern int32_t ast_pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx * ctx);
extern int32_t ast_pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx * ctx, int32_t i);
extern void ast_pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx * ctx, int32_t i, uint8_t * dst, int32_t cap);
extern int32_t ast_pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx * ctx);
extern void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx * ctx, int32_t idx, struct ast_Module * m);
extern void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx * ctx, int32_t idx, struct ast_ASTArena * a);
extern struct ast_ASTArena * ast_pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern struct ast_Module * ast_pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void ast_pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx * ctx, int32_t n);
extern int32_t ast_pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void ast_pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * bytes, int32_t len);
extern void ast_pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst);
extern void ast_ast_arena_init(struct ast_ASTArena * arena);
extern void ast_pipeline_expr_ptr_init_call_resolve(struct ast_Expr *e);
extern void ast_pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern void ast_pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix,
                                         int32_t func_ix);
extern int32_t ast_pipeline_module_func_alloc_slot(struct ast_Module *m);
extern void ast_pipeline_module_func_ref_set(struct ast_Module *m, int32_t fi, int32_t func_ref);
extern void ast_pipeline_module_func_set_return_type(struct ast_Module *m, int32_t fi, int32_t type_ref);
extern void ast_pipeline_module_func_set_body_ref(struct ast_Module *m, int32_t fi, int32_t body_ref);
extern void ast_pipeline_module_func_set_body_expr_ref(struct ast_Module *m, int32_t fi, int32_t body_expr_ref);
extern void ast_pipeline_module_func_set_is_extern(struct ast_Module *m, int32_t fi, int32_t is_extern);
extern void ast_pipeline_module_func_set_num_params(struct ast_Module *m, int32_t fi, int32_t n);
extern int32_t ast_pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi);
extern int32_t ast_pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t fi, uint8_t *name, int32_t name_len);
extern uint8_t ast_pipeline_module_func_name_byte_at(struct ast_Module *m, int32_t fi, int32_t i);
extern int32_t ast_pipeline_module_func_body_expr_ref_at(struct ast_Module *m, int32_t fi);
extern int32_t ast_pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path, int32_t len);
extern void ast_pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx);
extern int32_t ast_pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m);
extern void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a);
extern void ast_pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n);
extern void ast_pipeline_dep_ctx_set_codegen_prefix_mirror(struct ast_PipelineDepCtx *ctx, uint8_t *bytes, int32_t len);
extern int32_t ast_pipeline_dep_ctx_codegen_prefix_len(struct ast_PipelineDepCtx *ctx);
extern uint8_t ast_pipeline_dep_ctx_codegen_prefix_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off);
extern void ast_pipeline_dep_ctx_codegen_prefix_copy(struct ast_PipelineDepCtx *ctx, uint8_t *dst, int32_t cap);
extern int32_t ast_pipeline_dep_ctx_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx);
extern int32_t ast_pipeline_dep_ctx_current_func_index(struct ast_PipelineDepCtx *ctx);
extern void ast_pipeline_dep_ctx_set_current_codegen_module(struct ast_PipelineDepCtx *ctx, struct ast_Module *m);
extern void ast_pipeline_dep_ctx_set_current_codegen_arena(struct ast_PipelineDepCtx *ctx, struct ast_ASTArena *a);
extern void ast_pipeline_dep_ctx_set_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx, int32_t ix);
extern void ast_pipeline_dep_ctx_set_current_func_index(struct ast_PipelineDepCtx *ctx, int32_t ix);
extern int32_t ast_pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
extern int32_t ast_pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx);
extern int32_t ast_pipeline_dep_ctx_check_only_mode(struct ast_PipelineDepCtx *ctx);
extern int32_t ast_pipeline_dep_ctx_use_asm_backend(struct ast_PipelineDepCtx *ctx);
extern uint8_t ast_pipeline_dep_ctx_entry_dir_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off);
extern int32_t ast_pipeline_codegen_type_kind_copy(uint8_t *dst, int32_t cap, int32_t kind);
extern int32_t ast_pipeline_codegen_type_kind_append(uint8_t *scratch, int32_t cap, int32_t w, int32_t kind);
extern int32_t ast_pipeline_codegen_vector_type_copy(uint8_t *dst, int32_t cap, int32_t elem_kind, int32_t lanes);
extern int32_t ast_pipeline_codegen_call_num_args_override_lookup(uint8_t *buf, int32_t full, int32_t num_args);
extern int32_t ast_pipeline_codegen_call_num_args_override(uint8_t *prefix, int32_t prefix_len, uint8_t *name,
                                                    int32_t name_len, int32_t num_args);
extern int32_t ast_pipeline_codegen_is_std_io_driver_bridge_name(uint8_t *name, int32_t name_len);
extern int32_t ast_pipeline_codegen_path_is_std_io_driver_bytes(uint8_t *path);
extern int32_t ast_pipeline_codegen_path_is_std_io_core_bytes(uint8_t *path);
extern int32_t ast_pipeline_codegen_should_skip_emit_std_io_core_io_dup(uint8_t *dep_path, uint8_t *name, int32_t name_len);
extern int32_t ast_pipeline_codegen_should_skip_emit_std_io_trivial_handle(uint8_t *dep_path, uint8_t *name,
                                                                    int32_t name_len);
extern int32_t ast_pipeline_codegen_should_skip_emit_func(uint8_t *dep_path, uint8_t *prefix, int32_t prefix_len,
                                                   uint8_t *name, int32_t name_len);
extern int32_t ast_pipeline_codegen_skip_emit_extern_io_batch_buf(uint8_t *name, int32_t name_len);
extern int32_t ast_pipeline_codegen_entry_is_lsp_io_module(struct ast_Module *module);
extern int32_t ast_pipeline_codegen_entry_is_lsp_main_module(struct ast_Module *module);
extern int32_t ast_pipeline_codegen_force_param_std_io_driver_prefix_ok(uint8_t *prefix, int32_t prefix_len);
extern int32_t ast_pipeline_codegen_force_param_size_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                int32_t param_index);
extern int32_t ast_pipeline_codegen_force_param_size_t_std_io_print_str_second(uint8_t *prefix, int32_t prefix_len,
                                                                        uint8_t *name, int32_t name_len,
                                                                        int32_t param_index);
extern int32_t ast_pipeline_codegen_force_param_ptrdiff_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                   int32_t param_index);
extern int32_t ast_pipeline_codegen_force_param_uint32_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                  int32_t param_index);
extern int32_t ast_pipeline_codegen_use_buf_wrapper(uint8_t *name, int32_t name_len, int32_t num_args);
extern int32_t ast_pipeline_codegen_should_skip_emit_func_by_name(uint8_t *name, int32_t name_len);
extern int32_t ast_pipeline_codegen_is_submit_batch_buf_call(uint8_t *name, int32_t name_len);
extern int32_t ast_pipeline_codegen_should_skip_emit_func_core_read_ptr(uint8_t *name, int32_t name_len);
extern int32_t ast_pipeline_codegen_io_driver_buf_call_sym(uint8_t *name, int32_t name_len, int32_t num_args,
                                                    uint8_t *sym_out, int32_t sym_cap);
extern int32_t ast_pipeline_codegen_std_io_fixed_fd_emit_impl(uint8_t *prefix, int32_t prefix_len, uint8_t *name,
                                                     int32_t name_len);
extern int32_t ast_pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name, int32_t name_len,
                                          int32_t imm_bits);
extern int32_t ast_pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len);
extern void ast_pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes, int32_t len);
extern int32_t ast_pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void ast_pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst);
extern void ast_pipeline_dep_ctx_set_path_buf_byte(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t b);
extern int32_t ast_pipeline_dep_ctx_entry_dir_len(struct ast_PipelineDepCtx *ctx);
extern int32_t ast_pipeline_dep_ctx_ensure_source_buffers(struct ast_PipelineDepCtx *ctx);
extern void ast_pipeline_dep_ctx_free_source_buffers(struct ast_PipelineDepCtx *ctx);
extern void ast_pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx);
extern void ast_pipeline_dep_ctx_set_loaded_len(struct ast_PipelineDepCtx *ctx, ptrdiff_t n);
extern int32_t ast_pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx *ctx);
extern int32_t ast_pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx *ctx, int32_t i);
extern void ast_pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx *ctx, int32_t i, uint8_t *dst, int32_t cap);
extern uint8_t ast_pipeline_ctx_lib_root_byte_at(struct ast_PipelineDepCtx *ctx, int32_t i, int32_t off);
extern int32_t ast_pipeline_block_append_const(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                        int32_t type_ref, int32_t init_ref);
extern int32_t ast_pipeline_block_append_let(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                      int32_t type_ref, int32_t init_ref);
extern int32_t ast_pipeline_block_append_if(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t then_ref,
                                     int32_t else_ref);
extern int32_t ast_pipeline_block_append_while(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t body_ref);
extern int32_t ast_pipeline_block_append_for(struct ast_ASTArena *a, int32_t br, int32_t init_ref, int32_t cond_ref,
                                      int32_t step_ref, int32_t body_ref);
extern int32_t ast_pipeline_module_import_alloc(struct ast_Module *m);
extern void ast_pipeline_module_import_set_path(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
extern void ast_pipeline_module_import_set_kind(struct ast_Module *m, int32_t idx, int32_t kind);
extern void ast_pipeline_module_import_set_binding_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
extern void ast_pipeline_module_import_set_select_count(struct ast_Module *m, int32_t idx, int32_t n);
extern void ast_pipeline_module_import_path_copy(struct ast_Module *m, int32_t idx, uint8_t *dst, int32_t dst_cap);
extern int32_t ast_pipeline_module_enum_alloc(struct ast_Module *m);
extern void ast_pipeline_module_enum_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
extern int32_t ast_pipeline_module_top_level_let_alloc(struct ast_Module *m);
extern void ast_pipeline_module_top_level_let_set(struct ast_Module *m, int32_t idx, uint8_t *name, int32_t name_len,
                                            int32_t type_ref, int32_t init_ref, int32_t is_const);
extern void ast_pipeline_module_hoist_top_level_lets_into_main(struct ast_Module *m, struct ast_ASTArena *a);
extern int32_t ast_pipeline_module_import_path_len(struct ast_Module *m, int32_t idx);
extern uint8_t ast_pipeline_module_import_path_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_import_kind_at(struct ast_Module *m, int32_t idx);
extern int32_t ast_pipeline_module_import_binding_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t ast_pipeline_module_import_binding_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_import_select_count_at(struct ast_Module *m, int32_t idx);
extern int32_t ast_pipeline_module_import_select_name_len(struct ast_Module *m, int32_t idx, int32_t sel);
extern uint8_t ast_pipeline_module_import_select_name_byte_at(struct ast_Module *m, int32_t idx, int32_t sel, int32_t off);
extern int32_t ast_pipeline_module_struct_layout_alloc(struct ast_Module *m);
extern void ast_pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx);
extern void ast_pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
extern void ast_pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                                 int32_t fname_len, int32_t ftype_ref, int32_t foff);
extern void ast_pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf);
extern int32_t ast_pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx);
extern void ast_pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64);
extern uint8_t ast_pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx);
extern int32_t ast_pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j);
extern void ast_pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64);
extern int32_t ast_pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j);
extern int32_t ast_pipeline_module_struct_layout_field_offset_at(struct ast_Module *m, int32_t li, int32_t j);
extern void ast_pipeline_module_struct_layout_set_allow_padding(struct ast_Module *m, int32_t idx, int32_t v);
extern int32_t ast_pipeline_module_struct_layout_allow_padding_at(struct ast_Module *m, int32_t idx);
extern int32_t ast_pipeline_module_top_level_let_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t ast_pipeline_module_top_level_let_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t idx);
extern int32_t ast_pipeline_module_top_level_let_init_ref(struct ast_Module *m, int32_t idx);
extern int32_t ast_pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t idx);
extern int32_t ast_pipeline_module_enum_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t ast_pipeline_module_enum_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_enum_append_variant(struct ast_Module *m, int32_t idx, uint8_t *bytes,
                                                int32_t len);
extern int32_t ast_pipeline_module_enum_variant_tag_for_names(struct ast_Module *m, uint8_t *enum_name,
                                                         int32_t enum_len, uint8_t *variant_name,
                                                         int32_t variant_len);
extern void ast_pipeline_expr_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a,
                                                  int32_t expr_ref);
extern int32_t ast_pipeline_onefunc_num_consts(uint8_t *out);
extern int32_t ast_pipeline_onefunc_num_lets(uint8_t *out);
extern int32_t ast_pipeline_onefunc_num_whiles(uint8_t *out);
extern int32_t ast_pipeline_onefunc_num_fors(uint8_t *out);
extern int32_t ast_pipeline_onefunc_const_name_len(uint8_t *out, int32_t i);
extern void ast_pipeline_onefunc_const_name_copy64(uint8_t *out, int32_t i, uint8_t *dst);
extern int32_t ast_pipeline_onefunc_const_init_val(uint8_t *out, int32_t i);
extern int32_t ast_pipeline_onefunc_let_name_len(uint8_t *out, int32_t i);
extern void ast_pipeline_onefunc_let_name_copy64(uint8_t *out, int32_t i, uint8_t *dst);
extern int32_t ast_pipeline_onefunc_let_init_val(uint8_t *out, int32_t i);
extern int32_t ast_pipeline_onefunc_let_init_ref(uint8_t *out, int32_t i);
extern int32_t ast_pipeline_onefunc_let_type_ref(uint8_t *out, int32_t i);
extern int32_t ast_pipeline_onefunc_append_let(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val, int32_t init_ref,
                                        int32_t type_ref);
extern int32_t ast_pipeline_onefunc_append_const(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val,
                                          int32_t init_ref, int32_t type_ref);
extern int32_t ast_pipeline_onefunc_const_init_ref(uint8_t *out, int32_t i);
extern int32_t ast_pipeline_onefunc_const_type_ref(uint8_t *out, int32_t i);
extern int32_t ast_pipeline_onefunc_append_while(uint8_t *out, int32_t cond_ref, int32_t body_ref);
extern int32_t ast_pipeline_onefunc_append_for(uint8_t *out, int32_t init_ref, int32_t cond_ref, int32_t step_ref,
                                        int32_t body_ref);
extern void ast_pipeline_onefunc_copy_sidecar(uint8_t *dst, uint8_t *src);
extern int32_t ast_pipeline_block_append_expr_stmt(struct ast_ASTArena *a, int32_t br, int32_t expr_ref);
extern int32_t ast_pipeline_block_append_stmt_order(struct ast_ASTArena *a, int32_t br, uint8_t kind, int32_t idx);
extern int32_t ast_pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                           int32_t goto_target_len, int32_t return_expr_ref);
extern int32_t ast_pipeline_block_labeled_return_expr_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern void ast_pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void ast_pipeline_block_fill_whiles_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void ast_pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void ast_pipeline_block_fill_stmt_order_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void ast_pipeline_block_fill_expr_stmts_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern int32_t ast_pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern int32_t ast_pipeline_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern int32_t ast_pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t ast_pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
extern uint8_t ast_pipeline_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si);
extern int32_t ast_pipeline_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si);
extern int32_t ast_pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t ast_pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t ast_pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
extern int32_t ast_pipeline_block_const_name_len(struct ast_ASTArena *a, int32_t br, int32_t ci);
extern void ast_pipeline_block_const_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t ci, uint8_t *dst);
extern int32_t ast_pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
extern void ast_pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
extern int32_t ast_pipeline_block_resolve_var_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                                 int32_t vlen);
extern int32_t ast_pipeline_module_func_ref_at(struct ast_Module *m, int32_t func_index);
extern int32_t ast_pipeline_arena_type_cap(void);
extern int32_t ast_pipeline_arena_expr_cap(void);
extern int32_t ast_pipeline_arena_block_cap(void);
extern int32_t ast_pipeline_arena_func_cap(void);
extern int32_t ast_pipeline_arena_type_alloc(struct ast_ASTArena *a);
extern int32_t ast_pipeline_arena_expr_alloc(struct ast_ASTArena *a);
extern int32_t ast_pipeline_arena_block_alloc(struct ast_ASTArena *a);
extern int32_t ast_pipeline_arena_func_alloc(struct ast_ASTArena *a);
extern struct ast_Type ast_pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_pipeline_arena_type_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
extern struct ast_Expr ast_pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_pipeline_arena_expr_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
extern void ast_pipeline_arena_expr_write_var(struct ast_ASTArena *a, int32_t ref, uint8_t *name, int32_t name_len);
extern void ast_pipeline_arena_expr_write_binop(struct ast_ASTArena *a, int32_t ref, int32_t kind_ord, int32_t left_ref,
                                         int32_t right_ref);
extern struct ast_Block ast_pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_pipeline_arena_block_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
extern struct ast_Func ast_pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_pipeline_arena_func_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);
extern int32_t ast_pipeline_expr_append_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref);
extern void ast_pipeline_expr_on_call_created(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_prepare_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t ast_pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_append_method_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref);
extern int32_t ast_pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t ast_pipeline_expr_append_match_arm(struct ast_ASTArena *a, int32_t expr_ref, int32_t result_ref,
                                           int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                           int32_t variant_index);
extern int32_t ast_pipeline_expr_match_num_arms_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_match_arm_result_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t ast_pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t ast_pipeline_expr_match_arm_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t ast_pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern int32_t ast_pipeline_expr_match_arm_variant_index(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
extern void ast_pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v);
extern void ast_pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v);
extern void ast_pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i,
                                                  int32_t is_var, int32_t variant_index);
extern int32_t ast_pipeline_expr_append_struct_lit_field(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *name_bytes,
                                                  int32_t name_len, int32_t init_ref);
extern int32_t ast_pipeline_expr_append_array_lit_elem(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_ref);
extern int32_t ast_pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
extern int32_t ast_pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_float_bits_lo_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_float_bits_hi_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_method_call_name_len(struct ast_ASTArena *a, int32_t expr_ref);
extern void ast_pipeline_expr_method_call_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64);
extern int32_t ast_pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_field_access_layout_offset(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref);
extern int32_t ast_pipeline_expr_field_access_load_byte_sz(struct ast_ASTArena *a, struct ast_Module *m, int32_t expr_ref);
extern int32_t ast_pipeline_module_import_append_select_name(struct ast_Module *m, int32_t idx, uint8_t *bytes,
                                                      int32_t len);


/* pipeline extern TU aliases */
#define asm_codegen_ast asm_asm_codegen_ast
#define ast_arena_init ast_ast_arena_init
#define codegen_su_ast codegen_codegen_su_ast
#define fs_close std_fs_fs_close
#define fs_open_read std_fs_fs_open_read
#define fs_read std_fs_fs_read
#define lexer_init lexer_lexer_init
#define lexer_lexer_next_buf lexer_next_buf
#define lexer_lexer_next_into lexer_next_into
#define pipeline_ctx_lib_root_copy ast_pipeline_ctx_lib_root_copy
#define pipeline_ctx_lib_root_count ast_pipeline_ctx_lib_root_count
#define pipeline_ctx_lib_root_len ast_pipeline_ctx_lib_root_len
#define pipeline_dep_ctx_arena_at ast_pipeline_dep_ctx_arena_at
#define pipeline_dep_ctx_import_path_copy64 ast_pipeline_dep_ctx_import_path_copy64
#define pipeline_dep_ctx_import_path_len ast_pipeline_dep_ctx_import_path_len
#define pipeline_dep_ctx_module_at ast_pipeline_dep_ctx_module_at
#define pipeline_dep_ctx_ndep ast_pipeline_dep_ctx_ndep
#define pipeline_dep_ctx_set_arena ast_pipeline_dep_ctx_set_arena
#define pipeline_dep_ctx_set_import_path ast_pipeline_dep_ctx_set_import_path
#define pipeline_dep_ctx_set_module ast_pipeline_dep_ctx_set_module
#define pipeline_dep_ctx_set_ndep ast_pipeline_dep_ctx_set_ndep
#define preprocess_su_buf preprocess_preprocess_su_buf
#define typeck_merge_dep_struct_layouts_into_entry typeck_typeck_merge_dep_struct_layouts_into_entry
#define typeck_su_ast typeck_typeck_su_ast
#define typeck_su_ast_library typeck_typeck_su_ast_library


/* pipeline extern parser_parse_into_buf */
enum token_TokenKind { token_TokenKind_TOKEN_EOF, token_TokenKind_TOKEN_FUNCTION, token_TokenKind_TOKEN_LET, token_TokenKind_TOKEN_CONST, token_TokenKind_TOKEN_IF, token_TokenKind_TOKEN_ELSE, token_TokenKind_TOKEN_WHILE, token_TokenKind_TOKEN_LOOP, token_TokenKind_TOKEN_FOR, token_TokenKind_TOKEN_BREAK, token_TokenKind_TOKEN_CONTINUE, token_TokenKind_TOKEN_RETURN, token_TokenKind_TOKEN_PANIC, token_TokenKind_TOKEN_DEFER, token_TokenKind_TOKEN_MATCH, token_TokenKind_TOKEN_STRUCT, token_TokenKind_TOKEN_PACKED, token_TokenKind_TOKEN_ENUM, token_TokenKind_TOKEN_GOTO, token_TokenKind_TOKEN_TRAIT, token_TokenKind_TOKEN_IMPL, token_TokenKind_TOKEN_SELF, token_TokenKind_TOKEN_UNDERSCORE, token_TokenKind_TOKEN_IMPORT, token_TokenKind_TOKEN_EXTERN, token_TokenKind_TOKEN_IDENT, token_TokenKind_TOKEN_I32, token_TokenKind_TOKEN_BOOL, token_TokenKind_TOKEN_U8, token_TokenKind_TOKEN_U32, token_TokenKind_TOKEN_U64, token_TokenKind_TOKEN_I64, token_TokenKind_TOKEN_USIZE, token_TokenKind_TOKEN_ISIZE, token_TokenKind_TOKEN_I32X4, token_TokenKind_TOKEN_I32X8, token_TokenKind_TOKEN_I32X16, token_TokenKind_TOKEN_U32X4, token_TokenKind_TOKEN_U32X8, token_TokenKind_TOKEN_U32X16, token_TokenKind_TOKEN_TRUE, token_TokenKind_TOKEN_FALSE, token_TokenKind_TOKEN_F32, token_TokenKind_TOKEN_F64, token_TokenKind_TOKEN_VOID, token_TokenKind_TOKEN_INT, token_TokenKind_TOKEN_FLOAT, token_TokenKind_TOKEN_LPAREN, token_TokenKind_TOKEN_RPAREN, token_TokenKind_TOKEN_LBRACE, token_TokenKind_TOKEN_RBRACE, token_TokenKind_TOKEN_LBRACKET, token_TokenKind_TOKEN_RBRACKET, token_TokenKind_TOKEN_ARROW, token_TokenKind_TOKEN_FATARROW, token_TokenKind_TOKEN_COMMA, token_TokenKind_TOKEN_COLON, token_TokenKind_TOKEN_DOT, token_TokenKind_TOKEN_SEMICOLON, token_TokenKind_TOKEN_PLUS, token_TokenKind_TOKEN_MINUS, token_TokenKind_TOKEN_STAR, token_TokenKind_TOKEN_SLASH, token_TokenKind_TOKEN_PERCENT, token_TokenKind_TOKEN_AMP, token_TokenKind_TOKEN_PIPE, token_TokenKind_TOKEN_CARET, token_TokenKind_TOKEN_LSHIFT, token_TokenKind_TOKEN_RSHIFT, token_TokenKind_TOKEN_PLUS_EQ, token_TokenKind_TOKEN_MINUS_EQ, token_TokenKind_TOKEN_STAR_EQ, token_TokenKind_TOKEN_SLASH_EQ, token_TokenKind_TOKEN_PERCENT_EQ, token_TokenKind_TOKEN_AMP_EQ, token_TokenKind_TOKEN_PIPE_EQ, token_TokenKind_TOKEN_CARET_EQ, token_TokenKind_TOKEN_LSHIFT_EQ, token_TokenKind_TOKEN_RSHIFT_EQ, token_TokenKind_TOKEN_TILDE, token_TokenKind_TOKEN_ASSIGN, token_TokenKind_TOKEN_EQ, token_TokenKind_TOKEN_NE, token_TokenKind_TOKEN_LT, token_TokenKind_TOKEN_GT, token_TokenKind_TOKEN_LE, token_TokenKind_TOKEN_GE, token_TokenKind_TOKEN_AMPAMP, token_TokenKind_TOKEN_PIPEPIPE, token_TokenKind_TOKEN_BANG, token_TokenKind_TOKEN_QUESTION, token_TokenKind_TOKEN_AS };
struct token_Token { enum token_TokenKind kind; int32_t line; int32_t col; int32_t int_val; double float_val; uint8_t * ident; int32_t ident_len; };
struct lexer_Lexer { size_t pos; int32_t line; int32_t col; };
struct lexer_LexerResult { struct lexer_Lexer next_lex; struct token_Token tok; size_t token_start; };
enum std_io_driver_IO_Result { std_io_driver_IO_Result_Ok, std_io_driver_IO_Result_Err, std_io_driver_IO_Result_Timeout, std_io_driver_IO_Result_Cancelled };
struct std_io_driver_Buffer { uint8_t * ptr; size_t len; size_t handle; };
struct std_io_driver_Completion { int32_t tag; };
struct std_io_driver_AsyncContext { uint32_t flags; };
struct shulang_slice_uint8_t { uint8_t *data; size_t length; };
struct std_io_ReadOnlySlice { struct shulang_slice_uint8_t data; };
struct std_io_WriteOnlySlice { struct shulang_slice_uint8_t data; };
struct std_fs_FsIovecBuf { uint8_t * ptr; size_t len; size_t handle; };
struct parser_OneFuncResult { int ok; struct lexer_Lexer next_lex; uint8_t name[64]; int32_t name_len; int32_t num_params; int32_t num_consts; int32_t num_lets; int has_if_expr; int if_cond_true; int32_t if_then_val; int32_t if_else_val; int32_t if_cond_expr_ref; int has_mul; int32_t mul_right_val; int has_binop; int32_t binop_right_val; int32_t binop_left_param_idx; int32_t binop_right_param_idx; int has_unary_neg; int32_t return_val; int has_call_expr; uint8_t call_callee_name[64]; int32_t call_callee_len; uint8_t return_var_name[64]; int32_t return_var_name_len; int32_t return_expr_ref; int has_explicit_return_kw; int32_t call_num_args; int32_t num_loops; int32_t num_for_loops; int32_t num_if_stmts; int32_t num_src_stmt_order; int32_t num_src_body_expr_stmts; int32_t func_return_type_ref; };
struct parser_ParseResult { int ok; int32_t return_val; };
struct parser_ParseIntoResult { int32_t ok; int32_t main_idx; };
struct parser_TopLevelLetResult { int ok; struct lexer_Lexer next_lex; };
struct parser_CollectImportsResult { struct lexer_Lexer lex; };
struct parser_ParseExprResult { int ok; int32_t expr_ref; struct lexer_Lexer next_lex; };
struct parser_ParseBlockResult { int ok; int32_t block_ref; struct lexer_Lexer next_lex; };
struct parser_ExternParseResult { struct lexer_Lexer next_lex; uint8_t name[64]; int32_t name_len; int32_t return_ty_ref; int32_t num_params; };
struct parser_TrySkipAllowResult { struct lexer_Lexer lex; int32_t skipped; uint8_t _pad[4]; };
struct parser_LibraryParseResult { int ok; uint8_t _pad[4]; struct lexer_Lexer next_lex; uint8_t name[64]; int32_t name_len; uint8_t _pad_tail[4]; };
struct parser_LibraryParseScanResult { int ok; uint8_t _pad[4]; struct lexer_Lexer next_lex; uint8_t name[64]; int32_t name_len; uint8_t param_name[32]; int32_t param_name_len; uint8_t param_type_name[64]; int32_t param_type_len; uint8_t field_name[64]; int32_t field_len; uint8_t _pad_tail[4]; uint8_t _pad_tail2[4]; };
struct codegen_CodegenOutBuf { uint8_t data[8388608]; int32_t len; };
struct preprocess_ParseDirectiveResult { int32_t kind; int32_t sym_len; };
enum asm_types_TargetArch { asm_types_TargetArch_TARGET_X86_64, asm_types_TargetArch_TARGET_ARM64, asm_types_TargetArch_TARGET_RISCV64, asm_types_TargetArch_TARGET_NONE };
struct platform_elf_ElfLabelEntry { uint8_t name[64]; int32_t name_len; int32_t offset; };
struct platform_elf_ElfPatchEntry { int32_t rel32_offset; uint8_t name[64]; int32_t name_len; int32_t patch_imm_bits; };
struct platform_elf_ElfRelocEntry { int32_t offset; int32_t name_len; };
struct platform_elf_ElfSymEntry { uint8_t name[64]; int32_t name_len; int32_t offset; };
struct platform_elf_ElfCodegenCtx { int32_t code_len; struct platform_elf_ElfLabelEntry labels[2048]; int32_t num_labels; struct platform_elf_ElfPatchEntry patches[2048]; int32_t num_patches; struct platform_elf_ElfRelocEntry relocs[2048]; uint8_t reloc_sym_names[2048][64]; int32_t num_relocs; struct platform_elf_ElfSymEntry syms[2048]; int32_t num_syms; int32_t sym_name_len; int32_t e_machine; int32_t reloc_type_r_pc32; int32_t current_frame_size; int32_t macho_leading_underscore; uint8_t code_data[8388608]; uint8_t sym_name_data[32768]; };
struct backend_AsmFuncCtx { int32_t frame_size; int32_t next_offset; int32_t num_locals; int32_t label_counter; struct ast_Module * module_ref; uint8_t loop_break_label_stack[512]; int32_t loop_break_len_stack[8]; uint8_t loop_continue_label_stack[512]; int32_t loop_continue_len_stack[8]; uint8_t break_label[64]; int32_t break_len; uint8_t continue_label[64]; int32_t continue_len; int32_t loop_label_depth; struct ast_PipelineDepCtx * dep_pipe; uint8_t tail_join_label[64]; int32_t tail_join_label_len; };
extern int32_t ast_pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx * ctx);
extern int32_t ast_pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx * ctx, int32_t i);
extern void ast_pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx * ctx, int32_t i, uint8_t * dst, int32_t cap);
extern int32_t std_fs_fs_open_read(uint8_t * path);
extern int32_t std_fs_fs_close(int32_t fd);
extern ptrdiff_t std_fs_fs_read(int32_t fd, uint8_t * buf, size_t count);
extern struct lexer_Lexer lexer_lexer_init();
extern void parser_parse_into_init(struct ast_Module * restrict module, struct ast_ASTArena * restrict arena);
extern struct parser_ParseIntoResult parser_parse_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct shulang_slice_uint8_t * source);
extern int32_t typeck_typeck_su_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
extern void parser_parse_into_set_main_index(struct ast_Module * restrict module, int32_t main_idx);
extern int32_t typeck_typeck_su_ast_library(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
extern int32_t parser_get_module_num_imports(struct ast_Module * restrict module);
extern int32_t ast_pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx * ctx);
extern void parser_get_module_import_path(struct ast_Module * restrict module, int32_t i, uint8_t out[64]);
extern void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx * ctx, int32_t idx, struct ast_Module * m);
extern void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx * ctx, int32_t idx, struct ast_ASTArena * a);
extern int32_t preprocess_preprocess_su_buf(uint8_t source_buf[4194304], ptrdiff_t source_len, uint8_t out_buf[4194304], int32_t out_cap);
extern struct ast_ASTArena * ast_pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern struct ast_Module * ast_pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void ast_pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx * ctx, int32_t n);
extern void typeck_typeck_merge_dep_struct_layouts_into_entry(struct ast_Module * mod, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
extern int32_t asm_driver_skip_codegen_dep_0_get();
extern int32_t ast_pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx * ctx, int32_t idx);
extern void ast_pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * bytes, int32_t len);
extern void ast_pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx * ctx, int32_t idx, uint8_t * dst);
extern void asm_driver_set_current_dep_path_for_codegen(uint8_t * path);
extern int32_t codegen_codegen_su_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx, int32_t dep_index);
extern uint8_t * driver_dep_arena_buf(int32_t i);
extern uint8_t * driver_dep_module_buf(int32_t i);
extern int32_t driver_dep_seeded_get(int32_t i);
extern int32_t driver_dep_slot_for_path(uint8_t * path);
extern int32_t get_ndep();
extern void parser_parse_one_function_impl(struct parser_OneFuncResult * out, struct ast_ASTArena * arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
extern struct parser_OneFuncResult parser_onefunc_alloc_wired_for_parse(struct lexer_Lexer lex);
extern struct shulang_slice_uint8_t pipeline_source_slice(uint8_t * data, int32_t len);
extern void ast_ast_arena_init(struct ast_ASTArena * arena);
extern int32_t asm_asm_codegen_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out_buf, struct ast_PipelineDepCtx * ctx);
extern void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types);
extern void driver_diagnostic_typeck_fail();
extern void driver_diagnostic_before_codegen(int32_t num_funcs, int32_t out_len);
extern void driver_diagnostic_after_dep_codegen(int32_t j, int32_t out_len);
extern void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep);
extern int32_t driver_skip_codegen_dep_0_get();
extern int32_t driver_check_only_get();
extern void driver_diagnostic_entry_already(int32_t v);
extern void driver_diagnostic_source_len(int32_t len);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_entry_module(struct ast_Module * module, struct ast_ASTArena * arena);
extern void driver_set_current_dep_path_for_codegen(uint8_t * path);
int32_t pipeline_parse_into_buf(struct ast_ASTArena * arena, struct ast_Module * module, uint8_t buf[4194304], int32_t buf_len);
int32_t pipeline_path_append_from_buf_256(struct ast_PipelineDepCtx * ctx, int32_t off, uint8_t buf[256], int32_t len);
int32_t pipeline_path_append_from_buf_512(struct ast_PipelineDepCtx * ctx, int32_t off, uint8_t buf[512], int32_t len);
int32_t pipeline_path_append_import_path(struct ast_PipelineDepCtx * ctx, int32_t off, uint8_t import_path[64], int32_t path_len);
int32_t pipeline_resolve_path_su(struct ast_PipelineDepCtx * ctx, uint8_t import_path[64], int32_t path_len);
int32_t pipeline_read_file_su(struct ast_PipelineDepCtx * ctx);
int32_t pipeline_parse_one_function_ok(struct shulang_slice_uint8_t * source, struct ast_ASTArena * arena);
struct parser_ParseIntoResult pipeline_parse_into_with_init(struct ast_ASTArena * arena, struct ast_Module * module, struct shulang_slice_uint8_t * source);
struct parser_ParseIntoResult pipeline_parse_into_with_init_buf(struct ast_ASTArena * arena, struct ast_Module * module, uint8_t * data, int32_t len);
int32_t pipeline_typeck_after_parse_ok(struct ast_ASTArena * arena, struct ast_Module * module, struct shulang_slice_uint8_t * source, struct ast_PipelineDepCtx * ctx);
int32_t pipeline_load_and_sync_direct_import_deps(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
int32_t pipeline_lsp_diag_parse_typeck_buf(struct ast_Module * module, struct ast_ASTArena * arena, uint8_t * source_data, int32_t source_len, struct ast_PipelineDepCtx * ctx);
int32_t pipeline_run_su_pipeline_impl(struct ast_Module * module, struct ast_ASTArena * arena, uint8_t * source_data, size_t source_len, struct codegen_CodegenOutBuf * out_buf, struct ast_PipelineDepCtx * ctx);
int32_t pipeline_parse_into_buf(struct ast_ASTArena * arena, struct ast_Module * module, uint8_t buf[4194304], int32_t buf_len) {
  (void)(parser_parse_into_init(module, arena));
  struct parser_ParseIntoResult res = parser_parse_into_buf(arena, module, (&((buf)[0])), buf_len);
  (void)(({ int32_t __tmp = 0; if ((res).ok != 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t pipeline_path_append_from_buf_256(struct ast_PipelineDepCtx * ctx, int32_t off, uint8_t buf[256], int32_t len) {
  int32_t k = 0;
  while (k < len && off < 508) {
    (void)(((off < 0 || (off) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off] = (k < 0 || (k) >= 256 ? (shulang_panic_(1, 0), (buf)[0]) : (buf)[k]), 0))));
    (void)((off = off + 1));
    (void)((k = k + 1));
  }
  return off;
}
int32_t pipeline_path_append_from_buf_512(struct ast_PipelineDepCtx * ctx, int32_t off, uint8_t buf[512], int32_t len) {
  int32_t k = 0;
  while (k < len && off < 508) {
    (void)(((off < 0 || (off) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off] = (k < 0 || (k) >= 512 ? (shulang_panic_(1, 0), (buf)[0]) : (buf)[k]), 0))));
    (void)((off = off + 1));
    (void)((k = k + 1));
  }
  return off;
}
int32_t pipeline_path_append_import_path(struct ast_PipelineDepCtx * ctx, int32_t off, uint8_t import_path[64], int32_t path_len) {
  int32_t k = 0;
  while (k < path_len && off < 508) {
    (void)(({ uint8_t __tmp = 0; if ((k < 0 || (k) >= 64 ? (shulang_panic_(1, 0), (import_path)[0]) : (import_path)[k]) == 46) {   (void)(((off < 0 || (off) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off] = 47, 0))));
 } else {   (void)(((off < 0 || (off) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off] = (k < 0 || (k) >= 64 ? (shulang_panic_(1, 0), (import_path)[0]) : (import_path)[k]), 0))));
 } ; __tmp; }));
    (void)((off = off + 1));
    (void)((k = k + 1));
  }
  return off;
}
int32_t pipeline_resolve_path_su(struct ast_PipelineDepCtx * ctx, uint8_t import_path[64], int32_t path_len) {
  int32_t r = 0;
  int32_t n_lib = pipeline_ctx_lib_root_count(ctx);
  while (r < n_lib) {
    int32_t off = 0;
    int32_t lr_len = pipeline_ctx_lib_root_len(ctx, r);
    (void)(({ int32_t __tmp = 0; if (lr_len > 0) {   uint8_t lr_buf[256] = { 0 };
  (void)(pipeline_ctx_lib_root_copy(ctx, r, (&((lr_buf)[0])), 256));
  (void)((off = pipeline_path_append_from_buf_256(ctx, 0, lr_buf, lr_len)));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (off < 509) {   (void)(((off < 0 || (off) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off] = 47, 0))));
  (void)((off = off + 1));
 } else (__tmp = 0) ; __tmp; }));
    (void)((off = pipeline_path_append_import_path(ctx, off, import_path, path_len)));
    (void)(({ int32_t __tmp = 0; if (off + 4 <= 512) {   (void)(((off < 0 || (off) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off] = 46, 0))));
  (void)(((off + 1 < 0 || (off + 1) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 1] = 115, 0))));
  (void)(((off + 2 < 0 || (off + 2) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 2] = 117, 0))));
  (void)(((off + 3 < 0 || (off + 3) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 3] = 0, 0))));
  int32_t fd = std_fs_fs_open_read((ctx)->path_buf);
  (void)(({ int32_t __tmp = 0; if (fd >= 0) {   (void)(std_fs_fs_close(fd));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (off + 8 <= 512) {   (void)(((off < 0 || (off) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off] = 47, 0))));
  (void)(((off + 1 < 0 || (off + 1) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 1] = 109, 0))));
  (void)(((off + 2 < 0 || (off + 2) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 2] = 111, 0))));
  (void)(((off + 3 < 0 || (off + 3) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 3] = 100, 0))));
  (void)(((off + 4 < 0 || (off + 4) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 4] = 46, 0))));
  (void)(((off + 5 < 0 || (off + 5) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 5] = 115, 0))));
  (void)(((off + 6 < 0 || (off + 6) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 6] = 117, 0))));
  (void)(((off + 7 < 0 || (off + 7) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 7] = 0, 0))));
  int32_t fd_mod = std_fs_fs_open_read((ctx)->path_buf);
  __tmp = ({ int32_t __tmp = 0; if (fd_mod >= 0) {   (void)(std_fs_fs_close(fd_mod));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (path_len > 0 && path_len < 64) {   int32_t has_dot = 0;
  int32_t k = 0;
  while (k < path_len) {
    (void)(({ int32_t __tmp = 0; if ((k < 0 || (k) >= 64 ? (shulang_panic_(1, 0), (import_path)[0]) : (import_path)[k]) == 46) {   (void)((has_dot = 1));
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  __tmp = ({ int32_t __tmp = 0; if (has_dot == 0) {   int32_t off_base = 0;
  (void)(({ int32_t __tmp = 0; if (lr_len > 0) {   uint8_t lr_buf2[256] = { 0 };
  (void)(pipeline_ctx_lib_root_copy(ctx, r, (&((lr_buf2)[0])), 256));
  (void)((off_base = pipeline_path_append_from_buf_256(ctx, 0, lr_buf2, lr_len)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (off_base < 509) {   (void)(((off_base < 0 || (off_base) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off_base] = 47, 0))));
  (void)((off_base = off_base + 1));
 } else (__tmp = 0) ; __tmp; }));
  (void)((off_base = pipeline_path_append_import_path(ctx, off_base, import_path, path_len)));
  (void)(({ int32_t __tmp = 0; if (off_base < 509) {   (void)(((off_base < 0 || (off_base) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off_base] = 47, 0))));
  (void)((off_base = off_base + 1));
 } else (__tmp = 0) ; __tmp; }));
  (void)((off_base = pipeline_path_append_import_path(ctx, off_base, import_path, path_len)));
  __tmp = ({ int32_t __tmp = 0; if (off_base + 4 <= 512) {   (void)(((off_base < 0 || (off_base) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off_base] = 46, 0))));
  (void)(((off_base + 1 < 0 || (off_base + 1) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off_base + 1] = 115, 0))));
  (void)(((off_base + 2 < 0 || (off_base + 2) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off_base + 2] = 117, 0))));
  (void)(((off_base + 3 < 0 || (off_base + 3) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off_base + 3] = 0, 0))));
  int32_t fd_dir = std_fs_fs_open_read((ctx)->path_buf);
  __tmp = ({ int32_t __tmp = 0; if (fd_dir >= 0) {   (void)(std_fs_fs_close(fd_dir));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((r = r + 1));
  }
  (void)(({ int32_t __tmp = 0; if ((ctx)->entry_dir_len > 0) {   int32_t has_dot = 0;
  int32_t k = 0;
  while (k < path_len && k < 64) {
    (void)(({ int32_t __tmp = 0; if ((k < 0 || (k) >= 64 ? (shulang_panic_(1, 0), (import_path)[0]) : (import_path)[k]) == 46) {   (void)((has_dot = 1));
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  __tmp = ({ int32_t __tmp = 0; if (has_dot == 0) {   int32_t off = pipeline_path_append_from_buf_512(ctx, 0, (ctx)->entry_dir_buf, (ctx)->entry_dir_len);
  (void)(({ int32_t __tmp = 0; if (off < 509) {   (void)(((off < 0 || (off) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off] = 47, 0))));
  (void)((off = off + 1));
 } else (__tmp = 0) ; __tmp; }));
  (void)((off = pipeline_path_append_import_path(ctx, off, import_path, path_len)));
  __tmp = ({ int32_t __tmp = 0; if (off + 4 <= 512) {   (void)(((off < 0 || (off) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off] = 46, 0))));
  (void)(((off + 1 < 0 || (off + 1) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 1] = 115, 0))));
  (void)(((off + 2 < 0 || (off + 2) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 2] = 117, 0))));
  (void)(((off + 3 < 0 || (off + 3) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 3] = 0, 0))));
  int32_t fd = std_fs_fs_open_read((ctx)->path_buf);
  (void)(({ int32_t __tmp = 0; if (fd >= 0) {   (void)(std_fs_fs_close(fd));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (off + 8 <= 512) {   (void)(((off < 0 || (off) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off] = 47, 0))));
  (void)(((off + 1 < 0 || (off + 1) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 1] = 109, 0))));
  (void)(((off + 2 < 0 || (off + 2) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 2] = 111, 0))));
  (void)(((off + 3 < 0 || (off + 3) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 3] = 100, 0))));
  (void)(((off + 4 < 0 || (off + 4) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 4] = 46, 0))));
  (void)(((off + 5 < 0 || (off + 5) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 5] = 115, 0))));
  (void)(((off + 6 < 0 || (off + 6) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 6] = 117, 0))));
  (void)(((off + 7 < 0 || (off + 7) >= 512 ? (shulang_panic_(1, 0), 0) : (((ctx)->path_buf)[off + 7] = 0, 0))));
  int32_t fd_mod = std_fs_fs_open_read((ctx)->path_buf);
  __tmp = ({ int32_t __tmp = 0; if (fd_mod >= 0) {   (void)(std_fs_fs_close(fd_mod));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
}
int32_t pipeline_read_file_su(struct ast_PipelineDepCtx * ctx) {
  int32_t fd = std_fs_fs_open_read((ctx)->path_buf);
  (void)(({ int32_t __tmp = 0; if (fd < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  size_t cap = 4194304;
  ptrdiff_t n = std_fs_fs_read(fd, (&(((ctx)->loaded_buf)[0])), cap);
  (void)(std_fs_fs_close(fd));
  (void)(({ int32_t __tmp = 0; if (n < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(((ctx)->loaded_len = n));
  return 0;
}
int32_t pipeline_parse_one_function_ok(struct shulang_slice_uint8_t * source, struct ast_ASTArena * arena) {
  struct lexer_Lexer lex = lexer_init();
  struct parser_OneFuncResult res = parser_onefunc_alloc_wired_for_parse(lex);
  (void)(parser_parse_one_function_impl((&(res)), arena, lex, source));
  (void)(({ int32_t __tmp = 0; if ((res).ok) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
struct parser_ParseIntoResult pipeline_parse_into_with_init(struct ast_ASTArena * arena, struct ast_Module * module, struct shulang_slice_uint8_t * source) {
  (void)(ast_arena_init(arena));
  (void)(parser_parse_into_init(module, arena));
  return parser_parse_into(arena, module, source);
}
struct parser_ParseIntoResult pipeline_parse_into_with_init_buf(struct ast_ASTArena * arena, struct ast_Module * module, uint8_t * data, int32_t len) {
  (void)(ast_arena_init(arena));
  (void)(parser_parse_into_init(module, arena));
  return parser_parse_into_buf(arena, module, data, len);
}
int32_t pipeline_typeck_after_parse_ok(struct ast_ASTArena * arena, struct ast_Module * module, struct shulang_slice_uint8_t * source, struct ast_PipelineDepCtx * ctx) {
  struct parser_ParseIntoResult r = pipeline_parse_into_with_init(arena, module, source);
  (void)(({ int32_t __tmp = 0; if ((r).ok != 0) {   return (r).main_idx;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_parse_into_set_main_index(module, (r).main_idx));
  (void)(({ int32_t __tmp = 0; if ((module)->main_func_index < 0) {   int32_t tc_lib = typeck_su_ast_library(module, arena, ctx);
  (void)(({ int32_t __tmp = 0; if (tc_lib != 0) {   (void)(driver_diagnostic_typeck_fail());
 } else (__tmp = 0) ; __tmp; }));
  return tc_lib;
 } else (__tmp = 0) ; __tmp; }));
  int32_t tc_main = typeck_su_ast(module, arena, ctx);
  (void)(({ int32_t __tmp = 0; if (tc_main != 0) {   (void)(driver_diagnostic_typeck_fail());
 } else (__tmp = 0) ; __tmp; }));
  return tc_main;
}
int32_t pipeline_load_and_sync_direct_import_deps(struct ast_Module * module, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx) {
  int32_t n_imports = parser_get_module_num_imports(module);
  (void)(({ int32_t __tmp = 0; if (pipeline_dep_ctx_ndep(ctx) == 0) {   __tmp = ({ int32_t __tmp = 0; if (n_imports > 0) {   int32_t i = 0;
  while (i < n_imports) {
    uint8_t path_buf[64] = { 0 };
    (void)(parser_get_module_import_path(module, i, path_buf));
    int32_t path_len = 0;
    while (path_len < 64 && (path_len < 0 || (path_len) >= 64 ? (shulang_panic_(1, 0), (path_buf)[0]) : (path_buf)[path_len]) != 0) {
      (void)((path_len = path_len + 1));
    }
    int32_t global_slot = driver_dep_slot_for_path((&((path_buf)[0])));
    (void)(({ int32_t __tmp = 0; if (global_slot >= 0 && driver_dep_seeded_get(global_slot) != 0) {   (void)(pipeline_dep_ctx_set_arena(ctx, i, ((struct ast_ASTArena *)(driver_dep_arena_buf(global_slot)))));
  (void)(pipeline_dep_ctx_set_module(ctx, i, ((struct ast_Module *)(driver_dep_module_buf(global_slot)))));
 } else (__tmp = ({ int32_t __tmp = 0; if (driver_dep_seeded_get(i) != 0) {   (void)(pipeline_dep_ctx_set_arena(ctx, i, ((struct ast_ASTArena *)(driver_dep_arena_buf(i)))));
  (void)(pipeline_dep_ctx_set_module(ctx, i, ((struct ast_Module *)(driver_dep_module_buf(i)))));
 } else {   (void)(({ int32_t __tmp = 0; if (pipeline_resolve_path_su(ctx, path_buf, path_len) != 0) {   return (-7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_read_file_su(ctx) != 0) {   return (-8);
 } else (__tmp = 0) ; __tmp; }));
  int32_t out_len = preprocess_su_buf((ctx)->loaded_buf, (ctx)->loaded_len, (ctx)->preprocess_buf, 4194304);
  (void)(({ int32_t __tmp = 0; if (out_len < 0) {   return (-9);
 } else (__tmp = 0) ; __tmp; }));
  (void)(((ctx)->preprocess_len = out_len));
  (void)(pipeline_dep_ctx_set_arena(ctx, i, ((struct ast_ASTArena *)(driver_dep_arena_buf(i)))));
  (void)(pipeline_dep_ctx_set_module(ctx, i, ((struct ast_Module *)(driver_dep_module_buf(i)))));
  struct ast_ASTArena * dep_arena = pipeline_dep_ctx_arena_at(ctx, i);
  struct ast_Module * dep_module = pipeline_dep_ctx_module_at(ctx, i);
  __tmp = ({ int32_t __tmp = 0; if (pipeline_parse_into_buf(dep_arena, dep_module, (ctx)->preprocess_buf, (ctx)->preprocess_len) != 0) {   return (-10);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; })) ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)(pipeline_dep_ctx_set_ndep(ctx, n_imports));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t dep_sync_nd = pipeline_dep_ctx_ndep(ctx);
  int32_t dep_sync_i = 0;
  while (dep_sync_i < dep_sync_nd) {
    uint8_t sync_path[64] = { 0 };
    (void)(parser_get_module_import_path(module, dep_sync_i, sync_path));
    int32_t sync_slot = driver_dep_slot_for_path((&((sync_path)[0])));
    (void)(({ int32_t __tmp = 0; if (sync_slot < 0) {   (void)((sync_slot = dep_sync_i));
 } else (__tmp = 0) ; __tmp; }));
    (void)(pipeline_dep_ctx_set_module(ctx, dep_sync_i, ((struct ast_Module *)(driver_dep_module_buf(sync_slot)))));
    (void)(pipeline_dep_ctx_set_arena(ctx, dep_sync_i, ((struct ast_ASTArena *)(driver_dep_arena_buf(sync_slot)))));
    (void)((dep_sync_i = dep_sync_i + 1));
  }
  (void)(typeck_merge_dep_struct_layouts_into_entry(module, arena, ctx));
  return 0;
}
int32_t pipeline_lsp_diag_parse_typeck_buf(struct ast_Module * module, struct ast_ASTArena * arena, uint8_t * source_data, int32_t source_len, struct ast_PipelineDepCtx * ctx) {
  struct parser_ParseIntoResult r = pipeline_parse_into_with_init_buf(arena, module, source_data, source_len);
  (void)(({ int32_t __tmp = 0; if ((r).ok != 0) {   (void)(driver_diagnostic_parse_fail((r).main_idx, (module)->num_funcs, (arena)->num_types));
  return (-2);
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_parse_into_set_main_index(module, (r).main_idx));
  int32_t load_rc = pipeline_load_and_sync_direct_import_deps(module, arena, ctx);
  (void)(({ int32_t __tmp = 0; if (load_rc != 0) {   return load_rc;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((module)->main_func_index < 0) {   int32_t tc_lib = typeck_su_ast_library(module, arena, ctx);
  (void)(({ int32_t __tmp = 0; if (tc_lib != 0) {   (void)(driver_diagnostic_typeck_fail());
  return (-3);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t tc_main = typeck_su_ast(module, arena, ctx);
  (void)(({ int32_t __tmp = 0; if (tc_main != 0) {   (void)(driver_diagnostic_typeck_fail());
  return (-3);
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t pipeline_run_su_pipeline_impl(struct ast_Module * module, struct ast_ASTArena * arena, uint8_t * source_data, size_t source_len, struct codegen_CodegenOutBuf * out_buf, struct ast_PipelineDepCtx * ctx) {
  (void)(driver_diagnostic_entry_already((ctx)->entry_already_parsed));
  (void)(({ int32_t __tmp = 0; if ((ctx)->entry_already_parsed == 0) {   int32_t len_i32 = ((int32_t)(source_len));
  (void)(driver_diagnostic_source_len(len_i32));
  struct parser_ParseIntoResult r = pipeline_parse_into_with_init_buf(arena, module, source_data, len_i32);
  (void)(({ int32_t __tmp = 0; if ((r).ok != 0) {   (void)(driver_diagnostic_parse_fail((r).main_idx, (module)->num_funcs, (arena)->num_types));
  return (-2);
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_parse_into_set_main_index(module, (r).main_idx));
 } else (__tmp = 0) ; __tmp; }));
  (void)(driver_diagnostic_after_entry_parse((module)->num_funcs));
  (void)(driver_diagnostic_entry_module(module, arena));
  int32_t load_rc = pipeline_load_and_sync_direct_import_deps(module, arena, ctx);
  (void)(({ int32_t __tmp = 0; if (load_rc != 0) {   return load_rc;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((module)->main_func_index < 0) {   int32_t tc_lib = typeck_su_ast_library(module, arena, ctx);
  __tmp = ({ int32_t __tmp = 0; if (tc_lib != 0) {   (void)(driver_diagnostic_typeck_fail());
  return tc_lib;
 } else (__tmp = 0) ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (typeck_su_ast(module, arena, ctx) != 0) {   (void)(driver_diagnostic_typeck_fail());
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (driver_check_only_get() != 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out_buf)->len = 0));
  (void)(driver_diagnostic_before_codegen((module)->num_funcs, (out_buf)->len));
  int32_t skip_asm_dep_codegen = 0;
  (void)(({ int32_t __tmp = 0; if ((ctx)->asm_entry_module_only != 0 && (ctx)->use_asm_backend != 0) {   (void)((skip_asm_dep_codegen = 1));
 } else (__tmp = 0) ; __tmp; }));
  int32_t ndep_codegen = pipeline_dep_ctx_ndep(ctx);
  int32_t j = 0;
  while (j < ndep_codegen) {
    (void)(({ int32_t __tmp = 0; if (j == 0 && asm_driver_skip_codegen_dep_0_get() != 0) {   (void)((j = j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (pipeline_dep_ctx_import_path_len(ctx, j) == 0) {   uint8_t path_buf[64] = { 0 };
  (void)(parser_get_module_import_path(module, j, path_buf));
  int32_t path_len = 0;
  while (path_len < 64 && (path_len < 0 || (path_len) >= 64 ? (shulang_panic_(1, 0), (path_buf)[0]) : (path_buf)[path_len]) != 0) {
    (void)((path_len = path_len + 1));
  }
  __tmp = ({ int32_t __tmp = 0; if (path_len > 0) {   (void)(pipeline_dep_ctx_set_import_path(ctx, j, (&((path_buf)[0])), path_len));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Module * dep_mod = pipeline_dep_ctx_module_at(ctx, j);
    uint8_t dep_path_buf[64] = { 0 };
    (void)(pipeline_dep_ctx_import_path_copy64(ctx, j, (&((dep_path_buf)[0]))));
    (void)(asm_driver_set_current_dep_path_for_codegen((&((dep_path_buf)[0]))));
    (void)(({ int32_t __tmp = 0; if ((dep_mod)->num_funcs > 0) {   __tmp = ({ int32_t __tmp = 0; if ((ctx)->use_asm_backend != 0) {   __tmp = ({ int32_t __tmp = 0; if (skip_asm_dep_codegen == 0) {   __tmp = ({ int32_t __tmp = 0; if (asm_codegen_ast(dep_mod, pipeline_dep_ctx_arena_at(ctx, j), out_buf, ctx) != 0) {   (void)(driver_diagnostic_codegen_fail(j, 1));
  return (-6);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (codegen_su_ast(dep_mod, pipeline_dep_ctx_arena_at(ctx, j), out_buf, ctx, j) != 0) {   (void)(driver_diagnostic_codegen_fail(j, 1));
  return (-6);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(driver_diagnostic_after_dep_codegen(j, (out_buf)->len));
    (void)(asm_driver_set_current_dep_path_for_codegen(((uint8_t *)(0))));
    (void)((j = j + 1));
  }
  (void)(driver_diagnostic_entry_module(module, arena));
  (void)(({ int32_t __tmp = 0; if ((ctx)->use_asm_backend != 0) {   __tmp = ({ int32_t __tmp = 0; if (asm_codegen_ast(module, arena, out_buf, ctx) != 0) {   (void)(driver_diagnostic_codegen_fail(0, 0));
  return (-6);
 } else (__tmp = 0) ; __tmp; });
 } else {   int32_t main_dep_index = (-1);
  __tmp = ({ int32_t __tmp = 0; if (codegen_su_ast(module, arena, out_buf, ctx, main_dep_index) != 0) {   (void)(driver_diagnostic_codegen_fail(0, 0));
  return (-6);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  return 0;
}


/* pipeline extern TU: drop aliases before glue (ast_pool uses pipeline_* names) */
#undef pipeline_ctx_lib_root_count
#undef pipeline_ctx_lib_root_len
#undef pipeline_ctx_lib_root_copy
#undef pipeline_dep_ctx_ndep
#undef pipeline_dep_ctx_set_module
#undef pipeline_dep_ctx_set_arena
#undef pipeline_dep_ctx_arena_at
#undef pipeline_dep_ctx_module_at
#undef pipeline_dep_ctx_set_ndep
#undef pipeline_dep_ctx_import_path_len
#undef pipeline_dep_ctx_set_import_path
#undef pipeline_dep_ctx_import_path_copy64
#undef fs_open_read
#undef fs_close
#undef fs_read
#undef typeck_su_ast
#undef typeck_su_ast_library
#undef typeck_merge_dep_struct_layouts_into_entry
#undef codegen_su_ast
#undef asm_codegen_ast
#undef lexer_init
#undef lexer_lexer_next_into
#undef lexer_lexer_next_buf
#undef ast_arena_init
#undef preprocess_su_buf

#include "pipeline_glue.c"
