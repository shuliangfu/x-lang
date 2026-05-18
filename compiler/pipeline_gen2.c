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
enum ast_ExprKind { ast_ExprKind_EXPR_LIT, ast_ExprKind_EXPR_FLOAT_LIT, ast_ExprKind_EXPR_BOOL_LIT, ast_ExprKind_EXPR_VAR, ast_ExprKind_EXPR_ADD, ast_ExprKind_EXPR_SUB, ast_ExprKind_EXPR_MUL, ast_ExprKind_EXPR_DIV, ast_ExprKind_EXPR_MOD, ast_ExprKind_EXPR_SHL, ast_ExprKind_EXPR_SHR, ast_ExprKind_EXPR_BITAND, ast_ExprKind_EXPR_BITOR, ast_ExprKind_EXPR_BITXOR, ast_ExprKind_EXPR_EQ, ast_ExprKind_EXPR_NE, ast_ExprKind_EXPR_LT, ast_ExprKind_EXPR_LE, ast_ExprKind_EXPR_GT, ast_ExprKind_EXPR_GE, ast_ExprKind_EXPR_LOGAND, ast_ExprKind_EXPR_LOGOR, ast_ExprKind_EXPR_NEG, ast_ExprKind_EXPR_BITNOT, ast_ExprKind_EXPR_LOGNOT, ast_ExprKind_EXPR_IF, ast_ExprKind_EXPR_BLOCK, ast_ExprKind_EXPR_TERNARY, ast_ExprKind_EXPR_ASSIGN, ast_ExprKind_EXPR_ADD_ASSIGN, ast_ExprKind_EXPR_SUB_ASSIGN, ast_ExprKind_EXPR_MUL_ASSIGN, ast_ExprKind_EXPR_DIV_ASSIGN, ast_ExprKind_EXPR_MOD_ASSIGN, ast_ExprKind_EXPR_BITAND_ASSIGN, ast_ExprKind_EXPR_BITOR_ASSIGN, ast_ExprKind_EXPR_BITXOR_ASSIGN, ast_ExprKind_EXPR_SHL_ASSIGN, ast_ExprKind_EXPR_SHR_ASSIGN, ast_ExprKind_EXPR_BREAK, ast_ExprKind_EXPR_CONTINUE, ast_ExprKind_EXPR_RETURN, ast_ExprKind_EXPR_PANIC, ast_ExprKind_EXPR_MATCH, ast_ExprKind_EXPR_FIELD_ACCESS, ast_ExprKind_EXPR_STRUCT_LIT, ast_ExprKind_EXPR_ARRAY_LIT, ast_ExprKind_EXPR_INDEX, ast_ExprKind_EXPR_CALL, ast_ExprKind_EXPR_METHOD_CALL, ast_ExprKind_EXPR_ENUM_VARIANT, ast_ExprKind_EXPR_BINOP, ast_ExprKind_EXPR_AS };
enum ast_ImportKind { ast_ImportKind_IMPORT_WHOLE, ast_ImportKind_IMPORT_BINDING, ast_ImportKind_IMPORT_SELECT };
struct ast_Type { enum ast_TypeKind kind; uint8_t name[64]; int32_t name_len; int32_t elem_type_ref; int32_t array_size; };
struct ast_Expr { enum ast_ExprKind kind; int32_t resolved_type_ref; int32_t line; int32_t col; int32_t int_val; double float_val; uint8_t var_name[64]; int32_t var_name_len; int32_t binop_left_ref; int32_t binop_right_ref; int32_t unary_operand_ref; int32_t if_cond_ref; int32_t if_then_ref; int32_t if_else_ref; int32_t block_ref; int32_t match_matched_ref; int32_t match_arm_result_refs[16]; int32_t match_num_arms; int32_t match_arm_is_wildcard[16]; int32_t match_arm_lit_val[16]; int32_t match_arm_is_enum_variant[16]; int32_t match_arm_variant_index[16]; int32_t field_access_base_ref; uint8_t field_access_field_name[64]; int32_t field_access_field_len; int32_t field_access_is_enum_variant; int32_t field_access_offset; int32_t index_base_ref; int32_t index_index_ref; int32_t index_base_is_slice; int32_t call_callee_ref; int32_t call_arg_refs[16]; int32_t call_num_args; int32_t method_call_base_ref; uint8_t method_call_name[64]; int32_t method_call_name_len; int32_t method_call_arg_refs[16]; int32_t method_call_num_args; int32_t const_folded_val; int32_t const_folded_valid; int32_t index_proven_in_bounds; uint8_t struct_lit_struct_name[64]; int32_t struct_lit_struct_name_len; int32_t struct_lit_num_fields; uint8_t struct_lit_field_names[8][64]; int32_t struct_lit_field_lens[8]; int32_t struct_lit_init_refs[8]; int32_t array_lit_num_elems; int32_t array_lit_elem_refs[16]; int32_t float_bits_lo; int32_t float_bits_hi; int32_t enum_variant_tag; int32_t as_operand_ref; int32_t as_target_type_ref; };
struct ast_ConstDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_LetDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_WhileLoop { int32_t cond_ref; int32_t body_ref; };
struct ast_ForLoop { int32_t init_ref; int32_t cond_ref; int32_t step_ref; int32_t body_ref; };
struct ast_IfStmt { int32_t cond_ref; int32_t then_body_ref; };
struct ast_StmtOrderItem { uint8_t kind; int32_t idx; };
struct ast_LabeledStmt { uint8_t label[32]; int32_t label_len; int32_t is_goto; uint8_t goto_target[32]; int32_t goto_target_len; int32_t return_expr_ref; };
struct ast_Block { struct ast_ConstDecl const_decls[256]; int32_t num_consts; struct ast_LetDecl let_decls[256]; int32_t num_lets; int32_t num_early_lets; struct ast_WhileLoop loops[8]; int32_t num_loops; struct ast_ForLoop for_loops[8]; int32_t num_for_loops; struct ast_IfStmt if_stmts[16]; int32_t num_if_stmts; int32_t defer_block_refs[8]; int32_t num_defers; struct ast_LabeledStmt labeled_stmts[8]; int32_t num_labeled_stmts; int32_t expr_stmt_refs[32]; int32_t num_expr_stmts; int32_t final_expr_ref; struct ast_StmtOrderItem stmt_order[96]; int32_t num_stmt_order; };
struct ast_Param { uint8_t name[32]; int32_t name_len; int32_t type_ref; };
struct ast_Func { uint8_t name[64]; int32_t name_len; struct ast_Param params[16]; int32_t num_params; int32_t return_type_ref; int32_t body_ref; int32_t body_expr_ref; int32_t is_extern; };
struct ast_StructLayout { uint8_t name[64]; int32_t name_len; int32_t num_fields; uint8_t field_names[64][64]; int32_t field_lens[64]; int32_t field_offsets[64]; int32_t field_type_refs[64]; };
struct ast_Module { struct ast_Func funcs[256]; int32_t func_refs[256]; int32_t num_funcs; int32_t main_func_index; uint8_t import_path_data[2048]; int32_t import_path_lens[32]; int32_t num_imports; int32_t import_kinds[32]; uint8_t import_binding_name[32][64]; int32_t import_binding_name_len[32]; int32_t import_select_count[32]; uint8_t import_select_names[32][8][64]; int32_t import_select_name_lens[32][8]; int32_t num_top_level_lets; uint8_t top_level_let_names[32][64]; int32_t top_level_let_name_lens[32]; int32_t top_level_let_type_refs[32]; int32_t top_level_let_init_refs[32]; int32_t top_level_let_is_const[32]; struct ast_StructLayout struct_layouts[32]; int32_t num_struct_layouts; };
struct ast_ASTArena { struct ast_Type types[512]; int32_t num_types; struct ast_Expr exprs[8192]; int32_t num_exprs; struct ast_Block blocks[512]; int32_t num_blocks; struct ast_Func funcs[256]; int32_t num_funcs; };
struct ast_PipelineDepCtx { struct ast_Module * dep_modules[32]; struct ast_ASTArena * dep_arenas[32]; int32_t ndep; uint8_t entry_dir_buf[512]; int32_t entry_dir_len; int32_t num_lib_roots; uint8_t lib_root_bufs[16][256]; int32_t lib_root_lens[16]; uint8_t path_buf[512]; uint8_t loaded_buf[262144]; ptrdiff_t loaded_len; uint8_t preprocess_buf[262144]; int32_t preprocess_len; int32_t use_asm_backend; int32_t target_arch; int32_t use_macho_o; int32_t use_coff_o; int32_t current_block_ref; int32_t current_func_index; uint8_t dep_logical_path_mirror[32][64]; uint8_t * dep_paths[32]; int32_t skip_codegen_dep_0; int32_t entry_already_parsed; int32_t current_func_single_empty_param_index; int32_t current_func_empty_param_count; int32_t current_func_empty_param_indices[16]; int32_t current_emit_empty_var_next_index; int32_t emit_expr_as_callee; struct ast_Module * current_codegen_module; struct ast_ASTArena * current_codegen_arena; };
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
struct parser_OneFuncResult { int ok; struct lexer_Lexer next_lex; uint8_t name[64]; int32_t name_len; int32_t num_params; uint8_t param_names[16][32]; int32_t param_name_lens[16]; int32_t param_type_refs[16]; int32_t num_consts; uint8_t const_names[256][64]; int32_t const_name_lens[256]; int32_t const_init_vals[256]; int32_t num_lets; uint8_t let_names[256][64]; int32_t let_name_lens[256]; int32_t let_init_vals[256]; int32_t let_init_refs[256]; int32_t let_type_refs[256]; int has_if_expr; int if_cond_true; int32_t if_then_val; int32_t if_else_val; int32_t if_cond_expr_ref; int has_mul; int32_t mul_right_val; int has_binop; int32_t binop_right_val; int32_t binop_left_param_idx; int32_t binop_right_param_idx; int has_unary_neg; int32_t return_val; int has_call_expr; uint8_t call_callee_name[64]; int32_t call_callee_len; uint8_t return_var_name[64]; int32_t return_var_name_len; int32_t return_expr_ref; int32_t call_num_args; int32_t call_arg_vals[16]; int32_t num_loops; int32_t loop_cond_refs[8]; int32_t loop_body_refs[8]; int32_t num_for_loops; int32_t for_init_refs[8]; int32_t for_cond_refs[8]; int32_t for_step_refs[8]; int32_t for_body_refs[8]; int32_t num_if_stmts; int32_t if_cond_refs[16]; int32_t if_then_body_refs[16]; int32_t num_src_stmt_order; uint8_t src_stmt_kind[96]; int32_t src_stmt_idx[96]; int32_t num_src_body_expr_stmts; int32_t src_body_expr_stmt_refs[32]; int32_t func_return_type_ref; };
struct parser_ParseResult { int ok; int32_t return_val; };
struct parser_ParseIntoResult { int32_t ok; int32_t main_idx; };
struct parser_TopLevelLetResult { int ok; struct lexer_Lexer next_lex; };
struct parser_CollectImportsResult { struct lexer_Lexer lex; };
struct parser_ParseExprResult { int ok; int32_t expr_ref; struct lexer_Lexer next_lex; };
struct parser_ParseBlockResult { int ok; int32_t block_ref; struct lexer_Lexer next_lex; };
struct parser_ExternParseResult { struct lexer_Lexer next_lex; uint8_t name[64]; int32_t name_len; int32_t return_ty_ref; int32_t num_params; uint8_t param_names[16][32]; int32_t param_name_lens[16]; int32_t param_type_refs[16]; };
struct parser_TrySkipAllowResult { struct lexer_Lexer lex; int32_t skipped; uint8_t _pad[4]; };
struct parser_LibraryParseResult { int ok; uint8_t _pad[4]; struct lexer_Lexer next_lex; uint8_t name[64]; int32_t name_len; uint8_t _pad_tail[4]; };
struct parser_LibraryParseScanResult { int ok; uint8_t _pad[4]; struct lexer_Lexer next_lex; uint8_t name[64]; int32_t name_len; uint8_t param_name[32]; int32_t param_name_len; uint8_t param_type_name[64]; int32_t param_type_len; uint8_t field_name[64]; int32_t field_len; uint8_t _pad_tail[4]; uint8_t _pad_tail2[4]; };
struct codegen_CodegenOutBuf { uint8_t data[1048576]; int32_t len; };
struct preprocess_ParseDirectiveResult { int32_t kind; int32_t sym_len; };
enum asm_types_TargetArch { asm_types_TargetArch_TARGET_X86_64, asm_types_TargetArch_TARGET_ARM64, asm_types_TargetArch_TARGET_RISCV64, asm_types_TargetArch_TARGET_NONE };
struct platform_elf_ElfLabelEntry { uint8_t name[64]; int32_t name_len; int32_t offset; };
struct platform_elf_ElfPatchEntry { int32_t rel32_offset; uint8_t name[64]; int32_t name_len; int32_t patch_imm_bits; };
struct platform_elf_ElfRelocEntry { int32_t offset; uint8_t name[64]; int32_t name_len; };
struct platform_elf_ElfSymEntry { uint8_t name[64]; int32_t name_len; int32_t offset; };
struct platform_elf_ElfCodegenCtx { int32_t code_len; struct platform_elf_ElfLabelEntry labels[512]; int32_t num_labels; struct platform_elf_ElfPatchEntry patches[512]; int32_t num_patches; struct platform_elf_ElfRelocEntry relocs[512]; int32_t num_relocs; struct platform_elf_ElfSymEntry syms[512]; int32_t num_syms; int32_t e_machine; int32_t reloc_type_r_pc32; int32_t current_frame_size; uint8_t code_data[1048576]; };
struct backend_LocalSlot { uint8_t name[64]; int32_t name_len; int32_t offset; };
struct backend_AsmFuncCtx { int32_t frame_size; int32_t next_offset; struct backend_LocalSlot locals[24]; int32_t num_locals; int32_t label_counter; struct ast_Module * module_ref; uint8_t break_label[64]; int32_t break_len; uint8_t continue_label[64]; int32_t continue_len; struct ast_PipelineDepCtx * dep_pipe; uint8_t tail_join_label[64]; int32_t tail_join_label_len; };
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
extern void parser_get_module_import_path(struct ast_Module * restrict module, int32_t i, uint8_t out[64]);
extern int32_t codegen_codegen_su_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx, int32_t dep_index);
extern int32_t preprocess_preprocess_su_buf(uint8_t source_buf[262144], ptrdiff_t source_len, uint8_t out_buf[262144], int32_t out_cap);
extern void typeck_typeck_merge_dep_struct_layouts_into_entry(struct ast_Module * mod, struct ast_ASTArena * arena, struct ast_PipelineDepCtx * ctx);
extern uint8_t * driver_dep_arena_buf(int32_t i);
extern uint8_t * driver_dep_module_buf(int32_t i);
extern int32_t driver_dep_seeded_get(int32_t i);
extern int32_t get_ndep();
extern void parser_parse_one_function_impl(struct parser_OneFuncResult * out, struct ast_ASTArena * arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t * source);
extern struct shulang_slice_uint8_t pipeline_source_slice(uint8_t * data, int32_t len);
extern void ast_ast_arena_init(struct ast_ASTArena * arena);
extern int32_t asm_asm_codegen_ast(struct ast_Module * module, struct ast_ASTArena * arena, struct codegen_CodegenOutBuf * out_buf, struct ast_PipelineDepCtx * ctx);
extern void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types);
extern void driver_diagnostic_typeck_fail();
extern void driver_diagnostic_before_codegen(int32_t num_funcs, int32_t out_len);
extern void driver_diagnostic_after_dep_codegen(int32_t j, int32_t out_len);
extern void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep);
extern int32_t driver_skip_codegen_dep_0_get();
extern void driver_diagnostic_entry_already(int32_t v);
extern void driver_diagnostic_source_len(int32_t len);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_entry_module(struct ast_Module * module, struct ast_ASTArena * arena);
extern void driver_set_current_dep_path_for_codegen(uint8_t * path);
int32_t pipeline_pipeline_parse_into_buf(struct ast_ASTArena * arena, struct ast_Module * module, uint8_t buf[262144], int32_t buf_len);
int32_t pipeline_path_append_from_buf_256(struct ast_PipelineDepCtx * ctx, int32_t off, uint8_t buf[256], int32_t len);
int32_t pipeline_path_append_from_buf_512(struct ast_PipelineDepCtx * ctx, int32_t off, uint8_t buf[512], int32_t len);
int32_t pipeline_path_append_import_path(struct ast_PipelineDepCtx * ctx, int32_t off, uint8_t import_path[64], int32_t path_len);
int32_t pipeline_resolve_path_su(struct ast_PipelineDepCtx * ctx, uint8_t import_path[64], int32_t path_len);
int32_t pipeline_read_file_su(struct ast_PipelineDepCtx * ctx);
int32_t pipeline_parse_one_function_ok(struct shulang_slice_uint8_t * source, struct ast_ASTArena * arena);
struct parser_ParseIntoResult pipeline_parse_into_with_init(struct ast_ASTArena * arena, struct ast_Module * module, struct shulang_slice_uint8_t * source);
struct parser_ParseIntoResult pipeline_parse_into_with_init_buf(struct ast_ASTArena * arena, struct ast_Module * module, uint8_t * data, int32_t len);
int32_t pipeline_typeck_after_parse_ok(struct ast_ASTArena * arena, struct ast_Module * module, struct shulang_slice_uint8_t * source, struct ast_PipelineDepCtx * ctx);
int32_t pipeline_run_su_pipeline_impl(struct ast_Module * module, struct ast_ASTArena * arena, uint8_t * source_data, size_t source_len, struct codegen_CodegenOutBuf * out_buf, struct ast_PipelineDepCtx * ctx);
int32_t pipeline_pipeline_parse_into_buf(struct ast_ASTArena * arena, struct ast_Module * module, uint8_t buf[262144], int32_t buf_len) {
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
  while (r < (ctx)->num_lib_roots && r < 16) {
    int32_t off = 0;
    (void)(({ int32_t __tmp = 0; if ((r < 0 || (r) >= 16 ? (shulang_panic_(1, 0), ((ctx)->lib_root_lens)[0]) : ((ctx)->lib_root_lens)[r]) > 0) {   (void)((off = pipeline_path_append_from_buf_256(ctx, 0, (r < 0 || (r) >= 16 ? (shulang_panic_(1, 0), ((ctx)->lib_root_bufs)[0]) : ((ctx)->lib_root_bufs)[r]), (r < 0 || (r) >= 16 ? (shulang_panic_(1, 0), ((ctx)->lib_root_lens)[0]) : ((ctx)->lib_root_lens)[r]))));
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
  (void)(({ int32_t __tmp = 0; if ((r < 0 || (r) >= 16 ? (shulang_panic_(1, 0), ((ctx)->lib_root_lens)[0]) : ((ctx)->lib_root_lens)[r]) > 0) {   (void)((off_base = pipeline_path_append_from_buf_256(ctx, 0, (r < 0 || (r) >= 16 ? (shulang_panic_(1, 0), ((ctx)->lib_root_bufs)[0]) : ((ctx)->lib_root_bufs)[r]), (r < 0 || (r) >= 16 ? (shulang_panic_(1, 0), ((ctx)->lib_root_lens)[0]) : ((ctx)->lib_root_lens)[r]))));
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
  size_t cap = 262144;
  ptrdiff_t n = std_fs_fs_read(fd, (&(((ctx)->loaded_buf)[0])), cap);
  (void)(std_fs_fs_close(fd));
  (void)(({ int32_t __tmp = 0; if (n < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(((ctx)->loaded_len = n));
  return 0;
}
int32_t pipeline_parse_one_function_ok(struct shulang_slice_uint8_t * source, struct ast_ASTArena * arena) {
  struct lexer_Lexer lex = lexer_lexer_init();
  uint8_t empty64[64] = { 0 };
  uint8_t empty32[32] = { 0 };
  int32_t dummy_let_refs[24] = { 0 };
  int32_t dummy_let_typerefs[128] = { 0 };
  int32_t dummy_loop_refs[8] = { 0 };
  int32_t dummy_for_refs[8] = { 0 };
  int32_t dummy_if_refs[16] = { 0 };
  int32_t dummy_call_arg_vals[16] = { 0 };
  uint8_t dummy_pnames[16][32] = { 0 };
  int32_t dummy_plens[16] = { 0 };
  int32_t dummy_ptrefs[16] = { 0 };
  uint8_t dummy_const_names[24][64] = { 0 };
  int32_t dummy_const_lens[24] = { 0 };
  int32_t dummy_const_vals[24] = { 0 };
  uint8_t dummy_let_names[24][64] = { 0 };
  int32_t dummy_let_lens[24] = { 0 };
  int32_t dummy_let_vals[24] = { 0 };
  struct parser_OneFuncResult res = ({ struct parser_OneFuncResult _t = { 0 }; _t.ok = 0; _t.next_lex = lex; _t.name_len = 0; _t.num_params = 0; _t.num_consts = 0; _t.num_lets = 0; _t.has_if_expr = 0; _t.if_cond_true = 0; _t.if_then_val = 0; _t.if_else_val = 0; _t.if_cond_expr_ref = 0; _t.has_mul = 0; _t.mul_right_val = 0; _t.has_binop = 0; _t.binop_right_val = 0; _t.binop_left_param_idx = (-1); _t.binop_right_param_idx = (-1); _t.has_unary_neg = 0; _t.return_val = 0; _t.has_call_expr = 0; _t.call_callee_len = 0; _t.return_var_name_len = 0; _t.return_expr_ref = 0; _t.call_num_args = 0; _t.num_loops = 0; _t.num_for_loops = 0; _t.num_if_stmts = 0; _t.num_src_stmt_order = 0; _t.num_src_body_expr_stmts = 0; _t.func_return_type_ref = 0; memcpy(_t.name, empty64, sizeof(_t.name)); memcpy(_t.param_names, dummy_pnames, sizeof(_t.param_names)); memcpy(_t.param_name_lens, dummy_plens, sizeof(_t.param_name_lens)); memcpy(_t.param_type_refs, dummy_ptrefs, sizeof(_t.param_type_refs)); memcpy(_t.const_names, dummy_const_names, sizeof(_t.const_names)); memcpy(_t.const_name_lens, dummy_const_lens, sizeof(_t.const_name_lens)); memcpy(_t.const_init_vals, dummy_const_vals, sizeof(_t.const_init_vals)); memcpy(_t.let_names, dummy_let_names, sizeof(_t.let_names)); memcpy(_t.let_name_lens, dummy_let_lens, sizeof(_t.let_name_lens)); memcpy(_t.let_init_vals, dummy_let_vals, sizeof(_t.let_init_vals)); memcpy(_t.let_init_refs, dummy_let_refs, sizeof(_t.let_init_refs)); memcpy(_t.let_type_refs, dummy_let_typerefs, sizeof(_t.let_type_refs)); memcpy(_t.call_callee_name, empty64, sizeof(_t.call_callee_name)); memcpy(_t.return_var_name, empty64, sizeof(_t.return_var_name)); memcpy(_t.call_arg_vals, dummy_call_arg_vals, sizeof(_t.call_arg_vals)); memcpy(_t.loop_cond_refs, dummy_loop_refs, sizeof(_t.loop_cond_refs)); memcpy(_t.loop_body_refs, dummy_loop_refs, sizeof(_t.loop_body_refs)); memcpy(_t.for_init_refs, dummy_for_refs, sizeof(_t.for_init_refs)); memcpy(_t.for_cond_refs, dummy_for_refs, sizeof(_t.for_cond_refs)); memcpy(_t.for_step_refs, dummy_for_refs, sizeof(_t.for_step_refs)); memcpy(_t.for_body_refs, dummy_for_refs, sizeof(_t.for_body_refs)); memcpy(_t.if_cond_refs, dummy_if_refs, sizeof(_t.if_cond_refs)); memcpy(_t.if_then_body_refs, dummy_if_refs, sizeof(_t.if_then_body_refs)); _t; });
  (void)(parser_parse_one_function_impl((&(res)), arena, lex, source));
  (void)(({ int32_t __tmp = 0; if ((res).ok) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
struct parser_ParseIntoResult pipeline_parse_into_with_init(struct ast_ASTArena * arena, struct ast_Module * module, struct shulang_slice_uint8_t * source) {
  (void)(ast_ast_arena_init(arena));
  (void)(parser_parse_into_init(module, arena));
  return parser_parse_into(arena, module, source);
}
struct parser_ParseIntoResult pipeline_parse_into_with_init_buf(struct ast_ASTArena * arena, struct ast_Module * module, uint8_t * data, int32_t len) {
  (void)(ast_ast_arena_init(arena));
  (void)(parser_parse_into_init(module, arena));
  return parser_parse_into_buf(arena, module, data, len);
}
int32_t pipeline_typeck_after_parse_ok(struct ast_ASTArena * arena, struct ast_Module * module, struct shulang_slice_uint8_t * source, struct ast_PipelineDepCtx * ctx) {
  struct parser_ParseIntoResult r = pipeline_parse_into_with_init(arena, module, source);
  (void)(({ int32_t __tmp = 0; if ((r).ok != 0) {   return (r).main_idx;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_parse_into_set_main_index(module, (r).main_idx));
  (void)(({ int32_t __tmp = 0; if ((module)->main_func_index < 0) {   int32_t tc_lib = typeck_typeck_su_ast_library(module, arena, ctx);
  (void)(({ int32_t __tmp = 0; if (tc_lib != 0) {   (void)(driver_diagnostic_typeck_fail());
 } else (__tmp = 0) ; __tmp; }));
  return tc_lib;
 } else (__tmp = 0) ; __tmp; }));
  int32_t tc_main = typeck_typeck_su_ast(module, arena, ctx);
  (void)(({ int32_t __tmp = 0; if (tc_main != 0) {   (void)(driver_diagnostic_typeck_fail());
 } else (__tmp = 0) ; __tmp; }));
  return tc_main;
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
  int32_t n_imports = parser_get_module_num_imports(module);
  (void)(({ int32_t __tmp = 0; if ((ctx)->ndep == 0) {   (void)(((ctx)->ndep = 0));
  __tmp = ({ int32_t __tmp = 0; if (n_imports > 0) {   int32_t i = 0;
  while (i < n_imports) {
    (void)(({ int32_t __tmp = 0; if (i >= 32) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (driver_dep_seeded_get(i) != 0) {   (void)(((i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), 0) : (((ctx)->dep_arenas)[i] = ((struct ast_ASTArena *)(driver_dep_arena_buf(i))), 0))));
  (void)(((i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), 0) : (((ctx)->dep_modules)[i] = ((struct ast_Module *)(driver_dep_module_buf(i))), 0))));
 } else {   uint8_t path_buf[64] = { 0 };
  (void)(parser_get_module_import_path(module, i, path_buf));
  int32_t path_len = 0;
  while (path_len < 64 && (path_len < 0 || (path_len) >= 64 ? (shulang_panic_(1, 0), (path_buf)[0]) : (path_buf)[path_len]) != 0) {
    (void)((path_len = path_len + 1));
  }
  (void)(({ int32_t __tmp = 0; if (pipeline_resolve_path_su(ctx, path_buf, path_len) != 0) {   return (-7);
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_read_file_su(ctx) != 0) {   return (-8);
 } else (__tmp = 0) ; __tmp; }));
  int32_t out_len = preprocess_preprocess_su_buf((ctx)->loaded_buf, (ctx)->loaded_len, (ctx)->preprocess_buf, 262144);
  (void)(({ int32_t __tmp = 0; if (out_len < 0) {   return (-9);
 } else (__tmp = 0) ; __tmp; }));
  (void)(((ctx)->preprocess_len = out_len));
  (void)(((i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), 0) : (((ctx)->dep_arenas)[i] = ((struct ast_ASTArena *)(driver_dep_arena_buf(i))), 0))));
  (void)(((i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), 0) : (((ctx)->dep_modules)[i] = ((struct ast_Module *)(driver_dep_module_buf(i))), 0))));
  struct ast_ASTArena * dep_arena = (i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_arenas)[0]) : ((ctx)->dep_arenas)[i]);
  struct ast_Module * dep_module = (i < 0 || (i) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_modules)[0]) : ((ctx)->dep_modules)[i]);
  __tmp = ({ int32_t __tmp = 0; if (pipeline_pipeline_parse_into_buf(dep_arena, dep_module, (ctx)->preprocess_buf, (ctx)->preprocess_len) != 0) {   return (-10);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
    (void)((i = i + 1));
  }
  (void)(((ctx)->ndep = n_imports));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t dep_sync_i = 0;
  while (dep_sync_i < (ctx)->ndep && dep_sync_i < 32) {
    (void)(((dep_sync_i < 0 || (dep_sync_i) >= 32 ? (shulang_panic_(1, 0), 0) : (((ctx)->dep_modules)[dep_sync_i] = ((struct ast_Module *)(driver_dep_module_buf(dep_sync_i))), 0))));
    (void)(((dep_sync_i < 0 || (dep_sync_i) >= 32 ? (shulang_panic_(1, 0), 0) : (((ctx)->dep_arenas)[dep_sync_i] = ((struct ast_ASTArena *)(driver_dep_arena_buf(dep_sync_i))), 0))));
    (void)((dep_sync_i = dep_sync_i + 1));
  }
  (void)(typeck_typeck_merge_dep_struct_layouts_into_entry(module, arena, ctx));
  (void)(({ int32_t __tmp = 0; if ((module)->main_func_index < 0) {   int32_t tc_lib = typeck_typeck_su_ast_library(module, arena, ctx);
  __tmp = ({ int32_t __tmp = 0; if (tc_lib != 0) {   (void)(driver_diagnostic_typeck_fail());
  return tc_lib;
 } else (__tmp = 0) ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (typeck_typeck_su_ast(module, arena, ctx) != 0) {   (void)(driver_diagnostic_typeck_fail());
  return (-1);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  (void)(((out_buf)->len = 0));
  (void)(driver_diagnostic_before_codegen((module)->num_funcs, (out_buf)->len));
  int32_t j = 0;
  while (j < (ctx)->ndep) {
    (void)(({ int32_t __tmp = 0; if (j >= 32) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (j == 0 && driver_skip_codegen_dep_0_get() != 0) {   (void)((j = j + 1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((j < 0 || (j) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_paths)[0]) : ((ctx)->dep_paths)[j]) == ((uint8_t *)(0))) {   uint8_t path_buf[64] = { 0 };
  (void)(parser_get_module_import_path(module, j, path_buf));
  int32_t k = 0;
  while (k < 64) {
    (void)(((k < 0 || (k) >= 64 ? (shulang_panic_(1, 0), 0) : (((j < 0 || (j) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_logical_path_mirror)[0]) : ((ctx)->dep_logical_path_mirror)[j]))[k] = (k < 0 || (k) >= 64 ? (shulang_panic_(1, 0), (path_buf)[0]) : (path_buf)[k]), 0))));
    (void)((k = k + 1));
  }
  (void)(((j < 0 || (j) >= 32 ? (shulang_panic_(1, 0), 0) : (((ctx)->dep_paths)[j] = (&(((j < 0 || (j) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_logical_path_mirror)[0]) : ((ctx)->dep_logical_path_mirror)[j]))[0])), 0))));
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Module * dep_mod = (j < 0 || (j) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_modules)[0]) : ((ctx)->dep_modules)[j]);
    (void)(driver_set_current_dep_path_for_codegen((j < 0 || (j) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_paths)[0]) : ((ctx)->dep_paths)[j])));
    (void)(({ int32_t __tmp = 0; if ((dep_mod)->num_funcs > 0) {   __tmp = ({ int32_t __tmp = 0; if ((ctx)->use_asm_backend != 0) {   __tmp = ({ int32_t __tmp = 0; if (asm_asm_codegen_ast(dep_mod, (j < 0 || (j) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_arenas)[0]) : ((ctx)->dep_arenas)[j]), out_buf, ctx) != 0) {   (void)(driver_diagnostic_codegen_fail(j, 1));
  return (-6);
 } else (__tmp = 0) ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (codegen_codegen_su_ast(dep_mod, (j < 0 || (j) >= 32 ? (shulang_panic_(1, 0), ((ctx)->dep_arenas)[0]) : ((ctx)->dep_arenas)[j]), out_buf, ctx, j) != 0) {   (void)(driver_diagnostic_codegen_fail(j, 1));
  return (-6);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(driver_diagnostic_after_dep_codegen(j, (out_buf)->len));
    (void)(driver_set_current_dep_path_for_codegen(((uint8_t *)(0))));
    (void)((j = j + 1));
  }
  (void)(driver_diagnostic_entry_module(module, arena));
  (void)(({ int32_t __tmp = 0; if ((ctx)->use_asm_backend != 0) {   __tmp = ({ int32_t __tmp = 0; if (asm_asm_codegen_ast(module, arena, out_buf, ctx) != 0) {   (void)(driver_diagnostic_codegen_fail(0, 0));
  return (-6);
 } else (__tmp = 0) ; __tmp; });
 } else {   int32_t main_dep_index = (-1);
  __tmp = ({ int32_t __tmp = 0; if (codegen_codegen_su_ast(module, arena, out_buf, ctx, main_dep_index) != 0) {   (void)(driver_diagnostic_codegen_fail(0, 0));
  return (-6);
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
  return 0;
}

#include "pipeline_glue.c"
