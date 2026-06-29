/**
 * runtime_pipeline_abi.c — 编译器 C 侧 pipeline import / dep 槽 ABI 实现（Phase E-04 v24～v30）
 *
 * 文件职责：import 路径解析；dep 全局槽；v29～v31 预处理/typeck/asm ELF；v32 shux_preprocess。
 * 所属模块：compiler 运行时；被 runtime.c pipeline / run_compiler_c 链接。
 * 与其它文件的关系：仅依赖 POSIX access/realpath；不 include C 前端头。
 */

#include "runtime_pipeline_abi.h"
#include "runtime_driver_abi.h"
#include "runtime_io_abi.h"
#include "preprocess.h"

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/** preprocess.sx 生成；pipeline/import 与 runtime preprocess() 共用。 */
extern int32_t preprocess_sx_buf(const uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf, int32_t out_cap);
extern void preprocess_define_reset(void);
extern int32_t preprocess_if_stack_len(void);
extern void preprocess_define_add(const char *name);

/** typeck/pipeline 兼容 dep 侧车（pipeline_gen.c get_dep_* / pipeline_set_dep）。 */
void *typeck_dep_module_ptrs[32];
void *typeck_dep_arena_ptrs[32];
int typeck_ndep;

/**
 * 清 typeck dep 侧车；driver_dep_seeded_clear_all 调用，避免悬空指针。
 */
void driver_typeck_dep_sidecar_clear(void) {
    int i;
    typeck_ndep = 0;
    for (i = 0; i < 32; i++) {
        typeck_dep_arena_ptrs[i] = NULL;
        typeck_dep_module_ptrs[i] = NULL;
    }
}

/** 按 dep 下标取 module 指针；越界返回 NULL。 */
void *get_dep_module(int32_t i) {
    if (i < 0 || i >= typeck_ndep)
        return NULL;
    return typeck_dep_module_ptrs[i];
}

/** 按 dep 下标取 arena 指针；越界返回 NULL。 */
void *get_dep_arena(int32_t i) {
    if (i < 0 || i >= typeck_ndep)
        return NULL;
    return typeck_dep_arena_ptrs[i];
}

/** 当前 dep 数量。 */
int32_t get_ndep(void) {
    return (int32_t)typeck_ndep;
}

/** pipeline_gen.c 别名：与 get_dep_module 相同。 */
void *typeck_get_dep_module(int32_t i) {
    return get_dep_module(i);
}

/** pipeline_gen.c 别名：与 get_dep_arena 相同。 */
void *typeck_get_dep_arena(int32_t i) {
    return get_dep_arena(i);
}

/** 写入单 dep 槽（pipeline.sx 编排 import 加载时调用）。 */
void pipeline_set_dep(int32_t i, void *mod, void *arena) {
    if (i < 0 || i >= 32)
        return;
    typeck_dep_module_ptrs[i] = mod;
    typeck_dep_arena_ptrs[i] = arena;
}

/** 设置 dep 数量上限 32。 */
void pipeline_set_ndep(int32_t n) {
    typeck_ndep = n <= 32 ? n : 32;
}

/**
 * 对原始 .sx 做 preprocess.sx 条件编译扫描，写入新分配缓冲 NUL 结尾字符串。
 * 参数：path_diag 用于错误信息；defines/ndefines 注入 -D 宏。
 * 返回值：0 成功；否则写 stderr、不分配 *out_src。
 */
int shux_preprocess_raw_to_malloc(const unsigned char *raw, size_t raw_len, char **out_src, size_t *out_src_len,
    const char *path_diag, const char **defines, int ndefines) {
    int di;
    if (raw_len > (size_t)SHUX_PIPELINE_CTX_BUF_SIZE) {
        fprintf(stderr,
            "shux: entry file too large for .sx preprocessor (%zu > %d): '%s'\n",
            raw_len,
            SHUX_PIPELINE_CTX_BUF_SIZE,
            path_diag ? path_diag : "?");
        return -1;
    }
    uint8_t *scratch = (uint8_t *)malloc((size_t)SHUX_PIPELINE_CTX_BUF_SIZE);
    if (!scratch)
        return -1;
    preprocess_define_reset();
    for (di = 0; di < ndefines; di++)
        if (defines && defines[di])
            preprocess_define_add(defines[di]);
    int32_t n = preprocess_sx_buf(raw, (ptrdiff_t)raw_len, scratch, (int32_t)SHUX_PIPELINE_CTX_BUF_SIZE);
    if (n < 0) {
        free(scratch);
        if (preprocess_if_stack_len() != 0)
            fprintf(stderr, "preprocess: unclosed #if\n");
        else
            fprintf(stderr, "shux: .sx preprocess failed for '%s'\n", path_diag ? path_diag : "?");
        return -1;
    }
    if (preprocess_if_stack_len() != 0) {
        free(scratch);
        fprintf(stderr, "preprocess: unclosed #if\n");
        return -1;
    }
    char *dup = (char *)malloc((size_t)n + 1);
    if (!dup) {
        free(scratch);
        return -1;
    }
    memcpy(dup, scratch, (size_t)n);
    dup[n] = '\0';
    free(scratch);
    *out_src = dup;
    *out_src_len = (size_t)n;
    return 0;
}

/**
 * 将逻辑 import 路径转为 lib_root 下的 .sx 文件路径（'.' → '/'）。
 * 参数：见 runtime_pipeline_abi.h。
 * 副作用：写入 path，保证 NUL 结尾（path_size>0 时）。
 */
void shux_import_path_to_file_path(const char *lib_root, const char *import_path, char *path, size_t path_size) {
    const char *r = lib_root && lib_root[0] ? lib_root : ".";
    size_t off = (size_t)snprintf(path, path_size, "%s/", r);
    for (const char *s = import_path; *s && off + 1 < path_size; s++) {
        if (*s == '.')
            path[off++] = '/';
        else
            path[off++] = *s;
    }
    if (off + 4 <= path_size)
        snprintf(path + off, path_size - off, ".sx");
}

/**
 * 从入口 .sx 路径得到所在目录；无目录时写入 "."。
 * 参数：见 runtime_pipeline_abi.h。
 */
