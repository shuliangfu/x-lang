/* generated (single-file with deps) */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
extern int getpid(void);
static inline void shux_crash_evidence_collect_inline(int has_msg, int msg_val) {
  const char *_ev = getenv("SHUX_CRASH_EVIDENCE");
  if (!_ev || _ev[0] != '1') return;
  int _pid = (int)getpid();
  fprintf(stderr, "shux: [SHUX_CRASH_EVIDENCE] panic=%d msg=%d frames=0 pid=%d\n", has_msg, msg_val, _pid);
  const char *_dir = getenv("SHUX_CRASH_EVIDENCE_DIR");
  if (_dir && _dir[0]) { char _p[1024]; snprintf(_p, sizeof _p, "%s/shux-crash-%d.txt", _dir, _pid);
    FILE *_f = fopen(_p, "w"); if (_f) { fprintf(_f, "panic_has_msg=%d\npanic_msg=%d\nframes=0\npid=%d\n", has_msg, msg_val, _pid); fclose(_f);
      fprintf(stderr, "shux: [SHUX_CRASH_EVIDENCE] bundle=%s\n", _p); } } }
static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));
static inline void shux_panic_(int has_msg, int msg_val) {
  shux_crash_evidence_collect_inline(has_msg, msg_val);
  if (has_msg) (void)fprintf(stderr, "%d\n", msg_val);
  abort();
}
extern int32_t shux_io_register(uint8_t *ptr, size_t len, size_t handle);
extern int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
extern int32_t shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
typedef struct { void *ptr; size_t len; size_t handle; } shu_buffer_abi_t;
static inline int32_t shux_io_register_buf(intptr_t buf) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_register((uint8_t *)b->ptr, b->len, b->handle); }
static inline int32_t shux_io_submit_read_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_submit_read((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
static inline int32_t shux_io_submit_write_buf(intptr_t buf, int32_t timeout_m) { const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf; return shux_io_submit_write((uint8_t *)b->ptr, b->len, b->handle, (uint32_t)timeout_m); }
typedef struct { uint8_t *ptr; size_t len; size_t handle; } shu_batch_buf_t;
extern int io_register_buffers_buf_c(const shu_batch_buf_t *bufs, int nr);
static inline int io_register_buffers_buf_i32(intptr_t bufs, int nr) { return io_register_buffers_buf_c((const shu_batch_buf_t *)(uintptr_t)bufs, nr); }
enum token_TokenKind { token_TokenKind_TOKEN_EOF, token_TokenKind_TOKEN_FUNCTION, token_TokenKind_TOKEN_LET, token_TokenKind_TOKEN_CONST, token_TokenKind_TOKEN_IF, token_TokenKind_TOKEN_ELSE, token_TokenKind_TOKEN_WHILE, token_TokenKind_TOKEN_LOOP, token_TokenKind_TOKEN_FOR, token_TokenKind_TOKEN_BREAK, token_TokenKind_TOKEN_CONTINUE, token_TokenKind_TOKEN_RETURN, token_TokenKind_TOKEN_PANIC, token_TokenKind_TOKEN_DEFER, token_TokenKind_TOKEN_TRY, token_TokenKind_TOKEN_CATCH, token_TokenKind_TOKEN_REGION, token_TokenKind_TOKEN_WITH_ARENA, token_TokenKind_TOKEN_MATCH, token_TokenKind_TOKEN_STRUCT, token_TokenKind_TOKEN_TYPE, token_TokenKind_TOKEN_PACKED, token_TokenKind_TOKEN_SOA, token_TokenKind_TOKEN_ATTR_SOA, token_TokenKind_TOKEN_ATTR_CFG, token_TokenKind_TOKEN_ATTR_REPR_C, token_TokenKind_TOKEN_ATTR_REPR_COMPATIBLE, token_TokenKind_TOKEN_ATTR_ALLOC, token_TokenKind_TOKEN_ALIGN, token_TokenKind_TOKEN_ENUM, token_TokenKind_TOKEN_GOTO, token_TokenKind_TOKEN_TRAIT, token_TokenKind_TOKEN_IMPL, token_TokenKind_TOKEN_SELF, token_TokenKind_TOKEN_UNDERSCORE, token_TokenKind_TOKEN_IMPORT, token_TokenKind_TOKEN_EXTERN, token_TokenKind_TOKEN_ASYNC, token_TokenKind_TOKEN_AWAIT, token_TokenKind_TOKEN_RUN, token_TokenKind_TOKEN_SPAWN, token_TokenKind_TOKEN_IDENT, token_TokenKind_TOKEN_I32, token_TokenKind_TOKEN_BOOL, token_TokenKind_TOKEN_U8, token_TokenKind_TOKEN_U32, token_TokenKind_TOKEN_U64, token_TokenKind_TOKEN_I64, token_TokenKind_TOKEN_USIZE, token_TokenKind_TOKEN_ISIZE, token_TokenKind_TOKEN_I32X4, token_TokenKind_TOKEN_I32X8, token_TokenKind_TOKEN_I32X16, token_TokenKind_TOKEN_U32X4, token_TokenKind_TOKEN_U32X8, token_TokenKind_TOKEN_U32X16, token_TokenKind_TOKEN_F32X4, token_TokenKind_TOKEN_TRUE, token_TokenKind_TOKEN_FALSE, token_TokenKind_TOKEN_F32, token_TokenKind_TOKEN_F64, token_TokenKind_TOKEN_VOID, token_TokenKind_TOKEN_INT, token_TokenKind_TOKEN_FLOAT, token_TokenKind_TOKEN_LPAREN, token_TokenKind_TOKEN_RPAREN, token_TokenKind_TOKEN_LBRACE, token_TokenKind_TOKEN_RBRACE, token_TokenKind_TOKEN_LBRACKET, token_TokenKind_TOKEN_RBRACKET, token_TokenKind_TOKEN_ARROW, token_TokenKind_TOKEN_FATARROW, token_TokenKind_TOKEN_COMMA, token_TokenKind_TOKEN_COLON, token_TokenKind_TOKEN_DOT, token_TokenKind_TOKEN_DOTDOT, token_TokenKind_TOKEN_SEMICOLON, token_TokenKind_TOKEN_PLUS, token_TokenKind_TOKEN_MINUS, token_TokenKind_TOKEN_STAR, token_TokenKind_TOKEN_SLASH, token_TokenKind_TOKEN_PERCENT, token_TokenKind_TOKEN_AMP, token_TokenKind_TOKEN_PIPE, token_TokenKind_TOKEN_CARET, token_TokenKind_TOKEN_LSHIFT, token_TokenKind_TOKEN_RSHIFT, token_TokenKind_TOKEN_PLUS_EQ, token_TokenKind_TOKEN_MINUS_EQ, token_TokenKind_TOKEN_STAR_EQ, token_TokenKind_TOKEN_SLASH_EQ, token_TokenKind_TOKEN_PERCENT_EQ, token_TokenKind_TOKEN_AMP_EQ, token_TokenKind_TOKEN_PIPE_EQ, token_TokenKind_TOKEN_CARET_EQ, token_TokenKind_TOKEN_LSHIFT_EQ, token_TokenKind_TOKEN_RSHIFT_EQ, token_TokenKind_TOKEN_TILDE, token_TokenKind_TOKEN_ASSIGN, token_TokenKind_TOKEN_EQ, token_TokenKind_TOKEN_NE, token_TokenKind_TOKEN_LT, token_TokenKind_TOKEN_GT, token_TokenKind_TOKEN_LE, token_TokenKind_TOKEN_GE, token_TokenKind_TOKEN_AMPAMP, token_TokenKind_TOKEN_PIPEPIPE, token_TokenKind_TOKEN_BANG, token_TokenKind_TOKEN_QUESTION, token_TokenKind_TOKEN_AS, token_TokenKind_TOKEN_AT, token_TokenKind_TOKEN_STRING };
struct token_Token { enum token_TokenKind kind; int32_t line; int32_t col; int32_t int_val; double float_val; uint8_t * ident; int32_t ident_len; };
struct lexer_Lexer { size_t pos; int32_t line; int32_t col; };
struct lexer_LexerResult { struct lexer_Lexer next_lex; struct token_Token tok; size_t token_start; };
enum ast_TypeKind { ast_TypeKind_TYPE_I32, ast_TypeKind_TYPE_BOOL, ast_TypeKind_TYPE_U8, ast_TypeKind_TYPE_U32, ast_TypeKind_TYPE_U64, ast_TypeKind_TYPE_I64, ast_TypeKind_TYPE_USIZE, ast_TypeKind_TYPE_ISIZE, ast_TypeKind_TYPE_NAMED, ast_TypeKind_TYPE_PTR, ast_TypeKind_TYPE_ARRAY, ast_TypeKind_TYPE_SLICE, ast_TypeKind_TYPE_LINEAR, ast_TypeKind_TYPE_VECTOR, ast_TypeKind_TYPE_F32, ast_TypeKind_TYPE_F64, ast_TypeKind_TYPE_VOID };
enum ast_ExprKind { ast_ExprKind_EXPR_LIT, ast_ExprKind_EXPR_FLOAT_LIT, ast_ExprKind_EXPR_BOOL_LIT, ast_ExprKind_EXPR_VAR, ast_ExprKind_EXPR_ADD, ast_ExprKind_EXPR_SUB, ast_ExprKind_EXPR_MUL, ast_ExprKind_EXPR_DIV, ast_ExprKind_EXPR_MOD, ast_ExprKind_EXPR_SHL, ast_ExprKind_EXPR_SHR, ast_ExprKind_EXPR_BITAND, ast_ExprKind_EXPR_BITOR, ast_ExprKind_EXPR_BITXOR, ast_ExprKind_EXPR_EQ, ast_ExprKind_EXPR_NE, ast_ExprKind_EXPR_LT, ast_ExprKind_EXPR_LE, ast_ExprKind_EXPR_GT, ast_ExprKind_EXPR_GE, ast_ExprKind_EXPR_LOGAND, ast_ExprKind_EXPR_LOGOR, ast_ExprKind_EXPR_NEG, ast_ExprKind_EXPR_BITNOT, ast_ExprKind_EXPR_LOGNOT, ast_ExprKind_EXPR_IF, ast_ExprKind_EXPR_BLOCK, ast_ExprKind_EXPR_TERNARY, ast_ExprKind_EXPR_ASSIGN, ast_ExprKind_EXPR_ADD_ASSIGN, ast_ExprKind_EXPR_SUB_ASSIGN, ast_ExprKind_EXPR_MUL_ASSIGN, ast_ExprKind_EXPR_DIV_ASSIGN, ast_ExprKind_EXPR_MOD_ASSIGN, ast_ExprKind_EXPR_BITAND_ASSIGN, ast_ExprKind_EXPR_BITOR_ASSIGN, ast_ExprKind_EXPR_BITXOR_ASSIGN, ast_ExprKind_EXPR_SHL_ASSIGN, ast_ExprKind_EXPR_SHR_ASSIGN, ast_ExprKind_EXPR_BREAK, ast_ExprKind_EXPR_CONTINUE, ast_ExprKind_EXPR_RETURN, ast_ExprKind_EXPR_PANIC, ast_ExprKind_EXPR_MATCH, ast_ExprKind_EXPR_FIELD_ACCESS, ast_ExprKind_EXPR_STRUCT_LIT, ast_ExprKind_EXPR_ARRAY_LIT, ast_ExprKind_EXPR_INDEX, ast_ExprKind_EXPR_CALL, ast_ExprKind_EXPR_METHOD_CALL, ast_ExprKind_EXPR_ENUM_VARIANT, ast_ExprKind_EXPR_ADDR_OF, ast_ExprKind_EXPR_DEREF, ast_ExprKind_EXPR_BINOP, ast_ExprKind_EXPR_AS, ast_ExprKind_EXPR_AWAIT, ast_ExprKind_EXPR_RUN, ast_ExprKind_EXPR_SPAWN };
enum ast_ImportKind { ast_ImportKind_IMPORT_WHOLE, ast_ImportKind_IMPORT_BINDING, ast_ImportKind_IMPORT_SELECT };
struct ast_Type { enum ast_TypeKind kind; uint8_t name[64]; int32_t name_len; int32_t elem_type_ref; int32_t array_size; uint8_t region_label[64]; int32_t region_label_len; };
struct ast_Expr { enum ast_ExprKind kind; int32_t resolved_type_ref; int32_t line; int32_t col; int32_t int_val; double float_val; uint8_t var_name[64]; int32_t var_name_len; int32_t binop_left_ref; int32_t binop_right_ref; int32_t unary_operand_ref; int32_t if_cond_ref; int32_t if_then_ref; int32_t if_else_ref; int32_t block_ref; int32_t match_matched_ref; int32_t match_arm_base; int32_t match_num_arms; int32_t field_access_base_ref; uint8_t field_access_field_name[64]; int32_t field_access_field_len; int32_t field_access_is_enum_variant; int32_t field_access_offset; int32_t field_access_soa_stride; int32_t index_base_ref; int32_t index_index_ref; int32_t index_base_is_slice; int32_t call_callee_ref; int32_t call_arg_base; int32_t call_num_args; int32_t method_call_base_ref; uint8_t method_call_name[64]; int32_t method_call_name_len; int32_t method_call_arg_base; int32_t method_call_num_args; int32_t const_folded_val; int32_t const_folded_valid; int32_t index_proven_in_bounds; uint8_t struct_lit_struct_name[64]; int32_t struct_lit_struct_name_len; int32_t struct_lit_field_base; int32_t struct_lit_num_fields; int32_t array_lit_elem_base; int32_t array_lit_num_elems; int32_t float_bits_lo; int32_t float_bits_hi; int32_t enum_variant_tag; int32_t as_operand_ref; int32_t as_target_type_ref; int32_t call_resolved_func_index; int32_t call_resolved_dep_index; };

/* C-04 parser: ast_expr_init_match_enum after struct ast_Expr */
extern void ast_expr_init_match_enum(struct ast_Expr *e);
struct ast_ConstDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_LetDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_WhileLoop { int32_t cond_ref; int32_t body_ref; };
struct ast_ForLoop { int32_t init_ref; int32_t cond_ref; int32_t step_ref; int32_t body_ref; };
struct ast_IfStmt { int32_t cond_ref; int32_t then_body_ref; int32_t else_body_ref; };
struct ast_StmtOrderItem { uint8_t kind; int32_t idx; };
struct ast_LabeledStmt { uint8_t label[32]; int32_t label_len; int32_t is_goto; uint8_t goto_target[32]; int32_t goto_target_len; int32_t return_expr_ref; };
struct ast_Block { int32_t const_base; int32_t num_consts; int32_t let_base; int32_t num_lets; int32_t num_early_lets; int32_t loop_base; int32_t num_loops; int32_t for_loop_base; int32_t num_for_loops; int32_t if_base; int32_t num_if_stmts; int32_t region_base; int32_t num_regions; int32_t defer_base; int32_t num_defers; int32_t labeled_base; int32_t num_labeled_stmts; int32_t expr_stmt_base; int32_t num_expr_stmts; int32_t final_expr_ref; int32_t stmt_order_base; int32_t num_stmt_order; int32_t parent_block_ref; };
struct ast_Param { uint8_t name[32]; int32_t name_len; int32_t type_ref; };
struct ast_Func { uint8_t name[64]; int32_t name_len; int32_t param_base; int32_t num_params; int32_t return_type_ref; int32_t body_ref; int32_t body_expr_ref; int32_t is_extern; int32_t is_async; };
struct ast_StructLayout { uint8_t name[64]; int32_t name_len; int32_t field_base; int32_t num_fields; int32_t allow_padding; int32_t soa; int32_t packed; };
struct ast_Module { int32_t num_funcs; int32_t main_func_index; int32_t num_imports; int32_t num_top_level_lets; int32_t num_struct_layouts; int32_t pending_allow_padding; int32_t pending_soa_struct; int32_t pending_cfg_skip; int32_t pending_repr_c_struct; int32_t num_module_enums; };
struct ast_ASTArena { int32_t num_types; int32_t num_exprs; int32_t num_blocks; int32_t num_funcs; };
struct ast_PipelineDepCtx { int32_t ndep; uint8_t entry_dir_buf[512]; int32_t entry_dir_len; int32_t num_lib_roots; uint8_t path_buf[512]; uint8_t loaded_buf[4194304]; ptrdiff_t loaded_len; uint8_t preprocess_buf[4194304]; int32_t preprocess_len; int32_t use_asm_backend; int32_t target_arch; int32_t target_cpu_features; int32_t use_macho_o; int32_t use_coff_o; int32_t current_block_ref; int32_t typeck_loop_depth; int32_t current_func_index; int32_t skip_codegen_dep_0; int32_t entry_already_parsed; int32_t current_func_single_empty_param_index; int32_t current_func_empty_param_count; int32_t current_emit_empty_var_next_index; int32_t emit_expr_as_callee; struct ast_Module * current_codegen_module; struct ast_ASTArena * current_codegen_arena; int32_t current_codegen_dep_index; uint8_t current_codegen_prefix_mirror[64]; int32_t current_codegen_prefix_len; int32_t asm_entry_module_only; uint8_t entry_module_import_path_mirror[64]; int32_t entry_module_import_path_len; int32_t typeck_scope_region_len; uint8_t typeck_scope_region_label[64]; };
enum std_io_driver_IO_Result { std_io_driver_IO_Result_Ok, std_io_driver_IO_Result_Err, std_io_driver_IO_Result_Timeout, std_io_driver_IO_Result_Cancelled };
struct std_io_driver_Buffer { uint8_t * ptr; size_t len; size_t handle; };
struct std_io_driver_Completion { int32_t tag; };
struct std_io_driver_AsyncContext { uint32_t flags; };
struct std_context_Context { int64_t handle; };
struct core_result_Result_i32 { int32_t value; int32_t _pad1; int32_t err; int32_t _pad2; };
struct core_result_Result_u8 { uint8_t value; uint8_t _pad1; uint8_t _pad2; uint8_t _pad3; int32_t err; int32_t _pad4; };
struct std_error_Error { int32_t code; };
struct std_error_ErrorChain { int32_t depth; int32_t c0; int32_t c1; int32_t c2; int32_t c3; };
struct shux_slice_uint8_t { uint8_t *data; size_t length; };
struct std_io_ReadOnlySlice { struct shux_slice_uint8_t data; };
struct std_io_WriteOnlySlice { struct shux_slice_uint8_t data; };
struct std_io_ReadPtrView { uint8_t * ptr; int32_t len; uint64_t gen; };
struct std_fs_FsIovecBuf { uint8_t * ptr; size_t len; size_t handle; };
struct std_fs_FsStat { int64_t size; uint32_t mode; int32_t is_dir; int32_t is_file; int64_t mtime_sec; };
struct std_heap_Arena64 { uint8_t * chunk; size_t cap; size_t off; };
struct std_heap_HeapTraceStats { uint64_t alloc_count; uint64_t free_count; uint64_t realloc_count; uint64_t bytes_allocated; };
struct std_heap_Allocator { int32_t kind; struct std_heap_Arena64 * arena; };
/* slim arena grow pool glue (C-04 codegen; linked from pipeline/runtime) */
extern struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
extern void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
extern void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
extern void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);

extern struct lexer_Lexer lexer_lexer_init();
extern int32_t ast_ast_arena_expr_alloc(struct ast_ASTArena * arena);
extern struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena * arena, int32_t ref);
extern void ast_ast_arena_expr_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Expr e);
extern int ast_ref_is_null(int32_t ref);
extern struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena * arena, int32_t ref);
extern void *std_heap_alloc_zeroed(size_t size);
extern int32_t ast_ast_arena_block_alloc(struct ast_ASTArena * arena);
extern struct ast_Block ast_ast_arena_block_get(struct ast_ASTArena * arena, int32_t ref);
extern void lexer_lexer_next_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * data);
extern void ast_ast_arena_block_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Block b);
extern void ast_ast_arena_init(struct ast_ASTArena * arena);
extern void std_heap_free(uint8_t * ptr);
extern struct lexer_LexerResult lexer_lexer_next_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
extern int32_t ast_ast_arena_type_alloc(struct ast_ASTArena * arena);
extern void ast_ast_arena_type_set(struct ast_ASTArena * arena, int32_t ref, struct ast_Type t);
extern int32_t ast_ast_arena_func_alloc(struct ast_ASTArena * arena);
extern int32_t std_fs_fs_open_read(uint8_t * path);
extern ptrdiff_t std_fs_fs_read(int32_t fd, uint8_t * buf, size_t count);
extern int32_t std_fs_fs_close(int32_t fd);
extern void ast_pipeline_onefunc_copy_sidecar(uint8_t * dst, uint8_t * src);
extern int32_t ast_pipeline_onefunc_num_consts(uint8_t * out);
extern int32_t ast_pipeline_onefunc_num_lets(uint8_t * out);
extern int32_t ast_pipeline_onefunc_num_whiles(uint8_t * out);
extern int32_t ast_pipeline_onefunc_num_fors(uint8_t * out);
extern int32_t ast_pipeline_block_append_stmt_order(struct ast_ASTArena * arena, int32_t br, uint8_t kind, int32_t idx);
extern int32_t ast_pipeline_block_append_expr_stmt(struct ast_ASTArena * arena, int32_t br, int32_t expr_ref);
extern int32_t ast_pipeline_block_append_labeled(struct ast_ASTArena * arena, int32_t br, int32_t label_len, int32_t is_goto, int32_t goto_target_len, int32_t return_expr_ref);
extern int32_t ast_pipeline_block_append_while(struct ast_ASTArena * arena, int32_t br, int32_t cond_ref, int32_t body_ref);
extern int32_t ast_pipeline_block_append_for(struct ast_ASTArena * arena, int32_t br, int32_t init_ref, int32_t cond_ref, int32_t step_ref, int32_t body_ref);
extern int32_t ast_pipeline_block_append_region(struct ast_ASTArena * arena, int32_t br, uint8_t * label, int32_t label_len, int32_t body_ref);
extern int32_t ast_pipeline_block_append_with_arena(struct ast_ASTArena * arena, int32_t br, int32_t cap_ref, int32_t body_ref);
extern int32_t ast_pipeline_block_append_if(struct ast_ASTArena * arena, int32_t br, int32_t cond_ref, int32_t then_ref, int32_t else_ref);
extern int32_t ast_pipeline_expr_append_array_lit_elem(struct ast_ASTArena * arena, int32_t expr_ref, int32_t elem_ref);
extern int32_t ast_pipeline_onefunc_append_let(uint8_t * out, uint8_t * name, int32_t name_len, int32_t init_val, int32_t init_ref, int32_t type_ref);
extern void ast_ast_pool_onefunc_reset(uint8_t * out);
extern int32_t ast_pipeline_onefunc_append_while(uint8_t * out, int32_t cond_ref, int32_t body_ref);
extern int32_t ast_pipeline_onefunc_append_for(uint8_t * out, int32_t init_ref, int32_t cond_ref, int32_t step_ref, int32_t body_ref);
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
extern int32_t ast_pipeline_module_struct_layout_name_len(struct ast_Module * module, int32_t idx);
extern uint8_t ast_pipeline_module_struct_layout_name_byte_at(struct ast_Module * module, int32_t idx, int32_t off);
extern int32_t ast_pipeline_module_struct_layout_num_fields(struct ast_Module * module, int32_t idx);
extern int32_t ast_pipeline_module_struct_layout_field_name_len(struct ast_Module * module, int32_t li, int32_t j);
extern int32_t ast_pipeline_module_struct_layout_field_type_ref(struct ast_Module * module, int32_t li, int32_t j);
extern int32_t ast_pipeline_expr_append_call_arg(struct ast_ASTArena * arena, int32_t expr_ref, int32_t arg_ref);
extern void ast_pipeline_block_fill_whiles_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void ast_pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void ast_pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void ast_pipeline_block_fill_expr_stmts_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void ast_pipeline_block_fill_stmt_order_from_onefunc(struct ast_ASTArena * arena, int32_t br, uint8_t * out, int32_t count);
extern void lexer_lexer_next_buf_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
extern void ast_pipeline_module_import_path_copy(struct ast_Module * module, int32_t idx, uint8_t * dst, int32_t dst_cap);
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
extern int32_t parser_parse_peek_function_name_buf_glue(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, uint8_t * restrict out);
extern struct shux_slice_uint8_t parser_slice_from_buf(uint8_t * restrict data, int32_t len);
extern void parser_diagnostic_parse_skip(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t * restrict name);
extern void parser_diagnostic_parse_commit_fail(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len, uint8_t * restrict name);
extern void pipeline_module_struct_layout_reset_slot(struct ast_Module * restrict module, int32_t idx);
extern void pipeline_module_struct_layout_set_name(struct ast_Module * restrict module, int32_t idx, uint8_t * restrict bytes, int32_t len);
extern uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module * restrict module, int32_t idx, int32_t off);
extern void pipeline_module_struct_layout_set_field(struct ast_Module * restrict module, int32_t layout_idx, int32_t j, uint8_t * restrict fname, int32_t fname_len, int32_t ftype_ref, int32_t foff);
extern int32_t pipeline_struct_layout_next_field_offset(struct ast_Module * restrict module, struct ast_ASTArena * restrict arena, int32_t layout_idx, int32_t new_field_type_ref);
extern int32_t pipeline_struct_layout_next_field_offset_ex(struct ast_Module * restrict module, struct ast_ASTArena * restrict arena, int32_t layout_idx, int32_t new_field_type_ref, int32_t field_align_req);
extern void pipeline_module_struct_layout_set_field_align(struct ast_Module * restrict module, int32_t li, int32_t j, int32_t al);
extern int32_t pipeline_module_struct_layout_field_align_at(struct ast_Module * restrict module, int32_t li, int32_t j);
extern void pipeline_module_func_param_write(struct ast_Module * restrict module, int32_t func_index, int32_t param_index, uint8_t * restrict name_bytes, int32_t name_len, int32_t type_ref);
extern void pipeline_module_func_name_write(struct ast_Module * restrict module, int32_t func_index, uint8_t * restrict name_bytes, int32_t name_len);
extern void pipeline_arena_func_param_write(struct ast_ASTArena * restrict arena, int32_t func_ref, int32_t param_index, uint8_t * restrict name_bytes, int32_t name_len, int32_t type_ref);
extern void pipeline_arena_func_copy_slot_from_module(struct ast_ASTArena * restrict arena, int32_t func_ref, struct ast_Module * restrict module, int32_t fi);
extern void pipeline_module_reset_parse_counters_c(struct ast_Module * restrict module);
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
extern void pipeline_module_func_set_is_async(struct ast_Module * restrict module, int32_t fi, int32_t is_async);
extern void pipeline_module_func_set_num_params(struct ast_Module * restrict module, int32_t fi, int32_t n);
extern int32_t pipeline_block_append_const(struct ast_ASTArena * restrict arena, int32_t br, uint8_t * restrict name, int32_t name_len, int32_t type_ref, int32_t init_ref);
extern int32_t pipeline_block_append_let(struct ast_ASTArena * restrict arena, int32_t br, uint8_t * restrict name, int32_t name_len, int32_t type_ref, int32_t init_ref);
extern int32_t pipeline_block_append_if(struct ast_ASTArena * restrict arena, int32_t br, int32_t cond_ref, int32_t then_ref, int32_t else_ref);
extern int32_t pipeline_block_append_region(struct ast_ASTArena * restrict arena, int32_t br, uint8_t * restrict label, int32_t label_len, int32_t body_ref);
extern int32_t pipeline_block_append_with_arena(struct ast_ASTArena * restrict arena, int32_t br, int32_t cap_ref, int32_t body_ref);
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
extern int32_t pipeline_onefunc_append_region(uint8_t * restrict out, uint8_t * restrict label, int32_t label_len, int32_t body_ref);
extern int32_t pipeline_onefunc_append_with_arena(uint8_t * restrict out, int32_t cap_ref, int32_t body_ref);
extern int32_t pipeline_onefunc_num_regions(uint8_t * restrict out);
extern void pipeline_block_fill_regions_from_onefunc(struct ast_ASTArena * restrict arena, int32_t br, uint8_t * restrict out, int32_t count);
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
extern void pipeline_parser_set_match_module(struct ast_Module * restrict m);
extern struct ast_Module * pipeline_parser_get_match_module();
extern int32_t pipeline_module_enum_variant_tag_for_names(struct ast_Module * restrict m, uint8_t * restrict enum_name, int32_t enum_len, uint8_t * restrict variant_name, int32_t variant_len);
extern int32_t pipeline_expr_append_match_arm(struct ast_ASTArena * restrict arena, int32_t expr_ref, int32_t result_ref, int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant, int32_t variant_index);
extern int32_t pipeline_expr_append_array_lit_elem(struct ast_ASTArena * restrict arena, int32_t expr_ref, int32_t elem_ref);
extern int32_t pipeline_expr_append_call_arg(struct ast_ASTArena * restrict arena, int32_t expr_ref, int32_t arg_ref);
extern void lexer_next_buf_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
extern int32_t ast_block_expr_stmt_ref(struct ast_ASTArena * restrict arena, int32_t block_ref, int32_t ei);
extern int32_t pipeline_block_append_labeled(struct ast_ASTArena * restrict arena, int32_t br, int32_t label_len, int32_t is_goto, int32_t goto_target_len, int32_t return_expr_ref);
extern void pipeline_block_labeled_set_names(struct ast_ASTArena * restrict arena, int32_t br, int32_t li, uint8_t * restrict label, int32_t label_len, uint8_t * restrict goto_target, int32_t goto_target_len);
extern int32_t pipeline_module_struct_layout_alloc(struct ast_Module * restrict module);
extern int32_t pipeline_module_struct_layout_name_len(struct ast_Module * restrict module, int32_t idx);
extern int32_t pipeline_module_struct_layout_num_fields(struct ast_Module * restrict module, int32_t idx);
extern void pipeline_module_struct_layout_set_num_fields(struct ast_Module * restrict module, int32_t idx, int32_t nf);
extern int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module * restrict module, int32_t li, int32_t j);
extern int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module * restrict module, int32_t li, int32_t j);
extern void pipeline_module_struct_layout_set_allow_padding(struct ast_Module * restrict module, int32_t idx, int32_t v);
extern void pipeline_module_struct_layout_set_soa(struct ast_Module * restrict module, int32_t idx, int32_t v);
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
extern int32_t pipeline_module_enum_append_variant(struct ast_Module * restrict module, int32_t idx, uint8_t * restrict bytes, int32_t len);
extern int32_t pipeline_type_ensure_by_kind_ord(struct ast_ASTArena * restrict arena, int32_t kind_ord);
extern int32_t pipeline_module_top_level_let_alloc(struct ast_Module * restrict module);
extern void pipeline_module_top_level_let_set(struct ast_Module * restrict module, int32_t idx, uint8_t * restrict name, int32_t name_len, int32_t type_ref, int32_t init_ref, int32_t is_const);
extern void parser_lex_copy_from_collect_imports(struct lexer_Lexer * restrict out, struct parser_CollectImportsResult res);
extern void parser_lex_from_lexer_result_val_into(struct lexer_Lexer * restrict out, struct lexer_LexerResult r);
extern void parser_lex_from_next_into_glue(struct lexer_Lexer * restrict out, struct lexer_LexerResult r);
extern void parser_lex_from_lexer_result_ptr_into(struct lexer_Lexer * restrict out, struct lexer_LexerResult * restrict r);
extern void parser_lex_from_result_ptr_into_glue(struct lexer_Lexer * restrict out_lex, struct lexer_LexerResult * restrict r);
extern void parser_lex_from_onefunc_result_ptr_into(struct lexer_Lexer * restrict out, struct parser_OneFuncResult * restrict res);
extern void parser_lex_from_onefunc_next_into_glue(struct lexer_Lexer * restrict out, struct parser_OneFuncResult * restrict res);
extern struct lexer_Lexer parser_lex_at_token_from_result_glue(struct lexer_LexerResult r);
extern struct lexer_Lexer parser_parser_rewind_lex_for_following_stmt_glue(struct lexer_Lexer lex_in, struct lexer_LexerResult r);
extern int32_t parser_advance_past_stmt_semicolon_into_glue(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern int32_t parser_advance_past_cond_rparen_into_glue(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_expr_set_common_zeros_glue(struct ast_Expr * restrict e);
extern void parser_parse_match_subject_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_match_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_at_simd_builtin_into_glue(struct ast_ASTArena * restrict arena, struct lexer_LexerResult r0, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_primary_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_as_suffix_into_glue(struct ast_ASTArena * restrict arena, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_unary_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_cast_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_term_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_addsub_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_shift_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_relcompare_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_compare_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_bitand_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_bitxor_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_bitor_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_logand_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_logor_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_ternary_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern enum ast_ExprKind compound_assign_token_to_expr_kind_from_glue(enum token_TokenKind kind);
extern int pipeline_expr_ref_is_assign_lvalue(struct ast_ASTArena * restrict arena, int32_t expr_ref);
extern void parser_parse_assign_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_finish_struct_lit_from_type_ident_into_glue(struct ast_ASTArena * restrict arena, int32_t lit_ref, struct lexer_Lexer lex_in_brace, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern void parser_parse_cond_expr_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_start, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
extern int parser_fill_block_const_let_from_res_glue(struct ast_ASTArena * restrict arena, int32_t block_ref, struct parser_OneFuncResult * restrict res, int32_t type_ref);
extern int parser_append_block_lets_from_res_glue(struct ast_ASTArena * restrict arena, int32_t block_ref, struct parser_OneFuncResult * restrict res, int32_t let_base, int32_t type_ref);
extern int parser_parse_if_stmt_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_at_if, struct shux_slice_uint8_t * source, int32_t type_ref, int32_t * restrict out_cond, int32_t * restrict out_then, int32_t * restrict out_else, struct lexer_Lexer * restrict lex_out);
extern void parser_parse_if_expr_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_at_if, struct shux_slice_uint8_t * source, int32_t type_ref, struct parser_ParseExprResult * restrict out);
extern int32_t parser_first_token_kind_glue(struct shux_slice_uint8_t * source);
extern int32_t parser_diag_first_ident_len_glue(struct shux_slice_uint8_t * source);
extern void parser_diag_skip_let_const_into_glue(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern struct lexer_LexerResult parser_diag_skip_let_const_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_body_skip_let_const_then_if_into_glue(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern int32_t parser_parse_body_let_bracket_compound_init_ref_glue(struct ast_ASTArena * restrict arena, size_t bracket_start, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct lexer_Lexer * restrict lex_out, struct lexer_LexerResult * restrict r_out);
extern int32_t parser_parse_type_ref_for_arena_into_glue(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct lexer_Lexer * restrict out_lex);
extern struct lexer_LexerResult parser_body_skip_let_const_then_if_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern struct lexer_Lexer parser_skip_balanced_parens_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_skip_balanced_parens_into_glue(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern struct lexer_Lexer parser_skip_balanced_braces_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_skip_balanced_braces_into_glue(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_skip_one_function_full_into_glue(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_skip_one_top_level_const_into_glue(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_skip_one_top_level_const_into_buf_glue(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
extern struct lexer_Lexer parser_skip_one_function_full_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern struct lexer_LexerResult parser_skip_one_if_core_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern struct lexer_LexerResult parser_skip_one_if_statement_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_skip_one_if_statement_into_glue(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_skip_one_if_core_into_glue(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern struct lexer_Lexer parser_diag_lex_after_imports_glue(struct shux_slice_uint8_t * source);
extern struct lexer_LexerResult parser_diag_after_imports_then_structs_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern int32_t parser_diag_fail_at_token_kind_glue(struct shux_slice_uint8_t * source);
extern int32_t parser_struct_field_name_from_tok_glue(struct lexer_LexerResult r, struct shux_slice_uint8_t * source, uint8_t * restrict out);
extern void parser_import_path_dot_segment_copy_glue(struct shux_slice_uint8_t * source, size_t token_start, int32_t seg_len, uint8_t * restrict path_buf, int32_t path_len);
extern struct lexer_Lexer parser_skip_imports_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_collect_imports_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct ast_Module * restrict module, struct parser_CollectImportsResult * restrict out);
extern void parser_skip_one_struct_into_glue(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern struct lexer_Lexer parser_skip_one_struct_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern int32_t parser_module_try_register_enum_name_glue(struct ast_Module * restrict module, uint8_t * restrict name, int32_t name_len);
extern void parser_module_append_enum_variants_and_skip_body_into_glue(struct ast_Module * restrict module, int32_t enum_idx, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_skip_one_enum_register_into_glue(struct ast_Module * restrict module, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_skip_one_enum_into_glue(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern struct lexer_Lexer parser_skip_one_enum_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_skip_one_trait_into_glue(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern struct lexer_Lexer parser_skip_one_trait_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_skip_one_impl_into_glue(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern struct lexer_Lexer parser_skip_one_impl_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_skip_one_extern_into_glue(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern struct lexer_Lexer parser_skip_one_extern_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_write_extern_params_to_pools_glue(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, int32_t func_ref, int32_t fi, struct parser_ExternParseResult * restrict res);
extern void parser_parse_one_extern_skip_into_glue(struct parser_ExternParseResult * restrict out, struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_parse_one_extern_and_add_into_glue(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct lexer_Lexer * restrict lex_out);
extern void parser_lex_from_try_skip_into_glue(struct lexer_Lexer * restrict out, struct parser_TrySkipAllowResult t);
extern void parser_lex_from_library_into_glue(struct lexer_Lexer * restrict out, struct parser_LibraryParseResult lib);
extern struct lexer_Lexer parser_lex_from_try_skip_glue(struct parser_TrySkipAllowResult t);
extern struct lexer_Lexer parser_lex_from_library_glue(struct parser_LibraryParseResult lib);
extern int parser_parse_one_function_library_scan_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_LibraryParseScanResult * restrict result);
extern int parser_struct_layout_name_exists_arr_glue(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen);
extern int32_t parser_struct_layout_first_name_match_idx_glue(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen);
extern int32_t parser_struct_layout_placeholder_idx_glue(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen);
extern struct parser_LibraryParseResult parser_parse_one_function_library_glue(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern struct parser_TrySkipAllowResult parser_parse_into_try_skip_allow_glue(struct lexer_Lexer lex, struct lexer_LexerResult r, struct shux_slice_uint8_t * source);
extern struct parser_TrySkipAllowResult parser_try_skip_allow_padding_struct_glue(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern int32_t parser_consume_qualified_type_ident_name_glue(struct shux_slice_uint8_t * source, struct lexer_LexerResult * restrict r, uint8_t * restrict out, int32_t * restrict out_len);
extern int32_t parser_alloc_pointee_type_ref_from_tok_glue(struct ast_ASTArena * restrict arena, struct shux_slice_uint8_t * source, struct lexer_LexerResult * restrict r);
extern int32_t parser_parser_alloc_vector_type_ref_glue(struct ast_ASTArena * restrict arena, int32_t elem_ord, int32_t lanes);
extern int32_t parser_parser_vector_type_ref_from_ident_spelling_glue(struct ast_ASTArena * restrict arena, struct shux_slice_uint8_t * source, struct lexer_LexerResult r);
extern int32_t parser_parse_struct_record_layout_into_glue(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct lexer_Lexer * restrict out_lex, int32_t allow_pad, int32_t force_soa);
extern void parser_parse_one_function_buf_into_glue(struct parser_OneFuncResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
extern void parser_parse_one_function_library_into_glue(struct parser_LibraryParseResult * restrict out, struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
extern void parser_parse_into_try_skip_allow_into_glue(struct parser_TrySkipAllowResult * restrict out, struct lexer_Lexer lex, struct lexer_LexerResult r, struct shux_slice_uint8_t * source);
extern void parser_parse_one_top_level_let_into_glue(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, int is_const, struct parser_TopLevelLetResult * restrict out);
extern void parser_parse_into_set_main_index_glue(struct ast_Module * restrict module, int32_t main_idx);
extern int32_t parser_diag_token_after_collect_imports_glue(struct shux_slice_uint8_t * source, struct ast_Module * restrict module);
extern int32_t parser_diag_parse_one_after_collect_imports_glue(struct shux_slice_uint8_t * source, struct ast_Module * restrict module, struct ast_ASTArena * restrict arena);
extern int32_t parser_parse_one_function_ok_for_pipeline_glue(struct ast_ASTArena * restrict arena, struct shux_slice_uint8_t * source);

/* C-04 -E-extern TU aliases */
#define lexer_init lexer_lexer_init
#define ast_arena_expr_alloc ast_ast_arena_expr_alloc
#define ast_arena_expr_get ast_ast_arena_expr_get
#define ast_arena_expr_set ast_ast_arena_expr_set
#define ast_arena_type_get ast_ast_arena_type_get
#define ast_arena_block_alloc ast_ast_arena_block_alloc
#define ast_arena_block_get ast_ast_arena_block_get
#define lexer_next_into lexer_lexer_next_into
#define ast_arena_block_set ast_ast_arena_block_set
#define ast_arena_init ast_ast_arena_init
#define lexer_next_buf lexer_lexer_next_buf
#define ast_arena_type_alloc ast_ast_arena_type_alloc
#define ast_arena_type_set ast_ast_arena_type_set
#define ast_arena_func_alloc ast_ast_arena_func_alloc
#define ast_block_expr_stmt_ref ast_ast_ast_block_expr_stmt_ref
#define pipeline_onefunc_append_const ast_pipeline_onefunc_append_const
#define pipeline_onefunc_const_init_ref ast_pipeline_onefunc_const_init_ref
#define pipeline_onefunc_const_type_ref ast_pipeline_onefunc_const_type_ref

int32_t parser_parse_peek_function_name_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, uint8_t * restrict out);
void parser_pipeline_module_reset_parse_counters(struct ast_Module * restrict module);
uint8_t * parser_onefunc_result_pool_ptr(struct parser_OneFuncResult * restrict res);
void parser_copy_lex_from_import_into(struct lexer_Lexer * restrict out, struct parser_CollectImportsResult res);
void parser_lex_from_next_into(struct lexer_Lexer * restrict out, struct lexer_LexerResult r);
void parser_lex_from_result_ptr_into(struct lexer_Lexer * restrict out_lex, struct lexer_LexerResult * restrict r);
void parser_lex_from_onefunc_next_into(struct lexer_Lexer * restrict out, struct parser_OneFuncResult * restrict res);
size_t parser_lexer_pos_before_run(size_t end_pos, int32_t run_len);
int32_t parser_lexer_token_run_len(enum token_TokenKind kind);
struct lexer_Lexer parser_lex_at_token_from_result(struct lexer_LexerResult r);
struct lexer_Lexer parser_rewind_lex_for_following_stmt(struct lexer_Lexer lex_in, struct lexer_LexerResult r);
int parser_match_kw_immediately_before(struct shux_slice_uint8_t * source, size_t ident_start);
int parser_match_kw_immediately_before_buf(uint8_t * restrict data, int32_t len, size_t ident_start);
int32_t parser_advance_past_stmt_semicolon_into(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
int32_t parser_advance_past_stmt_semicolon_into_buf(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
int32_t parser_advance_past_cond_rparen_into(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
int32_t parser_advance_past_cond_rparen_into_buf(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
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
int32_t parser_alloc_float_lit(struct ast_ASTArena * restrict arena, double fval);
int32_t parser_expr_wrap_in_return(struct ast_ASTArena * restrict arena, int32_t type_ref, int32_t inner_ref);
int parser_should_wrap_func_tail_in_return(struct ast_ASTArena * restrict arena, struct parser_OneFuncResult * restrict res, int32_t type_ref);
void parser_parse_match_subject_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_match_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_at_simd_builtin_into(struct ast_ASTArena * restrict arena, struct lexer_LexerResult r0, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_primary_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_as_suffix_into(struct ast_ASTArena * restrict arena, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_unary_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_cast_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_term_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_addsub_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_shift_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_relcompare_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_compare_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_bitand_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_bitxor_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_bitor_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_logand_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_logor_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_ternary_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
int parser_is_compound_assign_token(enum token_TokenKind kind);
enum ast_ExprKind parser_compound_assign_token_to_expr_kind(enum token_TokenKind kind);
int parser_expr_ref_is_assign_lvalue(struct ast_ASTArena * restrict arena, int32_t expr_ref);
void parser_parse_assign_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_expr_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_finish_struct_lit_from_type_ident_into(struct ast_ASTArena * restrict arena, int32_t lit_ref, struct lexer_Lexer lex_in_brace, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_cond_expr_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_start, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_expr_with_leading_int_as_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_start, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out);
void parser_parse_expr_with_leading_int_as_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_start, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
int parser_fill_block_const_let_from_res(struct ast_ASTArena * restrict arena, int32_t block_ref, struct parser_OneFuncResult * restrict res, int32_t type_ref);
int parser_append_block_lets_from_res(struct ast_ASTArena * restrict arena, int32_t block_ref, struct parser_OneFuncResult * restrict res, int32_t let_base, int32_t type_ref);
int parser_parse_if_stmt_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_at_if, struct shux_slice_uint8_t * source, int32_t type_ref, int32_t * restrict out_cond, int32_t * restrict out_then, int32_t * restrict out_else, struct lexer_Lexer * restrict lex_out);
void parser_parse_block_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_after_lbrace, struct shux_slice_uint8_t * source, int32_t type_ref, struct parser_ParseBlockResult * restrict out);
int32_t parser_wrap_block_ref_as_expr(struct ast_ASTArena * restrict arena, int32_t block_ref, int32_t type_ref);
void parser_parse_if_expr_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_at_if, struct shux_slice_uint8_t * source, int32_t type_ref, struct parser_ParseExprResult * restrict out);
struct parser_ParseResult parser_parse(struct shux_slice_uint8_t * source);
int32_t parser_first_token_kind(struct shux_slice_uint8_t * source);
int32_t parser_first_token_kind_buf(uint8_t * restrict data, int32_t len);
int32_t parser_diag_first_ident_len(struct shux_slice_uint8_t * source);
int32_t parser_diag_first_ident_len_buf(uint8_t * restrict data, int32_t len);
void parser_diag_skip_let_const_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct lexer_LexerResult parser_diag_skip_let_const(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct lexer_LexerResult parser_diag_skip_let_const_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_diag_skip_let_const_into_buf(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_body_skip_let_const_then_if_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
int32_t parser_parse_body_let_bracket_compound_init_ref(struct ast_ASTArena * restrict arena, size_t bracket_start, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct lexer_Lexer * restrict lex_out, struct lexer_LexerResult * restrict r_out);
int32_t parser_parse_type_ref_for_arena_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct lexer_Lexer * restrict out_lex);
void parser_parse_body_lets_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_OneFuncResult * restrict out, struct lexer_Lexer * restrict lex_out);
struct lexer_LexerResult parser_body_skip_let_const_then_if(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct lexer_LexerResult parser_body_skip_let_const_then_if_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_body_skip_let_const_then_if_into_buf(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_balanced_parens(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_skip_balanced_parens_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_skip_balanced_parens_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_balanced_parens_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_balanced_braces(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_skip_balanced_braces_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_skip_balanced_braces_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_balanced_braces_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_function_full_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_skip_one_top_level_const_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_skip_one_top_level_const_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_one_function_full(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_skip_one_function_full_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_one_function_full_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_LexerResult parser_skip_one_if_core(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct lexer_LexerResult parser_skip_one_if_statement(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_skip_one_if_statement_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_skip_one_if_core_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct lexer_LexerResult parser_skip_one_if_core_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_LexerResult parser_skip_one_if_statement_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_if_core_into_buf(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_if_statement_into_buf(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_diag_lex_after_imports(struct shux_slice_uint8_t * source);
struct lexer_Lexer parser_diag_lex_after_imports_buf(uint8_t * restrict data, int32_t len);
struct lexer_LexerResult parser_diag_after_imports_then_structs(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct lexer_LexerResult parser_diag_after_imports_then_structs_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
int32_t parser_diag_fail_at_token_kind(struct shux_slice_uint8_t * source);
int32_t parser_diag_fail_at_token_kind_buf(uint8_t * restrict data, int32_t len);
void parser_copy_slice_to_name64(struct shux_slice_uint8_t * source, size_t start, int32_t nlen, uint8_t * restrict out);
void parser_copy_slice_to_name64_at_end(struct shux_slice_uint8_t * source, size_t end_pos, int32_t nlen, uint8_t * restrict out);
int32_t parser_struct_field_name_from_tok(struct lexer_LexerResult r, struct shux_slice_uint8_t * source, uint8_t * restrict out);
int32_t parser_struct_field_name_from_tok_buf(struct lexer_LexerResult r, uint8_t * restrict data, int32_t len, uint8_t * restrict out);
int parser_struct_field_name_tok_kind(enum token_TokenKind k);
int parser_struct_field_continues_tok_kind(enum token_TokenKind k);
int parser_token_is_label_start(struct lexer_LexerResult r, struct shux_slice_uint8_t * source);
void parser_copy_slice_to_param32(struct shux_slice_uint8_t * source, size_t start, int32_t nlen, uint8_t * restrict out);
void parser_copy_slice_to_param32_at_end(struct shux_slice_uint8_t * source, size_t end_pos, int32_t nlen, uint8_t * restrict out);
void parser_copy_slice_to_name64_buf(uint8_t * restrict source, int32_t source_len, size_t start, int32_t nlen, uint8_t * restrict out);
void parser_copy_slice_to_name64_at_end_buf(uint8_t * restrict source, int32_t source_len, size_t end_pos, int32_t nlen, uint8_t * restrict out);
void parser_copy_slice_to_param32_at_end_buf(uint8_t * restrict source, int32_t source_len, size_t end_pos, int32_t nlen, uint8_t * restrict out);
void parser_copy_slice_to_param32_buf(uint8_t * restrict source, int32_t source_len, size_t start, int32_t nlen, uint8_t * restrict out);
void parser_parse_one_function_impl(struct parser_OneFuncResult * restrict out, struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
int32_t parser_import_path_dot_segment_len(enum token_TokenKind kind, int32_t ident_len);
void parser_import_path_dot_segment_copy(struct shux_slice_uint8_t * source, size_t token_start, int32_t seg_len, uint8_t * restrict path_buf, int32_t path_len);
void parser_import_path_dot_segment_copy_buf(uint8_t * restrict data, int32_t len, size_t token_start, int32_t seg_len, uint8_t * restrict path_buf, int32_t path_len);
void parser_parse_into_init(struct ast_Module * restrict module, struct ast_ASTArena * restrict arena);
struct lexer_Lexer parser_skip_imports(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct lexer_Lexer parser_skip_imports_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_collect_imports(struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct ast_Module * restrict module, struct parser_CollectImportsResult * restrict out);
void parser_collect_imports_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct ast_Module * restrict module, struct parser_CollectImportsResult * restrict out);
void parser_skip_one_struct_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct lexer_Lexer parser_skip_one_struct(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
int32_t parser_module_try_register_enum_name(struct ast_Module * restrict module, uint8_t * restrict name, int32_t name_len);
void parser_module_append_enum_variants_and_skip_body_into(struct ast_Module * restrict module, int32_t enum_idx, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_module_append_enum_variants_and_skip_body_into_buf(struct ast_Module * restrict module, int32_t enum_idx, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_enum_register_into(struct ast_Module * restrict module, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_skip_one_enum_register_into_buf(struct ast_Module * restrict module, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_enum_register_buf(struct ast_Module * restrict module, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_enum_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct lexer_Lexer parser_skip_one_enum(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_skip_one_trait_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct lexer_Lexer parser_skip_one_trait(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_skip_one_impl_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct lexer_Lexer parser_skip_one_impl(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_skip_one_enum_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_one_enum_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_trait_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_one_trait_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_impl_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_one_impl_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_extern_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct lexer_Lexer parser_skip_one_extern(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
uint8_t * parser_extern_parse_pool_ptr(struct parser_ExternParseResult * restrict res);
void parser_write_extern_params_to_pools(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, int32_t func_ref, int32_t fi, struct parser_ExternParseResult * restrict res);
void parser_extern_parse_set_fail(struct parser_ExternParseResult * restrict out, struct lexer_Lexer lex);
void parser_parse_one_extern_skip_into(struct parser_ExternParseResult * restrict out, struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_parse_one_extern_skip_into_buf(struct parser_ExternParseResult * restrict out, struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
int32_t parser_module_register_arena_func(struct ast_Module * restrict module, int32_t func_ref, struct ast_Func f);
void parser_parse_one_extern_and_add_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct lexer_Lexer * restrict lex_out);
void parser_skip_one_extern_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_one_extern_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_parse_one_extern_and_add_into_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct lexer_Lexer * restrict lex_out);
void parser_lex_from_try_skip_into(struct lexer_Lexer * restrict out, struct parser_TrySkipAllowResult t);
void parser_lex_from_library_into(struct lexer_Lexer * restrict out, struct parser_LibraryParseResult lib);
struct lexer_Lexer parser_lex_from_try_skip(struct parser_TrySkipAllowResult t);
struct lexer_Lexer parser_lex_from_library(struct parser_LibraryParseResult lib);
int parser_parse_one_function_library_scan(struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_LibraryParseScanResult * restrict result);
int parser_struct_layout_name_exists_arr(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen);
int32_t parser_struct_layout_first_name_match_idx(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen);
int32_t parser_struct_layout_placeholder_idx(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen);
struct parser_LibraryParseResult parser_parse_one_function_library(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct parser_LibraryParseResult parser_parse_one_function_library_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct parser_TrySkipAllowResult parser_parse_into_try_skip_allow(struct lexer_Lexer lex, struct lexer_LexerResult r, struct shux_slice_uint8_t * source);
struct parser_TrySkipAllowResult parser_parse_into_try_skip_allow_buf(struct lexer_Lexer lex, struct lexer_LexerResult r, uint8_t * restrict data, int32_t len);
struct parser_TrySkipAllowResult parser_try_skip_allow_padding_struct(struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
struct parser_TrySkipAllowResult parser_try_skip_allow_padding_struct_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_one_struct_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct lexer_Lexer parser_skip_one_struct_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
int32_t parser_consume_qualified_type_ident_name(struct shux_slice_uint8_t * source, struct lexer_LexerResult * restrict r, uint8_t * restrict out, int32_t * restrict out_len);
int32_t parser_consume_qualified_type_ident_name_buf(uint8_t * restrict data, int32_t len, struct lexer_LexerResult * restrict r, uint8_t * restrict out, int32_t * restrict out_len);
int parser_is_pointee_type_token(enum token_TokenKind kind);
int32_t parser_alloc_pointee_type_ref_from_tok(struct ast_ASTArena * restrict arena, struct shux_slice_uint8_t * source, struct lexer_LexerResult * restrict r);
int32_t parser_alloc_vector_type_ref(struct ast_ASTArena * restrict arena, int32_t elem_ord, int32_t lanes);
int32_t parser_vector_type_ref_from_ident_spelling(struct ast_ASTArena * restrict arena, struct shux_slice_uint8_t * source, struct lexer_LexerResult r);
int32_t parser_parse_struct_record_layout_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct lexer_Lexer * restrict out_lex, int32_t allow_pad, int32_t force_soa);
void parser_parse_one_function_buf_into(struct parser_OneFuncResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_parse_one_function_library_into(struct parser_LibraryParseResult * restrict out, struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source);
void parser_parse_one_function_library_into_buf(struct parser_LibraryParseResult * restrict out, struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_parse_into_try_skip_allow_into(struct parser_TrySkipAllowResult * restrict out, struct lexer_Lexer lex, struct lexer_LexerResult r, struct shux_slice_uint8_t * source);
void parser_parse_into_try_skip_allow_into_buf(struct parser_TrySkipAllowResult * restrict out, struct lexer_Lexer lex, struct lexer_LexerResult r, uint8_t * restrict data, int32_t len);
struct parser_ParseIntoResult parser_parse_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct shux_slice_uint8_t * source);
void parser_parse_one_top_level_let_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, int is_const, struct parser_TopLevelLetResult * restrict out);
void parser_parse_primary_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_unary_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_cast_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_term_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_addsub_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_shift_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_relcompare_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_compare_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_bitand_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_bitxor_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_bitor_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_logand_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_logor_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_ternary_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_assign_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_expr_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_finish_struct_lit_from_type_ident_into_buf(struct ast_ASTArena * restrict arena, int32_t lit_ref, struct lexer_Lexer lex_in_brace, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_cond_expr_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_start, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
int parser_parse_if_stmt_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_at_if, uint8_t * restrict data, int32_t len, int32_t type_ref, int32_t * restrict out_cond, int32_t * restrict out_then, int32_t * restrict out_else, struct lexer_Lexer * restrict lex_out);
void parser_parse_block_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_after_lbrace, uint8_t * restrict data, int32_t len, int32_t type_ref, struct parser_ParseBlockResult * restrict out);
void parser_parse_if_expr_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_at_if, uint8_t * restrict data, int32_t len, int32_t type_ref, struct parser_ParseExprResult * restrict out);
void parser_parse_match_subject_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_match_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_at_simd_builtin_into_buf(struct ast_ASTArena * restrict arena, struct lexer_LexerResult r0, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
void parser_parse_as_suffix_into_buf(struct ast_ASTArena * restrict arena, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out);
int32_t parser_parse_type_ref_for_arena_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct lexer_Lexer * restrict out_lex);
int32_t parser_parse_body_let_bracket_compound_init_ref_buf(struct ast_ASTArena * restrict arena, size_t bracket_start, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct lexer_Lexer * restrict lex_out, struct lexer_LexerResult * restrict r_out);
int32_t parser_parse_struct_record_layout_into_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct lexer_Lexer * restrict out_lex, int32_t allow_pad, int32_t force_soa);
int parser_parse_one_function_library_scan_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_LibraryParseScanResult * restrict result);
int32_t parser_alloc_pointee_type_ref_from_tok_buf(struct ast_ASTArena * restrict arena, uint8_t * restrict data, int32_t len, struct lexer_LexerResult * restrict r);
int32_t parser_vector_type_ref_from_ident_spelling_buf(struct ast_ASTArena * restrict arena, uint8_t * restrict data, int32_t len, struct lexer_LexerResult r);
void parser_parse_one_top_level_let_into_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, int is_const, struct parser_TopLevelLetResult * restrict out);
void parser_skip_balanced_parens_slice_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_skip_balanced_braces_slice_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_module_append_enum_variants_and_skip_body_slice_into_buf(struct ast_Module * restrict module, int32_t enum_idx, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_parse_one_extern_skip_buf(struct parser_ExternParseResult * restrict out, struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
void parser_parse_one_extern_and_add_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct lexer_Lexer * restrict lex_out);
struct parser_LibraryParseResult parser_parse_one_function_library_from_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len);
struct parser_TrySkipAllowResult parser_parse_into_try_skip_allow_from_buf(struct lexer_Lexer lex, struct lexer_LexerResult r, uint8_t * restrict data, int32_t len);
struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, uint8_t * restrict data, int32_t len);
void parser_parse_into_set_main_index(struct ast_Module * restrict module, int32_t main_idx);
int32_t parser_diag_token_after_collect_imports(struct shux_slice_uint8_t * source, struct ast_Module * restrict module);
int32_t parser_diag_parse_one_after_collect_imports(struct shux_slice_uint8_t * source, struct ast_Module * restrict module, struct ast_ASTArena * restrict arena);
int32_t parser_parse_one_function_ok_for_pipeline(struct ast_ASTArena * restrict arena, struct shux_slice_uint8_t * source);
int32_t parser_get_module_num_imports(struct ast_Module * restrict module);
void parser_get_module_import_path(struct ast_Module * restrict module, int32_t i, uint8_t out[64]);
int32_t parser_copy_module_import_path64(struct ast_Module * restrict module, int32_t i, uint8_t out[64]);
int32_t parser_parse_peek_function_name_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, uint8_t * restrict out) {
  return parser_parse_peek_function_name_buf_glue(lex, data, len, out);
}
void parser_pipeline_module_reset_parse_counters(struct ast_Module * restrict module) {
  (void)(pipeline_module_reset_parse_counters_c(module));
}
uint8_t * parser_onefunc_result_pool_ptr(struct parser_OneFuncResult * restrict res) {
  return ((uint8_t *)(res));
}
void parser_copy_lex_from_import_into(struct lexer_Lexer * restrict out, struct parser_CollectImportsResult res) {
  (void)(parser_lex_copy_from_collect_imports(out, res));
}
void parser_lex_from_next_into(struct lexer_Lexer * restrict out, struct lexer_LexerResult r) {
  (void)(parser_lex_from_next_into_glue(out, r));
}
void parser_lex_from_result_ptr_into(struct lexer_Lexer * restrict out_lex, struct lexer_LexerResult * restrict r) {
  (void)(parser_lex_from_result_ptr_into_glue(out_lex, r));
}
void parser_lex_from_onefunc_next_into(struct lexer_Lexer * restrict out, struct parser_OneFuncResult * restrict res) {
  (void)(parser_lex_from_onefunc_next_into_glue(out, res));
}
size_t parser_lexer_pos_before_run(size_t end_pos, int32_t run_len) {
  int32_t rl = run_len;
  size_t start = end_pos - ((size_t)(rl));
  return start;
}
int32_t parser_lexer_token_run_len(enum token_TokenKind kind) {
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_RETURN) {   return 6;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_FUNCTION) {   return 8;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_CONST) {   return 5;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_WHILE) {   return 5;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_FALSE) {   return 5;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_STRUCT) {   return 6;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_IMPORT) {   return 6;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_EXTERN) {   return 6;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ko = ((int32_t)(kind));
  (void)(({ int32_t __tmp = 0; if (ko == 29) {   return 5;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_LET) {   return 3;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_IF) {   return 2;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_FOR) {   return 3;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_ELSE) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_TRUE) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_ENUM) {   return 4;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_MATCH) {   return 5;
 } else (__tmp = 0) ; __tmp; }));
  return 1;
}
struct lexer_Lexer parser_lex_at_token_from_result(struct lexer_LexerResult r) {
  return parser_lex_at_token_from_result_glue(r);
}
struct lexer_Lexer parser_rewind_lex_for_following_stmt(struct lexer_Lexer lex_in, struct lexer_LexerResult r) {
  return parser_parser_rewind_lex_for_following_stmt_glue(lex_in, r);
}
int parser_match_kw_immediately_before(struct shux_slice_uint8_t * source, size_t ident_start) {
  (void)(({ int __tmp = 0; if (ident_start < 6) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  size_t p = ident_start - 6;
  return (p < 0 || (size_t)(p) >= (source)->length ? (shux_panic_(1, 0), (source)->data[0]) : (source)->data[p]) == 109 && (p + 1 < 0 || (size_t)(p + 1) >= (source)->length ? (shux_panic_(1, 0), (source)->data[0]) : (source)->data[p + 1]) == 97 && (p + 2 < 0 || (size_t)(p + 2) >= (source)->length ? (shux_panic_(1, 0), (source)->data[0]) : (source)->data[p + 2]) == 116 && (p + 3 < 0 || (size_t)(p + 3) >= (source)->length ? (shux_panic_(1, 0), (source)->data[0]) : (source)->data[p + 3]) == 99 && (p + 4 < 0 || (size_t)(p + 4) >= (source)->length ? (shux_panic_(1, 0), (source)->data[0]) : (source)->data[p + 4]) == 104 && (p + 5 < 0 || (size_t)(p + 5) >= (source)->length ? (shux_panic_(1, 0), (source)->data[0]) : (source)->data[p + 5]) == 32;
}
int parser_match_kw_immediately_before_buf(uint8_t * restrict data, int32_t len, size_t ident_start) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_match_kw_immediately_before(&(slice), ident_start);
}
int32_t parser_advance_past_stmt_semicolon_into(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_advance_past_stmt_semicolon_into_glue(r_out, lex, source);
}
int32_t parser_advance_past_stmt_semicolon_into_buf(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_advance_past_stmt_semicolon_into(r_out, lex, &(slice));
}
int32_t parser_advance_past_cond_rparen_into(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_advance_past_cond_rparen_into_glue(r_out, lex, source);
}
int32_t parser_advance_past_cond_rparen_into_buf(struct lexer_LexerResult * restrict r_out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_advance_past_cond_rparen_into(r_out, lex, &(slice));
}
void parser_onefunc_result_layout_prime() {
  uint8_t z64[64] = { 0 };
  struct parser_OneFuncResult _prime = ({ struct parser_OneFuncResult _t = { 0 }; _t.ok = 0; _t.next_lex = lexer_init(); _t.name_len = 0; _t.num_params = 0; memcpy(_t.name, z64, sizeof(_t.name)); _t; });
  ((_prime).name_len = (0));
}
void parser_set_onefunc_fail(struct parser_OneFuncResult * restrict out, struct lexer_Lexer next_lex) {
  ((out)->ok = (0));
  ((out)->next_lex = (next_lex));
}
void parser_onefunc_result_layout_prime_b() {
  struct parser_OneFuncResult _q2 = (struct parser_OneFuncResult){ .num_consts = 0, .num_lets = 0 };
  ((_q2).num_consts = (0));
}
void parser_onefunc_result_layout_prime_c() {
  struct parser_OneFuncResult _q3 = (struct parser_OneFuncResult){ .has_if_expr = 0, .if_cond_true = 0, .if_then_val = 0, .if_else_val = 0, .if_cond_expr_ref = 0, .has_mul = 0, .mul_right_val = 0 };
  ((_q3).if_cond_expr_ref = (0));
}
void parser_onefunc_result_layout_prime_d() {
  uint8_t ccn[64] = { 0 };
  struct parser_OneFuncResult _q4 = ({ struct parser_OneFuncResult _t = { 0 }; _t.has_binop = 0; _t.binop_right_val = 0; _t.binop_left_param_idx = (-1); _t.binop_right_param_idx = (-1); _t.has_unary_neg = 0; _t.return_val = 0; _t.has_call_expr = 0; memcpy(_t.call_callee_name, ccn, sizeof(_t.call_callee_name)); _t; });
  ((_q4).binop_left_param_idx = ((-1)));
}
void parser_onefunc_result_layout_prime_d_b() {
  uint8_t rvn[64] = { 0 };
  struct parser_OneFuncResult _q4b = ({ struct parser_OneFuncResult _t = { 0 }; _t.call_callee_len = 0; _t.return_var_name_len = 0; _t.return_expr_ref = 0; _t.call_num_args = 0; _t.num_loops = 0; memcpy(_t.return_var_name, rvn, sizeof(_t.return_var_name)); _t; });
  ((_q4b).call_num_args = (0));
}
void parser_onefunc_result_layout_prime_e() {
  struct parser_OneFuncResult _q5 = (struct parser_OneFuncResult){ .num_for_loops = 0, .num_if_stmts = 0 };
  ((_q5).num_if_stmts = (0));
}
void parser_onefunc_result_layout_prime_f() {
  struct parser_OneFuncResult _q6 = (struct parser_OneFuncResult){ .num_src_stmt_order = 0, .num_src_body_expr_stmts = 0, .func_return_type_ref = 0 };
  ((_q6).func_return_type_ref = (0));
}
void parser_copy_onefunc_into(struct parser_OneFuncResult * restrict dst, struct parser_OneFuncResult * restrict src) {
  int32_t preserved_func_ret_ty = (dst)->func_return_type_ref;
  (void)(pipeline_onefunc_copy_sidecar(parser_onefunc_result_pool_ptr(dst), parser_onefunc_result_pool_ptr(src)));
  ((dst)->ok = ((src)->ok));
  ((dst)->next_lex = ((src)->next_lex));
  ((dst)->name_len = ((src)->name_len));
  int32_t ni = 0;
  while (ni < 64) {
    (void)(({ uint8_t __tmp = 0; if (ni < (src)->name_len) {   (((dst)->name)[ni] = (((src)->name)[ni]));
 } else (__tmp = 0) ; __tmp; }));
    ++ni;
  }
  ((dst)->num_params = ((src)->num_params));
  ((dst)->num_consts = (pipeline_onefunc_num_consts(parser_onefunc_result_pool_ptr(dst))));
  ((dst)->num_lets = (pipeline_onefunc_num_lets(parser_onefunc_result_pool_ptr(dst))));
  ((dst)->has_if_expr = ((src)->has_if_expr));
  ((dst)->if_cond_true = ((src)->if_cond_true));
  ((dst)->if_then_val = ((src)->if_then_val));
  ((dst)->if_else_val = ((src)->if_else_val));
  ((dst)->if_cond_expr_ref = ((src)->if_cond_expr_ref));
  ((dst)->has_mul = ((src)->has_mul));
  ((dst)->mul_right_val = ((src)->mul_right_val));
  ((dst)->has_binop = ((src)->has_binop));
  ((dst)->binop_right_val = ((src)->binop_right_val));
  ((dst)->binop_left_param_idx = ((src)->binop_left_param_idx));
  ((dst)->binop_right_param_idx = ((src)->binop_right_param_idx));
  ((dst)->has_unary_neg = ((src)->has_unary_neg));
  ((dst)->return_val = ((src)->return_val));
  ((dst)->return_var_name_len = ((src)->return_var_name_len));
  int32_t rvni = 0;
  while (rvni < 64) {
    (((dst)->return_var_name)[rvni] = (((src)->return_var_name)[rvni]));
    ++rvni;
  }
  ((dst)->return_expr_ref = ((src)->return_expr_ref));
  ((dst)->has_explicit_return_kw = ((src)->has_explicit_return_kw));
  ((dst)->has_call_expr = ((src)->has_call_expr));
  ((dst)->call_callee_len = ((src)->call_callee_len));
  int32_t cci = 0;
  while (cci < 64) {
    (((dst)->call_callee_name)[cci] = (((src)->call_callee_name)[cci]));
    ++cci;
  }
  ((dst)->call_num_args = ((src)->call_num_args));
  ((dst)->num_loops = (pipeline_onefunc_num_whiles(parser_onefunc_result_pool_ptr(dst))));
  ((dst)->num_for_loops = (pipeline_onefunc_num_fors(parser_onefunc_result_pool_ptr(dst))));
  ((dst)->num_if_stmts = (pipeline_onefunc_num_if_stmts(parser_onefunc_result_pool_ptr(dst))));
  ((dst)->num_src_stmt_order = (pipeline_onefunc_num_src_stmt_order(parser_onefunc_result_pool_ptr(dst))));
  ((dst)->num_src_body_expr_stmts = (pipeline_onefunc_num_body_expr_stmts(parser_onefunc_result_pool_ptr(dst))));
  (void)(({ int32_t __tmp = 0; if ((src)->func_return_type_ref != 0) {   ((dst)->func_return_type_ref = ((src)->func_return_type_ref));
 } else {   ((dst)->func_return_type_ref = (preserved_func_ret_ty));
 } ; __tmp; }));
}
struct parser_OneFuncResult parser_onefunc_scratch_empty() {
  uint8_t z64[64] = { 0 };
  return ({ struct parser_OneFuncResult _t = { 0 }; _t.ok = 0; _t.next_lex = lexer_init(); _t.name_len = 0; _t.num_params = 0; memcpy(_t.name, z64, sizeof(_t.name)); _t; });
}
void parser_onefunc_merge_pool_out_to_snap(struct parser_OneFuncResult * restrict snap, struct parser_OneFuncResult * restrict out) {
  (void)(pipeline_onefunc_copy_sidecar(parser_onefunc_result_pool_ptr(snap), parser_onefunc_result_pool_ptr(out)));
  ((snap)->num_params = ((out)->num_params));
  (void)(({ int32_t __tmp = 0; if ((out)->func_return_type_ref != 0) {   ((snap)->func_return_type_ref = ((out)->func_return_type_ref));
 } else (__tmp = 0) ; __tmp; }));
  ((snap)->num_consts = (pipeline_onefunc_num_consts(parser_onefunc_result_pool_ptr(snap))));
  ((snap)->num_lets = (pipeline_onefunc_num_lets(parser_onefunc_result_pool_ptr(snap))));
  ((snap)->num_if_stmts = (pipeline_onefunc_num_if_stmts(parser_onefunc_result_pool_ptr(snap))));
  ((snap)->num_src_stmt_order = (pipeline_onefunc_num_src_stmt_order(parser_onefunc_result_pool_ptr(snap))));
  ((snap)->num_src_body_expr_stmts = (pipeline_onefunc_num_body_expr_stmts(parser_onefunc_result_pool_ptr(snap))));
  ((snap)->num_loops = (pipeline_onefunc_num_whiles(parser_onefunc_result_pool_ptr(snap))));
  ((snap)->num_for_loops = (pipeline_onefunc_num_fors(parser_onefunc_result_pool_ptr(snap))));
}
void parser_onefunc_finish_impl_to_out(struct parser_OneFuncResult * restrict out, struct parser_OneFuncResult * restrict snap, struct lexer_Lexer lex, uint8_t * restrict name, int32_t name_len, int32_t ret_expr_storage) {
  (void)(parser_onefunc_merge_pool_out_to_snap(snap, out));
  ((snap)->return_expr_ref = (ret_expr_storage));
  ((snap)->ok = (1));
  ((snap)->next_lex = (lex));
  ((snap)->name_len = (name_len));
  int32_t ni = 0;
  while (ni < 64) {
    (((snap)->name)[ni] = ((name)[ni]));
    ++ni;
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
  ((snap)->has_call_expr = (has_call));
  ((snap)->return_var_name_len = (ret_var_len));
  ((snap)->return_expr_ref = (ret_expr_ref));
  ((snap)->has_explicit_return_kw = (1));
  int32_t rvni = 0;
  while (rvni < 64) {
    (((snap)->return_var_name)[rvni] = ((ret_var)[rvni]));
    ++rvni;
  }
}
void parser_onefunc_push_src_stmt(struct parser_OneFuncResult * restrict out, uint8_t kind, int32_t idx) {
  int32_t _so = pipeline_onefunc_push_stmt_order(parser_onefunc_result_pool_ptr(out), kind, idx);
  (void)(({ int32_t __tmp = 0; if (_so >= 0) {   ((out)->num_src_stmt_order = (pipeline_onefunc_num_src_stmt_order(parser_onefunc_result_pool_ptr(out))));
 } else (__tmp = 0) ; __tmp; }));
}
void parser_expr_set_common_zeros(struct ast_Expr * restrict e) {
  (void)(parser_expr_set_common_zeros_glue(e));
}
int32_t parser_alloc_true_bool_lit(struct ast_ASTArena * restrict arena) {
  int32_t ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr e = ast_arena_expr_get(arena, ref);
  ((e).kind = (ast_ExprKind_EXPR_BOOL_LIT));
  ((e).int_val = (1));
  ((e).line = (0));
  ((e).col = (0));
  (void)(parser_expr_set_common_zeros((&(e))));
  (void)(ast_arena_expr_set(arena, ref, e));
  return ref;
}
int32_t parser_alloc_float_lit(struct ast_ASTArena * restrict arena, double fval) {
  int32_t ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr e = ast_arena_expr_get(arena, ref);
  ((e).kind = (ast_ExprKind_EXPR_FLOAT_LIT));
  ((e).float_val = (fval));
  ((e).line = (0));
  ((e).col = (0));
  (void)(parser_expr_set_common_zeros((&(e))));
  (void)(ast_arena_expr_set(arena, ref, e));
  return ref;
}
int32_t parser_expr_wrap_in_return(struct ast_ASTArena * restrict arena, int32_t type_ref, int32_t inner_ref) {
  (void)(({ int32_t __tmp = 0; if (ast_ref_is_null(inner_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr inner = ast_arena_expr_get(arena, inner_ref);
  (void)(({ int32_t __tmp = 0; if ((inner).kind == ast_ExprKind_EXPR_RETURN) {   return inner_ref;
 } else (__tmp = 0) ; __tmp; }));
  int32_t wrap = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (wrap == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr rwe = ast_arena_expr_get(arena, wrap);
  ((rwe).kind = (ast_ExprKind_EXPR_RETURN));
  ((rwe).line = (0));
  ((rwe).col = (0));
  ((rwe).int_val = (0));
  (void)(parser_expr_set_common_zeros((&(rwe))));
  ((rwe).resolved_type_ref = (type_ref));
  ((rwe).unary_operand_ref = (inner_ref));
  (void)(ast_arena_expr_set(arena, wrap, rwe));
  return wrap;
}
int parser_should_wrap_func_tail_in_return(struct ast_ASTArena * restrict arena, struct parser_OneFuncResult * restrict res, int32_t type_ref) {
  (void)res;
  (void)(({ int __tmp = 0; if (ast_ref_is_null(type_ref)) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type rtw = ast_arena_type_get(arena, type_ref);
  (void)(({ int __tmp = 0; if ((rtw).kind == ast_TypeKind_TYPE_VOID) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  return 1;
}
void parser_parse_match_subject_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_match_subject_into_glue(arena, lex, source, out));
}
void parser_parse_match_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_match_into_glue(arena, lex, source, out));
}
void parser_parse_at_simd_builtin_into(struct ast_ASTArena * restrict arena, struct lexer_LexerResult r0, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_at_simd_builtin_into_glue(arena, r0, source, out));
}
void parser_parse_primary_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_primary_into_glue(arena, lex, source, out));
}
void parser_parse_as_suffix_into(struct ast_ASTArena * restrict arena, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_as_suffix_into_glue(arena, source, out));
}
void parser_parse_unary_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_unary_into_glue(arena, lex, source, out));
}
void parser_parse_cast_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_cast_into_glue(arena, lex, source, out));
}
void parser_parse_term_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_term_into_glue(arena, lex, source, out));
}
void parser_parse_addsub_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_addsub_into_glue(arena, lex, source, out));
}
void parser_parse_shift_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_shift_into_glue(arena, lex, source, out));
}
void parser_parse_relcompare_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_relcompare_into_glue(arena, lex, source, out));
}
void parser_parse_compare_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_compare_into_glue(arena, lex, source, out));
}
void parser_parse_bitand_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_bitand_into_glue(arena, lex, source, out));
}
void parser_parse_bitxor_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_bitxor_into_glue(arena, lex, source, out));
}
void parser_parse_bitor_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_bitor_into_glue(arena, lex, source, out));
}
void parser_parse_logand_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_logand_into_glue(arena, lex, source, out));
}
void parser_parse_logor_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_logor_into_glue(arena, lex, source, out));
}
void parser_parse_ternary_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_ternary_into_glue(arena, lex, source, out));
}
int parser_is_compound_assign_token(enum token_TokenKind kind) {
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_PLUS_EQ) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_MINUS_EQ) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_STAR_EQ) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_SLASH_EQ) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_PERCENT_EQ) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_AMP_EQ) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_PIPE_EQ) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_CARET_EQ) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_LSHIFT_EQ) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_RSHIFT_EQ) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
enum ast_ExprKind parser_compound_assign_token_to_expr_kind(enum token_TokenKind kind) {
  return compound_assign_token_to_expr_kind_from_glue(kind);
}
int parser_expr_ref_is_assign_lvalue(struct ast_ASTArena * restrict arena, int32_t expr_ref) {
  return pipeline_expr_ref_is_assign_lvalue(arena, expr_ref);
}
void parser_parse_assign_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_assign_into_glue(arena, lex, source, out));
}
void parser_parse_expr_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_assign_into(arena, lex, source, out));
}
void parser_finish_struct_lit_from_type_ident_into(struct ast_ASTArena * restrict arena, int32_t lit_ref, struct lexer_Lexer lex_in_brace, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_finish_struct_lit_from_type_ident_into_glue(arena, lit_ref, lex_in_brace, source, out));
}
void parser_parse_cond_expr_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_start, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_cond_expr_into_glue(arena, lex_start, source, out));
}
void parser_parse_expr_with_leading_int_as_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_start, struct shux_slice_uint8_t * source, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_cond_expr_into(arena, lex_start, source, out));
}
void parser_parse_expr_with_leading_int_as_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_start, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_expr_with_leading_int_as_into(arena, lex_start, &(slice), out));
}
int parser_fill_block_const_let_from_res(struct ast_ASTArena * restrict arena, int32_t block_ref, struct parser_OneFuncResult * restrict res, int32_t type_ref) {
  return parser_fill_block_const_let_from_res_glue(arena, block_ref, res, type_ref);
}
int parser_append_block_lets_from_res(struct ast_ASTArena * restrict arena, int32_t block_ref, struct parser_OneFuncResult * restrict res, int32_t let_base, int32_t type_ref) {
  return parser_append_block_lets_from_res_glue(arena, block_ref, res, let_base, type_ref);
}
int parser_parse_if_stmt_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_at_if, struct shux_slice_uint8_t * source, int32_t type_ref, int32_t * restrict out_cond, int32_t * restrict out_then, int32_t * restrict out_else, struct lexer_Lexer * restrict lex_out) {
  return parser_parse_if_stmt_into_glue(arena, lex_at_if, source, type_ref, out_cond, out_then, out_else, lex_out);
}
void parser_parse_block_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_after_lbrace, struct shux_slice_uint8_t * source, int32_t type_ref, struct parser_ParseBlockResult * restrict out) {
  size_t scratch_sz = pipeline_sizeof_onefunc_result();
  uint8_t * scratch_raw = std_heap_alloc_zeroed(scratch_sz);
  (void)(({ int32_t __tmp = 0; if (scratch_raw == ((uint8_t *)(0))) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct parser_OneFuncResult * temp = ((struct parser_OneFuncResult *)(scratch_raw));
  ((temp)->ok = (1));
  ((temp)->next_lex = (lex_after_lbrace));
  ((temp)->return_var_name_len = (0));
  ((temp)->return_expr_ref = (0));
  ((temp)->num_src_stmt_order = (0));
  ((temp)->num_src_body_expr_stmts = (0));
  ((temp)->func_return_type_ref = (0));
  struct lexer_Lexer lex_cur = lex_after_lbrace;
  (void)(parser_parse_body_lets_into(arena, lex_after_lbrace, source, temp, (&(lex_cur))));
  int32_t block_ref = ast_arena_block_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (block_ref == 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Block b = ast_arena_block_get(arena, block_ref);
  ((b).num_loops = (0));
  ((b).num_for_loops = (0));
  ((b).num_if_stmts = (0));
  ((b).num_regions = (0));
  ((b).num_defers = (0));
  ((b).num_labeled_stmts = (0));
  ((b).num_expr_stmts = (0));
  ((b).final_expr_ref = (0));
  ((b).num_stmt_order = (0));
  (void)(ast_arena_block_set(arena, block_ref, b));
  (void)(({ int32_t __tmp = 0; if ((!parser_fill_block_const_let_from_res(arena, block_ref, temp, type_ref))) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (b = (ast_arena_block_get(arena, block_ref)));
  int32_t ci = 0;
  while (ci < (b).num_consts) {
    (void)(({ int32_t __tmp = 0; if (pipeline_block_append_stmt_order(arena, block_ref, 0, ci) < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    ++ci;
  }
  int32_t li = 0;
  while (li < (b).num_lets) {
    (void)(({ int32_t __tmp = 0; if (pipeline_block_append_stmt_order(arena, block_ref, 1, li) < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    ++li;
  }
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex_cur, source));
  int stmt_tok_ready_blk = 1;
  while (((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {
    (void)(({ int32_t __tmp = 0; if ((!stmt_tok_ready_blk)) { (void)(lexer_next_into((&(r)), lex_cur, source)); } else (__tmp = 0) ; __tmp; }));
    (stmt_tok_ready_blk = (0));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LET || ((r).tok).kind == token_TokenKind_TOKEN_CONST) {   int32_t let_base_mid = (b).num_lets;
  ((temp)->num_lets = (0));
  ((temp)->num_consts = (0));
  int32_t kw_back_mid = 3;
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_CONST) {   (kw_back_mid = (5));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_mid_let = (struct lexer_Lexer){ .pos = parser_lexer_pos_before_run(((r).next_lex).pos, kw_back_mid), .line = ((r).tok).line, .col = ((r).tok).col };
  (void)(parser_parse_body_lets_into(arena, lex_mid_let, source, temp, (&(lex_cur))));
  (void)(({ int32_t __tmp = 0; if ((!parser_append_block_lets_from_res(arena, block_ref, temp, let_base_mid, type_ref))) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (b = (ast_arena_block_get(arena, block_ref)));
  int32_t pi_mid = let_base_mid;
  while (pi_mid < (b).num_lets) {
    (void)(({ int32_t __tmp = 0; if (pipeline_block_append_stmt_order(arena, block_ref, 1, pi_mid) < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    ++pi_mid;
  }
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (stmt_tok_ready_blk = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (parser_token_is_label_start(r, source)) {   int32_t label_len_blk = ((r).tok).ident_len;
  size_t label_start_blk = (r).token_start;
  (void)(({ size_t __tmp = 0; if (label_start_blk == 0) {   (label_start_blk = (parser_lexer_pos_before_run(((r).next_lex).pos, label_len_blk)));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_LexerResult colon_blk = (struct lexer_LexerResult){ .next_lex = (r).next_lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(colon_blk)), (r).next_lex, source));
  (lex_cur = ((colon_blk).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_GOTO) {   (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t goto_len_blk = ((r).tok).ident_len;
  size_t goto_start_blk = (r).token_start;
  (void)(({ size_t __tmp = 0; if (goto_start_blk == 0) {   (goto_start_blk = (parser_lexer_pos_before_run(((r).next_lex).pos, goto_len_blk)));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t goto_row_blk[32] = { 0 };
  (void)(parser_copy_slice_to_param32(source, goto_start_blk, goto_len_blk, (&((goto_row_blk)[0]))));
  (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (lex_cur = ((r).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t label_row_blk[32] = { 0 };
  (void)(parser_copy_slice_to_param32(source, label_start_blk, label_len_blk, (&((label_row_blk)[0]))));
  int32_t li_goto = pipeline_block_append_labeled(arena, block_ref, label_len_blk, 1, goto_len_blk, 0);
  (void)(({ int32_t __tmp = 0; if (li_goto < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_block_labeled_set_names(arena, block_ref, li_goto, (&((label_row_blk)[0])), label_len_blk, (&((goto_row_blk)[0])), goto_len_blk));
  (stmt_tok_ready_blk = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RETURN) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex_cur)), r));
  struct parser_ParseExprResult ret_val_lbl = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cur };
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(parser_parse_expr_into(arena, lex_cur, source, (&(ret_val_lbl))));
  (void)(({ int32_t __tmp = 0; if ((!(ret_val_lbl).ok)) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex_cur = ((ret_val_lbl).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (lex_cur = ((r).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
 } else (__tmp = 0) ; __tmp; }));
  uint8_t label_row_ret[32] = { 0 };
  (void)(parser_copy_slice_to_param32(source, label_start_blk, label_len_blk, (&((label_row_ret)[0]))));
  int32_t ret_operand = 0;
  (void)(({ int32_t __tmp = 0; if ((ret_val_lbl).ok) {   (ret_operand = ((ret_val_lbl).expr_ref));
 } else (__tmp = 0) ; __tmp; }));
  int32_t li_ret = pipeline_block_append_labeled(arena, block_ref, label_len_blk, 0, 0, ret_operand);
  (void)(({ int32_t __tmp = 0; if (li_ret < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_block_labeled_set_names(arena, block_ref, li_ret, (&((label_row_ret)[0])), label_len_blk, ((uint8_t *)(0)), 0));
  (stmt_tok_ready_blk = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RETURN) {   (void)(parser_lex_from_next_into((&(lex_cur)), r));
  struct parser_ParseExprResult ret_val_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cur };
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_parse_expr_into(arena, lex_cur, source, (&(ret_val_res))));
  (void)(({ int32_t __tmp = 0; if ((!(ret_val_res).ok)) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex_cur = ((ret_val_res).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (lex_cur = ((r).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
 } else (__tmp = 0) ; __tmp; }));
  int32_t ret_ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (ret_ref == 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr re = ast_arena_expr_get(arena, ret_ref);
  ((re).kind = (ast_ExprKind_EXPR_RETURN));
  ((re).line = (0));
  ((re).col = (0));
  (void)(parser_expr_set_common_zeros((&(re))));
  (void)(({ int32_t __tmp = 0; if ((ret_val_res).ok) {   ((re).unary_operand_ref = ((ret_val_res).expr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (void)(ast_arena_expr_set(arena, ret_ref, re));
  int32_t ret_ex_i = pipeline_block_append_expr_stmt(arena, block_ref, ret_ref);
  (void)(({ int32_t __tmp = 0; if (ret_ex_i < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_block_append_stmt_order(arena, block_ref, 2, ret_ex_i) < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (b = (ast_arena_block_get(arena, block_ref)));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   continue;
 } else (__tmp = 0) ; __tmp; }));
  (lex_cur = ((r).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (stmt_tok_ready_blk = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LOOP) {   (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex_cur = ((r).next_lex));
  int32_t cond_ref_blk = parser_alloc_true_bool_lit(arena);
  (void)(({ int32_t __tmp = 0; if (cond_ref_blk == 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct parser_ParseBlockResult block_res_blk = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_block_into(arena, lex_cur, source, type_ref, (&(block_res_blk))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res_blk).ok)) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t while_idx_blk = pipeline_block_append_while(arena, block_ref, cond_ref_blk, (block_res_blk).block_ref);
  (void)(({ int32_t __tmp = 0; if (while_idx_blk < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_block_append_stmt_order(arena, block_ref, 3, while_idx_blk) < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (b = (ast_arena_block_get(arena, block_ref)));
  (lex_cur = ((block_res_blk).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (stmt_tok_ready_blk = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_WHILE) {   (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex_cur = ((r).next_lex));
  struct lexer_Lexer loop_cond_start = lex_cur;
  struct parser_ParseExprResult expr_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = loop_cond_start };
  (void)(parser_parse_cond_expr_into(arena, loop_cond_start, source, (&(expr_res))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res).ok)) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t cond_ref = (expr_res).expr_ref;
  (lex_cur = ((expr_res).next_lex));
  (void)(({ int32_t __tmp = 0; if (parser_advance_past_cond_rparen_into((&(r)), lex_cur, source) == 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex_cur = ((r).next_lex));
  struct parser_ParseBlockResult block_res = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_block_into(arena, lex_cur, source, type_ref, (&(block_res))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res).ok)) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t while_idx = pipeline_block_append_while(arena, block_ref, cond_ref, (block_res).block_ref);
  (void)(({ int32_t __tmp = 0; if (while_idx < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_block_append_stmt_order(arena, block_ref, 3, while_idx) < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (b = (ast_arena_block_get(arena, block_ref)));
  (lex_cur = ((block_res).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (stmt_tok_ready_blk = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_FOR) {   (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex_cur = ((r).next_lex));
  int32_t init_ref = 0;
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   struct parser_ParseExprResult expr_res_fi = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_expr_into(arena, lex_cur, source, (&(expr_res_fi))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res_fi).ok)) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (init_ref = ((expr_res_fi).expr_ref));
  (lex_cur = ((expr_res_fi).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex_cur = ((r).next_lex));
  int32_t cond_ref = 0;
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   struct parser_ParseExprResult expr_res_fc = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_expr_into(arena, lex_cur, source, (&(expr_res_fc))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res_fc).ok)) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (cond_ref = ((expr_res_fc).expr_ref));
  (lex_cur = ((expr_res_fc).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex_cur = ((r).next_lex));
  int32_t step_ref = 0;
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   struct parser_ParseExprResult expr_res_fs = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_expr_into(arena, lex_cur, source, (&(expr_res_fs))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res_fs).ok)) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (step_ref = ((expr_res_fs).expr_ref));
  (lex_cur = ((expr_res_fs).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex_cur = ((r).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex_cur = ((r).next_lex));
  struct parser_ParseBlockResult block_res = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_block_into(arena, lex_cur, source, type_ref, (&(block_res))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res).ok)) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (cond_ref == 0) {   int32_t cond_expr_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (cond_expr_ref != 0) {   struct ast_Expr ce = ast_arena_expr_get(arena, cond_expr_ref);
  ((ce).kind = (ast_ExprKind_EXPR_BOOL_LIT));
  ((ce).int_val = (1));
  ((ce).line = (0));
  ((ce).col = (0));
  (void)(parser_expr_set_common_zeros((&(ce))));
  (void)(ast_arena_expr_set(arena, cond_expr_ref, ce));
  (cond_ref = (cond_expr_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t for_idx = pipeline_block_append_for(arena, block_ref, init_ref, cond_ref, step_ref, (block_res).block_ref);
  (void)(({ int32_t __tmp = 0; if (for_idx < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_block_append_stmt_order(arena, block_ref, 4, for_idx) < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (b = (ast_arena_block_get(arena, block_ref)));
  (lex_cur = ((block_res).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (stmt_tok_ready_blk = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_WITH_ARENA) {   (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex_cur)), r));
  struct parser_ParseExprResult cap_res_wa = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_expr_into(arena, lex_cur, source, (&(cap_res_wa))));
  (void)(({ int32_t __tmp = 0; if ((!(cap_res_wa).ok) || (cap_res_wa).expr_ref == 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t cap_ref_wa = (cap_res_wa).expr_ref;
  (lex_cur = ((cap_res_wa).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex_cur)), r));
  struct parser_ParseBlockResult block_res_wa = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_block_into(arena, lex_cur, source, type_ref, (&(block_res_wa))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res_wa).ok)) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t wa_pool_i = pipeline_block_append_with_arena(arena, block_ref, cap_ref_wa, (block_res_wa).block_ref);
  (void)(({ int32_t __tmp = 0; if (wa_pool_i < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_block_append_stmt_order(arena, block_ref, 6, wa_pool_i) < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (b = (ast_arena_block_get(arena, block_ref)));
  (lex_cur = ((block_res_wa).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (stmt_tok_ready_blk = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_REGION) {   (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t reg_label_blk[64] = { 0 };
  (void)(parser_copy_slice_to_name64(source, (r).token_start, ((r).tok).ident_len, (&((reg_label_blk)[0]))));
  int32_t reg_label_len_blk = ((r).tok).ident_len;
  (void)(parser_lex_from_next_into((&(lex_cur)), r));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex_cur)), r));
  struct parser_ParseBlockResult block_res_reg = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex_cur };
  (void)(parser_parse_block_into(arena, lex_cur, source, type_ref, (&(block_res_reg))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res_reg).ok)) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t reg_pool_i = pipeline_block_append_region(arena, block_ref, (&((reg_label_blk)[0])), reg_label_len_blk, (block_res_reg).block_ref);
  (void)(({ int32_t __tmp = 0; if (reg_pool_i < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_block_append_stmt_order(arena, block_ref, 6, reg_pool_i) < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (b = (ast_arena_block_get(arena, block_ref)));
  (lex_cur = ((block_res_reg).next_lex));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (stmt_tok_ready_blk = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IF) {   struct lexer_Lexer if_start = parser_lex_at_token_from_result(r);
  int32_t if_cond = 0;
  int32_t if_then = 0;
  int32_t if_else = 0;
  (void)(({ int32_t __tmp = 0; if ((!parser_parse_if_stmt_into(arena, if_start, source, type_ref, (&(if_cond)), (&(if_then)), (&(if_else)), (&(lex_cur))))) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t if_pool_i = pipeline_block_append_if(arena, block_ref, if_cond, if_then, if_else);
  (void)(({ int32_t __tmp = 0; if (if_pool_i < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (pipeline_block_append_stmt_order(arena, block_ref, 5, if_pool_i) < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (b = (ast_arena_block_get(arena, block_ref)));
  (void)(lexer_next_into((&(r)), lex_cur, source));
  (stmt_tok_ready_blk = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    struct lexer_Lexer stmt_start = parser_lex_at_token_from_result(r);
    struct parser_ParseExprResult expr_stmt_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = stmt_start };
    (void)(parser_parse_expr_into(arena, stmt_start, source, (&(expr_stmt_res))));
    (void)(({ int32_t __tmp = 0; if ((!(expr_stmt_res).ok)) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (lex_cur = ((expr_stmt_res).next_lex));
    struct lexer_LexerResult rpeek_fe = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
    (void)(lexer_next_into((&(rpeek_fe)), lex_cur, source));
    (void)(({ int32_t __tmp = 0; if (((rpeek_fe).tok).kind == token_TokenKind_TOKEN_RBRACE) {   ((b).final_expr_ref = ((expr_stmt_res).expr_ref));
  (void)(ast_arena_block_set(arena, block_ref, b));
  (r = (rpeek_fe));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (parser_advance_past_stmt_semicolon_into((&(r)), lex_cur, source) == 0) {   (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   ((b).final_expr_ref = ((expr_stmt_res).expr_ref));
  (void)(ast_arena_block_set(arena, block_ref, b));
  break;
 } else (__tmp = 0) ; __tmp; }));
  ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   ((b).final_expr_ref = ((expr_stmt_res).expr_ref));
  (void)(ast_arena_block_set(arena, block_ref, b));
  break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_result_ptr_into((&(lex_cur)), (&(r))));
  struct lexer_LexerResult after_semi_blk = (struct lexer_LexerResult){ .next_lex = lex_cur, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(after_semi_blk)), lex_cur, source));
  (r = (after_semi_blk));
 } else (__tmp = 0) ; __tmp; }));
    int32_t ex_pool_i = pipeline_block_append_expr_stmt(arena, block_ref, (expr_stmt_res).expr_ref);
    (void)(({ int32_t __tmp = 0; if (ex_pool_i < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (pipeline_block_append_stmt_order(arena, block_ref, 2, ex_pool_i) < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (b = (ast_arena_block_get(arena, block_ref)));
    (stmt_tok_ready_blk = (1));
    continue;
  }
  (b = (ast_arena_block_get(arena, block_ref)));
  (void)(({ struct ast_Block __tmp = (struct ast_Block){0}; if ((b).num_lets > 0 && (b).num_stmt_order == 0) {   int32_t li_fix = 0;
  while (li_fix < (b).num_lets) {
    (void)(({ int32_t __tmp = 0; if (pipeline_block_append_stmt_order(arena, block_ref, 1, li_fix) < 0) {   ((out)->ok = (0));
  return;
 } else (__tmp = 0) ; __tmp; }));
    ++li_fix;
  }
  (b = (ast_arena_block_get(arena, block_ref)));
 } else (__tmp = (struct ast_Block){0}) ; __tmp; }));
  (void)(ast_arena_block_set(arena, block_ref, b));
  ((out)->ok = (1));
  ((out)->block_ref = (block_ref));
  ((out)->next_lex = ((r).next_lex));
}
int32_t parser_wrap_block_ref_as_expr(struct ast_ASTArena * restrict arena, int32_t block_ref, int32_t type_ref) {
  (void)(({ int32_t __tmp = 0; if (block_ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (ref == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Expr e = ast_arena_expr_get(arena, ref);
  (void)(parser_expr_set_common_zeros((&(e))));
  ((e).kind = (ast_ExprKind_EXPR_BLOCK));
  ((e).block_ref = (block_ref));
  ((e).resolved_type_ref = (type_ref));
  ((e).line = (0));
  ((e).col = (0));
  (void)(ast_arena_expr_set(arena, ref, e));
  return ref;
}
void parser_parse_if_expr_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_at_if, struct shux_slice_uint8_t * source, int32_t type_ref, struct parser_ParseExprResult * restrict out) {
  (void)(parser_parse_if_expr_into_glue(arena, lex_at_if, source, type_ref, out));
}
struct parser_ParseResult parser_parse(struct shux_slice_uint8_t * source) {
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
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_INT) {   (ret_val = (((r).tok).int_val));
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
  struct ast_Expr e_read = ast_arena_expr_get(heap_arena, (expr_out).expr_ref);
  (void)(({ int32_t __tmp = 0; if ((e_read).const_folded_valid != 0) {   (ret_val = ((e_read).const_folded_val));
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((expr_out).next_lex));
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
int32_t parser_first_token_kind(struct shux_slice_uint8_t * source) {
  return parser_first_token_kind_glue(source);
}
int32_t parser_first_token_kind_buf(uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_first_token_kind(&(slice));
}
int32_t parser_diag_first_ident_len(struct shux_slice_uint8_t * source) {
  return parser_diag_first_ident_len_glue(source);
}
int32_t parser_diag_first_ident_len_buf(uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_diag_first_ident_len(&(slice));
}
void parser_diag_skip_let_const_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_diag_skip_let_const_into_glue(out, lex, source));
}
struct lexer_LexerResult parser_diag_skip_let_const(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_diag_skip_let_const_glue(lex, source);
}
struct lexer_LexerResult parser_diag_skip_let_const_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_diag_skip_let_const(lex, &(slice));
}
void parser_diag_skip_let_const_into_buf(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_diag_skip_let_const_into(out, lex, &(slice)));
}
void parser_body_skip_let_const_then_if_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_body_skip_let_const_then_if_into_glue(out, lex, source));
}
int32_t parser_parse_body_let_bracket_compound_init_ref(struct ast_ASTArena * restrict arena, size_t bracket_start, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct lexer_Lexer * restrict lex_out, struct lexer_LexerResult * restrict r_out) {
  return parser_parse_body_let_bracket_compound_init_ref_glue(arena, bracket_start, lex, source, lex_out, r_out);
}
int32_t parser_parse_type_ref_for_arena_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct lexer_Lexer * restrict out_lex) {
  return parser_parse_type_ref_for_arena_into_glue(arena, lex, source, out_lex);
}
void parser_parse_body_lets_into(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_OneFuncResult * restrict out, struct lexer_Lexer * restrict lex_out) {
  uint8_t * pool = parser_onefunc_result_pool_ptr(out);
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LET && ((r).tok).kind != token_TokenKind_TOKEN_CONST) {   (lex = (parser_lex_at_token_from_result(r)));
  ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  while (((r).tok).kind == token_TokenKind_TOKEN_LET || ((r).tok).kind == token_TokenKind_TOKEN_CONST) {
    int is_let = ((r).tok).kind == token_TokenKind_TOKEN_LET;
    int32_t let_init_val = 0;
    int32_t let_init_ref = 0;
    int32_t let_ty_ref = 0;
    (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    int32_t name_len = ((r).tok).ident_len;
    (void)(({ int32_t __tmp = 0; if (name_len <= 0 || name_len > 63) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    size_t name_start = (r).token_start;
    uint8_t name_row[64] = { 0 };
    int32_t ni = 0;
    while (ni < name_len && ni < 64) {
      (void)(({ uint8_t __tmp = 0; if (name_start + ni < (source)->length) {   ((ni < 0 || (ni) >= 64 ? (shux_panic_(1, 0), 0) : ((name_row)[ni] = (name_start + ni < 0 || (size_t)(name_start + ni) >= (source)->length ? (shux_panic_(1, 0), (source)->data[0]) : (source)->data[name_start + ni]), 0)));
 } else (__tmp = 0) ; __tmp; }));
      ++ni;
    }
    int32_t zi = ni;
    while (zi < 64) {
      ((name_row)[zi] = (0));
      ++zi;
    }
    (void)(({ int32_t __tmp = 0; if (is_let) {  } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_COLON) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
    (let_ty_ref = (parser_parse_type_ref_for_arena_into(arena, lex, source, (&(lex)))));
    (void)(({ int32_t __tmp = 0; if (let_ty_ref == 0) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(lexer_next_into((&(r)), lex, source));
    int let_omit_init = 0;
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_ASSIGN) {
  if (!is_let) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return; }
  if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_LET && ((r).tok).kind != token_TokenKind_TOKEN_CONST && ((r).tok).kind != token_TokenKind_TOKEN_RETURN && ((r).tok).kind != token_TokenKind_TOKEN_IF && ((r).tok).kind != token_TokenKind_TOKEN_WHILE && ((r).tok).kind != token_TokenKind_TOKEN_FOR && ((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return; }
  let_omit_init = 1;
  (let_init_ref = (-1));
  (let_init_val = (0));
 } else {
   (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
   (void)(lexer_next_into((&(r)), lex, source));
   (void)(({ int32_t __tmp2 = 0; if (is_let) {   (let_init_ref = (0));
  (let_init_val = (0));
 } else (__tmp2 = 0) ; __tmp2; }));
 } __tmp; }));
    int cast_init_semi_done = 0;
    if (!let_omit_init) {
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACKET) {   size_t bracket_start = (r).token_start;
  (void)(({ size_t __tmp = 0; if (bracket_start == 0) {   (bracket_start = ((lex).pos));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
  int32_t arr_ref = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (arr_ref != 0) {   struct ast_Expr ae0 = ast_arena_expr_get(arena, arr_ref);
  ((ae0).kind = (ast_ExprKind_EXPR_ARRAY_LIT));
  ((ae0).resolved_type_ref = (0));
  ((ae0).line = (0));
  ((ae0).col = (0));
  (void)(parser_expr_set_common_zeros((&(ae0))));
  (void)(ast_arena_expr_set(arena, arr_ref, ae0));
  while (((r).tok).kind != token_TokenKind_TOKEN_RBRACKET) {
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_INT) {   int32_t er = ast_arena_expr_alloc(arena);
  (void)(({ int32_t __tmp = 0; if (er != 0) {   struct ast_Expr ee = ast_arena_expr_get(arena, er);
  ((ee).kind = (ast_ExprKind_EXPR_LIT));
  ((ee).resolved_type_ref = (0));
  ((ee).line = (0));
  ((ee).col = (0));
  ((ee).int_val = (((r).tok).int_val));
  (void)(parser_expr_set_common_zeros((&(ee))));
  (void)(ast_arena_expr_set(arena, er, ee));
  (void)(pipeline_expr_append_array_lit_elem(arena, arr_ref, er));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_FLOAT) {   int32_t er = parser_alloc_float_lit(arena, ((r).tok).float_val);
  (void)(({ int32_t __tmp = 0; if (er != 0) {   (void)(pipeline_expr_append_array_lit_elem(arena, arr_ref, er));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_COMMA) {   (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACKET) {   break;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACKET) {   break;
 } else {   break;
 } ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
  }
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACKET) {   (void)(({ int32_t __tmp = 0; if (is_let) {   (let_init_ref = (arr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int arr_init_plain = ((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON || ((r).tok).kind == token_TokenKind_TOKEN_LET || ((r).tok).kind == token_TokenKind_TOKEN_CONST || ((r).tok).kind == token_TokenKind_TOKEN_RETURN || ((r).tok).kind == token_TokenKind_TOKEN_IF || ((r).tok).kind == token_TokenKind_TOKEN_WHILE || ((r).tok).kind == token_TokenKind_TOKEN_FOR || ((r).tok).kind == token_TokenKind_TOKEN_RBRACE;
  __tmp = ({ int32_t __tmp = 0; if (is_let && ((r).tok).kind == token_TokenKind_TOKEN_AS || (!arr_init_plain)) {   int32_t reparsed_ref = parser_parse_body_let_bracket_compound_init_ref(arena, bracket_start, lex, source, (&(lex)), (&(r)));
  (void)(({ int32_t __tmp = 0; if (reparsed_ref == 0) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (let_init_ref = (reparsed_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   size_t rhs_ident_start = (r).token_start;
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  struct lexer_Lexer expr_lex = (struct lexer_Lexer){ .pos = rhs_ident_start, .line = ((r).tok).line, .col = ((r).tok).col };
  struct parser_ParseExprResult expr_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = expr_lex };
  (void)(parser_parse_expr_into(arena, expr_lex, source, (&(expr_res))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res).ok)) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (is_let) {   (let_init_ref = ((expr_res).expr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((expr_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_TRUE || ((r).tok).kind == token_TokenKind_TOKEN_FALSE) {   (void)(({ int32_t __tmp = 0; if (is_let) {   int32_t bool_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (bool_ref != 0) {   struct ast_Expr be = ast_arena_expr_get(arena, bool_ref);
  ((be).kind = (ast_ExprKind_EXPR_BOOL_LIT));
  ((be).resolved_type_ref = (0));
  ((be).line = (0));
  ((be).col = (0));
  ((be).int_val = (({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_TRUE) {   __tmp = 1;
 } else {   __tmp = 0;
 } ; __tmp; })));
  (void)(ast_expr_init_match_enum((&(be))));
  ((be).binop_left_ref = (0));
  ((be).binop_right_ref = (0));
  ((be).unary_operand_ref = (0));
  ((be).if_cond_ref = (0));
  ((be).if_then_ref = (0));
  ((be).if_else_ref = (0));
  ((be).block_ref = (0));
  ((be).field_access_base_ref = (0));
  ((be).field_access_field_len = (0));
  ((be).field_access_is_enum_variant = (0));
  ((be).field_access_offset = (0));
  ((be).index_base_ref = (0));
  ((be).index_index_ref = (0));
  ((be).index_base_is_slice = (0));
  ((be).call_callee_ref = (0));
  ((be).call_num_args = (0));
  ((be).method_call_base_ref = (0));
  ((be).method_call_name_len = (0));
  ((be).method_call_num_args = (0));
  ((be).const_folded_val = (0));
  ((be).const_folded_valid = (0));
  ((be).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, bool_ref, be));
  (let_init_ref = (bool_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_FLOAT) {   (void)(({ int32_t __tmp = 0; if (is_let) {   (let_init_ref = (parser_alloc_float_lit(arena, ((r).tok).float_val)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_INT) {   int32_t int_val_saved = ((r).tok).int_val;
  size_t int_start = (r).token_start;
  (void)(({ size_t __tmp = 0; if (int_start == 0) {   (int_start = (((r).next_lex).pos - 1));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer int_lex = (struct lexer_Lexer){ .pos = int_start, .line = (lex).line, .col = (lex).col };
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  (void)(lexer_next_into((&(r)), lex, source));
  int int_init_plain = ((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON || ((r).tok).kind == token_TokenKind_TOKEN_LET || ((r).tok).kind == token_TokenKind_TOKEN_CONST || ((r).tok).kind == token_TokenKind_TOKEN_RETURN || ((r).tok).kind == token_TokenKind_TOKEN_IF || ((r).tok).kind == token_TokenKind_TOKEN_WHILE || ((r).tok).kind == token_TokenKind_TOKEN_FOR || ((r).tok).kind == token_TokenKind_TOKEN_RBRACE;
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_AS || (!int_init_plain)) {   struct parser_ParseExprResult expr_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = int_lex };
  (void)(parser_parse_expr_into(arena, int_lex, source, (&(expr_res))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res).ok)) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (is_let) {   (let_init_ref = ((expr_res).expr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((expr_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (is_let) {   (let_init_val = (int_val_saved));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_MINUS || ((r).tok).kind == token_TokenKind_TOKEN_BANG || ((r).tok).kind == token_TokenKind_TOKEN_LPAREN || ((r).tok).kind == token_TokenKind_TOKEN_TILDE) {   size_t rhs_unary_start = (r).token_start;
  (void)(({ size_t __tmp = 0; if (rhs_unary_start == 0) {   (rhs_unary_start = ((lex).pos));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer unary_lex = (struct lexer_Lexer){ .pos = rhs_unary_start, .line = ((r).tok).line, .col = ((r).tok).col };
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  struct parser_ParseExprResult unary_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = unary_lex };
  (void)(parser_parse_expr_into(arena, unary_lex, source, (&(unary_res))));
  (void)(({ int32_t __tmp = 0; if ((!(unary_res).ok)) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (is_let) {   (let_init_ref = ((unary_res).expr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((unary_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_AMP) {   size_t amp_start = (r).token_start;
  (void)(({ size_t __tmp = 0; if (amp_start == 0) {   (amp_start = ((lex).pos));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer amp_lex = (struct lexer_Lexer){ .pos = amp_start, .line = ((r).tok).line, .col = ((r).tok).col };
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  struct parser_ParseExprResult amp_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = amp_lex };
  (void)(parser_parse_expr_into(arena, amp_lex, source, (&(amp_res))));
  (void)(({ int32_t __tmp = 0; if ((!(amp_res).ok)) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (is_let) {   (let_init_ref = ((amp_res).expr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((amp_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IF) {   struct lexer_Lexer if_lex = parser_lex_at_token_from_result(r);
  struct parser_ParseExprResult if_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = if_lex };
  (void)(parser_parse_if_expr_into(arena, if_lex, source, let_ty_ref, (&(if_res))));
  (void)(({ int32_t __tmp = 0; if ((!(if_res).ok)) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (is_let) {   (let_init_ref = ((if_res).expr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((if_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (lex = (parser_rewind_lex_for_following_stmt(lex, r)));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_MATCH) {   struct lexer_Lexer match_lex = parser_lex_at_token_from_result(r);
  struct parser_ParseExprResult match_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = match_lex };
  (void)(parser_parse_match_into(arena, match_lex, source, (&(match_res))));
  (void)(({ int32_t __tmp = 0; if ((!(match_res).ok)) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (is_let) {   (let_init_ref = ((match_res).expr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((match_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (lex = (parser_rewind_lex_for_following_stmt(lex, r)));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_AWAIT || ((r).tok).kind == token_TokenKind_TOKEN_RUN || ((r).tok).kind == token_TokenKind_TOKEN_SPAWN) {   size_t async_start = (r).token_start;
  (void)(({ size_t __tmp = 0; if (async_start == 0) {   (async_start = ((lex).pos));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer async_lex = (struct lexer_Lexer){ .pos = async_start, .line = ((r).tok).line, .col = ((r).tok).col };
  (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  struct parser_ParseExprResult async_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = async_lex };
  (void)(parser_parse_expr_into(arena, async_lex, source, (&(async_res))));
  (void)(({ int32_t __tmp = 0; if ((!(async_res).ok)) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (is_let) {   (let_init_ref = ((async_res).expr_ref));
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((async_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; })) ; __tmp; }));
    }
    (void)(({ int32_t __tmp = 0; if ((!cast_init_semi_done)) {   __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  struct lexer_LexerResult after_semi = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(after_semi)), lex, source));
  (lex = (parser_lex_at_token_from_result(after_semi)));
  (r = (after_semi));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LET && ((r).tok).kind != token_TokenKind_TOKEN_CONST && ((r).tok).kind != token_TokenKind_TOKEN_RETURN && ((r).tok).kind != token_TokenKind_TOKEN_IF && ((r).tok).kind != token_TokenKind_TOKEN_WHILE && ((r).tok).kind != token_TokenKind_TOKEN_FOR && ((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   (void)(({ int32_t __tmp = 0; if ((!is_let && let_init_ref != 0 || let_init_val != 0)) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex = (parser_lex_at_token_from_result(r)));
 } else (__tmp = 0) ; __tmp; })) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (is_let) {   (void)(({ int32_t __tmp = 0; if (pipeline_onefunc_append_let(pool, (&((name_row)[0])), name_len, let_init_val, let_init_ref, let_ty_ref) < 0) {   ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
  ((out)->num_lets = (pipeline_onefunc_num_lets(pool)));
 } else (__tmp = 0) ; __tmp; }));
  }
  ((lex_out)->pos = ((lex).pos));
  ((lex_out)->line = ((lex).line));
  ((lex_out)->col = ((lex).col));
}
struct lexer_LexerResult parser_body_skip_let_const_then_if(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_body_skip_let_const_then_if_glue(lex, source);
}
struct lexer_LexerResult parser_body_skip_let_const_then_if_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_body_skip_let_const_then_if(lex, &(slice));
}
void parser_body_skip_let_const_then_if_into_buf(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_body_skip_let_const_then_if_into(out, lex, &(slice)));
}
struct lexer_Lexer parser_skip_balanced_parens(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_skip_balanced_parens_glue(lex, source);
}
void parser_skip_balanced_parens_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_skip_balanced_parens_into_glue(out, lex, source));
}
void parser_skip_balanced_parens_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  int32_t depth = 1;
  while (depth > 0) {
    struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LPAREN) {   ++depth;
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RPAREN) {   (depth = (depth - 1));
  __tmp = ({ int32_t __tmp = 0; if (depth == 0) {   ((out)->pos = (((r).next_lex).pos));
  ((out)->line = (((r).next_lex).line));
  ((out)->col = (((r).next_lex).col));
  return;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   ((out)->pos = ((lex).pos));
  ((out)->line = ((lex).line));
  ((out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
  }
  ((out)->pos = ((lex).pos));
  ((out)->line = ((lex).line));
  ((out)->col = ((lex).col));
}
struct lexer_Lexer parser_skip_balanced_parens_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_skip_balanced_parens(lex, &(slice));
}
struct lexer_Lexer parser_skip_balanced_braces(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_skip_balanced_braces_glue(lex, source);
}
void parser_skip_balanced_braces_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_skip_balanced_braces_into_glue(out, lex, source));
}
void parser_skip_balanced_braces_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  int32_t depth = 1;
  while (depth > 0) {
    struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   ++depth;
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (depth = (depth - 1));
  __tmp = ({ int32_t __tmp = 0; if (depth == 0) {   ((out)->pos = (((r).next_lex).pos));
  ((out)->line = (((r).next_lex).line));
  ((out)->col = (((r).next_lex).col));
  return;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   ((out)->pos = ((lex).pos));
  ((out)->line = ((lex).line));
  ((out)->col = ((lex).col));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
  }
  ((out)->pos = ((lex).pos));
  ((out)->line = ((lex).line));
  ((out)->col = ((lex).col));
}
struct lexer_Lexer parser_skip_balanced_braces_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_skip_balanced_braces(lex, &(slice));
}
void parser_skip_one_function_full_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_skip_one_function_full_into_glue(out, lex, source));
}
void parser_skip_one_top_level_const_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_skip_one_top_level_const_into_glue(out, lex, source));
}
void parser_skip_one_top_level_const_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  (void)(parser_skip_one_top_level_const_into_buf_glue(out, lex, data, len));
}
struct lexer_Lexer parser_skip_one_function_full(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_skip_one_function_full_glue(lex, source);
}
void parser_skip_one_function_full_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_skip_one_function_full_into(out, lex, &(slice)));
}
struct lexer_Lexer parser_skip_one_function_full_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_skip_one_function_full(lex, &(slice));
}
struct lexer_LexerResult parser_skip_one_if_core(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_skip_one_if_core_glue(lex, source);
}
struct lexer_LexerResult parser_skip_one_if_statement(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_skip_one_if_statement_glue(lex, source);
}
void parser_skip_one_if_statement_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_skip_one_if_statement_into_glue(out, lex, source));
}
void parser_skip_one_if_core_into(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_skip_one_if_core_into_glue(out, lex, source));
}
struct lexer_LexerResult parser_skip_one_if_core_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_skip_one_if_core(lex, &(slice));
}
struct lexer_LexerResult parser_skip_one_if_statement_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_skip_one_if_statement(lex, &(slice));
}
void parser_skip_one_if_core_into_buf(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_skip_one_if_core_into(out, lex, &(slice)));
}
void parser_skip_one_if_statement_into_buf(struct lexer_LexerResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_skip_one_if_statement_into(out, lex, &(slice)));
}
struct lexer_Lexer parser_diag_lex_after_imports(struct shux_slice_uint8_t * source) {
  return parser_diag_lex_after_imports_glue(source);
}
struct lexer_Lexer parser_diag_lex_after_imports_buf(uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_diag_lex_after_imports(&(slice));
}
struct lexer_LexerResult parser_diag_after_imports_then_structs(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_diag_after_imports_then_structs_glue(lex, source);
}
struct lexer_LexerResult parser_diag_after_imports_then_structs_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_diag_after_imports_then_structs(lex, &(slice));
}
int32_t parser_diag_fail_at_token_kind(struct shux_slice_uint8_t * source) {
  return parser_diag_fail_at_token_kind_glue(source);
}
int32_t parser_diag_fail_at_token_kind_buf(uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_diag_fail_at_token_kind(&(slice));
}
void parser_copy_slice_to_name64(struct shux_slice_uint8_t * source, size_t start, int32_t nlen, uint8_t * restrict out) {
  int32_t i = 0;
  while (i < nlen) {
    (void)(({ uint8_t __tmp = 0; if (start + ((size_t)(i)) < (source)->length) {   ((out)[i] = ((start + ((size_t)(i)) < 0 || (size_t)(start + ((size_t)(i))) >= (source)->length ? (shux_panic_(1, 0), (source)->data[0]) : (source)->data[start + ((size_t)(i))])));
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
}
void parser_copy_slice_to_name64_at_end(struct shux_slice_uint8_t * source, size_t end_pos, int32_t nlen, uint8_t * restrict out) {
  size_t start = end_pos - ((size_t)(nlen));
  (void)(parser_copy_slice_to_name64(source, start, nlen, out));
}
int32_t parser_struct_field_name_from_tok(struct lexer_LexerResult r, struct shux_slice_uint8_t * source, uint8_t * restrict out) {
  return parser_struct_field_name_from_tok_glue(r, source, out);
}
int32_t parser_struct_field_name_from_tok_buf(struct lexer_LexerResult r, uint8_t * restrict data, int32_t len, uint8_t * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_struct_field_name_from_tok(r, &(slice), out);
}
int parser_struct_field_name_tok_kind(enum token_TokenKind k) {
  (void)(({ int __tmp = 0; if (k == token_TokenKind_TOKEN_IDENT) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ko = ((int32_t)(k));
  (void)(({ int __tmp = 0; if (ko == 18) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int __tmp = 0; if (ko == 17) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int parser_struct_field_continues_tok_kind(enum token_TokenKind k) {
  (void)(({ int __tmp = 0; if (parser_struct_field_name_tok_kind(k)) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ko = ((int32_t)(k));
  (void)(({ int __tmp = 0; if (ko == 20) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int parser_token_is_label_start(struct lexer_LexerResult r, struct shux_slice_uint8_t * source) {
  (void)(({ int __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_LexerResult nx = (struct lexer_LexerResult){ .next_lex = (r).next_lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(nx)), (r).next_lex, source));
  return ((nx).tok).kind == token_TokenKind_TOKEN_COLON;
}
void parser_copy_slice_to_param32(struct shux_slice_uint8_t * source, size_t start, int32_t nlen, uint8_t * restrict out) {
  int32_t i = 0;
  while (i < 32) {
    (void)(({ uint8_t __tmp = 0; if (i < nlen && start + ((size_t)(i)) < (source)->length) {   ((out)[i] = ((start + ((size_t)(i)) < 0 || (size_t)(start + ((size_t)(i))) >= (source)->length ? (shux_panic_(1, 0), (source)->data[0]) : (source)->data[start + ((size_t)(i))])));
 } else {   ((out)[i] = (0));
 } ; __tmp; }));
    ++i;
  }
}
void parser_copy_slice_to_param32_at_end(struct shux_slice_uint8_t * source, size_t end_pos, int32_t nlen, uint8_t * restrict out) {
  size_t start = end_pos - ((size_t)(nlen));
  (void)(parser_copy_slice_to_param32(source, start, nlen, out));
}
void parser_copy_slice_to_name64_buf(uint8_t * restrict source, int32_t source_len, size_t start, int32_t nlen, uint8_t * restrict out) {
  int32_t i = 0;
  while (i < nlen) {
    (void)(({ uint8_t __tmp = 0; if (start + ((size_t)(i)) < ((size_t)(source_len))) {   ((out)[i] = ((source)[start + ((size_t)(i))]));
 } else (__tmp = 0) ; __tmp; }));
    ++i;
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
    (void)(({ uint8_t __tmp = 0; if (i < nlen && start + ((size_t)(i)) < ((size_t)(source_len))) {   ((out)[i] = ((source)[start + ((size_t)(i))]));
 } else {   ((out)[i] = (0));
 } ; __tmp; }));
    ++i;
  }
}
void parser_copy_slice_to_param32_buf(uint8_t * restrict source, int32_t source_len, size_t start, int32_t nlen, uint8_t * restrict out) {
  int32_t i = 0;
  while (i < 32) {
    (void)(({ uint8_t __tmp = 0; if (i < nlen && start + ((size_t)(i)) < ((size_t)(source_len))) {   ((out)[i] = ((source)[start + ((size_t)(i))]));
 } else {   ((out)[i] = (0));
 } ; __tmp; }));
    ++i;
  }
}
void parser_parse_one_function_impl(struct parser_OneFuncResult * restrict out, struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
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
  size_t name_start = ((size_t)(0));
  int32_t func_name_len_storage[1] = { 0 };
  struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IDENT) {  } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SPAWN) {   ((func_name_len_storage)[0] = (5));
  ((dummy_name)[0] = (115));
  ((1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), 0) : ((dummy_name)[1] = 112, 0)));
  ((2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), 0) : ((dummy_name)[2] = 97, 0)));
  ((3 < 0 || (3) >= 64 ? (shux_panic_(1, 0), 0) : ((dummy_name)[3] = 119, 0)));
  ((4 < 0 || (4) >= 64 ? (shux_panic_(1, 0), 0) : ((dummy_name)[4] = 110, 0)));
  (void)(parser_lex_from_next_into((&(lex)), r));
 } else {   (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SPAWN) {   ((func_name_len_storage)[0] = (5));
  ((dummy_name)[0] = (115));
  ((1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), 0) : ((dummy_name)[1] = 112, 0)));
  ((2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), 0) : ((dummy_name)[2] = 97, 0)));
  ((3 < 0 || (3) >= 64 ? (shux_panic_(1, 0), 0) : ((dummy_name)[3] = 119, 0)));
  ((4 < 0 || (4) >= 64 ? (shux_panic_(1, 0), 0) : ((dummy_name)[4] = 110, 0)));
  (void)(parser_lex_from_next_into((&(lex)), r));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else {   ((func_name_len_storage)[0] = (((r).tok).ident_len));
  (void)(({ int32_t __tmp = 0; if ((func_name_len_storage)[0] <= 0 || (func_name_len_storage)[0] > 63) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (name_start = (((r).next_lex).pos - (func_name_len_storage)[0]));
  (void)(parser_copy_slice_to_name64(source, name_start, (func_name_len_storage)[0], (&((dummy_name)[0]))));
  (void)(parser_lex_from_next_into((&(lex)), r));
 } ; __tmp; })) ; __tmp; });
 } ; __tmp; })) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((func_name_len_storage)[0] == 0) {   (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  ((func_name_len_storage)[0] = (((r).tok).ident_len));
  (void)(({ int32_t __tmp = 0; if ((func_name_len_storage)[0] <= 0 || (func_name_len_storage)[0] > 63) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (name_start = (((r).next_lex).pos - (func_name_len_storage)[0]));
  (void)(parser_copy_slice_to_name64(source, name_start, (func_name_len_storage)[0], (&((dummy_name)[0]))));
  (void)(parser_lex_from_next_into((&(lex)), r));
 } else (__tmp = 0) ; __tmp; }));
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
    ((out)->num_params = (param_idx + 1));
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
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RPAREN) {   (void)(parser_lex_from_next_into((&(lex)), r));
  break;
 } else (__tmp = 0) ; __tmp; }));
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
  ((out)->func_return_type_ref = (ret_type_ref));
  (void)(({ int __tmp = 0; if (ret_type_ref != 0) {   struct ast_Type rt = ast_arena_type_get(arena, ret_type_ref);
  __tmp = ({ int __tmp = 0; if ((rt).kind == ast_TypeKind_TYPE_BOOL) {   (return_type_is_bool = (1));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  ((out)->num_src_stmt_order = (0));
  ((out)->num_src_body_expr_stmts = (0));
  (void)(parser_parse_body_lets_into(arena, lex, source, out, (&(lex))));
  ((out)->num_lets = (pipeline_onefunc_num_lets(parser_onefunc_result_pool_ptr(out))));
  int32_t lsr = 0;
  while (lsr < (out)->num_lets) {
    (void)(parser_onefunc_push_src_stmt(out, 1, lsr));
    ++lsr;
  }
  struct lexer_LexerResult r_peek = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(r_peek)), lex, source));
  (r = (r_peek));
  (lex = (parser_rewind_lex_for_following_stmt(lex, r_peek)));
  int stmt_tok_ready = 1;
  while (1) {
    (void)(({ int32_t __tmp = 0; if ((!stmt_tok_ready)) {   (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
    (stmt_tok_ready = (0));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RETURN || ((r).tok).kind == token_TokenKind_TOKEN_RBRACE || ((r).tok).kind == token_TokenKind_TOKEN_MATCH) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LET || ((r).tok).kind == token_TokenKind_TOKEN_CONST) {   int32_t n_before_mid = pipeline_onefunc_num_lets(parser_onefunc_result_pool_ptr(out));
  int32_t kw_back = 3;
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_CONST) {   (kw_back = (5));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer lex_mid_let = (struct lexer_Lexer){ .pos = parser_lexer_pos_before_run(((r).next_lex).pos, kw_back), .line = ((r).tok).line, .col = ((r).tok).col };
  (void)(parser_parse_body_lets_into(arena, lex_mid_let, source, out, (&(lex))));
  ((out)->num_lets = (pipeline_onefunc_num_lets(parser_onefunc_result_pool_ptr(out))));
  int32_t push_mi = n_before_mid;
  while (push_mi < (out)->num_lets) {
    (void)(parser_onefunc_push_src_stmt(out, 1, push_mi));
    ++push_mi;
  }
  (void)(lexer_next_into((&(r)), lex, source));
  (stmt_tok_ready = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_DEFER) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer defer_skip = (struct lexer_Lexer){ .pos = (lex).pos, .line = (lex).line, .col = (lex).col };
  (void)(parser_skip_balanced_braces_into((&(defer_skip)), (r).next_lex, source));
  (lex = (defer_skip));
  (stmt_tok_ready = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_WITH_ARENA) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  struct parser_ParseExprResult cap_res_fn = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex };
  (void)(parser_parse_expr_into(arena, lex, source, (&(cap_res_fn))));
  (void)(({ int32_t __tmp = 0; if ((!(cap_res_fn).ok) || (cap_res_fn).expr_ref == 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((cap_res_fn).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  struct parser_ParseBlockResult block_res_wa_fn = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex };
  (void)(parser_parse_block_into(arena, lex, source, 0, (&(block_res_wa_fn))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res_wa_fn).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t wa_idx_fn = pipeline_onefunc_append_with_arena(parser_onefunc_result_pool_ptr(out), (cap_res_fn).expr_ref, (block_res_wa_fn).block_ref);
  (void)(({ int32_t __tmp = 0; if (wa_idx_fn < 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_onefunc_push_src_stmt(out, 6, wa_idx_fn));
  (lex = ((block_res_wa_fn).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (stmt_tok_ready = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_REGION) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  uint8_t reg_nm_fn[64] = { 0 };
  (void)(parser_copy_slice_to_name64(source, (r).token_start, ((r).tok).ident_len, (&((reg_nm_fn)[0]))));
  int32_t reg_nlen_fn = ((r).tok).ident_len;
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  struct parser_ParseBlockResult block_res_reg_fn = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex };
  (void)(parser_parse_block_into(arena, lex, source, 0, (&(block_res_reg_fn))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res_reg_fn).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t reg_idx_fn = pipeline_onefunc_append_region(parser_onefunc_result_pool_ptr(out), (&((reg_nm_fn)[0])), reg_nlen_fn, (block_res_reg_fn).block_ref);
  (void)(({ int32_t __tmp = 0; if (reg_idx_fn < 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_onefunc_push_src_stmt(out, 6, reg_idx_fn));
  (lex = ((block_res_reg_fn).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (stmt_tok_ready = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (parser_token_is_label_start(r, source)) {   struct lexer_LexerResult colon_fn = (struct lexer_LexerResult){ .next_lex = (r).next_lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(colon_fn)), (r).next_lex, source));
  (lex = ((colon_fn).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RETURN) {   break;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_GOTO) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_IDENT) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (stmt_tok_ready = (0));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LOOP) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((r).next_lex));
  int32_t cond_ref_loop = parser_alloc_true_bool_lit(arena);
  (void)(({ int32_t __tmp = 0; if (cond_ref_loop == 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  struct parser_ParseBlockResult block_res_loop = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex };
  (void)(parser_parse_block_into(arena, lex, source, 0, (&(block_res_loop))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res_loop).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t while_idx_loop = pipeline_onefunc_append_while(parser_onefunc_result_pool_ptr(out), cond_ref_loop, (block_res_loop).block_ref);
  (void)(({ int32_t __tmp = 0; if (while_idx_loop < 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  ((impl_snap).num_loops = (pipeline_onefunc_num_whiles(parser_onefunc_result_pool_ptr(out))));
  (void)(parser_onefunc_push_src_stmt(out, 3, while_idx_loop));
  (lex = ((block_res_loop).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (stmt_tok_ready = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_WHILE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((r).next_lex));
  struct lexer_Lexer while_cond_start = lex;
  struct parser_ParseExprResult expr_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = while_cond_start };
  (void)(parser_parse_cond_expr_into(arena, while_cond_start, source, (&(expr_res))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t cond_ref = (expr_res).expr_ref;
  (lex = ((expr_res).next_lex));
  (void)(({ int32_t __tmp = 0; if (parser_advance_past_cond_rparen_into((&(r)), lex, source) == 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((r).next_lex));
  struct parser_ParseBlockResult block_res = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex };
  (void)(parser_parse_block_into(arena, lex, source, 0, (&(block_res))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  int32_t while_idx = pipeline_onefunc_append_while(parser_onefunc_result_pool_ptr(out), cond_ref, (block_res).block_ref);
  (void)(({ int32_t __tmp = 0; if (while_idx < 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  ((impl_snap).num_loops = (pipeline_onefunc_num_whiles(parser_onefunc_result_pool_ptr(out))));
  (void)(parser_onefunc_push_src_stmt(out, 3, while_idx));
  (lex = ((block_res).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (stmt_tok_ready = (1));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_FOR) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LPAREN) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((r).next_lex));
  int32_t init_ref = 0;
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   struct parser_ParseExprResult expr_res_fi = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex };
  (void)(parser_parse_expr_into(arena, lex, source, (&(expr_res_fi))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res_fi).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (init_ref = ((expr_res_fi).expr_ref));
  (lex = ((expr_res_fi).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((r).next_lex));
  int32_t for_cond_ref = 0;
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   struct parser_ParseExprResult expr_res_fc = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex };
  (void)(parser_parse_expr_into(arena, lex, source, (&(expr_res_fc))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res_fc).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (for_cond_ref = ((expr_res_fc).expr_ref));
  (lex = ((expr_res_fc).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((r).next_lex));
  int32_t step_ref = 0;
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   struct parser_ParseExprResult expr_res_fs = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex };
  (void)(parser_parse_expr_into(arena, lex, source, (&(expr_res_fs))));
  (void)(({ int32_t __tmp = 0; if ((!(expr_res_fs).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (step_ref = ((expr_res_fs).expr_ref));
  (lex = ((expr_res_fs).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_RPAREN) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((r).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_LBRACE) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (lex = ((r).next_lex));
  struct parser_ParseBlockResult block_res_f = (struct parser_ParseBlockResult){ .ok = 0, .block_ref = 0, .next_lex = lex };
  (void)(parser_parse_block_into(arena, lex, source, 0, (&(block_res_f))));
  (void)(({ int32_t __tmp = 0; if ((!(block_res_f).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (for_cond_ref == 0) {   int32_t cond_expr_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (cond_expr_ref != 0) {   struct ast_Expr ce = ast_arena_expr_get(arena, cond_expr_ref);
  ((ce).kind = (ast_ExprKind_EXPR_BOOL_LIT));
  ((ce).int_val = (1));
  ((ce).line = (0));
  ((ce).col = (0));
  (void)(parser_expr_set_common_zeros((&(ce))));
  (void)(ast_arena_expr_set(arena, cond_expr_ref, ce));
  (for_cond_ref = (cond_expr_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t for_idx = pipeline_onefunc_append_for(parser_onefunc_result_pool_ptr(out), init_ref, for_cond_ref, step_ref, (block_res_f).block_ref);
  (void)(({ int32_t __tmp = 0; if (for_idx < 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  ((impl_snap).num_for_loops = (pipeline_onefunc_num_fors(parser_onefunc_result_pool_ptr(out))));
  (void)(parser_onefunc_push_src_stmt(out, 4, for_idx));
  (lex = ((block_res_f).next_lex));
  (void)(lexer_next_into((&(r)), lex, source));
  (stmt_tok_ready = (1));
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
  (stmt_tok_ready = (1));
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
    (lex = ((expr_stmt_res).next_lex));
    (void)(({ int32_t __tmp = 0; if (parser_advance_past_stmt_semicolon_into((&(r)), lex, source) == 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   (void)(parser_lex_from_result_ptr_into((&(lex)), (&(r))));
  struct lexer_LexerResult after_semi = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
  (void)(lexer_next_into((&(after_semi)), lex, source));
  (r = (after_semi));
 } else (__tmp = 0) ; __tmp; }));
    int32_t ex_i = pipeline_onefunc_push_body_expr_stmt(parser_onefunc_result_pool_ptr(out), (expr_stmt_res).expr_ref);
    (void)(({ int32_t __tmp = 0; if (ex_i < 0) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
    ((out)->num_src_body_expr_stmts = (pipeline_onefunc_num_body_expr_stmts(parser_onefunc_result_pool_ptr(out))));
    (void)(parser_onefunc_push_src_stmt(out, 2, ex_i));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RETURN || ((r).tok).kind == token_TokenKind_TOKEN_RBRACE || ((r).tok).kind == token_TokenKind_TOKEN_MATCH) {   break;
 } else (__tmp = 0) ; __tmp; }));
    (lex = (parser_lex_at_token_from_result(r)));
    (stmt_tok_ready = (1));
    continue;
  }
 } else {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_MATCH) {   ((impl_snap).has_explicit_return_kw = (1));
  struct lexer_Lexer match_tail_lex = parser_lex_at_token_from_result(r);
  struct parser_ParseExprResult match_tail_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = match_tail_lex };
  (void)(parser_parse_match_into(arena, match_tail_lex, source, (&(match_tail_res))));
  (void)(({ int32_t __tmp = 0; if ((!(match_tail_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (return_expr_ref_storage = ((match_tail_res).expr_ref));
  (lex = ((match_tail_res).next_lex));
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
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   size_t subj_start = (r).token_start;
  (void)(({ size_t __tmp = 0; if (subj_start == 0) {   (subj_start = (parser_lexer_pos_before_run(((r).next_lex).pos, ((r).tok).ident_len)));
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (parser_match_kw_immediately_before(source, subj_start)) {   ((impl_snap).has_explicit_return_kw = (1));
  struct lexer_Lexer match_subj_lex = (struct lexer_Lexer){ .pos = subj_start - 6, .line = ((r).tok).line, .col = ((r).tok).col };
  struct parser_ParseExprResult match_subj_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = match_subj_lex };
  (void)(parser_parse_match_into(arena, match_subj_lex, source, (&(match_subj_res))));
  (void)(({ int32_t __tmp = 0; if ((!(match_subj_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (return_expr_ref_storage = ((match_subj_res).expr_ref));
  (lex = ((match_subj_res).next_lex));
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
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RETURN) {   ((impl_snap).has_explicit_return_kw = (1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_MATCH) {   struct lexer_Lexer match_ret_lex = parser_lex_at_token_from_result(r);
  struct parser_ParseExprResult match_ret_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = match_ret_lex };
  (void)(parser_parse_match_into(arena, match_ret_lex, source, (&(match_ret_res))));
  (void)(({ int32_t __tmp = 0; if ((!(match_ret_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (return_expr_ref_storage = ((match_ret_res).expr_ref));
  (lex = ((match_ret_res).next_lex));
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
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IF) {   struct lexer_Lexer if_lex = parser_lex_at_token_from_result(r);
  struct parser_ParseExprResult if_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = if_lex };
  (void)(parser_parse_if_expr_into(arena, if_lex, source, 0, (&(if_res))));
  (void)(({ int32_t __tmp = 0; if ((!(if_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (return_expr_ref_storage = ((if_res).expr_ref));
  (lex = ((if_res).next_lex));
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
  (void)(({ int32_t __tmp = 0; if (return_type_is_bool && ((r).tok).kind != token_TokenKind_TOKEN_IF) {   struct lexer_Lexer rex_lex = parser_lex_at_token_from_result(r);
  struct parser_ParseExprResult rex_out = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = rex_lex };
  (void)(parser_parse_expr_into(arena, rex_lex, source, (&(rex_out))));
  (void)(({ int32_t __tmp = 0; if ((!(rex_out).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (return_expr_ref_storage = ((rex_out).expr_ref));
  (lex = ((rex_out).next_lex));
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
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_TRUE || ((r).tok).kind == token_TokenKind_TOKEN_FALSE) {   ((impl_snap).if_cond_true = (((r).tok).kind == token_TokenKind_TOKEN_TRUE));
  ((impl_snap).if_cond_expr_ref = (0));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else {   struct parser_ParseExprResult cond_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = lex_cond_start };
  (void)(parser_parse_expr_into(arena, lex_cond_start, source, (&(cond_res))));
  (void)(({ int32_t __tmp = 0; if ((!(cond_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  ((impl_snap).if_cond_expr_ref = ((cond_res).expr_ref));
  ((impl_snap).if_cond_true = (0));
  (lex = ((cond_res).next_lex));
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
  ((impl_snap).if_then_val = (((r).tok).int_val));
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
  ((impl_snap).if_else_val = (((r).tok).int_val));
  ((impl_snap).has_if_expr = (1));
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
  ((impl_snap).return_val = (((r).tok).int_val));
  ((impl_snap).has_unary_neg = (1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_INT) {   int32_t ret_int_val = ((r).tok).int_val;
  size_t ret_int_start = (r).token_start;
  (void)(({ size_t __tmp = 0; if (ret_int_start == 0) {   (ret_int_start = (((r).next_lex).pos - 1));
 } else (__tmp = 0) ; __tmp; }));
  struct lexer_Lexer ret_int_lex = (struct lexer_Lexer){ .pos = ret_int_start, .line = (lex).line, .col = (lex).col };
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_AS) {   struct parser_ParseExprResult ret_expr_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = ret_int_lex };
  (void)(parser_parse_expr_into(arena, ret_int_lex, source, (&(ret_expr_res))));
  (void)(({ int32_t __tmp = 0; if ((!(ret_expr_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (return_expr_ref_storage = ((ret_expr_res).expr_ref));
  (lex = ((ret_expr_res).next_lex));
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
  ((impl_snap).return_val = (ret_int_val));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_SEMICOLON && ((r).tok).kind != token_TokenKind_TOKEN_RBRACE) {   struct parser_ParseExprResult rex_add = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = ret_int_lex };
  (void)(parser_parse_expr_into(arena, ret_int_lex, source, (&(rex_add))));
  (void)(({ int32_t __tmp = 0; if ((!(rex_add).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (return_expr_ref_storage = ((rex_add).expr_ref));
  (lex = ((rex_add).next_lex));
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
  (return_expr_ref_storage = ((rex_out_ni).expr_ref));
  (lex = ((rex_out_ni).next_lex));
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
  ((impl_snap).call_callee_len = (clen));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_PLUS && (out)->num_params >= 2) {   (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  __tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   uint8_t * binop_pool = parser_onefunc_result_pool_ptr(out);
  int left_ok = (impl_snap).call_callee_len == pipeline_onefunc_param_name_len(binop_pool, 0);
  (void)(({ int32_t __tmp = 0; if (left_ok) {   int32_t ii = 0;
  while (ii < (impl_snap).call_callee_len) {
    (void)(({ int __tmp = 0; if ((ii < 0 || (ii) >= 64 ? (shux_panic_(1, 0), ((impl_snap).call_callee_name)[0]) : ((impl_snap).call_callee_name)[ii]) != pipeline_onefunc_param_name_byte_at(binop_pool, 0, ii)) {   (left_ok = (0));
 } else (__tmp = 0) ; __tmp; }));
    ++ii;
  }
 } else (__tmp = 0) ; __tmp; }));
  int right_ok = ((r).tok).ident_len == pipeline_onefunc_param_name_len(binop_pool, 1);
  __tmp = ({ int32_t __tmp = 0; if (left_ok && right_ok) {   ((impl_snap).has_binop = (1));
  ((impl_snap).binop_left_param_idx = (0));
  ((impl_snap).binop_right_param_idx = (1));
  ((impl_snap).return_val = (0));
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
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE && parser_match_kw_immediately_before(source, cstart)) {   size_t match_back = cstart - 6;
  struct lexer_Lexer match_lex_fix = (struct lexer_Lexer){ .pos = match_back, .line = ((r).tok).line, .col = ((r).tok).col };
  struct parser_ParseExprResult match_fix_res = (struct parser_ParseExprResult){ .ok = 0, .expr_ref = 0, .next_lex = match_lex_fix };
  (void)(parser_parse_match_into(arena, match_lex_fix, source, (&(match_fix_res))));
  (void)(({ int32_t __tmp = 0; if ((!(match_fix_res).ok)) {   (void)(parser_set_onefunc_fail(out, lex));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (return_expr_ref_storage = ((match_fix_res).expr_ref));
  (lex = ((match_fix_res).next_lex));
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
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE || ((r).tok).kind == token_TokenKind_TOKEN_SEMICOLON) {   ((impl_snap).has_call_expr = (0));
  ((impl_snap).return_val = (0));
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
  (return_expr_ref_storage = ((ret_expr_res).expr_ref));
  ((impl_snap).has_call_expr = (0));
  ((impl_snap).call_callee_len = (0));
  ((impl_snap).call_num_args = (0));
  (lex = ((ret_expr_res).next_lex));
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
  (return_expr_ref_storage = ((ret_expr_res_member).expr_ref));
  ((impl_snap).has_call_expr = (0));
  ((impl_snap).call_callee_len = (0));
  ((impl_snap).call_num_args = (0));
  (lex = ((ret_expr_res_member).next_lex));
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
  (return_expr_ref_storage = ((ret_id_badlen_res).expr_ref));
  ((impl_snap).has_call_expr = (0));
  ((impl_snap).call_callee_len = (0));
  ((impl_snap).call_num_args = (0));
  (lex = ((ret_id_badlen_res).next_lex));
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
  ((impl_snap).return_val = (0));
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
 } else {   (lex = (parser_skip_balanced_braces(lex, source)));
  (void)(parser_onefunc_finish_impl_to_out(out, (&(impl_snap)), lex, (&((dummy_name)[0])), (func_name_len_storage)[0], return_expr_ref_storage));
  return;
 } ; __tmp; }));
}
int32_t parser_import_path_dot_segment_len(enum token_TokenKind kind, int32_t ident_len) {
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_IDENT && ident_len > 0) {   return ident_len;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (kind == token_TokenKind_TOKEN_I32) {   return 3;
 } else (__tmp = 0) ; __tmp; }));
  int32_t ko = ((int32_t)(kind));
  (void)(({ int32_t __tmp = 0; if (ko == 29) {   return 5;
 } else (__tmp = 0) ; __tmp; }));
  return (-1);
}
void parser_import_path_dot_segment_copy(struct shux_slice_uint8_t * source, size_t token_start, int32_t seg_len, uint8_t * restrict path_buf, int32_t path_len) {
  int32_t i = 0;
  while (i < seg_len) {
    (void)(({ uint8_t __tmp = 0; if (token_start + ((size_t)(i)) < (source)->length) {   ((path_buf)[path_len + i] = ((token_start + ((size_t)(i)) < 0 || (size_t)(token_start + ((size_t)(i))) >= (source)->length ? (shux_panic_(1, 0), (source)->data[0]) : (source)->data[token_start + ((size_t)(i))])));
 } else (__tmp = 0) ; __tmp; }));
    ++i;
  }
}
void parser_import_path_dot_segment_copy_buf(uint8_t * restrict data, int32_t len, size_t token_start, int32_t seg_len, uint8_t * restrict path_buf, int32_t path_len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_import_path_dot_segment_copy(&(slice), token_start, seg_len, path_buf, path_len));
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
  (void)(pipeline_parser_set_match_module(module));
}
struct lexer_Lexer parser_skip_imports(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_skip_imports_glue(lex, source);
}
struct lexer_Lexer parser_skip_imports_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_skip_imports(lex, &(slice));
}
void parser_collect_imports(struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct ast_Module * restrict module, struct parser_CollectImportsResult * restrict out) {
  (void)(parser_collect_imports_glue(lex, source, module, out));
}
void parser_collect_imports_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct ast_Module * restrict module, struct parser_CollectImportsResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_collect_imports(lex, &(slice), module, out));
}
void parser_skip_one_struct_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_skip_one_struct_into_glue(out, lex, source));
}
struct lexer_Lexer parser_skip_one_struct(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_skip_one_struct_glue(lex, source);
}
int32_t parser_module_try_register_enum_name(struct ast_Module * restrict module, uint8_t * restrict name, int32_t name_len) {
  (void)(({ int32_t __tmp = 0; if (module == ((struct ast_Module *)(0)) || name == ((uint8_t *)(0)) || name_len <= 0 || name_len > 63) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  int32_t ei = 0;
  while (ei < (module)->num_module_enums) {
    (void)(({ int32_t __tmp = 0; if (pipeline_module_enum_name_len(module, ei) == name_len) {   int eq = 1;
  int32_t j = 0;
  while (j < name_len) {
    (void)(({ int32_t __tmp = 0; if (pipeline_module_enum_name_byte_at(module, ei, j) != (name)[j]) {   (eq = (0));
  break;
 } else (__tmp = 0) ; __tmp; }));
    ++j;
  }
  __tmp = ({ int32_t __tmp = 0; if (eq) {   return ei;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++ei;
  }
  int32_t slot = pipeline_module_enum_alloc(module);
  (void)(({ int32_t __tmp = 0; if (slot < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_module_enum_set_name(module, slot, name, name_len));
  return slot;
}
void parser_module_append_enum_variants_and_skip_body_into(struct ast_Module * restrict module, int32_t enum_idx, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_module_append_enum_variants_and_skip_body_into_glue(module, enum_idx, out, lex, source));
}
void parser_module_append_enum_variants_and_skip_body_into_buf(struct ast_Module * restrict module, int32_t enum_idx, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  int32_t depth = 1;
  size_t slen = ((size_t)(len));
  while (depth > 0) {
    struct lexer_LexerResult r = lexer_next_buf(lex, data, len);
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_RBRACE) {   (depth = (depth - 1));
  __tmp = ({ int32_t __tmp = 0; if (depth == 0) {   (void)(parser_lex_from_next_into((&(lex)), r));
  break;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LBRACE) {   ++depth;
 } else (__tmp = ({ int32_t __tmp = 0; if (depth == 1 && enum_idx >= 0 && ((r).tok).kind == token_TokenKind_TOKEN_IDENT) {   int32_t vlen = ((r).tok).ident_len;
  (void)(({ int32_t __tmp = 0; if (vlen > 63) {   (vlen = (63));
 } else (__tmp = 0) ; __tmp; }));
  size_t vstart = (r).token_start;
  uint8_t vb[64] = { 0 };
  int32_t nk = 0;
  while (nk < vlen && nk < 64) {
    size_t ix = vstart + ((size_t)(nk));
    (void)(({ int32_t __tmp = 0; if (ix >= slen) {   break;
 } else (__tmp = 0) ; __tmp; }));
    ((nk < 0 || (nk) >= 64 ? (shux_panic_(1, 0), 0) : ((vb)[nk] = (data)[ix], 0)));
    ++nk;
  }
  __tmp = ({ int32_t __tmp = 0; if (nk == vlen && vlen > 0) {   (void)(pipeline_module_enum_append_variant(module, enum_idx, (&((vb)[0])), vlen));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; })) ; __tmp; })) ; __tmp; }));
    (void)(parser_lex_from_next_into((&(lex)), r));
  }
  ((out)->pos = ((lex).pos));
  ((out)->line = ((lex).line));
  ((out)->col = ((lex).col));
}
void parser_skip_one_enum_register_into(struct ast_Module * restrict module, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_skip_one_enum_register_into_glue(module, out, lex, source));
}
void parser_skip_one_enum_register_into_buf(struct ast_Module * restrict module, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_skip_one_enum_register_into(module, out, lex, &(slice)));
}
void parser_skip_one_enum_register_buf(struct ast_Module * restrict module, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  (void)(parser_skip_one_enum_register_into_buf(module, out, lex, data, len));
}
void parser_skip_one_enum_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_skip_one_enum_into_glue(out, lex, source));
}
struct lexer_Lexer parser_skip_one_enum(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_skip_one_enum_glue(lex, source);
}
void parser_skip_one_trait_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_skip_one_trait_into_glue(out, lex, source));
}
struct lexer_Lexer parser_skip_one_trait(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_skip_one_trait_glue(lex, source);
}
void parser_skip_one_impl_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_skip_one_impl_into_glue(out, lex, source));
}
struct lexer_Lexer parser_skip_one_impl(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_skip_one_impl_glue(lex, source);
}
void parser_skip_one_enum_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_skip_one_enum_into(out, lex, &(slice)));
}
struct lexer_Lexer parser_skip_one_enum_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_skip_one_enum(lex, &(slice));
}
void parser_skip_one_trait_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_skip_one_trait_into(out, lex, &(slice)));
}
struct lexer_Lexer parser_skip_one_trait_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_skip_one_trait(lex, &(slice));
}
void parser_skip_one_impl_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_skip_one_impl_into(out, lex, &(slice)));
}
struct lexer_Lexer parser_skip_one_impl_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_skip_one_impl(lex, &(slice));
}
void parser_skip_one_extern_into(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_skip_one_extern_into_glue(out, lex, source));
}
struct lexer_Lexer parser_skip_one_extern(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_skip_one_extern_glue(lex, source);
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
    ++p;
  }
}
void parser_extern_parse_set_fail(struct parser_ExternParseResult * restrict out, struct lexer_Lexer lex) {
  uint8_t empty64[64] = { 0 };
  ((out)->next_lex = (lex));
  ((out)->name_len = ((-1)));
  ((out)->return_ty_ref = (0));
  ((out)->num_params = (0));
  int32_t ni = 0;
  while (ni < 64) {
    (((out)->name)[ni] = ((empty64)[ni]));
    ++ni;
  }
}
void parser_parse_one_extern_skip_into(struct parser_ExternParseResult * restrict out, struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_parse_one_extern_skip_into_glue(out, arena, lex, source));
}
void parser_parse_one_extern_skip_into_buf(struct parser_ExternParseResult * restrict out, struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_one_extern_skip_into(out, arena, lex, &(slice)));
}
int32_t parser_module_register_arena_func(struct ast_Module * restrict module, int32_t func_ref, struct ast_Func f) {
  int32_t fi = pipeline_module_func_alloc_slot(module);
  (void)(({ int32_t __tmp = 0; if (fi < 0) {   return (-1);
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_module_func_name_write(module, fi, (&(((f).name)[0])), (f).name_len));
  (void)(pipeline_module_func_set_num_params(module, fi, (f).num_params));
  (void)(pipeline_module_func_set_return_type(module, fi, (f).return_type_ref));
  (void)(pipeline_module_func_set_body_ref(module, fi, (f).body_ref));
  (void)(pipeline_module_func_set_body_expr_ref(module, fi, (f).body_expr_ref));
  (void)(pipeline_module_func_set_is_extern(module, fi, (f).is_extern));
  (void)(pipeline_module_func_set_is_async(module, fi, (f).is_async));
  (void)(pipeline_module_func_ref_set(module, fi, func_ref));
  return fi;
}
void parser_parse_one_extern_and_add_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct lexer_Lexer * restrict lex_out) {
  (void)(parser_parse_one_extern_and_add_into_glue(arena, module, lex, source, lex_out));
}
void parser_skip_one_extern_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_skip_one_extern_into(out, lex, &(slice)));
}
struct lexer_Lexer parser_skip_one_extern_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_skip_one_extern(lex, &(slice));
}
void parser_parse_one_extern_and_add_into_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct lexer_Lexer * restrict lex_out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_one_extern_and_add_into(arena, module, lex, &(slice), lex_out));
}
void parser_lex_from_try_skip_into(struct lexer_Lexer * restrict out, struct parser_TrySkipAllowResult t) {
  (void)(parser_lex_from_try_skip_into_glue(out, t));
}
void parser_lex_from_library_into(struct lexer_Lexer * restrict out, struct parser_LibraryParseResult lib) {
  (void)(parser_lex_from_library_into_glue(out, lib));
}
struct lexer_Lexer parser_lex_from_try_skip(struct parser_TrySkipAllowResult t) {
  return parser_lex_from_try_skip_glue(t);
}
struct lexer_Lexer parser_lex_from_library(struct parser_LibraryParseResult lib) {
  return parser_lex_from_library_glue(lib);
}
int parser_parse_one_function_library_scan(struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct parser_LibraryParseScanResult * restrict result) {
  return parser_parse_one_function_library_scan_glue(lex, source, result);
}
int parser_struct_layout_name_exists_arr(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    (void)(({ int __tmp = 0; if (pipeline_module_struct_layout_name_len(module, k) == nlen && nlen > 0) {   int32_t ii = 0;
  int same = 1;
  while (ii < nlen && ii < 64) {
    (void)(({ int __tmp = 0; if (pipeline_module_struct_layout_name_byte_at(module, k, ii) != (ii < 0 || (ii) >= 64 ? (shux_panic_(1, 0), (nm)[0]) : (nm)[ii])) {   (same = (0));
 } else (__tmp = 0) ; __tmp; }));
    ++ii;
  }
  __tmp = ({ int __tmp = 0; if (same) {   return 1;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  return 0;
}
int32_t parser_struct_layout_first_name_match_idx(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    (void)(({ int32_t __tmp = 0; if (pipeline_module_struct_layout_name_len(module, k) == nlen && nlen > 0) {   int32_t ii = 0;
  int same = 1;
  while (ii < nlen && ii < 64) {
    (void)(({ int __tmp = 0; if (pipeline_module_struct_layout_name_byte_at(module, k, ii) != (ii < 0 || (ii) >= 64 ? (shux_panic_(1, 0), (nm)[0]) : (nm)[ii])) {   (same = (0));
 } else (__tmp = 0) ; __tmp; }));
    ++ii;
  }
  __tmp = ({ int32_t __tmp = 0; if (same) {   return k;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  return (-1);
}
int32_t parser_struct_layout_placeholder_idx(struct ast_Module * restrict module, uint8_t nm[64], int32_t nlen) {
  int32_t k = 0;
  while (k < (module)->num_struct_layouts) {
    (void)(({ int32_t __tmp = 0; if (pipeline_module_struct_layout_name_len(module, k) == nlen && nlen > 0) {   int32_t ii = 0;
  int same = 1;
  while (ii < nlen && ii < 64) {
    (void)(({ int __tmp = 0; if (pipeline_module_struct_layout_name_byte_at(module, k, ii) != (ii < 0 || (ii) >= 64 ? (shux_panic_(1, 0), (nm)[0]) : (nm)[ii])) {   (same = (0));
 } else (__tmp = 0) ; __tmp; }));
    ++ii;
  }
  __tmp = ({ int32_t __tmp = 0; if (same) {   int32_t nf = pipeline_module_struct_layout_num_fields(module, k);
  (void)(({ int32_t __tmp = 0; if (nf == 0) {   return k;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (nf == 1 && pipeline_module_struct_layout_field_name_len(module, k, 0) == 0) {   return k;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (nf == 1 && pipeline_module_struct_layout_field_type_ref(module, k, 0) == 0) {   return k;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  return (-1);
}
struct parser_LibraryParseResult parser_parse_one_function_library(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_parse_one_function_library_glue(arena, module, lex, source);
}
struct parser_LibraryParseResult parser_parse_one_function_library_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_parse_one_function_library(arena, module, lex, &(slice));
}
struct parser_TrySkipAllowResult parser_parse_into_try_skip_allow(struct lexer_Lexer lex, struct lexer_LexerResult r, struct shux_slice_uint8_t * source) {
  return parser_parse_into_try_skip_allow_glue(lex, r, source);
}
struct parser_TrySkipAllowResult parser_parse_into_try_skip_allow_buf(struct lexer_Lexer lex, struct lexer_LexerResult r, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_parse_into_try_skip_allow(lex, r, &(slice));
}
struct parser_TrySkipAllowResult parser_try_skip_allow_padding_struct(struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  return parser_try_skip_allow_padding_struct_glue(lex, source);
}
struct parser_TrySkipAllowResult parser_try_skip_allow_padding_struct_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_try_skip_allow_padding_struct(lex, &(slice));
}
void parser_skip_one_struct_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_skip_one_struct_into(out, lex, &(slice)));
}
struct lexer_Lexer parser_skip_one_struct_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_skip_one_struct(lex, &(slice));
}
int32_t parser_consume_qualified_type_ident_name(struct shux_slice_uint8_t * source, struct lexer_LexerResult * restrict r, uint8_t * restrict out, int32_t * restrict out_len) {
  return parser_consume_qualified_type_ident_name_glue(source, r, out, out_len);
}
int32_t parser_consume_qualified_type_ident_name_buf(uint8_t * restrict data, int32_t len, struct lexer_LexerResult * restrict r, uint8_t * restrict out, int32_t * restrict out_len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_consume_qualified_type_ident_name(&(slice), r, out, out_len);
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
  (void)(({ int __tmp = 0; if (kind == token_TokenKind_TOKEN_F32 || kind == token_TokenKind_TOKEN_F64) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  return 0;
}
int32_t parser_alloc_pointee_type_ref_from_tok(struct ast_ASTArena * restrict arena, struct shux_slice_uint8_t * source, struct lexer_LexerResult * restrict r) {
  return parser_alloc_pointee_type_ref_from_tok_glue(arena, source, r);
}
int32_t parser_alloc_vector_type_ref(struct ast_ASTArena * restrict arena, int32_t elem_ord, int32_t lanes) {
  int32_t elem_tr_v = pipeline_type_ensure_by_kind_ord(arena, elem_ord);
  int32_t vec_ref = 0;
  (void)(({ int32_t __tmp = 0; if (elem_tr_v == 0) {   return 0;
 } else (__tmp = 0) ; __tmp; }));
  (vec_ref = (ast_arena_type_alloc(arena)));
  (void)(({ int32_t __tmp = 0; if (vec_ref != 0) {   struct ast_Type tv = ast_arena_type_get(arena, vec_ref);
  ((tv).kind = (ast_TypeKind_TYPE_VECTOR));
  ((tv).elem_type_ref = (elem_tr_v));
  ((tv).array_size = (lanes));
  ((tv).name_len = (0));
  (void)(ast_arena_type_set(arena, vec_ref, tv));
 } else (__tmp = 0) ; __tmp; }));
  return vec_ref;
}
int32_t parser_vector_type_ref_from_ident_spelling(struct ast_ASTArena * restrict arena, struct shux_slice_uint8_t * source, struct lexer_LexerResult r) {
  return parser_parser_vector_type_ref_from_ident_spelling_glue(arena, source, r);
}
int32_t parser_parse_struct_record_layout_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, struct lexer_Lexer * restrict out_lex, int32_t allow_pad, int32_t force_soa) {
  return parser_parse_struct_record_layout_into_glue(arena, module, lex, source, out_lex, allow_pad, force_soa);
}
void parser_parse_one_function_buf_into(struct parser_OneFuncResult * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  (void)(parser_parse_one_function_buf_into_glue(out, lex, data, len));
}
void parser_parse_one_function_library_into(struct parser_LibraryParseResult * restrict out, struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source) {
  (void)(parser_parse_one_function_library_into_glue(out, arena, module, lex, source));
}
void parser_parse_one_function_library_into_buf(struct parser_LibraryParseResult * restrict out, struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_one_function_library_into(out, arena, module, lex, &(slice)));
}
void parser_parse_into_try_skip_allow_into(struct parser_TrySkipAllowResult * restrict out, struct lexer_Lexer lex, struct lexer_LexerResult r, struct shux_slice_uint8_t * source) {
  (void)(parser_parse_into_try_skip_allow_into_glue(out, lex, r, source));
}
void parser_parse_into_try_skip_allow_into_buf(struct parser_TrySkipAllowResult * restrict out, struct lexer_Lexer lex, struct lexer_LexerResult r, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_into_try_skip_allow_into(out, lex, r, &(slice)));
}
struct parser_ParseIntoResult parser_parse_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct shux_slice_uint8_t * source) {
  struct lexer_Lexer lex = lexer_init();
  int32_t main_idx = -1;
  struct parser_CollectImportsResult import_res = (struct parser_CollectImportsResult){ .lex = lex };
  (void)(parser_collect_imports(lex, source, module, (&(import_res))));
  (void)(parser_copy_lex_from_import_into((&(lex)), import_res));
  int32_t loop_count = 0;
  while (1) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (loop_count >= 131072) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1003) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    ++loop_count;
    struct lexer_Lexer iter_start = lex;
    struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
    (void)(lexer_next_into((&(r)), lex, source));
    (void)(parser_lex_from_next_into((&(lex)), r));
    int32_t func_is_async_storage[1] = { 0 };
    ((func_is_async_storage)[0] = (0));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ASYNC) {   ((func_is_async_storage)[0] = (1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_into((&(r)), lex, source));
  (void)(parser_lex_from_next_into((&(lex)), r));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ATTR_SOA) {   ((module)->pending_soa_struct = (1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ATTR_CFG) {   ((module)->pending_cfg_skip = ((((r).tok).int_val == 0 ? 1 : 0)));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ATTR_REPR_C) {   ((module)->pending_repr_c_struct = (1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((module)->pending_cfg_skip != 0) {   (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STRUCT) {   (void)(parser_skip_one_struct_into((&(lex)), iter_start, source));
  ((module)->pending_cfg_skip = (0));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_CONST) {   (void)(parser_skip_one_top_level_const_into((&(lex)), iter_start, source));
  ((module)->pending_cfg_skip = (0));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_FUNCTION || (func_is_async_storage)[0] != 0 || ((r).tok).kind == token_TokenKind_TOKEN_EXTERN) {   (void)(parser_skip_one_function_full_into((&(lex)), iter_start, source));
  ((module)->pending_cfg_skip = (0));
  ((func_is_async_storage)[0] = (0));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  ((module)->pending_cfg_skip = (0));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STRUCT) {   int32_t ap_struct = (module)->pending_allow_padding;
  int32_t ps_struct = (module)->pending_soa_struct;
  int32_t pr_struct = (module)->pending_repr_c_struct;
  ((module)->pending_allow_padding = (0));
  ((module)->pending_soa_struct = (0));
  ((module)->pending_repr_c_struct = (0));
  int32_t allow_for_repr = ap_struct;
  (void)(({ int32_t __tmp = 0; if (pr_struct != 0) {   (allow_for_repr = (1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (parser_parse_struct_record_layout_into(arena, module, lex, source, (&(lex)), allow_for_repr, ps_struct) != 0) {   (void)(parser_skip_one_struct_into((&(lex)), iter_start, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ENUM) {   (void)(parser_skip_one_enum_register_into(module, (&(lex)), iter_start, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EXTERN) {   (void)(parser_parse_one_extern_and_add_into(arena, module, lex, source, (&(lex))));
  (void)(({ int32_t __tmp = 0; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   (void)(parser_skip_one_extern_into((&(lex)), lex, source));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_TRAIT) {   (void)(parser_skip_one_trait_into((&(lex)), iter_start, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IMPL) {   (void)(parser_skip_one_impl_into((&(lex)), iter_start, source));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   struct parser_TrySkipAllowResult try_res = ({ struct parser_TrySkipAllowResult _t = { 0 }; _t.lex = lex; _t.skipped = 0; _t; });
  (void)(parser_parse_into_try_skip_allow_into((&(try_res)), lex, r, source));
  (void)(({ int32_t __tmp = 0; if ((try_res).skipped != 0) {   ((module)->pending_allow_padding = (1));
  (void)(parser_lex_from_try_skip_into((&(lex)), try_res));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start).pos && (lex).pos < (source)->length) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
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
  ((out_idx_storage)[0] = (main_idx));
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
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (lex_at_function).pos && (lex).pos < (source)->length) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_parse_one_function_impl((&(res)), arena, lex, source));
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if ((!(res).ok)) {   return (struct parser_ParseIntoResult){ .ok = (-2), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    int32_t is_main_storage[1] = { 0 };
    (void)(({ int32_t __tmp = 0; if ((res).name_len == 4 && ((res).name)[0] == 109 && (1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), ((res).name)[0]) : ((res).name)[1]) == 97 && (2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), ((res).name)[0]) : ((res).name)[2]) == 105 && (3 < 0 || (3) >= 64 ? (shux_panic_(1, 0), ((res).name)[0]) : ((res).name)[3]) == 110) {   ((is_main_storage)[0] = (1));
 } else (__tmp = 0) ; __tmp; }));
    int32_t type_ref = (res).func_return_type_ref;
    (void)(({ int32_t __tmp = 0; if (type_ref == 0) {   (type_ref = (ast_arena_type_alloc(arena)));
  (void)(({ int32_t __tmp = 0; if (type_ref == 0 && (module)->num_funcs == 0) {   (void)(ast_arena_init(arena));
  (type_ref = (ast_arena_type_alloc(arena)));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (type_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1001) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Type t_fb = ast_arena_type_get(arena, type_ref);
  ((t_fb).kind = (ast_TypeKind_TYPE_I32));
  ((t_fb).name_len = (0));
  ((t_fb).elem_type_ref = (0));
  ((t_fb).array_size = (0));
  (void)(ast_arena_type_set(arena, type_ref, t_fb));
 } else (__tmp = 0) ; __tmp; }));
    int32_t expr_ref = ast_arena_expr_alloc(arena);
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (expr_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1002) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    struct ast_Expr e = ast_arena_expr_get(arena, expr_ref);
    (void)(({ int32_t __tmp = 0; if ((res).return_var_name_len > 0) {   ((e).kind = (ast_ExprKind_EXPR_VAR));
  ((e).var_name_len = ((res).return_var_name_len));
  int32_t rvi = 0;
  while (rvi < (res).return_var_name_len && rvi < 64) {
    ((rvi < 0 || (rvi) >= 64 ? (shux_panic_(1, 0), 0) : (((e).var_name)[rvi] = (rvi < 0 || (rvi) >= 64 ? (shux_panic_(1, 0), ((res).return_var_name)[0]) : ((res).return_var_name)[rvi]), 0)));
    ++rvi;
  }
  uint8_t rvz = ((uint8_t)(0));
  while (rvi < 64) {
    (((e).var_name)[rvi] = (rvz));
    ++rvi;
  }
  ((e).int_val = (0));
  ((e).resolved_type_ref = (0));
 } else {   ((e).kind = (ast_ExprKind_EXPR_LIT));
  ((e).resolved_type_ref = (type_ref));
  ((e).int_val = ((res).return_val));
 } ; __tmp; }));
    ((e).line = (0));
    ((e).col = (0));
    ((e).binop_left_ref = (0));
    ((e).binop_right_ref = (0));
    ((e).unary_operand_ref = (0));
    ((e).if_cond_ref = (0));
    ((e).if_then_ref = (0));
    ((e).if_else_ref = (0));
    ((e).block_ref = (0));
    ((e).match_matched_ref = (0));
    ((e).match_num_arms = (0));
    (void)(ast_expr_init_match_enum((&(e))));
    ((e).field_access_base_ref = (0));
    ((e).field_access_field_len = (0));
    ((e).field_access_is_enum_variant = (0));
    ((e).field_access_offset = (0));
    ((e).index_base_ref = (0));
    ((e).index_index_ref = (0));
    ((e).index_base_is_slice = (0));
    ((e).call_callee_ref = (0));
    ((e).call_num_args = (0));
    ((e).method_call_base_ref = (0));
    ((e).method_call_name_len = (0));
    ((e).method_call_num_args = (0));
    ((e).const_folded_val = (0));
    ((e).const_folded_valid = (0));
    ((e).index_proven_in_bounds = (0));
    (void)(ast_arena_expr_set(arena, expr_ref, e));
    int32_t final_expr_ref = expr_ref;
    (void)(({ int32_t __tmp = 0; if ((res).return_expr_ref != 0) {   (final_expr_ref = ((res).return_expr_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).return_var_name_len > 0 && (res).return_expr_ref == 0) {   int32_t var_wrapped = parser_expr_wrap_in_return(arena, type_ref, final_expr_ref);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (var_wrapped == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1003) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (final_expr_ref = (var_wrapped));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_mul && (!(res).has_binop)) {   int32_t mul_right_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_right_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr mre = ast_arena_expr_get(arena, mul_right_ref);
  ((mre).kind = (ast_ExprKind_EXPR_LIT));
  ((mre).resolved_type_ref = (type_ref));
  ((mre).line = (0));
  ((mre).col = (0));
  ((mre).int_val = ((res).mul_right_val));
  ((mre).binop_left_ref = (0));
  ((mre).binop_right_ref = (0));
  ((mre).unary_operand_ref = (0));
  ((mre).if_cond_ref = (0));
  ((mre).if_then_ref = (0));
  ((mre).if_else_ref = (0));
  ((mre).block_ref = (0));
  ((mre).match_matched_ref = (0));
  ((mre).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(mre))));
  ((mre).field_access_base_ref = (0));
  ((mre).field_access_field_len = (0));
  ((mre).field_access_is_enum_variant = (0));
  ((mre).field_access_offset = (0));
  ((mre).index_base_ref = (0));
  ((mre).index_index_ref = (0));
  ((mre).index_base_is_slice = (0));
  ((mre).call_callee_ref = (0));
  ((mre).call_num_args = (0));
  ((mre).method_call_base_ref = (0));
  ((mre).method_call_name_len = (0));
  ((mre).method_call_num_args = (0));
  ((mre).const_folded_val = (0));
  ((mre).const_folded_valid = (0));
  ((mre).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, mul_right_ref, mre));
  int32_t mul_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr me = ast_arena_expr_get(arena, mul_ref);
  ((me).kind = (ast_ExprKind_EXPR_MUL));
  ((me).resolved_type_ref = (type_ref));
  ((me).line = (0));
  ((me).col = (0));
  ((me).int_val = (0));
  ((me).binop_left_ref = (final_expr_ref));
  ((me).binop_right_ref = (mul_right_ref));
  ((me).unary_operand_ref = (0));
  ((me).if_cond_ref = (0));
  ((me).if_then_ref = (0));
  ((me).if_else_ref = (0));
  ((me).block_ref = (0));
  ((me).match_matched_ref = (0));
  ((me).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(me))));
  ((me).field_access_base_ref = (0));
  ((me).field_access_field_len = (0));
  ((me).field_access_is_enum_variant = (0));
  ((me).field_access_offset = (0));
  ((me).index_base_ref = (0));
  ((me).index_index_ref = (0));
  ((me).index_base_is_slice = (0));
  ((me).call_callee_ref = (0));
  ((me).call_num_args = (0));
  ((me).method_call_base_ref = (0));
  ((me).method_call_name_len = (0));
  ((me).method_call_num_args = (0));
  ((me).const_folded_val = (0));
  ((me).const_folded_valid = (0));
  ((me).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, mul_ref, me));
  (final_expr_ref = (mul_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_if_expr) {   int32_t cond_ref = 0;
  (void)(({ int32_t __tmp = 0; if ((res).if_cond_expr_ref != 0) {   (cond_ref = ((res).if_cond_expr_ref));
 } else {   int32_t bool_type_ref = ast_arena_type_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (bool_type_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1005) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Type bt = ast_arena_type_get(arena, bool_type_ref);
  ((bt).kind = (ast_TypeKind_TYPE_BOOL));
  ((bt).name_len = (0));
  ((bt).elem_type_ref = (0));
  ((bt).array_size = (0));
  (void)(ast_arena_type_set(arena, bool_type_ref, bt));
  (cond_ref = (ast_arena_expr_alloc(arena)));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (cond_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ce = ast_arena_expr_get(arena, cond_ref);
  ((ce).kind = (ast_ExprKind_EXPR_BOOL_LIT));
  ((ce).resolved_type_ref = (bool_type_ref));
  ((ce).line = (0));
  ((ce).col = (0));
  (void)(({ int32_t __tmp = 0; if ((res).if_cond_true) {   ((ce).int_val = (1));
 } else {   ((ce).int_val = (0));
 } ; __tmp; }));
  ((ce).binop_left_ref = (0));
  ((ce).binop_right_ref = (0));
  ((ce).unary_operand_ref = (0));
  ((ce).if_cond_ref = (0));
  ((ce).if_then_ref = (0));
  ((ce).if_else_ref = (0));
  ((ce).block_ref = (0));
  ((ce).match_matched_ref = (0));
  ((ce).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(ce))));
  ((ce).field_access_base_ref = (0));
  ((ce).field_access_field_len = (0));
  ((ce).field_access_is_enum_variant = (0));
  ((ce).field_access_offset = (0));
  ((ce).index_base_ref = (0));
  ((ce).index_index_ref = (0));
  ((ce).index_base_is_slice = (0));
  ((ce).call_callee_ref = (0));
  ((ce).call_num_args = (0));
  ((ce).method_call_base_ref = (0));
  ((ce).method_call_name_len = (0));
  ((ce).method_call_num_args = (0));
  ((ce).const_folded_val = (0));
  ((ce).const_folded_valid = (0));
  ((ce).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, cond_ref, ce));
 } ; __tmp; }));
  int32_t then_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (then_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr te = ast_arena_expr_get(arena, then_ref);
  ((te).kind = (ast_ExprKind_EXPR_LIT));
  ((te).resolved_type_ref = (type_ref));
  ((te).line = (0));
  ((te).col = (0));
  ((te).int_val = ((res).if_then_val));
  ((te).binop_left_ref = (0));
  ((te).binop_right_ref = (0));
  ((te).unary_operand_ref = (0));
  ((te).if_cond_ref = (0));
  ((te).if_then_ref = (0));
  ((te).if_else_ref = (0));
  ((te).block_ref = (0));
  ((te).match_matched_ref = (0));
  ((te).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(te))));
  ((te).field_access_base_ref = (0));
  ((te).field_access_field_len = (0));
  ((te).field_access_is_enum_variant = (0));
  ((te).field_access_offset = (0));
  ((te).index_base_ref = (0));
  ((te).index_index_ref = (0));
  ((te).index_base_is_slice = (0));
  ((te).call_callee_ref = (0));
  ((te).call_num_args = (0));
  ((te).method_call_base_ref = (0));
  ((te).method_call_name_len = (0));
  ((te).method_call_num_args = (0));
  ((te).const_folded_val = (0));
  ((te).const_folded_valid = (0));
  ((te).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, then_ref, te));
  int32_t else_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (else_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ee = ast_arena_expr_get(arena, else_ref);
  ((ee).kind = (ast_ExprKind_EXPR_LIT));
  ((ee).resolved_type_ref = (type_ref));
  ((ee).line = (0));
  ((ee).col = (0));
  ((ee).int_val = ((res).if_else_val));
  ((ee).binop_left_ref = (0));
  ((ee).binop_right_ref = (0));
  ((ee).unary_operand_ref = (0));
  ((ee).if_cond_ref = (0));
  ((ee).if_then_ref = (0));
  ((ee).if_else_ref = (0));
  ((ee).block_ref = (0));
  ((ee).match_matched_ref = (0));
  ((ee).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(ee))));
  ((ee).field_access_base_ref = (0));
  ((ee).field_access_field_len = (0));
  ((ee).field_access_is_enum_variant = (0));
  ((ee).field_access_offset = (0));
  ((ee).index_base_ref = (0));
  ((ee).index_index_ref = (0));
  ((ee).index_base_is_slice = (0));
  ((ee).call_callee_ref = (0));
  ((ee).call_num_args = (0));
  ((ee).method_call_base_ref = (0));
  ((ee).method_call_name_len = (0));
  ((ee).method_call_num_args = (0));
  ((ee).const_folded_val = (0));
  ((ee).const_folded_valid = (0));
  ((ee).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, else_ref, ee));
  int32_t if_expr_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (if_expr_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ie = ast_arena_expr_get(arena, if_expr_ref);
  ((ie).kind = (ast_ExprKind_EXPR_IF));
  ((ie).resolved_type_ref = (type_ref));
  ((ie).line = (0));
  ((ie).col = (0));
  ((ie).int_val = (0));
  ((ie).binop_left_ref = (0));
  ((ie).binop_right_ref = (0));
  ((ie).unary_operand_ref = (0));
  ((ie).if_cond_ref = (cond_ref));
  ((ie).if_then_ref = (then_ref));
  ((ie).if_else_ref = (else_ref));
  ((ie).block_ref = (0));
  ((ie).match_matched_ref = (0));
  ((ie).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(ie))));
  ((ie).field_access_base_ref = (0));
  ((ie).field_access_field_len = (0));
  ((ie).field_access_is_enum_variant = (0));
  ((ie).field_access_offset = (0));
  ((ie).index_base_ref = (0));
  ((ie).index_index_ref = (0));
  ((ie).index_base_is_slice = (0));
  ((ie).call_callee_ref = (0));
  ((ie).call_num_args = (0));
  ((ie).method_call_base_ref = (0));
  ((ie).method_call_name_len = (0));
  ((ie).method_call_num_args = (0));
  ((ie).const_folded_val = (0));
  ((ie).const_folded_valid = (0));
  ((ie).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, if_expr_ref, ie));
  (final_expr_ref = (if_expr_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).return_expr_ref == 0) {   __tmp = ({ int32_t __tmp = 0; if ((res).has_binop || (res).binop_right_val != 0) {   uint8_t * res_pool = parser_onefunc_result_pool_ptr((&(res)));
  int32_t left_ref = final_expr_ref;
  (void)(({ int32_t __tmp = 0; if ((res).binop_left_param_idx >= 0 && (res).binop_left_param_idx < (res).num_params) {   int32_t lpr = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (lpr != 0) {   struct ast_Expr lpe = ast_arena_expr_get(arena, lpr);
  ((lpe).kind = (ast_ExprKind_EXPR_VAR));
  ((lpe).resolved_type_ref = (type_ref));
  ((lpe).line = (0));
  ((lpe).col = (0));
  ((lpe).var_name_len = (pipeline_onefunc_param_name_len(res_pool, (res).binop_left_param_idx)));
  int32_t lk = 0;
  while (lk < (lpe).var_name_len && lk < 64) {
    ((lk < 0 || (lk) >= 64 ? (shux_panic_(1, 0), 0) : (((lpe).var_name)[lk] = pipeline_onefunc_param_name_byte_at(res_pool, (res).binop_left_param_idx, lk), 0)));
    ++lk;
  }
  uint8_t lz = ((uint8_t)(0));
  while (lk < 64) {
    (((lpe).var_name)[lk] = (lz));
    ++lk;
  }
  ((lpe).binop_left_ref = (0));
  ((lpe).binop_right_ref = (0));
  ((lpe).unary_operand_ref = (0));
  ((lpe).if_cond_ref = (0));
  ((lpe).if_then_ref = (0));
  ((lpe).if_else_ref = (0));
  ((lpe).block_ref = (0));
  ((lpe).match_matched_ref = (0));
  ((lpe).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(lpe))));
  ((lpe).field_access_base_ref = (0));
  ((lpe).field_access_field_len = (0));
  ((lpe).field_access_is_enum_variant = (0));
  ((lpe).field_access_offset = (0));
  ((lpe).index_base_ref = (0));
  ((lpe).index_index_ref = (0));
  ((lpe).index_base_is_slice = (0));
  ((lpe).call_callee_ref = (0));
  ((lpe).call_num_args = (0));
  ((lpe).method_call_base_ref = (0));
  ((lpe).method_call_name_len = (0));
  ((lpe).method_call_num_args = (0));
  ((lpe).const_folded_val = (0));
  ((lpe).const_folded_valid = (0));
  ((lpe).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, lpr, lpe));
  (left_ref = (lpr));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t right_ref = 0;
  (void)(({ int32_t __tmp = 0; if ((res).binop_right_param_idx >= 0 && (res).binop_right_param_idx < (res).num_params) {   int32_t rpr = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (rpr != 0) {   struct ast_Expr rpe = ast_arena_expr_get(arena, rpr);
  ((rpe).kind = (ast_ExprKind_EXPR_VAR));
  ((rpe).resolved_type_ref = (type_ref));
  ((rpe).line = (0));
  ((rpe).col = (0));
  ((rpe).var_name_len = (pipeline_onefunc_param_name_len(res_pool, (res).binop_right_param_idx)));
  int32_t rk = 0;
  while (rk < (rpe).var_name_len && rk < 64) {
    ((rk < 0 || (rk) >= 64 ? (shux_panic_(1, 0), 0) : (((rpe).var_name)[rk] = pipeline_onefunc_param_name_byte_at(res_pool, (res).binop_right_param_idx, rk), 0)));
    ++rk;
  }
  uint8_t rz = ((uint8_t)(0));
  while (rk < 64) {
    (((rpe).var_name)[rk] = (rz));
    ++rk;
  }
  ((rpe).binop_left_ref = (0));
  ((rpe).binop_right_ref = (0));
  ((rpe).unary_operand_ref = (0));
  ((rpe).if_cond_ref = (0));
  ((rpe).if_then_ref = (0));
  ((rpe).if_else_ref = (0));
  ((rpe).block_ref = (0));
  ((rpe).match_matched_ref = (0));
  ((rpe).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(rpe))));
  ((rpe).field_access_base_ref = (0));
  ((rpe).field_access_field_len = (0));
  ((rpe).field_access_is_enum_variant = (0));
  ((rpe).field_access_offset = (0));
  ((rpe).index_base_ref = (0));
  ((rpe).index_index_ref = (0));
  ((rpe).index_base_is_slice = (0));
  ((rpe).call_callee_ref = (0));
  ((rpe).call_num_args = (0));
  ((rpe).method_call_base_ref = (0));
  ((rpe).method_call_name_len = (0));
  ((rpe).method_call_num_args = (0));
  ((rpe).const_folded_val = (0));
  ((rpe).const_folded_valid = (0));
  ((rpe).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, rpr, rpe));
  (right_ref = (rpr));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = ({ int32_t __tmp = 0; if ((res).has_mul) {   int32_t mul_left_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_left_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr mle = ast_arena_expr_get(arena, mul_left_ref);
  ((mle).kind = (ast_ExprKind_EXPR_LIT));
  ((mle).resolved_type_ref = (type_ref));
  ((mle).line = (0));
  ((mle).col = (0));
  ((mle).int_val = ((res).binop_right_val));
  ((mle).binop_left_ref = (0));
  ((mle).binop_right_ref = (0));
  ((mle).unary_operand_ref = (0));
  ((mle).if_cond_ref = (0));
  ((mle).if_then_ref = (0));
  ((mle).if_else_ref = (0));
  ((mle).block_ref = (0));
  ((mle).match_matched_ref = (0));
  ((mle).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(mle))));
  ((mle).field_access_base_ref = (0));
  ((mle).field_access_field_len = (0));
  ((mle).field_access_is_enum_variant = (0));
  ((mle).field_access_offset = (0));
  ((mle).index_base_ref = (0));
  ((mle).index_index_ref = (0));
  ((mle).index_base_is_slice = (0));
  ((mle).call_callee_ref = (0));
  ((mle).call_num_args = (0));
  ((mle).method_call_base_ref = (0));
  ((mle).method_call_name_len = (0));
  ((mle).method_call_num_args = (0));
  ((mle).const_folded_val = (0));
  ((mle).const_folded_valid = (0));
  ((mle).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, mul_left_ref, mle));
  int32_t mul_r_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_r_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr mre = ast_arena_expr_get(arena, mul_r_ref);
  ((mre).kind = (ast_ExprKind_EXPR_LIT));
  ((mre).resolved_type_ref = (type_ref));
  ((mre).line = (0));
  ((mre).col = (0));
  ((mre).int_val = ((res).mul_right_val));
  ((mre).binop_left_ref = (0));
  ((mre).binop_right_ref = (0));
  ((mre).unary_operand_ref = (0));
  ((mre).if_cond_ref = (0));
  ((mre).if_then_ref = (0));
  ((mre).if_else_ref = (0));
  ((mre).block_ref = (0));
  ((mre).match_matched_ref = (0));
  ((mre).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(mre))));
  ((mre).field_access_base_ref = (0));
  ((mre).field_access_field_len = (0));
  ((mre).field_access_is_enum_variant = (0));
  ((mre).field_access_offset = (0));
  ((mre).index_base_ref = (0));
  ((mre).index_index_ref = (0));
  ((mre).index_base_is_slice = (0));
  ((mre).call_callee_ref = (0));
  ((mre).call_num_args = (0));
  ((mre).method_call_base_ref = (0));
  ((mre).method_call_name_len = (0));
  ((mre).method_call_num_args = (0));
  ((mre).const_folded_val = (0));
  ((mre).const_folded_valid = (0));
  ((mre).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, mul_r_ref, mre));
  int32_t mul_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr me = ast_arena_expr_get(arena, mul_ref);
  ((me).kind = (ast_ExprKind_EXPR_MUL));
  ((me).resolved_type_ref = (type_ref));
  ((me).line = (0));
  ((me).col = (0));
  ((me).int_val = (0));
  ((me).binop_left_ref = (mul_left_ref));
  ((me).binop_right_ref = (mul_r_ref));
  ((me).unary_operand_ref = (0));
  ((me).if_cond_ref = (0));
  ((me).if_then_ref = (0));
  ((me).if_else_ref = (0));
  ((me).block_ref = (0));
  ((me).match_matched_ref = (0));
  ((me).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(me))));
  ((me).field_access_base_ref = (0));
  ((me).field_access_field_len = (0));
  ((me).field_access_is_enum_variant = (0));
  ((me).field_access_offset = (0));
  ((me).index_base_ref = (0));
  ((me).index_index_ref = (0));
  ((me).index_base_is_slice = (0));
  ((me).call_callee_ref = (0));
  ((me).call_num_args = (0));
  ((me).method_call_base_ref = (0));
  ((me).method_call_name_len = (0));
  ((me).method_call_num_args = (0));
  ((me).const_folded_val = (0));
  ((me).const_folded_valid = (0));
  ((me).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, mul_ref, me));
  (right_ref = (mul_ref));
 } else {   (right_ref = (ast_arena_expr_alloc(arena)));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (right_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr re = ast_arena_expr_get(arena, right_ref);
  ((re).kind = (ast_ExprKind_EXPR_LIT));
  ((re).resolved_type_ref = (type_ref));
  ((re).line = (0));
  ((re).col = (0));
  ((re).int_val = ((res).binop_right_val));
  ((re).binop_left_ref = (0));
  ((re).binop_right_ref = (0));
  ((re).unary_operand_ref = (0));
  ((re).if_cond_ref = (0));
  ((re).if_then_ref = (0));
  ((re).if_else_ref = (0));
  ((re).block_ref = (0));
  ((re).match_matched_ref = (0));
  ((re).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(re))));
  ((re).field_access_base_ref = (0));
  ((re).field_access_field_len = (0));
  ((re).field_access_is_enum_variant = (0));
  ((re).field_access_offset = (0));
  ((re).index_base_ref = (0));
  ((re).index_index_ref = (0));
  ((re).index_base_is_slice = (0));
  ((re).call_callee_ref = (0));
  ((re).call_num_args = (0));
  ((re).method_call_base_ref = (0));
  ((re).method_call_name_len = (0));
  ((re).method_call_num_args = (0));
  ((re).const_folded_val = (0));
  ((re).const_folded_valid = (0));
  ((re).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, right_ref, re));
 } ; __tmp; })) ; __tmp; }));
  int32_t add_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (add_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ae = ast_arena_expr_get(arena, add_ref);
  ((ae).kind = (ast_ExprKind_EXPR_ADD));
  ((ae).resolved_type_ref = (type_ref));
  ((ae).line = (0));
  ((ae).col = (0));
  ((ae).int_val = (0));
  ((ae).binop_left_ref = (left_ref));
  ((ae).binop_right_ref = (right_ref));
  ((ae).unary_operand_ref = (0));
  ((ae).if_cond_ref = (0));
  ((ae).if_then_ref = (0));
  ((ae).if_else_ref = (0));
  ((ae).block_ref = (0));
  ((ae).match_matched_ref = (0));
  ((ae).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(ae))));
  ((ae).field_access_base_ref = (0));
  ((ae).field_access_field_len = (0));
  ((ae).field_access_is_enum_variant = (0));
  ((ae).field_access_offset = (0));
  ((ae).index_base_ref = (0));
  ((ae).index_index_ref = (0));
  ((ae).index_base_is_slice = (0));
  ((ae).call_callee_ref = (0));
  ((ae).call_num_args = (0));
  ((ae).method_call_base_ref = (0));
  ((ae).method_call_name_len = (0));
  ((ae).method_call_num_args = (0));
  ((ae).const_folded_val = (0));
  ((ae).const_folded_valid = (0));
  ((ae).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, add_ref, ae));
  (final_expr_ref = (add_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_unary_neg) {   int32_t operand_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (operand_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr oe = ast_arena_expr_get(arena, operand_ref);
  ((oe).kind = (ast_ExprKind_EXPR_LIT));
  ((oe).resolved_type_ref = (type_ref));
  ((oe).line = (0));
  ((oe).col = (0));
  ((oe).int_val = ((res).return_val));
  ((oe).binop_left_ref = (0));
  ((oe).binop_right_ref = (0));
  ((oe).unary_operand_ref = (0));
  ((oe).if_cond_ref = (0));
  ((oe).if_then_ref = (0));
  ((oe).if_else_ref = (0));
  ((oe).block_ref = (0));
  ((oe).match_matched_ref = (0));
  ((oe).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(oe))));
  ((oe).field_access_base_ref = (0));
  ((oe).field_access_field_len = (0));
  ((oe).field_access_is_enum_variant = (0));
  ((oe).field_access_offset = (0));
  ((oe).index_base_ref = (0));
  ((oe).index_index_ref = (0));
  ((oe).index_base_is_slice = (0));
  ((oe).call_callee_ref = (0));
  ((oe).call_num_args = (0));
  ((oe).method_call_base_ref = (0));
  ((oe).method_call_name_len = (0));
  ((oe).method_call_num_args = (0));
  ((oe).const_folded_val = (0));
  ((oe).const_folded_valid = (0));
  ((oe).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, operand_ref, oe));
  int32_t neg_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (neg_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ne = ast_arena_expr_get(arena, neg_ref);
  ((ne).kind = (ast_ExprKind_EXPR_NEG));
  ((ne).resolved_type_ref = (type_ref));
  ((ne).line = (0));
  ((ne).col = (0));
  ((ne).int_val = (0));
  ((ne).binop_left_ref = (0));
  ((ne).binop_right_ref = (0));
  ((ne).unary_operand_ref = (operand_ref));
  ((ne).if_cond_ref = (0));
  ((ne).if_then_ref = (0));
  ((ne).if_else_ref = (0));
  ((ne).block_ref = (0));
  ((ne).match_matched_ref = (0));
  ((ne).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(ne))));
  ((ne).field_access_base_ref = (0));
  ((ne).field_access_field_len = (0));
  ((ne).field_access_is_enum_variant = (0));
  ((ne).field_access_offset = (0));
  ((ne).index_base_ref = (0));
  ((ne).index_index_ref = (0));
  ((ne).index_base_is_slice = (0));
  ((ne).call_callee_ref = (0));
  ((ne).call_num_args = (0));
  ((ne).method_call_base_ref = (0));
  ((ne).method_call_name_len = (0));
  ((ne).method_call_num_args = (0));
  ((ne).const_folded_val = (0));
  ((ne).const_folded_valid = (0));
  ((ne).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, neg_ref, ne));
  (final_expr_ref = (neg_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_call_expr && (res).return_expr_ref == 0 && (res).call_callee_len > 0 && (res).call_callee_len <= 63) {   uint8_t * call_pool = parser_onefunc_result_pool_ptr((&(res)));
  int32_t callee_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (callee_ref != 0) {   struct ast_Expr ve = ast_arena_expr_get(arena, callee_ref);
  ((ve).kind = (ast_ExprKind_EXPR_VAR));
  ((ve).resolved_type_ref = (0));
  ((ve).line = (0));
  ((ve).col = (0));
  ((ve).var_name_len = ((res).call_callee_len));
  int32_t ck = 0;
  while (ck < (res).call_callee_len && ck < 64) {
    ((ck < 0 || (ck) >= 64 ? (shux_panic_(1, 0), 0) : (((ve).var_name)[ck] = (ck < 0 || (ck) >= 64 ? (shux_panic_(1, 0), ((res).call_callee_name)[0]) : ((res).call_callee_name)[ck]), 0)));
    ++ck;
  }
  uint8_t z = ((uint8_t)(0));
  while (ck < 64) {
    (((ve).var_name)[ck] = (z));
    ++ck;
  }
  ((ve).binop_left_ref = (0));
  ((ve).binop_right_ref = (0));
  ((ve).unary_operand_ref = (0));
  ((ve).if_cond_ref = (0));
  ((ve).if_then_ref = (0));
  ((ve).if_else_ref = (0));
  ((ve).block_ref = (0));
  ((ve).match_matched_ref = (0));
  ((ve).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(ve))));
  ((ve).field_access_base_ref = (0));
  ((ve).field_access_field_len = (0));
  ((ve).field_access_is_enum_variant = (0));
  ((ve).field_access_offset = (0));
  ((ve).index_base_ref = (0));
  ((ve).index_index_ref = (0));
  ((ve).index_base_is_slice = (0));
  ((ve).call_callee_ref = (0));
  ((ve).call_num_args = (0));
  ((ve).method_call_base_ref = (0));
  ((ve).method_call_name_len = (0));
  ((ve).method_call_num_args = (0));
  ((ve).const_folded_val = (0));
  ((ve).const_folded_valid = (0));
  ((ve).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, callee_ref, ve));
  int32_t call_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (call_ref != 0) {   struct ast_Expr ce = ast_arena_expr_get(arena, call_ref);
  (void)(parser_expr_set_common_zeros((&(ce))));
  ((ce).kind = (ast_ExprKind_EXPR_CALL));
  ((ce).resolved_type_ref = (type_ref));
  ((ce).line = (0));
  ((ce).col = (0));
  ((ce).call_callee_ref = (callee_ref));
  (void)(({ int32_t __tmp = 0; if ((res).call_num_args > 0) {   ((ce).call_num_args = ((res).call_num_args));
 } else {   ((ce).call_num_args = ((res).num_params));
 } ; __tmp; }));
  (void)(ast_arena_expr_set(arena, call_ref, ce));
  int32_t arg_i = 0;
  while (arg_i < (ce).call_num_args) {
    int32_t arg_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (arg_ref != 0) {   struct ast_Expr ae = ast_arena_expr_get(arena, arg_ref);
  ((ae).resolved_type_ref = (0));
  ((ae).line = (0));
  ((ae).col = (0));
  (void)(({ int32_t __tmp = 0; if ((res).call_num_args > 0 && arg_i < (res).call_num_args) {   ((ae).kind = (ast_ExprKind_EXPR_LIT));
  ((ae).int_val = (pipeline_onefunc_call_arg_val_at(call_pool, arg_i)));
 } else {   ((ae).kind = (ast_ExprKind_EXPR_VAR));
  ((ae).var_name_len = (pipeline_onefunc_param_name_len(call_pool, arg_i)));
  int32_t k = 0;
  while (k < (ae).var_name_len && k < 64) {
    ((k < 0 || (k) >= 64 ? (shux_panic_(1, 0), 0) : (((ae).var_name)[k] = pipeline_onefunc_param_name_byte_at(call_pool, arg_i, k), 0)));
    ++k;
  }
  uint8_t z = ((uint8_t)(0));
  while (k < 64) {
    (((ae).var_name)[k] = (z));
    ++k;
  }
 } ; __tmp; }));
  (void)(parser_expr_set_common_zeros((&(ae))));
  (void)(ast_arena_expr_set(arena, arg_ref, ae));
  (void)(pipeline_expr_append_call_arg(arena, call_ref, arg_ref));
 } else (__tmp = 0) ; __tmp; }));
    ++arg_i;
  }
  (final_expr_ref = (call_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    int32_t block_ref = ast_arena_block_alloc(arena);
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (block_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1010) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    struct ast_Block b = ast_arena_block_get(arena, block_ref);
    ((b).num_consts = ((res).num_consts));
    ((b).num_lets = ((res).num_lets));
    ((b).num_early_lets = (0));
    ((b).num_loops = ((res).num_loops));
    ((b).num_for_loops = ((res).num_for_loops));
    ((b).num_if_stmts = ((res).num_if_stmts));
    ((b).num_defers = (0));
    ((b).num_labeled_stmts = (0));
    ((b).num_expr_stmts = (0));
    (void)(({ int32_t __tmp = 0; if (parser_should_wrap_func_tail_in_return(arena, (&(res)), type_ref)) {   int32_t wrapped_fe = parser_expr_wrap_in_return(arena, type_ref, final_expr_ref);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (wrapped_fe == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1011) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (final_expr_ref = (wrapped_fe));
 } else (__tmp = 0) ; __tmp; }));
    ((b).final_expr_ref = (final_expr_ref));
    ((b).num_stmt_order = (0));
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if ((!parser_fill_block_const_let_from_res(arena, block_ref, (&(res)), type_ref))) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (b = (ast_arena_block_get(arena, block_ref)));
    int32_t n_while_pool = pipeline_onefunc_num_whiles(parser_onefunc_result_pool_ptr((&(res))));
    ((res).num_loops = (n_while_pool));
    (void)(pipeline_block_fill_whiles_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_while_pool));
    int32_t n_for_pool = pipeline_onefunc_num_fors(parser_onefunc_result_pool_ptr((&(res))));
    ((res).num_for_loops = (n_for_pool));
    (void)(pipeline_block_fill_fors_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_for_pool));
    (b = (ast_arena_block_get(arena, block_ref)));
    int32_t n_if_pool = pipeline_onefunc_num_if_stmts(parser_onefunc_result_pool_ptr((&(res))));
    ((res).num_if_stmts = (n_if_pool));
    (void)(pipeline_block_fill_ifs_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_if_pool));
    int32_t n_reg_pool = pipeline_onefunc_num_regions(parser_onefunc_result_pool_ptr((&(res))));
    (void)(pipeline_block_fill_regions_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_reg_pool));
    (b = (ast_arena_block_get(arena, block_ref)));
    (void)(({ int32_t __tmp = 0; if ((res).num_src_stmt_order > 0) {   (void)(pipeline_block_fill_expr_stmts_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), pipeline_onefunc_num_body_expr_stmts(parser_onefunc_result_pool_ptr((&(res))))));
  (void)(pipeline_block_fill_stmt_order_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), pipeline_onefunc_num_src_stmt_order(parser_onefunc_result_pool_ptr((&(res))))));
  (b = (ast_arena_block_get(arena, block_ref)));
 } else {   int32_t ci2 = 0;
  while (ci2 < (b).num_consts) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (pipeline_block_append_stmt_order(arena, block_ref, 0, ci2) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    ++ci2;
  }
  int32_t li2 = 0;
  while (li2 < (b).num_lets) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (pipeline_block_append_stmt_order(arena, block_ref, 1, li2) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    ++li2;
  }
  int32_t loop_i = 0;
  while (loop_i < (b).num_loops) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (pipeline_block_append_stmt_order(arena, block_ref, 3, loop_i) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    ++loop_i;
  }
  int32_t for_i = 0;
  while (for_i < (b).num_for_loops) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (pipeline_block_append_stmt_order(arena, block_ref, 4, for_i) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    ++for_i;
  }
  int32_t if_oi = 0;
  while (if_oi < (b).num_if_stmts) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (pipeline_block_append_stmt_order(arena, block_ref, 5, if_oi) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    ++if_oi;
  }
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(final_expr_ref)) && (b).num_expr_stmts == 0) {   int32_t fin_ex = pipeline_block_append_expr_stmt(arena, block_ref, final_expr_ref);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (fin_ex < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  ((b).final_expr_ref = (0));
  (final_expr_ref = (0));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (pipeline_block_append_stmt_order(arena, block_ref, 2, fin_ex) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (b = (ast_arena_block_get(arena, block_ref)));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
    (b = (ast_arena_block_get(arena, block_ref)));
    ((b).final_expr_ref = (final_expr_ref));
    (void)(({ int32_t __tmp = 0; if ((b).num_expr_stmts > 0 && (!ast_ref_is_null(final_expr_ref))) {   struct ast_Expr fe_dedup = ast_arena_expr_get(arena, final_expr_ref);
  __tmp = ({ int32_t __tmp = 0; if ((fe_dedup).kind != ast_ExprKind_EXPR_RETURN) {   ((b).final_expr_ref = (0));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(ast_arena_block_set(arena, block_ref, b));
    int32_t fi = pipeline_module_func_alloc_slot(module);
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (fi < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1000) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (void)(pipeline_module_func_name_write(module, fi, (&(((res).name)[0])), (res).name_len));
    (void)(pipeline_module_func_set_num_params(module, fi, (res).num_params));
    uint8_t * mod_pool = parser_onefunc_result_pool_ptr((&(res)));
    int32_t p = 0;
    while (p < (res).num_params) {
      uint8_t pname32[32] = { 0 };
      (void)(pipeline_onefunc_param_name_copy32(mod_pool, p, (&((pname32)[0]))));
      (void)(pipeline_module_func_param_write(module, fi, p, (&((pname32)[0])), pipeline_onefunc_param_name_len(mod_pool, p), pipeline_onefunc_param_type_ref(mod_pool, p)));
      ++p;
    }
    (void)(pipeline_module_func_set_return_type(module, fi, type_ref));
    (void)(pipeline_module_func_set_body_ref(module, fi, block_ref));
    (void)(pipeline_module_func_set_is_extern(module, fi, 0));
    (void)(pipeline_module_func_set_is_async(module, fi, (func_is_async_storage)[0]));
    (void)(({ int32_t __tmp = 0; if ((is_main_storage)[0] != 0) {   (main_idx = (fi));
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_lex_from_onefunc_next_into((&(lex)), (&(res))));
  }
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if ((module)->num_funcs == 0) {   return (struct parser_ParseIntoResult){ .ok = 0, .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  int32_t out_idx_storage[1] = { 0 };
  ((out_idx_storage)[0] = (main_idx));
  return (struct parser_ParseIntoResult){ .ok = 0, .main_idx = (out_idx_storage)[0] };
}
void parser_parse_one_top_level_let_into(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, struct shux_slice_uint8_t * source, int is_const, struct parser_TopLevelLetResult * restrict out) {
  (void)(parser_parse_one_top_level_let_into_glue(arena, module, lex, source, is_const, out));
}
void parser_parse_primary_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_primary_into(arena, lex, &(slice), out));
}
void parser_parse_unary_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_unary_into(arena, lex, &(slice), out));
}
void parser_parse_cast_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_cast_into(arena, lex, &(slice), out));
}
void parser_parse_term_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_term_into(arena, lex, &(slice), out));
}
void parser_parse_addsub_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_addsub_into(arena, lex, &(slice), out));
}
void parser_parse_shift_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_shift_into(arena, lex, &(slice), out));
}
void parser_parse_relcompare_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_relcompare_into(arena, lex, &(slice), out));
}
void parser_parse_compare_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_compare_into(arena, lex, &(slice), out));
}
void parser_parse_bitand_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_bitand_into(arena, lex, &(slice), out));
}
void parser_parse_bitxor_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_bitxor_into(arena, lex, &(slice), out));
}
void parser_parse_bitor_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_bitor_into(arena, lex, &(slice), out));
}
void parser_parse_logand_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_logand_into(arena, lex, &(slice), out));
}
void parser_parse_logor_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_logor_into(arena, lex, &(slice), out));
}
void parser_parse_ternary_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_ternary_into(arena, lex, &(slice), out));
}
void parser_parse_assign_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_assign_into(arena, lex, &(slice), out));
}
void parser_parse_expr_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_expr_into(arena, lex, &(slice), out));
}
void parser_finish_struct_lit_from_type_ident_into_buf(struct ast_ASTArena * restrict arena, int32_t lit_ref, struct lexer_Lexer lex_in_brace, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_finish_struct_lit_from_type_ident_into(arena, lit_ref, lex_in_brace, &(slice), out));
}
void parser_parse_cond_expr_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_start, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_cond_expr_into(arena, lex_start, &(slice), out));
}
int parser_parse_if_stmt_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_at_if, uint8_t * restrict data, int32_t len, int32_t type_ref, int32_t * restrict out_cond, int32_t * restrict out_then, int32_t * restrict out_else, struct lexer_Lexer * restrict lex_out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_parse_if_stmt_into(arena, lex_at_if, &(slice), type_ref, out_cond, out_then, out_else, lex_out);
}
void parser_parse_block_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_after_lbrace, uint8_t * restrict data, int32_t len, int32_t type_ref, struct parser_ParseBlockResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_block_into(arena, lex_after_lbrace, &(slice), type_ref, out));
}
void parser_parse_if_expr_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex_at_if, uint8_t * restrict data, int32_t len, int32_t type_ref, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_if_expr_into(arena, lex_at_if, &(slice), type_ref, out));
}
void parser_parse_match_subject_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_match_subject_into(arena, lex, &(slice), out));
}
void parser_parse_match_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_match_into(arena, lex, &(slice), out));
}
void parser_parse_at_simd_builtin_into_buf(struct ast_ASTArena * restrict arena, struct lexer_LexerResult r0, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_at_simd_builtin_into(arena, r0, &(slice), out));
}
void parser_parse_as_suffix_into_buf(struct ast_ASTArena * restrict arena, uint8_t * restrict data, int32_t len, struct parser_ParseExprResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_as_suffix_into(arena, &(slice), out));
}
int32_t parser_parse_type_ref_for_arena_into_buf(struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct lexer_Lexer * restrict out_lex) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_parse_type_ref_for_arena_into(arena, lex, &(slice), out_lex);
}
int32_t parser_parse_body_let_bracket_compound_init_ref_buf(struct ast_ASTArena * restrict arena, size_t bracket_start, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct lexer_Lexer * restrict lex_out, struct lexer_LexerResult * restrict r_out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_parse_body_let_bracket_compound_init_ref(arena, bracket_start, lex, &(slice), lex_out, r_out);
}
int32_t parser_parse_struct_record_layout_into_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct lexer_Lexer * restrict out_lex, int32_t allow_pad, int32_t force_soa) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_parse_struct_record_layout_into(arena, module, lex, &(slice), out_lex, allow_pad, force_soa);
}
int parser_parse_one_function_library_scan_buf(struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct parser_LibraryParseScanResult * restrict result) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_parse_one_function_library_scan(lex, &(slice), result);
}
int32_t parser_alloc_pointee_type_ref_from_tok_buf(struct ast_ASTArena * restrict arena, uint8_t * restrict data, int32_t len, struct lexer_LexerResult * restrict r) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_alloc_pointee_type_ref_from_tok(arena, &(slice), r);
}
int32_t parser_vector_type_ref_from_ident_spelling_buf(struct ast_ASTArena * restrict arena, uint8_t * restrict data, int32_t len, struct lexer_LexerResult r) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  return parser_vector_type_ref_from_ident_spelling(arena, &(slice), r);
}
void parser_parse_one_top_level_let_into_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, int is_const, struct parser_TopLevelLetResult * restrict out) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_parse_one_top_level_let_into(arena, module, lex, &(slice), is_const, out));
}
void parser_skip_balanced_parens_slice_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_skip_balanced_parens_into(out, lex, &(slice)));
}
void parser_skip_balanced_braces_slice_into_buf(struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_skip_balanced_braces_into(out, lex, &(slice)));
}
void parser_module_append_enum_variants_and_skip_body_slice_into_buf(struct ast_Module * restrict module, int32_t enum_idx, struct lexer_Lexer * restrict out, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  struct shux_slice_uint8_t slice = parser_slice_from_buf(data, len);
  (void)(parser_module_append_enum_variants_and_skip_body_into(module, enum_idx, out, lex, &(slice)));
}
void parser_parse_one_extern_skip_buf(struct parser_ExternParseResult * restrict out, struct ast_ASTArena * restrict arena, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  (void)(parser_parse_one_extern_skip_into_buf(out, arena, lex, data, len));
}
void parser_parse_one_extern_and_add_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len, struct lexer_Lexer * restrict lex_out) {
  (void)(parser_parse_one_extern_and_add_into_buf(arena, module, lex, data, len, lex_out));
}
struct parser_LibraryParseResult parser_parse_one_function_library_from_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, struct lexer_Lexer lex, uint8_t * restrict data, int32_t len) {
  return parser_parse_one_function_library_buf(arena, module, lex, data, len);
}
struct parser_TrySkipAllowResult parser_parse_into_try_skip_allow_from_buf(struct lexer_Lexer lex, struct lexer_LexerResult r, uint8_t * restrict data, int32_t len) {
  return parser_parse_into_try_skip_allow_buf(lex, r, data, len);
}
struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena * restrict arena, struct ast_Module * restrict module, uint8_t * restrict data, int32_t len) {
  struct lexer_Lexer lex = lexer_init();
  int32_t main_idx = -1;
  struct parser_CollectImportsResult import_res = (struct parser_CollectImportsResult){ .lex = lex };
  (void)(parser_collect_imports_buf(lex, data, len, module, (&(import_res))));
  (void)(parser_copy_lex_from_import_into((&(lex)), import_res));
  int32_t loop_count_buf = 0;
  while (1) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (loop_count_buf >= 131072) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1003) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    ++loop_count_buf;
    struct lexer_Lexer iter_start_buf = lex;
    struct lexer_LexerResult r = (struct lexer_LexerResult){ .next_lex = lex, .tok = (struct token_Token){ .kind = token_TokenKind_TOKEN_EOF, .line = 0, .col = 0, .int_val = 0, .float_val = 0.0, .ident = 0, .ident_len = 0 }, .token_start = 0 };
    (void)(lexer_next_buf_into((&(r)), lex, data, len));
    (void)(parser_lex_from_next_into((&(lex)), r));
    int32_t func_is_async_buf[1] = { 0 };
    ((func_is_async_buf)[0] = (0));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ASYNC) {   ((func_is_async_buf)[0] = (1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(lexer_next_buf_into((&(r)), lex, data, len));
  (void)(parser_lex_from_next_into((&(lex)), r));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ATTR_SOA) {   ((module)->pending_soa_struct = (1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ATTR_CFG) {   ((module)->pending_cfg_skip = ((((r).tok).int_val == 0 ? 1 : 0)));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ATTR_REPR_C) {   ((module)->pending_repr_c_struct = (1));
  (void)(parser_lex_from_next_into((&(lex)), r));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((module)->pending_cfg_skip != 0) {   (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STRUCT) {   (void)(parser_skip_one_struct_into_buf((&(lex)), iter_start_buf, data, len));
  ((module)->pending_cfg_skip = (0));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_CONST) {   (void)(parser_skip_one_top_level_const_into_buf((&(lex)), iter_start_buf, data, len));
  ((module)->pending_cfg_skip = (0));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_FUNCTION || (func_is_async_buf)[0] != 0 || ((r).tok).kind == token_TokenKind_TOKEN_EXTERN) {   (void)(parser_skip_one_function_full_into_buf((&(lex)), iter_start_buf, data, len));
  ((module)->pending_cfg_skip = (0));
  ((func_is_async_buf)[0] = (0));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  ((module)->pending_cfg_skip = (0));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_STRUCT) {   struct lexer_Lexer lex_kw = iter_start_buf;
  int32_t ap_sb = (module)->pending_allow_padding;
  int32_t ps_sb = (module)->pending_soa_struct;
  int32_t pr_sb = (module)->pending_repr_c_struct;
  ((module)->pending_allow_padding = (0));
  ((module)->pending_soa_struct = (0));
  ((module)->pending_repr_c_struct = (0));
  int32_t allow_for_repr_buf = ap_sb;
  (void)(({ int32_t __tmp = 0; if (pr_sb != 0) {   (allow_for_repr_buf = (1));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (parser_parse_struct_record_layout_into_buf(arena, module, lex, data, len, (&(lex)), allow_for_repr_buf, ps_sb) != 0) {   (void)(parser_skip_one_struct_into_buf((&(lex)), lex_kw, data, len));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_ENUM) {   (void)(parser_skip_one_enum_register_into_buf(module, (&(lex)), iter_start_buf, data, len));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_TRAIT) {   (void)(parser_skip_one_trait_into_buf((&(lex)), iter_start_buf, data, len));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_IMPL) {   (void)(parser_skip_one_impl_into_buf((&(lex)), iter_start_buf, data, len));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EXTERN) {   (void)(parser_parse_one_extern_and_add_into_buf(arena, module, iter_start_buf, data, len, (&(lex))));
  (void)(({ int32_t __tmp = 0; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   (void)(parser_skip_one_extern_into_buf((&(lex)), iter_start_buf, data, len));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_LET || ((r).tok).kind == token_TokenKind_TOKEN_CONST) {   struct parser_TopLevelLetResult toplevel_res = (struct parser_TopLevelLetResult){ .ok = 0, .next_lex = lex };
  (void)(parser_parse_one_top_level_let_into_buf(arena, module, (r).next_lex, data, len, ((r).tok).kind == token_TokenKind_TOKEN_CONST, (&(toplevel_res))));
  __tmp = ({ int32_t __tmp = 0; if ((toplevel_res).ok) {   (lex = ((toplevel_res).next_lex));
  continue;
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if (((r).tok).kind != token_TokenKind_TOKEN_FUNCTION) {   struct parser_TrySkipAllowResult try_res = ({ struct parser_TrySkipAllowResult _t = { 0 }; _t.lex = lex; _t.skipped = 0; _t; });
  (void)(parser_parse_into_try_skip_allow_into_buf((&(try_res)), lex, r, data, len));
  (void)(({ int32_t __tmp = 0; if ((try_res).skipped != 0) {   ((module)->pending_allow_padding = (1));
  (void)(parser_lex_from_try_skip_into((&(lex)), try_res));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   break;
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (iter_start_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (((r).tok).kind == token_TokenKind_TOKEN_EOF) {   (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if ((module)->num_funcs == 0) {   return (struct parser_ParseIntoResult){ .ok = 0, .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  int32_t out_idx_storage[1] = { 0 };
  ((out_idx_storage)[0] = (main_idx));
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
    struct shux_slice_uint8_t slice_for_impl = parser_slice_from_buf(data, len);
    struct parser_LibraryParseResult lib_buf_first = parser_parse_one_function_library_buf(arena, module, lex_at_function_buf, data, len);
    (void)(({ int32_t __tmp = 0; if ((lib_buf_first).ok) {   (void)(parser_lex_from_library_into((&(lex)), lib_buf_first));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(parser_parse_one_function_impl((&(res)), arena, lex, &(slice_for_impl)));
    (void)(({ int32_t __tmp = 0; if ((!(res).ok)) {   (void)(parser_parse_one_function_buf_into((&(res)), lex_at_function_buf, data, len));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((!(res).ok)) {   uint8_t skip_name[64] = { 0 };
  int32_t skip_nlen = parser_parse_peek_function_name_buf(lex_at_function_buf, data, len, (&((skip_name)[0])));
  (void)(parser_diagnostic_parse_skip(((int32_t)((lex_at_function_buf).pos)), (module)->num_funcs, skip_nlen, (&((skip_name)[0]))));
  (void)(parser_skip_one_function_full_into_buf((&(lex)), lex_at_function_buf, data, len));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (lex_at_function_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int32_t is_main_storage[1] = { 0 };
    (void)(({ int32_t __tmp = 0; if ((res).name_len == 4 && ((res).name)[0] == 109 && (1 < 0 || (1) >= 64 ? (shux_panic_(1, 0), ((res).name)[0]) : ((res).name)[1]) == 97 && (2 < 0 || (2) >= 64 ? (shux_panic_(1, 0), ((res).name)[0]) : ((res).name)[2]) == 105 && (3 < 0 || (3) >= 64 ? (shux_panic_(1, 0), ((res).name)[0]) : ((res).name)[3]) == 110) {   ((is_main_storage)[0] = (1));
 } else (__tmp = 0) ; __tmp; }));
    int32_t type_ref = (res).func_return_type_ref;
    (void)(({ int32_t __tmp = 0; if (type_ref == 0) {   (type_ref = (ast_arena_type_alloc(arena)));
  (void)(({ int32_t __tmp = 0; if (type_ref == 0) {   (void)(parser_diagnostic_parse_skip(((int32_t)((lex_at_function_buf).pos)), (module)->num_funcs, (res).name_len, (&(((res).name)[0]))));
  (void)(parser_skip_one_function_full_into_buf((&(lex)), lex_at_function_buf, data, len));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (lex_at_function_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
  struct ast_Type t_fb = ast_arena_type_get(arena, type_ref);
  ((t_fb).kind = (ast_TypeKind_TYPE_I32));
  ((t_fb).name_len = (0));
  ((t_fb).elem_type_ref = (0));
  ((t_fb).array_size = (0));
  (void)(ast_arena_type_set(arena, type_ref, t_fb));
 } else (__tmp = 0) ; __tmp; }));
    int32_t expr_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (expr_ref == 0) {   (void)(parser_diagnostic_parse_commit_fail(((int32_t)((lex_at_function_buf).pos)), (module)->num_funcs, (res).name_len, (&(((res).name)[0]))));
  (void)(parser_skip_one_function_full_into_buf((&(lex)), lex_at_function_buf, data, len));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (lex_at_function_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    struct ast_Expr e = ast_arena_expr_get(arena, expr_ref);
    (void)(({ int32_t __tmp = 0; if ((res).return_var_name_len > 0) {   ((e).kind = (ast_ExprKind_EXPR_VAR));
  ((e).var_name_len = ((res).return_var_name_len));
  int32_t rvi = 0;
  while (rvi < (res).return_var_name_len && rvi < 64) {
    ((rvi < 0 || (rvi) >= 64 ? (shux_panic_(1, 0), 0) : (((e).var_name)[rvi] = (rvi < 0 || (rvi) >= 64 ? (shux_panic_(1, 0), ((res).return_var_name)[0]) : ((res).return_var_name)[rvi]), 0)));
    ++rvi;
  }
  uint8_t rvz = ((uint8_t)(0));
  while (rvi < 64) {
    (((e).var_name)[rvi] = (rvz));
    ++rvi;
  }
  ((e).int_val = (0));
  ((e).resolved_type_ref = (0));
 } else {   ((e).kind = (ast_ExprKind_EXPR_LIT));
  ((e).int_val = ((res).return_val));
  ((e).resolved_type_ref = (type_ref));
 } ; __tmp; }));
    ((e).line = (0));
    ((e).col = (0));
    ((e).binop_left_ref = (0));
    ((e).binop_right_ref = (0));
    ((e).unary_operand_ref = (0));
    ((e).if_cond_ref = (0));
    ((e).if_then_ref = (0));
    ((e).if_else_ref = (0));
    ((e).block_ref = (0));
    ((e).match_matched_ref = (0));
    ((e).match_num_arms = (0));
    (void)(ast_expr_init_match_enum((&(e))));
    ((e).field_access_base_ref = (0));
    ((e).field_access_field_len = (0));
    ((e).field_access_is_enum_variant = (0));
    ((e).field_access_offset = (0));
    ((e).index_base_ref = (0));
    ((e).index_index_ref = (0));
    ((e).index_base_is_slice = (0));
    ((e).call_callee_ref = (0));
    ((e).call_num_args = (0));
    ((e).method_call_base_ref = (0));
    ((e).method_call_name_len = (0));
    ((e).method_call_num_args = (0));
    ((e).const_folded_val = (0));
    ((e).const_folded_valid = (0));
    ((e).index_proven_in_bounds = (0));
    (void)(ast_arena_expr_set(arena, expr_ref, e));
    int32_t final_expr_ref = expr_ref;
    (void)(({ int32_t __tmp = 0; if ((res).return_expr_ref != 0) {   (final_expr_ref = ((res).return_expr_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).return_var_name_len > 0 && (res).return_expr_ref == 0) {   int32_t var_wrapped = parser_expr_wrap_in_return(arena, type_ref, final_expr_ref);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (var_wrapped == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1003) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (final_expr_ref = (var_wrapped));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_mul && (!(res).has_binop)) {   int32_t mul_right_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_right_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr mre = ast_arena_expr_get(arena, mul_right_ref);
  ((mre).kind = (ast_ExprKind_EXPR_LIT));
  ((mre).resolved_type_ref = (type_ref));
  ((mre).line = (0));
  ((mre).col = (0));
  ((mre).int_val = ((res).mul_right_val));
  ((mre).binop_left_ref = (0));
  ((mre).binop_right_ref = (0));
  ((mre).unary_operand_ref = (0));
  ((mre).if_cond_ref = (0));
  ((mre).if_then_ref = (0));
  ((mre).if_else_ref = (0));
  ((mre).block_ref = (0));
  ((mre).match_matched_ref = (0));
  ((mre).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(mre))));
  ((mre).field_access_base_ref = (0));
  ((mre).field_access_field_len = (0));
  ((mre).field_access_is_enum_variant = (0));
  ((mre).field_access_offset = (0));
  ((mre).index_base_ref = (0));
  ((mre).index_index_ref = (0));
  ((mre).index_base_is_slice = (0));
  ((mre).call_callee_ref = (0));
  ((mre).call_num_args = (0));
  ((mre).method_call_base_ref = (0));
  ((mre).method_call_name_len = (0));
  ((mre).method_call_num_args = (0));
  ((mre).const_folded_val = (0));
  ((mre).const_folded_valid = (0));
  ((mre).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, mul_right_ref, mre));
  int32_t mul_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (mul_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr me = ast_arena_expr_get(arena, mul_ref);
  ((me).kind = (ast_ExprKind_EXPR_BINOP));
  ((me).resolved_type_ref = (type_ref));
  ((me).line = (0));
  ((me).col = (0));
  ((me).int_val = (0));
  ((me).binop_left_ref = (expr_ref));
  ((me).binop_right_ref = (mul_right_ref));
  ((me).unary_operand_ref = (0));
  ((me).if_cond_ref = (0));
  ((me).if_then_ref = (0));
  ((me).if_else_ref = (0));
  ((me).block_ref = (0));
  ((me).match_matched_ref = (0));
  ((me).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(me))));
  ((me).field_access_base_ref = (0));
  ((me).field_access_field_len = (0));
  ((me).field_access_is_enum_variant = (0));
  ((me).field_access_offset = (0));
  ((me).index_base_ref = (0));
  ((me).index_index_ref = (0));
  ((me).index_base_is_slice = (0));
  ((me).call_callee_ref = (0));
  ((me).call_num_args = (0));
  ((me).method_call_base_ref = (0));
  ((me).method_call_name_len = (0));
  ((me).method_call_num_args = (0));
  ((me).const_folded_val = (0));
  ((me).const_folded_valid = (0));
  ((me).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, mul_ref, me));
  (void)(ast_arena_expr_set(arena, expr_ref, e));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_if_expr) {   int32_t cond_ref = 0;
  (void)(({ int32_t __tmp = 0; if ((res).if_cond_expr_ref != 0) {   (cond_ref = ((res).if_cond_expr_ref));
 } else {   int32_t bool_type_ref = ast_arena_type_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (bool_type_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1005) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Type bt = ast_arena_type_get(arena, bool_type_ref);
  ((bt).kind = (ast_TypeKind_TYPE_BOOL));
  ((bt).name_len = (0));
  ((bt).elem_type_ref = (0));
  ((bt).array_size = (0));
  (void)(ast_arena_type_set(arena, bool_type_ref, bt));
  (cond_ref = (ast_arena_expr_alloc(arena)));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (cond_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ce = ast_arena_expr_get(arena, cond_ref);
  ((ce).kind = (ast_ExprKind_EXPR_BOOL_LIT));
  ((ce).resolved_type_ref = (bool_type_ref));
  ((ce).line = (0));
  ((ce).col = (0));
  (void)(({ int32_t __tmp = 0; if ((res).if_cond_true) {   ((ce).int_val = (1));
 } else {   ((ce).int_val = (0));
 } ; __tmp; }));
  ((ce).binop_left_ref = (0));
  ((ce).binop_right_ref = (0));
  ((ce).unary_operand_ref = (0));
  ((ce).if_cond_ref = (0));
  ((ce).if_then_ref = (0));
  ((ce).if_else_ref = (0));
  ((ce).block_ref = (0));
  ((ce).match_matched_ref = (0));
  ((ce).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(ce))));
  ((ce).field_access_base_ref = (0));
  ((ce).field_access_field_len = (0));
  ((ce).field_access_is_enum_variant = (0));
  ((ce).field_access_offset = (0));
  ((ce).index_base_ref = (0));
  ((ce).index_index_ref = (0));
  ((ce).index_base_is_slice = (0));
  ((ce).call_callee_ref = (0));
  ((ce).call_num_args = (0));
  ((ce).method_call_base_ref = (0));
  ((ce).method_call_name_len = (0));
  ((ce).method_call_num_args = (0));
  ((ce).const_folded_val = (0));
  ((ce).const_folded_valid = (0));
  ((ce).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, cond_ref, ce));
 } ; __tmp; }));
  int32_t then_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (then_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr te = ast_arena_expr_get(arena, then_ref);
  ((te).kind = (ast_ExprKind_EXPR_LIT));
  ((te).resolved_type_ref = (type_ref));
  ((te).line = (0));
  ((te).col = (0));
  ((te).int_val = ((res).if_then_val));
  ((te).binop_left_ref = (0));
  ((te).binop_right_ref = (0));
  ((te).unary_operand_ref = (0));
  ((te).if_cond_ref = (0));
  ((te).if_then_ref = (0));
  ((te).if_else_ref = (0));
  ((te).block_ref = (0));
  ((te).match_matched_ref = (0));
  ((te).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(te))));
  ((te).field_access_base_ref = (0));
  ((te).field_access_field_len = (0));
  ((te).field_access_is_enum_variant = (0));
  ((te).field_access_offset = (0));
  ((te).index_base_ref = (0));
  ((te).index_index_ref = (0));
  ((te).index_base_is_slice = (0));
  ((te).call_callee_ref = (0));
  ((te).call_num_args = (0));
  ((te).method_call_base_ref = (0));
  ((te).method_call_name_len = (0));
  ((te).method_call_num_args = (0));
  ((te).const_folded_val = (0));
  ((te).const_folded_valid = (0));
  ((te).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, then_ref, te));
  int32_t else_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (else_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ee = ast_arena_expr_get(arena, else_ref);
  ((ee).kind = (ast_ExprKind_EXPR_LIT));
  ((ee).resolved_type_ref = (type_ref));
  ((ee).line = (0));
  ((ee).col = (0));
  ((ee).int_val = ((res).if_else_val));
  ((ee).binop_left_ref = (0));
  ((ee).binop_right_ref = (0));
  ((ee).unary_operand_ref = (0));
  ((ee).if_cond_ref = (0));
  ((ee).if_then_ref = (0));
  ((ee).if_else_ref = (0));
  ((ee).block_ref = (0));
  ((ee).match_matched_ref = (0));
  ((ee).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(ee))));
  ((ee).field_access_base_ref = (0));
  ((ee).field_access_field_len = (0));
  ((ee).field_access_is_enum_variant = (0));
  ((ee).field_access_offset = (0));
  ((ee).index_base_ref = (0));
  ((ee).index_index_ref = (0));
  ((ee).index_base_is_slice = (0));
  ((ee).call_callee_ref = (0));
  ((ee).call_num_args = (0));
  ((ee).method_call_base_ref = (0));
  ((ee).method_call_name_len = (0));
  ((ee).method_call_num_args = (0));
  ((ee).const_folded_val = (0));
  ((ee).const_folded_valid = (0));
  ((ee).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, else_ref, ee));
  int32_t if_expr_ref = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (if_expr_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ie = ast_arena_expr_get(arena, if_expr_ref);
  ((ie).kind = (ast_ExprKind_EXPR_IF));
  ((ie).resolved_type_ref = (type_ref));
  ((ie).line = (0));
  ((ie).col = (0));
  ((ie).int_val = (0));
  ((ie).binop_left_ref = (0));
  ((ie).binop_right_ref = (0));
  ((ie).unary_operand_ref = (0));
  ((ie).if_cond_ref = (cond_ref));
  ((ie).if_then_ref = (then_ref));
  ((ie).if_else_ref = (else_ref));
  ((ie).block_ref = (0));
  ((ie).match_matched_ref = (0));
  ((ie).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(ie))));
  ((ie).field_access_base_ref = (0));
  ((ie).field_access_field_len = (0));
  ((ie).field_access_is_enum_variant = (0));
  ((ie).field_access_offset = (0));
  ((ie).index_base_ref = (0));
  ((ie).index_index_ref = (0));
  ((ie).index_base_is_slice = (0));
  ((ie).call_callee_ref = (0));
  ((ie).call_num_args = (0));
  ((ie).method_call_base_ref = (0));
  ((ie).method_call_name_len = (0));
  ((ie).method_call_num_args = (0));
  ((ie).const_folded_val = (0));
  ((ie).const_folded_valid = (0));
  ((ie).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, if_expr_ref, ie));
  (final_expr_ref = (if_expr_ref));
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).return_expr_ref == 0) {   __tmp = ({ int32_t __tmp = 0; if ((res).has_binop || (res).binop_right_val != 0) {   uint8_t * res_pool_buf = parser_onefunc_result_pool_ptr((&(res)));
  int32_t left_ref_buf = final_expr_ref;
  (void)(({ int32_t __tmp = 0; if ((res).binop_left_param_idx >= 0 && (res).binop_left_param_idx < (res).num_params) {   int32_t lpr_buf = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (lpr_buf != 0) {   struct ast_Expr lpe_buf = ast_arena_expr_get(arena, lpr_buf);
  ((lpe_buf).kind = (ast_ExprKind_EXPR_VAR));
  ((lpe_buf).resolved_type_ref = (type_ref));
  ((lpe_buf).line = (0));
  ((lpe_buf).col = (0));
  ((lpe_buf).var_name_len = (pipeline_onefunc_param_name_len(res_pool_buf, (res).binop_left_param_idx)));
  int32_t lk_buf = 0;
  while (lk_buf < (lpe_buf).var_name_len && lk_buf < 64) {
    ((lk_buf < 0 || (lk_buf) >= 64 ? (shux_panic_(1, 0), 0) : (((lpe_buf).var_name)[lk_buf] = pipeline_onefunc_param_name_byte_at(res_pool_buf, (res).binop_left_param_idx, lk_buf), 0)));
    ++lk_buf;
  }
  uint8_t lz_buf = ((uint8_t)(0));
  while (lk_buf < 64) {
    (((lpe_buf).var_name)[lk_buf] = (lz_buf));
    ++lk_buf;
  }
  ((lpe_buf).binop_left_ref = (0));
  ((lpe_buf).binop_right_ref = (0));
  ((lpe_buf).unary_operand_ref = (0));
  ((lpe_buf).if_cond_ref = (0));
  ((lpe_buf).if_then_ref = (0));
  ((lpe_buf).if_else_ref = (0));
  ((lpe_buf).block_ref = (0));
  ((lpe_buf).match_matched_ref = (0));
  ((lpe_buf).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(lpe_buf))));
  ((lpe_buf).field_access_base_ref = (0));
  ((lpe_buf).field_access_field_len = (0));
  ((lpe_buf).field_access_is_enum_variant = (0));
  ((lpe_buf).field_access_offset = (0));
  ((lpe_buf).index_base_ref = (0));
  ((lpe_buf).index_index_ref = (0));
  ((lpe_buf).index_base_is_slice = (0));
  ((lpe_buf).call_callee_ref = (0));
  ((lpe_buf).call_num_args = (0));
  ((lpe_buf).method_call_base_ref = (0));
  ((lpe_buf).method_call_name_len = (0));
  ((lpe_buf).method_call_num_args = (0));
  ((lpe_buf).const_folded_val = (0));
  ((lpe_buf).const_folded_valid = (0));
  ((lpe_buf).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, lpr_buf, lpe_buf));
  (left_ref_buf = (lpr_buf));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
  int32_t right_ref_buf = 0;
  (void)(({ int32_t __tmp = 0; if ((res).binop_right_param_idx >= 0 && (res).binop_right_param_idx < (res).num_params) {   int32_t rpr_buf = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (rpr_buf != 0) {   struct ast_Expr rpe_buf = ast_arena_expr_get(arena, rpr_buf);
  ((rpe_buf).kind = (ast_ExprKind_EXPR_VAR));
  ((rpe_buf).resolved_type_ref = (type_ref));
  ((rpe_buf).line = (0));
  ((rpe_buf).col = (0));
  ((rpe_buf).var_name_len = (pipeline_onefunc_param_name_len(res_pool_buf, (res).binop_right_param_idx)));
  int32_t rk_buf = 0;
  while (rk_buf < (rpe_buf).var_name_len && rk_buf < 64) {
    ((rk_buf < 0 || (rk_buf) >= 64 ? (shux_panic_(1, 0), 0) : (((rpe_buf).var_name)[rk_buf] = pipeline_onefunc_param_name_byte_at(res_pool_buf, (res).binop_right_param_idx, rk_buf), 0)));
    ++rk_buf;
  }
  uint8_t rz_buf = ((uint8_t)(0));
  while (rk_buf < 64) {
    (((rpe_buf).var_name)[rk_buf] = (rz_buf));
    ++rk_buf;
  }
  ((rpe_buf).binop_left_ref = (0));
  ((rpe_buf).binop_right_ref = (0));
  ((rpe_buf).unary_operand_ref = (0));
  ((rpe_buf).if_cond_ref = (0));
  ((rpe_buf).if_then_ref = (0));
  ((rpe_buf).if_else_ref = (0));
  ((rpe_buf).block_ref = (0));
  ((rpe_buf).match_matched_ref = (0));
  ((rpe_buf).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(rpe_buf))));
  ((rpe_buf).field_access_base_ref = (0));
  ((rpe_buf).field_access_field_len = (0));
  ((rpe_buf).field_access_is_enum_variant = (0));
  ((rpe_buf).field_access_offset = (0));
  ((rpe_buf).index_base_ref = (0));
  ((rpe_buf).index_index_ref = (0));
  ((rpe_buf).index_base_is_slice = (0));
  ((rpe_buf).call_callee_ref = (0));
  ((rpe_buf).call_num_args = (0));
  ((rpe_buf).method_call_base_ref = (0));
  ((rpe_buf).method_call_name_len = (0));
  ((rpe_buf).method_call_num_args = (0));
  ((rpe_buf).const_folded_val = (0));
  ((rpe_buf).const_folded_valid = (0));
  ((rpe_buf).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, rpr_buf, rpe_buf));
  (right_ref_buf = (rpr_buf));
 } else (__tmp = 0) ; __tmp; });
 } else {   (right_ref_buf = (ast_arena_expr_alloc(arena)));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (right_ref_buf == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr re_buf = ast_arena_expr_get(arena, right_ref_buf);
  ((re_buf).kind = (ast_ExprKind_EXPR_LIT));
  ((re_buf).resolved_type_ref = (type_ref));
  ((re_buf).line = (0));
  ((re_buf).col = (0));
  ((re_buf).int_val = ((res).binop_right_val));
  ((re_buf).binop_left_ref = (0));
  ((re_buf).binop_right_ref = (0));
  ((re_buf).unary_operand_ref = (0));
  ((re_buf).if_cond_ref = (0));
  ((re_buf).if_then_ref = (0));
  ((re_buf).if_else_ref = (0));
  ((re_buf).block_ref = (0));
  ((re_buf).match_matched_ref = (0));
  ((re_buf).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(re_buf))));
  ((re_buf).field_access_base_ref = (0));
  ((re_buf).field_access_field_len = (0));
  ((re_buf).field_access_is_enum_variant = (0));
  ((re_buf).field_access_offset = (0));
  ((re_buf).index_base_ref = (0));
  ((re_buf).index_index_ref = (0));
  ((re_buf).index_base_is_slice = (0));
  ((re_buf).call_callee_ref = (0));
  ((re_buf).call_num_args = (0));
  ((re_buf).method_call_base_ref = (0));
  ((re_buf).method_call_name_len = (0));
  ((re_buf).method_call_num_args = (0));
  ((re_buf).const_folded_val = (0));
  ((re_buf).const_folded_valid = (0));
  ((re_buf).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, right_ref_buf, re_buf));
 } ; __tmp; }));
  int32_t add_ref_buf = ast_arena_expr_alloc(arena);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (add_ref_buf == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  struct ast_Expr ae_buf = ast_arena_expr_get(arena, add_ref_buf);
  ((ae_buf).kind = (ast_ExprKind_EXPR_ADD));
  ((ae_buf).resolved_type_ref = (type_ref));
  ((ae_buf).line = (0));
  ((ae_buf).col = (0));
  ((ae_buf).int_val = (0));
  ((ae_buf).binop_left_ref = (left_ref_buf));
  ((ae_buf).binop_right_ref = (right_ref_buf));
  ((ae_buf).unary_operand_ref = (0));
  ((ae_buf).if_cond_ref = (0));
  ((ae_buf).if_then_ref = (0));
  ((ae_buf).if_else_ref = (0));
  ((ae_buf).block_ref = (0));
  ((ae_buf).match_matched_ref = (0));
  ((ae_buf).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(ae_buf))));
  ((ae_buf).field_access_base_ref = (0));
  ((ae_buf).field_access_field_len = (0));
  ((ae_buf).field_access_is_enum_variant = (0));
  ((ae_buf).field_access_offset = (0));
  ((ae_buf).index_base_ref = (0));
  ((ae_buf).index_index_ref = (0));
  ((ae_buf).index_base_is_slice = (0));
  ((ae_buf).call_callee_ref = (0));
  ((ae_buf).call_num_args = (0));
  ((ae_buf).method_call_base_ref = (0));
  ((ae_buf).method_call_name_len = (0));
  ((ae_buf).method_call_num_args = (0));
  ((ae_buf).const_folded_val = (0));
  ((ae_buf).const_folded_valid = (0));
  ((ae_buf).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, add_ref_buf, ae_buf));
  (final_expr_ref = (add_ref_buf));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(({ int32_t __tmp = 0; if ((res).has_call_expr && (res).return_expr_ref == 0 && (res).call_callee_len > 0 && (res).call_callee_len <= 63) {   uint8_t * call_pool_buf = parser_onefunc_result_pool_ptr((&(res)));
  int32_t callee_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (callee_ref != 0) {   struct ast_Expr ve = ast_arena_expr_get(arena, callee_ref);
  ((ve).kind = (ast_ExprKind_EXPR_VAR));
  ((ve).resolved_type_ref = (0));
  ((ve).line = (0));
  ((ve).col = (0));
  ((ve).var_name_len = ((res).call_callee_len));
  int32_t ck = 0;
  while (ck < (res).call_callee_len && ck < 64) {
    ((ck < 0 || (ck) >= 64 ? (shux_panic_(1, 0), 0) : (((ve).var_name)[ck] = (ck < 0 || (ck) >= 64 ? (shux_panic_(1, 0), ((res).call_callee_name)[0]) : ((res).call_callee_name)[ck]), 0)));
    ++ck;
  }
  uint8_t z = ((uint8_t)(0));
  while (ck < 64) {
    (((ve).var_name)[ck] = (z));
    ++ck;
  }
  ((ve).binop_left_ref = (0));
  ((ve).binop_right_ref = (0));
  ((ve).unary_operand_ref = (0));
  ((ve).if_cond_ref = (0));
  ((ve).if_then_ref = (0));
  ((ve).if_else_ref = (0));
  ((ve).block_ref = (0));
  ((ve).match_matched_ref = (0));
  ((ve).match_num_arms = (0));
  (void)(ast_expr_init_match_enum((&(ve))));
  ((ve).field_access_base_ref = (0));
  ((ve).field_access_field_len = (0));
  ((ve).field_access_is_enum_variant = (0));
  ((ve).field_access_offset = (0));
  ((ve).index_base_ref = (0));
  ((ve).index_index_ref = (0));
  ((ve).index_base_is_slice = (0));
  ((ve).call_callee_ref = (0));
  ((ve).call_num_args = (0));
  ((ve).method_call_base_ref = (0));
  ((ve).method_call_name_len = (0));
  ((ve).method_call_num_args = (0));
  ((ve).const_folded_val = (0));
  ((ve).const_folded_valid = (0));
  ((ve).index_proven_in_bounds = (0));
  (void)(ast_arena_expr_set(arena, callee_ref, ve));
  int32_t call_ref = ast_arena_expr_alloc(arena);
  __tmp = ({ int32_t __tmp = 0; if (call_ref != 0) {   struct ast_Expr ce = ast_arena_expr_get(arena, call_ref);
  (void)(parser_expr_set_common_zeros((&(ce))));
  ((ce).kind = (ast_ExprKind_EXPR_CALL));
  ((ce).resolved_type_ref = (type_ref));
  ((ce).line = (0));
  ((ce).col = (0));
  ((ce).call_callee_ref = (callee_ref));
  (void)(({ int32_t __tmp = 0; if ((res).call_num_args > 0) {   ((ce).call_num_args = ((res).call_num_args));
 } else {   ((ce).call_num_args = ((res).num_params));
 } ; __tmp; }));
  (void)(ast_arena_expr_set(arena, call_ref, ce));
  int32_t arg_i = 0;
  while (arg_i < (ce).call_num_args) {
    int32_t arg_ref = ast_arena_expr_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (arg_ref != 0) {   struct ast_Expr ae = ast_arena_expr_get(arena, arg_ref);
  ((ae).resolved_type_ref = (0));
  ((ae).line = (0));
  ((ae).col = (0));
  (void)(({ int32_t __tmp = 0; if ((res).call_num_args > 0 && arg_i < (res).call_num_args) {   ((ae).kind = (ast_ExprKind_EXPR_LIT));
  ((ae).int_val = (pipeline_onefunc_call_arg_val_at(call_pool_buf, arg_i)));
 } else {   ((ae).kind = (ast_ExprKind_EXPR_VAR));
  ((ae).var_name_len = (pipeline_onefunc_param_name_len(call_pool_buf, arg_i)));
  int32_t k = 0;
  while (k < (ae).var_name_len && k < 64) {
    ((k < 0 || (k) >= 64 ? (shux_panic_(1, 0), 0) : (((ae).var_name)[k] = pipeline_onefunc_param_name_byte_at(call_pool_buf, arg_i, k), 0)));
    ++k;
  }
  uint8_t z = ((uint8_t)(0));
  while (k < 64) {
    (((ae).var_name)[k] = (z));
    ++k;
  }
 } ; __tmp; }));
  (void)(parser_expr_set_common_zeros((&(ae))));
  (void)(ast_arena_expr_set(arena, arg_ref, ae));
  (void)(pipeline_expr_append_call_arg(arena, call_ref, arg_ref));
 } else (__tmp = 0) ; __tmp; }));
    ++arg_i;
  }
  ((res).return_expr_ref = (call_ref));
  (final_expr_ref = (call_ref));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    int32_t block_ref = ast_arena_block_alloc(arena);
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (block_ref == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    struct ast_Block b = ast_arena_block_get(arena, block_ref);
    ((b).num_consts = ((res).num_consts));
    ((b).num_lets = ((res).num_lets));
    ((b).num_early_lets = (0));
    ((b).num_loops = ((res).num_loops));
    ((b).num_for_loops = ((res).num_for_loops));
    ((b).num_if_stmts = ((res).num_if_stmts));
    ((b).num_defers = (0));
    ((b).num_labeled_stmts = (0));
    ((b).num_expr_stmts = (0));
    (void)(({ int32_t __tmp = 0; if (parser_should_wrap_func_tail_in_return(arena, (&(res)), type_ref)) {   int32_t wrapped_tail2 = parser_expr_wrap_in_return(arena, type_ref, final_expr_ref);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (wrapped_tail2 == 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (final_expr_ref = (wrapped_tail2));
 } else (__tmp = 0) ; __tmp; }));
    ((b).final_expr_ref = (final_expr_ref));
    ((b).num_stmt_order = (0));
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if ((!parser_fill_block_const_let_from_res(arena, block_ref, (&(res)), type_ref))) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    (b = (ast_arena_block_get(arena, block_ref)));
    int32_t n_while_pool2 = pipeline_onefunc_num_whiles(parser_onefunc_result_pool_ptr((&(res))));
    ((res).num_loops = (n_while_pool2));
    (void)(pipeline_block_fill_whiles_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_while_pool2));
    int32_t n_for_pool2 = pipeline_onefunc_num_fors(parser_onefunc_result_pool_ptr((&(res))));
    ((res).num_for_loops = (n_for_pool2));
    (void)(pipeline_block_fill_fors_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_for_pool2));
    (b = (ast_arena_block_get(arena, block_ref)));
    int32_t n_if_pool2 = pipeline_onefunc_num_if_stmts(parser_onefunc_result_pool_ptr((&(res))));
    ((res).num_if_stmts = (n_if_pool2));
    (void)(pipeline_block_fill_ifs_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_if_pool2));
    int32_t n_reg_pool2 = pipeline_onefunc_num_regions(parser_onefunc_result_pool_ptr((&(res))));
    (void)(pipeline_block_fill_regions_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), n_reg_pool2));
    (b = (ast_arena_block_get(arena, block_ref)));
    (void)(({ int32_t __tmp = 0; if ((res).num_src_stmt_order > 0) {   (void)(pipeline_block_fill_expr_stmts_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), pipeline_onefunc_num_body_expr_stmts(parser_onefunc_result_pool_ptr((&(res))))));
  (void)(pipeline_block_fill_stmt_order_from_onefunc(arena, block_ref, parser_onefunc_result_pool_ptr((&(res))), pipeline_onefunc_num_src_stmt_order(parser_onefunc_result_pool_ptr((&(res))))));
  (b = (ast_arena_block_get(arena, block_ref)));
 } else {   int32_t ci2b = 0;
  while (ci2b < (b).num_consts) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (pipeline_block_append_stmt_order(arena, block_ref, 0, ci2b) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    ++ci2b;
  }
  int32_t li2b = 0;
  while (li2b < (b).num_lets) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (pipeline_block_append_stmt_order(arena, block_ref, 1, li2b) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    ++li2b;
  }
  int32_t loop_ib = 0;
  while (loop_ib < (b).num_loops) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (pipeline_block_append_stmt_order(arena, block_ref, 3, loop_ib) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    ++loop_ib;
  }
  int32_t for_ib = 0;
  while (for_ib < (b).num_for_loops) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (pipeline_block_append_stmt_order(arena, block_ref, 4, for_ib) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    ++for_ib;
  }
  int32_t if_oib = 0;
  while (if_oib < (b).num_if_stmts) {
    (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (pipeline_block_append_stmt_order(arena, block_ref, 5, if_oib) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
    ++if_oib;
  }
  __tmp = ({ int32_t __tmp = 0; if ((!ast_ref_is_null(final_expr_ref)) && (b).num_expr_stmts == 0) {   int32_t fin_ex2 = pipeline_block_append_expr_stmt(arena, block_ref, final_expr_ref);
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (fin_ex2 < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  ((b).final_expr_ref = (0));
  (final_expr_ref = (0));
  (void)(({ struct parser_ParseIntoResult __tmp = (struct parser_ParseIntoResult){0}; if (pipeline_block_append_stmt_order(arena, block_ref, 2, fin_ex2) < 0) {   return (struct parser_ParseIntoResult){ .ok = (-1), .main_idx = (-1) };
 } else (__tmp = (struct parser_ParseIntoResult){0}) ; __tmp; }));
  (b = (ast_arena_block_get(arena, block_ref)));
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; }));
    (b = (ast_arena_block_get(arena, block_ref)));
    ((b).final_expr_ref = (final_expr_ref));
    (void)(({ int32_t __tmp = 0; if ((b).num_expr_stmts > 0 && (!ast_ref_is_null(final_expr_ref))) {   struct ast_Expr fe_dedup2 = ast_arena_expr_get(arena, final_expr_ref);
  __tmp = ({ int32_t __tmp = 0; if ((fe_dedup2).kind != ast_ExprKind_EXPR_RETURN) {   ((b).final_expr_ref = (0));
 } else (__tmp = 0) ; __tmp; });
 } else (__tmp = 0) ; __tmp; }));
    (void)(ast_arena_block_set(arena, block_ref, b));
    int32_t func_ref = ast_arena_func_alloc(arena);
    (void)(({ int32_t __tmp = 0; if (func_ref == 0) {   (void)(parser_diagnostic_parse_commit_fail(((int32_t)((lex_at_function_buf).pos)), (module)->num_funcs, (res).name_len, (&(((res).name)[0]))));
  (void)(parser_skip_one_function_full_into_buf((&(lex)), lex_at_function_buf, data, len));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (lex_at_function_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    int32_t fi_mod = pipeline_module_func_alloc_slot(module);
    (void)(({ int32_t __tmp = 0; if (fi_mod < 0) {   (void)(parser_diagnostic_parse_commit_fail(((int32_t)((lex_at_function_buf).pos)), (module)->num_funcs, (res).name_len, (&(((res).name)[0]))));
  (void)(parser_skip_one_function_full_into_buf((&(lex)), lex_at_function_buf, data, len));
  (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == (lex_at_function_buf).pos && (lex).pos < ((size_t)(len))) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  continue;
 } else (__tmp = 0) ; __tmp; }));
    (void)(pipeline_module_func_name_write(module, fi_mod, (&(((res).name)[0])), (res).name_len));
    (void)(pipeline_module_func_set_num_params(module, fi_mod, (res).num_params));
    (void)(pipeline_module_func_set_return_type(module, fi_mod, type_ref));
    (void)(pipeline_module_func_set_body_ref(module, fi_mod, block_ref));
    (void)(pipeline_module_func_set_body_expr_ref(module, fi_mod, 0));
    (void)(pipeline_module_func_set_is_extern(module, fi_mod, 0));
    (void)(pipeline_module_func_set_is_async(module, fi_mod, (func_is_async_buf)[0]));
    int32_t p_copy = 0;
    uint8_t * mod_pool_buf = parser_onefunc_result_pool_ptr((&(res)));
    while (p_copy < (res).num_params) {
      uint8_t pname32b[32] = { 0 };
      (void)(pipeline_onefunc_param_name_copy32(mod_pool_buf, p_copy, (&((pname32b)[0]))));
      (void)(pipeline_module_func_param_write(module, fi_mod, p_copy, (&((pname32b)[0])), pipeline_onefunc_param_name_len(mod_pool_buf, p_copy), pipeline_onefunc_param_type_ref(mod_pool_buf, p_copy)));
      ++p_copy;
    }
    (void)(pipeline_module_func_ref_set(module, fi_mod, func_ref));
    (void)(pipeline_arena_func_copy_slot_from_module(arena, func_ref, module, fi_mod));
    (void)(({ int32_t __tmp = 0; if ((is_main_storage)[0] != 0) {   (main_idx = (fi_mod));
 } else (__tmp = 0) ; __tmp; }));
    size_t parse_into_guard_pos = (lex).pos;
    (void)(parser_lex_from_onefunc_next_into((&(lex)), (&(res))));
    (void)(({ struct lexer_Lexer __tmp = (struct lexer_Lexer){0}; if ((lex).pos == parse_into_guard_pos) {   __tmp = (lex = ((struct lexer_Lexer){ .pos = (lex).pos + 1, .line = (lex).line, .col = (lex).col + 1 }));
 } else (__tmp = (struct lexer_Lexer){0}) ; __tmp; }));
  }
  int32_t out_idx = main_idx;
  int32_t out_idx_storage[1] = { 0 };
  ((out_idx_storage)[0] = (out_idx));
  return (struct parser_ParseIntoResult){ .ok = 0, .main_idx = (out_idx_storage)[0] };
}
void parser_parse_into_set_main_index(struct ast_Module * restrict module, int32_t main_idx) {
  (void)(parser_parse_into_set_main_index_glue(module, main_idx));
}
int32_t parser_diag_token_after_collect_imports(struct shux_slice_uint8_t * source, struct ast_Module * restrict module) {
  return parser_diag_token_after_collect_imports_glue(source, module);
}
int32_t parser_diag_parse_one_after_collect_imports(struct shux_slice_uint8_t * source, struct ast_Module * restrict module, struct ast_ASTArena * restrict arena) {
  return parser_diag_parse_one_after_collect_imports_glue(source, module, arena);
}
int32_t parser_parse_one_function_ok_for_pipeline(struct ast_ASTArena * restrict arena, struct shux_slice_uint8_t * source) {
  return parser_parse_one_function_ok_for_pipeline_glue(arena, source);
}
int32_t parser_get_module_num_imports(struct ast_Module * restrict module) {
  return (module)->num_imports;
}
void parser_get_module_import_path(struct ast_Module * restrict module, int32_t i, uint8_t out[64]) {
  (void)(({ int32_t __tmp = 0; if (i < 0 || i >= (module)->num_imports) {   uint8_t z = ((uint8_t)(0));
  ((out)[0] = (z));
  return;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_module_import_path_copy(module, i, (&((out)[0])), 64));
}
int32_t parser_copy_module_import_path64(struct ast_Module * restrict module, int32_t i, uint8_t out[64]) {
  (void)(parser_get_module_import_path(module, i, out));
  int32_t path_len = 0;
  while (path_len < 64 && (path_len < 0 || (path_len) >= 64 ? (shux_panic_(1, 0), (out)[0]) : (out)[path_len]) != 0) {
    ++path_len;
  }
  return path_len;
}
