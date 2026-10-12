/* seeds/rt_run_asm_backend.from_x.c — G-02f-315 P2 runtime rest (asm backend)
 * Logic source: src/runtime/rt_run_asm_backend.x
 * Hybrid: XLANG_RT_RUN_ASM_BACKEND_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full（2026-07-14）：公共业务符号 driver_run_asm_backend 由 full .x 提供；
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务符号 H=0）。
 * Cap residual（driver_abi）：FILE/pctx/host/defines/work 槽。
 * 冷启动/无 PREFER 时仍编译完整 C 体。
 *
 * Scope: driver_run_asm_backend（读源 → X pipeline → .o/.s/exe）。
 * run_compiler_parsed 仍 mega rest。
 */
#include <fcntl.h>
#include <limits.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <xlang_fmt_cap.h> /* Cap residual 10.7.2: asm tmp path → Cap snprintf */
/* G.7: Cap after stdio for rt_run_asm_backend cold seed. */
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
#include "runtime_proc_abi.h"
#include "token.h"

/* wave239 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — cold seed residual raw getenv call sites migrate to this face
 * (XLANG_DEBUG_PIPE / XLANG_ASM_DEBUG / XLANG_ASM_ENTRY_ONLY_DEBUG /
 *  XLANG_ASM_SKIP_C_TYPECK_PRECHECK). Header may already declare; explicit for cold TU.
 */
extern char *link_abi_getenv(const char *name);

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
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif


#define X_CODEGEN_OUTBUF_CAP (9 * 1024 * 1024)
struct codegen_CodegenOutBuf {
  unsigned char data[X_CODEGEN_OUTBUF_CAP];
  int32_t length;
};

struct parser_ParseIntoResult {
  int32_t ok;
  int32_t main_idx;
};
struct ASTModule;

extern void driver_bump_stack_limit(void);
extern int driver_argv_collect_defines(int argc, char **argv, const char **defines, int max_defines);
extern void cfg_apply_compile_target_from_triple(const char *triple, int len);
extern void cfg_reset_compile_target(void);
extern char *xlang_preprocess_with_path(const char *data, size_t len, const char *path, const char **defines, int n_defines, size_t *out_len);
extern char *xlang_preprocess(const char *data, size_t len, const char **defines, int n_defines, size_t *out_len);
extern char *xlang_preprocess_quiet(const char *data, size_t len, const char **defines, int n_defines, size_t *out_len);
extern void pipeline_diag_emitted_reset(void);
extern int pipeline_diag_emitted_get(void);
extern void diag_set_file(const char *path, const char *src, size_t len);
extern size_t pipeline_sizeof_arena(void);
extern size_t pipeline_sizeof_module(void);
extern size_t pipeline_sizeof_elf_ctx(void);
extern void parser_parse_into_init(void *arena, void *module);
extern struct parser_ParseIntoResult parser_parse_into_buf(void *arena, void *module, uint8_t *data, int32_t len);
extern void parser_parse_into_set_main_index(void *module, int32_t main_idx);
extern int driver_get_module_num_funcs(void *m);
/* Stage 12.2.4: extern-only module detection for asm backend CG002 false-positive
 * fix. extern-only modules (e.g., pipeline.x — 162 export extern function signatures
 * with ZERO bodies) legitimately produce 0 bytes of code; CG002 must not fire for
 * them. Provided by runtime_pipeline_abi (G.7 single authority).
 * PLATFORM: SHARED. */
extern int pipeline_module_func_is_extern_at(void *module, int fi);
extern int32_t parser_get_module_num_imports(void *module);
extern void xlang_get_entry_dir(const char *path, char *out, size_t out_sz);
extern int driver_deps_are_std_core_closure_only(char **dep_paths, int n_deps);
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
extern void pipeline_asm_seed_std_net_struct_layouts(void *m);
extern int pipeline_asm_user_deps_need_coemit(char **dep_paths, int n_deps);
extern int32_t pipeline_asm_user_dep_is_in_tree_core(uint8_t *path);
extern void pipeline_debug_module_funcs(void *module);
extern void driver_diagnostic_after_entry_parse_module(void *module);
extern int driver_check_diag_emitted_get(void);
extern int32_t driver_get_pending_target_cpu_features(void);
extern int32_t driver_freestanding_get(void);
extern void driver_set_pipeline_entry_source_len(size_t len);
extern void driver_x_pipeline_skip_typeck_set(int v);
extern void driver_x_pipeline_skip_codegen_set(int v);
extern int asm_codegen_elf_o(void *module, void *arena, void *out_buf, void *elf_ctx, void *pctx);
extern int xlang_pipeline_dep_prerun_for_asm_module_o(void *mod, void *arena, const uint8_t *src, size_t len, void *out, void *ctx);
extern int runtime_report_precise_parse_failure_if_known(const char *input_path, const char *src, size_t src_len);
extern int runtime_report_parse_recovery_diagnostics(const char *input_path, const char *src, size_t src_len);
extern void runtime_pipeline_elf_ctx_diag_note(uint8_t *ctx_bytes);
extern void runtime_diag_errno_path(const char *file, const char *kind, const char *op, const char *path);
extern void driver_unlink_failed_output(const char *out_path);

/**
 * -backend asm 专用：读文件、跑 .x pipeline、写 .o 或调 ld。与 run_compiler_c 内 asm 路径逻辑一致，供 driver_run_compiler_full 转调。
 */
#ifndef XLANG_RT_RUN_ASM_BACKEND_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_RT_RUN_ASM_BACKEND_FROM_X removed */
#if defined(__APPLE__) && defined(__aarch64__)
#endif
#if defined(__APPLE__)
#endif
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
#endif
#if defined(XLANG_ASM_USE_COMPILER_IMPL_C)
#endif
#if defined(XLANG_ASM_USE_COMPILER_IMPL_C)
#endif
#else /* XLANG_RT_RUN_ASM_BACKEND_FROM_X：产品 rest 仅 marker；业务体在 full .x */
int driver_run_asm_backend(const char *input_path, const char *out_path, const char **lib_roots_arr, int n_lib_roots,
    const char *target, int argc, char **argv);
#endif /* XLANG_RT_RUN_ASM_BACKEND_FROM_X */

int labi_rt_run_asm_backend_slice_marker(void) {
  return 1;
}
