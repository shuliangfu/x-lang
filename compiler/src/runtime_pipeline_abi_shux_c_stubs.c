/**
 * runtime_pipeline_abi_shux_c_stubs.c — shux-c 冷启动链接桩（NL-07 v4 / E-04）
 *
 * 【职责】
 * shux-c（OBJS_CORE + C 前端）不含 parser_x.o / pipeline_x.o / ast_pool 胶层，
 * 但 runtime_pipeline_abi.o / runtime_driver_abi.o 仍引用 X 管线符号。
 * 弱桩供 build_tool / 首次 shux-c 链入；bootstrap-driver-seed 链 X 前端时由真符号覆盖。
 *
 * 【范围】
 * 仅满足链接；调用返回失败/空，shux-c 冷路径不走 asm pipeline 分支。
 */

#include <stdint.h>
#include <stddef.h>
#include <stdio.h>

/* SHUX_WEAK: POSIX 用 weak attribute；Windows/MinGW 不支持 weak 函数符号，改为正常定义，
 * 配合 Makefile 的 -Wl,--allow-multiple-definition 解决重复定义冲突。 */
#ifndef SHUX_WEAK
#if defined(_WIN32) || defined(_WIN64)
#define SHUX_WEAK
#else
#define SHUX_WEAK __attribute__((weak))
#endif
#endif

/** codegen.x 辅助 emit；C 前端 shux-c 冷启动弱桩。 */
SHUX_WEAK void codegen_emit_fmt_json_helpers_once(FILE *out) {
    (void)out;
}

/** CORE-009 builtin inline 包装器 emit；冷启动弱桩（真实现见 codegen.c）。 */
SHUX_WEAK void codegen_emit_builtin_inline_decls(FILE *out) {
    (void)out;
}

/** 与 runtime_pipeline_abi.c / runtime.c 一致的 parse 结果布局。 */
struct parser_ParseIntoResult {
    int32_t ok;
    int32_t main_idx;
};

struct shux_slice_uint8_t {
    const uint8_t *ptr;
    size_t len;
};

struct ast_Module;
struct ast_ASTArena;
struct ast_PipelineDepCtx;

/** asm 后端 ELF 生成桩；冷启动 shux-c 不走 asm 分支。 */
SHUX_WEAK int32_t asm_asm_codegen_elf_o(void *module, void *arena, void *ctx, void *elf_ctx, void *out_buf) {
    (void)module;
    (void)arena;
    (void)ctx;
    (void)elf_ctx;
    (void)out_buf;
    return -1;
}

/** driver 模块查询桩。 */
SHUX_WEAK int32_t driver_get_module_num_funcs(void *module) {
    (void)module;
    return 0;
}

SHUX_WEAK int32_t driver_get_module_main_func_index(void *module) {
    (void)module;
    return -1;
}

/** pipeline 模块函数查询桩。 */
SHUX_WEAK int32_t pipeline_module_num_funcs(void *module) {
    (void)module;
    return 0;
}

SHUX_WEAK int32_t pipeline_module_func_is_extern_at(void *module, int32_t idx) {
    (void)module;
    (void)idx;
    return 0;
}

/** parser 模块 import 计数桩。 */
SHUX_WEAK int32_t parser_get_module_num_imports(void *module) {
    (void)module;
    return 0;
}

/** parser import 路径写入桩。 */
SHUX_WEAK void parser_get_module_import_path(void *module, int32_t idx, uint8_t *path_buf) {
    (void)module;
    (void)idx;
    if (path_buf)
        path_buf[0] = '\0';
}

/** parser parse 初始化桩。 */
SHUX_WEAK void parser_parse_into_init(void *module, void *arena) {
    (void)module;
    (void)arena;
}

/** parser parse 桩；返回失败。 */
SHUX_WEAK struct parser_ParseIntoResult parser_parse_into(void *arena, void *module,
                                                                      struct shux_slice_uint8_t *source) {
    (void)arena;
    (void)module;
    (void)source;
    struct parser_ParseIntoResult pr = { 0, -1 };
    return pr;
}

/** pipeline X 入口桩。 */
SHUX_WEAK int pipeline_run_x_pipeline(void *module, void *arena, const uint8_t *source_data,
                                                   size_t source_len, void *out_buf, void *ctx) {
    (void)module;
    (void)arena;
    (void)source_data;
    (void)source_len;
    (void)out_buf;
    (void)ctx;
    return -1;
}

/** pipeline dep ctx 桩。 */
SHUX_WEAK void ast_pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx) {
    (void)ctx;
}

SHUX_WEAK int32_t ast_pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path,
                                                               int32_t len) {
    (void)ctx;
    (void)path;
    (void)len;
    return 0;
}

