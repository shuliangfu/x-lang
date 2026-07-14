/* seeds/rt_run_asm_backend.from_x.c — G-02f-315 P2 runtime rest (asm backend)
 * Logic source: src/runtime/rt_run_asm_backend.x
 * Hybrid: SHUX_RT_RUN_ASM_BACKEND_FROM_X + ld -r into runtime_driver_no_c.o
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
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "diag.h"
#include "runtime_diag_codes.h"
#include "runtime_io_abi.h"
#include "runtime_driver_abi.h"
#include "runtime_pipeline_abi.h"
#include "runtime_link_abi.h"
#include "runtime_proc_abi.h"
#include "token.h"

#ifndef SHUX_TMP_PREFIX
#if !defined(_WIN32) && !defined(_WIN64)
#define SHUX_TMP_PREFIX "/tmp/shux_"
#else
#define SHUX_TMP_PREFIX "shux_"
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
  int32_t len;
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
extern char *shux_preprocess_with_path(const char *data, size_t len, const char *path, const char **defines, int n_defines, size_t *out_len);
extern char *shux_preprocess(const char *data, size_t len, const char **defines, int n_defines, size_t *out_len);
extern char *shux_preprocess_quiet(const char *data, size_t len, const char **defines, int n_defines, size_t *out_len);
extern void pipeline_diag_emitted_reset(void);
extern int pipeline_diag_emitted_get(void);
extern void diag_set_file(const char *path, const char *src, size_t len);
extern int driver_c_frontend_smoke(const char *input_path, char *src, const char **lib_roots_arr, int n_lib_roots);
extern size_t pipeline_sizeof_arena(void);
extern size_t pipeline_sizeof_module(void);
extern size_t pipeline_sizeof_elf_ctx(void);
extern void parser_parse_into_init(void *arena, void *module);
extern struct parser_ParseIntoResult parser_parse_into_buf(void *arena, void *module, uint8_t *data, int32_t len);
extern void parser_parse_into_set_main_index(void *module, int32_t main_idx);
extern int driver_get_module_num_funcs(void *m);
extern int32_t parser_get_module_num_imports(void *module);
extern void shux_get_entry_dir(const char *path, char *out, size_t out_sz);
extern int driver_deps_are_std_core_closure_only(char **dep_paths, int n_deps);
extern int typeck_ndep;
extern void *typeck_dep_module_ptrs[];
extern void *typeck_dep_arena_ptrs[];
extern void driver_dep_seeded_clear_all(void);
extern void driver_dep_seed_slots(void **arenas, void **modules, int n);
extern void driver_dep_publish_slot(int j, void *arena, void *module, const char *path);
extern void pipeline_set_dep_slots(void **arenas, void **modules);
extern void codegen_set_dep_slots_for_x_pipeline(struct ASTModule **mods, const char **paths, int n);
extern void codegen_set_preamble_has_core_option_result(int on);
extern void pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx);
extern void pipeline_asm_seed_std_net_struct_layouts(void *m);
extern int pipeline_asm_user_deps_need_coemit(char **dep_paths, int n_deps);
extern void pipeline_debug_module_funcs(void *module);
extern void driver_diagnostic_after_entry_parse_module(void *module);
extern int driver_check_diag_emitted_get(void);
extern int driver_c_typeck_entry(void *module, void *arena, const char *src, size_t len);
extern int driver_c_typeck_entry_large_stack(void *module, void *arena, const char *src, size_t len);
extern int32_t driver_get_pending_target_cpu_features(void);
extern int32_t driver_freestanding_get(void);
extern void driver_set_pipeline_entry_source_len(size_t len);
extern void driver_x_pipeline_skip_typeck_set(int v);
extern void driver_x_pipeline_skip_codegen_set(int v);
extern int asm_codegen_elf_o(void *module, void *arena, void *out_buf, void *elf_ctx, void *pctx);
extern int shux_pipeline_dep_prerun_for_asm_module_o(void *mod, void *arena, const uint8_t *src, size_t len, void *out, void *ctx);
extern int runtime_report_precise_parse_failure_if_known(const char *input_path, const char *src, size_t src_len);
extern void runtime_pipeline_elf_ctx_diag_note(uint8_t *ctx_bytes);
extern void runtime_diag_errno_path(const char *file, const char *kind, const char *op, const char *path);
extern void driver_unlink_failed_output(const char *out_path);

/**
 * -backend asm 专用：读文件、跑 .x pipeline、写 .o 或调 ld。与 run_compiler_c 内 asm 路径逻辑一致，供 driver_run_compiler_full 转调。
 */
#ifndef SHUX_RT_RUN_ASM_BACKEND_FROM_X

