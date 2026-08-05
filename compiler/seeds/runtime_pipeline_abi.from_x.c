
/* Generated from src/runtime_pipeline_abi.x (G-02f-32..63/84/85/93/95/96/97/223 true .x + C tail).
 * wave135: x86_enc_helpers pure leave cold twins under #ifndef FROM_X (glue_enc_x86_* + lcg body).
 * wave134: match pure leave cold twins under #ifndef FROM_X (match_elf/expr_if_elf/subject).
 * wave133: unary pure leave cold twins under #ifndef FROM_X (neg/lognot/bitnot/sxt/jz).
 * wave131: async_cps pure leave cold twins under #ifndef FROM_X (after_await/phase_reset/entry/end).
 * wave132: struct_let pure leave cold twins under #ifndef FROM_X (struct_let_init/type_let_init/sret).
 * wave130: wpo_mono pure leave cold twins under #ifndef FROM_X (reset/register_n/register + thunks_elf).
 * wave129: block_if pure leave cold twins under #ifndef FROM_X (block_if_stmt_elf + if_then_block_body).
 * wave128: logand/logor pure leave cold twins under #ifndef FROM_X (logand_impl + logor_impl).
 * wave127: panic pure leave cold twins under #ifndef FROM_X (call + panic_elf + div0 + rbx check).
 * wave126: next_offset pure leave cold twins under #ifndef FROM_X (align + 2 bump).
 * wave125: ctx_layout pure leave cold twin under #ifndef FROM_X (identity cast).
 * wave124: var_decl pure leave cold twins under #ifndef FROM_X.
 * wave123: lea_common pure leave cold twins under #ifndef FROM_X.
 * wave121: lint_meta pure leave cold twins under #ifndef FROM_X.
 * wave110: pure ImportEntry storage (pipeline_module_import_* + storage_release) in .x
 *   product hybrid; Cap ast_pool XLANG_WEAK cold twins. Structure debt close.
 * wave97: pure load_and_sync step5 typeck merge+wpo → G.7 typeck.x authority
 *   (typeck_merge_dep_struct_layouts_into_entry / typeck_wpo_unify_soa_layouts;
 *   no typeck_typeck_* hop). Closes Cap residual merge call surface under pure load_and_sync.
 * wave96: pure pipeline_parse_into_buf orch (init + driver_parse_into_buf_rc +
 *   debug_trace + fixup on ok; under wave94 pure load_import). glue XLANG_WEAK cold twin.
 * wave95: pure pipeline_resolve_path_x / pipeline_read_file_x /
 *   pipeline_preprocess_loaded_into_ctx orch (under wave94 pure load_import);
 *   Cap residual try_one/try_entry + path/loaded accessors + preprocess_x_buf;
 *   parse_into_buf wave96→pure. glue/ast_pool XLANG_WEAK cold twins.
 * wave45 R2 hybrid (2026-07-21): product PREFER g05_try_x_to_o full .x pure (~115) +
 *   this seed as rest under -DXLANG_RUNTIME_PIPELINE_ABI_FROM_X (no pure-dup public bodies).
 * wave46: pure residual helpers (ptr/size slots, i32_store, module import cstr,
 *   collect_to_load_has, preprocess directive diag) — cold twins under FROM_X.
 * wave47: pure collect seed_to_load + enqueue_module_imports.
 * wave48: pure collect deps_process_one orch; Cap residual tmp_parse_and_enqueue always-seed;
 *   G.7 reuses load_one_direct_import_at for resolve/read/preprocess.
 * wave49: pure collect paths_process_one orch; Cap residual paths_tmp_resolve_parse_enqueue
 *   (resolve/read/preprocess + G.7 tmp_parse_and_enqueue).
 * wave50: pure collect deps/paths transitive_impl orch (stack to_load + process_one loop).
 * wave51: pure load_one_direct_import_at + load_direct_fail_cleanup orch;
 *   Cap residual then pure (wave55) xlang_load_one_direct_resolve_read_preprocess;
 *   G.7 paths_tmp reuses same resolve_read (no dual resolve/read/preprocess bodies).
 * wave52: pure collect tmp_parse_and_enqueue orch (malloc/memset ensure + parse + G.7 enqueue).
 * wave53: pure collect paths_tmp_resolve_parse_enqueue orch (ensure tmp + resolve_read
 *   + G.7 pure tmp_parse + free prep).
 * wave54: pure collect strdup thin shell (malloc + scan + byte copy + NUL).
 * wave55: pure resolve_read_preprocess orch (stack resolved + FileView + pure resolve
 *   + runtime_read_file_view + pure preprocess + release + diags).
 * wave56: pure pipeline_run_x thread large-stack _impl orch (PipelineRunSuArgs stack pack;
 *   Cap-fn-ptr → wave84 pure thin + g05 &fn cast; G.7 driver_run_thread_on_large_stack;
 *   XLANG_DEBUG_PIPE notes cold-only).
 * wave57: pure asm elf_o large-stack _impl orch (AsmElfLargeArgs stack pack;
 *   Cap-fn-ptr → wave84 pure thin + g05 &fn cast;
 *   product_emit → wave80 pure thin + cold twin under #ifndef FROM_X).
 * wave58: pure dep_prerun_parse_skip_typeck_impl orch (driver check_only + skip typeck/codegen
 *   + G.7 driver_pipeline_dep_ctx_* asm_entry_module_only + pure large_stack; cold twin
 *   under #ifndef FROM_X).
 * wave59: pure dep_prerun_parse_only_impl orch (parser_parse_into_init +
 *   pipeline_parse_set_main_from_buf_c; XLANG_ASM_DEBUG notes cold-only; cold twin
 *   under #ifndef FROM_X).
 * wave60: pure dep_prerun_typeck_only_impl orch (parse_set_main + load_sync deps +
 *   typeck_dep_prerun_module; XLANG_DEBUG_PIPE notes cold-only; cold twin under
 *   #ifndef FROM_X).
 * wave61: pure preprocess_raw_to_malloc_impl orch (scratch + define table + preprocess_x_buf
 *   + owned dup; Cap residual preprocess_* engine; pure diag helpers; oversized reportf
 *   cold-only / pure fail; cold twin under #ifndef FROM_X).
 * wave62: pure one_ctx_for_dep_prerun_map_impl orch (tmp malloc arena/module + parse_into
 *   ok/allow -2 + import map; G.7 pctx_update / find_loaded / import path; cold twin under
 *   #ifndef FROM_X).
 * wave63: pure typeck_module_entry_only / with_sidecar / pipeline_typeck_module_for_ctx_impl
 *   orch (Cap residual typeck_module C frontend + typeck_dep_module_ptrs_base → wave77 pure;
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
 *   buf+len+cap; ensure floor XLANG_PIPELINE_IMPORT_BUF_CAP; cold twins under #ifndef FROM_X).
 * wave73: pure pipeline_diag_emitted_flag_slot (pure BSS sticky i32; cold twin under
 *   #ifndef FROM_X).
 * wave74: pure driver_dep_* table BSS orch (arena/module/path_registry/seeded 32 slots;
 *   G.7 ptr slots + seeded_slot; cold twins + seed static tables under #ifndef FROM_X).
 * wave75: pure entry_lib authority (typeck_lit / keyword_lit / name_from_path_impl + thin gate;
 *   pure BSS stem_buf + keyword lits; G.7 single path matches C keyword-before-std order;
 *   cold twins under #ifndef FROM_X).
 * wave76: pure xlang_cstr_offset (G.7 &s[off] ≡ s+off; closes Cap residual pointer arith leaf;
 *   cold twin under #ifndef FROM_X).
 * wave77: pure typeck_ndep / typeck_dep_* table BSS + slot/get/set_impl / ptrs_base
 *   (G.7 xlang_ptr_slot_*; product hybrid writers only via accessors; cold twins under #ifndef FROM_X).
 * wave78: pure xlang_lsp_ptr_slot_clear (G.7 xlang_ptr_slot_set null) + xlang_fputs_stdout
 *   (G.7 g05 stdout_ptr + fputs_opaque) + driver_asm_fp_is_stdout + driver_asm_fclose_file
 *   (G.7 g05 stdout compare + fclose_opaque); cold twins under #ifndef FROM_X.
 * wave79: pure xlang_path_try_realpath_inplace (G.7 g05 realpath_opaque + stack 1024 +
 *   pipe_cstr_copy; fail leave path; cold twin under #ifndef FROM_X).
 * wave80: pure xlang_asm_codegen_elf_o_product_emit thin (export-extern asm_asm_codegen_elf_o
 *   only — no same-TU weak -1; external reloc → bridge strong; cold twin under #ifndef FROM_X).
 * wave81: pure xlang_preprocess / quiet / with_path thin public surface (G.7 pure
 *   raw_to_malloc_impl; product X-pipeline; cold twin keeps LEGACY fallback under #ifndef FROM_X).
 * wave82: pure pipeline_debug_trace_named_func_bodies_impl orch (getenv + module walk +
 *   G.7 pure body_func_match + pipe_diag_msg_append_* + diag_report; no reportf; cold twin
 *   under #ifndef FROM_X keeps reportf). Closes soft residual always-seed body-trace leaf.
 * wave83: pure pipeline_sizeof_arena / pipeline_sizeof_module (LP64 constants 16 / 68;
 *   glue weak cold fallback). Closes Cap residual sizeof leaf for pure path.
 * wave84: pure pipeline_run_x_thread_fn_ptr / xlang_asm_codegen_elf_o_thread_fn_ptr thin
 *   (G.7 g05 xlang_driver_*_thread_fn_ptr &fn cast residual; cold twins under #ifndef FROM_X).
 *   Closes Cap residual always-seed Cap-fn-ptr product surface leaf.
 * wave85: pure preprocess_define_reset / add / has (-D table BSS in pure pipeline_abi;
 *   glue strict_stubs XLANG_WEAK cold fallback). Closes Cap residual define-table leaf
 *   of preprocess engine (x_buf / if_stack still Cap residual).
 * wave86: pure preprocess_if_stack_* (fixed i32[32] BSS; ast_pool GrowVec XLANG_WEAK
 *   cold fallback). Closes Cap residual preprocess #if stack leaf.
 * wave87: pure typeck_module_for_ctx route → typeck_x_ast / typeck_x_ast_library
 *   (G.7 single typeck authority; C typeck_module deleted). Closes Cap residual
 *   typeck_module C frontend leaf. Cold twin under #ifndef FROM_X matches pure route.
 * wave88: pure preprocess_eval_condition_c (trim + pure define_has simple path;
 *   Cap residual cfg_eval_expr_c complex; glue strict_stubs XLANG_WEAK cold fallback).
 *   Closes Cap residual preprocess #if condition-eval leaf.
 * wave89: pure pipeline_typeck_dep_prerun_module_c (set_dep_ctx + soft_suppress +
 *   typeck_x_ast_library + Cap residual layout validate/patch; glue XLANG_WEAK cold).
 *   Closes Cap residual typeck dep-prerun leaf used by wave60 typeck_only orch.
 * wave90: pure pipeline_typeck_diag_soft_suppress_set / _get (i32 BSS; glue XLANG_WEAK cold).
 *   Closes Cap residual soft-suppress leaf under pure dep-prerun orch.
 * wave91: pure pipeline_typeck_set_dep_ctx / get_dep_ctx (LP64 ptr BSS; glue XLANG_WEAK cold).
 *   Closes Cap residual set_dep_ctx leaf; ast_pool enum fallback via get_dep_ctx.
 * wave92: pure layout validate/patch_c thin → typeck.x (G.7; glue XLANG_WEAK cold).
 * wave94: pure load_import_from_disk_c + sync_dep_slots_from_driver_c orch +
 *   bind_import_dep_buffers + sync_one_dep_slot (Cap residual resolve/read/pp/parse).
 * wave93: pure load_and_sync_direct_import_deps_c orch + try_bind + realign
 *   (ast_pool XLANG_WEAK cold; Cap residual disk load / sync / typeck merge+wpo).
 *   Closes Cap residual layout validate+patch helpers under pure dep-prerun light fallback.
 * wave97: pure load_and_sync step5 merge+wpo → typeck.x (G.7).
 * wave98: product cfg_eval complex #if → cfg_eval.x (-E+alias), not bootstrap stub
 *   (Makefile PIPELINE_GEN_CFLAGS + -Wno-parentheses-equality on gen).
 * wave99: pure parser_copy_module_import_path64 thin → G.7 pipeline_module_import_path_copy
 *   + NUL len; parser_gen path64 weak cold twin.
 * Cap residual still: preprocess_x_buf pure preprocess.x cross-TU; g05 &fn cast;
 *   ImportEntry storage pipeline_module_import_path_*; cfg_eval complex = permanent G.7 cross-TU.
 * Root fix wave45: .x docblock must not embed end-comment marker in prose (char star / void star
 *   was written as char star-star-slash void-star and truncated the block → silent AST drop of all
 *   subsequent export function; -E only externs; pure never productized until fix).
 * Cold/fallback without PREFER: full C bodies (no FROM_X). PLATFORM: SHARED.
 * Regen: g05_try_x_to_o src/runtime_pipeline_abi.x (product) / host-cc this file (cold).
 * G-02f pure gates remain under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X for cold twins.
 */
#include <xlang_weak.h>
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
#if !defined(_WIN32) && !defined(_WIN64)
#include <dirent.h>
#include <sys/stat.h>
#endif
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            macOS/Linux delegate to system <unistd.h> via #include_next.
 *            Historical #ifndef _WIN32 guard removed — shim is a no-op
 *            on POSIX and provides needed declarations on Windows. */
#include <unistd.h>
/* wave235 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — cold seed twins use same face as product hybrid pure .x. */
extern char *link_abi_getenv(const char *name);
/** preprocess.x 生成；pipeline/import 与 runtime preprocess() 共用。 */
extern int32_t preprocess_x_buf(const uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf, int32_t out_cap);
extern void preprocess_define_reset(void);
extern int32_t preprocess_if_stack_len(void);
extern void preprocess_define_add(const char *name);







/* G-02f-63 helper protos */
int32_t pipeline_typeck_module_for_ctx_impl(void *module, void *arena, void *ctx_void);
void xlang_lsp_free_loaded_imports_impl(void **all_dep_mods, char **all_dep_paths, int n_all);

/* G-02f-62 helper protos */
void pipeline_debug_trace_named_func_bodies_impl(const char *phase, void *module, void *arena);
int xlang_merge_direct_then_transitive_deps_impl(void *module, int32_t n_imports, char *cls[], size_t clens[], char *cpaths[],
    int n_closure, char *out_src[], size_t out_lens[], char *out_paths[], int *out_n);

/* wave1225: release AST sidecars before free on collect/prerun tmp arenas.
 * free alone leaves g_arena_sc / g_module_sc used; malloc address reuse reattaches
 * stale GrowVec data (directory check truncates large files after importful peers).
 * PLATFORM: SHARED — cold twin of pipe_release_tmp_arena_module in .x. */
extern void ast_pool_arena_release(void *a);
extern void ast_pool_module_release(void *m);
static void pipe_release_tmp_arena_module(void *arena, void *module) {
    if (arena) {
        ast_pool_arena_release(arena);
        free(arena);
    }
    if (module) {
        ast_pool_module_release(module);
        free(module);
    }
}

int xlang_collect_deps_transitive_impl(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_sources[],
    size_t dep_lens[], char *dep_paths[], int *n_deps);
int xlang_collect_dep_paths_transitive_impl(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_paths[], int *n_deps);

/* G-02f-61 / G-02f-240 helper protos */
int32_t xlang_asm_codegen_elf_o_large_stack_impl(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf);
int32_t xlang_asm_codegen_elf_o_large_stack(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf);
int xlang_load_direct_imports_for_asm_layout_impl(void *module, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int *out_n);
int xlang_merge_direct_then_transitive_dep_paths_impl(void *module, int32_t n_imports, char *cpaths[], int n_closure,
    char *out_paths[], int *out_n);

/* G-02f-60 helper protos */
void pipeline_set_entry_dir(const char *path);
void pipeline_set_dep_slots(void *arenas[32], void *modules[32]);
void xlang_pipeline_fill_ctx_path_buffers_impl(struct ast_PipelineDepCtx *ctx, const char *entry_dir,
    const char **lib_roots, int n_lib_roots);
void xlang_pipeline_pctx_seed_dep_slots_impl(struct ast_PipelineDepCtx *ctx, void **dep_mods, void **dep_ar,
    char **import_paths, int n);
void xlang_pipeline_pctx_seed_dep_import_paths_only_impl(struct ast_PipelineDepCtx *ctx, char **import_paths, int n);
void xlang_pipeline_one_ctx_for_dep_prerun_impl(struct ast_PipelineDepCtx *ctx, int j, void **dep_mods,
                                          void **dep_ars, char **dep_paths, int ndep, const uint8_t *dep_src,
                                          size_t dep_src_len);

/* G-02f-59 helper protos */
int xlang_pipeline_dep_prerun_typeck_only_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len, void *dep_out,
    void *one_ctx);
void xlang_resolve_import_file_path_multi_impl(const char **lib_roots, int n_lib_roots, const char *entry_dir,
    const char *import_path, char *path, size_t path_size);

/* G-02f-58 helper protos */
int xlang_pipeline_dep_prerun_parse_skip_typeck_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
    void *dep_out, void *one_ctx);
int xlang_pipeline_dep_prerun_parse_only_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len);

/* G-02f-57 / G-02f-239 helper protos */
int xlang_pipeline_run_x_pipeline_large_stack_impl(void *module, void *arena, const uint8_t *source_data, size_t source_len,
    void *out_buf, void *ctx);
int xlang_pipeline_run_x_pipeline_large_stack(void *module, void *arena, const uint8_t *source_data, size_t source_len,
    void *out_buf, void *ctx);

/* G-02f-56 helper protos */
int32_t pipeline_resolve_path_impl(const uint8_t *path_ptr, int32_t path_len);
int32_t pipeline_read_file(void);
int32_t pipeline_parse_into_loaded_import_impl(void *arena, void *module);

/* G-02f-33 forward slots (defs near storage) */
int xlang_cstr_ends_with_dot_x(const char *s);
int xlang_asm_out_buf_is_object_magic(const unsigned char *data);
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
void xlang_pipeline_pctx_update_dep_slots_no_reset(struct ast_PipelineDepCtx *ctx, void **dep_mods,
                                                        void **dep_ar, char **import_paths, int n);
void *pipeline_run_x_thread_fn(void *arg);
int pipeline_asm_debug_enabled(void);
void pipeline_diag_merge_dep_missing(const char *import_path);
void *xlang_asm_codegen_elf_o_thread_fn(void *arg);

/* wave46–57: pure-migrated helpers live in .x under FROM_X; residual rest still calls them.
 * PLATFORM: SHARED — prototypes only when cold twin bodies are #ifndef'd out. */
#ifdef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t xlang_module_num_imports(void *module);
void xlang_module_import_path_cstr(void *module, int32_t idx, uint8_t *buf, int32_t cap);
void xlang_ptr_slot_set(void **arr, int32_t i, void *p);
void *xlang_ptr_slot_get(void **arr, int32_t i);
void xlang_i32_store(int32_t *p, int32_t v);
size_t xlang_size_slot_get(size_t *arr, int32_t i);
void xlang_size_slot_set(size_t *arr, int32_t i, size_t v);
int xlang_collect_to_load_has(char *to_load[], int to_load_n, const char *path);
/* wave54 pure strdup thin shell — pure orch / cold twins call this under hybrid. */
char *xlang_collect_strdup(const char *s);
/* wave55 pure resolve_read orch — pure load_one / paths_tmp call under hybrid. */
int xlang_load_one_direct_resolve_read_preprocess(const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir, const char *import_key, const char **defines, int ndefines, char **out_prep,
    size_t *out_prep_len);
/* wave56 pure pipeline large-stack _impl — thin pure wrappers call under hybrid. */
void *pipeline_run_x_thread_fn_impl(void *arg);
int xlang_pipeline_run_x_pipeline_large_stack_impl(void *module, void *arena, const uint8_t *source_data,
    size_t source_len, void *out_buf, void *ctx);
/* wave57 pure asm elf_o large-stack _impl — thin pure wrappers call under hybrid. */
void *xlang_asm_codegen_elf_o_thread_fn_impl(void *arg);
int32_t xlang_asm_codegen_elf_o_large_stack_impl(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf);
/* wave58 pure dep_prerun_parse_skip_typeck_impl — thin pure gate calls under hybrid. */
int xlang_pipeline_dep_prerun_parse_skip_typeck_impl(void *dep_mod, void *dep_arena, const uint8_t *src,
    size_t len, void *dep_out, void *one_ctx);
/* wave59 pure dep_prerun_parse_only_impl — thin pure gate calls under hybrid. */
int xlang_pipeline_dep_prerun_parse_only_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len);
/* wave60 pure dep_prerun_typeck_only_impl — thin pure gate calls under hybrid. */
int xlang_pipeline_dep_prerun_typeck_only_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
    void *dep_out, void *one_ctx);
/* wave61 pure preprocess_raw_to_malloc_impl — thin pure gate + load_one paths call under hybrid. */
int xlang_preprocess_raw_to_malloc_impl(const unsigned char *raw, size_t raw_len, char **out_src,
    size_t *out_src_len, const char *path_diag, const char **defines, int ndefines, int emit_diag);
/* wave62 pure one_ctx map_impl — thin pure one_ctx_for_dep_prerun + seed _impl call under hybrid. */
void xlang_pipeline_one_ctx_for_dep_prerun_map_impl(struct ast_PipelineDepCtx *ctx, void **dep_mods,
    void **dep_ars, char **dep_paths, int ndep, const uint8_t *dep_src, size_t dep_src_len);
/* wave63 pure typeck entry/sidecar/for_ctx_impl — thin pure gates call under hybrid. */
int32_t typeck_module_entry_only(void *module);
int32_t typeck_module_with_sidecar(void *module);
int32_t pipeline_typeck_module_for_ctx_impl(void *module, void *arena, void *ctx_void);
/* wave77 pure typeck dep BSS accessors — pure orch / pure with_sidecar call under hybrid. */
int32_t *typeck_ndep_slot(void);
void typeck_ndep_store_impl(int32_t n);
void *typeck_dep_module_get(int32_t i);
void *typeck_dep_arena_get(int32_t i);
void typeck_dep_module_set_impl(int32_t i, void *mod);
void typeck_dep_arena_set_impl(int32_t i, void *arena);
void *typeck_dep_module_ptrs_base(void);
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
int xlang_collect_seed_to_load(void *module, char *to_load[], int *to_load_n);
void xlang_collect_enqueue_module_imports(void *tmp_module, char *to_load[], int *to_load_n,
    char *dep_paths[], int n_loaded);
/* wave52 pure tmp_parse orch — pure paths_tmp + pure process_one call it. */
void xlang_collect_tmp_parse_and_enqueue(void **tmp_arena, void **tmp_module, size_t arena_sz, size_t module_sz,
    char *prep, size_t prep_len, const char *debug_path, char *to_load[], int *to_load_n, char *dep_paths[],
    int n_loaded);
/* wave53 pure paths_tmp orch — pure paths_process_one calls it. */
int xlang_collect_paths_tmp_resolve_parse_enqueue(char *path_c, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir_buf, const char **defines, int ndefines, void **tmp_arena, void **tmp_module,
    size_t arena_sz, size_t module_sz, char *to_load[], int *to_load_n, char *dep_paths[], int n_loaded);
/* wave48 pure process_one orch — pure transitive_impl + Cap residual may call. */
int xlang_collect_deps_process_one(char *path_c, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir_buf, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int *n, char *to_load[], int *to_load_n, void **tmp_arena, void **tmp_module,
    size_t arena_sz, size_t module_sz);
/* wave49 pure paths_process_one orch — pure paths transitive_impl calls it. */
int xlang_collect_paths_process_one(char *path_c, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir_buf, const char **defines, int ndefines, char *dep_paths[], int *n, char *to_load[],
    int *to_load_n, void **tmp_arena, void **tmp_module, size_t arena_sz, size_t module_sz);
/* wave50 pure transitive_impl orch — thin pure wrappers still call these. */
int xlang_collect_deps_transitive_impl(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_sources[],
    size_t dep_lens[], char *dep_paths[], int *n_deps);
int xlang_collect_dep_paths_transitive_impl(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_paths[], int *n_deps);
/* wave51 pure load_one orch + fail_cleanup — cold layout_impl / pure process_one call these. */
int xlang_load_one_direct_import_at(const char **lib_roots_arr, int n_lib_roots, const char *entry_dir,
    const char *import_key, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int32_t mi);
void xlang_load_direct_fail_cleanup(char *dep_sources[], char *dep_paths[], int32_t mi);
/* wave78 pure soft residual — pure emit/fclose_asm_out / free_loaded_imports call under hybrid. */
void xlang_lsp_ptr_slot_clear(void **arr, int32_t i);
void xlang_fputs_stdout(const char *s);
int driver_asm_fp_is_stdout(FILE *fp);
void driver_asm_fclose_file(FILE *fp);
/* wave79 pure OS residual — always-seed resolve_*_impl / pure resolve_file call under hybrid. */
void xlang_path_try_realpath_inplace(char *path, size_t path_size);
/* pipeline_diag_preprocess_directive_code already declared above */


#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-33 / wave73: hybrid pure owns flag BSS + slot; cold twin under #ifndef FROM_X.
 * PLATFORM: SHARED — same sticky int as pure g_pipe_diag_emitted_flag. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
static int pipeline_diag_emitted_flag;

int32_t *pipeline_diag_emitted_flag_slot(void) {
    return (int32_t *)&pipeline_diag_emitted_flag;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */
static int pipeline_last_import_open_valid;
static char pipeline_last_import_open_import[65];
static char pipeline_last_import_open_resolved[PATH_MAX];

#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_emitted_reset(void) {
  (void)(({   {
    int32_t * p = pipeline_diag_emitted_flag_slot();
    (void)(((p)[0] = 0));
  }
 }));
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_emitted_note(void) {
  (void)(({   {
    int32_t * p = pipeline_diag_emitted_flag_slot();
    (void)(((p)[0] = 1));
  }
 }));
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */

/* G-02f-227：逻辑源 .x（真迁）；seed 保留 printf 细文案 + 去重表 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
    diag_reportf_with_code(resolved_path, 0, 0, "import error", XLANG_DIAG_CODE_IMPORT_IMP001, NULL,
                 "cannot open import '%s' (tried %s)",
                 import_key,
                 resolved_key);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/* G-02f-225：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc（含 printf 细文案） */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_preprocess_unclosed_if(const char *path_diag) {
    pipeline_diag_emitted_note();
    diag_report_with_code(path_diag, 0, 0, "preprocess error", XLANG_DIAG_CODE_PREPROCESS_PP001, "unclosed #if", NULL);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-225：逻辑源 .x（真迁）；seed 保留 printf 细文案 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_preprocess_fail(const char *path_diag) {
    pipeline_diag_emitted_note();
    diag_reportf_with_code(path_diag, 0, 0, "preprocess error", XLANG_DIAG_CODE_PREPROCESS_PP002, NULL,
                 ".x preprocess failed for '%s'",
                 path_diag ? path_diag : "?");
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave46 Cap residual pure: directive code map in .x; cold twin below. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
    diag_report_with_code(path_diag, 0, 0, "preprocess error", XLANG_DIAG_CODE_PREPROCESS_PP002, msg, NULL);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-225：逻辑源 .x（真迁）；seed 保留 printf 细文案 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_import_preprocess_fail(const char *import_path, const char *resolved_path) {
    pipeline_diag_emitted_note();
    diag_reportf_with_code(resolved_path, 0, 0, "preprocess error", XLANG_DIAG_CODE_IMPORT_IMP002, NULL,
                 "preprocess failed for import '%s' (%s)",
                 import_path ? import_path : "?",
                 resolved_path ? resolved_path : "?");
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-225：逻辑源 .x（真迁）；seed 保留 printf 细文案 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_preprocess_alloc_fail(const char *path_diag, const char *what) {
    pipeline_diag_emitted_note();
    diag_reportf_with_code(path_diag, 0, 0, "pipeline error", XLANG_DIAG_CODE_X_PIPELINE_XP005, NULL,
                 "%s allocation failed during .x preprocess",
                 what ? what : "buffer");
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-225：逻辑源 .x（真迁）；seed 保留 printf 细文案 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_diag_merge_dep_missing(const char *import_path) {
    pipeline_diag_emitted_note();
    diag_reportf_with_code(import_path, 0, 0, "import error", XLANG_DIAG_CODE_IMPORT_IMP004, NULL,
                 "direct import '%s' was not found in the resolved dependency closure",
                 import_path ? import_path : "?");
    diag_report(NULL, 0, 0, "note",
                "dependency closure construction failed before merge_deps completed", NULL);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/* G-02f-116：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* wave235 G.7: XLANG_ASM_DEBUG via link_abi_getenv (not raw getenv). */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int pipeline_asm_debug_enabled(void) {
  return link_abi_getenv("XLANG_ASM_DEBUG") != NULL;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */



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
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */




/* wave82: pure owns pipeline_debug_trace_named_func_bodies_impl under PREFER FROM_X
 * (append+diag_report, no reportf). Cold twin keeps historical reportf format.
 * wave235 G.7: XLANG_DEBUG_BODY_FUNC via link_abi_getenv (not raw getenv). */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_named_func_bodies_impl(const char *phase, void *module, void *arena) {
    const char *filter = link_abi_getenv("XLANG_DEBUG_BODY_FUNC");
    int32_t nf;
    int32_t fi;
    if (!filter || !filter[0] || filter[0] == '0' || !module || !arena)
        return;
    nf = pipeline_module_num_funcs(module);
    for (fi = 0; fi < nf; fi++) {
        uint8_t raw_name[128];
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_body_x_mega_pre_reset(void *module, void *arena) {
  {
    pipeline_debug_trace_named_func_bodies("x_mega_pre_reset", module, arena);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_body_x_mega_post_reset(void *module, void *arena) {
  {
    pipeline_debug_trace_named_func_bodies("x_mega_post_reset", module, arena);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_body_x_mega_post_params(void *module, void *arena) {
  {
    pipeline_debug_trace_named_func_bodies("x_mega_post_params", module, arena);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_body_x_mega_post_frame(void *module, void *arena) {
  {
    pipeline_debug_trace_named_func_bodies("x_mega_post_frame", module, arena);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_body_x_mega_post_locals(void *module, void *arena) {
  {
    pipeline_debug_trace_named_func_bodies("x_mega_post_locals", module, arena);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_debug_trace_body_x_mega_pre_emit(void *module, void *arena) {
  {
    pipeline_debug_trace_named_func_bodies("x_mega_pre_emit", module, arena);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-240 / wave61：hybrid pure owns _impl; cold twin under #ifndef FROM_X.
 * Pure orch: scratch + define table + preprocess_x_buf + owned dup; Cap residual
 * preprocess_* engine; pure pipeline_diag_preprocess_* (oversized reportf cold-only).
 * PLATFORM: SHARED. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_preprocess_raw_to_malloc_impl(const unsigned char *raw, size_t raw_len, char **out_src,
    size_t *out_src_len, const char *path_diag, const char **defines, int ndefines, int emit_diag) {
    int di;
    if (out_src)
        *out_src = NULL;
    if (out_src_len)
        *out_src_len = 0;
    if (raw_len > (size_t)XLANG_PIPELINE_CTX_BUF_SIZE) {
        if (emit_diag) {
            diag_reportf_with_code(path_diag, 0, 0, "preprocess error", XLANG_DIAG_CODE_PREPROCESS_PP002, NULL,
                         "entry file too large for .x preprocessor (%zu > %d): '%s'",
                         raw_len,
                         XLANG_PIPELINE_CTX_BUF_SIZE,
                         path_diag ? path_diag : "?");
        }
        return -1;
    }
    uint8_t *scratch = (uint8_t *)malloc((size_t)XLANG_PIPELINE_CTX_BUF_SIZE);
    if (!scratch) {
        if (emit_diag)
            pipeline_diag_preprocess_alloc_fail(path_diag, "scratch buffer");
        return -1;
    }
    preprocess_define_reset();
    for (di = 0; di < ndefines; di++)
        if (defines && defines[di])
            preprocess_define_add(defines[di]);
    int32_t n = preprocess_x_buf(raw, (ptrdiff_t)raw_len, scratch, (int32_t)XLANG_PIPELINE_CTX_BUF_SIZE);
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
int xlang_preprocess_raw_to_malloc(const unsigned char *raw, size_t raw_len, char **out_src, size_t *out_src_len,
    const char *path_diag, const char **defines, int ndefines) {
  if (raw == NULL && raw_len > 0)
    return -1;
  if (ndefines < 0)
    return -1;
  {
    return xlang_preprocess_raw_to_malloc_impl(raw, raw_len, out_src, out_src_len, path_diag, defines, ndefines, 1);
  }
  return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */



/* G-02f-33 / wave77: hybrid pure owns typeck_ndep + typeck_dep_* table BSS + slot/get/set_impl /
 * ptrs_base; cold twins under #ifndef FROM_X keep naked C globals for cold run seed naked
 * writers. PLATFORM: SHARED LP64 — 32 void* + int ndep. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/** typeck/pipeline 兼容 dep 侧车（pipeline_gen.c get_dep_* / pipeline_set_dep；cold path）。 */
void *typeck_dep_module_ptrs[32];
void *typeck_dep_arena_ptrs[32];
int typeck_ndep;

/* G-02f-33: storage slot for cold get_ndep */
int32_t *typeck_ndep_slot(void) {
    return (int32_t *)&typeck_ndep;
}
/* wave45 / wave77 cold twin: BSS write for typeck_ndep_store orch.
 * Pure hybrid owns the cell; cold clamp orch still calls this. PLATFORM: SHARED. */
void typeck_ndep_store_impl(int32_t n) {
    typeck_ndep = n;
}
/* G-02f-223：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void typeck_ndep_store(int32_t n) {
    typeck_ndep_store_impl((n <= 32) ? ((n < 0) ? 0 : n) : 32);
}

/* G-02f-40: opaque dep pointer get/set slots for .x API (cold) */
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

/* wave63 / wave77 cold twin: base of typeck_dep_module_ptrs for with_sidecar.
 * Hybrid pure owns pure BSS base. PLATFORM: SHARED — LP64 void* table base ABI. */
void *typeck_dep_module_ptrs_base(void) {
    return (void *)typeck_dep_module_ptrs;
}
/* wave45 / wave77 cold twin: BSS write for typeck_dep_*_set orch. PLATFORM: SHARED. */
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
void typeck_dep_module_set(int32_t i, void *mod) {
    typeck_dep_module_set_impl(i, mod);
}

/* G-02f-223：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void typeck_dep_arena_set(int32_t i, void *arena) {
    typeck_dep_arena_set_impl(i, arena);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */





/**
 * 清 typeck dep 侧车；driver_dep_seeded_clear_all 调用，避免悬空指针。
 */
/* G-02f-225：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void driver_typeck_dep_sidecar_clear(void) {
    int i;
    typeck_ndep = 0;
    for (i = 0; i < 32; i++) {
        typeck_dep_arena_ptrs[i] = NULL;
        typeck_dep_module_ptrs[i] = NULL;
    }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */



/** 按 dep 下标取 module 指针；越界返回 NULL。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** 按 dep 下标取 arena 指针；越界返回 NULL。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** 当前 dep 数量。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t get_ndep(void) {
  (void)(({   {
    int32_t * p = typeck_ndep_slot();
    int32_t r = (p)[0];
    return r;
  }
 }));
  return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** pipeline_gen.c 别名：与 get_dep_module 相同。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void *typeck_get_dep_module(int32_t i) {
  return get_dep_module(i);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** pipeline_gen.c 别名：与 get_dep_arena 相同。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void *typeck_get_dep_arena(int32_t i) {
  return get_dep_arena(i);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** 写入单 dep 槽（pipeline.x 编排 import 加载时调用）。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** 设置 dep 数量上限 32。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_set_ndep(int32_t n) {
  (void)(({   {
    (void)(typeck_ndep_store(n));
  }
 }));
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

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
void xlang_import_path_to_file_path_impl(const char *lib_root, const char *import_path, char *path, size_t path_size) {
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
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_import_path_to_file_path(const char *lib_root, const char *import_path, char *path, size_t path_size) {
  if (path == NULL) {
    return;
  }
  if (path_size == 0) {
    return;
  }
  {
    xlang_import_path_to_file_path_impl(lib_root, import_path, path, path_size);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 从入口 .x 路径得到所在目录；无目录时写入 "."。
 * 参数：见 runtime_pipeline_abi.h。
 */
/* G-02f-229：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void xlang_get_entry_dir_impl(const char *input_path, char *entry_dir, size_t size) {
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
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_get_entry_dir(const char *input_path, char *entry_dir, size_t size) {
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
    xlang_get_entry_dir_impl(input_path, entry_dir, size);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 判断 import 是否为文件路径（相对/绝对/.x），而非逻辑模块名 std.io。
 * 返回值：非 0 表示文件路径形式。
 */

/* G-02f-63：真逻辑来自 .x（逐字节扫 / 魔数比较；无 _impl）。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_cstr_ends_with_dot_x(const char *s) {
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_asm_out_buf_is_object_magic(const unsigned char *data) {
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_import_path_is_file_path(const char *import_path) {
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
    if (xlang_cstr_ends_with_dot_x(import_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 将相对/绝对文件路径解析为可打开的 .x 路径（相对 entry_dir）。
 * 参数：见 runtime_pipeline_abi.h。
 */
/* wave79: hybrid pure owns xlang_path_try_realpath_inplace (g05 realpath_opaque + stack 1024 +
 * pipe_cstr_copy); cold twin under #ifndef FROM_X.
 * wave261 G.7: cold twin uses public pure thin link_abi_realpath_cap (wave218 → _impl host
 * realpath), not raw libc realpath — align with product link_abi face (pure still uses
 * xlang_driver_realpath_opaque for -E *u8/char* cast residual under g05 harness).
 * PLATFORM: SHARED — POSIX/APPLE realpath face+snprintf; non-POSIX no-op (same as pure harness null). */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/* Forward: defined in labi_path_io / mega rest (same product bag). */
extern char *link_abi_realpath_cap(const char *path, char *out);
void xlang_path_try_realpath_inplace(char *path, size_t path_size) {
    if (!path || path_size == 0)
        return;
#if defined(_POSIX_VERSION) || defined(__APPLE__)
    {
        char resolved[1024];
        if (link_abi_realpath_cap(path, resolved) != NULL)
            (void)snprintf(path, path_size, "%s", resolved);
    }
#else
    (void)path_size;
#endif
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-231：逻辑源 .x（join pure）；seed 保留同语义 C 供产品 cc */
void xlang_resolve_file_import_path_impl(const char *entry_dir, const char *import_path, char *path, size_t path_size) {
    char tmp[1024];
    if (import_path[0] == '/') {
        (void)snprintf(tmp, sizeof(tmp), "%s", import_path);
    } else if (entry_dir && entry_dir[0]) {
        (void)snprintf(tmp, sizeof(tmp), "%s/%s", entry_dir, import_path);
    } else {
        (void)snprintf(tmp, sizeof(tmp), "%s", import_path);
    }
    (void)snprintf(path, path_size, "%s", tmp);
    xlang_path_try_realpath_inplace(path, path_size);
}

/* G-02f-231：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_resolve_file_import_path(const char *entry_dir, const char *import_path, char *path, size_t path_size) {
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
    xlang_resolve_file_import_path_impl(entry_dir, import_path, path, path_size);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave76: hybrid pure owns xlang_cstr_offset (&s[off]); cold twin under #ifndef FROM_X.
 * PLATFORM: SHARED — same null / negative-off / s+off semantics as pure. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
const char *xlang_cstr_offset(const char *s, int32_t off) {
    if (!s)
        return NULL;
    if (off < 0)
        return s;
    return s + off;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 在 lib_roots 与 entry_dir 下解析 import 到可读 .x 路径。
 * 参数：见 runtime_pipeline_abi.h；未找到时 path 仍写入最后一次尝试路径。
 */
/* G-02f-232：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void xlang_resolve_import_file_path_multi_impl(const char **lib_roots, int n_lib_roots, const char *entry_dir,
    const char *import_path, char *path, size_t path_size) {
    if (xlang_import_path_is_file_path(import_path)) {
        xlang_resolve_file_import_path(entry_dir, import_path, path, path_size);
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
        xlang_import_path_to_file_path(lib_root, import_path, path, path_size);
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
            xlang_import_path_to_file_path(lib_root, import_path, path, path_size);
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
    /* wave1222: single-segment import sibling-directory scan. When `import("token")`
     * is used from parser/parser.x but token.x lives in lexer/token.x (sibling
     * directory under the same src/ root), all preceding lookups fail. Scan
     * entry_dir's parent directory for sibling subdirs containing <name>.x or
     * <name>/<name>.x. This mirrors how modern module resolvers fall back to a
     * parent-level search when a bare name is not found in the current dir.
     * PLATFORM: POSIX (opendir/readdir); Windows skips (rare in bootstrap path). */
    if (entry_dir && entry_dir[0] && path_size >= 16) {
        const char *last_slash = strrchr(entry_dir, '/');
        if (last_slash) {
            size_t parent_len = (size_t)(last_slash - entry_dir);
            if (parent_len > 0 && parent_len < 480) {
                char parent_buf[512];
                (void)memcpy(parent_buf, entry_dir, parent_len);
                parent_buf[parent_len] = '\0';
#if !defined(_WIN32) && !defined(_WIN64)
                DIR *d = opendir(parent_buf);
                if (d) {
                    struct dirent *de;
                    while ((de = readdir(d)) != NULL) {
                        const char *dn = de->d_name;
                        if (dn[0] == '.') continue;
                        if (strchr(import_path, '.') == NULL) {
                            /* Single-segment: <parent>/<sibling>/<name>.x
                             * and <parent>/<sibling>/<name>/<name>.x */
                            (void)snprintf(path, path_size, "%s/%s/%.200s.x",
                                           parent_buf, dn, import_path);
                            if (access(path, R_OK) == 0) {
                                closedir(d);
                                return;
                            }
                            int imp_n = (int)strlen(import_path);
                            if (imp_n > 0 && imp_n < 64) {
                                (void)snprintf(path, path_size, "%s/%s/%.64s/%.64s.x",
                                               parent_buf, dn, import_path, import_path);
                                if (access(path, R_OK) == 0) {
                                    closedir(d);
                                    return;
                                }
                            }
                        } else {
                            /* Dotted: <parent>/<sibling>/<dotted-as-slashes>.x
                             * e.g. import("asm.backend") from pipeline/ →
                             * <src>/asm/backend.x when sibling dir "asm" matches
                             * the first dotted segment. */
                            const char *first_dot = strchr(import_path, '.');
                            size_t first_seg_len = first_dot
                                ? (size_t)(first_dot - import_path) : 0;
                            if (first_seg_len > 0 && first_seg_len < 64 &&
                                strlen(dn) == first_seg_len &&
                                strncmp(dn, import_path, first_seg_len) == 0) {
                                size_t off = (size_t)snprintf(path, path_size,
                                    "%s/%s/", parent_buf, dn);
                                for (const char *s = import_path; *s && off + 1 < path_size; s++)
                                    path[off++] = (char)(*s == '.' ? '/' : *s);
                                if (off + 5 <= path_size) {
                                    (void)snprintf(path + off, path_size - off, ".x");
                                    if (access(path, R_OK) == 0) {
                                        closedir(d);
                                        return;
                                    }
                                }
                                if (off + 9 <= path_size) {
                                    (void)snprintf(path + off, path_size - off, "/mod.x");
                                    if (access(path, R_OK) == 0) {
                                        closedir(d);
                                        return;
                                    }
                                }
                            }
                        }
                    }
                    closedir(d);
                }
#endif
            }
        }
    }
}

/* G-02f-232：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_resolve_import_file_path_multi(const char **lib_roots, int n_lib_roots, const char *entry_dir,
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
    xlang_resolve_import_file_path_multi_impl(lib_roots, n_lib_roots, entry_dir, import_path, path, path_size);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-34 / wave74: hybrid pure owns driver_dep table BSS + slot/set/at/buf;
 * cold twins under #ifndef FROM_X. PLATFORM: SHARED LP64 — XLANG_DRIVER_DEP_SLOT_MAX=32. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/** pipeline dep 全局槽：arena/module 指针、import 路径注册表、seeded 标记。 */
static void *driver_dep_arena_ptrs[XLANG_DRIVER_DEP_SLOT_MAX];
static void *driver_dep_module_ptrs[XLANG_DRIVER_DEP_SLOT_MAX];
static const char *driver_dep_path_registry[XLANG_DRIVER_DEP_SLOT_MAX];
static int driver_dep_seeded[XLANG_DRIVER_DEP_SLOT_MAX];

/* G-02f-34: per-slot storage for .x dep_seeded get/set */
int32_t *driver_dep_seeded_slot(int32_t i) {
    if (i < 0)
        i = 0;
    if (i >= XLANG_DRIVER_DEP_SLOT_MAX)
        i = XLANG_DRIVER_DEP_SLOT_MAX - 1;
    return (int32_t *)&driver_dep_seeded[i];
}

/* G-02f-224：path registry 读槽（供 .x scan 真迁） */
const char *driver_dep_path_registry_at(int32_t i) {
    if (i < 0 || i >= XLANG_DRIVER_DEP_SLOT_MAX)
        return NULL;
    return driver_dep_path_registry[i];
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

extern size_t pipeline_sizeof_arena(void);
extern size_t pipeline_sizeof_module(void);

/**
 * 查询 dep 槽 i 是否已由 C 侧预填（pipeline 不再 read/parse）。
 * 参数：i 槽下标 0..31。
 * 返回值：1 已 seeded，0 否或 i 越界。
 */

/* G-02f-42: driver dep pointer/path slots for .x publish_slot */
/* wave74: pure owns BSS write under hybrid; cold twin under #ifndef FROM_X. PLATFORM: SHARED. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_arena_ptr_set_impl(int32_t i, void *arena) {
    if (i < 0 || i >= XLANG_DRIVER_DEP_SLOT_MAX)
        return;
    driver_dep_arena_ptrs[i] = arena;
}
void driver_dep_module_ptr_set_impl(int32_t i, void *module) {
    if (i < 0 || i >= XLANG_DRIVER_DEP_SLOT_MAX)
        return;
    driver_dep_module_ptrs[i] = module;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_arena_ptr_set(int32_t i, void *arena) {
    driver_dep_arena_ptr_set_impl(i, arena);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */


#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_module_ptr_set(int32_t i, void *module) {
    driver_dep_module_ptr_set_impl(i, module);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */




/* G-02f-224 / wave74：pure path_registry_set under hybrid; cold twin stores non-null only. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_path_registry_set(int32_t i, const char *path) {
    if (i < 0 || i >= XLANG_DRIVER_DEP_SLOT_MAX)
        return;
    if (!path)
        return;
    driver_dep_path_registry[i] = path;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 设置 dep 槽 seeded 标志（run_compiler_x_path 预填后调用）。
 * 参数：i 槽下标；v 非 0 表示 seeded。
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 批量预填 dep 槽指针并标记 seeded；entry pipeline 复用不重载。
 * 参数：arenas/modules 各 32 槽；n 有效 dep 数。
 */
/* G-02f-224：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_seed_slots(void *arenas[32], void *modules[32], int32_t n) {
    int j;
    for (j = 0; j < XLANG_DRIVER_DEP_SLOT_MAX && j < n; j++) {
        driver_dep_arena_ptrs[j] = arenas ? arenas[j] : NULL;
        driver_dep_module_ptrs[j] = modules ? modules[j] : NULL;
        driver_dep_seeded[j] = 1;
    }
    for (; j < XLANG_DRIVER_DEP_SLOT_MAX; j++)
        driver_dep_seeded[j] = 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */



/**
 * 单槽发布：dep 预跑 parse 完成后供 pipeline_load 按 import 路径绑定。
 * 参数：import_path 逻辑路径指针须存活至 clear_all（通常 dep_paths[j]）。
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 按 import 逻辑路径查 dep 预跑全局槽。
 * 返回值：槽下标 0..31，未 publish 返回 -1。
 */
/* G-02f-224：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t driver_dep_slot_for_path_scan(const char *path) {
    int i;
    for (i = 0; i < XLANG_DRIVER_DEP_SLOT_MAX; i++) {
        if (driver_dep_path_registry[i] && strcmp(driver_dep_path_registry[i], path) == 0)
            return i;
    }
    return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-224：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t driver_dep_slot_for_path(const char *path) {
  if (path == NULL) {
    return -1;
  }
  {
    return driver_dep_slot_for_path_scan(path);
  }
  return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * entry pipeline 返回后清除 seeded 与槽指针；并同步清 runtime.c typeck dep 侧车。
 */
/* G-02f-230 / wave74：pure clear_slots under hybrid; cold twin direct-writes static tables. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_seeded_clear_slots_impl(void) {
    int i;
    for (i = 0; i < XLANG_DRIVER_DEP_SLOT_MAX; i++) {
        driver_dep_seeded[i] = 0;
        driver_dep_path_registry[i] = NULL;
        driver_dep_arena_ptrs[i] = NULL;
        driver_dep_module_ptrs[i] = NULL;
    }
}

/* G-02f-230：逻辑源 .x（真迁）；产品门闩可走 impl 或与 .x 同语义循环 */
void driver_dep_seeded_clear_slots(void) {
    driver_dep_seeded_clear_slots_impl();
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-230：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void driver_dep_seeded_clear_all(void) {
  {
    driver_dep_seeded_clear_slots_impl();
    driver_typeck_dep_sidecar_clear();
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 获取 dep i 的 arena 缓冲；首访 malloc+清零，seeded 槽复用预填指针。
 * 返回值：arena 字节区或 NULL（i 越界 / OOM）。
 * wave74: pure owns under hybrid; cold twin below.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
uint8_t *driver_dep_arena_buf(int32_t i) {
    if (i < 0 || i >= XLANG_DRIVER_DEP_SLOT_MAX)
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
    if (i < 0 || i >= XLANG_DRIVER_DEP_SLOT_MAX)
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** typeck.x 导出名：转发 driver_dep_module_buf。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
uint8_t *typeck_driver_dep_module_buf(int32_t i) {
  (void)(({   {
    uint8_t * r = driver_dep_module_buf(i);
    return r;
  }
 }));
  return ((void *)(0));
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
uint8_t *typeck_driver_dep_arena_buf(int32_t i) {
  (void)(({   {
    uint8_t * r = driver_dep_arena_buf(i);
    return r;
  }
 }));
  return ((void *)(0));
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** typeck.x 导出名：转发 driver_dep_seeded_get。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t typeck_driver_dep_seeded_get(int32_t i) {
  return driver_dep_seeded_get(i);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * 在已加载 import 列表中查找下标。
 * 参数：import_path 逻辑路径；all_paths/n_all 已加载列表。
 * 返回值：下标或 -1。
 */




/* G-02f-54 helper protos */
int xlang_preprocess_raw_to_malloc_impl(const unsigned char *raw, size_t raw_len, char **out_src,
    size_t *out_src_len, const char *path_diag, const char **defines, int ndefines, int emit_diag);
void driver_dep_seed_slots_impl(void *arenas[32], void *modules[32], int32_t n);
const char *xlang_entry_lib_name_from_path_impl(const char *input_path);
const char *xlang_cstr_typeck_lit(void);

/* G-02f-53 helper protos */
void xlang_import_path_to_file_path_impl(const char *lib_root, const char *import_path, char *path, size_t path_size);
void xlang_resolve_file_import_path_impl(const char *entry_dir, const char *import_path, char *path, size_t path_size);
int32_t driver_dep_slot_for_path_scan(const char *path);

/* G-02f-52 helper protos */
void driver_typeck_dep_sidecar_clear_impl(void);
void driver_dep_seeded_clear_slots_impl(void);
void xlang_get_entry_dir_impl(const char *input_path, char *entry_dir, size_t size);
void driver_asm_fclose_asm_out_impl(FILE *fp);

/* G-02f-51 helper protos (defs later near dep_prerun) */
const char *xlang_dep_prerun_entry_dir_pick(const char *main_entry_dir, const char **lib_roots, int n_lib_roots);
int xlang_find_loaded_import_index_scan(const char *import_path, char **all_paths, int n_all);
int xlang_merge_deps_path_already_out_scan(const char *path, char *out_paths[], int n_out);
void xlang_emit_pipeline_glue_include_impl(void);
int xlang_import_dep_dir_from_path_impl(const char *path, char *dep_dir, size_t dep_dir_size);

#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_find_loaded_import_index(const char *import_path, char **all_paths, int n_all) {
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
    return xlang_find_loaded_import_index_scan(import_path, all_paths, n_all);
  }
  return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * dep 预跑 resolve import 时用 lib root（-L）优先于主文件 entry_dir。
 * 参数：main_entry_dir 入口目录；lib_roots/n_lib_roots 与 -L 一致。
 * 返回值：优先 lib_roots[0] 或 main_entry_dir。
 */

/* G-02f-223：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
const char *xlang_dep_prerun_entry_dir_pick(const char *main_entry_dir, const char **lib_roots, int n_lib_roots) {
    if (lib_roots && n_lib_roots > 0 && lib_roots[0] && lib_roots[0][0])
        return lib_roots[0];
    return main_entry_dir;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-134：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_find_loaded_import_index_scan(const char *import_path, char **all_paths, int n_all) {
    int i;
    for (i = 0; i < n_all; i++) {
        if (all_paths[i] && strcmp(all_paths[i], import_path) == 0)
            return i;
    }
    return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/* G-02f-134：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_merge_deps_path_already_out_scan(const char *path, char *out_paths[], int n_out) {
    int j;
    for (j = 0; j < n_out; j++) {
        if (out_paths[j] && strcmp(out_paths[j], path) == 0)
            return 1;
    }
    return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */
/* wave78: hybrid pure owns xlang_fputs_stdout (g05 stdout_ptr + fputs_opaque); cold twin under
 * #ifndef FROM_X. PLATFORM: SHARED — same null-skip + fputs(stdout) semantics as pure. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_fputs_stdout(const char *s) {
    if (s)
        fputs(s, stdout);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-234：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_emit_pipeline_glue_include(void) {
    fputs("\n#include \"pipeline_glue.c\"\n", stdout);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


int xlang_import_dep_dir_from_path_impl(const char *path, char *dep_dir, size_t dep_dir_size) {
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
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
const char *xlang_dep_prerun_entry_dir(const char *main_entry_dir, const char **lib_roots, int n_lib_roots) {
  {
    if (n_lib_roots <= 0) {
      return main_entry_dir;
    }
    return xlang_dep_prerun_entry_dir_pick(main_entry_dir, lib_roots, n_lib_roots);
  }
  return main_entry_dir;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * From entry .x path derive -E C lib_prefix (keywords / std_ / core_ / basename).
 * wave75: hybrid pure owns full body + typeck_lit + keyword_lit; cold twins under #ifndef.
 * PLATFORM: SHARED — same order as pure (keywords before std/stem).
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
const char *xlang_entry_lib_name_from_path_impl(const char *input_path) {
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
    /* std/xxx/mod.x → lib_prefix std_xxx；std/xxx/yyy.x → std_xxx_yyy.
     * Why: codegen mangles import("std.heap.libc") → std_heap_libc_; -E lib_prefix
     * must match. Segments after std/ joined by _; skip trailing mod; strip .x/.su.
     * PLATFORM: SHARED — compile-time path only. */
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
            size_t off = 4;  /* "std_" prefix */
            memcpy(stem_buf, "std_", 4);
            const char *p = std_seg;
            while (*p && off + 2 < sizeof(stem_buf)) {
                const char *seg_start = p;
                while (*p && *p != '/' && *p != '\\') p++;
                size_t seg_len = (size_t)(p - seg_start);
                if (seg_len >= 3 && memcmp(seg_start + seg_len - 3, ".su", 3) == 0)
                    seg_len -= 3;
                else if (seg_len >= 2 && memcmp(seg_start + seg_len - 2, ".x", 2) == 0)
                    seg_len -= 2;
                if (seg_len == 3 && memcmp(seg_start, "mod", 3) == 0) {
                    /* skip mod segment */
                } else if (seg_len > 0) {
                    if (off > 4 && off + seg_len + 1 < sizeof(stem_buf)) {
                        stem_buf[off++] = '_';
                    }
                    if (off + seg_len < sizeof(stem_buf)) {
                        memcpy(stem_buf + off, seg_start, seg_len);
                        off += seg_len;
                    }
                }
                if (*p) p++;
            }
            if (off > 4) {
                stem_buf[off] = '\0';
                return stem_buf;
            }
        }
    }
    /* core/xxx — symmetric with std/ for core_* prefix mangle. PLATFORM: SHARED. */
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
            size_t off = 5;  /* "core_" prefix */
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
                    /* skip mod */
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
    /* basename without .x/.su as lib prefix. */
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

const char *xlang_cstr_typeck_lit(void) {
    return "typeck";
}

/* G-02f-226 / wave75 cold twin: entry_lib keyword lits (0=main..9=ast; else typeck). */
const char *xlang_entry_lib_keyword_lit(int32_t k) {
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

/* G-02f-226 / wave75 cold twin: thin gate → pure-matched impl. */
const char *xlang_entry_lib_name_from_path(const char *input_path) {
  if (input_path == NULL) {
    return xlang_cstr_typeck_lit();
  }
  {
    return xlang_entry_lib_name_from_path_impl(input_path);
  }
  return NULL;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** -E 且入口为 pipeline.x 时输出 pipeline_glue.c include 行。 */


/**
 * asm 后端写出 FILE *：stdout 仅 fflush，避免 fclose(stdout)。
 * 参数：fp 汇编输出流，可为 NULL。
 */
/* wave78: hybrid pure owns driver_asm_fp_is_stdout + driver_asm_fclose_file (g05 opaque);
 * cold twins under #ifndef FROM_X. PLATFORM: SHARED. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int driver_asm_fp_is_stdout(FILE *fp) {
    return fp == stdout ? 1 : 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* 产品链与 runtime_driver_abi 同链；driver_abi 为权威定义。弱化避免 Darwin ld 双 T。 */
XLANG_WEAK void driver_asm_fflush_stdout(void) {
    fflush(stdout);
}

#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void driver_asm_fclose_file(FILE *fp) {
    if (fp)
        fclose(fp);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-234：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void driver_asm_fclose_asm_out(FILE *fp) {
    if (!fp || fp == stdout)
        fflush(stdout);
    else
        fclose(fp);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */



/**
 * 判断缓冲前缀是否为 Mach-O/ELF 对象魔数（asm_codegen_elf_o 产出检测）。
 * 参数：data/len 为 codegen out_buf 内容。
 * 返回值：非 0 表示已是对象文件字节。
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_asm_out_buf_is_object(const unsigned char *data, size_t len) {
  if (data == NULL) {
    return 0;
  }
  if (len < 4) {
    return 0;
  }
  {
    return xlang_asm_out_buf_is_object_magic(data);
  }
  return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

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
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-230：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void xlang_pipeline_fill_ctx_path_buffers_impl(struct ast_PipelineDepCtx *ctx, const char *entry_dir,
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
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_pipeline_fill_ctx_path_buffers(struct ast_PipelineDepCtx *ctx, const char *entry_dir,
    const char **lib_roots, int n_lib_roots) {
  if (ctx == NULL) {
    return;
  }
  {
    xlang_pipeline_fill_ctx_path_buffers_impl(ctx, entry_dir, lib_roots, n_lib_roots);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/**
 * 将 C 侧 dep 槽写入 PipelineDepCtx sidecar（与 ast.x pipeline_dep_ctx_* 对齐）。
 * 参数：dep_mods/dep_ar/import_paths 长度 n；ctx 输出 sidecar。
 */
/* G-02f-228：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void xlang_pipeline_pctx_seed_dep_slots_impl(struct ast_PipelineDepCtx *ctx, void **dep_mods, void **dep_ar,
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
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_pipeline_pctx_seed_dep_slots(struct ast_PipelineDepCtx *ctx, void **dep_mods, void **dep_ar,
    char **import_paths, int n) {
  if (ctx == NULL) {
    return;
  }
  {
    xlang_pipeline_pctx_seed_dep_slots_impl(ctx, dep_mods, dep_ar, import_paths, n);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/* G-02f-228：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
void xlang_pipeline_pctx_seed_dep_import_paths_only_impl(struct ast_PipelineDepCtx *ctx, char **import_paths, int n) {
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
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_pipeline_pctx_seed_dep_import_paths_only(struct ast_PipelineDepCtx *ctx, char **import_paths, int n) {
  if (ctx == NULL) {
    return;
  }
  {
    xlang_pipeline_pctx_seed_dep_import_paths_only_impl(ctx, import_paths, n);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/**
 * 更新 dep 槽 module/arena/path，不调用 ast_pipeline_dep_ctx_reset（保留 lib_root 等路径缓冲）。
 */
/* G-02f-228：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_pipeline_pctx_update_dep_slots_no_reset(struct ast_PipelineDepCtx *ctx, void **dep_mods,
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */




/** parser.x 符号（dep 预跑 import 扫描与 pipeline_parse_into_loaded_import 共用）。 */
struct parser_ParseIntoResult {
    int32_t ok;
    int32_t main_idx;
};
extern void parser_parse_into_init(void *module, void *arena);
extern struct parser_ParseIntoResult parser_parse_into(void *arena, void *module, struct xlang_slice_uint8_t *source);
extern int32_t parser_get_module_num_imports(void *module);
extern void parser_get_module_import_path(void *module, int32_t idx, uint8_t *path_buf);

/**
 * 单 dep 预跑 ctx：按 dep 自身 import 表过滤 ctx 槽（import_idx 与 ctx 下标一一对应）。
 * 勿写入 entry 全量 dep 表：coff→[elf,codegen,ast] 时 codegen 仅 import ast，ndep=3 会使 sync/typeck 错位 ec=-5。
 */
/* G-02f-233：字段写 helper（.x 早退编排调用） */
/* G-02f-233 / wave67：hybrid pure owns set_use_asm_backend thin → G.7
 * driver_pipeline_dep_ctx_set_use_asm; cold twin under #ifndef FROM_X. PLATFORM: SHARED LP64. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_dep_ctx_set_use_asm_backend(struct ast_PipelineDepCtx *ctx, int32_t v) {
    if (!ctx)
        return;
    ctx->use_asm_backend = v;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-233 / wave62：hybrid pure owns map_impl; cold twin under #ifndef FROM_X.
 * PLATFORM: SHARED — same control flow as pure orch (ok 0|-2 accept; else full slots). */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_pipeline_one_ctx_for_dep_prerun_map_impl(struct ast_PipelineDepCtx *ctx, void **dep_mods,
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
        pipe_release_tmp_arena_module(tmp_arena, tmp_module);
        xlang_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
        return;
    }
    memset(tmp_arena, 0, pipeline_sizeof_arena());
    memset(tmp_module, 0, pipeline_sizeof_module());
    parser_parse_into_init(tmp_module, tmp_arena);
    {
        struct xlang_slice_uint8_t dep_slice = { (uint8_t *)dep_src, dep_src_len };
        struct parser_ParseIntoResult pr = parser_parse_into(tmp_arena, tmp_module, &dep_slice);
        n_imp = parser_get_module_num_imports(tmp_module);
    if (pr.ok != 0 && pr.ok != -2) {
            pipe_release_tmp_arena_module(tmp_arena, tmp_module);
            xlang_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
            return;
        }
        if (n_imp <= 0) {
            pipe_release_tmp_arena_module(tmp_arena, tmp_module);
            ast_pipeline_dep_ctx_set_ndep(ctx, 0);
            return;
        }
    }
    mapped = 0;
    for (int32_t ii = 0; ii < n_imp; ii++) {
        uint8_t path_buf[128];
        char path_c[65];
        size_t k = 0;
        int g;

        parser_get_module_import_path(tmp_module, ii, path_buf);
        while (k < sizeof(path_buf) && path_buf[k]) {
            path_c[k] = (char)path_buf[k];
            k++;
        }
        path_c[k] = '\0';
        g = xlang_find_loaded_import_index(path_c, dep_paths, ndep);
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
    pipe_release_tmp_arena_module(tmp_arena, tmp_module);
    ast_pipeline_dep_ctx_set_ndep(ctx, mapped);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-233：逻辑源 .x（早退 pure）；seed 保留同语义全路径 C 供产品 cc */
void xlang_pipeline_one_ctx_for_dep_prerun_impl(struct ast_PipelineDepCtx *ctx, int j, void **dep_mods,
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
        xlang_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
        return;
    }
    xlang_pipeline_one_ctx_for_dep_prerun_map_impl(ctx, dep_mods, dep_ars, dep_paths, ndep, dep_src, dep_src_len);
}

/* G-02f-233：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_pipeline_one_ctx_for_dep_prerun(struct ast_PipelineDepCtx *ctx, int j, void **dep_mods,
                                          void **dep_ars, char **dep_paths, int ndep, const uint8_t *dep_src,
                                          size_t dep_src_len) {
  if (ctx == NULL) {
    return;
  }
  {
    xlang_pipeline_one_ctx_for_dep_prerun_impl(ctx, j, dep_mods, dep_ars, dep_paths, ndep, dep_src, dep_src_len);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/** asm 用户程序：std.io/fs/net dep 跳过 .x typeck（符号由并列 .o 提供）。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_asm_user_std_dep_skip_x_typeck(const char *dep_path) {
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** std.net dep：须 co-emit listen/accept_many，seed typeck 对 stream_* 假阳性。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_asm_user_std_net_dep_path(const char *dep_path) {
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** std.io.driver：co-emit submit_* 包装；seed typeck 对 register 假阳性。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_asm_user_std_io_driver_dep_path(const char *dep_path) {
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** dep 预跑 parse+skip typeck 路径（std.net / std.io.driver）。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_asm_user_dep_parse_skip_typeck_path(const char *dep_path) {
  {
    if (xlang_asm_user_std_net_dep_path(dep_path) != 0) {
      return 1;
    }
    if (xlang_asm_user_std_io_driver_dep_path(dep_path) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** pipeline.x 编排：entry_dir / resolved / loaded import 与 dep arena/module 槽。 */
/* wave68: hybrid pure owns entry_dir BSS; cold-only statics under #ifndef FROM_X. */
/* wave69: hybrid pure owns resolved_path BSS; cold-only static under #ifndef FROM_X. */
/* wave70: hybrid pure owns dep arena/module slot tables; cold-only statics under #ifndef FROM_X. */
/* wave72: hybrid pure owns loaded_import BSS; cold-only statics under #ifndef FROM_X. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
static char pipeline_entry_dir_buf[512];
static const char *pipeline_entry_dir = ".";
static char pipeline_resolved_path_buf[512];
static void *pipeline_dep_arena_slots[32];
static void *pipeline_dep_module_slots[32];
static char *pipeline_loaded_import_buf;
static size_t pipeline_loaded_import_len;
static size_t pipeline_loaded_import_cap;
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

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
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */




/* G-02f-226 / wave70：hybrid pure owns dep_arena/module_slot_set/at (pure BSS 32×LP64);
 * cold twins under #ifndef FROM_X share seed static tables. PLATFORM: SHARED LP64. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */




/* G-02f-231 / wave68：hybrid pure owns entry_dir_get; cold twin under #ifndef FROM_X.
 * Cold uses seed static pointer cell (may point at buf or "." lit). PLATFORM: SHARED. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
const char *pipeline_entry_dir_get(void) {
    return pipeline_entry_dir ? pipeline_entry_dir : ".";
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-237 / wave69：hybrid pure owns resolved_path_buf_slot (pure BSS 512);
 * cold twin under #ifndef FROM_X. PLATFORM: SHARED. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
char *pipeline_resolved_path_buf_slot(void) {
    return pipeline_resolved_path_buf;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** 将 import 逻辑路径解析为文件系统路径写入内部 buffer。 */
/* G-02f-237 / wave65：hybrid pure owns into_static; cold twin under #ifndef FROM_X.
 * Pure orch: G.7 pure multi + pure entry_dir_get (wave68) / pure resolved_path_buf_slot (wave69).
 * PLATFORM: SHARED. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void pipeline_resolve_path_into_static(const char *path_c) {
    const char *lib_roots[1] = { "." };
    if (!path_c)
        return;
    xlang_resolve_import_file_path_multi(lib_roots, 1, pipeline_entry_dir, path_c, pipeline_resolved_path_buf,
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** 读 resolved 路径文件并 preprocess，结果写入 loaded buffer。 */
/* G-02f-238 / wave66：stage 暂存 prep BSS（pure stage_prep / commit_prep). */
/* wave71: hybrid pure owns stage prep BSS + clear/set/take; cold-only statics under #ifndef FROM_X. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave66 / wave72: ensure loaded_import BSS, copy prep, set len, free prep.
 * Same ensure policy as historical commit_prep (cap floor XLANG_PIPELINE_IMPORT_BUF_CAP).
 * hybrid pure owns commit under FROM_X; cold twin under #ifndef. PLATFORM: SHARED. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t pipeline_loaded_import_commit_from_owned(char *prep, size_t prep_len) {
    if (!prep)
        return -1;
    if (prep_len > pipeline_loaded_import_cap || !pipeline_loaded_import_buf) {
        free(pipeline_loaded_import_buf);
        pipeline_loaded_import_cap = prep_len < XLANG_PIPELINE_IMPORT_BUF_CAP ? XLANG_PIPELINE_IMPORT_BUF_CAP
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-238 / wave66：hybrid pure owns stage_prep; cold twin under #ifndef FROM_X.
 * Pure orch: pure clear/set (wave71) + pure resolved_path_buf_slot (wave69) + runtime_read_file_view
 *   + G.7 pure xlang_preprocess_raw_to_malloc + pure diags. PLATFORM: SHARED. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t pipeline_read_file_stage_prep(void) {
    XlangRuntimeFileView raw_view;
    char *prep = NULL;
    size_t prep_len = 0;

    pipeline_rf_stage_prep_clear();

    if (runtime_read_file_view(pipeline_resolved_path_buf, &raw_view) != 0) {
        pipeline_diag_import_open_fail_once(NULL, pipeline_resolved_path_buf);
        return -1;
    }
    if (xlang_preprocess_raw_to_malloc((const unsigned char *)raw_view.data, raw_view.length, &prep, &prep_len,
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */



/** 取 dep arena 槽指针。 */
/* G-02f-226 / wave70：hybrid pure owns slot_at; cold twin under #ifndef FROM_X. PLATFORM: SHARED LP64. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** 将 loaded import 缓冲 parse 进 module。 */
/* G-02f-239 / wave72：loaded 缓冲访问 — hybrid pure owns data/len_get; cold twins under #ifndef. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
uint8_t *pipeline_loaded_import_data(void) {
    return pipeline_loaded_import_buf ? (uint8_t *)pipeline_loaded_import_buf : NULL;
}

size_t pipeline_loaded_import_len_get(void) {
    return pipeline_loaded_import_len;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-239 / wave64：hybrid pure owns pipeline_parse_into_bytes; cold twin under #ifndef FROM_X.
 * Pure orch: parser_parse_into_init + driver_parse_into_buf_rc; non-zero ok → -1.
 * wave72 pure: pipeline_loaded_import_data / len_get (BSS) for loaded_import public.
 * PLATFORM: SHARED. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t pipeline_parse_into_bytes(void *arena, void *module, uint8_t *data, size_t len) {
    struct xlang_slice_uint8_t slice;
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

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

/** Cold twin Cap-fn-ptr: opaque address of pipeline_run_x_thread_fn.
 * wave84/wave100: hybrid pure owns product surface via (fn as *u8) language residual;
 * cold full-C keeps this cast under #ifndef FROM_X (≡ pure C emit).
 * PLATFORM: SHARED — pure path no longer needs g05 xlang_driver_* harness. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
uint8_t *pipeline_run_x_thread_fn_ptr(void) {
    return (uint8_t *)(void *)pipeline_run_x_thread_fn;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** pthread 入口：跑 pipeline_run_x_pipeline 并写回 ec。 */
/* G-02f-241 / wave56：hybrid pure owns _impl; cold twin under #ifndef FROM_X.
 * XLANG_DEBUG_PIPE notes only in cold twin (pure skips). */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void *pipeline_run_x_thread_fn_impl(void *arg) {
    PipelineRunSuArgs *a = (PipelineRunSuArgs *)arg;
    if (!a)
        return NULL;
    driver_set_pipeline_entry_source_len(a->source_len);
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: pipeline thread start len=%zu", a->source_len);
    a->result = pipeline_run_x_pipeline(a->module, a->arena, a->source_data, a->source_len, a->out_buf, a->ctx);
    if (link_abi_getenv("XLANG_DEBUG_PIPE"))
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: pipeline thread done ec=%d", a->result);
    return NULL;
}

void *pipeline_run_x_thread_fn(void *arg) {
    if (!arg)
        return NULL;
    return pipeline_run_x_thread_fn_impl(arg);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */




/** 大栈 pthread 上调用 pipeline_run_x_pipeline；pthread 失败时回退当前线程。 */
/* G-02f-239 / wave56：hybrid pure owns _impl; cold twin under #ifndef FROM_X. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_pipeline_run_x_pipeline_large_stack_impl(void *module, void *arena, const uint8_t *source_data, size_t source_len,
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

int xlang_pipeline_run_x_pipeline_large_stack(void *module, void *arena, const uint8_t *source_data, size_t source_len,
    void *out_buf, void *ctx) {
    if (!module || !arena || !source_data || source_len == 0)
        return -1;
    return xlang_pipeline_run_x_pipeline_large_stack_impl(module, arena, source_data, source_len, out_buf, ctx);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */



/** dep 预跑：完整 parse，跳过 typeck/codegen。 */
/* G-02f-239 / wave58：hybrid pure owns _impl; cold twin under #ifndef FROM_X.
 * Pure orch uses G.7 driver_pipeline_dep_ctx_* asm_entry accessors (no C field).
 * PLATFORM: SHARED — same flag order as pure orch. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_pipeline_dep_prerun_parse_skip_typeck_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
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
    ec = xlang_pipeline_run_x_pipeline_large_stack(dep_mod, dep_arena, src, len, dep_out, one_ctx);
    driver_x_pipeline_skip_codegen_set(0);
    driver_x_pipeline_skip_typeck_set(0);
    if (pctx)
        pctx->asm_entry_module_only = saved_entry_only;
    driver_check_only_set(saved ? 1 : 0);
    return ec;
}

/* G-02f-239：逻辑源 .x（边界 pure）；seed 保留同语义 C 供产品 cc */
int xlang_pipeline_dep_prerun_parse_skip_typeck(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
    void *dep_out, void *one_ctx) {
    if (!dep_mod || !dep_arena || !src || len == 0)
        return -1;
    return xlang_pipeline_dep_prerun_parse_skip_typeck_impl(dep_mod, dep_arena, src, len, dep_out, one_ctx);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */



/** dep 预跑：parse+typeck（C glue 直调），跳过 codegen；勿走 X run_x_pipeline_impl（大模块 ctx 易丢）。 */
/* G-02f-typeck_only / wave60：hybrid pure owns _impl; cold twin under #ifndef FROM_X.
 * Pure orch calls pipeline_parse_set_main_from_buf_c + load_and_sync + typeck_dep_prerun;
 * XLANG_DEBUG_PIPE notes live on cold twin only. PLATFORM: SHARED. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_pipeline_dep_prerun_typeck_only_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len, void *dep_out,
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
        if (link_abi_getenv("XLANG_DEBUG_PIPE"))
            diag_reportf(NULL, 0, 0, "note", NULL,
                         "pipeline debug: dep prerun parse rc=%d", (int)parse_rc);
        return -2;
    }
    load_rc = pipeline_load_and_sync_direct_import_deps_c((struct ast_Module *)dep_mod, (struct ast_ASTArena *)dep_arena,
                                                          (struct ast_PipelineDepCtx *)one_ctx);
    if (load_rc != 0) {
        if (link_abi_getenv("XLANG_DEBUG_PIPE"))
            diag_reportf(NULL, 0, 0, "note", NULL,
                         "pipeline debug: dep prerun load rc=%d ndep=%d",
                         (int)load_rc, (int)pipeline_dep_ctx_ndep((struct ast_PipelineDepCtx *)one_ctx));
        return load_rc;
    }
    if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
        uint8_t dep_path_buf[128];
        memset(dep_path_buf, 0, sizeof(dep_path_buf));
        pipeline_dep_ctx_import_path_copy64((struct ast_PipelineDepCtx *)one_ctx, 0, dep_path_buf);
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: dep prerun call path=%s main=%d",
                     dep_path_buf[0] ? (char *)dep_path_buf : "?", (int)pipeline_module_main_func_index(dep_mod));
    }
    tc_rc = pipeline_typeck_dep_prerun_module_c((struct ast_Module *)dep_mod, (struct ast_ASTArena *)dep_arena,
                                              (struct ast_PipelineDepCtx *)one_ctx);
    if (link_abi_getenv("XLANG_DEBUG_PIPE") && tc_rc != 0)
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: dep prerun typeck rc=%d funcs=%d main=%d ctx=%p",
                     (int)tc_rc, (int)pipeline_module_num_funcs(dep_mod),
                     (int)pipeline_module_main_func_index(dep_mod), one_ctx);
    return tc_rc;
}

int xlang_pipeline_dep_prerun_typeck_only(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len, void *dep_out,
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
    return xlang_pipeline_dep_prerun_typeck_only_impl(dep_mod, dep_arena, src, len, dep_out, one_ctx);
  }
  return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-parse_only / wave59：hybrid pure owns _impl; cold twin under #ifndef FROM_X.
 * Must use pipeline_parse_set_main_from_buf_c (parse_into_with_init_buf); bare
 * parser_parse_into under-parses large std modules. PLATFORM: SHARED. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/**
 * dep 预跑：仅 parse，不做全量 typeck。
 * 须走 pipeline_parse_set_main_from_buf_c（parse_into_with_init_buf）；直调 parser_parse_into 的 slice
 * 路径对大库模块（如 std/string/mod.x）常 ok=-2 且仅 ~2 func，co-emit 缺 std_string_* 符号。
 * XLANG_ASM_DEBUG notes live on cold twin only (pure orch omits diag noise).
 */
int xlang_pipeline_dep_prerun_parse_only_impl(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len) {
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

int xlang_pipeline_dep_prerun_parse_only(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len) {
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
    return xlang_pipeline_dep_prerun_parse_only_impl(dep_mod, dep_arena, src, len);
  }
  return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** asm 单模块 -o：dep 预跑走 typeck_only。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_pipeline_dep_prerun_for_asm_module_o(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
    void *dep_out, void *one_ctx) {
    (void)driver_asm_entry_module_only_from_env;
    return xlang_pipeline_dep_prerun_typeck_only(dep_mod, dep_arena, src, len, dep_out, one_ctx);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** ast.x 模块释放；LSP import 列表清理用。 */
extern void ast_module_free(struct ast_Module *mod);

/** 从绝对/相对源文件 path 提取所在目录写入 dep_dir；供 load_one_import 递归 import 切换 dep_dir。 */
/* G-02f-223：逻辑源 .x（真迁 pure）；seed 仍可走 _impl 同语义 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_import_dep_dir_from_path(const char *path, char *dep_dir, size_t dep_dir_size) {
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
    return xlang_import_dep_dir_from_path_impl(path, dep_dir, dep_dir_size);
  }
  return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** 判断 import 路径是否已在 out_paths[0..n_out) 中（asm dep merge 去重）。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_merge_deps_path_already_out(const char *path, char *out_paths[], int n_out) {
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
    return xlang_merge_deps_path_already_out_scan(path, out_paths, n_out);
  }
  return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** parser.x：读 module import 路径与 parse_into（dep 传递闭包收集用）。 */
extern int32_t parser_get_module_num_imports(void *module);
extern void parser_get_module_import_path(void *module, int32_t idx, uint8_t *path_buf);

/**
 * build_xlang_asm（ENTRY_MODULE_ONLY + SKIP_TYPECK）：仅读入口 direct import 源码（不递归传递闭包），
 * 供 parse-only 填 dep struct layout；避免 xlang_collect_deps_transitive 耗时/失败。
 * 返回 0 成功；失败时释放已写入 dep_sources/dep_paths 并返回 1。
 */
/* wave46 pure in .x; cold twin for non-PREFER product. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/* G-02f-236：module import 计数（.x 编排） */
int32_t xlang_module_num_imports(void *module) {
    if (!module)
        return 0;
    return parser_get_module_num_imports(module);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave55 pure in .x; cold twin for non-PREFER product.
 * wave51 Cap residual always-seed → wave55 pure orch (stack PATH + FileView + pure resolve/preprocess).
 * Pure load_one orch stores dep slots; paths_tmp reuses this (G.7).
 * PLATFORM: SHARED — PATH_MAX stack + XlangRuntimeFileView cold twin only. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_load_one_direct_resolve_read_preprocess(const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir, const char *import_key, const char **defines, int ndefines, char **out_prep,
    size_t *out_prep_len) {
    char resolved[PATH_MAX];
    XlangRuntimeFileView raw_view;
    size_t prep_len = 0;
    char *prep = NULL;

    if (out_prep)
        *out_prep = NULL;
    if (out_prep_len)
        *out_prep_len = 0;
    if (!import_key || !out_prep || !out_prep_len)
        return 1;
    xlang_resolve_import_file_path_multi(lib_roots_arr, n_lib_roots, entry_dir, import_key, resolved,
        sizeof(resolved));
    if (runtime_read_file_view(resolved, &raw_view) != 0) {
        pipeline_diag_import_open_fail_once(import_key, resolved);
        return 1;
    }
    if (xlang_preprocess_raw_to_malloc((const unsigned char *)raw_view.data, raw_view.length, &prep, &prep_len,
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave51 pure in .x; cold twin for non-PREFER product.
 * G-02f-236：单项 Cap residual resolve/read/preprocess + store dep 槽 mi；0 成功，1 失败。
 * Cold uses libc strdup (same as historical); pure orch uses Cap residual xlang_collect_strdup. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_load_one_direct_import_at(const char **lib_roots_arr, int n_lib_roots, const char *entry_dir,
    const char *import_key, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int32_t mi) {
    size_t prep_len = 0;
    char *prep = NULL;

    if (!import_key || mi < 0)
        return 1;
    if (xlang_load_one_direct_resolve_read_preprocess(lib_roots_arr, n_lib_roots, entry_dir, import_key, defines,
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave51 pure in .x; cold twin for non-PREFER product.
 * G-02f-236：失败时释放 0..mi-1 已写 dep_sources/dep_paths */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_load_direct_fail_cleanup(char *dep_sources[], char *dep_paths[], int32_t mi) {
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-236：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc（cold only under non-FROM_X） */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_load_direct_imports_for_asm_layout_impl(void *module, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int *out_n) {
    int32_t n_imports = xlang_module_num_imports(module);
    int mi = 0;

    *out_n = 0;
    if (n_imports <= 0)
        return 0;
    for (int i = 0; i < n_imports && i < XLANG_DRIVER_DEP_SLOT_MAX && mi < XLANG_DRIVER_DEP_SLOT_MAX; i++) {
        uint8_t path_buf[128];
        char path_c[65];
        size_t k = 0;

        parser_get_module_import_path(module, i, path_buf);
        while (k < sizeof(path_buf) && path_buf[k] && k < 64) {
            path_c[k] = (char)path_buf[k];
            k++;
        }
        path_c[k] = '\0';
        if (xlang_load_one_direct_import_at(lib_roots_arr, n_lib_roots, entry_dir, path_c, defines, ndefines,
                dep_sources, dep_lens, dep_paths, mi) != 0) {
            xlang_load_direct_fail_cleanup(dep_sources, dep_paths, mi);
            *out_n = 0;
            return 1;
        }
        mi++;
    }
    *out_n = mi;
    return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-236：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_load_direct_imports_for_asm_layout(void *module, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int *out_n) {
  if (module == NULL) {
    return -1;
  }
  if (out_n == NULL) {
    return -1;
  }
  {
    return xlang_load_direct_imports_for_asm_layout_impl(module, lib_roots_arr, n_lib_roots, entry_dir, defines, ndefines, dep_sources, dep_lens, dep_paths, out_n);
  }
  return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/**
 * 将 xlang_collect_deps_transitive 得到的 closure（调用方已对 triple 数组做过反转）合并为 pipeline/asm_elf dep 列表。
 * 前 n_imports 项与入口 module import 槽对齐；传递依赖按 closure 顺序追加并路径去重。
 */
/* wave46 pure in .x; cold twin for non-PREFER product. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/* G-02f-235：size_t 槽读写（.x merge deps pure） */
size_t xlang_size_slot_get(size_t *arr, int32_t i) {
    if (!arr || i < 0)
        return 0;
    return arr[i];
}

void xlang_size_slot_set(size_t *arr, int32_t i, size_t v) {
    if (!arr || i < 0)
        return;
    arr[i] = v;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-235：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int xlang_merge_direct_then_transitive_deps_impl(void *module, int32_t n_imports, char *cls[], size_t clens[], char *cpaths[],
    int n_closure, char *out_src[], size_t out_lens[], char *out_paths[], int *out_n) {
    unsigned char used[XLANG_DRIVER_DEP_SLOT_MAX];
    int mi = 0;

    memset(used, 0, sizeof used);
    for (int i = 0; i < n_imports && i < XLANG_DRIVER_DEP_SLOT_MAX && mi < XLANG_DRIVER_DEP_SLOT_MAX; i++) {
        uint8_t path_buf[128];
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
    for (int kj = 0; kj < n_closure && mi < XLANG_DRIVER_DEP_SLOT_MAX; kj++) {
        if (!used[kj]) {
            if (cpaths[kj] && xlang_merge_deps_path_already_out(cpaths[kj], out_paths, mi)) {
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
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_merge_direct_then_transitive_deps(void *module, int32_t n_imports, char *cls[], size_t clens[], char *cpaths[],
    int n_closure, char *out_src[], size_t out_lens[], char *out_paths[], int *out_n) {
  if (module == NULL) {
    return -1;
  }
  if (out_n == NULL) {
    return -1;
  }
  {
    return xlang_merge_direct_then_transitive_deps_impl(module, n_imports, cls, clens, cpaths, n_closure, out_src, out_lens, out_paths, out_n);
  }
  return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/* wave46 pure in .x; cold twins for non-PREFER product. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/* G-02f-234：import path 拷到 C 字符串（供 .x merge pure） */
void xlang_module_import_path_cstr(void *module, int32_t idx, uint8_t *buf, int32_t cap) {
    uint8_t path_buf[128];
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

void xlang_ptr_slot_set(void **arr, int32_t i, void *p) {
    if (!arr || i < 0)
        return;
    arr[i] = p;
}

/* G.7 expand set authority: load pointer array slot i (argv/paths). PLATFORM: SHARED. */
void *xlang_ptr_slot_get(void **arr, int32_t i) {
    if (!arr || i < 0)
        return NULL;
    return arr[i];
}

void xlang_i32_store(int32_t *p, int32_t v) {
    if (p)
        *p = v;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-234：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int xlang_merge_direct_then_transitive_dep_paths_impl(void *module, int32_t n_imports, char *cpaths[], int n_closure,
    char *out_paths[], int *out_n) {
    unsigned char used[XLANG_DRIVER_DEP_SLOT_MAX];
    int mi = 0;

    memset(used, 0, sizeof used);
    for (int i = 0; i < n_imports && i < XLANG_DRIVER_DEP_SLOT_MAX && mi < XLANG_DRIVER_DEP_SLOT_MAX; i++) {
        uint8_t path_buf[128];
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
        if (found >= 0 && found < XLANG_DRIVER_DEP_SLOT_MAX)
            used[found] = 1;
        mi++;
    }
    for (int kj = 0; kj < n_closure && mi < XLANG_DRIVER_DEP_SLOT_MAX; kj++) {
        if (!used[kj]) {
            if (cpaths[kj] && xlang_merge_deps_path_already_out(cpaths[kj], out_paths, mi)) {
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
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_merge_direct_then_transitive_dep_paths(void *module, int32_t n_imports, char *cpaths[], int n_closure,
    char *out_paths[], int *out_n) {
  if (module == NULL) {
    return -1;
  }
  if (out_n == NULL) {
    return -1;
  }
  {
    return xlang_merge_direct_then_transitive_dep_paths_impl(module, n_imports, cpaths, n_closure, out_paths, out_n);
  }
  return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/**
 * 传递加载 dep：从 main 的 import 出发递归解析子 import，填满 dep_sources/dep_lens/dep_paths。
 * 返回 0 成功，1 失败（调用方负责释放已分配）。
 */
/* wave54 pure in .x; cold twin for non-PREFER product (wraps libc strdup).
 * PLATFORM: SHARED — null s → null; free() still releases ownership. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
char *xlang_collect_strdup(const char *s) {
    if (!s)
        return NULL;
    return strdup(s);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave47 pure in .x; cold twin for non-PREFER product. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/* G-02f-238：入口 import → to_load 队列（strdup）；0 成功，1 OOM（已清队列） */
int xlang_collect_seed_to_load(void *module, char *to_load[], int *to_load_n) {
    int32_t n_imports;
    int j;

    if (!to_load || !to_load_n)
        return 1;
    *to_load_n = 0;
    n_imports = xlang_module_num_imports(module);
    for (j = 0; j < n_imports && j < XLANG_DRIVER_DEP_SLOT_MAX && *to_load_n < XLANG_DRIVER_DEP_SLOT_MAX; j++) {
        uint8_t path_buf[128];
        char path_c[65];
        size_t k = 0;

        parser_get_module_import_path(module, j, path_buf);
        while (k < sizeof(path_buf) && path_buf[k]) {
            path_c[k] = (char)path_buf[k];
            k++;
        }
        path_c[k] = '\0';
        to_load[*to_load_n] = xlang_collect_strdup(path_c);
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave46 pure in .x; cold twin for non-PREFER product. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/* G-02f-238：to_load 是否已有 path */
int xlang_collect_to_load_has(char *to_load[], int to_load_n, const char *path) {
    int t;
    if (!to_load || !path)
        return 0;
    for (t = 0; t < to_load_n; t++) {
        if (to_load[t] && strcmp(to_load[t], path) == 0)
            return 1;
    }
    return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave47 pure in .x; cold twin for non-PREFER product. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/* G-02f-239：从已 parse 的 tmp_module 入队子 import（未 loaded / 未在 to_load） */
void xlang_collect_enqueue_module_imports(void *tmp_module, char *to_load[], int *to_load_n, char *dep_paths[],
    int n_loaded) {
    int n_imp;
    int jj;
    if (!tmp_module || !to_load || !to_load_n)
        return;
    n_imp = parser_get_module_num_imports(tmp_module);
    if (n_imp <= 0)
        return;
    for (jj = 0; jj < n_imp && jj < XLANG_DRIVER_DEP_SLOT_MAX && *to_load_n < XLANG_DRIVER_DEP_SLOT_MAX; jj++) {
        uint8_t sub_buf[128];
        char sub_c[65];
        size_t kk = 0;

        parser_get_module_import_path(tmp_module, jj, sub_buf);
        while (kk < sizeof(sub_buf) && sub_buf[kk]) {
            sub_c[kk] = (char)sub_buf[kk];
            kk++;
        }
        sub_c[kk] = '\0';
        if (xlang_find_loaded_import_index(sub_c, dep_paths, n_loaded) >= 0)
            continue;
        if (xlang_collect_to_load_has(to_load, *to_load_n, sub_c))
            continue;
        to_load[*to_load_n] = xlang_collect_strdup(sub_c);
        if (!to_load[*to_load_n])
            continue;
        (*to_load_n)++;
    }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave52 pure in .x; cold twin for non-PREFER product.
 * wave48 Cap residual was always-seed; now pure orch + cold twin under #ifndef FROM_X.
 * Ensure tmp arena/module, parse prep bytes, enqueue sub-imports.
 * PLATFORM: SHARED — cold keeps XLANG_DEBUG_PIPE note; pure skips debug-only note. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_collect_tmp_parse_and_enqueue(void **tmp_arena, void **tmp_module, size_t arena_sz, size_t module_sz,
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
            if (link_abi_getenv("XLANG_DEBUG_PIPE")) {
                diag_reportf(NULL, 0, 0, "note", NULL,
                             "pipeline debug: collect parse dep=%s pr_ok=%d n_imp=%d",
                             debug_path ? debug_path : "?", pr_rc == 0 ? 1 : 0, n_imp);
            }
            (void)n_imp;
            xlang_collect_enqueue_module_imports(*tmp_module, to_load, to_load_n, dep_paths, n_loaded);
        }
    }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave48 pure in .x; cold twin for non-PREFER product.
 * G-02f-241：处理 to_load 一项（owned path_c）；0 继续，1 失败。*n 递增；可更新 tmp_* / to_load
 * Cold body uses Cap residual load_one + tmp_parse_and_enqueue (same as pure orch). */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_collect_deps_process_one(char *path_c, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir_buf, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int *n, char *to_load[], int *to_load_n, void **tmp_arena, void **tmp_module,
    size_t arena_sz, size_t module_sz) {
    int mi;

    if (!path_c || !n || !to_load || !to_load_n || !tmp_arena || !tmp_module)
        return 1;
    if (xlang_find_loaded_import_index(path_c, dep_paths, *n) >= 0) {
        free(path_c);
        return 0;
    }
    mi = *n;
    /* G.7: resolve+read+preprocess+store slot is Cap residual load_one_direct_import_at. */
    if (xlang_load_one_direct_import_at(lib_roots_arr, n_lib_roots, entry_dir_buf, path_c, defines, ndefines,
            dep_sources, dep_lens, dep_paths, mi) != 0) {
        free(path_c);
        return 1;
    }
    free(path_c);
    if (!dep_paths[mi])
        return 1;
    (*n) = mi + 1;
    xlang_collect_tmp_parse_and_enqueue(tmp_arena, tmp_module, arena_sz, module_sz, dep_sources[mi], dep_lens[mi],
        dep_paths[mi], to_load, to_load_n, dep_paths, *n);
    return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave50 pure in .x; cold twin for non-PREFER product.
 * G-02f-237：seed queue + process_one drain + free leftovers / fail partial deps.
 * Cold body mirrors pure orch (stack to_load + tmp cells via locals). */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_collect_deps_transitive_impl(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_sources[],
    size_t dep_lens[], char *dep_paths[], int *n_deps) {
    int n = 0;
    char *to_load[XLANG_DRIVER_DEP_SLOT_MAX];
    int to_load_n = 0;
    void *tmp_arena = NULL;
    void *tmp_module = NULL;

    if (xlang_collect_seed_to_load(module, to_load, &to_load_n) != 0)
        goto fail_to_load;
    while (to_load_n > 0 && n < XLANG_DRIVER_DEP_SLOT_MAX) {
        char *path_c = to_load[--to_load_n];
        if (xlang_collect_deps_process_one(path_c, lib_roots_arr, n_lib_roots, entry_dir_buf, defines, ndefines,
                dep_sources, dep_lens, dep_paths, &n, to_load, &to_load_n, &tmp_arena, &tmp_module, arena_sz,
                module_sz) != 0)
            goto fail_to_load;
    }
    while (to_load_n > 0) {
        to_load_n--;
        free(to_load[to_load_n]);
    }
    pipe_release_tmp_arena_module(tmp_arena, tmp_module);
    *n_deps = n;
    return 0;
fail_to_load:
    while (to_load_n > 0) {
        to_load_n--;
        free(to_load[to_load_n]);
    }
    pipe_release_tmp_arena_module(tmp_arena, tmp_module);
    while (n > 0) {
        n--;
        free(dep_sources[n]);
        free(dep_paths[n]);
    }
    return 1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-237：逻辑源 .x（空 import 早退 pure）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_collect_deps_transitive(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_sources[],
    size_t dep_lens[], char *dep_paths[], int *n_deps) {
  if (module == NULL) {
    return -1;
  }
  if (n_deps == NULL) {
    return -1;
  }
  if (xlang_module_num_imports(module) <= 0) {
    *n_deps = 0;
    return 0;
  }
  {
    return xlang_collect_deps_transitive_impl(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir_buf, defines, ndefines, dep_sources, dep_lens, dep_paths, n_deps);
  }
  return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/* wave53 pure in .x; cold twin for non-PREFER product.
 * ensure tmp; Cap residual resolve/read/preprocess path_c; G.7 pure tmp_parse; free prep.
 * Pure paths_process_one orch calls this after registering owned dep_paths key.
 * If tmp malloc fails: no-op success (path already registered; same as historical body).
 * wave51/wave55: G.7 reuses pure xlang_load_one_direct_resolve_read_preprocess (no dual FILE/PATH_MAX body).
 * wave52: G.7 pure tmp_parse_and_enqueue (FROM_X weak pure; cold twin under #ifndef).
 * PLATFORM: SHARED — Cap residual resolve/read/preprocess + G.7 tmp_parse_and_enqueue. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_collect_paths_tmp_resolve_parse_enqueue(char *path_c, const char **lib_roots_arr, int n_lib_roots,
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
    if (xlang_load_one_direct_resolve_read_preprocess(lib_roots_arr, n_lib_roots, entry_dir_buf, path_c, defines,
            ndefines, &prep, &prep_len) != 0)
        return 1;
    xlang_collect_tmp_parse_and_enqueue(tmp_arena, tmp_module, arena_sz, module_sz, prep, prep_len, path_c, to_load,
        to_load_n, dep_paths, n_loaded);
    free(prep);
    return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave49 pure in .x; cold twin for non-PREFER product.
 * G-02f-241：paths-only process one（owned path_c）；0 继续，1 失败
 * Cold body mirrors pure orch: strdup key + Cap residual resolve/parse. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_collect_paths_process_one(char *path_c, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir_buf, const char **defines, int ndefines, char *dep_paths[], int *n, char *to_load[],
    int *to_load_n, void **tmp_arena, void **tmp_module, size_t arena_sz, size_t module_sz) {
    int mi;
    char *key;
    int rc;

    if (!path_c || !n || !to_load || !to_load_n || !tmp_arena || !tmp_module)
        return 1;
    if (xlang_find_loaded_import_index(path_c, dep_paths, *n) >= 0) {
        free(path_c);
        return 0;
    }
    mi = *n;
    key = xlang_collect_strdup(path_c);
    if (!key) {
        free(path_c);
        return 1;
    }
    dep_paths[mi] = key;
    (*n) = mi + 1;
    rc = xlang_collect_paths_tmp_resolve_parse_enqueue(path_c, lib_roots_arr, n_lib_roots, entry_dir_buf, defines,
        ndefines, tmp_arena, tmp_module, arena_sz, module_sz, to_load, to_load_n, dep_paths, *n);
    free(path_c);
    return rc;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave50 pure in .x; cold twin for non-PREFER product.
 * paths-only transitive: same orch as deps_transitive_impl without sources/lens. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_collect_dep_paths_transitive_impl(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_paths[], int *n_deps) {
    int n = 0;
    char *to_load[XLANG_DRIVER_DEP_SLOT_MAX];
    int to_load_n = 0;
    void *tmp_arena = NULL;
    void *tmp_module = NULL;

    if (xlang_collect_seed_to_load(module, to_load, &to_load_n) != 0)
        goto fail_to_load;
    while (to_load_n > 0 && n < XLANG_DRIVER_DEP_SLOT_MAX) {
        char *path_c = to_load[--to_load_n];
        if (xlang_collect_paths_process_one(path_c, lib_roots_arr, n_lib_roots, entry_dir_buf, defines, ndefines,
                dep_paths, &n, to_load, &to_load_n, &tmp_arena, &tmp_module, arena_sz, module_sz) != 0)
            goto fail_to_load;
    }
    while (to_load_n > 0) {
        to_load_n--;
        free(to_load[to_load_n]);
    }
    pipe_release_tmp_arena_module(tmp_arena, tmp_module);
    *n_deps = n;
    return 0;
fail_to_load:
    while (to_load_n > 0) {
        to_load_n--;
        free(to_load[to_load_n]);
    }
    pipe_release_tmp_arena_module(tmp_arena, tmp_module);
    while (n > 0) {
        n--;
        free(dep_paths[n]);
    }
    return 1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* G-02f-237：逻辑源 .x（空 import 早退 pure）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int xlang_collect_dep_paths_transitive(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_paths[], int *n_deps) {
  if (module == NULL) {
    return -1;
  }
  if (n_deps == NULL) {
    return -1;
  }
  if (xlang_module_num_imports(module) <= 0) {
    *n_deps = 0;
    return 0;
  }
  {
    return xlang_collect_dep_paths_transitive_impl(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir_buf, defines, ndefines, dep_paths, n_deps);
  }
  return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/** asm emit 桩判定与 ARRAY_LIT/SoA 补类型（ast_pool.c / pipeline_glue.c）。 */
extern void asm_skip_heavy_set_pipeline_ctx(void *ctx);
extern void pipeline_fill_array_lit_types_for_skipped_typeck(void *m, void *arena);
extern void typeck_soa_fill_field_access_for_asm_emit(void *m, void *arena);
extern void pipeline_module_fixup_with_arena_stmt_orders(void *m, void *arena);

/** asm_codegen_elf_o 前：设置 skip_heavy 上下文并为 ARRAY_LIT / SoA field 补类型。 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_driver_asm_prepare_entry_elf_emit(void *module, void *arena, void *pctx) {
  {
    asm_skip_heavy_set_pipeline_ctx(pctx);
    pipeline_fill_array_lit_types_for_skipped_typeck(module, arena);
    typeck_soa_fill_field_access_for_asm_emit(module, arena);
    pipeline_debug_trace_named_func_bodies("emit_prepare_pre_fixup", module, arena);
    pipeline_module_fixup_with_arena_stmt_orders(module, arena);
    pipeline_debug_trace_named_func_bodies("emit_prepare_post_fixup", module, arena);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */


/** pthread 大栈 emit 参数包。 */
typedef struct {
    void *module;
    void *arena;
    void *ctx;
    struct platform_elf_ElfCodegenCtx *elf_ctx;
    void *out_buf;
    int32_t result;
} XlangAsmCodegenElfLargeArgs;

extern int32_t asm_asm_codegen_elf_o(void *module, void *arena, void *ctx, struct platform_elf_ElfCodegenCtx *elf_ctx,
    void *out_buf);

/** Product asm elf_o emit trampoline (wave80: hybrid pure owns thin; cold twin below).
 * Forwards to strong asm_asm_codegen_elf_o (user_asm_seed_bridge at final link).
 * Cold full-C TU has no pure weak -1 stub — direct call is safe.
 * PLATFORM: SHARED. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t xlang_asm_codegen_elf_o_product_emit(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf) {
    return asm_asm_codegen_elf_o(module, arena, ctx, elf_ctx, out_buf);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** Cold twin Cap-fn-ptr: opaque address of xlang_asm_codegen_elf_o_thread_fn.
 * wave84/wave100: hybrid pure owns product surface via (fn as *u8) language residual;
 * cold full-C keeps this cast under #ifndef FROM_X (≡ pure C emit).
 * PLATFORM: SHARED — pure path no longer needs g05 xlang_driver_* harness. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
uint8_t *xlang_asm_codegen_elf_o_thread_fn_ptr(void) {
    return (uint8_t *)(void *)xlang_asm_codegen_elf_o_thread_fn;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** pthread 入口：调用 product emit 并将 ec 写入 args->result。 */
/* G-02f-241 / wave57：hybrid pure owns _impl; cold twin under #ifndef FROM_X. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void *xlang_asm_codegen_elf_o_thread_fn_impl(void *arg) {
    XlangAsmCodegenElfLargeArgs *a = (XlangAsmCodegenElfLargeArgs *)arg;
    if (!a)
        return NULL;
    a->result = asm_asm_codegen_elf_o(a->module, a->arena, a->ctx, a->elf_ctx, a->out_buf);
    return NULL;
}

void *xlang_asm_codegen_elf_o_thread_fn(void *arg) {
    if (!arg)
        return NULL;
    return xlang_asm_codegen_elf_o_thread_fn_impl(arg);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */




/** 在 256MiB 栈 pthread 上调用 asm_asm_codegen_elf_o；主线程栈已深时避免 lexer emit Abort。 */
/* G-02f-240 / wave57：hybrid pure owns _impl; cold twin under #ifndef FROM_X. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t xlang_asm_codegen_elf_o_large_stack_impl(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf) {
    XlangAsmCodegenElfLargeArgs args;

    args.module = module;
    args.arena = arena;
    args.ctx = ctx;
    args.elf_ctx = elf_ctx;
    args.out_buf = out_buf;
    args.result = -99;
    driver_run_thread_on_large_stack(xlang_asm_codegen_elf_o_thread_fn, &args);
    if (args.result == -99)
        return asm_asm_codegen_elf_o(module, arena, ctx, elf_ctx, out_buf);
    return args.result;
}

/* G-02f-240：逻辑源 .x（边界 pure）；seed 保留同语义 C 供产品 cc */
int32_t xlang_asm_codegen_elf_o_large_stack(void *module, void *arena, void *ctx,
    struct platform_elf_ElfCodegenCtx *elf_ctx, void *out_buf) {
    if (!module || !arena || !out_buf)
        return -1;
    return xlang_asm_codegen_elf_o_large_stack_impl(module, arena, ctx, elf_ctx, out_buf);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */




/* wave87: product typeck authority is typeck_x_ast* (typeck.x); C typeck_module deleted. */
extern int32_t typeck_x_ast(void *module, void *arena, void *ctx);
extern int32_t typeck_x_ast_library(void *module, void *arena, void *ctx);
extern int32_t pipeline_module_main_func_index(void *module);

/**
 * Historical C typeck surfaces + product force_c for_ctx.
 * wave87: for_ctx_impl routes to typeck_x_ast / typeck_x_ast_library (G.7 single authority).
 * entry_only / with_sidecar fail-closed (-1): X frontend needs arena+ctx via for_ctx.
 * XLANG_NO_C_FRONTEND: still export symbols for pipeline_asm_typecheck_alias link.
 * G-02f-242 / wave63 / wave87: hybrid pure owns bodies; cold twins under #ifndef FROM_X.
 * PLATFORM: SHARED.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
int32_t typeck_module_entry_only(void *module) {
    if (!module)
        return -1;
    /* No arena/ctx — cannot call typeck_x_ast. Use pipeline_typeck_module_for_ctx. */
    return -1;
}

int32_t typeck_module_with_sidecar(void *module) {
    if (!module)
        return -1;
    /* C sidecar BSS obsolete under X frontend (deps live in PipelineDepCtx). */
    return -1;
}

int32_t pipeline_typeck_module_for_ctx_impl(void *module, void *arena, void *ctx_void) {
    int32_t mi;
    int32_t rc;
    if (!module)
        return -1;
    if (!arena || !ctx_void)
        return -1;
    mi = pipeline_module_main_func_index(module);
    if (mi < 0)
        rc = typeck_x_ast_library(module, arena, ctx_void);
    else
        rc = typeck_x_ast(module, arena, ctx_void);
    if (rc != 0)
        return -1;
    return 0;
}

/* G-02f-242：逻辑源 .x（真迁门闩）；seed 保留同语义 C 供产品 cold */
int32_t pipeline_typeck_module_for_ctx(void *module, void *arena, void *ctx_void) {
  if (module == NULL) {
    return -1;
  }
  {
    return pipeline_typeck_module_for_ctx_impl(module, arena, ctx_void);
  }
  return -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/** 释放 xlang_lsp_resolve_and_load_imports 写入的 all_dep_mods / all_dep_paths（不含 entry 模块本身）。 */
/* wave78: hybrid pure owns xlang_lsp_ptr_slot_clear (G.7 xlang_ptr_slot_set null); cold twin under
 * #ifndef FROM_X. PLATFORM: SHARED. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_lsp_ptr_slot_clear(void **arr, int32_t i) {
    if (!arr || i < 0)
        return;
    arr[i] = NULL;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

void xlang_lsp_free_loaded_imports_impl(void **all_dep_mods, char **all_dep_paths, int n_all) {
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
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void xlang_lsp_free_loaded_imports(struct ast_Module **all_dep_mods, char **all_dep_paths, int n_all) {
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
    xlang_lsp_free_loaded_imports_impl((void **)all_dep_mods, all_dep_paths, n_all);
  }
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/**
 * Public preprocess surface (wave81: hybrid pure owns; cold twin under #ifndef FROM_X).
 * Product pure thin → G.7 xlang_preprocess_raw_to_malloc_impl; cold keeps LEGACY
 * preprocess_c_fallback when !XLANG_USE_X_PIPELINE || XLANG_LEGACY_PREPROCESS_C.
 * PLATFORM: SHARED.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
char *xlang_preprocess(const char *source, size_t source_len, const char **defines, int ndefines, size_t *out_length) {
    return xlang_preprocess_quiet(source, source_len, defines, ndefines, out_length);
}

char *xlang_preprocess_with_path(const char *source, size_t source_len, const char *path_diag,
    const char **defines, int ndefines, size_t *out_length) {
    size_t slen;

    if (out_length)
        *out_length = 0;
    if (!source)
        return NULL;
#if defined(XLANG_USE_X_PIPELINE) && !defined(XLANG_LEGACY_PREPROCESS_C)
    slen = source_len ? source_len : strlen(source);
    {
        char *out = NULL;
        size_t olen = 0;

        if (xlang_preprocess_raw_to_malloc_impl((const unsigned char *)source, slen, &out, &olen, path_diag,
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

char *xlang_preprocess_quiet(const char *source, size_t source_len, const char **defines, int ndefines, size_t *out_length) {
    size_t slen;

    if (out_length)
        *out_length = 0;
    if (!source)
        return NULL;
#if defined(XLANG_USE_X_PIPELINE) && !defined(XLANG_LEGACY_PREPROCESS_C)
    slen = source_len ? source_len : strlen(source);
    {
        char *out = NULL;
        size_t olen = 0;

        if (xlang_preprocess_raw_to_malloc_impl((const unsigned char *)source, slen, &out, &olen, NULL,
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
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

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
 *      XLANG_WEAK is empty on PE/MinGW, so the stubs compiled as STRONG defs;
 *      runtime_pipeline_abi.o is ordered BEFORE parser_x.o in DRIVER_SEED_OBJS,
 *      so with --allow-multiple-definition the empty `parser_parse_into_init`
 *      (a no-op that skips ast_ast_arena_init / ast_pool_module_reset /
 *      parser_onefunc_result_layout_prime) won over parser_x.o's real impl,
 *      leaving the module uninitialised → driver_first_parse num_funcs=0
 *      → silent parser failure on every `xlang -c/-E/build/run` invocation.
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
 *            typeck_soa_fill_field_access_for_asm_emit,
 *            pipeline_module_fixup_with_arena_stmt_orders,
 *            asm_asm_codegen_elf_o, pipeline_parse_set_main_from_buf_c) MUST
 *            be provided as a strong definition by some .o in
 *            DRIVER_SEED_OBJS / BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS. Verified
 *            on macOS via `nm xlang` (all 10 symbols present as T).
 * PLATFORM: SHARED — block removal is a no-op on macOS/Linux (block was
 *           already skipped via `#ifdef _WIN32`); on Windows it eliminates
 *           the duplicate authority so the real impls from parser_x.o etc.
 *           are linked, matching macOS behaviour.
 */

/* wave101 import_bind leave cold twins — former pipeline_import_bind.c
 * faces when PREFER=0 (full seed, no pure thin). Under FROM_X (PREFER thin+rest)
 * omitted; pure thin owns. PLATFORM: SHARED — match runtime_pipeline_abi.x.
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/* Prefer existing seed faces; cast only. */
extern uint8_t *pipeline_dep_ctx_path_buf_ptr(void *ctx);
extern uint8_t *pipeline_dep_ctx_loaded_buf_ptr(void *ctx);
extern void pipeline_dep_ctx_set_loaded_len(void *ctx, int64_t n);
extern uint8_t *pipeline_dep_ctx_preprocess_buf_ptr(void *ctx);
extern int32_t preprocess_x_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out, int32_t out_cap);
extern int32_t driver_dep_seeded_get(int32_t i);
extern int32_t parser_copy_module_import_path64(void *module, int32_t i, uint8_t out[128]);
extern void pipeline_dep_ctx_set_import_path(void *ctx, int32_t idx, uint8_t *path, int32_t pl);
extern uint8_t *driver_dep_arena_buf(int32_t i);
extern uint8_t *driver_dep_module_buf(int32_t i);
extern int32_t driver_dep_slot_for_path(const char *path);
extern ptrdiff_t std_fs_fs_read(int fd, void *buf, size_t count);

/* LP64 offsets — match pure pipe_pctx_off_* */
static int32_t wave101_off_loaded_len(void) { return 4195344; }
static int32_t wave101_off_preprocess_len(void) { return 8389656; }

static void wave101_store_i32_le(uint8_t *base, int32_t off, int32_t v) {
  uint32_t u;
  if (!base || off < 0)
    return;
  u = (uint32_t)v;
  base[off] = (uint8_t)(u & 255u);
  base[off + 1] = (uint8_t)((u / 256u) & 255u);
  base[off + 2] = (uint8_t)((u / 65536u) & 255u);
  base[off + 3] = (uint8_t)((u / 16777216u) & 255u);
}

static int32_t wave101_load_i32_le(uint8_t *base, int32_t off) {
  uint32_t b0, b1, b2, b3, u;
  if (!base || off < 0)
    return 0;
  b0 = base[off];
  b1 = base[off + 1];
  b2 = base[off + 2];
  b3 = base[off + 3];
  u = b0 + b1 * 256u + b2 * 65536u + b3 * 16777216u;
  return (int32_t)u;
}

static int64_t wave101_load_i64_le(uint8_t *base, int32_t off) {
  uint64_t u = 0;
  int i;
  if (!base || off < 0)
    return 0;
  for (i = 0; i < 8; i++)
    u |= ((uint64_t)base[off + i]) << (8 * i);
  return (int64_t)u;
}

int32_t pipeline_dep_ctx_preprocess_len_get(void *ctx) {
  if (!ctx)
    return -1;
  return wave101_load_i32_le((uint8_t *)ctx, wave101_off_preprocess_len());
}

int32_t pipeline_read_file_x(void *ctx) {
  uint8_t *path;
  uint8_t *buf;
  int n;
  if (!ctx)
    return -1;
  path = pipeline_dep_ctx_path_buf_ptr(ctx);
  buf = pipeline_dep_ctx_loaded_buf_ptr(ctx);
  if (!path || !buf)
    return -1;
  n = xlang_read_file_into_path((const char *)path, buf, (size_t)4194304);
  if (n < 0)
    return -1;
  pipeline_dep_ctx_set_loaded_len(ctx, (int64_t)n);
  return 0;
}

int32_t pipeline_read_file_x_impl_c(void *ctx) {
  return pipeline_read_file_x(ctx);
}

int32_t pipeline_read_file_x_c(void *ctx) {
  return pipeline_read_file_x(ctx);
}

int32_t pipeline_read_fd_into_loaded_buf(void *ctx, int32_t fd) {
  uint8_t *buf;
  ptrdiff_t n;
  if (!ctx || fd < 0)
    return -1;
  buf = pipeline_dep_ctx_loaded_buf_ptr(ctx);
  if (!buf)
    return -1;
  n = std_fs_fs_read(fd, buf, (size_t)4194304);
  if (n < 0)
    return -1;
  pipeline_dep_ctx_set_loaded_len(ctx, (int64_t)n);
  return 0;
}

int32_t pipeline_preprocess_loaded_into_ctx(void *ctx) {
  uint8_t *loaded;
  uint8_t *prep;
  int64_t loaded_len;
  int32_t out_len;
  if (!ctx)
    return -1;
  loaded = pipeline_dep_ctx_loaded_buf_ptr(ctx);
  prep = pipeline_dep_ctx_preprocess_buf_ptr(ctx);
  if (!loaded || !prep)
    return -1;
  loaded_len = wave101_load_i64_le((uint8_t *)ctx, wave101_off_loaded_len());
  out_len = preprocess_x_buf(loaded, (ptrdiff_t)loaded_len, prep, 4194304);
  if (out_len < 0)
    return -9;
  wave101_store_i32_le((uint8_t *)ctx, wave101_off_preprocess_len(), out_len);
  return 0;
}

void pipeline_bind_import_dep_buffers(void *ctx, int32_t import_idx) {
  if (!ctx || import_idx < 0)
    return;
  ast_pipeline_dep_ctx_set_arena((struct ast_PipelineDepCtx *)(struct ast_PipelineDepCtx *)ctx, import_idx, (struct ast_ASTArena *)(struct ast_ASTArena *)driver_dep_arena_buf(import_idx));
  ast_pipeline_dep_ctx_set_module((struct ast_PipelineDepCtx *)(struct ast_PipelineDepCtx *)ctx, import_idx, (struct ast_Module *)(struct ast_Module *)driver_dep_module_buf(import_idx));
}

int32_t pipeline_try_bind_seeded_import(void *ctx, int32_t import_idx, int32_t global_slot) {
  if (!ctx || import_idx < 0)
    return 0;
  if (global_slot >= 0 && driver_dep_seeded_get(global_slot) != 0) {
    ast_pipeline_dep_ctx_set_arena((struct ast_PipelineDepCtx *)ctx, import_idx, (struct ast_ASTArena *)driver_dep_arena_buf(global_slot));
    ast_pipeline_dep_ctx_set_module((struct ast_PipelineDepCtx *)ctx, import_idx, (struct ast_Module *)driver_dep_module_buf(global_slot));
    return 1;
  }
  if (driver_dep_seeded_get(import_idx) != 0) {
    ast_pipeline_dep_ctx_set_arena((struct ast_PipelineDepCtx *)ctx, import_idx, (struct ast_ASTArena *)driver_dep_arena_buf(import_idx));
    ast_pipeline_dep_ctx_set_module((struct ast_PipelineDepCtx *)ctx, import_idx, (struct ast_Module *)driver_dep_module_buf(import_idx));
    return 1;
  }
  return 0;
}

int32_t pipeline_sync_one_dep_slot(void *module, void *ctx, int32_t dep_i) {
  uint8_t sync_path[128];
  int32_t sync_slot;
  int32_t pl;
  if (!module || !ctx || dep_i < 0)
    return -1;
  (void)parser_copy_module_import_path64(module, dep_i, sync_path);
  sync_slot = driver_dep_slot_for_path((const char *)sync_path);
  if (sync_slot < 0)
    sync_slot = dep_i;
  pl = 0;
  while (pl < 64 && sync_path[pl] != 0)
    pl = pl + 1;
  if (pl > 0)
    pipeline_dep_ctx_set_import_path(ctx, dep_i, sync_path, pl);
  ast_pipeline_dep_ctx_set_module((struct ast_PipelineDepCtx *)ctx, dep_i, (struct ast_Module *)driver_dep_module_buf(sync_slot));
  ast_pipeline_dep_ctx_set_arena((struct ast_PipelineDepCtx *)ctx, dep_i, (struct ast_ASTArena *)driver_dep_arena_buf(sync_slot));
  return 0;
}

/* wave102 asm_diag leave cold twins — former pipeline_asm_diag.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong asm_diag_* after host-cc leave. Product hybrid defines FROM_X so
 * this block is excluded; pure prints full BODY_TRACE metrics via write(2). */
extern char *link_abi_getenv(const char *name);
/* Cold twin of static asm_env_build_skip_typeck (emit_heavy_env same-TU helper). */
static int32_t wave102_asm_env_build_skip_typeck(void) {
  const char *e = link_abi_getenv("XLANG_ASM_BUILD_SKIP_TYPECK");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

int32_t asm_diag_start_func_skip(void) {
  const char *e = link_abi_getenv("XLANG_ASM_START_FUNC");
  const char *allow = link_abi_getenv("XLANG_ASM_ALLOW_START_FUNC");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return 0;
  if ((allow == NULL || allow[0] == '\0' || allow[0] == '0') &&
      wave102_asm_env_build_skip_typeck() != 0 &&
      link_abi_getenv("XLANG_ASM_ENTRY_MODULE_ONLY") != NULL) {
    const char *em = link_abi_getenv("XLANG_ASM_ENTRY_MODULE_ONLY");
    if (em && em[0] != '\0' && em[0] != '0')
      return 0;
  }
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return 0;
  if (v > 100000)
    return 100000;
  return (int32_t)v;
}

void asm_diag_trace_func_body(struct ast_ASTArena *arena, int32_t body_ref) {
  const char *trace;
  if (!arena || body_ref <= 0)
    return;
  trace = link_abi_getenv("XLANG_ASM_BODY_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  /* Cold twin lacks Block layout; pure product path prints full metrics. */
  fprintf(stderr, "asm_body: ref=%d (cold)\n", (int)body_ref);
  fflush(stderr);
}

void asm_diag_trace_body_ref(int32_t body_ref) {
  const char *trace = link_abi_getenv("XLANG_ASM_BODY_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  fprintf(stderr, "asm_body_ref=%d\n", (int)body_ref);
  fflush(stderr);
}

void asm_diag_trace_emit_phase(int32_t phase) {
  const char *trace = link_abi_getenv("XLANG_ASM_BODY_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  fprintf(stderr, "asm_emit_phase=%d\n", (int)phase);
  fflush(stderr);
}

void asm_diag_trace_func_idx(int32_t func_idx, uint8_t *name, int32_t name_len) {
  const char *trace;
  int32_t i;
  if (!name || name_len <= 0)
    return;
  trace = link_abi_getenv("XLANG_ASM_FUNC_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  if (func_idx >= 0)
    fprintf(stderr, "asm_trace: #%d ", (int)func_idx);
  else
    fprintf(stderr, "asm_trace: ");
  for (i = 0; i < name_len && i < 64; i++)
    fputc(name[i], stderr);
  fputc('\n', stderr);
  fflush(stderr);
}

void asm_diag_trace_func(uint8_t *name, int32_t name_len) {
  asm_diag_trace_func_idx(-1, name, name_len);
}

/* wave103 lsp_diag leave cold twins — former pipeline_lsp_diag.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong lsp_diag_*_c after host-cc leave. */
extern int32_t pipeline_load_and_sync_direct_import_deps_c(void *module, void *arena, void *ctx);
extern int32_t pipeline_typeck_parsed_module_c(void *module, void *arena, void *ctx, int32_t fail_mapped);
extern int32_t pipeline_parse_set_main_from_buf_c(void *module, void *arena, uint8_t *data, int32_t len);
extern int32_t driver_is_large_stack_thread(void);
extern void driver_run_thread_on_large_stack(uint8_t *fn, uint8_t *arg);

int32_t lsp_diag_typeck_after_load_c(void *module, void *arena, void *ctx) {
  int32_t load_rc;
  if (!module || !arena || !ctx)
    return -1;
  load_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  if (load_rc != 0)
    return load_rc;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, -3);
}

int32_t lsp_diag_parse_entry_buf_c(void *module, void *arena, uint8_t *source_data, int32_t source_len) {
  return pipeline_parse_set_main_from_buf_c(module, arena, source_data, source_len);
}

static int32_t wave103_lsp_diag_parse_typeck_buf_impl(void *module, void *arena, uint8_t *source_data,
                                                     int32_t source_len, void *ctx) {
  int32_t parse_rc;
  int32_t load_rc;
  if (!module || !arena || !ctx || !source_data || source_len <= 0)
    return -2;
  parse_rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, source_len);
  if (parse_rc != 0)
    return parse_rc;
  load_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  if (load_rc != 0)
    return load_rc;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, -3);
}

/* LP64 pack matches pure: module@0 arena@8 src@16 len@24 ctx@32 result@40. */
typedef struct {
  void *module;
  void *arena;
  uint8_t *source_data;
  int32_t source_len;
  void *ctx;
  int32_t result;
} Wave103LspDiagArgs;

static void *wave103_lsp_diag_parse_typeck_thread_fn(void *arg) {
  Wave103LspDiagArgs *a = (Wave103LspDiagArgs *)arg;
  a->result = wave103_lsp_diag_parse_typeck_buf_impl(a->module, a->arena, a->source_data, a->source_len, a->ctx);
  return NULL;
}

uint8_t *lsp_diag_parse_typeck_thread_fn(uint8_t *arg) {
  (void)wave103_lsp_diag_parse_typeck_thread_fn(arg);
  return NULL;
}

uint8_t *lsp_diag_parse_typeck_thread_fn_ptr(void) {
  return (uint8_t *)(void *)&wave103_lsp_diag_parse_typeck_thread_fn;
}

int32_t lsp_diag_parse_typeck_buf_c(void *module, void *arena, uint8_t *source_data, int32_t source_len,
                                   void *ctx) {
  Wave103LspDiagArgs args;
  if (driver_is_large_stack_thread())
    return wave103_lsp_diag_parse_typeck_buf_impl(module, arena, source_data, source_len, ctx);
  args.module = module;
  args.arena = arena;
  args.source_data = source_data;
  args.source_len = source_len;
  args.ctx = ctx;
  args.result = -99;
  driver_run_thread_on_large_stack((uint8_t *)(void *)&wave103_lsp_diag_parse_typeck_thread_fn,
                                   (uint8_t *)&args);
  if (args.result == -99)
    return wave103_lsp_diag_parse_typeck_buf_impl(module, arena, source_data, source_len, ctx);
  return args.result;
}

/* wave104 emit_sidecar leave cold twins — former pipeline_emit_sidecar.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong driver_emit_* / asm_qual_sym_* after host-cc leave. Fixed caps
 * match pure: 64 state slots, 32 roots/slot × 256B, 32 qual layers × 64B. */
#define WAVE104_EMIT_SC_MAX 64
#define WAVE104_EMIT_ROOTS 32
#define WAVE104_EMIT_PATH 256
#define WAVE104_QUAL_MAX 32
#define WAVE104_QUAL_W 64

static int32_t wave104_emit_used[WAVE104_EMIT_SC_MAX];
static uint8_t *wave104_emit_state[WAVE104_EMIT_SC_MAX];
static int32_t wave104_emit_n[WAVE104_EMIT_SC_MAX];
static uint8_t wave104_emit_rows[WAVE104_EMIT_SC_MAX * WAVE104_EMIT_ROOTS * WAVE104_EMIT_PATH];
static int32_t wave104_emit_lens[WAVE104_EMIT_SC_MAX * WAVE104_EMIT_ROOTS];
static int32_t wave104_qual_n;
static uint8_t wave104_qual_rows[WAVE104_QUAL_MAX * WAVE104_QUAL_W];
static int32_t wave104_qual_lens[WAVE104_QUAL_MAX];

static int32_t wave104_emit_sc_find(uint8_t *state, int create) {
  int i;
  if (!state)
    return -1;
  for (i = 0; i < WAVE104_EMIT_SC_MAX; i++) {
    if (wave104_emit_used[i] && wave104_emit_state[i] == state)
      return i;
  }
  if (!create)
    return -1;
  for (i = 0; i < WAVE104_EMIT_SC_MAX; i++) {
    if (!wave104_emit_used[i]) {
      wave104_emit_used[i] = 1;
      wave104_emit_state[i] = state;
      wave104_emit_n[i] = 0;
      return i;
    }
  }
  return -1;
}

void driver_emit_lib_root_reset(uint8_t *state) {
  int32_t s = wave104_emit_sc_find(state, 0);
  if (s < 0)
    return;
  wave104_emit_n[s] = 0;
}

void driver_emit_lib_root_release(uint8_t *state) {
  int32_t s = wave104_emit_sc_find(state, 0);
  if (s < 0)
    return;
  wave104_emit_used[s] = 0;
  wave104_emit_n[s] = 0;
  wave104_emit_state[s] = NULL;
}

int32_t driver_emit_append_lib_root(uint8_t *state, uint8_t *path, int32_t len) {
  int32_t s, n, clen, base, k;
  if (!state || !path || len <= 0)
    return -1;
  s = wave104_emit_sc_find(state, 1);
  if (s < 0)
    return -1;
  n = wave104_emit_n[s];
  if (n >= WAVE104_EMIT_ROOTS)
    return -1;
  clen = len > 255 ? 255 : len;
  base = (s * WAVE104_EMIT_ROOTS + n) * WAVE104_EMIT_PATH;
  memset(&wave104_emit_rows[base], 0, WAVE104_EMIT_PATH);
  memcpy(&wave104_emit_rows[base], path, (size_t)clen);
  wave104_emit_lens[s * WAVE104_EMIT_ROOTS + n] = clen;
  wave104_emit_n[s] = n + 1;
  return n;
}

int32_t driver_emit_lib_root_count(uint8_t *state) {
  int32_t s = wave104_emit_sc_find(state, 0);
  return s < 0 ? 0 : wave104_emit_n[s];
}

int32_t driver_emit_lib_root_len(uint8_t *state, int32_t i) {
  int32_t s;
  if (i < 0)
    return 0;
  s = wave104_emit_sc_find(state, 0);
  if (s < 0 || i >= wave104_emit_n[s])
    return 0;
  return wave104_emit_lens[s * WAVE104_EMIT_ROOTS + i];
}

void driver_emit_lib_root_copy(uint8_t *state, int32_t i, uint8_t *dst, int32_t cap) {
  int32_t s, n, base, k;
  if (!dst || cap <= 0)
    return;
  memset(dst, 0, (size_t)cap);
  if (i < 0)
    return;
  s = wave104_emit_sc_find(state, 0);
  if (s < 0 || i >= wave104_emit_n[s])
    return;
  n = wave104_emit_lens[s * WAVE104_EMIT_ROOTS + i];
  if (n >= cap)
    n = cap - 1;
  base = (s * WAVE104_EMIT_ROOTS + i) * WAVE104_EMIT_PATH;
  for (k = 0; k < n; k++)
    dst[k] = wave104_emit_rows[base + k];
}

void asm_qual_sym_layer_reset(void) {
  wave104_qual_n = 0;
}

int32_t asm_qual_sym_layer_push(uint8_t *bytes, int32_t len) {
  int32_t n, idx, base, k;
  if (!bytes || len <= 0)
    return -1;
  if (wave104_qual_n >= WAVE104_QUAL_MAX)
    return -1;
  n = len > 63 ? 63 : len;
  idx = wave104_qual_n;
  base = idx * WAVE104_QUAL_W;
  memset(&wave104_qual_rows[base], 0, WAVE104_QUAL_W);
  memcpy(&wave104_qual_rows[base], bytes, (size_t)n);
  wave104_qual_lens[idx] = n;
  wave104_qual_n = idx + 1;
  return idx;
}

int32_t asm_qual_sym_layer_count(void) {
  return wave104_qual_n;
}

int32_t asm_qual_sym_layer_len(int32_t i) {
  if (i < 0 || i >= wave104_qual_n)
    return 0;
  return wave104_qual_lens[i];
}

void asm_qual_sym_layer_copy(int32_t i, uint8_t *dst, int32_t cap) {
  int32_t n, base, k;
  if (!dst || cap <= 0)
    return;
  memset(dst, 0, (size_t)cap);
  if (i < 0 || i >= wave104_qual_n)
    return;
  n = wave104_qual_lens[i];
  if (n >= cap)
    n = cap - 1;
  base = i * WAVE104_QUAL_W;
  for (k = 0; k < n; k++)
    dst[k] = wave104_qual_rows[base + k];
}

/* wave105 resolve_path leave cold twins — former pipeline_resolve_path.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong path_append_*_c / probe / flat / off-sidecar / codegen_out_buf_* /
 * resolve_path_x_impl_c|_c after host-cc leave. Probe bytes match historical
 * host-cc leaf (46,115,117 and /mod + same). Prefer void* like wave101. */
extern void pipeline_dep_ctx_set_path_buf_byte(void *ctx, int32_t off, uint8_t b);
extern uint8_t *pipeline_dep_ctx_path_buf_ptr(void *ctx);
extern int32_t pipeline_dep_ctx_entry_dir_len(void *ctx);
extern void pipeline_dep_ctx_entry_dir_copy(void *ctx, uint8_t *dst, int32_t cap);
extern int32_t pipeline_copy_lib_root_to_buf256(void *ctx, int32_t lib_idx, uint8_t *dst);
extern int32_t pipeline_ctx_lib_root_count(void *ctx);
extern int32_t std_fs_fs_open_read(uint8_t *path);
extern int32_t std_fs_fs_close(int32_t fd);
extern int32_t pipeline_resolve_path_x(void *ctx, uint8_t *import_path, int32_t path_len);

static int32_t wave105_resolve_off;

int32_t pipeline_path_append_from_buf_256_c(void *ctx, int32_t off, uint8_t *buf, int32_t len) {
  int32_t k;
  if (!ctx || !buf || len <= 0)
    return off;
  k = 0;
  while (k < len && off < 508) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, buf[k]);
    off++;
    k++;
  }
  return off;
}

int32_t pipeline_path_append_from_buf_512_c(void *ctx, int32_t off, uint8_t *buf, int32_t len) {
  return pipeline_path_append_from_buf_256_c(ctx, off, buf, len);
}

int32_t pipeline_path_append_import_path_c(void *ctx, int32_t off, uint8_t *import_path, int32_t path_len) {
  int32_t k;
  uint8_t b;
  if (!ctx || !import_path || path_len <= 0)
    return off;
  k = 0;
  while (k < path_len && off < 508) {
    b = import_path[k];
    if (b == 46)
      b = 47;
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, b);
    off++;
    k++;
  }
  return off;
}

int32_t pipeline_resolve_path_import_has_dot_c(uint8_t *import_path, int32_t path_len) {
  int32_t k;
  if (!import_path || path_len <= 0)
    return 0;
  k = 0;
  while (k < path_len && k < 64) {
    if (import_path[k] == 46)
      return 1;
    k++;
  }
  return 0;
}

#define WAVE105_CODEGEN_OUTBUF_CAP 9437184

int32_t codegen_out_buf_len(void *out) {
  if (!out)
    return 0;
  return *(int32_t *)((uint8_t *)out + (ptrdiff_t)WAVE105_CODEGEN_OUTBUF_CAP);
}

void codegen_out_buf_set_len(void *out, int32_t n) {
  if (out)
    *(int32_t *)((uint8_t *)out + (ptrdiff_t)WAVE105_CODEGEN_OUTBUF_CAP) = n > 0 ? n : 0;
}

static int32_t wave105_probe_dot_x_and_mod(void *ctx, int32_t off) {
  int32_t fd;
  if (!ctx)
    return -1;
  if (off + 4 <= 512) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 46);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off + 1, 115);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off + 2, 117);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off + 3, 0);
    fd = std_fs_fs_open_read(pipeline_dep_ctx_path_buf_ptr(ctx));
    if (fd >= 0) {
      std_fs_fs_close(fd);
      return 0;
    }
    if (off + 8 <= 512) {
      pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 1, 109);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 2, 111);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 3, 100);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 4, 46);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 5, 115);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 6, 117);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 7, 0);
      fd = std_fs_fs_open_read(pipeline_dep_ctx_path_buf_ptr(ctx));
      if (fd >= 0) {
        std_fs_fs_close(fd);
        return 0;
      }
    }
  }
  return -1;
}

int32_t pipeline_resolve_path_last_off_get_c(void) {
  return wave105_resolve_off;
}

int32_t pipeline_resolve_path_lib_root_prefix_off_c(void *ctx, int32_t lib_idx) {
  uint8_t lr_buf[256];
  int32_t lr_len;
  int32_t off;
  if (!ctx || lib_idx < 0)
    return -1;
  memset(lr_buf, 0, sizeof(lr_buf));
  lr_len = pipeline_copy_lib_root_to_buf256(ctx, lib_idx, lr_buf);
  off = 0;
  if (lr_len > 0)
    off = pipeline_path_append_from_buf_256_c(ctx, 0, lr_buf, lr_len);
  if (off < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
    off = off + 1;
  }
  wave105_resolve_off = off;
  return off;
}

int32_t pipeline_path_append_import_path_sidecar_c(void *ctx, int32_t off, uint8_t *import_path, int32_t path_len) {
  int32_t new_off;
  if (!ctx || !import_path || off < 0)
    return -1;
  new_off = pipeline_path_append_import_path_c(ctx, off, import_path, path_len);
  if (new_off < 0)
    return -1;
  wave105_resolve_off = new_off;
  return new_off;
}

int32_t pipeline_resolve_path_entry_dir_prefix_off_c(void *ctx) {
  int32_t ed_len;
  uint8_t ed_buf[512];
  int32_t off;
  if (!ctx)
    return -1;
  ed_len = pipeline_dep_ctx_entry_dir_len(ctx);
  if (ed_len <= 0)
    return -1;
  memset(ed_buf, 0, sizeof(ed_buf));
  pipeline_dep_ctx_entry_dir_copy(ctx, ed_buf, 512);
  off = pipeline_path_append_from_buf_512_c(ctx, 0, ed_buf, ed_len);
  if (off < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
    off = off + 1;
  }
  wave105_resolve_off = off;
  return off;
}

int32_t pipeline_flat_import_build_path_c(void *ctx, int32_t lib_idx, uint8_t *import_path, int32_t path_len) {
  int32_t off_base;
  if (!ctx || !import_path || lib_idx < 0)
    return -1;
  if (pipeline_resolve_path_lib_root_prefix_off_c(ctx, lib_idx) < 0)
    return -1;
  off_base = wave105_resolve_off;
  if (pipeline_path_append_import_path_sidecar_c(ctx, off_base, import_path, path_len) < 0)
    return -1;
  off_base = wave105_resolve_off;
  if (off_base < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 47);
    wave105_resolve_off = off_base + 1;
  }
  if (pipeline_path_append_import_path_sidecar_c(ctx, wave105_resolve_off, import_path, path_len) < 0)
    return -1;
  off_base = wave105_resolve_off;
  if (off_base + 4 > 512)
    return -1;
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 46);
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 1, 115);
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 2, 117);
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 3, 0);
  return 0;
}

int32_t pipeline_flat_import_probe_open_c(void *ctx) {
  int32_t fd_dir;
  if (!ctx)
    return -1;
  fd_dir = std_fs_fs_open_read(pipeline_dep_ctx_path_buf_ptr(ctx));
  if (fd_dir >= 0) {
    std_fs_fs_close(fd_dir);
    return 0;
  }
  return -1;
}

int32_t pipeline_resolve_path_probe_export_c(void *ctx, int32_t off) {
  return wave105_probe_dot_x_and_mod(ctx, off);
}

static int32_t wave105_try_flat_import_under_lib(void *ctx, int32_t lib_idx, uint8_t *import_path, int32_t path_len) {
  uint8_t lr_buf[256];
  int32_t lr_len;
  int32_t off_base;
  if (!ctx || !import_path)
    return -1;
  lr_len = pipeline_copy_lib_root_to_buf256(ctx, lib_idx, lr_buf);
  off_base = 0;
  if (lr_len > 0)
    off_base = pipeline_path_append_from_buf_256_c(ctx, 0, lr_buf, lr_len);
  if (off_base < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 47);
    off_base = off_base + 1;
  }
  off_base = pipeline_path_append_import_path_c(ctx, off_base, import_path, path_len);
  if (off_base < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 47);
    off_base = off_base + 1;
  }
  off_base = pipeline_path_append_import_path_c(ctx, off_base, import_path, path_len);
  if (off_base + 4 <= 512) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 46);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 1, 115);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 2, 117);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 3, 0);
    if (std_fs_fs_open_read(pipeline_dep_ctx_path_buf_ptr(ctx)) >= 0)
      return 0;
  }
  return -1;
}

static int32_t wave105_try_one_lib_root(void *ctx, int32_t lib_idx, uint8_t *import_path, int32_t path_len) {
  uint8_t lr_buf[256];
  int32_t lr_len;
  int32_t off;
  if (!ctx || !import_path)
    return -1;
  lr_len = pipeline_copy_lib_root_to_buf256(ctx, lib_idx, lr_buf);
  off = 0;
  if (lr_len > 0)
    off = pipeline_path_append_from_buf_256_c(ctx, 0, lr_buf, lr_len);
  if (off < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
    off = off + 1;
  }
  off = pipeline_path_append_import_path_c(ctx, off, import_path, path_len);
  if (wave105_probe_dot_x_and_mod(ctx, off) == 0)
    return 0;
  if (path_len > 0 && path_len < 64 && pipeline_resolve_path_import_has_dot_c(import_path, path_len) == 0) {
    if (wave105_try_flat_import_under_lib(ctx, lib_idx, import_path, path_len) == 0)
      return 0;
  }
  return -1;
}

static int32_t wave105_try_entry_dir(void *ctx, uint8_t *import_path, int32_t path_len) {
  int32_t ed_len;
  uint8_t ed_buf[512];
  int32_t off;
  if (!ctx || !import_path)
    return -1;
  ed_len = pipeline_dep_ctx_entry_dir_len(ctx);
  if (ed_len <= 0 || pipeline_resolve_path_import_has_dot_c(import_path, path_len) != 0)
    return -1;
  pipeline_dep_ctx_entry_dir_copy(ctx, ed_buf, 512);
  off = pipeline_path_append_from_buf_512_c(ctx, 0, ed_buf, ed_len);
  if (off < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
    off = off + 1;
  }
  off = pipeline_path_append_import_path_c(ctx, off, import_path, path_len);
  return wave105_probe_dot_x_and_mod(ctx, off);
}

int32_t pipeline_resolve_path_x_impl_c(void *ctx, uint8_t *import_path, int32_t path_len) {
  int32_t r;
  int32_t n_lib;
  if (!ctx || !import_path || path_len <= 0)
    return -1;
  n_lib = pipeline_ctx_lib_root_count(ctx);
  r = 0;
  while (r < n_lib) {
    if (wave105_try_one_lib_root(ctx, r, import_path, path_len) == 0)
      return 0;
    r = r + 1;
  }
  if (wave105_try_entry_dir(ctx, import_path, path_len) == 0)
    return 0;
  return -1;
}

int32_t pipeline_resolve_path_x_c(void *ctx, uint8_t *import_path, int32_t path_len) {
  return pipeline_resolve_path_x(ctx, import_path, path_len);
}

/* wave106 run_x_pipeline leave cold twins — former pipeline_run_x_pipeline.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong last_rc / typeck_fail / load_deps / typecheck_after_load /
 * parse_entry_do_parse / typecheck_entry_emit / pipeline_run_x_pipeline after
 * host-cc leave. Prefer void* like wave101/105. */
extern int32_t pipeline_should_skip_x_typeck(void *ctx);
extern int32_t pipeline_typeck_entry_module_c(void *module, void *arena, void *ctx);
extern int32_t pipeline_typeck_dep_prerun_module_c(void *module, void *arena, void *ctx);
extern int32_t pipeline_load_and_sync_direct_import_deps_c(void *module, void *arena, void *ctx);
extern int32_t pipeline_parse_set_main_from_buf_c(void *module, void *arena, uint8_t *data, int32_t len);
extern int32_t pipeline_module_num_funcs(void *module);
extern int32_t pipeline_dep_ctx_ndep(void *ctx);
extern int32_t parser_get_module_num_imports(void *module);
extern void driver_diagnostic_typeck_fail(void);
extern void driver_diagnostic_source_len(int32_t len);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_after_entry_parse_module(void *module);
extern void driver_diagnostic_entry_module(void *module, void *arena);
extern int32_t driver_x_pipeline_skip_typeck_get(void);
extern int32_t driver_x_pipeline_skip_codegen_get(void);
extern int32_t pipeline_driver_asm_build_skip_typeck(void);
extern int32_t pipeline_run_x_pipeline_impl(void *module, void *arena, uint8_t *source_data, size_t source_len,
                                           void *out_buf, void *ctx);

static int32_t wave106_last_rc;

int32_t run_x_pipeline_last_rc_get(void) {
  return wave106_last_rc;
}

void run_x_pipeline_last_rc_store_c(int32_t rc) {
  wave106_last_rc = rc;
}

int32_t pipeline_typeck_fail_return_c(int32_t fail_mapped) {
  driver_diagnostic_typeck_fail();
  if (fail_mapped != 0)
    return fail_mapped;
  return -1;
}

int32_t pipeline_typeck_null_fail_return_c(int32_t fail_mapped) {
  if (fail_mapped != 0)
    return fail_mapped;
  return -1;
}

int32_t run_x_pipeline_typecheck_entry_c(void *module, void *arena, void *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  if (pipeline_should_skip_x_typeck(ctx) != 0)
    return 0;
  return pipeline_typeck_entry_module_c(module, arena, ctx);
}

int32_t run_x_pipeline_load_deps_after_parse_c(void *module, void *arena, void *ctx) {
  wave106_last_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  return wave106_last_rc;
}

int32_t run_x_pipeline_typecheck_after_load_c(void *module, void *arena, void *ctx) {
  wave106_last_rc = run_x_pipeline_typecheck_entry_c(module, arena, ctx);
  return wave106_last_rc;
}

int32_t run_x_pipeline_parse_entry_do_parse_c(void *module, void *arena, uint8_t *source_data, size_t source_len,
                                             void *ctx) {
  int32_t len_i32;
  int32_t parse_rc;
  if (!module || !arena || !ctx)
    return -1;
  len_i32 = (int32_t)source_len;
  driver_diagnostic_source_len(len_i32);
  parse_rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, len_i32);
  if (parse_rc != 0)
    return parse_rc;
  driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
  driver_diagnostic_after_entry_parse_module(module);
  driver_diagnostic_entry_module(module, arena);
  return 0;
}

int32_t run_x_pipeline_typecheck_entry_emit_c(void *module, void *arena, void *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  /* DEBUG_PIPE fprintf omitted in cold twin; product non-debug path identical. */
  if (driver_x_pipeline_skip_typeck_get() != 0) {
    if (parser_get_module_num_imports(module) == 0 && driver_x_pipeline_skip_codegen_get() != 0)
      return pipeline_typeck_entry_module_c(module, arena, ctx);
    if (pipeline_driver_asm_build_skip_typeck() != 0)
      return pipeline_typeck_dep_prerun_module_c(module, arena, ctx);
    return pipeline_typeck_entry_module_c(module, arena, ctx);
  }
  if (pipeline_should_skip_x_typeck(ctx) != 0)
    return 0;
  return pipeline_typeck_entry_module_c(module, arena, ctx);
}

int32_t pipeline_run_x_pipeline(void *module, void *arena, const uint8_t *source_data, size_t source_len, void *out_buf,
                               void *ctx) {
  return pipeline_run_x_pipeline_impl(module, arena, (uint8_t *)source_data, source_len, out_buf, ctx);
}

/* wave107 codegen residual leave cold twins — former pipeline_codegen_residual.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong name predicates + io.core/driver symbol rewrites after host-cc leave.
 * Prefer void-star and u8-star like wave101/105/106. Historical slen quirks twin C. */
static int wave107_name_prefix_eq(uint8_t *name, int32_t name_len, const char *pfx, int32_t plen) {
  if (!name || name_len < plen || !pfx)
    return 0;
  return memcmp(name, pfx, (size_t)plen) == 0 ? 1 : 0;
}

int32_t pipeline_codegen_use_buf_wrapper(uint8_t *name, int32_t name_len, int32_t num_args) {
  if (!name || name_len <= 0)
    return 0;
  if (num_args == 1 && name_len == 15 && wave107_name_prefix_eq(name, name_len, "xlang_io_register", 15))
    return 1;
  if (num_args == 2 && name_len == 18 && wave107_name_prefix_eq(name, name_len, "xlang_io_submit_read", 18))
    return 1;
  if (num_args == 2 && name_len == 19 && wave107_name_prefix_eq(name, name_len, "xlang_io_submit_write", 19))
    return 1;
  return 0;
}

int32_t pipeline_codegen_skip_emit_extern_io_batch_buf(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len == 17 && memcmp(name, "io_read_batch_buf", 17) == 0)
    return 1;
  if (name_len == 18 && memcmp(name, "io_write_batch_buf", 18) == 0)
    return 1;
  if (name_len == 23 && memcmp(name, "io_register_buffers_buf", 23) == 0)
    return 1;
  return 0;
}

int32_t pipeline_codegen_should_skip_emit_func_by_name(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len == 11 && wave107_name_prefix_eq(name, name_len, "placeholder", 11))
    return 1;
  if (name_len == 22 && wave107_name_prefix_eq(name, name_len, "std_string_placeholder", 22))
    return 1;
  if (name_len == 10 && wave107_name_prefix_eq(name, name_len, "string_new", 10))
    return 1;
  if (name_len == 22 && wave107_name_prefix_eq(name, name_len, "std_string_string_new", 22))
    return 1;
  if (name_len == 21 && wave107_name_prefix_eq(name, name_len, "std_string_string_new", 21))
    return 1;
  if (!link_abi_getenv("XLANG_EMIT_SEED_MEGA")) {
    if (name_len == 25 && memcmp(name, "asm_codegen_ast_seed_mega", 25) == 0)
      return 1;
    if (name_len == 32 && memcmp(name, "asm_codegen_ast_to_elf_seed_mega", 32) == 0)
      return 1;
  }
  return 0;
}

int32_t pipeline_codegen_emit_seed_mega_enabled(void) {
  const char *e = (const char *)link_abi_getenv("XLANG_EMIT_SEED_MEGA");
  return (e && e[0] && e[0] != '0') ? 1 : 0;
}

int32_t pipeline_codegen_is_submit_batch_buf_call(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len == 21 && wave107_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
    return 1;
  if (name_len == 22 && wave107_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
    return 1;
  return 0;
}

int32_t pipeline_codegen_should_skip_emit_func_core_read_ptr(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len >= 19 && wave107_name_prefix_eq(name, name_len, "xlang_io_read_ptr_len", 19))
    return 1;
  if (name_len == 15 && wave107_name_prefix_eq(name, name_len, "xlang_io_read_ptr", 15))
    return 1;
  if (name_len == 15 && wave107_name_prefix_eq(name, name_len, "xlang_io_register", 15))
    return 1;
  if (name_len == 23 && wave107_name_prefix_eq(name, name_len, "xlang_io_register_buffers", 23))
    return 1;
  if (name_len == 25 && wave107_name_prefix_eq(name, name_len, "xlang_io_unregister_buffers", 25))
    return 1;
  if (name_len == 20 && wave107_name_prefix_eq(name, name_len, "xlang_io_wait_readable", 20))
    return 1;
  return 0;
}

int32_t pipeline_asm_io_core_extern_callee_sym(uint8_t *name, int32_t name_len, uint8_t *sym_out, int32_t sym_cap) {
  uint8_t *bare;
  int32_t blen;
  const char *sym;
  int32_t slen;
  if (!name || name_len <= 0 || !sym_out || sym_cap <= 0)
    return 0;
  bare = name;
  blen = name_len;
  if (name_len > 12 && memcmp(name, "std_io_core_", 12) == 0) {
    bare = name + 12;
    blen = name_len - 12;
  }
  sym = NULL;
  slen = 0;
  if (blen == 23 && wave107_name_prefix_eq(bare, blen, "xlang_io_register_buffers", 23)) {
    sym = "io_register_buffers_4";
    slen = 23;
  } else if (blen == 25 && wave107_name_prefix_eq(bare, blen, "xlang_io_unregister_buffers", 25)) {
    sym = "io_unregister_buffers";
    slen = 21;
  } else if (blen == 15 && wave107_name_prefix_eq(bare, blen, "xlang_io_register", 15)) {
    sym = "io_register_buffer";
    slen = 19;
  } else if (blen == 19 && wave107_name_prefix_eq(bare, blen, "xlang_io_read_ptr_len", 19)) {
    sym = "io_read_ptr_len";
    slen = 15;
  } else if (blen == 15 && wave107_name_prefix_eq(bare, blen, "xlang_io_read_ptr", 15)) {
    sym = "io_read_ptr";
    slen = 11;
  } else if (blen == 20 && wave107_name_prefix_eq(bare, blen, "xlang_io_wait_readable", 20)) {
    sym = "io_wait_readable";
    slen = 17;
  }
  if (!sym)
    return 0;
  if (sym_cap < slen)
    return -1;
  memcpy(sym_out, sym, (size_t)slen);
  return slen;
}

int32_t pipeline_codegen_io_driver_buf_call_sym(uint8_t *name, int32_t name_len, int32_t num_args, uint8_t *sym_out,
                                                int32_t sym_cap) {
  const char *sym;
  int32_t sym_len;
  if (!name || name_len <= 0)
    return 0;
  sym = NULL;
  sym_len = 0;
  if (num_args == 1 && name_len == 8 && wave107_name_prefix_eq(name, name_len, "register", 8)) {
    sym = "xlang_io_register_buf";
    sym_len = 20;
  } else if (num_args == 2 && name_len == 11 && wave107_name_prefix_eq(name, name_len, "submit_read", 11)) {
    sym = "xlang_io_submit_read_buf";
    sym_len = 23;
  } else if (num_args == 2 && name_len == 12 && wave107_name_prefix_eq(name, name_len, "submit_write", 12)) {
    sym = "xlang_io_submit_write_buf";
    sym_len = 24;
  }
  if (!sym)
    return 0;
  if (!sym_out || sym_cap < sym_len)
    return -1;
  memcpy(sym_out, sym, (size_t)sym_len);
  return sym_len;
}

int32_t pipeline_codegen_std_io_fixed_fd_emit_impl(uint8_t *prefix, int32_t prefix_len, uint8_t *name,
                                                   int32_t name_len) {
  if (!prefix || !name || prefix_len < 7 || name_len <= 0)
    return 0;
  if (!wave107_name_prefix_eq(prefix, prefix_len, "std_io_", 7))
    return 0;
  if (name_len >= 13 && wave107_name_prefix_eq(name, name_len, "read_fixed_fd", 13))
    return 1;
  if (name_len >= 14 && wave107_name_prefix_eq(name, name_len, "write_fixed_fd", 14))
    return 1;
  return 0;
}


/* wave108 skip_force leave cold twins — former pipeline_codegen_skip_force.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong skip/force/path predicates after host-cc leave.
 * Prefer void-star and u8-star like wave107. Historical path/NUL quirks twin C. */
typedef struct {
  const char *sym;
  int32_t sym_len;
  int32_t override_nargs;
} CodegenCallOverrideEntry;

static const CodegenCallOverrideEntry k_codegen_call_overrides[] = {
    {"vec_len_empty", 13, 0},
    {"std_vec_vec_len_empty", 21, 0},
    {"alloc_size_zero", 15, 0},
    {"std_heap_alloc_size_zero", 24, 0},
    {"runtime_ready", 13, 0},
    {"std_runtime_runtime_ready", 25, 0},
    {"string_new", 10, 0},
    {"std_string_string_new", 21, 0},
    {"placeholder", 11, 0},
    {"std_string_placeholder", 22, 0},
    {"thread_self", 11, 0},
    {"std_thread_thread_self", 22, 0},
    {"thread_dummy_entry_ptr", 22, 0},
    {"std_thread_thread_dummy_entry_ptr", 33, 0},
    {"now_monotonic_ns", 16, 0},
    {"std_time_now_monotonic_ns", 25, 0},
    {"now_monotonic_ms", 16, 0},
    {"std_time_now_monotonic_ms", 25, 0},
    {"fmt_i32", 7, 1},
    {"core_fmt_fmt_i32", 16, 1},
    {"print_i32", 9, 1},
    {"std_io_print_i32", 16, 1},
    {"print_u32", 9, 1},
    {"std_io_print_u32", 16, 1},
    {"print_i64", 9, 1},
    {"std_io_print_i64", 16, 1},
    {"std_fmt_println", 14, 2},
    {"std_fmt_print", 13, 2},
    {"std_debug_println", 16, 2},
    {"std_debug_print", 14, 2},
    {"ok_i32", 6, 1},
    {"core_result_ok_i32", 18, 1},
    {"err_i32", 7, 1},
    {"core_result_err_i32", 19, 1},
};

int32_t pipeline_codegen_call_num_args_override_lookup(uint8_t *buf, int32_t full, int32_t num_args) {
  int i, n;
  if (!buf || full <= 0 || num_args <= 0)
    return num_args;
  n = (int)(sizeof(k_codegen_call_overrides) / sizeof(k_codegen_call_overrides[0]));
  for (i = 0; i < n; i++) {
    if (full == k_codegen_call_overrides[i].sym_len &&
        memcmp(buf, k_codegen_call_overrides[i].sym, (size_t)full) == 0)
      return k_codegen_call_overrides[i].override_nargs;
  }
  return num_args;
}

/** codegen.x / asm backend：拼接 prefix+name 后查表，避免 .x 内 u8[N] 字面量与 *u8 下标在 asm emit 失败。 */
int32_t pipeline_codegen_call_num_args_override(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                int32_t num_args) {
  uint8_t buf[96];
  int32_t full = 0;
  int32_t i;
  if (num_args <= 0)
    return num_args;
  if (prefix && prefix_len > 0) {
    for (i = 0; i < prefix_len && full < 96; i++)
      buf[full++] = prefix[i];
  }
  if (name && name_len > 0) {
    for (i = 0; i < name_len && full < 96; i++)
      buf[full++] = name[i];
  }
  return pipeline_codegen_call_num_args_override_lookup(buf, full, num_args);
}

/** codegen.x：std.io.driver 桥接名前缀表（asm 不支持函数内数组字面量）。 */
static int wave108_name_prefix_eq(uint8_t *name, int32_t name_len, const char *pfx, int32_t plen) {
  if (!name || name_len < plen)
    return 0;
  return memcmp(name, pfx, (size_t)plen) == 0 ? 1 : 0;
}

int32_t pipeline_codegen_is_std_io_driver_bridge_name(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if ((name_len == 8 || name_len == 9) && wave108_name_prefix_eq(name, name_len, "register", 8))
    return 1;
  if ((name_len == 11 || name_len == 12) && wave108_name_prefix_eq(name, name_len, "submit_read", 11))
    return 1;
  if ((name_len == 12 || name_len == 13) && wave108_name_prefix_eq(name, name_len, "submit_write", 12))
    return 1;
  if ((name_len == 13 || name_len == 14) && wave108_name_prefix_eq(name, name_len, "wait_readable", 13))
    return 1;
  /* register_fixed_buffers only (exact prefix); not submit_write_batch_buf (also len 22) */
  if (name_len == 22 && wave108_name_prefix_eq(name, name_len, "register_fixed_buffers", 22))
    return 1;
  /*
   * submit_*_batch(_buf) / submit_register_fixed_buffers_buf：不得 skip。
   * 与 codegen.x / seed bridge 对齐：call 端仍要 std_io_driver_submit_*_batch 真体；
   * skip 后仅剩 undef（或 weak -1 假红 run-io-driver）。
   */
  return 0;
}

/** import 路径逐字节含末尾 NUL 比较（codegen.x asm 无数组字面量）。 */
static int wave108_path_bytes_eq(uint8_t *path, const char *expect, int32_t len_with_nul) {
  int32_t i;
  if (!path)
    return 0;
  for (i = 0; i < len_with_nul; i++)
    if (path[i] != (uint8_t)expect[i])
      return 0;
  return 1;
}

/** prefix+name 拼接是否等于 full（总长须一致）。 */
static int wave108_prefix_name_bytes_eq(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                        const char *full, int32_t full_len) {
  int32_t pi;
  int32_t ni;
  if (!prefix || !name || prefix_len <= 0 || name_len <= 0)
    return 0;
  if (prefix_len + name_len != full_len)
    return 0;
  for (pi = 0; pi < prefix_len; pi++)
    if (prefix[pi] != (uint8_t)full[pi])
      return 0;
  for (ni = 0; ni < name_len; ni++)
    if (name[ni] != (uint8_t)full[prefix_len + ni])
      return 0;
  return 1;
}

/** codegen.x：import 路径是否为 std.io.driver（含 NUL，14 字节）。 */
int32_t pipeline_codegen_path_is_std_io_driver_bytes(uint8_t *path) {
  return wave108_path_bytes_eq(path, "std.io.driver\0", 14);
}

/** codegen.x：import 路径是否为 std.io.core（含 NUL，12 字节）。 */
int32_t pipeline_codegen_path_is_std_io_core_bytes(uint8_t *path) {
  return wave108_path_bytes_eq(path, "std.io.core\0", 12);
}

/**
 * seed 用户程序 asm：std.io 族模块由 io.o + user_asm_seed_bridge 桩提供，勿整模块 emit（易宿主栈 Abort）。
 * 匹配 std.io、std.io.core、std.io.driver 等。
 */
int32_t pipeline_codegen_dep_skip_asm_user_std_io(uint8_t *path) {
  if (!path)
    return 0;
  if (pipeline_codegen_path_is_std_io_core_bytes(path) != 0)
    return 1;
  if (memcmp(path, "std.io", 6) != 0)
    return 0;
  if (path[6] == 0 || path[6] == '.')
    return 1;
  return 0;
}

/**
 * 产品轨 std link_only：唯一权威在 seeds/runtime_link_abi.from_x.c。
 * 此处勿再维护第二份表（双权威必然漂移；std.env 曾因表不一致假红）。
 * 声明见文件前部 extern；实现由 runtime_link_abi.o 提供。
 */
/* pipeline_codegen_std_dep_link_only — defined in runtime_link_abi.from_x.c */

/**
 * bootstrap -E / asm partial：compiler 前端模块符号已由 *_x.o 链入，勿整库 X C codegen（ast 等大库 emit 失败）。
 * 精确匹配 import 路径（如 ast、codegen、parser.x→parser）。
 */
int32_t pipeline_codegen_dep_skip_x_bootstrap_partial(uint8_t *path) {
  static const char *const k_exact[] = {
      "ast", "codegen", "parser", "typeck", "lexer", "preprocess", "pipeline", "lsp", "lsp.diag", "lsp.io",
      "driver", "driver.check", "driver.compile", "driver.emit", "driver.fmt", "driver.test", "driver.build",
      "driver.run", "asm.types", NULL};
  int32_t i;
  if (!path)
    return 0;
  for (i = 0; k_exact[i]; i++) {
    if (wave108_path_bytes_eq(path, k_exact[i], (int32_t)strlen(k_exact[i])))
      return 1;
  }
  return 0;
}

/**
 * codegen.x / seed：std.io.core 与 preamble weak 重复的 xlang_io_* 须跳过 emit。
 * 【Why 根源】仅 skip read_fixed/write_fixed（preamble weak）；勿 skip submit_read /
 *   submit_*_batch — 与 codegen.x codegen_should_skip_emit_std_io_core_io_dup 单权威对齐。
 *   旧 skip 假定 io.o/weak batch 权威；产品 C 不硬链 stubs 且 weak batch 已撤 → 假绿/UNDEF。
 * PLATFORM: SHARED.
 */
int32_t pipeline_codegen_should_skip_emit_std_io_core_io_dup(uint8_t *dep_path, uint8_t *name, int32_t name_len) {
  if (!dep_path || !name)
    return 0;
  if (memcmp(dep_path, "std.io.core", 11) != 0)
    return 0;
  if ((name_len == 18 || name_len == 19) && wave108_name_prefix_eq(name, name_len, "xlang_io_read_fixed", 18))
    return 1;
  if ((name_len == 19 || name_len == 20) && wave108_name_prefix_eq(name, name_len, "xlang_io_write_fixed", 19))
    return 1;
  return 0;
}

/** codegen.x：std.io handle_* 字面量函数须跳过 emit；dep_path 为空时仅按 name 判断。 */
int32_t pipeline_codegen_should_skip_emit_std_io_trivial_handle(uint8_t *dep_path, uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (dep_path && !wave108_path_bytes_eq(dep_path, "std.io\0", 7))
    return 0;
  if ((name_len == 12 || name_len == 13) && wave108_name_prefix_eq(name, name_len, "handle_stdin", 12))
    return 1;
  if ((name_len == 13 || name_len == 14) && wave108_name_prefix_eq(name, name_len, "handle_stdout", 13))
    return 1;
  if ((name_len == 13 || name_len == 14) && wave108_name_prefix_eq(name, name_len, "handle_stderr", 13))
    return 1;
  if ((name_len == 15 || name_len == 16) && wave108_name_prefix_eq(name, name_len, "handle_from_fd", 15))
    return 1;
  return 0;
}

/** codegen.x：合并 driver_should_skip_emit 三套逻辑（原 codegen_should_skip_emit_func）。 */
int32_t pipeline_codegen_should_skip_emit_func(uint8_t *dep_path, uint8_t *prefix, int32_t prefix_len,
                                               uint8_t *name, int32_t name_len) {
  int32_t ok_path;
  if (prefix && prefix_len > 0 && name && name_len > 0) {
    if (wave108_prefix_name_bytes_eq(prefix, prefix_len, name, name_len, "std_io_driver_driver_read_ptr_len", 33))
      return 1;
    if (wave108_prefix_name_bytes_eq(prefix, prefix_len, name, name_len, "std_io_driver_driver_read_ptr", 29))
      return 1;
  }
  if (dep_path) {
    ok_path = wave108_path_bytes_eq(dep_path, "std.io.driver\0", 14);
    if (!ok_path)
      ok_path = wave108_path_bytes_eq(dep_path, "std.io\0", 7);
    if (ok_path && name) {
      if ((name_len == 19 || name_len == 20) &&
          wave108_name_prefix_eq(name, name_len, "driver_read_ptr_len", 19))
        return 1;
      if ((name_len == 15 || name_len == 16) && wave108_name_prefix_eq(name, name_len, "driver_read_ptr", 15))
        return 1;
    }
  }
  if (prefix && prefix_len == 14 && name &&
      wave108_name_prefix_eq(prefix, prefix_len, "std_io_driver_", 14) &&
      pipeline_codegen_is_std_io_driver_bridge_name(name, name_len))
    return 1;
  if (dep_path && name && wave108_path_bytes_eq(dep_path, "std.io.driver\0", 14) &&
      pipeline_codegen_is_std_io_driver_bridge_name(name, name_len))
    return 1;
  if (prefix && prefix_len == 14 && name &&
      pipeline_codegen_should_skip_emit_std_io_trivial_handle(0, name, name_len))
    return 1;
  if (dep_path && name) {
    if (pipeline_codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len))
      return 1;
    if (wave108_path_bytes_eq(dep_path, "std.io.driver\0", 14) &&
        pipeline_codegen_should_skip_emit_std_io_trivial_handle(0, name, name_len))
      return 1;
  }
  return 0;
}

/** codegen.x：entry 模块是否含 read_message（LSP io 入口探测）。 */
int32_t pipeline_codegen_entry_is_lsp_io_module(void *module) {
  static const uint8_t rd[] = "read_message";
  int32_t i;
  int32_t n;
  uint8_t raw[64];
  int32_t nlen;
  if (!module)
    return 0;
  n = pipeline_module_num_funcs(module);
  for (i = 0; i < n; i++) {
    nlen = pipeline_module_func_name_len_at(module, i);
    if (nlen != 12)
      continue;
    pipeline_module_func_name_copy64(module, i, raw);
    if (wave108_name_prefix_eq(raw, 12, "read_message", 12))
      return 1;
  }
  return 0;
}

/** codegen.x：entry 模块是否含 lsp_main。 */
int32_t pipeline_codegen_entry_is_lsp_main_module(void *module) {
  static const uint8_t main_nm[] = "lsp_main";
  int32_t i;
  int32_t n;
  uint8_t raw[64];
  int32_t nlen;
  if (!module)
    return 0;
  n = pipeline_module_num_funcs(module);
  for (i = 0; i < n; i++) {
    nlen = pipeline_module_func_name_len_at(module, i);
    if (nlen != 8)
      continue;
    pipeline_module_func_name_copy64(module, i, raw);
    if (wave108_name_prefix_eq(raw, 8, "lsp_main", 8))
      return 1;
  }
  return 0;
}

/** codegen.x：C 前缀是否为 std_io_driver 族（13 字节 + 可选第 14 字节 NUL/_）。 */
int32_t pipeline_codegen_force_param_std_io_driver_prefix_ok(uint8_t *prefix, int32_t prefix_len) {
  static const char exp13[] = "std_io_driver";
  int32_t i;
  if (!prefix || prefix_len < 13)
    return 0;
  for (i = 0; i < 13; i++)
    if (prefix[i] != (uint8_t)exp13[i])
      return 0;
  if (prefix_len > 13) {
    uint8_t b14 = prefix[13];
    if (b14 != 0 && b14 != 95)
      return 0;
  }
  return 1;
}

/** codegen.x：std_io_driver submit_*_batch_buf 首参强制 size_t。 */
int32_t pipeline_codegen_force_param_size_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                            int32_t param_index) {
  if (param_index != 0)
    return 0;
  if (!pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len))
    return 0;
  if (!name)
    return 0;
  if (name_len == 21 && wave108_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
    return 1;
  if (name_len == 22 && wave108_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
    return 1;
  return 0;
}

/** codegen.x：std.io print 第二参强制 size_t（前缀须 std_io_）。 */
int32_t pipeline_codegen_force_param_size_t_std_io_print_str_second(uint8_t *prefix, int32_t prefix_len,
                                                                    uint8_t *name, int32_t name_len,
                                                                    int32_t param_index) {
  if (param_index != 1 || !name || name_len != 5)
    return 0;
  if (memcmp(name, "print", 5) != 0)
    return 0;
  if (!prefix || prefix_len < 7)
    return 0;
  return memcmp(prefix, "std_io_", 7) == 0 ? 1 : 0;
}

/** codegen.x：std_io_driver register/submit_read/submit_write 首参 ptrdiff_t。 */
int32_t pipeline_codegen_force_param_ptrdiff_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                               int32_t param_index) {
  if (param_index != 0 || !pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) || !name)
    return 0;
  if (name_len == 8 && wave108_name_prefix_eq(name, name_len, "register", 8))
    return 1;
  if (name_len == 11 && wave108_name_prefix_eq(name, name_len, "submit_read", 11))
    return 1;
  if (name_len == 12 && wave108_name_prefix_eq(name, name_len, "submit_write", 12))
    return 1;
  return 0;
}

/** codegen.x：std_io_driver 按名/下标强制 uint32_t（timeout_ms/nr）。 */
int32_t pipeline_codegen_force_param_uint32_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                              int32_t param_index) {
  if (!pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) || !name)
    return 0;
  if (param_index == 1) {
    if (name_len == 11 && wave108_name_prefix_eq(name, name_len, "submit_read", 11))
      return 1;
    if (name_len == 12 && wave108_name_prefix_eq(name, name_len, "submit_write", 12))
      return 1;
    if (name_len == 33 && wave108_name_prefix_eq(name, name_len, "submit_register_fixed_buffers_buf", 33))
      return 1;
    return 0;
  }
  if (param_index == 3) {
    if (name_len == 21 && wave108_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
      return 1;
    if (name_len == 22 && wave108_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
      return 1;
  }
  return 0;
}


/* wave109 type_to_c leave cold twins — former pipeline_codegen_type_to_c.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong type_kind_copy / vector_type_copy / type_kind_append / type_to_c_repr
 * after host-cc leave. Prefer void-star arena like wave105/108. */
int32_t pipeline_codegen_type_kind_cstr(int32_t kind, uint8_t **out_ptr) {
  static const char *k_i32 = "int32_t";
  static const char *k_i64 = "int64_t";
  static const char *k_bool = "int";
  static const char *k_u8 = "uint8_t";
  static const char *k_u32 = "uint32_t";
  static const char *k_u64 = "uint64_t";
  static const char *k_f32 = "float";
  static const char *k_f64 = "double";
  static const char *k_void = "void";
  static const char *k_usize = "size_t";
  static const char *k_isize = "ssize_t";
  if (!out_ptr)
    return 0;
  *out_ptr = NULL;
  switch (kind) {
  case 0:
    *out_ptr = (uint8_t *)k_i32;
    return 7;
  case 1:
    *out_ptr = (uint8_t *)k_bool;
    return 3;
  case 2:
    *out_ptr = (uint8_t *)k_u8;
    return 7;
  case 3:
    *out_ptr = (uint8_t *)k_u32;
    return 8;
  case 4:
    *out_ptr = (uint8_t *)k_u64;
    return 8;
  case 5:
    *out_ptr = (uint8_t *)k_i64;
    return 7;
  case 6:
    *out_ptr = (uint8_t *)k_usize;
    return 6;
  case 7:
    *out_ptr = (uint8_t *)k_isize;
    return 7;
  case 14:
    *out_ptr = (uint8_t *)k_f32;
    return 5;
  case 15:
    *out_ptr = (uint8_t *)k_f64;
    return 6;
  case 16:
    *out_ptr = (uint8_t *)k_void;
    return 4;
  default:
    return 0;
  }
}

int32_t pipeline_codegen_type_kind_copy(uint8_t *dst, int32_t cap, int32_t kind) {
  uint8_t *s;
  int32_t n;
  int32_t i;
  n = pipeline_codegen_type_kind_cstr(kind, &s);
  if (n <= 0 || !s || !dst || cap < n)
    return -1;
  for (i = 0; i < n; i++)
    dst[i] = s[i];
  return n;
}

int32_t pipeline_codegen_vector_type_cstr(int32_t elem_kind, int32_t lanes, uint8_t **out_ptr) {
  if (!out_ptr)
    return 0;
  *out_ptr = NULL;
  if (elem_kind == 0) {
    if (lanes == 4) {
      *out_ptr = (uint8_t *)"i32x4_t";
      return 7;
    }
    if (lanes == 8) {
      *out_ptr = (uint8_t *)"i32x8_t";
      return 7;
    }
    if (lanes == 16) {
      *out_ptr = (uint8_t *)"i32x16_t";
      return 8;
    }
  }
  if (elem_kind == 3) {
    if (lanes == 4) {
      *out_ptr = (uint8_t *)"u32x4_t";
      return 7;
    }
    if (lanes == 8) {
      *out_ptr = (uint8_t *)"u32x8_t";
      return 7;
    }
    if (lanes == 16) {
      *out_ptr = (uint8_t *)"u32x16_t";
      return 8;
    }
  }
  if (elem_kind == 14) {
    if (lanes == 4) {
      *out_ptr = (uint8_t *)"f32x4_t";
      return 7;
    }
    if (lanes == 8) {
      *out_ptr = (uint8_t *)"f32x8_t";
      return 7;
    }
    if (lanes == 16) {
      *out_ptr = (uint8_t *)"f32x16_t";
      return 8;
    }
  }
  return 0;
}

int32_t pipeline_codegen_vector_type_copy(uint8_t *dst, int32_t cap, int32_t elem_kind, int32_t lanes) {
  uint8_t *s;
  int32_t n;
  int32_t i;
  n = pipeline_codegen_vector_type_cstr(elem_kind, lanes, &s);
  if (n <= 0 || !s || !dst || cap < n)
    return -1;
  for (i = 0; i < n; i++)
    dst[i] = s[i];
  return n;
}

int32_t pipeline_codegen_type_kind_append(uint8_t *scratch, int32_t cap, int32_t w, int32_t kind) {
  uint8_t *s;
  int32_t n;
  int32_t i;
  n = pipeline_codegen_type_kind_cstr(kind, &s);
  if (n <= 0 || !s)
    return -1;
  for (i = 0; i < n; i++) {
    if (w >= cap - 1)
      return -1;
    scratch[w++] = s[i];
  }
  return w;
}

extern int32_t pipeline_type_named_name_into(void *arena, int32_t ref, uint8_t *out64);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t type_ref);
extern int32_t pipeline_type_array_size_at(void *arena, int32_t type_ref);
extern int32_t pipeline_arena_num_types(void *arena);

static int32_t pipeline_codegen_type_to_c_repr_inner(void *arena, uint8_t *scratch, int32_t cap, int32_t type_ref,
                                                     uint8_t *struct_prefix, int32_t struct_prefix_len) {
  uint8_t inner[256];
  uint8_t eb[256];
  int32_t tk;
  int32_t elem_ref;
  int32_t arr_sz;
  int32_t elem_kind;
  int32_t n;
  int32_t j;
  int32_t sp;
  int32_t plen;
  int32_t pi;
  int32_t hi;
  int32_t w;
  int32_t h;
  int32_t name_len;
  uint8_t nm[128];
  int32_t sn;
  int32_t nt;

  if (cap < 16)
    return -1;
  nt = arena ? pipeline_arena_num_types(arena) : 0;
  if (!arena || type_ref <= 0 || type_ref > nt) {
    static const uint8_t k_i32[7] = {'i', 'n', 't', '3', '2', '_', 't'};
    if (cap < 7)
      return -1;
    for (j = 0; j < 7; j++)
      scratch[j] = k_i32[j];
    return 7;
  }
  tk = pipeline_type_kind_ord_at(arena, type_ref);
  elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  arr_sz = pipeline_type_array_size_at(arena, type_ref);
  if (tk == 9 && elem_ref > 0) {
    n = pipeline_codegen_type_to_c_repr_inner(arena, inner, 256, elem_ref, struct_prefix, struct_prefix_len);
    if (n < 0 || n + 2 >= cap)
      return -1;
    for (j = 0; j < n; j++)
      scratch[j] = inner[j];
    scratch[n] = (uint8_t)' ';
    scratch[n + 1] = (uint8_t)'*';
    return n + 2;
  }
  if (tk == 10 && elem_ref > 0)
    return pipeline_codegen_type_to_c_repr_inner(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
  if (tk == 13 && elem_ref > 0) {
    elem_kind = pipeline_type_kind_ord_at(arena, elem_ref);
    n = pipeline_codegen_vector_type_copy(scratch, cap, elem_kind, arr_sz);
    if (n >= 0)
      return n;
    return pipeline_codegen_type_kind_copy(scratch, cap, 0);
  }
  if (tk == 12 && elem_ref > 0)
    return pipeline_codegen_type_to_c_repr_inner(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
  if (tk == 11 && elem_ref > 0) {
    n = pipeline_codegen_type_to_c_repr_inner(arena, eb, 256, elem_ref, struct_prefix, struct_prefix_len);
    if (n < 0 || n >= 256)
      return -1;
    sp = 0;
    if (n >= 7 && eb[0] == 's' && eb[1] == 't' && eb[2] == 'r' && eb[3] == 'u' && eb[4] == 'c' && eb[5] == 't'
        && eb[6] == ' ') {
      sp = 7;
      while (sp < n && eb[sp] == ' ')
        sp++;
    }
    plen = n - sp;
    if (plen <= 0 || 19 + plen >= cap)
      return -1;
    {
      static const uint8_t hdr[19] = {'s', 't', 'r', 'u', 'c', 't', ' ', 'x', 'l', 'a', 'n', 'g', '_', 's', 'l', 'i', 'c', 'e', '_'};
      if (19 + plen >= cap)
        return -1;
      for (hi = 0; hi < 19; hi++)
        scratch[hi] = hdr[hi];
    }
    for (pi = 0; pi < plen; pi++)
      scratch[19 + pi] = eb[sp + pi];
    return 19 + plen;
  }
  name_len = pipeline_type_named_name_into(arena, type_ref, nm);
  if (tk == 8 && name_len > 0) {
    if (name_len == 2 && nm[0] == 'i' && nm[1] == '8') {
      static const uint8_t k_i8[6] = {'i', 'n', 't', '8', '_', 't'};
      if (cap < 6)
        return -1;
      for (j = 0; j < 6; j++)
        scratch[j] = k_i8[j];
      return 6;
    }
    if (name_len == 3 && nm[0] == 'i' && nm[1] == '1' && nm[2] == '6') {
      static const uint8_t k_i16[7] = {'i', 'n', 't', '1', '6', '_', 't'};
      if (cap < 7)
        return -1;
      for (j = 0; j < 7; j++)
        scratch[j] = k_i16[j];
      return 7;
    }
    if (name_len == 3 && nm[0] == 'u' && nm[1] == '1' && nm[2] == '6') {
      static const uint8_t k_u16[8] = {'u', 'i', 'n', 't', '1', '6', '_', 't'};
      if (cap < 8)
        return -1;
      for (j = 0; j < 8; j++)
        scratch[j] = k_u16[j];
      return 8;
    }
    {
      static const uint8_t hdr2[7] = {'s', 't', 'r', 'u', 'c', 't', ' '};
      w = 0;
      for (h = 0; h < 7; h++) {
        if (w >= cap - 1)
          return -1;
        scratch[w++] = hdr2[h];
      }
    }
    if (struct_prefix && struct_prefix_len > 0) {
      for (pi = 0; pi < struct_prefix_len; pi++) {
        if (w >= cap - 1)
          return -1;
        scratch[w++] = struct_prefix[pi];
      }
    }
    for (pi = 0; pi < name_len && pi < 64; pi++) {
      if (w >= cap - 1)
        return -1;
      scratch[w++] = nm[pi];
    }
    return w;
  }
  sn = pipeline_codegen_type_kind_copy(scratch, cap, tk);
  if (sn > 0)
    return sn;
  return pipeline_codegen_type_kind_copy(scratch, cap, 0);
}

int32_t pipeline_codegen_type_to_c_repr(void *arena, uint8_t *scratch, int32_t cap, int32_t type_ref,
                                        uint8_t *struct_prefix, int32_t struct_prefix_len) {
  return pipeline_codegen_type_to_c_repr_inner(arena, scratch, cap, type_ref, struct_prefix, struct_prefix_len);
}



/* wave110 struct_emit leave cold twins — former pipeline_codegen_struct_emit.c.
 * PLATFORM: SHARED — only when pure FROM_X object is not linked. Product pure
 * owns strong prologue/tag/field emit after host-cc leave.
 * Prefer void-star arena/out like wave105/109. */
#ifndef PIPELINE_CODEGEN_OUTBUF_CAP
#define PIPELINE_CODEGEN_OUTBUF_CAP 9437184
#endif
#define PIPELINE_CODEGEN_STRUCT_TAG_MAX 256
#define PIPELINE_CODEGEN_STRUCT_TAG_CAP 128

static int g_codegen_c_file_prologue_done_w110;
static char g_codegen_struct_tags_w110[PIPELINE_CODEGEN_STRUCT_TAG_MAX][PIPELINE_CODEGEN_STRUCT_TAG_CAP];
static int g_codegen_struct_tag_n_w110;

int32_t pipeline_codegen_c_file_prologue_done_get(void) {
  return g_codegen_c_file_prologue_done_w110;
}

void pipeline_codegen_c_file_prologue_done_set(int32_t v) {
  g_codegen_c_file_prologue_done_w110 = v != 0 ? 1 : 0;
}

void pipeline_codegen_c_file_prologue_done_reset(void) {
  g_codegen_c_file_prologue_done_w110 = 0;
  g_codegen_struct_tag_n_w110 = 0;
}

int32_t pipeline_codegen_struct_tag_try_claim(const uint8_t *prefix, int32_t prefix_len, const uint8_t *name,
                                             int32_t name_len) {
  char tag[PIPELINE_CODEGEN_STRUCT_TAG_CAP];
  int32_t i;
  int32_t tlen;
  if (!name || name_len <= 0)
    return -1;
  if (prefix_len < 0)
    prefix_len = 0;
  if (!prefix)
    prefix_len = 0;
  tlen = prefix_len + name_len;
  if (tlen <= 0 || tlen >= PIPELINE_CODEGEN_STRUCT_TAG_CAP)
    return -1;
  if (prefix_len > 0)
    memcpy(tag, prefix, (size_t)prefix_len);
  memcpy(tag + prefix_len, name, (size_t)name_len);
  tag[tlen] = '\0';
  for (i = 0; i < g_codegen_struct_tag_n_w110; i++) {
    if (strcmp(g_codegen_struct_tags_w110[i], tag) == 0)
      return 0;
  }
  if (g_codegen_struct_tag_n_w110 >= PIPELINE_CODEGEN_STRUCT_TAG_MAX)
    return 0;
  memcpy(g_codegen_struct_tags_w110[g_codegen_struct_tag_n_w110], tag, (size_t)tlen + 1);
  g_codegen_struct_tag_n_w110++;
  return 1;
}

static int32_t pipeline_codegen_out_append_bytes_w110(void *out, const uint8_t *p, int32_t n) {
  int32_t len;
  uint8_t *data;
  int32_t i;
  if (!out || !p || n < 0)
    return -1;
  len = codegen_out_buf_len(out);
  if (len + n > (int32_t)PIPELINE_CODEGEN_OUTBUF_CAP)
    return -1;
  data = (uint8_t *)out;
  for (i = 0; i < n; i++)
    data[len + i] = p[i];
  codegen_out_buf_set_len(out, len + n);
  return 0;
}

static int32_t pipeline_codegen_out_append_byte_w110(void *out, uint8_t b) {
  return pipeline_codegen_out_append_bytes_w110(out, &b, 1);
}

static int32_t pipeline_codegen_out_format_int_w110(void *out, int32_t val) {
  char buf[16];
  int n;
  if (!out)
    return -1;
  n = snprintf(buf, sizeof(buf), "%d", (int)val);
  if (n <= 0 || n >= (int)sizeof(buf))
    return -1;
  return pipeline_codegen_out_append_bytes_w110(out, (const uint8_t *)buf, n);
}

extern int32_t pipeline_codegen_type_kind_copy(uint8_t *dst, int32_t cap, int32_t kind);
extern int32_t pipeline_codegen_vector_type_copy(uint8_t *dst, int32_t cap, int32_t elem_kind, int32_t lanes);
extern int32_t pipeline_codegen_type_to_c_repr(void *arena, uint8_t *scratch, int32_t cap, int32_t type_ref,
                                              uint8_t *struct_prefix, int32_t struct_prefix_len);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(void *arena, int32_t type_ref);
extern int32_t pipeline_type_array_size_at(void *arena, int32_t type_ref);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t ref, uint8_t *out64);

static int32_t pipeline_codegen_emit_struct_field_type_inner_w110(void *arena, void *out, int32_t type_ref,
                                                                  uint8_t *struct_prefix, int32_t struct_prefix_len) {
  static uint8_t scratch[256];
  int32_t ord;
  int32_t inner;
  int32_t asz;
  int32_t ik;
  int32_t lanes_v;
  int32_t nl;
  int32_t sn;
  uint8_t nm[128];

  ord = pipeline_type_kind_ord_at(arena, type_ref);
  if (!arena || type_ref <= 0 || ord < 0) {
    static const uint8_t k_i32[7] = {'i', 'n', 't', '3', '2', '_', 't'};
    return pipeline_codegen_out_append_bytes_w110(out, k_i32, 7);
  }
  if (ord == 9) {
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    if (pipeline_codegen_emit_struct_field_type_inner_w110(arena, out, inner, struct_prefix, struct_prefix_len) != 0)
      return -1;
    if (pipeline_codegen_out_append_byte_w110(out, (uint8_t)' ') != 0)
      return -1;
    return pipeline_codegen_out_append_byte_w110(out, (uint8_t)'*');
  }
  if (ord == 10) {
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    asz = pipeline_type_array_size_at(arena, type_ref);
    if (pipeline_codegen_emit_struct_field_type_inner_w110(arena, out, inner, struct_prefix, struct_prefix_len) != 0)
      return -1;
    if (pipeline_codegen_out_append_byte_w110(out, (uint8_t)'[') != 0)
      return -1;
    if (pipeline_codegen_out_format_int_w110(out, asz) != 0)
      return -1;
    return pipeline_codegen_out_append_byte_w110(out, (uint8_t)']');
  }
  if (ord == 8) {
    static const uint8_t hdr[7] = {'s', 't', 'r', 'u', 'c', 't', ' '};
    nl = pipeline_type_named_name_into(arena, type_ref, nm);
    if (nl <= 0) {
      static const uint8_t k_i32[7] = {'i', 'n', 't', '3', '2', '_', 't'};
      return pipeline_codegen_out_append_bytes_w110(out, k_i32, 7);
    }
    if (pipeline_codegen_out_append_bytes_w110(out, hdr, 7) != 0)
      return -1;
    if (struct_prefix && struct_prefix_len > 0) {
      if (pipeline_codegen_out_append_bytes_w110(out, struct_prefix, struct_prefix_len) != 0)
        return -1;
    }
    return pipeline_codegen_out_append_bytes_w110(out, nm, nl);
  }
  if (ord == 11) {
    nl = pipeline_codegen_type_to_c_repr(arena, scratch, 256, type_ref, struct_prefix, struct_prefix_len);
    if (nl <= 0)
      return -1;
    return pipeline_codegen_out_append_bytes_w110(out, scratch, nl);
  }
  if (ord == 12) {
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    return pipeline_codegen_emit_struct_field_type_inner_w110(arena, out, inner, struct_prefix, struct_prefix_len);
  }
  if (ord == 13) {
    lanes_v = pipeline_type_array_size_at(arena, type_ref);
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    ik = pipeline_type_kind_ord_at(arena, inner);
    sn = pipeline_codegen_vector_type_copy(scratch, 256, ik, lanes_v);
    if (sn > 0)
      return pipeline_codegen_out_append_bytes_w110(out, scratch, sn);
    sn = pipeline_codegen_type_kind_copy(scratch, 256, 0);
    if (sn > 0)
      return pipeline_codegen_out_append_bytes_w110(out, scratch, sn);
    return -1;
  }
  sn = pipeline_codegen_type_kind_copy(scratch, 256, ord);
  if (sn > 0)
    return pipeline_codegen_out_append_bytes_w110(out, scratch, sn);
  sn = pipeline_codegen_type_kind_copy(scratch, 256, 0);
  if (sn > 0)
    return pipeline_codegen_out_append_bytes_w110(out, scratch, sn);
  return -1;
}

int32_t pipeline_codegen_emit_struct_field_type(void *arena, void *out, int32_t type_ref, uint8_t *struct_prefix,
                                               int32_t struct_prefix_len) {
  return pipeline_codegen_emit_struct_field_type_inner_w110(arena, out, type_ref, struct_prefix, struct_prefix_len);
}

int32_t pipeline_codegen_emit_struct_field_decl(void *arena, void *out, int32_t type_ref, uint8_t *field_name,
                                                int32_t field_name_len, uint8_t *struct_prefix,
                                                int32_t struct_prefix_len) {
  int32_t base_type_ref;
  int32_t dims[8];
  int32_t ndim;
  int32_t i;

  if (!arena || !out || type_ref <= 0 || !field_name || field_name_len <= 0)
    return -1;

  base_type_ref = type_ref;
  ndim = 0;
  while (base_type_ref > 0 && pipeline_type_kind_ord_at(arena, base_type_ref) == 10 && ndim < 8) {
    dims[ndim] = pipeline_type_array_size_at(arena, base_type_ref);
    base_type_ref = pipeline_type_elem_ref_at(arena, base_type_ref);
    ndim++;
  }

  if (pipeline_codegen_emit_struct_field_type_inner_w110(arena, out, base_type_ref, struct_prefix, struct_prefix_len) != 0)
    return -1;
  if (pipeline_codegen_out_append_byte_w110(out, (uint8_t)' ') != 0)
    return -1;
  if (pipeline_codegen_out_append_bytes_w110(out, field_name, field_name_len) != 0)
    return -1;
  for (i = 0; i < ndim; i++) {
    if (pipeline_codegen_out_append_byte_w110(out, (uint8_t)'[') != 0)
      return -1;
    if (pipeline_codegen_out_format_int_w110(out, dims[i]) != 0)
      return -1;
    if (pipeline_codegen_out_append_byte_w110(out, (uint8_t)']') != 0)
      return -1;
  }
  return 0;
}


/* wave111 codegen_dep leave cold twins — former pipeline_codegen_dep.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns strong orchestration.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X from wave101 leave twins.
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked.
 */

/* Cap residual faces not yet declared earlier in this cold block. */
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst);
extern void *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern int32_t pipeline_dep_ctx_use_asm_backend(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern void pipeline_dep_ctx_set_import_path(void *ctx, int32_t idx, uint8_t *path, int32_t len);
extern void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m);
extern void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a);
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t driver_dep_slot_for_path(const char *path);
extern uint8_t *driver_dep_module_buf(int32_t i);
extern uint8_t *driver_dep_arena_buf(int32_t i);
extern int pipeline_codegen_std_dep_link_only(uint8_t *path);
extern int32_t asm_asm_codegen_ast(void *module, void *arena, void *out_buf, void *ctx);
extern int32_t codegen_codegen_x_ast(void *module, void *arena, void *out_buf, void *ctx, int32_t dep_index);
extern void driver_set_current_dep_path_for_codegen(const char *path);
extern void driver_diagnostic_after_dep_codegen(int32_t j, int32_t out_len);
extern void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep);
extern int32_t driver_skip_codegen_dep_0_get(void);
extern void driver_diagnostic_entry_already(int32_t v);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_entry_module(void *module, void *arena);
extern int32_t parser_copy_module_import_path64(void *module, int32_t i, uint8_t out[128]);
extern int32_t pipeline_resolve_path_x(void *ctx, uint8_t *import_path, int32_t path_len);

static int32_t pipeline_dep_ctx_has_earlier_same_import_path_c_w111(struct ast_PipelineDepCtx *ctx, int32_t dep_j) {
  int32_t path_len, prev_j;
  uint8_t path_buf[128];
  if (!ctx || dep_j <= 0)
    return 0;
  path_len = pipeline_dep_ctx_import_path_len(ctx, dep_j);
  if (path_len <= 0 || path_len > (int32_t)sizeof(path_buf))
    return 0;
  memset(path_buf, 0, sizeof(path_buf));
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, path_buf);
  for (prev_j = 0; prev_j < dep_j; prev_j++) {
    int32_t prev_len = pipeline_dep_ctx_import_path_len(ctx, prev_j);
    uint8_t prev_buf[128];
    if (prev_len == path_len && prev_len > 0 && prev_len <= (int32_t)sizeof(prev_buf)) {
      memset(prev_buf, 0, sizeof(prev_buf));
      pipeline_dep_ctx_import_path_copy64(ctx, prev_j, prev_buf);
      if (memcmp(prev_buf, path_buf, (size_t)path_len) == 0)
        return 1;
    }
  }
  return 0;
}

int32_t run_x_pipeline_codegen_one_dep_emit(void *dep_mod, void *out_buf, void *ctx_v, int32_t dep_j,
                                            int32_t skip_asm_dep_codegen, int32_t use_asm_backend) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  uint8_t dep_path_buf[128];
  void *mod = dep_mod;
  if (!out_buf || !ctx || dep_j < 0)
    return -1;
  if (pipeline_dep_ctx_has_earlier_same_import_path_c_w111(ctx, dep_j) != 0)
    return 0;
  memset(dep_path_buf, 0, sizeof(dep_path_buf));
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dep_path_buf);
  if (!mod) {
    int32_t sync_slot = driver_dep_slot_for_path((const char *)dep_path_buf);
    if (sync_slot < 0)
      sync_slot = dep_j;
    mod = driver_dep_module_buf(sync_slot);
    if (mod) {
      ast_pipeline_dep_ctx_set_module(ctx, dep_j, (struct ast_Module *)mod);
      ast_pipeline_dep_ctx_set_arena(ctx, dep_j, (struct ast_ASTArena *)driver_dep_arena_buf(sync_slot));
    }
  }
  if (pipeline_codegen_dep_skip_x_bootstrap_partial(dep_path_buf) != 0)
    return 0;
  if (pipeline_codegen_std_dep_link_only(dep_path_buf) != 0)
    return 0;
  if (skip_asm_dep_codegen != 0)
    return 0;
  if (mod && pipeline_module_num_funcs(mod) > 0) {
    void *arena_j = pipeline_dep_ctx_arena_at(ctx, dep_j);
    if (use_asm_backend != 0) {
      if (asm_asm_codegen_ast(mod, arena_j, out_buf, ctx) != 0)
        return -6;
    } else if (codegen_codegen_x_ast(mod, arena_j, out_buf, ctx, dep_j) != 0) {
      return -6;
    }
  }
  return 0;
}

int32_t run_x_pipeline_codegen_entry_emit(void *module, void *arena, void *out_buf, void *ctx,
                                          int32_t use_asm_backend) {
  if (!module || !arena || !out_buf || !ctx)
    return -1;
  if (use_asm_backend != 0) {
    if (asm_asm_codegen_ast(module, arena, out_buf, ctx) != 0)
      return -6;
  } else if (codegen_codegen_x_ast(module, arena, out_buf, ctx, -1) != 0) {
    return -6;
  }
  return 0;
}

int32_t run_x_pipeline_parse_entry_if_needed_c(void *module, void *arena, uint8_t *source_data,
                                               size_t source_len, void *ctx_v) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  if (!module || !arena || !ctx)
    return -1;
  driver_diagnostic_entry_already(pipeline_dep_ctx_entry_already_parsed(ctx));
  if (pipeline_dep_ctx_entry_already_parsed(ctx) != 0) {
    driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
    driver_diagnostic_entry_module(module, arena);
    return 0;
  }
  return run_x_pipeline_parse_entry_do_parse_c(module, arena, source_data, source_len, ctx);
}

int32_t pipeline_fill_dep_import_path_from_buf_c(void *ctx, int32_t dep_j, uint8_t *path_buf) {
  int32_t path_len = 0;
  if (!ctx || !path_buf || dep_j < 0)
    return -1;
  while (path_len < 127 && path_buf[path_len] != 0)
    path_len++;
  if (path_len > 0)
    pipeline_dep_ctx_set_import_path(ctx, dep_j, path_buf, path_len);
  return 0;
}

int32_t pipeline_resolve_path_x_from_buf64_c(void *ctx, uint8_t *path_buf) {
  int32_t path_len = 0;
  if (!ctx || !path_buf)
    return -1;
  while (path_len < 127 && path_buf[path_len] != 0)
    path_len++;
  if (path_len <= 0)
    return -1;
  return pipeline_resolve_path_x(ctx, path_buf, path_len);
}

int32_t run_x_pipeline_fill_dep_import_path_c(void *module, void *ctx_v, int32_t dep_j) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  uint8_t path_buf[128];
  int32_t path_len = 0;
  int32_t existing;
  if (!module || !ctx || dep_j < 0)
    return -1;
  existing = pipeline_dep_ctx_import_path_len(ctx, dep_j);
  if (existing > 0)
    return 0;
  memset(path_buf, 0, sizeof(path_buf));
  (void)parser_copy_module_import_path64(module, dep_j, path_buf);
  while (path_len < 127 && path_buf[path_len] != 0)
    path_len++;
  if (path_len > 0)
    pipeline_dep_ctx_set_import_path(ctx, dep_j, path_buf, path_len);
  return 0;
}

int32_t pipeline_prepare_dep_codegen_path_c(void *ctx_v, int32_t dep_j, uint8_t *dst) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  if (!ctx || !dst || dep_j < 0)
    return -1;
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dst);
  driver_set_current_dep_path_for_codegen((const char *)dst);
  return 0;
}

int32_t pipeline_finish_dep_codegen_diag_c(int32_t dep_j, void *out_buf) {
  if (!out_buf)
    return -1;
  driver_diagnostic_after_dep_codegen(dep_j, codegen_out_buf_len(out_buf));
  driver_set_current_dep_path_for_codegen(NULL);
  return 0;
}

int32_t run_x_pipeline_codegen_one_dep_c(void *module, void *out_buf, void *ctx_v, int32_t dep_j,
                                         int32_t skip_asm_dep_codegen) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  uint8_t dep_path_buf[128];
  void *dep_mod;
  int32_t use_asm;
  if (!module || !out_buf || !ctx || dep_j < 0)
    return -1;
  if (dep_j == 0 && driver_skip_codegen_dep_0_get() != 0)
    return 0;
  if (run_x_pipeline_fill_dep_import_path_c(module, ctx, dep_j) != 0)
    return -1;
  memset(dep_path_buf, 0, sizeof(dep_path_buf));
  pipeline_prepare_dep_codegen_path_c(ctx, dep_j, dep_path_buf);
  dep_mod = pipeline_dep_ctx_module_at(ctx, dep_j);
  if (!dep_mod) {
    int32_t sync_slot = driver_dep_slot_for_path((const char *)dep_path_buf);
    if (sync_slot < 0)
      sync_slot = dep_j;
    dep_mod = driver_dep_module_buf(sync_slot);
    if (dep_mod) {
      ast_pipeline_dep_ctx_set_module(ctx, dep_j, (struct ast_Module *)dep_mod);
      ast_pipeline_dep_ctx_set_arena(ctx, dep_j, (struct ast_ASTArena *)driver_dep_arena_buf(sync_slot));
    }
  }
  if (pipeline_codegen_dep_skip_x_bootstrap_partial(dep_path_buf) != 0) {
    driver_set_current_dep_path_for_codegen(NULL);
    return 0;
  }
  use_asm = pipeline_dep_ctx_use_asm_backend(ctx);
  if (run_x_pipeline_codegen_one_dep_emit(dep_mod, out_buf, ctx, dep_j, skip_asm_dep_codegen, use_asm) != 0) {
    driver_diagnostic_codegen_fail(dep_j, 1);
    return -6;
  }
  pipeline_finish_dep_codegen_diag_c(dep_j, out_buf);
  return 0;
}

static void *g_codegen_entry_arena_for_mono_w111;

void *pipeline_codegen_entry_arena_for_mono_get(void) {
  return g_codegen_entry_arena_for_mono_w111;
}

int32_t run_x_pipeline_codegen_deps_c(void *module, void *arena, void *out_buf, void *ctx_v,
                                      int32_t skip_asm_dep_codegen) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  int32_t ndep, j;
  if (!module || !arena || !out_buf || !ctx)
    return -1;
  g_codegen_entry_arena_for_mono_w111 = arena;
  pipeline_codegen_c_file_prologue_done_reset();
  ndep = pipeline_dep_ctx_ndep(ctx);
  for (j = 0; j < ndep; j++) {
    if (pipeline_dep_ctx_has_earlier_same_import_path_c_w111(ctx, j) != 0)
      continue;
    if (run_x_pipeline_codegen_one_dep_c(module, out_buf, ctx, j, skip_asm_dep_codegen) != 0)
      return -6;
  }
  return 0;
}

int32_t run_x_pipeline_codegen_entry_c(void *module, void *arena, void *out_buf, void *ctx_v) {
  struct ast_PipelineDepCtx *ctx = (struct ast_PipelineDepCtx *)ctx_v;
  if (!module || !arena || !out_buf || !ctx)
    return -1;
  driver_diagnostic_entry_module(module, arena);
  if (run_x_pipeline_codegen_entry_emit(module, arena, out_buf, ctx, pipeline_dep_ctx_use_asm_backend(ctx)) != 0) {
    driver_diagnostic_codegen_fail(0, 0);
    return -6;
  }
  return 0;
}

/* wave112 parse_typeck_dispatch leave cold twins — former pipeline_parse_typeck_dispatch.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns strong faces.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X from wave101 leave twins.
 * Cap residual result_c / impl_rc live always in pipeline_parse_orch.c.
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked.
 */

extern int32_t pipeline_parse_into_with_init_buf_impl_rc(struct ast_ASTArena *arena, struct ast_Module *module,
                                                         uint8_t *data, int32_t len, int32_t *out_ok,
                                                         int32_t *out_main_idx);
extern int32_t pipeline_driver_x_pipeline_skip_typeck(void);
extern int32_t pipeline_driver_asm_build_skip_typeck(void);
extern int32_t pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx);
extern void pipeline_typeck_set_active_ctx_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);
extern void pipeline_typeck_set_dep_ctx(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_scan_module_struct_stack_escape_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                 struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_unused_private_funcs(struct ast_Module *m, struct ast_ASTArena *a);
extern int32_t typeck_typeck_x_ast(struct ast_Module *module, struct ast_ASTArena *arena, struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_typeck_x_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_module_main_func_index(struct ast_Module *m);
extern void pipeline_module_set_main_func_index(struct ast_Module *m, int32_t idx);
extern void pipeline_lint_set_source_buf(const uint8_t *data, int32_t len);
extern void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types);
extern void driver_diagnostic_typeck_fail(void);
extern int32_t pipeline_arena_num_types(struct ast_ASTArena *a);
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t parser_get_module_num_imports(struct ast_Module *module);
extern int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx);
extern void pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n);
extern void pipeline_dep_ctx_set_import_path(void *ctx, int32_t idx, uint8_t *path, int32_t len);
extern void *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m);
extern void pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a);
extern int32_t pipeline_try_bind_seeded_import(struct ast_PipelineDepCtx *ctx, int32_t import_idx, int32_t global_slot);
extern int32_t pipeline_load_import_from_disk_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                struct ast_PipelineDepCtx *ctx, int32_t import_idx);
extern int32_t pipeline_sync_dep_slots_from_driver_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);
extern void typeck_typeck_merge_dep_struct_layouts_into_entry(struct ast_Module *mod, struct ast_ASTArena *arena,
                                                              struct ast_PipelineDepCtx *ctx);
extern void typeck_typeck_wpo_unify_soa_layouts(struct ast_Module *entry, struct ast_PipelineDepCtx *ctx);
extern int32_t driver_dep_seeded_get(int32_t i);
extern const char *driver_dep_path_registry_at(int32_t i);
extern uint8_t *driver_dep_module_buf(int32_t i);
extern uint8_t *driver_dep_arena_buf(int32_t i);
extern int32_t driver_dep_slot_for_path(const char *path);
extern int32_t parser_copy_module_import_path64(void *module, int32_t i, uint8_t out[128]);
extern int32_t pipeline_resolve_path_x(void *ctx, uint8_t *import_path, int32_t path_len);
extern int32_t pipeline_read_file_x(void *ctx);

static int32_t g_pipeline_parse_scalars_ok_w112;
static int32_t g_pipeline_parse_scalars_main_idx_w112;

int32_t pipeline_parse_scalars_ok_get(void) {
  return g_pipeline_parse_scalars_ok_w112;
}

int32_t pipeline_parse_scalars_main_idx_get(void) {
  return g_pipeline_parse_scalars_main_idx_w112;
}

int32_t pipeline_should_skip_x_typeck_c(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return 0;
  if (pipeline_driver_x_pipeline_skip_typeck() != 0)
    return 1;
  if (pipeline_dep_ctx_asm_entry_module_only(ctx) == 0)
    return 0;
  if (pipeline_driver_asm_build_skip_typeck() != 0)
    return 1;
  return 0;
}

void pipeline_parse_fail_diag_scalars_c(struct ast_Module *module, struct ast_ASTArena *arena) {
  if (!module || !arena)
    return;
  driver_diagnostic_parse_fail(g_pipeline_parse_scalars_main_idx_w112, pipeline_module_num_funcs(module),
                               pipeline_arena_num_types(arena));
}

int32_t pipeline_parse_into_with_init_buf_scalars(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *data,
                                                   int32_t len, int32_t *out_ok, int32_t *out_main_idx) {
  int32_t ok = 1;
  int32_t main_idx = -1;
  if (!arena || !module || !data || len <= 0) {
    g_pipeline_parse_scalars_ok_w112 = 1;
    g_pipeline_parse_scalars_main_idx_w112 = -1;
    if (out_ok)
      *out_ok = 1;
    if (out_main_idx)
      *out_main_idx = -1;
    return 0;
  }
  (void)pipeline_parse_into_with_init_buf_impl_rc(arena, module, data, len, &ok, &main_idx);
  g_pipeline_parse_scalars_ok_w112 = ok;
  g_pipeline_parse_scalars_main_idx_w112 = main_idx;
  if (out_ok)
    *out_ok = ok;
  if (out_main_idx)
    *out_main_idx = main_idx;
  return 0;
}

int32_t pipeline_parse_into_with_init_buf_scalars_sidecar(struct ast_ASTArena *arena, struct ast_Module *module,
                                                          uint8_t *data, int32_t len) {
  return pipeline_parse_into_with_init_buf_scalars(arena, module, data, len, NULL, NULL);
}

int32_t pipeline_parse_into_with_init_slice_scalars_sidecar(struct ast_ASTArena *arena, struct ast_Module *module,
                                                             struct xlang_slice_uint8_t *source) {
  if (!source || !source->data || source->length == 0)
    return pipeline_parse_into_with_init_buf_scalars(arena, module, NULL, 0, NULL, NULL);
  if (source->length > (size_t)2147483647)
    return pipeline_parse_into_with_init_buf_scalars(arena, module, source->data, 2147483647, NULL, NULL);
  return pipeline_parse_into_with_init_buf_scalars(arena, module, source->data, (int32_t)source->length, NULL, NULL);
}

int32_t pipeline_parse_apply_main_from_scalars_c(struct ast_Module *module, struct ast_ASTArena *arena) {
  int32_t ok;
  int32_t main_idx;
  if (!module || !arena)
    return -2;
  ok = pipeline_parse_scalars_ok_get();
  main_idx = pipeline_parse_scalars_main_idx_get();
  if (ok != 0) {
    pipeline_parse_fail_diag_scalars_c(module, arena);
    return -2;
  }
  pipeline_module_set_main_func_index(module, main_idx);
  return 0;
}

int32_t pipeline_parse_set_main_from_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *data,
                                           int32_t len) {
  int32_t ok;
  int32_t main_idx;
  if (!module || !arena || !data || len <= 0)
    return -2;
  pipeline_lint_set_source_buf(data, len);
  pipeline_parse_into_with_init_buf_scalars(arena, module, data, len, &ok, &main_idx);
  if (ok != 0) {
    driver_diagnostic_parse_fail(main_idx, pipeline_module_num_funcs(module), pipeline_arena_num_types(arena));
    return -2;
  }
  pipeline_module_set_main_func_index(module, main_idx);
  return 0;
}

int32_t pipeline_typeck_parsed_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                        struct ast_PipelineDepCtx *ctx, int32_t fail_mapped) {
  if (!module || !arena || !ctx) {
    if (fail_mapped != 0)
      return fail_mapped;
    return -1;
  }
  if (pipeline_module_num_funcs(module) == 0)
    pipeline_module_set_main_func_index(module, -1);
  pipeline_typeck_set_active_ctx_c(module, ctx);
  pipeline_typeck_set_dep_ctx(ctx);
  if (pipeline_module_main_func_index(module) < 0) {
    int32_t tc_lib = typeck_typeck_x_ast_library(module, arena, ctx);
    if (tc_lib != 0) {
      driver_diagnostic_typeck_fail();
      if (fail_mapped != 0)
        return fail_mapped;
      return tc_lib;
    }
    if (pipeline_typeck_scan_module_struct_stack_escape_c(module, arena, ctx) != 0) {
      driver_diagnostic_typeck_fail();
      if (fail_mapped != 0)
        return fail_mapped;
      return -1;
    }
    (void)pipeline_typeck_unused_private_funcs(module, arena);
    return 0;
  }
  {
    pipeline_typeck_set_dep_ctx(ctx);
    int32_t tc = typeck_typeck_x_ast(module, arena, ctx);
    if (tc != 0) {
      driver_diagnostic_typeck_fail();
      if (fail_mapped != 0)
        return fail_mapped;
      return tc;
    }
    if (pipeline_typeck_scan_module_struct_stack_escape_c(module, arena, ctx) != 0) {
      driver_diagnostic_typeck_fail();
      if (fail_mapped != 0)
        return fail_mapped;
      return -1;
    }
  }
  (void)pipeline_typeck_unused_private_funcs(module, arena);
  return 0;
}

int32_t pipeline_typeck_entry_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                       struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, 0);
}

void pipeline_dep_ctx_realign_ndep_for_entry_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  int32_t n_imp;
  int32_t ndep;
  if (!module || !ctx)
    return;
  n_imp = parser_get_module_num_imports(module);
  ndep = pipeline_dep_ctx_ndep(ctx);
  if (ndep == n_imp)
    return;
  if (ndep > n_imp)
    return;
  pipeline_dep_ctx_set_ndep(ctx, 0);
}

int32_t pipeline_load_import_resolve_read_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                            int32_t import_idx) {
  uint8_t path_buf[128];
  int32_t path_len;
  if (!module || !ctx || import_idx < 0)
    return -1;
  memset(path_buf, 0, sizeof(path_buf));
  path_len = parser_copy_module_import_path64(module, import_idx, path_buf);
  if (pipeline_resolve_path_x(ctx, path_buf, path_len) != 0)
    return -7;
  if (pipeline_read_file_x(ctx) != 0)
    return -8;
  return 0;
}

int32_t pipeline_load_one_import_slot_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                        struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  uint8_t path_buf[128];
  int32_t gs;
  if (!module || !arena || !ctx || import_idx < 0)
    return -1;
  memset(path_buf, 0, sizeof(path_buf));
  (void)parser_copy_module_import_path64(module, import_idx, path_buf);
  gs = driver_dep_slot_for_path((const char *)path_buf);
  if (pipeline_try_bind_seeded_import(ctx, import_idx, gs) != 0)
    return 0;
  return pipeline_load_import_from_disk_c(module, arena, ctx, import_idx);
}

int32_t pipeline_load_and_sync_direct_import_deps_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    struct ast_PipelineDepCtx *ctx) {
  int32_t n_imports;
  int32_t i;
  int32_t rc;
  int32_t sync_rc;
  uint8_t path_buf[128];
  if (!module || !arena || !ctx)
    return -1;
  n_imports = parser_get_module_num_imports(module);
  pipeline_dep_ctx_realign_ndep_for_entry_c(module, ctx);
  if (pipeline_dep_ctx_ndep(ctx) == 0 && n_imports > 0) {
    for (i = 0; i < n_imports; i++) {
      int32_t pl = 0;
      memset(path_buf, 0, sizeof(path_buf));
      (void)parser_copy_module_import_path64(module, i, path_buf);
      while (pl < 64 && path_buf[pl] != 0)
        pl = pl + 1;
      if (pl > 0)
        pipeline_dep_ctx_set_import_path(ctx, i, path_buf, pl);
      if (pipeline_try_bind_seeded_import(ctx, i, driver_dep_slot_for_path((const char *)path_buf)) != 0)
        continue;
      rc = pipeline_load_import_from_disk_c(module, arena, ctx, i);
      if (rc != 0)
        return rc;
    }
    pipeline_dep_ctx_set_ndep(ctx, n_imports);
  } else if (n_imports > 0) {
    int32_t cur_ndep = pipeline_dep_ctx_ndep(ctx);
    if (cur_ndep > n_imports) {
      for (i = 0; i < cur_ndep; i++) {
        const char *reg_path = NULL;
        int32_t pl = 0;
        if (driver_dep_seeded_get(i) == 0)
          continue;
        pipeline_dep_ctx_set_module(ctx, i, (struct ast_Module *)driver_dep_module_buf(i));
        pipeline_dep_ctx_set_arena(ctx, i, (struct ast_ASTArena *)driver_dep_arena_buf(i));
        reg_path = driver_dep_path_registry_at(i);
        if (reg_path && reg_path[0]) {
          while (pl < 63 && reg_path[pl] != 0)
            pl = pl + 1;
          if (pl > 0)
            pipeline_dep_ctx_set_import_path(ctx, i, (uint8_t *)reg_path, pl);
        }
      }
    } else {
      for (i = 0; i < n_imports; i++) {
        int32_t pl = 0;
        memset(path_buf, 0, sizeof(path_buf));
        (void)parser_copy_module_import_path64(module, i, path_buf);
        while (pl < 64 && path_buf[pl] != 0)
          pl = pl + 1;
        if (pl > 0)
          pipeline_dep_ctx_set_import_path(ctx, i, path_buf, pl);
        if (pipeline_try_bind_seeded_import(ctx, i, driver_dep_slot_for_path((const char *)path_buf)) != 0)
          continue;
        if (pipeline_dep_ctx_module_at(ctx, i) == NULL) {
          rc = pipeline_load_import_from_disk_c(module, arena, ctx, i);
          if (rc != 0)
            return rc;
        }
      }
      if (pipeline_dep_ctx_ndep(ctx) < n_imports)
        pipeline_dep_ctx_set_ndep(ctx, n_imports);
    }
  }
  sync_rc = pipeline_sync_dep_slots_from_driver_c(module, ctx);
  if (sync_rc != 0)
    return sync_rc;
  {
    int32_t all_seeded = (n_imports > 0) ? 1 : 0;
    for (i = 0; i < n_imports; i++) {
      int32_t gs;
      memset(path_buf, 0, sizeof(path_buf));
      (void)parser_copy_module_import_path64(module, i, path_buf);
      gs = driver_dep_slot_for_path((const char *)path_buf);
      if ((gs < 0 || driver_dep_seeded_get(gs) == 0) && driver_dep_seeded_get(i) == 0) {
        all_seeded = 0;
        break;
      }
    }
    if (!all_seeded) {
      typeck_typeck_merge_dep_struct_layouts_into_entry(module, arena, ctx);
      typeck_typeck_wpo_unify_soa_layouts(module, ctx);
    }
  }
  return 0;
}

/* wave113 backend_asm_wrapper leave cold twins — former pipeline_backend_asm_wrapper.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns strong faces.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X from wave101 leave twins.
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked.
 */

extern void pipeline_module_hoist_top_level_lets_into_main(struct ast_Module *m, struct ast_ASTArena *a);
extern int32_t backend_asm_codegen_ast_seed_mega(struct ast_Module *m, struct ast_ASTArena *a, void *out,
                                                 struct ast_PipelineDepCtx *pipeline_ctx);
extern void pipeline_asm_emit_set_elf_ctx(void *elf_ctx);
extern void pipeline_asm_emit_set_dep_pipe(struct ast_PipelineDepCtx *ctx);
extern void pipeline_asm_emit_set_module(struct ast_Module *m);
extern void pipeline_asm_emit_set_arena(struct ast_ASTArena *arena);
extern void glue_wpo_mono_reset_pending(void);
extern void pipeline_elf_label_mod_scope_begin_module(void);
extern int32_t pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                                   void *elf_ctx,
                                                                   struct ast_PipelineDepCtx *pipeline_ctx);
extern int32_t pipeline_asm_emit_wpo_mono_thunks_elf_c(struct ast_Module *m, struct ast_ASTArena *a, void *elf_ctx,
                                                      struct ast_PipelineDepCtx *pipeline_ctx);
extern void pipeline_fill_array_lit_types_for_skipped_typeck(struct ast_Module *m, struct ast_ASTArena *arena);
extern void typeck_soa_fill_field_access_for_asm_emit(struct ast_Module *m, struct ast_ASTArena *arena);
extern void pipeline_debug_trace_named_func_bodies(const char *phase, void *module, void *arena);

int32_t pipeline_backend_asm_codegen_ast_c(struct ast_Module *m, struct ast_ASTArena *a, void *out,
                                            struct ast_PipelineDepCtx *pipeline_ctx) {
  if (!m || !a || !out || !pipeline_ctx)
    return -1;
  if (m->num_top_level_lets > 0)
    pipeline_module_hoist_top_level_lets_into_main(m, a);
  return backend_asm_codegen_ast_seed_mega(m, a, out, pipeline_ctx);
}

int32_t pipeline_backend_asm_codegen_ast_to_elf_c(struct ast_Module *m, struct ast_ASTArena *a, void *elf_ctx,
                                                   struct ast_PipelineDepCtx *pipeline_ctx) {
  int32_t rc;
  if (!m || !a || !elf_ctx || !pipeline_ctx)
    return -1;
  pipeline_debug_trace_named_func_bodies("backend_pre_hoist_top_level_lets", m, a);
  if (m->num_top_level_lets > 0)
    pipeline_module_hoist_top_level_lets_into_main(m, a);
  pipeline_debug_trace_named_func_bodies("backend_post_hoist_top_level_lets", m, a);
  pipeline_debug_trace_named_func_bodies("backend_pre_merge_dep_layouts", m, a);
  typeck_typeck_merge_dep_struct_layouts_into_entry(m, a, pipeline_ctx);
  pipeline_debug_trace_named_func_bodies("backend_post_merge_dep_layouts", m, a);
  typeck_typeck_wpo_unify_soa_layouts(m, pipeline_ctx);
  pipeline_debug_trace_named_func_bodies("backend_post_unify_soa_layouts", m, a);
  pipeline_asm_emit_set_dep_pipe(pipeline_ctx);
  pipeline_fill_array_lit_types_for_skipped_typeck(m, a);
  typeck_soa_fill_field_access_for_asm_emit(m, a);
  glue_wpo_mono_reset_pending();
  pipeline_elf_label_mod_scope_begin_module();
  pipeline_asm_emit_set_module(m);
  pipeline_asm_emit_set_arena(a);
  pipeline_asm_emit_set_elf_ctx(elf_ctx);
  rc = pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(m, a, elf_ctx, pipeline_ctx);
  pipeline_asm_emit_set_elf_ctx(NULL);
  if (rc != 0)
    return rc;
  return pipeline_asm_emit_wpo_mono_thunks_elf_c(m, a, elf_ctx, pipeline_ctx);
}

/* wave114 asm_ctx_loop leave cold twins — former pipeline_asm_ctx_loop.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns strong faces.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X. Fixed caps match pure:
 * 64 ctx slots, depth 8, label 64B rows, be_cont 24 × 128B end labels.
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked.
 */
#define WAVE114_LOOP_SC_MAX 64
#define WAVE114_LOOP_DEPTH_MAX 8
#define WAVE114_LOOP_LABEL_W 64
#define WAVE114_LOOP_STACK (WAVE114_LOOP_DEPTH_MAX * WAVE114_LOOP_LABEL_W)
#define WAVE114_BE_CONT_MAX 24
#define WAVE114_BE_END_W 128

static int32_t wave114_loop_used[WAVE114_LOOP_SC_MAX];
static uint8_t *wave114_loop_ctx[WAVE114_LOOP_SC_MAX];
static int32_t wave114_loop_depth[WAVE114_LOOP_SC_MAX];
static uint8_t wave114_loop_break[WAVE114_LOOP_SC_MAX * WAVE114_LOOP_STACK];
static int32_t wave114_loop_break_lens[WAVE114_LOOP_SC_MAX * WAVE114_LOOP_DEPTH_MAX];
static uint8_t wave114_loop_cont[WAVE114_LOOP_SC_MAX * WAVE114_LOOP_STACK];
static int32_t wave114_loop_cont_lens[WAVE114_LOOP_SC_MAX * WAVE114_LOOP_DEPTH_MAX];
static int32_t wave114_be_cont_depth;
static int32_t wave114_be_cont_block[WAVE114_BE_CONT_MAX];
static int32_t wave114_be_cont_stmt[WAVE114_BE_CONT_MAX];
static int32_t wave114_be_cont_end_len[WAVE114_BE_CONT_MAX];
static uint8_t wave114_be_cont_end[WAVE114_BE_CONT_MAX * WAVE114_BE_END_W];

static int32_t wave114_loop_sc_find(uint8_t *ctx, int create) {
  int i;
  if (!ctx)
    return -1;
  for (i = 0; i < WAVE114_LOOP_SC_MAX; i++) {
    if (wave114_loop_used[i] && wave114_loop_ctx[i] == ctx)
      return i;
  }
  if (!create)
    return -1;
  for (i = 0; i < WAVE114_LOOP_SC_MAX; i++) {
    if (!wave114_loop_used[i]) {
      wave114_loop_used[i] = 1;
      wave114_loop_ctx[i] = ctx;
      wave114_loop_depth[i] = 0;
      return i;
    }
  }
  return -1;
}

void asm_ctx_loop_reset(uint8_t *ctx) {
  int32_t s = wave114_loop_sc_find(ctx, 0);
  if (s < 0)
    return;
  wave114_loop_depth[s] = 0;
}

int32_t asm_ctx_loop_push(uint8_t *ctx, uint8_t *exit_buf, int32_t exit_len, uint8_t *loop_buf, int32_t loop_len) {
  int32_t s, d, base, sc_base, k, n, m;
  if (!ctx || !exit_buf || !loop_buf || exit_len < 0 || loop_len < 0)
    return -1;
  s = wave114_loop_sc_find(ctx, 1);
  if (s < 0)
    return -1;
  d = wave114_loop_depth[s];
  if (d >= WAVE114_LOOP_DEPTH_MAX)
    return -1;
  base = d * WAVE114_LOOP_LABEL_W;
  sc_base = s * WAVE114_LOOP_STACK;
  n = exit_len > WAVE114_LOOP_LABEL_W ? WAVE114_LOOP_LABEL_W : exit_len;
  for (k = 0; k < n; k++)
    wave114_loop_break[sc_base + base + k] = exit_buf[k];
  wave114_loop_break_lens[s * WAVE114_LOOP_DEPTH_MAX + d] = exit_len;
  m = loop_len > WAVE114_LOOP_LABEL_W ? WAVE114_LOOP_LABEL_W : loop_len;
  for (k = 0; k < m; k++)
    wave114_loop_cont[sc_base + base + k] = loop_buf[k];
  wave114_loop_cont_lens[s * WAVE114_LOOP_DEPTH_MAX + d] = loop_len;
  wave114_loop_depth[s] = d + 1;
  return 0;
}

void asm_ctx_loop_pop(uint8_t *ctx, uint8_t *break_out, int32_t break_cap, int32_t *break_len_out,
                      uint8_t *cont_out, int32_t cont_cap, int32_t *cont_len_out) {
  int32_t s, d, prev, base, sc_base, k, bl, cl, bn, cn;
  if (break_len_out)
    *break_len_out = 0;
  if (cont_len_out)
    *cont_len_out = 0;
  if (!ctx || (s = wave114_loop_sc_find(ctx, 0)) < 0 || wave114_loop_depth[s] <= 0)
    return;
  wave114_loop_depth[s]--;
  d = wave114_loop_depth[s];
  if (d <= 0)
    return;
  prev = d - 1;
  base = prev * WAVE114_LOOP_LABEL_W;
  sc_base = s * WAVE114_LOOP_STACK;
  bl = wave114_loop_break_lens[s * WAVE114_LOOP_DEPTH_MAX + prev];
  cl = wave114_loop_cont_lens[s * WAVE114_LOOP_DEPTH_MAX + prev];
  if (break_out && break_len_out && break_cap > 0) {
    bn = bl > break_cap - 1 ? break_cap - 1 : bl;
    for (k = 0; k < bn; k++)
      break_out[k] = wave114_loop_break[sc_base + base + k];
    *break_len_out = bl;
  }
  if (cont_out && cont_len_out && cont_cap > 0) {
    cn = cl > cont_cap - 1 ? cont_cap - 1 : cl;
    for (k = 0; k < cn; k++)
      cont_out[k] = wave114_loop_cont[sc_base + base + k];
    *cont_len_out = cl;
  }
}

int32_t asm_ctx_loop_depth(uint8_t *ctx) {
  int32_t s = wave114_loop_sc_find(ctx, 0);
  return s < 0 ? 0 : wave114_loop_depth[s];
}

void asm_be_cont_reset(void) {
  wave114_be_cont_depth = 0;
}

int32_t asm_be_cont_suspend(int32_t block_ref, int32_t stmt_i, uint8_t *end_lbl, int32_t end_len) {
  int32_t d, k, n, base;
  if (wave114_be_cont_depth >= WAVE114_BE_CONT_MAX || !end_lbl || end_len < 0)
    return -1;
  d = wave114_be_cont_depth++;
  wave114_be_cont_block[d] = block_ref;
  wave114_be_cont_stmt[d] = stmt_i;
  if (end_len == 0) {
    wave114_be_cont_end_len[d] = 0;
    return 0;
  }
  n = end_len > 64 ? 64 : end_len;
  base = d * WAVE114_BE_END_W;
  for (k = 0; k < n; k++)
    wave114_be_cont_end[base + k] = end_lbl[k];
  wave114_be_cont_end_len[d] = end_len;
  return 0;
}

int32_t asm_be_cont_resume(int32_t *out_block, int32_t *out_stmt_i, uint8_t *out_end, int32_t end_cap,
                           int32_t *out_end_len) {
  int32_t d, k, n, base;
  if (wave114_be_cont_depth <= 0)
    return 0;
  d = --wave114_be_cont_depth;
  if (out_block)
    *out_block = wave114_be_cont_block[d];
  if (out_stmt_i)
    *out_stmt_i = wave114_be_cont_stmt[d];
  if (out_end_len)
    *out_end_len = wave114_be_cont_end_len[d];
  if (out_end && end_cap > 0 && out_end_len) {
    n = wave114_be_cont_end_len[d];
    if (n > end_cap - 1)
      n = end_cap - 1;
    base = d * WAVE114_BE_END_W;
    for (k = 0; k < n; k++)
      out_end[k] = wave114_be_cont_end[base + k];
  }
  return 1;
}

int32_t asm_be_cont_depth(void) {
  return wave114_be_cont_depth;
}

/* wave115 asm_selfhost leave cold twins — former pipeline_asm_selfhost.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns strong faces.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X. Semantics ≡ pure:
 * num_defined / defined_ordinal + 9 is_* predicates via module accessors
 * (no m->num_funcs field; incomplete Module safe under cold seed).
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked.
 */
extern int32_t pipeline_module_num_funcs(void *module);
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, uint8_t *name, int32_t name_len);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);

int32_t asm_module_num_defined_funcs(void *m) {
  int32_t i, n = 0, nfuncs;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_asm_module_func_is_extern_at(m, i) == 0)
      n++;
  }
  return n;
}

int32_t asm_module_defined_func_ordinal(void *m, int32_t func_index) {
  int32_t i, ord = 0, nfuncs;
  if (!m || func_index < 0)
    return -1;
  nfuncs = pipeline_module_num_funcs(m);
  if (func_index >= nfuncs)
    return -1;
  if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
    return -1;
  for (i = 0; i < func_index; i++) {
    if (pipeline_asm_module_func_is_extern_at(m, i) == 0)
      ord++;
  }
  return ord;
}

int32_t asm_module_is_backend_selfhost(void *m) {
  int32_t i, nfuncs;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 80)
    return 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"asm_codegen_ast", 15))
      return 1;
  }
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"emit_expr_elf", 13))
      return 1;
  }
  return 0;
}

int32_t asm_module_is_typeck_selfhost(void *m) {
  int32_t i, nfuncs, ndef;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 40)
    return 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_arena_init", 14))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_placeholder", 15))
      return 0;
  }
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_module_reset_parse_counters", 36))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"parse_into_init", 15))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"skip_one_struct_into_buf", 24))
      return 0;
  }
  if (pipeline_module_func_name_equal_at(m, 0, (uint8_t *)"type_kind_ordinal", 17))
    return 1;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"typeck_x_ast", 12))
      return 1;
  }
  ndef = asm_module_num_defined_funcs(m);
  if (ndef >= 75 && ndef <= 155)
    return 1;
  if (ndef >= 160 && ndef <= 180)
    return 1;
  return 0;
}

int32_t asm_module_is_pipeline_selfhost(void *m) {
  int32_t i, nfuncs, has_resolve, has_marker;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 12)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_typeck_selfhost(m))
    return 0;
  has_resolve = 0;
  has_marker = 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"resolve_path_x", 15))
      has_resolve = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_should_skip_x_typeck", 30))
      has_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"path_append_from_buf_256", 24))
      has_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"read_file_x", 12))
      has_marker = 1;
  }
  return has_resolve != 0 && has_marker != 0;
}

int32_t asm_module_is_parser_selfhost(void *m) {
  int32_t i, nfuncs, has_parse_marker, has_reset;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 150 || nfuncs > 1450)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_pipeline_selfhost(m))
    return 0;
  has_parse_marker = 0;
  has_reset = 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_module_reset_parse_counters", 36))
      has_reset = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"parse_into_init", 15))
      has_parse_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"parse_into_set_main_index", 25))
      has_parse_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"skip_one_struct_into_buf", 24))
      has_parse_marker = 1;
  }
  if (has_reset != 0 && has_parse_marker == 0 && nfuncs >= 200)
    has_parse_marker = 1;
  if (has_reset == 0)
    return 0;
  if (asm_module_is_typeck_selfhost(m) && has_parse_marker == 0)
    return 0;
  return has_parse_marker != 0;
}

int32_t asm_module_is_parser_emit_heavy(void *m) {
  int32_t i, nfuncs;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 150 || nfuncs > 1450)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_pipeline_selfhost(m))
    return 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_module_reset_parse_counters", 36))
      return 1;
  }
  return asm_module_is_parser_selfhost(m);
}

int32_t asm_module_is_main_driver_selfhost(void *m) {
  int32_t i, nfuncs, has_entry, has_run_path, ndef;
  if (!m)
    return 0;
  ndef = asm_module_num_defined_funcs(m);
  if (ndef < 12 || ndef > 48)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_typeck_selfhost(m) ||
      asm_module_is_pipeline_selfhost(m) || asm_module_is_parser_selfhost(m))
    return 0;
  has_entry = 0;
  has_run_path = 0;
  nfuncs = pipeline_module_num_funcs(m);
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"entry", 5))
      has_entry = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"main_run_compiler_x_path_impl", 29) ||
        pipeline_module_func_name_equal_at(m, i, (uint8_t *)"run_compiler_x_path_impl", 24))
      has_run_path = 1;
  }
  return has_entry != 0 && has_run_path != 0;
}

int32_t asm_module_is_driver_compile_selfhost(void *m) {
  int32_t i, nfuncs, has_parse_argv, has_entry;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 8 || nfuncs > 120)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_typeck_selfhost(m) ||
      asm_module_is_pipeline_selfhost(m) || asm_module_is_parser_selfhost(m))
    return 0;
  has_parse_argv = 0;
  has_entry = 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"driver_compile_parse_argv", 25))
      has_parse_argv = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"run_compiler_full_x", 19))
      has_entry = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"compile_dispatch_asm_backend", 28))
      has_parse_argv = 1;
  }
  return has_parse_argv != 0 && has_entry != 0;
}

int32_t asm_module_is_ast_selfhost(void *m) {
  int32_t i, nfuncs, has_arena_init, has_placeholder;
  if (!m)
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs < 15 || nfuncs > 250)
    return 0;
  has_arena_init = 0;
  has_placeholder = 0;
  for (i = 0; i < nfuncs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_arena_init", 14))
      has_arena_init = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_placeholder", 15))
      has_placeholder = 1;
  }
  if (has_arena_init == 0 || has_placeholder == 0)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_pipeline_selfhost(m) ||
      asm_module_is_parser_selfhost(m))
    return 0;
  return 1;
}

int32_t asm_module_is_compiler_selfhost(void *m) {
  return asm_module_is_ast_selfhost(m) || asm_module_is_backend_selfhost(m) ||
         asm_module_is_typeck_selfhost(m) || asm_module_is_pipeline_selfhost(m) ||
         asm_module_is_parser_selfhost(m) || asm_module_is_parser_emit_heavy(m) ||
         asm_module_is_driver_compile_selfhost(m) || asm_module_is_main_driver_selfhost(m);
}


/* wave116 asm_thin_delegate leave cold twins — former pipeline_asm_thin_delegate.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns the 4 strong faces.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X. Semantics ≡ pure:
 * backend/pipeline/driver/typeck m8-tail thin delegate C-name lookup. The parser
 * table + its accessor stayed host-cc in pipeline_asm_parser_emit_heavy.c (not here).
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked. */
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, uint8_t *name, int32_t name_len);
extern int32_t pipeline_module_func_name_len_at(void *m, int32_t fi);
extern void    pipeline_asm_module_func_name_copy64(void *m, int32_t fi, uint8_t *dst);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);
extern int32_t asm_env_entry_emit_heavy(void);
/* asm_module_is_{pipeline,driver_compile,typeck}_selfhost: cold twins defined above. */
typedef struct {
  const char *x_name;
  int32_t x_len;
  const char *c_name;
  int32_t c_len;
} AsmBackendThinDelegateRow;

static const AsmBackendThinDelegateRow k_asm_backend_thin_delegate[] = {
    {"fill_param_slots", 16, "pipeline_asm_fill_param_slots", 29},
    {"fill_local_slots", 16, "pipeline_asm_fill_local_slots", 29},
    {"compute_frame_size", 18, "pipeline_asm_compute_frame_size_c", 33},
    {"emit_block_body_elf", 19, "backend_emit_block_body_sync_elf", 32},
    {"emit_block_inits_elf", 20, "pipeline_asm_emit_block_inits_elf_c", 35},
    {"emit_if_then_block_body_elf", 27, "pipeline_asm_emit_if_then_block_body_elf_c", 42},
    {"emit_while_loop_elf", 18, "pipeline_asm_emit_while_loop_elf_c", 34},
    {"emit_for_loop_elf", 16, "pipeline_asm_emit_for_loop_elf_c", 32},
    {"emit_loop_body_content", 22, "pipeline_asm_emit_loop_body_content_c", 35},
    {"emit_loop_body_content_elf", 26, "pipeline_asm_emit_loop_body_content_elf_c", 39},
    {"emit_next_label", 15, "pipeline_asm_emit_next_label_c", 30},
    {"format_label_id", 15, "pipeline_asm_format_label_id_c", 30},
    {"emit_expr_elf_call", 18, "pipeline_asm_emit_call_elf_c", 28},
    {"emit_expr_elf_method_call", 25, "pipeline_asm_emit_method_call_elf_c", 35},
    {"asm_emit_call_args_elf", 22, "pipeline_asm_emit_call_args_elf_c", 33},
    {"emit_block_inits", 16, "pipeline_asm_emit_block_inits_c", 31},
    {"emit_block_body", 15, "pipeline_asm_emit_block_body_c", 30},
    {"emit_while_loop", 15, "pipeline_asm_emit_while_loop_c", 30},
    {"emit_for_loop", 13, "pipeline_asm_emit_for_loop_c", 28},
    {"emit_if_then_block_body_text", 28, "pipeline_asm_emit_if_then_block_body_text_c", 43},
    {"emit_expr", 9, "pipeline_asm_emit_expr_c", 24},
    {"emit_expr_call", 14, "pipeline_asm_emit_expr_call_c", 29},
    {"emit_expr_method_call", 21, "pipeline_asm_emit_expr_method_call_c", 36},
    {"emit_expr_elf", 13, "pipeline_asm_emit_expr_elf_c", 28},
    {"emit_index_eff_addr_text", 24, "pipeline_asm_emit_index_eff_addr_text_c", 39},
    {"emit_index_eff_addr_elf", 23, "pipeline_asm_emit_index_eff_addr_elf_c", 38},
    {"emit_lvalue_eff_addr_text", 25, "pipeline_asm_emit_lvalue_eff_addr_text_c", 40},
    {"emit_lvalue_eff_addr_elf", 24, "pipeline_asm_emit_lvalue_eff_addr_elf_c", 39},
    {"asm_emit_call_args_text", 23, "pipeline_asm_emit_call_args_text_c", 33},
    {"local_offset", 12, "pipeline_asm_local_offset_c", 27},
    {"asm_resolve_whole_import_qualified_symbol", 41, "pipeline_asm_resolve_whole_import_qualified_symbol_c", 52},
    {"emit_skip_heavy_stub_elf", 24, "pipeline_asm_emit_skip_heavy_stub_elf_c", 39},
    {"simd_try_inline_shuffle_call_elf", 32, "pipeline_asm_simd_try_inline_shuffle_call_elf_c", 47},
    {"simd_try_inline_select_call_elf", 31, "pipeline_asm_simd_try_inline_select_call_elf_c", 46},
    {"simd_try_inline_binop2_call_elf", 31, "pipeline_asm_simd_try_inline_binop2_call_elf_c", 46},
    {"simd_try_inline_fma3_call_elf", 29, "pipeline_asm_simd_try_inline_fma3_call_elf_c", 46},
    {"asm_codegen_ast", 15, "pipeline_backend_asm_codegen_ast_c", 34},
    {"asm_codegen_ast_to_elf", 22, "pipeline_backend_asm_codegen_ast_to_elf_c", 41},
};

/**
 * 查 backend 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_backend_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                  int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  nrows = (int32_t)(sizeof(k_asm_backend_thin_delegate) / sizeof(k_asm_backend_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_backend_thin_delegate[i].x_name,
                                           k_asm_backend_thin_delegate[i].x_len)) {
      if (k_asm_backend_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_backend_thin_delegate[i].c_name, (size_t)k_asm_backend_thin_delegate[i].c_len);
      out[k_asm_backend_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_backend_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/** M8-tail：parse/typecheck entry 薄 bl→C（do_parse 仍 X emit 调 set_main thin→C）。 */
static const AsmBackendThinDelegateRow k_asm_pipeline_thin_delegate[] = {
    {"pipeline_parse_set_main_from_buf", 32, "pipeline_parse_set_main_from_buf_c", 34},
    {"pipeline_should_skip_x_typeck", 30, "pipeline_should_skip_x_typeck_c", 32},
    {"run_x_pipeline_typecheck_entry", 31, "run_x_pipeline_typecheck_entry_emit_c", 36},
};

/**
 * 查 pipeline 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_pipeline_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                   int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0 || !asm_module_is_pipeline_selfhost(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_pipeline_thin_delegate) / sizeof(k_asm_pipeline_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_pipeline_thin_delegate[i].x_name,
                                           k_asm_pipeline_thin_delegate[i].x_len)) {
      if (k_asm_pipeline_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_pipeline_thin_delegate[i].c_name, (size_t)k_asm_pipeline_thin_delegate[i].c_len);
      out[k_asm_pipeline_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_pipeline_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}


/* ── driver / typeck M8-tail 薄委托表（补全五表域；自 ast_pool.c 抽出）── */
/* k_asm_driver_thin_delegate + k_asm_typeck_thin_delegate 及其 m8 查找符号。 */

/** M8-tail：driver compile 薄 bl 表已空；run_compiler_full_x* 堆 state + X post_parse 真 emit。 */
static const AsmBackendThinDelegateRow k_asm_driver_thin_delegate[] = {
};

/**
 * 查 driver/compile.x 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_driver_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0 || !asm_module_is_driver_compile_selfhost(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_driver_thin_delegate) / sizeof(k_asm_driver_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_driver_thin_delegate[i].x_name,
                                           k_asm_driver_thin_delegate[i].x_len)) {
      if (k_asm_driver_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_driver_thin_delegate[i].c_name, (size_t)k_asm_driver_thin_delegate[i].c_len);
      out[k_asm_driver_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_driver_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/** typeck EMIT_HEAVY 薄委托：仅剩须 C 维持的入口（typeck 主体已 X emit）。 */
static const AsmBackendThinDelegateRow k_asm_typeck_thin_delegate[] = {
};

/**
 * typeck EMIT_HEAVY 第二遍：SKIP 桩路径 bl→C 委托或 typeck_x.o 同名实现（首遍 SKIP 仍 ret0）。
 * 实参已在 ABI 寄存器；Mach-O 由 backend_enc_call_arch 加 leading `_`。
 */
int32_t asm_typeck_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  int32_t nl;

  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  if (!asm_module_is_typeck_selfhost(m) || asm_env_entry_emit_heavy() == 0)
    return 0;
  if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
    return 0;
  nrows = (int32_t)(sizeof(k_asm_typeck_thin_delegate) / sizeof(k_asm_typeck_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_typeck_thin_delegate[i].x_name,
                                           k_asm_typeck_thin_delegate[i].x_len)) {
      if (k_asm_typeck_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_typeck_thin_delegate[i].c_name, (size_t)k_asm_typeck_thin_delegate[i].c_len);
      out[k_asm_typeck_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_typeck_thin_delegate[i].c_len;
      return 1;
    }
  }
  nl = pipeline_module_func_name_len_at(m, func_index);
  if (nl <= 0 || nl >= out_cap)
    return 0;
  pipeline_asm_module_func_name_copy64(m, func_index, out);
  out[nl] = 0;
  *out_len = nl;
  return 1;
}


/* wave117 asm emit_heavy safe-helper leave cold twins — former pipeline_asm_emit_heavy_safe_helper.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns the 9 strong faces.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X. Semantics ≡ pure:
 * 9 EMIT_HEAVY 2nd-pass per-module name classifiers. C macros kept (seed is C).
 * Residual accessors extern; asm_module_is_*_selfhost cold twins defined above.
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked. */
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, uint8_t *name, int32_t name_len);
extern int32_t pipeline_module_func_name_has_prefix_at(void *m, int32_t fi, const char *pfx, int32_t plen);
static int32_t asm_typeck_emit_heavy_safe_helper(void *m, int32_t func_index) {
  if (!m || func_index < 0)
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_kind_ordinal", 17))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"name_equal", 10))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "ensure_", 7))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "find_or_alloc_", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_offset_from_layout", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_type_ref_from_layout", 30))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_name", 18))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_field_name", 24))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_import_path_slice", 24))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_import_binding_name", 26))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_import_select_name", 25))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_top_level_let_name", 25))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_find_layout_idx", 22))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_x_named_builtin_", 24))
    return 1;
  /** §11.1 align/size：layout 命中走 C glue，X 真 emit 递归/array 分支（勿 metrics depth slot）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_align", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_size", 19))
    return 1;
  /** §11.1 metrics：scratch 预绑定 + typeck_i32_ptr_store 写 out；槽位≤96 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_struct_layout_metrics", 28))
    return 1;
  /** import 合并 / struct_lit 登记：scratch 预绑定 + glue 读 num_struct_layouts。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_merge_dep_struct_layouts_into_entry", 42))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_wpo_unify_soa_layouts", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_ensure_primitive_by_kind_ord", 35))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_find_or_alloc_compound_type_ref", 38))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ensure_struct_layout_from_struct_lit", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_dep_return_type_in_caller_arena", 35))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"dep_return_type_to_caller_arena", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_offset_from_layout_deps", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_type_ref_from_layout_deps", 35))
    return 1;
  /** FIELD_ACCESS 内联池字段 / Expr 标量回落：小 helper X 真 emit（layout_deps/name_fallback 已真 emit）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_inline_u8_64_array_field_type_ref", 40))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_expr_inline_array_field_type_ref", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_field_access_fallback_scalar_type_ref", 42))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_field_access_lexer_wrapper_fallback", 42))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"entry_module_find_struct_layout_index", 37))
    return 1;
  /** ord>45 小 helper：import 路径分段 / diag 追加 / 隐式 return 判定 / parent 链 patch。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_import_path_segment_count", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_import_segment_at", 24))
    return 1;
  /** ord>58：diag 缓冲追加（小循环体；fmt_* 仍 mega 桩）。 */
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_diag_append_", 19))
    return 1;
  /** diag fmt 族：glue 读类型池 + 局部序数；勿 ast_arena_type_get 按值 Type。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_at", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_into", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_or_question", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_resolve_scan_dep_with_apply", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_return_type", 31))
    return 1;
  /** 隐式尾返回判定：tail ref 扫描 + ast_expr_disallows_implicit_tail（patch 4096 后 X 真 emit）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"func_body_tail_expr_ref_for_implicit_rule", 41))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"func_body_has_implicit_return_tail", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_binop", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_binop_cmp", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_method_call", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_method_call_arg", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_as", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_struct_lit", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_struct_lit_field", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_field_access", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_const", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_let", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_while", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_for", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_if", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_final", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_binop_arith", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"find_func_return_type_in_module", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"find_func_return_type_in_module_by_name", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_whole_import_qualified_call_return_type", 47))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_binding_import_return_type", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_select_import_return_type", 38))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_local_module", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_try_whole_import", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_try_binding_import", 38))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_scan_dep", 28))
    return 1;
  /** S2 X 真 emit：expr/type 小 helper（glue 指针读池；勿 Type 按值 ast_arena_type_get）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_type_ref", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_ref_is_bool", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_ref_is_bool_impl", 21))
    return 1;
  /** type_refs_equal 薄包装可 X emit；拆分 named/same_kind/impl 逐步 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal_impl", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_return_operand_matches", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_integer_widen_ok", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_var_name_equal_func", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_ret_coerce_integral_to_expect_i32", 40))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_ret_coerce_integral_widen", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_expr_to_decl", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal_named", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal_same_kind", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_lit_to_decl", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_enum_field_to_decl", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_float_lit_to_decl", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_named_call_to_decl", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_array_vector_lit_to_decl", 43))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_vector_binop_to_decl", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_slice_from_array", 35))
    return 1;
  /** validate 薄循环：metrics/align/size 仍 mega/thin stub（独立 X emit SIGSEGV）；本函数 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_validate_struct_layouts_zero_padding", 43))
    return 1;
  /** typeck_x_ast 薄入口见 mega_entry；check_block 薄 guard 仍 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block", 11))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_as_loop_body", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_loop_depth_push", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_loop_depth_pop", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_patch_all_body_parent_links", 34))
    return 1;
  /** check_expr/check_block 薄 guard→check_*_impl；impl/mega 走 asm_skip_heavy_typeck_mega_entry 桩。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr", 10))
    return 1;
  /** check_expr mega 分派子 helper（assign/index/unary/addr/deref/var/return/panic）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_expr_is_any_assign_kind", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_assign", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_index", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_unary", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_addr_of", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_deref", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_var", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_return", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_panic", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_break_continue", 32))
    return 1;
  /** check_block_impl 编排子 helper（stmt_order/impl 主体 mega 桩）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_consts", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_lets", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_whiles", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_fors", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_ifs", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_expr_stmts", 36))
    return 1;
  /** check_expr_impl 小 kind 子 helper（impl/mega 主体 mega 桩）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_int_lit", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_bool_lit", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_float_lit", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_enum_variant", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_block", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_if_ternary", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_match", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_match_arm", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_call", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_call_arg", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_call_resolve", 30))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
    return 0;
  return 0;
}

/**
 * pipeline EMIT_HEAVY 第二遍：编排 helper X 真 emit；parse/typecheck 关键路径 thin→C（strict smoke）。
 * S3：resolve/read 经 weak→强符号 dispatch（build_asm 覆盖 impl_c）。
 */
static int32_t asm_pipeline_emit_heavy_safe_helper(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_pipeline_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_one_function_ok", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_should_skip_x_typeck", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_loaded_buf_cap", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_parse_entry_if_needed", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_typecheck_entry", 31))
    return 1;
  /** parse set_main + typeck 分派：if(CALL) 模式 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_parse_set_main_from_buf", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_typeck_parsed_module", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_typeck_entry_module", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_fill_dep_import_path", 36))
    return 1;
  /** import 路径含 '.' 探测：纯 while，无 let=CALL。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_import_has_dot", 27))
    return 1;
  /** 单 import resolve+read：X 栈 path + if(CALL!=0) return。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_import_resolve_read", 33))
    return 1;
  /** 单 import 全链 resolve/read/preprocess/parse；X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_import_from_disk", 30))
    return 1;
  /** 单 import 槽 bind 或 load_from_disk；X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_one_import_slot", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_prepare_dep_codegen_path", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_finish_dep_codegen_diag", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_parse_entry_do_parse", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_codegen_one_dep", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_codegen_entry", 29))
    return 1;
  /** sync 入口：null 检查 + 有界 while(CALL!=0) + if(sync_one) X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_sync_dep_slots_from_driver", 35))
    return 1;
  /** dep 批量 codegen：有界 while + run_x_pipeline_codegen_one_dep X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_codegen_deps", 28))
    return 1;
  /** load/sync deps：import 有界 while + sync/typeck merge X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_and_sync_direct_import_deps", 41))
    return 1;
  /** resolve 编排：lib_root while + try_* CALL（try_* 仍 thin→C）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_x", 15))
    return 1;
  /** resolve try_*：sidecar off + if(CALL) 模式 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_try_one_lib_root", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_try_entry_dir", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_try_flat_import_under_lib", 38))
    return 1;
  /** 完整流水线编排：run_x_pipeline_impl X 真 emit（if(CALL)+last_rc_get 模式）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_impl", 19))
    return 1;
  /** load/typecheck phase 编排 + last_rc sidecar。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_load_deps_after_parse", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_typecheck_after_load", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"lsp_diag_typeck_after_load", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"lsp_diag_parse_typeck_buf", 25))
    return 1;
  return 0;
}

/**
 * driver/compile.x EMIT_HEAVY 第二遍：argv 分 helper + dispatch X 真 emit；post_parse / run_compiler_full_x 仍桩。
 */
static int32_t asm_driver_compile_emit_heavy_safe_helper(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_driver_compile_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compile_dispatch_asm_backend", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compile_dispatch_emit_c_path", 28))
    return 1;
  /** driver_compile_gen.o 导出带 driver_ 前缀；module 表多为裸名，二者均匹配。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_dispatch_asm_backend", 35))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_dispatch_emit_c_path", 35))
    return 1;
  /** run_compiler_full_x* 大栈/复杂分派：EMIT_HEAVY 堆 state + post_parse/dispatch X 真 emit（thin 表已空）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_state_key", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_ensure_default_lib", 29))
    return 1;
  /** parse_argv 分 helper：init/step/loop/finalize/入口 X 真 emit（单函数双 512 栈数组 SIGSEGV）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_init", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_step", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_loop", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_finalize", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_scan_c", 31))
    return 0;
  /** run_compiler_full_x / post_parse：堆 state + dispatch X 真 emit（勿 thin→impl_c）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_compiler_full_x", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_compiler_full_x_post_parse", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_run_compiler_full_x", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_run_compiler_full_x_post_parse", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"path_ends_x", 12))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"target_has_arm", 14))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "eq_", 3))
    return 1;
  return 0;
}

/**
 * backend EMIT_HEAVY 第二遍：按符号名保留小 helper 真 emit（覆盖 #87+ 索引桩；219 func 模块中 arch_emit/enc 常在 #87 之后）。
 * M8-tail：fold_/asm_import_ 等前缀体 + 薄包装 C 委托函数按名放行。
 */
static int32_t asm_skip_heavy_backend_m8_helper_keep(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
#define ASMB_M8_HLP_PREFIX(pfx, plen)                                                                                  \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen)))                                \
      return 1;                                                                                                        \
  } while (0)
  ASMB_M8_HLP_PREFIX("asm_import_", 11);
  ASMB_M8_HLP_PREFIX("asm_build_import_", 17);
  ASMB_M8_HLP_PREFIX("asm_c_prefix_", 13);
  ASMB_M8_HLP_PREFIX("fold_", 5);
  ASMB_M8_HLP_PREFIX("asm_module_named_", 17);
  ASMB_M8_HLP_PREFIX("asm_expr_binop_", 15);
  ASMB_M8_HLP_PREFIX("asm_field_access_", 17);
#undef ASMB_M8_HLP_PREFIX
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ctx_push_loop_labels", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ctx_pop_loop_labels", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_hoist_top_level_lets_for_codegen", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ctx_reset", 9))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compute_frame_size", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"local_offset", 12))
    return 1;
  /** M8-tail：形参/局部槽与 ELF/text 块体薄包装（单行 C 委托），扩 backend.o __text。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_param_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_local_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body_elf", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits_elf", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_elf", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop_elf", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop_elf", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content_elf", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_next_label", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"format_label_id", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_call", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_method_call", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_emit_call_args_elf", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_text", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr", 9))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_call", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_method_call", 21))
    return 1;
  return 0;
}

/** 旧名别名：arch_emit_/enc_ 前缀 helper。 */
static int32_t asm_skip_heavy_backend_helper_keep(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
#define ASMB_KEEP_PREFIX(pfx)                                                                                            \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(sizeof(pfx) - 1)))                     \
      return 1;                                                                                                        \
  } while (0)
  ASMB_KEEP_PREFIX("arch_emit_");
  ASMB_KEEP_PREFIX("enc_");
#undef ASMB_KEEP_PREFIX
  return 0;
}

/* ── EMIT_HEAVY 第二遍 backend/typeck mega + m8-tail skip 入口分类器（补全 skip_heavy 全集；自 ast_pool.c 抽出）── */

/**
 * M8-tail：backend 薄包装 helper 按名真 emit，须先于 #87+ 索引桩（emit_block_body_elf #179 等）。
 * 不含 fold_/asm_import_ 等前缀体，避免 Abort 带内误放行大函数。
 */
static int32_t asm_skip_heavy_backend_m8_tail_thin_keep(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_param_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_local_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compute_frame_size", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body_elf", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits_elf", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_elf", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop_elf", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop_elf", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content_elf", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_next_label", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"format_label_id", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_call", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_method_call", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_emit_call_args_elf", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_text", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr", 9))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_call", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_method_call", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_index_eff_addr_text", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_index_eff_addr_elf", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_lvalue_eff_addr_text", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_lvalue_eff_addr_elf", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_emit_call_args_text", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"local_offset", 12))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_resolve_whole_import_qualified_symbol", 41))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_skip_heavy_stub_elf", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_shuffle_call_elf", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_select_call_elf", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_binop2_call_elf", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_fma3_call_elf", 29))
    return 1;
  return 0;
}

/**
 * typeck EMIT_HEAVY 第二遍：layout/diag 小 helper 真 emit（ExprKind=51 已修；槽位过大仍走 mega/默认桩）。
 */
static int32_t asm_skip_heavy_typeck_helper_keep(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_typeck_selfhost(m))
    return 0;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_align", 20) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_size", 19))
    return 0;
  return 0;
}

/**
 * backend 第二遍 EMIT_HEAVY：按符号名桩化 mega codegen/emit 入口（expr 树递归、块体、入口 asm_codegen_ast）。
 * 小 helper（arch_emit_*、try_fold_*、fill_param_slots 等）仍真 emit，扩 backend.o __text 且避免宿主栈 Abort。
 */
static int32_t asm_skip_heavy_backend_mega_entry(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
#define ASMB_MEGA(name, nlen)                                                                                          \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(name), (nlen)))                                  \
      return 1;                                                                                                        \
  } while (0)
  ASMB_MEGA("asm_codegen_ast", 15);
  ASMB_MEGA("asm_codegen_ast_to_elf", 22);
  ASMB_MEGA("asm_codegen_ast_seed_mega", 25);
  ASMB_MEGA("asm_codegen_ast_to_elf_seed_mega", 32);
  /** emit_expr / emit_block_* / loop / if-then / fill_* / call / local_offset：thin_keep 真 emit（C/partial 委托）。 */
  /** extern/C sidecar glue：.x 体含 ExprKind 54 等 asm 未支持形态，须桩化。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_ctx_key", 11))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_local_", 14))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_block_", 14))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_loop_", 13))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_ensure_", 15))
    return 1;
  return 0;
}

/** typeck 第二遍 emit：桩化巨型 typecheck/diag/implicit-return 入口；layout/helper 须真 emit 过 8KiB。 */
static int32_t asm_skip_heavy_typeck_mega_entry(void *m, int32_t func_index) {
  if (!m || func_index < 0)
    return 0;
  if (/** typeck_skip_heavy_selfhost 等 mega 入口仍桩化。 */
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_skip_heavy_selfhost_func_body", 36))
    return 1;
  /**
   * check_* mega：宿主编译器真 emit 会 SIGSEGV；EMIT_HEAVY 第二遍 ret0 桩。
   * 子 helper 经 asm_typeck_emit_heavy_safe_helper 分片 X 真 emit。
   */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl_mega", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_impl", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_stmt_order_one", 33))
    return 1;
  /** 遍历全模块函数：槽位高；EMIT_HEAVY 第二遍 ret0 桩（子 helper check_one_func 仍 X）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_impl", 17))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_library", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_check_all_funcs_loop", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_check_one_func", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast", 12))
    return 1;
  /** type_kind_ordinal 在瘦 typeck #0 须真 emit；勿在此 mega 桩。 */
  return 0;
}

/* wave118 asm skip_dispatch leave cold twins — former pipeline_asm_skip_dispatch.c.
 * Product hybrid PREFER: pure runtime_pipeline_abi.x owns the 2 strong faces +
 * set_pipeline_ctx BSS. Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * void* module + Cap residual accessors only (no incomplete Module fields).
 * PLATFORM: SHARED — cold only when pure FROM_X object is not linked. */
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t pipeline_module_func_name_len_at(void *m, int32_t fi);
extern uint8_t pipeline_module_func_name_byte_at(void *m, int32_t fi, int32_t i);
extern int32_t xlang_module_num_imports(void *m);
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, uint8_t *name, int32_t name_len);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_body_ref_at(void *m, int32_t fi);
extern int32_t asm_env_build_skip_typeck(void);
extern int32_t asm_env_entry_emit_heavy(void);
extern int32_t asm_skip_typeck_entry_whitelist(void *m, int32_t func_index);
extern int32_t driver_typeck_skip_large_entry(void);
extern int32_t pipeline_dep_ctx_asm_entry_module_only(void *ctx);
extern int32_t pipeline_dep_ctx_use_asm_backend(void *ctx);
extern int32_t asm_count_block_stack_slots(void *arena, int32_t block_ref);
extern int32_t asm_module_is_compiler_selfhost(void *m);
extern int32_t asm_module_is_ast_selfhost(void *m);
extern int32_t asm_module_is_typeck_selfhost(void *m);
extern int32_t asm_module_is_backend_selfhost(void *m);
extern int32_t asm_module_is_pipeline_selfhost(void *m);
extern int32_t asm_module_is_main_driver_selfhost(void *m);
extern int32_t asm_module_is_driver_compile_selfhost(void *m);
extern int32_t asm_module_is_parser_emit_heavy(void *m);
extern int32_t asm_module_num_defined_funcs(void *m);
extern int32_t asm_module_defined_func_ordinal(void *m, int32_t func_index);
extern int32_t asm_typeck_emit_heavy_safe_helper(void *m, int32_t func_index);
extern int32_t asm_pipeline_emit_heavy_safe_helper(void *m, int32_t func_index);
extern int32_t asm_driver_compile_emit_heavy_safe_helper(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_m8_helper_keep(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_helper_keep(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_m8_tail_thin_keep(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_typeck_helper_keep(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_backend_mega_entry(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_typeck_mega_entry(void *m, int32_t func_index);
extern int32_t asm_skip_heavy_parser_mega_entry(void *m, int32_t func_index);
extern int32_t asm_parser_emit_heavy_bisect_max_index(void);
extern int32_t asm_parser_emit_heavy_safe_helper(void *m, int32_t func_index);
extern int32_t asm_parser_emit_heavy_force_stub(void *m, int32_t func_index);
extern int32_t asm_parser_func_is_thin_delegate(void *m, int32_t func_index);
extern int32_t asm_parser_emit_heavy_slot_max(void);
extern void asm_parser_emit_heavy_dbg_real(void *m, int32_t fi, const char *why);
extern int32_t asm_emit_heavy_abort_lo(void);
extern int32_t asm_emit_heavy_abort_hi(void);
extern int32_t pipeline_module_func_name_has_prefix_at(void *m, int32_t fi, const char *pfx, int32_t plen);

static void *g_asm_skip_pipeline_ctx_cold;

void asm_skip_heavy_set_pipeline_ctx(void *ctx) {
  g_asm_skip_pipeline_ctx_cold = ctx;
}

void asm_empty_text_stub_label(void *m, uint8_t *out, int32_t out_cap, int32_t *out_len) {
  uint32_t h = 2166136261u;
  int32_t i, k, nl, pos, d, nd;
  uint32_t v;
  uint8_t digits[16];
  static const uint8_t prefix[] = "_xlang_asm_stu_";
  if (!out || out_cap < 24 || !out_len) {
    if (out_len)
      *out_len = 0;
    return;
  }
  if (m && pipeline_module_num_funcs(m) > 0) {
    int32_t nfuncs = pipeline_module_num_funcs(m);
    for (i = 0; i < nfuncs; i++) {
      nl = pipeline_module_func_name_len_at(m, i);
      for (k = 0; k < nl; k++)
        h = (uint32_t)((h ^ (uint8_t)pipeline_module_func_name_byte_at(m, i, k)) * 16777619u);
    }
  } else {
    h ^= (uint32_t)(m ? xlang_module_num_imports(m) : 0);
    h *= 16777619u;
  }
  memcpy(out, prefix, sizeof(prefix) - 1);
  pos = (int32_t)(sizeof(prefix) - 1);
  nd = 0;
  v = h;
  if (v == 0)
    digits[nd++] = (uint8_t)'0';
  else {
    while (v > 0 && nd < 16) {
      digits[nd++] = (uint8_t)('0' + (v % 10));
      v /= 10;
    }
  }
  for (d = nd - 1; d >= 0; d--)
    out[pos++] = digits[d];
  out[pos] = 0;
  *out_len = pos;
}

int32_t asm_skip_heavy_module_func_body(void *m, void *arena, int32_t func_index) {
  int32_t body_ref;
  int32_t slots;
  int32_t slot_threshold;
  int32_t nfuncs;
  if (!m || func_index < 0)
    return 0;
  if (!asm_module_is_compiler_selfhost(m))
    return 0;
  if (asm_module_is_ast_selfhost(m) && asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0) {
    if (asm_skip_typeck_entry_whitelist(m, func_index) != 0)
      return 0;
    return 1;
  }
  if (g_asm_skip_pipeline_ctx_cold != NULL &&
      pipeline_dep_ctx_asm_entry_module_only(g_asm_skip_pipeline_ctx_cold) != 0 &&
      pipeline_dep_ctx_use_asm_backend(g_asm_skip_pipeline_ctx_cold) != 0 &&
      driver_typeck_skip_large_entry() == 0 &&
      asm_env_build_skip_typeck() == 0 &&
      asm_env_entry_emit_heavy() == 0) {
    return 0;
  }
  if (asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0) {
    if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
      return 0;
    if (asm_skip_typeck_entry_whitelist(m, func_index) != 0)
      return 0;
    return 1;
  }
  nfuncs = pipeline_module_num_funcs(m);
  if (asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0 && nfuncs > 0 &&
      nfuncs <= 32 && func_index < 10)
    return 1;
  if (asm_env_entry_emit_heavy() == 0 &&
      (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr", 10) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl", 15) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block", 11) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_impl", 16)))
    return 1;
  if (asm_env_entry_emit_heavy() != 0) {
    int32_t typeck_ndef = asm_module_is_typeck_selfhost(m) ? asm_module_num_defined_funcs(m) : 0;
    int32_t typeck_ord = asm_module_defined_func_ordinal(m, func_index);
    if (asm_module_is_parser_emit_heavy(m)) {
      if (asm_skip_heavy_parser_mega_entry(m, func_index) != 0)
        return 1;
      if (asm_parser_emit_heavy_bisect_max_index() == 0)
        return 1;
      if (asm_parser_emit_heavy_safe_helper(m, func_index) != 0) {
        asm_parser_emit_heavy_dbg_real(m, func_index, "safe_helper");
        return 0;
      }
      if (asm_parser_emit_heavy_force_stub(m, func_index) != 0)
        return 1;
      if (asm_parser_func_is_thin_delegate(m, func_index) != 0)
        return 1;
      if (func_index >= asm_parser_emit_heavy_bisect_max_index())
        return 1;
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0)
        return 1;
      slots = asm_count_block_stack_slots(arena, body_ref);
      if (slots > asm_parser_emit_heavy_slot_max())
        return 1;
      asm_parser_emit_heavy_dbg_real(m, func_index, "slot_fallback");
      return 0;
    }
    if (asm_module_is_typeck_selfhost(m) && typeck_ndef >= 160 && typeck_ndef <= 180) {
      if (typeck_ord < 0)
        return 1;
      if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
        return 1;
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      if (typeck_ord >= 118 && typeck_ord <= 159)
        return 1;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_kind_ordinal", 17))
        return 0;
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      if (typeck_ord < 90)
        return 1;
      return 1;
    }
    if (typeck_ndef >= 75 && typeck_ndef <= 200 && !asm_module_is_backend_selfhost(m) &&
        !asm_module_is_parser_emit_heavy(m)) {
      int32_t body_ref_thin;
      int32_t slots_thin;
      if (typeck_ord < 0)
        return 1;
      if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
        return 1;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_merge_dep_struct_layouts_into_entry", 42))
        return 0;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_wpo_unify_soa_layouts", 28))
        return 0;
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) == 0)
        return 1;
      body_ref_thin = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref_thin <= 0)
        return 1;
      slots_thin = asm_count_block_stack_slots(arena, body_ref_thin);
      if (slots_thin > 128)
        return 1;
      return 0;
    }
    if (asm_module_is_pipeline_selfhost(m)) {
      if (asm_pipeline_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    if (asm_module_is_main_driver_selfhost(m)) {
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"entry", 5))
        return 0;
      return 1;
    }
    if (asm_module_is_driver_compile_selfhost(m)) {
      if (asm_driver_compile_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    if (asm_module_is_backend_selfhost(m) && asm_skip_heavy_backend_m8_tail_thin_keep(m, func_index) != 0)
      return 1;
    if (asm_module_is_backend_selfhost(m) && nfuncs <= 150 &&
        (asm_skip_heavy_backend_helper_keep(m, func_index) != 0 ||
         asm_skip_heavy_backend_m8_helper_keep(m, func_index) != 0)) {
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0 ||
          asm_count_block_stack_slots(arena, body_ref) <= 48)
        return 0;
    }
    if (asm_module_is_typeck_selfhost(m) && asm_skip_heavy_typeck_helper_keep(m, func_index) != 0) {
      if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
        return 1;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_align", 20) ||
          pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_size", 19))
        return 1;
      if (func_index >= 90 && func_index <= 159)
        return 1;
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0)
        return 0;
      if (asm_count_block_stack_slots(arena, body_ref) <= 128)
        return 0;
    }
    if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
      return 1;
    if (asm_skip_heavy_backend_mega_entry(m, func_index) != 0)
      return 1;
    if (asm_module_is_typeck_selfhost(m) && typeck_ndef >= 90 && typeck_ord >= 0 &&
        typeck_ord >= 90 && typeck_ord <= 159) {
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    if (asm_module_is_backend_selfhost(m) && nfuncs >= 80) {
      int32_t be_hi = asm_emit_heavy_abort_hi();
      if (be_hi >= nfuncs)
        be_hi = nfuncs - 1;
      if (func_index >= asm_emit_heavy_abort_lo() && func_index <= be_hi)
        return 1;
    } else if (driver_typeck_skip_large_entry() != 0 && nfuncs >= 175) {
      if (func_index >= asm_emit_heavy_abort_lo() && func_index <= asm_emit_heavy_abort_hi())
        return 1;
    } else if (nfuncs >= 160 && func_index >= 72 && !asm_module_is_backend_selfhost(m) &&
               !asm_module_is_typeck_selfhost(m) && !asm_module_is_parser_emit_heavy(m)) {
      return 1;
    }
    body_ref = pipeline_module_func_body_ref_at(m, func_index);
    slot_threshold = 256;
    if (asm_module_is_backend_selfhost(m) && func_index < 87) {
      slot_threshold = 256;
    } else if ((asm_module_is_backend_selfhost(m) && nfuncs >= 80) ||
               (driver_typeck_skip_large_entry() != 0 && nfuncs >= 175))
      slot_threshold = 96;
    if (arena && body_ref > 0) {
      slots = asm_count_block_stack_slots(arena, body_ref);
      if (slots > slot_threshold)
        return 1;
    }
    if (asm_module_is_backend_selfhost(m))
      return 1;
    if (asm_module_is_typeck_selfhost(m)) {
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 0;
    }
    return 0;
  }
  if (nfuncs >= 160 && func_index >= 72)
    return 1;
  body_ref = pipeline_module_func_body_ref_at(m, func_index);
  if (arena && body_ref > 0) {
    slots = asm_count_block_stack_slots(arena, body_ref);
    if (slots > 48)
      return 1;
  }
  return 0;
}

/* wave119 cold twins: emit_heavy_env pure leave (void* Module/Arena).
 * Cap residual accessors remain host-cc (top_level_let / expr / driver_get).
 * PLATFORM: SHARED. */
extern const char *driver_get_current_dep_path_for_codegen(void);
extern int32_t pipeline_module_top_level_let_name_len(void *m, int32_t idx);
extern uint8_t pipeline_module_top_level_let_name_byte_at(void *m, int32_t idx, int32_t off);
extern int32_t pipeline_module_top_level_let_init_ref(void *m, int32_t idx);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_int_val_at(void *a, int32_t expr_ref);
extern long strtol(const char *nptr, char **endptr, int base);

static int32_t wave119_env_truthy(const char *e) {
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

int32_t asm_env_entry_emit_heavy(void) {
  return wave119_env_truthy(link_abi_getenv("XLANG_ASM_ENTRY_EMIT_HEAVY"));
}

int32_t asm_env_build_skip_typeck(void) {
  return wave119_env_truthy(link_abi_getenv("XLANG_ASM_BUILD_SKIP_TYPECK"));
}

static int32_t wave119_asm_env_strict_orchestration(void) {
  return wave119_env_truthy(link_abi_getenv("XLANG_ASM_STRICT_ORCHESTRATION"));
}

int32_t asm_emit_heavy_abort_lo(void) {
  const char *e = link_abi_getenv("XLANG_ASM_EMIT_ABORT_LO");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return 87;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return 87;
  return (int32_t)v;
}

int32_t asm_emit_heavy_abort_hi(void) {
  const char *e = link_abi_getenv("XLANG_ASM_EMIT_ABORT_HI");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return 218;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return 218;
  return (int32_t)v;
}

int32_t pipeline_module_func_name_has_prefix_at(void *m, int32_t fi, const char *pfx, int32_t plen) {
  int32_t nl;
  int32_t k;
  if (!m || fi < 0 || !pfx || plen <= 0)
    return 0;
  nl = pipeline_module_func_name_len_at(m, fi);
  if (nl < plen)
    return 0;
  for (k = 0; k < plen; k++) {
    if (pipeline_module_func_name_byte_at(m, fi, k) != (int32_t)(uint8_t)pfx[k])
      return 0;
  }
  return 1;
}

uint8_t *asm_driver_current_dep_path_for_codegen(void) {
  const char *p = driver_get_current_dep_path_for_codegen();
  return (uint8_t *)(p ? p : "");
}

void asm_import_path_to_c_prefix_into(uint8_t *path, uint8_t *buf, int32_t buf_cap) {
  int32_t off = 0;
  int32_t pi = 0;
  if (!buf || buf_cap <= 0)
    return;
  if (!path) {
    buf[0] = '\0';
    return;
  }
  while (path[pi] != 0 && off + 2 < buf_cap) {
    buf[off++] = (uint8_t)(path[pi] == '.' ? '_' : path[pi]);
    pi++;
  }
  if (off + 1 < buf_cap)
    buf[off++] = '_';
  buf[off] = 0;
}

int32_t asm_module_top_level_const_lit_i32(void *m, void *a, uint8_t *name, int32_t name_len,
    int32_t *out_imm) {
  int32_t tl;
  int32_t nl;
  int32_t k;
  int32_t init_ref;
  int32_t ntl;
  if (!m || !a || !name || name_len <= 0 || !out_imm)
    return 0;
  /* LP64: Module.num_top_level_lets @ offset 12 (≡ pure pipe_mod_get_num_top_level_lets). */
  ntl = m ? *(int32_t *)((char *)m + 12) : 0;
  for (tl = 0; tl < ntl; tl++) {
    nl = pipeline_module_top_level_let_name_len(m, tl);
    if (nl != name_len || nl <= 0)
      continue;
    for (k = 0; k < name_len; k++) {
      if (pipeline_module_top_level_let_name_byte_at(m, tl, k) != name[k])
        break;
    }
    if (k != name_len)
      continue;
    init_ref = pipeline_module_top_level_let_init_ref(m, tl);
    if (init_ref <= 0)
      continue;
    k = pipeline_expr_kind_ord_at(a, init_ref);
    if (k == 0 || k == 2) {
      *out_imm = pipeline_expr_int_val_at(a, init_ref);
      return 1;
    }
  }
  return 0;
}

int32_t asm_skip_typeck_entry_whitelist(void *m, int32_t func_index) {
  int32_t large_entry;
  if (!m || func_index < 0)
    return 0;
  if (asm_module_is_parser_selfhost(m)) {
    if (link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT") != NULL) {
      if (link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL") != NULL) {
        if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_init", 15) ||
            pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_set_main_index", 25))
          return 1;
      } else {
        if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_buf", 14) ||
            pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into", 10) ||
            pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_init", 15) ||
            pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_set_main_index", 25) ||
            pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"collect_imports_buf", 19))
          return 1;
      }
    }
    return 0;
  }
  large_entry = driver_typeck_skip_large_entry();
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_run_all", 21) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_impl", 19) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_should_skip_codegen", 33) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_phase_parse_load", 30) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_phase_parse_only", 30) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_phase_load_deps", 29) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_typecheck", 23) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_codegen_deps", 26) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_codegen_entry", 27) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_codegen_chain", 27) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_init", 15) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_set_main_index", 25) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"collect_imports_buf", 19) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_buf", 14) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"entry", 5))
    return 1;
  if (large_entry == 0) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast", 12) ||
        pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_library", 20) ||
        pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_codegen_ast", 15))
      return 1;
  }
  return 0;
}

int32_t asm_orchestration_extern_only_func(void *m, int32_t func_index) {
  if (!m || func_index < 0)
    return 0;
  if (wave119_asm_env_strict_orchestration() == 0)
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_typecheck", 23) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_with_init_buf", 24) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_phase_parse_load", 30) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_run_all", 21) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_impl", 19))
    return 1;
  return 0;
}


/* wave120 cold twins: parser_emit_heavy pure leave (void* Module).
 * G.7 sole cold provider under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED. */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern int32_t pipeline_module_func_name_len_at(void *m, int32_t fi);
extern void pipeline_module_func_name_copy64(void *m, int32_t fi, uint8_t *dst);
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, const uint8_t *name, int32_t name_len);
extern int32_t pipeline_module_func_name_has_prefix_at(void *m, int32_t fi, const char *pfx, int32_t plen);
extern int32_t pipeline_module_num_funcs(void *m);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);
extern int32_t asm_module_is_parser_emit_heavy(void *m);
extern const char *link_abi_getenv(const char *name);

#define ASM_EMIT_HEAVY_PARSER_SLOT_MAX 16

void asm_parser_emit_heavy_dbg_real(void *m, int32_t fi, const char *why) {
  uint8_t fn[128];
  int32_t fl;
  if (!link_abi_getenv("XLANG_ASM_DEBUG") || !m || fi < 0 || !why)
    return;
  fl = pipeline_module_func_name_len_at(m, fi);
  pipeline_module_func_name_copy64(m, fi, fn);
  fprintf(stderr, "xlang: parser REAL_EMIT fi=%d fn=%.*s why=%s\n", fi, (int)(fl > 127 ? 127 : fl), fn, why);
  fflush(stderr);
}

int32_t asm_parser_emit_heavy_bisect_max_index(void) {
  const char *stub = link_abi_getenv("XLANG_PARSER_EMIT_HEAVY_STUB_ONLY");
  char *end = NULL;
  long v;
  const char *e;
  if (stub != NULL && stub[0] != '\0' && stub[0] != '0')
    return 0;
  e = link_abi_getenv("XLANG_PARSER_EMIT_HEAVY_BISECT_N");
  if (!e || e[0] == '\0')
    return 2147483647;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return 2147483647;
  if (v > 2147483647L)
    return 2147483647;
  return (int32_t)v;
}

int32_t asm_parser_emit_heavy_slot_max(void) {
  const char *e = link_abi_getenv("XLANG_PARSER_EMIT_HEAVY_SLOT_MAX");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return ASM_EMIT_HEAVY_PARSER_SLOT_MAX;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return ASM_EMIT_HEAVY_PARSER_SLOT_MAX;
  if (v > 512)
    return 512;
  return (int32_t)v;
}

typedef struct {
  const char *name;
  int32_t len;
} wave120_boot_parse_sym_t;

static int32_t wave120_mega_bisect_skip_stub(void *m, int32_t func_index, const char *name, int32_t len) {
  const char *b;
  size_t blen;
  if (!m || func_index < 0 || !name || len <= 0)
    return 0;
  b = link_abi_getenv("XLANG_ASM_PARSER_MEGA_BISECT");
  if (!b || b[0] == '\0')
    return 0;
  blen = strlen(b);
  if ((int32_t)blen != len)
    return 0;
  if (memcmp(b, name, (size_t)len) != 0)
    return 0;
  return pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)name, len);
}

static int32_t wave120_bootstrap_mega_emit_allowed(void *m, int32_t func_index, const char *name, int32_t len) {
  static const wave120_boot_parse_sym_t k_min[] = {
      {"parse_into_init", 15},
      {"parse_into_set_main_index", 25},
  };
  static const wave120_boot_parse_sym_t k_full[] = {
      {"parse_into_buf", 14},
      {"parse_into", 10},
      {"parse_into_init", 15},
      {"parse_into_set_main_index", 25},
      {"collect_imports_buf", 19},
  };
  const wave120_boot_parse_sym_t *k;
  int32_t kn;
  int32_t i;
  if (!m || func_index < 0 || link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT") == NULL)
    return 0;
  if (!pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)name, len))
    return 0;
  if (link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL") != NULL) {
    k = k_min;
    kn = (int32_t)(sizeof(k_min) / sizeof(k_min[0]));
  } else {
    k = k_full;
    kn = (int32_t)(sizeof(k_full) / sizeof(k_full[0]));
  }
  for (i = 0; i < kn; i++) {
    if (k[i].len == len && memcmp(k[i].name, name, (size_t)len) == 0)
      return 1;
  }
  return 0;
}

int32_t asm_skip_heavy_parser_mega_entry(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_MEGA_EQ(n, l) \
  do { \
    if (wave120_mega_bisect_skip_stub(m, func_index, (n), (l))) \
      break; \
    if (wave120_bootstrap_mega_emit_allowed(m, func_index, (n), (l))) \
      break; \
    if (pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)(n), (l))) \
      return 1; \
  } while (0)
  PARSER_MEGA_EQ("parse_into_buf", 14);
  PARSER_MEGA_EQ("parse_into", 10);
  PARSER_MEGA_EQ("parse", 5);
  PARSER_MEGA_EQ("parse_one_function_impl", 23);
  PARSER_MEGA_EQ("parse_expr_into", 15);
  PARSER_MEGA_EQ("parse_block_into", 16);
  PARSER_MEGA_EQ("parse_body_lets_into", 20);
#undef PARSER_MEGA_EQ
  return 0;
}

int32_t asm_parser_emit_heavy_force_stub(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_STUB_EQ(n, l) \
  do { \
    if (pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)(n), (l))) \
      return 1; \
  } while (0)
#define PARSER_STUB_PFX(pfx, plen) \
  do { \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen))) \
      return 1; \
  } while (0)
  PARSER_STUB_PFX("copy_onefunc_", 13);
  PARSER_STUB_PFX("onefunc_", 8);
  PARSER_STUB_PFX("set_onefunc_", 12);
  PARSER_STUB_EQ("wrap_block_ref_as_expr", 22);
  PARSER_STUB_EQ("parser_alloc_true_bool_lit", 26);
  PARSER_STUB_EQ("parser_alloc_float_lit", 22);
  PARSER_STUB_EQ("parser_expr_wrap_in_return", 26);
  PARSER_STUB_EQ("try_skip_allow_padding_struct", 29);
  PARSER_STUB_EQ("try_skip_allow_padding_struct_buf", 33);
#undef PARSER_STUB_EQ
#undef PARSER_STUB_PFX
  return 0;
}

int32_t asm_parser_emit_heavy_safe_helper(void *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_SAFE_EQ(n, l) \
  do { \
    if (pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)(n), (l))) \
      return 1; \
  } while (0)
  PARSER_SAFE_EQ("get_module_num_imports", 22);
  PARSER_SAFE_EQ("expr_ref_is_assign_lvalue", 25);
  PARSER_SAFE_EQ("copy_slice_to_name64", 20);
  PARSER_SAFE_EQ("copy_slice_to_name64_at_end", 27);
  PARSER_SAFE_EQ("copy_slice_to_param32", 21);
  PARSER_SAFE_EQ("copy_slice_to_param32_at_end", 28);
  PARSER_SAFE_EQ("copy_slice_to_name64_buf", 24);
  PARSER_SAFE_EQ("copy_slice_to_name64_at_end_buf", 31);
  PARSER_SAFE_EQ("copy_slice_to_param32_at_end_buf", 32);
  PARSER_SAFE_EQ("copy_slice_to_param32_buf", 25);
  PARSER_SAFE_EQ("get_module_import_path", 22);
  PARSER_SAFE_EQ("copy_module_import_path64", 25);
  PARSER_SAFE_EQ("parse_one_function_library_buf", 30);
  PARSER_SAFE_EQ("parse_one_function_library_into_buf", 35);
  PARSER_SAFE_EQ("parse_one_function_buf_into", 27);
  PARSER_SAFE_EQ("parse_into_init", 15);
  PARSER_SAFE_EQ("parse_one_function_library_into", 31);
  PARSER_SAFE_EQ("pipeline_module_reset_parse_counters", 36);
  PARSER_SAFE_EQ("extern_parse_set_fail", 21);
  PARSER_SAFE_EQ("extern_parse_pool_ptr", 21);
  PARSER_SAFE_EQ("onefunc_result_pool_ptr", 23);
  PARSER_SAFE_EQ("set_onefunc_fail", 16);
  PARSER_SAFE_EQ("copy_lex_from_import_into", 25);
  PARSER_SAFE_EQ("lex_from_next_into", 18);
  PARSER_SAFE_EQ("lex_from_result_ptr_into", 24);
  PARSER_SAFE_EQ("lex_from_onefunc_next_into", 26);
  PARSER_SAFE_EQ("write_extern_params_to_pools", 28);
  PARSER_SAFE_EQ("module_register_arena_func", 26);
  PARSER_SAFE_EQ("is_pointee_type_token", 21);
  PARSER_SAFE_EQ("compound_assign_token_to_expr_kind", 34);
  PARSER_SAFE_EQ("import_path_dot_segment_copy", 28);
  PARSER_SAFE_EQ("parser_alloc_vector_type_ref", 28);
  PARSER_SAFE_EQ("parse_peek_function_name_buf", 28);
  PARSER_SAFE_EQ("lexer_pos_before_run", 20);
  PARSER_SAFE_EQ("parser_match_kw_immediately_before", 34);
  PARSER_SAFE_EQ("import_path_dot_segment_len", 27);
  PARSER_SAFE_EQ("is_compound_assign_token", 24);
  PARSER_SAFE_EQ("struct_field_name_tok_kind", 26);
  PARSER_SAFE_EQ("struct_field_continues_tok_kind", 31);
  PARSER_SAFE_EQ("module_try_register_enum_name", 29);
  PARSER_SAFE_EQ("struct_layout_name_exists_arr", 29);
  PARSER_SAFE_EQ("struct_layout_first_name_match_idx", 34);
  PARSER_SAFE_EQ("struct_layout_placeholder_idx", 29);
  PARSER_SAFE_EQ("lexer_token_run_len", 19);
  PARSER_SAFE_EQ("module_append_enum_variants_and_skip_body_into_buf", 50);
  PARSER_SAFE_EQ("skip_balanced_parens_into_buf", 29);
  PARSER_SAFE_EQ("skip_balanced_braces_into_buf", 29);
  PARSER_SAFE_EQ("skip_one_enum_into_buf", 22);
  PARSER_SAFE_EQ("skip_one_struct_into_buf", 24);
  PARSER_SAFE_EQ("skip_one_trait_into_buf", 23);
  PARSER_SAFE_EQ("skip_one_impl_into_buf", 22);
  PARSER_SAFE_EQ("skip_one_extern_into_buf", 24);
  PARSER_SAFE_EQ("skip_one_function_full_into_buf", 31);
  PARSER_SAFE_EQ("skip_one_enum_register_into_buf", 31);
  PARSER_SAFE_EQ("parse_one_extern_and_add_into_buf", 33);
  PARSER_SAFE_EQ("diag_skip_let_const_buf", 23);
  PARSER_SAFE_EQ("body_skip_let_const_then_if_buf", 31);
  PARSER_SAFE_EQ("skip_balanced_parens_buf", 24);
  PARSER_SAFE_EQ("skip_balanced_braces_buf", 24);
  PARSER_SAFE_EQ("skip_one_function_full_buf", 26);
  PARSER_SAFE_EQ("skip_one_if_core_buf", 20);
  PARSER_SAFE_EQ("skip_one_if_statement_buf", 25);
  PARSER_SAFE_EQ("skip_one_enum_buf", 17);
  PARSER_SAFE_EQ("skip_one_trait_buf", 18);
  PARSER_SAFE_EQ("skip_one_impl_buf", 17);
  PARSER_SAFE_EQ("skip_one_extern_buf", 19);
  PARSER_SAFE_EQ("skip_one_struct_buf", 19);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_buf", 29);
  PARSER_SAFE_EQ("try_skip_allow_padding_struct_buf", 33);
  PARSER_SAFE_EQ("lex_from_library_into", 21);
  PARSER_SAFE_EQ("lex_from_try_skip_into", 22);
  PARSER_SAFE_EQ("lex_from_library", 16);
  PARSER_SAFE_EQ("lex_from_try_skip", 17);
  PARSER_SAFE_EQ("advance_past_stmt_semicolon_into", 32);
  PARSER_SAFE_EQ("advance_past_cond_rparen_into", 29);
  PARSER_SAFE_EQ("first_token_kind", 16);
  PARSER_SAFE_EQ("diag_first_ident_len", 20);
  PARSER_SAFE_EQ("parser_rewind_lex_for_following_stmt", 36);
  PARSER_SAFE_EQ("lex_at_token_from_result", 24);
  PARSER_SAFE_EQ("struct_field_name_from_tok", 26);
  PARSER_SAFE_EQ("diag_skip_let_const_into", 24);
  PARSER_SAFE_EQ("diag_skip_let_const", 19);
  PARSER_SAFE_EQ("body_skip_let_const_then_if_into", 32);
  PARSER_SAFE_EQ("body_skip_let_const_then_if", 27);
  PARSER_SAFE_EQ("skip_one_if_statement_into", 26);
  PARSER_SAFE_EQ("skip_one_if_core_into", 21);
  PARSER_SAFE_EQ("skip_one_if_statement", 21);
  PARSER_SAFE_EQ("skip_one_if_core", 16);
  PARSER_SAFE_EQ("skip_one_enum_into", 18);
  PARSER_SAFE_EQ("skip_one_impl_into", 18);
  PARSER_SAFE_EQ("skip_one_trait_into", 19);
  PARSER_SAFE_EQ("skip_one_extern_into", 20);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_into", 30);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_into_buf", 34);
  PARSER_SAFE_EQ("parse_into_set_main_index", 25);
  PARSER_SAFE_EQ("diag_token_after_collect_imports", 32);
  PARSER_SAFE_EQ("diag_parse_one_after_collect_imports", 36);
  PARSER_SAFE_EQ("parse_one_function_ok_for_pipeline", 34);
  PARSER_SAFE_EQ("skip_imports", 12);
  PARSER_SAFE_EQ("skip_one_struct", 15);
  PARSER_SAFE_EQ("skip_one_struct_into", 20);
  PARSER_SAFE_EQ("parse_one_extern_skip_into", 26);
  PARSER_SAFE_EQ("skip_one_enum", 13);
  PARSER_SAFE_EQ("skip_one_trait", 14);
  PARSER_SAFE_EQ("skip_one_impl", 13);
  PARSER_SAFE_EQ("skip_one_extern", 15);
  PARSER_SAFE_EQ("skip_one_function_full", 22);
  PARSER_SAFE_EQ("collect_imports", 15);
  PARSER_SAFE_EQ("consume_qualified_type_ident_name", 33);
  PARSER_SAFE_EQ("expr_set_common_zeros", 21);
  PARSER_SAFE_EQ("fill_block_const_let_from_res", 29);
  PARSER_SAFE_EQ("append_block_lets_from_res", 26);
  PARSER_SAFE_EQ("diag_after_imports_then_structs", 31);
  PARSER_SAFE_EQ("diag_fail_at_token_kind", 23);
  PARSER_SAFE_EQ("diag_lex_after_imports", 22);
  PARSER_SAFE_EQ("skip_balanced_parens", 20);
  PARSER_SAFE_EQ("skip_balanced_parens_into", 25);
  PARSER_SAFE_EQ("skip_balanced_braces", 20);
  PARSER_SAFE_EQ("skip_balanced_braces_into", 25);
  PARSER_SAFE_EQ("parse_primary_into", 18);
  PARSER_SAFE_EQ("parse_unary_into", 16);
  PARSER_SAFE_EQ("parse_cast_into", 15);
  PARSER_SAFE_EQ("parse_term_into", 15);
  PARSER_SAFE_EQ("parse_addsub_into", 17);
  PARSER_SAFE_EQ("parse_shift_into", 16);
  PARSER_SAFE_EQ("parse_relcompare_into", 21);
  PARSER_SAFE_EQ("parse_compare_into", 18);
  PARSER_SAFE_EQ("parse_bitand_into", 17);
  PARSER_SAFE_EQ("parse_bitor_into", 16);
  PARSER_SAFE_EQ("parse_bitxor_into", 17);
  PARSER_SAFE_EQ("parse_logand_into", 17);
  PARSER_SAFE_EQ("parse_logor_into", 16);
  PARSER_SAFE_EQ("parse_ternary_into", 18);
  PARSER_SAFE_EQ("parse_assign_into", 17);
  PARSER_SAFE_EQ("parse_as_suffix_into", 20);
  PARSER_SAFE_EQ("parse_one_function_library", 26);
  PARSER_SAFE_EQ("parse_one_function_library_scan", 31);
  PARSER_SAFE_EQ("parse_into_try_skip_allow", 25);
  PARSER_SAFE_EQ("parse_one_extern_and_add_into", 29);
  PARSER_SAFE_EQ("parse_one_top_level_let_into", 28);
  PARSER_SAFE_EQ("parser_should_wrap_func_tail_in_return", 38);
  PARSER_SAFE_EQ("skip_one_enum_register_into", 27);
  PARSER_SAFE_EQ("skip_one_function_full_into", 27);
  PARSER_SAFE_EQ("alloc_pointee_type_ref_from_tok", 31);
  PARSER_SAFE_EQ("parse_struct_record_layout_into", 31);
  PARSER_SAFE_EQ("parse_type_ref_for_arena_into", 29);
  PARSER_SAFE_EQ("parse_cond_expr_into", 20);
  PARSER_SAFE_EQ("module_append_enum_variants_and_skip_body_into", 46);
  PARSER_SAFE_EQ("parse_body_let_bracket_compound_init_ref", 40);
  PARSER_SAFE_EQ("parser_vector_type_ref_from_ident_spelling", 42);
  PARSER_SAFE_EQ("collect_imports_buf", 19);
  PARSER_SAFE_EQ("skip_imports_buf", 16);
  PARSER_SAFE_EQ("diag_skip_let_const_into_buf", 28);
  PARSER_SAFE_EQ("body_skip_let_const_then_if_into_buf", 36);
  PARSER_SAFE_EQ("skip_one_if_core_into_buf", 25);
  PARSER_SAFE_EQ("skip_one_if_statement_into_buf", 30);
  PARSER_SAFE_EQ("first_token_kind_buf", 20);
  PARSER_SAFE_EQ("diag_first_ident_len_buf", 24);
  PARSER_SAFE_EQ("diag_lex_after_imports_buf", 26);
  PARSER_SAFE_EQ("diag_after_imports_then_structs_buf", 35);
  PARSER_SAFE_EQ("diag_fail_at_token_kind_buf", 27);
  PARSER_SAFE_EQ("parse_one_extern_skip_into_buf", 30);
  PARSER_SAFE_EQ("consume_qualified_type_ident_name_buf", 37);
  PARSER_SAFE_EQ("advance_past_stmt_semicolon_into_buf", 36);
  PARSER_SAFE_EQ("advance_past_cond_rparen_into_buf", 33);
  PARSER_SAFE_EQ("parse_primary_into_buf", 22);
  PARSER_SAFE_EQ("parse_unary_into_buf", 20);
  PARSER_SAFE_EQ("parse_cast_into_buf", 19);
  PARSER_SAFE_EQ("parse_term_into_buf", 19);
  PARSER_SAFE_EQ("parse_addsub_into_buf", 21);
  PARSER_SAFE_EQ("parse_shift_into_buf", 20);
  PARSER_SAFE_EQ("parse_relcompare_into_buf", 25);
  PARSER_SAFE_EQ("parse_compare_into_buf", 22);
  PARSER_SAFE_EQ("parse_bitand_into_buf", 21);
  PARSER_SAFE_EQ("parse_bitxor_into_buf", 21);
  PARSER_SAFE_EQ("parse_bitor_into_buf", 20);
  PARSER_SAFE_EQ("parse_logand_into_buf", 21);
  PARSER_SAFE_EQ("parse_logor_into_buf", 20);
  PARSER_SAFE_EQ("parse_ternary_into_buf", 22);
  PARSER_SAFE_EQ("parse_assign_into_buf", 21);
  PARSER_SAFE_EQ("parse_expr_into_buf", 19);
  PARSER_SAFE_EQ("finish_struct_lit_from_type_ident_into_buf", 42);
  PARSER_SAFE_EQ("parse_cond_expr_into_buf", 24);
  PARSER_SAFE_EQ("parse_if_stmt_into_buf", 22);
  PARSER_SAFE_EQ("parse_if_stmt_into", 18);
  PARSER_SAFE_EQ("parse_if_expr_into", 18);
  PARSER_SAFE_EQ("parse_match_into", 16);
  PARSER_SAFE_EQ("parse_match_subject_into", 24);
  PARSER_SAFE_EQ("parse_at_simd_builtin_into", 26);
  PARSER_SAFE_EQ("finish_struct_lit_from_type_ident_into", 38);
  PARSER_SAFE_EQ("parse_expr_with_leading_int_as_into", 35);
  PARSER_SAFE_EQ("parse_block_into_buf", 20);
  PARSER_SAFE_EQ("parse_if_expr_into_buf", 22);
  PARSER_SAFE_EQ("parse_match_subject_into_buf", 28);
  PARSER_SAFE_EQ("parse_match_into_buf", 20);
  PARSER_SAFE_EQ("parse_at_simd_builtin_into_buf", 30);
  PARSER_SAFE_EQ("parse_as_suffix_into_buf", 24);
  PARSER_SAFE_EQ("parse_type_ref_for_arena_into_buf", 33);
  PARSER_SAFE_EQ("parse_body_let_bracket_compound_init_ref_buf", 44);
  PARSER_SAFE_EQ("parse_struct_record_layout_into_buf", 35);
  PARSER_SAFE_EQ("parse_one_function_library_scan_buf", 35);
  PARSER_SAFE_EQ("alloc_pointee_type_ref_from_tok_buf", 35);
  PARSER_SAFE_EQ("parser_vector_type_ref_from_ident_spelling_buf", 46);
  PARSER_SAFE_EQ("parse_one_top_level_let_into_buf", 32);
  PARSER_SAFE_EQ("import_path_dot_segment_copy_buf", 32);
  PARSER_SAFE_EQ("parser_match_kw_immediately_before_buf", 38);
  PARSER_SAFE_EQ("struct_field_name_from_tok_buf", 30);
  PARSER_SAFE_EQ("parse_expr_with_leading_int_as_into_buf", 39);
  PARSER_SAFE_EQ("skip_one_enum_register_buf", 26);
  PARSER_SAFE_EQ("skip_balanced_parens_slice_into_buf", 35);
  PARSER_SAFE_EQ("skip_balanced_braces_slice_into_buf", 35);
  PARSER_SAFE_EQ("module_append_enum_variants_and_skip_body_slice_into_buf", 56);
  PARSER_SAFE_EQ("parse_one_extern_skip_buf", 25);
  PARSER_SAFE_EQ("parse_one_extern_and_add_buf", 28);
  PARSER_SAFE_EQ("parse_one_function_library_from_buf", 35);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_from_buf", 34);
#undef PARSER_SAFE_EQ
  return 0;
}

typedef struct {
  const char *x_name;
  int32_t x_len;
  const char *c_name;
  int32_t c_len;
} wave120_thin_row_t;

static const wave120_thin_row_t k_wave120_parser_thin_delegate[] = {
    {"collect_imports_buf", 19, "parser_collect_imports_buf_glue", 31},
    {"advance_past_cond_rparen_into", 29, "parser_advance_past_cond_rparen_into_glue", 41},
    {"advance_past_stmt_semicolon_into", 32, "parser_advance_past_stmt_semicolon_into_glue", 44},
    {"alloc_pointee_type_ref_from_tok", 31, "parser_alloc_pointee_type_ref_from_tok_glue", 43},
    {"append_block_lets_from_res", 26, "parser_append_block_lets_from_res_glue", 38},
    {"body_skip_let_const_then_if_buf", 31, "parser_body_skip_let_const_then_if_buf_glue", 43},
    {"body_skip_let_const_then_if", 27, "parser_body_skip_let_const_then_if_glue", 39},
    {"body_skip_let_const_then_if_into", 32, "parser_body_skip_let_const_then_if_into_glue", 44},
    {"collect_imports", 15, "parser_collect_imports_glue", 27},
    {"copy_lex_from_import_into", 25, "parser_lex_copy_from_import_into_glue", 37},
    {"consume_qualified_type_ident_name", 33, "parser_consume_qualified_type_ident_name_glue", 45},
    {"diag_after_imports_then_structs", 31, "parser_diag_after_imports_then_structs_glue", 43},
    {"diag_fail_at_token_kind", 23, "parser_diag_fail_at_token_kind_glue", 35},
    {"diag_first_ident_len", 20, "parser_diag_first_ident_len_glue", 32},
    {"diag_lex_after_imports", 22, "parser_diag_lex_after_imports_glue", 34},
    {"diag_skip_let_const_buf", 23, "parser_diag_skip_let_const_buf_glue", 35},
    {"diag_skip_let_const", 19, "parser_diag_skip_let_const_glue", 31},
    {"diag_skip_let_const_into", 24, "parser_diag_skip_let_const_into_glue", 36},
    {"expr_set_common_zeros", 21, "parser_expr_set_common_zeros_glue", 33},
    {"fill_block_const_let_from_res", 29, "parser_fill_block_const_let_from_res_glue", 41},
    {"finish_struct_lit_from_type_ident_into", 38, "parser_finish_struct_lit_from_type_ident_into_glue", 50},
    {"first_token_kind", 16, "parser_first_token_kind_glue", 28},
    {"lex_at_token_from_result", 24, "parser_lex_at_token_from_result_glue", 36},
    {"lex_from_library", 16, "parser_lex_from_library_glue", 28},
    {"lex_from_library_into", 21, "parser_lex_from_library_into_glue", 33},
    {"lex_from_onefunc_next_into", 26, "parser_lex_from_onefunc_next_into_glue", 38},
    {"lex_from_next_into", 18, "parser_lex_from_next_into_glue", 30},
    {"lex_from_result_ptr_into", 24, "parser_lex_from_result_ptr_into_glue", 36},
    {"lex_from_try_skip", 17, "parser_lex_from_try_skip_glue", 29},
    {"lex_from_try_skip_into", 22, "parser_lex_from_try_skip_into_glue", 34},
    {"module_append_enum_variants_and_skip_body_into", 46, "parser_module_append_enum_variants_and_skip_body_into_glue", 58},
    {"parse_addsub_into", 17, "parser_parse_addsub_into_glue", 29},
    {"parse_as_suffix_into", 20, "parser_parse_as_suffix_into_glue", 32},
    {"parse_assign_into", 17, "parser_parse_assign_into_glue", 29},
    {"parse_at_simd_builtin_into", 26, "parser_parse_at_simd_builtin_into_glue", 38},
    {"parse_bitand_into", 17, "parser_parse_bitand_into_glue", 29},
    {"parse_bitor_into", 16, "parser_parse_bitor_into_glue", 28},
    {"parse_bitxor_into", 17, "parser_parse_bitxor_into_glue", 29},
    {"parse_body_let_bracket_compound_init_ref", 40, "parser_parse_body_let_bracket_compound_init_ref_glue", 52},
    {"parse_cast_into", 15, "parser_parse_cast_into_glue", 27},
    {"parse_compare_into", 18, "parser_parse_compare_into_glue", 30},
    {"parse_cond_expr_into", 20, "parser_parse_cond_expr_into_glue", 32},
    {"parse_if_expr_into", 18, "parser_parse_if_expr_into_glue", 30},
    {"parse_if_stmt_into", 18, "parser_parse_if_stmt_into_glue", 30},
    {"parse_into_try_skip_allow_buf", 29, "parser_parse_into_try_skip_allow_buf_glue", 41},
    {"parse_into_try_skip_allow", 25, "parser_parse_into_try_skip_allow_glue", 37},
    {"parse_into_try_skip_allow_into_buf", 34, "parser_parse_into_try_skip_allow_into_buf_glue", 46},
    {"parse_into_try_skip_allow_into", 30, "parser_parse_into_try_skip_allow_into_glue", 42},
    {"parse_into_set_main_index", 25, "parser_parse_into_set_main_index_glue", 37},
    {"parse_logand_into", 17, "parser_parse_logand_into_glue", 29},
    {"parse_logor_into", 16, "parser_parse_logor_into_glue", 28},
    {"parse_match_into", 16, "parser_parse_match_into_glue", 28},
    {"parse_match_subject_into", 24, "parser_parse_match_subject_into_glue", 36},
    {"parse_one_extern_and_add_into_buf", 33, "parser_parse_one_extern_and_add_into_buf_glue", 45},
    {"parse_one_extern_and_add_into", 29, "parser_parse_one_extern_and_add_into_glue", 41},
    {"parse_one_extern_skip_into", 26, "parser_parse_one_extern_skip_into_glue", 38},
    {"parse_one_function_buf_into", 27, "parser_parse_one_function_buf_into_glue", 39},
    {"parse_one_function_library", 26, "parser_parse_one_function_library_glue", 38},
    {"parse_one_function_library_into", 31, "parser_parse_one_function_library_into_glue", 43},
    {"parse_one_function_library_scan", 31, "parser_parse_one_function_library_scan_glue", 43},
    {"parse_one_top_level_let_into", 28, "parser_parse_one_top_level_let_into_glue", 40},
    {"parse_primary_into", 18, "parser_parse_primary_into_glue", 30},
    {"parse_relcompare_into", 21, "parser_parse_relcompare_into_glue", 33},
    {"parse_shift_into", 16, "parser_parse_shift_into_glue", 28},
    {"parse_struct_record_layout_into", 31, "parser_parse_struct_record_layout_into_glue", 43},
    {"parse_term_into", 15, "parser_parse_term_into_glue", 27},
    {"parse_ternary_into", 18, "parser_parse_ternary_into_glue", 30},
    {"parse_type_ref_for_arena_into", 29, "parser_parse_type_ref_for_arena_into_glue", 41},
    {"parse_unary_into", 16, "parser_parse_unary_into_glue", 28},
    {"parser_rewind_lex_for_following_stmt", 36, "parser_parser_rewind_lex_for_following_stmt_glue", 48},
    {"parser_vector_type_ref_from_ident_spelling", 42, "parser_parser_vector_type_ref_from_ident_spelling_glue", 54},
    {"skip_balanced_braces_buf", 24, "parser_skip_balanced_braces_buf_glue", 36},
    {"skip_balanced_braces", 20, "parser_skip_balanced_braces_glue", 32},
    {"skip_balanced_braces_into", 25, "parser_skip_balanced_braces_into_glue", 37},
    {"skip_balanced_parens_buf", 24, "parser_skip_balanced_parens_buf_glue", 36},
    {"skip_balanced_parens", 20, "parser_skip_balanced_parens_glue", 32},
    {"skip_balanced_parens_into", 25, "parser_skip_balanced_parens_into_glue", 37},
    {"skip_imports", 12, "parser_skip_imports_glue", 24},
    {"skip_one_enum_buf", 17, "parser_skip_one_enum_buf_glue", 29},
    {"skip_one_enum", 13, "parser_skip_one_enum_glue", 25},
    {"skip_one_enum_into", 18, "parser_skip_one_enum_into_glue", 30},
    {"skip_one_enum_into_buf", 22, "parser_skip_one_enum_into_buf_glue", 34},
    {"skip_one_enum_register_into_buf", 31, "parser_skip_one_enum_register_into_buf_glue", 43},
    {"skip_one_enum_register_into", 27, "parser_skip_one_enum_register_into_glue", 39},
    {"skip_one_extern_buf", 19, "parser_skip_one_extern_buf_glue", 31},
    {"skip_one_extern", 15, "parser_skip_one_extern_glue", 27},
    {"skip_one_extern_into_buf", 24, "parser_skip_one_extern_into_buf_glue", 36},
    {"skip_one_extern_into", 20, "parser_skip_one_extern_into_glue", 32},
    {"skip_one_function_full_buf", 26, "parser_skip_one_function_full_buf_glue", 38},
    {"skip_one_function_full", 22, "parser_skip_one_function_full_glue", 34},
    {"skip_one_function_full_into_buf", 31, "parser_skip_one_function_full_into_buf_glue", 43},
    {"skip_one_function_full_into", 27, "parser_skip_one_function_full_into_glue", 39},
    {"skip_one_if_core_buf", 20, "parser_skip_one_if_core_buf_glue", 32},
    {"skip_one_if_core", 16, "parser_skip_one_if_core_glue", 28},
    {"skip_one_if_core_into", 21, "parser_skip_one_if_core_into_glue", 33},
    {"skip_one_if_statement_buf", 25, "parser_skip_one_if_statement_buf_glue", 37},
    {"skip_one_if_statement", 21, "parser_skip_one_if_statement_glue", 33},
    {"skip_one_if_statement_into", 26, "parser_skip_one_if_statement_into_glue", 38},
    {"skip_one_impl_buf", 17, "parser_skip_one_impl_buf_glue", 29},
    {"skip_one_impl", 13, "parser_skip_one_impl_glue", 25},
    {"skip_one_impl_into_buf", 22, "parser_skip_one_impl_into_buf_glue", 34},
    {"skip_one_impl_into", 18, "parser_skip_one_impl_into_glue", 30},
    {"skip_one_struct_buf", 19, "parser_skip_one_struct_buf_glue", 31},
    {"skip_one_struct", 15, "parser_skip_one_struct_glue", 27},
    {"skip_one_struct_into_buf", 24, "parser_skip_one_struct_into_buf_glue", 36},
    {"skip_one_struct_into", 20, "parser_skip_one_struct_into_glue", 32},
    {"skip_one_trait_buf", 18, "parser_skip_one_trait_buf_glue", 30},
    {"skip_one_trait", 14, "parser_skip_one_trait_glue", 26},
    {"skip_one_trait_into_buf", 23, "parser_skip_one_trait_into_buf_glue", 35},
    {"skip_one_trait_into", 19, "parser_skip_one_trait_into_glue", 31},
    {"struct_field_name_from_tok", 26, "parser_struct_field_name_from_tok_glue", 38},
    {"parser_token_is_label_start", 27, "parser_token_is_label_start_glue", 32},
    {"parser_should_wrap_func_tail_in_return", 38, "parser_should_wrap_func_tail_in_return_glue", 43},
    {"pipeline_module_reset_parse_counters", 36, "pipeline_module_reset_parse_counters_c", 38},
    {"try_skip_allow_padding_struct_buf", 33, "parser_try_skip_allow_padding_struct_buf_glue", 45},
    {"try_skip_allow_padding_struct", 29, "parser_try_skip_allow_padding_struct_glue", 41},
};

int32_t asm_parser_func_is_thin_delegate(void *m, int32_t func_index) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
  nrows = (int32_t)(sizeof(k_wave120_parser_thin_delegate) / sizeof(k_wave120_parser_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)k_wave120_parser_thin_delegate[i].x_name,
                                           k_wave120_parser_thin_delegate[i].x_len))
      return 1;
  }
  return 0;
}

int32_t asm_parser_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  nrows = (int32_t)(sizeof(k_wave120_parser_thin_delegate) / sizeof(k_wave120_parser_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (const uint8_t *)k_wave120_parser_thin_delegate[i].x_name,
                                           k_wave120_parser_thin_delegate[i].x_len)) {
      if (k_wave120_parser_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_wave120_parser_thin_delegate[i].c_name, (size_t)k_wave120_parser_thin_delegate[i].c_len);
      out[k_wave120_parser_thin_delegate[i].c_len] = 0;
      *out_len = k_wave120_parser_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

int32_t asm_parser_emit_heavy_resolve_call_to_glue(void *m, uint8_t *name, int32_t name_len,
                                                    uint8_t *out, int32_t out_cap, int32_t *out_len) {
  int32_t fi;
  int32_t nf;
  if (!m || !name || name_len <= 0 || !out || !out_len || out_cap <= 0)
    return 0;
  *out_len = 0;
  if (!asm_module_is_parser_emit_heavy(m))
    return 0;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, name, name_len) == 0)
      continue;
    if (asm_parser_m8_tail_thin_delegate_c_name(m, fi, out, out_cap, out_len) != 0)
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (const uint8_t *)"pipeline_module_reset_parse_counters", 36)) {
      const char *c = "pipeline_module_reset_parse_counters_c";
      int32_t n = 38;
      if (n >= out_cap)
        return 0;
      memcpy(out, c, (size_t)n);
      out[n] = 0;
      *out_len = n;
      return 1;
    }
    return 0;
  }
  return 0;
}

int32_t asm_parser_emit_heavy_callee_is_same_module_local(void *m, uint8_t *name, int32_t name_len) {
  int32_t fi;
  int32_t nf;
  if (!m || !name || name_len <= 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, name, name_len) == 0)
      continue;
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0)
      return 0;
    return 1;
  }
  return 0;
}



/* wave121 cold twins: lint_meta pure leave (void* Module / ASTArena).
 * G.7 sole cold provider under #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X.
 * PLATFORM: SHARED. */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

struct ast_Module;
struct ast_ASTArena;
struct ast_Func;
struct ast_Expr;

/* Module header field access via C struct when available from including TU.
 * Cold twin uses same layout as product Module (LP64 i32 header). */
typedef struct wave121_ModuleHdr {
  int32_t num_funcs;
  int32_t main_func_index;
  int32_t num_imports;
  int32_t num_top_level_lets;
  int32_t num_struct_layouts;
  int32_t pending_allow_padding;
  int32_t pending_soa_struct;
  int32_t pending_cfg_skip;
  int32_t pending_repr_c_struct;
  int32_t pending_repr_compatible_struct;
  int32_t pending_used;
  int32_t pending_naked;
  int32_t pending_entry;
  int32_t pending_no_mangle;
  int32_t pending_interrupt;
  int32_t pending_export;
  int32_t num_module_enums;
} wave121_ModuleHdr;

typedef struct wave121_ArenaHdr {
  int32_t num_types;
  int32_t num_exprs;
} wave121_ArenaHdr;

extern const char *link_abi_getenv(const char *name);
extern int32_t pipeline_module_func_is_export_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_name_len_at(void *m, int32_t fi);
extern void pipeline_module_func_name_copy64(void *m, int32_t fi, uint8_t *dst);
extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t fi, const uint8_t *name, int32_t name_len);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_is_used_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_is_no_mangle_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_is_entry_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_is_interrupt_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_body_ref_at(void *m, int32_t fi);
extern int32_t pipeline_module_func_body_expr_ref_at(void *m, int32_t fi);
extern int32_t pipeline_expr_kind_ord_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_callee_ref_at(void *a, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(void *a, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *a, int32_t expr_ref, uint8_t *out64);
extern int32_t pipeline_expr_method_call_name_len(void *a, int32_t expr_ref);
extern void pipeline_expr_method_call_name_into(void *a, int32_t expr_ref, uint8_t *out64);
extern int32_t driver_check_only_get(void);
extern int32_t lsp_diag_get_enabled(void);
extern void lsp_diag_add_code(int line, int col, int severity, const char *code, const char *msg);
extern void diag_report(const char *path, int line, int col, const char *kind, const char *msg, const char *code);
extern void ast_ast_arena_init(void *arena);
extern void ast_pool_module_reset(void *module);
extern void ast_pool_arena_reset(void *arena);
extern void parser_onefunc_result_layout_prime(void);
extern void parser_onefunc_result_layout_prime_b(void);
extern void parser_onefunc_result_layout_prime_c(void);
extern void parser_onefunc_result_layout_prime_d(void);
extern void parser_onefunc_result_layout_prime_d_b(void);
extern void parser_onefunc_result_layout_prime_e(void);
extern void parser_onefunc_result_layout_prime_f(void);
extern void pipeline_parser_set_match_module(void *module);

static int wave121_vis_cached = -1;
static const uint8_t *wave121_l7_source = NULL;
static int32_t wave121_l7_source_len = 0;

int32_t pipeline_module_num_funcs(void *m) {
  wave121_ModuleHdr *h = (wave121_ModuleHdr *)m;
  return h ? h->num_funcs : 0;
}

int32_t pipeline_module_main_func_index(void *m) {
  wave121_ModuleHdr *h = (wave121_ModuleHdr *)m;
  return h ? h->main_func_index : -1;
}

void pipeline_module_set_main_func_index(void *m, int32_t idx) {
  wave121_ModuleHdr *h = (wave121_ModuleHdr *)m;
  if (h)
    h->main_func_index = idx;
}

void pipeline_module_reset_parse_counters_c(void *module) {
  wave121_ModuleHdr *h = (wave121_ModuleHdr *)module;
  if (!h)
    return;
  h->num_funcs = 0;
  h->main_func_index = -1;
  h->num_imports = 0;
  h->num_top_level_lets = 0;
  h->num_struct_layouts = 0;
  h->num_module_enums = 0;
}

void pipeline_lint_set_source_buf(const uint8_t *data, int32_t len) {
  wave121_l7_source = data;
  wave121_l7_source_len = (data && len > 0) ? len : 0;
}

int32_t pipeline_visibility_mode(void) {
  const char *e;
  if (wave121_vis_cached >= 0)
    return wave121_vis_cached;
  e = link_abi_getenv("XLANG_VISIBILITY");
  if (!e || !e[0] || strcmp(e, "strict") == 0)
    wave121_vis_cached = 0;
  else if (strcmp(e, "warn") == 0)
    wave121_vis_cached = 1;
  else if (strcmp(e, "compat") == 0)
    wave121_vis_cached = 0;
  else
    wave121_vis_cached = 2;
  return wave121_vis_cached;
}

int32_t pipeline_visibility_allow_func(void *m, int32_t fi, int32_t cross_module) {
  int32_t mode;
  uint8_t name[128];
  int32_t nlen;
  if (!cross_module)
    return 1;
  mode = pipeline_visibility_mode();
  if (mode == 0)
    return 1;
  if (pipeline_module_func_is_export_at(m, fi) != 0)
    return 1;
  nlen = pipeline_module_func_name_len_at(m, fi);
  if (nlen == 4) {
    pipeline_module_func_name_copy64(m, fi, name);
    if (name[0] == 'm' && name[1] == 'a' && name[2] == 'i' && name[3] == 'n')
      return 1;
  }
  if (mode == 1) {
    pipeline_module_func_name_copy64(m, fi, name);
    nlen = pipeline_module_func_name_len_at(m, fi);
    if (nlen < 0)
      nlen = 0;
    if (nlen > 127)
      nlen = 127;
    fprintf(stderr, "warning: '%.*s' is not exported (XLANG_VISIBILITY=warn); "
                    "add `export` or it will error under strict\n",
            (int)nlen, (const char *)name);
    return 1;
  }
  return 0;
}

static int wave121_unused_private_enabled(void) {
  const char *e = link_abi_getenv("XLANG_UNUSED_PRIVATE");
  if (e && e[0]) {
    if (e[0] == '0' && e[1] == '\0')
      return 0;
    return 1;
  }
  if (driver_check_only_get() != 0)
    return 1;
  if (lsp_diag_get_enabled() != 0)
    return 1;
  return 0;
}

static int wave121_l7_find_func_def(const uint8_t *source, int32_t sl, const uint8_t *name, int32_t name_len,
                                   int *out_line, int *out_col) {
  static const uint8_t kw[] = {'f', 'u', 'n', 'c', 't', 'i', 'o', 'n', ' '};
  int32_t i;
  int line = 1;
  int col = 1;
  if (!source || !name || name_len <= 0 || sl <= 0 || !out_line || !out_col)
    return 0;
  for (i = 0; i < sl; i++) {
    int boundary = (i == 0);
    if (!boundary) {
      uint8_t prev = source[i - 1];
      if (prev == ' ' || prev == '\t' || prev == '\n' || prev == '\r')
        boundary = 1;
    }
    if (boundary && i + 9 + name_len <= sl) {
      int ki;
      int kw_ok = 1;
      for (ki = 0; ki < 9; ki++) {
        if (source[i + ki] != kw[ki]) {
          kw_ok = 0;
          break;
        }
      }
      if (kw_ok) {
        int ni;
        int name_ok = 1;
        for (ni = 0; ni < name_len; ni++) {
          if (source[i + 9 + ni] != name[ni]) {
            name_ok = 0;
            break;
          }
        }
        if (name_ok) {
          int32_t after = i + 9 + name_len;
          uint8_t ac = (after < sl) ? source[after] : (uint8_t)' ';
          if (after >= sl || ac == ' ' || ac == '(' || ac == '\n' || ac == '\t' || ac == '<' || ac == '\r') {
            *out_line = line;
            *out_col = col + 9;
            return 1;
          }
        }
      }
    }
    if (source[i] == '\n') {
      line++;
      col = 1;
    } else {
      col++;
    }
  }
  return 0;
}

static void wave121_report_unused_private(const uint8_t *name, int32_t nlen) {
  char msg[192];
  int nl = (nlen > 0) ? (int)nlen : 0;
  int line = 1;
  int col = 1;
  if (nl > 127)
    nl = 63;
  snprintf(msg, sizeof msg, "unused private function '%.*s' (not export, not reachable in module)",
           nl, (const char *)(name ? name : (const uint8_t *)""));
  if (wave121_l7_source && wave121_l7_source_len > 0 && name && nlen > 0)
    (void)wave121_l7_find_func_def(wave121_l7_source, wave121_l7_source_len, name, nlen, &line, &col);
  if (lsp_diag_get_enabled()) {
    lsp_diag_add_code(line, col, 2, "L7", msg);
  } else {
    diag_report(NULL, line, col, "warning", msg, "L7");
  }
}

static void wave121_mark_local_call_names(void *a, uint8_t *used_flags, int32_t nfuncs, void *m) {
  int32_t er;
  int32_t nexpr;
  int32_t fi;
  if (!a || !used_flags || !m || nfuncs <= 0)
    return;
  nexpr = ((wave121_ArenaHdr *)a)->num_exprs;
  for (er = 1; er <= nexpr; er++) {
    int32_t ko = pipeline_expr_kind_ord_at(a, er);
    if (ko == 48) { /* EXPR_CALL */
      int32_t callee_ref = pipeline_expr_call_callee_ref_at(a, er);
      int32_t clen;
      uint8_t cname[128];
      if (callee_ref <= 0)
        continue;
      if (pipeline_expr_kind_ord_at(a, callee_ref) != 3)
        continue;
      clen = pipeline_expr_var_name_len(a, callee_ref);
      if (clen <= 0)
        continue;
      pipeline_expr_var_name_into(a, callee_ref, cname);
      for (fi = 0; fi < nfuncs; fi++) {
        if (pipeline_module_func_name_equal_at(m, fi, cname, clen))
          used_flags[fi] = 1;
      }
    } else if (ko == 49) { /* EXPR_METHOD_CALL */
      int32_t mlen = pipeline_expr_method_call_name_len(a, er);
      uint8_t mname[128];
      if (mlen <= 0)
        continue;
      pipeline_expr_method_call_name_into(a, er, mname);
      for (fi = 0; fi < nfuncs; fi++) {
        if (pipeline_module_func_name_equal_at(m, fi, mname, mlen))
          used_flags[fi] = 1;
      }
    }
  }
}

int32_t pipeline_typeck_unused_private_funcs(void *m, void *a) {
  int32_t nfuncs;
  int32_t fi;
  int32_t nwarn = 0;
  uint8_t *used = NULL;
  uint8_t name[128];
  int32_t nlen;
  if (!m || !a)
    return 0;
  if (!wave121_unused_private_enabled())
    return 0;
  nfuncs = pipeline_module_num_funcs(m);
  if (nfuncs <= 0)
    return 0;
  used = (uint8_t *)calloc((size_t)nfuncs, 1);
  if (!used)
    return 0;
  wave121_mark_local_call_names(a, used, nfuncs, m);
  for (fi = 0; fi < nfuncs; fi++) {
    if (pipeline_module_func_is_export_at(m, fi) != 0)
      continue;
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0)
      continue;
    if (pipeline_module_func_is_used_at(m, fi) != 0 ||
        pipeline_module_func_is_no_mangle_at(m, fi) != 0 ||
        pipeline_module_func_is_entry_at(m, fi) != 0 ||
        pipeline_module_func_is_interrupt_at(m, fi) != 0)
      continue;
    nlen = pipeline_module_func_name_len_at(m, fi);
    if (nlen == 4) {
      pipeline_module_func_name_copy64(m, fi, name);
      if (name[0] == 'm' && name[1] == 'a' && name[2] == 'i' && name[3] == 'n')
        continue;
    }
    if (nlen <= 0)
      continue;
    if (pipeline_module_func_body_ref_at(m, fi) <= 0 &&
        pipeline_module_func_body_expr_ref_at(m, fi) <= 0)
      continue;
    if (used[fi] != 0)
      continue;
    pipeline_module_func_name_copy64(m, fi, name);
    wave121_report_unused_private(name, nlen);
    nwarn++;
  }
  free(used);
  return nwarn;
}

void pipeline_strict_parse_into_init(void *arena, void *module) {
  wave121_ModuleHdr *h = (wave121_ModuleHdr *)module;
  ast_ast_arena_init(arena);
  ast_pool_module_reset(module);
  ast_pool_arena_reset(arena);
  parser_onefunc_result_layout_prime();
  parser_onefunc_result_layout_prime_b();
  parser_onefunc_result_layout_prime_c();
  parser_onefunc_result_layout_prime_d();
  parser_onefunc_result_layout_prime_d_b();
  parser_onefunc_result_layout_prime_e();
  parser_onefunc_result_layout_prime_f();
  pipeline_module_reset_parse_counters_c(module);
  pipeline_parser_set_match_module(module);
  if (h) {
    h->num_funcs = 0;
    h->main_func_index = -1;
    h->num_imports = 0;
    h->num_top_level_lets = 0;
    h->num_struct_layouts = 0;
    h->pending_allow_padding = 0;
    h->pending_soa_struct = 0;
    h->pending_cfg_skip = 0;
    h->pending_repr_c_struct = 0;
    h->pending_repr_compatible_struct = 0;
    h->num_module_enums = 0;
  }
}



#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave122: pipeline_asm_emit_with_arena pure leave cold twins under #ifndef FROM_X.
 * PLATFORM: SHARED — PREFER pure; cold path when PREFER!=1 / hybrid fail. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/* wave122 cold: with_arena scope BSS (fixed cap 16). */
static int32_t wave122_wa_scope_off_stack[16];
static int32_t wave122_wa_scope_n;
static int32_t wave122_wa_temp_base;
static int32_t wave122_wa_temp_next;
static int32_t wave122_wa_func_body_ref;

/* Cap residual faces used by pure leave (also available on host-cc product). */
extern int32_t asm_sum_block_array_temp_bytes(void *arena, int32_t block_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_call_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta);

int32_t glue_with_arena_scope_active_c(void) {
  return wave122_wa_scope_n > 0 ? 1 : 0;
}

int32_t glue_with_arena_scope_top_off_c(void) {
  return wave122_wa_scope_n > 0 ? wave122_wa_scope_off_stack[wave122_wa_scope_n - 1] : 0;
}

void glue_wa_emit_begin_func_c(void *ctx, void *arena, int32_t body_ref) {
  int32_t next_off;
  int32_t arr_temp;
  wave122_wa_scope_n = 0;
  wave122_wa_temp_next = 0;
  wave122_wa_func_body_ref = body_ref;
  if (!ctx)
    return;
  /* AsmFuncCtx.next_offset @4 (LP64). */
  next_off = (int32_t)((uint8_t *)ctx)[4]
           | ((int32_t)((uint8_t *)ctx)[5] << 8)
           | ((int32_t)((uint8_t *)ctx)[6] << 16)
           | ((int32_t)((uint8_t *)ctx)[7] << 24);
  arr_temp = arena ? asm_sum_block_array_temp_bytes(arena, body_ref) : 0;
  wave122_wa_temp_base = next_off + arr_temp + 24;
}

int32_t glue_wa_scope_alloc_off_c(void *ctx) {
  int32_t off = wave122_wa_temp_base + wave122_wa_temp_next;
  int32_t end;
  int32_t cur;
  uint8_t *b;
  wave122_wa_temp_next += 24;
  if (wave122_wa_temp_next % 8 != 0)
    wave122_wa_temp_next += 8 - (wave122_wa_temp_next % 8);
  if (ctx) {
    end = off + 24;
    if (end % 8 != 0)
      end += 8 - (end % 8);
    b = (uint8_t *)ctx;
    cur = (int32_t)b[4] | ((int32_t)b[5] << 8) | ((int32_t)b[6] << 16) | ((int32_t)b[7] << 24);
    if (end > cur) {
      b[4] = (uint8_t)(end & 255);
      b[5] = (uint8_t)((end >> 8) & 255);
      b[6] = (uint8_t)((end >> 16) & 255);
      b[7] = (uint8_t)((end >> 24) & 255);
    }
  }
  return off;
}

void glue_wa_scope_push_c(int32_t wa_off) {
  if (wave122_wa_scope_n >= 16)
    return;
  wave122_wa_scope_off_stack[wave122_wa_scope_n++] = wa_off;
}

void glue_wa_scope_pop_c(void) {
  if (wave122_wa_scope_n > 0)
    wave122_wa_scope_n--;
}

int32_t glue_emit_with_arena_init_elf(void *arena, void *elf_ctx, void *ctx, int32_t wa_off, int32_t cap_ref,
                                     int32_t ta) {
  static const uint8_t init_sym[] = "heap_arena_init_c";
  /* PLATFORM: SHARED — arm64 rax==x0: emit cap → arg1 before lea → arg0
   * (historical residual lea-first clobbers arena on MACOS|ARM64). */
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, cap_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, wa_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, (uint8_t *)init_sym, (int32_t)(sizeof(init_sym) - 1), ta);
}

int32_t glue_emit_with_arena_deinit_elf(void *elf_ctx, int32_t wa_off, int32_t ta) {
  static const uint8_t deinit_sym[] = "heap_arena64_deinit_c";
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, wa_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, (uint8_t *)deinit_sym, (int32_t)(sizeof(deinit_sym) - 1), ta);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave123: pipeline_asm_emit_lea_common pure leave cold twins under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding emit · LINUX+MACOS x86_64 SysV · MACOS|ARM64 AAPCS64.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx, uint8_t *ptr, int32_t n);
extern int32_t pipeline_elf_ctx_emit_code_len(uint8_t *ctx);
extern int32_t pipeline_elf_ctx_append_reloc(uint8_t *ctx, int32_t at, uint8_t *name, int32_t name_len);
extern int32_t pipeline_elf_ctx_append_reloc_typed(uint8_t *ctx, int32_t at, uint8_t *name, int32_t name_len,
                                                   int32_t r_type, int32_t r_pcrel);

/* PLATFORM: LINUX+MACOS x86_64 SysV — lea rax, [rip+disp32] + R_X86_64_PC32. */
int32_t glue_asm_lea_rax_common_rip_x86(void *elf_ctx, uint8_t *name, int32_t name_len) {
  uint8_t lea7[7];
  int32_t rel32_at;
  if (!elf_ctx || !name || name_len <= 0)
    return -1;
  lea7[0] = 0x48;
  lea7[1] = 0x8d;
  lea7[2] = 0x05;
  lea7[3] = 0;
  lea7[4] = 0;
  lea7[5] = 0;
  lea7[6] = 0;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, lea7, 7) != 0)
    return -1;
  rel32_at = pipeline_elf_ctx_emit_code_len((uint8_t *)elf_ctx) - 4;
  return pipeline_elf_ctx_append_reloc((uint8_t *)elf_ctx, rel32_at, name, name_len);
}

/* PLATFORM: LINUX+MACOS x86_64 SysV — lea rbx, [rip+disp32] + R_X86_64_PC32. */
int32_t glue_asm_lea_rbx_common_rip_x86(void *elf_ctx, uint8_t *name, int32_t name_len) {
  uint8_t lea7[7];
  int32_t rel32_at;
  if (!elf_ctx || !name || name_len <= 0)
    return -1;
  lea7[0] = 0x48;
  lea7[1] = 0x8d;
  lea7[2] = 0x1d;
  lea7[3] = 0;
  lea7[4] = 0;
  lea7[5] = 0;
  lea7[6] = 0;
  if (pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, lea7, 7) != 0)
    return -1;
  rel32_at = pipeline_elf_ctx_emit_code_len((uint8_t *)elf_ctx) - 4;
  return pipeline_elf_ctx_append_reloc((uint8_t *)elf_ctx, rel32_at, name, name_len);
}

/* PLATFORM: MACOS|ARM64 AAPCS64 — mov x8, x0 (ORR X8, XZR, X0). */
int32_t glue_arm64_mov_x0_to_x8_elf_c(void *elf_ctx) {
  uint8_t insn[4];
  if (!elf_ctx)
    return -1;
  insn[0] = 0xe8;
  insn[1] = 0x03;
  insn[2] = 0x00;
  insn[3] = 0xaa;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, insn, 4);
}

/* PLATFORM: MACOS|ARM64 AAPCS64 — mov x0, x8 (ORR X0, XZR, X8). */
int32_t glue_arm64_mov_x8_to_x0_elf_c(void *elf_ctx) {
  uint8_t insn[4];
  if (!elf_ctx)
    return -1;
  insn[0] = 0xe0;
  insn[1] = 0x03;
  insn[2] = 0x08;
  insn[3] = 0xaa;
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, insn, 4);
}

/* PLATFORM: MACOS|ARM64 — adrp x1 + add pageoff → COMMON in x1 (rbx).
 * r_type 3 = PAGE_HI21 pcrel=1; 4 = LO12_NC pcrel=0. */
int32_t glue_asm_lea_rbx_common_adrp_arm64(void *elf_ctx, uint8_t *name, int32_t name_len) {
  uint8_t *cb;
  uint8_t adrp4[4];
  uint8_t add4[4];
  int32_t adrp_at;
  int32_t add_at;
  if (!elf_ctx || !name || name_len <= 0)
    return -1;
  cb = (uint8_t *)elf_ctx;
  adrp4[0] = 0x01;
  adrp4[1] = 0x00;
  adrp4[2] = 0x00;
  adrp4[3] = 0x90;
  if (pipeline_elf_ctx_append_bytes(cb, adrp4, 4) != 0)
    return -1;
  adrp_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  if (pipeline_elf_ctx_append_reloc_typed(cb, adrp_at, name, name_len, 3, 1) != 0)
    return -1;
  add4[0] = 0x21;
  add4[1] = 0x00;
  add4[2] = 0x00;
  add4[3] = 0x91;
  if (pipeline_elf_ctx_append_bytes(cb, add4, 4) != 0)
    return -1;
  add_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  return pipeline_elf_ctx_append_reloc_typed(cb, add_at, name, name_len, 4, 0);
}

/* PLATFORM: MACOS|ARM64 — adrp x0 + add pageoff → COMMON in x0 (rax). */
int32_t glue_asm_lea_rax_common_adrp_arm64(void *elf_ctx, uint8_t *name, int32_t name_len) {
  uint8_t *cb;
  uint8_t adrp4[4];
  uint8_t add4[4];
  int32_t adrp_at;
  int32_t add_at;
  if (!elf_ctx || !name || name_len <= 0)
    return -1;
  cb = (uint8_t *)elf_ctx;
  adrp4[0] = 0x00;
  adrp4[1] = 0x00;
  adrp4[2] = 0x00;
  adrp4[3] = 0x90;
  if (pipeline_elf_ctx_append_bytes(cb, adrp4, 4) != 0)
    return -1;
  adrp_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  if (pipeline_elf_ctx_append_reloc_typed(cb, adrp_at, name, name_len, 3, 1) != 0)
    return -1;
  add4[0] = 0x00;
  add4[1] = 0x00;
  add4[2] = 0x00;
  add4[3] = 0x91;
  if (pipeline_elf_ctx_append_bytes(cb, add4, 4) != 0)
    return -1;
  add_at = pipeline_elf_ctx_emit_code_len(cb) - 4;
  return pipeline_elf_ctx_append_reloc_typed(cb, add_at, name, name_len, 4, 0);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave124: pipeline_asm_emit_var_decl pure leave cold twins under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding emit · Cap residual emit context + local/slot helpers.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern int32_t asm_ctx_scope_block_ref_at(uint8_t *ctx);
extern int32_t pipeline_block_resolve_var_type_ref(void *arena, int32_t block_ref, uint8_t *vname, int32_t vlen);
extern int32_t pipeline_module_func_param_type_ref_for_name(void *module, int32_t func_index, uint8_t *var_name,
                                                           int32_t name_len);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t pipeline_asm_emit_func_index_c(void);
extern int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t name_len);
extern int32_t asm_ctx_block_slot_get(uint8_t *ctx, int32_t block_ref);
extern int32_t pipeline_block_let_type_ref(void *arena, int32_t block_ref, int32_t let_idx);
extern int32_t asm_local_slot_reg_offset(void *arena, int32_t type_ref, int32_t off, int32_t *inout_off);
extern int32_t asm_ctx_local_append(uint8_t *ctx, uint8_t *name, int32_t name_len, int32_t offset);
extern int32_t asm_ctx_local_count(uint8_t *ctx);

/* GLUE_EXPR_KIND_VAR == 3 */
int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t var_expr_ref) {
  uint8_t vname[128];
  int32_t vlen;
  int32_t scope_br;
  int32_t tr;
  void *mod;
  int32_t fi;
  if (!arena || !ctx || var_expr_ref <= 0 || pipeline_expr_kind_ord_at(arena, var_expr_ref) != 3)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  if (vlen <= 0 || vlen > 127)
    return 0;
  pipeline_expr_var_name_into(arena, var_expr_ref, vname);
  scope_br = asm_ctx_scope_block_ref_at((uint8_t *)ctx);
  if (scope_br > 0) {
    tr = pipeline_block_resolve_var_type_ref(arena, scope_br, vname, vlen);
    if (tr > 0)
      return tr;
  }
  mod = pipeline_asm_emit_module_ref_c();
  fi = pipeline_asm_emit_func_index_c();
  if (mod && fi >= 0) {
    tr = pipeline_module_func_param_type_ref_for_name(mod, fi, vname, vlen);
    if (tr > 0)
      return tr;
  }
  tr = pipeline_expr_resolved_type_ref(arena, var_expr_ref);
  if (tr > 0)
    return tr;
  return 0;
}

int32_t glue_lazy_append_block_let_local(void *arena, void *ctx, int32_t block_ref, int32_t let_idx, uint8_t *name,
                                         int32_t name_len) {
  int32_t tref;
  int32_t off;
  int32_t slot_off;
  int32_t *ly_next;
  int32_t *ly_num;
  if (!arena || !ctx || !name || name_len <= 0 || block_ref <= 0 || let_idx < 0)
    return -1;
  /* LP64: next_offset@4, num_locals@8 on AsmFuncCtx layout overlay */
  ly_next = (int32_t *)((uint8_t *)ctx + 4);
  ly_num = (int32_t *)((uint8_t *)ctx + 8);
  if (asm_ctx_local_find_offset((uint8_t *)ctx, name, name_len) >= 0)
    return 0;
  if (asm_ctx_block_slot_get((uint8_t *)ctx, block_ref) >= 0)
    return 0;
  tref = pipeline_block_let_type_ref(arena, block_ref, let_idx);
  off = *ly_next;
  slot_off = asm_local_slot_reg_offset(arena, tref, off, &off);
  *ly_next = off;
  if (asm_ctx_local_append((uint8_t *)ctx, name, name_len, slot_off) < 0)
    return -1;
  *ly_num = asm_ctx_local_count((uint8_t *)ctx);
  return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave125: pipeline_asm_ctx_layout pure leave cold twin under #ifndef FROM_X.
 * Identity cast: residual C reinterprets return as pipeline_glue_AsmFuncCtxLayout*.
 * PLATFORM: SHARED freestanding · PREFER pure; cold when PREFER!=1 / hybrid fail. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
void *pipeline_asm_ctx_layout(void *ctx) {
  return ctx;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave126: next_offset pure leave cold twins under #ifndef FROM_X.
 * LP64 next_offset@4; Cap residual glue_array_temp_bytes_for_let_init still residual.
 * PLATFORM: SHARED freestanding · PREFER pure; cold when PREFER!=1 / hybrid fail. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
extern int32_t glue_array_temp_bytes_for_let_init(void *arena, int32_t let_type_ref, int32_t init_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_block_let_type_ref(void *arena, int32_t block_ref, int32_t let_idx);

void glue_align_next_offset(void *ctx) {
  int32_t *ly_next;
  int32_t off;
  int32_t m;
  if (!ctx)
    return;
  ly_next = (int32_t *)((uint8_t *)ctx + 4);
  off = *ly_next;
  m = off % 8;
  if (m != 0)
    *ly_next = off + (8 - m);
}

void pipeline_asm_bump_next_offset_for_array_lit(void *arena, int32_t expr_ref, void *ctx) {
  int32_t bytes;
  int32_t *ly_next;
  if (!ctx || expr_ref <= 0)
    return;
  ly_next = (int32_t *)((uint8_t *)ctx + 4);
  bytes = glue_array_temp_bytes_for_let_init(arena, pipeline_expr_resolved_type_ref(arena, expr_ref), expr_ref);
  if (bytes <= 0)
    return;
  *ly_next = *ly_next + bytes;
  glue_align_next_offset(ctx);
}

void pipeline_asm_bump_next_offset_after_let_init(void *arena, int32_t block_ref, int32_t let_idx, int32_t init_ref,
                                                   void *ctx) {
  int32_t tref;
  int32_t bytes;
  int32_t *ly_next;
  if (!ctx)
    return;
  ly_next = (int32_t *)((uint8_t *)ctx + 4);
  /* EXPR_ARRAY_LIT (46) already bumped; STRUCT_LIT (45) writes stack slot. */
  if (init_ref > 0) {
    int32_t iko = pipeline_expr_kind_ord_at(arena, init_ref);
    if (iko == 46 || iko == 45)
      return;
  }
  tref = pipeline_block_let_type_ref(arena, block_ref, let_idx);
  bytes = glue_array_temp_bytes_for_let_init(arena, tref, init_ref);
  if (bytes <= 0)
    return;
  *ly_next = *ly_next + bytes;
  glue_align_next_offset(ctx);
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave127: panic pure leave cold twins under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding emit · Cap residual enc_* + emit_expr_elf_c + next_label.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_call_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta);
extern int32_t backend_enc_test_rbx_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_jne_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t pipeline_expr_unary_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);

int32_t pipeline_asm_emit_xlang_panic_call_elf_c(void *arena, void *elf_ctx, void *ctx, int32_t ta, int32_t code,
                                                 int32_t msg_ref) {
  static const uint8_t panic_nm[] = "xlang_panic_";
  if (msg_ref > 0) {
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, msg_ref, ctx, ta) != 0)
      return -1;
  } else if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0) {
    return -1;
  }
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, code, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, (uint8_t *)panic_nm, 14, ta);
}

int32_t pipeline_asm_emit_panic_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t op_ref;
  int32_t code;
  int32_t is_cstr;
  int32_t op_ty;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  op_ref = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op_ref <= 0) {
    code = 0;
  } else {
    is_cstr = 0;
    if (pipeline_expr_kind_ord_at(arena, op_ref) == 59) /* EXPR_STRING_LIT */ {
      is_cstr = 1;
    } else {
      op_ty = pipeline_expr_resolved_type_ref(arena, op_ref);
      if (op_ty > 0 && pipeline_type_kind_ord_at(arena, op_ty) == 9 /* TYPE_PTR */)
        is_cstr = 1;
    }
    code = is_cstr ? 2 : 1;
  }
  return pipeline_asm_emit_xlang_panic_call_elf_c(arena, elf_ctx, ctx, ta, code, op_ref);
}

int32_t pipeline_asm_emit_panic_int_div_zero_elf_c(void *elf_ctx, int32_t ta) {
  return pipeline_asm_emit_xlang_panic_call_elf_c(0, elf_ctx, 0, ta, 1, 0);
}

int32_t pipeline_asm_emit_divisor_zero_check_rbx_elf_c(void *elf_ctx, void *ctx, int32_t ta) {
  uint8_t ok_lbl[128];
  int32_t ok_len;
  ok_len = pipeline_asm_emit_next_label_c(ctx, ok_lbl, 64);
  if (ok_len <= 0)
    return -1;
  if (backend_enc_test_rbx_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jne_arch(elf_ctx, ok_lbl, ok_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_panic_int_div_zero_elf_c(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, ok_lbl, ok_len, 0, ta) != 0)
    return -1;
  return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave128: logand/logor pure leave cold twins under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding emit · Cap residual binop + enc_* + emit_expr_elf_c + next_label.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
extern int32_t pipeline_expr_binop_left_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t backend_enc_test_eax_eax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_jz_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_jnz_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_jmp_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);

int32_t pipeline_asm_emit_logand_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t left_ref;
  int32_t right_ref;
  uint8_t false_lbl[128];
  uint8_t end_lbl[128];
  int32_t false_len;
  int32_t end_len;
  left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -1;
  false_len = pipeline_asm_emit_next_label_c(ctx, false_lbl, 64);
  end_len = pipeline_asm_emit_next_label_c(ctx, end_lbl, 64);
  if (false_len <= 0 || end_len <= 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jz_arch(elf_ctx, false_lbl, false_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jz_arch(elf_ctx, false_lbl, false_len, ta) != 0)
    return -1;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_jmp_arch(elf_ctx, end_lbl, end_len, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, false_lbl, false_len, 0, ta) != 0)
    return -1;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, end_lbl, end_len, 0, ta) != 0)
    return -1;
  return 0;
}

int32_t pipeline_asm_emit_logor_elf_impl(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t left_ref;
  int32_t right_ref;
  uint8_t true_lbl[128];
  uint8_t end_lbl[128];
  int32_t true_len;
  int32_t end_len;
  left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  right_ref = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  if (left_ref <= 0 || right_ref <= 0)
    return -1;
  true_len = pipeline_asm_emit_next_label_c(ctx, true_lbl, 64);
  end_len = pipeline_asm_emit_next_label_c(ctx, end_lbl, 64);
  if (true_len <= 0 || end_len <= 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, left_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jnz_arch(elf_ctx, true_lbl, true_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, right_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jnz_arch(elf_ctx, true_lbl, true_len, ta) != 0)
    return -1;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (backend_enc_jmp_arch(elf_ctx, end_lbl, end_len, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, true_lbl, true_len, 0, ta) != 0)
    return -1;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, end_lbl, end_len, 0, ta) != 0)
    return -1;
  return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave129: block_if pure leave cold twins under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding emit · Cap residual block if refs + scope/jz/body +
 * live-end merge + ensure/fill locals + enc jmp/label + next_label + emit_expr_elf_c.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail. */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
extern int32_t ast_pipeline_block_if_cond_ref(void *arena, int32_t block_ref, int32_t if_idx);
extern int32_t ast_pipeline_block_if_then_body_ref(void *arena, int32_t block_ref, int32_t if_idx);
extern int32_t ast_pipeline_block_if_else_body_ref(void *arena, int32_t block_ref, int32_t if_idx);
extern void glue_asm_ctx_set_scope_block(void *ctx, int32_t block_ref);
extern int32_t glue_enc_jz_after_bool_in_eax(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern void backend_ensure_block_local_slots(void *ctx, void *arena, int32_t block_ref);
extern void pipeline_asm_fill_block_locals_tree(void *ctx, void *arena, int32_t block_ref);
extern int32_t pipeline_asm_emit_block_body_sync_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx, int32_t ta);
extern void glue_block_fill_live_end_for_merge(void *arena, void *ctx, int32_t block_ref, void *out_live);
extern int glue_block_stmt_order_has_return(void *arena, int32_t block_ref);
extern void glue_live_fwd_copy_from_snap_before_if(void *dst_live);
extern void glue_asm_cache_invalidate_at_cfg_merge_selective(void *arena, void *ctx, int32_t branch_a, int32_t branch_b);
extern void glue_asm_if_phi_invalidate_both_branch_defs(void *arena, void *ctx, int32_t then_ref, int32_t else_ref);
extern void glue_asm_if_merge_live_union_from_ends(void *arena, void *ctx, void *then_live, void *else_live);
extern void pipeline_asm_fill_local_slots(void *ctx, void *arena, int32_t block_ref);
extern int32_t backend_emit_block_body_sync_elf(void *arena, void *elf_ctx, int32_t block_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t backend_enc_jmp_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);
extern void *pipeline_asm_ctx_layout(void *ctx);

/* LP64 AsmFuncCtx: next_offset@4, num_locals@8 — match pure pipe_asm_ctx_off_*. */
static int32_t seed_pipe_load_i32_le(void *base, int32_t off) {
  const uint8_t *p = (const uint8_t *)base + off;
  return (int32_t)((uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24));
}
static void seed_pipe_store_i32_le(void *base, int32_t off, int32_t v) {
  uint8_t *p = (uint8_t *)base + off;
  p[0] = (uint8_t)(v & 0xff);
  p[1] = (uint8_t)((v >> 8) & 0xff);
  p[2] = (uint8_t)((v >> 16) & 0xff);
  p[3] = (uint8_t)((v >> 24) & 0xff);
}

int32_t pipeline_asm_emit_block_if_stmt_elf(void *arena, void *elf_ctx, int32_t cur_block, int32_t if_idx, void *ctx,
                                            int32_t ta, int32_t stmt_i) {
  int32_t cond_if;
  int32_t then_ref;
  int32_t else_ref;
  uint8_t else_lbl[128];
  uint8_t done_lbl[128];
  int32_t else_len;
  int32_t done_len;
  uint8_t then_live[136];
  uint8_t else_live[136];
  (void)stmt_i;
  if (!arena || !elf_ctx || !ctx || cur_block <= 0)
    return -1;
  glue_asm_ctx_set_scope_block(ctx, cur_block);
  cond_if = ast_pipeline_block_if_cond_ref(arena, cur_block, if_idx);
  then_ref = ast_pipeline_block_if_then_body_ref(arena, cur_block, if_idx);
  else_ref = ast_pipeline_block_if_else_body_ref(arena, cur_block, if_idx);
  if (cond_if == 0 || then_ref == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, cond_if, ctx, ta) != 0)
    return -1;
  else_len = pipeline_asm_emit_next_label_c(ctx, else_lbl, 64);
  done_len = pipeline_asm_emit_next_label_c(ctx, done_lbl, 64);
  if (else_len <= 0 || done_len <= 0)
    return -1;
  if (else_ref != 0) {
    if (glue_enc_jz_after_bool_in_eax(elf_ctx, else_lbl, else_len, ta) != 0)
      return -1;
  } else {
    if (glue_enc_jz_after_bool_in_eax(elf_ctx, done_lbl, done_len, ta) != 0)
      return -1;
  }
  backend_ensure_block_local_slots(ctx, arena, then_ref);
  pipeline_asm_fill_block_locals_tree(ctx, arena, then_ref);
  glue_asm_ctx_set_scope_block(ctx, then_ref);
  if (pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, then_ref, ctx, ta) != 0)
    return -1;
  glue_block_fill_live_end_for_merge(arena, ctx, then_ref, then_live);
  if (!glue_block_stmt_order_has_return(arena, then_ref)) {
    if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0)
      return -1;
  }
  if (else_ref != 0) {
    if (backend_enc_label_arch(elf_ctx, else_lbl, else_len, 0, ta) != 0)
      return -1;
    backend_ensure_block_local_slots(ctx, arena, else_ref);
    pipeline_asm_fill_block_locals_tree(ctx, arena, else_ref);
    glue_asm_ctx_set_scope_block(ctx, else_ref);
    if (pipeline_asm_emit_block_body_sync_elf(arena, elf_ctx, else_ref, ctx, ta) != 0)
      return -1;
    glue_block_fill_live_end_for_merge(arena, ctx, else_ref, else_live);
  } else {
    glue_live_fwd_copy_from_snap_before_if(else_live);
  }
  if (backend_enc_label_arch(elf_ctx, done_lbl, done_len, 0, ta) != 0)
    return -1;
  glue_asm_cache_invalidate_at_cfg_merge_selective(arena, ctx, then_ref, else_ref);
  glue_asm_if_phi_invalidate_both_branch_defs(arena, ctx, then_ref, else_ref);
  glue_asm_if_merge_live_union_from_ends(arena, ctx, then_live, else_live);
  glue_asm_ctx_set_scope_block(ctx, cur_block);
  return 0;
}

int32_t pipeline_asm_emit_if_then_block_body_elf_c(void *arena, void *elf_ctx, int32_t then_block_ref, void *ctx,
                                                   int32_t ta) {
  int32_t sv_locs;
  int32_t sv_next;
  int32_t r;
  void *ly;
  if (!ctx || !arena || then_block_ref <= 0)
    return -1;
  ly = pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  sv_locs = seed_pipe_load_i32_le(ly, 8);
  sv_next = seed_pipe_load_i32_le(ly, 4);
  pipeline_asm_fill_local_slots(ctx, arena, then_block_ref);
  r = backend_emit_block_body_sync_elf(arena, elf_ctx, then_block_ref, ctx, ta);
  seed_pipe_store_i32_le(ly, 8, sv_locs);
  seed_pipe_store_i32_le(ly, 4, sv_next);
  return r;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave130: wpo_mono pure leave cold twins under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding emit · Cap residual codegen_wpo_mono_sym_format +
 * backend_enc_label/prologue/mov_imm64/epilogue + pipeline_dep_ctx_target_arch +
 * link_abi_getenv + memset/memcpy/strcmp/strlen.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Layout: GlueWpoMonoThunks = 64 * 136 + 4 = 8708 (sym[128]@0, result@128, valid@132).
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
#define WAVE130_WPO_MONO_MAX_THUNKS 64
#define WAVE130_WPO_MONO_SYM_MAX 128
#define WAVE130_WPO_MONO_MAX_ARGS 8
#define WAVE130_WPO_MONO_THUNK_SZ 136
#define WAVE130_WPO_MONO_BAG_SZ 8708
#define WAVE130_WPO_MONO_N_OFF 8704

typedef struct Wave130GlueWpoMonoThunk {
  char sym[WAVE130_WPO_MONO_SYM_MAX];
  int32_t result_imm;
  unsigned char valid;
} Wave130GlueWpoMonoThunk;

typedef struct Wave130GlueWpoMonoThunks {
  Wave130GlueWpoMonoThunk thunks[WAVE130_WPO_MONO_MAX_THUNKS];
  int n;
} Wave130GlueWpoMonoThunks;

static Wave130GlueWpoMonoThunks g_glue_wpo_mono_pending;

extern int codegen_wpo_mono_sym_format(const char *base, int nargs, const int *args, char *out, int cap);
extern char *link_abi_getenv(const char *name);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);
extern int32_t backend_enc_prologue_arch(void *elf_ctx, int32_t frame_sz, int32_t ta);
extern int32_t backend_enc_epilogue_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t pipeline_dep_ctx_target_arch(void *ctx);

static int glue_wpo_mono_has_sym(const Wave130GlueWpoMonoThunks *bag, const char *sym) {
  int i;
  if (!bag || !sym)
    return 0;
  for (i = 0; i < bag->n; i++)
    if (bag->thunks[i].valid && strcmp(bag->thunks[i].sym, sym) == 0)
      return 1;
  return 0;
}

void glue_wpo_mono_reset_pending(void) {
  memset(&g_glue_wpo_mono_pending, 0, sizeof(g_glue_wpo_mono_pending));
}

void glue_wpo_mono_register_thunk_n(const char *base, int32_t nargs, const int32_t *args, int32_t folded) {
  char sym[WAVE130_WPO_MONO_SYM_MAX];
  int sym_len;
  Wave130GlueWpoMonoThunk *slot;
  if (!base || !link_abi_getenv("XLANG_WPO_MONO"))
    return;
  if (nargs < 0)
    nargs = 0;
  if (nargs > WAVE130_WPO_MONO_MAX_ARGS)
    nargs = WAVE130_WPO_MONO_MAX_ARGS;
  sym_len = codegen_wpo_mono_sym_format(base, (int)nargs, (const int *)args, sym, (int)sizeof(sym));
  if (sym_len <= 0 || glue_wpo_mono_has_sym(&g_glue_wpo_mono_pending, sym))
    return;
  if (g_glue_wpo_mono_pending.n >= WAVE130_WPO_MONO_MAX_THUNKS)
    return;
  slot = &g_glue_wpo_mono_pending.thunks[g_glue_wpo_mono_pending.n];
  memset(slot, 0, sizeof(*slot));
  memcpy(slot->sym, sym, (size_t)sym_len + 1);
  slot->result_imm = folded;
  slot->valid = 1;
  g_glue_wpo_mono_pending.n++;
}

void glue_wpo_mono_register_thunk(const char *base, int32_t av0, int32_t av1, int32_t folded) {
  int32_t args[2];
  args[0] = av0;
  args[1] = av1;
  glue_wpo_mono_register_thunk_n(base, 2, args, folded);
}

int32_t pipeline_asm_emit_wpo_mono_thunks_elf_c(struct ast_Module *entry, struct ast_ASTArena *arena,
                                                 void *elf_ctx, void *pipeline_ctx) {
  const Wave130GlueWpoMonoThunks *thunks;
  int ta;
  int ti;
  (void)entry;
  (void)arena;
  if (!elf_ctx || !pipeline_ctx)
    return -1;
  if (!link_abi_getenv("XLANG_WPO_MONO"))
    return 0;
  thunks = &g_glue_wpo_mono_pending;
  ta = (int)pipeline_dep_ctx_target_arch(pipeline_ctx);
  for (ti = 0; ti < thunks->n; ti++) {
    const Wave130GlueWpoMonoThunk *th = &thunks->thunks[ti];
    int32_t hi;
    uint8_t sym[WAVE130_WPO_MONO_SYM_MAX];
    int32_t sym_len;
    if (!th->valid)
      continue;
    sym_len = (int32_t)strlen(th->sym);
    if (sym_len <= 0 || sym_len >= WAVE130_WPO_MONO_SYM_MAX)
      return -1;
    memcpy(sym, th->sym, (size_t)sym_len);
    if (backend_enc_label_arch(elf_ctx, sym, sym_len, 1, ta) != 0)
      return -1;
    if (backend_enc_prologue_arch(elf_ctx, 0, ta) != 0)
      return -1;
    hi = (th->result_imm < 0) ? -1 : 0;
    if (backend_enc_mov_imm64_to_rax_arch(elf_ctx, th->result_imm, hi, ta) != 0)
      return -1;
    if (backend_enc_epilogue_arch(elf_ctx, ta) != 0)
      return -1;
  }
  return 0;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave131: async_cps pure leave cold twins under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding emit · Cap residual async_asm_pool_build_layout +
 * asm_ctx_local_find_offset + pipeline_asm_ctx_layout + next_label +
 * glue_enc_jz_after_bool_in_eax + backend_enc_* + memset.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Layout: GlueAsyncCpsEmitState = 9124 (layout@16 AsyncAsmPoolLayout 8976;
 * LiveVar 140; resume@8992; resume_len@9120).
 * AsmFuncCtxLayout: tail_join_label@1392 tail_join_label_len@1520 (LP64).
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
#define WAVE131_ASYNC_LIVE_MAX 64
#define WAVE131_ASYNC_LIVE_VAR_SZ 140
#define WAVE131_ASYNC_LAYOUT_SZ 8976
#define WAVE131_ASYNC_STATE_SZ 9124
#define WAVE131_ASYNC_OFF_LAYOUT 16
#define WAVE131_ASYNC_OFF_RESUME 8992
#define WAVE131_ASYNC_OFF_RESUME_LEN 9120
#define WAVE131_TAIL_JOIN_LBL 1392
#define WAVE131_TAIL_JOIN_LEN 1520

typedef struct Wave131AsyncAsmPoolLiveVar {
  char name[128];
  int32_t name_len;
  int32_t size_bytes;
  int32_t frame_data_off;
} Wave131AsyncAsmPoolLiveVar;

typedef struct Wave131AsyncAsmPoolLayout {
  uint32_t fn_id;
  int32_t num_awaits;
  int32_t num_live;
  Wave131AsyncAsmPoolLiveVar live[WAVE131_ASYNC_LIVE_MAX];
  int32_t await_stmt_idx;
} Wave131AsyncAsmPoolLayout;

typedef struct Wave131GlueAsyncCpsEmitState {
  int32_t active;
  int32_t ta;
  uint32_t fn_id;
  int32_t next_phase;
  Wave131AsyncAsmPoolLayout layout;
  uint8_t resume_label[128];
  int32_t resume_label_len;
} Wave131GlueAsyncCpsEmitState;

static Wave131GlueAsyncCpsEmitState g_glue_async_cps_emit;

extern int32_t async_asm_pool_build_layout(void *arena, void *mod, int32_t func_index, void *out);
extern int32_t asm_ctx_local_find_offset(void *ctx, uint8_t *name, int32_t name_len);
extern void *pipeline_asm_ctx_layout(void *ctx);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t glue_enc_jz_after_bool_in_eax(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_mov_imm64_to_rax_arch(void *elf_ctx, int32_t lo, int32_t hi, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t backend_enc_call_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t ta);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_push_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_pop_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_load_32_from_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_cmp_rbx_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_jeq_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_jmp_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);

static int32_t glue_async_cps_mov_imm32_to_rax(void *elf_ctx, int32_t imm, int32_t ta) {
  return backend_enc_mov_imm64_to_rax_arch(elf_ctx, imm, 0, ta);
}

static int32_t glue_async_cps_emit_frame_phase_ptr(void *elf_ctx, uint32_t fn_id, int32_t ta) {
  static const uint8_t nm[] = "xlang_async_asm_frame_phase_by_id";
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, (int32_t)fn_id, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, (uint8_t *)nm, (int32_t)(sizeof(nm) - 1), ta);
}

static int32_t glue_async_cps_call_frame_memop(void *elf_ctx, uint8_t *cname, int32_t cname_len, uint32_t fn_id,
                                               int32_t data_off, int32_t stack_off, int32_t nbytes, int32_t ta) {
  if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 2, ta) != 0)
    return -1;
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, nbytes, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 3, ta) != 0)
    return -1;
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, data_off, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, (int32_t)fn_id, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_call_arch(elf_ctx, cname, cname_len, ta);
}

static int32_t glue_async_cps_save_live(void *elf_ctx, void *ctx, int32_t ta) {
  int32_t i;
  static const uint8_t store_nm[] = "xlang_async_asm_frame_store_from_ptr";
  for (i = 0; i < g_glue_async_cps_emit.layout.num_live; i++) {
    const Wave131AsyncAsmPoolLiveVar *lv = &g_glue_async_cps_emit.layout.live[i];
    int32_t stack_off = asm_ctx_local_find_offset(ctx, (uint8_t *)lv->name, lv->name_len);
    if (stack_off < 0)
      return -1;
    if (glue_async_cps_call_frame_memop(elf_ctx, (uint8_t *)store_nm, (int32_t)(sizeof(store_nm) - 1),
                                        g_glue_async_cps_emit.fn_id, lv->frame_data_off, stack_off, lv->size_bytes,
                                        ta) != 0)
      return -1;
  }
  return 0;
}

static int32_t glue_async_cps_restore_live(void *elf_ctx, void *ctx, int32_t ta) {
  int32_t i;
  static const uint8_t load_nm[] = "xlang_async_asm_frame_load_to_ptr";
  for (i = 0; i < g_glue_async_cps_emit.layout.num_live; i++) {
    const Wave131AsyncAsmPoolLiveVar *lv = &g_glue_async_cps_emit.layout.live[i];
    int32_t stack_off = asm_ctx_local_find_offset(ctx, (uint8_t *)lv->name, lv->name_len);
    if (stack_off < 0)
      return -1;
    if (glue_async_cps_call_frame_memop(elf_ctx, (uint8_t *)load_nm, (int32_t)(sizeof(load_nm) - 1),
                                        g_glue_async_cps_emit.fn_id, lv->frame_data_off, stack_off, lv->size_bytes,
                                        ta) != 0)
      return -1;
  }
  return 0;
}

int32_t glue_async_cps_emit_after_await(void *arena, void *elf_ctx, void *ctx, int32_t ta) {
  uint8_t *ly;
  static const uint8_t suspend_nm[] = "xlang_async_cps_suspend";
  int32_t next_ph;
  int32_t tj_len;
  (void)arena;
  if (!g_glue_async_cps_emit.active)
    return 0;
  next_ph = g_glue_async_cps_emit.next_phase++;
  if (glue_async_cps_save_live(elf_ctx, ctx, ta) != 0)
    return -1;
  if (glue_async_cps_emit_frame_phase_ptr(elf_ctx, g_glue_async_cps_emit.fn_id, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, next_ph, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_call_arch(elf_ctx, (uint8_t *)suspend_nm, (int32_t)(sizeof(suspend_nm) - 1), ta) != 0)
    return -1;
  if (glue_enc_jz_after_bool_in_eax(elf_ctx, g_glue_async_cps_emit.resume_label, g_glue_async_cps_emit.resume_label_len,
                                    ta) != 0)
    return -1;
  ly = (uint8_t *)pipeline_asm_ctx_layout(ctx);
  if (!ly)
    return -1;
  {
    int32_t *p = (int32_t *)(ly + WAVE131_TAIL_JOIN_LEN);
    tj_len = *p;
  }
  if (tj_len <= 0)
    return -1;
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, (int32_t)0x41535700, ta) != 0)
    return -1;
  if (backend_enc_jmp_arch(elf_ctx, ly + WAVE131_TAIL_JOIN_LBL, tj_len, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, g_glue_async_cps_emit.resume_label, g_glue_async_cps_emit.resume_label_len, 0,
                             ta) != 0)
    return -1;
  return glue_async_cps_restore_live(elf_ctx, ctx, ta);
}

int32_t glue_async_cps_emit_phase_reset(void *elf_ctx, int32_t ta) {
  static const uint8_t reset_nm[] = "xlang_async_asm_frame_reset_by_id";
  if (!g_glue_async_cps_emit.active)
    return 0;
  if (backend_enc_push_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, (int32_t)g_glue_async_cps_emit.fn_id, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0)
    return -1;
  if (backend_enc_call_arch(elf_ctx, (uint8_t *)reset_nm, (int32_t)(sizeof(reset_nm) - 1), ta) != 0)
    return -1;
  return backend_enc_pop_rax_arch(elf_ctx, ta);
}

int32_t pipeline_asm_emit_async_cps_entry_elf_c(void *arena, void *elf_ctx, void *ctx, void *mod, int32_t func_index,
                                                int32_t ta) {
  int32_t lr;
  memset(&g_glue_async_cps_emit, 0, sizeof(g_glue_async_cps_emit));
  if (!arena || !elf_ctx || !ctx || !mod || func_index < 0)
    return 0;
  if (ta < 0 || ta > 2)
    return 0;
  lr = async_asm_pool_build_layout(arena, mod, func_index, &g_glue_async_cps_emit.layout);
  if (lr != 0)
    return 0;
  g_glue_async_cps_emit.active = 1;
  g_glue_async_cps_emit.ta = ta;
  g_glue_async_cps_emit.fn_id = g_glue_async_cps_emit.layout.fn_id;
  g_glue_async_cps_emit.next_phase = 1;
  g_glue_async_cps_emit.resume_label_len =
      pipeline_asm_emit_next_label_c(ctx, g_glue_async_cps_emit.resume_label, 64);
  if (g_glue_async_cps_emit.resume_label_len <= 0)
    return -1;
  if (glue_async_cps_emit_frame_phase_ptr(elf_ctx, g_glue_async_cps_emit.fn_id, ta) != 0)
    return -1;
  if (backend_enc_load_32_from_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
    return -1;
  if (glue_async_cps_mov_imm32_to_rax(elf_ctx, 1, ta) != 0)
    return -1;
  if (backend_enc_cmp_rbx_rax_arch(elf_ctx, ta) != 0)
    return -1;
  if (backend_enc_jeq_arch(elf_ctx, g_glue_async_cps_emit.resume_label, g_glue_async_cps_emit.resume_label_len, ta) !=
      0)
    return -1;
  return 0;
}

void pipeline_asm_emit_async_cps_end_func_elf_c(void) {
  memset(&g_glue_async_cps_emit, 0, sizeof(g_glue_async_cps_emit));
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* wave132: struct_let pure leave cold twins under #ifndef FROM_X.
 * PLATFORM: SHARED freestanding emit · Cap residual struct_lit_fields + try_inline*
 * + set_call_expected_ret_ty + call_return_byte_size + type_size_simple +
 * named_layout_size + store_retval_pair + emit_module_from_ctx + expr_kind +
 * emit_expr_elf_c + lea/mov_arg + arm64 x0→x8.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Pure-owned g_call_sret_reg_shift (was glue_statics static).
 */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
static int32_t g_wave132_call_sret_reg_shift = 0;

extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_struct_lit_fields_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx,
                                                        int32_t ta, int32_t stack_slot_off);
extern int32_t try_inline_struct_lit_return_call_to_slot_elf(void *arena, void *elf_ctx, int32_t call_ref, void *ctx,
                                                            int32_t ta, int32_t stack_slot_off);
extern int32_t try_inline_const_struct_lit_return_call_to_slot_elf(void *arena, void *elf_ctx, int32_t call_ref,
                                                                  void *ctx, int32_t ta, int32_t stack_slot_off);
extern void pipeline_asm_set_call_expected_ret_ty_c(int32_t type_ref);
extern int32_t glue_call_return_byte_size_c(void *arena, int32_t call_expr_ref);
extern int32_t glue_type_size_simple(void *m, void *a, int32_t ty_ref, int32_t depth);
extern int32_t glue_type_named_layout_size_any_module_elf_c(void *arena, int32_t ty_ref);
extern int32_t glue_store_retval_pair_to_rbp_elf_c(void *m, void *arena, void *elf_ctx, int32_t ty_ref, int32_t slot_off,
                                                   int32_t ta, int32_t init_ref, void *ctx);
extern void *glue_emit_module_from_ctx(void *ctx);
extern int32_t backend_enc_lea_rbp_to_rax_arch(void *elf_ctx, int32_t offset, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(void *elf_ctx, int32_t k, int32_t ta);
extern int32_t glue_arm64_mov_x0_to_x8_elf_c(void *elf_ctx);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);

void pipeline_asm_emit_set_call_sret_reg_shift_c(int32_t shift) {
  g_wave132_call_sret_reg_shift = shift > 0 ? 1 : 0;
}

int32_t pipeline_asm_emit_call_sret_reg_shift_c(void) {
  return g_wave132_call_sret_reg_shift;
}

int32_t pipeline_asm_emit_struct_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta,
                                                 int32_t stack_slot_off) {
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -1;
  if (pipeline_expr_kind_ord_at(arena, init_ref) != 45)
    return -1;
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
}

int32_t glue_emit_struct_type_let_init_elf_c(void *arena, void *elf_ctx, int32_t init_ref, void *ctx, int32_t ta,
                                             int32_t let_ty_ref, int32_t stack_slot_off) {
  int32_t ko;
  int32_t inl;
  int32_t emit_rc;
  int32_t call_ret_sz;
  int32_t let_sz;
  int32_t named_sz;
  int32_t best;
  void *modp;
  if (!arena || !elf_ctx || !ctx || init_ref <= 0)
    return -2;
  ko = pipeline_expr_kind_ord_at(arena, init_ref);
  if (ko == 45)
    return pipeline_asm_emit_struct_let_init_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
  if (ko == 48 || ko == 49) {
    if (ko == 48) {
      inl = try_inline_struct_lit_return_call_to_slot_elf(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
      if (inl == 1)
        return 0;
      inl = try_inline_const_struct_lit_return_call_to_slot_elf(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
      if (inl == 1)
        return 0;
    }
    pipeline_asm_set_call_expected_ret_ty_c(let_ty_ref > 0 ? let_ty_ref : 0);
    call_ret_sz = glue_call_return_byte_size_c(arena, init_ref);
    if (call_ret_sz <= 16 && let_ty_ref > 0) {
      modp = glue_emit_module_from_ctx(ctx);
      let_sz = glue_type_size_simple(modp, arena, let_ty_ref, 0);
      named_sz = 0;
      if (let_sz <= 16)
        named_sz = glue_type_named_layout_size_any_module_elf_c(arena, let_ty_ref);
      best = let_sz;
      if (named_sz > best) {
        if (call_ret_sz > 0 && call_ret_sz <= 16 && named_sz > 16) {
          /* keep best */
        } else if (let_sz <= 4 || call_ret_sz <= 0 || named_sz <= 16) {
          best = named_sz;
        }
      }
      if (best > call_ret_sz)
        call_ret_sz = best;
    }
    if (call_ret_sz > 16 && (ta == 0 || ta == 1)) {
      if (backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta) != 0) {
        pipeline_asm_set_call_expected_ret_ty_c(0);
        return -1;
      }
      if (ta == 0) {
        if (backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, 0, ta) != 0) {
          pipeline_asm_set_call_expected_ret_ty_c(0);
          return -1;
        }
        pipeline_asm_emit_set_call_sret_reg_shift_c(1);
      } else {
        if (glue_arm64_mov_x0_to_x8_elf_c(elf_ctx) != 0) {
          pipeline_asm_set_call_expected_ret_ty_c(0);
          return -1;
        }
      }
      emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
      pipeline_asm_emit_set_call_sret_reg_shift_c(0);
      pipeline_asm_set_call_expected_ret_ty_c(0);
      return emit_rc != 0 ? -1 : 0;
    }
    emit_rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
    pipeline_asm_set_call_expected_ret_ty_c(0);
    if (emit_rc != 0)
      return -1;
    modp = glue_emit_module_from_ctx(ctx);
    if (glue_store_retval_pair_to_rbp_elf_c(modp, arena, elf_ctx, let_ty_ref, stack_slot_off, ta, init_ref, ctx) != 0)
      return -1;
    return 0;
  }
  return -2;
}

/*
 * wave133: pipeline_asm_emit_unary pure-owned leave cold twins.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Faces: sxt i32, jz-after-bool, neg/lognot/bitnot ELF.
 */
extern int32_t pipeline_elf_ctx_append_bytes(void *ctx, uint8_t *ptr, int32_t n);
extern int32_t backend_enc_test_eax_eax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_jz_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t pipeline_expr_unary_operand_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta);
extern int32_t glue_binop_operand_is_scalar_f32_elf_c(void *arena, void *ctx, int32_t expr_ref);
extern int32_t glue_binop_operand_is_scalar_f64_elf_c(void *arena, void *ctx, int32_t expr_ref);
extern int32_t arch_arm64_enc_enc_u32_le(void *elf_ctx, int32_t val);
extern int32_t pipeline_expr_resolved_type_ref(void *arena, int32_t expr_ref);
extern int32_t glue_var_decl_type_ref_elf_c(void *arena, void *ctx, int32_t var_expr_ref);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int64_t pipeline_expr_int64_val_at(void *arena, int32_t expr_ref);
extern int32_t backend_enc_neg_eax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_not_eax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_setz_movzbl_eax_arch(void *elf_ctx, int32_t ta);
extern int32_t pipeline_type_named_name_into(void *arena, int32_t ref, uint8_t *out64);

int32_t glue_enc_sxt_i32_result_to_rax_elf_c(void *elf_ctx, int32_t ta) {
  if (!elf_ctx)
    return -1;
  if (ta == 0) {
    static const uint8_t cdqe[2] = {0x48, 0x98};
    return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)cdqe, 2);
  }
  if (ta == 1) {
    static const uint8_t sxtw[4] = {0x00, 0x7c, 0x40, 0x93};
    return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)sxtw, 4);
  }
  return 0;
}

int32_t glue_enc_jz_after_bool_in_eax(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta) {
  if (ta == 0) {
    if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
      return -1;
  }
  return backend_enc_jz_arch(elf_ctx, label, label_len, ta);
}

int32_t pipeline_asm_emit_neg_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t op;
  int32_t use_i64_neg = 0;
  int32_t tr;
  int32_t kind_ord = -1;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta) != 0)
    return -1;
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f32_elf_c(arena, ctx, op)) {
    if (ta == 1) {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x52b00001u) != 0)
        return -1;
      return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0x4a010000u);
    }
    {
      static const uint8_t btc_eax_31[4] = {0x0f, 0xba, 0xf8, 0x1f};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)btc_eax_31, 4);
    }
  }
  if ((ta == 0 || ta == 1) && glue_binop_operand_is_scalar_f64_elf_c(arena, ctx, op)) {
    if (ta == 1) {
      if (arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0xd2f00001u) != 0)
        return -1;
      return arch_arm64_enc_enc_u32_le(elf_ctx, (int32_t)0xca010000u);
    }
    {
      static const uint8_t btc_rax_63[5] = {0x48, 0x0f, 0xba, 0xf8, 0x3f};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)btc_rax_63, 5);
    }
  }
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, op);
  if (tr <= 0)
    tr = glue_var_decl_type_ref_elf_c(arena, ctx, op);
  if (tr > 0)
    kind_ord = pipeline_type_kind_ord_at(arena, tr);
  if (kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7 || kind_ord == 9)
    use_i64_neg = 1;
  if (!use_i64_neg && pipeline_expr_kind_ord_at(arena, op) == 0) {
    int64_t v64 = pipeline_expr_int64_val_at(arena, op);
    if (v64 < (int64_t)INT32_MIN || v64 > (int64_t)INT32_MAX)
      use_i64_neg = 1;
  }
  if (use_i64_neg) {
    if (ta == 0) {
      static const uint8_t neg_rax[3] = {0x48, 0xf7, 0xd8};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)neg_rax, 3);
    }
    if (ta == 1) {
      static const uint8_t neg_x0[4] = {0xe0, 0x03, 0x00, 0xcb};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)neg_x0, 4);
    }
  }
  if (backend_enc_neg_eax_arch(elf_ctx, ta) != 0)
    return -1;
  {
    int32_t tr_n = pipeline_expr_resolved_type_ref(arena, expr_ref);
    int32_t k_n = (tr_n > 0) ? pipeline_type_kind_ord_at(arena, tr_n) : -1;
    if (k_n == 0)
      return glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
    if (k_n == 2 && ta == 0) {
      static const uint8_t and_eax_ff[5] = {0x25, 0xff, 0x00, 0x00, 0x00};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)and_eax_ff, 5);
    }
    if (k_n == 8) {
      uint8_t nm[128];
      int32_t nlen = pipeline_type_named_name_into(arena, tr_n, nm);
      if (nlen == 3 && nm[0] == (uint8_t)'u' && nm[1] == (uint8_t)'1' && nm[2] == (uint8_t)'6' && ta == 0) {
        static const uint8_t and_eax_ffff[5] = {0x25, 0xff, 0xff, 0x00, 0x00};
        return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)and_eax_ffff, 5);
      }
    }
  }
  return 0;
}

int32_t pipeline_asm_emit_lognot_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t op;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta) != 0)
    return -1;
  if (backend_enc_test_eax_eax_arch(elf_ctx, ta) != 0)
    return -1;
  return backend_enc_setz_movzbl_eax_arch(elf_ctx, ta);
}

int32_t pipeline_asm_emit_bitnot_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t op;
  int32_t use_i64_not = 0;
  int32_t tr;
  int32_t kind_ord = -1;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
  if (op == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta) != 0)
    return -1;
  tr = pipeline_expr_resolved_type_ref(arena, expr_ref);
  if (tr <= 0)
    tr = pipeline_expr_resolved_type_ref(arena, op);
  if (tr <= 0)
    tr = glue_var_decl_type_ref_elf_c(arena, ctx, op);
  if (tr > 0)
    kind_ord = pipeline_type_kind_ord_at(arena, tr);
  if (kind_ord == 4 || kind_ord == 5 || kind_ord == 6 || kind_ord == 7 || kind_ord == 9)
    use_i64_not = 1;
  if (use_i64_not) {
    if (ta == 0) {
      static const uint8_t not_rax[3] = {0x48, 0xf7, 0xd0};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)not_rax, 3);
    }
    if (ta == 1) {
      static const uint8_t mvn_x0[4] = {0xe0, 0x03, 0x20, 0xaa};
      return pipeline_elf_ctx_append_bytes(elf_ctx, (uint8_t *)mvn_x0, 4);
    }
  }
  if (backend_enc_not_eax_arch(elf_ctx, ta) != 0)
    return -1;
  if (kind_ord == 0)
    return glue_enc_sxt_i32_result_to_rax_elf_c(elf_ctx, ta);
  return 0;
}

/*
 * wave134: pipeline_asm_emit_match pure-owned leave cold twins.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Faces: match_elf + expr_if_elf + match subject context + name_is_subject_field.
 */
extern int32_t pipeline_expr_match_matched_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_match_num_arms_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_match_arm_is_wildcard(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_guard_ref(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_result_ref(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_is_enum_variant(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_variant_index(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_match_arm_lit_val(void *arena, int32_t expr_ref, int32_t i);
extern int32_t pipeline_expr_if_cond_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_then_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_if_else_ref_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_asm_emit_expr_if_arm_elf_c(void *arena, void *elf_ctx, int32_t arm_ref, void *ctx,
                                                   int32_t ta);
extern int32_t pipeline_asm_emit_next_label_c(void *ctx, uint8_t *buf, int32_t buf_size);
extern int32_t glue_enc_jz_after_bool_in_eax(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_jmp_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern int32_t backend_enc_label_arch(void *elf_ctx, uint8_t *name, int32_t name_len, int32_t is_global, int32_t ta);
extern int32_t backend_enc_mov_rax_to_rbx_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_mov_imm32_to_w0_arch(void *elf_ctx, int32_t imm, int32_t ta);
extern int32_t backend_enc_cmp_rbx_rax_arch(void *elf_ctx, int32_t ta);
extern int32_t backend_enc_jne_arch(void *elf_ctx, uint8_t *label, int32_t label_len, int32_t ta);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t pipeline_asm_emit_func_index_c(void);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out64);
extern int32_t pipeline_module_func_param_type_ref_for_name(void *module, int32_t func_index, uint8_t *var_name,
                                                           int32_t name_len);
extern int32_t pipeline_module_num_struct_layouts_at(void *module);
extern int32_t pipeline_module_struct_layout_name_len(void *module, int32_t idx);
extern int32_t pipeline_module_struct_layout_name_byte_at(void *module, int32_t idx, int32_t off);
extern int32_t pipeline_module_struct_layout_num_fields(void *module, int32_t layout_idx);
extern int32_t pipeline_module_struct_layout_field_name_len(void *module, int32_t layout_idx, int32_t fi);
extern void pipeline_module_struct_layout_field_name_into(void *module, int32_t layout_idx, int32_t fi, uint8_t *out64);

static int32_t g_codegen_match_matched_ref = 0;
static int32_t g_codegen_match_subject_ty = 0;
static void *g_codegen_match_mod = 0;

void pipeline_codegen_match_set_subject_c(void *module, int32_t matched_ref, int32_t subject_ty) {
  g_codegen_match_mod = module;
  g_codegen_match_matched_ref = matched_ref;
  g_codegen_match_subject_ty = subject_ty;
}

void pipeline_codegen_match_clear_subject_c(void) {
  g_codegen_match_mod = 0;
  g_codegen_match_matched_ref = 0;
  g_codegen_match_subject_ty = 0;
}

int32_t pipeline_codegen_match_matched_ref_c(void) {
  return g_codegen_match_matched_ref;
}

int32_t pipeline_codegen_match_subject_ty_c(void) {
  return g_codegen_match_subject_ty;
}

void *pipeline_codegen_match_mod_c(void) {
  return g_codegen_match_mod;
}

int32_t pipeline_codegen_match_name_is_subject_field_c(void *module, void *arena, uint8_t *name, int32_t name_len) {
  int32_t ty;
  int32_t k;
  int32_t nsl;
  int32_t fi;
  int32_t nf;
  int32_t fl;
  int32_t j;
  uint8_t tnm[128];
  uint8_t fnm[128];
  int32_t tnl;
  if (!module || !arena || !name || name_len <= 0)
    return 0;
  ty = g_codegen_match_subject_ty;
  if (ty <= 0 || g_codegen_match_mod != module || g_codegen_match_matched_ref <= 0)
    return 0;
  if (pipeline_type_kind_ord_at(arena, ty) != 8)
    return 0;
  tnl = pipeline_type_named_name_into(arena, ty, tnm);
  if (tnl <= 0)
    return 0;
  nsl = pipeline_module_num_struct_layouts_at(module);
  for (k = 0; k < nsl; k++) {
    fl = pipeline_module_struct_layout_name_len(module, k);
    if (fl != tnl)
      continue;
    {
      int32_t match = 1;
      int32_t bi;
      for (bi = 0; bi < fl && match; bi++) {
        if (pipeline_module_struct_layout_name_byte_at(module, k, bi) != (int32_t)tnm[bi])
          match = 0;
      }
      if (!match)
        continue;
    }
    nf = pipeline_module_struct_layout_num_fields(module, k);
    for (fi = 0; fi < nf; fi++) {
      int32_t fnl = pipeline_module_struct_layout_field_name_len(module, k, fi);
      if (fnl != name_len)
        continue;
      memset(fnm, 0, sizeof(fnm));
      pipeline_module_struct_layout_field_name_into(module, k, fi, fnm);
      {
        int32_t match = 1;
        for (j = 0; j < fnl && match; j++) {
          if (fnm[j] != name[j])
            match = 0;
        }
        if (match)
          return 1;
      }
    }
  }
  return 0;
}

int32_t pipeline_asm_emit_match_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t matched_ref;
  int32_t num_arms;
  int32_t i;
  int32_t cmp_val;
  int32_t is_wild;
  int32_t guard_ref;
  uint8_t done_lbl[128];
  uint8_t next_lbl[128];
  int32_t done_len;
  int32_t next_len;
  int32_t result_ref;
  void *prev_mod;
  int32_t prev_mref;
  int32_t prev_ty;
  int32_t rc;
  int32_t saw_terminal_wild;
  void *emit_mod;
  int32_t emit_fi;
  if (!arena || !elf_ctx || !ctx || expr_ref <= 0)
    return -1;
  matched_ref = pipeline_expr_match_matched_ref_at(arena, expr_ref);
  num_arms = pipeline_expr_match_num_arms_at(arena, expr_ref);
  if (matched_ref <= 0 || num_arms <= 0 || num_arms > 32)
    return -1;
  prev_mod = pipeline_codegen_match_mod_c();
  prev_mref = pipeline_codegen_match_matched_ref_c();
  prev_ty = pipeline_codegen_match_subject_ty_c();
  emit_mod = pipeline_asm_emit_module_ref_c();
  emit_fi = pipeline_asm_emit_func_index_c();
  if (emit_mod != 0 && matched_ref > 0) {
    int32_t subj_ty = pipeline_expr_resolved_type_ref(arena, matched_ref);
    if (subj_ty <= 0 && pipeline_expr_kind_ord_at(arena, matched_ref) == 3 && emit_fi >= 0) {
      uint8_t mn[128];
      int32_t mln = pipeline_expr_var_name_len(arena, matched_ref);
      if (mln > 0 && mln <= 127) {
        pipeline_expr_var_name_into(arena, matched_ref, mn);
        subj_ty = pipeline_module_func_param_type_ref_for_name(emit_mod, emit_fi, mn, mln);
      }
    }
    if (subj_ty > 0)
      pipeline_codegen_match_set_subject_c(emit_mod, matched_ref, subj_ty);
  }
  rc = -1;
  saw_terminal_wild = 0;
  done_len = pipeline_asm_emit_next_label_c(ctx, done_lbl, 64);
  if (done_len <= 0)
    goto match_elf_done;
  for (i = 0; i < num_arms; i++) {
    is_wild = pipeline_expr_match_arm_is_wildcard(arena, expr_ref, i);
    guard_ref = pipeline_expr_match_arm_guard_ref(arena, expr_ref, i);
    result_ref = pipeline_expr_match_arm_result_ref(arena, expr_ref, i);
    if (result_ref <= 0)
      goto match_elf_done;
    if (is_wild != 0 && guard_ref <= 0) {
      if (pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, result_ref, ctx, ta) != 0)
        goto match_elf_done;
      if (pipeline_expr_kind_ord_at(arena, result_ref) != 41) {
        if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0)
          goto match_elf_done;
      }
      saw_terminal_wild = 1;
      break;
    }
    next_len = pipeline_asm_emit_next_label_c(ctx, next_lbl, 64);
    if (next_len <= 0)
      goto match_elf_done;
    if (is_wild != 0) {
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, guard_ref, ctx, ta) != 0)
        goto match_elf_done;
      if (glue_enc_jz_after_bool_in_eax(elf_ctx, next_lbl, next_len, ta) != 0)
        goto match_elf_done;
    } else {
      if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, matched_ref, ctx, ta) != 0)
        goto match_elf_done;
      if (backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta) != 0)
        goto match_elf_done;
      if (pipeline_expr_match_arm_is_enum_variant(arena, expr_ref, i) != 0)
        cmp_val = pipeline_expr_match_arm_variant_index(arena, expr_ref, i);
      else
        cmp_val = pipeline_expr_match_arm_lit_val(arena, expr_ref, i);
      if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, cmp_val, ta) != 0)
        goto match_elf_done;
      if (backend_enc_cmp_rbx_rax_arch(elf_ctx, ta) != 0)
        goto match_elf_done;
      if (backend_enc_jne_arch(elf_ctx, next_lbl, next_len, ta) != 0)
        goto match_elf_done;
      if (guard_ref > 0) {
        if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, guard_ref, ctx, ta) != 0)
          goto match_elf_done;
        if (glue_enc_jz_after_bool_in_eax(elf_ctx, next_lbl, next_len, ta) != 0)
          goto match_elf_done;
      }
    }
    if (pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, result_ref, ctx, ta) != 0)
      goto match_elf_done;
    if (pipeline_expr_kind_ord_at(arena, result_ref) != 41) {
      if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0)
        goto match_elf_done;
    }
    if (backend_enc_label_arch(elf_ctx, next_lbl, next_len, 0, ta) != 0)
      goto match_elf_done;
  }
  if (saw_terminal_wild == 0) {
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
      goto match_elf_done;
  }
  if (backend_enc_label_arch(elf_ctx, done_lbl, done_len, 0, ta) != 0)
    goto match_elf_done;
  rc = 0;
match_elf_done:
  pipeline_codegen_match_set_subject_c(prev_mod, prev_mref, prev_ty);
  return rc;
}

int32_t pipeline_asm_emit_expr_if_elf_c(void *arena, void *elf_ctx, int32_t expr_ref, void *ctx, int32_t ta) {
  int32_t cond;
  int32_t then_ref;
  int32_t else_ref;
  uint8_t else_lbl[128];
  uint8_t done_lbl[128];
  int32_t else_len;
  int32_t done_len;
  cond = pipeline_expr_if_cond_ref_at(arena, expr_ref);
  then_ref = pipeline_expr_if_then_ref_at(arena, expr_ref);
  else_ref = pipeline_expr_if_else_ref_at(arena, expr_ref);
  if (cond == 0 || then_ref == 0)
    return -1;
  if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, cond, ctx, ta) != 0)
    return -1;
  else_len = pipeline_asm_emit_next_label_c(ctx, else_lbl, 64);
  done_len = pipeline_asm_emit_next_label_c(ctx, done_lbl, 64);
  if (else_len <= 0 || done_len <= 0)
    return -1;
  if (glue_enc_jz_after_bool_in_eax(elf_ctx, else_lbl, else_len, ta) != 0)
    return -1;
  if (pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, then_ref, ctx, ta) != 0)
    return -1;
  if (backend_enc_jmp_arch(elf_ctx, done_lbl, done_len, ta) != 0)
    return -1;
  if (backend_enc_label_arch(elf_ctx, else_lbl, else_len, 0, ta) != 0)
    return -1;
  if (else_ref != 0) {
    if (pipeline_asm_emit_expr_if_arm_elf_c(arena, elf_ctx, else_ref, ctx, ta) != 0)
      return -1;
  } else {
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
      return -1;
  }
  if (backend_enc_label_arch(elf_ctx, done_lbl, done_len, 0, ta) != 0)
    return -1;
  return 0;
}

/*
 * wave135: pipeline_asm_emit_x86_enc_helpers pure-owned leave cold twins.
 * PREFER pure; cold path when PREFER!=1 / hybrid fail.
 * Faces: 27 glue_enc_x86_* + glue_emit_lcg_xor_body_x86_c.
 * Continues #ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X from wave132+ leave twins.
 */
extern int32_t pipeline_elf_ctx_append_bytes(void *ctx, uint8_t *ptr, int32_t n);

/** x86: cmpl $imm32, %eax. */
int32_t glue_enc_x86_cmpl_eax_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[5];
  if (!elf_ctx)
    return -1;
  b[0] = 0x3d;
  b[1] = (uint8_t)imm32;
  b[2] = (uint8_t)(imm32 >> 8);
  b[3] = (uint8_t)(imm32 >> 16);
  b[4] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 5);
}

/** x86: imull $imm32, %eax. */
int32_t glue_enc_x86_imull_imm_eax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  b[0] = 0x69;
  b[1] = 0xc0;
  b[2] = (uint8_t)imm32;
  b[3] = (uint8_t)(imm32 >> 8);
  b[4] = (uint8_t)(imm32 >> 16);
  b[5] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: addl $imm32, %eax (skip if imm==0). */
int32_t glue_enc_x86_addl_imm_eax(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  if (imm32 == 0)
    return 0;
  if (imm32 >= -128 && imm32 <= 127) {
    b[0] = 0x83;
    b[1] = 0xc0;
    b[2] = (uint8_t)imm32;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x05;
  b[1] = (uint8_t)imm32;
  b[2] = (uint8_t)(imm32 >> 8);
  b[3] = (uint8_t)(imm32 >> 16);
  b[4] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 5);
}

/** x86: addl $imm8/imm32, -off(%rbp) (i++ fast path; disp32 for large disp). */
int32_t glue_enc_x86_addl_imm_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off,
                                             int32_t imm32) {
  int32_t disp;
  uint8_t b[10];
  if (!elf_ctx)
    return -1;
  if (imm32 == 0)
    return 0;
  disp = -off;
  if (imm32 >= -128 && imm32 <= 127 && disp >= -128 && disp <= -1) {
    b[0] = 0x83;
    b[1] = 0x45;
    b[2] = (uint8_t)disp;
    b[3] = (uint8_t)imm32;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 4);
  }
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x81;
    b[1] = 0x45;
    b[2] = (uint8_t)disp;
    b[3] = (uint8_t)imm32;
    b[4] = (uint8_t)(imm32 >> 8);
    b[5] = (uint8_t)(imm32 >> 16);
    b[6] = (uint8_t)(imm32 >> 24);
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 7);
  }
  if (imm32 >= -128 && imm32 <= 127) {
    b[0] = 0x83;
    b[1] = 0x85;
    b[2] = (uint8_t)disp;
    b[3] = (uint8_t)(disp >> 8);
    b[4] = (uint8_t)(disp >> 16);
    b[5] = (uint8_t)(disp >> 24);
    b[6] = (uint8_t)imm32;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 7);
  }
  b[0] = 0x81;
  b[1] = 0x85;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  b[6] = (uint8_t)imm32;
  b[7] = (uint8_t)(imm32 >> 8);
  b[8] = (uint8_t)(imm32 >> 16);
  b[9] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 10);
}

/** x86: movl -off(%rbp), %ecx (loop_i32 LCG register-ization). */
int32_t glue_enc_x86_movl_rbp_off_to_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
  int32_t disp;
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  disp = -off;
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x8b;
    b[1] = 0x4d;
    b[2] = (uint8_t)disp;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x8b;
  b[1] = 0x8d;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: movl -off(%rbp), %edx. */
int32_t glue_enc_x86_movl_rbp_off_to_edx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
  int32_t disp;
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  disp = -off;
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x8b;
    b[1] = 0x55;
    b[2] = (uint8_t)disp;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x8b;
  b[1] = 0x95;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: movl %ecx, -off(%rbp). */
int32_t glue_enc_x86_movl_ecx_to_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
  int32_t disp;
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  disp = -off;
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x89;
    b[1] = 0x4d;
    b[2] = (uint8_t)disp;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x89;
  b[1] = 0x8d;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: movl %edx, -off(%rbp). */
int32_t glue_enc_x86_movl_edx_to_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
  int32_t disp;
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  disp = -off;
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x89;
    b[1] = 0x55;
    b[2] = (uint8_t)disp;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x89;
  b[1] = 0x95;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: cmpl $imm32, %ecx. */
int32_t glue_enc_x86_cmpl_ecx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  b[0] = 0x81;
  b[1] = 0xf9;
  b[2] = (uint8_t)imm32;
  b[3] = (uint8_t)(imm32 >> 8);
  b[4] = (uint8_t)(imm32 >> 16);
  b[5] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: xorl %eax, %eax (LCG s initial value 0). */
int32_t glue_enc_x86_xor_eax_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xc0};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: imull $imm32, %edx, %ecx (t = i*C1, i resident in edx). */
int32_t glue_enc_x86_imul_ecx_edx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  b[0] = 0x69;
  b[1] = 0xca;
  b[2] = (uint8_t)imm32;
  b[3] = (uint8_t)(imm32 >> 8);
  b[4] = (uint8_t)(imm32 >> 16);
  b[5] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: addl $imm32, %ecx (LCG t += C2). */
int32_t glue_enc_x86_addl_imm_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  b[0] = 0x81;
  b[1] = 0xc1;
  b[2] = (uint8_t)imm32;
  b[3] = (uint8_t)(imm32 >> 8);
  b[4] = (uint8_t)(imm32 >> 16);
  b[5] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: xorl %ecx, %eax (s ^= t, s resident in eax). */
int32_t glue_enc_x86_xorl_ecx_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xc8};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: incl %edx (LCG i++). */
int32_t glue_enc_x86_incl_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0xff, 0xc2};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: cmpl $imm32, %edx (LCG bottom-tested i vs n-1 compare). */
int32_t glue_enc_x86_cmpl_edx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  b[0] = 0x81;
  b[1] = 0xfa;
  b[2] = (uint8_t)imm32;
  b[3] = (uint8_t)(imm32 >> 8);
  b[4] = (uint8_t)(imm32 >> 16);
  b[5] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** Emit single LCG body iteration: t=i*C1+C2; s^=t; i++ (edx=i, eax=s, ecx=scratch). */
int32_t glue_emit_lcg_xor_body_x86_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t c1, int32_t c2) {
  if (glue_enc_x86_imul_ecx_edx_imm32(elf_ctx, c1) != 0)
    return -1;
  if (glue_enc_x86_incl_edx(elf_ctx) != 0)
    return -1;
  if (glue_enc_x86_addl_imm_ecx(elf_ctx, c2) != 0)
    return -1;
  if (glue_enc_x86_xorl_ecx_eax(elf_ctx) != 0)
    return -1;
  return 0;
}

/** x86: imull $imm32, %ecx, %eax (t = i*C1, i stays in ecx). */
int32_t glue_enc_x86_imul_eax_ecx_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  b[0] = 0x69;
  b[1] = 0xc1;
  b[2] = (uint8_t)imm32;
  b[3] = (uint8_t)(imm32 >> 8);
  b[4] = (uint8_t)(imm32 >> 16);
  b[5] = (uint8_t)(imm32 >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: xorl %ecx, %ecx. */
int32_t glue_enc_x86_xor_ecx_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xc9};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: xorl %edx, %edx. */
int32_t glue_enc_x86_xor_edx_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xd2};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: movl %ecx, %eax. */
int32_t glue_enc_x86_movl_ecx_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x89, 0xc8};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: xorl %eax, %edx (LCG s ^= t, s resident in edx). */
int32_t glue_enc_x86_xorl_eax_edx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0x31, 0xc2};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: incl %ecx. */
int32_t glue_enc_x86_incl_ecx(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[2] = {0xff, 0xc1};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 2) : -1;
}

/** x86: xorl %eax, -off(%rbp) (s ^= t in-place, avoid t stack slot). */
int32_t glue_enc_x86_xorl_eax_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
  int32_t disp;
  uint8_t b[6];
  if (!elf_ctx)
    return -1;
  disp = -off;
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x31;
    b[1] = 0x45;
    b[2] = (uint8_t)disp;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x31;
  b[1] = 0x85;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: mov %al, (%rbx,%rax,1). */
int32_t glue_enc_x86_mov_al_mem_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[3] = {0x88, 0x04, 0x03};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3) : -1;
}

/** x86: movzbl (%rbx,%rax,1), %ecx. */
int32_t glue_enc_x86_movzx_ecx_mem_rbx_rax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[4] = {0x0f, 0xb6, 0x0c, 0x03};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 4) : -1;
}

/** x86: add %ecx, -off(%rbp). */
int32_t glue_enc_x86_add_ecx_rbp_off(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t off) {
  int32_t disp = -off;
  uint8_t b[7];
  if (!elf_ctx)
    return -1;
  if (disp >= -128 && disp <= -1) {
    b[0] = 0x01;
    b[1] = 0x4d;
    b[2] = (uint8_t)disp;
    return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3);
  }
  b[0] = 0x01;
  b[1] = 0x8d;
  b[2] = (uint8_t)disp;
  b[3] = (uint8_t)(disp >> 8);
  b[4] = (uint8_t)(disp >> 16);
  b[5] = (uint8_t)(disp >> 24);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 6);
}

/** x86: imul %eax, %eax. */
int32_t glue_enc_x86_imul_eax_eax(struct platform_elf_ElfCodegenCtx *elf_ctx) {
  uint8_t b[3] = {0x0f, 0xaf, 0xc0};
  return elf_ctx ? pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, b, 3) : -1;
}
#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

/* ---------------------------------------------------------------------------
 * wave136: pipeline_asm_emit_fold_primitives pure-owned leave cold twins.
 * Live = runtime_pipeline_abi pure; these under #ifndef FROM_X only.
 * PLATFORM: SHARED.
 * --------------------------------------------------------------------------- */
#ifndef XLANG_RUNTIME_PIPELINE_ABI_FROM_X
/** Whether two VAR expr refs refer to the same variable name (B-CMP LCG xor while pattern match). */
int32_t glue_fold_expr_var_refs_same_c(struct ast_ASTArena *arena, int32_t a_ref, int32_t b_ref) {
  int32_t alen;
  int32_t blen;
  uint8_t abuf[128];
  uint8_t bbuf[128];
  int32_t k;
  if (a_ref <= 0 || b_ref <= 0 || !arena)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, a_ref) != 3 ||
      pipeline_expr_kind_ord_at(arena, b_ref) != 3)
    return 0;
  alen = pipeline_expr_var_name_len(arena, a_ref);
  blen = pipeline_expr_var_name_len(arena, b_ref);
  if (alen <= 0 || blen <= 0 || alen != blen || alen > 127)
    return 0;
  pipeline_expr_var_name_into(arena, a_ref, abuf);
  pipeline_expr_var_name_into(arena, b_ref, bbuf);
  k = 0;
  while (k < alen) {
    if (abuf[k] != bbuf[k])
      return 0;
    k++;
  }
  return 1;
}

/** Parse `while (i < n)`: left VAR i, right LIT or VAR n. */
int32_t glue_fold_parse_while_lt_i_n_c(struct ast_ASTArena *arena, int32_t cond_ref, int32_t *out_i_ref,
                                              int32_t *out_n_is_lit, int32_t *out_n_lit, int32_t *out_n_ref) {
  int32_t i_ref;
  int32_t n_side;
  if (!arena || cond_ref <= 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, cond_ref) != 16)
    return 0;
  i_ref = pipeline_expr_binop_left_ref_at(arena, cond_ref);
  n_side = pipeline_expr_binop_right_ref_at(arena, cond_ref);
  if (pipeline_expr_kind_ord_at(arena, i_ref) != 3)
    return 0;
  if (out_i_ref)
    *out_i_ref = i_ref;
  if (pipeline_expr_kind_ord_at(arena, n_side) == 0) {
    if (out_n_is_lit)
      *out_n_is_lit = 1;
    if (out_n_lit)
      *out_n_lit = pipeline_expr_int_val_at(arena, n_side);
    if (out_n_ref)
      *out_n_ref = 0;
    return 1;
  }
  if (pipeline_expr_kind_ord_at(arena, n_side) == 3) {
    if (out_n_is_lit)
      *out_n_is_lit = 0;
    if (out_n_lit)
      *out_n_lit = 0;
    if (out_n_ref)
      *out_n_ref = n_side;
    return 1;
  }
  return 0;
}

/** Same-block let binding integer literal init (`let n: i32 = 100000000`). */
int32_t glue_fold_block_let_init_lit_c(struct ast_ASTArena *arena, int32_t block_ref, int32_t var_ref,
                                              int32_t *out_lit) {
  int32_t vlen;
  int32_t nlet;
  int32_t li;
  uint8_t vbuf[128];
  if (!arena || block_ref <= 0 || var_ref <= 0 || pipeline_expr_kind_ord_at(arena, var_ref) != 3)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, var_ref);
  if (vlen <= 0 || vlen > 127)
    return 0;
  pipeline_expr_var_name_into(arena, var_ref, vbuf);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  li = 0;
  while (li < nlet) {
    int32_t llen = pipeline_block_let_name_len(arena, block_ref, li);
    if (llen == vlen) {
      int32_t is_match = 1;
      uint8_t lb[128];
      int32_t kk;
      int32_t init_ref;
      pipeline_block_let_name_copy64(arena, block_ref, li, lb);
      kk = 0;
      while (kk < vlen) {
        if (lb[kk] != vbuf[kk])
          is_match = 0;
        kk++;
      }
      if (is_match) {
        init_ref = pipeline_block_let_init_ref(arena, block_ref, li);
        if (init_ref > 0 && pipeline_expr_kind_ord_at(arena, init_ref) == 0) {
          if (out_lit)
            *out_lit = pipeline_expr_int_val_at(arena, init_ref);
          return 1;
        }
        return 0;
      }
    }
    li++;
  }
  return 0;
}

/** Parse `i * c1 + c2` or `c1 * i + c2` (loop_i32 LCG mixed term). */
int32_t glue_parse_i_mul_add_lit_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t i_ref,
                                          int32_t *out_c1, int32_t *out_c2) {
  int32_t ko;
  int32_t left;
  int32_t right;
  int32_t mul_ref;
  int32_t lit_ref;
  int32_t ml;
  int32_t mr;
  if (!arena || expr_ref <= 0 || i_ref <= 0)
    return 0;
  ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  if (ko == 6) {
    ml = pipeline_expr_binop_left_ref_at(arena, expr_ref);
    mr = pipeline_expr_binop_right_ref_at(arena, expr_ref);
    if (glue_fold_expr_var_refs_same_c(arena, ml, i_ref) && pipeline_expr_kind_ord_at(arena, mr) == 0) {
      if (out_c1)
        *out_c1 = pipeline_expr_int_val_at(arena, mr);
      if (out_c2)
        *out_c2 = 0;
      return 1;
    }
    return 0;
  }
  if (ko != 4)
    return 0;
  left = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  right = pipeline_expr_binop_right_ref_at(arena, expr_ref);
  if (pipeline_expr_kind_ord_at(arena, left) == 6 && pipeline_expr_kind_ord_at(arena, right) == 0) {
    mul_ref = left;
    lit_ref = right;
  } else {
    return 0;
  }
  ml = pipeline_expr_binop_left_ref_at(arena, mul_ref);
  mr = pipeline_expr_binop_right_ref_at(arena, mul_ref);
  if (glue_fold_expr_var_refs_same_c(arena, ml, i_ref) && pipeline_expr_kind_ord_at(arena, mr) == 0) {
    if (out_c1)
      *out_c1 = pipeline_expr_int_val_at(arena, mr);
    if (out_c2)
      *out_c2 = pipeline_expr_int_val_at(arena, lit_ref);
    return 1;
  }
  if (glue_fold_expr_var_refs_same_c(arena, mr, i_ref) && pipeline_expr_kind_ord_at(arena, ml) == 0) {
    if (out_c1)
      *out_c1 = pipeline_expr_int_val_at(arena, ml);
    if (out_c2)
      *out_c2 = pipeline_expr_int_val_at(arena, lit_ref);
    return 1;
  }
  return 0;
}

/** Whether expr is `target = target + 1`. */
int32_t glue_is_assign_var_add_one_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t target_ref) {
  int32_t left_ref;
  int32_t add_l;
  int32_t add_r;
  if (!arena || expr_ref <= 0 || pipeline_expr_kind_ord_at(arena, expr_ref) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, expr_ref);
  add_l = pipeline_expr_binop_left_ref_at(arena, pipeline_expr_binop_right_ref_at(arena, expr_ref));
  add_r = pipeline_expr_binop_right_ref_at(arena, pipeline_expr_binop_right_ref_at(arena, expr_ref));
  if (!glue_fold_expr_var_refs_same_c(arena, left_ref, target_ref))
    return 0;
  if (pipeline_expr_kind_ord_at(arena, pipeline_expr_binop_right_ref_at(arena, expr_ref)) != 4)
    return 0;
  if (!glue_fold_expr_var_refs_same_c(arena, add_l, target_ref))
    return 0;
  if (pipeline_expr_kind_ord_at(arena, add_r) != 0 || pipeline_expr_int_val_at(arena, add_r) != 1)
    return 0;
  return 1;
}

/** Whether expr is a field access on func's 0th formal parameter. */
int32_t glue_expr_is_param0_field_access_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                  int32_t func_idx, int32_t expr_ref) {
  if (!arena || !mod || func_idx < 0 || expr_ref <= 0 || pipeline_expr_kind_ord_at(arena, expr_ref) != 44)
    return 0;
  return glue_expr_is_func_param_at_c(arena, mod, func_idx,
                                     pipeline_expr_field_access_base_ref(arena, expr_ref), 0);
}

/** Whether func body is `return p.a + p.b` (param0 field sum). */
int32_t glue_fold_func_returns_param0_field_sum_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                         int32_t func_idx) {
  int32_t ret_ref;
  int32_t al;
  int32_t ar;
  ret_ref = glue_fold_func_return_operand_ref_c(arena, mod, func_idx);
  if (ret_ref <= 0 || pipeline_expr_kind_ord_at(arena, ret_ref) != 4)
    return 0;
  al = pipeline_expr_binop_left_ref_at(arena, ret_ref);
  ar = pipeline_expr_binop_right_ref_at(arena, ret_ref);
  if (!glue_expr_is_param0_field_access_c(arena, mod, func_idx, al))
    return 0;
  return glue_expr_is_param0_field_access_c(arena, mod, func_idx, ar) ? 1 : 0;
}

/** Whether expr is `pair.field = src_ref` (single-char field name). */
int32_t glue_is_field_assign_from_var_c(struct ast_ASTArena *arena, int32_t er, int32_t pair_ref,
                                               uint8_t field_ch, int32_t src_ref) {
  int32_t left_ref;
  int32_t right_ref;
  uint8_t fn[128];
  if (!arena || er <= 0 || pair_ref <= 0 || src_ref <= 0 || pipeline_expr_kind_ord_at(arena, er) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, er);
  right_ref = pipeline_expr_binop_right_ref_at(arena, er);
  if (pipeline_expr_kind_ord_at(arena, left_ref) != 44)
    return 0;
  if (!glue_fold_expr_var_refs_same_c(arena, pipeline_expr_field_access_base_ref(arena, left_ref), pair_ref))
    return 0;
  if (pipeline_expr_field_access_name_len(arena, left_ref) != 1)
    return 0;
  pipeline_expr_field_access_name_into(arena, left_ref, fn);
  if (fn[0] != field_ch)
    return 0;
  return glue_fold_expr_var_refs_same_c(arena, right_ref, src_ref) ? 1 : 0;
}

/** Whether expr is `pair.b = i + 1`. */
int32_t glue_is_field_assign_i_plus_one_c(struct ast_ASTArena *arena, int32_t er, int32_t pair_ref,
                                                 int32_t i_ref) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t add_l;
  int32_t add_r;
  uint8_t fn[128];
  if (!arena || er <= 0 || pipeline_expr_kind_ord_at(arena, er) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, er);
  right_ref = pipeline_expr_binop_right_ref_at(arena, er);
  if (pipeline_expr_kind_ord_at(arena, left_ref) != 44)
    return 0;
  if (!glue_fold_expr_var_refs_same_c(arena, pipeline_expr_field_access_base_ref(arena, left_ref), pair_ref))
    return 0;
  if (pipeline_expr_field_access_name_len(arena, left_ref) != 1)
    return 0;
  pipeline_expr_field_access_name_into(arena, left_ref, fn);
  if (fn[0] != (uint8_t)'b')
    return 0;
  if (pipeline_expr_kind_ord_at(arena, right_ref) != 4)
    return 0;
  add_l = pipeline_expr_binop_left_ref_at(arena, right_ref);
  add_r = pipeline_expr_binop_right_ref_at(arena, right_ref);
  if (!glue_fold_expr_var_refs_same_c(arena, add_l, i_ref))
    return 0;
  if (pipeline_expr_kind_ord_at(arena, add_r) != 0 || pipeline_expr_int_val_at(arena, add_r) != 1)
    return 0;
  return 1;
}

/** Whether expr is `s = s + add_pair(pair)`. */
int32_t glue_is_assign_s_plus_pair_field_sum_call_c(struct ast_ASTArena *arena, struct ast_Module *mod,
                                                           int32_t er, int32_t *out_s_ref, int32_t pair_ref) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t add_l;
  int32_t inner;
  int32_t callee_ref;
  int32_t arg0;
  uint8_t cname[128];
  int32_t clen;
  if (!arena || !mod || er <= 0 || pair_ref <= 0 || pipeline_expr_kind_ord_at(arena, er) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, er);
  right_ref = pipeline_expr_binop_right_ref_at(arena, er);
  if (pipeline_expr_kind_ord_at(arena, right_ref) != 4)
    return 0;
  add_l = pipeline_expr_binop_left_ref_at(arena, right_ref);
  inner = pipeline_expr_binop_right_ref_at(arena, right_ref);
  if (!glue_fold_expr_var_refs_same_c(arena, add_l, left_ref))
    return 0;
  if (pipeline_expr_kind_ord_at(arena, inner) != 48 || pipeline_expr_call_num_args_at(arena, inner) != 1)
    return 0;
  arg0 = pipeline_expr_call_arg_ref(arena, inner, 0);
  if (!glue_fold_expr_var_refs_same_c(arena, arg0, pair_ref))
    return 0;
  callee_ref = pipeline_expr_call_callee_ref_at(arena, inner);
  if (callee_ref <= 0 || pipeline_expr_kind_ord_at(arena, callee_ref) != 3)
    return 0;
  clen = pipeline_expr_var_name_len(arena, callee_ref);
  if (clen != 8)
    return 0;
  pipeline_expr_var_name_into(arena, callee_ref, cname);
  if (cname[0] != (uint8_t)'a' || cname[1] != (uint8_t)'d' || cname[2] != (uint8_t)'d' || cname[3] != (uint8_t)'_' ||
      cname[4] != (uint8_t)'p' || cname[5] != (uint8_t)'a' || cname[6] != (uint8_t)'i' || cname[7] != (uint8_t)'r')
    return 0;
  if (out_s_ref)
    *out_s_ref = left_ref;
  return 1;
}

/** Whether expr is `buf[i] = (i as u8)`. */
int32_t glue_is_assign_u8_index_store_cast_i_c(struct ast_ASTArena *arena, int32_t er, int32_t *out_buf_ref,
                                                      int32_t i_ref) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t as_op;
  if (!arena || er <= 0 || pipeline_expr_kind_ord_at(arena, er) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, er);
  right_ref = pipeline_expr_binop_right_ref_at(arena, er);
  if (pipeline_expr_kind_ord_at(arena, left_ref) != 47)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, pipeline_expr_index_base_ref(arena, left_ref)) != 3)
    return 0;
  if (!glue_fold_expr_var_refs_same_c(arena, pipeline_expr_index_index_ref(arena, left_ref), i_ref))
    return 0;
  if (!glue_expr_is_x_as_cast_at_c(arena, right_ref))
    return 0;
  as_op = pipeline_expr_as_operand_ref_at(arena, right_ref);
  if (!glue_fold_expr_var_refs_same_c(arena, as_op, i_ref))
    return 0;
  if (out_buf_ref)
    *out_buf_ref = pipeline_expr_index_base_ref(arena, left_ref);
  return 1;
}

/** Whether expr is `sum = sum + (buf[j] as i32)`. */
int32_t glue_is_assign_sum_plus_u8_index_cast_c(struct ast_ASTArena *arena, int32_t er, int32_t *out_sum_ref,
                                                       int32_t *out_buf_ref, int32_t j_ref) {
  int32_t left_ref;
  int32_t right_ref;
  int32_t add_l;
  int32_t as_op;
  int32_t ix_ref;
  if (!arena || er <= 0 || pipeline_expr_kind_ord_at(arena, er) != 28)
    return 0;
  left_ref = pipeline_expr_binop_left_ref_at(arena, er);
  right_ref = pipeline_expr_binop_right_ref_at(arena, er);
  if (pipeline_expr_kind_ord_at(arena, right_ref) != 4)
    return 0;
  add_l = pipeline_expr_binop_left_ref_at(arena, right_ref);
  as_op = pipeline_expr_binop_right_ref_at(arena, right_ref);
  if (!glue_fold_expr_var_refs_same_c(arena, add_l, left_ref))
    return 0;
  if (!glue_expr_is_x_as_cast_at_c(arena, as_op))
    return 0;
  ix_ref = pipeline_expr_as_operand_ref_at(arena, as_op);
  if (pipeline_expr_kind_ord_at(arena, ix_ref) != 47)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, pipeline_expr_index_base_ref(arena, ix_ref)) != 3)
    return 0;
  if (!glue_fold_expr_var_refs_same_c(arena, pipeline_expr_index_index_ref(arena, ix_ref), j_ref))
    return 0;
  if (out_sum_ref)
    *out_sum_ref = left_ref;
  if (out_buf_ref)
    *out_buf_ref = pipeline_expr_index_base_ref(arena, ix_ref);
  return 1;
}

/** Whether VAR expr name equals the name of body's let_idx-th let. */
int32_t glue_expr_var_name_eq_let_idx_c(struct ast_ASTArena *arena, int32_t var_expr_ref,
                                               int32_t body_ref, int32_t let_idx) {
  uint8_t vname[128];
  uint8_t lname[128];
  int32_t vlen;
  int32_t llen;
  int32_t k;
  if (!arena || var_expr_ref <= 0 || body_ref <= 0 || let_idx < 0)
    return 0;
  if (pipeline_expr_kind_ord_at(arena, var_expr_ref) != 3)
    return 0;
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  llen = pipeline_block_let_name_len(arena, body_ref, let_idx);
  if (vlen <= 0 || llen <= 0 || vlen != llen || vlen > 127)
    return 0;
  pipeline_expr_var_name_into(arena, var_expr_ref, vname);
  pipeline_block_let_name_copy64(arena, body_ref, let_idx, lname);
  k = 0;
  while (k < vlen) {
    if (vname[k] != lname[k])
      return 0;
    k++;
  }
  return 1;
}

#endif /* XLANG_RUNTIME_PIPELINE_ABI_FROM_X */

