/* seeds/rt_run_x_emit.from_x.c — G-02f-314 P2 runtime rest (-x -E emit)
 * Logic source: src/runtime/rt_run_x_emit.x
 * Hybrid: SHUX_RT_RUN_X_EMIT_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * Scope: driver_run_x_emit_c（读源 → pipeline → stdout）。
 * run_asm_backend / run_compiler_parsed 仍 mega rest。
 */
#include <limits.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "diag.h"
#include "runtime_diag_codes.h"
#include "runtime_io_abi.h"
#include "runtime_driver_abi.h"
#include "runtime_pipeline_abi.h"
#include "token.h"

#ifndef X_EMIT_MAX_LIB_ROOTS
#define X_EMIT_MAX_LIB_ROOTS 16
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
  int32_t len;
};

struct parser_ParseIntoResult {
  int32_t ok;
  int32_t main_idx;
};
struct ASTModule;

extern const char *driver_x_emit_c_path;
extern int driver_x_emit_c_want_extern;
extern int driver_x_emit_n_lib_roots;
extern const char *driver_x_emit_lib_roots[X_EMIT_MAX_LIB_ROOTS];

extern char *shux_preprocess_with_path(const char *data, size_t len, const char *path, const char **defines, int n_defines, size_t *out_len);
extern char *shux_preprocess(const char *data, size_t len, const char **defines, int n_defines, size_t *out_len);
extern void pipeline_diag_emitted_reset(void);
extern int pipeline_diag_emitted_get(void);
extern void diag_set_file(const char *path, const char *src, size_t len);
extern size_t pipeline_sizeof_arena(void);
extern size_t pipeline_sizeof_module(void);
extern void parser_parse_into_init(void *arena, void *module);
extern struct parser_ParseIntoResult parser_parse_into_buf(void *arena, void *module, uint8_t *data, int32_t len);
extern void parser_parse_into_set_main_index(void *module, int32_t main_idx);
extern int driver_get_module_num_funcs(void *m);
extern int32_t parser_diag_fail_at_token_kind(struct shux_slice_uint8_t *source);
extern int32_t parser_get_module_num_imports(void *module);
extern void shux_get_entry_dir(const char *path, char *out, size_t out_sz);
extern void pipeline_set_entry_dir(const char *dir);
extern int driver_x_emit_asm_direct_import_only(const char *input_path);
extern int driver_x_emit_asm_dep_parse_only_ok(const char *input_path, const char *dep_path);
extern int driver_x_emit_asm_dep_parse_skip_typeck_ok(const char *input_path, const char *dep_path);
extern int typeck_ndep;
extern void *typeck_dep_module_ptrs[];
extern void *typeck_dep_arena_ptrs[];
extern void driver_dep_seeded_clear_all(void);
extern void driver_set_current_dep_path_for_codegen(const char *path);
extern int shux_pipeline_dep_prerun_parse_skip_typeck(void *mod, void *arena, const uint8_t *src, size_t len, void *out, void *ctx);
extern int shux_pipeline_dep_prerun_parse_only(void *mod, void *arena, const uint8_t *src, size_t len);
extern int shux_pipeline_dep_prerun_typeck_only(void *mod, void *arena, const uint8_t *src, size_t len, void *out, void *ctx);
extern void driver_dep_publish_slot(int j, void *arena, void *module, const char *path);
extern void pipeline_set_dep_slots(void **arenas, void **modules);
extern void driver_dep_seed_slots(void **arenas, void **modules, int n);
extern void codegen_set_dep_slots_for_x_pipeline(struct ASTModule **mods, const char **paths, int n);
extern int runtime_report_precise_parse_failure_if_known(const char *input_path, const char *src, size_t src_len);
extern int driver_run_x_emit_c_extern_via_cparser(const char *input_path);
extern void pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx);

