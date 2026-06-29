/* generated (single-file with deps) */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
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
enum ast_TypeKind { ast_TypeKind_TYPE_I32, ast_TypeKind_TYPE_BOOL, ast_TypeKind_TYPE_U8, ast_TypeKind_TYPE_U32, ast_TypeKind_TYPE_U64, ast_TypeKind_TYPE_I64, ast_TypeKind_TYPE_USIZE, ast_TypeKind_TYPE_ISIZE, ast_TypeKind_TYPE_NAMED, ast_TypeKind_TYPE_PTR, ast_TypeKind_TYPE_ARRAY, ast_TypeKind_TYPE_SLICE, ast_TypeKind_TYPE_LINEAR, ast_TypeKind_TYPE_VECTOR, ast_TypeKind_TYPE_F32, ast_TypeKind_TYPE_F64, ast_TypeKind_TYPE_VOID };
enum ast_ExprKind { ast_ExprKind_EXPR_LIT, ast_ExprKind_EXPR_FLOAT_LIT, ast_ExprKind_EXPR_BOOL_LIT, ast_ExprKind_EXPR_VAR, ast_ExprKind_EXPR_ADD, ast_ExprKind_EXPR_SUB, ast_ExprKind_EXPR_MUL, ast_ExprKind_EXPR_DIV, ast_ExprKind_EXPR_MOD, ast_ExprKind_EXPR_SHL, ast_ExprKind_EXPR_SHR, ast_ExprKind_EXPR_BITAND, ast_ExprKind_EXPR_BITOR, ast_ExprKind_EXPR_BITXOR, ast_ExprKind_EXPR_EQ, ast_ExprKind_EXPR_NE, ast_ExprKind_EXPR_LT, ast_ExprKind_EXPR_LE, ast_ExprKind_EXPR_GT, ast_ExprKind_EXPR_GE, ast_ExprKind_EXPR_LOGAND, ast_ExprKind_EXPR_LOGOR, ast_ExprKind_EXPR_NEG, ast_ExprKind_EXPR_BITNOT, ast_ExprKind_EXPR_LOGNOT, ast_ExprKind_EXPR_IF, ast_ExprKind_EXPR_BLOCK, ast_ExprKind_EXPR_TERNARY, ast_ExprKind_EXPR_ASSIGN, ast_ExprKind_EXPR_ADD_ASSIGN, ast_ExprKind_EXPR_SUB_ASSIGN, ast_ExprKind_EXPR_MUL_ASSIGN, ast_ExprKind_EXPR_DIV_ASSIGN, ast_ExprKind_EXPR_MOD_ASSIGN, ast_ExprKind_EXPR_BITAND_ASSIGN, ast_ExprKind_EXPR_BITOR_ASSIGN, ast_ExprKind_EXPR_BITXOR_ASSIGN, ast_ExprKind_EXPR_SHL_ASSIGN, ast_ExprKind_EXPR_SHR_ASSIGN, ast_ExprKind_EXPR_BREAK, ast_ExprKind_EXPR_CONTINUE, ast_ExprKind_EXPR_RETURN, ast_ExprKind_EXPR_PANIC, ast_ExprKind_EXPR_MATCH, ast_ExprKind_EXPR_FIELD_ACCESS, ast_ExprKind_EXPR_STRUCT_LIT, ast_ExprKind_EXPR_ARRAY_LIT, ast_ExprKind_EXPR_INDEX, ast_ExprKind_EXPR_CALL, ast_ExprKind_EXPR_METHOD_CALL, ast_ExprKind_EXPR_ENUM_VARIANT, ast_ExprKind_EXPR_ADDR_OF, ast_ExprKind_EXPR_DEREF, ast_ExprKind_EXPR_BINOP, ast_ExprKind_EXPR_AS, ast_ExprKind_EXPR_AWAIT, ast_ExprKind_EXPR_RUN, ast_ExprKind_EXPR_SPAWN };
enum ast_ImportKind { ast_ImportKind_IMPORT_WHOLE, ast_ImportKind_IMPORT_BINDING, ast_ImportKind_IMPORT_SELECT };
struct ast_Type { enum ast_TypeKind kind; uint8_t name[64]; int32_t name_len; int32_t elem_type_ref; int32_t array_size; uint8_t region_label[64]; int32_t region_label_len; };
struct ast_Expr { enum ast_ExprKind kind; int32_t resolved_type_ref; int32_t line; int32_t col; int32_t int_val; double float_val; uint8_t var_name[64]; int32_t var_name_len; int32_t binop_left_ref; int32_t binop_right_ref; int32_t unary_operand_ref; int32_t if_cond_ref; int32_t if_then_ref; int32_t if_else_ref; int32_t block_ref; int32_t match_matched_ref; int32_t match_arm_base; int32_t match_num_arms; int32_t field_access_base_ref; uint8_t field_access_field_name[64]; int32_t field_access_field_len; int32_t field_access_is_enum_variant; int32_t field_access_offset; int32_t field_access_soa_stride; int32_t index_base_ref; int32_t index_index_ref; int32_t index_base_is_slice; int32_t call_callee_ref; int32_t call_arg_base; int32_t call_num_args; int32_t call_num_type_args; int32_t method_call_base_ref; uint8_t method_call_name[64]; int32_t method_call_name_len; int32_t method_call_arg_base; int32_t method_call_num_args; int32_t const_folded_val; int32_t const_folded_valid; int32_t index_proven_in_bounds; uint8_t struct_lit_struct_name[64]; int32_t struct_lit_struct_name_len; int32_t struct_lit_field_base; int32_t struct_lit_num_fields; int32_t array_lit_elem_base; int32_t array_lit_num_elems; int32_t float_bits_lo; int32_t float_bits_hi; int32_t enum_variant_tag; int32_t as_operand_ref; int32_t as_target_type_ref; int32_t call_resolved_func_index; int32_t call_resolved_dep_index; };
struct ast_ConstDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_LetDecl { uint8_t name[64]; int32_t name_len; int32_t type_ref; int32_t init_ref; };
struct ast_WhileLoop { int32_t cond_ref; int32_t body_ref; };
struct ast_ForLoop { int32_t init_ref; int32_t cond_ref; int32_t step_ref; int32_t body_ref; };
struct ast_IfStmt { int32_t cond_ref; int32_t then_body_ref; int32_t else_body_ref; };
struct ast_StmtOrderItem { uint8_t kind; int32_t idx; };
struct ast_LabeledStmt { uint8_t label[32]; int32_t label_len; int32_t is_goto; uint8_t goto_target[32]; int32_t goto_target_len; int32_t return_expr_ref; };
struct ast_Block { int32_t const_base; int32_t num_consts; int32_t let_base; int32_t num_lets; int32_t num_early_lets; int32_t loop_base; int32_t num_loops; int32_t for_loop_base; int32_t num_for_loops; int32_t if_base; int32_t num_if_stmts; int32_t region_base; int32_t num_regions; int32_t defer_base; int32_t num_defers; int32_t labeled_base; int32_t num_labeled_stmts; int32_t expr_stmt_base; int32_t num_expr_stmts; int32_t final_expr_ref; int32_t stmt_order_base; int32_t num_stmt_order; int32_t parent_block_ref; };
struct ast_Param { uint8_t name[32]; int32_t name_len; int32_t type_ref; };
struct ast_Func { uint8_t name[64]; int32_t name_len; int32_t param_base; int32_t num_params; int32_t num_generic_params; int32_t return_type_ref; int32_t body_ref; int32_t body_expr_ref; int32_t is_extern; int32_t is_async; };
struct ast_StructLayout { uint8_t name[64]; int32_t name_len; int32_t field_base; int32_t num_fields; int32_t allow_padding; int32_t soa; int32_t packed; int32_t repr_compatible; };
struct ast_Module { int32_t num_funcs; int32_t main_func_index; int32_t num_imports; int32_t num_top_level_lets; int32_t num_struct_layouts; int32_t pending_allow_padding; int32_t pending_soa_struct; int32_t pending_cfg_skip; int32_t pending_repr_c_struct; int32_t pending_repr_compatible_struct; int32_t num_module_enums; };
struct ast_ASTArena { int32_t num_types; int32_t num_exprs; int32_t num_blocks; int32_t num_funcs; };
struct ast_PipelineDepCtx { int32_t ndep; uint8_t entry_dir_buf[512]; int32_t entry_dir_len; int32_t num_lib_roots; uint8_t path_buf[512]; uint8_t loaded_buf[4194304]; ptrdiff_t loaded_len; uint8_t preprocess_buf[4194304]; int32_t preprocess_len; int32_t use_asm_backend; int32_t target_arch; int32_t target_cpu_features; int32_t use_macho_o; int32_t use_coff_o; int32_t current_block_ref; int32_t typeck_loop_depth; int32_t current_func_index; int32_t skip_codegen_dep_0; int32_t entry_already_parsed; int32_t current_func_single_empty_param_index; int32_t current_func_empty_param_count; int32_t current_emit_empty_var_next_index; int32_t emit_expr_as_callee; struct ast_Module * current_codegen_module; struct ast_ASTArena * current_codegen_arena; int32_t current_codegen_dep_index; uint8_t current_codegen_prefix_mirror[64]; int32_t current_codegen_prefix_len; int32_t asm_entry_module_only; uint8_t entry_module_import_path_mirror[64]; int32_t entry_module_import_path_len; int32_t typeck_scope_region_len; uint8_t typeck_scope_region_label[64]; };
struct codegen_CodegenOutBuf { uint8_t data[9437184]; int32_t len; };
/* slim arena grow pool glue (C-04 codegen; linked from pipeline/runtime) */
extern struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
extern void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
extern void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
extern void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);