void shux_get_entry_dir(const char *input_path, char *entry_dir, size_t size) {
    if (!input_path || !entry_dir || size == 0) {
        if (size)
            entry_dir[0] = '\0';
        return;
    }
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

/**
 * 判断 import 是否为文件路径（相对/绝对/.sx），而非逻辑模块名 std.io。
 * 返回值：非 0 表示文件路径形式。
 */
int shux_import_path_is_file_path(const char *import_path) {
    if (!import_path || !import_path[0])
        return 0;
    if (import_path[0] == '/' || import_path[0] == '.')
        return 1;
    if (strchr(import_path, '/') != NULL)
        return 1;
    size_t n = strlen(import_path);
    if (n >= 3 && strcmp(import_path + n - 3, ".sx") == 0)
        return 1;
    return 0;
}

/**
 * 将相对/绝对文件路径解析为可打开的 .sx 路径（相对 entry_dir）。
 * 参数：见 runtime_pipeline_abi.h。
 */
void shux_resolve_file_import_path(const char *entry_dir, const char *import_path, char *path, size_t path_size) {
    char tmp[1024];
    if (import_path[0] == '/') {
        (void)snprintf(tmp, sizeof(tmp), "%s", import_path);
    } else if (entry_dir && entry_dir[0]) {
        (void)snprintf(tmp, sizeof(tmp), "%s/%s", entry_dir, import_path);
    } else {
        (void)snprintf(tmp, sizeof(tmp), "%s", import_path);
    }
#if defined(_POSIX_VERSION) || defined(__APPLE__)
    {
        char resolved[1024];
        if (realpath(tmp, resolved) != NULL) {
            (void)snprintf(path, path_size, "%s", resolved);
            return;
        }
    }
#endif
    (void)snprintf(path, path_size, "%s", tmp);
}

/**
 * 在 lib_roots 与 entry_dir 下解析 import 到可读 .sx 路径。
 * 参数：见 runtime_pipeline_abi.h；未找到时 path 仍写入最后一次尝试路径。
 */
void shux_resolve_import_file_path_multi(const char **lib_roots, int n_lib_roots, const char *entry_dir,
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
        /* 单段 import（如 preprocess）：再试 lib_root/import/import.sx */
        if (strchr(import_path, '.') == NULL && path_size >= 16) {
            int n = (int)strlen(import_path);
            if (n > 0 && n < 64) {
                (void)snprintf(path, path_size, "%s/%.64s/%.64s.sx", lib_root, import_path, import_path);
                if (access(path, R_OK) == 0)
                    return;
            }
        }
        if (strchr(import_path, '.') != NULL && path_size >= 16) {
            size_t off = (size_t)snprintf(path, path_size, "%s/", lib_root);
            for (const char *s = import_path; *s && off + 1 < path_size; s++)
                path[off++] = (char)(*s == '.' ? '/' : *s);
            if (off + 9 <= path_size)
                (void)snprintf(path + off, path_size - off, "/mod.sx");
            if (access(path, R_OK) == 0)
                return;
            shux_import_path_to_file_path(lib_root, import_path, path, path_size);
            if (access(path, R_OK) == 0)
                return;
        }
    }
    /* 入口同目录的单段 fallback */
    if (entry_dir && entry_dir[0] && strchr(import_path, '.') == NULL) {
        (void)snprintf(path, path_size, "%s/%.255s.sx", entry_dir, import_path);
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
            snprintf(path + off, path_size - off, ".sx");
        if (access(path, R_OK) == 0)
            return;
        if (off + (size_t)8 <= path_size)
            (void)snprintf(path + off, path_size - off, "/mod.sx");
        if (access(path, R_OK) == 0)
            return;
    }
}

/** pipeline dep 全局槽：arena/module 指针、import 路径注册表、seeded 标记。 */
static void *driver_dep_arena_ptrs[SHUX_DRIVER_DEP_SLOT_MAX];
static void *driver_dep_module_ptrs[SHUX_DRIVER_DEP_SLOT_MAX];
static const char *driver_dep_path_registry[SHUX_DRIVER_DEP_SLOT_MAX];
static int driver_dep_seeded[SHUX_DRIVER_DEP_SLOT_MAX];

extern size_t pipeline_sizeof_arena(void);
extern size_t pipeline_sizeof_module(void);

/**
 * 查询 dep 槽 i 是否已由 C 侧预填（pipeline 不再 read/parse）。
 * 参数：i 槽下标 0..31。
 * 返回值：1 已 seeded，0 否或 i 越界。
 */
int32_t driver_dep_seeded_get(int32_t i) {
    if (i < 0 || i >= SHUX_DRIVER_DEP_SLOT_MAX)
        return 0;
    return driver_dep_seeded[i] ? 1 : 0;
}

/**
 * 设置 dep 槽 seeded 标志（run_compiler_sx_path 预填后调用）。
 * 参数：i 槽下标；v 非 0 表示 seeded。
 */
void driver_dep_seeded_set(int32_t i, int32_t v) {
    if (i >= 0 && i < SHUX_DRIVER_DEP_SLOT_MAX)
        driver_dep_seeded[i] = (v != 0);
}

/**
 * 批量预填 dep 槽指针并标记 seeded；entry pipeline 复用不重载。
 * 参数：arenas/modules 各 32 槽；n 有效 dep 数。
 */
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

/**
 * 单槽发布：dep 预跑 parse 完成后供 pipeline_load 按 import 路径绑定。
 * 参数：import_path 逻辑路径指针须存活至 clear_all（通常 dep_paths[j]）。
 */
void driver_dep_publish_slot(int32_t i, void *arena, void *module, const char *import_path) {
    if (i < 0 || i >= SHUX_DRIVER_DEP_SLOT_MAX)
        return;
    driver_dep_arena_ptrs[i] = arena;
    driver_dep_module_ptrs[i] = module;
    driver_dep_seeded[i] = 1;
    if (import_path)
        driver_dep_path_registry[i] = import_path;
}

/**
 * 按 import 逻辑路径查 dep 预跑全局槽。
 * 返回值：槽下标 0..31，未 publish 返回 -1。
 */
int32_t driver_dep_slot_for_path(const char *path) {
    int i;
    if (!path)
        return -1;
    for (i = 0; i < SHUX_DRIVER_DEP_SLOT_MAX; i++) {
        if (driver_dep_path_registry[i] && strcmp(driver_dep_path_registry[i], path) == 0)
            return i;
    }
    return -1;
}

