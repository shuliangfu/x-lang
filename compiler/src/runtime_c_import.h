/**
 * runtime_c_import.h — shux-c C 前端 import 递归加载（Phase E-04 v33）
 *
 * 文件职责：声明 load_one_import / resolve_and_load_imports 的对外入口；仅 shux-c（OBJS_CORE）链接。
 * 所属模块：compiler 运行时 C import 加载；实现于 runtime_c_import.c。
 * 与其它文件的关系：bootstrap driver seed（SHUX_NO_C_FRONTEND）不链本 TU。
 */

#ifndef SHUX_RUNTIME_C_IMPORT_H
#define SHUX_RUNTIME_C_IMPORT_H

#include "ast.h"

/** 传递 import 列表上限（与 runtime.c MAX_ALL_DEPS 一致）。pipeline.sx 链 std 时 >32。 */
#define SHU_C_MAX_ALL_DEPS 128

/** import 对应 .sx 文件路径缓冲容量。 */
#define SHU_C_IMPORT_PATH_FS_CAP 512

/**
 * 解析并 typeck 全部 import（含传递依赖）；填入 direct dep 与 all_dep 列表。
 * 参数语义同原 runtime.c resolve_and_load_imports。
 * 返回值：0 成功；-1 失败且已释放已写入的 all_dep_*。
 */
int shu_c_resolve_and_load_imports(ASTModule *mod, const char **lib_roots, int n_lib_roots, const char *entry_dir,
    const char **defines, int ndefines, int allow_legacy_extern, ASTModule **dep_mods, int *ndep_out,
    ASTModule **all_dep_mods, char **all_dep_paths, char all_dep_fs[][SHU_C_IMPORT_PATH_FS_CAP], int *n_all_out,
    int max_deps);

/**
 * LSP 专用：解析并 typeck 全部 import 依赖，并记录各模块 .sx 路径（跨文件 Location.uri）。
 */
int shu_lsp_resolve_and_load_imports(ASTModule *mod, const char **lib_roots, int n_lib_roots, const char *entry_dir,
    ASTModule **dep_mods, int *ndep_out, ASTModule **all_dep_mods, char **all_dep_paths,
    char all_dep_fs[][SHU_C_IMPORT_PATH_FS_CAP], int *n_all_out, int max_deps);

#endif /* SHUX_RUNTIME_C_IMPORT_H */
