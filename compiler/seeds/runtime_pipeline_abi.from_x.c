
/* Generated from src/runtime_pipeline_abi.x (G-02f-32..63/84/85/93/95/223 true .x + C tail).
 * wave45 R2 hybrid (2026-07-21): product PREFER g05_try_x_to_o full .x pure (~115) +
 *   this seed as rest under -DSHUX_RUNTIME_PIPELINE_ABI_FROM_X (no pure-dup public bodies).
 * wave46: pure residual helpers (ptr/size slots, i32_store, module import cstr,
 *   collect_to_load_has, preprocess directive diag) — cold twins under FROM_X.
 * wave47: pure collect seed_to_load + enqueue_module_imports.
 * wave48: pure collect deps_process_one orch; Cap residual tmp_parse_and_enqueue always-seed;
 *   G.7 reuses load_one_direct_import_at for resolve/read/preprocess.
 * wave49: pure collect paths_process_one orch; Cap residual paths_tmp_resolve_parse_enqueue
 *   (resolve/read/preprocess + G.7 tmp_parse_and_enqueue).
 * wave50: pure collect deps/paths transitive_impl orch (stack to_load + process_one loop).
 * wave51: pure load_one_direct_import_at + load_direct_fail_cleanup orch;
 *   Cap residual then pure (wave55) shux_load_one_direct_resolve_read_preprocess;
 *   G.7 paths_tmp reuses same resolve_read (no dual resolve/read/preprocess bodies).
 * wave52: pure collect tmp_parse_and_enqueue orch (malloc/memset ensure + parse + G.7 enqueue).
 * wave53: pure collect paths_tmp_resolve_parse_enqueue orch (ensure tmp + resolve_read
 *   + G.7 pure tmp_parse + free prep).
 * wave54: pure collect strdup thin shell (malloc + scan + byte copy + NUL).
 * wave55: pure resolve_read_preprocess orch (stack resolved + FileView + pure resolve
 *   + runtime_read_file_view + pure preprocess + release + diags).
 * wave56: pure pipeline_run_x thread large-stack _impl orch (PipelineRunSuArgs stack pack;
 *   Cap-fn-ptr pipeline_run_x_thread_fn_ptr always-seed; G.7 driver_run_thread_on_large_stack;
 *   SHUX_DEBUG_PIPE notes cold-only).
 * wave57: pure asm elf_o large-stack _impl orch (AsmElfLargeArgs stack pack;
 *   Cap-fn-ptr shux_asm_codegen_elf_o_thread_fn_ptr always-seed;
 *   Cap residual shux_asm_codegen_elf_o_product_emit always-seed — true emit via external
 *   reloc to strong user_asm_seed_bridge; pure must not call same-TU weak stub
 *   asm_asm_codegen_elf_o which returns -1).
 * wave58: pure dep_prerun_parse_skip_typeck_impl orch (driver check_only + skip typeck/codegen
 *   + G.7 driver_pipeline_dep_ctx_* asm_entry_module_only + pure large_stack; cold twin
 *   under #ifndef FROM_X).
 * wave59: pure dep_prerun_parse_only_impl orch (parser_parse_into_init +
 *   pipeline_parse_set_main_from_buf_c; SHUX_ASM_DEBUG notes cold-only; cold twin
 *   under #ifndef FROM_X).
 * wave60: pure dep_prerun_typeck_only_impl orch (parse_set_main + load_sync deps +
 *   typeck_dep_prerun_module; SHUX_DEBUG_PIPE notes cold-only; cold twin under
 *   #ifndef FROM_X).
 * wave61: pure preprocess_raw_to_malloc_impl orch (scratch + define table + preprocess_x_buf
 *   + owned dup; Cap residual preprocess_* engine; pure diag helpers; oversized reportf
 *   cold-only / pure fail; cold twin under #ifndef FROM_X).
 * wave62: pure one_ctx_for_dep_prerun_map_impl orch (tmp malloc arena/module + parse_into
 *   ok/allow -2 + import map; G.7 pctx_update / find_loaded / import path; cold twin under
 *   #ifndef FROM_X).
 * wave63: pure typeck_module_entry_only / with_sidecar / pipeline_typeck_module_for_ctx_impl
 *   orch (Cap residual typeck_module C frontend + typeck_dep_module_ptrs_base always-seed;
 *   cold twins under #ifndef FROM_X).
 * wave64: pure pipeline_parse_into_bytes orch (G.7 parser_parse_into_init +
 *   driver_parse_into_buf_rc; non-zero ok → -1; cold twin + loaded_import_impl under
 *   #ifndef FROM_X).
 * wave65: pure pipeline_resolve_path_into_static orch (G.7 pure multi resolve +
 *   entry_dir_get (wave68 pure) / Cap residual resolved_path_buf_slot BSS; cold twin under #ifndef FROM_X).
 * wave66: pure pipeline_read_file_stage_prep + pipeline_read_file_commit_prep orch
 *   (G.7 pure preprocess + Cap residual stage BSS / loaded_import_commit_from_owned;
 *   cold twins under #ifndef FROM_X).
 * wave67: pure pipeline_dep_ctx_path_bufs_reset + pipeline_dep_ctx_copy_entry_dir orch
 *   (LP64 offsetof + LE store/byte copy; same layout as driver_abi wave19);
 *   pure pipeline_dep_ctx_set_use_asm_backend thin → G.7 driver_pipeline_dep_ctx_set_use_asm;
 *   cold twins under #ifndef FROM_X).
 * wave68: pure pipeline_entry_dir_copy / set_dot / get orch (pure BSS buf 512 + "." lit +
 *   is_dot; cold twins under #ifndef FROM_X).
 * wave69: pure pipeline_resolved_path_buf_slot (pure BSS buf 512; cold twin under #ifndef FROM_X).
 * wave70: pure pipeline_dep_arena/module_slot_set/at (pure BSS 32×LP64 via G.7 ptr slots;
 *   cold twins + seed static tables under #ifndef FROM_X).
 * wave71: pure pipeline_rf_stage_prep_clear/set/take (pure BSS ptr+size cells via G.7
 *   ptr/size slots; cold twins + seed stage statics under #ifndef FROM_X).
 * wave72: pure pipeline_loaded_import_commit_from_owned / data / len_get (pure BSS
 *   buf+len+cap; ensure floor SHUX_PIPELINE_IMPORT_BUF_CAP; cold twins under #ifndef FROM_X).
 *   Cap residual still: fn-ptr / product_emit / typeck_module C frontend.
 * Root fix wave45: .x docblock must not embed end-comment marker in prose (char star / void star
 *   was written as char star-star-slash void-star and truncated the block → silent AST drop of all
 *   subsequent export function; -E only externs; pure never productized until fix).
 * Cold/fallback without PREFER: full C bodies (no FROM_X). PLATFORM: SHARED.
 * Regen: g05_try_x_to_o src/runtime_pipeline_abi.x (product) / host-cc this file (cold).
 * G-02f pure gates remain under #ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X for cold twins.
 */
#include <shux_weak.h>
#include "win32_compat.h"
#include "runtime_pipeline_abi.h"
#include "runtime_driver_abi.h"
#include "runtime_io_abi.h"
#include "runtime_diag_codes.h"
#include "diag.h"
#include "preprocess.h"

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            macOS/Linux delegate to system <unistd.h> via #include_next.
 *            Historical #ifndef _WIN32 guard removed — shim is a no-op
 *            on POSIX and provides needed declarations on Windows. */
#include <unistd.h>
/** preprocess.x 生成；pipeline/import 与 runtime preprocess() 共用。 */
extern int32_t preprocess_x_buf(const uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf, int32_t out_cap);
extern void preprocess_define_reset(void);
extern int32_t preprocess_if_stack_len(void);
extern void preprocess_define_add(const char *name);







/* G-02f-63 helper protos */
int32_t pipeline_typeck_module_for_ctx_impl(void *module, void *arena, void *ctx_void);
void shu_lsp_free_loaded_imports_impl(void **all_dep_mods, char **all_dep_paths, int n_all);

/* G-02f-62 helper protos */
void pipeline_debug_trace_named_func_bodies_impl(const char *phase, void *module, void *arena);
int shux_merge_direct_then_transitive_deps_impl(void *module, int32_t n_imports, char *cls[], size_t clens[], char *cpaths[],
    int n_closure, char *out_src[], size_t out_lens[], char *out_paths[], int *out_n);
int shux_collect_deps_transitive_impl(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_sources[],
    size_t dep_lens[], char *dep_paths[], int *n_deps);
int shux_collect_dep_paths_transitive_impl(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_paths[], int *n_deps);

/* G-02f-61 / G-02f-240 helper protos */
int32_t shux_asm_codegen_elf_o_large_stack_impl(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf);
int32_t shux_asm_codegen_elf_o_large_stack(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf);
int shux_load_direct_imports_for_asm_layout_impl(void *module, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int *out_n);
int shux_merge_direct_then_transitive_dep_paths_impl(void *module, int32_t n_imports, char *cpaths[], int n_closure,
    char *out_paths[], int *out_n);

/* G-02f-60 helper protos */
void pipeline_set_entry_dir(const char *path);
void pipeline_set_dep_slots(void *arenas[32], void *modules[32]);
void shux_pipeline_fill_ctx_path_buffers_impl(struct ast_PipelineDepCtx *ctx, const char *entry_dir,
    const char **lib_roots, int n_lib_roots);
void shux_pipeline_pctx_seed_dep_slots_impl(struct ast_PipelineDepCtx *ctx, void **dep_mods, void **dep_ar,
    char **import_paths, int n);
void shux_pipeline_pctx_seed_dep_import_paths_only_impl(struct ast_PipelineDepCtx *ctx, char **import_paths, int n);
void shux_pipeline_one_ctx_for_dep_prerun_impl(struct ast_PipelineDepCtx *ctx, int j, void **dep_mods,
                                          void **dep_ars, char **dep_paths, int ndep, const uint8_t *dep_src,
                                          size_t dep_src_len);

/* G-02f-59 helper protos */
int shux_pipeline_dep_prerun_typeck_only_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len, void *dep_out,
    void *one_ctx);
void shux_resolve_import_file_path_multi_impl(const char **lib_roots, int n_lib_roots, const char *entry_dir,
    const char *import_path, char *path, size_t path_size);

/* G-02f-58 helper protos */
int shux_pipeline_dep_prerun_parse_skip_typeck_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
    void *dep_out, void *one_ctx);
int shux_pipeline_dep_prerun_parse_only_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len);

/* G-02f-57 / G-02f-239 helper protos */
int shux_pipeline_run_x_pipeline_large_stack_impl(void *module, void *arena, const uint8_t *source_data, size_t source_len,
    void *out_buf, void *ctx);
int shux_pipeline_run_x_pipeline_large_stack(void *module, void *arena, const uint8_t *source_data, size_t source_len,
    void *out_buf, void *ctx);

/* G-02f-56 helper protos */
int32_t pipeline_resolve_path_impl(const uint8_t *path_ptr, int32_t path_len);
int32_t pipeline_read_file(void);
int32_t pipeline_parse_into_loaded_import_impl(void *arena, void *module);

/* G-02f-33 forward slots (defs near storage) */
int shux_cstr_ends_with_dot_x(const char *s);
int shux_asm_out_buf_is_object_magic(const unsigned char *data);
int32_t *pipeline_diag_emitted_flag_slot(void);
int32_t *typeck_ndep_slot(void);
void typeck_ndep_store(int32_t n);

/* G-02f-222 thin+rest：thin 函数前向声明（rest 模式下 REST 函数调用 thin 时可见） */
int pipeline_debug_body_func_match(const char *filter, const char *name);
void pipeline_diag_preprocess_alloc_fail(const char *path_diag, const char *what);
void pipeline_diag_preprocess_unclosed_if(const char *path_diag);
void pipeline_diag_preprocess_fail(const char *path_diag);
void pipeline_diag_preprocess_directive_code(const char *path_diag, int32_t code);
void pipeline_diag_import_preprocess_fail(const char *import_path, const char *resolved_path);
void shux_pipeline_pctx_update_dep_slots_no_reset(struct ast_PipelineDepCtx *ctx, void **dep_mods,
                                                        void **dep_ar, char **import_paths, int n);
void *pipeline_run_x_thread_fn(void *arg);
int pipeline_asm_debug_enabled(void);
void pipeline_diag_merge_dep_missing(const char *import_path);
void *shux_asm_codegen_elf_o_thread_fn(void *arg);

/* wave46–57: pure-migrated helpers live in .x under FROM_X; residual rest still calls them.
 * PLATFORM: SHARED — prototypes only when cold twin bodies are #ifndef'd out. */
#ifdef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int32_t shux_module_num_imports(void *module);
void shux_module_import_path_cstr(void *module, int32_t idx, uint8_t *buf, int32_t cap);
void shux_ptr_slot_set(void **arr, int32_t i, void *p);
void *shux_ptr_slot_get(void **arr, int32_t i);
void shux_i32_store(int32_t *p, int32_t v);
size_t shux_size_slot_get(size_t *arr, int32_t i);
void shux_size_slot_set(size_t *arr, int32_t i, size_t v);
int shux_collect_to_load_has(char *to_load[], int to_load_n, const char *path);
/* wave54 pure strdup thin shell — pure orch / cold twins call this under hybrid. */
char *shux_collect_strdup(const char *s);
/* wave55 pure resolve_read orch — pure load_one / paths_tmp call under hybrid. */
int shux_load_one_direct_resolve_read_preprocess(const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir, const char *import_key, const char **defines, int ndefines, char **out_prep,
    size_t *out_prep_len);
/* wave56 pure pipeline large-stack _impl — thin pure wrappers call under hybrid. */
void *pipeline_run_x_thread_fn_impl(void *arg);
int shux_pipeline_run_x_pipeline_large_stack_impl(void *module, void *arena, const uint8_t *source_data,
    size_t source_len, void *out_buf, void *ctx);
/* wave57 pure asm elf_o large-stack _impl — thin pure wrappers call under hybrid. */
void *shux_asm_codegen_elf_o_thread_fn_impl(void *arg);
int32_t shux_asm_codegen_elf_o_large_stack_impl(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf);
/* wave58 pure dep_prerun_parse_skip_typeck_impl — thin pure gate calls under hybrid. */
int shux_pipeline_dep_prerun_parse_skip_typeck_impl(void *dep_mod, void *dep_arena, const uint8_t *src,
    size_t len, void *dep_out, void *one_ctx);
/* wave59 pure dep_prerun_parse_only_impl — thin pure gate calls under hybrid. */
int shux_pipeline_dep_prerun_parse_only_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len);
/* wave60 pure dep_prerun_typeck_only_impl — thin pure gate calls under hybrid. */
int shux_pipeline_dep_prerun_typeck_only_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
    void *dep_out, void *one_ctx);
/* wave61 pure preprocess_raw_to_malloc_impl — thin pure gate + load_one paths call under hybrid. */
int shux_preprocess_raw_to_malloc_impl(const unsigned char *raw, size_t raw_len, char **out_src,
    size_t *out_src_len, const char *path_diag, const char **defines, int ndefines, int emit_diag);
/* wave62 pure one_ctx map_impl — thin pure one_ctx_for_dep_prerun + seed _impl call under hybrid. */
void shux_pipeline_one_ctx_for_dep_prerun_map_impl(struct ast_PipelineDepCtx *ctx, void **dep_mods,
    void **dep_ars, char **dep_paths, int ndep, const uint8_t *dep_src, size_t dep_src_len);
/* wave63 pure typeck entry/sidecar/for_ctx_impl — thin pure gates call under hybrid. */
int32_t typeck_module_entry_only(void *module);
int32_t typeck_module_with_sidecar(void *module);
int32_t pipeline_typeck_module_for_ctx_impl(void *module, void *arena, void *ctx_void);
/* wave64 pure pipeline_parse_into_bytes — pure loaded_import + tmp_parse call under hybrid. */
int32_t pipeline_parse_into_bytes(void *arena, void *module, uint8_t *data, size_t len);
/* wave65 pure pipeline_resolve_path_into_static — pure resolve_path calls under hybrid. */
void pipeline_resolve_path_into_static(const char *path_c);
/* wave71 pure stage prep BSS — pure stage_prep / commit_prep call under hybrid. */
void pipeline_rf_stage_prep_clear(void);
void pipeline_rf_stage_prep_set(char *prep, size_t prep_len);
int32_t pipeline_rf_stage_prep_take(char **out_prep, size_t *out_len);
/* wave72 pure loaded_import BSS — pure commit_prep / parse_into_loaded_import under hybrid. */
int32_t pipeline_loaded_import_commit_from_owned(char *prep, size_t prep_len);
uint8_t *pipeline_loaded_import_data(void);
size_t pipeline_loaded_import_len_get(void);
/* wave67 pure path buf helpers + use_asm thin — pure fill_ctx / one_ctx call under hybrid. */
void pipeline_dep_ctx_path_bufs_reset(struct ast_PipelineDepCtx *ctx);
void pipeline_dep_ctx_copy_entry_dir(struct ast_PipelineDepCtx *ctx, const char *entry_dir);
void pipeline_dep_ctx_set_use_asm_backend(struct ast_PipelineDepCtx *ctx, int32_t v);
/* wave47 pure collect queue helpers. */
int shux_collect_seed_to_load(void *module, char *to_load[], int *to_load_n);
void shux_collect_enqueue_module_imports(void *tmp_module, char *to_load[], int *to_load_n,
    char *dep_paths[], int n_loaded);
/* wave52 pure tmp_parse orch — pure paths_tmp + pure process_one call it. */
void shux_collect_tmp_parse_and_enqueue(void **tmp_arena, void **tmp_module, size_t arena_sz, size_t module_sz,
    char *prep, size_t prep_len, const char *debug_path, char *to_load[], int *to_load_n, char *dep_paths[],
    int n_loaded);
/* wave53 pure paths_tmp orch — pure paths_process_one calls it. */
int shux_collect_paths_tmp_resolve_parse_enqueue(char *path_c, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir_buf, const char **defines, int ndefines, void **tmp_arena, void **tmp_module,
    size_t arena_sz, size_t module_sz, char *to_load[], int *to_load_n, char *dep_paths[], int n_loaded);
/* wave48 pure process_one orch — pure transitive_impl + Cap residual may call. */
int shux_collect_deps_process_one(char *path_c, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir_buf, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int *n, char *to_load[], int *to_load_n, void **tmp_arena, void **tmp_module,
    size_t arena_sz, size_t module_sz);