/**
 * entry pipeline 返回后清除 seeded 与槽指针；并同步清 runtime.c typeck dep 侧车。
 */
void driver_dep_seeded_clear_all(void) {
    int i;
    for (i = 0; i < SHUX_DRIVER_DEP_SLOT_MAX; i++) {
        driver_dep_seeded[i] = 0;
        driver_dep_path_registry[i] = NULL;
        driver_dep_arena_ptrs[i] = NULL;
        driver_dep_module_ptrs[i] = NULL;
    }
    driver_typeck_dep_sidecar_clear();
}

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

/** typeck.sx 导出名：转发 driver_dep_module_buf。 */
uint8_t *typeck_driver_dep_module_buf(int32_t i) {
    return driver_dep_module_buf(i);
}

/** typeck.sx 导出名：转发 driver_dep_seeded_get。 */
int32_t typeck_driver_dep_seeded_get(int32_t i) {
    return driver_dep_seeded_get(i);
}

/**
 * 在已加载 import 列表中查找下标。
 * 参数：import_path 逻辑路径；all_paths/n_all 已加载列表。
 * 返回值：下标或 -1。
 */
int shux_find_loaded_import_index(const char *import_path, char **all_paths, int n_all) {
    for (int i = 0; i < n_all; i++)
        if (all_paths[i] && strcmp(all_paths[i], import_path) == 0)
            return i;
    return -1;
}

/**
 * dep 预跑 resolve import 时用 lib root（-L）优先于主文件 entry_dir。
 * 参数：main_entry_dir 入口目录；lib_roots/n_lib_roots 与 -L 一致。
 * 返回值：优先 lib_roots[0] 或 main_entry_dir。
 */
const char *shux_dep_prerun_entry_dir(const char *main_entry_dir, const char **lib_roots, int n_lib_roots) {
    if (lib_roots && n_lib_roots > 0 && lib_roots[0] && lib_roots[0][0])
        return lib_roots[0];
    return main_entry_dir;
}

/**
 * 从入口文件路径推导 -E 时库模块的 C 前缀。
 * 参数：input_path 入口 .sx 路径。
 * 返回值：静态字符串字面量前缀名。
 */
const char *shux_entry_lib_name_from_path(const char *input_path) {
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
    /* std/json/json.sx 等：basename 去 .sx/.su 作为库前缀（json_ → json_*_c 符号）。 */
    base = strrchr(input_path, '/');
    if (!base)
        base = strrchr(input_path, '\\');
    base = base ? base + 1 : input_path;
    dot = strrchr(base, '.');
    if (dot && dot > base && (strcmp(dot, ".sx") == 0 || strcmp(dot, ".su") == 0)) {
        stem_len = (size_t)(dot - base);
        if (stem_len > 0 && stem_len < sizeof(stem_buf)) {
            memcpy(stem_buf, base, stem_len);
            stem_buf[stem_len] = '\0';
            return stem_buf;
        }
    }
    return "typeck";
}

/** -E 且入口为 pipeline.sx 时输出 pipeline_glue.c include 行。 */
void shux_emit_pipeline_glue_include(void) {
    fputs("\n#include \"pipeline_glue.c\"\n", stdout);
}

/**
 * asm 后端写出 FILE *：stdout 仅 fflush，避免 fclose(stdout)。
 * 参数：fp 汇编输出流，可为 NULL。
 */
void driver_asm_fclose_asm_out(FILE *fp) {
    if (!fp || fp == stdout)
        fflush(stdout);
    else
        fclose(fp);
}

/**
 * 判断缓冲前缀是否为 Mach-O/ELF 对象魔数（asm_codegen_elf_o 产出检测）。
 * 参数：data/len 为 codegen out_buf 内容。
 * 返回值：非 0 表示已是对象文件字节。
 */
int shux_asm_out_buf_is_object(const unsigned char *data, size_t len) {
    if (!data || len < 4)
        return 0;
    if (data[0] == 0xcf && data[1] == 0xfa && data[2] == 0xed && data[3] == 0xfe)
        return 1;
    if (data[0] == 0xfe && data[1] == 0xed && data[2] == 0xfa && data[3] == 0xcf)
        return 1;
    if (data[0] == 0x7f && data[1] == 'E' && data[2] == 'L' && data[3] == 'F')
        return 1;
    return 0;
}

/** ast.sx pipeline_dep_ctx_* 与 lib_root sidecar（由 ast_pool.c 提供）。 */
extern void ast_pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx);
extern int32_t ast_pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path, int32_t len);
extern void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m);
extern void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a);
extern void ast_pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n);
extern void ast_pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes, int32_t len);

/** pipeline.sx asm 用户 dep 路径判定（符号由 pipeline_gen.c / pipeline_sx.o 提供）。 */
extern int32_t pipeline_asm_user_dep_skip_sx_typeck(uint8_t *path);
extern int32_t pipeline_asm_user_std_net_dep_path(uint8_t *path);
extern int32_t pipeline_codegen_path_is_std_io_driver_bytes(uint8_t *path);

/**
 * 填充 ctx 的 entry_dir_buf、lib_root sidecar，供 .sx 内 resolve_path_sx 使用。
 * 参数：ctx 非 NULL；entry_dir 入口目录；lib_roots/n_lib_roots 与 -L 一致。
 */
void shux_pipeline_fill_ctx_path_buffers(struct ast_PipelineDepCtx *ctx, const char *entry_dir,
    const char **lib_roots, int n_lib_roots) {
    if (!ctx)
        return;
    ctx->loaded_len = 0;
    ctx->preprocess_len = 0;
    ctx->entry_dir_len = 0;
    ctx->num_lib_roots = 0;
    if (entry_dir) {
        size_t el = strlen(entry_dir);
        if (el >= 512)
            el = 511;
        memcpy(ctx->entry_dir_buf, entry_dir, el);
        ctx->entry_dir_buf[el] = '\0';
        ctx->entry_dir_len = (int32_t)el;
    }
    if (lib_roots && n_lib_roots > 0) {
        for (int i = 0; i < n_lib_roots && lib_roots[i]; i++) {
            size_t ll = strlen(lib_roots[i]);
            if (ll >= 256)
                ll = 255;
            ast_pipeline_ctx_append_lib_root(ctx, (uint8_t *)lib_roots[i], (int32_t)ll);
        }
    }
}