SHUX_WEAK void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx,
                                                           struct ast_Module *m) {
    (void)ctx;
    (void)idx;
    (void)m;
}

SHUX_WEAK void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx,
                                                          struct ast_ASTArena *a) {
    (void)ctx;
    (void)idx;
    (void)a;
}

SHUX_WEAK void ast_pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n) {
    (void)ctx;
    (void)n;
}

SHUX_WEAK void ast_pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx,
                                                                uint8_t *bytes, int32_t len) {
    (void)ctx;
    (void)idx;
    (void)bytes;
    (void)len;
}

SHUX_WEAK int32_t pipeline_asm_user_dep_skip_x_typeck(uint8_t *path) {
    (void)path;
    return 0;
}

SHUX_WEAK int32_t pipeline_asm_user_std_net_dep_path(uint8_t *path) {
    (void)path;
    return 0;
}

SHUX_WEAK int32_t pipeline_codegen_path_is_std_io_driver_bytes(uint8_t *path) {
    (void)path;
    return 0;
}

SHUX_WEAK void asm_skip_heavy_set_pipeline_ctx(void *ctx) {
    (void)ctx;
}

SHUX_WEAK void pipeline_fill_array_lit_types_for_skipped_typeck(void *module, void *arena) {
    (void)module;
    (void)arena;
}

SHUX_WEAK void pipeline_fill_soa_field_access_for_asm_emit(void *module, void *arena) {
    (void)module;
    (void)arena;
}

SHUX_WEAK size_t pipeline_sizeof_arena(void) {
    return 4096u;
}

SHUX_WEAK size_t pipeline_sizeof_module(void) {
    return 4096u;
}

SHUX_WEAK void ast_module_free(struct ast_Module *mod) {
    (void)mod;
}

/** pipeline 解析/typeck 依赖；冷启动 C 前端 check 不走 X dep prerun，弱桩返回失败。 */
SHUX_WEAK int32_t pipeline_parse_set_main_from_buf_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                 uint8_t *data, int32_t len) {
    (void)module;
    (void)arena;
    (void)data;
    (void)len;
    return -1;
}

SHUX_WEAK int32_t pipeline_load_and_sync_direct_import_deps_c(struct ast_Module *module,
                                                                            struct ast_ASTArena *arena,
                                                                            struct ast_PipelineDepCtx *ctx) {
    (void)module;
    (void)arena;
    (void)ctx;
    return -1;
}

SHUX_WEAK int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx) {
    (void)ctx;
    return 0;
}

SHUX_WEAK void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx,
                                                               uint8_t *dst) {
    (void)ctx;
    (void)idx;
    if (!dst)
        return;
    for (int i = 0; i < 64; i++)
        dst[i] = 0;
}

SHUX_WEAK int32_t pipeline_module_main_func_index(struct ast_Module *m) {
    (void)m;
    return -1;
}

SHUX_WEAK int32_t pipeline_typeck_dep_prerun_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                                  struct ast_PipelineDepCtx *ctx) {
    (void)module;
    (void)arena;
    (void)ctx;
    return -1;
}

SHUX_WEAK void pipeline_module_fixup_with_arena_stmt_orders(struct ast_Module *m, struct ast_ASTArena *a) {
    (void)m;
    (void)a;
}

SHUX_WEAK int32_t pipeline_module_func_name_len_at(struct ast_Module *m, int32_t func_index) {
    (void)m;
    (void)func_index;
    return 0;
}

SHUX_WEAK uint8_t pipeline_module_func_name_byte_at(struct ast_Module *m, int32_t fi, int32_t i) {
    (void)m;
    (void)fi;
    (void)i;
    return 0;
}

SHUX_WEAK void pipeline_module_func_name_copy64(struct ast_Module *m, int32_t fi, uint8_t *dst) {
    int i;
    (void)m;
    (void)fi;
    if (!dst)
        return;
    for (i = 0; i < 64; i++)
        dst[i] = 0;
}

SHUX_WEAK int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t func_index) {
    (void)m;
    (void)func_index;
    return 0;
}

SHUX_WEAK int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br) {
    (void)a;
    (void)br;
    return 0;
}

SHUX_WEAK int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br) {
    (void)a;
    (void)br;
    return 0;
}

SHUX_WEAK int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *a, int32_t br) {
    (void)a;
    (void)br;
    return 0;
}

SHUX_WEAK int32_t ast_ast_block_num_regions(struct ast_ASTArena *a, int32_t br) {
    (void)a;
    (void)br;
    return 0;
}

SHUX_WEAK int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *a, int32_t br) {
    (void)a;
    (void)br;
    return 0;
}

SHUX_WEAK int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br) {
    (void)a;
    (void)br;
    return 0;
}
