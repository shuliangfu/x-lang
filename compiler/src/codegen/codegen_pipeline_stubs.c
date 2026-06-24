/**
 * codegen_pipeline_stubs.c — 仅 SX pipeline 链接时提供 codegen_set_* 桩
 *
 * 当构建「不链 src/codegen/codegen.o」的实验目标（如 SHUX_NO_C_FRONTEND）时，
 * runtime.c 中 pipeline 路径仍会调用 codegen_set_dep_slots / codegen_set_preamble，
 * 本文件提供空实现以满足链接，行为与「无跨 TU 状态」等价。
 */
#include "codegen.h"

void codegen_set_preamble_has_core_option_result(int on) { (void)on; }

void codegen_reset_preamble_skip_mask(void) { }
void codegen_or_preamble_skip_mask(unsigned mask) { (void)mask; }
unsigned codegen_get_preamble_skip_mask(void) { return 0; }

void codegen_set_dep_slots_for_sx_pipeline(struct ASTModule **mods, const char **paths, int n) {
    (void)mods;
    (void)paths;
    (void)n;
}

/**
 * B-02 #[cfg] -target：真实现见 src/lexer/cfg_eval.c（seed 链 DRIVER_SEED_SUPPORT_EXTRA 链接）。
 */

/**
 * WPO 单态符号名格式化桩：seed 不链 codegen.o 时 asm backend 仍 extern 本符号。
 * 返回 -1 表示无法格式化（调用方应走 fallback）。
 */
int codegen_wpo_mono_sym_format(const char *base, int nargs, const int *args, char *out, int cap) {
    (void)base;
    (void)nargs;
    (void)args;
    (void)out;
    (void)cap;
    return -1;
}

/**
 * C codegen 入口弱桩：B-strict experimental 不链 codegen.o 时 runtime 仍引用 -E / 库 emit 符号。
 * 返回 -1 表示不可用；真实现由 codegen.o 覆盖。
 */
__attribute__((weak)) int codegen_module_to_c(struct ASTModule *m, FILE *out, struct ASTModule **dep_mods, const char **dep_import_paths, int ndep,
    codegen_is_func_used_fn is_func_used, codegen_is_mono_used_fn is_mono_used, codegen_is_type_used_fn is_type_used, void *dce_ctx,
    char (*emitted_type_names)[CODEGEN_EMITTED_TYPE_NAME_MAX], int *n_emitted_inout, int max_emitted) {
    (void)m;
    (void)out;
    (void)dep_mods;
    (void)dep_import_paths;
    (void)ndep;
    (void)is_func_used;
    (void)is_mono_used;
    (void)is_type_used;
    (void)dce_ctx;
    (void)emitted_type_names;
    (void)n_emitted_inout;
    (void)max_emitted;
    return -1;
}

__attribute__((weak)) int codegen_library_module_to_c(struct ASTModule *m, const char *import_path,
    struct ASTModule **lib_dep_mods, const char **lib_dep_paths, int n_lib_dep,
    FILE *out,
    codegen_is_func_used_fn is_func_used, codegen_is_mono_used_fn is_mono_used, codegen_is_type_used_fn is_type_used, void *dce_ctx,
    char (*emitted_type_names)[CODEGEN_EMITTED_TYPE_NAME_MAX], int *n_emitted_inout, int max_emitted,
    const char *emit_entry_path) {
    (void)m;
    (void)import_path;
    (void)lib_dep_mods;
    (void)lib_dep_paths;
    (void)n_lib_dep;
    (void)out;
    (void)is_func_used;
    (void)is_mono_used;
    (void)is_type_used;
    (void)dce_ctx;
    (void)emitted_type_names;
    (void)n_emitted_inout;
    (void)max_emitted;
    (void)emit_entry_path;
    return -1;
}
