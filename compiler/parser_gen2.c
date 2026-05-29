/* generated (single-file with deps) */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
/* parser extern ast helpers */
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
enum token_TokenKind { token_TokenKind_TOKEN_EOF, token_TokenKind_TOKEN_FUNCTION, token_TokenKind_TOKEN_LET, token_TokenKind_TOKEN_CONST, token_TokenKind_TOKEN_IF, token_TokenKind_TOKEN_ELSE, token_TokenKind_TOKEN_WHILE, token_TokenKind_TOKEN_LOOP, token_TokenKind_TOKEN_FOR, token_TokenKind_TOKEN_BREAK, token_TokenKind_TOKEN_CONTINUE, token_TokenKind_TOKEN_RETURN, token_TokenKind_TOKEN_PANIC, token_TokenKind_TOKEN_DEFER, token_TokenKind_TOKEN_MATCH, token_TokenKind_TOKEN_STRUCT, token_TokenKind_TOKEN_PACKED, token_TokenKind_TOKEN_ENUM, token_TokenKind_TOKEN_GOTO, token_TokenKind_TOKEN_TRAIT, token_TokenKind_TOKEN_IMPL, token_TokenKind_TOKEN_SELF, token_TokenKind_TOKEN_UNDERSCORE, token_TokenKind_TOKEN_IMPORT, token_TokenKind_TOKEN_EXTERN, token_TokenKind_TOKEN_IDENT, token_TokenKind_TOKEN_I32, token_TokenKind_TOKEN_BOOL, token_TokenKind_TOKEN_U8, token_TokenKind_TOKEN_U32, token_TokenKind_TOKEN_U64, token_TokenKind_TOKEN_I64, token_TokenKind_TOKEN_USIZE, token_TokenKind_TOKEN_ISIZE, token_TokenKind_TOKEN_I32X4, token_TokenKind_TOKEN_I32X8, token_TokenKind_TOKEN_I32X16, token_TokenKind_TOKEN_U32X4, token_TokenKind_TOKEN_U32X8, token_TokenKind_TOKEN_U32X16, token_TokenKind_TOKEN_TRUE, token_TokenKind_TOKEN_FALSE, token_TokenKind_TOKEN_F32, token_TokenKind_TOKEN_F64, token_TokenKind_TOKEN_VOID, token_TokenKind_TOKEN_INT, token_TokenKind_TOKEN_FLOAT, token_TokenKind_TOKEN_LPAREN, token_TokenKind_TOKEN_RPAREN, token_TokenKind_TOKEN_LBRACE, token_TokenKind_TOKEN_RBRACE, token_TokenKind_TOKEN_LBRACKET, token_TokenKind_TOKEN_RBRACKET, token_TokenKind_TOKEN_ARROW, token_TokenKind_TOKEN_FATARROW, token_TokenKind_TOKEN_COMMA, token_TokenKind_TOKEN_COLON, token_TokenKind_TOKEN_DOT, token_TokenKind_TOKEN_SEMICOLON, token_TokenKind_TOKEN_PLUS, token_TokenKind_TOKEN_MINUS, token_TokenKind_TOKEN_STAR, token_TokenKind_TOKEN_SLASH, token_TokenKind_TOKEN_PERCENT, token_TokenKind_TOKEN_AMP, token_TokenKind_TOKEN_PIPE, token_TokenKind_TOKEN_CARET, token_TokenKind_TOKEN_LSHIFT, token_TokenKind_TOKEN_RSHIFT, token_TokenKind_TOKEN_PLUS_EQ, token_TokenKind_TOKEN_MINUS_EQ, token_TokenKind_TOKEN_STAR_EQ, token_TokenKind_TOKEN_SLASH_EQ, token_TokenKind_TOKEN_PERCENT_EQ, token_TokenKind_TOKEN_AMP_EQ, token_TokenKind_TOKEN_PIPE_EQ, token_TokenKind_TOKEN_CARET_EQ, token_TokenKind_TOKEN_LSHIFT_EQ, token_TokenKind_TOKEN_RSHIFT_EQ, token_TokenKind_TOKEN_TILDE, token_TokenKind_TOKEN_ASSIGN, token_TokenKind_TOKEN_EQ, token_TokenKind_TOKEN_NE, token_TokenKind_TOKEN_LT, token_TokenKind_TOKEN_GT, token_TokenKind_TOKEN_LE, token_TokenKind_TOKEN_GE, token_TokenKind_TOKEN_AMPAMP, token_TokenKind_TOKEN_PIPEPIPE, token_TokenKind_TOKEN_BANG, token_TokenKind_TOKEN_QUESTION, token_TokenKind_TOKEN_AS };
struct token_Token { enum token_TokenKind kind; int32_t line; int32_t col; int32_t int_val; double float_val; uint8_t * ident; int32_t ident_len; };
struct lexer_Lexer { size_t pos; int32_t line; int32_t col; };
struct lexer_LexerResult { struct lexer_Lexer next_lex; struct token_Token tok; size_t token_start; };
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

/* ast gen2 single-prefix externs */
extern int32_t ast_arena_expr_alloc(struct ast_ASTArena * arena);
extern int32_t ast_arena_type_alloc(struct ast_ASTArena * arena);
extern int32_t ast_arena_block_alloc(struct ast_ASTArena * arena);
extern struct ast_Block ast_arena_block_get(struct ast_ASTArena * arena, int32_t ref);
extern void ast_arena_init(struct ast_ASTArena * arena);
extern int32_t ast_arena_func_alloc(struct ast_ASTArena * arena);
extern struct ast_Func ast_arena_func_get(struct ast_ASTArena * arena, int32_t ref);

/* pipeline call aliases (ast_pipeline_* extern, pipeline_* call) */
#define pipeline_onefunc_copy_sidecar ast_pipeline_onefunc_copy_sidecar
#define pipeline_onefunc_num_consts ast_pipeline_onefunc_num_consts
#define pipeline_onefunc_num_lets ast_pipeline_onefunc_num_lets
#define pipeline_onefunc_num_whiles ast_pipeline_onefunc_num_whiles
#define pipeline_onefunc_num_fors ast_pipeline_onefunc_num_fors
#define pipeline_expr_append_call_arg ast_pipeline_expr_append_call_arg
#define pipeline_expr_append_array_lit_elem ast_pipeline_expr_append_array_lit_elem
#define pipeline_expr_append_struct_lit_field ast_pipeline_expr_append_struct_lit_field
#define pipeline_onefunc_const_init_val ast_pipeline_onefunc_const_init_val
#define pipeline_onefunc_const_name_copy64 ast_pipeline_onefunc_const_name_copy64
#define pipeline_block_append_const ast_pipeline_block_append_const
#define pipeline_onefunc_const_name_len ast_pipeline_onefunc_const_name_len
#define pipeline_onefunc_let_type_ref ast_pipeline_onefunc_let_type_ref
#define pipeline_onefunc_let_init_ref ast_pipeline_onefunc_let_init_ref
#define pipeline_onefunc_let_init_val ast_pipeline_onefunc_let_init_val
#define pipeline_onefunc_let_name_copy64 ast_pipeline_onefunc_let_name_copy64
#define pipeline_block_append_let ast_pipeline_block_append_let
#define pipeline_onefunc_let_name_len ast_pipeline_onefunc_let_name_len
#define pipeline_block_append_if ast_pipeline_block_append_if
#define pipeline_block_append_stmt_order ast_pipeline_block_append_stmt_order
#define pipeline_block_append_expr_stmt ast_pipeline_block_append_expr_stmt
#define pipeline_block_append_while ast_pipeline_block_append_while
#define pipeline_block_append_for ast_pipeline_block_append_for
#define pipeline_onefunc_append_let ast_pipeline_onefunc_append_let
#define pipeline_onefunc_const_type_ref ast_pipeline_onefunc_const_type_ref
#define pipeline_onefunc_const_init_ref ast_pipeline_onefunc_const_init_ref
#define pipeline_onefunc_append_const ast_pipeline_onefunc_append_const
#define pipeline_onefunc_append_while ast_pipeline_onefunc_append_while
#define pipeline_onefunc_append_for ast_pipeline_onefunc_append_for
#define pipeline_module_import_alloc ast_pipeline_module_import_alloc
#define pipeline_module_import_set_path ast_pipeline_module_import_set_path
#define pipeline_module_import_set_kind ast_pipeline_module_import_set_kind
#define pipeline_module_import_set_binding_name ast_pipeline_module_import_set_binding_name
#define pipeline_module_import_set_select_count ast_pipeline_module_import_set_select_count
#define pipeline_module_import_append_select_name ast_pipeline_module_import_append_select_name
#define pipeline_module_enum_alloc ast_pipeline_module_enum_alloc
#define pipeline_module_enum_name_len ast_pipeline_module_enum_name_len
#define pipeline_module_enum_name_byte_at ast_pipeline_module_enum_name_byte_at
#define pipeline_module_enum_set_name ast_pipeline_module_enum_set_name
#define pipeline_module_func_alloc_slot ast_pipeline_module_func_alloc_slot
#define pipeline_module_func_set_num_params ast_pipeline_module_func_set_num_params
#define pipeline_module_func_set_return_type ast_pipeline_module_func_set_return_type
#define pipeline_module_func_set_body_ref ast_pipeline_module_func_set_body_ref
#define pipeline_module_func_set_body_expr_ref ast_pipeline_module_func_set_body_expr_ref
#define pipeline_module_func_set_is_extern ast_pipeline_module_func_set_is_extern
#define pipeline_module_func_ref_set ast_pipeline_module_func_ref_set
#define pipeline_module_struct_layout_name_len ast_pipeline_module_struct_layout_name_len
#define ast_arena_expr_alloc ast_ast_arena_expr_alloc
#define ast_arena_expr_get ast_ast_arena_expr_get
#define ast_arena_expr_set ast_ast_arena_expr_set
#define ast_arena_type_get ast_ast_arena_type_get
#define ast_arena_type_alloc ast_ast_arena_type_alloc
#define ast_arena_type_set ast_ast_arena_type_set
#define ast_arena_block_alloc ast_ast_arena_block_alloc
#define ast_arena_block_get ast_ast_arena_block_get
#define ast_arena_block_set ast_ast_arena_block_set
#define ast_arena_init ast_ast_arena_init
#define ast_arena_func_alloc ast_ast_arena_func_alloc
#define ast_arena_func_get ast_ast_arena_func_get
#define ast_arena_func_set ast_ast_arena_func_set
#define ast_block_expr_stmt_ref ast_ast_block_expr_stmt_ref
#define ast_arena_expr_set ast_ast_arena_expr_set
#define ast_arena_block_set ast_ast_arena_block_set
#define ast_arena_type_set ast_ast_arena_type_set
#define ast_arena_func_set ast_ast_arena_func_set

/* pipeline reverse aliases (call ast_pipeline_* → pipeline_* extern) */
#define ast_pipeline_module_func_param_write pipeline_module_func_param_write
#define ast_pipeline_module_func_name_write pipeline_module_func_name_write
#define ast_pipeline_arena_func_param_write pipeline_arena_func_param_write
#define ast_pipeline_arena_func_copy_slot_from_module pipeline_arena_func_copy_slot_from_module
#define ast_pipeline_sizeof_arena pipeline_sizeof_arena
#define ast_pipeline_sizeof_onefunc_result pipeline_sizeof_onefunc_result
#define ast_pipeline_onefunc_append_if pipeline_onefunc_append_if
#define ast_pipeline_onefunc_if_cond_ref pipeline_onefunc_if_cond_ref
#define ast_pipeline_onefunc_if_then_body_ref pipeline_onefunc_if_then_body_ref
#define ast_pipeline_onefunc_if_else_body_ref pipeline_onefunc_if_else_body_ref
#define ast_pipeline_onefunc_num_if_stmts pipeline_onefunc_num_if_stmts
#define ast_pipeline_onefunc_append_const_name pipeline_onefunc_append_const_name
#define ast_pipeline_onefunc_push_stmt_order pipeline_onefunc_push_stmt_order
#define ast_pipeline_onefunc_num_src_stmt_order pipeline_onefunc_num_src_stmt_order
#define ast_pipeline_onefunc_src_stmt_kind pipeline_onefunc_src_stmt_kind
#define ast_pipeline_onefunc_src_stmt_idx pipeline_onefunc_src_stmt_idx
#define ast_pipeline_onefunc_push_body_expr_stmt pipeline_onefunc_push_body_expr_stmt
#define ast_pipeline_onefunc_body_expr_stmt_ref pipeline_onefunc_body_expr_stmt_ref
#define ast_pipeline_onefunc_num_body_expr_stmts pipeline_onefunc_num_body_expr_stmts
#define ast_pipeline_onefunc_append_param pipeline_onefunc_append_param
#define ast_pipeline_onefunc_set_param_type_ref pipeline_onefunc_set_param_type_ref
#define ast_pipeline_onefunc_param_name_len pipeline_onefunc_param_name_len
#define ast_pipeline_onefunc_param_name_byte_at pipeline_onefunc_param_name_byte_at
#define ast_pipeline_onefunc_param_name_copy32 pipeline_onefunc_param_name_copy32
#define ast_pipeline_onefunc_param_type_ref pipeline_onefunc_param_type_ref
#define ast_pipeline_onefunc_call_arg_val_at pipeline_onefunc_call_arg_val_at
#define ast_pipeline_onefunc_reset_call_args pipeline_onefunc_reset_call_args
#define ast_pipeline_expr_ref_is_assign_lvalue pipeline_expr_ref_is_assign_lvalue

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

/* pipeline glue usage aliases */
extern struct ast_Block ast_pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Expr ast_pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Func ast_pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Type ast_pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern int32_t ast_pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                           int32_t goto_target_len, int32_t return_expr_ref);
extern void ast_pipeline_block_fill_expr_stmts_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void ast_pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void ast_pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void ast_pipeline_block_fill_stmt_order_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void ast_pipeline_block_fill_whiles_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count);
extern void ast_pipeline_module_import_path_copy(struct ast_Module *m, int32_t idx, uint8_t *dst, int32_t dst_cap);
extern int32_t ast_pipeline_module_struct_layout_alloc(struct ast_Module *m);
extern int32_t ast_pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j);
extern int32_t ast_pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j);
extern uint8_t ast_pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx);
extern void ast_pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx);
extern void ast_pipeline_module_struct_layout_set_allow_padding(struct ast_Module *m, int32_t idx, int32_t v);
extern void ast_pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                                 int32_t fname_len, int32_t ftype_ref, int32_t foff);
extern void ast_pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
extern void ast_pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf);
extern int32_t ast_pipeline_module_top_level_let_alloc(struct ast_Module *m);
extern void ast_pipeline_module_top_level_let_set(struct ast_Module *m, int32_t idx, uint8_t *name, int32_t name_len,
                                            int32_t type_ref, int32_t init_ref, int32_t is_const);
#define pipeline_arena_block_get_copy ast_pipeline_arena_block_get_copy
#define pipeline_arena_expr_get_copy ast_pipeline_arena_expr_get_copy
#define pipeline_arena_func_get_copy ast_pipeline_arena_func_get_copy
#define pipeline_arena_type_get_copy ast_pipeline_arena_type_get_copy
#define pipeline_block_append_const ast_pipeline_block_append_const
#define pipeline_block_append_expr_stmt ast_pipeline_block_append_expr_stmt
#define pipeline_block_append_for ast_pipeline_block_append_for
#define pipeline_block_append_if ast_pipeline_block_append_if
#define pipeline_block_append_labeled ast_pipeline_block_append_labeled
#define pipeline_block_append_let ast_pipeline_block_append_let
#define pipeline_block_append_stmt_order ast_pipeline_block_append_stmt_order
#define pipeline_block_append_while ast_pipeline_block_append_while
#define pipeline_block_fill_expr_stmts_from_onefunc ast_pipeline_block_fill_expr_stmts_from_onefunc
#define pipeline_block_fill_fors_from_onefunc ast_pipeline_block_fill_fors_from_onefunc
#define pipeline_block_fill_ifs_from_onefunc ast_pipeline_block_fill_ifs_from_onefunc
#define pipeline_block_fill_stmt_order_from_onefunc ast_pipeline_block_fill_stmt_order_from_onefunc
#define pipeline_block_fill_whiles_from_onefunc ast_pipeline_block_fill_whiles_from_onefunc
#define pipeline_expr_append_array_lit_elem ast_pipeline_expr_append_array_lit_elem
#define pipeline_expr_append_call_arg ast_pipeline_expr_append_call_arg
#define pipeline_expr_append_struct_lit_field ast_pipeline_expr_append_struct_lit_field
#define pipeline_module_enum_alloc ast_pipeline_module_enum_alloc
#define pipeline_module_enum_name_byte_at ast_pipeline_module_enum_name_byte_at
#define pipeline_module_enum_name_len ast_pipeline_module_enum_name_len
#define pipeline_module_enum_set_name ast_pipeline_module_enum_set_name
#define pipeline_module_func_alloc_slot ast_pipeline_module_func_alloc_slot
#define pipeline_module_func_ref_set ast_pipeline_module_func_ref_set
#define pipeline_module_func_set_body_expr_ref ast_pipeline_module_func_set_body_expr_ref
#define pipeline_module_func_set_body_ref ast_pipeline_module_func_set_body_ref
#define pipeline_module_func_set_is_extern ast_pipeline_module_func_set_is_extern
#define pipeline_module_func_set_num_params ast_pipeline_module_func_set_num_params
#define pipeline_module_func_set_return_type ast_pipeline_module_func_set_return_type
#define pipeline_module_import_alloc ast_pipeline_module_import_alloc
#define pipeline_module_import_append_select_name ast_pipeline_module_import_append_select_name
#define pipeline_module_import_path_copy ast_pipeline_module_import_path_copy
#define pipeline_module_import_set_binding_name ast_pipeline_module_import_set_binding_name
#define pipeline_module_import_set_kind ast_pipeline_module_import_set_kind
#define pipeline_module_import_set_path ast_pipeline_module_import_set_path
#define pipeline_module_import_set_select_count ast_pipeline_module_import_set_select_count
#define pipeline_module_struct_layout_alloc ast_pipeline_module_struct_layout_alloc
#define pipeline_module_struct_layout_field_name_len ast_pipeline_module_struct_layout_field_name_len
#define pipeline_module_struct_layout_field_type_ref ast_pipeline_module_struct_layout_field_type_ref
#define pipeline_module_struct_layout_name_byte_at ast_pipeline_module_struct_layout_name_byte_at
#define pipeline_module_struct_layout_name_len ast_pipeline_module_struct_layout_name_len
#define pipeline_module_struct_layout_num_fields ast_pipeline_module_struct_layout_num_fields
#define pipeline_module_struct_layout_reset_slot ast_pipeline_module_struct_layout_reset_slot
#define pipeline_module_struct_layout_set_allow_padding ast_pipeline_module_struct_layout_set_allow_padding
#define pipeline_module_struct_layout_set_field ast_pipeline_module_struct_layout_set_field
#define pipeline_module_struct_layout_set_name ast_pipeline_module_struct_layout_set_name
#define pipeline_module_struct_layout_set_num_fields ast_pipeline_module_struct_layout_set_num_fields
#define pipeline_module_top_level_let_alloc ast_pipeline_module_top_level_let_alloc
#define pipeline_module_top_level_let_set ast_pipeline_module_top_level_let_set
#define pipeline_onefunc_append_for ast_pipeline_onefunc_append_for
#define pipeline_onefunc_append_let ast_pipeline_onefunc_append_let
#define pipeline_onefunc_append_while ast_pipeline_onefunc_append_while
#define pipeline_onefunc_const_init_val ast_pipeline_onefunc_const_init_val
#define pipeline_onefunc_const_name_copy64 ast_pipeline_onefunc_const_name_copy64
#define pipeline_onefunc_const_name_len ast_pipeline_onefunc_const_name_len
#define pipeline_onefunc_copy_sidecar ast_pipeline_onefunc_copy_sidecar
#define pipeline_onefunc_let_init_ref ast_pipeline_onefunc_let_init_ref
#define pipeline_onefunc_let_init_val ast_pipeline_onefunc_let_init_val
#define pipeline_onefunc_let_name_copy64 ast_pipeline_onefunc_let_name_copy64
#define pipeline_onefunc_let_name_len ast_pipeline_onefunc_let_name_len
#define pipeline_onefunc_let_type_ref ast_pipeline_onefunc_let_type_ref
#define pipeline_onefunc_num_consts ast_pipeline_onefunc_num_consts
#define pipeline_onefunc_num_fors ast_pipeline_onefunc_num_fors
#define pipeline_onefunc_num_lets ast_pipeline_onefunc_num_lets
#define pipeline_onefunc_num_whiles ast_pipeline_onefunc_num_whiles
enum std_io_driver_IO_Result { std_io_driver_IO_Result_Ok, std_io_driver_IO_Result_Err, std_io_driver_IO_Result_Timeout, std_io_driver_IO_Result_Cancelled };
struct std_io_driver_Buffer { uint8_t * ptr; size_t len; size_t handle; };
struct std_io_driver_Completion { int32_t tag; };
struct std_io_driver_AsyncContext { uint32_t flags; };
struct shulang_slice_uint8_t { uint8_t *data; size_t length; };
struct std_io_ReadOnlySlice { struct shulang_slice_uint8_t data; };
struct std_io_WriteOnlySlice { struct shulang_slice_uint8_t data; };
struct std_fs_FsIovecBuf { uint8_t * ptr; size_t len; size_t handle; };
extern void lexer_next_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * data);
extern struct lexer_Lexer lexer_init();
extern void ast_pipeline_onefunc_copy_sidecar(uint8_t * dst, uint8_t * src);
extern int32_t ast_pipeline_onefunc_num_consts(uint8_t * out);
extern int32_t ast_pipeline_onefunc_num_lets(uint8_t * out);
extern int32_t ast_pipeline_onefunc_num_whiles(uint8_t * out);
extern int32_t ast_pipeline_onefunc_num_fors(uint8_t * out);
extern int32_t ast_ast_arena_expr_alloc(struct ast_ASTArena * arena);
extern struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena * arena, int32_t ref);
extern void ast_ast_arena_expr_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Expr e);
extern int ast_ref_is_null(int32_t ref);
extern struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena * arena, int32_t ref);
extern int32_t ast_pipeline_expr_append_call_arg(struct ast_ASTArena * arena, int32_t expr_ref, int32_t arg_ref);
extern int32_t ast_pipeline_expr_append_array_lit_elem(struct ast_ASTArena * arena, int32_t expr_ref, int32_t elem_ref);
extern int32_t ast_ast_arena_type_alloc(struct ast_ASTArena * arena);
extern void ast_ast_arena_type_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Type t);
extern int32_t ast_pipeline_expr_append_struct_lit_field(struct ast_ASTArena * arena, int32_t expr_ref, uint8_t * name_bytes, int32_t name_len, int32_t init_ref);
extern int32_t ast_pipeline_onefunc_const_init_val(uint8_t * out, int32_t i);
extern void ast_pipeline_onefunc_const_name_copy64(uint8_t * out, int32_t i, uint8_t * dst);
extern int32_t ast_pipeline_block_append_const(struct ast_ASTArena * arena, int32_t br, uint8_t * name, int32_t name_len, int32_t type_ref, int32_t init_ref);
extern int32_t ast_pipeline_onefunc_const_name_len(uint8_t * out, int32_t i);
extern int32_t ast_pipeline_onefunc_let_type_ref(uint8_t * out, int32_t i);
extern int32_t ast_pipeline_onefunc_let_init_ref(uint8_t * out, int32_t i);
extern int32_t ast_pipeline_onefunc_let_init_val(uint8_t * out, int32_t i);
extern void ast_pipeline_onefunc_let_name_copy64(uint8_t * out, int32_t i, uint8_t * dst);
extern int32_t ast_pipeline_block_append_let(struct ast_ASTArena * arena, int32_t br, uint8_t * name, int32_t name_len, int32_t type_ref, int32_t init_ref);
extern int32_t ast_pipeline_onefunc_let_name_len(uint8_t * out, int32_t i);
extern int32_t ast_ast_arena_block_alloc(struct ast_ASTArena * arena);
extern int32_t ast_pipeline_block_append_if(struct ast_ASTArena * arena, int32_t br, int32_t cond_ref, int32_t then_ref, int32_t else_ref);
extern int32_t ast_pipeline_block_append_stmt_order(struct ast_ASTArena * arena, int32_t br, uint8_t kind, int32_t idx);
extern uint8_t * std_heap_alloc_zeroed(size_t size);
extern struct ast_Block ast_ast_arena_block_get(struct ast_ASTArena * arena, int32_t ref);
extern int32_t ast_pipeline_block_append_expr_stmt(struct ast_ASTArena * arena, int32_t br, int32_t expr_ref);
extern int32_t ast_pipeline_block_append_while(struct ast_ASTArena * arena, int32_t br, int32_t cond_ref, int32_t body_ref);
extern int32_t ast_pipeline_block_append_for(struct ast_ASTArena * arena, int32_t br, int32_t init_ref, int32_t cond_ref, int32_t step_ref, int32_t body_ref);
extern void ast_ast_arena_block_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Block b);
extern void ast_ast_arena_init(struct ast_ASTArena * arena);
extern void std_heap_free(uint8_t * ptr);
extern struct lexer_LexerResult lexer_next_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
extern int32_t ast_pipeline_onefunc_append_let(uint8_t * out, uint8_t * name, int32_t name_len, int32_t init_val, int32_t init_ref, int32_t type_ref);
extern void ast_ast_pool_onefunc_reset(uint8_t * out);
extern int32_t ast_pipeline_onefunc_append_while(uint8_t * out, int32_t cond_ref, int32_t body_ref);
extern int32_t ast_pipeline_onefunc_append_for(uint8_t * out, int32_t init_ref, int32_t cond_ref, int32_t step_ref, int32_t body_ref);
extern int32_t ast_pipeline_module_import_alloc(struct ast_Module * module);
extern void ast_pipeline_module_import_set_path(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern void ast_pipeline_module_import_set_kind(struct ast_Module * module, int32_t idx, int32_t kind);
extern void ast_pipeline_module_import_set_binding_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern void ast_pipeline_module_import_set_select_count(struct ast_Module * module, int32_t idx, int32_t n);
extern int32_t ast_pipeline_module_import_append_select_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t ast_pipeline_module_enum_alloc(struct ast_Module * module);
extern int32_t ast_pipeline_module_enum_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t ast_pipeline_module_enum_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern void ast_pipeline_module_enum_set_name(struct ast_Module * module, int32_t idx, uint8_t * bytes, int32_t len);
extern int32_t ast_pipeline_module_func_alloc_slot(struct ast_Module * module);
extern void ast_pipeline_module_func_set_num_params(struct ast_Module * module, int32_t fi, int32_t n);
extern void ast_pipeline_module_func_set_return_type(struct ast_Module * module, int32_t fi, int32_t type_ref);
extern void ast_pipeline_module_func_set_body_ref(struct ast_Module * module, int32_t fi, int32_t body_ref);
extern void ast_pipeline_module_func_set_body_expr_ref(struct ast_Module * module, int32_t fi, int32_t body_expr_ref);
extern void ast_pipeline_module_func_set_is_extern(struct ast_Module * module, int32_t fi, int32_t is_extern);
extern void ast_pipeline_module_func_ref_set(struct ast_Module * module, int32_t func_index, int32_t func_ref);
extern int32_t ast_ast_arena_func_alloc(struct ast_ASTArena * arena);
extern struct ast_Func ast_ast_arena_func_get(struct ast_ASTArena * arena, int32_t ref);
extern void ast_ast_arena_func_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Func f);
extern int32_t ast_pipeline_module_struct_layout_name_len(struct ast_Module * module, int32_t idx);
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
extern struct shulang_slice_uint8_t parser_slice_from_buf(uint8_t * restrict data, int32_t len);
extern void pipeline_module_struct_layout_reset_slot(struct ast_Module * restrict module, int32_t idx);
extern void pipeline_module_struct_layout_set_name(struct ast_Module * restrict module, int32_t idx, uint8_t * restrict bytes, int32_t len);
extern uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module * restrict module, int32_t idx, int32_t off);
extern void pipeline_module_struct_layout_set_field(struct ast_Module * restrict module, int32_t layout_idx, int32_t j, uint8_t * restrict fname, int32_t fname_len, int32_t ftype_ref, int32_t foff);
extern void pipeline_module_func_param_write(struct ast_Module * restrict module, int32_t func_index, int32_t param_index, uint8_t * restrict name_bytes, int32_t name_len, int32_t type_ref);
extern void pipeline_module_func_name_write(struct ast_Module * restrict module, int32_t func_index, uint8_t * restrict name_bytes, int32_t name_len);
extern void pipeline_arena_func_param_write(struct ast_ASTArena * restrict arena, int32_t func_ref, int32_t param_index, uint8_t * restrict name_bytes, int32_t name_len, int32_t type_ref);
extern void pipeline_arena_func_copy_slot_from_module(struct ast_ASTArena * restrict arena, int32_t func_ref, struct ast_Module * restrict module, int32_t fi);
extern size_t pipeline_sizeof_arena();
extern size_t pipeline_sizeof_onefunc_result();
extern void ast_pool_onefunc_reset(uint8_t * restrict out);
extern void ast_pool_module_reset(struct ast_Module * restrict module);
extern void ast_pool_arena_reset(struct ast_ASTArena * restrict arena);
extern int32_t pipeline_module_func_alloc_slot(struct ast_Module * restrict module);
extern void pipeline_module_func_ref_set(struct ast_Module * restrict module, int32_t func_index, int32_t func_ref);
extern void pipeline_module_func_set_return_type(struct ast_Module * restrict module, int32_t fi, int32_t type_ref);
extern void pipeline_module_func_set_body_ref(struct ast_Module * restrict module, int32_t fi, int32_t body_ref);
extern void pipeline_module_func_set_body_expr_ref(struct ast_Module * restrict module, int32_t fi, int32_t body_expr_ref);
extern void pipeline_module_func_set_is_extern(struct ast_Module * restrict module, int32_t fi, int32_t is_extern);
extern void pipeline_module_func_set_num_params(struct ast_Module * restrict module, int32_t fi, int32_t n);
extern int32_t pipeline_block_append_const(struct ast_ASTArena * restrict arena, int32_t br, uint8_t * restrict name, int32_t name_len, int32_t type_ref, int32_t init_ref);
extern int32_t pipeline_block_append_let(struct ast_ASTArena * restrict arena, int32_t br, uint8_t * restrict name, int32_t name_len, int32_t type_ref, int32_t init_ref);
extern int32_t pipeline_block_append_if(struct ast_ASTArena * restrict arena, int32_t br, int32_t cond_ref, int32_t then_ref, int32_t else_ref);
extern int32_t pipeline_block_append_expr_stmt(struct ast_ASTArena * restrict arena, int32_t br, int32_t expr_ref);
extern int32_t pipeline_block_append_stmt_order(struct ast_ASTArena * restrict arena, int32_t br, uint8_t kind, int32_t idx);
extern void pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena * restrict arena, int32_t br, uint8_t * restrict out, int32_t count);
extern void pipeline_block_fill_stmt_order_from_onefunc(struct ast_ASTArena * restrict arena, int32_t br, uint8_t * restrict out, int32_t count);
extern void pipeline_block_fill_expr_stmts_from_onefunc(struct ast_ASTArena * restrict arena, int32_t br, uint8_t * restrict out, int32_t count);
extern int32_t pipeline_onefunc_append_if(uint8_t * restrict out, int32_t cond, int32_t then_ref, int32_t else_ref);
extern int32_t pipeline_onefunc_if_cond_ref(uint8_t * restrict out, int32_t i);
extern int32_t pipeline_onefunc_if_then_body_ref(uint8_t * restrict out, int32_t i);
extern int32_t pipeline_onefunc_if_else_body_ref(uint8_t * restrict out, int32_t i);
extern int32_t pipeline_onefunc_num_if_stmts(uint8_t * restrict out);
extern int32_t pipeline_onefunc_append_const_name(uint8_t * restrict out, uint8_t * restrict name, int32_t name_len, int32_t init_val);
extern int32_t pipeline_onefunc_const_name_len(uint8_t * restrict out, int32_t i);
extern int32_t pipeline_onefunc_const_init_val(uint8_t * restrict out, int32_t i);
extern int32_t pipeline_onefunc_num_consts(uint8_t * restrict out);
extern void pipeline_onefunc_const_name_copy64(uint8_t * restrict out, int32_t i, uint8_t * restrict dst);
extern int32_t pipeline_onefunc_append_let(uint8_t * restrict out, uint8_t * restrict name, int32_t name_len, int32_t init_val, int32_t init_ref, int32_t type_ref);
extern int32_t pipeline_onefunc_let_name_len(uint8_t * restrict out, int32_t i);
extern int32_t pipeline_onefunc_let_init_val(uint8_t * restrict out, int32_t i);
extern int32_t pipeline_onefunc_let_init_ref(uint8_t * restrict out, int32_t i);
extern int32_t pipeline_onefunc_let_type_ref(uint8_t * restrict out, int32_t i);
extern int32_t pipeline_onefunc_num_lets(uint8_t * restrict out);
extern void pipeline_onefunc_let_name_copy64(uint8_t * restrict out, int32_t i, uint8_t * restrict dst);
extern void pipeline_onefunc_copy_sidecar(uint8_t * restrict dst, uint8_t * restrict src);
extern int32_t pipeline_onefunc_push_stmt_order(uint8_t * restrict out, uint8_t kind, int32_t idx);
extern int32_t pipeline_onefunc_num_src_stmt_order(uint8_t * restrict out);
extern uint8_t pipeline_onefunc_src_stmt_kind(uint8_t * restrict out, int32_t i);
extern int32_t pipeline_onefunc_src_stmt_idx(uint8_t * restrict out, int32_t i);
extern int32_t pipeline_onefunc_push_body_expr_stmt(uint8_t * restrict out, int32_t expr_ref);
extern int32_t pipeline_onefunc_body_expr_stmt_ref(uint8_t * restrict out, int32_t i);
extern int32_t pipeline_onefunc_num_body_expr_stmts(uint8_t * restrict out);
extern int32_t pipeline_onefunc_append_param(uint8_t * restrict out, uint8_t * restrict name, int32_t name_len, int32_t type_ref);
extern void pipeline_onefunc_set_param_type_ref(uint8_t * restrict out, int32_t i, int32_t type_ref);
extern int32_t pipeline_onefunc_param_name_len(uint8_t * restrict out, int32_t i);
extern uint8_t pipeline_onefunc_param_name_byte_at(uint8_t * restrict out, int32_t i, int32_t off);
extern void pipeline_onefunc_param_name_copy32(uint8_t * restrict out, int32_t i, uint8_t * restrict dst);
extern int32_t pipeline_onefunc_param_type_ref(uint8_t * restrict out, int32_t i);
extern int32_t pipeline_onefunc_call_arg_val_at(uint8_t * restrict out, int32_t i);
extern void pipeline_onefunc_reset_call_args(uint8_t * restrict out);
extern int32_t pipeline_block_append_while(struct ast_ASTArena * restrict arena, int32_t br, int32_t cond_ref, int32_t body_ref);
extern int32_t pipeline_block_append_for(struct ast_ASTArena * restrict arena, int32_t br, int32_t init_ref, int32_t cond_ref, int32_t step_ref, int32_t body_ref);
extern void pipeline_block_fill_whiles_from_onefunc(struct ast_ASTArena * restrict arena, int32_t br, uint8_t * restrict out, int32_t count);
extern void pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena * restrict arena, int32_t br, uint8_t * restrict out, int32_t count);
extern int32_t pipeline_onefunc_append_while(uint8_t * restrict out, int32_t cond_ref, int32_t body_ref);
extern int32_t pipeline_onefunc_num_whiles(uint8_t * restrict out);
extern int32_t pipeline_onefunc_append_for(uint8_t * restrict out, int32_t init_ref, int32_t cond_ref, int32_t step_ref, int32_t body_ref);
extern int32_t pipeline_onefunc_num_fors(uint8_t * restrict out);
extern void lexer_next_buf_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
extern int32_t ast_block_expr_stmt_ref(struct ast_ASTArena * restrict arena, int32_t block_ref, int32_t ei);
extern int32_t pipeline_block_append_labeled(struct ast_ASTArena * restrict arena, int32_t br, int32_t label_len, int32_t is_goto, int32_t goto_target_len, int32_t return_expr_ref);
extern int32_t pipeline_module_struct_layout_alloc(struct ast_Module * restrict module);
extern int32_t pipeline_module_struct_layout_name_len(struct ast_Module * restrict module, int32_t idx);
extern int32_t pipeline_module_struct_layout_num_fields(struct ast_Module * restrict module, int32_t idx);
extern void pipeline_module_struct_layout_set_num_fields(struct ast_Module * restrict module, int32_t idx, int32_t nf);
extern int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module * restrict module, int32_t li, int32_t j);
extern int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module * restrict module, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_set_allow_padding(struct ast_Module * restrict module, int32_t idx, int32_t v);
extern int32_t pipeline_module_import_alloc(struct ast_Module * restrict module);
extern void pipeline_module_import_set_path(struct ast_Module * restrict module, int32_t idx, uint8_t * restrict bytes, int32_t len);
extern void pipeline_module_import_set_kind(struct ast_Module * restrict module, int32_t idx, int32_t kind);
extern void pipeline_module_import_set_binding_name(struct ast_Module * restrict module, int32_t idx, uint8_t * restrict bytes, int32_t len);
extern void pipeline_module_import_set_select_count(struct ast_Module * restrict module, int32_t idx, int32_t n);
extern int32_t pipeline_module_import_append_select_name(struct ast_Module * restrict module, int32_t idx, uint8_t * restrict bytes, int32_t len);
extern void pipeline_module_import_path_copy(struct ast_Module * restrict module, int32_t idx, uint8_t * restrict dst, int32_t dst_cap);
extern int32_t pipeline_module_enum_alloc(struct ast_Module * restrict module);
extern int32_t pipeline_module_enum_name_len(struct ast_Module * restrict module, int32_t idx);
extern uint8_t pipeline_module_enum_name_byte_at(struct ast_Module * restrict module, int32_t idx, int32_t off);
extern void pipeline_module_enum_set_name(struct ast_Module * restrict module, int32_t idx, uint8_t * restrict bytes, int32_t len);
extern int32_t pipeline_module_top_level_let_alloc(struct ast_Module * restrict module);
extern void pipeline_module_top_level_let_set(struct ast_Module * restrict module, int32_t idx, uint8_t * restrict name, int32_t name_len, int32_t type_ref, int32_t init_ref, int32_t is_const);
extern void parser_lex_copy_from_collect_imports(struct lexer_Lexer * restrict out, struct parser_CollectImportsResult res);
extern void parser_lex_from_lexer_result_val_into(struct lexer_Lexer * restrict out, struct lexer_LexerResult r);
extern void parser_lex_from_lexer_result_ptr_into(struct lexer_Lexer * restrict out, struct lexer_LexerResult * restrict r);
extern void parser_lex_from_onefunc_result_ptr_into(struct lexer_Lexer * restrict out, struct parser_OneFuncResult * restrict res);
extern enum ast_ExprKind compound_assign_token_to_expr_kind_from_glue(enum token_TokenKind kind);
extern int pipeline_expr_ref_is_assign_lvalue(struct ast_ASTArena * restrict arena, int32_t expr_ref);
void parser_pipeline_module_reset_parse_counters(struct ast_Module * restrict module);
uint8_t * parser_onefunc_result_pool_ptr(struct parser_OneFuncResult * restrict res);
void parser_copy_lex_from_import_into(struct lexer_Lexer * restrict out, struct parser_CollectImportsResult res);
void parser_lex_from_next_into(struct lexer_Lexer * restrict out, struct lexer_LexerResult r);
void parser_lex_from_result_ptr_into(struct lexer_Lexer * restrict out_lex, struct lexer_LexerResult * restrict r);
void parser_lex_from_onefunc_next_into(struct lexer_Lexer * restrict out, struct parser_OneFuncResult * restrict res);
size_t parser_lexer_pos_before_run(size_t end_pos, int32_t run_len);
int32_t parser_lexer_token_run_len(struct token_Token tok);
struct lexer_Lexer parser_lex_at_token_from_result(struct lexer_LexerResult r);
int32_t parser_advance_past_stmt_semicolon_into(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
int32_t parser_advance_past_cond_rparen_into(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_onefunc_result_layout_prime();
void parser_set_onefunc_fail(struct parser_OneFuncResult * restrict out, struct lexer_Lexer next_lex);
void parser_onefunc_result_layout_prime_b();
void parser_onefunc_result_layout_prime_c();
void parser_onefunc_result_layout_prime_d();
void parser_onefunc_result_layout_prime_d_b();
void parser_onefunc_result_layout_prime_e();
void parser_onefunc_result_layout_prime_f();
void parser_copy_onefunc_into(struct parser_OneFuncResult * restrict dst, struct parser_OneFuncResult * restrict src);
struct parser_OneFuncResult parser_onefunc_scratch_empty();
void parser_onefunc_merge_pool_out_to_snap(struct parser_OneFuncResult * restrict snap, struct parser_OneFuncResult * restrict out);
void parser_onefunc_finish_impl_to_out(struct parser_OneFuncResult * restrict out, struct parser_OneFuncResult * restrict snap, struct lexer_Lexer lex, uint8_t * restrict name, int32_t name_len, int32_t ret_expr_storage);
void parser_onefunc_res_wire_dummy_head(struct parser_OneFuncResult * restrict res, struct lexer_Lexer lex, uint8_t name64[64]);
void parser_onefunc_res_wire_dummy_const_let(struct parser_OneFuncResult * restrict res);
void parser_onefunc_res_wire_dummy_if_mul(struct parser_OneFuncResult * restrict res);
void parser_onefunc_res_wire_dummy_call_binop(struct parser_OneFuncResult * restrict res, uint8_t name64[64]);
void parser_onefunc_res_wire_dummy_loop_call(struct parser_OneFuncResult * restrict res);
void parser_onefunc_res_wire_dummy_for_if(struct parser_OneFuncResult * restrict res);
struct parser_OneFuncResult parser_onefunc_alloc_wired_for_parse(struct lexer_Lexer lex);
void parser_onefunc_snap_set_return_path(struct parser_OneFuncResult * restrict snap, int has_call, uint8_t ret_var[64], int32_t ret_var_len, int32_t ret_expr_ref);
void parser_onefunc_push_src_stmt(struct parser_OneFuncResult * restrict out, uint8_t kind, int32_t idx);
void parser_expr_set_common_zeros(struct ast_Expr * restrict e);
int32_t parser_alloc_true_bool_lit(struct ast_ASTArena * restrict arena);
int32_t parser_expr_wrap_in_return(struct ast_ASTArena * restrict arena, int32_t type_ref, int32_t inner_ref);
int parser_should_wrap_func_tail_in_return(struct ast_ASTArena * restrict arena, struct parser_OneFuncResult * restrict res, int32_t type_ref);
void parser_parse_primary_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_as_suffix_into(struct ast_ASTArena * restrict arena, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_unary_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_cast_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_term_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_addsub_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_shift_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_relcompare_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_compare_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_bitand_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_bitxor_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_bitor_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_logand_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_logor_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_ternary_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
int parser_is_compound_assign_token(enum token_TokenKind kind);
enum ast_ExprKind parser_compound_assign_token_to_expr_kind(enum token_TokenKind kind);
int parser_expr_ref_is_assign_lvalue(struct ast_ASTArena * restrict arena, int32_t expr_ref);
void parser_parse_assign_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_expr_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_finish_struct_lit_from_type_ident_into(struct ast_ASTArena * restrict arena, int32_t lit_ref, struct lexer_Lexer lex_in_brace, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_cond_expr_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_start, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_expr_with_leading_int_as_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_start, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
int parser_fill_block_const_let_from_res(struct ast_ASTArena * restrict arena, int32_t block_ref, struct parser_OneFuncResult * restrict res, int32_t type_ref);
int parser_append_block_lets_from_res(struct ast_ASTArena * restrict arena, int32_t block_ref, struct parser_OneFuncResult * restrict res, int32_t let_base, int32_t type_ref);
int parser_parse_if_stmt_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_at_if, struct shulang_slice_uint8_t * source, int32_t type_ref, int32_t * restrict out_cond, int32_t * restrict out_then, int32_t * restrict out_else, struct lexer_Lexer * restrict lex_out);
void parser_parse_block_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_after_lbrace, struct shulang_slice_uint8_t * source, int32_t type_ref, struct parser_ParseBlockResult * restrict out);
struct parser_ParseResult parser_parse(struct shulang_slice_uint8_t * source);
int32_t parser_first_token_kind(struct shulang_slice_uint8_t * source);
int32_t parser_diag_first_ident_len(struct shulang_slice_uint8_t * source);
void parser_diag_skip_let_const_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
struct lexer_LexerResult parser_diag_skip_let_const(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
struct lexer_LexerResult parser_diag_skip_let_const_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_body_skip_let_const_then_if_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_parse_body_lets_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_OneFuncResult * restrict out, struct lexer_Lexer * restrict lex_out);
struct lexer_LexerResult parser_body_skip_let_const_then_if(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
struct lexer_LexerResult parser_body_skip_let_const_then_if_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_balanced_parens(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_skip_balanced_parens_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_skip_balanced_parens_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_balanced_parens_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_balanced_braces(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_skip_balanced_braces_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_skip_balanced_braces_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_balanced_braces_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_function_full_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
struct lexer_Lexer parser_skip_one_function_full(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_skip_one_function_full_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_one_function_full_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_LexerResult parser_skip_one_if_core(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
struct lexer_LexerResult parser_skip_one_if_statement(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_skip_one_if_statement_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_skip_one_if_core_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
struct lexer_LexerResult parser_skip_one_if_core_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_LexerResult parser_skip_one_if_statement_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_diag_lex_after_imports(struct shulang_slice_uint8_t * source);
struct lexer_LexerResult parser_diag_after_imports_then_structs(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
int32_t parser_diag_fail_at_token_kind(struct shulang_slice_uint8_t * source);
void parser_copy_slice_to_name64(struct shulang_slice_uint8_t * source, size_t start, int32_t nlen, uint8_t * restrict out);
void parser_copy_slice_to_name64_at_end(struct shulang_slice_uint8_t * source, size_t end_pos, int32_t nlen, uint8_t * restrict out);
void parser_copy_slice_to_param32(struct shulang_slice_uint8_t * source, size_t start, int32_t nlen, uint8_t * restrict out);
void parser_copy_slice_to_param32_at_end(struct shulang_slice_uint8_t * source, size_t end_pos, int32_t nlen, uint8_t * restrict out);
void parser_copy_slice_to_name64_buf(uint8_t * restrict source, int32_t source_len, size_t start, int32_t nlen, uint8_t * restrict out);
void parser_copy_slice_to_name64_at_end_buf(uint8_t * restrict source, int32_t source_len, size_t end_pos, int32_t nlen, uint8_t * restrict out);
void parser_copy_slice_to_param32_at_end_buf(uint8_t * restrict source, int32_t source_len, size_t end_pos, int32_t nlen, uint8_t * restrict out);
void parser_parse_one_function_impl(struct parser_OneFuncResult * restrict out, struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_parse_into_init(struct ast_Module * restrict module, struct ast_ASTArena * restrict arena);
struct lexer_Lexer parser_skip_imports(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_collect_imports(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct ast_Module * restrict module, struct parser_CollectImportsResult * restrict out);
void parser_collect_imports_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct ast_Module * restrict module, struct parser_CollectImportsResult * restrict out);
void parser_skip_one_struct_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
struct lexer_Lexer parser_skip_one_struct(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_module_try_register_enum_name(struct ast_Module * restrict module, uint8_t * restrict name, int32_t name_len);
void parser_skip_one_enum_register_into(struct ast_Module * restrict module, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_skip_one_enum_register_into_buf(struct ast_Module * restrict module, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_enum_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
struct lexer_Lexer parser_skip_one_enum(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_skip_one_trait_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
struct lexer_Lexer parser_skip_one_trait(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_skip_one_impl_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
struct lexer_Lexer parser_skip_one_impl(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_skip_one_enum_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_one_enum_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_trait_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_one_trait_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_impl_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_one_impl_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_extern_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
struct lexer_Lexer parser_skip_one_extern(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
uint8_t * parser_extern_parse_pool_ptr(struct parser_ExternParseResult * restrict res);
void parser_write_extern_params_to_pools(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, int32_t func_ref, int32_t fi, struct parser_ExternParseResult * restrict res);
void parser_extern_parse_set_fail(struct parser_ExternParseResult * restrict out, struct lexer_Lexer lex);
void parser_parse_one_extern_skip_into(struct parser_ExternParseResult * restrict out, struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
int32_t parser_module_register_arena_func(struct ast_Module * restrict module, int32_t func_ref, struct ast_Func f);
void parser_parse_one_extern_and_add_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct lexer_Lexer * restrict lex_out);
void parser_skip_one_extern_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_one_extern_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_parse_one_extern_and_add_into_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct lexer_Lexer * restrict lex_out);
void parser_lex_from_try_skip_into(struct lexer_Lexer * restrict out, struct parser_TrySkipAllowResult t);
void parser_lex_from_library_into(struct lexer_Lexer * restrict out, struct parser_LibraryParseResult lib);
struct lexer_Lexer parser_lex_from_try_skip(struct parser_TrySkipAllowResult t);
struct lexer_Lexer parser_lex_from_library(struct parser_LibraryParseResult lib);
int parser_parse_one_function_library_scan(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_LibraryParseScanResult * restrict result);
int parser_struct_layout_name_exists_arr(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen);
int32_t parser_struct_layout_first_name_match_idx(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen);
int32_t parser_struct_layout_placeholder_idx(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen);
struct parser_LibraryParseResult parser_parse_one_function_library(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
struct parser_LibraryParseResult parser_parse_one_function_library_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct parser_TrySkipAllowResult parser_parse_into_try_skip_allow(struct lexer_Lexer lex, struct lexer_LexerResult r, struct shulang_slice_uint8_t * source);
struct parser_TrySkipAllowResult parser_parse_into_try_skip_allow_buf(struct lexer_Lexer lex, struct lexer_LexerResult r, uint8_t * restrict data, int32_t len);
struct parser_TrySkipAllowResult parser_try_skip_allow_padding_struct(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
struct parser_TrySkipAllowResult parser_try_skip_allow_padding_struct_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_struct_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_one_struct_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
int parser_is_pointee_type_token(enum token_TokenKind kind);
int32_t parser_alloc_pointee_type_ref_from_tok(struct ast_ASTArena * restrict arena, struct shulang_slice_uint8_t * source, struct lexer_LexerResult * restrict r);
int32_t parser_parse_type_ref_for_arena_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct lexer_Lexer * restrict out_lex);
int32_t parser_parse_struct_record_layout_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct lexer_Lexer * restrict out_lex, int32_t allow_pad);
void parser_parse_one_function_buf_into(struct parser_OneFuncResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_parse_one_function_library_into(struct parser_LibraryParseResult * restrict out, struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
void parser_parse_into_try_skip_allow_into(struct parser_TrySkipAllowResult * restrict out, struct lexer_Lexer lex, struct lexer_LexerResult r, struct shulang_slice_uint8_t * source);
void parser_parse_into_try_skip_allow_into_buf(struct parser_TrySkipAllowResult * restrict out, struct lexer_Lexer lex, struct lexer_LexerResult r, uint8_t * restrict data, int32_t len);
struct parser_ParseIntoResult parser_parse_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct shulang_slice_uint8_t * source);
void parser_parse_one_top_level_let_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, int is_const, struct parser_TopLevelLetResult * restrict out);
struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, uint8_t * restrict data, int32_t len);
void parser_parse_into_set_main_index(struct ast_Module * restrict module, int32_t main_idx);
int32_t parser_diag_token_after_collect_imports(struct shulang_slice_uint8_t * source, struct ast_Module * restrict module);
int32_t parser_diag_parse_one_after_collect_imports(struct shulang_slice_uint8_t * source, struct ast_Module * restrict module, struct ast_ASTArena * restrict arena);
int32_t parser_get_module_num_imports(struct ast_Module * restrict module);
void parser_get_module_import_path(struct ast_Module * restrict module, int32_t i, uint8_t out[64]);
void parser_pipeline_module_reset_parse_counters(struct ast_Module * restrict module) {
  (void)(({ int32_t __tmp = 0; if (module == ((struct ast_Module *)(0))) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((module)->num_funcs = 0));
  (void)(((module)->main_func_index = (-1)));
  (void)(((module)->num_imports = 0));
  (void)(((module)->num_top_level_lets = 0));
  (void)(((module)->num_struct_layouts = 0));
  (void)(((module)->num_module_enums = 0));
}
uint8_t * parser_onefunc_result_pool_ptr(struct parser_OneFuncResult * restrict res) {
  return ((uint8_t *)(res));
}
void parser_copy_lex_from_import_into(struct lexer_Lexer * restrict out, struct parser_CollectImportsResult res) {
  (void)(parser_lex_copy_from_collect_imports(out, res));
}
void parser_lex_from_next_into(struct lexer_Lexer * restrict out, struct lexer_LexerResult r) {
  (void)(parser_lex_from_lexer_result_val_into(out, r));
}
void parser_lex_from_result_ptr_into(struct lexer_Lexer * restrict out_lex, struct lexer_LexerResult * restrict r) {
  (void)(parser_lex_from_lexer_result_ptr_into(out_lex, r));
}
void parser_lex_from_onefunc_next_into(struct lexer_Lexer * restrict out, struct parser_OneFuncResult * restrict res) {
  (void)(parser_lex_from_onefunc_result_ptr_into(out, res));
}
size_t parser_lexer_pos_before_run(size_t end_pos, int32_t run_len) {
  int32_t rl = run_len;
  size_t start = end_pos - ((size_t)(rl));
  return start;
}
int32_t parser_lexer_token_run_len(struct token_Token tok) {
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_RETURN) {   return 6;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_FUNCTION) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_CONST) {   return 5;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_WHILE) {   return 5;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_FALSE) {   return 5;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_STRUCT) {   return 6;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_IMPORT) {   return 6;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_EXTERN) {   return 6;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_LET) {   return 3;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_IF) {   return 2;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_FOR) {   return 3;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_ELSE) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_TRUE) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_ENUM) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((tok).kind == token_TokenKind_TOKEN_MATCH) {   return 5;
 } else (__tmp = 0) ; __tmp; }));
  return 1;
}
struct lexer_Lexer parser_lex_at_token_from_result(struct lexer_LexerResult r) {
  size_t p = (r).token_start;
  (void)(({ size_t __tmp = 0; if (p == 0) {   __tmp = ({ size_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IDENT && ((r).tok).ident_len > 0) {   (void)((p = parser_lexer_pos_before_run(((r).next_lex).pos, ((r).tok).ident_len)));
 } else {   int32_t kw_len = parser_lexer_token_run_len((r).tok);
  (void)((p = parser_lexer_pos_before_run(((r).next_lex).pos, kw_len)));
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return (struct lexer_Lexer){ .pos = p, .line = ((r).tok).line, .col = ((r).tok).col };
}
int32_t parser_advance_past_stmt_semicolon_into(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  (void)(lexer_next_into(r_out, lex, source));
  (void)(({ int32_t __tmp = 0; if (((r_out)->tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r_out)->tok).kind == token_TokenKind_TOKEN_LET || ((r_out)->tok).kind == token_TokenKind_TOKEN_CONST || ((r_out)->tok).kind == token_TokenKind_TOKEN_RETURN || ((r_out)->tok).kind == token_TokenKind_TOKEN_IF || ((r_out)->tok).kind == token_TokenKind_TOKEN_WHILE || ((r_out)->tok).kind == token_TokenKind_TOKEN_FOR || ((r_out)->tok).kind == token_TokenKind_TOKEN_RBRACE) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t parser_advance_past_cond_rparen_into(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  (void)(lexer_next_into(r_out, lex, source));
  (void)(({ int32_t __tmp = 0; if (((r_out)->tok).kind == token_TokenKind_TOKEN_RPAREN) {   struct lexer_Lexer lex_after = (struct lexer_Lexer){ .pos = ((r_out)->next_lex).pos, .line = ((r_out)->next_lex).line, .col = ((r_out)->next_lex).col };
  (void)(lexer_next_into(r_out, lex_after, source));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r_out)->tok).kind == token_TokenKind_TOKEN_LBRACE) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
void parser_onefunc_result_layout_prime() {
  uint8_t z64[64] = { 0 };
  struct parser_OneFuncResult _prime = ({ struct parser_OneFuncResult _t = { 0 }; _t.ok = 0; _t.next_lex = lexer_init(); _t.name_len = 0; _t.num_params = 0; memcpy(_t.name, z64, sizeof(_t.name)); _t; });
  (void)(((_prime).name_len = 0));
}
void parser_set_onefunc_fail(struct parser_OneFuncResult * restrict out, struct lexer_Lexer next_lex) {
  (void)(((out)->ok = 0));
  (void)(((out)->next_lex = next_lex));
}
void parser_onefunc_result_layout_prime_b() {
  struct parser_OneFuncResult _q2 = (struct parser_OneFuncResult){ .num_consts = 0, .num_lets = 0 };
  (void)(((_q2).num_consts = 0));
}
void parser_onefunc_result_layout_prime_c() {
  struct parser_OneFuncResult _q3 = (struct parser_OneFuncResult){ .has_if_expr = 0, .if_cond_true = 0, .if_then_val = 0, .if_else_val = 0, .if_cond_expr_ref = 0, .has_mul = 0, .mul_right_val = 0 };
  (void)(((_q3).if_cond_expr_ref = 0));
}
void parser_onefunc_result_layout_prime_d() {
  uint8_t ccn[64] = { 0 };
  struct parser_OneFuncResult _q4 = ({ struct parser_OneFuncResult _t = { 0 }; _t.has_binop = 0; _t.binop_right_val = 0; _t.binop_left_param_idx = (-1); _t.binop_right_param_idx = (-1); _t.has_unary_neg = 0; _t.return_val = 0; _t.has_call_expr = 0; memcpy(_t.call_callee_name, ccn, sizeof(_t.call_callee_name)); _t; });
  (void)(((_q4).binop_left_param_idx = (-1)));
}
void parser_onefunc_result_layout_prime_d_b() {
  uint8_t rvn[64] = { 0 };
  struct parser_OneFuncResult _q4b = ({ struct parser_OneFuncResult _t = { 0 }; _t.call_callee_len = 0; _t.return_var_name_len = 0; _t.return_expr_ref = 0; _t.call_num_args = 0; _t.num_loops = 0; memcpy(_t.return_var_name, rvn, sizeof(_t.return_var_name)); _t; });
  (void)(((_q4b).call_num_args = 0));
}
void parser_onefunc_result_layout_prime_e() {
  struct parser_OneFuncResult _q5 = (struct parser_OneFuncResult){ .num_for_loops = 0, .num_if_stmts = 0 };
  (void)(((_q5).num_if_stmts = 0));
}
void parser_onefunc_result_layout_prime_f() {
  struct parser_OneFuncResult _q6 = (struct parser_OneFuncResult){ .num_src_stmt_order = 0, .num_src_body_expr_stmts = 0, .func_return_type_ref = 0 };
  (void)(((_q6).func_return_type_ref = 0));
}
void parser_copy_onefunc_into(struct parser_OneFuncResult * restrict dst, struct parser_OneFuncResult * restrict src) {
  int32_t preserved_func_ret_ty = (dst)->func_return_type_ref;
  (void)(ast_pipeline_onefunc_copy_sidecar(parser_onefunc_result_pool_ptr(dst), parser_onefunc_result_pool_ptr(src)));
  (void)(((dst)->ok = (src)->ok));
  (void)(((dst)->next_lex = (src)->next_lex));
  (void)(((dst)->name_len = (src)->name_len));
  int32_t ni = 0;
  while (ni < 64) {
    (void)(({ uint8_t __tmp = 0; if (ni < (src)->name_len) {   (void)(((ni < 0 || (ni) >= 64 ? (shulang_panic_(1, 0), 0) : (((dst)->name)[ni] = (ni < 0 || (ni) >= 64 ? (shulang_panic_(1, 0), ((src)->name)[0]) : ((src)->name)[ni]), 0))));
 } else (__tmp = 0) ; __tmp; }));
    (void)((ni = ni + 1));
  }
  (void)(((dst)->num_params = (src)->num_params));
  (void)(((dst)->num_consts = ast_pipeline_onefunc_num_consts(parser_onefunc_result_pool_ptr(dst))));
  (void)(((dst)->num_lets = ast_pipeline_onefunc_num_lets(parser_onefunc_result_pool_ptr(dst))));
  (void)(((dst)->has_if_expr = (src)->has_if_expr));
  (void)(((dst)->if_cond_true = (src)->if_cond_true));
  (void)(((dst)->if_then_val = (src)->if_then_val));
  (void)(((dst)->if_else_val = (src)->if_else_val));
  (void)(((dst)->if_cond_expr_ref = (src)->if_cond_expr_ref));
  (void)(((dst)->has_mul = (src)->has_mul));
  (void)(((dst)->mul_right_val = (src)->mul_right_val));
  (void)(((dst)->has_binop = (src)->has_binop));
  (void)(((dst)->binop_right_val = (src)->binop_right_val));
  (void)(((dst)->binop_left_param_idx = (src)->binop_left_param_idx));
  (void)(((dst)->binop_right_param_idx = (src)->binop_right_param_idx));
  (void)(((dst)->has_unary_neg = (src)->has_unary_neg));
  (void)(((dst)->return_val = (src)->return_val));
  (void)(((dst)->return_var_name_len = (src)->return_var_name_len));
  int32_t rvni = 0;
  while (rvni < 64) {
    (void)(((rvni < 0 || (rvni) >= 64 ? (shulang_panic_(1, 0), 0) : (((dst)->return_var_name)[rvni] = (rvni < 0 || (rvni) >= 64 ? (shulang_panic_(1, 0), ((src)->return_var_name)[0]) : ((src)->return_var_name)[rvni]), 0))));
    (void)((rvni = rvni + 1));
  }
  (void)(((dst)->return_expr_ref = (src)->return_expr_ref));
  (void)(((dst)->has_explicit_return_kw = (src)->has_explicit_return_kw));
  (void)(((dst)->has_call_expr = (src)->has_call_expr));
  (void)(((dst)->call_callee_len = (src)->call_callee_len));
  int32_t cci = 0;
  while (cci < 64) {
    (void)(((cci < 0 || (cci) >= 64 ? (shulang_panic_(1, 0), 0) : (((dst)->call_callee_name)[cci] = (cci < 0 || (cci) >= 64 ? (shulang_panic_(1, 0), ((src)->call_callee_name)[0]) : ((src)->call_callee_name)[cci]), 0))));
    (void)((cci = cci + 1));
  }
  (void)(((dst)->call_num_args = (src)->call_num_args));
  (void)(((dst)->num_loops = ast_pipeline_onefunc_num_whiles(parser_onefunc_result_pool_ptr(dst))));
  (void)(((dst)->num_for_loops = ast_pipeline_onefunc_num_fors(parser_onefunc_result_pool_ptr(dst))));
  (void)(((dst)->num_if_stmts = pipeline_onefunc_num_if_stmts(parser_onefunc_result_pool_ptr(dst))));
  (void)(((dst)->num_src_stmt_order = pipeline_onefunc_num_src_stmt_order(parser_onefunc_result_pool_ptr(dst))));
  (void)(((dst)->num_src_body_expr_stmts = pipeline_onefunc_num_body_expr_stmts(parser_onefunc_result_pool_ptr(dst))));
  (void)(({ int32_t __tmp = 0; if ((src)->func_return_type_ref != 0) {   (void)(((dst)->func_return_type_ref = (src)->func_return_type_ref));
 } else {   (void)(((dst)->func_return_type_ref = preserved_func_ret_ty));
 } ; __tmp; }));
}
struct parser_OneFuncResult parser_onefunc_scratch_empty() {
  uint8_t z64[64] = { 0 };
  return ({ struct parser_OneFuncResult _t = { 0 }; _t.ok = 0; _t.next_lex = lexer_init(); _t.name_len = 0; _t.num_params = 0; memcpy(_t.name, z64, sizeof(_t.name)); _t; });
}
void parser_onefunc_merge_pool_out_to_snap(struct parser_OneFuncResult * restrict snap, struct parser_OneFuncResult * restrict out) {
  (void)(ast_pipeline_onefunc_copy_sidecar(parser_onefunc_result_pool_ptr(snap), parser_onefunc_result_pool_ptr(out)));
  (void)(((snap)->num_params = (out)->num_params));
  (void)(({ int32_t __tmp = 0; if ((out)->func_return_type_ref != 0) {   (void)(((snap)->func_return_type_ref = (out)->func_return_type_ref));
 } else (__tmp = 0) ; __tmp; }));
  (void)(((snap)->num_consts = ast_pipeline_onefunc_num_consts(parser_onefunc_result_pool_ptr(snap))));
  (void)(((snap)->num_lets = ast_pipeline_onefunc_num_lets(parser_onefunc_result_pool_ptr(snap))));
  (void)(((snap)->num_if_stmts = pipeline_onefunc_num_if_stmts(parser_onefunc_result_pool_ptr(snap))));
  (void)(((snap)->num_src_stmt_order = pipeline_onefunc_num_src_stmt_order(parser_onefunc_result_pool_ptr(snap))));
  (void)(((snap)->num_src_body_expr_stmts = pipeline_onefunc_num_body_expr_stmts(parser_onefunc_result_pool_ptr(snap))));
  (void)(((snap)->num_loops = ast_pipeline_onefunc_num_whiles(parser_onefunc_result_pool_ptr(snap))));
  (void)(((snap)->num_for_loops = ast_pipeline_onefunc_num_fors(parser_onefunc_result_pool_ptr(snap))));
}
void parser_onefunc_finish_impl_to_out(struct parser_OneFuncResult * restrict out, struct parser_OneFuncResult * restrict snap, struct lexer_Lexer lex, uint8_t * restrict name, int32_t name_len, int32_t ret_expr_storage) {
  (void)(parser_onefunc_merge_pool_out_to_snap(snap, out));
  (void)(((snap)->return_expr_ref = ret_expr_storage));
  (void)(((snap)->ok = 1));
  (void)(((snap)->next_lex = lex));
  (void)(((snap)->name_len = name_len));
  int32_t ni = 0;
  while (ni < 64) {
    (void)(((ni < 0 || (ni) >= 64 ? (shulang_panic_(1, 0), 0) : (((snap)->name)[ni] = (name)[ni], 0))));
    (void)((ni = ni + 1));
  }
  (void)(parser_copy_onefunc_into(out, snap));
}
void parser_onefunc_res_wire_dummy_head(struct parser_OneFuncResult * restrict res, struct lexer_Lexer lex, uint8_t name64[64]) {
  struct parser_OneFuncResult _w = ({ struct parser_OneFuncResult _t = { 0 }; _t.ok = 0; _t.next_lex = lex; _t.name_len = 0; _t.num_params = 0; memcpy(_t.name, name64, sizeof(_t.name)); _t; });
  (void)(parser_copy_onefunc_into(res, (&(_w))));
}
void parser_onefunc_res_wire_dummy_const_let(struct parser_OneFuncResult * restrict res) {
  struct parser_OneFuncResult _w = (struct parser_OneFuncResult){ .num_consts = 0, .num_lets = 0 };
  (void)(parser_copy_onefunc_into(res, (&(_w))));
}
void parser_onefunc_res_wire_dummy_if_mul(struct parser_OneFuncResult * restrict res) {
  struct parser_OneFuncResult _w = (struct parser_OneFuncResult){ .has_if_expr = 0, .if_cond_true = 0, .if_then_val = 0, .if_else_val = 0, .if_cond_expr_ref = 0, .has_mul = 0, .mul_right_val = 0 };
  (void)(parser_copy_onefunc_into(res, (&(_w))));
}
void parser_onefunc_res_wire_dummy_call_binop(struct parser_OneFuncResult * restrict res, uint8_t name64[64]) {
  struct parser_OneFuncResult _w = ({ struct parser_OneFuncResult _t = { 0 }; _t.has_binop = 0; _t.binop_right_val = 0; _t.binop_left_param_idx = (-1); _t.binop_right_param_idx = (-1); _t.has_unary_neg = 0; _t.return_val = 0; _t.has_call_expr = 0; memcpy(_t.call_callee_name, name64, sizeof(_t.call_callee_name)); _t; });
  (void)(parser_copy_onefunc_into(res, (&(_w))));
}
void parser_onefunc_res_wire_dummy_loop_call(struct parser_OneFuncResult * restrict res) {
  struct parser_OneFuncResult _w = (struct parser_OneFuncResult){ .call_callee_len = 0, .return_var_name_len = 0, .return_expr_ref = 0, .call_num_args = 0, .num_loops = 0 };
  (void)(parser_copy_onefunc_into(res, (&(_w))));
}
void parser_onefunc_res_wire_dummy_for_if(struct parser_OneFuncResult * restrict res) {
  struct parser_OneFuncResult _w = (struct parser_OneFuncResult){ .num_for_loops = 0, .num_if_stmts = 0 };
  (void)(parser_copy_onefunc_into(res, (&(_w))));
}
struct parser_OneFuncResult parser_onefunc_alloc_wired_for_parse(struct lexer_Lexer lex) {
  uint8_t dummy_name[64] = { 0 };
  struct parser_OneFuncResult res = parser_onefunc_scratch_empty();
  (void)(parser_onefunc_res_wire_dummy_head((&(res)), lex, dummy_name));
  (void)(parser_onefunc_res_wire_dummy_const_let((&(res))));
  (void)(parser_onefunc_res_wire_dummy_if_mul((&(res))));
  (void)(parser_onefunc_res_wire_dummy_call_binop((&(res)), dummy_name));
  (void)(parser_onefunc_res_wire_dummy_loop_call((&(res))));
  (void)(parser_onefunc_res_wire_dummy_for_if((&(res))));
  return res;
}
void parser_onefunc_snap_set_return_path(struct parser_OneFuncResult * restrict snap, int has_call, uint8_t ret_var[64], int32_t ret_var_len, int32_t ret_expr_ref) {
  (void)(((snap)->has_call_expr = has_call));
  (void)(((snap)->return_var_name_len = ret_var_len));
  (void)(((snap)->return_expr_ref = ret_expr_ref));
  (void)(((snap)->has_explicit_return_kw = 1));
  int32_t rvni = 0;
  while (rvni < 64) {
    (void)(((rvni < 0 || (rvni) >= 64 ? (shulang_panic_(1, 0), 0) : (((snap)->return_var_name)[rvni] = (rvni < 0 || (rvni) >= 64 ? (shulang_panic_(1, 0), (ret_var)[0]) : (ret_var)[rvni]), 0))));
    (void)((rvni = rvni + 1));
  }
}
void parser_onefunc_push_src_stmt(struct parser_OneFuncResult * restrict out, uint8_t kind, int32_t idx) {
  int32_t _so = pipeline_onefunc_push_stmt_order(parser_onefunc_result_pool_ptr(out), kind, idx);
  (void)(({ int32_t __tmp = 0; if (_so >= 0) {   (void)(((out)->num_src_stmt_order = pipeline_onefunc_num_src_stmt_order(parser_onefunc_result_pool_ptr(out))));
 } else (__tmp = 0) ; __tmp; }));
}
void parser_expr_set_common_zeros(struct ast_Expr * restrict e) {
  (void)(((e)->resolved_type_ref = 0));
  (void)(((e)->binop_left_ref = 0));
  (void)(((e)->binop_right_ref = 0));
  (void)(((e)->unary_operand_ref = 0));
  (void)(((e)->if_cond_ref = 0));
  (void)(((e)->if_then_ref = 0));
  (void)(((e)->if_else_ref = 0));
  (void)(((e)->block_ref = 0));
  (void)(((e)->match_matched_ref = 0));
  (void)(((e)->match_arm_base = 0));
  (void)(((e)->match_num_arms = 0));
  (void)(ast_expr_init_match_enum(e));
  (void)(((e)->field_access_base_ref = 0));
  (void)(((e)->field_access_field_len = 0));
  (void)(((e)->field_access_is_enum_variant = 0));
  (void)(((e)->field_access_offset = 0));
  (void)(((e)->index_base_ref = 0));
  (void)(((e)->index_index_ref = 0));
  (void)(((e)->index_base_is_slice = 0));
  (void)(((e)->call_callee_ref = 0));
  (void)(((e)->call_arg_base = 0));
  (void)(((e)->call_num_args = 0));
  (void)(((e)->method_call_base_ref = 0));
  (void)(((e)->method_call_name_len = 0));
  (void)(((e)->method_call_arg_base = 0));
  (void)(((e)->method_call_num_args = 0));
  (void)(((e)->const_folded_val = 0));
  (void)(((e)->const_folded_valid = 0));
  (void)(((e)->index_proven_in_bounds = 0));
  (void)(((e)->struct_lit_field_base = 0));
  (void)(((e)->struct_lit_num_fields = 0));
  (void)(((e)->array_lit_elem_base = 0));
  (void)(((e)->array_lit_num_elems = 0));
  (void)(((e)->as_operand_ref = 0));
  (void)(((e)->as_target_type_ref = 0));
  (void)(((e)->call_resolved_func_index = 0 - 1));
  (void)(((e)->call_resolved_dep_index = 0 - 1));
}
int32_t parser_alloc_true_bool_lit(struct ast_ASTArena * restrict arena) {
  int32_t ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr e;
  e = pipeline_arena_expr_get_copy(arena, ref);
  (void)(((e).kind = ast_ExprKind_EXPR_BOOL_LIT));
  (void)(((e).int_val = 1));
  (void)(((e).line = 0));
  (void)(((e).col = 0));
  (void)(parser_expr_set_common_zeros((&(e))));
  (void)(ast_arena_expr_set(arena, ref, e));
  return ref;
}
int32_t parser_expr_wrap_in_return(struct ast_ASTArena * restrict arena, int32_t type_ref, int32_t inner_ref) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(inner_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr inner;
  inner = pipeline_arena_expr_get_copy(arena, inner_ref);
  (void)(({ int32_t __tmp = 0; if ((inner).kind == ast_ExprKind_EXPR_RETURN) {   return inner_ref;
 } else (__tmp = 0) ; __tmp; }));
  int32_t wrap = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (wrap == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr rwe;
  rwe = pipeline_arena_expr_get_copy(arena, wrap);
  (void)(((rwe).kind = ast_ExprKind_EXPR_RETURN));
  (void)(((rwe).line = 0));
  (void)(((rwe).col = 0));
  (void)(((rwe).int_val = 0));
  (void)(parser_expr_set_common_zeros((&(rwe))));
  (void)(((rwe).resolved_type_ref = type_ref));
  (void)(((rwe).unary_operand_ref = inner_ref));
  (void)(ast_arena_expr_set(arena, wrap, rwe));
  return wrap;
}
int parser_should_wrap_func_tail_in_return(struct ast_ASTArena * restrict arena, struct parser_OneFuncResult * restrict res, int32_t type_ref) {
  (void)(({ int __tmp = 0; if ((res)->return_expr_ref == 0 && (res)->return_var_name_len == 0 && (!(res)->has_explicit_return_kw)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (ast_ref_is_null(type_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type rtw;
  rtw = pipeline_arena_type_get_copy(arena, type_ref);
  (void)(({ int __tmp = 0; if ((rtw).kind == ast_TypeKind_TYPE_VOID) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return 1;
}
void parser_parse_primary_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_INT) {   int32_t ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr e;
  e = pipeline_arena_expr_get_copy(arena, ref);
  (void)(((e).kind = ast_ExprKind_EXPR_LIT));
  (void)(((e).line = 0));
  (void)(((e).col = 0));
  (void)(((e).int_val = ((r).tok).int_val));
  (void)(parser_expr_set_common_zeros((&(e))));
  (void)(ast_arena_expr_set(arena, ref, e));
  (void)(((out)->ok = 1));
  (void)(((out)->expr_ref = ref));
  (void)(((out)->next_lex = (r).next_lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_TRUE || ((r).tok).kind == token_TokenKind_TOKEN_FALSE) {   int32_t ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr e;
  e = pipeline_arena_expr_get_copy(arena, ref);
  (void)(((e).kind = ast_ExprKind_EXPR_BOOL_LIT));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_TRUE) {   (void)(((e).int_val = 1));
 } else {   (void)(((e).int_val = 0));
 } ; __tmp; }));
  (void)(((e).line = 0));
  (void)(((e).col = 0));
  (void)(parser_expr_set_common_zeros((&(e))));
  (void)(ast_arena_expr_set(arena, ref, e));
  (void)(((out)->ok = 1));
  (void)(((out)->expr_ref = ref));
  (void)(((out)->next_lex = (r).next_lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_BREAK || ((r).tok).kind == token_TokenKind_TOKEN_CONTINUE) {   int32_t ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr e;
  e = pipeline_arena_expr_get_copy(arena, ref);
  (void)(({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_BREAK) {   (void)(((e).kind = ast_ExprKind_EXPR_BREAK));
 } else {   (void)(((e).kind = ast_ExprKind_EXPR_CONTINUE));
 } ; __tmp; }));
  (void)(((e).line = 0));
  (void)(((e).col = 0));
  (void)(parser_expr_set_common_zeros((&(e))));
  (void)(ast_arena_expr_set(arena, ref, e));
  (void)(((out)->ok = 1));
  (void)(((out)->expr_ref = ref));
  (void)(((out)->next_lex = (r).next_lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_PANIC) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  int32_t panic_op = 0;
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LPAREN) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   struct parser_ParseExprResult arg_pr = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex };
  (void)(parser_parse_expr_into(arena, lex, source, (&(arg_pr))));
  (void)(({ int32_t __tmp = 0; if ((!(arg_pr).ok)) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((panic_op = (arg_pr).expr_ref));
  (void)((lex = (arg_pr).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
 } else (__tmp = 0) ; __tmp; }));
  int32_t pref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (pref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr pe;
  pe = pipeline_arena_expr_get_copy(arena, pref);
  (void)(parser_expr_set_common_zeros((&(pe))));
  (void)(((pe).kind = ast_ExprKind_EXPR_PANIC));
  (void)(((pe).unary_operand_ref = panic_op));
  (void)(((pe).line = 0));
  (void)(((pe).col = 0));
  (void)(ast_arena_expr_set(arena, pref, pe));
  (void)(((out)->ok = 1));
  (void)(((out)->expr_ref = pref));
  (void)(((out)->next_lex = lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   int32_t ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr e;
  e = pipeline_arena_expr_get_copy(arena, ref);
  (void)(((e).kind = ast_ExprKind_EXPR_VAR));
  (void)(((e).var_name_len = ((r).tok).ident_len));
  (void)(({ int32_t __tmp = 0; if ((e).var_name_len > 63) {   (void)(((e).var_name_len = 63));
 } else (__tmp = 0) ; __tmp; }));
  size_t start = (r).token_start;
  int32_t i = 0;
  while (i < (e).var_name_len && start + i < (source)->length) {
    (void)(((i < 0 || (i) >= 64 ? (shulang_panic_(1, 0), 0) : (((e).var_name)[i] = (start + i < 0 || (size_t)(start + i) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[start + i]), 0))));
    (void)((i = i + 1));
  }
  while (i < 64) {
    (void)(((i < 0 || (i) >= 64 ? (shulang_panic_(1, 0), 0) : (((e).var_name)[i] = 0, 0))));
    (void)((i = i + 1));
  }
  (void)(((e).line = 0));
  (void)(((e).col = 0));
  (void)(parser_expr_set_common_zeros((&(e))));
  (void)(ast_arena_expr_set(arena, ref, e));
  (void)(((out)->ok = 1));
  (void)(((out)->expr_ref = ref));
  (void)((lex = (r).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)(parser_finish_struct_lit_from_type_ident_into(arena, ref, (r).next_lex, source, out));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int first_suffix = 1;
  while (1) {
    (void)(({ int32_t __tmp = 0; if ((!first_suffix)) {   (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
    (void)((first_suffix = 0));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_DOT) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->next_lex = lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t fa_ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (fa_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr fe;
  fe = pipeline_arena_expr_get_copy(arena, fa_ref);
  (void)(((fe).kind = ast_ExprKind_EXPR_FIELD_ACCESS));
  (void)(((fe).line = 0));
  (void)(((fe).col = 0));
  (void)(parser_expr_set_common_zeros((&(fe))));
  (void)(((fe).field_access_base_ref = (out)->expr_ref));
  (void)(((fe).field_access_field_len = ((r).tok).ident_len));
  (void)(({ int32_t __tmp = 0; if ((fe).field_access_field_len > 63) {   (void)(((fe).field_access_field_len = 63));
 } else (__tmp = 0) ; __tmp; }));
  size_t fstart = (r).token_start;
  int32_t fi = 0;
  while (fi < (fe).field_access_field_len && fstart + ((size_t)(fi)) < (source)->length) {
    (void)(((fi < 0 || (fi) >= 64 ? (shulang_panic_(1, 0), 0) : (((fe).field_access_field_name)[fi] = (fstart + ((size_t)(fi)) < 0 || (size_t)(fstart + ((size_t)(fi))) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[fstart + ((size_t)(fi))]), 0))));
    (void)((fi = fi + 1));
  }
  while (fi < 64) {
    (void)(((fi < 0 || (fi) >= 64 ? (shulang_panic_(1, 0), 0) : (((fe).field_access_field_name)[fi] = 0, 0))));
    (void)((fi = fi + 1));
  }
  (void)(ast_arena_expr_set(arena, fa_ref, fe));
  (void)(((out)->expr_ref = fa_ref));
  (void)((lex = (r).next_lex));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACKET) {   int32_t base_ref_saved = (out)->expr_ref;
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_parse_expr_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t idx_ref_2 = (out)->expr_ref;
  (void)((lex = (out)->next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACKET) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (r).next_lex));
  int32_t idx_ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (idx_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr ie;
  ie = pipeline_arena_expr_get_copy(arena, idx_ref);
  (void)(parser_expr_set_common_zeros((&(ie))));
  (void)(((ie).kind = ast_ExprKind_EXPR_INDEX));
  (void)(((ie).index_base_ref = base_ref_saved));
  (void)(((ie).index_index_ref = idx_ref_2));
  (void)(((ie).index_base_is_slice = 0));
  (void)(((ie).line = 0));
  (void)(((ie).col = 0));
  (void)(ast_arena_expr_set(arena, idx_ref, ie));
  (void)(((out)->expr_ref = idx_ref));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LPAREN) {   int32_t callee_ref = (out)->expr_ref;
  (void)((lex = (r).next_lex));
  int32_t call_ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (call_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr ce_init;
  ce_init = pipeline_arena_expr_get_copy(arena, call_ref);
  (void)(((ce_init).kind = ast_ExprKind_EXPR_CALL));
  (void)(((ce_init).line = 0));
  (void)(((ce_init).col = 0));
  (void)(parser_expr_set_common_zeros((&(ce_init))));
  (void)(((ce_init).call_callee_ref = callee_ref));
  (void)(ast_arena_expr_set(arena, call_ref, ce_init));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   while (1) {
    struct parser_ParseExprResult arg_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex };
    (void)(parser_parse_expr_into(arena, lex, source, (&(arg_res))));
    (void)(({ int32_t __tmp = 0; if ((!(arg_res).ok)) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (pipeline_expr_append_call_arg(arena, call_ref, (arg_res).expr_ref) < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)((lex = (arg_res).next_lex));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_COMMA) {   (void)((lex = (r).next_lex));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RPAREN) {   (void)((lex = (r).next_lex));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(((out)->ok = 0));
    return;
  }
 } else {   (void)((lex = (r).next_lex));
 } ; __tmp; }));
  (void)(((out)->expr_ref = call_ref));
 } else {   (void)(((out)->next_lex = lex));
  return;
 } ; __tmp; })) ; __tmp; })) ; __tmp; }));
  }
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LPAREN) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_parse_expr_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (out)->next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out)->next_lex = (r).next_lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACKET) {   (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
  int32_t arr_ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (arr_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr ae0;
  ae0 = pipeline_arena_expr_get_copy(arena, arr_ref);
  (void)(((ae0).kind = ast_ExprKind_EXPR_ARRAY_LIT));
  (void)(((ae0).resolved_type_ref = 0));
  (void)(((ae0).line = 0));
  (void)(((ae0).col = 0));
  (void)(parser_expr_set_common_zeros((&(ae0))));
  (void)(ast_arena_expr_set(arena, arr_ref, ae0));
  while (((r).tok).kind != token_TokenKind_TOKEN_RBRACKET) {
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_INT) {   int32_t er = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (er != 0) {   struct ast_Expr ee;
  ee = pipeline_arena_expr_get_copy(arena, er);
  (void)(((ee).kind = ast_ExprKind_EXPR_LIT));
  (void)(((ee).resolved_type_ref = 0));
  (void)(((ee).line = 0));
  (void)(((ee).col = 0));
  (void)(((ee).int_val = ((r).tok).int_val));
  (void)(parser_expr_set_common_zeros((&(ee))));
  (void)(ast_arena_expr_set(arena, er, ee));
  __tmp = ({ int32_t __tmp = 0; if (pipeline_expr_append_array_lit_elem(arena, arr_ref, er) < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_COMMA) {   (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
 } else {   break;
 } ; __tmp; })) ; __tmp; }));
  }
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACKET) {   (void)(((out)->ok = 1));
  (void)(((out)->expr_ref = arr_ref));
  (void)(((out)->next_lex = (r).next_lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out)->ok = 0));
}
void parser_parse_as_suffix_into(struct ast_ASTArena * restrict arena, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_cur = (out)->next_lex;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  while (1) {
    (void)(lexer_next_into((&(r)), lex_cur, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_AS) {   (void)(((out)->next_lex = lex_cur));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex_cur)), r));
    (void)(lexer_next_into((&(r)), lex_cur, source));
    int32_t type_ref = 0;
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STAR) {   (void)(parser_lex_from_result_ptr_into((&(lex_cur)), (&(r))));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  int32_t elem_ref = parser_alloc_pointee_type_ref_from_tok(arena, source, (&(r)));
  (void)(({ int32_t __tmp = 0; if (elem_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((type_ref = ast_arena_type_alloc(arena)));
  (void)(({ int32_t __tmp = 0; if (type_ref != 0) {   struct ast_Type tptr;
  tptr = pipeline_arena_type_get_copy(arena, type_ref);
  (void)(((tptr).kind = ast_TypeKind_TYPE_PTR));
  (void)(((tptr).elem_type_ref = elem_ref));
  (void)(((tptr).name_len = 0));
  (void)(((tptr).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref, tptr));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex_cur)), (&(r))));
  (void)((lex_cur = (r).next_lex));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_I32 || ((r).tok).kind == token_TokenKind_TOKEN_I64 || ((r).tok).kind == token_TokenKind_TOKEN_BOOL || ((r).tok).kind == token_TokenKind_TOKEN_U8 || ((r).tok).kind == token_TokenKind_TOKEN_U32 || ((r).tok).kind == token_TokenKind_TOKEN_U64 || ((r).tok).kind == token_TokenKind_TOKEN_USIZE || ((r).tok).kind == token_TokenKind_TOKEN_ISIZE || ((r).tok).kind == token_TokenKind_TOKEN_VOID || ((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   (void)((type_ref = ast_arena_type_alloc(arena)));
  (void)(({ int32_t __tmp = 0; if (type_ref != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref);
  (void)(({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_I32) {   (void)(((t).kind = ast_TypeKind_TYPE_I32));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_I64) {   (void)(((t).kind = ast_TypeKind_TYPE_I64));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_BOOL) {   (void)(((t).kind = ast_TypeKind_TYPE_BOOL));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_U8) {   (void)(((t).kind = ast_TypeKind_TYPE_U8));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_U32) {   (void)(((t).kind = ast_TypeKind_TYPE_U32));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_U64) {   (void)(((t).kind = ast_TypeKind_TYPE_U64));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_USIZE) {   (void)(((t).kind = ast_TypeKind_TYPE_USIZE));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ISIZE) {   (void)(((t).kind = ast_TypeKind_TYPE_ISIZE));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_VOID) {   (void)(((t).kind = ast_TypeKind_TYPE_VOID));
 } else {   (void)(((t).kind = ast_TypeKind_TYPE_NAMED));
  (void)(((t).name_len = ((r).tok).ident_len));
  (void)(({ int32_t __tmp = 0; if ((t).name_len > 63) {   (void)(((t).name_len = 63));
 } else (__tmp = 0) ; __tmp; }));
  int32_t si2 = 0;
  while (si2 < (t).name_len && (r).token_start + ((size_t)(si2)) < (source)->length) {
    (void)(((si2 < 0 || (si2) >= 64 ? (shulang_panic_(1, 0), 0) : (((t).name)[si2] = ((r).token_start + ((size_t)(si2)) < 0 || (size_t)((r).token_start + ((size_t)(si2))) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[(r).token_start + ((size_t)(si2))]), 0))));
    (void)((si2 = si2 + 1));
  }
 } ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  (void)(((t).elem_type_ref = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref, t));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex_cur)), (&(r))));
  (void)((lex_cur = (r).next_lex));
 } else {   (void)(((out)->ok = 0));
  return;
 } ; __tmp; })) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (type_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t inner_ref = (out)->expr_ref;
    int32_t as_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (as_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr ae;
    ae = pipeline_arena_expr_get_copy(arena, as_ref);
    (void)(((ae).kind = ast_ExprKind_EXPR_AS));
    (void)(((ae).line = 0));
    (void)(((ae).col = 0));
    (void)(parser_expr_set_common_zeros((&(ae))));
    (void)(((ae).as_operand_ref = inner_ref));
    (void)(((ae).as_target_type_ref = type_ref));
    (void)(ast_arena_expr_set(arena, as_ref, ae));
    (void)(((out)->expr_ref = as_ref));
    (void)((lex_cur = (r).next_lex));
  }
}
void parser_parse_unary_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_MINUS) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_parse_unary_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t op_ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (op_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr e;
  e = pipeline_arena_expr_get_copy(arena, op_ref);
  (void)(parser_expr_set_common_zeros((&(e))));
  (void)(((e).kind = ast_ExprKind_EXPR_NEG));
  (void)(((e).unary_operand_ref = (out)->expr_ref));
  (void)(((e).line = 0));
  (void)(((e).col = 0));
  (void)(ast_arena_expr_set(arena, op_ref, e));
  (void)(((out)->expr_ref = op_ref));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_BANG) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_parse_unary_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t op_ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (op_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr e;
  e = pipeline_arena_expr_get_copy(arena, op_ref);
  (void)(parser_expr_set_common_zeros((&(e))));
  (void)(((e).kind = ast_ExprKind_EXPR_LOGNOT));
  (void)(((e).unary_operand_ref = (out)->expr_ref));
  (void)(((e).line = 0));
  (void)(((e).col = 0));
  (void)(ast_arena_expr_set(arena, op_ref, e));
  (void)(((out)->expr_ref = op_ref));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_AMP) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_parse_unary_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t addr_ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (addr_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr ae;
  ae = pipeline_arena_expr_get_copy(arena, addr_ref);
  (void)(parser_expr_set_common_zeros((&(ae))));
  (void)(((ae).kind = ast_ExprKind_EXPR_ADDR_OF));
  (void)(((ae).unary_operand_ref = (out)->expr_ref));
  (void)(((ae).line = 0));
  (void)(((ae).col = 0));
  (void)(ast_arena_expr_set(arena, addr_ref, ae));
  (void)(((out)->expr_ref = addr_ref));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_parse_primary_into(arena, lex, source, out));
}
void parser_parse_cast_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_unary_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_parse_as_suffix_into(arena, source, out));
}
void parser_parse_term_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_cast_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_cur = (out)->next_lex;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  while (1) {
    (void)(lexer_next_into((&(r)), lex_cur, source));
    enum ast_ExprKind kind = ast_ExprKind_EXPR_LIT;
    (void)(({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STAR) {   (void)((kind = ast_ExprKind_EXPR_MUL));
 } else (__tmp = ({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SLASH) {   (void)((kind = ast_ExprKind_EXPR_DIV));
 } else (__tmp = ({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_PERCENT) {   (void)((kind = ast_ExprKind_EXPR_MOD));
 } else {   (void)(((out)->next_lex = lex_cur));
  return;
 } ; __tmp; })) ; __tmp; })) ; __tmp; }));
    int32_t left_ref = (out)->expr_ref;
    (void)(parser_lex_from_next_into((&(lex_cur)), r));
    (void)(parser_parse_cast_into(arena, lex_cur, source, out));
    (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t right_ref = (out)->expr_ref;
    int32_t bin_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (bin_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr be;
    be = pipeline_arena_expr_get_copy(arena, bin_ref);
    (void)(parser_expr_set_common_zeros((&(be))));
    (void)(((be).kind = kind));
    (void)(((be).binop_left_ref = left_ref));
    (void)(((be).binop_right_ref = right_ref));
    (void)(((be).line = 0));
    (void)(((be).col = 0));
    (void)(ast_arena_expr_set(arena, bin_ref, be));
    (void)(((out)->expr_ref = bin_ref));
    (void)((lex_cur = (out)->next_lex));
  }
}
void parser_parse_addsub_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_term_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_cur = (out)->next_lex;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  while (1) {
    (void)(lexer_next_into((&(r)), lex_cur, source));
    enum ast_ExprKind kind = ast_ExprKind_EXPR_LIT;
    (void)(({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_PLUS) {   (void)((kind = ast_ExprKind_EXPR_ADD));
 } else (__tmp = ({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_MINUS) {   (void)((kind = ast_ExprKind_EXPR_SUB));
 } else {   (void)(((out)->next_lex = lex_cur));
  return;
 } ; __tmp; })) ; __tmp; }));
    int32_t left_ref = (out)->expr_ref;
    (void)(parser_lex_from_next_into((&(lex_cur)), r));
    (void)(parser_parse_term_into(arena, lex_cur, source, out));
    (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t right_ref = (out)->expr_ref;
    int32_t bin_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (bin_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr be;
    be = pipeline_arena_expr_get_copy(arena, bin_ref);
    (void)(parser_expr_set_common_zeros((&(be))));
    (void)(((be).kind = kind));
    (void)(((be).binop_left_ref = left_ref));
    (void)(((be).binop_right_ref = right_ref));
    (void)(((be).line = 0));
    (void)(((be).col = 0));
    (void)(ast_arena_expr_set(arena, bin_ref, be));
    (void)(((out)->expr_ref = bin_ref));
    (void)((lex_cur = (out)->next_lex));
  }
}
void parser_parse_shift_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_addsub_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_cur = (out)->next_lex;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  while (1) {
    (void)(lexer_next_into((&(r)), lex_cur, source));
    enum ast_ExprKind kind = ast_ExprKind_EXPR_SHL;
    (void)(({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LSHIFT) {   (void)((kind = ast_ExprKind_EXPR_SHL));
 } else (__tmp = ({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RSHIFT) {   (void)((kind = ast_ExprKind_EXPR_SHR));
 } else {   (void)(((out)->next_lex = lex_cur));
  return;
 } ; __tmp; })) ; __tmp; }));
    int32_t left_ref = (out)->expr_ref;
    (void)(parser_lex_from_next_into((&(lex_cur)), r));
    (void)(parser_parse_addsub_into(arena, lex_cur, source, out));
    (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t right_ref = (out)->expr_ref;
    int32_t bin_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (bin_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr be;
    be = pipeline_arena_expr_get_copy(arena, bin_ref);
    (void)(parser_expr_set_common_zeros((&(be))));
    (void)(((be).kind = kind));
    (void)(((be).binop_left_ref = left_ref));
    (void)(((be).binop_right_ref = right_ref));
    (void)(((be).line = 0));
    (void)(((be).col = 0));
    (void)(ast_arena_expr_set(arena, bin_ref, be));
    (void)(((out)->expr_ref = bin_ref));
    (void)((lex_cur = (out)->next_lex));
  }
}
void parser_parse_relcompare_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_shift_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_cur = (out)->next_lex;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  while (1) {
    (void)(lexer_next_into((&(r)), lex_cur, source));
    enum ast_ExprKind kind = ast_ExprKind_EXPR_LT;
    (void)(({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LT) {   (void)((kind = ast_ExprKind_EXPR_LT));
 } else (__tmp = ({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LE) {   (void)((kind = ast_ExprKind_EXPR_LE));
 } else (__tmp = ({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_GT) {   (void)((kind = ast_ExprKind_EXPR_GT));
 } else (__tmp = ({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_GE) {   (void)((kind = ast_ExprKind_EXPR_GE));
 } else {   (void)(((out)->next_lex = lex_cur));
  return;
 } ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
    int32_t left_ref = (out)->expr_ref;
    (void)(parser_lex_from_next_into((&(lex_cur)), r));
    (void)(parser_parse_shift_into(arena, lex_cur, source, out));
    (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t right_ref = (out)->expr_ref;
    int32_t bin_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (bin_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr be;
    be = pipeline_arena_expr_get_copy(arena, bin_ref);
    (void)(parser_expr_set_common_zeros((&(be))));
    (void)(((be).kind = kind));
    (void)(((be).binop_left_ref = left_ref));
    (void)(((be).binop_right_ref = right_ref));
    (void)(((be).line = 0));
    (void)(((be).col = 0));
    (void)(ast_arena_expr_set(arena, bin_ref, be));
    (void)(((out)->expr_ref = bin_ref));
    (void)((lex_cur = (out)->next_lex));
  }
}
void parser_parse_compare_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_relcompare_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_cur = (out)->next_lex;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  while (1) {
    (void)(lexer_next_into((&(r)), lex_cur, source));
    enum ast_ExprKind kind = ast_ExprKind_EXPR_EQ;
    (void)(({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EQ) {   (void)((kind = ast_ExprKind_EXPR_EQ));
 } else (__tmp = ({ enum ast_ExprKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_NE) {   (void)((kind = ast_ExprKind_EXPR_NE));
 } else {   (void)(((out)->next_lex = lex_cur));
  return;
 } ; __tmp; })) ; __tmp; }));
    int32_t left_ref = (out)->expr_ref;
    (void)(parser_lex_from_next_into((&(lex_cur)), r));
    (void)(parser_parse_relcompare_into(arena, lex_cur, source, out));
    (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t right_ref = (out)->expr_ref;
    int32_t bin_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (bin_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr be;
    be = pipeline_arena_expr_get_copy(arena, bin_ref);
    (void)(parser_expr_set_common_zeros((&(be))));
    (void)(((be).kind = kind));
    (void)(((be).binop_left_ref = left_ref));
    (void)(((be).binop_right_ref = right_ref));
    (void)(((be).line = 0));
    (void)(((be).col = 0));
    (void)(ast_arena_expr_set(arena, bin_ref, be));
    (void)(((out)->expr_ref = bin_ref));
    (void)((lex_cur = (out)->next_lex));
  }
}
void parser_parse_bitand_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_compare_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_cur = (out)->next_lex;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  while (1) {
    (void)(lexer_next_into((&(r)), lex_cur, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_AMP) {   (void)(((out)->next_lex = lex_cur));
  return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t left_ref = (out)->expr_ref;
    (void)(parser_lex_from_next_into((&(lex_cur)), r));
    (void)(parser_parse_compare_into(arena, lex_cur, source, out));
    (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t right_ref = (out)->expr_ref;
    int32_t bin_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (bin_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr be;
    be = pipeline_arena_expr_get_copy(arena, bin_ref);
    (void)(parser_expr_set_common_zeros((&(be))));
    (void)(((be).kind = ast_ExprKind_EXPR_BITAND));
    (void)(((be).binop_left_ref = left_ref));
    (void)(((be).binop_right_ref = right_ref));
    (void)(((be).line = 0));
    (void)(((be).col = 0));
    (void)(ast_arena_expr_set(arena, bin_ref, be));
    (void)(((out)->expr_ref = bin_ref));
    (void)((lex_cur = (out)->next_lex));
  }
}
void parser_parse_bitxor_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_bitand_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_cur = (out)->next_lex;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  while (1) {
    (void)(lexer_next_into((&(r)), lex_cur, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_CARET) {   (void)(((out)->next_lex = lex_cur));
  return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t left_ref = (out)->expr_ref;
    (void)(parser_lex_from_next_into((&(lex_cur)), r));
    (void)(parser_parse_bitand_into(arena, lex_cur, source, out));
    (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t right_ref = (out)->expr_ref;
    int32_t bin_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (bin_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr be;
    be = pipeline_arena_expr_get_copy(arena, bin_ref);
    (void)(parser_expr_set_common_zeros((&(be))));
    (void)(((be).kind = ast_ExprKind_EXPR_BITXOR));
    (void)(((be).binop_left_ref = left_ref));
    (void)(((be).binop_right_ref = right_ref));
    (void)(((be).line = 0));
    (void)(((be).col = 0));
    (void)(ast_arena_expr_set(arena, bin_ref, be));
    (void)(((out)->expr_ref = bin_ref));
    (void)((lex_cur = (out)->next_lex));
  }
}
void parser_parse_bitor_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_bitxor_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_cur = (out)->next_lex;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  while (1) {
    (void)(lexer_next_into((&(r)), lex_cur, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_PIPE) {   (void)(((out)->next_lex = lex_cur));
  return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t left_ref = (out)->expr_ref;
    (void)(parser_lex_from_next_into((&(lex_cur)), r));
    (void)(parser_parse_bitxor_into(arena, lex_cur, source, out));
    (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t right_ref = (out)->expr_ref;
    int32_t bin_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (bin_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr be;
    be = pipeline_arena_expr_get_copy(arena, bin_ref);
    (void)(parser_expr_set_common_zeros((&(be))));
    (void)(((be).kind = ast_ExprKind_EXPR_BITOR));
    (void)(((be).binop_left_ref = left_ref));
    (void)(((be).binop_right_ref = right_ref));
    (void)(((be).line = 0));
    (void)(((be).col = 0));
    (void)(ast_arena_expr_set(arena, bin_ref, be));
    (void)(((out)->expr_ref = bin_ref));
    (void)((lex_cur = (out)->next_lex));
  }
}
void parser_parse_logand_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_bitor_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_cur = (out)->next_lex;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  while (1) {
    (void)(lexer_next_into((&(r)), lex_cur, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_AMPAMP) {   (void)(((out)->next_lex = lex_cur));
  return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t left_ref = (out)->expr_ref;
    (void)(parser_lex_from_next_into((&(lex_cur)), r));
    (void)(parser_parse_bitor_into(arena, lex_cur, source, out));
    (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t right_ref = (out)->expr_ref;
    int32_t bin_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (bin_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr be;
    be = pipeline_arena_expr_get_copy(arena, bin_ref);
    (void)(parser_expr_set_common_zeros((&(be))));
    (void)(((be).kind = ast_ExprKind_EXPR_LOGAND));
    (void)(((be).binop_left_ref = left_ref));
    (void)(((be).binop_right_ref = right_ref));
    (void)(((be).line = 0));
    (void)(((be).col = 0));
    (void)(ast_arena_expr_set(arena, bin_ref, be));
    (void)(((out)->expr_ref = bin_ref));
    (void)((lex_cur = (out)->next_lex));
  }
}
void parser_parse_logor_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_logand_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_cur = (out)->next_lex;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  while (1) {
    (void)(lexer_next_into((&(r)), lex_cur, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_PIPEPIPE) {   (void)(((out)->next_lex = lex_cur));
  return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t left_ref = (out)->expr_ref;
    (void)(parser_lex_from_next_into((&(lex_cur)), r));
    (void)(parser_parse_logand_into(arena, lex_cur, source, out));
    (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t right_ref = (out)->expr_ref;
    int32_t bin_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (bin_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr be;
    be = pipeline_arena_expr_get_copy(arena, bin_ref);
    (void)(parser_expr_set_common_zeros((&(be))));
    (void)(((be).kind = ast_ExprKind_EXPR_LOGOR));
    (void)(((be).binop_left_ref = left_ref));
    (void)(((be).binop_right_ref = right_ref));
    (void)(((be).line = 0));
    (void)(((be).col = 0));
    (void)(ast_arena_expr_set(arena, bin_ref, be));
    (void)(((out)->expr_ref = bin_ref));
    (void)((lex_cur = (out)->next_lex));
  }
}
void parser_parse_ternary_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_logor_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_cur = (out)->next_lex;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_QUESTION) {   (void)(((out)->next_lex = lex_cur));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t cond_ref = (out)->expr_ref;
  (void)(parser_lex_from_next_into((&(lex_cur)), r));
  struct parser_ParseExprResult mid = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_expr_into(arena, lex_cur, source, (&(mid))));
  (void)(({ int32_t __tmp = 0; if ((!(mid).ok)) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex_cur = (mid).next_lex));
  int32_t then_ref = (mid).expr_ref;
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(parser_parse_ternary_into(arena, lex_cur, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t else_ref = (out)->expr_ref;
  int32_t tern_ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (tern_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr te;
  te = pipeline_arena_expr_get_copy(arena, tern_ref);
  (void)(parser_expr_set_common_zeros((&(te))));
  (void)(((te).kind = ast_ExprKind_EXPR_TERNARY));
  (void)(((te).if_cond_ref = cond_ref));
  (void)(((te).if_then_ref = then_ref));
  (void)(((te).if_else_ref = else_ref));
  (void)(((te).line = 0));
  (void)(((te).col = 0));
  (void)(ast_arena_expr_set(arena, tern_ref, te));
  (void)(((out)->expr_ref = tern_ref));
}
int parser_is_compound_assign_token(enum token_TokenKind kind) {
  return kind == token_TokenKind_TOKEN_PLUS_EQ || kind == token_TokenKind_TOKEN_MINUS_EQ || kind == token_TokenKind_TOKEN_STAR_EQ || kind == token_TokenKind_TOKEN_SLASH_EQ || kind == token_TokenKind_TOKEN_PERCENT_EQ || kind == token_TokenKind_TOKEN_AMP_EQ || kind == token_TokenKind_TOKEN_PIPE_EQ || kind == token_TokenKind_TOKEN_CARET_EQ || kind == token_TokenKind_TOKEN_LSHIFT_EQ || kind == token_TokenKind_TOKEN_RSHIFT_EQ;
}
enum ast_ExprKind parser_compound_assign_token_to_expr_kind(enum token_TokenKind kind) {
  return compound_assign_token_to_expr_kind_from_glue(kind);
}
int parser_expr_ref_is_assign_lvalue(struct ast_ASTArena * restrict arena, int32_t expr_ref) {
  return pipeline_expr_ref_is_assign_lvalue(arena, expr_ref);
}
void parser_parse_assign_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_ternary_into(arena, lex, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_cur = (out)->next_lex;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex_cur, source));
  enum token_TokenKind tok = ((r).tok).kind;
  (void)(({ int32_t __tmp = 0; if (tok != token_TokenKind_TOKEN_ASSIGN && (!parser_is_compound_assign_token(tok))) {   (void)(((out)->next_lex = lex_cur));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((!parser_expr_ref_is_assign_lvalue(arena, (out)->expr_ref))) {   (void)(((out)->next_lex = lex_cur));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t left_ref = (out)->expr_ref;
  enum ast_ExprKind assign_kind = ast_ExprKind_EXPR_ASSIGN;
  (void)(({ enum ast_ExprKind __tmp = 0; if (tok != token_TokenKind_TOKEN_ASSIGN) {   (void)((assign_kind = parser_compound_assign_token_to_expr_kind(tok)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(parser_parse_ternary_into(arena, lex_cur, source, out));
  (void)(({ int32_t __tmp = 0; if ((!(out)->ok)) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t right_ref = (out)->expr_ref;
  int32_t bin_ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (bin_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr be;
  be = pipeline_arena_expr_get_copy(arena, bin_ref);
  (void)(parser_expr_set_common_zeros((&(be))));
  (void)(((be).kind = assign_kind));
  (void)(((be).binop_left_ref = left_ref));
  (void)(((be).binop_right_ref = right_ref));
  (void)(((be).line = 0));
  (void)(((be).col = 0));
  (void)(ast_arena_expr_set(arena, bin_ref, be));
  (void)(((out)->expr_ref = bin_ref));
}
void parser_parse_expr_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_assign_into(arena, lex, source, out));
}
void parser_finish_struct_lit_from_type_ident_into(struct ast_ASTArena * restrict arena, int32_t lit_ref, struct lexer_Lexer lex_in_brace, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(({ int32_t __tmp = 0; if (lit_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr le;
  le = pipeline_arena_expr_get_copy(arena, lit_ref);
  int32_t tlen = (le).var_name_len;
  (void)(({ int32_t __tmp = 0; if (tlen <= 0 || tlen > 63) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t tnm[64] = { 0 };
  int32_t ti = 0;
  while (ti < 64) {
    (void)(((ti < 0 || (ti) >= 64 ? (shulang_panic_(1, 0), 0) : ((tnm)[ti] = (ti < 0 || (ti) >= 64 ? (shulang_panic_(1, 0), ((le).var_name)[0]) : ((le).var_name)[ti]), 0))));
    (void)((ti = ti + 1));
  }
  (void)(parser_expr_set_common_zeros((&(le))));
  (void)(((le).kind = ast_ExprKind_EXPR_STRUCT_LIT));
  (void)(((le).struct_lit_struct_name_len = tlen));
  int32_t tj = 0;
  while (tj < 64) {
    (void)(((tj < 0 || (tj) >= 64 ? (shulang_panic_(1, 0), 0) : (((le).struct_lit_struct_name)[tj] = (tj < 0 || (tj) >= 64 ? (shulang_panic_(1, 0), (tnm)[0]) : (tnm)[tj]), 0))));
    (void)((tj = tj + 1));
  }
  (void)(((le).struct_lit_field_base = 0));
  (void)(((le).struct_lit_num_fields = 0));
  (void)(((le).line = 0));
  (void)(((le).col = 0));
  (void)(((le).int_val = 0));
  (void)(((le).float_val = 0.0));
  (void)(ast_arena_expr_set(arena, lit_ref, le));
  struct lexer_Lexer lex = lex_in_brace;
  while (1) {
    struct lexer_LexerResult rf = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
    (void)(lexer_next_into((&(rf)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((rf).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(((out)->ok = 1));
  (void)(((out)->expr_ref = lit_ref));
  (void)(((out)->next_lex = (rf).next_lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((rf).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t flen = ((rf).tok).ident_len;
    (void)(({ int32_t __tmp = 0; if (flen <= 0 || flen > 63) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    uint8_t fnbuf[64] = { 0 };
    size_t fs = (rf).token_start;
    int32_t fq = 0;
    while (fq < flen && fq < 64) {
      size_t idx_fs = fs + fq;
      (void)(({ int32_t __tmp = 0; if (idx_fs >= (source)->length) {   break;
 } else (__tmp = 0) ; __tmp; }));
      (void)(((fq < 0 || (fq) >= 64 ? (shulang_panic_(1, 0), 0) : ((fnbuf)[fq] = (idx_fs < 0 || (size_t)(idx_fs) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[idx_fs]), 0))));
      (void)((fq = fq + 1));
    }
    while (fq < 64) {
      (void)(((fq < 0 || (fq) >= 64 ? (shulang_panic_(1, 0), 0) : ((fnbuf)[fq] = 0, 0))));
      (void)((fq = fq + 1));
    }
    (void)(parser_lex_from_next_into((&(lex)), rf));
    (void)(lexer_next_into((&(rf)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((rf).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)((lex = (rf).next_lex));
    struct parser_ParseExprResult fv = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex };
    (void)(parser_parse_expr_into(arena, lex, source, (&(fv))));
    (void)(({ int32_t __tmp = 0; if ((!(fv).ok) || (fv).expr_ref <= 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (pipeline_expr_append_struct_lit_field(arena, lit_ref, (&((fnbuf)[0])), flen, (fv).expr_ref) < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)((lex = (fv).next_lex));
    (void)(lexer_next_into((&(rf)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((rf).tok).kind == token_TokenKind_TOKEN_COMMA) {   (void)((lex = (rf).next_lex));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((rf).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(((out)->ok = 1));
  (void)(((out)->expr_ref = lit_ref));
  (void)(((out)->next_lex = (rf).next_lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(((out)->ok = 0));
    return;
  }
}
void parser_parse_cond_expr_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_start, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  struct lexer_LexerResult rpeek = (struct lexer_LexerResult){ .next_lex = lex_start, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(rpeek)), lex_start, source));
  (void)(({ int32_t __tmp = 0; if (((rpeek).tok).kind == token_TokenKind_TOKEN_INT) {   size_t int_start = (rpeek).token_start;
  (void)(({ size_t __tmp = 0; if (int_start == 0) {   (void)((int_start = ((rpeek).next_lex).pos - 1));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer int_lex = (struct lexer_Lexer){ .pos = int_start, .line = (lex_start).line, .col = (lex_start).col };
  struct lexer_LexerResult r_as = (struct lexer_LexerResult){ .next_lex = (rpeek).next_lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r_as)), (rpeek).next_lex, source));
  (void)(({ int32_t __tmp = 0; if (((r_as).tok).kind == token_TokenKind_TOKEN_AS) {   (void)(parser_parse_expr_into(arena, int_lex, source, out));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_parse_expr_into(arena, lex_start, source, out));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_parse_expr_into(arena, lex_start, source, out));
}
void parser_parse_expr_with_leading_int_as_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_start, struct shulang_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_cond_expr_into(arena, lex_start, source, out));
}
int parser_fill_block_const_let_from_res(struct ast_ASTArena * restrict arena, int32_t block_ref, struct parser_OneFuncResult * restrict res, int32_t type_ref) {
  uint8_t * pool = parser_onefunc_result_pool_ptr(res);
  int32_t const_i = 0;
  int32_t nc = ast_pipeline_onefunc_num_consts(pool);
  while (const_i < nc) {
    int32_t cinit_ref = ast_arena_expr_alloc(arena);
    (void)(({ int __tmp = 0; if (cinit_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr ce;
    ce = pipeline_arena_expr_get_copy(arena, cinit_ref);
    (void)(((ce).kind = ast_ExprKind_EXPR_LIT));
    (void)(((ce).resolved_type_ref = type_ref));
    (void)(((ce).line = 0));
    (void)(((ce).col = 0));
    (void)(((ce).int_val = ast_pipeline_onefunc_const_init_val(pool, const_i)));
    (void)(parser_expr_set_common_zeros((&(ce))));
    (void)(ast_arena_expr_set(arena, cinit_ref, ce));
    uint8_t cname_buf[64] = { 0 };
    (void)(ast_pipeline_onefunc_const_name_copy64(pool, const_i, (&((cname_buf)[0]))));
    (void)(({ int __tmp = 0; if (ast_pipeline_block_append_const(arena, block_ref, (&((cname_buf)[0])), ast_pipeline_onefunc_const_name_len(pool, const_i), type_ref, cinit_ref) < 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)((const_i = const_i + 1));
  }
  (void)(((res)->num_consts = nc));
  int32_t let_i = 0;
  int32_t nl = ast_pipeline_onefunc_num_lets(pool);
  while (let_i < nl) {
    int32_t let_decl_ty = type_ref;
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_onefunc_let_type_ref(pool, let_i) != 0) {   (void)((let_decl_ty = ast_pipeline_onefunc_let_type_ref(pool, let_i)));
 } else (__tmp = 0) ; __tmp; }));
    int32_t init_ref = 0;
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_onefunc_let_init_ref(pool, let_i) != 0) {   (void)((init_ref = ast_pipeline_onefunc_let_init_ref(pool, let_i)));
 } else {   (void)((init_ref = ast_arena_expr_alloc(arena)));
  (void)(({ int __tmp = 0; if (init_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr le;
  le = pipeline_arena_expr_get_copy(arena, init_ref);
  (void)(((le).kind = ast_ExprKind_EXPR_LIT));
  (void)(((le).resolved_type_ref = let_decl_ty));
  (void)(((le).line = 0));
  (void)(((le).col = 0));
  (void)(((le).int_val = ast_pipeline_onefunc_let_init_val(pool, let_i)));
  (void)(parser_expr_set_common_zeros((&(le))));
  (void)(ast_arena_expr_set(arena, init_ref, le));
 } ; __tmp; }));
    uint8_t lname_buf[64] = { 0 };
    (void)(ast_pipeline_onefunc_let_name_copy64(pool, let_i, (&((lname_buf)[0]))));
    (void)(({ int __tmp = 0; if (ast_pipeline_block_append_let(arena, block_ref, (&((lname_buf)[0])), ast_pipeline_onefunc_let_name_len(pool, let_i), let_decl_ty, init_ref) < 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)((let_i = let_i + 1));
  }
  (void)(((res)->num_lets = nl));
  return 1;
}
int parser_append_block_lets_from_res(struct ast_ASTArena * restrict arena, int32_t block_ref, struct parser_OneFuncResult * restrict res, int32_t let_base, int32_t type_ref) {
  uint8_t * pool = parser_onefunc_result_pool_ptr(res);
  int32_t src_i = let_base;
  int32_t nl = ast_pipeline_onefunc_num_lets(pool);
  while (src_i < nl) {
    int32_t let_decl_ty = type_ref;
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_onefunc_let_type_ref(pool, src_i) != 0) {   (void)((let_decl_ty = ast_pipeline_onefunc_let_type_ref(pool, src_i)));
 } else (__tmp = 0) ; __tmp; }));
    int32_t init_ref = 0;
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_onefunc_let_init_ref(pool, src_i) != 0) {   (void)((init_ref = ast_pipeline_onefunc_let_init_ref(pool, src_i)));
 } else {   (void)((init_ref = ast_arena_expr_alloc(arena)));
  (void)(({ int __tmp = 0; if (init_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr le;
  le = pipeline_arena_expr_get_copy(arena, init_ref);
  (void)(((le).kind = ast_ExprKind_EXPR_LIT));
  (void)(((le).resolved_type_ref = let_decl_ty));
  (void)(((le).line = 0));
  (void)(((le).col = 0));
  (void)(((le).int_val = ast_pipeline_onefunc_let_init_val(pool, src_i)));
  (void)(parser_expr_set_common_zeros((&(le))));
  (void)(ast_arena_expr_set(arena, init_ref, le));
 } ; __tmp; }));
    uint8_t lname_buf[64] = { 0 };
    (void)(ast_pipeline_onefunc_let_name_copy64(pool, src_i, (&((lname_buf)[0]))));
    (void)(({ int __tmp = 0; if (ast_pipeline_block_append_let(arena, block_ref, (&((lname_buf)[0])), ast_pipeline_onefunc_let_name_len(pool, src_i), let_decl_ty, init_ref) < 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
    (void)((src_i = src_i + 1));
  }
  (void)(((res)->num_lets = nl));
  return 1;
}
int parser_parse_if_stmt_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_at_if, struct shulang_slice_uint8_t * source, int32_t type_ref, int32_t * restrict out_cond, int32_t * restrict out_then, int32_t * restrict out_else, struct lexer_Lexer * restrict lex_out) {
  struct lexer_Lexer lex_cur = lex_at_if;
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IF) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex_cur = (r).next_lex));
  struct parser_ParseExprResult cond_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_cond_expr_into(arena, lex_cur, source, (&(cond_res))));
  (void)(({ int __tmp = 0; if ((!(cond_res).ok)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t cond_ref = (cond_res).expr_ref;
  (void)((lex_cur = (cond_res).next_lex));
  (void)(({ int __tmp = 0; if (parser_advance_past_cond_rparen_into((&(r)), lex_cur, source) == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex_cur = (r).next_lex));
  struct parser_ParseBlockResult then_res = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_block_into(arena, lex_cur, source, type_ref, (&(then_res))));
  (void)(({ int __tmp = 0; if ((!(then_res).ok)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out_cond)[0] = cond_ref));
  (void)(((out_then)[0] = (then_res).block_ref));
  (void)(((out_else)[0] = 0));
  (void)((lex_cur = (then_res).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ELSE) {   (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  __tmp = ({ int __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IF) {   int32_t wrap_ref = ast_arena_block_alloc(arena);
  (void)(({ int __tmp = 0; if (wrap_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ncond = 0;
  int32_t nthen = 0;
  int32_t nelse = 0;
  struct lexer_Lexer lex_after = lex_cur;
  (void)(({ int __tmp = 0; if ((!parser_parse_if_stmt_into(arena, lex_cur, source, type_ref, (&(ncond)), (&(nthen)), (&(nelse)), (&(lex_after))))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (ast_pipeline_block_append_if(arena, wrap_ref, ncond, nthen, nelse) < 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (ast_pipeline_block_append_stmt_order(arena, wrap_ref, 5, 0) < 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out_else)[0] = wrap_ref));
  (void)((lex_cur = lex_after));
 } else (__tmp = ({ int __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)((lex_cur = (r).next_lex));
  struct parser_ParseBlockResult else_res = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_block_into(arena, lex_cur, source, type_ref, (&(else_res))));
  (void)(({ int __tmp = 0; if ((!(else_res).ok)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out_else)[0] = (else_res).block_ref));
  (void)((lex_cur = (else_res).next_lex));
 } else {   return 0;
 } ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(((lex_out)->pos = (lex_cur).pos));
  (void)(((lex_out)->line = (lex_cur).line));
  (void)(((lex_out)->col = (lex_cur).col));
  return 1;
}
void parser_parse_block_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_after_lbrace, struct shulang_slice_uint8_t * source, int32_t type_ref, struct parser_ParseBlockResult * restrict out) {
  size_t scratch_sz = pipeline_sizeof_onefunc_result();
  uint8_t * scratch_raw = std_heap_alloc_zeroed(scratch_sz);
  (void)(({ int32_t __tmp = 0; if (scratch_raw == ((uint8_t *)(0))) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct parser_OneFuncResult * temp = ((struct parser_OneFuncResult *)(scratch_raw));
  (void)(((temp)->ok = 1));
  (void)(((temp)->next_lex = lex_after_lbrace));
  (void)(((temp)->return_var_name_len = 0));
  (void)(((temp)->return_expr_ref = 0));
  (void)(((temp)->num_src_stmt_order = 0));
  (void)(((temp)->num_src_body_expr_stmts = 0));
  (void)(((temp)->func_return_type_ref = 0));
  struct lexer_Lexer lex_cur = lex_after_lbrace;
  (void)(parser_parse_body_lets_into(arena, lex_after_lbrace, source, temp, (&(lex_cur))));
  int32_t block_ref = ast_arena_block_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (block_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block b;
  b = pipeline_arena_block_get_copy(arena, block_ref);
  (void)(((b).num_loops = 0));
  (void)(((b).num_for_loops = 0));
  (void)(((b).num_if_stmts = 0));
  (void)(((b).num_defers = 0));
  (void)(((b).num_labeled_stmts = 0));
  (void)(((b).num_expr_stmts = 0));
  (void)(((b).final_expr_ref = 0));
  (void)(((b).num_stmt_order = 0));
  (void)(ast_arena_block_set(arena, block_ref, b));
  (void)(({ int32_t __tmp = 0; if ((!parser_fill_block_const_let_from_res(arena, block_ref, temp, type_ref))) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((b = ast_arena_block_get(arena, block_ref)));
  int32_t ci = 0;
  while (ci < (b).num_consts) {
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 0, ci) < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)((ci = ci + 1));
  }
  int32_t li = 0;
  while (li < (b).num_lets) {
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 1, li) < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)((li = li + 1));
  }
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex_cur, source));
  while (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LET || ((r).tok).kind == token_TokenKind_TOKEN_CONST) {   int32_t let_base_mid = (b).num_lets;
  (void)(((temp)->num_lets = 0));
  (void)(((temp)->num_consts = 0));
  int32_t kw_back_mid = 3;
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_CONST) {   (void)((kw_back_mid = 5));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_mid_let = (struct lexer_Lexer){ .pos = parser_lexer_pos_before_run(((r).next_lex).pos, kw_back_mid), .line = ((r).tok).line, .col = ((r).tok).col };
  (void)(parser_parse_body_lets_into(arena, lex_mid_let, source, temp, (&(lex_cur))));
  (void)(({ int32_t __tmp = 0; if ((!parser_append_block_lets_from_res(arena, block_ref, temp, let_base_mid, type_ref))) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((b = ast_arena_block_get(arena, block_ref)));
  int32_t pi_mid = let_base_mid;
  while (pi_mid < (b).num_lets) {
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 1, pi_mid) < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)((pi_mid = pi_mid + 1));
  }
  (void)(lexer_next_into((&(r)), lex_cur, source));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RETURN) {   (void)(parser_lex_from_next_into((&(lex_cur)), r));
  struct parser_ParseExprResult ret_val_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cur };
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_parse_expr_into(arena, lex_cur, source, (&(ret_val_res))));
  (void)(({ int32_t __tmp = 0; if ((!(ret_val_res).ok)) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex_cur = (ret_val_res).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ret_ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (ret_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr re;
  re = pipeline_arena_expr_get_copy(arena, ret_ref);
  (void)(((re).kind = ast_ExprKind_EXPR_RETURN));
  (void)(((re).line = 0));
  (void)(((re).col = 0));
  (void)(parser_expr_set_common_zeros((&(re))));
  (void)(({ int32_t __tmp = 0; if ((ret_val_res).ok) {   (void)(((re).unary_operand_ref = (ret_val_res).expr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_arena_expr_set(arena, ret_ref, re));
  int32_t ret_ex_i = ast_pipeline_block_append_expr_stmt(arena, block_ref, ret_ref);
  (void)(({ int32_t __tmp = 0; if (ret_ex_i < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 2, ret_ex_i) < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((b = ast_arena_block_get(arena, block_ref)));
  (void)((lex_cur = (r).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LOOP) {   (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex_cur = (r).next_lex));
  int32_t cond_ref_blk = parser_alloc_true_bool_lit(arena);
  (void)(({ int32_t __tmp = 0; if (cond_ref_blk == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct parser_ParseBlockResult block_res_blk = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_block_into(arena, lex_cur, source, type_ref, (&(block_res_blk))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res_blk).ok)) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t while_idx_blk = ast_pipeline_block_append_while(arena, block_ref, cond_ref_blk, (block_res_blk).block_ref);
  (void)(({ int32_t __tmp = 0; if (while_idx_blk < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 3, while_idx_blk) < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((b = ast_arena_block_get(arena, block_ref)));
  (void)((lex_cur = (block_res_blk).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_WHILE) {   (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex_cur = (r).next_lex));
  struct lexer_Lexer loop_cond_start = lex_cur;
  struct parser_ParseExprResult expr_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = loop_cond_start };
  (void)(parser_parse_cond_expr_into(arena, loop_cond_start, source, (&(expr_res))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res).ok)) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t cond_ref = (expr_res).expr_ref;
  (void)((lex_cur = (expr_res).next_lex));
  (void)(({ int32_t __tmp = 0; if (parser_advance_past_cond_rparen_into((&(r)), lex_cur, source) == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex_cur = (r).next_lex));
  struct parser_ParseBlockResult block_res = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_block_into(arena, lex_cur, source, type_ref, (&(block_res))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res).ok)) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t while_idx = ast_pipeline_block_append_while(arena, block_ref, cond_ref, (block_res).block_ref);
  (void)(({ int32_t __tmp = 0; if (while_idx < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 3, while_idx) < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((b = ast_arena_block_get(arena, block_ref)));
  (void)((lex_cur = (block_res).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_FOR) {   (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex_cur = (r).next_lex));
  int32_t init_ref = 0;
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   struct parser_ParseExprResult expr_res_fi = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_expr_into(arena, lex_cur, source, (&(expr_res_fi))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res_fi).ok)) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((init_ref = (expr_res_fi).expr_ref));
  (void)((lex_cur = (expr_res_fi).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex_cur = (r).next_lex));
  int32_t cond_ref = 0;
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   struct parser_ParseExprResult expr_res_fc = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_expr_into(arena, lex_cur, source, (&(expr_res_fc))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res_fc).ok)) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((cond_ref = (expr_res_fc).expr_ref));
  (void)((lex_cur = (expr_res_fc).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex_cur = (r).next_lex));
  int32_t step_ref = 0;
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   struct parser_ParseExprResult expr_res_fs = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_expr_into(arena, lex_cur, source, (&(expr_res_fs))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res_fs).ok)) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((step_ref = (expr_res_fs).expr_ref));
  (void)((lex_cur = (expr_res_fs).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex_cur = (r).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex_cur = (r).next_lex));
  struct parser_ParseBlockResult block_res = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_block_into(arena, lex_cur, source, type_ref, (&(block_res))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res).ok)) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (cond_ref == 0) {   int32_t cond_expr_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (cond_expr_ref != 0) {   struct ast_Expr ce;
  ce = pipeline_arena_expr_get_copy(arena, cond_expr_ref);
  (void)(((ce).kind = ast_ExprKind_EXPR_BOOL_LIT));
  (void)(((ce).int_val = 1));
  (void)(((ce).line = 0));
  (void)(((ce).col = 0));
  (void)(parser_expr_set_common_zeros((&(ce))));
  (void)(ast_arena_expr_set(arena, cond_expr_ref, ce));
  (void)((cond_ref = cond_expr_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t for_idx = ast_pipeline_block_append_for(arena, block_ref, init_ref, cond_ref, step_ref, (block_res).block_ref);
  (void)(({ int32_t __tmp = 0; if (for_idx < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 4, for_idx) < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((b = ast_arena_block_get(arena, block_ref)));
  (void)((lex_cur = (block_res).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IF) {   struct lexer_Lexer if_start = parser_lex_at_token_from_result(r);
  int32_t if_cond = 0;
  int32_t if_then = 0;
  int32_t if_else = 0;
  (void)(({ int32_t __tmp = 0; if ((!parser_parse_if_stmt_into(arena, if_start, source, type_ref, (&(if_cond)), (&(if_then)), (&(if_else)), (&(lex_cur))))) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t if_pool_i = ast_pipeline_block_append_if(arena, block_ref, if_cond, if_then, if_else);
  (void)(({ int32_t __tmp = 0; if (if_pool_i < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 5, if_pool_i) < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((b = ast_arena_block_get(arena, block_ref)));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    struct lexer_Lexer stmt_start = parser_lex_at_token_from_result(r);
    struct parser_ParseExprResult expr_stmt_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = stmt_start };
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_INT) {   (void)(parser_parse_cond_expr_into(arena, stmt_start, source, (&(expr_stmt_res))));
 } else {   (void)(parser_parse_expr_into(arena, stmt_start, source, (&(expr_stmt_res))));
 } ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!(expr_stmt_res).ok)) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)((lex_cur = (expr_stmt_res).next_lex));
    (void)(({ int32_t __tmp = 0; if (parser_advance_past_stmt_semicolon_into((&(r)), lex_cur, source) == 0) {   (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(((b).final_expr_ref = (expr_stmt_res).expr_ref));
  break;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_result_ptr_into((&(lex_cur)), (&(r))));
  struct lexer_LexerResult after_semi_blk = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(after_semi_blk)), lex_cur, source));
  (void)((r = after_semi_blk));
 } else (__tmp = 0) ; __tmp; }));
    int32_t ex_pool_i = ast_pipeline_block_append_expr_stmt(arena, block_ref, (expr_stmt_res).expr_ref);
    (void)(({ int32_t __tmp = 0; if (ex_pool_i < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 2, ex_pool_i) < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)((b = ast_arena_block_get(arena, block_ref)));
    continue;
  }
  (void)(ast_arena_block_set(arena, block_ref, b));
  (void)(((out)->ok = 1));
  (void)(((out)->block_ref = block_ref));
  (void)(((out)->next_lex = (r).next_lex));
}
struct parser_ParseResult parser_parse(struct shulang_slice_uint8_t * source) {
  size_t arena_heap_bytes = pipeline_sizeof_arena();
  struct lexer_Lexer lex = lexer_init();
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct parser_ParseResult __tmp = (struct parser_ParseResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   return (struct parser_ParseResult){ .ok = 0, .return_val = 0 };
 } else (__tmp = (struct parser_ParseResult){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct parser_ParseResult __tmp = (struct parser_ParseResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return (struct parser_ParseResult){ .ok = 0, .return_val = 0 };
 } else (__tmp = (struct parser_ParseResult){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct parser_ParseResult __tmp = (struct parser_ParseResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   return (struct parser_ParseResult){ .ok = 0, .return_val = 0 };
 } else (__tmp = (struct parser_ParseResult){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct parser_ParseResult __tmp = (struct parser_ParseResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   return (struct parser_ParseResult){ .ok = 0, .return_val = 0 };
 } else (__tmp = (struct parser_ParseResult){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct parser_ParseResult __tmp = (struct parser_ParseResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   return (struct parser_ParseResult){ .ok = 0, .return_val = 0 };
 } else (__tmp = (struct parser_ParseResult){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct parser_ParseResult __tmp = (struct parser_ParseResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_I32) {   return (struct parser_ParseResult){ .ok = 0, .return_val = 0 };
 } else (__tmp = (struct parser_ParseResult){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct parser_ParseResult __tmp = (struct parser_ParseResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return (struct parser_ParseResult){ .ok = 0, .return_val = 0 };
 } else (__tmp = (struct parser_ParseResult){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct parser_ParseResult __tmp = (struct parser_ParseResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_RETURN) {   return (struct parser_ParseResult){ .ok = 0, .return_val = 0 };
 } else (__tmp = (struct parser_ParseResult){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  struct lexer_Lexer lex_at_expr_start = lex;
  (void)(lexer_next_into((&(r)), lex, source));
  int32_t ret_val = 0;
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_INT) {   (void)((ret_val = ((r).tok).int_val));
  (void)(parser_lex_from_next_into((&(lex)), r));
 } else {   uint8_t * raw_arena = std_heap_alloc_zeroed(arena_heap_bytes);
  (void)(({ struct parser_ParseResult __tmp = (struct parser_ParseResult){0}; if (raw_arena == ((uint8_t *)(0))) {   return (struct parser_ParseResult){ .ok = 0, .return_val = 0 };
 } else (__tmp = (struct parser_ParseResult){0}) ; __tmp; }));
  struct ast_ASTArena * heap_arena = ((struct ast_ASTArena *)(raw_arena));
  (void)(ast_arena_init(heap_arena));
  struct parser_ParseExprResult expr_out = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex };
  (void)(parser_parse_expr_into(heap_arena, lex_at_expr_start, source, (&(expr_out))));
  (void)(({ struct parser_ParseResult __tmp = (struct parser_ParseResult){0}; if ((!(expr_out).ok) || (expr_out).expr_ref <= 0) {   (void)(std_heap_free(raw_arena));
  return (struct parser_ParseResult){ .ok = 0, .return_val = 0 };
 } else (__tmp = (struct parser_ParseResult){0}) ; __tmp; }));
  struct ast_Expr e_read;
  e_read = pipeline_arena_expr_get_copy(heap_arena, (expr_out).expr_ref);
  (void)(({ int32_t __tmp = 0; if ((e_read).const_folded_valid != 0) {   (void)((ret_val = (e_read).const_folded_val));
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (expr_out).next_lex));
  (void)(std_heap_free(raw_arena));
 } ; __tmp; }));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct parser_ParseResult __tmp = (struct parser_ParseResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   return (struct parser_ParseResult){ .ok = 0, .return_val = 0 };
 } else (__tmp = (struct parser_ParseResult){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct parser_ParseResult __tmp = (struct parser_ParseResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   return (struct parser_ParseResult){ .ok = 0, .return_val = 0 };
 } else (__tmp = (struct parser_ParseResult){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct parser_ParseResult __tmp = (struct parser_ParseResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_EOF) {   return (struct parser_ParseResult){ .ok = 0, .return_val = 0 };
 } else (__tmp = (struct parser_ParseResult){0}) ; __tmp; }));
  return (struct parser_ParseResult){ .ok = 1, .return_val = ret_val };
}
int32_t parser_first_token_kind(struct shulang_slice_uint8_t * source) {
  struct lexer_Lexer lex = lexer_init();
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  return ((r).tok).kind;
}
int32_t parser_diag_first_ident_len(struct shulang_slice_uint8_t * source) {
  struct lexer_Lexer lex = lexer_init();
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   return (-2);
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return (-3);
 } else (__tmp = 0) ; __tmp; }));
  return ((r).tok).ident_len;
}
void parser_diag_skip_let_const_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  (void)(lexer_next_into(out, lex, source));
  while (((out)->tok).kind == token_TokenKind_TOKEN_LET || ((out)->tok).kind == token_TokenKind_TOKEN_CONST) {
    (void)(parser_lex_from_result_ptr_into((&(lex)), out));
    (void)(lexer_next_into(out, lex, source));
    (void)(({ int32_t __tmp = 0; if (((out)->tok).kind != token_TokenKind_TOKEN_IDENT) {   return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_result_ptr_into((&(lex)), out));
    (void)(lexer_next_into(out, lex, source));
    (void)(({ int32_t __tmp = 0; if (((out)->tok).kind != token_TokenKind_TOKEN_COLON) {   return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_result_ptr_into((&(lex)), out));
    (void)(lexer_next_into(out, lex, source));
    (void)(({ int32_t __tmp = 0; if (((out)->tok).kind == token_TokenKind_TOKEN_STAR) {   (void)(parser_lex_from_result_ptr_into((&(lex)), out));
  (void)(lexer_next_into(out, lex, source));
  (void)(({ int32_t __tmp = 0; if (((out)->tok).kind != token_TokenKind_TOKEN_IDENT) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), out));
  (void)(lexer_next_into(out, lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((out)->tok).kind == token_TokenKind_TOKEN_I32 || ((out)->tok).kind == token_TokenKind_TOKEN_BOOL || ((out)->tok).kind == token_TokenKind_TOKEN_I64 || ((out)->tok).kind == token_TokenKind_TOKEN_VOID || ((out)->tok).kind == token_TokenKind_TOKEN_IDENT) {   (void)(parser_lex_from_result_ptr_into((&(lex)), out));
  (void)(lexer_next_into(out, lex, source));
 } else {   return;
 } ; __tmp; })) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((out)->tok).kind != token_TokenKind_TOKEN_ASSIGN) {   return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_result_ptr_into((&(lex)), out));
    (void)(lexer_next_into(out, lex, source));
    while (((out)->tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((out)->tok).kind != token_TokenKind_TOKEN_EOF) {
      (void)(parser_lex_from_result_ptr_into((&(lex)), out));
      (void)(lexer_next_into(out, lex, source));
    }
    (void)(({ int32_t __tmp = 0; if (((out)->tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_result_ptr_into((&(lex)), out));
    (void)(lexer_next_into(out, lex, source));
  }
}
struct lexer_LexerResult parser_diag_skip_let_const(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(parser_diag_skip_let_const_into((&(r)), lex, source));
  return r;
}
struct lexer_LexerResult parser_diag_skip_let_const_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  while (((r).tok).kind == token_TokenKind_TOKEN_LET || ((r).tok).kind == token_TokenKind_TOKEN_CONST) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)((r = lexer_next_buf(lex, data, len)));
    (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return r;
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)((r = lexer_next_buf(lex, data, len)));
    (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   return r;
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)((r = lexer_next_buf(lex, data, len)));
    (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (((r).tok).kind == token_TokenKind_TOKEN_STAR) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return r;
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
 } else (__tmp = ({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (((r).tok).kind == token_TokenKind_TOKEN_I32 || ((r).tok).kind == token_TokenKind_TOKEN_BOOL || ((r).tok).kind == token_TokenKind_TOKEN_I64 || ((r).tok).kind == token_TokenKind_TOKEN_VOID || ((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
 } else {   return r;
 } ; __tmp; })) ; __tmp; }));
    (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_ASSIGN) {   return r;
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)((r = lexer_next_buf(lex, data, len)));
    while (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
      (void)(parser_lex_from_next_into((&(lex)), r));
      (void)((r = lexer_next_buf(lex, data, len)));
    }
    (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   return r;
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)((r = lexer_next_buf(lex, data, len)));
  }
  return r;
}
void parser_body_skip_let_const_then_if_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  (void)(parser_diag_skip_let_const_into(out, lex, source));
  while (((out)->tok).kind == token_TokenKind_TOKEN_IF) {
    (void)(parser_skip_one_if_statement_into(out, (out)->next_lex, source));
  }
}
void parser_parse_body_lets_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_OneFuncResult * restrict out, struct lexer_Lexer * restrict lex_out) {
  uint8_t * pool = parser_onefunc_result_pool_ptr(out);
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LET && ((r).tok).kind != token_TokenKind_TOKEN_CONST) {   (void)((lex = parser_lex_at_token_from_result(r)));
  (void)(((lex_out)->pos = (lex).pos));
  (void)(((lex_out)->line = (lex).line));
  (void)(((lex_out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  while (((r).tok).kind == token_TokenKind_TOKEN_LET || ((r).tok).kind == token_TokenKind_TOKEN_CONST) {
    int is_let = ((r).tok).kind == token_TokenKind_TOKEN_LET;
    int32_t let_init_val = 0;
    int32_t let_init_ref = 0;
    int32_t let_ty_ref = 0;
    (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((lex_out)->pos = (lex).pos));
  (void)(((lex_out)->line = (lex).line));
  (void)(((lex_out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t name_len = ((r).tok).ident_len;
    (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   (void)(((lex_out)->pos = (lex).pos));
  (void)(((lex_out)->line = (lex).line));
  (void)(((lex_out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    size_t name_start = (r).token_start;
    uint8_t name_row[64] = { 0 };
    int32_t ni = 0;
    while (ni < name_len && ni < 64) {
      (void)(({ uint8_t __tmp = 0; if (name_start + ni < (source)->length) {   (void)(((ni < 0 || (ni) >= 64 ? (shulang_panic_(1, 0), 0) : ((name_row)[ni] = (name_start + ni < 0 || (size_t)(name_start + ni) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[name_start + ni]), 0))));
 } else (__tmp = 0) ; __tmp; }));
      (void)((ni = ni + 1));
    }
    int32_t zi = ni;
    while (zi < 64) {
      (void)(((zi < 0 || (zi) >= 64 ? (shulang_panic_(1, 0), 0) : ((name_row)[zi] = 0, 0))));
      (void)((zi = zi + 1));
    }
    (void)(({ int32_t __tmp = 0; if (is_let) {  } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(((lex_out)->pos = (lex).pos));
  (void)(((lex_out)->line = (lex).line));
  (void)(((lex_out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
    (void)((let_ty_ref = parser_parse_type_ref_for_arena_into(arena, lex, source, (&(lex)))));
    (void)(({ int32_t __tmp = 0; if (let_ty_ref == 0) {   (void)(((lex_out)->pos = (lex).pos));
  (void)(((lex_out)->line = (lex).line));
  (void)(((lex_out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_ASSIGN) {   (void)(((lex_out)->pos = (lex).pos));
  (void)(((lex_out)->line = (lex).line));
  (void)(((lex_out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (is_let) {   (void)((let_init_ref = 0));
  (void)((let_init_val = 0));
 } else (__tmp = 0) ; __tmp; }));
    int cast_init_semi_done = 0;
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACKET) {   (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
  int32_t arr_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (arr_ref != 0) {   struct ast_Expr ae0;
  ae0 = pipeline_arena_expr_get_copy(arena, arr_ref);
  (void)(((ae0).kind = ast_ExprKind_EXPR_ARRAY_LIT));
  (void)(((ae0).resolved_type_ref = 0));
  (void)(((ae0).line = 0));
  (void)(((ae0).col = 0));
  (void)(parser_expr_set_common_zeros((&(ae0))));
  (void)(ast_arena_expr_set(arena, arr_ref, ae0));
  while (((r).tok).kind != token_TokenKind_TOKEN_RBRACKET) {
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_INT) {   int32_t er = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (er != 0) {   struct ast_Expr ee;
  ee = pipeline_arena_expr_get_copy(arena, er);
  (void)(((ee).kind = ast_ExprKind_EXPR_LIT));
  (void)(((ee).resolved_type_ref = 0));
  (void)(((ee).line = 0));
  (void)(((ee).col = 0));
  (void)(((ee).int_val = ((r).tok).int_val));
  (void)(parser_expr_set_common_zeros((&(ee))));
  (void)(ast_arena_expr_set(arena, er, ee));
  (void)(pipeline_expr_append_array_lit_elem(arena, arr_ref, er));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_COMMA) {   (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
 } else {   break;
 } ; __tmp; })) ; __tmp; }));
  }
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACKET) {   (void)(({ int32_t __tmp = 0; if (is_let) {   (void)((let_init_ref = arr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   size_t rhs_ident_start = (r).token_start;
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  struct lexer_Lexer expr_lex = (struct lexer_Lexer){ .pos = rhs_ident_start, .line = ((r).tok).line, .col = ((r).tok).col };
  struct parser_ParseExprResult expr_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = expr_lex };
  (void)(parser_parse_expr_into(arena, expr_lex, source, (&(expr_res))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res).ok)) {   (void)(((lex_out)->pos = (lex).pos));
  (void)(((lex_out)->line = (lex).line));
  (void)(((lex_out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (is_let) {   (void)((let_init_ref = (expr_res).expr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (expr_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_TRUE || ((r).tok).kind == token_TokenKind_TOKEN_FALSE) {   (void)(({ int32_t __tmp = 0; if (is_let) {   int32_t bool_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (bool_ref != 0) {   struct ast_Expr be;
  be = pipeline_arena_expr_get_copy(arena, bool_ref);
  (void)(((be).kind = ast_ExprKind_EXPR_BOOL_LIT));
  (void)(((be).resolved_type_ref = 0));
  (void)(((be).line = 0));
  (void)(((be).col = 0));
  (void)(((be).int_val = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_TRUE) {   __tmp = 1;
 } else {   __tmp = 0;
 } ; __tmp; })));
  (void)(ast_expr_init_match_enum((&(be))));
  (void)(((be).binop_left_ref = 0));
  (void)(((be).binop_right_ref = 0));
  (void)(((be).unary_operand_ref = 0));
  (void)(((be).if_cond_ref = 0));
  (void)(((be).if_then_ref = 0));
  (void)(((be).if_else_ref = 0));
  (void)(((be).block_ref = 0));
  (void)(((be).field_access_base_ref = 0));
  (void)(((be).field_access_field_len = 0));
  (void)(((be).field_access_is_enum_variant = 0));
  (void)(((be).field_access_offset = 0));
  (void)(((be).index_base_ref = 0));
  (void)(((be).index_index_ref = 0));
  (void)(((be).index_base_is_slice = 0));
  (void)(((be).call_callee_ref = 0));
  (void)(((be).call_num_args = 0));
  (void)(((be).method_call_base_ref = 0));
  (void)(((be).method_call_name_len = 0));
  (void)(((be).method_call_num_args = 0));
  (void)(((be).const_folded_val = 0));
  (void)(((be).const_folded_valid = 0));
  (void)(((be).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, bool_ref, be));
  (void)((let_init_ref = bool_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_INT) {   int32_t int_val_saved = ((r).tok).int_val;
  size_t int_start = (r).token_start;
  (void)(({ size_t __tmp = 0; if (int_start == 0) {   (void)((int_start = ((r).next_lex).pos - 1));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer int_lex = (struct lexer_Lexer){ .pos = int_start, .line = (lex).line, .col = (lex).col };
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
  int int_init_plain = ((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON || ((r).tok).kind == token_TokenKind_TOKEN_LET || ((r).tok).kind == token_TokenKind_TOKEN_CONST || ((r).tok).kind == token_TokenKind_TOKEN_RETURN || ((r).tok).kind == token_TokenKind_TOKEN_IF || ((r).tok).kind == token_TokenKind_TOKEN_WHILE || ((r).tok).kind == token_TokenKind_TOKEN_FOR || ((r).tok).kind == token_TokenKind_TOKEN_RBRACE;
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_AS || (!int_init_plain)) {   struct parser_ParseExprResult expr_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = int_lex };
  (void)(parser_parse_expr_into(arena, int_lex, source, (&(expr_res))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res).ok)) {   (void)(((lex_out)->pos = (lex).pos));
  (void)(((lex_out)->line = (lex).line));
  (void)(((lex_out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (is_let) {   (void)((let_init_ref = (expr_res).expr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (expr_res).next_lex));
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_AS) {   (void)(({ int32_t __tmp = 0; if (parser_advance_past_stmt_semicolon_into((&(r)), lex, source) == 0) {   (void)(((lex_out)->pos = (lex).pos));
  (void)(((lex_out)->line = (lex).line));
  (void)(((lex_out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(((lex).pos = ((r).next_lex).pos));
  (void)(((lex).line = ((r).next_lex).line));
  (void)(((lex).col = ((r).next_lex).col));
 } else {   (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
 } ; __tmp; }));
  (void)((cast_init_semi_done = 1));
 } else {   (void)(lexer_next_into((&(r)), lex, source));
 } ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (is_let) {   (void)((let_init_val = int_val_saved));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_MINUS || ((r).tok).kind == token_TokenKind_TOKEN_BANG || ((r).tok).kind == token_TokenKind_TOKEN_LPAREN || ((r).tok).kind == token_TokenKind_TOKEN_TILDE) {   size_t rhs_unary_start = (r).token_start;
  (void)(({ size_t __tmp = 0; if (rhs_unary_start == 0) {   (void)((rhs_unary_start = (lex).pos));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer unary_lex = (struct lexer_Lexer){ .pos = rhs_unary_start, .line = ((r).tok).line, .col = ((r).tok).col };
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  struct parser_ParseExprResult unary_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = unary_lex };
  (void)(parser_parse_expr_into(arena, unary_lex, source, (&(unary_res))));
  (void)(({ int32_t __tmp = 0; if ((!(unary_res).ok)) {   (void)(((lex_out)->pos = (lex).pos));
  (void)(((lex_out)->line = (lex).line));
  (void)(((lex_out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (is_let) {   (void)((let_init_ref = (unary_res).expr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (unary_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!cast_init_semi_done)) {   __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  struct lexer_LexerResult after_semi = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(after_semi)), lex, source));
  __tmp = ({ int32_t __tmp = 0; if (((after_semi).tok).kind == token_TokenKind_TOKEN_RETURN || ((after_semi).tok).kind == token_TokenKind_TOKEN_IF || ((after_semi).tok).kind == token_TokenKind_TOKEN_WHILE || ((after_semi).tok).kind == token_TokenKind_TOKEN_FOR || ((after_semi).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)((lex = parser_lex_at_token_from_result(after_semi)));
  (void)((r = after_semi));
 } else {   (void)(parser_lex_from_result_ptr_into((&(lex)), (&(after_semi))));
  (void)((r = after_semi));
 } ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LET && ((r).tok).kind != token_TokenKind_TOKEN_CONST && ((r).tok).kind != token_TokenKind_TOKEN_RETURN && ((r).tok).kind != token_TokenKind_TOKEN_IF && ((r).tok).kind != token_TokenKind_TOKEN_WHILE && ((r).tok).kind != token_TokenKind_TOKEN_FOR && ((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(((lex_out)->pos = (lex).pos));
  (void)(((lex_out)->line = (lex).line));
  (void)(((lex_out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (is_let) {   (void)(({ int32_t __tmp = 0; if (ast_pipeline_onefunc_append_let(pool, (&((name_row)[0])), name_len, let_init_val, let_init_ref, let_ty_ref) < 0) {   (void)(((lex_out)->pos = (lex).pos));
  (void)(((lex_out)->line = (lex).line));
  (void)(((lex_out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out)->num_lets = ast_pipeline_onefunc_num_lets(pool)));
 } else (__tmp = 0) ; __tmp; }));
  }
  (void)(((lex_out)->pos = (lex).pos));
  (void)(((lex_out)->line = (lex).line));
  (void)(((lex_out)->col = (lex).col));
}
struct lexer_LexerResult parser_body_skip_let_const_then_if(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(parser_body_skip_let_const_then_if_into((&(r)), lex, source));
  return r;
}
struct lexer_LexerResult parser_body_skip_let_const_then_if_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = parser_diag_skip_let_const_buf(lex, data, len);
  while (((r).tok).kind == token_TokenKind_TOKEN_IF) {
    (void)((r = parser_skip_one_if_statement_buf((r).next_lex, data, len)));
  }
  return r;
}
struct lexer_Lexer parser_skip_balanced_parens(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  int32_t depth = 1;
  while (depth > 0) {
    struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_LPAREN) {   (void)((depth = depth + 1));
 } else (__tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_RPAREN) {   (void)((depth = depth - 1));
  __tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (depth == 0) {   return (r).next_lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; })) ; __tmp; }));
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
  }
  return lex;
}
void parser_skip_balanced_parens_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  int32_t depth = 1;
  while (depth > 0) {
    struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LPAREN) {   (void)((depth = depth + 1));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RPAREN) {   (void)((depth = depth - 1));
  __tmp = ({ int32_t __tmp = 0; if (depth == 0) {   (void)(((out)->pos = ((r).next_lex).pos));
  (void)(((out)->line = ((r).next_lex).line));
  (void)(((out)->col = ((r).next_lex).col));
  return;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
  }
  (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
}
void parser_skip_balanced_parens_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  int32_t depth = 1;
  while (depth > 0) {
    struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LPAREN) {   (void)((depth = depth + 1));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RPAREN) {   (void)((depth = depth - 1));
  __tmp = ({ int32_t __tmp = 0; if (depth == 0) {   (void)(((out)->pos = ((r).next_lex).pos));
  (void)(((out)->line = ((r).next_lex).line));
  (void)(((out)->col = ((r).next_lex).col));
  return;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
  }
  (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
}
struct lexer_Lexer parser_skip_balanced_parens_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  int32_t depth = 1;
  while (depth > 0) {
    struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_LPAREN) {   (void)((depth = depth + 1));
 } else (__tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_RPAREN) {   (void)((depth = depth - 1));
  __tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (depth == 0) {   return (r).next_lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; })) ; __tmp; }));
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
  }
  return lex;
}
struct lexer_Lexer parser_skip_balanced_braces(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  int32_t depth = 1;
  while (depth > 0) {
    struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)((depth = depth + 1));
 } else (__tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)((depth = depth - 1));
  __tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (depth == 0) {   return (r).next_lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; })) ; __tmp; }));
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
  }
  return lex;
}
void parser_skip_balanced_braces_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  int32_t depth = 1;
  while (depth > 0) {
    struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)((depth = depth + 1));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)((depth = depth - 1));
  __tmp = ({ int32_t __tmp = 0; if (depth == 0) {   (void)(((out)->pos = ((r).next_lex).pos));
  (void)(((out)->line = ((r).next_lex).line));
  (void)(((out)->col = ((r).next_lex).col));
  return;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
  }
  (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
}
void parser_skip_balanced_braces_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  int32_t depth = 1;
  while (depth > 0) {
    struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)((depth = depth + 1));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)((depth = depth - 1));
  __tmp = ({ int32_t __tmp = 0; if (depth == 0) {   (void)(((out)->pos = ((r).next_lex).pos));
  (void)(((out)->line = ((r).next_lex).line));
  (void)(((out)->col = ((r).next_lex).col));
  return;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
  }
  (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
}
struct lexer_Lexer parser_skip_balanced_braces_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  int32_t depth = 1;
  while (depth > 0) {
    struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)((depth = depth + 1));
 } else (__tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)((depth = depth - 1));
  __tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (depth == 0) {   return (r).next_lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; })) ; __tmp; }));
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
  }
  return lex;
}
void parser_skip_one_function_full_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_parens_into((&(lex)), (r).next_lex, source));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  while (((r).tok).kind != token_TokenKind_TOKEN_LBRACE && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
  }
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_braces_into(out, (r).next_lex, source));
}
struct lexer_Lexer parser_skip_one_function_full(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_parens((r).next_lex, source)));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  while (((r).tok).kind != token_TokenKind_TOKEN_LBRACE && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
  }
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_braces((r).next_lex, source)));
  return lex;
}
void parser_skip_one_function_full_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_parens_into_buf((&(lex)), (r).next_lex, data, len));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  while (((r).tok).kind != token_TokenKind_TOKEN_LBRACE && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)((r = lexer_next_buf(lex, data, len)));
  }
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_braces_into_buf(out, (r).next_lex, data, len));
}
struct lexer_Lexer parser_skip_one_function_full_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_parens_buf((r).next_lex, data, len)));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  while (((r).tok).kind != token_TokenKind_TOKEN_LBRACE && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)((r = lexer_next_buf(lex, data, len)));
  }
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_braces_buf((r).next_lex, data, len)));
  return lex;
}
struct lexer_LexerResult parser_skip_one_if_core(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   return r;
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_parens((r).next_lex, source)));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)((lex = parser_skip_balanced_braces((r).next_lex, source)));
  (void)(lexer_next_into((&(r)), lex, source));
 } else {   while (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
  }
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  return r;
}
struct lexer_LexerResult parser_skip_one_if_statement(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(parser_skip_one_if_core_into((&(r)), lex, source));
  while (((r).tok).kind == token_TokenKind_TOKEN_ELSE) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IF) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_skip_one_if_core_into((&(r)), lex, source));
 } else {   __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)((lex = parser_skip_balanced_braces((r).next_lex, source)));
  (void)(lexer_next_into((&(r)), lex, source));
 } else {   while (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
  }
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; });
 } ; __tmp; }));
  }
  return r;
}
void parser_skip_one_if_statement_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  (void)(parser_skip_one_if_core_into(out, lex, source));
  while (((out)->tok).kind == token_TokenKind_TOKEN_ELSE) {
    (void)(parser_lex_from_next_into((&(lex)), (*(out))));
    (void)(lexer_next_into(out, lex, source));
    (void)(({ int32_t __tmp = 0; if (((out)->tok).kind == token_TokenKind_TOKEN_IF) {   (void)(parser_lex_from_next_into((&(lex)), (*(out))));
  (void)(parser_skip_one_if_core_into(out, lex, source));
 } else {   __tmp = ({ int32_t __tmp = 0; if (((out)->tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)(parser_skip_balanced_braces_into((&(lex)), (out)->next_lex, source));
  (void)(lexer_next_into(out, lex, source));
 } else {   while (((out)->tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((out)->tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), (*(out))));
    (void)(lexer_next_into(out, lex, source));
  }
  __tmp = ({ int32_t __tmp = 0; if (((out)->tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), (*(out))));
  (void)(lexer_next_into(out, lex, source));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; });
 } ; __tmp; }));
  }
}
void parser_skip_one_if_core_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  (void)(lexer_next_into(out, lex, source));
  (void)(({ int32_t __tmp = 0; if (((out)->tok).kind != token_TokenKind_TOKEN_LPAREN) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_parens_into((&(lex)), (out)->next_lex, source));
  (void)(lexer_next_into(out, lex, source));
  (void)(({ int32_t __tmp = 0; if (((out)->tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)(parser_skip_balanced_braces_into((&(lex)), (out)->next_lex, source));
  (void)(lexer_next_into(out, lex, source));
 } else {   while (((out)->tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((out)->tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), (*(out))));
    (void)(lexer_next_into(out, lex, source));
  }
  __tmp = ({ int32_t __tmp = 0; if (((out)->tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), (*(out))));
  (void)(lexer_next_into(out, lex, source));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
}
struct lexer_LexerResult parser_skip_one_if_core_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ struct lexer_LexerResult __tmp = (struct lexer_LexerResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   return r;
 } else (__tmp = (struct lexer_LexerResult){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_parens_buf((r).next_lex, data, len)));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)((lex = parser_skip_balanced_braces_buf((r).next_lex, data, len)));
  (void)((r = lexer_next_buf(lex, data, len)));
 } else {   while (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)((r = lexer_next_buf(lex, data, len)));
  }
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  return r;
}
struct lexer_LexerResult parser_skip_one_if_statement_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = parser_skip_one_if_core_buf(lex, data, len);
  while (((r).tok).kind == token_TokenKind_TOKEN_ELSE) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)((r = lexer_next_buf(lex, data, len)));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IF) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = parser_skip_one_if_core_buf(lex, data, len)));
 } else {   __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)((lex = parser_skip_balanced_braces_buf((r).next_lex, data, len)));
  (void)((r = lexer_next_buf(lex, data, len)));
 } else {   while (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)((r = lexer_next_buf(lex, data, len)));
  }
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; });
 } ; __tmp; }));
  }
  return r;
}
struct lexer_Lexer parser_diag_lex_after_imports(struct shulang_slice_uint8_t * source) {
  struct lexer_Lexer lex = lexer_init();
  return parser_skip_imports(lex, source);
}
struct lexer_LexerResult parser_diag_after_imports_then_structs(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  while (((r).tok).kind == token_TokenKind_TOKEN_STRUCT) {
    (void)((lex = parser_skip_one_struct(lex, source)));
    (void)(lexer_next_into((&(r)), lex, source));
  }
  return r;
}
int32_t parser_diag_fail_at_token_kind(struct shulang_slice_uint8_t * source) {
  struct lexer_Lexer lex = parser_diag_lex_after_imports(source);
  struct lexer_LexerResult r = parser_diag_after_imports_then_structs(lex, source);
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).ident_len <= 0 || ((r).tok).ident_len > 63) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RPAREN) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else {   while (((r).tok).kind == token_TokenKind_TOKEN_IDENT) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_I32 || ((r).tok).kind == token_TokenKind_TOKEN_I64 || ((r).tok).kind == token_TokenKind_TOKEN_BOOL || ((r).tok).kind == token_TokenKind_TOKEN_U8 || ((r).tok).kind == token_TokenKind_TOKEN_U32 || ((r).tok).kind == token_TokenKind_TOKEN_U64 || ((r).tok).kind == token_TokenKind_TOKEN_USIZE || ((r).tok).kind == token_TokenKind_TOKEN_VOID || ((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ enum token_TokenKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STAR) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ enum token_TokenKind __tmp = 0; if ((!parser_is_pointee_type_token(((r).tok).kind))) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ enum token_TokenKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACKET) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_INT) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACKET) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_U8) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else {   return ((r).tok).kind;
 } ; __tmp; })) ; __tmp; })) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_COMMA) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  }
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } ; __tmp; }));
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_I32 || ((r).tok).kind == token_TokenKind_TOKEN_I64 || ((r).tok).kind == token_TokenKind_TOKEN_BOOL || ((r).tok).kind == token_TokenKind_TOKEN_U8 || ((r).tok).kind == token_TokenKind_TOKEN_U32 || ((r).tok).kind == token_TokenKind_TOKEN_U64 || ((r).tok).kind == token_TokenKind_TOKEN_USIZE || ((r).tok).kind == token_TokenKind_TOKEN_VOID || ((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ enum token_TokenKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STAR) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ enum token_TokenKind __tmp = 0; if ((!parser_is_pointee_type_token(((r).tok).kind))) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else {   return ((r).tok).kind;
 } ; __tmp; })) ; __tmp; }));
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_body_skip_let_const_then_if_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_INT) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RETURN) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_INT) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE && ((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ enum token_TokenKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  __tmp = ({ enum token_TokenKind __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   return ((r).tok).kind;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
 } else (__tmp = 0) ; __tmp; }));
  return ((r).tok).kind;
}
void parser_copy_slice_to_name64(struct shulang_slice_uint8_t * source, size_t start, int32_t nlen, uint8_t * restrict out) {
  int32_t i = 0;
  while (i < nlen) {
    (void)(({ uint8_t __tmp = 0; if (start + ((size_t)(i)) < (source)->length) {   (void)(((out)[i] = (start + ((size_t)(i)) < 0 || (size_t)(start + ((size_t)(i))) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[start + ((size_t)(i))])));
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
}
void parser_copy_slice_to_name64_at_end(struct shulang_slice_uint8_t * source, size_t end_pos, int32_t nlen, uint8_t * restrict out) {
  size_t start = end_pos - ((size_t)(nlen));
  (void)(parser_copy_slice_to_name64(source, start, nlen, out));
}
void parser_copy_slice_to_param32(struct shulang_slice_uint8_t * source, size_t start, int32_t nlen, uint8_t * restrict out) {
  int32_t i = 0;
  while (i < 32) {
    (void)(({ uint8_t __tmp = 0; if (i < nlen && start + ((size_t)(i)) < (source)->length) {   (void)(((out)[i] = (start + ((size_t)(i)) < 0 || (size_t)(start + ((size_t)(i))) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[start + ((size_t)(i))])));
 } else {   (void)(((out)[i] = 0));
 } ; __tmp; }));
    (void)((i = i + 1));
  }
}
void parser_copy_slice_to_param32_at_end(struct shulang_slice_uint8_t * source, size_t end_pos, int32_t nlen, uint8_t * restrict out) {
  size_t start = end_pos - ((size_t)(nlen));
  (void)(parser_copy_slice_to_param32(source, start, nlen, out));
}
void parser_copy_slice_to_name64_buf(uint8_t * restrict source, int32_t source_len, size_t start, int32_t nlen, uint8_t * restrict out) {
  int32_t i = 0;
  while (i < nlen) {
    (void)(({ uint8_t __tmp = 0; if (start + ((size_t)(i)) < ((size_t)(source_len))) {   (void)(((out)[i] = (source)[start + ((size_t)(i))]));
 } else (__tmp = 0) ; __tmp; }));
    (void)((i = i + 1));
  }
}
void parser_copy_slice_to_name64_at_end_buf(uint8_t * restrict source, int32_t source_len, size_t end_pos, int32_t nlen, uint8_t * restrict out) {
  size_t start = end_pos - ((size_t)(nlen));
  (void)(parser_copy_slice_to_name64_buf(source, source_len, start, nlen, out));
}
void parser_copy_slice_to_param32_at_end_buf(uint8_t * restrict source, int32_t source_len, size_t end_pos, int32_t nlen, uint8_t * restrict out) {
  size_t start = end_pos - ((size_t)(nlen));
  int32_t i = 0;
  while (i < 32) {
    (void)(({ uint8_t __tmp = 0; if (i < nlen && start + ((size_t)(i)) < ((size_t)(source_len))) {   (void)(((out)[i] = (source)[start + ((size_t)(i))]));
 } else {   (void)(((out)[i] = 0));
 } ; __tmp; }));
    (void)((i = i + 1));
  }
}
void parser_parse_one_function_impl(struct parser_OneFuncResult * restrict out, struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  (void)(ast_pool_onefunc_reset(parser_onefunc_result_pool_ptr(out)));
  struct parser_OneFuncResult * out_ref = out;
  uint8_t dummy_name[64] = { 0 };
  struct parser_OneFuncResult impl_snap = parser_onefunc_scratch_empty();
  (void)(ast_pool_onefunc_reset(parser_onefunc_result_pool_ptr((&(impl_snap)))));
  (void)(parser_onefunc_res_wire_dummy_head((&(impl_snap)), lex, dummy_name));
  (void)(parser_onefunc_res_wire_dummy_const_let((&(impl_snap))));
  (void)(parser_onefunc_res_wire_dummy_if_mul((&(impl_snap))));
  (void)(parser_onefunc_res_wire_dummy_call_binop((&(impl_snap)), dummy_name));
  (void)(parser_onefunc_res_wire_dummy_loop_call((&(impl_snap))));
  (void)(parser_onefunc_res_wire_dummy_for_if((&(impl_snap))));
  int return_type_is_bool = 0;
  int32_t return_expr_ref_storage = 0;
  size_t name_start = 0;
  int32_t func_name_len_storage[1] = { 0 };
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IDENT) {  } else {   (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(((func_name_len_storage)[0] = ((r).tok).ident_len));
  (void)(({ int32_t __tmp = 0; if ((func_name_len_storage)[0] <= 0 || (func_name_len_storage)[0] > 63) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((name_start = ((r).next_lex).pos - (func_name_len_storage)[0]));
  (void)(parser_copy_slice_to_name64(source, name_start, (func_name_len_storage)[0], (&((dummy_name)[0]))));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RPAREN) {   (void)(parser_lex_from_next_into((&(lex)), r));
 } else {   while (1) {
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(parser_set_onefunc_fail(out_ref, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t plen = ((r).tok).ident_len;
    (void)(({ int32_t __tmp = 0; if (plen <= 0 || plen > 31) {   (void)(parser_set_onefunc_fail(out_ref, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    uint8_t pname_row[32] = { 0 };
    (void)(parser_copy_slice_to_param32(source, (r).token_start, plen, (&((pname_row)[0]))));
    uint8_t * param_pool = parser_onefunc_result_pool_ptr(out);
    int32_t param_idx = pipeline_onefunc_append_param(param_pool, (&((pname_row)[0])), plen, 0);
    (void)(({ int32_t __tmp = 0; if (param_idx < 0) {   (void)(parser_set_onefunc_fail(out_ref, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(((out)->num_params = param_idx + 1));
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(parser_set_onefunc_fail(out_ref, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
    struct lexer_Lexer lex_before_type = lex;
    int32_t type_ref_param = parser_parse_type_ref_for_arena_into(arena, lex_before_type, source, (&(lex)));
    (void)(({ int32_t __tmp = 0; if (type_ref_param == 0) {   (void)(parser_set_onefunc_fail(out_ref, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(pipeline_onefunc_set_param_type_ref(param_pool, param_idx, type_ref_param));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RPAREN) {   (void)(parser_lex_from_next_into((&(lex)), r));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COMMA) {   (void)(parser_set_onefunc_fail(out_ref, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
  }
 } ; __tmp; }));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(parser_set_onefunc_fail(out_ref, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  struct lexer_Lexer lex_before_ret = lex;
  int32_t ret_type_ref = parser_parse_type_ref_for_arena_into(arena, lex_before_ret, source, (&(lex)));
  (void)(({ int32_t __tmp = 0; if (ret_type_ref == 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out)->func_return_type_ref = ret_type_ref));
  (void)(({ int __tmp = 0; if (ret_type_ref != 0) {   struct ast_Type rt;
  rt = pipeline_arena_type_get_copy(arena, ret_type_ref);
  __tmp = ({ int __tmp = 0; if ((rt).kind == ast_TypeKind_TYPE_BOOL) {   (void)((return_type_is_bool = 1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(((out)->num_src_stmt_order = 0));
  (void)(((out)->num_src_body_expr_stmts = 0));
  (void)(parser_parse_body_lets_into(arena, lex, source, out, (&(lex))));
  (void)(((out)->num_lets = ast_pipeline_onefunc_num_lets(parser_onefunc_result_pool_ptr(out))));
  int32_t lsr = 0;
  while (lsr < (out)->num_lets) {
    (void)(parser_onefunc_push_src_stmt(out, 1, lsr));
    (void)((lsr = lsr + 1));
  }
  int stmt_tok_ready = 0;
  while (1) {
    (void)(({ int32_t __tmp = 0; if ((!stmt_tok_ready)) {   (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
    (void)((stmt_tok_ready = 0));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RETURN || ((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LET || ((r).tok).kind == token_TokenKind_TOKEN_CONST) {   int32_t n_before_mid = ast_pipeline_onefunc_num_lets(parser_onefunc_result_pool_ptr(out));
  int32_t kw_back = 3;
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_CONST) {   (void)((kw_back = 5));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_mid_let = (struct lexer_Lexer){ .pos = parser_lexer_pos_before_run(((r).next_lex).pos, kw_back), .line = ((r).tok).line, .col = ((r).tok).col };
  (void)(parser_parse_body_lets_into(arena, lex_mid_let, source, out, (&(lex))));
  (void)(((out)->num_lets = ast_pipeline_onefunc_num_lets(parser_onefunc_result_pool_ptr(out))));
  int32_t push_mi = n_before_mid;
  while (push_mi < (out)->num_lets) {
    (void)(parser_onefunc_push_src_stmt(out, 1, push_mi));
    (void)((push_mi = push_mi + 1));
  }
  (void)(lexer_next_into((&(r)), lex, source));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LOOP) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (r).next_lex));
  int32_t cond_ref_loop = parser_alloc_true_bool_lit(arena);
  (void)(({ int32_t __tmp = 0; if (cond_ref_loop == 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct parser_ParseBlockResult block_res_loop = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex };
  (void)(parser_parse_block_into(arena, lex, source, 0, (&(block_res_loop))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res_loop).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t while_idx_loop = ast_pipeline_onefunc_append_while(parser_onefunc_result_pool_ptr(out), cond_ref_loop, (block_res_loop).block_ref);
  (void)(({ int32_t __tmp = 0; if (while_idx_loop < 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((impl_snap).num_loops = ast_pipeline_onefunc_num_whiles(parser_onefunc_result_pool_ptr(out))));
  (void)(parser_onefunc_push_src_stmt(out, 3, while_idx_loop));
  (void)((lex = (block_res_loop).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_WHILE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (r).next_lex));
  struct lexer_Lexer while_cond_start = lex;
  struct parser_ParseExprResult expr_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = while_cond_start };
  (void)(parser_parse_cond_expr_into(arena, while_cond_start, source, (&(expr_res))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t cond_ref = (expr_res).expr_ref;
  (void)((lex = (expr_res).next_lex));
  (void)(({ int32_t __tmp = 0; if (parser_advance_past_cond_rparen_into((&(r)), lex, source) == 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (r).next_lex));
  struct parser_ParseBlockResult block_res = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex };
  (void)(parser_parse_block_into(arena, lex, source, 0, (&(block_res))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t while_idx = ast_pipeline_onefunc_append_while(parser_onefunc_result_pool_ptr(out), cond_ref, (block_res).block_ref);
  (void)(({ int32_t __tmp = 0; if (while_idx < 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((impl_snap).num_loops = ast_pipeline_onefunc_num_whiles(parser_onefunc_result_pool_ptr(out))));
  (void)(parser_onefunc_push_src_stmt(out, 3, while_idx));
  (void)((lex = (block_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_FOR) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (r).next_lex));
  int32_t init_ref = 0;
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   struct parser_ParseExprResult expr_res_fi = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex };
  (void)(parser_parse_expr_into(arena, lex, source, (&(expr_res_fi))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res_fi).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((init_ref = (expr_res_fi).expr_ref));
  (void)((lex = (expr_res_fi).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (r).next_lex));
  int32_t for_cond_ref = 0;
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   struct parser_ParseExprResult expr_res_fc = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex };
  (void)(parser_parse_expr_into(arena, lex, source, (&(expr_res_fc))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res_fc).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((for_cond_ref = (expr_res_fc).expr_ref));
  (void)((lex = (expr_res_fc).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (r).next_lex));
  int32_t step_ref = 0;
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   struct parser_ParseExprResult expr_res_fs = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex };
  (void)(parser_parse_expr_into(arena, lex, source, (&(expr_res_fs))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res_fs).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((step_ref = (expr_res_fs).expr_ref));
  (void)((lex = (expr_res_fs).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (r).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (r).next_lex));
  struct parser_ParseBlockResult block_res_f = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex };
  (void)(parser_parse_block_into(arena, lex, source, 0, (&(block_res_f))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res_f).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (for_cond_ref == 0) {   int32_t cond_expr_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (cond_expr_ref != 0) {   struct ast_Expr ce;
  ce = pipeline_arena_expr_get_copy(arena, cond_expr_ref);
  (void)(((ce).kind = ast_ExprKind_EXPR_BOOL_LIT));
  (void)(((ce).int_val = 1));
  (void)(((ce).line = 0));
  (void)(((ce).col = 0));
  (void)(parser_expr_set_common_zeros((&(ce))));
  (void)(ast_arena_expr_set(arena, cond_expr_ref, ce));
  (void)((for_cond_ref = cond_expr_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t for_idx = ast_pipeline_onefunc_append_for(parser_onefunc_result_pool_ptr(out), init_ref, for_cond_ref, step_ref, (block_res_f).block_ref);
  (void)(({ int32_t __tmp = 0; if (for_idx < 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((impl_snap).num_for_loops = ast_pipeline_onefunc_num_fors(parser_onefunc_result_pool_ptr(out))));
  (void)(parser_onefunc_push_src_stmt(out, 4, for_idx));
  (void)((lex = (block_res_f).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IF) {   struct lexer_Lexer if_start_fn = parser_lex_at_token_from_result(r);
  int32_t if_cref = 0;
  int32_t if_then_ref = 0;
  int32_t if_else_ref = 0;
  (void)(({ int32_t __tmp = 0; if ((!parser_parse_if_stmt_into(arena, if_start_fn, source, 0, (&(if_cref)), (&(if_then_ref)), (&(if_else_ref)), (&(lex))))) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t if_pool_idx = pipeline_onefunc_append_if(parser_onefunc_result_pool_ptr(out), if_cref, if_then_ref, if_else_ref);
  (void)(({ int32_t __tmp = 0; if (if_pool_idx < 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_onefunc_push_src_stmt(out, 5, if_pool_idx));
  (void)(lexer_next_into((&(r)), lex, source));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
    struct lexer_Lexer stmt_start = parser_lex_at_token_from_result(r);
    struct parser_ParseExprResult expr_stmt_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = stmt_start };
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_INT) {   (void)(parser_parse_cond_expr_into(arena, stmt_start, source, (&(expr_stmt_res))));
 } else {   (void)(parser_parse_expr_into(arena, stmt_start, source, (&(expr_stmt_res))));
 } ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!(expr_stmt_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)((lex = (expr_stmt_res).next_lex));
    (void)(({ int32_t __tmp = 0; if (parser_advance_past_stmt_semicolon_into((&(r)), lex, source) == 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  struct lexer_LexerResult after_semi = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(after_semi)), lex, source));
  (void)((r = after_semi));
 } else (__tmp = 0) ; __tmp; }));
    int32_t ex_i = pipeline_onefunc_push_body_expr_stmt(parser_onefunc_result_pool_ptr(out), (expr_stmt_res).expr_ref);
    (void)(({ int32_t __tmp = 0; if (ex_i < 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(((out)->num_src_body_expr_stmts = pipeline_onefunc_num_body_expr_stmts(parser_onefunc_result_pool_ptr(out))));
    (void)(parser_onefunc_push_src_stmt(out, 2, ex_i));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RETURN || ((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)((lex = parser_lex_at_token_from_result(r)));
    (void)((stmt_tok_ready = 1));
    continue;
  }
 } else {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RETURN) {   (void)(((impl_snap).has_explicit_return_kw = 1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (return_type_is_bool && ((r).tok).kind != token_TokenKind_TOKEN_IF) {   struct lexer_Lexer rex_lex = parser_lex_at_token_from_result(r);
  struct parser_ParseExprResult rex_out = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = rex_lex };
  (void)(parser_parse_expr_into(arena, rex_lex, source, (&(rex_out))));
  (void)(({ int32_t __tmp = 0; if ((!(rex_out).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((return_expr_ref_storage = (rex_out).expr_ref));
  (void)((lex = (rex_out).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IF) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  struct lexer_Lexer lex_cond_start = lex;
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_TRUE || ((r).tok).kind == token_TokenKind_TOKEN_FALSE) {   (void)(((impl_snap).if_cond_true = ((r).tok).kind == token_TokenKind_TOKEN_TRUE));
  (void)(((impl_snap).if_cond_expr_ref = 0));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else {   struct parser_ParseExprResult cond_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cond_start };
  (void)(parser_parse_expr_into(arena, lex_cond_start, source, (&(cond_res))));
  (void)(({ int32_t __tmp = 0; if ((!(cond_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((impl_snap).if_cond_expr_ref = (cond_res).expr_ref));
  (void)(((impl_snap).if_cond_true = 0));
  (void)((lex = (cond_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RPAREN) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_INT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((impl_snap).if_then_val = ((r).tok).int_val));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_ELSE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_INT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((impl_snap).if_else_val = ((r).tok).int_val));
  (void)(((impl_snap).has_if_expr = 1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_MINUS) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_INT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((impl_snap).return_val = ((r).tok).int_val));
  (void)(((impl_snap).has_unary_neg = 1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_INT) {   int32_t ret_int_val = ((r).tok).int_val;
  size_t ret_int_start = (r).token_start;
  (void)(({ size_t __tmp = 0; if (ret_int_start == 0) {   (void)((ret_int_start = ((r).next_lex).pos - 1));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer ret_int_lex = (struct lexer_Lexer){ .pos = ret_int_start, .line = (lex).line, .col = (lex).col };
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_AS) {   struct parser_ParseExprResult ret_expr_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = ret_int_lex };
  (void)(parser_parse_expr_into(arena, ret_int_lex, source, (&(ret_expr_res))));
  (void)(({ int32_t __tmp = 0; if ((!(ret_expr_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((return_expr_ref_storage = (ret_expr_res).expr_ref));
  (void)((lex = (ret_expr_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
 } else {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } ; __tmp; })) ; __tmp; }));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((impl_snap).return_val = ret_int_val));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_PLUS) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_INT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((impl_snap).binop_right_val = ((r).tok).int_val));
  (void)(((impl_snap).has_binop = 1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STAR) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_INT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((impl_snap).mul_right_val = ((r).tok).int_val));
  (void)(((impl_snap).has_mul = 1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STAR) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_INT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((impl_snap).mul_right_val = ((r).tok).int_val));
  (void)(((impl_snap).has_mul = 1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
 } else {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } ; __tmp; })) ; __tmp; }));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } else {   (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   struct lexer_Lexer rex_lex_ni = parser_lex_at_token_from_result(r);
  struct parser_ParseExprResult rex_out_ni = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = rex_lex_ni };
  (void)(parser_parse_expr_into(arena, rex_lex_ni, source, (&(rex_out_ni))));
  (void)(({ int32_t __tmp = 0; if ((!(rex_out_ni).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((return_expr_ref_storage = (rex_out_ni).expr_ref));
  (void)((lex = (rex_out_ni).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   int32_t clen = ((r).tok).ident_len;
  __tmp = ({ int32_t __tmp = 0; if (clen > 0 && clen <= 63) {   size_t cstart = ((r).next_lex).pos - clen;
  (void)(parser_copy_slice_to_name64(source, cstart, clen, (&(((impl_snap).call_callee_name)[0]))));
  (void)(((impl_snap).call_callee_len = clen));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_PLUS && (out)->num_params >= 2) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   uint8_t * binop_pool = parser_onefunc_result_pool_ptr(out);
  int left_ok = (impl_snap).call_callee_len == pipeline_onefunc_param_name_len(binop_pool, 0);
  (void)(({ int32_t __tmp = 0; if (left_ok) {   int32_t ii = 0;
  while (ii < (impl_snap).call_callee_len) {
    (void)(({ int __tmp = 0; if ((ii < 0 || (ii) >= 64 ? (shulang_panic_(1, 0), ((impl_snap).call_callee_name)[0]) : ((impl_snap).call_callee_name)[ii]) != pipeline_onefunc_param_name_byte_at(binop_pool, 0, ii)) {   (void)((left_ok = 0));
 } else (__tmp = 0) ; __tmp; }));
    (void)((ii = ii + 1));
  }
 } else (__tmp = 0) ; __tmp; }));
  int right_ok = ((r).tok).ident_len == pipeline_onefunc_param_name_len(binop_pool, 1);
  __tmp = ({ int32_t __tmp = 0; if (left_ok && right_ok) {   (void)(((impl_snap).has_binop = 1));
  (void)(((impl_snap).binop_left_param_idx = 0));
  (void)(((impl_snap).binop_right_param_idx = 1));
  (void)(((impl_snap).return_val = 0));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE || ((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(((impl_snap).has_call_expr = 0));
  (void)(((impl_snap).return_val = 0));
  (void)(parser_onefunc_snap_set_return_path((&(impl_snap)), 0, (impl_snap).call_callee_name, (impl_snap).call_callee_len, 0));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } ; __tmp; }));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LPAREN) {   struct lexer_Lexer ret_expr_lex = (struct lexer_Lexer){ .pos = cstart, .line = 1, .col = 1 };
  struct parser_ParseExprResult ret_expr_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = ret_expr_lex };
  (void)(parser_parse_expr_into(arena, ret_expr_lex, source, (&(ret_expr_res))));
  (void)(({ int32_t __tmp = 0; if ((!(ret_expr_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((return_expr_ref_storage = (ret_expr_res).expr_ref));
  (void)(((impl_snap).has_call_expr = 0));
  (void)(((impl_snap).call_callee_len = 0));
  (void)(((impl_snap).call_num_args = 0));
  (void)((lex = (ret_expr_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer ret_expr_lex_member = (struct lexer_Lexer){ .pos = cstart, .line = 1, .col = 1 };
  struct parser_ParseExprResult ret_expr_res_member = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = ret_expr_lex_member };
  (void)(parser_parse_expr_into(arena, ret_expr_lex_member, source, (&(ret_expr_res_member))));
  (void)(({ int32_t __tmp = 0; if ((!(ret_expr_res_member).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((return_expr_ref_storage = (ret_expr_res_member).expr_ref));
  (void)(((impl_snap).has_call_expr = 0));
  (void)(((impl_snap).call_callee_len = 0));
  (void)(((impl_snap).call_num_args = 0));
  (void)((lex = (ret_expr_res_member).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } else {   struct lexer_Lexer ret_id_badlen_lex = parser_lex_at_token_from_result(r);
  struct parser_ParseExprResult ret_id_badlen_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = ret_id_badlen_lex };
  (void)(parser_parse_expr_into(arena, ret_id_badlen_lex, source, (&(ret_id_badlen_res))));
  (void)(({ int32_t __tmp = 0; if ((!(ret_id_badlen_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((return_expr_ref_storage = (ret_id_badlen_res).expr_ref));
  (void)(((impl_snap).has_call_expr = 0));
  (void)(((impl_snap).call_callee_len = 0));
  (void)(((impl_snap).call_num_args = 0));
  (void)((lex = (ret_id_badlen_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  while (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
  }
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(((impl_snap).return_val = 0));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
 } else {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } ; __tmp; }));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } ; __tmp; })) ; __tmp; })) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
 } else {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } ; __tmp; })) ; __tmp; }));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } else {   (void)((lex = parser_skip_balanced_braces(lex, source)));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } ; __tmp; }));
}
void parser_parse_into_init(struct ast_Module * restrict module, struct ast_ASTArena * restrict arena) {
  (void)(ast_arena_init(arena));
  (void)(ast_pool_module_reset(module));
  (void)(ast_pool_arena_reset(arena));
  (void)(parser_onefunc_result_layout_prime());
  (void)(parser_onefunc_result_layout_prime_b());
  (void)(parser_onefunc_result_layout_prime_c());
  (void)(parser_onefunc_result_layout_prime_d());
  (void)(parser_onefunc_result_layout_prime_d_b());
  (void)(parser_onefunc_result_layout_prime_e());
  (void)(parser_onefunc_result_layout_prime_f());
  (void)(parser_pipeline_module_reset_parse_counters(module));
}
struct lexer_Lexer parser_skip_imports(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  while (1) {
    struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IMPORT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
    while (1) {
      struct lexer_LexerResult r2 = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
      (void)(lexer_next_into((&(r2)), lex, source));
      (void)(({ int32_t __tmp = 0; if (((r2).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)((lex = (r2).next_lex));
  break;
 } else (__tmp = 0) ; __tmp; }));
      (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r2).tok).kind == token_TokenKind_TOKEN_EOF) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
      (void)((lex = (r2).next_lex));
    }
  }
  return lex;
}
void parser_collect_imports(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct ast_Module * restrict module, struct parser_CollectImportsResult * restrict out) {
  uint8_t path_buf[64] = { 0 };
  int32_t path_len = 0;
  (void)((((out)->lex).pos = (lex).pos));
  (void)((((out)->lex).line = (lex).line));
  (void)((((out)->lex).col = (lex).col));
  while (1) {
    struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = (out)->lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
    (void)(lexer_next_into((&(r)), (out)->lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_CONST) {   struct lexer_LexerResult r2 = (struct lexer_LexerResult){ .next_lex = (r).next_lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r2)), (r).next_lex, source));
  (void)(({ int32_t __tmp = 0; if (((r2).tok).kind == token_TokenKind_TOKEN_IDENT && ((r2).tok).ident_len > 0 && ((r2).tok).ident_len <= 63) {   struct lexer_LexerResult r3 = (struct lexer_LexerResult){ .next_lex = (r2).next_lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r3)), (r2).next_lex, source));
  __tmp = ({ int32_t __tmp = 0; if (((r3).tok).kind == token_TokenKind_TOKEN_ASSIGN) {   size_t bind_start = (r2).token_start;
  uint8_t bind_buf[64] = { 0 };
  int32_t bi = 0;
  while (bi < 64) {
    (void)(({ uint8_t __tmp = 0; if (bi < ((r2).tok).ident_len && bind_start + bi < (source)->length) {   (void)(((bi < 0 || (bi) >= 64 ? (shulang_panic_(1, 0), 0) : ((bind_buf)[bi] = (bind_start + bi < 0 || (size_t)(bind_start + bi) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[bind_start + bi]), 0))));
 } else {   (void)(((bi < 0 || (bi) >= 64 ? (shulang_panic_(1, 0), 0) : ((bind_buf)[bi] = 0, 0))));
 } ; __tmp; }));
    (void)((bi = bi + 1));
  }
  (void)((((out)->lex).pos = ((r3).next_lex).pos));
  (void)((((out)->lex).line = ((r3).next_lex).line));
  (void)((((out)->lex).col = ((r3).next_lex).col));
  (void)(lexer_next_into((&(r)), (out)->lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IMPORT) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&((out)->lex)), r));
  (void)((path_len = 0));
  (void)(lexer_next_into((&(r)), (out)->lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT || ((r).tok).ident_len <= 0 || ((r).tok).ident_len > 63) {   return;
 } else (__tmp = 0) ; __tmp; }));
  size_t ident_start = (r).token_start;
  (void)(parser_copy_slice_to_name64(source, ident_start, ((r).tok).ident_len, (&((path_buf)[0]))));
  (void)((path_len = ((r).tok).ident_len));
  (void)(parser_lex_from_next_into((&((out)->lex)), r));
  (void)(lexer_next_into((&(r)), (out)->lex, source));
  while (((r).tok).kind == token_TokenKind_TOKEN_DOT) {
    (void)(({ int32_t __tmp = 0; if (path_len >= 63) {   return;
 } else (__tmp = 0) ; __tmp; }));
    uint8_t dot_u8 = 46;
    (void)(((path_len < 0 || (path_len) >= 64 ? (shulang_panic_(1, 0), 0) : ((path_buf)[path_len] = dot_u8, 0))));
    (void)((path_len = path_len + 1));
    (void)(parser_lex_from_next_into((&((out)->lex)), r));
    (void)(lexer_next_into((&(r)), (out)->lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT || path_len + ((r).tok).ident_len > 63) {   return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t i = 0;
    while (i < ((r).tok).ident_len) {
      (void)(({ uint8_t __tmp = 0; if ((r).token_start + ((size_t)(i)) < (source)->length) {   (void)(((path_len + i < 0 || (path_len + i) >= 64 ? (shulang_panic_(1, 0), 0) : ((path_buf)[path_len + i] = ((r).token_start + ((size_t)(i)) < 0 || (size_t)((r).token_start + ((size_t)(i))) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[(r).token_start + ((size_t)(i))]), 0))));
 } else (__tmp = 0) ; __tmp; }));
      (void)((i = i + 1));
    }
    (void)((path_len = path_len + ((r).tok).ident_len));
    (void)(parser_lex_from_next_into((&((out)->lex)), r));
    (void)(lexer_next_into((&(r)), (out)->lex, source));
  }
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t imp_ix = ast_pipeline_module_import_alloc(module);
  (void)(({ int32_t __tmp = 0; if (imp_ix < 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_pipeline_module_import_set_path(module, imp_ix, (&((path_buf)[0])), path_len));
  (void)(ast_pipeline_module_import_set_kind(module, imp_ix, 1));
  (void)(ast_pipeline_module_import_set_binding_name(module, imp_ix, (&((bind_buf)[0])), ((r2).tok).ident_len));
  (void)(ast_pipeline_module_import_set_select_count(module, imp_ix, 0));
  (void)(parser_lex_from_next_into((&((out)->lex)), r));
  continue;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r2).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)((((out)->lex).pos = ((r2).next_lex).pos));
  (void)((((out)->lex).line = ((r2).next_lex).line));
  (void)((((out)->lex).col = ((r2).next_lex).col));
  int32_t imp_ix2 = ast_pipeline_module_import_alloc(module);
  (void)(({ int32_t __tmp = 0; if (imp_ix2 < 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_pipeline_module_import_set_kind(module, imp_ix2, 2));
  (void)(ast_pipeline_module_import_set_select_count(module, imp_ix2, 0));
  (void)((r = r2));
  (void)(parser_lex_from_next_into((&((out)->lex)), r));
  (void)(lexer_next_into((&(r)), (out)->lex, source));
  while (((r).tok).kind == token_TokenKind_TOKEN_IDENT) {
    size_t sel_start = (r).token_start;
    (void)(({ int32_t __tmp = 0; if (((r).tok).ident_len <= 0 || ((r).tok).ident_len > 63) {   return;
 } else (__tmp = 0) ; __tmp; }));
    uint8_t sel_buf[64] = { 0 };
    int32_t si = 0;
    while (si < 64) {
      (void)(({ uint8_t __tmp = 0; if (si < ((r).tok).ident_len && sel_start + si < (source)->length) {   (void)(((si < 0 || (si) >= 64 ? (shulang_panic_(1, 0), 0) : ((sel_buf)[si] = (sel_start + si < 0 || (size_t)(sel_start + si) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[sel_start + si]), 0))));
 } else {   (void)(((si < 0 || (si) >= 64 ? (shulang_panic_(1, 0), 0) : ((sel_buf)[si] = 0, 0))));
 } ; __tmp; }));
      (void)((si = si + 1));
    }
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_module_import_append_select_name(module, imp_ix2, (&((sel_buf)[0])), ((r).tok).ident_len) < 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&((out)->lex)), r));
    (void)(lexer_next_into((&(r)), (out)->lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_COMMA) {   (void)(parser_lex_from_next_into((&((out)->lex)), r));
  (void)(lexer_next_into((&(r)), (out)->lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   break;
 } else {   return;
 } ; __tmp; })) ; __tmp; }));
  }
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&((out)->lex)), r));
  (void)(lexer_next_into((&(r)), (out)->lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_ASSIGN) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&((out)->lex)), r));
  (void)(lexer_next_into((&(r)), (out)->lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IMPORT) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&((out)->lex)), r));
  (void)((path_len = 0));
  (void)(lexer_next_into((&(r)), (out)->lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT || ((r).tok).ident_len <= 0 || ((r).tok).ident_len > 63) {   return;
 } else (__tmp = 0) ; __tmp; }));
  size_t ident_start = (r).token_start;
  (void)(parser_copy_slice_to_name64(source, ident_start, ((r).tok).ident_len, (&((path_buf)[0]))));
  (void)((path_len = ((r).tok).ident_len));
  (void)(parser_lex_from_next_into((&((out)->lex)), r));
  (void)(lexer_next_into((&(r)), (out)->lex, source));
  while (((r).tok).kind == token_TokenKind_TOKEN_DOT) {
    (void)(({ int32_t __tmp = 0; if (path_len >= 63) {   return;
 } else (__tmp = 0) ; __tmp; }));
    uint8_t dot_u8 = 46;
    (void)(((path_len < 0 || (path_len) >= 64 ? (shulang_panic_(1, 0), 0) : ((path_buf)[path_len] = dot_u8, 0))));
    (void)((path_len = path_len + 1));
    (void)(parser_lex_from_next_into((&((out)->lex)), r));
    (void)(lexer_next_into((&(r)), (out)->lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT || path_len + ((r).tok).ident_len > 63) {   return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t i = 0;
    while (i < ((r).tok).ident_len) {
      (void)(({ uint8_t __tmp = 0; if ((r).token_start + ((size_t)(i)) < (source)->length) {   (void)(((path_len + i < 0 || (path_len + i) >= 64 ? (shulang_panic_(1, 0), 0) : ((path_buf)[path_len + i] = ((r).token_start + ((size_t)(i)) < 0 || (size_t)((r).token_start + ((size_t)(i))) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[(r).token_start + ((size_t)(i))]), 0))));
 } else (__tmp = 0) ; __tmp; }));
      (void)((i = i + 1));
    }
    (void)((path_len = path_len + ((r).tok).ident_len));
    (void)(parser_lex_from_next_into((&((out)->lex)), r));
    (void)(lexer_next_into((&(r)), (out)->lex, source));
  }
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_pipeline_module_import_set_path(module, imp_ix2, (&((path_buf)[0])), path_len));
  (void)(parser_lex_from_next_into((&((out)->lex)), r));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IMPORT) {   return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&((out)->lex)), r));
    (void)((path_len = 0));
    (void)(lexer_next_into((&(r)), (out)->lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).ident_len <= 0 || ((r).tok).ident_len > 63) {   return;
 } else (__tmp = 0) ; __tmp; }));
    size_t ident_start = (r).token_start;
    (void)(parser_copy_slice_to_name64(source, ident_start, ((r).tok).ident_len, (&((path_buf)[0]))));
    (void)((path_len = ((r).tok).ident_len));
    (void)(parser_lex_from_next_into((&((out)->lex)), r));
    (void)(lexer_next_into((&(r)), (out)->lex, source));
    while (((r).tok).kind == token_TokenKind_TOKEN_DOT) {
      (void)(({ int32_t __tmp = 0; if (path_len >= 63) {   return;
 } else (__tmp = 0) ; __tmp; }));
      uint8_t dot_u8 = 46;
      (void)(((path_len < 0 || (path_len) >= 64 ? (shulang_panic_(1, 0), 0) : ((path_buf)[path_len] = dot_u8, 0))));
      (void)((path_len = path_len + 1));
      (void)(parser_lex_from_next_into((&((out)->lex)), r));
      (void)(lexer_next_into((&(r)), (out)->lex, source));
      (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return;
 } else (__tmp = 0) ; __tmp; }));
      (void)(({ int32_t __tmp = 0; if (path_len + ((r).tok).ident_len > 63) {   return;
 } else (__tmp = 0) ; __tmp; }));
      int32_t i = 0;
      while (i < ((r).tok).ident_len) {
      (void)(({ uint8_t __tmp = 0; if ((r).token_start + ((size_t)(i)) < (source)->length) {   (void)(((path_len + i < 0 || (path_len + i) >= 64 ? (shulang_panic_(1, 0), 0) : ((path_buf)[path_len + i] = ((r).token_start + ((size_t)(i)) < 0 || (size_t)((r).token_start + ((size_t)(i))) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[(r).token_start + ((size_t)(i))]), 0))));
 } else (__tmp = 0) ; __tmp; }));
      (void)((i = i + 1));
      }
      (void)((path_len = path_len + ((r).tok).ident_len));
      (void)(parser_lex_from_next_into((&((out)->lex)), r));
      (void)(lexer_next_into((&(r)), (out)->lex, source));
    }
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t imp_ix3 = ast_pipeline_module_import_alloc(module);
    (void)(({ int32_t __tmp = 0; if (imp_ix3 < 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(ast_pipeline_module_import_set_path(module, imp_ix3, (&((path_buf)[0])), path_len));
    (void)(ast_pipeline_module_import_set_kind(module, imp_ix3, 0));
    (void)(parser_lex_from_next_into((&((out)->lex)), r));
  }
}
void parser_collect_imports_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct ast_Module * restrict module, struct parser_CollectImportsResult * restrict out) {
  struct shulang_slice_uint8_t source = parser_slice_from_buf(data, len);
  (void)(parser_collect_imports(lex, &(source), module, out));
}
void parser_skip_one_struct_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_STRUCT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_braces_into(out, (r).next_lex, source));
}
struct lexer_Lexer parser_skip_one_struct(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_STRUCT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_braces((r).next_lex, source)));
  return lex;
}
void parser_module_try_register_enum_name(struct ast_Module * restrict module, uint8_t * restrict name, int32_t name_len) {
  (void)(({ int32_t __tmp = 0; if (module == ((struct ast_Module *)(0)) || name == ((uint8_t *)(0)) || name_len <= 0 || name_len > 63) {   return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ei = 0;
  while (ei < (module)->num_module_enums) {
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_module_enum_name_len(module, ei) == name_len) {   int eq = 1;
  int32_t j = 0;
  while (j < name_len) {
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_module_enum_name_byte_at(module, ei, j) != (name)[j]) {   (void)((eq = 0));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)((j = j + 1));
  }
  __tmp = ({ int32_t __tmp = 0; if (eq) {   return;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((ei = ei + 1));
  }
  int32_t slot = ast_pipeline_module_enum_alloc(module);
  (void)(({ int32_t __tmp = 0; if (slot < 0) {   return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_pipeline_module_enum_set_name(module, slot, name, name_len));
}
void parser_skip_one_enum_register_into(struct ast_Module * restrict module, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_ENUM) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t nlen = ((r).tok).ident_len;
  size_t nstart = (r).token_start;
  uint8_t nb[64] = { 0 };
  int32_t nk = 0;
  while (nk < nlen && nk < 64) {
    size_t ix = nstart + ((size_t)(nk));
    (void)(({ int32_t __tmp = 0; if (ix >= (source)->length) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(((nk < 0 || (nk) >= 64 ? (shulang_panic_(1, 0), 0) : ((nb)[nk] = (ix < 0 || (size_t)(ix) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[ix]), 0))));
    (void)((nk = nk + 1));
  }
  (void)(({ int32_t __tmp = 0; if (nk == nlen && nlen > 0) {   (void)(parser_module_try_register_enum_name(module, (&((nb)[0])), nlen));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_braces_into(out, (r).next_lex, source));
}
void parser_skip_one_enum_register_into_buf(struct ast_Module * restrict module, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_ENUM) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t nlen2 = ((r).tok).ident_len;
  size_t nstart2 = (r).token_start;
  uint8_t nb2[64] = { 0 };
  int32_t nk2 = 0;
  size_t slen = ((size_t)(len));
  while (nk2 < nlen2 && nk2 < 64) {
    size_t ix2 = nstart2 + ((size_t)(nk2));
    (void)(({ int32_t __tmp = 0; if (ix2 >= slen) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(((nk2 < 0 || (nk2) >= 64 ? (shulang_panic_(1, 0), 0) : ((nb2)[nk2] = (data)[ix2], 0))));
    (void)((nk2 = nk2 + 1));
  }
  (void)(({ int32_t __tmp = 0; if (nk2 == nlen2 && nlen2 > 0) {   (void)(parser_module_try_register_enum_name(module, (&((nb2)[0])), nlen2));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_braces_into_buf(out, (r).next_lex, data, len));
}
void parser_skip_one_enum_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_ENUM) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_braces_into(out, (r).next_lex, source));
}
struct lexer_Lexer parser_skip_one_enum(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_ENUM) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_braces((r).next_lex, source)));
  return lex;
}
void parser_skip_one_trait_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_TRAIT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_braces_into(out, (r).next_lex, source));
}
struct lexer_Lexer parser_skip_one_trait(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_TRAIT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_braces((r).next_lex, source)));
  return lex;
}
void parser_skip_one_impl_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IMPL) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_FOR) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_braces_into(out, (r).next_lex, source));
}
struct lexer_Lexer parser_skip_one_impl(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IMPL) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_FOR) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_braces((r).next_lex, source)));
  return lex;
}
void parser_skip_one_enum_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_ENUM) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_braces_into_buf(out, (r).next_lex, data, len));
}
struct lexer_Lexer parser_skip_one_enum_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_ENUM) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_braces_buf((r).next_lex, data, len)));
  return lex;
}
void parser_skip_one_trait_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_TRAIT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_braces_into_buf(out, (r).next_lex, data, len));
}
struct lexer_Lexer parser_skip_one_trait_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_TRAIT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_braces_buf((r).next_lex, data, len)));
  return lex;
}
void parser_skip_one_impl_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IMPL) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_FOR) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_braces_into_buf(out, (r).next_lex, data, len));
}
struct lexer_Lexer parser_skip_one_impl_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IMPL) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_FOR) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_braces_buf((r).next_lex, data, len)));
  return lex;
}
void parser_skip_one_extern_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_EXTERN) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_parens_into((&(lex)), (r).next_lex, source));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  while (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
  }
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
}
struct lexer_Lexer parser_skip_one_extern(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_EXTERN) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_parens((r).next_lex, source)));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  while (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
  }
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
 } else (__tmp = 0) ; __tmp; }));
  return lex;
}
uint8_t * parser_extern_parse_pool_ptr(struct parser_ExternParseResult * restrict res) {
  return ((uint8_t *)(res));
}
void parser_write_extern_params_to_pools(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, int32_t func_ref, int32_t fi, struct parser_ExternParseResult * restrict res) {
  uint8_t * pool = parser_extern_parse_pool_ptr(res);
  int32_t p = 0;
  while (p < (res)->num_params) {
    uint8_t pname32[32] = { 0 };
    (void)(pipeline_onefunc_param_name_copy32(pool, p, (&((pname32)[0]))));
    int32_t plen = pipeline_onefunc_param_name_len(pool, p);
    int32_t pty = pipeline_onefunc_param_type_ref(pool, p);
    (void)(pipeline_arena_func_param_write(arena, func_ref, p, (&((pname32)[0])), plen, pty));
    (void)(pipeline_module_func_param_write(module, fi, p, (&((pname32)[0])), plen, pty));
    (void)((p = p + 1));
  }
}
void parser_extern_parse_set_fail(struct parser_ExternParseResult * restrict out, struct lexer_Lexer lex) {
  uint8_t empty64[64] = { 0 };
  (void)(((out)->next_lex = lex));
  (void)(((out)->name_len = (-1)));
  (void)(((out)->return_ty_ref = 0));
  (void)(((out)->num_params = 0));
  int32_t ni = 0;
  while (ni < 64) {
    (void)(((ni < 0 || (ni) >= 64 ? (shulang_panic_(1, 0), 0) : (((out)->name)[ni] = (ni < 0 || (ni) >= 64 ? (shulang_panic_(1, 0), (empty64)[0]) : (empty64)[ni]), 0))));
    (void)((ni = ni + 1));
  }
}
void parser_parse_one_extern_skip_into(struct parser_ExternParseResult * restrict out, struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  (void)(ast_pool_onefunc_reset(parser_extern_parse_pool_ptr(out)));
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_EXTERN) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t name_len = ((r).tok).ident_len;
  (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t name_buf[64] = { 0 };
  (void)(parser_copy_slice_to_name64_at_end(source, ((r).next_lex).pos, name_len, (&((name_buf)[0]))));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  uint8_t * ex_pool = parser_extern_parse_pool_ptr(out);
  int32_t n_ex = 0;
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RPAREN) {   (void)(parser_lex_from_next_into((&(lex)), r));
 } else {   while (1) {
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t plen_ex = ((r).tok).ident_len;
    (void)(({ int32_t __tmp = 0; if (plen_ex <= 0 || plen_ex > 31) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    uint8_t pname_ex[32] = { 0 };
    (void)(parser_copy_slice_to_param32(source, (r).token_start, plen_ex, (&((pname_ex)[0]))));
    int32_t pidx_append = pipeline_onefunc_append_param(ex_pool, (&((pname_ex)[0])), plen_ex, 0);
    (void)(({ int32_t __tmp = 0; if (pidx_append < 0) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)((n_ex = pidx_append + 1));
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
    struct lexer_Lexer lex_before_pt = lex;
    int32_t ty_pex = parser_parse_type_ref_for_arena_into(arena, lex_before_pt, source, (&(lex)));
    (void)(({ int32_t __tmp = 0; if (ty_pex == 0) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(pipeline_onefunc_set_param_type_ref(ex_pool, pidx_append, ty_pex));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RPAREN) {   (void)(parser_lex_from_next_into((&(lex)), r));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COMMA) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
  }
 } ; __tmp; }));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  struct lexer_Lexer lex_before_ret = lex;
  int32_t ret_ty = parser_parse_type_ref_for_arena_into(arena, lex_before_ret, source, (&(lex)));
  (void)(({ int32_t __tmp = 0; if (ret_ty == 0) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_extern_parse_set_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(((out)->next_lex = lex));
  (void)(((out)->name_len = name_len));
  (void)(((out)->return_ty_ref = ret_ty));
  (void)(((out)->num_params = n_ex));
  int32_t nk = 0;
  while (nk < 64) {
    (void)(((nk < 0 || (nk) >= 64 ? (shulang_panic_(1, 0), 0) : (((out)->name)[nk] = (nk < 0 || (nk) >= 64 ? (shulang_panic_(1, 0), (name_buf)[0]) : (name_buf)[nk]), 0))));
    (void)((nk = nk + 1));
  }
}
int32_t parser_module_register_arena_func(struct ast_Module * restrict module, int32_t func_ref, struct ast_Func f) {
  int32_t fi = ast_pipeline_module_func_alloc_slot(module);
  (void)(({ int32_t __tmp = 0; if (fi < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_module_func_name_write(module, fi, (&(((f).name)[0])), (f).name_len));
  (void)(ast_pipeline_module_func_set_num_params(module, fi, (f).num_params));
  (void)(ast_pipeline_module_func_set_return_type(module, fi, (f).return_type_ref));
  (void)(ast_pipeline_module_func_set_body_ref(module, fi, (f).body_ref));
  (void)(ast_pipeline_module_func_set_body_expr_ref(module, fi, (f).body_expr_ref));
  (void)(ast_pipeline_module_func_set_is_extern(module, fi, (f).is_extern));
  (void)(ast_pipeline_module_func_ref_set(module, fi, func_ref));
  return fi;
}
void parser_parse_one_extern_and_add_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct lexer_Lexer * restrict lex_out) {
  uint8_t empty64_ex[64] = { 0 };
  struct parser_ExternParseResult res = ({ struct parser_ExternParseResult _t = { 0 }; _t.next_lex = lex; _t.name_len = (-1); _t.return_ty_ref = 0; _t.num_params = 0; memcpy(_t.name, empty64_ex, sizeof(_t.name)); _t; });
  (void)(parser_parse_one_extern_skip_into((&(res)), arena, lex, source));
  (void)(({ int32_t __tmp = 0; if ((res).name_len < 0) {   (void)(parser_skip_one_extern_into(lex_out, lex, source));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t type_ref = (res).return_ty_ref;
  (void)(({ int32_t __tmp = 0; if (type_ref == 0) {   (void)(((lex_out)->pos = ((res).next_lex).pos));
  (void)(((lex_out)->line = ((res).next_lex).line));
  (void)(((lex_out)->col = ((res).next_lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t func_ref = ast_arena_func_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (func_ref == 0) {   (void)(((lex_out)->pos = ((res).next_lex).pos));
  (void)(((lex_out)->line = ((res).next_lex).line));
  (void)(((lex_out)->col = ((res).next_lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Func f = ast_arena_func_get(arena, func_ref);
  int32_t ki = 0;
  while (ki < 64) {
    (void)(({ uint8_t __tmp = 0; if (ki < (res).name_len) {   (void)(((ki < 0 || (ki) >= 64 ? (shulang_panic_(1, 0), 0) : (((f).name)[ki] = (ki < 0 || (ki) >= 64 ? (shulang_panic_(1, 0), ((res).name)[0]) : ((res).name)[ki]), 0))));
 } else {   (void)(((ki < 0 || (ki) >= 64 ? (shulang_panic_(1, 0), 0) : (((f).name)[ki] = 0, 0))));
 } ; __tmp; }));
    (void)((ki = ki + 1));
  }
  (void)(((f).name_len = (res).name_len));
  (void)(((f).num_params = (res).num_params));
  (void)(((f).return_type_ref = type_ref));
  (void)(((f).body_ref = 0));
  (void)(((f).body_expr_ref = 0));
  (void)(((f).is_extern = 1));
  (void)(ast_arena_func_set(arena, func_ref, f));
  int32_t fi_ex = parser_module_register_arena_func(module, func_ref, f);
  (void)(({ int32_t __tmp = 0; if (fi_ex < 0) {   (void)(((lex_out)->pos = ((res).next_lex).pos));
  (void)(((lex_out)->line = ((res).next_lex).line));
  (void)(((lex_out)->col = ((res).next_lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_write_extern_params_to_pools(arena, module, func_ref, fi_ex, (&(res))));
  (void)(((lex_out)->pos = ((res).next_lex).pos));
  (void)(((lex_out)->line = ((res).next_lex).line));
  (void)(((lex_out)->col = ((res).next_lex).col));
}
void parser_skip_one_extern_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_EXTERN) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_parens_into_buf((&(lex)), (r).next_lex, data, len));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  while (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)((r = lexer_next_buf(lex, data, len)));
  }
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
}
struct lexer_Lexer parser_skip_one_extern_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_EXTERN) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_parens_buf((r).next_lex, data, len)));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  while (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)((r = lexer_next_buf(lex, data, len)));
  }
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
 } else (__tmp = 0) ; __tmp; }));
  return lex;
}
void parser_parse_one_extern_and_add_into_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct lexer_Lexer * restrict lex_out) {
  uint8_t empty64_buf_ex[64] = { 0 };
  struct parser_ExternParseResult res = ({ struct parser_ExternParseResult _t = { 0 }; _t.next_lex = lex; _t.name_len = (-1); _t.return_ty_ref = 0; _t.num_params = 0; memcpy(_t.name, empty64_buf_ex, sizeof(_t.name)); _t; });
  struct shulang_slice_uint8_t slice_ex = parser_slice_from_buf(data, len);
  (void)(parser_parse_one_extern_skip_into((&(res)), arena, lex, &(slice_ex)));
  (void)(({ int32_t __tmp = 0; if ((res).name_len < 0) {   (void)(parser_skip_one_extern_into_buf(lex_out, lex, data, len));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t type_ref = (res).return_ty_ref;
  (void)(({ int32_t __tmp = 0; if (type_ref == 0) {   (void)(((lex_out)->pos = ((res).next_lex).pos));
  (void)(((lex_out)->line = ((res).next_lex).line));
  (void)(((lex_out)->col = ((res).next_lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t func_ref = ast_arena_func_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (func_ref == 0) {   (void)(((lex_out)->pos = ((res).next_lex).pos));
  (void)(((lex_out)->line = ((res).next_lex).line));
  (void)(((lex_out)->col = ((res).next_lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Func f = ast_arena_func_get(arena, func_ref);
  int32_t ki = 0;
  while (ki < 64) {
    (void)(({ uint8_t __tmp = 0; if (ki < (res).name_len) {   (void)(((ki < 0 || (ki) >= 64 ? (shulang_panic_(1, 0), 0) : (((f).name)[ki] = (ki < 0 || (ki) >= 64 ? (shulang_panic_(1, 0), ((res).name)[0]) : ((res).name)[ki]), 0))));
 } else {   (void)(((ki < 0 || (ki) >= 64 ? (shulang_panic_(1, 0), 0) : (((f).name)[ki] = 0, 0))));
 } ; __tmp; }));
    (void)((ki = ki + 1));
  }
  (void)(((f).name_len = (res).name_len));
  (void)(((f).num_params = (res).num_params));
  (void)(((f).return_type_ref = type_ref));
  (void)(((f).body_ref = 0));
  (void)(((f).body_expr_ref = 0));
  (void)(((f).is_extern = 1));
  (void)(ast_arena_func_set(arena, func_ref, f));
  int32_t fi_ex = parser_module_register_arena_func(module, func_ref, f);
  (void)(({ int32_t __tmp = 0; if (fi_ex < 0) {   (void)(((lex_out)->pos = ((res).next_lex).pos));
  (void)(((lex_out)->line = ((res).next_lex).line));
  (void)(((lex_out)->col = ((res).next_lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_write_extern_params_to_pools(arena, module, func_ref, fi_ex, (&(res))));
  (void)(((lex_out)->pos = ((res).next_lex).pos));
  (void)(((lex_out)->line = ((res).next_lex).line));
  (void)(((lex_out)->col = ((res).next_lex).col));
}
void parser_lex_from_try_skip_into(struct lexer_Lexer * restrict out, struct parser_TrySkipAllowResult t) {
  (void)(((out)->pos = ((t).lex).pos));
  (void)(((out)->line = ((t).lex).line));
  (void)(((out)->col = ((t).lex).col));
}
void parser_lex_from_library_into(struct lexer_Lexer * restrict out, struct parser_LibraryParseResult lib) {
  (void)(((out)->pos = ((lib).next_lex).pos));
  (void)(((out)->line = ((lib).next_lex).line));
  (void)(((out)->col = ((lib).next_lex).col));
}
struct lexer_Lexer parser_lex_from_try_skip(struct parser_TrySkipAllowResult t) {
  return (struct lexer_Lexer){ .pos = ((t).lex).pos, .line = ((t).lex).line, .col = ((t).lex).col };
}
struct lexer_Lexer parser_lex_from_library(struct parser_LibraryParseResult lib) {
  return (struct lexer_Lexer){ .pos = ((lib).next_lex).pos, .line = ((lib).next_lex).line, .col = ((lib).next_lex).col };
}
int parser_parse_one_function_library_scan(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct parser_LibraryParseScanResult * restrict result) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((result)->name_len = ((r).tok).ident_len));
  (void)(({ int __tmp = 0; if ((result)->name_len <= 0 || (result)->name_len > 63) {   (void)(((result)->ok = 0));
  (void)(parser_lex_from_next_into((&((result)->next_lex)), r));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_copy_slice_to_name64_at_end(source, ((r).next_lex).pos, (result)->name_len, (&(((result)->name)[0]))));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((result)->param_name_len = ((r).tok).ident_len));
  (void)(({ int __tmp = 0; if ((result)->param_name_len <= 0 || (result)->param_name_len > 31) {   (void)(((result)->ok = 0));
  (void)(parser_lex_from_next_into((&((result)->next_lex)), r));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t pnlen = (result)->param_name_len;
  (void)(parser_copy_slice_to_param32(source, (r).token_start, pnlen, (&(((result)->param_name)[0]))));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((result)->param_type_len = ((r).tok).ident_len));
  (void)(({ int __tmp = 0; if ((result)->param_type_len <= 0 || (result)->param_type_len > 63) {   (void)(((result)->ok = 0));
  (void)(parser_lex_from_next_into((&((result)->next_lex)), r));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ptlen = (result)->param_type_len;
  (void)(parser_copy_slice_to_name64(source, (r).token_start, ptlen, (&(((result)->param_type_name)[0]))));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_BOOL) {   __tmp = ({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT || ((r).tok).ident_len != 4) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RETURN) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   while (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_EOF) {
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
  }
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((result)->field_len = 4));
  (void)((((result)->field_name)[0] = 107));
  (void)(((1 < 0 || (1) >= 64 ? (shulang_panic_(1, 0), 0) : (((result)->field_name)[1] = 105, 0))));
  (void)(((2 < 0 || (2) >= 64 ? (shulang_panic_(1, 0), 0) : (((result)->field_name)[2] = 110, 0))));
  (void)(((3 < 0 || (3) >= 64 ? (shulang_panic_(1, 0), 0) : (((result)->field_name)[3] = 100, 0))));
  (void)(((result)->ok = 1));
  (void)(parser_lex_from_next_into((&((result)->next_lex)), r));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_DOT) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((result)->field_len = ((r).tok).ident_len));
  (void)(({ int __tmp = 0; if ((result)->field_len <= 0 || (result)->field_len > 63) {   (void)(((result)->ok = 0));
  (void)(parser_lex_from_next_into((&((result)->next_lex)), r));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_copy_slice_to_name64_at_end(source, ((r).next_lex).pos, (result)->field_len, (&(((result)->field_name)[0]))));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_EQ) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_DOT) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(((result)->ok = 0));
  (void)(((result)->next_lex = lex));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((result)->ok = 1));
  (void)(parser_lex_from_next_into((&((result)->next_lex)), r));
  return 1;
}
int parser_struct_layout_name_exists_arr(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    (void)(({ int __tmp = 0; if (ast_pipeline_module_struct_layout_name_len(module, k) == nlen && nlen > 0) {   int32_t ii = 0;
  int same = 1;
  while (ii < nlen && ii < 64) {
    (void)(({ int __tmp = 0; if (ast_pipeline_module_struct_layout_name_byte_at(module, k, ii) != (ii < 0 || (ii) >= 64 ? (shulang_panic_(1, 0), (nm)[0]) : (nm)[ii])) {   (void)((same = 0));
 } else (__tmp = 0) ; __tmp; }));
    (void)((ii = ii + 1));
  }
  __tmp = ({ int __tmp = 0; if (same) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  return 0;
}
int32_t parser_struct_layout_first_name_match_idx(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_module_struct_layout_name_len(module, k) == nlen && nlen > 0) {   int32_t ii = 0;
  int same = 1;
  while (ii < nlen && ii < 64) {
    (void)(({ int __tmp = 0; if (ast_pipeline_module_struct_layout_name_byte_at(module, k, ii) != (ii < 0 || (ii) >= 64 ? (shulang_panic_(1, 0), (nm)[0]) : (nm)[ii])) {   (void)((same = 0));
 } else (__tmp = 0) ; __tmp; }));
    (void)((ii = ii + 1));
  }
  __tmp = ({ int32_t __tmp = 0; if (same) {   return k;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  return (-1);
}
int32_t parser_struct_layout_placeholder_idx(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    (void)(({ int32_t __tmp = 0; if (ast_pipeline_module_struct_layout_name_len(module, k) == nlen && nlen > 0) {   int32_t ii = 0;
  int same = 1;
  while (ii < nlen && ii < 64) {
    (void)(({ int __tmp = 0; if (ast_pipeline_module_struct_layout_name_byte_at(module, k, ii) != (ii < 0 || (ii) >= 64 ? (shulang_panic_(1, 0), (nm)[0]) : (nm)[ii])) {   (void)((same = 0));
 } else (__tmp = 0) ; __tmp; }));
    (void)((ii = ii + 1));
  }
  __tmp = ({ int32_t __tmp = 0; if (same) {   int32_t nf = ast_pipeline_module_struct_layout_num_fields(module, k);
  (void)(({ int32_t __tmp = 0; if (nf == 0) {   return k;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nf == 1 && ast_pipeline_module_struct_layout_field_name_len(module, k, 0) == 0) {   return k;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (nf == 1 && ast_pipeline_module_struct_layout_field_type_ref(module, k, 0) == 0) {   return k;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)((k = k + 1));
  }
  return (-1);
}
struct parser_LibraryParseResult parser_parse_one_function_library(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  uint8_t empty64[64] = { 0 };
  struct parser_LibraryParseResult fail = ({ struct parser_LibraryParseResult _t = { 0 }; _t.ok = 0; _t.next_lex = lex; _t.name_len = 0; memcpy(_t.name, empty64, sizeof(_t.name)); _t; });
  uint8_t empty32[32] = { 0 };
  struct parser_LibraryParseScanResult scan = ({ struct parser_LibraryParseScanResult _t = { 0 }; _t.ok = 0; _t.next_lex = lex; _t.name_len = 0; _t.param_name_len = 0; _t.param_type_len = 0; _t.field_len = 0; memcpy(_t.name, empty64, sizeof(_t.name)); memcpy(_t.param_name, empty32, sizeof(_t.param_name)); memcpy(_t.param_type_name, empty64, sizeof(_t.param_type_name)); memcpy(_t.field_name, empty64, sizeof(_t.field_name)); _t; });
  (void)(({ struct parser_LibraryParseResult __tmp = (struct parser_LibraryParseResult){0}; if ((!parser_parse_one_function_library_scan(lex, source, (&(scan))))) {   return ({ struct parser_LibraryParseResult _t = { 0 }; _t.ok = 0; _t.next_lex = (scan).next_lex; _t.name_len = 0; memcpy(_t.name, empty64, sizeof(_t.name)); _t; });
 } else (__tmp = (struct parser_LibraryParseResult){0}) ; __tmp; }));
  int32_t bool_type_ref = ast_arena_type_alloc(arena);
  (void)(({ struct parser_LibraryParseResult __tmp = (struct parser_LibraryParseResult){0}; if (bool_type_ref == 0) {   return fail;
 } else (__tmp = (struct parser_LibraryParseResult){0}) ; __tmp; }));
  struct ast_Type bt;
  bt = pipeline_arena_type_get_copy(arena, bool_type_ref);
  (void)(((bt).kind = ast_TypeKind_TYPE_BOOL));
  (void)(((bt).name_len = 0));
  (void)(((bt).elem_type_ref = 0));
  (void)(((bt).array_size = 0));
  (void)(ast_arena_type_set(arena, bool_type_ref, bt));
  int32_t token_type_ref = ast_arena_type_alloc(arena);
  (void)(({ struct parser_LibraryParseResult __tmp = (struct parser_LibraryParseResult){0}; if (token_type_ref == 0) {   return fail;
 } else (__tmp = (struct parser_LibraryParseResult){0}) ; __tmp; }));
  struct ast_Type tt;
  tt = pipeline_arena_type_get_copy(arena, token_type_ref);
  (void)(((tt).kind = ast_TypeKind_TYPE_NAMED));
  (void)(((tt).name_len = (scan).param_type_len));
  int32_t ti = 0;
  while (ti < 64) {
    (void)(({ uint8_t __tmp = 0; if (ti < (scan).param_type_len) {   (void)(((ti < 0 || (ti) >= 64 ? (shulang_panic_(1, 0), 0) : (((tt).name)[ti] = (ti < 0 || (ti) >= 64 ? (shulang_panic_(1, 0), ((scan).param_type_name)[0]) : ((scan).param_type_name)[ti]), 0))));
 } else {   (void)(((ti < 0 || (ti) >= 64 ? (shulang_panic_(1, 0), 0) : (((tt).name)[ti] = 0, 0))));
 } ; __tmp; }));
    (void)((ti = ti + 1));
  }
  (void)(((tt).elem_type_ref = 0));
  (void)(((tt).array_size = 0));
  (void)(ast_arena_type_set(arena, token_type_ref, tt));
  int32_t var_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_LibraryParseResult __tmp = (struct parser_LibraryParseResult){0}; if (var_ref == 0) {   return fail;
 } else (__tmp = (struct parser_LibraryParseResult){0}) ; __tmp; }));
  struct ast_Expr ve;
  ve = pipeline_arena_expr_get_copy(arena, var_ref);
  (void)(((ve).kind = ast_ExprKind_EXPR_VAR));
  (void)(((ve).resolved_type_ref = token_type_ref));
  (void)(((ve).line = 0));
  (void)(((ve).col = 0));
  (void)(((ve).var_name_len = (scan).param_name_len));
  int32_t vi = 0;
  while (vi < 64) {
    (void)(({ uint8_t __tmp = 0; if (vi < 32) {   (void)(((vi < 0 || (vi) >= 64 ? (shulang_panic_(1, 0), 0) : (((ve).var_name)[vi] = (vi < 0 || (vi) >= 32 ? (shulang_panic_(1, 0), ((scan).param_name)[0]) : ((scan).param_name)[vi]), 0))));
 } else {   (void)(((vi < 0 || (vi) >= 64 ? (shulang_panic_(1, 0), 0) : (((ve).var_name)[vi] = 0, 0))));
 } ; __tmp; }));
    (void)((vi = vi + 1));
  }
  (void)(ast_expr_init_match_enum((&(ve))));
  (void)(((ve).field_access_base_ref = 0));
  (void)(((ve).field_access_field_len = 0));
  (void)(((ve).field_access_is_enum_variant = 0));
  (void)(((ve).field_access_offset = 0));
  (void)(ast_arena_expr_set(arena, var_ref, ve));
  int32_t field_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_LibraryParseResult __tmp = (struct parser_LibraryParseResult){0}; if (field_ref == 0) {   return fail;
 } else (__tmp = (struct parser_LibraryParseResult){0}) ; __tmp; }));
  struct ast_Expr fe;
  fe = pipeline_arena_expr_get_copy(arena, field_ref);
  (void)(((fe).kind = ast_ExprKind_EXPR_FIELD_ACCESS));
  (void)(((fe).resolved_type_ref = 0));
  (void)(((fe).line = 0));
  (void)(((fe).col = 0));
  (void)(((fe).field_access_base_ref = var_ref));
  (void)(((fe).field_access_field_len = (scan).field_len));
  int32_t fi = 0;
  while (fi < 64) {
    (void)(({ uint8_t __tmp = 0; if (fi < (scan).field_len) {   (void)(((fi < 0 || (fi) >= 64 ? (shulang_panic_(1, 0), 0) : (((fe).field_access_field_name)[fi] = (fi < 0 || (fi) >= 64 ? (shulang_panic_(1, 0), ((scan).field_name)[0]) : ((scan).field_name)[fi]), 0))));
 } else {   (void)(((fi < 0 || (fi) >= 64 ? (shulang_panic_(1, 0), 0) : (((fe).field_access_field_name)[fi] = 0, 0))));
 } ; __tmp; }));
    (void)((fi = fi + 1));
  }
  (void)(((fe).field_access_is_enum_variant = 0));
  (void)(((fe).field_access_offset = 0));
  (void)(ast_expr_init_match_enum((&(fe))));
  (void)(((fe).binop_left_ref = 0));
  (void)(((fe).binop_right_ref = 0));
  (void)(ast_arena_expr_set(arena, field_ref, fe));
  int32_t enum_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_LibraryParseResult __tmp = (struct parser_LibraryParseResult){0}; if (enum_ref == 0) {   return fail;
 } else (__tmp = (struct parser_LibraryParseResult){0}) ; __tmp; }));
  struct ast_Expr ene;
  ene = pipeline_arena_expr_get_copy(arena, enum_ref);
  (void)(((ene).kind = ast_ExprKind_EXPR_ENUM_VARIANT));
  (void)(((ene).resolved_type_ref = 0));
  (void)(((ene).line = 0));
  (void)(((ene).col = 0));
  (void)(((ene).enum_variant_tag = 0));
  (void)(ast_expr_init_match_enum((&(ene))));
  (void)(((ene).field_access_base_ref = 0));
  (void)(((ene).field_access_field_len = 0));
  (void)(ast_arena_expr_set(arena, enum_ref, ene));
  int32_t eq_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_LibraryParseResult __tmp = (struct parser_LibraryParseResult){0}; if (eq_ref == 0) {   return fail;
 } else (__tmp = (struct parser_LibraryParseResult){0}) ; __tmp; }));
  struct ast_Expr eqe;
  eqe = pipeline_arena_expr_get_copy(arena, eq_ref);
  (void)(((eqe).kind = ast_ExprKind_EXPR_EQ));
  (void)(((eqe).resolved_type_ref = bool_type_ref));
  (void)(((eqe).line = 0));
  (void)(((eqe).col = 0));
  (void)(((eqe).binop_left_ref = field_ref));
  (void)(((eqe).binop_right_ref = enum_ref));
  (void)(ast_expr_init_match_enum((&(eqe))));
  (void)(((eqe).field_access_base_ref = 0));
  (void)(((eqe).field_access_field_len = 0));
  (void)(ast_arena_expr_set(arena, eq_ref, eqe));
  int32_t block_ref = ast_arena_block_alloc(arena);
  (void)(({ struct parser_LibraryParseResult __tmp = (struct parser_LibraryParseResult){0}; if (block_ref == 0) {   return fail;
 } else (__tmp = (struct parser_LibraryParseResult){0}) ; __tmp; }));
  struct ast_Block b;
  b = pipeline_arena_block_get_copy(arena, block_ref);
  (void)(((b).num_consts = 0));
  (void)(((b).num_lets = 0));
  (void)(((b).num_early_lets = 0));
  (void)(((b).num_loops = 0));
  (void)(((b).num_for_loops = 0));
  (void)(((b).num_if_stmts = 0));
  (void)(((b).num_defers = 0));
  (void)(({ struct parser_LibraryParseResult __tmp = (struct parser_LibraryParseResult){0}; if (ast_pipeline_block_append_labeled(arena, block_ref, 0, 0, 0, eq_ref) < 0) {   return fail;
 } else (__tmp = (struct parser_LibraryParseResult){0}) ; __tmp; }));
  (void)((b = ast_arena_block_get(arena, block_ref)));
  (void)(((b).num_expr_stmts = 0));
  (void)(((b).final_expr_ref = 0));
  (void)(((b).num_stmt_order = 0));
  (void)(ast_arena_block_set(arena, block_ref, b));
  (void)(({ int32_t __tmp = 0; if ((scan).field_len > 0 && (!parser_struct_layout_name_exists_arr(module, (scan).param_type_name, (scan).param_type_len))) {   int32_t idx = ast_pipeline_module_struct_layout_alloc(module);
  __tmp = ({ int32_t __tmp = 0; if (idx >= 0) {   (void)(ast_pipeline_module_struct_layout_set_name(module, idx, (&(((scan).param_type_name)[0])), (scan).param_type_len));
  (void)(ast_pipeline_module_struct_layout_set_num_fields(module, idx, 1));
  (void)(ast_pipeline_module_struct_layout_set_field(module, idx, 0, (&(((scan).field_name)[0])), (scan).field_len, 0, 0));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t fi_lib = ast_pipeline_module_func_alloc_slot(module);
  (void)(({ struct parser_LibraryParseResult __tmp = (struct parser_LibraryParseResult){0}; if (fi_lib < 0) {   return fail;
 } else (__tmp = (struct parser_LibraryParseResult){0}) ; __tmp; }));
  (void)(pipeline_module_func_name_write(module, fi_lib, (&(((scan).name)[0])), (scan).name_len));
  (void)(ast_pipeline_module_func_set_num_params(module, fi_lib, 1));
  (void)(pipeline_module_func_param_write(module, fi_lib, 0, (&(((scan).param_name)[0])), (scan).param_name_len, token_type_ref));
  (void)(ast_pipeline_module_func_set_return_type(module, fi_lib, bool_type_ref));
  (void)(ast_pipeline_module_func_set_body_ref(module, fi_lib, block_ref));
  (void)(ast_pipeline_module_func_set_body_expr_ref(module, fi_lib, 0));
  (void)(ast_pipeline_module_func_set_is_extern(module, fi_lib, 0));
  return ({ struct parser_LibraryParseResult _t = { 0 }; _t.ok = 1; _t.next_lex = (scan).next_lex; _t.name_len = (scan).name_len; memcpy(_t.name, (scan).name, sizeof(_t.name)); _t; });
}
struct parser_LibraryParseResult parser_parse_one_function_library_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shulang_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_parse_one_function_library(arena, module, lex, &(slice));
}
struct parser_TrySkipAllowResult parser_parse_into_try_skip_allow(struct lexer_Lexer lex, struct lexer_LexerResult r, struct shulang_slice_uint8_t * source) {
  (void)(({ struct parser_TrySkipAllowResult __tmp = (struct parser_TrySkipAllowResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT || ((r).tok).ident_len != 5) {   return ({ struct parser_TrySkipAllowResult _t = { 0 }; _t.lex = lex; _t.skipped = 0; _t; });
 } else (__tmp = (struct parser_TrySkipAllowResult){0}) ; __tmp; }));
  return parser_try_skip_allow_padding_struct((r).next_lex, source);
}
struct parser_TrySkipAllowResult parser_parse_into_try_skip_allow_buf(struct lexer_Lexer lex, struct lexer_LexerResult r, uint8_t * restrict data, int32_t len) {
  (void)(({ struct parser_TrySkipAllowResult __tmp = (struct parser_TrySkipAllowResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT || ((r).tok).ident_len != 5) {   return ({ struct parser_TrySkipAllowResult _t = { 0 }; _t.lex = lex; _t.skipped = 0; _t; });
 } else (__tmp = (struct parser_TrySkipAllowResult){0}) ; __tmp; }));
  return parser_try_skip_allow_padding_struct_buf((r).next_lex, data, len);
}
struct parser_TrySkipAllowResult parser_try_skip_allow_padding_struct(struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ struct parser_TrySkipAllowResult __tmp = (struct parser_TrySkipAllowResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   return ({ struct parser_TrySkipAllowResult _t = { 0 }; _t.lex = lex; _t.skipped = 0; _t; });
 } else (__tmp = (struct parser_TrySkipAllowResult){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_parens((r).next_lex, source)));
  return ({ struct parser_TrySkipAllowResult _t = { 0 }; _t.lex = lex; _t.skipped = 1; _t; });
}
struct parser_TrySkipAllowResult parser_try_skip_allow_padding_struct_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ struct parser_TrySkipAllowResult __tmp = (struct parser_TrySkipAllowResult){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   return ({ struct parser_TrySkipAllowResult _t = { 0 }; _t.lex = lex; _t.skipped = 0; _t; });
 } else (__tmp = (struct parser_TrySkipAllowResult){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_parens_buf((r).next_lex, data, len)));
  return ({ struct parser_TrySkipAllowResult _t = { 0 }; _t.lex = lex; _t.skipped = 1; _t; });
}
void parser_skip_one_struct_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_STRUCT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(((out)->pos = (lex).pos));
  (void)(((out)->line = (lex).line));
  (void)(((out)->col = (lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_skip_balanced_braces_into_buf(out, (r).next_lex, data, len));
}
struct lexer_Lexer parser_skip_one_struct_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_STRUCT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return lex;
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  (void)((lex = parser_skip_balanced_braces_buf((r).next_lex, data, len)));
  return lex;
}
int parser_is_pointee_type_token(enum token_TokenKind kind) {
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_IDENT) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_I32 || kind == token_TokenKind_TOKEN_I64 || kind == token_TokenKind_TOKEN_BOOL) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_U8 || kind == token_TokenKind_TOKEN_U32 || kind == token_TokenKind_TOKEN_U64) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_USIZE || kind == token_TokenKind_TOKEN_ISIZE || kind == token_TokenKind_TOKEN_VOID) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t parser_alloc_pointee_type_ref_from_tok(struct ast_ASTArena * restrict arena, struct shulang_slice_uint8_t * source, struct lexer_LexerResult * restrict r) {
  (void)(({ int32_t __tmp = 0; if ((!parser_is_pointee_type_token(((r)->tok).kind))) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t elem_ref = ast_arena_type_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (elem_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type te;
  te = pipeline_arena_type_get_copy(arena, elem_ref);
  (void)(((te).elem_type_ref = 0));
  (void)(((te).array_size = 0));
  (void)(((te).name_len = 0));
  (void)(({ enum ast_TypeKind __tmp = 0; if (((r)->tok).kind == token_TokenKind_TOKEN_IDENT) {   (void)(((te).kind = ast_TypeKind_TYPE_NAMED));
  (void)(((te).name_len = ((r)->tok).ident_len));
  (void)(({ int32_t __tmp = 0; if ((te).name_len > 63) {   (void)(((te).name_len = 63));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_copy_slice_to_name64_at_end(source, ((r)->next_lex).pos, (te).name_len, (&(((te).name)[0]))));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r)->tok).kind == token_TokenKind_TOKEN_I32) {   (void)(((te).kind = ast_TypeKind_TYPE_I32));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r)->tok).kind == token_TokenKind_TOKEN_I64) {   (void)(((te).kind = ast_TypeKind_TYPE_I64));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r)->tok).kind == token_TokenKind_TOKEN_BOOL) {   (void)(((te).kind = ast_TypeKind_TYPE_BOOL));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r)->tok).kind == token_TokenKind_TOKEN_U8) {   (void)(((te).kind = ast_TypeKind_TYPE_U8));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r)->tok).kind == token_TokenKind_TOKEN_U32) {   (void)(((te).kind = ast_TypeKind_TYPE_U32));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r)->tok).kind == token_TokenKind_TOKEN_U64) {   (void)(((te).kind = ast_TypeKind_TYPE_U64));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r)->tok).kind == token_TokenKind_TOKEN_USIZE) {   (void)(((te).kind = ast_TypeKind_TYPE_USIZE));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r)->tok).kind == token_TokenKind_TOKEN_ISIZE) {   (void)(((te).kind = ast_TypeKind_TYPE_ISIZE));
 } else {   (void)(((te).kind = ast_TypeKind_TYPE_VOID));
 } ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  (void)(ast_arena_type_set(arena, elem_ref, te));
  return elem_ref;
}
int32_t parser_parse_type_ref_for_arena_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct lexer_Lexer * restrict out_lex) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STAR) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  int32_t elem_ref = parser_alloc_pointee_type_ref_from_tok(arena, source, (&(r)));
  (void)(({ int32_t __tmp = 0; if (elem_ref == 0) {   (void)(((out_lex)->pos = (lex).pos));
  (void)(((out_lex)->line = (lex).line));
  (void)(((out_lex)->col = (lex).col));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t type_ref_param = ast_arena_type_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (type_ref_param != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref_param);
  (void)(((t).kind = ast_TypeKind_TYPE_PTR));
  (void)(((t).elem_type_ref = elem_ref));
  (void)(((t).name_len = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref_param, t));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(((out_lex)->pos = (lex).pos));
  (void)(((out_lex)->line = (lex).line));
  (void)(((out_lex)->col = (lex).col));
  return type_ref_param;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACKET) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_INT) {   (void)(((out_lex)->pos = (lex).pos));
  (void)(((out_lex)->line = (lex).line));
  (void)(((out_lex)->col = (lex).col));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t asz = ((r).tok).int_val;
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACKET) {   (void)(((out_lex)->pos = (lex).pos));
  (void)(((out_lex)->line = (lex).line));
  (void)(((out_lex)->col = (lex).col));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  int32_t elem_tr = parser_parse_type_ref_for_arena_into(arena, lex, source, (&(lex)));
  (void)(({ int32_t __tmp = 0; if (elem_tr == 0) {   (void)(((out_lex)->pos = (lex).pos));
  (void)(((out_lex)->line = (lex).line));
  (void)(((out_lex)->col = (lex).col));
  return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t arr_ref = ast_arena_type_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (arr_ref != 0) {   struct ast_Type ta;
  ta = pipeline_arena_type_get_copy(arena, arr_ref);
  (void)(((ta).kind = ast_TypeKind_TYPE_ARRAY));
  (void)(((ta).elem_type_ref = elem_tr));
  (void)(((ta).array_size = asz));
  (void)(((ta).name_len = 0));
  (void)(ast_arena_type_set(arena, arr_ref, ta));
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out_lex)->pos = (lex).pos));
  (void)(((out_lex)->line = (lex).line));
  (void)(((out_lex)->col = (lex).col));
  return arr_ref;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_I32 || ((r).tok).kind == token_TokenKind_TOKEN_BOOL || ((r).tok).kind == token_TokenKind_TOKEN_I64 || ((r).tok).kind == token_TokenKind_TOKEN_U8 || ((r).tok).kind == token_TokenKind_TOKEN_U32 || ((r).tok).kind == token_TokenKind_TOKEN_U64 || ((r).tok).kind == token_TokenKind_TOKEN_USIZE || ((r).tok).kind == token_TokenKind_TOKEN_ISIZE || ((r).tok).kind == token_TokenKind_TOKEN_VOID) {   int32_t type_ref_param = 0;
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_I32) {   (void)((type_ref_param = ast_arena_type_alloc(arena)));
  __tmp = ({ int32_t __tmp = 0; if (type_ref_param != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref_param);
  (void)(((t).kind = ast_TypeKind_TYPE_I32));
  (void)(((t).name_len = 0));
  (void)(((t).elem_type_ref = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref_param, t));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_I64) {   (void)((type_ref_param = ast_arena_type_alloc(arena)));
  __tmp = ({ int32_t __tmp = 0; if (type_ref_param != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref_param);
  (void)(((t).kind = ast_TypeKind_TYPE_I64));
  (void)(((t).name_len = 0));
  (void)(((t).elem_type_ref = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref_param, t));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_BOOL) {   (void)((type_ref_param = ast_arena_type_alloc(arena)));
  __tmp = ({ int32_t __tmp = 0; if (type_ref_param != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref_param);
  (void)(((t).kind = ast_TypeKind_TYPE_BOOL));
  (void)(((t).name_len = 0));
  (void)(((t).elem_type_ref = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref_param, t));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_U8) {   (void)((type_ref_param = ast_arena_type_alloc(arena)));
  __tmp = ({ int32_t __tmp = 0; if (type_ref_param != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref_param);
  (void)(((t).kind = ast_TypeKind_TYPE_U8));
  (void)(((t).name_len = 0));
  (void)(((t).elem_type_ref = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref_param, t));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_U32) {   (void)((type_ref_param = ast_arena_type_alloc(arena)));
  __tmp = ({ int32_t __tmp = 0; if (type_ref_param != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref_param);
  (void)(((t).kind = ast_TypeKind_TYPE_U32));
  (void)(((t).name_len = 0));
  (void)(((t).elem_type_ref = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref_param, t));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_U64) {   (void)((type_ref_param = ast_arena_type_alloc(arena)));
  __tmp = ({ int32_t __tmp = 0; if (type_ref_param != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref_param);
  (void)(((t).kind = ast_TypeKind_TYPE_U64));
  (void)(((t).name_len = 0));
  (void)(((t).elem_type_ref = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref_param, t));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_USIZE) {   (void)((type_ref_param = ast_arena_type_alloc(arena)));
  __tmp = ({ int32_t __tmp = 0; if (type_ref_param != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref_param);
  (void)(((t).kind = ast_TypeKind_TYPE_USIZE));
  (void)(((t).name_len = 0));
  (void)(((t).elem_type_ref = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref_param, t));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ISIZE) {   (void)((type_ref_param = ast_arena_type_alloc(arena)));
  __tmp = ({ int32_t __tmp = 0; if (type_ref_param != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref_param);
  (void)(((t).kind = ast_TypeKind_TYPE_ISIZE));
  (void)(((t).name_len = 0));
  (void)(((t).elem_type_ref = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref_param, t));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_VOID) {   (void)((type_ref_param = ast_arena_type_alloc(arena)));
  __tmp = ({ int32_t __tmp = 0; if (type_ref_param != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref_param);
  (void)(((t).kind = ast_TypeKind_TYPE_VOID));
  (void)(((t).name_len = 0));
  (void)(((t).elem_type_ref = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref_param, t));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(((out_lex)->pos = (lex).pos));
  (void)(((out_lex)->line = (lex).line));
  (void)(((out_lex)->col = (lex).col));
  return type_ref_param;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   int32_t type_ref_param = ast_arena_type_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (type_ref_param != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref_param);
  (void)(((t).kind = ast_TypeKind_TYPE_NAMED));
  (void)(((t).name_len = ((r).tok).ident_len));
  (void)(({ int32_t __tmp = 0; if ((t).name_len > 63) {   (void)(((t).name_len = 63));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_copy_slice_to_name64_at_end(source, ((r).next_lex).pos, (t).name_len, (&(((t).name)[0]))));
  (void)(((t).elem_type_ref = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref_param, t));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(((out_lex)->pos = (lex).pos));
  (void)(((out_lex)->line = (lex).line));
  (void)(((out_lex)->col = (lex).col));
  return type_ref_param;
 } else (__tmp = 0) ; __tmp; }));
  (void)(((out_lex)->pos = (lex).pos));
  (void)(((out_lex)->line = (lex).line));
  (void)(((out_lex)->col = (lex).col));
  return 0;
}
int32_t parser_parse_struct_record_layout_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, struct lexer_Lexer * restrict out_lex, int32_t allow_pad) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT || ((r).tok).ident_len <= 0 || ((r).tok).ident_len > 63) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t sname_len = ((r).tok).ident_len;
  uint8_t sname_buf[64] = { 0 };
  (void)(parser_copy_slice_to_name64_at_end(source, ((r).next_lex).pos, sname_len, (&((sname_buf)[0]))));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (r).next_lex));
  int dup = parser_struct_layout_name_exists_arr(module, sname_buf, sname_len);
  int32_t weak_idx = parser_struct_layout_placeholder_idx(module, sname_buf, sname_len);
  int32_t replace_idx = (-1);
  (void)(({ int32_t __tmp = 0; if (dup) {   __tmp = ({ int32_t __tmp = 0; if (weak_idx < 0) {   int32_t dup_idx = parser_struct_layout_first_name_match_idx(module, sname_buf, sname_len);
  __tmp = ({ int32_t __tmp = 0; if (dup_idx >= 0) {   (void)((replace_idx = dup_idx));
 } else {   (void)((lex = parser_skip_balanced_braces(lex, source)));
  (void)(((out_lex)->pos = (lex).pos));
  (void)(((out_lex)->line = (lex).line));
  (void)(((out_lex)->col = (lex).col));
  return 0;
 } ; __tmp; });
 } else {   (void)((replace_idx = weak_idx));
 } ; __tmp; });
 } else {   (void)((replace_idx = (-1)));
 } ; __tmp; }));
  int32_t layout_idx = replace_idx;
  (void)(({ int32_t __tmp = 0; if (layout_idx < 0) {   (void)((layout_idx = ast_pipeline_module_struct_layout_alloc(module)));
  __tmp = ({ int32_t __tmp = 0; if (layout_idx < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_pipeline_module_struct_layout_reset_slot(module, layout_idx));
  (void)(ast_pipeline_module_struct_layout_set_name(module, layout_idx, (&((sname_buf)[0])), sname_len));
  int32_t nf = 0;
  int32_t off = 0;
  uint8_t fname_buf[64] = { 0 };
  while (1) {
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT || ((r).tok).ident_len <= 0 || ((r).tok).ident_len > 63) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    int32_t fn_len = ((r).tok).ident_len;
    (void)(parser_copy_slice_to_name64_at_end(source, ((r).next_lex).pos, fn_len, (&((fname_buf)[0]))));
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
    int32_t tr = parser_parse_type_ref_for_arena_into(arena, lex, source, (&(lex)));
    (void)(({ int32_t __tmp = 0; if (tr == 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(ast_pipeline_module_struct_layout_set_field(module, layout_idx, nf, (&((fname_buf)[0])), fn_len, tr, off));
    (void)((off = off + 8));
    (void)((nf = nf + 1));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
 } else (__tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  break;
 } else (__tmp = ({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if (((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   (void)((lex = parser_lex_at_token_from_result(r)));
 } else {   return (-1);
 } ; __tmp; })) ; __tmp; })) ; __tmp; }));
  }
  (void)(ast_pipeline_module_struct_layout_set_num_fields(module, layout_idx, nf));
  (void)(ast_pipeline_module_struct_layout_set_allow_padding(module, layout_idx, allow_pad));
  (void)(((out_lex)->pos = (lex).pos));
  (void)(((out_lex)->line = (lex).line));
  (void)(((out_lex)->col = (lex).col));
  return 0;
}
void parser_parse_one_function_buf_into(struct parser_OneFuncResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  uint8_t dummy_name[64] = { 0 };
  struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t name_len = ((r).tok).ident_len;
  (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  size_t name_start_buf = ((r).next_lex).pos - name_len;
  (void)(parser_copy_slice_to_name64_buf(data, len, name_start_buf, name_len, (&((dummy_name)[0]))));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_I32 && ((r).tok).kind != token_TokenKind_TOKEN_I64 && ((r).tok).kind != token_TokenKind_TOKEN_BOOL && ((r).tok).kind != token_TokenKind_TOKEN_VOID && ((r).tok).kind != token_TokenKind_TOKEN_U8 && ((r).tok).kind != token_TokenKind_TOKEN_U32 && ((r).tok).kind != token_TokenKind_TOKEN_U64 && ((r).tok).kind != token_TokenKind_TOKEN_USIZE && ((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = parser_body_skip_let_const_then_if_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RETURN) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_INT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ret_val = ((r).tok).int_val;
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)((r = lexer_next_buf(lex, data, len)));
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(((out)->ok = 1));
  (void)(((out)->next_lex = lex));
  (void)(((out)->name_len = name_len));
  int32_t ni = 0;
  while (ni < 64) {
    (void)(((ni < 0 || (ni) >= 64 ? (shulang_panic_(1, 0), 0) : (((out)->name)[ni] = (ni < 0 || (ni) >= 64 ? (shulang_panic_(1, 0), (dummy_name)[0]) : (dummy_name)[ni]), 0))));
    (void)((ni = ni + 1));
  }
  (void)(((out)->return_val = ret_val));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_set_onefunc_fail(out, lex));
}
void parser_parse_one_function_library_into(struct parser_LibraryParseResult * restrict out, struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source) {
  struct parser_LibraryParseResult res = parser_parse_one_function_library(arena, module, lex, source);
  (void)(((out)->ok = (res).ok));
  (void)((((out)->_pad)[0] = ((res)._pad)[0]));
  (void)(((1 < 0 || (1) >= 4 ? (shulang_panic_(1, 0), 0) : (((out)->_pad)[1] = (1 < 0 || (1) >= 4 ? (shulang_panic_(1, 0), ((res)._pad)[0]) : ((res)._pad)[1]), 0))));
  (void)(((2 < 0 || (2) >= 4 ? (shulang_panic_(1, 0), 0) : (((out)->_pad)[2] = (2 < 0 || (2) >= 4 ? (shulang_panic_(1, 0), ((res)._pad)[0]) : ((res)._pad)[2]), 0))));
  (void)(((3 < 0 || (3) >= 4 ? (shulang_panic_(1, 0), 0) : (((out)->_pad)[3] = (3 < 0 || (3) >= 4 ? (shulang_panic_(1, 0), ((res)._pad)[0]) : ((res)._pad)[3]), 0))));
  (void)((((out)->next_lex).pos = ((res).next_lex).pos));
  (void)((((out)->next_lex).line = ((res).next_lex).line));
  (void)((((out)->next_lex).col = ((res).next_lex).col));
  int32_t nli = 0;
  while (nli < 64) {
    (void)(((nli < 0 || (nli) >= 64 ? (shulang_panic_(1, 0), 0) : (((out)->name)[nli] = (nli < 0 || (nli) >= 64 ? (shulang_panic_(1, 0), ((res).name)[0]) : ((res).name)[nli]), 0))));
    (void)((nli = nli + 1));
  }
  (void)(((out)->name_len = (res).name_len));
  (void)((((out)->_pad_tail)[0] = ((res)._pad_tail)[0]));
  (void)(((1 < 0 || (1) >= 4 ? (shulang_panic_(1, 0), 0) : (((out)->_pad_tail)[1] = (1 < 0 || (1) >= 4 ? (shulang_panic_(1, 0), ((res)._pad_tail)[0]) : ((res)._pad_tail)[1]), 0))));
  (void)(((2 < 0 || (2) >= 4 ? (shulang_panic_(1, 0), 0) : (((out)->_pad_tail)[2] = (2 < 0 || (2) >= 4 ? (shulang_panic_(1, 0), ((res)._pad_tail)[0]) : ((res)._pad_tail)[2]), 0))));
  (void)(((3 < 0 || (3) >= 4 ? (shulang_panic_(1, 0), 0) : (((out)->_pad_tail)[3] = (3 < 0 || (3) >= 4 ? (shulang_panic_(1, 0), ((res)._pad_tail)[0]) : ((res)._pad_tail)[3]), 0))));
}
void parser_parse_into_try_skip_allow_into(struct parser_TrySkipAllowResult * restrict out, struct lexer_Lexer lex, struct lexer_LexerResult r, struct shulang_slice_uint8_t * source) {
  struct parser_TrySkipAllowResult res = parser_parse_into_try_skip_allow(lex, r, source);
  (void)((((out)->lex).pos = ((res).lex).pos));
  (void)((((out)->lex).line = ((res).lex).line));
  (void)((((out)->lex).col = ((res).lex).col));
  (void)(((out)->skipped = (res).skipped));
  (void)((((out)->_pad)[0] = ((res)._pad)[0]));
  (void)(((1 < 0 || (1) >= 4 ? (shulang_panic_(1, 0), 0) : (((out)->_pad)[1] = (1 < 0 || (1) >= 4 ? (shulang_panic_(1, 0), ((res)._pad)[0]) : ((res)._pad)[1]), 0))));
  (void)(((2 < 0 || (2) >= 4 ? (shulang_panic_(1, 0), 0) : (((out)->_pad)[2] = (2 < 0 || (2) >= 4 ? (shulang_panic_(1, 0), ((res)._pad)[0]) : ((res)._pad)[2]), 0))));
  (void)(((3 < 0 || (3) >= 4 ? (shulang_panic_(1, 0), 0) : (((out)->_pad)[3] = (3 < 0 || (3) >= 4 ? (shulang_panic_(1, 0), ((res)._pad)[0]) : ((res)._pad)[3]), 0))));
}
void parser_parse_into_try_skip_allow_into_buf(struct parser_TrySkipAllowResult * restrict out, struct lexer_Lexer lex, struct lexer_LexerResult r, uint8_t * restrict data, int32_t len) {
  struct parser_TrySkipAllowResult res = parser_parse_into_try_skip_allow_buf(lex, r, data, len);
  (void)((((out)->lex).pos = ((res).lex).pos));
  (void)((((out)->lex).line = ((res).lex).line));
  (void)((((out)->lex).col = ((res).lex).col));
  (void)(((out)->skipped = (res).skipped));
}
struct parser_ParseIntoResult parser_parse_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct shulang_slice_uint8_t * source) {
  struct lexer_Lexer lex = lexer_init();
  int32_t main_idx = (-1);
  struct parser_CollectImportsResult import_res = (struct parser_CollectImportsResult){ .lex = lex };
  (void)(parser_collect_imports(lex, source, module, (&(import_res))));
  (void)(parser_copy_lex_from_import_into((&(lex)), import_res));
  int32_t loop_count = 0;
  while (1) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (loop_count >= 131072) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1003) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((loop_count = loop_count + 1));
    struct lexer_Lexer iter_start = lex;
    struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STRUCT) {   int32_t ap_struct = (module)->pending_allow_padding;
  (void)(((module)->pending_allow_padding = 0));
  (void)(({ int32_t __tmp = 0; if (parser_parse_struct_record_layout_into(arena, module, lex, source, (&(lex)), ap_struct) != 0) {   (void)(parser_skip_one_struct_into((&(lex)), iter_start, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ENUM) {   (void)(parser_skip_one_enum_register_into(module, (&(lex)), iter_start, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EXTERN) {   (void)(parser_parse_one_extern_and_add_into(arena, module, lex, source, (&(lex))));
  (void)(({ int32_t __tmp = 0; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   (void)(parser_skip_one_extern_into((&(lex)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_TRAIT) {   (void)(parser_skip_one_trait_into((&(lex)), iter_start, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IMPL) {   (void)(parser_skip_one_impl_into((&(lex)), iter_start, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   struct parser_TrySkipAllowResult try_res = ({ struct parser_TrySkipAllowResult _t = { 0 }; _t.lex = lex; _t.skipped = 0; _t; });
  (void)(parser_parse_into_try_skip_allow_into((&(try_res)), lex, r, source));
  (void)(({ int32_t __tmp = 0; if ((try_res).skipped != 0) {   (void)(((module)->pending_allow_padding = 1));
  (void)(parser_lex_from_try_skip_into((&(lex)), try_res));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   break;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if ((module)->num_funcs == 0) {   return (struct parser_ParseIntoResult){ .ok = 0, .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  int32_t out_idx_storage[1] = { 0 };
  (void)(((out_idx_storage)[0] = main_idx));
  return (struct parser_ParseIntoResult){ .ok = 0, .main_idx = (out_idx_storage)[0] };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    struct lexer_Lexer lex_at_function = lex;
    (void)(parser_lex_from_next_into((&(lex)), r));
    uint8_t parse_into_empty64[64] = { 0 };
    struct parser_OneFuncResult res = parser_onefunc_scratch_empty();
    (void)(parser_onefunc_res_wire_dummy_head((&(res)), lex, parse_into_empty64));
    (void)(parser_onefunc_res_wire_dummy_const_let((&(res))));
    (void)(parser_onefunc_res_wire_dummy_if_mul((&(res))));
    (void)(parser_onefunc_res_wire_dummy_call_binop((&(res)), parse_into_empty64));
    (void)(parser_onefunc_res_wire_dummy_loop_call((&(res))));
    (void)(parser_onefunc_res_wire_dummy_for_if((&(res))));
    uint8_t empty64_lib_first[64] = { 0 };
    struct parser_LibraryParseResult lib_first = ({ struct parser_LibraryParseResult _t = { 0 }; _t.ok = 0; _t.next_lex = lex_at_function; _t.name_len = 0; memcpy(_t.name, empty64_lib_first, sizeof(_t.name)); _t; });
    (void)(parser_parse_one_function_library_into((&(lib_first)), arena, module, lex_at_function, source));
    (void)(({ int32_t __tmp = 0; if ((lib_first).ok) {   (void)(parser_lex_from_library_into((&(lex)), lib_first));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (lex_at_function).pos && (lex).pos < (source)->length) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_parse_one_function_impl((&(res)), arena, lex, source));
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if ((!(res).ok)) {   return (struct parser_ParseIntoResult){ .ok = (-2), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    int32_t is_main_storage[1] = { 0 };
    (void)(({ int32_t __tmp = 0; if ((res).name_len == 4 && ((res).name)[0] == 109 && (1 < 0 || (1) >= 64 ? (shulang_panic_(1, 0), ((res).name)[0]) : ((res).name)[1]) == 97 && (2 < 0 || (2) >= 64 ? (shulang_panic_(1, 0), ((res).name)[0]) : ((res).name)[2]) == 105 && (3 < 0 || (3) >= 64 ? (shulang_panic_(1, 0), ((res).name)[0]) : ((res).name)[3]) == 110) {   (void)(((is_main_storage)[0] = 1));
 } else (__tmp = 0) ; __tmp; }));
    int32_t type_ref = (res).func_return_type_ref;
    (void)(({ int32_t __tmp = 0; if (type_ref == 0) {   (void)((type_ref = ast_arena_type_alloc(arena)));
  (void)(({ int32_t __tmp = 0; if (type_ref == 0 && (module)->num_funcs == 0) {   (void)(ast_arena_init(arena));
  (void)((type_ref = ast_arena_type_alloc(arena)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (type_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1001) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Type t_fb;
  t_fb = pipeline_arena_type_get_copy(arena, type_ref);
  (void)(((t_fb).kind = ast_TypeKind_TYPE_I32));
  (void)(((t_fb).name_len = 0));
  (void)(((t_fb).elem_type_ref = 0));
  (void)(((t_fb).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref, t_fb));
 } else (__tmp = 0) ; __tmp; }));
    int32_t expr_ref = ast_arena_expr_alloc(arena);
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (expr_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1002) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    struct ast_Expr e;
    e = pipeline_arena_expr_get_copy(arena, expr_ref);
    (void)(({ int32_t __tmp = 0; if ((res).return_var_name_len > 0) {   (void)(((e).kind = ast_ExprKind_EXPR_VAR));
  (void)(((e).var_name_len = (res).return_var_name_len));
  int32_t rvi = 0;
  while (rvi < (res).return_var_name_len && rvi < 64) {
    (void)(((rvi < 0 || (rvi) >= 64 ? (shulang_panic_(1, 0), 0) : (((e).var_name)[rvi] = (rvi < 0 || (rvi) >= 64 ? (shulang_panic_(1, 0), ((res).return_var_name)[0]) : ((res).return_var_name)[rvi]), 0))));
    (void)((rvi = rvi + 1));
  }
  uint8_t rvz = 0;
  while (rvi < 64) {
    (void)(((rvi < 0 || (rvi) >= 64 ? (shulang_panic_(1, 0), 0) : (((e).var_name)[rvi] = rvz, 0))));
    (void)((rvi = rvi + 1));
  }
  (void)(((e).int_val = 0));
  (void)(((e).resolved_type_ref = 0));
 } else {   (void)(((e).kind = ast_ExprKind_EXPR_LIT));
  (void)(((e).resolved_type_ref = type_ref));
  (void)(((e).int_val = (res).return_val));
 } ; __tmp; }));
    (void)(((e).line = 0));
    (void)(((e).col = 0));
    (void)(((e).binop_left_ref = 0));
    (void)(((e).binop_right_ref = 0));
    (void)(((e).unary_operand_ref = 0));
    (void)(((e).if_cond_ref = 0));
    (void)(((e).if_then_ref = 0));
    (void)(((e).if_else_ref = 0));
    (void)(((e).block_ref = 0));
    (void)(((e).match_matched_ref = 0));
    (void)(((e).match_num_arms = 0));
    (void)(ast_expr_init_match_enum((&(e))));
    (void)(((e).field_access_base_ref = 0));
    (void)(((e).field_access_field_len = 0));
    (void)(((e).field_access_is_enum_variant = 0));
    (void)(((e).field_access_offset = 0));
    (void)(((e).index_base_ref = 0));
    (void)(((e).index_index_ref = 0));
    (void)(((e).index_base_is_slice = 0));
    (void)(((e).call_callee_ref = 0));
    (void)(((e).call_num_args = 0));
    (void)(((e).method_call_base_ref = 0));
    (void)(((e).method_call_name_len = 0));
    (void)(((e).method_call_num_args = 0));
    (void)(((e).const_folded_val = 0));
    (void)(((e).const_folded_valid = 0));
    (void)(((e).index_proven_in_bounds = 0));
    (void)(ast_arena_expr_set(arena, expr_ref, e));
    int32_t final_expr_ref = expr_ref;
    (void)(({ int32_t __tmp = 0; if ((res).return_expr_ref != 0) {   (void)((final_expr_ref = (res).return_expr_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).return_var_name_len > 0 && (res).return_expr_ref == 0) {   int32_t var_wrapped = parser_expr_wrap_in_return(arena, type_ref, final_expr_ref);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (var_wrapped == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1003) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (void)((final_expr_ref = var_wrapped));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_mul && (!(res).has_binop)) {   int32_t mul_right_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_right_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr mre;
  mre = pipeline_arena_expr_get_copy(arena, mul_right_ref);
  (void)(((mre).kind = ast_ExprKind_EXPR_LIT));
  (void)(((mre).resolved_type_ref = type_ref));
  (void)(((mre).line = 0));
  (void)(((mre).col = 0));
  (void)(((mre).int_val = (res).mul_right_val));
  (void)(((mre).binop_left_ref = 0));
  (void)(((mre).binop_right_ref = 0));
  (void)(((mre).unary_operand_ref = 0));
  (void)(((mre).if_cond_ref = 0));
  (void)(((mre).if_then_ref = 0));
  (void)(((mre).if_else_ref = 0));
  (void)(((mre).block_ref = 0));
  (void)(((mre).match_matched_ref = 0));
  (void)(((mre).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(mre))));
  (void)(((mre).field_access_base_ref = 0));
  (void)(((mre).field_access_field_len = 0));
  (void)(((mre).field_access_is_enum_variant = 0));
  (void)(((mre).field_access_offset = 0));
  (void)(((mre).index_base_ref = 0));
  (void)(((mre).index_index_ref = 0));
  (void)(((mre).index_base_is_slice = 0));
  (void)(((mre).call_callee_ref = 0));
  (void)(((mre).call_num_args = 0));
  (void)(((mre).method_call_base_ref = 0));
  (void)(((mre).method_call_name_len = 0));
  (void)(((mre).method_call_num_args = 0));
  (void)(((mre).const_folded_val = 0));
  (void)(((mre).const_folded_valid = 0));
  (void)(((mre).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, mul_right_ref, mre));
  int32_t mul_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr me;
  me = pipeline_arena_expr_get_copy(arena, mul_ref);
  (void)(((me).kind = ast_ExprKind_EXPR_MUL));
  (void)(((me).resolved_type_ref = type_ref));
  (void)(((me).line = 0));
  (void)(((me).col = 0));
  (void)(((me).int_val = 0));
  (void)(((me).binop_left_ref = final_expr_ref));
  (void)(((me).binop_right_ref = mul_right_ref));
  (void)(((me).unary_operand_ref = 0));
  (void)(((me).if_cond_ref = 0));
  (void)(((me).if_then_ref = 0));
  (void)(((me).if_else_ref = 0));
  (void)(((me).block_ref = 0));
  (void)(((me).match_matched_ref = 0));
  (void)(((me).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(me))));
  (void)(((me).field_access_base_ref = 0));
  (void)(((me).field_access_field_len = 0));
  (void)(((me).field_access_is_enum_variant = 0));
  (void)(((me).field_access_offset = 0));
  (void)(((me).index_base_ref = 0));
  (void)(((me).index_index_ref = 0));
  (void)(((me).index_base_is_slice = 0));
  (void)(((me).call_callee_ref = 0));
  (void)(((me).call_num_args = 0));
  (void)(((me).method_call_base_ref = 0));
  (void)(((me).method_call_name_len = 0));
  (void)(((me).method_call_num_args = 0));
  (void)(((me).const_folded_val = 0));
  (void)(((me).const_folded_valid = 0));
  (void)(((me).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, mul_ref, me));
  (void)((final_expr_ref = mul_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_if_expr) {   int32_t cond_ref = 0;
  (void)(({ int32_t __tmp = 0; if ((res).if_cond_expr_ref != 0) {   (void)((cond_ref = (res).if_cond_expr_ref));
 } else {   int32_t bool_type_ref = ast_arena_type_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (bool_type_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1005) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Type bt;
  bt = pipeline_arena_type_get_copy(arena, bool_type_ref);
  (void)(((bt).kind = ast_TypeKind_TYPE_BOOL));
  (void)(((bt).name_len = 0));
  (void)(((bt).elem_type_ref = 0));
  (void)(((bt).array_size = 0));
  (void)(ast_arena_type_set(arena, bool_type_ref, bt));
  (void)((cond_ref = ast_arena_expr_alloc(arena)));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (cond_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ce;
  ce = pipeline_arena_expr_get_copy(arena, cond_ref);
  (void)(((ce).kind = ast_ExprKind_EXPR_BOOL_LIT));
  (void)(((ce).resolved_type_ref = bool_type_ref));
  (void)(((ce).line = 0));
  (void)(((ce).col = 0));
  (void)(({ int32_t __tmp = 0; if ((res).if_cond_true) {   (void)(((ce).int_val = 1));
 } else {   (void)(((ce).int_val = 0));
 } ; __tmp; }));
  (void)(((ce).binop_left_ref = 0));
  (void)(((ce).binop_right_ref = 0));
  (void)(((ce).unary_operand_ref = 0));
  (void)(((ce).if_cond_ref = 0));
  (void)(((ce).if_then_ref = 0));
  (void)(((ce).if_else_ref = 0));
  (void)(((ce).block_ref = 0));
  (void)(((ce).match_matched_ref = 0));
  (void)(((ce).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(ce))));
  (void)(((ce).field_access_base_ref = 0));
  (void)(((ce).field_access_field_len = 0));
  (void)(((ce).field_access_is_enum_variant = 0));
  (void)(((ce).field_access_offset = 0));
  (void)(((ce).index_base_ref = 0));
  (void)(((ce).index_index_ref = 0));
  (void)(((ce).index_base_is_slice = 0));
  (void)(((ce).call_callee_ref = 0));
  (void)(((ce).call_num_args = 0));
  (void)(((ce).method_call_base_ref = 0));
  (void)(((ce).method_call_name_len = 0));
  (void)(((ce).method_call_num_args = 0));
  (void)(((ce).const_folded_val = 0));
  (void)(((ce).const_folded_valid = 0));
  (void)(((ce).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, cond_ref, ce));
 } ; __tmp; }));
  int32_t then_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (then_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr te;
  te = pipeline_arena_expr_get_copy(arena, then_ref);
  (void)(((te).kind = ast_ExprKind_EXPR_LIT));
  (void)(((te).resolved_type_ref = type_ref));
  (void)(((te).line = 0));
  (void)(((te).col = 0));
  (void)(((te).int_val = (res).if_then_val));
  (void)(((te).binop_left_ref = 0));
  (void)(((te).binop_right_ref = 0));
  (void)(((te).unary_operand_ref = 0));
  (void)(((te).if_cond_ref = 0));
  (void)(((te).if_then_ref = 0));
  (void)(((te).if_else_ref = 0));
  (void)(((te).block_ref = 0));
  (void)(((te).match_matched_ref = 0));
  (void)(((te).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(te))));
  (void)(((te).field_access_base_ref = 0));
  (void)(((te).field_access_field_len = 0));
  (void)(((te).field_access_is_enum_variant = 0));
  (void)(((te).field_access_offset = 0));
  (void)(((te).index_base_ref = 0));
  (void)(((te).index_index_ref = 0));
  (void)(((te).index_base_is_slice = 0));
  (void)(((te).call_callee_ref = 0));
  (void)(((te).call_num_args = 0));
  (void)(((te).method_call_base_ref = 0));
  (void)(((te).method_call_name_len = 0));
  (void)(((te).method_call_num_args = 0));
  (void)(((te).const_folded_val = 0));
  (void)(((te).const_folded_valid = 0));
  (void)(((te).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, then_ref, te));
  int32_t else_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (else_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ee;
  ee = pipeline_arena_expr_get_copy(arena, else_ref);
  (void)(((ee).kind = ast_ExprKind_EXPR_LIT));
  (void)(((ee).resolved_type_ref = type_ref));
  (void)(((ee).line = 0));
  (void)(((ee).col = 0));
  (void)(((ee).int_val = (res).if_else_val));
  (void)(((ee).binop_left_ref = 0));
  (void)(((ee).binop_right_ref = 0));
  (void)(((ee).unary_operand_ref = 0));
  (void)(((ee).if_cond_ref = 0));
  (void)(((ee).if_then_ref = 0));
  (void)(((ee).if_else_ref = 0));
  (void)(((ee).block_ref = 0));
  (void)(((ee).match_matched_ref = 0));
  (void)(((ee).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(ee))));
  (void)(((ee).field_access_base_ref = 0));
  (void)(((ee).field_access_field_len = 0));
  (void)(((ee).field_access_is_enum_variant = 0));
  (void)(((ee).field_access_offset = 0));
  (void)(((ee).index_base_ref = 0));
  (void)(((ee).index_index_ref = 0));
  (void)(((ee).index_base_is_slice = 0));
  (void)(((ee).call_callee_ref = 0));
  (void)(((ee).call_num_args = 0));
  (void)(((ee).method_call_base_ref = 0));
  (void)(((ee).method_call_name_len = 0));
  (void)(((ee).method_call_num_args = 0));
  (void)(((ee).const_folded_val = 0));
  (void)(((ee).const_folded_valid = 0));
  (void)(((ee).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, else_ref, ee));
  int32_t if_expr_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (if_expr_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ie;
  ie = pipeline_arena_expr_get_copy(arena, if_expr_ref);
  (void)(((ie).kind = ast_ExprKind_EXPR_IF));
  (void)(((ie).resolved_type_ref = type_ref));
  (void)(((ie).line = 0));
  (void)(((ie).col = 0));
  (void)(((ie).int_val = 0));
  (void)(((ie).binop_left_ref = 0));
  (void)(((ie).binop_right_ref = 0));
  (void)(((ie).unary_operand_ref = 0));
  (void)(((ie).if_cond_ref = cond_ref));
  (void)(((ie).if_then_ref = then_ref));
  (void)(((ie).if_else_ref = else_ref));
  (void)(((ie).block_ref = 0));
  (void)(((ie).match_matched_ref = 0));
  (void)(((ie).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(ie))));
  (void)(((ie).field_access_base_ref = 0));
  (void)(((ie).field_access_field_len = 0));
  (void)(((ie).field_access_is_enum_variant = 0));
  (void)(((ie).field_access_offset = 0));
  (void)(((ie).index_base_ref = 0));
  (void)(((ie).index_index_ref = 0));
  (void)(((ie).index_base_is_slice = 0));
  (void)(((ie).call_callee_ref = 0));
  (void)(((ie).call_num_args = 0));
  (void)(((ie).method_call_base_ref = 0));
  (void)(((ie).method_call_name_len = 0));
  (void)(((ie).method_call_num_args = 0));
  (void)(((ie).const_folded_val = 0));
  (void)(((ie).const_folded_valid = 0));
  (void)(((ie).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, if_expr_ref, ie));
  (void)((final_expr_ref = if_expr_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_binop) {   uint8_t * res_pool = parser_onefunc_result_pool_ptr((&(res)));
  int32_t left_ref = final_expr_ref;
  (void)(({ int32_t __tmp = 0; if ((res).binop_left_param_idx >= 0 && (res).binop_left_param_idx < (res).num_params) {   int32_t lpr = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (lpr != 0) {   struct ast_Expr lpe;
  lpe = pipeline_arena_expr_get_copy(arena, lpr);
  (void)(((lpe).kind = ast_ExprKind_EXPR_VAR));
  (void)(((lpe).resolved_type_ref = type_ref));
  (void)(((lpe).line = 0));
  (void)(((lpe).col = 0));
  (void)(((lpe).var_name_len = pipeline_onefunc_param_name_len(res_pool, (res).binop_left_param_idx)));
  int32_t lk = 0;
  while (lk < (lpe).var_name_len && lk < 64) {
    (void)(((lk < 0 || (lk) >= 64 ? (shulang_panic_(1, 0), 0) : (((lpe).var_name)[lk] = pipeline_onefunc_param_name_byte_at(res_pool, (res).binop_left_param_idx, lk), 0))));
    (void)((lk = lk + 1));
  }
  uint8_t lz = 0;
  while (lk < 64) {
    (void)(((lk < 0 || (lk) >= 64 ? (shulang_panic_(1, 0), 0) : (((lpe).var_name)[lk] = lz, 0))));
    (void)((lk = lk + 1));
  }
  (void)(((lpe).binop_left_ref = 0));
  (void)(((lpe).binop_right_ref = 0));
  (void)(((lpe).unary_operand_ref = 0));
  (void)(((lpe).if_cond_ref = 0));
  (void)(((lpe).if_then_ref = 0));
  (void)(((lpe).if_else_ref = 0));
  (void)(((lpe).block_ref = 0));
  (void)(((lpe).match_matched_ref = 0));
  (void)(((lpe).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(lpe))));
  (void)(((lpe).field_access_base_ref = 0));
  (void)(((lpe).field_access_field_len = 0));
  (void)(((lpe).field_access_is_enum_variant = 0));
  (void)(((lpe).field_access_offset = 0));
  (void)(((lpe).index_base_ref = 0));
  (void)(((lpe).index_index_ref = 0));
  (void)(((lpe).index_base_is_slice = 0));
  (void)(((lpe).call_callee_ref = 0));
  (void)(((lpe).call_num_args = 0));
  (void)(((lpe).method_call_base_ref = 0));
  (void)(((lpe).method_call_name_len = 0));
  (void)(((lpe).method_call_num_args = 0));
  (void)(((lpe).const_folded_val = 0));
  (void)(((lpe).const_folded_valid = 0));
  (void)(((lpe).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, lpr, lpe));
  (void)((left_ref = lpr));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t right_ref = 0;
  (void)(({ int32_t __tmp = 0; if ((res).binop_right_param_idx >= 0 && (res).binop_right_param_idx < (res).num_params) {   int32_t rpr = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (rpr != 0) {   struct ast_Expr rpe;
  rpe = pipeline_arena_expr_get_copy(arena, rpr);
  (void)(((rpe).kind = ast_ExprKind_EXPR_VAR));
  (void)(((rpe).resolved_type_ref = type_ref));
  (void)(((rpe).line = 0));
  (void)(((rpe).col = 0));
  (void)(((rpe).var_name_len = pipeline_onefunc_param_name_len(res_pool, (res).binop_right_param_idx)));
  int32_t rk = 0;
  while (rk < (rpe).var_name_len && rk < 64) {
    (void)(((rk < 0 || (rk) >= 64 ? (shulang_panic_(1, 0), 0) : (((rpe).var_name)[rk] = pipeline_onefunc_param_name_byte_at(res_pool, (res).binop_right_param_idx, rk), 0))));
    (void)((rk = rk + 1));
  }
  uint8_t rz = 0;
  while (rk < 64) {
    (void)(((rk < 0 || (rk) >= 64 ? (shulang_panic_(1, 0), 0) : (((rpe).var_name)[rk] = rz, 0))));
    (void)((rk = rk + 1));
  }
  (void)(((rpe).binop_left_ref = 0));
  (void)(((rpe).binop_right_ref = 0));
  (void)(((rpe).unary_operand_ref = 0));
  (void)(((rpe).if_cond_ref = 0));
  (void)(((rpe).if_then_ref = 0));
  (void)(((rpe).if_else_ref = 0));
  (void)(((rpe).block_ref = 0));
  (void)(((rpe).match_matched_ref = 0));
  (void)(((rpe).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(rpe))));
  (void)(((rpe).field_access_base_ref = 0));
  (void)(((rpe).field_access_field_len = 0));
  (void)(((rpe).field_access_is_enum_variant = 0));
  (void)(((rpe).field_access_offset = 0));
  (void)(((rpe).index_base_ref = 0));
  (void)(((rpe).index_index_ref = 0));
  (void)(((rpe).index_base_is_slice = 0));
  (void)(((rpe).call_callee_ref = 0));
  (void)(((rpe).call_num_args = 0));
  (void)(((rpe).method_call_base_ref = 0));
  (void)(((rpe).method_call_name_len = 0));
  (void)(((rpe).method_call_num_args = 0));
  (void)(((rpe).const_folded_val = 0));
  (void)(((rpe).const_folded_valid = 0));
  (void)(((rpe).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, rpr, rpe));
  (void)((right_ref = rpr));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((res).has_mul) {   int32_t mul_left_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_left_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr mle;
  mle = pipeline_arena_expr_get_copy(arena, mul_left_ref);
  (void)(((mle).kind = ast_ExprKind_EXPR_LIT));
  (void)(((mle).resolved_type_ref = type_ref));
  (void)(((mle).line = 0));
  (void)(((mle).col = 0));
  (void)(((mle).int_val = (res).binop_right_val));
  (void)(((mle).binop_left_ref = 0));
  (void)(((mle).binop_right_ref = 0));
  (void)(((mle).unary_operand_ref = 0));
  (void)(((mle).if_cond_ref = 0));
  (void)(((mle).if_then_ref = 0));
  (void)(((mle).if_else_ref = 0));
  (void)(((mle).block_ref = 0));
  (void)(((mle).match_matched_ref = 0));
  (void)(((mle).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(mle))));
  (void)(((mle).field_access_base_ref = 0));
  (void)(((mle).field_access_field_len = 0));
  (void)(((mle).field_access_is_enum_variant = 0));
  (void)(((mle).field_access_offset = 0));
  (void)(((mle).index_base_ref = 0));
  (void)(((mle).index_index_ref = 0));
  (void)(((mle).index_base_is_slice = 0));
  (void)(((mle).call_callee_ref = 0));
  (void)(((mle).call_num_args = 0));
  (void)(((mle).method_call_base_ref = 0));
  (void)(((mle).method_call_name_len = 0));
  (void)(((mle).method_call_num_args = 0));
  (void)(((mle).const_folded_val = 0));
  (void)(((mle).const_folded_valid = 0));
  (void)(((mle).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, mul_left_ref, mle));
  int32_t mul_r_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_r_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr mre;
  mre = pipeline_arena_expr_get_copy(arena, mul_r_ref);
  (void)(((mre).kind = ast_ExprKind_EXPR_LIT));
  (void)(((mre).resolved_type_ref = type_ref));
  (void)(((mre).line = 0));
  (void)(((mre).col = 0));
  (void)(((mre).int_val = (res).mul_right_val));
  (void)(((mre).binop_left_ref = 0));
  (void)(((mre).binop_right_ref = 0));
  (void)(((mre).unary_operand_ref = 0));
  (void)(((mre).if_cond_ref = 0));
  (void)(((mre).if_then_ref = 0));
  (void)(((mre).if_else_ref = 0));
  (void)(((mre).block_ref = 0));
  (void)(((mre).match_matched_ref = 0));
  (void)(((mre).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(mre))));
  (void)(((mre).field_access_base_ref = 0));
  (void)(((mre).field_access_field_len = 0));
  (void)(((mre).field_access_is_enum_variant = 0));
  (void)(((mre).field_access_offset = 0));
  (void)(((mre).index_base_ref = 0));
  (void)(((mre).index_index_ref = 0));
  (void)(((mre).index_base_is_slice = 0));
  (void)(((mre).call_callee_ref = 0));
  (void)(((mre).call_num_args = 0));
  (void)(((mre).method_call_base_ref = 0));
  (void)(((mre).method_call_name_len = 0));
  (void)(((mre).method_call_num_args = 0));
  (void)(((mre).const_folded_val = 0));
  (void)(((mre).const_folded_valid = 0));
  (void)(((mre).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, mul_r_ref, mre));
  int32_t mul_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr me;
  me = pipeline_arena_expr_get_copy(arena, mul_ref);
  (void)(((me).kind = ast_ExprKind_EXPR_MUL));
  (void)(((me).resolved_type_ref = type_ref));
  (void)(((me).line = 0));
  (void)(((me).col = 0));
  (void)(((me).int_val = 0));
  (void)(((me).binop_left_ref = mul_left_ref));
  (void)(((me).binop_right_ref = mul_r_ref));
  (void)(((me).unary_operand_ref = 0));
  (void)(((me).if_cond_ref = 0));
  (void)(((me).if_then_ref = 0));
  (void)(((me).if_else_ref = 0));
  (void)(((me).block_ref = 0));
  (void)(((me).match_matched_ref = 0));
  (void)(((me).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(me))));
  (void)(((me).field_access_base_ref = 0));
  (void)(((me).field_access_field_len = 0));
  (void)(((me).field_access_is_enum_variant = 0));
  (void)(((me).field_access_offset = 0));
  (void)(((me).index_base_ref = 0));
  (void)(((me).index_index_ref = 0));
  (void)(((me).index_base_is_slice = 0));
  (void)(((me).call_callee_ref = 0));
  (void)(((me).call_num_args = 0));
  (void)(((me).method_call_base_ref = 0));
  (void)(((me).method_call_name_len = 0));
  (void)(((me).method_call_num_args = 0));
  (void)(((me).const_folded_val = 0));
  (void)(((me).const_folded_valid = 0));
  (void)(((me).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, mul_ref, me));
  (void)((right_ref = mul_ref));
 } else {   (void)((right_ref = ast_arena_expr_alloc(arena)));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (right_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr re;
  re = pipeline_arena_expr_get_copy(arena, right_ref);
  (void)(((re).kind = ast_ExprKind_EXPR_LIT));
  (void)(((re).resolved_type_ref = type_ref));
  (void)(((re).line = 0));
  (void)(((re).col = 0));
  (void)(((re).int_val = (res).binop_right_val));
  (void)(((re).binop_left_ref = 0));
  (void)(((re).binop_right_ref = 0));
  (void)(((re).unary_operand_ref = 0));
  (void)(((re).if_cond_ref = 0));
  (void)(((re).if_then_ref = 0));
  (void)(((re).if_else_ref = 0));
  (void)(((re).block_ref = 0));
  (void)(((re).match_matched_ref = 0));
  (void)(((re).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(re))));
  (void)(((re).field_access_base_ref = 0));
  (void)(((re).field_access_field_len = 0));
  (void)(((re).field_access_is_enum_variant = 0));
  (void)(((re).field_access_offset = 0));
  (void)(((re).index_base_ref = 0));
  (void)(((re).index_index_ref = 0));
  (void)(((re).index_base_is_slice = 0));
  (void)(((re).call_callee_ref = 0));
  (void)(((re).call_num_args = 0));
  (void)(((re).method_call_base_ref = 0));
  (void)(((re).method_call_name_len = 0));
  (void)(((re).method_call_num_args = 0));
  (void)(((re).const_folded_val = 0));
  (void)(((re).const_folded_valid = 0));
  (void)(((re).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, right_ref, re));
 } ; __tmp; })) ; __tmp; }));
  int32_t add_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (add_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ae;
  ae = pipeline_arena_expr_get_copy(arena, add_ref);
  (void)(((ae).kind = ast_ExprKind_EXPR_ADD));
  (void)(((ae).resolved_type_ref = type_ref));
  (void)(((ae).line = 0));
  (void)(((ae).col = 0));
  (void)(((ae).int_val = 0));
  (void)(((ae).binop_left_ref = left_ref));
  (void)(((ae).binop_right_ref = right_ref));
  (void)(((ae).unary_operand_ref = 0));
  (void)(((ae).if_cond_ref = 0));
  (void)(((ae).if_then_ref = 0));
  (void)(((ae).if_else_ref = 0));
  (void)(((ae).block_ref = 0));
  (void)(((ae).match_matched_ref = 0));
  (void)(((ae).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(ae))));
  (void)(((ae).field_access_base_ref = 0));
  (void)(((ae).field_access_field_len = 0));
  (void)(((ae).field_access_is_enum_variant = 0));
  (void)(((ae).field_access_offset = 0));
  (void)(((ae).index_base_ref = 0));
  (void)(((ae).index_index_ref = 0));
  (void)(((ae).index_base_is_slice = 0));
  (void)(((ae).call_callee_ref = 0));
  (void)(((ae).call_num_args = 0));
  (void)(((ae).method_call_base_ref = 0));
  (void)(((ae).method_call_name_len = 0));
  (void)(((ae).method_call_num_args = 0));
  (void)(((ae).const_folded_val = 0));
  (void)(((ae).const_folded_valid = 0));
  (void)(((ae).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, add_ref, ae));
  (void)((final_expr_ref = add_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_unary_neg) {   int32_t operand_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (operand_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr oe;
  oe = pipeline_arena_expr_get_copy(arena, operand_ref);
  (void)(((oe).kind = ast_ExprKind_EXPR_LIT));
  (void)(((oe).resolved_type_ref = type_ref));
  (void)(((oe).line = 0));
  (void)(((oe).col = 0));
  (void)(((oe).int_val = (res).return_val));
  (void)(((oe).binop_left_ref = 0));
  (void)(((oe).binop_right_ref = 0));
  (void)(((oe).unary_operand_ref = 0));
  (void)(((oe).if_cond_ref = 0));
  (void)(((oe).if_then_ref = 0));
  (void)(((oe).if_else_ref = 0));
  (void)(((oe).block_ref = 0));
  (void)(((oe).match_matched_ref = 0));
  (void)(((oe).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(oe))));
  (void)(((oe).field_access_base_ref = 0));
  (void)(((oe).field_access_field_len = 0));
  (void)(((oe).field_access_is_enum_variant = 0));
  (void)(((oe).field_access_offset = 0));
  (void)(((oe).index_base_ref = 0));
  (void)(((oe).index_index_ref = 0));
  (void)(((oe).index_base_is_slice = 0));
  (void)(((oe).call_callee_ref = 0));
  (void)(((oe).call_num_args = 0));
  (void)(((oe).method_call_base_ref = 0));
  (void)(((oe).method_call_name_len = 0));
  (void)(((oe).method_call_num_args = 0));
  (void)(((oe).const_folded_val = 0));
  (void)(((oe).const_folded_valid = 0));
  (void)(((oe).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, operand_ref, oe));
  int32_t neg_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (neg_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ne;
  ne = pipeline_arena_expr_get_copy(arena, neg_ref);
  (void)(((ne).kind = ast_ExprKind_EXPR_NEG));
  (void)(((ne).resolved_type_ref = type_ref));
  (void)(((ne).line = 0));
  (void)(((ne).col = 0));
  (void)(((ne).int_val = 0));
  (void)(((ne).binop_left_ref = 0));
  (void)(((ne).binop_right_ref = 0));
  (void)(((ne).unary_operand_ref = operand_ref));
  (void)(((ne).if_cond_ref = 0));
  (void)(((ne).if_then_ref = 0));
  (void)(((ne).if_else_ref = 0));
  (void)(((ne).block_ref = 0));
  (void)(((ne).match_matched_ref = 0));
  (void)(((ne).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(ne))));
  (void)(((ne).field_access_base_ref = 0));
  (void)(((ne).field_access_field_len = 0));
  (void)(((ne).field_access_is_enum_variant = 0));
  (void)(((ne).field_access_offset = 0));
  (void)(((ne).index_base_ref = 0));
  (void)(((ne).index_index_ref = 0));
  (void)(((ne).index_base_is_slice = 0));
  (void)(((ne).call_callee_ref = 0));
  (void)(((ne).call_num_args = 0));
  (void)(((ne).method_call_base_ref = 0));
  (void)(((ne).method_call_name_len = 0));
  (void)(((ne).method_call_num_args = 0));
  (void)(((ne).const_folded_val = 0));
  (void)(((ne).const_folded_valid = 0));
  (void)(((ne).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, neg_ref, ne));
  (void)((final_expr_ref = neg_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_call_expr && (res).return_expr_ref == 0 && (res).call_callee_len > 0 && (res).call_callee_len <= 63) {   uint8_t * call_pool = parser_onefunc_result_pool_ptr((&(res)));
  int32_t callee_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (callee_ref != 0) {   struct ast_Expr ve;
  ve = pipeline_arena_expr_get_copy(arena, callee_ref);
  (void)(((ve).kind = ast_ExprKind_EXPR_VAR));
  (void)(((ve).resolved_type_ref = 0));
  (void)(((ve).line = 0));
  (void)(((ve).col = 0));
  (void)(((ve).var_name_len = (res).call_callee_len));
  int32_t ck = 0;
  while (ck < (res).call_callee_len && ck < 64) {
    (void)(((ck < 0 || (ck) >= 64 ? (shulang_panic_(1, 0), 0) : (((ve).var_name)[ck] = (ck < 0 || (ck) >= 64 ? (shulang_panic_(1, 0), ((res).call_callee_name)[0]) : ((res).call_callee_name)[ck]), 0))));
    (void)((ck = ck + 1));
  }
  uint8_t z = 0;
  while (ck < 64) {
    (void)(((ck < 0 || (ck) >= 64 ? (shulang_panic_(1, 0), 0) : (((ve).var_name)[ck] = z, 0))));
    (void)((ck = ck + 1));
  }
  (void)(((ve).binop_left_ref = 0));
  (void)(((ve).binop_right_ref = 0));
  (void)(((ve).unary_operand_ref = 0));
  (void)(((ve).if_cond_ref = 0));
  (void)(((ve).if_then_ref = 0));
  (void)(((ve).if_else_ref = 0));
  (void)(((ve).block_ref = 0));
  (void)(((ve).match_matched_ref = 0));
  (void)(((ve).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(ve))));
  (void)(((ve).field_access_base_ref = 0));
  (void)(((ve).field_access_field_len = 0));
  (void)(((ve).field_access_is_enum_variant = 0));
  (void)(((ve).field_access_offset = 0));
  (void)(((ve).index_base_ref = 0));
  (void)(((ve).index_index_ref = 0));
  (void)(((ve).index_base_is_slice = 0));
  (void)(((ve).call_callee_ref = 0));
  (void)(((ve).call_num_args = 0));
  (void)(((ve).method_call_base_ref = 0));
  (void)(((ve).method_call_name_len = 0));
  (void)(((ve).method_call_num_args = 0));
  (void)(((ve).const_folded_val = 0));
  (void)(((ve).const_folded_valid = 0));
  (void)(((ve).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, callee_ref, ve));
  int32_t call_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (call_ref != 0) {   struct ast_Expr ce;
  ce = pipeline_arena_expr_get_copy(arena, call_ref);
  (void)(parser_expr_set_common_zeros((&(ce))));
  (void)(((ce).kind = ast_ExprKind_EXPR_CALL));
  (void)(((ce).resolved_type_ref = type_ref));
  (void)(((ce).line = 0));
  (void)(((ce).col = 0));
  (void)(((ce).call_callee_ref = callee_ref));
  (void)(({ int32_t __tmp = 0; if ((res).call_num_args > 0) {   (void)(((ce).call_num_args = (res).call_num_args));
 } else {   (void)(((ce).call_num_args = (res).num_params));
 } ; __tmp; }));
  (void)(ast_arena_expr_set(arena, call_ref, ce));
  int32_t arg_i = 0;
  while (arg_i < (ce).call_num_args) {
    int32_t arg_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (arg_ref != 0) {   struct ast_Expr ae;
  ae = pipeline_arena_expr_get_copy(arena, arg_ref);
  (void)(((ae).resolved_type_ref = 0));
  (void)(((ae).line = 0));
  (void)(((ae).col = 0));
  (void)(({ int32_t __tmp = 0; if ((res).call_num_args > 0 && arg_i < (res).call_num_args) {   (void)(((ae).kind = ast_ExprKind_EXPR_LIT));
  (void)(((ae).int_val = pipeline_onefunc_call_arg_val_at(call_pool, arg_i)));
 } else {   (void)(((ae).kind = ast_ExprKind_EXPR_VAR));
  (void)(((ae).var_name_len = pipeline_onefunc_param_name_len(call_pool, arg_i)));
  int32_t k = 0;
  while (k < (ae).var_name_len && k < 64) {
    (void)(((k < 0 || (k) >= 64 ? (shulang_panic_(1, 0), 0) : (((ae).var_name)[k] = pipeline_onefunc_param_name_byte_at(call_pool, arg_i, k), 0))));
    (void)((k = k + 1));
  }
  uint8_t z = 0;
  while (k < 64) {
    (void)(((k < 0 || (k) >= 64 ? (shulang_panic_(1, 0), 0) : (((ae).var_name)[k] = z, 0))));
    (void)((k = k + 1));
  }
 } ; __tmp; }));
  (void)(parser_expr_set_common_zeros((&(ae))));
  (void)(ast_arena_expr_set(arena, arg_ref, ae));
  (void)(pipeline_expr_append_call_arg(arena, call_ref, arg_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)((arg_i = arg_i + 1));
  }
  (void)((final_expr_ref = call_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    int32_t block_ref = ast_arena_block_alloc(arena);
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (block_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1010) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    struct ast_Block b;
    b = pipeline_arena_block_get_copy(arena, block_ref);
    (void)(((b).num_consts = (res).num_consts));
    (void)(((b).num_lets = (res).num_lets));
    (void)(((b).num_early_lets = 0));
    (void)(((b).num_loops = (res).num_loops));
    (void)(((b).num_for_loops = (res).num_for_loops));
    (void)(((b).num_if_stmts = (res).num_if_stmts));
    (void)(((b).num_defers = 0));
    (void)(((b).num_labeled_stmts = 0));
    (void)(((b).num_expr_stmts = 0));
    (void)(({ int32_t __tmp = 0; if (parser_should_wrap_func_tail_in_return(arena, (&(res)), type_ref)) {   int32_t wrapped_fe = parser_expr_wrap_in_return(arena, type_ref, final_expr_ref);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (wrapped_fe == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1011) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (void)((final_expr_ref = wrapped_fe));
 } else (__tmp = 0) ; __tmp; }));
    (void)(((b).final_expr_ref = final_expr_ref));
    (void)(((b).num_stmt_order = 0));
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if ((!parser_fill_block_const_let_from_res(arena, block_ref, (&(res)), type_ref))) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((b = ast_arena_block_get(arena, block_ref)));
    int32_t n_while_pool = ast_pipeline_onefunc_num_whiles(parser_onefunc_result_pool_ptr((&(res))));
    (void)(((res).num_loops = n_while_pool));
    (void)(ast_pipeline_block_fill_whiles_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_while_pool));
    int32_t n_for_pool = ast_pipeline_onefunc_num_fors(parser_onefunc_result_pool_ptr((&(res))));
    (void)(((res).num_for_loops = n_for_pool));
    (void)(ast_pipeline_block_fill_fors_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_for_pool));
    (void)((b = ast_arena_block_get(arena, block_ref)));
    int32_t n_if_pool = pipeline_onefunc_num_if_stmts(parser_onefunc_result_pool_ptr((&(res))));
    (void)(((res).num_if_stmts = n_if_pool));
    (void)(ast_pipeline_block_fill_ifs_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_if_pool));
    (void)((b = ast_arena_block_get(arena, block_ref)));
    (void)(({ int32_t __tmp = 0; if ((res).num_src_stmt_order > 0) {   (void)(ast_pipeline_block_fill_expr_stmts_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), pipeline_onefunc_num_body_expr_stmts(parser_onefunc_result_pool_ptr((&(res))))));
  (void)(ast_pipeline_block_fill_stmt_order_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), pipeline_onefunc_num_src_stmt_order(parser_onefunc_result_pool_ptr((&(res))))));
  (void)((b = ast_arena_block_get(arena, block_ref)));
 } else {   int32_t ci2 = 0;
  while (ci2 < (b).num_consts) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 0, ci2) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((ci2 = ci2 + 1));
  }
  int32_t li2 = 0;
  while (li2 < (b).num_lets) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 1, li2) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((li2 = li2 + 1));
  }
  int32_t loop_i = 0;
  while (loop_i < (b).num_loops) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 3, loop_i) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((loop_i = loop_i + 1));
  }
  int32_t for_i = 0;
  while (for_i < (b).num_for_loops) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 4, for_i) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((for_i = for_i + 1));
  }
  int32_t if_oi = 0;
  while (if_oi < (b).num_if_stmts) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 5, if_oi) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((if_oi = if_oi + 1));
  }
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(final_expr_ref)) && (b).num_expr_stmts == 0) {   int32_t fin_ex = ast_pipeline_block_append_expr_stmt(arena, block_ref, final_expr_ref);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (fin_ex < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (void)(((b).final_expr_ref = 0));
  (void)((final_expr_ref = 0));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 2, fin_ex) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (void)((b = ast_arena_block_get(arena, block_ref)));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
    (void)((b = ast_arena_block_get(arena, block_ref)));
    (void)(((b).final_expr_ref = final_expr_ref));
    (void)(({ int32_t __tmp = 0; if ((b).num_expr_stmts > 0 && (!ast_ref_is_null(final_expr_ref))) {   struct ast_Expr fe_dedup;
  fe_dedup = pipeline_arena_expr_get_copy(arena, final_expr_ref);
  __tmp = ({ int32_t __tmp = 0; if ((fe_dedup).kind != ast_ExprKind_EXPR_RETURN) {   (void)(((b).final_expr_ref = 0));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(ast_arena_block_set(arena, block_ref, b));
    int32_t fi = ast_pipeline_module_func_alloc_slot(module);
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (fi < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1000) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)(pipeline_module_func_name_write(module, fi, (&(((res).name)[0])), (res).name_len));
    (void)(ast_pipeline_module_func_set_num_params(module, fi, (res).num_params));
    uint8_t * mod_pool = parser_onefunc_result_pool_ptr((&(res)));
    int32_t p = 0;
    while (p < (res).num_params) {
      uint8_t pname32[32] = { 0 };
      (void)(pipeline_onefunc_param_name_copy32(mod_pool, p, (&((pname32)[0]))));
      (void)(pipeline_module_func_param_write(module, fi, p, (&((pname32)[0])), pipeline_onefunc_param_name_len(mod_pool, p), pipeline_onefunc_param_type_ref(mod_pool, p)));
      (void)((p = p + 1));
    }
    (void)(ast_pipeline_module_func_set_return_type(module, fi, type_ref));
    (void)(ast_pipeline_module_func_set_body_ref(module, fi, block_ref));
    (void)(ast_pipeline_module_func_set_is_extern(module, fi, 0));
    (void)(({ int32_t __tmp = 0; if ((is_main_storage)[0] != 0) {   (void)((main_idx = fi));
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_onefunc_next_into((&(lex)), (&(res))));
  }
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if ((module)->num_funcs == 0) {   return (struct parser_ParseIntoResult){ .ok = 0, .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  int32_t out_idx_storage[1] = { 0 };
  (void)(((out_idx_storage)[0] = main_idx));
  return (struct parser_ParseIntoResult){ .ok = 0, .main_idx = (out_idx_storage)[0] };
}
void parser_parse_one_top_level_let_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source, int is_const, struct parser_TopLevelLetResult * restrict out) {
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  int32_t name_len = 0;
  uint8_t name_buf[64] = { 0 };
  int32_t type_ref = 0;
  int32_t tl_ix = 0;
  int32_t ic = 0;
  struct parser_ParseExprResult expr_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((name_len = ((r).tok).ident_len));
  (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_copy_slice_to_name64(source, (r).token_start, name_len, (&((name_buf)[0]))));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)((type_ref = 0));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STAR) {   (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t elem_ref = ast_arena_type_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (elem_ref == 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type te;
  te = pipeline_arena_type_get_copy(arena, elem_ref);
  (void)(((te).kind = ast_TypeKind_TYPE_NAMED));
  (void)(((te).name_len = ((r).tok).ident_len));
  (void)(({ int32_t __tmp = 0; if ((te).name_len > 63) {   (void)(((te).name_len = 63));
 } else (__tmp = 0) ; __tmp; }));
  int32_t si = 0;
  while (si < (te).name_len && si < 64) {
    (void)(({ uint8_t __tmp = 0; if ((r).token_start + ((size_t)(si)) < (source)->length) {   (void)(((si < 0 || (si) >= 64 ? (shulang_panic_(1, 0), 0) : (((te).name)[si] = ((r).token_start + ((size_t)(si)) < 0 || (size_t)((r).token_start + ((size_t)(si))) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[(r).token_start + ((size_t)(si))]), 0))));
 } else (__tmp = 0) ; __tmp; }));
    (void)((si = si + 1));
  }
  (void)(((te).elem_type_ref = 0));
  (void)(((te).array_size = 0));
  (void)(ast_arena_type_set(arena, elem_ref, te));
  (void)((type_ref = ast_arena_type_alloc(arena)));
  (void)(({ int32_t __tmp = 0; if (type_ref != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref);
  (void)(((t).kind = ast_TypeKind_TYPE_PTR));
  (void)(((t).elem_type_ref = elem_ref));
  (void)(((t).name_len = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref, t));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_I32 || ((r).tok).kind == token_TokenKind_TOKEN_I64 || ((r).tok).kind == token_TokenKind_TOKEN_BOOL || ((r).tok).kind == token_TokenKind_TOKEN_U8 || ((r).tok).kind == token_TokenKind_TOKEN_U32 || ((r).tok).kind == token_TokenKind_TOKEN_U64 || ((r).tok).kind == token_TokenKind_TOKEN_USIZE || ((r).tok).kind == token_TokenKind_TOKEN_ISIZE || ((r).tok).kind == token_TokenKind_TOKEN_VOID || ((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   (void)((type_ref = ast_arena_type_alloc(arena)));
  (void)(({ int32_t __tmp = 0; if (type_ref != 0) {   struct ast_Type t;
  t = pipeline_arena_type_get_copy(arena, type_ref);
  (void)(({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_I32) {   (void)(((t).kind = ast_TypeKind_TYPE_I32));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_I64) {   (void)(((t).kind = ast_TypeKind_TYPE_I64));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_BOOL) {   (void)(((t).kind = ast_TypeKind_TYPE_BOOL));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_U8) {   (void)(((t).kind = ast_TypeKind_TYPE_U8));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_U32) {   (void)(((t).kind = ast_TypeKind_TYPE_U32));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_U64) {   (void)(((t).kind = ast_TypeKind_TYPE_U64));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_USIZE) {   (void)(((t).kind = ast_TypeKind_TYPE_USIZE));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ISIZE) {   (void)(((t).kind = ast_TypeKind_TYPE_ISIZE));
 } else (__tmp = ({ enum ast_TypeKind __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_VOID) {   (void)(((t).kind = ast_TypeKind_TYPE_VOID));
 } else {   (void)(((t).kind = ast_TypeKind_TYPE_NAMED));
  (void)(((t).name_len = ((r).tok).ident_len));
  (void)(({ int32_t __tmp = 0; if ((t).name_len > 63) {   (void)(((t).name_len = 63));
 } else (__tmp = 0) ; __tmp; }));
  int32_t si2 = 0;
  while (si2 < (t).name_len && si2 < 64) {
    (void)(({ uint8_t __tmp = 0; if ((r).token_start + ((size_t)(si2)) < (source)->length) {   (void)(((si2 < 0 || (si2) >= 64 ? (shulang_panic_(1, 0), 0) : (((t).name)[si2] = ((r).token_start + ((size_t)(si2)) < 0 || (size_t)((r).token_start + ((size_t)(si2))) >= (source)->length ? (shulang_panic_(1, 0), (source)->data[0]) : (source)->data[(r).token_start + ((size_t)(si2))]), 0))));
 } else (__tmp = 0) ; __tmp; }));
    (void)((si2 = si2 + 1));
  }
 } ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  (void)(((t).elem_type_ref = 0));
  (void)(((t).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref, t));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
 } else {   (void)(((out)->ok = 0));
  return;
 } ; __tmp; })) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_ASSIGN) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(((expr_res).ok = 0));
  (void)(((expr_res).expr_ref = 0));
  (void)(((expr_res).next_lex = lex));
  (void)(parser_parse_expr_into(arena, lex, source, (&(expr_res))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res).ok)) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((lex = (expr_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((tl_ix = ast_pipeline_module_top_level_let_alloc(module)));
  (void)(({ int32_t __tmp = 0; if (tl_ix < 0) {   (void)(((out)->ok = 0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)((ic = 0));
  (void)(({ int32_t __tmp = 0; if (is_const) {   (void)((ic = 1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_pipeline_module_top_level_let_set(module, tl_ix, (&((name_buf)[0])), name_len, type_ref, (expr_res).expr_ref, ic));
  (void)(parser_lex_from_next_into((&((out)->next_lex)), r));
  (void)(((out)->ok = 1));
}
struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, uint8_t * restrict data, int32_t len) {
  struct lexer_Lexer lex = lexer_init();
  int32_t main_idx = (-1);
  struct parser_CollectImportsResult import_res = (struct parser_CollectImportsResult){ .lex = lex };
  (void)(parser_collect_imports_buf(lex, data, len, module, (&(import_res))));
  (void)(parser_copy_lex_from_import_into((&(lex)), import_res));
  int32_t loop_count_buf = 0;
  while (1) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (loop_count_buf >= 131072) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1003) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((loop_count_buf = loop_count_buf + 1));
    struct lexer_Lexer iter_start_buf = lex;
    struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
    (void)(lexer_next_buf_into((&(r)), lex, data, len));
    (void)(parser_lex_from_next_into((&(lex)), r));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STRUCT) {   struct shulang_slice_uint8_t slice_st = parser_slice_from_buf(data, len);
  struct lexer_Lexer lex_kw = iter_start_buf;
  int32_t ap_sb = (module)->pending_allow_padding;
  (void)(((module)->pending_allow_padding = 0));
  (void)(({ int32_t __tmp = 0; if (parser_parse_struct_record_layout_into(arena, module, lex, &(slice_st), (&(lex)), ap_sb) != 0) {   (void)(parser_skip_one_struct_into_buf((&(lex)), lex_kw, data, len));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ENUM) {   (void)(parser_skip_one_enum_register_into_buf(module, (&(lex)), iter_start_buf, data, len));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_TRAIT) {   (void)(parser_skip_one_trait_into_buf((&(lex)), iter_start_buf, data, len));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IMPL) {   (void)(parser_skip_one_impl_into_buf((&(lex)), iter_start_buf, data, len));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EXTERN) {   (void)(parser_parse_one_extern_and_add_into_buf(arena, module, iter_start_buf, data, len, (&(lex))));
  (void)(({ int32_t __tmp = 0; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   (void)(parser_skip_one_extern_into_buf((&(lex)), iter_start_buf, data, len));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LET || ((r).tok).kind == token_TokenKind_TOKEN_CONST) {   struct shulang_slice_uint8_t slice_tl = parser_slice_from_buf(data, len);
  struct parser_TopLevelLetResult toplevel_res = (struct parser_TopLevelLetResult){ .ok = 0, .next_lex = lex };
  (void)(parser_parse_one_top_level_let_into(arena, module, (r).next_lex, &(slice_tl), ((r).tok).kind == token_TokenKind_TOKEN_CONST, (&(toplevel_res))));
  __tmp = ({ int32_t __tmp = 0; if ((toplevel_res).ok) {   (void)((lex = (toplevel_res).next_lex));
  continue;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   struct parser_TrySkipAllowResult try_res = ({ struct parser_TrySkipAllowResult _t = { 0 }; _t.lex = lex; _t.skipped = 0; _t; });
  (void)(parser_parse_into_try_skip_allow_into_buf((&(try_res)), lex, r, data, len));
  (void)(({ int32_t __tmp = 0; if ((try_res).skipped != 0) {   (void)(((module)->pending_allow_padding = 1));
  (void)(parser_lex_from_try_skip_into((&(lex)), try_res));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   break;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if ((module)->num_funcs == 0) {   return (struct parser_ParseIntoResult){ .ok = 0, .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  int32_t out_idx_storage[1] = { 0 };
  (void)(((out_idx_storage)[0] = main_idx));
  return (struct parser_ParseIntoResult){ .ok = 0, .main_idx = (out_idx_storage)[0] };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    struct lexer_Lexer lex_at_function_buf = lex;
    (void)(parser_lex_from_next_into((&(lex)), r));
    uint8_t empty64_buf[64] = { 0 };
    struct parser_OneFuncResult res = parser_onefunc_scratch_empty();
    (void)(parser_onefunc_res_wire_dummy_head((&(res)), lex, empty64_buf));
    (void)(parser_onefunc_res_wire_dummy_const_let((&(res))));
    (void)(parser_onefunc_res_wire_dummy_if_mul((&(res))));
    (void)(parser_onefunc_res_wire_dummy_call_binop((&(res)), empty64_buf));
    (void)(parser_onefunc_res_wire_dummy_loop_call((&(res))));
    (void)(parser_onefunc_res_wire_dummy_for_if((&(res))));
    struct shulang_slice_uint8_t slice_for_impl = parser_slice_from_buf(data, len);
    struct parser_LibraryParseResult lib_buf_first = parser_parse_one_function_library_buf(arena, module, lex_at_function_buf, data, len);
    (void)(({ int32_t __tmp = 0; if ((lib_buf_first).ok) {   (void)(parser_lex_from_library_into((&(lex)), lib_buf_first));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_parse_one_function_impl((&(res)), arena, lex, &(slice_for_impl)));
    (void)(({ int32_t __tmp = 0; if ((!(res).ok)) {   (void)(parser_parse_one_function_buf_into((&(res)), lex_at_function_buf, data, len));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!(res).ok)) {   (void)(parser_skip_one_function_full_into_buf((&(lex)), lex_at_function_buf, data, len));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (lex_at_function_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int32_t is_main_storage[1] = { 0 };
    (void)(({ int32_t __tmp = 0; if ((res).name_len == 4 && ((res).name)[0] == 109 && (1 < 0 || (1) >= 64 ? (shulang_panic_(1, 0), ((res).name)[0]) : ((res).name)[1]) == 97 && (2 < 0 || (2) >= 64 ? (shulang_panic_(1, 0), ((res).name)[0]) : ((res).name)[2]) == 105 && (3 < 0 || (3) >= 64 ? (shulang_panic_(1, 0), ((res).name)[0]) : ((res).name)[3]) == 110) {   (void)(((is_main_storage)[0] = 1));
 } else (__tmp = 0) ; __tmp; }));
    int32_t type_ref = (res).func_return_type_ref;
    (void)(({ int32_t __tmp = 0; if (type_ref == 0) {   (void)((type_ref = ast_arena_type_alloc(arena)));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (type_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Type t_fb;
  t_fb = pipeline_arena_type_get_copy(arena, type_ref);
  (void)(((t_fb).kind = ast_TypeKind_TYPE_I32));
  (void)(((t_fb).name_len = 0));
  (void)(((t_fb).elem_type_ref = 0));
  (void)(((t_fb).array_size = 0));
  (void)(ast_arena_type_set(arena, type_ref, t_fb));
 } else (__tmp = 0) ; __tmp; }));
    int32_t expr_ref = ast_arena_expr_alloc(arena);
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (expr_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    struct ast_Expr e;
    e = pipeline_arena_expr_get_copy(arena, expr_ref);
    (void)(({ int32_t __tmp = 0; if ((res).return_var_name_len > 0) {   (void)(((e).kind = ast_ExprKind_EXPR_VAR));
  (void)(((e).var_name_len = (res).return_var_name_len));
  int32_t rvi = 0;
  while (rvi < (res).return_var_name_len && rvi < 64) {
    (void)(((rvi < 0 || (rvi) >= 64 ? (shulang_panic_(1, 0), 0) : (((e).var_name)[rvi] = (rvi < 0 || (rvi) >= 64 ? (shulang_panic_(1, 0), ((res).return_var_name)[0]) : ((res).return_var_name)[rvi]), 0))));
    (void)((rvi = rvi + 1));
  }
  uint8_t rvz = 0;
  while (rvi < 64) {
    (void)(((rvi < 0 || (rvi) >= 64 ? (shulang_panic_(1, 0), 0) : (((e).var_name)[rvi] = rvz, 0))));
    (void)((rvi = rvi + 1));
  }
  (void)(((e).int_val = 0));
  (void)(((e).resolved_type_ref = 0));
 } else {   (void)(((e).kind = ast_ExprKind_EXPR_LIT));
  (void)(((e).int_val = (res).return_val));
  (void)(((e).resolved_type_ref = type_ref));
 } ; __tmp; }));
    (void)(((e).line = 0));
    (void)(((e).col = 0));
    (void)(((e).binop_left_ref = 0));
    (void)(((e).binop_right_ref = 0));
    (void)(((e).unary_operand_ref = 0));
    (void)(((e).if_cond_ref = 0));
    (void)(((e).if_then_ref = 0));
    (void)(((e).if_else_ref = 0));
    (void)(((e).block_ref = 0));
    (void)(((e).match_matched_ref = 0));
    (void)(((e).match_num_arms = 0));
    (void)(ast_expr_init_match_enum((&(e))));
    (void)(((e).field_access_base_ref = 0));
    (void)(((e).field_access_field_len = 0));
    (void)(((e).field_access_is_enum_variant = 0));
    (void)(((e).field_access_offset = 0));
    (void)(((e).index_base_ref = 0));
    (void)(((e).index_index_ref = 0));
    (void)(((e).index_base_is_slice = 0));
    (void)(((e).call_callee_ref = 0));
    (void)(((e).call_num_args = 0));
    (void)(((e).method_call_base_ref = 0));
    (void)(((e).method_call_name_len = 0));
    (void)(((e).method_call_num_args = 0));
    (void)(((e).const_folded_val = 0));
    (void)(((e).const_folded_valid = 0));
    (void)(((e).index_proven_in_bounds = 0));
    (void)(ast_arena_expr_set(arena, expr_ref, e));
    int32_t final_expr_ref = expr_ref;
    (void)(({ int32_t __tmp = 0; if ((res).return_expr_ref != 0) {   (void)((final_expr_ref = (res).return_expr_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).return_var_name_len > 0 && (res).return_expr_ref == 0) {   int32_t var_wrapped = parser_expr_wrap_in_return(arena, type_ref, final_expr_ref);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (var_wrapped == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1003) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (void)((final_expr_ref = var_wrapped));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_mul && (!(res).has_binop)) {   int32_t mul_right_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_right_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr mre;
  mre = pipeline_arena_expr_get_copy(arena, mul_right_ref);
  (void)(((mre).kind = ast_ExprKind_EXPR_LIT));
  (void)(((mre).resolved_type_ref = type_ref));
  (void)(((mre).line = 0));
  (void)(((mre).col = 0));
  (void)(((mre).int_val = (res).mul_right_val));
  (void)(((mre).binop_left_ref = 0));
  (void)(((mre).binop_right_ref = 0));
  (void)(((mre).unary_operand_ref = 0));
  (void)(((mre).if_cond_ref = 0));
  (void)(((mre).if_then_ref = 0));
  (void)(((mre).if_else_ref = 0));
  (void)(((mre).block_ref = 0));
  (void)(((mre).match_matched_ref = 0));
  (void)(((mre).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(mre))));
  (void)(((mre).field_access_base_ref = 0));
  (void)(((mre).field_access_field_len = 0));
  (void)(((mre).field_access_is_enum_variant = 0));
  (void)(((mre).field_access_offset = 0));
  (void)(((mre).index_base_ref = 0));
  (void)(((mre).index_index_ref = 0));
  (void)(((mre).index_base_is_slice = 0));
  (void)(((mre).call_callee_ref = 0));
  (void)(((mre).call_num_args = 0));
  (void)(((mre).method_call_base_ref = 0));
  (void)(((mre).method_call_name_len = 0));
  (void)(((mre).method_call_num_args = 0));
  (void)(((mre).const_folded_val = 0));
  (void)(((mre).const_folded_valid = 0));
  (void)(((mre).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, mul_right_ref, mre));
  int32_t mul_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr me;
  me = pipeline_arena_expr_get_copy(arena, mul_ref);
  (void)(((me).kind = ast_ExprKind_EXPR_BINOP));
  (void)(((me).resolved_type_ref = type_ref));
  (void)(((me).line = 0));
  (void)(((me).col = 0));
  (void)(((me).int_val = 0));
  (void)(((me).binop_left_ref = expr_ref));
  (void)(((me).binop_right_ref = mul_right_ref));
  (void)(((me).unary_operand_ref = 0));
  (void)(((me).if_cond_ref = 0));
  (void)(((me).if_then_ref = 0));
  (void)(((me).if_else_ref = 0));
  (void)(((me).block_ref = 0));
  (void)(((me).match_matched_ref = 0));
  (void)(((me).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(me))));
  (void)(((me).field_access_base_ref = 0));
  (void)(((me).field_access_field_len = 0));
  (void)(((me).field_access_is_enum_variant = 0));
  (void)(((me).field_access_offset = 0));
  (void)(((me).index_base_ref = 0));
  (void)(((me).index_index_ref = 0));
  (void)(((me).index_base_is_slice = 0));
  (void)(((me).call_callee_ref = 0));
  (void)(((me).call_num_args = 0));
  (void)(((me).method_call_base_ref = 0));
  (void)(((me).method_call_name_len = 0));
  (void)(((me).method_call_num_args = 0));
  (void)(((me).const_folded_val = 0));
  (void)(((me).const_folded_valid = 0));
  (void)(((me).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, mul_ref, me));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_if_expr) {   int32_t cond_ref = 0;
  (void)(({ int32_t __tmp = 0; if ((res).if_cond_expr_ref != 0) {   (void)((cond_ref = (res).if_cond_expr_ref));
 } else {   int32_t bool_type_ref = ast_arena_type_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (bool_type_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1005) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Type bt;
  bt = pipeline_arena_type_get_copy(arena, bool_type_ref);
  (void)(((bt).kind = ast_TypeKind_TYPE_BOOL));
  (void)(((bt).name_len = 0));
  (void)(((bt).elem_type_ref = 0));
  (void)(((bt).array_size = 0));
  (void)(ast_arena_type_set(arena, bool_type_ref, bt));
  (void)((cond_ref = ast_arena_expr_alloc(arena)));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (cond_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ce;
  ce = pipeline_arena_expr_get_copy(arena, cond_ref);
  (void)(((ce).kind = ast_ExprKind_EXPR_BOOL_LIT));
  (void)(((ce).resolved_type_ref = bool_type_ref));
  (void)(((ce).line = 0));
  (void)(((ce).col = 0));
  (void)(({ int32_t __tmp = 0; if ((res).if_cond_true) {   (void)(((ce).int_val = 1));
 } else {   (void)(((ce).int_val = 0));
 } ; __tmp; }));
  (void)(((ce).binop_left_ref = 0));
  (void)(((ce).binop_right_ref = 0));
  (void)(((ce).unary_operand_ref = 0));
  (void)(((ce).if_cond_ref = 0));
  (void)(((ce).if_then_ref = 0));
  (void)(((ce).if_else_ref = 0));
  (void)(((ce).block_ref = 0));
  (void)(((ce).match_matched_ref = 0));
  (void)(((ce).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(ce))));
  (void)(((ce).field_access_base_ref = 0));
  (void)(((ce).field_access_field_len = 0));
  (void)(((ce).field_access_is_enum_variant = 0));
  (void)(((ce).field_access_offset = 0));
  (void)(((ce).index_base_ref = 0));
  (void)(((ce).index_index_ref = 0));
  (void)(((ce).index_base_is_slice = 0));
  (void)(((ce).call_callee_ref = 0));
  (void)(((ce).call_num_args = 0));
  (void)(((ce).method_call_base_ref = 0));
  (void)(((ce).method_call_name_len = 0));
  (void)(((ce).method_call_num_args = 0));
  (void)(((ce).const_folded_val = 0));
  (void)(((ce).const_folded_valid = 0));
  (void)(((ce).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, cond_ref, ce));
 } ; __tmp; }));
  int32_t then_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (then_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr te;
  te = pipeline_arena_expr_get_copy(arena, then_ref);
  (void)(((te).kind = ast_ExprKind_EXPR_LIT));
  (void)(((te).resolved_type_ref = type_ref));
  (void)(((te).line = 0));
  (void)(((te).col = 0));
  (void)(((te).int_val = (res).if_then_val));
  (void)(((te).binop_left_ref = 0));
  (void)(((te).binop_right_ref = 0));
  (void)(((te).unary_operand_ref = 0));
  (void)(((te).if_cond_ref = 0));
  (void)(((te).if_then_ref = 0));
  (void)(((te).if_else_ref = 0));
  (void)(((te).block_ref = 0));
  (void)(((te).match_matched_ref = 0));
  (void)(((te).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(te))));
  (void)(((te).field_access_base_ref = 0));
  (void)(((te).field_access_field_len = 0));
  (void)(((te).field_access_is_enum_variant = 0));
  (void)(((te).field_access_offset = 0));
  (void)(((te).index_base_ref = 0));
  (void)(((te).index_index_ref = 0));
  (void)(((te).index_base_is_slice = 0));
  (void)(((te).call_callee_ref = 0));
  (void)(((te).call_num_args = 0));
  (void)(((te).method_call_base_ref = 0));
  (void)(((te).method_call_name_len = 0));
  (void)(((te).method_call_num_args = 0));
  (void)(((te).const_folded_val = 0));
  (void)(((te).const_folded_valid = 0));
  (void)(((te).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, then_ref, te));
  int32_t else_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (else_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ee;
  ee = pipeline_arena_expr_get_copy(arena, else_ref);
  (void)(((ee).kind = ast_ExprKind_EXPR_LIT));
  (void)(((ee).resolved_type_ref = type_ref));
  (void)(((ee).line = 0));
  (void)(((ee).col = 0));
  (void)(((ee).int_val = (res).if_else_val));
  (void)(((ee).binop_left_ref = 0));
  (void)(((ee).binop_right_ref = 0));
  (void)(((ee).unary_operand_ref = 0));
  (void)(((ee).if_cond_ref = 0));
  (void)(((ee).if_then_ref = 0));
  (void)(((ee).if_else_ref = 0));
  (void)(((ee).block_ref = 0));
  (void)(((ee).match_matched_ref = 0));
  (void)(((ee).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(ee))));
  (void)(((ee).field_access_base_ref = 0));
  (void)(((ee).field_access_field_len = 0));
  (void)(((ee).field_access_is_enum_variant = 0));
  (void)(((ee).field_access_offset = 0));
  (void)(((ee).index_base_ref = 0));
  (void)(((ee).index_index_ref = 0));
  (void)(((ee).index_base_is_slice = 0));
  (void)(((ee).call_callee_ref = 0));
  (void)(((ee).call_num_args = 0));
  (void)(((ee).method_call_base_ref = 0));
  (void)(((ee).method_call_name_len = 0));
  (void)(((ee).method_call_num_args = 0));
  (void)(((ee).const_folded_val = 0));
  (void)(((ee).const_folded_valid = 0));
  (void)(((ee).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, else_ref, ee));
  int32_t if_expr_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (if_expr_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ie;
  ie = pipeline_arena_expr_get_copy(arena, if_expr_ref);
  (void)(((ie).kind = ast_ExprKind_EXPR_IF));
  (void)(((ie).resolved_type_ref = type_ref));
  (void)(((ie).line = 0));
  (void)(((ie).col = 0));
  (void)(((ie).int_val = 0));
  (void)(((ie).binop_left_ref = 0));
  (void)(((ie).binop_right_ref = 0));
  (void)(((ie).unary_operand_ref = 0));
  (void)(((ie).if_cond_ref = cond_ref));
  (void)(((ie).if_then_ref = then_ref));
  (void)(((ie).if_else_ref = else_ref));
  (void)(((ie).block_ref = 0));
  (void)(((ie).match_matched_ref = 0));
  (void)(((ie).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(ie))));
  (void)(((ie).field_access_base_ref = 0));
  (void)(((ie).field_access_field_len = 0));
  (void)(((ie).field_access_is_enum_variant = 0));
  (void)(((ie).field_access_offset = 0));
  (void)(((ie).index_base_ref = 0));
  (void)(((ie).index_index_ref = 0));
  (void)(((ie).index_base_is_slice = 0));
  (void)(((ie).call_callee_ref = 0));
  (void)(((ie).call_num_args = 0));
  (void)(((ie).method_call_base_ref = 0));
  (void)(((ie).method_call_name_len = 0));
  (void)(((ie).method_call_num_args = 0));
  (void)(((ie).const_folded_val = 0));
  (void)(((ie).const_folded_valid = 0));
  (void)(((ie).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, if_expr_ref, ie));
  (void)((final_expr_ref = if_expr_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_binop) {   int32_t right_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (right_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr re;
  re = pipeline_arena_expr_get_copy(arena, right_ref);
  (void)(((re).kind = ast_ExprKind_EXPR_LIT));
  (void)(((re).resolved_type_ref = type_ref));
  (void)(((re).line = 0));
  (void)(((re).col = 0));
  (void)(((re).int_val = (res).binop_right_val));
  (void)(((re).binop_left_ref = 0));
  (void)(((re).binop_right_ref = 0));
  (void)(((re).unary_operand_ref = 0));
  (void)(((re).if_cond_ref = 0));
  (void)(((re).if_then_ref = 0));
  (void)(((re).if_else_ref = 0));
  (void)(((re).block_ref = 0));
  (void)(((re).match_matched_ref = 0));
  (void)(((re).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(re))));
  (void)(((re).field_access_base_ref = 0));
  (void)(((re).field_access_field_len = 0));
  (void)(((re).field_access_is_enum_variant = 0));
  (void)(((re).field_access_offset = 0));
  (void)(((re).index_base_ref = 0));
  (void)(((re).index_index_ref = 0));
  (void)(((re).index_base_is_slice = 0));
  (void)(((re).call_callee_ref = 0));
  (void)(((re).call_num_args = 0));
  (void)(((re).method_call_base_ref = 0));
  (void)(((re).method_call_name_len = 0));
  (void)(((re).method_call_num_args = 0));
  (void)(((re).const_folded_val = 0));
  (void)(((re).const_folded_valid = 0));
  (void)(((re).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, right_ref, re));
  int32_t binop_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (binop_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr be;
  be = pipeline_arena_expr_get_copy(arena, binop_ref);
  (void)(((be).kind = ast_ExprKind_EXPR_BINOP));
  (void)(((be).resolved_type_ref = type_ref));
  (void)(((be).line = 0));
  (void)(((be).col = 0));
  (void)(((be).int_val = 0));
  (void)(((be).binop_left_ref = final_expr_ref));
  (void)(((be).binop_right_ref = right_ref));
  (void)(((be).unary_operand_ref = 0));
  (void)(((be).if_cond_ref = 0));
  (void)(((be).if_then_ref = 0));
  (void)(((be).if_else_ref = 0));
  (void)(((be).block_ref = 0));
  (void)(((be).match_matched_ref = 0));
  (void)(((be).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(be))));
  (void)(((be).field_access_base_ref = 0));
  (void)(((be).field_access_field_len = 0));
  (void)(((be).field_access_is_enum_variant = 0));
  (void)(((be).field_access_offset = 0));
  (void)(((be).index_base_ref = 0));
  (void)(((be).index_index_ref = 0));
  (void)(((be).index_base_is_slice = 0));
  (void)(((be).call_callee_ref = 0));
  (void)(((be).call_num_args = 0));
  (void)(((be).method_call_base_ref = 0));
  (void)(((be).method_call_name_len = 0));
  (void)(((be).method_call_num_args = 0));
  (void)(((be).const_folded_val = 0));
  (void)(((be).const_folded_valid = 0));
  (void)(((be).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, binop_ref, be));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_call_expr && (res).return_expr_ref == 0 && (res).call_callee_len > 0 && (res).call_callee_len <= 63) {   uint8_t * call_pool_buf = parser_onefunc_result_pool_ptr((&(res)));
  int32_t callee_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (callee_ref != 0) {   struct ast_Expr ve;
  ve = pipeline_arena_expr_get_copy(arena, callee_ref);
  (void)(((ve).kind = ast_ExprKind_EXPR_VAR));
  (void)(((ve).resolved_type_ref = 0));
  (void)(((ve).line = 0));
  (void)(((ve).col = 0));
  (void)(((ve).var_name_len = (res).call_callee_len));
  int32_t ck = 0;
  while (ck < (res).call_callee_len && ck < 64) {
    (void)(((ck < 0 || (ck) >= 64 ? (shulang_panic_(1, 0), 0) : (((ve).var_name)[ck] = (ck < 0 || (ck) >= 64 ? (shulang_panic_(1, 0), ((res).call_callee_name)[0]) : ((res).call_callee_name)[ck]), 0))));
    (void)((ck = ck + 1));
  }
  uint8_t z = 0;
  while (ck < 64) {
    (void)(((ck < 0 || (ck) >= 64 ? (shulang_panic_(1, 0), 0) : (((ve).var_name)[ck] = z, 0))));
    (void)((ck = ck + 1));
  }
  (void)(((ve).binop_left_ref = 0));
  (void)(((ve).binop_right_ref = 0));
  (void)(((ve).unary_operand_ref = 0));
  (void)(((ve).if_cond_ref = 0));
  (void)(((ve).if_then_ref = 0));
  (void)(((ve).if_else_ref = 0));
  (void)(((ve).block_ref = 0));
  (void)(((ve).match_matched_ref = 0));
  (void)(((ve).match_num_arms = 0));
  (void)(ast_expr_init_match_enum((&(ve))));
  (void)(((ve).field_access_base_ref = 0));
  (void)(((ve).field_access_field_len = 0));
  (void)(((ve).field_access_is_enum_variant = 0));
  (void)(((ve).field_access_offset = 0));
  (void)(((ve).index_base_ref = 0));
  (void)(((ve).index_index_ref = 0));
  (void)(((ve).index_base_is_slice = 0));
  (void)(((ve).call_callee_ref = 0));
  (void)(((ve).call_num_args = 0));
  (void)(((ve).method_call_base_ref = 0));
  (void)(((ve).method_call_name_len = 0));
  (void)(((ve).method_call_num_args = 0));
  (void)(((ve).const_folded_val = 0));
  (void)(((ve).const_folded_valid = 0));
  (void)(((ve).index_proven_in_bounds = 0));
  (void)(ast_arena_expr_set(arena, callee_ref, ve));
  int32_t call_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (call_ref != 0) {   struct ast_Expr ce;
  ce = pipeline_arena_expr_get_copy(arena, call_ref);
  (void)(parser_expr_set_common_zeros((&(ce))));
  (void)(((ce).kind = ast_ExprKind_EXPR_CALL));
  (void)(((ce).resolved_type_ref = type_ref));
  (void)(((ce).line = 0));
  (void)(((ce).col = 0));
  (void)(((ce).call_callee_ref = callee_ref));
  (void)(({ int32_t __tmp = 0; if ((res).call_num_args > 0) {   (void)(((ce).call_num_args = (res).call_num_args));
 } else {   (void)(((ce).call_num_args = (res).num_params));
 } ; __tmp; }));
  (void)(ast_arena_expr_set(arena, call_ref, ce));
  int32_t arg_i = 0;
  while (arg_i < (ce).call_num_args) {
    int32_t arg_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (arg_ref != 0) {   struct ast_Expr ae;
  ae = pipeline_arena_expr_get_copy(arena, arg_ref);
  (void)(((ae).resolved_type_ref = 0));
  (void)(((ae).line = 0));
  (void)(((ae).col = 0));
  (void)(({ int32_t __tmp = 0; if ((res).call_num_args > 0 && arg_i < (res).call_num_args) {   (void)(((ae).kind = ast_ExprKind_EXPR_LIT));
  (void)(((ae).int_val = pipeline_onefunc_call_arg_val_at(call_pool_buf, arg_i)));
 } else {   (void)(((ae).kind = ast_ExprKind_EXPR_VAR));
  (void)(((ae).var_name_len = pipeline_onefunc_param_name_len(call_pool_buf, arg_i)));
  int32_t k = 0;
  while (k < (ae).var_name_len && k < 64) {
    (void)(((k < 0 || (k) >= 64 ? (shulang_panic_(1, 0), 0) : (((ae).var_name)[k] = pipeline_onefunc_param_name_byte_at(call_pool_buf, arg_i, k), 0))));
    (void)((k = k + 1));
  }
  uint8_t z = 0;
  while (k < 64) {
    (void)(((k < 0 || (k) >= 64 ? (shulang_panic_(1, 0), 0) : (((ae).var_name)[k] = z, 0))));
    (void)((k = k + 1));
  }
 } ; __tmp; }));
  (void)(parser_expr_set_common_zeros((&(ae))));
  (void)(ast_arena_expr_set(arena, arg_ref, ae));
  (void)(pipeline_expr_append_call_arg(arena, call_ref, arg_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)((arg_i = arg_i + 1));
  }
  (void)(((res).return_expr_ref = call_ref));
  (void)((final_expr_ref = call_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    int32_t block_ref = ast_arena_block_alloc(arena);
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (block_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    struct ast_Block b;
    b = pipeline_arena_block_get_copy(arena, block_ref);
    (void)(((b).num_consts = (res).num_consts));
    (void)(((b).num_lets = (res).num_lets));
    (void)(((b).num_early_lets = 0));
    (void)(((b).num_loops = (res).num_loops));
    (void)(((b).num_for_loops = (res).num_for_loops));
    (void)(((b).num_if_stmts = (res).num_if_stmts));
    (void)(((b).num_defers = 0));
    (void)(((b).num_labeled_stmts = 0));
    (void)(((b).num_expr_stmts = 0));
    (void)(({ int32_t __tmp = 0; if (parser_should_wrap_func_tail_in_return(arena, (&(res)), type_ref)) {   int32_t wrapped_tail2 = parser_expr_wrap_in_return(arena, type_ref, final_expr_ref);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (wrapped_tail2 == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (void)((final_expr_ref = wrapped_tail2));
 } else (__tmp = 0) ; __tmp; }));
    (void)(((b).final_expr_ref = final_expr_ref));
    (void)(((b).num_stmt_order = 0));
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if ((!parser_fill_block_const_let_from_res(arena, block_ref, (&(res)), type_ref))) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((b = ast_arena_block_get(arena, block_ref)));
    int32_t n_while_pool2 = ast_pipeline_onefunc_num_whiles(parser_onefunc_result_pool_ptr((&(res))));
    (void)(((res).num_loops = n_while_pool2));
    (void)(ast_pipeline_block_fill_whiles_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_while_pool2));
    int32_t n_for_pool2 = ast_pipeline_onefunc_num_fors(parser_onefunc_result_pool_ptr((&(res))));
    (void)(((res).num_for_loops = n_for_pool2));
    (void)(ast_pipeline_block_fill_fors_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_for_pool2));
    (void)((b = ast_arena_block_get(arena, block_ref)));
    int32_t n_if_pool2 = pipeline_onefunc_num_if_stmts(parser_onefunc_result_pool_ptr((&(res))));
    (void)(((res).num_if_stmts = n_if_pool2));
    (void)(ast_pipeline_block_fill_ifs_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_if_pool2));
    (void)((b = ast_arena_block_get(arena, block_ref)));
    (void)(({ int32_t __tmp = 0; if ((res).num_src_stmt_order > 0) {   (void)(ast_pipeline_block_fill_expr_stmts_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), pipeline_onefunc_num_body_expr_stmts(parser_onefunc_result_pool_ptr((&(res))))));
  (void)(ast_pipeline_block_fill_stmt_order_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), pipeline_onefunc_num_src_stmt_order(parser_onefunc_result_pool_ptr((&(res))))));
  (void)((b = ast_arena_block_get(arena, block_ref)));
 } else {   int32_t ci2b = 0;
  while (ci2b < (b).num_consts) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 0, ci2b) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((ci2b = ci2b + 1));
  }
  int32_t li2b = 0;
  while (li2b < (b).num_lets) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 1, li2b) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((li2b = li2b + 1));
  }
  int32_t loop_ib = 0;
  while (loop_ib < (b).num_loops) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 3, loop_ib) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((loop_ib = loop_ib + 1));
  }
  int32_t for_ib = 0;
  while (for_ib < (b).num_for_loops) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 4, for_ib) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((for_ib = for_ib + 1));
  }
  int32_t if_oib = 0;
  while (if_oib < (b).num_if_stmts) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 5, if_oib) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)((if_oib = if_oib + 1));
  }
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(final_expr_ref)) && (b).num_expr_stmts == 0) {   int32_t fin_ex2 = ast_pipeline_block_append_expr_stmt(arena, block_ref, final_expr_ref);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (fin_ex2 < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (void)(((b).final_expr_ref = 0));
  (void)((final_expr_ref = 0));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (ast_pipeline_block_append_stmt_order(arena, block_ref, 2, fin_ex2) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (void)((b = ast_arena_block_get(arena, block_ref)));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
    (void)((b = ast_arena_block_get(arena, block_ref)));
    (void)(((b).final_expr_ref = final_expr_ref));
    (void)(({ int32_t __tmp = 0; if ((b).num_expr_stmts > 0 && (!ast_ref_is_null(final_expr_ref))) {   struct ast_Expr fe_dedup2;
  fe_dedup2 = pipeline_arena_expr_get_copy(arena, final_expr_ref);
  __tmp = ({ int32_t __tmp = 0; if ((fe_dedup2).kind != ast_ExprKind_EXPR_RETURN) {   (void)(((b).final_expr_ref = 0));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(ast_arena_block_set(arena, block_ref, b));
    int32_t func_ref = ast_arena_func_alloc(arena);
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (func_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    int32_t fi_mod = ast_pipeline_module_func_alloc_slot(module);
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (fi_mod < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)(pipeline_module_func_name_write(module, fi_mod, (&(((res).name)[0])), (res).name_len));
    (void)(ast_pipeline_module_func_set_num_params(module, fi_mod, (res).num_params));
    (void)(ast_pipeline_module_func_set_return_type(module, fi_mod, type_ref));
    (void)(ast_pipeline_module_func_set_body_ref(module, fi_mod, block_ref));
    (void)(ast_pipeline_module_func_set_body_expr_ref(module, fi_mod, 0));
    (void)(ast_pipeline_module_func_set_is_extern(module, fi_mod, 0));
    int32_t p_copy = 0;
    uint8_t * mod_pool_buf = parser_onefunc_result_pool_ptr((&(res)));
    while (p_copy < (res).num_params) {
      uint8_t pname32b[32] = { 0 };
      (void)(pipeline_onefunc_param_name_copy32(mod_pool_buf, p_copy, (&((pname32b)[0]))));
      (void)(pipeline_module_func_param_write(module, fi_mod, p_copy, (&((pname32b)[0])), pipeline_onefunc_param_name_len(mod_pool_buf, p_copy), pipeline_onefunc_param_type_ref(mod_pool_buf, p_copy)));
      (void)((p_copy = p_copy + 1));
    }
    (void)(ast_pipeline_module_func_ref_set(module, fi_mod, func_ref));
    (void)(pipeline_arena_func_copy_slot_from_module(arena, func_ref, module, fi_mod));
    (void)(({ int32_t __tmp = 0; if ((is_main_storage)[0] != 0) {   (void)((main_idx = fi_mod));
 } else (__tmp = 0) ; __tmp; }));
    size_t parse_into_guard_pos = (lex).pos;
    (void)(parser_lex_from_onefunc_next_into((&(lex)), (&(res))));
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == parse_into_guard_pos) {   __tmp = (lex = (struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 });
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  }
  int32_t out_idx = main_idx;
  int32_t out_idx_storage[1] = { 0 };
  (void)(((out_idx_storage)[0] = out_idx));
  return (struct parser_ParseIntoResult){ .ok = 0, .main_idx = (out_idx_storage)[0] };
}
void parser_parse_into_set_main_index(struct ast_Module * restrict module, int32_t main_idx) {
  (void)(((module)->main_func_index = main_idx));
}
int32_t parser_diag_token_after_collect_imports(struct shulang_slice_uint8_t * source, struct ast_Module * restrict module) {
  struct lexer_Lexer lex = lexer_init();
  struct parser_CollectImportsResult import_res = (struct parser_CollectImportsResult){ .lex = lex };
  (void)(parser_collect_imports(lex, source, module, (&(import_res))));
  (void)(parser_copy_lex_from_import_into((&(lex)), import_res));
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  return ((r).tok).kind;
}
int32_t parser_diag_parse_one_after_collect_imports(struct shulang_slice_uint8_t * source, struct ast_Module * restrict module, struct ast_ASTArena * restrict arena) {
  struct lexer_Lexer lex = lexer_init();
  struct parser_CollectImportsResult import_res = (struct parser_CollectImportsResult){ .lex = lex };
  (void)(parser_collect_imports(lex, source, module, (&(import_res))));
  (void)(parser_copy_lex_from_import_into((&(lex)), import_res));
  uint8_t diag_empty64[64] = { 0 };
  struct parser_OneFuncResult res = parser_onefunc_scratch_empty();
  (void)(parser_onefunc_res_wire_dummy_head((&(res)), lex, diag_empty64));
  (void)(parser_onefunc_res_wire_dummy_const_let((&(res))));
  (void)(parser_onefunc_res_wire_dummy_if_mul((&(res))));
  (void)(parser_onefunc_res_wire_dummy_call_binop((&(res)), diag_empty64));
  (void)(parser_onefunc_res_wire_dummy_loop_call((&(res))));
  (void)(parser_onefunc_res_wire_dummy_for_if((&(res))));
  (void)(parser_parse_one_function_impl((&(res)), arena, lex, source));
  return ((res).ok ? 1 : 0);
}
int32_t parser_get_module_num_imports(struct ast_Module * restrict module) {
  return (module)->num_imports;
}
void parser_get_module_import_path(struct ast_Module * restrict module, int32_t i, uint8_t out[64]) {
  (void)(({ int32_t __tmp = 0; if (i < 0 || i >= (module)->num_imports) {   uint8_t z = 0;
  (void)(((out)[0] = z));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_pipeline_module_import_path_copy(module, i, (&((out)[0])), 64));
}
