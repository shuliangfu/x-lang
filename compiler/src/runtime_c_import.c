/**
 * runtime_c_import.c — shux-c C 前端 import 递归加载（Phase E-04 v33）
 *
 * 文件职责：load_one_import / resolve_and_load_imports / shu_lsp_resolve_and_load_imports；
 *           自 runtime.c 迁出，供 shux-c 与带 C 前端的 runtime_driver 路径链接。
 * 所属模块：compiler 运行时；bootstrap driver seed（NO_C）不链本 TU。
 * 与其它文件的关系：依赖 runtime_pipeline_abi（路径/preprocess）、preprocess.o、lexer/parser/typeck。
 */

#include "runtime_c_import.h"
#include "runtime_pipeline_abi.h"
#include "runtime_io_abi.h"
#include "preprocess.h"
#include "lexer/lexer.h"
#include "parser/parser.h"
#include "typeck/typeck.h"
#include "lsp/lsp_diag.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define read_file runtime_read_file_malloc

/**
 * 递归加载单条 import：解析→递归子 import→typeck→加入 all_dep 列表。
 * 返回值：成功返回 ASTModule*；失败 NULL（调用方须释放已写入的 all_dep_*）。
 */
static ASTModule *load_one_import(const char *import_path, const char **lib_roots, int n_lib_roots, const char *entry_dir,
    const char **defines, int ndefines, int allow_legacy_extern, ASTModule **all_dep_mods, char **all_dep_paths,
    char all_dep_fs[][SHU_C_IMPORT_PATH_FS_CAP], int *n_all, int max_all) {
    int idx = shux_find_loaded_import_index(import_path, all_dep_paths, *n_all);

    if (idx >= 0)
        return all_dep_mods[idx];
    if (*n_all >= max_all) {
        fprintf(stderr, "shux: too many transitive imports\n");
        return NULL;
    }
    {
        char path[512];
        char dep_dir[512];
        ShuxRuntimeFileView raw_view;
        char *src;
        Lexer *lex;
        ASTModule *dep = NULL;
        int pr;

        shux_resolve_import_file_path_multi(lib_roots, n_lib_roots, entry_dir, import_path, path, sizeof(path));
        if (shux_import_dep_dir_from_path(path, dep_dir, sizeof(dep_dir)) != 0) {
            fprintf(stderr, "shux: import path too long for dep_dir '%s'\n", import_path);
            return NULL;
        }
        if (runtime_read_file_view(path, &raw_view) != 0) {
            fprintf(stderr, "shux: cannot open import '%s' (tried %s)\n", import_path, path);
            return NULL;
        }
        src = preprocess(raw_view.data, raw_view.length, defines, ndefines, NULL);
        runtime_release_file_view(&raw_view);
        if (!src) {
            fprintf(stderr, "shux: preprocess failed for import '%s'\n", import_path);
            return NULL;
        }
        lex = lexer_new(src);
        pr = parse(lex, &dep);
        lexer_free(lex);
        free(src);
        if (pr != 0 || !dep) {
            fprintf(stderr, "shux: failed to parse import '%s'\n", import_path);
            return NULL;
        }
        if (dep->num_imports > 0 && !dep->import_paths) {
            fprintf(stderr, "shux: internal error: module has num_imports but import_paths is NULL\n");
            ast_module_free(dep);
            return NULL;
        }
        for (int i = 0; i < dep->num_imports; i++) {
            ASTModule *sub = load_one_import(dep->import_paths[i], lib_roots, n_lib_roots, dep_dir, defines, ndefines,
                allow_legacy_extern, all_dep_mods, all_dep_paths, all_dep_fs, n_all, max_all);
            if (!sub) {
                ast_module_free(dep);
                return NULL;
            }
        }
        {
            ASTModule *deps[SHU_C_MAX_ALL_DEPS];
            int ndeps = 0;

            for (int j = 0; j < dep->num_imports && ndeps < SHU_C_MAX_ALL_DEPS; j++) {
                idx = shux_find_loaded_import_index(dep->import_paths[j], all_dep_paths, *n_all);
                if (idx >= 0)
                    deps[ndeps++] = all_dep_mods[idx];
            }
            lsp_diag_collect_begin();
            {
                const int old_allow_legacy_extern = typeck_set_allow_legacy_extern_calls(allow_legacy_extern ? 1 : 0);
                const int typeck_rc = typeck_module(dep, deps, ndeps, NULL, 0);
                typeck_set_allow_legacy_extern_calls(old_allow_legacy_extern);
                if (typeck_rc != 0) {
                lsp_diag_collect_end();
                lsp_diag_print_stderr_human(path);
                fprintf(stderr, "shux: typeck failed for import '%s' (file %s)\n", import_path, path);
                ast_module_free(dep);
                return NULL;
                }
            }
            lsp_diag_collect_end();
        }
        all_dep_mods[*n_all] = dep;
        all_dep_paths[*n_all] = strdup(import_path);
        if (!all_dep_paths[*n_all]) {
            ast_module_free(dep);
            return NULL;
        }
        if (all_dep_fs)
            (void)snprintf(all_dep_fs[*n_all], SHU_C_IMPORT_PATH_FS_CAP, "%s", path);
        (*n_all)++;
        return dep;
    }
}

/** 解析并 typeck 全部 import（含传递依赖）。 */
int shu_c_resolve_and_load_imports(ASTModule *mod, const char **lib_roots, int n_lib_roots, const char *entry_dir,
    const char **defines, int ndefines, int allow_legacy_extern, ASTModule **dep_mods, int *ndep_out,
    ASTModule **all_dep_mods, char **all_dep_paths, char all_dep_fs[][SHU_C_IMPORT_PATH_FS_CAP], int *n_all_out,
    int max_deps) {
    int n_all = 0;

    if (mod->num_imports > 0 && !mod->import_paths) {
        fprintf(stderr, "shux: internal error: entry module has num_imports but import_paths is NULL\n");
        return -1;
    }
    for (int i = 0; i < mod->num_imports && i < max_deps; i++) {
        ASTModule *m = load_one_import(mod->import_paths[i], lib_roots, n_lib_roots, entry_dir, defines, ndefines,
            allow_legacy_extern, all_dep_mods, all_dep_paths, all_dep_fs, &n_all, max_deps);
        if (!m) {
            while (n_all--) {
                free(all_dep_paths[n_all]);
                ast_module_free(all_dep_mods[n_all]);
            }
            return -1;
        }
        dep_mods[i] = m;
    }
    *ndep_out = mod->num_imports;
    *n_all_out = n_all;
    return 0;
}

/** LSP：解析并 typeck 全部 import，可选记录 fs 路径。 */
int shu_lsp_resolve_and_load_imports(ASTModule *mod, const char **lib_roots, int n_lib_roots, const char *entry_dir,
    ASTModule **dep_mods, int *ndep_out, ASTModule **all_dep_mods, char **all_dep_paths,
    char all_dep_fs[][SHU_C_IMPORT_PATH_FS_CAP], int *n_all_out, int max_deps) {
    if (!mod || !dep_mods || !ndep_out || !all_dep_mods || !all_dep_paths || !n_all_out || max_deps <= 0)
        return -1;
    return shu_c_resolve_and_load_imports(mod, lib_roots, n_lib_roots, entry_dir, NULL, 0, 0, dep_mods, ndep_out,
        all_dep_mods, all_dep_paths, all_dep_fs, n_all_out, max_deps);
}