/**
 * 将 C 侧 dep 槽写入 PipelineDepCtx sidecar（与 ast.sx pipeline_dep_ctx_* 对齐）。
 * 参数：dep_mods/dep_ar/import_paths 长度 n；ctx 输出 sidecar。
 */
void shux_pipeline_pctx_seed_dep_slots(struct ast_PipelineDepCtx *ctx, void **dep_mods, void **dep_ar,
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

/**
 * 更新 dep 槽 module/arena/path，不调用 ast_pipeline_dep_ctx_reset（保留 lib_root 等路径缓冲）。
 */
static void shux_pipeline_pctx_update_dep_slots_no_reset(struct ast_PipelineDepCtx *ctx, void **dep_mods,
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

/** parser.sx 符号（dep 预跑 import 扫描与 pipeline_parse_into_loaded_import 共用）。 */
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
void shux_pipeline_one_ctx_for_dep_prerun(struct ast_PipelineDepCtx *ctx, int j, void **dep_mods,
                                          void **dep_ars, char **dep_paths, int ndep, const uint8_t *dep_src,
                                          size_t dep_src_len) {
    int32_t n_imp;
    int mapped;
    void *tmp_arena = NULL;
    void *tmp_module = NULL;

    (void)j;
    if (!ctx)
        return;
    ctx->use_asm_backend = 0;
    if (!dep_mods || !dep_ars || !dep_paths || ndep <= 0) {
        ast_pipeline_dep_ctx_set_ndep(ctx, 0);
        return;
    }
    if (!dep_src || dep_src_len == 0 || dep_src_len > (size_t)INT32_MAX) {
        shux_pipeline_pctx_update_dep_slots_no_reset(ctx, dep_mods, dep_ars, dep_paths, ndep);
        return;
    }
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
        /* ok=-2：与 collect_deps 一致，import 已收集即可过滤 ctx，勿回退 entry 全量 dep 表。 */
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

/** asm 用户程序：std.io/fs/net dep 跳过 .sx typeck（符号由并列 .o 提供）。 */
int shux_asm_user_std_dep_skip_sx_typeck(const char *dep_path) {
    if (!dep_path || dep_path[0] == '\0')
        return 0;
    return pipeline_asm_user_dep_skip_sx_typeck((uint8_t *)dep_path) != 0;
}

/** std.net dep：须 co-emit listen/accept_many，seed typeck 对 stream_* 假阳性。 */
int shux_asm_user_std_net_dep_path(const char *dep_path) {
    if (!dep_path || dep_path[0] == '\0')
        return 0;
    return pipeline_asm_user_std_net_dep_path((uint8_t *)dep_path) != 0;
}

/** std.io.driver：co-emit submit_* 包装；seed typeck 对 register 假阳性。 */
int shux_asm_user_std_io_driver_dep_path(const char *dep_path) {
    if (!dep_path || dep_path[0] == '\0')
        return 0;
    return pipeline_codegen_path_is_std_io_driver_bytes((uint8_t *)dep_path) != 0;
}

/** dep 预跑 parse+skip typeck 路径（std.net / std.io.driver）。 */
int shux_asm_user_dep_parse_skip_typeck_path(const char *dep_path) {
    return shux_asm_user_std_net_dep_path(dep_path) || shux_asm_user_std_io_driver_dep_path(dep_path);
}

/** pipeline.sx 编排：entry_dir / resolved / loaded import 与 dep arena/module 槽。 */
static char pipeline_entry_dir_buf[512];
static const char *pipeline_entry_dir = ".";
static char pipeline_resolved_path_buf[512];
static void *pipeline_dep_arena_slots[32];
static void *pipeline_dep_module_slots[32];
static char *pipeline_loaded_import_buf;
static size_t pipeline_loaded_import_len;
static size_t pipeline_loaded_import_cap;

/** pipeline_run_sx_pipeline 由 pipeline_sx.o / pipeline_gen.c 提供。 */
extern int pipeline_run_sx_pipeline(void *module, void *arena, const uint8_t *source_data, size_t source_len,
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
extern int32_t pipeline_module_num_funcs(void *module);

/** 设置 pipeline resolve/read 用的 entry 目录。 */
void pipeline_set_entry_dir(const char *path) {
    if (path && path[0]) {
        (void)snprintf(pipeline_entry_dir_buf, sizeof(pipeline_entry_dir_buf), "%s", path);
        pipeline_entry_dir = pipeline_entry_dir_buf;
    } else {
        pipeline_entry_dir = ".";
    }
}

/** 写入 dep arena/module 槽（collect_deps 预分配缓冲）。 */
void pipeline_set_dep_slots(void *arenas[32], void *modules[32]) {
    for (int i = 0; i < 32; i++) {
        pipeline_dep_arena_slots[i] = arenas ? arenas[i] : NULL;
        pipeline_dep_module_slots[i] = modules ? modules[i] : NULL;
    }
}

/** 将 import 逻辑路径解析为文件系统路径写入内部 buffer。 */
int32_t pipeline_resolve_path(const uint8_t *path_ptr, int32_t path_len) {
    char path_c[65];
    size_t k = 0;
    if (path_len <= 0 || path_len > 64)
        path_len = 64;
    while (k < (size_t)path_len && path_ptr[k]) {
        path_c[k] = (char)path_ptr[k];
        k++;
    }
    path_c[k] = '\0';
    const char *lib_roots[1] = { "." };
    shux_resolve_import_file_path_multi(lib_roots, 1, pipeline_entry_dir, path_c, pipeline_resolved_path_buf,
        sizeof(pipeline_resolved_path_buf));
    return 0;
}

/** 读 resolved 路径文件并 preprocess，结果写入 loaded buffer。 */
int32_t pipeline_read_file(void) {
    ShuxRuntimeFileView raw_view;
    char *prep = NULL;
    size_t prep_len = 0;

    if (runtime_read_file_view(pipeline_resolved_path_buf, &raw_view) != 0) {
        fprintf(stderr, "shux: cannot open import (tried %s)\n", pipeline_resolved_path_buf);
        return -1;
    }
    if (shux_preprocess_raw_to_malloc((const unsigned char *)raw_view.data, raw_view.length, &prep, &prep_len,
            pipeline_resolved_path_buf,
            NULL, 0) != 0) {
        runtime_release_file_view(&raw_view);
        fprintf(stderr, "shux: preprocess failed for import\n");
        return -1;
    }
    runtime_release_file_view(&raw_view);
    if (!prep) {
        fprintf(stderr, "shux: preprocess failed for import\n");
        return -1;
    }
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

/** 取 dep arena 槽指针。 */
void *pipeline_get_dep_arena_slot(int32_t i) {
    if (i < 0 || i >= 32)
        return NULL;
    return pipeline_dep_arena_slots[i];
}

/** 取 dep module 槽指针。 */
void *pipeline_get_dep_module_slot(int32_t i) {
    if (i < 0 || i >= 32)
        return NULL;
    return pipeline_dep_module_slots[i];
}

/** 将 loaded import 缓冲 parse 进 module。 */
int32_t pipeline_parse_into_loaded_import(void *arena, void *module) {
    struct shux_slice_uint8_t slice = {
        .data = pipeline_loaded_import_buf ? (uint8_t *)pipeline_loaded_import_buf : NULL,
        .length = pipeline_loaded_import_len
    };
    struct parser_ParseIntoResult pr;
    if (!slice.data)
        return -1;
    parser_parse_into_init(module, arena);
    pr = parser_parse_into(arena, module, &slice);
    return pr.ok == 0 ? 0 : -1;
}

/** pipeline_run_sx_pipeline 大栈线程参数。 */
typedef struct {
    void *module;
    void *arena;
    const uint8_t *source_data;
    size_t source_len;
    void *out_buf;
    void *ctx;
    int result;
} PipelineRunSuArgs;

/** pthread 入口：跑 pipeline_run_sx_pipeline 并写回 ec。 */
static void *pipeline_run_sx_thread_fn(void *arg) {
    PipelineRunSuArgs *a = (PipelineRunSuArgs *)arg;
    driver_set_pipeline_entry_source_len(a->source_len);
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] pipeline thread start len=%zu\n", a->source_len);
    a->result = pipeline_run_sx_pipeline(a->module, a->arena, a->source_data, a->source_len, a->out_buf, a->ctx);
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] pipeline thread done ec=%d\n", a->result);
    return NULL;
}

/** 大栈 pthread 上调用 pipeline_run_sx_pipeline；pthread 失败时回退当前线程。 */
int shux_pipeline_run_sx_pipeline_large_stack(void *module, void *arena, const uint8_t *source_data, size_t source_len,
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
    driver_run_thread_on_large_stack(pipeline_run_sx_thread_fn, &args);
    if (args.result == -99)
        return pipeline_run_sx_pipeline(module, arena, source_data, source_len, out_buf, ctx);
    return args.result;
}

/** dep 预跑：完整 parse，跳过 typeck/codegen。 */
int shux_pipeline_dep_prerun_parse_skip_typeck(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
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
    driver_sx_pipeline_skip_typeck_set(1);
    driver_sx_pipeline_skip_codegen_set(1);
    ec = shux_pipeline_run_sx_pipeline_large_stack(dep_mod, dep_arena, src, len, dep_out, one_ctx);
    driver_sx_pipeline_skip_codegen_set(0);
    driver_sx_pipeline_skip_typeck_set(0);
    if (pctx)
        pctx->asm_entry_module_only = saved_entry_only;
    driver_check_only_set(saved ? 1 : 0);
    return ec;
}

/** dep 预跑：parse+typeck（C glue 直调），跳过 codegen；勿走 SX run_sx_pipeline_impl（大模块 ctx 易丢）。 */
int shux_pipeline_dep_prerun_typeck_only(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len, void *dep_out,
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
            fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] dep prerun parse rc=%d\n", (int)parse_rc);
        return -2;
    }
    load_rc = pipeline_load_and_sync_direct_import_deps_c((struct ast_Module *)dep_mod, (struct ast_ASTArena *)dep_arena,
                                                          (struct ast_PipelineDepCtx *)one_ctx);
    if (load_rc != 0) {
        if (getenv("SHUX_DEBUG_PIPE"))
            fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] dep prerun load rc=%d ndep=%d\n", (int)load_rc,
                    (int)pipeline_dep_ctx_ndep((struct ast_PipelineDepCtx *)one_ctx));
        return load_rc;
    }
    if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] dep prerun call dep_prerun_module_c main=%d\n",
                (int)pipeline_module_main_func_index(dep_mod));
    tc_rc = pipeline_typeck_dep_prerun_module_c((struct ast_Module *)dep_mod, (struct ast_ASTArena *)dep_arena,
                                              (struct ast_PipelineDepCtx *)one_ctx);
    if (getenv("SHUX_DEBUG_PIPE") && tc_rc != 0)
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] dep prerun typeck rc=%d funcs=%d main=%d ctx=%p\n", (int)tc_rc,
                (int)pipeline_module_num_funcs(dep_mod), (int)pipeline_module_main_func_index(dep_mod), one_ctx);
    return tc_rc;
}