/** 执行刚解析的 -x -E（读文件、.x pipeline、写 stdout）；成功 0，失败 1。无 SHUX_USE_X_PIPELINE 时返回 1。 */
int driver_run_x_emit_c(void) {
    const char *input_path = driver_x_emit_c_path;
    driver_x_emit_c_path = NULL;
    if (!input_path) return 1;
#ifdef SHUX_USE_X_PIPELINE
    {
        /* 关闭 stdout 缓冲，避免重定向或管道下输出被截断（平台差异见 analysis/下一步开发分析.md §4.4） */
        (void)setvbuf(stdout, NULL, _IONBF, 0);
#if defined(SHUX_USE_X_DRIVER) && defined(SHUX_USE_X_PIPELINE)
        {
            const int want_extern = driver_x_emit_c_want_extern;
            driver_x_emit_c_want_extern = 0;
            if (want_extern) {
#if !defined(SHUX_NO_C_FRONTEND)
                return driver_run_x_emit_c_extern_via_cparser(input_path);
#else
                diag_report_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001,
                            "-x -E -E-extern requires C parser/codegen (rebuild without -DSHUX_NO_C_FRONTEND)",
                            NULL);
                return 1;
#endif
            }
        }
#endif
        ShuxRuntimeFileView raw_src_view;
        if (runtime_read_file_view(input_path, &raw_src_view) != 0) {
            diag_reportf_with_code(input_path, 0, 0, "io error", SHUX_DIAG_CODE_IO_IO001, NULL,
                                   "cannot read file '%s'", input_path ? input_path : "?");
            return 1;
        }
        size_t src_len = 0;
        pipeline_diag_emitted_reset();
        char *src = shux_preprocess_with_path(raw_src_view.data, raw_src_view.length, input_path, NULL, 0, &src_len);
        runtime_release_file_view(&raw_src_view);
        if (!src && !pipeline_diag_emitted_get()) {
            diag_reportf_with_code(input_path, 0, 0, "preprocess error", SHUX_DIAG_CODE_PREPROCESS_PP002, NULL,
                         "preprocess failed for '%s'", input_path);
            return 1;
        }
        if (!src)
            return 1;
        diag_set_file(input_path, src, src_len);
        size_t arena_sz = pipeline_sizeof_arena();
        size_t module_sz = pipeline_sizeof_module();
        void *arena = malloc(arena_sz);
        void *module = malloc(module_sz);
        if (!arena || !module) {
            diag_report_with_code(NULL, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP005,
                                  ".x pipeline allocation failed", NULL);
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        memset(arena, 0, arena_sz);
        memset(module, 0, module_sz);
        if (src_len > (size_t)INT32_MAX) {
            diag_reportf_with_code(input_path, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP007, NULL,
                                   ".x -E source too large for parser (>%d bytes): '%s'",
                                   INT32_MAX, input_path ? input_path : "?");
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        parser_parse_into_init(module, arena);
        /* 与 run_compiler_c 的 -x pipeline 一致：用 parse_into_buf，勿 parse_into（slice 路径在 seed 链易失败）。 */
        struct parser_ParseIntoResult pr =
            parser_parse_into_buf(arena, module, (uint8_t *)src, (int32_t)src_len);
        if (pr.ok != 0) {
            if (runtime_report_precise_parse_failure_if_known(input_path, src, src_len)) {
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            diag_reportf_with_code(input_path, 0, 0, "parse error", SHUX_DIAG_CODE_PARSE_P001, NULL,
                         ".x -E parse_into failed for '%s'",
                         input_path ? input_path : "?");
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        parser_parse_into_set_main_index(module, pr.main_idx);
        if (driver_get_module_num_funcs(module) <= 0) {
            struct shux_slice_uint8_t diag_src_slice = {(uint8_t *)src, src_len};
            int32_t fail_tok = parser_diag_fail_at_token_kind(&diag_src_slice);
            if (fail_tok == TOKEN_STRING) {
                diag_reportf_with_code(input_path, 0, 0, "parse error", SHUX_DIAG_CODE_PARSE_P001, NULL,
                                       "expected integer literal, float literal, identifier, 'true', 'false', 'if', "
                                       "'break', 'continue', 'return', 'panic', 'match', or '('");
                free(arena);
                free(module);
                free(src);
                return 1;
            }
        }
        int32_t n_imports = parser_get_module_num_imports(module);
        char entry_dir_buf[512];
        shux_get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
        const char *entry_dir = entry_dir_buf;
        /* 供 pipeline 内 resolve/read 单段 import 用；仅在有 import 时设置，避免单文件时影响 */
        if (n_imports > 0)
            pipeline_set_entry_dir(entry_dir_buf);
        /* 阶段 2.1：使用解析到的 -L 库根；无 -L 时退化为当前目录 */
        const char *lib_roots_arr[X_EMIT_MAX_LIB_ROOTS];
        int n_lib_roots = driver_x_emit_n_lib_roots;
        if (n_lib_roots == 0) {
            lib_roots_arr[0] = ".";
            n_lib_roots = 1;
        } else {
            for (int k = 0; k < n_lib_roots; k++) lib_roots_arr[k] = driver_x_emit_lib_roots[k];
        }
        char *dep_sources[MAX_ALL_DEPS];
        size_t dep_lens[MAX_ALL_DEPS];
        char *dep_paths[MAX_ALL_DEPS];
        int n_deps = 0;
        int asm_direct_import_only = driver_x_emit_asm_direct_import_only(input_path);
        for (int i = 0; i < MAX_ALL_DEPS; i++) {
            dep_sources[i] = NULL;
            dep_lens[i] = 0;
            dep_paths[i] = NULL;
        }
        if (n_imports > 0 && n_imports <= 32) {
            if (asm_direct_import_only) {
                if (shux_load_direct_imports_for_asm_layout(module, lib_roots_arr, n_lib_roots, entry_dir, NULL, 0,
                        dep_sources, dep_lens, dep_paths, &n_deps) != 0) {
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
            } else {
                char *cpaths[MAX_ALL_DEPS];
                int n_closure = 0;
                for (int i = 0; i < MAX_ALL_DEPS; i++)
                    cpaths[i] = NULL;
                if (shux_collect_dep_paths_transitive(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir,
                        NULL, 0, cpaths, &n_closure) != 0) {
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
                if (shux_merge_direct_then_transitive_dep_paths(module, n_imports, cpaths, n_closure, dep_paths, &n_deps) != 0) {
                    while (n_closure > 0) {
                        n_closure--;
                        free(cpaths[n_closure]);
                    }
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
            }
        }
        typeck_ndep = 0;
        /*
         * CodegenOutBuf / PipelineDepCtx 体积大；-x -E 路径同样堆分配避免栈溢出。
         */
        void *dep_arenas[32];
        void *dep_modules[32];
        for (int i = 0; i < n_deps; i++) {
            dep_arenas[i] = malloc(arena_sz);
            dep_modules[i] = malloc(module_sz);
            if (!dep_arenas[i] || !dep_modules[i]) {
                diag_report_with_code(NULL, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP005,
                                      ".x pipeline dependency allocation failed", NULL);
                while (i > 0) { i--; free(dep_arenas[i]); free(dep_modules[i]); }
                while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                free(arena); free(module); free(src);
                return 1;
            }
            memset(dep_arenas[i], 0, arena_sz);
            memset(dep_modules[i], 0, module_sz);
        }
        struct codegen_CodegenOutBuf *out_buf = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*out_buf));
        struct ast_PipelineDepCtx *pctx_e = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*pctx_e));
        if (!out_buf || !pctx_e) {
            diag_report_with_code(NULL, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP006,
                                  ".x -E output/context allocation failed", NULL);
            for (int di = 0; di < n_deps; di++) { free(dep_arenas[di]); free(dep_modules[di]); }
            while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena); free(module); free(src);
            if (out_buf) free(out_buf);
            if (pctx_e) pipeline_dep_ctx_heap_destroy(pctx_e);
            return 1;
        }
        shux_pipeline_fill_ctx_path_buffers(pctx_e, entry_dir_buf, lib_roots_arr, n_lib_roots);
        if (asm_direct_import_only)
            shux_pipeline_pctx_seed_dep_import_paths_only(pctx_e, dep_paths, n_deps);
        else
            shux_pipeline_pctx_seed_dep_slots(pctx_e, dep_modules, dep_arenas, dep_paths, n_deps);
        pctx_e->use_asm_backend = 0; /* -E 须走 C codegen 写 stdout */
        /* 与 driver_run_compiler_parsed 一致：逆拓扑 dep prerun parse+typeck，再编入口+deps。 */
        driver_dep_seeded_clear_all();
        for (int j = n_deps - 1; j >= 0; j--) {
            struct ast_PipelineDepCtx *one_ctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*one_ctx));
            struct codegen_CodegenOutBuf *dep_out = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*dep_out));
            char *dep_src = NULL;
            size_t dep_len = 0;
            int ec_dep;
            if (!one_ctx || !dep_out) {
                diag_report_with_code(NULL, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP006,
                                      ".x -E dependency context/output allocation failed", NULL);
                pipeline_dep_ctx_heap_destroy(one_ctx);
                free(dep_out);
                for (int di = 0; di < n_deps; di++) { free(dep_arenas[di]); free(dep_modules[di]); }
                while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx_e);
                free(arena); free(module); free(src);
                return 1;
            }
            shux_pipeline_fill_ctx_path_buffers(one_ctx, shux_dep_prerun_entry_dir(entry_dir_buf, lib_roots_arr, n_lib_roots),
                                                lib_roots_arr, n_lib_roots);
            char resolved[PATH_MAX];
            resolved[0] = '\0';
            if (asm_direct_import_only) {
                dep_src = dep_sources[j];
                dep_len = dep_lens[j];
            } else {
                ShuxRuntimeFileView raw_view;
                shux_resolve_import_file_path_multi(lib_roots_arr, n_lib_roots, entry_dir, dep_paths[j], resolved, sizeof(resolved));
                if (runtime_read_file_view(resolved, &raw_view) != 0) {
                    pipeline_diag_import_open_fail_once(dep_paths[j], resolved);
                    pipeline_dep_ctx_heap_destroy(one_ctx);
                    free(dep_out);
                    for (int di = 0; di < n_deps; di++) { free(dep_arenas[di]); free(dep_modules[di]); }
                    while (n_deps > 0) {
                        n_deps--;
                        if (dep_sources[n_deps]) free(dep_sources[n_deps]);
                        free(dep_paths[n_deps]);
                    }
                    free(out_buf);
                    pipeline_dep_ctx_heap_destroy(pctx_e);
                    free(arena); free(module); free(src);
                    return 1;
                }
                dep_src = shux_preprocess(raw_view.data, raw_view.length, NULL, 0, &dep_len);
                runtime_release_file_view(&raw_view);
                if (!dep_src) {
                    diag_reportf_with_code(resolved, 0, 0, "preprocess error", SHUX_DIAG_CODE_PREPROCESS_PP002, NULL,
                                 "preprocess failed for import '%s'", dep_paths[j]);
                    pipeline_dep_ctx_heap_destroy(one_ctx);
                    free(dep_out);
                    for (int di = 0; di < n_deps; di++) { free(dep_arenas[di]); free(dep_modules[di]); }
                    while (n_deps > 0) {
                        n_deps--;
                        if (dep_sources[n_deps]) free(dep_sources[n_deps]);
                        free(dep_paths[n_deps]);
                    }
                    free(out_buf);
                    pipeline_dep_ctx_heap_destroy(pctx_e);
                    free(arena); free(module); free(src);
                    return 1;
                }
            }
            shux_pipeline_one_ctx_for_dep_prerun(one_ctx, j, dep_modules, dep_arenas, dep_paths, n_deps,
            (const uint8_t *)dep_src, dep_len);
            driver_set_current_dep_path_for_codegen(dep_paths[j]);
            DiagContextSnapshot dep_diag_snapshot;
            const char *dep_diag_file = dep_paths[j];
            if (!asm_direct_import_only)
                dep_diag_file = resolved;
            diag_push_file(&dep_diag_snapshot, dep_diag_file, dep_src, dep_len);
            if (driver_x_emit_asm_dep_parse_skip_typeck_ok(input_path, dep_paths[j])) {
                ec_dep = shux_pipeline_dep_prerun_parse_skip_typeck(dep_modules[j], dep_arenas[j],
                                                                    (const uint8_t *)dep_src, dep_len,
                                                                    (void *)dep_out, (void *)one_ctx);
            } else if (asm_direct_import_only || driver_x_emit_asm_dep_parse_only_ok(input_path, dep_paths[j])) {
                ec_dep = shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                                                             (const uint8_t *)dep_src, dep_len);
            } else {
                if (getenv("SHUX_DEBUG_PIPE"))
                    diag_reportf(NULL, 0, 0, "note", NULL,
                                 "pipeline debug: dep prerun begin j=%d path=%s",
                                 j, dep_paths[j] ? dep_paths[j] : "?");
                ec_dep = shux_pipeline_dep_prerun_typeck_only(dep_modules[j], dep_arenas[j],
                                                              (const uint8_t *)dep_src, dep_len,
                                                              (void *)dep_out, (void *)one_ctx);
                if (getenv("SHUX_DEBUG_PIPE"))
                    diag_reportf(NULL, 0, 0, "note", NULL,
                                 "pipeline debug: dep prerun end j=%d path=%s rc=%d",
                                 j, dep_paths[j] ? dep_paths[j] : "?", ec_dep);
            }
            diag_restore(&dep_diag_snapshot);
            driver_set_current_dep_path_for_codegen(NULL);
            pipeline_dep_ctx_heap_destroy(one_ctx);
            free(dep_out);
            if (!asm_direct_import_only)
                free(dep_src);
            if (ec_dep != 0) {
                diag_reportf_with_code(dep_diag_file, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP008, NULL,
                                       "pipeline failed for import '%s' (dep prerun rc=%d)",
                                       dep_paths[j] ? dep_paths[j] : "?", ec_dep);
                for (int di = 0; di < n_deps; di++) { free(dep_arenas[di]); free(dep_modules[di]); }
                while (n_deps > 0) {
                    n_deps--;
                    if (dep_sources[n_deps]) free(dep_sources[n_deps]);
                    free(dep_paths[n_deps]);
                }
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx_e);
                free(arena); free(module); free(src);
                return 1;
            }
            driver_dep_publish_slot(j, dep_arenas[j], dep_modules[j], dep_paths[j]);
        }
        typeck_ndep = asm_direct_import_only ? 0 : n_deps;
        for (int j = 0; j < typeck_ndep; j++) {
            typeck_dep_module_ptrs[j] = dep_modules[j];
            typeck_dep_arena_ptrs[j] = dep_arenas[j];
        }
        if (asm_direct_import_only) {
            pipeline_set_dep_slots(dep_arenas, dep_modules);
            driver_dep_seed_slots(NULL, NULL, 0);
            codegen_set_dep_slots_for_x_pipeline(NULL, NULL, 0);
        } else {
            pipeline_set_dep_slots(dep_arenas, dep_modules);
            driver_dep_seed_slots(dep_arenas, dep_modules, n_deps);
            codegen_set_dep_slots_for_x_pipeline((struct ASTModule **)dep_modules, (const char **)dep_paths, n_deps);
            /* 设置 driver_dep_* 槽位，使 pipeline 内 resolve/load 时能拿到与当前 dep 一致的 arena/module。仅对 entry 跑一次 pipeline，其内部会 codegen 所有 deps + entry，避免对每个 dep 单独跑 pipeline 再 fwrite 导致 deps 的 C 被写两遍（重复符号）。 */
            pipeline_set_dep_slots(dep_arenas, dep_modules);
        }
        memset(arena, 0, arena_sz);
        memset(module, 0, module_sz);
        int ec = shux_pipeline_run_x_pipeline_large_stack(module, arena, (uint8_t *)src, src_len, (void *)out_buf, (void *)pctx_e);
        if (ec == 0 && out_buf->len > 0) {
            /* 平台差异诊断（分析文档 4.4）：main 段输出过短时打 stderr，便于 CI/本地确认是 len 错误还是内容只写了数字 */
            if (out_buf->len < 20) {
                char hexbuf[16 * 3 + 1];
                int hexlen = 0;
                hexbuf[0] = '\0';
                for (int di = 0; di < out_buf->len && di < 16 && hexlen + 4 < (int)sizeof(hexbuf); di++) {
                    hexlen += snprintf(hexbuf + hexlen, sizeof(hexbuf) - (size_t)hexlen,
                                       "%s%02x", di == 0 ? "" : " ", (unsigned char)out_buf->data[di]);
                }
                diag_reportf(input_path, 0, 0, "note", NULL,
                             "-x -E diagnostic: out_buf.len=%d first bytes: %s",
                             (int)out_buf->len, hexbuf);
            }
            fwrite(out_buf->data, 1, (size_t)out_buf->len, stdout);
            fflush(stdout);
            for (int j = n_deps - 1; j >= 0; j--) { free(dep_arenas[j]); free(dep_modules[j]); }
            while (n_deps > 0) {
                n_deps--;
                if (dep_sources[n_deps]) free(dep_sources[n_deps]);
                free(dep_paths[n_deps]);
            }
        } else {
            for (int j = n_deps - 1; j >= 0; j--) { free(dep_arenas[j]); free(dep_modules[j]); }
            while (n_deps > 0) {
                n_deps--;
                if (dep_sources[n_deps]) free(dep_sources[n_deps]);
                free(dep_paths[n_deps]);
            }
            if (ec != 0) {
                diag_reportf_with_code(input_path, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP003, NULL,
                             ".x pipeline failed for '%s'",
                             input_path ? input_path : "?");
            } else if (out_buf->len <= 0) {
                if (driver_get_module_num_funcs(module) <= 0) {
                    if (!runtime_report_precise_parse_failure_if_known(input_path, src, src_len)) {
                        diag_reportf_with_code(input_path, 0, 0, "parse error", SHUX_DIAG_CODE_PARSE_P001, NULL,
                                               "parse produced no functions in '%s'",
                                               input_path ? input_path : "?");
                    }
                    goto x_emit_c_done;
                }
                /* CI / cross-host: distinguish -x -E 「只吐 0」与真失败——空缓冲视为 codegen 路径未写入 */
                diag_reportf_with_code(input_path, 0, 0, "codegen error", SHUX_DIAG_CODE_CODEGEN_CG004, NULL,
                             "-x -E pipeline succeeded but codegen buffer is empty (ec=0 out_buf.len=%d); "
                             "check typeck/codegen/pipeline CodegenOutBuf",
                             (int)out_buf->len);
            }
        }
        int emit_ret = (ec != 0 || out_buf->len <= 0) ? 1 : 0;
x_emit_c_done:
        if (ec == 0 && out_buf->len <= 0)
            emit_ret = 1;
        free(out_buf);
        pipeline_dep_ctx_heap_destroy(pctx_e);
        free(arena);
        free(module);
        free(src);
        return emit_ret;
    }
#else
    (void)input_path;
    return 1;
#endif
}

int labi_rt_run_x_emit_slice_marker(void) {
  return 1;
}
