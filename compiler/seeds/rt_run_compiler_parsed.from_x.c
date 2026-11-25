/* seeds/rt_run_compiler_parsed.from_x.c — G-02f-316 P2 runtime rest (parsed dispatch)
 * Logic source: src/runtime/rt_run_compiler_parsed.x
 * Hybrid: XLANG_RT_RUN_COMPILER_PARSED_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full（2026-07-14）：公共业务符号 driver_run_compiler_parsed 由 full .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务符号 H=0）。
 * Cap residual（driver_abi）：Parsed 字段/FILE+invoke_cc/work 槽。
 * Leftover C frontend generic-syntax lexer/parse + import-downgrade
 * !XLANG_NO_C_FRONTEND blocks retired (this knife).
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 *
 * Scope: driver_run_compiler_parsed（argv 已解析后的 asm/C/pipeline 编排）。
 */
#include <fcntl.h>
#include <limits.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <xlang_fmt_cap.h> /* Cap residual 10.7.2: parsed dispatch path → Cap snprintf */
/* G.7: Cap after stdio for rt_run_compiler_parsed cold seed. */
#undef snprintf
#define snprintf xlang_snprintf
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "diag.h"
#include "runtime_diag_codes.h"
#include "runtime_io_abi.h"
#include "runtime_driver_abi.h"
#include "xlang_driver_stream_cap.h" /* Cap residual 9.7.1: opaque FILE* face → fd-handle face */
#include "runtime_pipeline_abi.h"
#include "runtime_link_abi.h"
/* wave238 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — cold seed twin uses same face as product hybrid pure .x peers. */
extern char *link_abi_getenv(const char *name);
#include "runtime_proc_abi.h"
/* token.h / Lexer retired with leftover C frontend lexer_new/parse (this knife). */

#ifndef XLANG_TMP_PREFIX
#if !defined(_WIN32) && !defined(_WIN64)
#define XLANG_TMP_PREFIX "/tmp/xlang_"
#else
#define XLANG_TMP_PREFIX "xlang_"
#endif
#endif

#ifndef MAX_DEFINES
#define MAX_DEFINES 64
#endif
#ifndef MAX_ALL_DEPS
#define MAX_ALL_DEPS 128
#endif
#ifndef X_FULL_MAX_LIB_ROOTS
#define X_FULL_MAX_LIB_ROOTS 16
#endif
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif

#define X_CODEGEN_OUTBUF_CAP (9 * 1024 * 1024)
struct codegen_CodegenOutBuf {
  int32_t length;
  unsigned char data[X_CODEGEN_OUTBUF_CAP];
};

struct parser_ParseIntoResult {
  int32_t ok;
  int32_t main_idx;
};
struct ASTModule;

typedef struct DriverCompileParsed {
  const char *input_path;
  const char *out_path;
  const char *lib_roots_arr[X_FULL_MAX_LIB_ROOTS];
  int n_lib_roots;
  int want_asm_backend;
  const char *target;
  const char *opt_level;
  int use_lto;
} DriverCompileParsed;

extern void driver_bump_stack_limit(void);
extern int driver_argv_collect_defines(int argc, char **argv, const char **defines, int max_defines);
extern void cfg_apply_compile_target_from_triple(const char *triple, int len);
extern void cfg_reset_compile_target(void);
extern char *xlang_preprocess_with_path(const char *data, size_t len, const char *path, const char **defines, int n_defines, size_t *out_len);
extern char *xlang_preprocess(const char *data, size_t len, const char **defines, int n_defines, size_t *out_len);
extern void pipeline_diag_emitted_reset(void);
extern int pipeline_diag_emitted_get(void);
extern void diag_set_file(const char *path, const char *src, size_t len);
extern size_t pipeline_sizeof_arena(void);
extern size_t pipeline_sizeof_module(void);
extern void parser_parse_into_init(void *arena, void *module);
extern struct parser_ParseIntoResult parser_parse_into_buf(void *arena, void *module, uint8_t *data, int32_t len);
extern void parser_parse_into_set_main_index(void *module, int32_t main_idx);
extern int driver_get_module_num_funcs(void *m);
extern int32_t parser_get_module_num_imports(void *module);
extern void xlang_get_entry_dir(const char *path, char *out, size_t out_sz);
/* wave77: G.7 accessors only — pure owns typeck_dep BSS under hybrid; no naked C globals. */
extern void typeck_ndep_store(int32_t n);
extern void typeck_dep_module_set(int32_t i, void *mod);
extern void typeck_dep_arena_set(int32_t i, void *arena);
extern void driver_dep_seeded_clear_all(void);
extern void driver_dep_seed_slots(void **arenas, void **modules, int n);
extern void driver_dep_publish_slot(int j, void *arena, void *module, const char *path);
extern void pipeline_set_dep_slots(void **arenas, void **modules);
extern void codegen_set_dep_slots_for_x_pipeline(struct ASTModule **mods, const char **paths, int n);
extern void codegen_set_preamble_has_core_option_result(int on);
extern void pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx);
extern int driver_run_asm_backend(const char *input_path, const char *out_path, const char **lib_roots_arr, int n_lib_roots,
                                  const char *target, int argc, char **argv);