/**
 * dep 预跑：仅 parse，不做全量 typeck。
 * 须走 pipeline_parse_set_main_from_buf_c（parse_into_with_init_buf）；直调 parser_parse_into 的 slice
 * 路径对大库模块（如 std/string/mod.sx）常 ok=-2 且仅 ~2 func，co-emit 缺 std_string_* 符号。
 */
int shux_pipeline_dep_prerun_parse_only(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len) {
    int32_t parse_rc;
    if (!dep_mod || !dep_arena || !src || len == 0)
        return -1;
    if (len > (size_t)INT32_MAX)
        return -1;
    if (getenv("SHUX_ASM_DEBUG"))
        fprintf(stderr, "shux: dep_prerun_parse_only len=%zu funcs_before=%d\n", len,
                pipeline_module_num_funcs(dep_mod));
    parser_parse_into_init(dep_mod, dep_arena);
    parse_rc = pipeline_parse_set_main_from_buf_c((struct ast_Module *)dep_mod, (struct ast_ASTArena *)dep_arena,
                                                  (uint8_t *)src, (int32_t)len);
    if (getenv("SHUX_ASM_DEBUG"))
        fprintf(stderr, "shux: dep_prerun_parse_only done rc=%d funcs=%d\n", (int)parse_rc,
                pipeline_module_num_funcs(dep_mod));
    return (parse_rc == 0) ? 0 : -1;
}

