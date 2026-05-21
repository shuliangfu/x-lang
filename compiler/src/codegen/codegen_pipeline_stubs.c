/**
 * codegen_pipeline_stubs.c — 仅 SU pipeline 链接时提供 codegen_set_* 桩
 *
 * 当构建「不链 src/codegen/codegen.o」的实验目标（如 SHU_NO_C_FRONTEND）时，
 * runtime.c 中 pipeline 路径仍会调用 codegen_set_dep_slots / codegen_set_preamble，
 * 本文件提供空实现以满足链接，行为与「无跨 TU 状态」等价。
 */
#include "codegen.h"

void codegen_set_preamble_has_core_option_result(int on) { (void)on; }

void codegen_set_dep_slots_for_su_pipeline(struct ASTModule **mods, const char **paths, int n) {
    (void)mods;
    (void)paths;
    (void)n;
}