extern int runtime_report_precise_parse_failure_if_known(const char *input_path, const char *src, size_t src_len);
extern int runtime_report_parse_recovery_diagnostics(const char *input_path, const char *src, size_t src_len);
extern void driver_unlink_failed_output(const char *out_path);
extern void driver_print_x_smoke_summary(void *module, size_t codegen_len);
extern void driver_print_check_ok(const char *input_path);
extern void driver_diagnostic_after_entry_parse_module(void *module);
extern int driver_check_diag_emitted_get(void);
extern void driver_set_pipeline_entry_source_len(size_t len);
extern void driver_x_pipeline_skip_typeck_set(int v);
extern void driver_x_pipeline_skip_codegen_set(int v);
extern int32_t driver_freestanding_get(void);
extern int32_t parser_diag_token_after_collect_imports(struct xlang_slice_uint8_t *source, void *module);
extern void runtime_diag_errno_path(const char *file, const char *kind, const char *op, const char *path);
extern void runtime_diag_errno_path_pair(const char *file, const char *kind, const char *op, const char *from_path,
                                         const char *to_path);
extern int driver_deps_are_std_core_closure_only(char **dep_paths, int n_deps);
extern void codegen_reset_preamble_skip_mask(void);
extern void codegen_or_preamble_skip_mask(unsigned mask);
#define CODEGEN_PREAMBLE_SKIP_STD_IO_CORE_MACROS    1u
#define CODEGEN_PREAMBLE_SKIP_STD_IO_DRIVER_HANDLE  2u
#define CODEGEN_PREAMBLE_SKIP_STD_IO_UNDEF_REDEFINE 4u
#define CODEGEN_PREAMBLE_SKIP_WEAK_IO_BATCH         8u
/* Cap residual 9.7.1: ABI writers take an opaque fd handle (see
 * xlang_driver_stream_cap.h); the emitted-C stream may be the stdout handle
 * (fd 1) or a temp-file handle. Twin of the seed bodies in
 * runtime/rt_preamble seed and src/runtime.x codegen_emit_include_pipeline_glue_c
 * (authority signature *u8). PLATFORM: SHARED. */
extern int write_io_net_abi_inline(uint8_t *cf);
extern int write_fs_path_map_error_abi_inline(uint8_t *cf);
extern void codegen_emit_include_pipeline_glue_c(uint8_t *out, const char *argv0);
extern const char *xlang_entry_lib_name_from_path(const char *path);
extern void xlang_emit_pipeline_glue_include(void);


/* wave1225: release process-wide AST sidecars before free(arena/module).
 * free alone leaves g_arena_sc / g_module_sc used with dangling keys; the next
 * malloc may reuse the same address and reattach stale GrowVec data. That is
 * why single-file `xlang check file.x` is green while batch/directory check
 * truncates large files (e.g. runtime_pipeline_abi num_funcs 363→111).
 * Safe no-op if pointer never registered or already released.
 * PLATFORM: SHARED — cold mono twin of rt_run_compiler_parsed.x rt_cp_release. */
extern void ast_pool_arena_release(void *a);
extern void ast_pool_module_release(void *m);
static void rt_cp_release_arena_module(void *arena, void *module) {
    if (arena) {
        ast_pool_arena_release(arena);
        free(arena);
    }
    if (module) {
        ast_pool_module_release(module);
        free(module);
    }
}

/**
 * argv 已解析后的编译执行：泛型降级、asm/C 分派、pipeline/cc。
 * 由 driver/compile.x 经 driver_run_compiler_dispatch_c 调用。
 */
#ifndef XLANG_RT_RUN_COMPILER_PARSED_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_RUN_COMPILER_PARSED_FROM_X removed */
#if defined(XLANG_USE_X_DRIVER) && defined(XLANG_USE_X_PIPELINE)
#endif
#else /* XLANG_RT_RUN_COMPILER_PARSED_FROM_X：产品 rest 仅 marker；业务体在 full .x */
int driver_run_compiler_parsed(DriverCompileParsed *p, int argc, char **argv);
#endif /* XLANG_RT_RUN_COMPILER_PARSED_FROM_X */


int labi_rt_run_compiler_parsed_slice_marker(void) {
  return 1;
}