/** asm 单模块 -o：dep 预跑走 typeck_only。 */
int shux_pipeline_dep_prerun_for_asm_module_o(void *dep_mod, void *dep_arena, const uint8_t *src, size_t len,
    void *dep_out, void *one_ctx) {
    (void)driver_asm_entry_module_only_from_env;
    return shux_pipeline_dep_prerun_typeck_only(dep_mod, dep_arena, src, len, dep_out, one_ctx);
}

/** ast.sx 模块释放；LSP import 列表清理用。 */
extern void ast_module_free(struct ast_Module *mod);

/** 从绝对/相对源文件 path 提取所在目录写入 dep_dir；供 load_one_import 递归 import 切换 dep_dir。 */
int shux_import_dep_dir_from_path(const char *path, char *dep_dir, size_t dep_dir_size) {
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

/** 判断 import 路径是否已在 out_paths[0..n_out) 中（asm dep merge 去重）。 */
int shux_merge_deps_path_already_out(const char *path, char *out_paths[], int n_out) {
    int j;

    if (!path || !out_paths || n_out <= 0)
        return 0;
    for (j = 0; j < n_out; j++)
        if (out_paths[j] && strcmp(out_paths[j], path) == 0)
            return 1;
    return 0;
}

/** parser.sx：读 module import 路径与 parse_into（dep 传递闭包收集用）。 */
extern int32_t parser_get_module_num_imports(void *module);
extern void parser_get_module_import_path(void *module, int32_t idx, uint8_t *path_buf);

/**
 * build_shux_asm（ENTRY_MODULE_ONLY + SKIP_TYPECK）：仅读入口 direct import 源码（不递归传递闭包），
 * 供 parse-only 填 dep struct layout；避免 shux_collect_deps_transitive 耗时/失败。
 * 返回 0 成功；失败时释放已写入 dep_sources/dep_paths 并返回 1。
 */
int shux_load_direct_imports_for_asm_layout(void *module, const char **lib_roots_arr, int n_lib_roots,
    const char *entry_dir, const char **defines, int ndefines, char *dep_sources[], size_t dep_lens[],
    char *dep_paths[], int *out_n) {
    int32_t n_imports = parser_get_module_num_imports(module);
    int mi = 0;

    *out_n = 0;
    if (n_imports <= 0)
        return 0;
    for (int i = 0; i < n_imports && i < SHUX_DRIVER_DEP_SLOT_MAX && mi < SHUX_DRIVER_DEP_SLOT_MAX; i++) {
        uint8_t path_buf[64];
        char path_c[65];
        size_t k = 0;
        char resolved[PATH_MAX];
        ShuxRuntimeFileView raw_view;
        size_t prep_len = 0;
        char *prep;

        parser_get_module_import_path(module, i, path_buf);
        while (k < sizeof(path_buf) && path_buf[k] && k < 64) {
            path_c[k] = (char)path_buf[k];
            k++;
        }
        path_c[k] = '\0';
        shux_resolve_import_file_path_multi(lib_roots_arr, n_lib_roots, entry_dir, path_c, resolved, sizeof(resolved));
        if (runtime_read_file_view(resolved, &raw_view) != 0) {
            fprintf(stderr, "shux: cannot open direct import '%s' (tried %s)\n", path_c, resolved);
            goto fail_partial;
        }
        prep = shux_preprocess(raw_view.data, raw_view.length, ndefines > 0 ? defines : NULL, ndefines, &prep_len);
        runtime_release_file_view(&raw_view);
        if (!prep) {
            fprintf(stderr, "shux: preprocess failed for direct import '%s'\n", path_c);
            goto fail_partial;
        }
        dep_sources[mi] = prep;
        dep_lens[mi] = prep_len;
        dep_paths[mi] = strdup(path_c);
        if (!dep_paths[mi]) {
            free(prep);
            goto fail_partial;
        }
        mi++;
    }
    *out_n = mi;
    return 0;
fail_partial:
    while (mi > 0) {
        mi--;
        free(dep_sources[mi]);
        free(dep_paths[mi]);
    }
    *out_n = 0;
    return 1;
}

/**
 * 将 shux_collect_deps_transitive 得到的 closure（调用方已对 triple 数组做过反转）合并为 pipeline/asm_elf dep 列表。
 * 前 n_imports 项与入口 module import 槽对齐；传递依赖按 closure 顺序追加并路径去重。
 */
int shux_merge_direct_then_transitive_deps(void *module, int32_t n_imports, char *cls[], size_t clens[], char *cpaths[],
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
            fprintf(stderr, "shux: merge deps: direct import '%s' not found in transitive closure\n", path_c);
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

int shux_merge_direct_then_transitive_dep_paths(void *module, int32_t n_imports, char *cpaths[], int n_closure,
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
            fprintf(stderr, "shux: merge deps: direct import '%s' not found in transitive closure\n", path_c);
            return 1;
        }
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
            out_paths[mi] = cpaths[kj];
            mi++;
        }
    }
    *out_n = mi;
    return 0;
}

/**
 * 传递加载 dep：从 main 的 import 出发递归解析子 import，填满 dep_sources/dep_lens/dep_paths。
 * 返回 0 成功，1 失败（调用方负责释放已分配）。
 */