int driver_run_asm_backend(const char *input_path, const char *out_path, const char **lib_roots_arr, int n_lib_roots,
    const char *target, int argc, char **argv) {
    const char *defines[MAX_DEFINES];
    int ndefines = 0;
    driver_bump_stack_limit();
    if (argv && argc > 0)
        ndefines = driver_argv_collect_defines(argc, argv, defines, MAX_DEFINES);
    /** B-02：#[cfg] 与 -target triple 联动（asm 后端路径）。 */
    if (target)
        cfg_apply_compile_target_from_triple(target, (int)strlen(target));
    else
        cfg_reset_compile_target();
    ShuxRuntimeFileView raw_src_view;
    if (runtime_read_file_view(input_path, &raw_src_view) != 0) {
        diag_reportf_with_code(input_path, 0, 0, "io error", SHUX_DIAG_CODE_IO_IO001, NULL,
                               "cannot read file '%s'", input_path ? input_path : "?");
        return 1;
    }
    size_t src_len = 0;
    pipeline_diag_emitted_reset();
    char *src = shux_preprocess_with_path(raw_src_view.data, raw_src_view.length, input_path,
        ndefines > 0 ? defines : NULL, ndefines,
        &src_len);
    runtime_release_file_view(&raw_src_view);
    if (!src && !pipeline_diag_emitted_get()) {
        diag_reportf_with_code(input_path, 0, 0, "preprocess error", SHUX_DIAG_CODE_PREPROCESS_PP002, NULL,
                     "preprocess failed for '%s'", input_path);
        return 1;
    }
    if (!src)
        return 1;
    diag_set_file(input_path, src, src_len);
#if !defined(SHUX_NO_C_FRONTEND)
    /* 无 -o 烟测走 C 前端（含 import 时 X asm parse 易 0 func）；shux check 不走烟测。 */
    if (out_path == NULL && !driver_check_only_get()) {
        int smoke_rc = driver_c_frontend_smoke(input_path, src, lib_roots_arr, n_lib_roots);
        free(src);
        return smoke_rc;
    }
    /*
     * shux check + asm 后端：优先走下方 X pipeline（check_only_mode），与 compile 同 parse/typeck 路径。
     * 无 X pipeline 时回退 C typeck。
     */
#if !defined(SHUX_USE_X_PIPELINE)
    if (driver_check_only_get()) {
        int ck = driver_c_typeck_entry(input_path, src, lib_roots_arr, n_lib_roots, 1);
        free(src);
        return ck;
    }
#endif
#endif
    size_t arena_sz = pipeline_sizeof_arena();
    size_t module_sz = pipeline_sizeof_module();
    void *arena = malloc(arena_sz);
    void *module = malloc(module_sz);
    if (!arena || !module) {
        diag_report_with_code(NULL, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP005,
                              ".x pipeline allocation failed", NULL);
        if (arena) free(arena);
        if (module) free(module);
        free(src);
        return 1;
    }
    memset(arena, 0, arena_sz);
    memset(module, 0, module_sz);
    parser_parse_into_init(module, arena);
    struct parser_ParseIntoResult pr_imp = parser_parse_into_buf(arena, module, (uint8_t *)src, (int32_t)src_len);
    if (pr_imp.ok != 0) {
        if (runtime_report_precise_parse_failure_if_known(input_path, src, src_len)) {
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        diag_reportf_with_code(input_path, 0, 0, "parse error", SHUX_DIAG_CODE_PARSE_P001, NULL,
                     "asm backend parse_into_buf failed for '%s'",
                     input_path ? input_path : "?");
        free(arena);
        free(module);
        free(src);
        return 1;
    }
    parser_parse_into_set_main_index(module, pr_imp.main_idx);
    driver_set_pipeline_entry_source_len(src_len);
    if (getenv("SHUX_DEBUG_PIPE"))
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "pipeline debug: driver_first_parse num_funcs=%d src_len=%zu",
                     driver_get_module_num_funcs(module), src_len);
    /*
     * A-11 run-typeck-parse-count-gate：ENTRY_MODULE_ONLY 下 entry parse_into 即金标准；
     * 全量 asm_codegen_elf_o(typeck.x) 在 Docker 内易 OOM(137)，仅 stderr 指标 + 占位 .o。
     */
    if (driver_asm_parse_metric_only_from_env() && out_path != NULL) {
        extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
        extern void driver_diagnostic_after_entry_parse_module(void *module);
        driver_diagnostic_after_entry_parse(driver_get_module_num_funcs(module));
        driver_diagnostic_after_entry_parse_module(module);
        {
            FILE *metric_o = fopen(out_path, "wb");
            if (!metric_o) {
                diag_reportf_with_code(out_path, 0, 0, "io error", SHUX_DIAG_CODE_IO_IO001, NULL,
                             "cannot open parse-metric output '%s'",
                             out_path ? out_path : "?");
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            (void)fputc('\0', metric_o);
            if (fclose(metric_o) != 0) {
                diag_reportf_with_code(out_path, 0, 0, "io error", SHUX_DIAG_CODE_IO_IO001, NULL,
                             "failed to write parse-metric output '%s'",
                             out_path ? out_path : "?");
                free(arena);
                free(module);
                free(src);
                return 1;
            }
        }
        free(arena);
        free(module);
        free(src);
        return 0;
    }
    int32_t n_imports_entry = parser_get_module_num_imports(module);
    char entry_dir_buf[512];
    shux_get_entry_dir(input_path, entry_dir_buf, sizeof(entry_dir_buf));
    const char *entry_dir = entry_dir_buf;

    char *dep_sources[MAX_ALL_DEPS];
    size_t dep_lens[MAX_ALL_DEPS];
    char *dep_paths[MAX_ALL_DEPS];
    int n_deps = 0;
    /*
     * build_shux_asm 单模块 -o（SHUX_ASM_ENTRY_MODULE_ONLY + SHUX_ASM_BUILD_SKIP_TYPECK）：
     * 并列链 build_asm/*.o，勿 collect_deps 读 import 源（无 lib_root 时 rc=1 → 4B stub）。
     */
    const int skip_dep_file_load =
        driver_asm_entry_module_only_from_env() && driver_asm_build_skip_typeck() != 0;
    if (n_imports_entry > 0 && n_imports_entry <= 32) {
        if (skip_dep_file_load) {
            if (shux_load_direct_imports_for_asm_layout(module, lib_roots_arr, n_lib_roots, entry_dir, defines, ndefines,
                    dep_sources, dep_lens, dep_paths, &n_deps) != 0) {
                free(arena);
                free(module);
                free(src);
                return 1;
            }
        } else {
            char *cls[MAX_ALL_DEPS];
            size_t clens[MAX_ALL_DEPS];
            char *cpaths[MAX_ALL_DEPS];
            int n_closure = 0;
            if (shux_collect_deps_transitive(module, arena_sz, module_sz, lib_roots_arr, n_lib_roots, entry_dir, defines,
                    ndefines, cls, clens, cpaths, &n_closure) != 0) {
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            for (int rev = 0; rev < n_closure / 2; rev++) {
                int o = n_closure - 1 - rev;
                char *ts = cls[rev];
                cls[rev] = cls[o];
                cls[o] = ts;
                size_t tl = clens[rev];
                clens[rev] = clens[o];
                clens[o] = tl;
                char *tp = cpaths[rev];
                cpaths[rev] = cpaths[o];
                cpaths[o] = tp;
            }
            if (shux_merge_direct_then_transitive_deps(module, n_imports_entry, cls, clens, cpaths, n_closure, dep_sources,
                    dep_lens, dep_paths, &n_deps) != 0) {
                while (n_closure > 0) {
                    n_closure--;
                    free(cls[n_closure]);
                    free(cpaths[n_closure]);
                }
                free(arena);
                free(module);
                free(src);
                return 1;
            }
        }
    }
    /*
     * 入口已在上方 parser_parse_into_buf 解析（driver_first_parse）；勿再 memset module/arena，
     * 否则 pipeline 二次 strict parse 大模块仅 ~4 func（parser.x）；见 run-parser-parse-count-gate.sh。
     */
    typeck_ndep = 0;
    FILE *asm_out = NULL;
    int emit_elf_o = 0;
    void *elf_ctx_ptr = NULL;
    char asm_tmp_o_path[64];
    int asm_want_exe = 0;
    /*
     * 无 -o：前端烟测（run-import / run-stdlib-import 的 grep「parse OK|typeck OK」），
     * 与 driver_run_emit_c_path 的 stderr 两行一致；不链 a.out、不向 stdout 写对象/汇编。
     * 有 -o 时：后缀决定 .o/.s 或临时 .o + ld 可执行。
     */
    const int asm_smoke_only = (out_path == NULL);
    asm_tmp_o_path[0] = '\0';
    if (asm_smoke_only) {
        asm_want_exe = 0;
        emit_elf_o = 0;
    } else {
        asm_want_exe = shux_output_want_exe(out_path);
        if (asm_want_exe) {
            snprintf(asm_tmp_o_path, 64, "%sshux_asm_XXXXXX", SHUX_TMP_PREFIX);
            int fd = mkstemp(asm_tmp_o_path);
            if (fd < 0) {
                runtime_diag_errno_path(input_path, "build error", "mkstemp (asm)", asm_tmp_o_path);
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            asm_out = fdopen(fd, "wb");
            if (!asm_out) {
                runtime_diag_errno_path(input_path, "build error", "fdopen (asm)", asm_tmp_o_path);
                close(fd);
                unlink(asm_tmp_o_path);
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            emit_elf_o = 1;
        } else {
            asm_out = fopen(out_path, "wb");
            if (!asm_out) {
                runtime_diag_errno_path(out_path, "io error", "fopen (-o asm)", out_path);
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            emit_elf_o = shux_output_is_elf_o(out_path);
        }
    }
    if (emit_elf_o) {
        elf_ctx_ptr = malloc(pipeline_sizeof_elf_ctx());
        if (!elf_ctx_ptr) {
            diag_report_with_code(NULL, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP005,
                                  "ELF context allocation failed", NULL);
            driver_asm_fclose_asm_out(asm_out);
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        memset(elf_ctx_ptr, 0, pipeline_sizeof_elf_ctx());
    }
    void *dep_arenas[32];
    void *dep_modules[32];
    int j;
    for (j = 0; j < n_deps; j++) {
        dep_arenas[j] = malloc(arena_sz);
        dep_modules[j] = malloc(module_sz);
        if (!dep_arenas[j] || !dep_modules[j]) {
            diag_report_with_code(NULL, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP005,
                                  ".x pipeline dependency allocation failed", NULL);
            driver_asm_fclose_asm_out(asm_out);
            if (elf_ctx_ptr) free(elf_ctx_ptr);
            while (j > 0) { j--; free(dep_arenas[j]); free(dep_modules[j]); }
            while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
            free(arena);
            free(module);
            free(src);
            return 1;
        }
        memset(dep_arenas[j], 0, arena_sz);
        memset(dep_modules[j], 0, module_sz);
    }
    /*
     * CodegenOutBuf / PipelineDepCtx 动辄含 MiB 级内嵌缓冲区；在栈上会撑爆 ARM64/macOS 默认可用栈（线程默认约 512KiB）。
     * 改为堆分配，避免 driver_run_asm_backend 栈溢出。
     */
    struct codegen_CodegenOutBuf *out_buf = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*out_buf));
    struct ast_PipelineDepCtx *pctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*pctx));
    if (!out_buf || !pctx) {
        diag_report_with_code(NULL, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP006,
                              ".x pipeline output/context allocation failed", NULL);
        driver_asm_fclose_asm_out(asm_out);
        if (elf_ctx_ptr) free(elf_ctx_ptr);
        for (j = 0; j < n_deps; j++) { free(dep_arenas[j]); free(dep_modules[j]); }
        while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
        free(arena);
        free(module);
        free(src);
        if (out_buf) free(out_buf);
        if (pctx) pipeline_dep_ctx_heap_destroy(pctx);
        return 1;
    }
    shux_pipeline_fill_ctx_path_buffers(pctx, entry_dir, lib_roots_arr, n_lib_roots);
    /*
     * 入口 pipeline 阶段 use_asm_backend=0：与 shux check 同走 parse+merge+typeck（+ 可选 C codegen 填 out_buf），
     * 避免 use_asm_backend=1 时在 typeck_merge / typeck_x_ast 上对 core.option 等 dep 崩溃（134/139）。
     * 真 .o/.Mach-O 由下方 asm_asm_codegen_elf_o 在 use_asm_backend=1 时 emit。
     * dep 槽在预跑结束后再 shux_pipeline_pctx_seed_dep_slots（见下方 typeck_ndep 块）。
     */
    pctx->use_asm_backend = 0;
    pctx->target_arch = 0;
    if (target && (strstr(target, "aarch64") != NULL || strstr(target, "arm64") != NULL))
        pctx->target_arch = 1;
    if (target && strstr(target, "riscv64") != NULL)
        pctx->target_arch = 2;
    pctx->target_cpu_features = (int32_t)driver_get_pending_target_cpu_features();
#if defined(__APPLE__) && defined(__aarch64__)
    if (!target)
        pctx->target_arch = 1;
#endif
    pctx->use_macho_o = 0;
    pctx->use_coff_o = 0;
#if defined(__APPLE__)
    if (emit_elf_o)
        pctx->use_macho_o = 1;
#endif
#if defined(_WIN32) || defined(_WIN64) || defined(__CYGWIN__)
    /* Windows 宿主默认走 COFF 分支（lld-link/link），否则会错走 Linux/gcc 分支并用 fork 必失败。 */
    if (emit_elf_o)
        pctx->use_coff_o = 1;
#endif
    if (emit_elf_o && target && strstr(target, "windows") != NULL)
        pctx->use_coff_o = 1;
    if (emit_elf_o)
        pctx->asm_entry_module_only = driver_asm_entry_module_only_from_env();
    /**
     * build_shux_asm（SKIP_TYPECK）：dep 已由 build_asm/*.o 提供，仅编入口模块。
     * 用户多文件（tests/multi-file 等）：须在 asm_codegen_elf_o 内编入各 dep，否则 ld 缺 _foo_bar 等符号。
     */
    if (asm_want_exe && n_deps > 0 && !asm_smoke_only && driver_asm_build_skip_typeck() != 0)
        pctx->asm_entry_module_only = 1;
    /**
     * 用户单文件 -o（无 dep、非 build_shux_asm SKIP_TYPECK）：单函数仍 ENTRY_MODULE_ONLY
     *（return42 等烟测）；多函数单文件（C5 spill_probe 等）须 emit 全 TU 否则 ld 缺符号。
     */
    if (emit_elf_o && n_deps == 0 && !asm_smoke_only && driver_asm_build_skip_typeck() == 0 &&
        driver_get_module_num_funcs(module) <= 1)
        pctx->asm_entry_module_only = 1;
    /**
     * 用户单文件 import 仅 std/core 闭包（hello.x）：仅 emit entry，dep 由 io 桩 + ld 解析。
     * Why freestanding 例外：freestanding -backend asm 无预编译 std .o（nostdlib 链），
     *   std/core dep 须 co-emit 进入口 .o 否则 ld 缺符号（NL-06 smoke import 场景）。
     *   hosted 模式仍走 entry-only（dep 由 io.o/fs.o 等预编译 .o 提供）。
     */
    if (emit_elf_o && n_deps > 0 && !asm_smoke_only && driver_asm_build_skip_typeck() == 0 &&
        driver_freestanding_get() == 0 &&
        pipeline_asm_user_deps_need_coemit(dep_paths, n_deps) == 0)
        pctx->asm_entry_module_only = 1;
    driver_dep_seeded_clear_all();
    /*
     * build_shux_asm（SHUX_ASM_BUILD_SKIP_TYPECK + ENTRY_MODULE_ONLY）：dep 已由 build_asm/*.o 提供，仅 publish 槽位。
     * 用户链 exe（无 SKIP_TYPECK）：须 parse+typeck dep 以解析 import 符号名，仅跳过 dep codegen（pipeline.x）。
     */
    if (emit_elf_o && pctx->asm_entry_module_only && driver_asm_build_skip_typeck() != 0) {
        for (j = 0; j < n_deps; j++) {
            if (shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j], (const uint8_t *)dep_sources[j],
                    dep_lens[j]) != 0) {
                diag_reportf_with_code(dep_paths[j], 0, 0, "parse error", SHUX_DIAG_CODE_PARSE_P001, NULL,
                             "asm layout dep parse-only failed for '%s'",
                             dep_paths[j] ? dep_paths[j] : "?");
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx);
                for (int k = 0; k < n_deps; k++) {
                    free(dep_arenas[k]);
                    free(dep_modules[k]);
                }
                while (n_deps > 0) {
                    n_deps--;
                    free(dep_sources[n_deps]);
                    free(dep_paths[n_deps]);
                }
                driver_asm_fclose_asm_out(asm_out);
                if (elf_ctx_ptr)
                    free(elf_ctx_ptr);
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            driver_dep_publish_slot(j, dep_arenas[j], dep_modules[j], dep_paths[j]);
        }
    } else {
        for (j = 0; j < n_deps; j++) {
            struct ast_PipelineDepCtx *one_ctx = (struct ast_PipelineDepCtx *)calloc(1, sizeof(*one_ctx));
            struct codegen_CodegenOutBuf *dep_out = (struct codegen_CodegenOutBuf *)calloc(1, sizeof(*dep_out));
            if (!one_ctx || !dep_out) {
                diag_report_with_code(NULL, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP006,
                                      ".x pipeline dependency context/output allocation failed", NULL);
                pipeline_dep_ctx_heap_destroy(one_ctx);
                free(dep_out);
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx);
                for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
                driver_asm_fclose_asm_out(asm_out);
                if (elf_ctx_ptr) free(elf_ctx_ptr);
                while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            shux_pipeline_fill_ctx_path_buffers(one_ctx, shux_dep_prerun_entry_dir(entry_dir, lib_roots_arr, n_lib_roots),
                lib_roots_arr, n_lib_roots);
            shux_pipeline_one_ctx_for_dep_prerun(one_ctx, j, dep_modules, dep_arenas, dep_paths, n_deps,
            (const uint8_t *)dep_sources[j], dep_lens[j]);
            /*
             * 无 -o 烟测：dep 仅 parse 填槽；全量 .x typeck 在 strict typeck.o 上对 std.io 等大库易 SIGSEGV。
             * 有 -o 用户链仍 typeck dep（std.io 经 seed bridge）；入口走 C typeck。
             */
            int ec_loop;
            if (asm_smoke_only) {
                if (getenv("SHUX_ASM_DEBUG"))
                    diag_reportf(NULL, 0, 0, "note", NULL,
                                 "asm debug: dep_prerun[%d] path=%s len=%zu", (int)j,
                                 dep_paths[j] ? dep_paths[j] : "?", (size_t)dep_lens[j]);
                ec_loop = shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j]);
            } else if (emit_elf_o && shux_asm_user_std_dep_skip_x_typeck(dep_paths[j])) {
                /*
                 * 用户 asm -o：std.io/fs 由并列 *.o 提供 *_c，dep 仅 parse 填 import 槽；
                 * 勿对 read_fd 等跑 .x typeck（与 user_asm_seed_bridge dep skip emit 对齐）。
                 */
                ec_loop = shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j]);
            } else if (emit_elf_o && shux_asm_user_dep_parse_skip_typeck_path(dep_paths[j])) {
                /*
                 * std.net：须 co-emit listen/accept_many；parse_only 常 funcs=0，改 parse+skip typeck 填槽。
                 */
                ec_loop = shux_pipeline_dep_prerun_parse_skip_typeck(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j], (void *)dep_out, (void *)one_ctx);
                if (ec_loop == 0 && shux_asm_user_std_net_dep_path(dep_paths[j]))
                    pipeline_asm_seed_std_net_struct_layouts((struct ast_Module *)dep_modules[j]);
            } else if (emit_elf_o && pctx->asm_entry_module_only && driver_asm_build_skip_typeck() == 0) {
                /*
                 * ENTRY_MODULE_ONLY 且将走 C typeck 预检：dep 仅 parse 填槽，勿对整棵 dep 再跑 .x typeck（栈/耗时）。
                 * 入口模块类型由 driver_c_typeck_entry 与并列 build_asm/*.o 保证。
                 */
                ec_loop = shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j]);
