/**
 * runtime_pipeline_abi_shux_c_stubs.c — shux-c 冷启动链接桩（NL-07 v4 / E-04）
 *
 * 【职责】
 * shux-c（OBJS_CORE + C 前端）不含 parser_sx.o / pipeline_sx.o / ast_pool 胶层，
 * 但 runtime_pipeline_abi.o / runtime_driver_abi.o 仍引用 SX 管线符号。
 * 弱桩供 build_tool / 首次 shux-c 链入；bootstrap-driver-seed 链 SX 前端时由真符号覆盖。
 *
 * 【范围】
 * 仅满足链接；调用返回失败/空，shux-c 冷路径不走 asm pipeline 分支。
 */

#include <stdint.h>
#include <stddef.h>
#include <stdio.h>

/** codegen.sx 辅助 emit；C 前端 shux-c 冷启动弱桩。 */
__attribute__((weak)) void codegen_emit_fmt_json_helpers_once(FILE *out) {
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

/** preprocess.sx 桥接；冷启动返回 -1。 */
__attribute__((weak)) int32_t typeck_preprocess_sx_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf,
                                                       int32_t out_cap) {
    (void)src;
    (void)src_len;
    (void)out_buf;
    (void)out_cap;
    return -1;
}

/** driver/pipeline 统一名；转发至 typeck_preprocess_sx_buf 弱桩。 */
__attribute__((weak)) int32_t preprocess_sx_buf(const uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf,
                                                int32_t out_cap) {
    return typeck_preprocess_sx_buf(source_buf, source_len, out_buf, out_cap);
}

/** asm 后端 ELF 生成桩；冷启动 shux-c 不走 asm 分支。 */
__attribute__((weak)) int32_t asm_asm_codegen_elf_o(void *module, void *arena, void *ctx, void *elf_ctx, void *out_buf) {
    (void)module;
    (void)arena;
    (void)ctx;
    (void)elf_ctx;
    (void)out_buf;
    return -1;
}

/** preprocess define 桩（C preprocess.o 不提供 SX 符号名）。 */
__attribute__((weak)) void preprocess_define_reset(void) {
}

__attribute__((weak)) int32_t preprocess_if_stack_len(void) {
    return 0;
}

__attribute__((weak)) void preprocess_define_add(const char *name) {
    (void)name;
}

/** driver 模块查询桩。 */
__attribute__((weak)) int32_t driver_get_module_num_funcs(void *module) {
    (void)module;
    return 0;
}

__attribute__((weak)) int32_t driver_get_module_main_func_index(void *module) {
    (void)module;
    return -1;
}

/** pipeline 模块函数查询桩。 */
__attribute__((weak)) int32_t pipeline_module_num_funcs(void *module) {
    (void)module;
    return 0;
}

__attribute__((weak)) int32_t pipeline_module_func_is_extern_at(void *module, int32_t idx) {
    (void)module;
    (void)idx;
    return 0;
}

/** parser 模块 import 计数桩。 */
__attribute__((weak)) int32_t parser_get_module_num_imports(void *module) {
    (void)module;
    return 0;
}

/** parser import 路径写入桩。 */
__attribute__((weak)) void parser_get_module_import_path(void *module, int32_t idx, uint8_t *path_buf) {
    (void)module;
    (void)idx;
    if (path_buf)
        path_buf[0] = '\0';
}

/** parser parse 初始化桩。 */
__attribute__((weak)) void parser_parse_into_init(void *module, void *arena) {
    (void)module;
    (void)arena;
}

/** parser parse 桩；返回失败。 */
__attribute__((weak)) struct parser_ParseIntoResult parser_parse_into(void *arena, void *module,
                                                                      struct shux_slice_uint8_t *source) {
    (void)arena;
    (void)module;
    (void)source;
    struct parser_ParseIntoResult pr = { 0, -1 };
    return pr;
}

/** pipeline SX 入口桩。 */
__attribute__((weak)) int pipeline_run_sx_pipeline(void *module, void *arena, const uint8_t *source_data,
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
__attribute__((weak)) void ast_pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx) {
    (void)ctx;
}

__attribute__((weak)) int32_t ast_pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path,
                                                               int32_t len) {
    (void)ctx;
    (void)path;
    (void)len;
    return 0;
}

__attribute__((weak)) void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx,
                                                           struct ast_Module *m) {
    (void)ctx;
    (void)idx;
    (void)m;
}

__attribute__((weak)) void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx,
                                                          struct ast_ASTArena *a) {
    (void)ctx;
    (void)idx;
    (void)a;
}

__attribute__((weak)) void ast_pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n) {
    (void)ctx;
    (void)n;
}

__attribute__((weak)) void ast_pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx,
                                                                uint8_t *bytes, int32_t len) {
    (void)ctx;
    (void)idx;
    (void)bytes;
    (void)len;
}

__attribute__((weak)) int32_t pipeline_asm_user_dep_skip_sx_typeck(uint8_t *path) {
    (void)path;
    return 0;
}

__attribute__((weak)) int32_t pipeline_asm_user_std_net_dep_path(uint8_t *path) {
    (void)path;
    return 0;
}

__attribute__((weak)) int32_t pipeline_codegen_path_is_std_io_driver_bytes(uint8_t *path) {
    (void)path;
    return 0;
}

__attribute__((weak)) void asm_skip_heavy_set_pipeline_ctx(void *ctx) {
    (void)ctx;
}

__attribute__((weak)) void pipeline_fill_array_lit_types_for_skipped_typeck(void *module, void *arena) {
    (void)module;
    (void)arena;
}

__attribute__((weak)) void pipeline_fill_soa_field_access_for_asm_emit(void *module, void *arena) {
    (void)module;
    (void)arena;
}

__attribute__((weak)) size_t pipeline_sizeof_arena(void) {
    return 4096u;
}

__attribute__((weak)) size_t pipeline_sizeof_module(void) {
    return 4096u;
}

__attribute__((weak)) void ast_module_free(struct ast_Module *mod) {
    (void)mod;
}