extern int32_t std_sys_read_file_into(uint8_t * path, uint8_t * buf, int32_t cap);
struct driver_DriverSxEmitState { uint8_t path_buf[512]; int32_t path_len; int32_t emit_extern_imports; int32_t use_asm_backend; int32_t target_arch; uint8_t out_path_buf[512]; int32_t out_path_len; };
extern ptrdiff_t fs_posix_read_c(int32_t fd, uint8_t * buf, size_t count);
extern ptrdiff_t fs_posix_write_c(int32_t fd, uint8_t * buf, size_t count);
extern int32_t fs_posix_close_c(int32_t fd);
extern int32_t preprocess_sx_buf(uint8_t * source_buf, ptrdiff_t source_len, uint8_t * out_buf, int32_t out_cap);
extern int32_t pipeline_dep_ctx_ensure_source_buffers(struct ast_PipelineDepCtx * ctx);
extern void pipeline_dep_ctx_free_source_buffers(struct ast_PipelineDepCtx * ctx);
extern uint8_t * pipeline_dep_ctx_loaded_buf_ptr(struct ast_PipelineDepCtx * ctx);
extern uint8_t * pipeline_dep_ctx_preprocess_buf_ptr(struct ast_PipelineDepCtx * ctx);
extern void pipeline_dep_ctx_set_loaded_len(struct ast_PipelineDepCtx * ctx, ptrdiff_t n);
extern int32_t driver_emit_lib_root_count(uint8_t * state);
extern int32_t driver_emit_lib_root_len(uint8_t * state, int32_t i);
extern void driver_emit_lib_root_copy(uint8_t * state, int32_t i, uint8_t * dst, int32_t cap);
extern int32_t driver_fs_open_read_path(uint8_t * path, int32_t path_len);
extern int32_t driver_fs_open_write(uint8_t * path, int32_t path_len);
extern uint8_t * driver_arena_buf();
extern uint8_t * driver_module_buf();
extern void driver_pipeline_fail_code(int32_t rc, uint8_t * path);
extern void driver_print_sx_smoke_summary(uint8_t * module, size_t codegen_len);
extern int32_t pipeline_run_sx_pipeline_impl(uint8_t * module_buf, uint8_t * arena_buf, uint8_t * source, size_t source_len, struct codegen_CodegenOutBuf * out, struct ast_PipelineDepCtx * ctx);
extern int32_t driver_run_sx_emit_c_set_path(uint8_t * path, int32_t path_len);
extern int32_t driver_run_sx_emit_c_set_lib(int32_t i, uint8_t * buf, int32_t len);
extern int32_t driver_run_sx_emit_c_set_n_lib_roots(int32_t n);
extern int32_t driver_run_sx_emit_c_set_emit_extern(int32_t v);
extern int32_t driver_run_sx_emit_c();
extern int32_t ast_pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx * ctx, uint8_t * path, int32_t len);