int shux_collect_deps_transitive(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_sources[],
    size_t dep_lens[], char *dep_paths[], int *n_deps) {
    int n = 0;
    char *to_load[SHUX_DRIVER_DEP_SLOT_MAX];
    int to_load_n = 0;
    void *tmp_arena = NULL;
    void *tmp_module = NULL;
    int32_t n_imports = parser_get_module_num_imports(module);

    for (int j = 0; j < n_imports && j < SHUX_DRIVER_DEP_SLOT_MAX && to_load_n < SHUX_DRIVER_DEP_SLOT_MAX; j++) {
        uint8_t path_buf[64];
        char path_c[65];
        size_t k = 0;

        parser_get_module_import_path(module, j, path_buf);
        while (k < sizeof(path_buf) && path_buf[k]) {
            path_c[k] = (char)path_buf[k];
            k++;
        }
        path_c[k] = '\0';
        to_load[to_load_n++] = strdup(path_c);
        if (!to_load[to_load_n - 1])
            goto fail_to_load;
    }
    while (to_load_n > 0 && n < SHUX_DRIVER_DEP_SLOT_MAX) {
        char *path_c = to_load[--to_load_n];
        if (shux_find_loaded_import_index(path_c, dep_paths, n) >= 0) {
            free(path_c);
            continue;
        }
        char resolved[PATH_MAX];
        shux_resolve_import_file_path_multi(lib_roots_arr, n_lib_roots, entry_dir_buf, path_c, resolved, sizeof(resolved));
        ShuxRuntimeFileView raw_view;
        if (runtime_read_file_view(resolved, &raw_view) != 0) {
            fprintf(stderr, "shux: cannot open import '%s' (tried %s)\n", path_c, resolved);
            free(path_c);
            goto fail_to_load;
        }
        size_t prep_len = 0;
        char *prep = shux_preprocess(raw_view.data, raw_view.length, ndefines > 0 ? defines : NULL, ndefines, &prep_len);
        runtime_release_file_view(&raw_view);
        if (!prep) {
            fprintf(stderr, "shux: preprocess failed for import '%s'\n", path_c);
            free(path_c);
            goto fail_to_load;
        }
        dep_sources[n] = prep;
        dep_lens[n] = prep_len;
        dep_paths[n] = strdup(path_c);
        free(path_c);
        if (!dep_paths[n])
            goto fail_to_load;
        n++;
        if (!tmp_arena) {
            tmp_arena = malloc(arena_sz);
            tmp_module = malloc(module_sz);
        }
        if (tmp_arena && tmp_module) {
            memset(tmp_arena, 0, arena_sz);
            memset(tmp_module, 0, module_sz);
            struct shux_slice_uint8_t dep_slice = { (uint8_t *)dep_sources[n - 1], dep_lens[n - 1] };
            parser_parse_into_init(tmp_module, tmp_arena);
            struct parser_ParseIntoResult pr_dep = parser_parse_into(tmp_arena, tmp_module, &dep_slice);
            {
                int n_imp = parser_get_module_num_imports(tmp_module);
                if (getenv("SHUX_DEBUG_PIPE")) {
                    fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] collect parse dep=%s pr_ok=%d n_imp=%d\n",
                            dep_paths[n - 1] ? dep_paths[n - 1] : "?", (int)pr_dep.ok, n_imp);
                }
                if (n_imp > 0) {
                    for (int jj = 0; jj < n_imp && jj < SHUX_DRIVER_DEP_SLOT_MAX && to_load_n < SHUX_DRIVER_DEP_SLOT_MAX;
                         jj++) {
                        uint8_t sub_buf[64];
                        char sub_c[65];
                        size_t kk = 0;

                        parser_get_module_import_path(tmp_module, jj, sub_buf);
                        while (kk < sizeof(sub_buf) && sub_buf[kk]) {
                            sub_c[kk] = (char)sub_buf[kk];
                            kk++;
                        }
                        sub_c[kk] = '\0';
                        if (shux_find_loaded_import_index(sub_c, dep_paths, n) >= 0)
                            continue;
                        {
                            int found = 0;
                            for (int t = 0; t < to_load_n; t++)
                                if (to_load[t] && strcmp(to_load[t], sub_c) == 0) {
                                    found = 1;
                                    break;
                                }
                            if (found)
                                continue;
                        }
                        to_load[to_load_n++] = strdup(sub_c);
                        if (!to_load[to_load_n - 1])
                            to_load_n--;
                    }
                }
            }
        }
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

int shux_collect_dep_paths_transitive(void *module, size_t arena_sz, size_t module_sz, const char **lib_roots_arr,
    int n_lib_roots, const char *entry_dir_buf, const char **defines, int ndefines, char *dep_paths[], int *n_deps) {
    int n = 0;
    char *to_load[SHUX_DRIVER_DEP_SLOT_MAX];
    int to_load_n = 0;
    void *tmp_arena = NULL;
    void *tmp_module = NULL;
    int32_t n_imports = parser_get_module_num_imports(module);

    for (int j = 0; j < n_imports && j < SHUX_DRIVER_DEP_SLOT_MAX && to_load_n < SHUX_DRIVER_DEP_SLOT_MAX; j++) {
        uint8_t path_buf[64];
        char path_c[65];
        size_t k = 0;

        parser_get_module_import_path(module, j, path_buf);
        while (k < sizeof(path_buf) && path_buf[k]) {
            path_c[k] = (char)path_buf[k];
            k++;
        }
        path_c[k] = '\0';
        to_load[to_load_n++] = strdup(path_c);
        if (!to_load[to_load_n - 1])
            goto fail_to_load;
    }
    while (to_load_n > 0 && n < SHUX_DRIVER_DEP_SLOT_MAX) {
        char *path_c = to_load[--to_load_n];
        if (shux_find_loaded_import_index(path_c, dep_paths, n) >= 0) {
            free(path_c);
            continue;
        }
        dep_paths[n] = strdup(path_c);
        if (!dep_paths[n]) {
            free(path_c);
            goto fail_to_load;
        }
        n++;
        if (!tmp_arena) {
            tmp_arena = malloc(arena_sz);
            tmp_module = malloc(module_sz);
        }
        if (tmp_arena && tmp_module) {
            char resolved[PATH_MAX];
            shux_resolve_import_file_path_multi(lib_roots_arr, n_lib_roots, entry_dir_buf, path_c, resolved, sizeof(resolved));
            ShuxRuntimeFileView raw_view;
            if (runtime_read_file_view(resolved, &raw_view) != 0) {
                fprintf(stderr, "shux: cannot open import '%s' (tried %s)\n", path_c, resolved);
                free(path_c);
                goto fail_to_load;
            }
            size_t prep_len = 0;
            char *prep = shux_preprocess(raw_view.data, raw_view.length, ndefines > 0 ? defines : NULL, ndefines, &prep_len);
            runtime_release_file_view(&raw_view);
            if (!prep) {
                fprintf(stderr, "shux: preprocess failed for import '%s'\n", path_c);
                free(path_c);
                goto fail_to_load;
            }
            memset(tmp_arena, 0, arena_sz);
            memset(tmp_module, 0, module_sz);
            struct shux_slice_uint8_t dep_slice = { (uint8_t *)prep, prep_len };
            parser_parse_into_init(tmp_module, tmp_arena);
            struct parser_ParseIntoResult pr_dep = parser_parse_into(tmp_arena, tmp_module, &dep_slice);
            {
                int n_imp = parser_get_module_num_imports(tmp_module);
                if (getenv("SHUX_DEBUG_PIPE")) {
                    fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] collect parse dep=%s pr_ok=%d n_imp=%d\n",
                            path_c ? path_c : "?", (int)pr_dep.ok, n_imp);
                }
                if (n_imp > 0) {
                    for (int jj = 0; jj < n_imp && jj < SHUX_DRIVER_DEP_SLOT_MAX && to_load_n < SHUX_DRIVER_DEP_SLOT_MAX;
                         jj++) {
                        uint8_t sub_buf[64];
                        char sub_c[65];
                        size_t kk = 0;

                        parser_get_module_import_path(tmp_module, jj, sub_buf);
                        while (kk < sizeof(sub_buf) && sub_buf[kk]) {
                            sub_c[kk] = (char)sub_buf[kk];
                            kk++;
                        }
                        sub_c[kk] = '\0';
                        if (shux_find_loaded_import_index(sub_c, dep_paths, n) >= 0)
                            continue;
                        {
                            int found = 0;
                            for (int t = 0; t < to_load_n; t++)
                                if (to_load[t] && strcmp(to_load[t], sub_c) == 0) {
                                    found = 1;
                                    break;
                                }
                            if (found)
                                continue;
                        }
                        to_load[to_load_n++] = strdup(sub_c);
                        if (!to_load[to_load_n - 1])
                            to_load_n--;
                    }
                }
            }
            free(prep);
        }
        free(path_c);
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