/* wave49 pure paths_process_one orch — pure paths transitive_impl calls it. */
int shux_collect_paths_process_one(char *path_c, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir_buf, const char **defines, int ndefines, char *dep_paths[], int *n, char *to_load[],
    int *to_load_n, void **tmp_arena, void **tmp_module, size_t arena_sz, size_t module_sz);
/* wave50 pure transitive_impl orch — thin pure wrappers still call these. */
int shux_collect_deps_transitive_impl(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_sources[],
    size_t dep_lens[], char *dep_paths[], int *n_deps);
int shux_collect_dep_paths_transitive_impl(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_paths[], int *n_deps);
/* wave51 pure load_one orch + fail_cleanup — cold layout_impl / pure process_one call these. */
int shux_load_one_direct_import_at(const char **lib_roots_arr, int n_lib_roots, const char *entry_dir,
    const char *import_key, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int32_t mi);
void shux_load_direct_fail_cleanup(char *dep_sources[], char *dep_paths[], int32_t mi);
/* pipeline_diag_preprocess_directive_code already declared above */
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

static int pipeline_diag_emitted_flag;

/* G-02f-33: storage slot for .x pipeline_diag_emitted_* */
int32_t *pipeline_diag_emitted_flag_slot(void) {
    return (int32_t *)&pipeline_diag_emitted_flag;
}
static int pipeline_last_import_open_valid;
static char pipeline_last_import_open_import[65];
static char pipeline_last_import_open_resolved[PATH_MAX];

