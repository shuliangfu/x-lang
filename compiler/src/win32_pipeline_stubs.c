/* win32_pipeline_stubs.c — Windows 下 shux-c 链接桩
 * 提供 .sx 管道/AST/driver 函数的空实现，使 C 前端可链接。
 * 仅在 _WIN32 下编译。 */
#ifdef _WIN32
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

/* AST arena/module 大小 */
size_t pipeline_sizeof_arena(void) { return 4096; }
size_t pipeline_sizeof_module(void) { return 4096; }

/* AST block 访问桩 */
int32_t ast_ast_block_final_expr_ref(void *b) { (void)b; return 0; }
int32_t ast_ast_block_num_consts(void *b) { (void)b; return 0; }
int32_t ast_ast_block_num_if_stmts(void *b) { (void)b; return 0; }
int32_t ast_ast_block_num_lets(void *b) { (void)b; return 0; }
int32_t ast_ast_block_num_regions(void *b) { (void)b; return 0; }
int32_t ast_ast_block_num_stmt_order(void *b) { (void)b; return 0; }

/* pipeline dep ctx */
void ast_pipeline_ctx_append_lib_root(void *ctx, const char *root) { (void)ctx; (void)root; }
void ast_pipeline_dep_ctx_reset(void *ctx) { (void)ctx; }
void ast_pipeline_dep_ctx_set_arena(void *ctx, int idx, void *arena) { (void)ctx; (void)idx; (void)arena; }
void ast_pipeline_dep_ctx_set_import_path(void *ctx, int idx, const uint8_t *path, int len) { (void)ctx; (void)idx; (void)path; (void)len; }
void ast_pipeline_dep_ctx_set_module(void *ctx, int idx, void *mod) { (void)ctx; (void)idx; (void)mod; }
void ast_pipeline_dep_ctx_set_ndep(void *ctx, int ndep) { (void)ctx; (void)ndep; }
int32_t ast_pipeline_dep_ctx_ndep(void *ctx) { (void)ctx; return 0; }
int32_t pipeline_dep_ctx_ndep(void *ctx) { (void)ctx; return 0; }
void pipeline_dep_ctx_import_path_copy64(void *ctx, int idx, uint8_t *dst) { (void)ctx; (void)idx; if(dst) dst[0]=0; }

/* pipeline module 查询 */
int32_t pipeline_module_main_func_index(void *m) { (void)m; return -1; }
void pipeline_module_func_name_byte_at(void *m, int fi, int off, uint8_t *out) { (void)m; (void)fi; (void)off; (void)out; }
void pipeline_module_func_name_copy64(void *m, int fi, uint8_t *dst) { (void)m; (void)fi; if(dst) dst[0]=0; }
int32_t pipeline_module_func_is_extern_at(void *m, int i) { (void)m; (void)i; return 0; }
int32_t pipeline_module_func_body_ref_at(void *m, int i) { (void)m; (void)i; return 0; }
int32_t pipeline_module_func_name_len_at(void *m, int i) { (void)m; (void)i; return 0; }

/* driver */
void driver_print_usage_c(void) {}
int32_t driver_get_module_num_funcs(void *m) { (void)m; return 0; }
int32_t driver_get_module_main_func_index(void *m) { (void)m; return -1; }

/* pipeline 函数 */
int32_t pipeline_run_sx_pipeline(void *m, void *a, void *ctx, const char **lib_roots, int n_lib, const char **defines, int ndef, const char *entry_dir, const char *out_path, int gen_asm, const char *target_triple) {
    (void)m; (void)a; (void)ctx; (void)lib_roots; (void)n_lib; (void)defines; (void)ndef; (void)entry_dir; (void)out_path; (void)gen_asm; (void)target_triple; return -1;
}
int32_t pipeline_typeck_dep_prerun_module_c(void *m, void *a, void *ctx) { (void)m; (void)a; (void)ctx; return 0; }
int32_t pipeline_load_and_sync_direct_import_deps_c(void *m, void *a, void *ctx, const char **lib_roots, int n, const char *entry_dir, const char **defines, int ndef) {
    (void)m; (void)a; (void)ctx; (void)lib_roots; (void)n; (void)entry_dir; (void)defines; (void)ndef; return 0;
}
int32_t pipeline_asm_user_dep_skip_sx_typeck(const uint8_t *path) { (void)path; return 0; }
const char *pipeline_asm_user_std_net_dep_path(void) { return "std.net"; }
int32_t pipeline_codegen_path_is_std_io_driver_bytes(const uint8_t *p, int len) { (void)p; (void)len; return 0; }
void codegen_emit_fmt_json_helpers_once(void) {}
int32_t bootstrap_nostdlib_pthread_is_stub(void) { return 1; }

#endif /* _WIN32 */