#if defined(SHUX_ASM_USE_COMPILER_IMPL_C)
            } else if (emit_elf_o && !asm_smoke_only && !driver_asm_build_skip_typeck()) {
                /*
                 * B-strict shux_asm 用户多文件 -o：dep 仅 parse 填 import 槽；入口 skip .x typeck（见下方 set）。
                 * 注：std.string/heap 等 .x 符号须 shux-c 链 exe，或后续改 co-emit 填全量 func 槽。
                 */
                ec_loop = shux_pipeline_dep_prerun_parse_only(dep_modules[j], dep_arenas[j],
                    (const uint8_t *)dep_sources[j], (size_t)dep_lens[j]);
#endif
            } else {
                ec_loop = shux_pipeline_dep_prerun_for_asm_module_o(dep_modules[j], dep_arenas[j], (const uint8_t *)dep_sources[j],
                    (size_t)dep_lens[j], (void *)dep_out, (void *)one_ctx);
            }
            pipeline_dep_ctx_heap_destroy(one_ctx);
            free(dep_out);
            if (ec_loop != 0) {
                diag_reportf_with_code(dep_paths[j], 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP008, NULL,
                                       "pipeline failed for import '%s' (rc=%d)", dep_paths[j], ec_loop);
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx);
                for (int k = 0; k < n_deps; k++) { free(dep_arenas[k]); free(dep_modules[k]); }
                driver_asm_fclose_asm_out(asm_out);
                if (elf_ctx_ptr) free(elf_ctx_ptr);
                while (n_deps--) { free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                free(arena);
                free(module);
                free(src);
                return 1;
            }
            driver_dep_publish_slot(j, dep_arenas[j], dep_modules[j], dep_paths[j]);
        }
    }
    typeck_ndep = n_deps;
    for (j = 0; j < n_deps; j++) {
        typeck_dep_module_ptrs[j] = dep_modules[j];
        typeck_dep_arena_ptrs[j] = dep_arenas[j];
    }
    shux_pipeline_pctx_seed_dep_slots(pctx, dep_modules, dep_arenas, dep_paths, n_deps);
    pipeline_set_dep_slots(dep_arenas, dep_modules);
    driver_dep_seed_slots(dep_arenas, dep_modules, n_deps);
    codegen_set_dep_slots_for_x_pipeline((struct ASTModule **)dep_modules, (const char **)dep_paths, n_deps);
    codegen_set_preamble_has_core_option_result(1);
    /**
     * 入口已在上方 parser_parse_into_buf 解析进 module/arena；pipeline 内勿 pipeline_strict_parse_into_init 重 parse
     * （大模块 parser.x 二次 parse 仅 ~4 func，见 run-parser-parse-count-gate.sh）。
     */
    pctx->entry_already_parsed = 1;
    int ec = 0;
    {
        /* === SHUX_ASM_ENTRY_ONLY_DEBUG: 分段日志，定位 segfault === */
        const char *entry_name = input_path ? strrchr(input_path, '/') : NULL;
        entry_name = entry_name ? entry_name + 1 : input_path;
        if (getenv("SHUX_ASM_ENTRY_ONLY_DEBUG")) {
            diag_reportf(NULL, 0, 0, "note", NULL,
                         "asm entry debug: entry=%s n_deps=%d",
                         entry_name ? entry_name : "?", n_deps);
        }
        /* 1. 预检：当前文件长度 */
        if (getenv("SHUX_ASM_ENTRY_ONLY_DEBUG")) {
            diag_reportf(NULL, 0, 0, "note", NULL,
                         "asm entry debug: src_len=%zu entry_funcs=%d",
                         src_len, driver_get_module_num_funcs(module));
        }
        /* 2. 调 pipeline_run_x_pipeline */
        if (getenv("SHUX_ASM_ENTRY_ONLY_DEBUG")) {
            diag_report(NULL, 0, 0, "note",
                        "asm entry debug: BEFORE pipeline_run_x_pipeline", NULL);
        }
#if !defined(SHUX_NO_C_FRONTEND)
        /*
         * 用户程序 asm 编译：C typeck 预检（strict 链 typeck_c_orchestration_partial 提供真 typeck_module），
         * 再 skip pipeline 内 .x typeck（第 2+ CALL 实参仍可能 SIGSEGV）。
         */
        if (!driver_asm_build_skip_typeck()) {
            const char *skip_c_precheck = getenv("SHUX_ASM_SKIP_C_TYPECK_PRECHECK");
            if (skip_c_precheck == NULL || skip_c_precheck[0] == '\0' || skip_c_precheck[0] == '0') {
                if (driver_c_typeck_entry_large_stack(input_path, src, lib_roots_arr, n_lib_roots, 0) != 0) {
                    free(out_buf);
                    pipeline_dep_ctx_heap_destroy(pctx);
                    for (j = 0; j < n_deps; j++) {
                        free(dep_arenas[j]);
                        free(dep_modules[j]);
                    }
                    while (n_deps > 0) {
                        n_deps--;
                        free(dep_sources[n_deps]);
                        free(dep_paths[n_deps]);
                    }
                    free(arena);
                    free(module);
                    free(src);
                    return 1;
                }
            }
        }
#endif
        /*
         * 用户 asm -o：入口 pipeline 跳过 .x typeck（须在 #endif 外：shux_asm 为 SHUX_NO_C_FRONTEND 时仍要 skip）。
         * import 程序（dead_user 等）否则 typecheck_entry SIGSEGV。
         * 无 import 单文件仍须 typeck（struct field_access_offset）；仅 skip codegen，机器码由 asm_codegen_elf_o 生成。
         * std 库 .o 仍靠 C typeck 预检 + pipeline_fill_*_for_skipped_typeck；勿跑 x typeck（enc_label 失败）。
         * shux check + std/core 闭包：与 -o 多文件一致 skip 入口 .x typeck，parse 已在 smoke 路径完成。
         */
        if (!asm_smoke_only) {
            if (n_deps > 0)
                driver_x_pipeline_skip_typeck_set(1);
            /** 仅 parse+typeck（单文件）或 parse+填槽（多文件）；真机器码由 asm_asm_codegen_elf_o 生成。 */
            driver_x_pipeline_skip_codegen_set(1);
        } else {
            /*
             * asm_smoke_only（out_path==NULL，含 -c check 与无 -o smoke）：skip codegen。
             * 【Why】strict link 产出的 shux_asm 不链入 codegen_x.o（C codegen），
             * codegen_x_ast 是 bridge.c weak stub（返回 -1）；asm_smoke_only 调用 codegen
             * 会走 weak stub → XP001。-c check 语义只需验证语法与类型，codegen 错误
             * 由 -o 模式检测。-c flag 不设置 driver_check_only（仅 fmt/dep_prerun 设置），
             * 故以 asm_smoke_only 为判据而非 driver_check_only_get()。
             * 【Invariant】typeck skip 条件不变（仅 std/core 闭包多文件 skip typeck）；
             * 无 import 单文件仍走全量 typeck 填 field_access_offset。
             */
            if (n_deps > 0 && driver_deps_are_std_core_closure_only(dep_paths, n_deps)) {
                driver_x_pipeline_skip_typeck_set(1);
            }
            driver_x_pipeline_skip_codegen_set(1);
        }
        ec = shux_pipeline_run_x_pipeline_large_stack(module, arena, (const uint8_t *)src, src_len, (void *)out_buf, (void *)pctx);
        driver_x_pipeline_skip_typeck_set(0);
        driver_x_pipeline_skip_codegen_set(0);
        if (getenv("SHUX_ASM_ENTRY_ONLY_DEBUG")) {
            diag_reportf(NULL, 0, 0, "note", NULL,
                         "asm entry debug: AFTER pipeline_run_x_pipeline ec=%d funcs=%d out_len=%zu",
                         ec, driver_get_module_num_funcs(module), (size_t)out_buf->len);
        }
        /* 3. 如果是 segfault，上面的 fprintf 不会执行；需要更前置的分段日志 */
        if (ec != 0 && !driver_check_diag_emitted_get()) {
            diag_reportf(input_path, 0, 0, "note", NULL,
                         "smoke diagnostic: main pipeline returned %d", ec);
        }
    }
    pctx->use_asm_backend = 1;
    if (getenv("SHUX_ASM_DEBUG")) {
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "asm debug: backend after pipeline ec=%d num_funcs=%d out_asm_len=%zu",
                     ec, driver_get_module_num_funcs(module), (size_t)out_buf->len);
        pipeline_debug_module_funcs(module);
    }
    if (asm_smoke_only) {
        for (j = 0; j < n_deps; j++) {
            free(dep_arenas[j]);
            free(dep_modules[j]);
        }
        while (n_deps > 0) {
            n_deps--;
            free(dep_sources[n_deps]);
            free(dep_paths[n_deps]);
        }
        {
            int smoke_ec = ec;
            int smoke_num_funcs = driver_get_module_num_funcs(module);
            int smoke_diag_emitted = driver_check_diag_emitted_get();
            if (smoke_ec != 0 && !driver_check_diag_emitted_get())
                diag_reportf_with_code(input_path, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP001, NULL,
                             ".x pipeline failed for '%s' (stage=parse_into/typeck_x_ast/codegen_x_ast)",
                             input_path ? input_path : "?");
            else if (smoke_num_funcs <= 0)
                diag_reportf_with_code(input_path, 0, 0, "parse error", SHUX_DIAG_CODE_PARSE_P001, NULL,
                             "parse produced no functions for '%s'", input_path ? input_path : "?");
            else if (driver_check_only_get() && smoke_diag_emitted) {
                /* check 已有更具体失败诊断时，不再冒充 parse/typeck 成功摘要。 */
            }
            else if (driver_check_only_get()) {
                driver_print_x_smoke_summary(module, (size_t)out_buf->len);
                if (input_path)
                    driver_print_check_ok(input_path);
            } else
                driver_print_x_smoke_summary(module, (size_t)out_buf->len);
            free(out_buf);
            pipeline_dep_ctx_heap_destroy(pctx);
            free(arena);
            free(module);
            free(src);
            if (smoke_ec != 0) {
                driver_dep_seeded_clear_all();
                typeck_ndep = 0;
                return 1;
            }
            if (smoke_num_funcs <= 0) {
                driver_dep_seeded_clear_all();
                typeck_ndep = 0;
                return 1;
            }
            if (driver_check_only_get() && smoke_diag_emitted) {
                driver_dep_seeded_clear_all();
                typeck_ndep = 0;
                return 1;
            }
            /* 烟测与后续 -o 同进程时须清 dep 全局槽，否则第二次 asm 易 SIGSEGV（run-import 等）。 */
            driver_dep_seeded_clear_all();
            typeck_ndep = 0;
            return 0;
        }
    }
    if (ec == 0 && (out_buf->len > 0 || emit_elf_o)) {
        if (emit_elf_o && elf_ctx_ptr && !shux_asm_out_buf_is_object(out_buf ? out_buf->data : NULL, out_buf ? (size_t)out_buf->len : 0)) {
            /*
             * pipeline_run 后 driver_dep_seeded_clear_all 仅清全局槽；须把 dep 模块重新写入 pctx，
             * 且对用户多文件关闭 ENTRY_MODULE_ONLY，否则 asm_codegen_elf_o 只编 main、ld 缺 _foo_bar。
             */
            if (n_deps > 0) {
                for (j = 0; j < n_deps; j++)
                    driver_dep_publish_slot(j, dep_arenas[j], dep_modules[j], dep_paths[j]);
                typeck_ndep = n_deps;
                for (j = 0; j < n_deps; j++) {
                    typeck_dep_module_ptrs[j] = dep_modules[j];
                    typeck_dep_arena_ptrs[j] = dep_arenas[j];
                }
                pipeline_set_dep_slots(dep_arenas, dep_modules);
                driver_dep_seed_slots(dep_arenas, dep_modules, n_deps);
                shux_pipeline_pctx_seed_dep_slots(pctx, dep_modules, dep_arenas, dep_paths, n_deps);
                /*
                 * 多文件 -o 须编 dep 机器码；显式 SHUX_ASM_ENTRY_MODULE_ONLY=1（build_shux_asm / M8 单模块 -o）
                 * 时保持仅入口，dep 由并列 build_asm/*.o 提供，勿对 arch/x86_64 等 dep 再跑 asm emit。
                 * hello 等纯 std 闭包勿关 ENTRY_MODULE_ONLY（否则 co-emit std.fmt → SIGSEGV）。
                 */
                if (!driver_asm_entry_module_only_from_env() && pipeline_asm_user_deps_need_coemit(dep_paths, n_deps))
                    pctx->asm_entry_module_only = 0;
                pctx->use_asm_backend = 1;
            }
            shux_driver_asm_prepare_entry_elf_emit(module, arena, pctx);
            int32_t elf_ec = shux_asm_codegen_elf_o_large_stack(module, arena, (void *)pctx, (struct platform_elf_ElfCodegenCtx *)elf_ctx_ptr, (void *)out_buf);
            if (getenv("SHUX_ASM_DEBUG")) {
                diag_reportf(NULL, 0, 0, "note", NULL,
                             "asm debug: asm_codegen_elf_o elf_ec=%d elf_len=%zu",
                             (int)elf_ec, (size_t)out_buf->len);
            }
            if (elf_ec != 0 || out_buf->len <= 0) {
                diag_reportf_with_code(input_path, 0, 0, "codegen error", SHUX_DIAG_CODE_CODEGEN_CG002, NULL,
                                       "asm_codegen_elf_o failed (elf_ec=%d, out_len=%zu, num_funcs=%d)",
                                       (int)elf_ec, (size_t)out_buf->len, driver_get_module_num_funcs(module));
                if (elf_ec == SHUX_ASM_CODEGEN_ELF_EMPTY_TEXT_RC)
                    diag_report(NULL, 0, 0, "note",
                                "asm backend produced no object text; empty .o emission was rejected", NULL);
                if (elf_ec != 0 && elf_ctx_ptr)
                    runtime_pipeline_elf_ctx_diag_note((uint8_t *)elf_ctx_ptr);
                driver_unlink_failed_output(out_path);
                driver_asm_fclose_asm_out(asm_out);
                if (elf_ctx_ptr) free(elf_ctx_ptr);
                for (j = 0; j < n_deps; j++) { free(dep_arenas[j]); free(dep_modules[j]); }
                while (n_deps > 0) { n_deps--; free(dep_sources[n_deps]); free(dep_paths[n_deps]); }
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx);
                free(arena);
                free(module);
                free(src);
                return 1;
            }
        }
        fwrite(out_buf->data, 1, (size_t)out_buf->len, asm_out ? asm_out : stdout);
        if (!asm_out)
            fflush(stdout);
        driver_asm_fclose_asm_out(asm_out);
        asm_out = NULL;
        if (elf_ctx_ptr) { free(elf_ctx_ptr); elf_ctx_ptr = NULL; }
        for (j = 0; j < n_deps; j++) { free(dep_arenas[j]); free(dep_modules[j]); }
        while (n_deps > 0) {
            n_deps--;
            free(dep_sources[n_deps]);
            free(dep_paths[n_deps]);
        }
        if (asm_want_exe && asm_tmp_o_path[0]) {
            const char *asm_exe_out = out_path ? out_path : "a.out";
            /** elf emit 后主栈已深；nostdlib invoke_ld 前再抬高 soft limit（C6 -o exe）。 */
            driver_bump_stack_limit();
            int ld_ok = shux_invoke_ld_for_exe(asm_tmp_o_path, asm_exe_out, target, pctx->use_macho_o, pctx->use_coff_o, argv ? argv[0] : NULL,
                lib_roots_arr, n_lib_roots);
            unlink(asm_tmp_o_path);
            if (ld_ok != 0) {
                driver_unlink_failed_output(asm_exe_out);
                diag_reportf_with_code(NULL, 0, 0, "build error", SHUX_DIAG_CODE_BUILD_BLD001, NULL,
                             "ld failed (asm -> %s)", asm_exe_out);
                free(out_buf);
                pipeline_dep_ctx_heap_destroy(pctx);
                free(arena);
                free(module);
                free(src);
                return 1;
            }
        }
    } else {
        driver_asm_fclose_asm_out(asm_out);
        if (asm_want_exe && asm_tmp_o_path[0]) unlink(asm_tmp_o_path);
        if (elf_ctx_ptr) free(elf_ctx_ptr);
        for (j = 0; j < n_deps; j++) { free(dep_arenas[j]); free(dep_modules[j]); }
        while (n_deps > 0) {
            n_deps--;
            free(dep_sources[n_deps]);
            free(dep_paths[n_deps]);
        }
        if (ec != 0) {
            driver_unlink_failed_output(out_path);
            diag_reportf_with_code(input_path, 0, 0, "pipeline error", SHUX_DIAG_CODE_X_PIPELINE_XP001, NULL,
                         ".x pipeline failed for '%s' (stage=parse_into/typeck_x_ast/codegen_x_ast)",
                         input_path ? input_path : "?");
        }
    }
    if (ec == 0 && emit_elf_o && driver_get_module_num_funcs(module) <= 0) {
        diag_reportf_with_code(input_path, 0, 0, "parse error", SHUX_DIAG_CODE_PARSE_P001, NULL,
                     "parse produced no functions in '%s'", input_path ? input_path : "?");
        ec = -1;
    }
    driver_dep_seeded_clear_all();
    codegen_set_dep_slots_for_x_pipeline(NULL, NULL, 0);
    free(out_buf);
    pipeline_dep_ctx_heap_destroy(pctx);
    free(arena);
    free(module);
    free(src);
    return (ec != 0) ? 1 : 0;
}

#else /* SHUX_RT_RUN_ASM_BACKEND_FROM_X：产品 rest 仅 marker；业务体在 full .x */
int driver_run_asm_backend(const char *input_path, const char *out_path, const char **lib_roots_arr, int n_lib_roots,
    const char *target, int argc, char **argv);
#endif /* SHUX_RT_RUN_ASM_BACKEND_FROM_X */

int labi_rt_run_asm_backend_slice_marker(void) {
  return 1;
}