/** asm emit 桩判定与 ARRAY_LIT/SoA 补类型（ast_pool.c / pipeline_glue.c）。 */
extern void asm_skip_heavy_set_pipeline_ctx(void *ctx);
extern void pipeline_fill_array_lit_types_for_skipped_typeck(void *m, void *arena);
extern void pipeline_fill_soa_field_access_for_asm_emit(void *m, void *arena);
extern void pipeline_module_fixup_with_arena_stmt_orders(void *m, void *arena);

/** asm_codegen_elf_o 前：设置 skip_heavy 上下文并为 ARRAY_LIT / SoA field 补类型。 */
void shux_driver_asm_prepare_entry_elf_emit(void *module, void *arena, void *pctx) {
    asm_skip_heavy_set_pipeline_ctx(pctx);
    pipeline_fill_array_lit_types_for_skipped_typeck(module, arena);
    pipeline_fill_soa_field_access_for_asm_emit(module, arena);
    /** with_arena：parse 扁平 stmt_order 时补 kind=6 region，否则 main 仅 emit 前几条 if（SIGSEGV）。 */
    pipeline_module_fixup_with_arena_stmt_orders((struct ast_Module *)module, (struct ast_ASTArena *)arena);
}

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

/** pthread 入口：调用 asm_asm_codegen_elf_o 并将 ec 写入 args->result。 */
static void *shux_asm_codegen_elf_o_thread_fn(void *arg) {
    ShuxAsmCodegenElfLargeArgs *a = (ShuxAsmCodegenElfLargeArgs *)arg;

    a->result = asm_asm_codegen_elf_o(a->module, a->arena, a->ctx, a->elf_ctx, a->out_buf);
    return NULL;
}

/** 在 256MiB 栈 pthread 上调用 asm_asm_codegen_elf_o；主线程栈已深时避免 lexer emit Abort。 */
int32_t shux_asm_codegen_elf_o_large_stack(void *module, void *arena, void *ctx,
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

/** C typecheck 入口；由 typeck.c 提供。 */
extern int typeck_module(void *module, void **dep_mods, int ndep, void *a, int b);

/**
 * 使用已填充的 typeck_ndep / typeck_dep_module_ptrs 对入口模块做 C 类型检查（大模块 asm 构建用）。
 * SHUX_NO_C_FRONTEND 时仍导出符号供 pipeline_asm_typecheck_alias 链接。
 */
int32_t pipeline_typeck_module_for_ctx(void *module, void *arena, void *ctx_void) {
    (void)arena;
    (void)ctx_void;
    if (typeck_module(module, typeck_ndep > 0 ? (void **)typeck_dep_module_ptrs : NULL, typeck_ndep, NULL, 0) != 0)
        return -1;
    return 0;
}

/** 释放 shu_lsp_resolve_and_load_imports 写入的 all_dep_mods / all_dep_paths（不含 entry 模块本身）。 */
void shu_lsp_free_loaded_imports(struct ast_Module **all_dep_mods, char **all_dep_paths, int n_all) {
    int i;

    if (!all_dep_mods || !all_dep_paths || n_all <= 0)
        return;
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

/**
 * 对 .sx 源码做条件编译预处理；默认 bootstrap 走 preprocess.sx，LEGACY 或 shux-c 冷路径走 C fallback。
 * 参数：与 preprocess.h preprocess() 一致。
 * 返回值：malloc 字符串（调用方 free）；失败 NULL。
 */
char *shux_preprocess(const char *source, size_t source_len, const char **defines, int ndefines, size_t *out_length) {
    size_t slen;

    if (out_length)
        *out_length = 0;
    if (!source)
        return NULL;
#if defined(SHUX_USE_SX_PIPELINE) && !defined(SHUX_LEGACY_PREPROCESS_C)
    slen = source_len ? source_len : strlen(source);
    {
        char *out = NULL;
        size_t olen = 0;

        if (shux_preprocess_raw_to_malloc((const unsigned char *)source, slen, &out, &olen, NULL,
                ndefines > 0 ? defines : NULL, ndefines) != 0)
            return NULL;
        if (out_length)
            *out_length = olen;
        return out;
    }
#else
    return preprocess_c_fallback(source, source_len, defines, ndefines, out_length);
#endif
}