#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_emitted_reset(void) {
  (void)(({   {
    int32_t * p = pipeline_diag_emitted_flag_slot();
    (void)(((p)[0] = 0));
  }
 }));
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_emitted_note(void) {
  (void)(({   {
    int32_t * p = pipeline_diag_emitted_flag_slot();
    (void)(((p)[0] = 1));
  }
 }));
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int32_t pipeline_diag_emitted_get(void) {
  (void)(({   {
    int32_t * p = pipeline_diag_emitted_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */

/* G-02f-227：逻辑源 .x（真迁）；seed 保留 printf 细文案 + 去重表 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_import_open_fail_once(const char *import_path, const char *resolved_path) {
    const char *import_key = import_path ? import_path : "?";
    const char *resolved_key = resolved_path ? resolved_path : "?";
    if (pipeline_last_import_open_valid &&
        strcmp(pipeline_last_import_open_import, import_key) == 0 &&
        strcmp(pipeline_last_import_open_resolved, resolved_key) == 0) {
        pipeline_diag_emitted_note();
        return;
    }
    snprintf(pipeline_last_import_open_import, sizeof(pipeline_last_import_open_import), "%s", import_key);
    snprintf(pipeline_last_import_open_resolved, sizeof(pipeline_last_import_open_resolved), "%s", resolved_key);
    pipeline_last_import_open_valid = 1;
    pipeline_diag_emitted_note();
    diag_reportf_with_code(resolved_path, 0, 0, "import error", SHUX_DIAG_CODE_IMPORT_IMP001, NULL,
                 "cannot open import '%s' (tried %s)",
                 import_key,
                 resolved_key);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/* G-02f-225：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc（含 printf 细文案） */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_preprocess_unclosed_if(const char *path_diag) {
    pipeline_diag_emitted_note();
    diag_report_with_code(path_diag, 0, 0, "preprocess error", SHUX_DIAG_CODE_PREPROCESS_PP001, "unclosed #if", NULL);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-225：逻辑源 .x（真迁）；seed 保留 printf 细文案 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_preprocess_fail(const char *path_diag) {
    pipeline_diag_emitted_note();
    diag_reportf_with_code(path_diag, 0, 0, "preprocess error", SHUX_DIAG_CODE_PREPROCESS_PP002, NULL,
                 ".x preprocess failed for '%s'",
                 path_diag ? path_diag : "?");
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave46 Cap residual pure: directive code map in .x; cold twin below. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
/* 指令级失败码（preprocess_x_buf 负返回值）→ 历史 C 文案。 */
void pipeline_diag_preprocess_directive_code(const char *path_diag, int32_t code) {
    const char *msg = NULL;
    if (code == -2)
        msg = "#else without #if";
    else if (code == -3)
        msg = "#endif without #if";
    else if (code == -4)
        msg = "#elseif without #if";
    else if (code == -5)
        msg = "#elseif after #else";
    else if (code == -6)
        msg = "duplicate #else";
    else if (code == -7)
        msg = "#if nesting too deep";
    else {
        pipeline_diag_preprocess_fail(path_diag);
        return;
    }
    pipeline_diag_emitted_note();
    diag_report_with_code(path_diag, 0, 0, "preprocess error", SHUX_DIAG_CODE_PREPROCESS_PP002, msg, NULL);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-225：逻辑源 .x（真迁）；seed 保留 printf 细文案 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_import_preprocess_fail(const char *import_path, const char *resolved_path) {
    pipeline_diag_emitted_note();
    diag_reportf_with_code(resolved_path, 0, 0, "preprocess error", SHUX_DIAG_CODE_IMPORT_IMP002, NULL,
                 "preprocess failed for import '%s' (%s)",
                 import_path ? import_path : "?",
                 resolved_path ? resolved_path : "?");
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-225：逻辑源 .x（真迁）；seed 保留 printf 细文案 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_preprocess_alloc_fail(const char *path_diag, const char *what) {
    pipeline_diag_emitted_note();
    diag_reportf_with_code(path_diag, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP005, NULL,
                 "%s allocation failed during .x preprocess",
                 what ? what : "buffer");
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-225：逻辑源 .x（真迁）；seed 保留 printf 细文案 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_merge_dep_missing(const char *import_path) {
    pipeline_diag_emitted_note();
    diag_reportf_with_code(import_path, 0, 0, "import error", SHUX_DIAG_CODE_IMPORT_IMP004, NULL,
                 "direct import '%s' was not found in the resolved dependency closure",
                 import_path ? import_path : "?");
    diag_report(NULL, 0, 0, "note",
                "dependency closure construction failed before merge_deps completed", NULL);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/* G-02f-116：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int pipeline_asm_debug_enabled(void) {
  return getenv("SHUX_ASM_DEBUG") != NULL;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */



extern int32_t pipeline_module_num_funcs(void *module);
extern int32_t pipeline_module_func_name_len_at(void *module, int32_t fi);
extern void pipeline_module_func_name_copy64(void *module, int32_t fi, uint8_t *dst);
extern int32_t pipeline_module_func_body_ref_at(void *module, int32_t fi);
extern int32_t ast_ast_block_num_consts(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_lets(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_if_stmts(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_regions(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_num_stmt_order(void *arena, int32_t block_ref);
extern int32_t ast_ast_block_final_expr_ref(void *arena, int32_t block_ref);
/* G-02f-118：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int pipeline_debug_body_func_match(const char *filter, const char *name) {
    const char *p;
    size_t name_len;
    if (!filter || !filter[0] || filter[0] == '0' || !name || !name[0])
        return 0;
    name_len = strlen(name);
    p = filter;
    while (*p) {
        const char *start;
        const char *end;
        size_t tok_len;
        while (*p == ' ' || *p == '\t' || *p == ',')
            p++;
        if (!*p)
            break;
        start = p;
        while (*p && *p != ',')
            p++;
        end = p;
        while (end > start && (end[-1] == ' ' || end[-1] == '\t'))
            end--;
        tok_len = (size_t)(end - start);
        if (tok_len > 0 && tok_len == name_len && strncmp(start, name, tok_len) == 0)
            return 1;
    }
    return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */




void pipeline_debug_trace_named_func_bodies_impl(const char *phase, void *module, void *arena) {
    const char *filter = getenv("SHUX_DEBUG_BODY_FUNC");
    int32_t nf;
    int32_t fi;
    if (!filter || !filter[0] || filter[0] == '0' || !module || !arena)
        return;
    nf = pipeline_module_num_funcs(module);
    for (fi = 0; fi < nf; fi++) {
        uint8_t raw_name[64];
        char name[65];
        int32_t name_len;
        int32_t body_ref;
        memset(raw_name, 0, sizeof(raw_name));
        memset(name, 0, sizeof(name));
        name_len = pipeline_module_func_name_len_at(module, fi);
        if (name_len <= 0 || name_len > 64)
            continue;
        pipeline_module_func_name_copy64(module, fi, raw_name);
        memcpy(name, raw_name, (size_t)name_len);
        name[name_len] = '\0';
        if (!pipeline_debug_body_func_match(filter, name))
            continue;
        body_ref = pipeline_module_func_body_ref_at(module, fi);
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "body trace: phase=%s fi=%d body_ref=%d name=%s block(c=%d l=%d if=%d reg=%d so=%d fin=%d)",
                     phase ? phase : "?", (int)fi, (int)body_ref, name,
                     body_ref > 0 ? (int)ast_ast_block_num_consts(arena, body_ref) : -1,
                     body_ref > 0 ? (int)ast_ast_block_num_lets(arena, body_ref) : -1,
                     body_ref > 0 ? (int)ast_ast_block_num_if_stmts(arena, body_ref) : -1,
                     body_ref > 0 ? (int)ast_ast_block_num_regions(arena, body_ref) : -1,
                     body_ref > 0 ? (int)ast_ast_block_num_stmt_order(arena, body_ref) : -1,
                     body_ref > 0 ? (int)ast_ast_block_final_expr_ref(arena, body_ref) : -1);
    }
}

#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_named_func_bodies(const char *phase, void *module, void *arena) {
  if (module == NULL) {
    return;
  }
  if (arena == NULL) {
    return;
  }
  {
    pipeline_debug_trace_named_func_bodies_impl(phase, module, arena);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_body_x_mega_pre_reset(void *module, void *arena) {
  {
    pipeline_debug_trace_named_func_bodies("x_mega_pre_reset", module, arena);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_body_x_mega_post_reset(void *module, void *arena) {
  {
    pipeline_debug_trace_named_func_bodies("x_mega_post_reset", module, arena);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_body_x_mega_post_params(void *module, void *arena) {
  {
    pipeline_debug_trace_named_func_bodies("x_mega_post_params", module, arena);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_body_x_mega_post_frame(void *module, void *arena) {
  {
    pipeline_debug_trace_named_func_bodies("x_mega_post_frame", module, arena);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_body_x_mega_post_locals(void *module, void *arena) {
  {
    pipeline_debug_trace_named_func_bodies("x_mega_post_locals", module, arena);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_body_x_mega_pre_emit(void *module, void *arena) {
  {
    pipeline_debug_trace_named_func_bodies("x_mega_pre_emit", module, arena);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-240 / wave61：hybrid pure owns _impl; cold twin under #ifndef FROM_X.
 * Pure orch: scratch + define table + preprocess_x_buf + owned dup; Cap residual
 * preprocess_* engine; pure pipeline_diag_preprocess_* (oversized reportf cold-only).
 * PLATFORM: SHARED. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_preprocess_raw_to_malloc_impl(const unsigned char *raw, size_t raw_len, char **out_src,
    size_t *out_src_len, const char *path_diag, const char **defines, int ndefines, int emit_diag) {
    int di;
    if (out_src)
        *out_src = NULL;
    if (out_src_len)
        *out_src_len = 0;
    if (raw_len > (size_t)SHUX_PIPELINE_CTX_BUF_SIZE) {
        if (emit_diag) {
            diag_reportf_with_code(path_diag, 0, 0, "preprocess error", SHUX_DIAG_CODE_PREPROCESS_PP002, NULL,
                         "entry file too large for .x preprocessor (%zu > %d): '%s'",
                         raw_len,
                         SHUX_PIPELINE_CTX_BUF_SIZE,
                         path_diag ? path_diag : "?");
        }
        return -1;
    }
    uint8_t *scratch = (uint8_t *)malloc((size_t)SHUX_PIPELINE_CTX_BUF_SIZE);
    if (!scratch) {
        if (emit_diag)
            pipeline_diag_preprocess_alloc_fail(path_diag, "scratch buffer");
        return -1;
    }
    preprocess_define_reset();
    for (di = 0; di < ndefines; di++)
        if (defines && defines[di])
            preprocess_define_add(defines[di]);
    int32_t n = preprocess_x_buf(raw, (ptrdiff_t)raw_len, scratch, (int32_t)SHUX_PIPELINE_CTX_BUF_SIZE);
    if (n < 0) {
        free(scratch);
        if (emit_diag) {
            /* 指令级负码（-2..-7）优先于「栈非空」：duplicate #else 等失败时栈上仍有 #if。 */
            if (n <= -2)
                pipeline_diag_preprocess_directive_code(path_diag, n);
            else if (preprocess_if_stack_len() != 0)
                pipeline_diag_preprocess_unclosed_if(path_diag);
            else
                pipeline_diag_preprocess_fail(path_diag);
        }
        return -1;
    }
    if (preprocess_if_stack_len() != 0) {
        free(scratch);
        if (emit_diag)
            pipeline_diag_preprocess_unclosed_if(path_diag);
        return -1;
    }
    char *dup = (char *)malloc((size_t)n + 1);
    if (!dup) {
        free(scratch);
        if (emit_diag)
            pipeline_diag_preprocess_alloc_fail(path_diag, "output buffer");
        return -1;
    }
    memcpy(dup, scratch, (size_t)n);
    dup[n] = '\0';
    free(scratch);
    if (out_src)
        *out_src = dup;
    if (out_src_len)
        *out_src_len = (size_t)n;
    return 0;
}

/* G-02f-240：逻辑源 .x（边界 pure）；seed 保留同语义 C 供产品 cc */
int shux_preprocess_raw_to_malloc(const unsigned char *raw, size_t raw_len, char **out_src, size_t *out_src_len,
    const char *path_diag, const char **defines, int ndefines) {
  if (raw == NULL && raw_len > 0)
    return -1;
  if (ndefines < 0)
    return -1;
  {
    return shux_preprocess_raw_to_malloc_impl(raw, raw_len, out_src, out_src_len, path_diag, defines, ndefines, 1);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */



/** typeck/pipeline 兼容 dep 侧车（pipeline_gen.c get_dep_* / pipeline_set_dep）。 */
void *typeck_dep_module_ptrs[32];
void *typeck_dep_arena_ptrs[32];
int typeck_ndep;

/* G-02f-33: storage slot for .x get_ndep */
int32_t *typeck_ndep_slot(void) {
    return (int32_t *)&typeck_ndep;
}
/* wave45 Cap residual always-seed: BSS write for pure typeck_ndep_store orch.
 * Pure owns clamp; this stores the final value. PLATFORM: SHARED. */
void typeck_ndep_store_impl(int32_t n) {
    typeck_ndep = n;
}
/* G-02f-223：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void typeck_ndep_store(int32_t n) {
    typeck_ndep_store_impl((n <= 32) ? ((n < 0) ? 0 : n) : 32);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */




/* G-02f-40: opaque dep pointer get/set slots for .x API */
void *typeck_dep_module_get(int32_t i) {
    if (i < 0 || i >= 32)
        return NULL;
    return typeck_dep_module_ptrs[i];
}

void *typeck_dep_arena_get(int32_t i) {
    if (i < 0 || i >= 32)
        return NULL;
    return typeck_dep_arena_ptrs[i];
}

/* wave63 Cap residual always-seed: base of typeck_dep_module_ptrs for pure with_sidecar.
 * Pure cannot take address of this seed BSS array; typeck_module wants void**.
 * PLATFORM: SHARED — LP64 void* table base ABI. */
void *typeck_dep_module_ptrs_base(void) {
    return (void *)typeck_dep_module_ptrs;
}
/* wave45 Cap residual always-seed: BSS write for pure typeck_dep_*_set orch.
 * Pure owns bounds; residual writes typeck_dep_*_ptrs. PLATFORM: SHARED. */
void typeck_dep_module_set_impl(int32_t i, void *mod) {
    if (i < 0 || i >= 32)
        return;
    typeck_dep_module_ptrs[i] = mod;
}
void typeck_dep_arena_set_impl(int32_t i, void *arena) {
    if (i < 0 || i >= 32)
        return;
    typeck_dep_arena_ptrs[i] = arena;
}
/* G-02f-223：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void typeck_dep_module_set(int32_t i, void *mod) {
    typeck_dep_module_set_impl(i, mod);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-223：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void typeck_dep_arena_set(int32_t i, void *arena) {
    typeck_dep_arena_set_impl(i, arena);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */





/**
 * 清 typeck dep 侧车；driver_dep_seeded_clear_all 调用，避免悬空指针。
 */
/* G-02f-225：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void driver_typeck_dep_sidecar_clear(void) {
    int i;
    typeck_ndep = 0;
    for (i = 0; i < 32; i++) {
        typeck_dep_arena_ptrs[i] = NULL;
        typeck_dep_module_ptrs[i] = NULL;
    }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */



/** 按 dep 下标取 module 指针；越界返回 NULL。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void *get_dep_module(int32_t i) {
  if ((i < 0)) {
    return ((void *)(0));
  }
  (void)(({   {
    int32_t n = get_ndep();
    if ((i >=n)) {
      return ((void *)(0));
    }
    void * r = typeck_dep_module_get(i);
    return r;
  }
 }));
  return ((void *)(0));
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** 按 dep 下标取 arena 指针；越界返回 NULL。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void *get_dep_arena(int32_t i) {
  if ((i < 0)) {
    return ((void *)(0));
  }
  (void)(({   {
    int32_t n = get_ndep();
    if ((i >=n)) {
      return ((void *)(0));
    }
    void * r = typeck_dep_arena_get(i);
    return r;
  }
 }));
  return ((void *)(0));
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** 当前 dep 数量。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int32_t get_ndep(void) {
  (void)(({   {
    int32_t * p = typeck_ndep_slot();
    int32_t r = (p)[0];
    return r;
  }
 }));
  return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** pipeline_gen.c 别名：与 get_dep_module 相同。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void *typeck_get_dep_module(int32_t i) {
  return get_dep_module(i);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** pipeline_gen.c 别名：与 get_dep_arena 相同。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void *typeck_get_dep_arena(int32_t i) {
  return get_dep_arena(i);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** 写入单 dep 槽（pipeline.x 编排 import 加载时调用）。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_set_dep(int32_t i, void *mod, void *arena) {
  if ((i < 0)) {
    return;
  }
  if ((i >=32)) {
    return;
  }
  (void)(({   {
    (void)(typeck_dep_module_set(i, mod));
    (void)(typeck_dep_arena_set(i, arena));
  }
 }));
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** 设置 dep 数量上限 32。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_set_ndep(int32_t n) {
  (void)(({   {
    (void)(typeck_ndep_store(n));
  }
 }));
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 对原始 .x 做 preprocess.x 条件编译扫描，写入新分配缓冲 NUL 结尾字符串。
 * 参数：path_diag 用于错误信息；defines/ndefines 注入 -D 宏。
 * 返回值：0 成功；否则写 stderr、不分配 *out_src。
 */


/**
 * 将逻辑 import 路径转为 lib_root 下的 .x 文件路径（'.' → '/'）。
 * 参数：见 runtime_pipeline_abi.h。
 * 副作用：写入 path，保证 NUL 结尾（path_size>0 时）。
 */
/* G-02f-229：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void shux_import_path_to_file_path_impl(const char *lib_root, const char *import_path, char *path, size_t path_size) {
    const char *r = lib_root && lib_root[0] ? lib_root : ".";
    size_t off = (size_t)snprintf(path, path_size, "%s/", r);
    for (const char *s = import_path ? import_path : ""; *s && off + 1 < path_size; s++) {
        if (*s == '.')
            path[off++] = '/';
        else
            path[off++] = *s;
    }
    if (off + 4 <= path_size)
        snprintf(path + off, path_size - off, ".x");
}

/* G-02f-229：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_import_path_to_file_path(const char *lib_root, const char *import_path, char *path, size_t path_size) {
  if (path == NULL) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  {
    shux_import_path_to_file_path_impl(lib_root, import_path, path, path_size);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 从入口 .x 路径得到所在目录；无目录时写入 "."。
 * 参数：见 runtime_pipeline_abi.h。
 */
/* G-02f-229：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void shux_get_entry_dir_impl(const char *input_path, char *entry_dir, size_t size) {
    const char *last = strrchr(input_path, '/');
    if (!last) {
        (void)snprintf(entry_dir, size, ".");
        return;
    }
    size_t len = (size_t)(last - input_path);
    if (len >= size)
        len = size - 1;
    memcpy(entry_dir, input_path, len);
    entry_dir[len] = '\0';
}

/* G-02f-229：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_get_entry_dir(const char *input_path, char *entry_dir, size_t size) {
  if (entry_dir == NULL) {
    return;
  }
  if (size == 0) {
    return;
  }
  if (input_path == NULL) {
    entry_dir[0] = '\0';
    return;
  }
  {
    shux_get_entry_dir_impl(input_path, entry_dir, size);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 判断 import 是否为文件路径（相对/绝对/.x），而非逻辑模块名 std.io。
 * 返回值：非 0 表示文件路径形式。
 */

/* G-02f-63：真逻辑来自 .x（逐字节扫 / 魔数比较；无 _impl）。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_cstr_ends_with_dot_x(const char *s) {
    size_t n;
    if (s == NULL) {
        return 0;
    }
    n = 0;
    while (s[n] != 0) {
        n = n + 1;
    }
    if (n < 2) {
        return 0;
    }
    if (s[n - 2] != '.') {
        return 0;
    }
    if (s[n - 1] != 'x') {
        return 0;
    }
    return 1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_asm_out_buf_is_object_magic(const unsigned char *data) {
    unsigned char b0;
    unsigned char b1;
    unsigned char b2;
    unsigned char b3;
    if (data == NULL) {
        return 0;
    }
    b0 = data[0];
    b1 = data[1];
    b2 = data[2];
    b3 = data[3];
    /* MH_MAGIC_64 LE */
    if (b0 == 0xcf) {
        if (b1 == 0xfa) {
            if (b2 == 0xed) {
                if (b3 == 0xfe) {
                    return 1;
                }
            }
        }
    }
    /* MH_CIGAM_64 */
    if (b0 == 0xfe) {
        if (b1 == 0xed) {
            if (b2 == 0xfa) {
                if (b3 == 0xcf) {
                    return 1;
                }
            }
        }
    }
    /* ELF */
    if (b0 == 0x7f) {
        if (b1 == 'E') {
            if (b2 == 'L') {
                if (b3 == 'F') {
                    return 1;
                }
            }
        }
    }
    return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_import_path_is_file_path(const char *import_path) {
  if (import_path == NULL) {
    return 0;
  }
  {
    if (import_path[0] == 0) {
      return 0;
    }
    if (import_path[0] == '/') {
      return 1;
    }
    if (import_path[0] == '.') {
      return 1;
    }
    if (strchr(import_path, '/') != NULL) {
      return 1;
    }
    if (shux_cstr_ends_with_dot_x(import_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 将相对/绝对文件路径解析为可打开的 .x 路径（相对 entry_dir）。
 * 参数：见 runtime_pipeline_abi.h。
 */
/* G-02f-231：realpath 🔒（.x join 后调用；失败则保留原 path） */
void shux_path_try_realpath_inplace(char *path, size_t path_size) {
    if (!path || path_size == 0)
        return;
#if defined(_POSIX_VERSION) || defined(__APPLE__)
    {
        char resolved[1024];
        if (realpath(path, resolved) != NULL)
            (void)snprintf(path, path_size, "%s", resolved);
    }
#else
    (void)path_size;
#endif
}

/* G-02f-231：逻辑源 .x（join pure）；seed 保留同语义 C 供产品 cc */
void shux_resolve_file_import_path_impl(const char *entry_dir, const char *import_path, char *path, size_t path_size) {
    char tmp[1024];
    if (import_path[0] == '/') {
        (void)snprintf(tmp, sizeof(tmp), "%s", import_path);
    } else if (entry_dir && entry_dir[0]) {
        (void)snprintf(tmp, sizeof(tmp), "%s/%s", entry_dir, import_path);
    } else {
        (void)snprintf(tmp, sizeof(tmp), "%s", import_path);
    }
    (void)snprintf(path, path_size, "%s", tmp);
    shux_path_try_realpath_inplace(path, path_size);
}

/* G-02f-231：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_resolve_file_import_path(const char *entry_dir, const char *import_path, char *path, size_t path_size) {
  if (path == NULL) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  if (import_path == NULL) {
    path[0] = '\0';
    return;
  }
  {
    shux_resolve_file_import_path_impl(entry_dir, import_path, path, path_size);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-232：s + off（.x 无可靠指针算术时用） */
const char *shux_cstr_offset(const char *s, int32_t off) {
    if (!s)
        return NULL;
    if (off < 0)
        return s;
    return s + off;
}

/**
 * 在 lib_roots 与 entry_dir 下解析 import 到可读 .x 路径。
 * 参数：见 runtime_pipeline_abi.h；未找到时 path 仍写入最后一次尝试路径。
 */
/* G-02f-232：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void shux_resolve_import_file_path_multi_impl(const char **lib_roots, int n_lib_roots, const char *entry_dir,
    const char *import_path, char *path, size_t path_size) {
    if (shux_import_path_is_file_path(import_path)) {
        shux_resolve_file_import_path(entry_dir, import_path, path, path_size);
        if (access(path, R_OK) == 0)
            return;
        if (import_path[0] != '/') {
            (void)snprintf(path, path_size, "%s", import_path);
            if (access(path, R_OK) == 0)
                return;
        }
    }
    for (int r = 0; r < n_lib_roots; r++) {
        const char *lib_root = lib_roots[r] && lib_roots[r][0] ? lib_roots[r] : ".";
        shux_import_path_to_file_path(lib_root, import_path, path, path_size);
        if (access(path, R_OK) == 0)
            return;
        /* 单段 import（如 preprocess）：再试 lib_root/import/import.x */
        if (strchr(import_path, '.') == NULL && path_size >= 16) {
            int n = (int)strlen(import_path);
            if (n > 0 && n < 64) {
                (void)snprintf(path, path_size, "%s/%.64s/%.64s.x", lib_root, import_path, import_path);
                if (access(path, R_OK) == 0)
                    return;
            }
        }
        if (strchr(import_path, '.') != NULL && path_size >= 16) {
            size_t off = (size_t)snprintf(path, path_size, "%s/", lib_root);
            for (const char *s = import_path; *s && off + 1 < path_size; s++)
                path[off++] = (char)(*s == '.' ? '/' : *s);
            if (off + 9 <= path_size)
                (void)snprintf(path + off, path_size - off, "/mod.x");
            if (access(path, R_OK) == 0)
                return;
            shux_import_path_to_file_path(lib_root, import_path, path, path_size);
            if (access(path, R_OK) == 0)
                return;
        }
    }
    /* 入口同目录的单段 fallback */
    if (entry_dir && entry_dir[0] && strchr(import_path, '.') == NULL) {
        (void)snprintf(path, path_size, "%s/%.255s.x", entry_dir, import_path);
        if (access(path, R_OK) == 0)
            return;
    }
    /* 带点 import 在 dep 所在目录查找；首段与 entry_dir 末段同名时跳过去重前缀 */
    if (entry_dir && entry_dir[0] && strchr(import_path, '.') != NULL && path_size >= 16) {
        const char *eff = import_path;
        const char *last_slash = strrchr(entry_dir, '/');
        const char *dir_tail = last_slash ? last_slash + 1 : entry_dir;
        size_t tail_len = strlen(dir_tail);
        const char *first_dot = strchr(import_path, '.');
        if (first_dot && (size_t)(first_dot - import_path) == tail_len &&
            strncmp(import_path, dir_tail, tail_len) == 0) {
            eff = first_dot + 1;
        }
        size_t off = (size_t)snprintf(path, path_size, "%s/", entry_dir);
        for (const char *s = eff; *s && off + 1 < path_size; s++)
            path[off++] = (char)(*s == '.' ? '/' : *s);
        if (off + 5 <= path_size)
            snprintf(path + off, path_size - off, ".x");
        if (access(path, R_OK) == 0)
            return;
        if (off + (size_t)8 <= path_size)
            (void)snprintf(path + off, path_size - off, "/mod.x");
        if (access(path, R_OK) == 0)
            return;
    }
}

/* G-02f-232：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_resolve_import_file_path_multi(const char **lib_roots, int n_lib_roots, const char *entry_dir,
    const char *import_path, char *path, size_t path_size) {
  if (path == NULL) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  if (import_path == NULL) {
    path[0] = '\0';
    return;
  }
  {
    shux_resolve_import_file_path_multi_impl(lib_roots, n_lib_roots, entry_dir, import_path, path, path_size);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** pipeline dep 全局槽：arena/module 指针、import 路径注册表、seeded 标记。 */
static void *driver_dep_arena_ptrs[SHUX_DRIVER_DEP_SLOT_MAX];
static void *driver_dep_module_ptrs[SHUX_DRIVER_DEP_SLOT_MAX];
static const char *driver_dep_path_registry[SHUX_DRIVER_DEP_SLOT_MAX];
static int driver_dep_seeded[SHUX_DRIVER_DEP_SLOT_MAX];

/* G-02f-34: per-slot storage for .x dep_seeded get/set */
int32_t *driver_dep_seeded_slot(int32_t i) {
    if (i < 0)
        i = 0;
    if (i >= SHUX_DRIVER_DEP_SLOT_MAX)
        i = SHUX_DRIVER_DEP_SLOT_MAX - 1;
    return (int32_t *)&driver_dep_seeded[i];
}

/* G-02f-224：path registry 读槽（供 .x scan 真迁） */
const char *driver_dep_path_registry_at(int32_t i) {
    if (i < 0 || i >= SHUX_DRIVER_DEP_SLOT_MAX)
        return NULL;
    return driver_dep_path_registry[i];
}

extern size_t pipeline_sizeof_arena(void);
extern size_t pipeline_sizeof_module(void);

/**
 * 查询 dep 槽 i 是否已由 C 侧预填（pipeline 不再 read/parse）。
 * 参数：i 槽下标 0..31。
 * 返回值：1 已 seeded，0 否或 i 越界。
 */

/* G-02f-42: driver dep pointer/path slots for .x publish_slot */
/* wave45 Cap residual always-seed: BSS write for pure driver_dep_*_ptr_set orch.
 * Pure owns bounds; residual writes driver_dep_*_ptrs. PLATFORM: SHARED. */
void driver_dep_arena_ptr_set_impl(int32_t i, void *arena) {
    if (i < 0 || i >= SHUX_DRIVER_DEP_SLOT_MAX)
        return;
    driver_dep_arena_ptrs[i] = arena;
}
void driver_dep_module_ptr_set_impl(int32_t i, void *module) {
    if (i < 0 || i >= SHUX_DRIVER_DEP_SLOT_MAX)
        return;
    driver_dep_module_ptrs[i] = module;
}
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_arena_ptr_set(int32_t i, void *arena) {
    driver_dep_arena_ptr_set_impl(i, arena);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */


#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_module_ptr_set(int32_t i, void *module) {
    driver_dep_module_ptr_set_impl(i, module);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */




/* G-02f-224：逻辑源 .x（真迁边界）；seed 保留同语义 C 供产品 cc */
void driver_dep_path_registry_set(int32_t i, const char *path) {
    if (i < 0 || i >= SHUX_DRIVER_DEP_SLOT_MAX)
        return;
    if (!path)
        return;
    driver_dep_path_registry[i] = path;
}

#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int32_t driver_dep_seeded_get(int32_t i) {
  if ((i < 0)) {
    return 0;
  }
  if ((i >=32)) {
    return 0;
  }
  (void)(({   {
    int32_t * p = driver_dep_seeded_slot(i);
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
 }));
  return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 设置 dep 槽 seeded 标志（run_compiler_x_path 预填后调用）。
 * 参数：i 槽下标；v 非 0 表示 seeded。
 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_seeded_set(int32_t i, int32_t v) {
  if ((i < 0)) {
    return;
  }
  if ((i >=32)) {
    return;
  }
  (void)(({   {
    int32_t * p = driver_dep_seeded_slot(i);
    (void)(((p)[0] = v));
  }
 }));
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 批量预填 dep 槽指针并标记 seeded；entry pipeline 复用不重载。
 * 参数：arenas/modules 各 32 槽；n 有效 dep 数。
 */
/* G-02f-224：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_seed_slots(void *arenas[32], void *modules[32], int32_t n) {
    int j;
    for (j = 0; j < SHUX_DRIVER_DEP_SLOT_MAX && j < n; j++) {
        driver_dep_arena_ptrs[j] = arenas ? arenas[j] : NULL;
        driver_dep_module_ptrs[j] = modules ? modules[j] : NULL;
        driver_dep_seeded[j] = 1;
    }
    for (; j < SHUX_DRIVER_DEP_SLOT_MAX; j++)
        driver_dep_seeded[j] = 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */



/**
 * 单槽发布：dep 预跑 parse 完成后供 pipeline_load 按 import 路径绑定。
 * 参数：import_path 逻辑路径指针须存活至 clear_all（通常 dep_paths[j]）。
 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_publish_slot(int32_t i, void *arena, void *module, const char *import_path) {
  if ((i < 0)) {
    return;
  }
  if ((i >=32)) {
    return;
  }
  (void)(({   {
    (void)(driver_dep_arena_ptr_set(i, arena));
    (void)(driver_dep_module_ptr_set(i, module));
    (void)(driver_dep_seeded_set(i, 1));
    (void)(driver_dep_path_registry_set(i, import_path));
  }
 }));
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 按 import 逻辑路径查 dep 预跑全局槽。
 * 返回值：槽下标 0..31，未 publish 返回 -1。
 */
/* G-02f-224：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int32_t driver_dep_slot_for_path_scan(const char *path) {
    int i;
    for (i = 0; i < SHUX_DRIVER_DEP_SLOT_MAX; i++) {
        if (driver_dep_path_registry[i] && strcmp(driver_dep_path_registry[i], path) == 0)
            return i;
    }
    return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-224：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int32_t driver_dep_slot_for_path(const char *path) {
  if (path == NULL) {
    return -1;
  }
  {
    return driver_dep_slot_for_path_scan(path);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * entry pipeline 返回后清除 seeded 与槽指针；并同步清 runtime.c typeck dep 侧车。
 */
/* G-02f-230：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void driver_dep_seeded_clear_slots_impl(void) {
    int i;
    for (i = 0; i < SHUX_DRIVER_DEP_SLOT_MAX; i++) {
        driver_dep_seeded[i] = 0;
        driver_dep_path_registry[i] = NULL;
        driver_dep_arena_ptrs[i] = NULL;
        driver_dep_module_ptrs[i] = NULL;
    }
}

/* G-02f-230：逻辑源 .x（真迁）；产品门闩可走 impl 或与 .x 同语义循环 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_seeded_clear_slots(void) {
    driver_dep_seeded_clear_slots_impl();
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-230：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_seeded_clear_all(void) {
  {
    driver_dep_seeded_clear_slots_impl();
    driver_typeck_dep_sidecar_clear();
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 获取 dep i 的 arena 缓冲；首访 malloc+清零，seeded 槽复用预填指针。
 * 返回值：arena 字节区或 NULL（i 越界 / OOM）。
 */
uint8_t *driver_dep_arena_buf(int32_t i) {
    if (i < 0 || i >= SHUX_DRIVER_DEP_SLOT_MAX)
        return NULL;
    if (driver_dep_arena_ptrs[i] == NULL) {
        size_t sz = pipeline_sizeof_arena();
        driver_dep_arena_ptrs[i] = malloc(sz);
        if (!driver_dep_arena_ptrs[i])
            return NULL;
        memset(driver_dep_arena_ptrs[i], 0, sz);
    }
    return (uint8_t *)driver_dep_arena_ptrs[i];
}

/**
 * 获取 dep i 的 module 缓冲；首访 malloc+清零，seeded 槽复用预填指针。
 * 返回值：module 字节区或 NULL。
 */
uint8_t *driver_dep_module_buf(int32_t i) {
    if (i < 0 || i >= SHUX_DRIVER_DEP_SLOT_MAX)
        return NULL;
    if (driver_dep_module_ptrs[i] == NULL) {
        size_t sz = pipeline_sizeof_module();
        driver_dep_module_ptrs[i] = malloc(sz);
        if (!driver_dep_module_ptrs[i])
            return NULL;
        memset(driver_dep_module_ptrs[i], 0, sz);
    }
    return (uint8_t *)driver_dep_module_ptrs[i];
}

/** typeck.x 导出名：转发 driver_dep_module_buf。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
uint8_t *typeck_driver_dep_module_buf(int32_t i) {
  (void)(({   {
    uint8_t * r = driver_dep_module_buf(i);
    return r;
  }
 }));
  return ((void *)(0));
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
uint8_t *typeck_driver_dep_arena_buf(int32_t i) {
  (void)(({   {
    uint8_t * r = driver_dep_arena_buf(i);
    return r;
  }
 }));
  return ((void *)(0));
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** typeck.x 导出名：转发 driver_dep_seeded_get。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int32_t typeck_driver_dep_seeded_get(int32_t i) {
  return driver_dep_seeded_get(i);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 在已加载 import 列表中查找下标。
 * 参数：import_path 逻辑路径；all_paths/n_all 已加载列表。
 * 返回值：下标或 -1。
 */




/* G-02f-54 helper protos */
int shux_preprocess_raw_to_malloc_impl(const unsigned char *raw, size_t raw_len, char **out_src,
    size_t *out_src_len, const char *path_diag, const char **defines, int ndefines, int emit_diag);
void driver_dep_seed_slots_impl(void *arenas[32], void *modules[32], int32_t n);
const char *shux_entry_lib_name_from_path_impl(const char *input_path);
const char *shux_cstr_typeck_lit(void);

/* G-02f-53 helper protos */
void shux_import_path_to_file_path_impl(const char *lib_root, const char *import_path, char *path, size_t path_size);
void shux_resolve_file_import_path_impl(const char *entry_dir, const char *import_path, char *path, size_t path_size);
int32_t driver_dep_slot_for_path_scan(const char *path);

/* G-02f-52 helper protos */
void driver_typeck_dep_sidecar_clear_impl(void);
void driver_dep_seeded_clear_slots_impl(void);
void shux_get_entry_dir_impl(const char *input_path, char *entry_dir, size_t size);
void driver_asm_fclose_asm_out_impl(FILE *fp);

/* G-02f-51 helper protos (defs later near dep_prerun) */
const char *shux_dep_prerun_entry_dir_pick(const char *main_entry_dir, const char **lib_roots, int n_lib_roots);
int shux_find_loaded_import_index_scan(const char *import_path, char **all_paths, int n_all);
int shux_merge_deps_path_already_out_scan(const char *path, char *out_paths[], int n_out);
void shux_emit_pipeline_glue_include_impl(void);
int shux_import_dep_dir_from_path_impl(const char *path, char *dep_dir, size_t dep_dir_size);

#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_find_loaded_import_index(const char *import_path, char **all_paths, int n_all) {
  if (import_path == NULL) {
    return -1;
  }
  if (all_paths == NULL) {
    return -1;
  }
  if (n_all <= 0) {
    return -1;
  }
  {
    return shux_find_loaded_import_index_scan(import_path, all_paths, n_all);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * dep 预跑 resolve import 时用 lib root（-L）优先于主文件 entry_dir。
 * 参数：main_entry_dir 入口目录；lib_roots/n_lib_roots 与 -L 一致。
 * 返回值：优先 lib_roots[0] 或 main_entry_dir。
 */

/* G-02f-223：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
const char *shux_dep_prerun_entry_dir_pick(const char *main_entry_dir, const char **lib_roots, int n_lib_roots) {
    if (lib_roots && n_lib_roots > 0 && lib_roots[0] && lib_roots[0][0])
        return lib_roots[0];
    return main_entry_dir;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-134：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_find_loaded_import_index_scan(const char *import_path, char **all_paths, int n_all) {
    int i;
    for (i = 0; i < n_all; i++) {
        if (all_paths[i] && strcmp(all_paths[i], import_path) == 0)
            return i;
    }
    return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/* G-02f-134：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_merge_deps_path_already_out_scan(const char *path, char *out_paths[], int n_out) {
    int j;
    for (j = 0; j < n_out; j++) {
        if (out_paths[j] && strcmp(out_paths[j], path) == 0)
            return 1;
    }
    return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */
/* G-02f-234：fputs 到 stdout（.x emit_glue pure） */
void shux_fputs_stdout(const char *s) {
    if (s)
        fputs(s, stdout);
}

/* G-02f-234：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_emit_pipeline_glue_include(void) {
    fputs("\n#include \"pipeline_glue.c\"\n", stdout);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


int shux_import_dep_dir_from_path_impl(const char *path, char *dep_dir, size_t dep_dir_size) {
    const char *slash;
    if (!path || !dep_dir || dep_dir_size == 0)
        return -1;
    slash = strrchr(path, '/');
    if (slash) {
        size_t dlen = (size_t)(slash - path);
        if (dlen >= dep_dir_size)
            return -1;
        memcpy(dep_dir, path, dlen);
        dep_dir[dlen] = '\0';
    } else {
        if (dep_dir_size < 2)
            return -1;
        snprintf(dep_dir, dep_dir_size, ".");
    }
    return 0;
}
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
const char *shux_dep_prerun_entry_dir(const char *main_entry_dir, const char **lib_roots, int n_lib_roots) {
  {
    if (n_lib_roots <= 0) {
      return main_entry_dir;
    }
    return shux_dep_prerun_entry_dir_pick(main_entry_dir, lib_roots, n_lib_roots);
  }
  return main_entry_dir;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 从入口文件路径推导 -E 时库模块的 C 前缀。
 * 参数：input_path 入口 .x 路径。
 * 返回值：静态字符串字面量前缀名。
 */
const char *shux_entry_lib_name_from_path_impl(const char *input_path) {
    static char stem_buf[128];
    const char *base;
    const char *dot;
    size_t stem_len;

    if (!input_path)
        return "typeck";
    if (strstr(input_path, "main") != NULL)
        return "main";
    if (strstr(input_path, "build") != NULL)
        return "build";
    if (strstr(input_path, "pipeline") != NULL)
        return "pipeline";
    if (strstr(input_path, "driver") != NULL)
        return "driver";
    if (strstr(input_path, "codegen") != NULL)
        return "codegen";
    if (strstr(input_path, "typeck") != NULL)
        return "typeck";
    if (strstr(input_path, "parser") != NULL)
        return "parser";
    if (strstr(input_path, "token") != NULL)
        return "token";
    if (strstr(input_path, "lexer") != NULL)
        return "lexer";
    if (strstr(input_path, "ast") != NULL)
        return "ast";
    /* std/xxx/mod.x → lib_prefix std_xxx；std/xxx/yyy.x → std_xxx_yyy。
     * 【Why 根源】codegen 用 import path 生成符号前缀：import("std.heap.libc") →
     * std_heap_libc_（codegen_import_path_to_c_prefix_into）。-E-extern 编译 libc.x 时
     * lib_prefix 须与之一致，否则 mod.x 引用 std_heap_libc_heap_alloc_c 而 libc.o 提供
     * std_heap_heap_alloc_c，符号不匹配。规则：提取 std/ 后所有路径段用 _ 连接，跳过末尾
     * mod（mod.x 的 import path 不含 mod）。此修复使 .o 直接提供正确符号，C 桩可删，F 闭合。
     * 【Invariant】仅影响路径含 "std/" 段的输入；compiler/ 等其他路径不受影响。
     * 【Asm/Perf】编译期决议，无运行期开销。 */
    {
        const char *std_seg = NULL;
        for (const char *s = input_path; *s; s++) {
            if ((s == input_path || s[-1] == '/' || s[-1] == '\\')
                && strncmp(s, "std/", 4) == 0) {
                std_seg = s + 4;
                break;
            }
        }
        if (std_seg) {
            /* 收集所有路径段，用 _ 连接，跳过末尾 mod（去 .x/.su 后缀） */
            size_t off = 4;  /* "std_" 前缀 */
            memcpy(stem_buf, "std_", 4);
            const char *p = std_seg;
            while (*p && off + 2 < sizeof(stem_buf)) {
                const char *seg_start = p;
                while (*p && *p != '/' && *p != '\\') p++;
                size_t seg_len = (size_t)(p - seg_start);
                /* 去 .x/.su 后缀 */
                if (seg_len >= 3 && memcmp(seg_start + seg_len - 3, ".su", 3) == 0)
                    seg_len -= 3;
                else if (seg_len >= 2 && memcmp(seg_start + seg_len - 2, ".x", 2) == 0)
                    seg_len -= 2;
                /* 跳过 "mod" 段（mod.x 的 import path 不含 mod） */
                if (seg_len == 3 && memcmp(seg_start, "mod", 3) == 0) {
                    /* mod 段跳过；但需记录以处理后续段 */
                } else if (seg_len > 0) {
                    if (off > 4 && off + seg_len + 1 < sizeof(stem_buf)) {
                        stem_buf[off++] = '_';
                    }
                    if (off + seg_len < sizeof(stem_buf)) {
                        memcpy(stem_buf + off, seg_start, seg_len);
                        off += seg_len;
                    }
                }
                if (*p) p++;  /* 跳过 / */
            }
            if (off > 4) {
                stem_buf[off] = '\0';
                return stem_buf;
            }
        }
    }
    /* core/xxx/mod.x → lib_prefix core_xxx；core/xxx/yyy.x → core_xxx_yyy。
     * 【Why 根源】与 std/ 对称：codegen 用 import path 生成符号前缀
     * （import("core.mem") → core_mem_）。-E-extern 编译 core/mem/mod.x 时
     * lib_prefix 须为 core_mem，否则函数被 emit 为裸符号（placeholder），
     * 而调用端期望 core_mem_placeholder，链接报 undefined reference。
     * 此修复使 core/*.o 提供正确前缀符号，on-demand linking
     * （link_abi_user_o_needs_core_mem）才能匹配。
     * 【Invariant】仅影响路径含 "core/" 段的输入；其他路径不受影响。
     * 【Asm/Perf】编译期决议，无运行期开销。 */
    {
        const char *core_seg = NULL;
        for (const char *s = input_path; *s; s++) {
            if ((s == input_path || s[-1] == '/' || s[-1] == '\\')
                && strncmp(s, "core/", 5) == 0) {
                core_seg = s + 5;
                break;
            }
        }
        if (core_seg) {
            size_t off = 5;  /* "core_" 前缀 */
            memcpy(stem_buf, "core_", 5);
            const char *p = core_seg;
            while (*p && off + 2 < sizeof(stem_buf)) {
                const char *seg_start = p;
                while (*p && *p != '/' && *p != '\\') p++;
                size_t seg_len = (size_t)(p - seg_start);
                if (seg_len >= 3 && memcmp(seg_start + seg_len - 3, ".su", 3) == 0)
                    seg_len -= 3;
                else if (seg_len >= 2 && memcmp(seg_start + seg_len - 2, ".x", 2) == 0)
                    seg_len -= 2;
                if (seg_len == 3 && memcmp(seg_start, "mod", 3) == 0) {
                    /* mod 段跳过 */
                } else if (seg_len > 0) {
                    if (off > 5 && off + seg_len + 1 < sizeof(stem_buf)) {
                        stem_buf[off++] = '_';
                    }
                    if (off + seg_len < sizeof(stem_buf)) {
                        memcpy(stem_buf + off, seg_start, seg_len);
                        off += seg_len;
                    }
                }
                if (*p) p++;
            }
            if (off > 5) {
                stem_buf[off] = '\0';
                return stem_buf;
            }
        }
    }
    /* std/json/json.x 等：basename 去 .x/.su 作为库前缀（json_ → json_*_c 符号）。 */
    base = strrchr(input_path, '/');
    if (!base)
        base = strrchr(input_path, '\\');
    base = base ? base + 1 : input_path;
    dot = strrchr(base, '.');
    if (dot && dot > base && (strcmp(dot, ".x") == 0 || strcmp(dot, ".su") == 0)) {
        stem_len = (size_t)(dot - base);
        if (stem_len > 0 && stem_len < sizeof(stem_buf)) {
            memcpy(stem_buf, base, stem_len);
            stem_buf[stem_len] = '\0';
            return stem_buf;
        }
    }
    return "typeck";
}

const char *shux_cstr_typeck_lit(void) {
    return "typeck";
}

/* G-02f-226：entry_lib 关键字字面量（0=main..9=ast；其它 typeck） */
const char *shux_entry_lib_keyword_lit(int32_t k) {
    if (k == 0) return "main";
    if (k == 1) return "build";
    if (k == 2) return "pipeline";
    if (k == 3) return "driver";
    if (k == 4) return "codegen";
    if (k == 5) return "typeck";
    if (k == 6) return "parser";
    if (k == 7) return "token";
    if (k == 8) return "lexer";
    if (k == 9) return "ast";
    return "typeck";
}

/* G-02f-226：逻辑源 .x（真迁关键词路径；std/ 仍走 impl） */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
const char *shux_entry_lib_name_from_path(const char *input_path) {
  if (input_path == NULL) {
    return shux_cstr_typeck_lit();
  }
  {
    return shux_entry_lib_name_from_path_impl(input_path);
  }
  return NULL;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** -E 且入口为 pipeline.x 时输出 pipeline_glue.c include 行。 */


/**
 * asm 后端写出 FILE *：stdout 仅 fflush，避免 fclose(stdout)。
 * 参数：fp 汇编输出流，可为 NULL。
 */
/* G-02f-234：stdout 判定 / fflush / fclose helpers */
int driver_asm_fp_is_stdout(FILE *fp) {
    return fp == stdout ? 1 : 0;
}

/* 产品链与 runtime_driver_abi 同链；driver_abi 为权威定义。弱化避免 Darwin ld 双 T。 */
SHUX_WEAK void driver_asm_fflush_stdout(void) {
    fflush(stdout);
}

void driver_asm_fclose_file(FILE *fp) {
    if (fp)
        fclose(fp);
}

/* G-02f-234：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void driver_asm_fclose_asm_out(FILE *fp) {
    if (!fp || fp == stdout)
        fflush(stdout);
    else
        fclose(fp);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */



/**
 * 判断缓冲前缀是否为 Mach-O/ELF 对象魔数（asm_codegen_elf_o 产出检测）。
 * 参数：data/len 为 codegen out_buf 内容。
 * 返回值：非 0 表示已是对象文件字节。
 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_asm_out_buf_is_object(const unsigned char *data, size_t len) {
  if (data == NULL) {
    return 0;
  }
  if (len < 4) {
    return 0;
  }
  {
    return shux_asm_out_buf_is_object_magic(data);
  }
  return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** ast.x pipeline_dep_ctx_* 与 lib_root sidecar（由 ast_pool.c 提供）。 */
extern void ast_pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx);
extern int32_t ast_pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path, int32_t len);
extern void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m);
extern void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a);
extern void ast_pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n);
extern void ast_pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes, int32_t len);

/** pipeline.x asm 用户 dep 路径判定（符号由 pipeline_gen.c / pipeline_x.o 提供）。 */
extern int32_t pipeline_asm_user_dep_skip_x_typeck(uint8_t *path);
extern int32_t pipeline_asm_user_std_net_dep_path(uint8_t *path);
extern int32_t pipeline_codegen_path_is_std_io_driver_bytes(uint8_t *path);

/**
 * 填充 ctx 的 entry_dir_buf、lib_root sidecar，供 .x 内 resolve_path_x 使用。
 * 参数：ctx 非 NULL；entry_dir 入口目录；lib_roots/n_lib_roots 与 -L 一致。
 */
/* G-02f-230 / wave67：hybrid pure owns path_bufs_reset; cold twin under #ifndef FROM_X.
 * Pure orch: LP64 offsetof + LE store (loaded_len i64 + three i32 cells). PLATFORM: SHARED LP64. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_dep_ctx_path_bufs_reset(struct ast_PipelineDepCtx *ctx) {
    if (!ctx)
        return;
    ctx->loaded_len = 0;
    ctx->preprocess_len = 0;
    ctx->entry_dir_len = 0;
    ctx->num_lib_roots = 0;
}

/* G-02f-230 / wave67：hybrid pure owns copy_entry_dir; cold twin under #ifndef FROM_X.
 * Pure orch: byte copy into entry_dir_buf + LE store entry_dir_len. PLATFORM: SHARED LP64. */
void pipeline_dep_ctx_copy_entry_dir(struct ast_PipelineDepCtx *ctx, const char *entry_dir) {
    size_t el;
    if (!ctx || !entry_dir)
        return;
    el = strlen(entry_dir);
    if (el >= 512)
        el = 511;
    memcpy(ctx->entry_dir_buf, entry_dir, el);
    ctx->entry_dir_buf[el] = '\0';
    ctx->entry_dir_len = (int32_t)el;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-230：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void shux_pipeline_fill_ctx_path_buffers_impl(struct ast_PipelineDepCtx *ctx, const char *entry_dir,
    const char **lib_roots, int n_lib_roots) {
    if (!ctx)
        return;
    pipeline_dep_ctx_path_bufs_reset(ctx);
    if (entry_dir)
        pipeline_dep_ctx_copy_entry_dir(ctx, entry_dir);
    if (lib_roots && n_lib_roots > 0) {
        for (int i = 0; i < n_lib_roots && lib_roots[i]; i++) {
            size_t ll = strlen(lib_roots[i]);
            if (ll >= 256)
                ll = 255;
            ast_pipeline_ctx_append_lib_root(ctx, (uint8_t *)lib_roots[i], (int32_t)ll);
        }
    }
}

/* G-02f-230：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_pipeline_fill_ctx_path_buffers(struct ast_PipelineDepCtx *ctx, const char *entry_dir,
    const char **lib_roots, int n_lib_roots) {
  if (ctx == NULL) {
    return;
  }
  {
    shux_pipeline_fill_ctx_path_buffers_impl(ctx, entry_dir, lib_roots, n_lib_roots);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/**
 * 将 C 侧 dep 槽写入 PipelineDepCtx sidecar（与 ast.x pipeline_dep_ctx_* 对齐）。
 * 参数：dep_mods/dep_ar/import_paths 长度 n；ctx 输出 sidecar。
 */
/* G-02f-228：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void shux_pipeline_pctx_seed_dep_slots_impl(struct ast_PipelineDepCtx *ctx, void **dep_mods, void **dep_ar,
    char **import_paths, int n) {
    int i;
    if (!ctx)
        return;
    ast_pipeline_dep_ctx_reset(ctx);
    for (i = 0; i < n; i++) {
        ast_pipeline_dep_ctx_set_module(ctx, i, (struct ast_Module *)dep_mods[i]);
        ast_pipeline_dep_ctx_set_arena(ctx, i, (struct ast_ASTArena *)dep_ar[i]);
        if (import_paths && import_paths[i]) {
            int pl = (int)strlen(import_paths[i]);
            ast_pipeline_dep_ctx_set_import_path(ctx, i, (uint8_t *)import_paths[i], pl);
        }
    }
    ast_pipeline_dep_ctx_set_ndep(ctx, n);
}

/* G-02f-228：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_pipeline_pctx_seed_dep_slots(struct ast_PipelineDepCtx *ctx, void **dep_mods, void **dep_ar,
    char **import_paths, int n) {
  if (ctx == NULL) {
    return;
  }
  {
    shux_pipeline_pctx_seed_dep_slots_impl(ctx, dep_mods, dep_ar, import_paths, n);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/* G-02f-228：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void shux_pipeline_pctx_seed_dep_import_paths_only_impl(struct ast_PipelineDepCtx *ctx, char **import_paths, int n) {
    int i;
    if (!ctx)
        return;
    ast_pipeline_dep_ctx_reset(ctx);
    for (i = 0; i < n; i++) {
        if (import_paths && import_paths[i]) {
            int pl = (int)strlen(import_paths[i]);
            ast_pipeline_dep_ctx_set_import_path(ctx, i, (uint8_t *)import_paths[i], pl);
        }
    }
    /* 仅镜像 import path；ndep 保持 0，让 entry pipeline 自行 load/sync direct imports。 */
}

/* G-02f-228：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_pipeline_pctx_seed_dep_import_paths_only(struct ast_PipelineDepCtx *ctx, char **import_paths, int n) {
  if (ctx == NULL) {
    return;
  }
  {
    shux_pipeline_pctx_seed_dep_import_paths_only_impl(ctx, import_paths, n);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/**
 * 更新 dep 槽 module/arena/path，不调用 ast_pipeline_dep_ctx_reset（保留 lib_root 等路径缓冲）。
 */
/* G-02f-228：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_pipeline_pctx_update_dep_slots_no_reset(struct ast_PipelineDepCtx *ctx, void **dep_mods,
                                                         void **dep_ars, char **import_paths, int n) {
    int i;
    if (!ctx)
        return;
    for (i = 0; i < n; i++) {
        ast_pipeline_dep_ctx_set_module(ctx, i, (struct ast_Module *)dep_mods[i]);
        ast_pipeline_dep_ctx_set_arena(ctx, i, (struct ast_ASTArena *)dep_ars[i]);
        if (import_paths && import_paths[i]) {
            int pl = (int)strlen(import_paths[i]);
            ast_pipeline_dep_ctx_set_import_path(ctx, i, (uint8_t *)import_paths[i], pl);
        }
    }
    ast_pipeline_dep_ctx_set_ndep(ctx, n);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */




/** parser.x 符号（dep 预跑 import 扫描与 pipeline_parse_into_loaded_import 共用）。 */
struct parser_ParseIntoResult {
    int32_t ok;
    int32_t main_idx;
};
extern void parser_parse_into_init(void *module, void *arena);
extern struct parser_ParseIntoResult parser_parse_into(void *arena, void *module, struct shux_slice_uint8_t *source);
extern int32_t parser_get_module_num_imports(void *module);
extern void parser_get_module_import_path(void *module, int32_t idx, uint8_t *path_buf);

/**
 * 单 dep 预跑 ctx：按 dep 自身 import 表过滤 ctx 槽（import_idx 与 ctx 下标一一对应）。
 * 勿写入 entry 全量 dep 表：coff→[elf,codegen,ast] 时 codegen 仅 import ast，ndep=3 会使 sync/typeck 错位 ec=-5。
 */
/* G-02f-233：字段写 helper（.x 早退编排调用） */
/* G-02f-233 / wave67：hybrid pure owns set_use_asm_backend thin → G.7
 * driver_pipeline_dep_ctx_set_use_asm; cold twin under #ifndef FROM_X. PLATFORM: SHARED LP64. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_dep_ctx_set_use_asm_backend(struct ast_PipelineDepCtx *ctx, int32_t v) {
    if (!ctx)
        return;
    ctx->use_asm_backend = v;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-233 / wave62：hybrid pure owns map_impl; cold twin under #ifndef FROM_X.
 * PLATFORM: SHARED — same control flow as pure orch (ok 0|-2 accept; else full slots). */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_pipeline_one_ctx_for_dep_prerun_map_impl(struct ast_PipelineDepCtx *ctx, void **dep_mods,
                                          void **dep_ars, char **dep_paths, int ndep, const uint8_t *dep_src,
                                          size_t dep_src_len) {
    int32_t n_imp;
    int mapped;
    void *tmp_arena = NULL;
    void *tmp_module = NULL;

    if (!ctx)
        return;
    tmp_arena = malloc(pipeline_sizeof_arena());
    tmp_module = malloc(pipeline_sizeof_module());
    if (!tmp_arena || !tmp_module) {
        free(tmp_arena);
        free(tmp_module);
        shux_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
        return;
    }
    memset(tmp_arena, 0, pipeline_sizeof_arena());
    memset(tmp_module, 0, pipeline_sizeof_module());
    parser_parse_into_init(tmp_module, tmp_arena);
    {
        struct shux_slice_uint8_t dep_slice = { (uint8_t *)dep_src, dep_src_len };
        struct parser_ParseIntoResult pr = parser_parse_into(tmp_arena, tmp_module, &dep_slice);
        n_imp = parser_get_module_num_imports(tmp_module);
    if (pr.ok != 0 && pr.ok != -2) {
            free(tmp_arena);
            free(tmp_module);
            shux_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
            return;
        }
        if (n_imp <= 0) {
            free(tmp_arena);
            free(tmp_module);
            ast_pipeline_dep_ctx_set_ndep(ctx, 0);
            return;
        }
    }
    mapped = 0;
    for (int32_t ii = 0; ii < n_imp; ii++) {
        uint8_t path_buf[64];
        char path_c[65];
        size_t k = 0;
        int g;

        parser_get_module_import_path(tmp_module, ii, path_buf);
        while (k < sizeof(path_buf) && path_buf[k]) {
            path_c[k] = (char)path_buf[k];
            k++;
        }
        path_c[k] = '\0';
        g = shux_find_loaded_import_index(path_c, dep_paths, ndep);
        if (g < 0)
            continue;
        ast_pipeline_dep_ctx_set_module(ctx, mapped, (struct ast_Module *)dep_mods[g]);
        ast_pipeline_dep_ctx_set_arena(ctx, mapped, (struct ast_ASTArena *)dep_ars[g]);
        if (dep_paths[g]) {
            int pl = (int)strlen(dep_paths[g]);
            ast_pipeline_dep_ctx_set_import_path(ctx, mapped, (uint8_t *)dep_paths[g], pl);
        }
        mapped = mapped + 1;
    }
    free(tmp_arena);
    free(tmp_module);
    ast_pipeline_dep_ctx_set_ndep(ctx, mapped);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-233：逻辑源 .x（早退 pure）；seed 保留同语义全路径 C 供产品 cc */
void shux_pipeline_one_ctx_for_dep_prerun_impl(struct ast_PipelineDepCtx *ctx, int j, void **dep_mods,
                                          void **dep_ars, char **dep_paths, int ndep, const uint8_t *dep_src,
                                          size_t dep_src_len) {
    (void)j;
    if (!ctx)
        return;
    pipeline_dep_ctx_set_use_asm_backend(ctx, 0);
    if (!dep_mods || !dep_ars || !dep_paths || ndep <= 0) {
        ast_pipeline_dep_ctx_set_ndep(ctx, 0);
        return;
    }
    if (!dep_src || dep_src_len == 0 || dep_src_len > (size_t)INT32_MAX) {
        shux_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
        return;
    }
    shux_pipeline_one_ctx_for_dep_prerun_map_impl(ctx, dep_mods, dep_ars, dep_paths, ndep, dep_src, dep_src_len);
}

/* G-02f-233：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_pipeline_one_ctx_for_dep_prerun(struct ast_PipelineDepCtx *ctx, int j, void **dep_mods,
                                          void **dep_ars, char **dep_paths, int ndep, const uint8_t *dep_src,
                                          size_t dep_src_len) {
  if (ctx == NULL) {
    return;
  }
  {
    shux_pipeline_one_ctx_for_dep_prerun_impl(ctx, j, dep_mods, dep_ars, dep_paths, ndep, dep_src, dep_src_len);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/** asm 用户程序：std.io/fs/net dep 跳过 .x typeck（符号由并列 .o 提供）。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_asm_user_std_dep_skip_x_typeck(const char *dep_path) {
  if (dep_path == NULL) {
    return 0;
  }
  {
    if (dep_path[0] == 0) {
      return 0;
    }
    if (pipeline_asm_user_dep_skip_x_typeck((uint8_t *)dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** std.net dep：须 co-emit listen/accept_many，seed typeck 对 stream_* 假阳性。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_asm_user_std_net_dep_path(const char *dep_path) {
  if (dep_path == NULL) {
    return 0;
  }
  {
    if (dep_path[0] == 0) {
      return 0;
    }
    if (pipeline_asm_user_std_net_dep_path((uint8_t *)dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** std.io.driver：co-emit submit_* 包装；seed typeck 对 register 假阳性。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_asm_user_std_io_driver_dep_path(const char *dep_path) {
  if (dep_path == NULL) {
    return 0;
  }
  {
    if (dep_path[0] == 0) {
      return 0;
    }
    if (pipeline_codegen_path_is_std_io_driver_bytes((uint8_t *)dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** dep 预跑 parse+skip typeck 路径（std.net / std.io.driver）。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_asm_user_dep_parse_skip_typeck_path(const char *dep_path) {
  {
    if (shux_asm_user_std_net_dep_path(dep_path) != 0) {
      return 1;
    }
    if (shux_asm_user_std_io_driver_dep_path(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** pipeline.x 编排：entry_dir / resolved / loaded import 与 dep arena/module 槽。 */
/* wave68: hybrid pure owns entry_dir BSS; cold-only statics under #ifndef FROM_X. */
/* wave69: hybrid pure owns resolved_path BSS; cold-only static under #ifndef FROM_X. */
/* wave70: hybrid pure owns dep arena/module slot tables; cold-only statics under #ifndef FROM_X. */
/* wave72: hybrid pure owns loaded_import BSS; cold-only statics under #ifndef FROM_X. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
static char pipeline_entry_dir_buf[512];
static const char *pipeline_entry_dir = ".";
static char pipeline_resolved_path_buf[512];
static void *pipeline_dep_arena_slots[32];
static void *pipeline_dep_module_slots[32];
static char *pipeline_loaded_import_buf;
static size_t pipeline_loaded_import_len;
static size_t pipeline_loaded_import_cap;
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** pipeline_run_x_pipeline 由 pipeline_x.o / pipeline_gen.c 提供。 */
extern int pipeline_run_x_pipeline(void *module, void *arena, const uint8_t *source_data, size_t source_len,
    void *out_buf, void *ctx);
extern int32_t pipeline_parse_set_main_from_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *data,
                                                  int32_t len);
extern int32_t pipeline_load_and_sync_direct_import_deps_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                           struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_entry_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                              struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_dep_prerun_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                   struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_module_main_func_index(void *module);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst);
extern int32_t pipeline_module_num_funcs(void *module);

/** 设置 pipeline resolve/read 用的 entry 目录。 */
/* G-02f-231 / wave68：hybrid pure owns entry_dir_copy / set_dot / get (pure BSS);
 * cold twins under #ifndef FROM_X share seed static buf + pointer. PLATFORM: SHARED. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_entry_dir_copy(const char *path) {
    if (!path)
        return;
    (void)snprintf(pipeline_entry_dir_buf, sizeof(pipeline_entry_dir_buf), "%s", path);
    pipeline_entry_dir = pipeline_entry_dir_buf;
}

/* G-02f-231 / wave68：entry_dir 回落为 "." */
void pipeline_entry_dir_set_dot(void) {
    pipeline_entry_dir = ".";
}

/* G-02f-231：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void pipeline_set_entry_dir(const char *path) {
    if (path && path[0]) {
        pipeline_entry_dir_copy(path);
    } else {
        pipeline_entry_dir_set_dot();
    }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */




/* G-02f-226 / wave70：hybrid pure owns dep_arena/module_slot_set/at (pure BSS 32×LP64);
 * cold twins under #ifndef FROM_X share seed static tables. PLATFORM: SHARED LP64. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_dep_arena_slot_set(int32_t i, void *p) {
    if (i < 0 || i >= 32)
        return;
    pipeline_dep_arena_slots[i] = p;
}

void pipeline_dep_module_slot_set(int32_t i, void *p) {
    if (i < 0 || i >= 32)
        return;
    pipeline_dep_module_slots[i] = p;
}

/** 写入 dep arena/module 槽（collect_deps 预分配缓冲）。 */
/* G-02f-226：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void pipeline_set_dep_slots(void *arenas[32], void *modules[32]) {
    for (int i = 0; i < 32; i++) {
        pipeline_dep_arena_slots[i] = arenas ? arenas[i] : NULL;
        pipeline_dep_module_slots[i] = modules ? modules[i] : NULL;
    }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */




/* G-02f-231 / wave68：hybrid pure owns entry_dir_get; cold twin under #ifndef FROM_X.
 * Cold uses seed static pointer cell (may point at buf or "." lit). PLATFORM: SHARED. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
const char *pipeline_entry_dir_get(void) {
    return pipeline_entry_dir ? pipeline_entry_dir : ".";
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-237 / wave69：hybrid pure owns resolved_path_buf_slot (pure BSS 512);
 * cold twin under #ifndef FROM_X. PLATFORM: SHARED. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
char *pipeline_resolved_path_buf_slot(void) {
    return pipeline_resolved_path_buf;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** 将 import 逻辑路径解析为文件系统路径写入内部 buffer。 */
/* G-02f-237 / wave65：hybrid pure owns into_static; cold twin under #ifndef FROM_X.
 * Pure orch: G.7 pure multi + pure entry_dir_get (wave68) / pure resolved_path_buf_slot (wave69).
 * PLATFORM: SHARED. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_resolve_path_into_static(const char *path_c) {
    const char *lib_roots[1] = { "." };
    if (!path_c)
        return;
    shux_resolve_import_file_path_multi(lib_roots, 1, pipeline_entry_dir, path_c, pipeline_resolved_path_buf,
        sizeof(pipeline_resolved_path_buf));
}

/* Cold-only _impl: pure resolve_path inlines path copy + pure into_static under hybrid. */
int32_t pipeline_resolve_path_impl(const uint8_t *path_ptr, int32_t path_len) {
    char path_c[65];
    size_t k = 0;
    if (path_len <= 0 || path_len > 64)
        path_len = 64;
    while (k < (size_t)path_len && path_ptr[k]) {
        path_c[k] = (char)path_ptr[k];
        k++;
    }
    path_c[k] = '\0';
    pipeline_resolve_path_into_static(path_c);
    return 0;
}

/* G-02f-237：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
int32_t pipeline_resolve_path(const uint8_t *path_ptr, int32_t path_len) {
  if (path_ptr == NULL) {
    return -1;
  }
  {
    return pipeline_resolve_path_impl(path_ptr, path_len);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** 读 resolved 路径文件并 preprocess，结果写入 loaded buffer。 */
/* G-02f-238 / wave66：stage 暂存 prep BSS（pure stage_prep / commit_prep). */
/* wave71: hybrid pure owns stage prep BSS + clear/set/take; cold-only statics under #ifndef FROM_X. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
static char *pipeline_rf_stage_prep;
static size_t pipeline_rf_stage_prep_len;

/* wave66 / wave71 cold twin: free prior stage prep and clear BSS cells.
 * Pure stage_prep calls pure clear under hybrid. PLATFORM: SHARED. */
void pipeline_rf_stage_prep_clear(void) {
    free(pipeline_rf_stage_prep);
    pipeline_rf_stage_prep = NULL;
    pipeline_rf_stage_prep_len = 0;
}

/* wave66 / wave71 cold twin: store owned prep into stage BSS (does not free prior;
 * caller must clear first). prep may be null (stores empty). PLATFORM: SHARED. */
void pipeline_rf_stage_prep_set(char *prep, size_t prep_len) {
    pipeline_rf_stage_prep = prep;
    pipeline_rf_stage_prep_len = prep ? prep_len : 0;
}

/* wave66 / wave71 cold twin: move stage prep out without free (caller owns);
 * clear stage BSS. Returns 0 if prep non-null; -1 if empty. PLATFORM: SHARED. */
int32_t pipeline_rf_stage_prep_take(char **out_prep, size_t *out_len) {
    char *prep = pipeline_rf_stage_prep;
    size_t prep_len = pipeline_rf_stage_prep_len;
    pipeline_rf_stage_prep = NULL;
    pipeline_rf_stage_prep_len = 0;
    if (out_prep)
        *out_prep = prep;
    if (out_len)
        *out_len = prep ? prep_len : 0;
    if (!prep)
        return -1;
    return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave66 / wave72: ensure loaded_import BSS, copy prep, set len, free prep.
 * Same ensure policy as historical commit_prep (cap floor SHUX_PIPELINE_IMPORT_BUF_CAP).
 * hybrid pure owns commit under FROM_X; cold twin under #ifndef. PLATFORM: SHARED. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int32_t pipeline_loaded_import_commit_from_owned(char *prep, size_t prep_len) {
    if (!prep)
        return -1;
    if (prep_len > pipeline_loaded_import_cap || !pipeline_loaded_import_buf) {
        free(pipeline_loaded_import_buf);
        pipeline_loaded_import_cap = prep_len < SHUX_PIPELINE_IMPORT_BUF_CAP ? SHUX_PIPELINE_IMPORT_BUF_CAP
                                                                             : prep_len + 65536;
        pipeline_loaded_import_buf = (char *)malloc(pipeline_loaded_import_cap);
        if (!pipeline_loaded_import_buf) {
            free(prep);
            return -1;
        }
    }
    memcpy(pipeline_loaded_import_buf, prep, prep_len);
    pipeline_loaded_import_len = prep_len;
    free(prep);
    return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-238 / wave66：hybrid pure owns stage_prep; cold twin under #ifndef FROM_X.
 * Pure orch: pure clear/set (wave71) + pure resolved_path_buf_slot (wave69) + runtime_read_file_view
 *   + G.7 pure shux_preprocess_raw_to_malloc + pure diags. PLATFORM: SHARED. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int32_t pipeline_read_file_stage_prep(void) {
    ShuxRuntimeFileView raw_view;
    char *prep = NULL;
    size_t prep_len = 0;

    pipeline_rf_stage_prep_clear();

    if (runtime_read_file_view(pipeline_resolved_path_buf, &raw_view) != 0) {
        pipeline_diag_import_open_fail_once(NULL, pipeline_resolved_path_buf);
        return -1;
    }
    if (shux_preprocess_raw_to_malloc((const unsigned char *)raw_view.data, raw_view.length, &prep, &prep_len,
            pipeline_resolved_path_buf, NULL, 0) != 0) {
        runtime_release_file_view(&raw_view);
        return -1;
    }
    runtime_release_file_view(&raw_view);
    if (!prep) {
        pipeline_diag_import_preprocess_fail(NULL, pipeline_resolved_path_buf);
        return -1;
    }
    pipeline_rf_stage_prep_set(prep, prep_len);
    return 0;
}

/* G-02f-238 / wave66：hybrid pure owns commit_prep; cold twin under #ifndef FROM_X.
 * Pure orch: pure take (wave71) + pure loaded_import_commit_from_owned (wave72). PLATFORM: SHARED. */
int32_t pipeline_read_file_commit_prep(void) {
    char *prep = NULL;
    size_t prep_len = 0;

    if (pipeline_rf_stage_prep_take(&prep, &prep_len) != 0)
        return -1;
    return pipeline_loaded_import_commit_from_owned(prep, prep_len);
}

/* G-02f-238：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t pipeline_read_file(void) {
    if (pipeline_read_file_stage_prep() != 0)
        return -1;
    if (pipeline_read_file_commit_prep() != 0)
        return -1;
    return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */



/** 取 dep arena 槽指针。 */
/* G-02f-226 / wave70：hybrid pure owns slot_at; cold twin under #ifndef FROM_X. PLATFORM: SHARED LP64. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void *pipeline_dep_arena_slot_at(int32_t i) {
    if (i < 0 || i >= 32)
        return NULL;
    return pipeline_dep_arena_slots[i];
}

void *pipeline_get_dep_arena_slot(int32_t i) {
  if (i < 0) {
    return NULL;
  }
  if (i >= 32) {
    return NULL;
  }
  {
    return pipeline_dep_arena_slot_at(i);
  }
  return NULL;
}

/** 取 dep module 槽指针。 */
void *pipeline_dep_module_slot_at(int32_t i) {
    if (i < 0 || i >= 32)
        return NULL;
    return pipeline_dep_module_slots[i];
}

void *pipeline_get_dep_module_slot(int32_t i) {
  if (i < 0) {
    return NULL;
  }
  if (i >= 32) {
    return NULL;
  }
  {
    return pipeline_dep_module_slot_at(i);
  }
  return NULL;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** 将 loaded import 缓冲 parse 进 module。 */
/* G-02f-239 / wave72：loaded 缓冲访问 — hybrid pure owns data/len_get; cold twins under #ifndef. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
uint8_t *pipeline_loaded_import_data(void) {
    return pipeline_loaded_import_buf ? (uint8_t *)pipeline_loaded_import_buf : NULL;
}

size_t pipeline_loaded_import_len_get(void) {
    return pipeline_loaded_import_len;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-239 / wave64：hybrid pure owns pipeline_parse_into_bytes; cold twin under #ifndef FROM_X.
 * Pure orch: parser_parse_into_init + driver_parse_into_buf_rc; non-zero ok → -1.
 * wave72 pure: pipeline_loaded_import_data / len_get (BSS) for loaded_import public.
 * PLATFORM: SHARED. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int32_t pipeline_parse_into_bytes(void *arena, void *module, uint8_t *data, size_t len) {
    struct shux_slice_uint8_t slice;
    struct parser_ParseIntoResult pr;
    if (!arena || !module || !data)
        return -1;
    slice.data = data;
    slice.length = len;
    parser_parse_into_init(module, arena);
    pr = parser_parse_into(arena, module, &slice);
    return pr.ok == 0 ? 0 : -1;
}

/* Cold-only _impl: pure loaded_import public inlines Cap residual data/len + pure parse_into_bytes. */
int32_t pipeline_parse_into_loaded_import_impl(void *arena, void *module) {
    uint8_t *data = pipeline_loaded_import_data();
    if (!data)
        return -1;
    return pipeline_parse_into_bytes(arena, module, data, pipeline_loaded_import_len_get());
}

/* G-02f-239：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
int32_t pipeline_parse_into_loaded_import(void *arena, void *module) {
  if (arena == NULL) {
    return -1;
  }
  if (module == NULL) {
    return -1;
  }
  {
    return pipeline_parse_into_loaded_import_impl(arena, module);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** pipeline_run_x_pipeline 大栈线程参数。 */
typedef struct {
    void *module;
    void *arena;
    const uint8_t *source_data;
    size_t source_len;
    void *out_buf;
    void *ctx;
    int result;
} PipelineRunSuArgs;

/** Always-seed Cap-fn-ptr residual: opaque address of pipeline_run_x_thread_fn.
 * wave56 pure large-stack orch binds this then driver_run_thread_on_large_stack.
 * PLATFORM: SHARED — function address not expressible safely in .x. */
uint8_t *pipeline_run_x_thread_fn_ptr(void) {
    return (uint8_t *)(void *)pipeline_run_x_thread_fn;
}

/** pthread 入口：跑 pipeline_run_x_pipeline 并写回 ec。 */
/* G-02f-241 / wave56：hybrid pure owns _impl; cold twin under #ifndef FROM_X.
 * SHUX_DEBUG_PIPE notes only in cold twin (pure skips). */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void *pipeline_run_x_thread_fn_impl(void *arg) {
    PipelineRunSuArgs *a = (PipelineRunSuArgs *)arg;
    if (!a)
        return NULL;
    driver_set_pipeline_entry_source_len(a->source_len);
    if (getenv("SHUX_DEBUG_PIPE"))
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: pipeline thread start len=%zu", a->source_len);
    a->result = pipeline_run_x_pipeline(a->module, a->arena, a->source_data, a->source_len, a->out_buf, a->ctx);
    if (getenv("SHUX_DEBUG_PIPE"))
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: pipeline thread done ec=%d", a->result);
    return NULL;
}

void *pipeline_run_x_thread_fn(void *arg) {
    if (!arg)
        return NULL;
    return pipeline_run_x_thread_fn_impl(arg);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */




/** 大栈 pthread 上调用 pipeline_run_x_pipeline；pthread 失败时回退当前线程。 */
/* G-02f-239 / wave56：hybrid pure owns _impl; cold twin under #ifndef FROM_X. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_pipeline_run_x_pipeline_large_stack_impl(void *module, void *arena, const uint8_t *source_data, size_t source_len,
    void *out_buf, void *ctx) {
    PipelineRunSuArgs args;
    driver_set_pipeline_entry_source_len(source_len);
    args.module = module;
    args.arena = arena;
    args.source_data = source_data;
    args.source_len = source_len;
    args.out_buf = out_buf;
    args.ctx = ctx;
    args.result = -99;
    driver_run_thread_on_large_stack(pipeline_run_x_thread_fn, &args);
    if (args.result == -99)
        return pipeline_run_x_pipeline(module, arena, source_data, source_len, out_buf, ctx);
    return args.result;
}

int shux_pipeline_run_x_pipeline_large_stack(void *module, void *arena, const uint8_t *source_data, size_t source_len,
    void *out_buf, void *ctx) {
    if (!module || !arena || !source_data || source_len == 0)
        return -1;
    return shux_pipeline_run_x_pipeline_large_stack_impl(module, arena, source_data, source_len, out_buf, ctx);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */



/** dep 预跑：完整 parse，跳过 typeck/codegen。 */
/* G-02f-239 / wave58：hybrid pure owns _impl; cold twin under #ifndef FROM_X.
 * Pure orch uses G.7 driver_pipeline_dep_ctx_* asm_entry accessors (no C field).
 * PLATFORM: SHARED — same flag order as pure orch. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_pipeline_dep_prerun_parse_skip_typeck_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
    void *dep_out, void *one_ctx) {
    int saved = driver_check_only_get();
    int saved_entry_only = 0;
    int ec;
    struct ast_PipelineDepCtx *pctx = (struct ast_PipelineDepCtx *)one_ctx;
    driver_check_only_set(1);
    if (pctx) {
        saved_entry_only = pctx->asm_entry_module_only;
        pctx->asm_entry_module_only = 1;
    }
    driver_x_pipeline_skip_typeck_set(1);
    driver_x_pipeline_skip_codegen_set(1);
    ec = shux_pipeline_run_x_pipeline_large_stack(dep_mod, dep_arena, src, len, dep_out, one_ctx);
    driver_x_pipeline_skip_codegen_set(0);
    driver_x_pipeline_skip_typeck_set(0);
    if (pctx)
        pctx->asm_entry_module_only = saved_entry_only;
    driver_check_only_set(saved ? 1 : 0);
    return ec;
}

/* G-02f-239：逻辑源 .x（边界 pure）；seed 保留同语义 C 供产品 cc */
int shux_pipeline_dep_prerun_parse_skip_typeck(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
    void *dep_out, void *one_ctx) {
    if (!dep_mod || !dep_arena || !src || len == 0)
        return -1;
    return shux_pipeline_dep_prerun_parse_skip_typeck_impl(dep_mod, dep_arena, src, len, dep_out, one_ctx);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */



/** dep 预跑：parse+typeck（C glue 直调），跳过 codegen；勿走 X run_x_pipeline_impl（大模块 ctx 易丢）。 */
/* G-02f-typeck_only / wave60：hybrid pure owns _impl; cold twin under #ifndef FROM_X.
 * Pure orch calls pipeline_parse_set_main_from_buf_c + load_and_sync + typeck_dep_prerun;
 * SHUX_DEBUG_PIPE notes live on cold twin only. PLATFORM: SHARED. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_pipeline_dep_prerun_typeck_only_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len, void *dep_out,
    void *one_ctx) {
    int32_t len_i32;
    int32_t parse_rc;
    int32_t load_rc;
    int32_t tc_rc;

    (void)dep_out;
    if (!dep_mod || !dep_arena || !src || len == 0 || !one_ctx)
        return -1;
    if (len > (size_t)INT32_MAX)
        return -1;
    len_i32 = (int32_t)len;
    parse_rc = pipeline_parse_set_main_from_buf_c((struct ast_Module *)dep_mod, (struct ast_ASTArena *)dep_arena,
                                                    (uint8_t *)src, len_i32);
    if (parse_rc != 0) {
        if (getenv("SHUX_DEBUG_PIPE"))
            diag_reportf(NULL, 0, 0, "note", NULL,
                         "pipeline debug: dep prerun parse rc=%d", (int)parse_rc);
        return -2;
    }
    load_rc = pipeline_load_and_sync_direct_import_deps_c((struct ast_Module *)dep_mod, (struct ast_ASTArena *)dep_arena,
                                                          (struct ast_PipelineDepCtx *)one_ctx);
    if (load_rc != 0) {
        if (getenv("SHUX_DEBUG_PIPE"))
            diag_reportf(NULL, 0, 0, "note", NULL,
                         "pipeline debug: dep prerun load rc=%d ndep=%d",
                         (int)load_rc, (int)pipeline_dep_ctx_ndep((struct ast_PipelineDepCtx *)one_ctx));
        return load_rc;
    }
    if (getenv("SHUX_DEBUG_PIPE")) {
        uint8_t dep_path_buf[64];
        memset(dep_path_buf, 0, sizeof(dep_path_buf));
        pipeline_dep_ctx_import_path_copy64((struct ast_PipelineDepCtx *)one_ctx, 0, dep_path_buf);
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: dep prerun call path=%s main=%d",
                     dep_path_buf[0] ? (char *)dep_path_buf : "?", (int)pipeline_module_main_func_index(dep_mod));
    }
    tc_rc = pipeline_typeck_dep_prerun_module_c((struct ast_Module *)dep_mod, (struct ast_ASTArena *)dep_arena,
                                              (struct ast_PipelineDepCtx *)one_ctx);
    if (getenv("SHUX_DEBUG_PIPE") && tc_rc != 0)
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: dep prerun typeck rc=%d funcs=%d main=%d ctx=%p",
                     (int)tc_rc, (int)pipeline_module_num_funcs(dep_mod),
                     (int)pipeline_module_main_func_index(dep_mod), one_ctx);
    return tc_rc;
}

int shux_pipeline_dep_prerun_typeck_only(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len, void *dep_out,
    void *one_ctx) {
  if (dep_mod == NULL) {
    return -1;
  }
  if (dep_arena == NULL) {
    return -1;
  }
  if (src == NULL) {
    return -1;
  }
  if (len == 0) {
    return -1;
  }
  if (one_ctx == NULL) {
    return -1;
  }
  {
    return shux_pipeline_dep_prerun_typeck_only_impl(dep_mod, dep_arena, src, len, dep_out, one_ctx);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-parse_only / wave59：hybrid pure owns _impl; cold twin under #ifndef FROM_X.
 * Must use pipeline_parse_set_main_from_buf_c (parse_into_with_init_buf); bare
 * parser_parse_into under-parses large std modules. PLATFORM: SHARED. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
/**
 * dep 预跑：仅 parse，不做全量 typeck。
 * 须走 pipeline_parse_set_main_from_buf_c（parse_into_with_init_buf）；直调 parser_parse_into 的 slice
 * 路径对大库模块（如 std/string/mod.x）常 ok=-2 且仅 ~2 func，co-emit 缺 std_string_* 符号。
 * SHUX_ASM_DEBUG notes live on cold twin only (pure orch omits diag noise).
 */
int shux_pipeline_dep_prerun_parse_only_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len) {
    int32_t parse_rc;
    if (!dep_mod || !dep_arena || !src || len == 0)
        return -1;
    if (len > (size_t)INT32_MAX)
        return -1;
    if (pipeline_asm_debug_enabled())
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "asm debug: dep_prerun_parse_only len=%zu funcs_before=%d",
                     len, pipeline_module_num_funcs(dep_mod));
    parser_parse_into_init(dep_mod, dep_arena);
    parse_rc = pipeline_parse_set_main_from_buf_c((struct ast_Module *)dep_mod, (struct ast_ASTArena *)dep_arena,
                                                  (uint8_t *)src, (int32_t)len);
    if (pipeline_asm_debug_enabled())
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "asm debug: dep_prerun_parse_only done rc=%d funcs=%d",
                     (int)parse_rc, pipeline_module_num_funcs(dep_mod));
    return (parse_rc == 0) ? 0 : -1;
}

int shux_pipeline_dep_prerun_parse_only(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len) {
  if (dep_mod == NULL) {
    return -1;
  }
  if (dep_arena == NULL) {
    return -1;
  }
  if (src == NULL) {
    return -1;
  }
  if (len == 0) {
    return -1;
  }
  {
    return shux_pipeline_dep_prerun_parse_only_impl(dep_mod, dep_arena, src, len);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** asm 单模块 -o：dep 预跑走 typeck_only。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_pipeline_dep_prerun_for_asm_module_o(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
    void *dep_out, void *one_ctx) {
    (void)driver_asm_entry_module_only_from_env;
    return shux_pipeline_dep_prerun_typeck_only(dep_mod, dep_arena, src, len, dep_out, one_ctx);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** ast.x 模块释放；LSP import 列表清理用。 */
extern void ast_module_free(struct ast_Module *mod);

/** 从绝对/相对源文件 path 提取所在目录写入 dep_dir；供 load_one_import 递归 import 切换 dep_dir。 */
/* G-02f-223：逻辑源 .x（真迁 pure）；seed 仍可走 _impl 同语义 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_import_dep_dir_from_path(const char *path, char *dep_dir, size_t dep_dir_size) {
  if (path == NULL) {
    return -1;
  }
  if (dep_dir == NULL) {
    return -1;
  }
  if (dep_dir_size == 0) {
    return -1;
  }
  {
    return shux_import_dep_dir_from_path_impl(path, dep_dir, dep_dir_size);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** 判断 import 路径是否已在 out_paths[0..n_out) 中（asm dep merge 去重）。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_merge_deps_path_already_out(const char *path, char *out_paths[], int n_out) {
  if (path == NULL) {
    return 0;
  }
  if (out_paths == NULL) {
    return 0;
  }
  if (n_out <= 0) {
    return 0;
  }
  {
    return shux_merge_deps_path_already_out_scan(path, out_paths, n_out);
  }
  return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** parser.x：读 module import 路径与 parse_into（dep 传递闭包收集用）。 */
extern int32_t parser_get_module_num_imports(void *module);
extern void parser_get_module_import_path(void *module, int32_t idx, uint8_t *path_buf);

/**
 * build_shux_asm（ENTRY_MODULE_ONLY + SKIP_TYPECK）：仅读入口 direct import 源码（不递归传递闭包），
 * 供 parse-only 填 dep struct layout；避免 shux_collect_deps_transitive 耗时/失败。
 * 返回 0 成功；失败时释放已写入 dep_sources/dep_paths 并返回 1。
 */
/* wave46 pure in .x; cold twin for non-PREFER product. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
/* G-02f-236：module import 计数（.x 编排） */
int32_t shux_module_num_imports(void *module) {
    if (!module)
        return 0;
    return parser_get_module_num_imports(module);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave55 pure in .x; cold twin for non-PREFER product.
 * wave51 Cap residual always-seed → wave55 pure orch (stack PATH + FileView + pure resolve/preprocess).
 * Pure load_one orch stores dep slots; paths_tmp reuses this (G.7).
 * PLATFORM: SHARED — PATH_MAX stack + ShuxRuntimeFileView cold twin only. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_load_one_direct_resolve_read_preprocess(const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir, const char *import_key, const char **defines, int ndefines, char **out_prep,
    size_t *out_prep_len) {
    char resolved[PATH_MAX];
    ShuxRuntimeFileView raw_view;
    size_t prep_len = 0;
    char *prep = NULL;

    if (out_prep)
        *out_prep = NULL;
    if (out_prep_len)
        *out_prep_len = 0;
    if (!import_key || !out_prep || !out_prep_len)
        return 1;
    shux_resolve_import_file_path_multi(lib_roots_arr, n_lib_roots, entry_dir, import_key, resolved,
        sizeof(resolved));
    if (runtime_read_file_view(resolved, &raw_view) != 0) {
        pipeline_diag_import_open_fail_once(import_key, resolved);
        return 1;
    }
    if (shux_preprocess_raw_to_malloc((const unsigned char *)raw_view.data, raw_view.length, &prep, &prep_len,
            resolved, ndefines > 0 ? defines : NULL, ndefines) != 0) {
        runtime_release_file_view(&raw_view);
        return 1;
    }
    runtime_release_file_view(&raw_view);
    if (!prep) {
        pipeline_diag_import_preprocess_fail(import_key, resolved);
        return 1;
    }
    *out_prep = prep;
    *out_prep_len = prep_len;
    return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave51 pure in .x; cold twin for non-PREFER product.
 * G-02f-236：单项 Cap residual resolve/read/preprocess + store dep 槽 mi；0 成功，1 失败。
 * Cold uses libc strdup (same as historical); pure orch uses Cap residual shux_collect_strdup. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_load_one_direct_import_at(const char **lib_roots_arr, int n_lib_roots, const char *entry_dir,
    const char *import_key, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int32_t mi) {
    size_t prep_len = 0;
    char *prep = NULL;

    if (!import_key || mi < 0)
        return 1;
    if (shux_load_one_direct_resolve_read_preprocess(lib_roots_arr, n_lib_roots, entry_dir, import_key, defines,
            ndefines, &prep, &prep_len) != 0)
        return 1;
    if (dep_sources)
        dep_sources[mi] = prep;
    if (dep_lens)
        dep_lens[mi] = prep_len;
    if (dep_paths) {
        dep_paths[mi] = strdup(import_key);
        if (!dep_paths[mi]) {
            free(prep);
            if (dep_sources)
                dep_sources[mi] = NULL;
            return 1;
        }
    }
    return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave51 pure in .x; cold twin for non-PREFER product.
 * G-02f-236：失败时释放 0..mi-1 已写 dep_sources/dep_paths */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_load_direct_fail_cleanup(char *dep_sources[], char *dep_paths[], int32_t mi) {
    while (mi > 0) {
        mi--;
        if (dep_sources && dep_sources[mi]) {
            free(dep_sources[mi]);
            dep_sources[mi] = NULL;
        }
        if (dep_paths && dep_paths[mi]) {
            free(dep_paths[mi]);
            dep_paths[mi] = NULL;
        }
    }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-236：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc（cold only under non-FROM_X） */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_load_direct_imports_for_asm_layout_impl(void *module, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int *out_n) {
    int32_t n_imports = shux_module_num_imports(module);
    int mi = 0;

    *out_n = 0;
    if (n_imports <= 0)
        return 0;
    for (int i = 0; i < n_imports && i < SHUX_DRIVER_DEP_SLOT_MAX && mi < SHUX_DRIVER_DEP_SLOT_MAX; i++) {
        uint8_t path_buf[64];
        char path_c[65];
        size_t k = 0;

        parser_get_module_import_path(module, i, path_buf);
        while (k < sizeof(path_buf) && path_buf[k] && k < 64) {
            path_c[k] = (char)path_buf[k];
            k++;
        }
        path_c[k] = '\0';
        if (shux_load_one_direct_import_at(lib_roots_arr, n_lib_roots, entry_dir, path_c, defines, ndefines,
                dep_sources, dep_lens, dep_paths, mi) != 0) {
            shux_load_direct_fail_cleanup(dep_sources, dep_paths, mi);
            *out_n = 0;
            return 1;
        }
        mi++;
    }
    *out_n = mi;
    return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-236：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_load_direct_imports_for_asm_layout(void *module, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int *out_n) {
  if (module == NULL) {
    return -1;
  }
  if (out_n == NULL) {
    return -1;
  }
  {
    return shux_load_direct_imports_for_asm_layout_impl(module, lib_roots_arr, n_lib_roots, entry_dir, defines, ndefines, dep_sources, dep_lens, dep_paths, out_n);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/**
 * 将 shux_collect_deps_transitive 得到的 closure（调用方已对 triple 数组做过反转）合并为 pipeline/asm_elf dep 列表。
 * 前 n_imports 项与入口 module import 槽对齐；传递依赖按 closure 顺序追加并路径去重。
 */
/* wave46 pure in .x; cold twin for non-PREFER product. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
/* G-02f-235：size_t 槽读写（.x merge deps pure） */
size_t shux_size_slot_get(size_t *arr, int32_t i) {
    if (!arr || i < 0)
        return 0;
    return arr[i];
}

void shux_size_slot_set(size_t *arr, int32_t i, size_t v) {
    if (!arr || i < 0)
        return;
    arr[i] = v;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-235：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int shux_merge_direct_then_transitive_deps_impl(void *module, int32_t n_imports, char *cls[], size_t clens[], char *cpaths[],
    int n_closure, char *out_src[], size_t out_lens[], char *out_paths[], int *out_n) {
    unsigned char used[SHUX_DRIVER_DEP_SLOT_MAX];
    int mi = 0;

    memset(used, 0, sizeof used);
    for (int i = 0; i < n_imports && i < SHUX_DRIVER_DEP_SLOT_MAX && mi < SHUX_DRIVER_DEP_SLOT_MAX; i++) {
        uint8_t path_buf[64];
        char path_c[65];
        size_t k = 0;
        int found = -1;
        int kk = 0;

        parser_get_module_import_path(module, i, path_buf);
        while (k < sizeof(path_buf) && path_buf[k] && k < 64) {
            path_c[k] = (char)path_buf[k];
            k++;
        }
        path_c[k] = '\0';
        while (kk < n_closure) {
            if (cpaths[kk] && strcmp(cpaths[kk], path_c) == 0) {
                found = kk;
                break;
            }
            kk++;
        }
        if (found < 0) {
            pipeline_diag_merge_dep_missing(path_c);
            return 1;
        }
        out_src[mi] = cls[found];
        out_lens[mi] = clens[found];
        out_paths[mi] = cpaths[found];
        used[found] = 1;
        mi++;
    }
    for (int kj = 0; kj < n_closure && mi < SHUX_DRIVER_DEP_SLOT_MAX; kj++) {
        if (!used[kj]) {
            if (cpaths[kj] && shux_merge_deps_path_already_out(cpaths[kj], out_paths, mi)) {
                used[kj] = 1;
                continue;
            }
            out_src[mi] = cls[kj];
            out_lens[mi] = clens[kj];
            out_paths[mi] = cpaths[kj];
            mi++;
        }
    }
    *out_n = mi;
    return 0;
}

/* G-02f-235：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_merge_direct_then_transitive_deps(void *module, int32_t n_imports, char *cls[], size_t clens[], char *cpaths[],
    int n_closure, char *out_src[], size_t out_lens[], char *out_paths[], int *out_n) {
  if (module == NULL) {
    return -1;
  }
  if (out_n == NULL) {
    return -1;
  }
  {
    return shux_merge_direct_then_transitive_deps_impl(module, n_imports, cls, clens, cpaths, n_closure, out_src, out_lens, out_paths, out_n);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/* wave46 pure in .x; cold twins for non-PREFER product. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
/* G-02f-234：import path 拷到 C 字符串（供 .x merge pure） */
void shux_module_import_path_cstr(void *module, int32_t idx, uint8_t *buf, int32_t cap) {
    uint8_t path_buf[64];
    int32_t k = 0;
    if (!buf || cap <= 0)
        return;
    buf[0] = 0;
    if (!module)
        return;
    parser_get_module_import_path(module, idx, path_buf);
    while (k < 64 && path_buf[k] && k + 1 < cap) {
        buf[k] = path_buf[k];
        k++;
    }
    buf[k] = 0;
}

void shux_ptr_slot_set(void **arr, int32_t i, void *p) {
    if (!arr || i < 0)
        return;
    arr[i] = p;
}

/* G.7 expand set authority: load pointer array slot i (argv/paths). PLATFORM: SHARED. */
void *shux_ptr_slot_get(void **arr, int32_t i) {
    if (!arr || i < 0)
        return NULL;
    return arr[i];
}

void shux_i32_store(int32_t *p, int32_t v) {
    if (p)
        *p = v;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-234：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int shux_merge_direct_then_transitive_dep_paths_impl(void *module, int32_t n_imports, char *cpaths[], int n_closure,
    char *out_paths[], int *out_n) {
    unsigned char used[SHUX_DRIVER_DEP_SLOT_MAX];
    int mi = 0;

    memset(used, 0, sizeof used);
    for (int i = 0; i < n_imports && i < SHUX_DRIVER_DEP_SLOT_MAX && mi < SHUX_DRIVER_DEP_SLOT_MAX; i++) {
        uint8_t path_buf[64];
        char path_c[65];
        size_t k = 0;
        int found = -1;
        int kk = 0;

        parser_get_module_import_path(module, i, path_buf);
        while (k < sizeof(path_buf) && path_buf[k] && k < 64) {
            path_c[k] = (char)path_buf[k];
            k++;
        }
        path_c[k] = '\0';
        while (kk < n_closure) {
            if (cpaths[kk] && strcmp(cpaths[kk], path_c) == 0) {
                found = kk;
                break;
            }
            kk++;
        }
        if (found < 0) {
            pipeline_diag_merge_dep_missing(path_c);
            return 1;
        }
        out_paths[mi] = cpaths[found];
        if (found >= 0 && found < SHUX_DRIVER_DEP_SLOT_MAX)
            used[found] = 1;
        mi++;
    }
    for (int kj = 0; kj < n_closure && mi < SHUX_DRIVER_DEP_SLOT_MAX; kj++) {
        if (!used[kj]) {
            if (cpaths[kj] && shux_merge_deps_path_already_out(cpaths[kj], out_paths, mi)) {
                used[kj] = 1;
                continue;
            }
            out_paths[mi] = cpaths[kj];
            mi++;
        }
    }
    *out_n = mi;
    return 0;
}

/* G-02f-234：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_merge_direct_then_transitive_dep_paths(void *module, int32_t n_imports, char *cpaths[], int n_closure,
    char *out_paths[], int *out_n) {
  if (module == NULL) {
    return -1;
  }
  if (out_n == NULL) {
    return -1;
  }
  {
    return shux_merge_direct_then_transitive_dep_paths_impl(module, n_imports, cpaths, n_closure, out_paths, out_n);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/**
 * 传递加载 dep：从 main 的 import 出发递归解析子 import，填满 dep_sources/dep_lens/dep_paths。
 * 返回 0 成功，1 失败（调用方负责释放已分配）。
 */
/* wave54 pure in .x; cold twin for non-PREFER product (wraps libc strdup).
 * PLATFORM: SHARED — null s → null; free() still releases ownership. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
char *shux_collect_strdup(const char *s) {
    if (!s)
        return NULL;
    return strdup(s);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave47 pure in .x; cold twin for non-PREFER product. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
/* G-02f-238：入口 import → to_load 队列（strdup）；0 成功，1 OOM（已清队列） */
int shux_collect_seed_to_load(void *module, char *to_load[], int *to_load_n) {
    int32_t n_imports;
    int j;

    if (!to_load || !to_load_n)
        return 1;
    *to_load_n = 0;
    n_imports = shux_module_num_imports(module);
    for (j = 0; j < n_imports && j < SHUX_DRIVER_DEP_SLOT_MAX && *to_load_n < SHUX_DRIVER_DEP_SLOT_MAX; j++) {
        uint8_t path_buf[64];
        char path_c[65];
        size_t k = 0;

        parser_get_module_import_path(module, j, path_buf);
        while (k < sizeof(path_buf) && path_buf[k]) {
            path_c[k] = (char)path_buf[k];
            k++;
        }
        path_c[k] = '\0';
        to_load[*to_load_n] = shux_collect_strdup(path_c);
        if (!to_load[*to_load_n]) {
            while (*to_load_n > 0) {
                (*to_load_n)--;
                free(to_load[*to_load_n]);
                to_load[*to_load_n] = NULL;
            }
            return 1;
        }
        (*to_load_n)++;
    }
    return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave46 pure in .x; cold twin for non-PREFER product. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
/* G-02f-238：to_load 是否已有 path */
int shux_collect_to_load_has(char *to_load[], int to_load_n, const char *path) {
    int t;
    if (!to_load || !path)
        return 0;
    for (t = 0; t < to_load_n; t++) {
        if (to_load[t] && strcmp(to_load[t], path) == 0)
            return 1;
    }
    return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave47 pure in .x; cold twin for non-PREFER product. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
/* G-02f-239：从已 parse 的 tmp_module 入队子 import（未 loaded / 未在 to_load） */
void shux_collect_enqueue_module_imports(void *tmp_module, char *to_load[], int *to_load_n, char *dep_paths[],
    int n_loaded) {
    int n_imp;
    int jj;
    if (!tmp_module || !to_load || !to_load_n)
        return;
    n_imp = parser_get_module_num_imports(tmp_module);
    if (n_imp <= 0)
        return;
    for (jj = 0; jj < n_imp && jj < SHUX_DRIVER_DEP_SLOT_MAX && *to_load_n < SHUX_DRIVER_DEP_SLOT_MAX; jj++) {
        uint8_t sub_buf[64];
        char sub_c[65];
        size_t kk = 0;

        parser_get_module_import_path(tmp_module, jj, sub_buf);
        while (kk < sizeof(sub_buf) && sub_buf[kk]) {
            sub_c[kk] = (char)sub_buf[kk];
            kk++;
        }
        sub_c[kk] = '\0';
        if (shux_find_loaded_import_index(sub_c, dep_paths, n_loaded) >= 0)
            continue;
        if (shux_collect_to_load_has(to_load, *to_load_n, sub_c))
            continue;
        to_load[*to_load_n] = shux_collect_strdup(sub_c);
        if (!to_load[*to_load_n])
            continue;
        (*to_load_n)++;
    }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave52 pure in .x; cold twin for non-PREFER product.
 * wave48 Cap residual was always-seed; now pure orch + cold twin under #ifndef FROM_X.
 * Ensure tmp arena/module, parse prep bytes, enqueue sub-imports.
 * PLATFORM: SHARED — cold keeps SHUX_DEBUG_PIPE note; pure skips debug-only note. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_collect_tmp_parse_and_enqueue(void **tmp_arena, void **tmp_module, size_t arena_sz, size_t module_sz,
    char *prep, size_t prep_len, const char *debug_path, char *to_load[], int *to_load_n, char *dep_paths[],
    int n_loaded) {
    if (!tmp_arena || !tmp_module || !prep)
        return;
    if (!*tmp_arena) {
        *tmp_arena = malloc(arena_sz);
        *tmp_module = malloc(module_sz);
    }
    if (*tmp_arena && *tmp_module) {
        memset(*tmp_arena, 0, arena_sz);
        memset(*tmp_module, 0, module_sz);
        {
            int n_imp;
            int pr_rc;
            pr_rc = pipeline_parse_into_bytes(*tmp_arena, *tmp_module, (uint8_t *)prep, prep_len);
            n_imp = parser_get_module_num_imports(*tmp_module);
            if (getenv("SHUX_DEBUG_PIPE")) {
                diag_reportf(NULL, 0, 0, "note", NULL,
                             "pipeline debug: collect parse dep=%s pr_ok=%d n_imp=%d",
                             debug_path ? debug_path : "?", pr_rc == 0 ? 1 : 0, n_imp);
            }
            (void)n_imp;
            shux_collect_enqueue_module_imports(*tmp_module, to_load, to_load_n, dep_paths, n_loaded);
        }
    }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave48 pure in .x; cold twin for non-PREFER product.
 * G-02f-241：处理 to_load 一项（owned path_c）；0 继续，1 失败。*n 递增；可更新 tmp_* / to_load
 * Cold body uses Cap residual load_one + tmp_parse_and_enqueue (same as pure orch). */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_collect_deps_process_one(char *path_c, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir_buf, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int *n, char *to_load[], int *to_load_n, void **tmp_arena, void **tmp_module,
    size_t arena_sz, size_t module_sz) {
    int mi;

    if (!path_c || !n || !to_load || !to_load_n || !tmp_arena || !tmp_module)
        return 1;
    if (shux_find_loaded_import_index(path_c, dep_paths, *n) >= 0) {
        free(path_c);
        return 0;
    }
    mi = *n;
    /* G.7: resolve+read+preprocess+store slot is Cap residual load_one_direct_import_at. */
    if (shux_load_one_direct_import_at(lib_roots_arr, n_lib_roots, entry_dir_buf, path_c, defines, ndefines,
            dep_sources, dep_lens, dep_paths, mi) != 0) {
        free(path_c);
        return 1;
    }
    free(path_c);
    if (!dep_paths[mi])
        return 1;
    (*n) = mi + 1;
    shux_collect_tmp_parse_and_enqueue(tmp_arena, tmp_module, arena_sz, module_sz, dep_sources[mi], dep_lens[mi],
        dep_paths[mi], to_load, to_load_n, dep_paths, *n);
    return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave50 pure in .x; cold twin for non-PREFER product.
 * G-02f-237：seed queue + process_one drain + free leftovers / fail partial deps.
 * Cold body mirrors pure orch (stack to_load + tmp cells via locals). */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_collect_deps_transitive_impl(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_sources[],
    size_t dep_lens[], char *dep_paths[], int *n_deps) {
    int n = 0;
    char *to_load[SHUX_DRIVER_DEP_SLOT_MAX];
    int to_load_n = 0;
    void *tmp_arena = NULL;
    void *tmp_module = NULL;

    if (shux_collect_seed_to_load(module, to_load, &to_load_n) != 0)
        goto fail_to_load;
    while (to_load_n > 0 && n < SHUX_DRIVER_DEP_SLOT_MAX) {
        char *path_c = to_load[--to_load_n];
        if (shux_collect_deps_process_one(path_c, lib_roots_arr, n_lib_roots, entry_dir_buf, defines, ndefines,
                dep_sources, dep_lens, dep_paths, &n, to_load, &to_load_n, &tmp_arena, &tmp_module, arena_sz,
                module_sz) != 0)
            goto fail_to_load;
    }
    while (to_load_n > 0) {
        to_load_n--;
        free(to_load[to_load_n]);
    }
    if (tmp_arena)
        free(tmp_arena);
    if (tmp_module)
        free(tmp_module);
    *n_deps = n;
    return 0;
fail_to_load:
    while (to_load_n > 0) {
        to_load_n--;
        free(to_load[to_load_n]);
    }
    if (tmp_arena)
        free(tmp_arena);
    if (tmp_module)
        free(tmp_module);
    while (n > 0) {
        n--;
        free(dep_sources[n]);
        free(dep_paths[n]);
    }
    return 1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-237：逻辑源 .x（空 import 早退 pure）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_collect_deps_transitive(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_sources[],
    size_t dep_lens[], char *dep_paths[], int *n_deps) {
  if (module == NULL) {
    return -1;
  }
  if (n_deps == NULL) {
    return -1;
  }
  if (shux_module_num_imports(module) <= 0) {
    *n_deps = 0;
    return 0;
  }
  {
    return shux_collect_deps_transitive_impl(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir_buf, defines, ndefines, dep_sources, dep_lens, dep_paths, n_deps);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/* wave53 pure in .x; cold twin for non-PREFER product.
 * ensure tmp; Cap residual resolve/read/preprocess path_c; G.7 pure tmp_parse; free prep.
 * Pure paths_process_one orch calls this after registering owned dep_paths key.
 * If tmp malloc fails: no-op success (path already registered; same as historical body).
 * wave51/wave55: G.7 reuses pure shux_load_one_direct_resolve_read_preprocess (no dual FILE/PATH_MAX body).
 * wave52: G.7 pure tmp_parse_and_enqueue (FROM_X weak pure; cold twin under #ifndef).
 * PLATFORM: SHARED — Cap residual resolve/read/preprocess + G.7 tmp_parse_and_enqueue. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_collect_paths_tmp_resolve_parse_enqueue(char *path_c, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir_buf, const char **defines, int ndefines, void **tmp_arena, void **tmp_module,
    size_t arena_sz, size_t module_sz, char *to_load[], int *to_load_n, char *dep_paths[], int n_loaded) {
    size_t prep_len = 0;
    char *prep = NULL;

    if (!path_c || !tmp_arena || !tmp_module)
        return 1;
    if (!*tmp_arena) {
        *tmp_arena = malloc(arena_sz);
        *tmp_module = malloc(module_sz);
    }
    /* Historical: if tmp unavailable, path stays registered and we skip parse. */
    if (!*tmp_arena || !*tmp_module)
        return 0;
    if (shux_load_one_direct_resolve_read_preprocess(lib_roots_arr, n_lib_roots, entry_dir_buf, path_c, defines,
            ndefines, &prep, &prep_len) != 0)
        return 1;
    shux_collect_tmp_parse_and_enqueue(tmp_arena, tmp_module, arena_sz, module_sz, prep, prep_len, path_c, to_load,
        to_load_n, dep_paths, n_loaded);
    free(prep);
    return 0;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave49 pure in .x; cold twin for non-PREFER product.
 * G-02f-241：paths-only process one（owned path_c）；0 继续，1 失败
 * Cold body mirrors pure orch: strdup key + Cap residual resolve/parse. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_collect_paths_process_one(char *path_c, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir_buf, const char **defines, int ndefines, char *dep_paths[], int *n, char *to_load[],
    int *to_load_n, void **tmp_arena, void **tmp_module, size_t arena_sz, size_t module_sz) {
    int mi;
    char *key;
    int rc;

    if (!path_c || !n || !to_load || !to_load_n || !tmp_arena || !tmp_module)
        return 1;
    if (shux_find_loaded_import_index(path_c, dep_paths, *n) >= 0) {
        free(path_c);
        return 0;
    }
    mi = *n;
    key = shux_collect_strdup(path_c);
    if (!key) {
        free(path_c);
        return 1;
    }
    dep_paths[mi] = key;
    (*n) = mi + 1;
    rc = shux_collect_paths_tmp_resolve_parse_enqueue(path_c, lib_roots_arr, n_lib_roots, entry_dir_buf, defines,
        ndefines, tmp_arena, tmp_module, arena_sz, module_sz, to_load, to_load_n, dep_paths, *n);
    free(path_c);
    return rc;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave50 pure in .x; cold twin for non-PREFER product.
 * paths-only transitive: same orch as deps_transitive_impl without sources/lens. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_collect_dep_paths_transitive_impl(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_paths[], int *n_deps) {
    int n = 0;
    char *to_load[SHUX_DRIVER_DEP_SLOT_MAX];
    int to_load_n = 0;
    void *tmp_arena = NULL;
    void *tmp_module = NULL;

    if (shux_collect_seed_to_load(module, to_load, &to_load_n) != 0)
        goto fail_to_load;
    while (to_load_n > 0 && n < SHUX_DRIVER_DEP_SLOT_MAX) {
        char *path_c = to_load[--to_load_n];
        if (shux_collect_paths_process_one(path_c, lib_roots_arr, n_lib_roots, entry_dir_buf, defines, ndefines,
                dep_paths, &n, to_load, &to_load_n, &tmp_arena, &tmp_module, arena_sz, module_sz) != 0)
            goto fail_to_load;
    }
    while (to_load_n > 0) {
        to_load_n--;
        free(to_load[to_load_n]);
    }
    if (tmp_arena)
        free(tmp_arena);
    if (tmp_module)
        free(tmp_module);
    *n_deps = n;
    return 0;
fail_to_load:
    while (to_load_n > 0) {
        to_load_n--;
        free(to_load[to_load_n]);
    }
    if (tmp_arena)
        free(tmp_arena);
    if (tmp_module)
        free(tmp_module);
    while (n > 0) {
        n--;
        free(dep_paths[n]);
    }
    return 1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-237：逻辑源 .x（空 import 早退 pure）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int shux_collect_dep_paths_transitive(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_paths[], int *n_deps) {
  if (module == NULL) {
    return -1;
  }
  if (n_deps == NULL) {
    return -1;
  }
  if (shux_module_num_imports(module) <= 0) {
    *n_deps = 0;
    return 0;
  }
  {
    return shux_collect_dep_paths_transitive_impl(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir_buf, defines, ndefines, dep_paths, n_deps);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/** asm emit 桩判定与 ARRAY_LIT/SoA 补类型（ast_pool.c / pipeline_glue.c）。 */
extern void asm_skip_heavy_set_pipeline_ctx(void *ctx);
extern void pipeline_fill_array_lit_types_for_skipped_typeck(void *m, void *arena);
extern void pipeline_fill_soa_field_access_for_asm_emit(void *m, void *arena);
extern void pipeline_module_fixup_with_arena_stmt_orders(void *m, void *arena);

/** asm_codegen_elf_o 前：设置 skip_heavy 上下文并为 ARRAY_LIT / SoA field 补类型。 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shux_driver_asm_prepare_entry_elf_emit(void *module, void *arena, void *pctx) {
  {
    asm_skip_heavy_set_pipeline_ctx(pctx);
    pipeline_fill_array_lit_types_for_skipped_typeck(module, arena);
    pipeline_fill_soa_field_access_for_asm_emit(module, arena);
    pipeline_debug_trace_named_func_bodies("emit_prepare_pre_fixup", module, arena);
    pipeline_module_fixup_with_arena_stmt_orders(module, arena);
    pipeline_debug_trace_named_func_bodies("emit_prepare_post_fixup", module, arena);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */


/** pthread 大栈 emit 参数包。 */
typedef struct {
    void *module;
    void *arena;
    void *ctx;
    struct platform_elf_ElfCodegenCtx *elf_ctx;
    void *out_buf;
    int32_t result;
} ShuxAsmCodegenElfLargeArgs;

extern int32_t asm_asm_codegen_elf_o(void *module, void *arena, void *ctx, struct platform_elf_ElfCodegenCtx *elf_ctx,
    void *out_buf);

/** Always-seed Cap residual: product asm elf_o emit for pure large-stack orch.
 * Pure must not call same-TU weak stub asm_asm_codegen_elf_o (returns -1).
 * This rest-TU call keeps an external reloc → final strong user_asm_seed_bridge.
 * G.7 single trampoline authority for pure→bridge emit; cold twins may still call
 * asm_asm_codegen_elf_o directly (no pure weak stub in cold full-C TU).
 * PLATFORM: SHARED. */
int32_t shux_asm_codegen_elf_o_product_emit(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf) {
    return asm_asm_codegen_elf_o(module, arena, ctx, elf_ctx, out_buf);
}

/** Always-seed Cap-fn-ptr residual: opaque address of shux_asm_codegen_elf_o_thread_fn.
 * wave57 pure large-stack orch binds this then driver_run_thread_on_large_stack.
 * PLATFORM: SHARED — function address not expressible safely in .x. */
uint8_t *shux_asm_codegen_elf_o_thread_fn_ptr(void) {
    return (uint8_t *)(void *)shux_asm_codegen_elf_o_thread_fn;
}

/** pthread 入口：调用 product emit 并将 ec 写入 args->result。 */
/* G-02f-241 / wave57：hybrid pure owns _impl; cold twin under #ifndef FROM_X. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void *shux_asm_codegen_elf_o_thread_fn_impl(void *arg) {
    ShuxAsmCodegenElfLargeArgs *a = (ShuxAsmCodegenElfLargeArgs *)arg;
    if (!a)
        return NULL;
    a->result = asm_asm_codegen_elf_o(a->module, a->arena, a->ctx, a->elf_ctx, a->out_buf);
    return NULL;
}

void *shux_asm_codegen_elf_o_thread_fn(void *arg) {
    if (!arg)
        return NULL;
    return shux_asm_codegen_elf_o_thread_fn_impl(arg);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */




/** 在 256MiB 栈 pthread 上调用 asm_asm_codegen_elf_o；主线程栈已深时避免 lexer emit Abort。 */
/* G-02f-240 / wave57：hybrid pure owns _impl; cold twin under #ifndef FROM_X. */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int32_t shux_asm_codegen_elf_o_large_stack_impl(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf) {
    ShuxAsmCodegenElfLargeArgs args;

    args.module = module;
    args.arena = arena;
    args.ctx = ctx;
    args.elf_ctx = elf_ctx;
    args.out_buf = out_buf;
    args.result = -99;
    driver_run_thread_on_large_stack(shux_asm_codegen_elf_o_thread_fn, &args);
    if (args.result == -99)
        return asm_asm_codegen_elf_o(module, arena, ctx, elf_ctx, out_buf);
    return args.result;
}

/* G-02f-240：逻辑源 .x（边界 pure）；seed 保留同语义 C 供产品 cc */
int32_t shux_asm_codegen_elf_o_large_stack(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf) {
    if (!module || !arena || !out_buf)
        return -1;
    return shux_asm_codegen_elf_o_large_stack_impl(module, arena, ctx, elf_ctx, out_buf);
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */




/** C typecheck 入口；由 typeck.c 提供。 */
extern int typeck_module(void *module, void **dep_mods, int ndep, void *a, int b);

/**
 * 使用已填充的 typeck_ndep / typeck_dep_module_ptrs 对入口模块做 C 类型检查（大模块 asm 构建用）。
 * SHUX_NO_C_FRONTEND 时仍导出符号供 pipeline_asm_typecheck_alias 链接。
 * G-02f-242 / wave63：hybrid pure owns entry/sidecar/for_ctx_impl; cold twins under #ifndef FROM_X.
 * Cap residual always-seed: typeck_module C frontend + typeck_dep_module_ptrs_base.
 * PLATFORM: SHARED.
 */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
int32_t typeck_module_entry_only(void *module) {
    if (!module)
        return -1;
    if (typeck_module(module, NULL, 0, NULL, 0) != 0)
        return -1;
    return 0;
}

int32_t typeck_module_with_sidecar(void *module) {
    if (!module)
        return -1;
    if (typeck_module(module, typeck_ndep > 0 ? (void **)typeck_dep_module_ptrs : NULL, typeck_ndep, NULL, 0) != 0)
        return -1;
    return 0;
}

int32_t pipeline_typeck_module_for_ctx_impl(void *module, void *arena, void *ctx_void) {
    (void)arena;
    (void)ctx_void;
    if (typeck_ndep > 0)
        return typeck_module_with_sidecar(module);
    return typeck_module_entry_only(module);
}

/* G-02f-242：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
int32_t pipeline_typeck_module_for_ctx(void *module, void *arena, void *ctx_void) {
  if (module == NULL) {
    return -1;
  }
  {
    return pipeline_typeck_module_for_ctx_impl(module, arena, ctx_void);
  }
  return -1;
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/** 释放 shu_lsp_resolve_and_load_imports 写入的 all_dep_mods / all_dep_paths（不含 entry 模块本身）。 */
/* G-02f-227：槽清空（.x free 循环后写回 NULL） */
void shu_lsp_ptr_slot_clear(void **arr, int32_t i) {
    if (!arr || i < 0)
        return;
    arr[i] = NULL;
}

void shu_lsp_free_loaded_imports_impl(void **all_dep_mods, char **all_dep_paths, int n_all) {
    int i;

    for (i = 0; i < n_all; i++) {
        if (all_dep_paths[i]) {
            free(all_dep_paths[i]);
            all_dep_paths[i] = NULL;
        }
        if (all_dep_mods[i]) {
            ast_module_free(all_dep_mods[i]);
            all_dep_mods[i] = NULL;
        }
    }
}

/* G-02f-227：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RUNTIME_PIPELINE_ABI_FROM_X
void shu_lsp_free_loaded_imports(struct ast_Module **all_dep_mods, char **all_dep_paths, int n_all) {
  if (all_dep_mods == NULL) {
    return;
  }
  if (all_dep_paths == NULL) {
    return;
  }
  if (n_all <= 0) {
    return;
  }
  {
    shu_lsp_free_loaded_imports_impl((void **)all_dep_mods, all_dep_paths, n_all);
  }
}
#endif /* SHUX_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 对 .x 源码做条件编译预处理；默认 bootstrap 走 preprocess.x，LEGACY 或 shux-c 冷路径走 C fallback。
 * 参数：与 preprocess.h preprocess() 一致。
 * 返回值：malloc 字符串（调用方 free）；失败 NULL。
 */
char *shux_preprocess(const char *source, size_t source_len, const char **defines, int ndefines, size_t *out_length) {
    return shux_preprocess_quiet(source, source_len, defines, ndefines, out_length);
}

char *shux_preprocess_with_path(const char *source, size_t source_len, const char *path_diag,
    const char **defines, int ndefines, size_t *out_length) {
    size_t slen;

    if (out_length)
        *out_length = 0;
    if (!source)
        return NULL;
#if defined(SHUX_USE_X_PIPELINE) && !defined(SHUX_LEGACY_PREPROCESS_C)
    slen = source_len ? source_len : strlen(source);
    {
        char *out = NULL;
        size_t olen = 0;

        if (shux_preprocess_raw_to_malloc_impl((const unsigned char *)source, slen, &out, &olen, path_diag,
                ndefines > 0 ? defines : NULL, ndefines, 1) != 0)
            return NULL;
        if (out_length)
            *out_length = olen;
        return out;
    }
#else
    return preprocess_c_fallback(source, source_len, defines, ndefines, out_length);
#endif
}

char *shux_preprocess_quiet(const char *source, size_t source_len, const char **defines, int ndefines, size_t *out_length) {
    size_t slen;

    if (out_length)
        *out_length = 0;
    if (!source)
        return NULL;
#if defined(SHUX_USE_X_PIPELINE) && !defined(SHUX_LEGACY_PREPROCESS_C)
    slen = source_len ? source_len : strlen(source);
    {
        char *out = NULL;
        size_t olen = 0;

        if (shux_preprocess_raw_to_malloc_impl((const unsigned char *)source, slen, &out, &olen, NULL,
                ndefines > 0 ? defines : NULL, ndefines, 0) != 0)
            return NULL;
        if (out_length)
            *out_length = olen;
        return out;
    }
#else
    return preprocess_c_fallback(source, source_len, defines, ndefines, out_length);
#endif
}

/* Why: The previous `#ifdef _WIN32` block here provided empty/failure stubs
 *      for parser_parse_into_init / parser_parse_into / parser_get_module_* /
 *      asm_skip_heavy_set_pipeline_ctx / pipeline_fill_* / asm_asm_codegen_elf_o /
 *      pipeline_parse_set_main_from_buf_c. It was originally added (commit
 *      dc33395a4, 2026-07-03) because the Windows bootstrap link path did NOT
 *      include parser_x.o / typeck_x.o / codegen_x.o, so the symbols had to
 *      be stubbed out to satisfy the linker.
 *
 *      After the LD_R_MULTIDEF_FLAGS fix (commit 001309dc) the Windows
 *      bootstrap-driver-seed link now includes the same X-pipeline .o files
 *      as macOS/Linux (parser_x.o, typeck_x.o, codegen_x.o, …), so all these
 *      symbols are provided by their authoritative implementations. The stubs
 *      became a duplicate authority that silently broke the parser:
 *      SHUX_WEAK is empty on PE/MinGW, so the stubs compiled as STRONG defs;
 *      runtime_pipeline_abi.o is ordered BEFORE parser_x.o in DRIVER_SEED_OBJS,
 *      so with --allow-multiple-definition the empty `parser_parse_into_init`
 *      (a no-op that skips ast_ast_arena_init / ast_pool_module_reset /
 *      parser_onefunc_result_layout_prime) won over parser_x.o's real impl,
 *      leaving the module uninitialised → driver_first_parse num_funcs=0
 *      → silent parser failure on every `shux -c/-E/build/run` invocation.
 *
 *      Removing the block restores single-authority resolution: the extern
 *      declarations earlier in this file (L1814 etc.) reference the real
 *      implementations in parser_x.o / typeck_x.o / codegen_x.o, exactly as
 *      on macOS/Linux. The "9 conflicting-types errors" the block existed
 *      to silence were an artefact of the stubs themselves (uint8_t* params
 *      vs void* extern decls in the same TU); with the stubs gone, only the
 *      extern declarations remain, and cross-TU type differences are not
 *      visible to the C compiler.
 *
 * Invariant: Every previously-stubbed symbol (parser_parse_into_init,
 *            parser_parse_into, parser_get_module_num_imports,
 *            parser_get_module_import_path, asm_skip_heavy_set_pipeline_ctx,
 *            pipeline_fill_array_lit_types_for_skipped_typeck,
 *            pipeline_fill_soa_field_access_for_asm_emit,
 *            pipeline_module_fixup_with_arena_stmt_orders,
 *            asm_asm_codegen_elf_o, pipeline_parse_set_main_from_buf_c) MUST
 *            be provided as a strong definition by some .o in
 *            DRIVER_SEED_OBJS / BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS. Verified
 *            on macOS via `nm shux` (all 10 symbols present as T).
 * PLATFORM: SHARED — block removal is a no-op on macOS/Linux (block was
 *           already skipped via `#ifdef _WIN32`); on Windows it eliminates
 *           the duplicate authority so the real impls from parser_x.o etc.
 *           are linked, matching macOS behaviour.
 */