/* C-04 -E-extern TU aliases */
#define pipeline_ctx_append_lib_root ast_pipeline_ctx_append_lib_root

uint8_t * driver_emit_state_key(struct driver_DriverSxEmitState * state);
void driver_emit_copy_lib_roots_to_ctx(struct driver_DriverSxEmitState * state, struct ast_PipelineDepCtx * ctx);
struct ast_PipelineDepCtx driver_pipeline_dep_ctx_for_emit(int32_t use_asm, int32_t target);
int32_t driver_run_sx_emit_sx(struct driver_DriverSxEmitState * state);
int32_t driver_dispatch_sx_emit_to_c(struct driver_DriverSxEmitState * state);
uint8_t * driver_emit_state_key(struct driver_DriverSxEmitState * state) {
  return ((uint8_t *)(state));
}
void driver_emit_copy_lib_roots_to_ctx(struct driver_DriverSxEmitState * state, struct ast_PipelineDepCtx * ctx) {
  int32_t k = 0;
  int32_t n = driver_emit_lib_root_count(driver_emit_state_key(state));
  uint8_t tmp[256] = { 0 };
  while (k < n) {
    int32_t llen = driver_emit_lib_root_len(driver_emit_state_key(state), k);
    (void)(({ int32_t __tmp = 0; if (llen > 0) {   (void)(driver_emit_lib_root_copy(driver_emit_state_key(state), k, (&((tmp)[0])), 256));
  (void)(ast_pipeline_ctx_append_lib_root(ctx, (&((tmp)[0])), llen));
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
}
struct ast_PipelineDepCtx driver_pipeline_dep_ctx_for_emit(int32_t use_asm, int32_t target) {
  struct ast_PipelineDepCtx ctx = ({ struct ast_PipelineDepCtx _t = { 0 }; _t.ndep = 0; _t.entry_dir_len = 0; _t.num_lib_roots = 0; _t; });
  ((ctx).use_asm_backend = (use_asm));
  ((ctx).target_arch = (target));
  ((ctx).current_func_index = ((-1)));
  ((ctx).current_func_single_empty_param_index = ((-1)));
  return ctx;
}
int32_t driver_run_sx_emit_sx(struct driver_DriverSxEmitState * state) {
  (void)(({ uint8_t __tmp = 0; if ((state)->path_len >= 0 && (state)->path_len < 511) {   (((state)->path_len < 0 || ((state)->path_len) >= 512 ? (shux_panic_(1, 0), 0) : (((state)->path_buf)[(state)->path_len] = ((uint8_t)(0)), 0)));
 } else (__tmp = 0) ; __tmp; }));
  struct ast_PipelineDepCtx ctx = driver_pipeline_dep_ctx_for_emit((state)->use_asm_backend, (state)->target_arch);
  (void)(({ int32_t __tmp = 0; if (pipeline_dep_ctx_ensure_source_buffers((&(ctx))) != 0) {   return 1;
 } else (__tmp = 0) ; __tmp; }));
  int32_t cap_i = 4194304;
  int32_t n = std_sys_read_file_into((&(((state)->path_buf)[0])), pipeline_dep_ctx_loaded_buf_ptr((&(ctx))), cap_i);
  (void)(({ int32_t __tmp = 0; if (n < 0) {   (void)(pipeline_dep_ctx_free_source_buffers((&(ctx))));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  (void)(pipeline_dep_ctx_set_loaded_len((&(ctx)), ((ptrdiff_t)(n))));
  int32_t out_len = preprocess_sx_buf(pipeline_dep_ctx_loaded_buf_ptr((&(ctx))), n, pipeline_dep_ctx_preprocess_buf_ptr((&(ctx))), 4194304);
  (void)(({ int32_t __tmp = 0; if (out_len < 0) {   (void)(pipeline_dep_ctx_free_source_buffers((&(ctx))));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  ((ctx).preprocess_len = (out_len));
  uint8_t * arena_buf = driver_arena_buf();
  uint8_t * module_buf = driver_module_buf();
  int32_t last_slash = -1;
  int32_t k = 0;
  while (k < (state)->path_len && k < 512) {
    (void)(({ int32_t __tmp = 0; if ((k < 0 || (k) >= 512 ? (shux_panic_(1, 0), ((state)->path_buf)[0]) : ((state)->path_buf)[k]) == 47) {   (last_slash = (k));
 } else (__tmp = 0) ; __tmp; }));
    ++k;
  }
  (void)(({ int32_t __tmp = 0; if (last_slash >= 0) {   (k = (0));
  while (k < last_slash && k < 511) {
    ((k < 0 || (k) >= 512 ? (shux_panic_(1, 0), 0) : (((ctx).entry_dir_buf)[k] = (k < 0 || (k) >= 512 ? (shux_panic_(1, 0), ((state)->path_buf)[0]) : ((state)->path_buf)[k]), 0)));
    ++k;
  }
  ((k < 0 || (k) >= 512 ? (shux_panic_(1, 0), 0) : (((ctx).entry_dir_buf)[k] = 0, 0)));
  ((ctx).entry_dir_len = (k));
 } else {   (((ctx).entry_dir_buf)[0] = (46));
  ((1 < 0 || (1) >= 512 ? (shux_panic_(1, 0), 0) : (((ctx).entry_dir_buf)[1] = 0, 0)));
  ((ctx).entry_dir_len = (1));
 } ; __tmp; }));
  ((ctx).num_lib_roots = (0));
  (void)(driver_emit_copy_lib_roots_to_ctx(state, (&(ctx))));
  struct codegen_CodegenOutBuf out = ({ struct codegen_CodegenOutBuf _t = { 0 }; _t.len = 0; _t; });
  size_t source_len = ((size_t)(out_len));
  int32_t rc = pipeline_run_sx_pipeline_impl(module_buf, arena_buf, pipeline_dep_ctx_preprocess_buf_ptr((&(ctx))), source_len, (&(out)), (&(ctx)));
  (void)(({ int32_t __tmp = 0; if (rc != 0) {   (void)(driver_pipeline_fail_code(rc, (&(((ctx).path_buf)[0]))));
  (void)(pipeline_dep_ctx_free_source_buffers((&(ctx))));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  int32_t len = (out).len;
  (void)(({ int32_t __tmp = 0; if ((state)->out_path_len == 0) {   (void)(driver_print_sx_smoke_summary(module_buf, ((size_t)(len))));
 } else (__tmp = 0) ; __tmp; }));
  (void)(({ int32_t __tmp = 0; if ((state)->out_path_len > 0) {   int32_t wfd = driver_fs_open_write((state)->out_path_buf, (state)->out_path_len);
  (void)(({ int32_t __tmp = 0; if (wfd < 0) {   (void)(pipeline_dep_ctx_free_source_buffers((&(ctx))));
  return 1;
 } else (__tmp = 0) ; __tmp; }));
  __tmp = ({ int32_t __tmp = 0; if (len > 262144) {   ptrdiff_t written = fs_posix_write_c(wfd, (&(((out).data)[0])), 262144);
  (void)(fs_posix_close_c(wfd));
  __tmp = ({ int32_t __tmp = 0; if (written < 0 || ((int32_t)(written)) != 262144) {   (void)(pipeline_dep_ctx_free_source_buffers((&(ctx))));
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } else {   ptrdiff_t written = fs_posix_write_c(wfd, (&(((out).data)[0])), ((size_t)(len)));
  (void)(fs_posix_close_c(wfd));
  __tmp = ({ int32_t __tmp = 0; if (written < 0 || ((int32_t)(written)) != len) {   (void)(pipeline_dep_ctx_free_source_buffers((&(ctx))));
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; });
 } else {   __tmp = ({ int32_t __tmp = 0; if (len > 262144) {   ptrdiff_t written = fs_posix_write_c(1, (&(((out).data)[0])), 262144);
  __tmp = ({ int32_t __tmp = 0; if (written < 0 || ((int32_t)(written)) != 262144) {   (void)(pipeline_dep_ctx_free_source_buffers((&(ctx))));
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } else {   ptrdiff_t written = fs_posix_write_c(1, (&(((out).data)[0])), ((size_t)(len)));
  __tmp = ({ int32_t __tmp = 0; if (written < 0 || ((int32_t)(written)) != len) {   (void)(pipeline_dep_ctx_free_source_buffers((&(ctx))));
  return 1;
 } else (__tmp = 0) ; __tmp; });
 } ; __tmp; });
 } ; __tmp; }));
  (void)(pipeline_dep_ctx_free_source_buffers((&(ctx))));
  return 0;
}
int32_t driver_dispatch_sx_emit_to_c(struct driver_DriverSxEmitState * state) {
  (void)(driver_run_sx_emit_c_set_emit_extern((state)->emit_extern_imports));
  (void)(driver_run_sx_emit_c_set_path((state)->path_buf, (state)->path_len));
  int32_t k = 0;
  int32_t n_roots = driver_emit_lib_root_count(driver_emit_state_key(state));
  uint8_t lib_tmp[256] = { 0 };
  while (k < n_roots) {
    int32_t llen = driver_emit_lib_root_len(driver_emit_state_key(state), k);
    (void)(driver_emit_lib_root_copy(driver_emit_state_key(state), k, (&((lib_tmp)[0])), 256));
    (void)(driver_run_sx_emit_c_set_lib(k, (&((lib_tmp)[0])), llen));
    ++k;
  }
  (void)(driver_run_sx_emit_c_set_n_lib_roots(n_roots));
  return driver_run_sx_emit_c();
}
