/**
 * lsp_diag.c — LSP 诊断收集器与 definition/hover/references/formatting 等 C 实现
 *
 * 维护固定大小诊断列表；C parser fail() 与（启用时）.su 流水线的 driver_diagnostic_* 写入 lsp_diag_add。
 * textDocument/diagnostic 的 JSON-RPC 正文由 lsp_diag.su 的 lsp_build_diagnostics_response（parse_into_buf + typeck_su_ast）构建。
 *
 * 纯 JSON 外壳（initialize_result、response_with_result）可迁到 lsp.su，但默认 shu 的 OBJS 未链 lsp_su/io
 *（无 std io/heap），lsp_diag 仍须在本文件提供这些符号；自举目标（shu-su）链 lsp_gen 后可再拆。
 *
 * 为何大量逻辑仍保留为 C：直接调用 parser/lexer/typeck/ast 的 C API 与可变参 typeck 回调；迁 .su 见 docs/完全去掉C与H-前置清单.md §2。
 */

#include "lsp/lsp_diag.h"
#include "parser/parser.h"
#include "lexer/lexer.h"
#include "typeck/typeck.h"
#include "ast.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>

/** LSP import 图：由 runtime.c 提供，供跨模块 typeck 与跳转 URI。 */
extern int shu_lsp_resolve_and_load_imports(struct ASTModule *mod, const char **lib_roots, int n_lib_roots,
                                          const char *entry_dir, struct ASTModule **dep_mods, int *ndep_out,
                                          struct ASTModule **all_dep_mods, char **all_dep_paths,
                                          char all_dep_fs[][512], int *n_all_out, int max_deps);
extern void shu_lsp_free_loaded_imports(struct ASTModule **all_dep_mods, char **all_dep_paths, int n_all);

extern void lsp_diag_pipeline_ctx_fill_paths(void *ctx_void, const char *entry_dir, const char **lib_roots, int n_lib_roots);

extern size_t lsp_diag_pipeline_sizeof_arena(void);
extern size_t lsp_diag_pipeline_sizeof_module(void);
extern size_t lsp_diag_pipeline_sizeof_dep_ctx(void);

/** 调试 LSP read_message 的 leftover 长度 n；LSP_READ_DEBUG 时打 stderr，便于确认 state 是否在两次调用间保留。 */
void lsp_debug_u32(uint32_t n) {
    if (getenv("LSP_READ_DEBUG") != NULL)
        (void)fprintf(stderr, "lsp_read_message leftover n=%u\n", (unsigned)n);
}
/** 调试：打 state 指针。 */
void lsp_debug_ptr(uint8_t *p) {
    if (getenv("LSP_READ_DEBUG") != NULL)
        (void)fprintf(stderr, "lsp_read_message state_buf=%p\n", (void *)p);
}

/* 前向声明：行索引、引用索引与定义/引用/悬停。 */
static void build_line_index(const struct ASTModule *mod);
static void build_refs_index(const struct ASTModule *mod);
static struct ASTFunc *get_function_at_line(const struct ASTModule *mod, int line_1);
static int find_def_in_expr(const struct ASTModule *mod, const struct ASTExpr *e, int line_1, int col_1, int *out_line, int *out_col);
static int find_def_in_block(const struct ASTModule *mod, const struct ASTBlock *b, int line_1, int col_1, int *out_line, int *out_col);
static int find_def_in_module(const struct ASTModule *mod, int line_1, int col_1, int *out_line, int *out_col);
int lsp_extract_uri_from_params(const uint8_t *body, int len, uint8_t *uri_buf, int uri_cap);
/* References：按位置确定目标函数，并收集所有引用位置。 */
static struct ASTFunc *find_target_function_at(const struct ASTModule *mod, int line_1, int col_1);
static int collect_refs_to_func(const struct ASTModule *mod, const struct ASTFunc *func, int *out_lines, int *out_cols, int max_refs);
/* Hover：按位置找最内层表达式，并格式化类型字符串。 */
static struct ASTExpr *get_innermost_expr_at(struct ASTExpr *e, int line_1, int col_1);
static struct ASTExpr *get_expr_at_in_block(const struct ASTBlock *b, int line_1, int col_1);
static struct ASTExpr *get_expr_at_in_module(const struct ASTModule *mod, int line_1, int col_1);
static int type_to_string(const struct ASTType *ty, char *buf, int cap);
int lsp_diag_format_diagnostics_json(char *out, int out_cap);

#define LSP_DIAG_MAX  64
#define LSP_MSG_MAX   240

typedef struct {
    int line;
    int col;
    int severity;
    char msg[LSP_MSG_MAX + 1];
} LspDiagEntry;

static LspDiagEntry s_diag[LSP_DIAG_MAX];
static int s_diag_count;

/* 诊断/模块缓存与行索引（lsp_diag_invalidate_cache 需在文件前部可见）。 */
#define LSP_CACHE_DIAG_JSON_INIT 8192
#define LSP_CACHE_DIAG_JSON_MAX_CAP  (2 * 1024 * 1024)  /* 单次缓存上限 2MB */
static int s_last_source_len;
static unsigned s_last_source_hash;
static char *s_last_diag_json = NULL;
static int s_last_diag_json_cap = 0;
static int s_last_diag_len = 0;
static ASTModule *s_cached_mod = NULL;
static int s_cached_source_len = -1;
static unsigned s_cached_source_hash = 0;
static int s_typeck_full = 0;  /* 1=缓存模块已全量 typeck，0=仅懒 typeck 过单函数 */

#define LSP_MAX_IMPORTS 32
/** 当前文档 file URI 与本地路径（didOpen 时更新）。 */
static char s_doc_uri[512];
static char s_entry_fs_path[512];
static char s_entry_dir[512];
/** libRoots：默认与 VS Code shulang.compiler.libRoots 对齐，可由 SHULANG_LSP_LIB_ROOTS 覆盖（`:` 分隔）。 */
static const char *s_lib_roots[8];
static char s_lib_roots_storage[8][256];
static int s_n_lib_roots;
static int s_lib_roots_inited;
/** 已加载 import 模块（不含 entry）；与 s_all_dep_paths / s_all_dep_fs 同下标。 */
static ASTModule *s_all_dep_mods[LSP_MAX_IMPORTS];
static char *s_all_dep_paths[LSP_MAX_IMPORTS];
static char s_all_dep_fs[LSP_MAX_IMPORTS][512];
static int s_n_all_deps;
static ASTModule *s_direct_deps[LSP_MAX_IMPORTS];
static int s_ndirect_deps;
/** 最近一次 definition 解析到的目标函数（用于跨文件 URI）。 */
static struct ASTFunc *s_def_target_func;
#define LSP_LINE_INDEX_MAX 1024
#define LSP_REFS_PER_FUNC_MAX 256
static struct {
    int start_line;
    int end_line;
    struct ASTFunc *func;
} s_line_index[LSP_LINE_INDEX_MAX];
static int s_line_index_n = 0;
/* References 索引：s_refs_lines[i][0..s_refs_count[i]-1] 为第 i 个函数被引用的 (line,col)。 */
static int s_refs_lines[LSP_LINE_INDEX_MAX][LSP_REFS_PER_FUNC_MAX];
static int s_refs_cols[LSP_LINE_INDEX_MAX][LSP_REFS_PER_FUNC_MAX];
static int s_refs_count[LSP_LINE_INDEX_MAX];

/** 释放 import 依赖缓存（不含 entry 模块 s_cached_mod）。 */
static void lsp_free_import_cache(void) {
    shu_lsp_free_loaded_imports(s_all_dep_mods, s_all_dep_paths, s_n_all_deps);
    s_n_all_deps = 0;
    s_ndirect_deps = 0;
    memset(s_all_dep_mods, 0, sizeof(s_all_dep_mods));
    memset(s_all_dep_paths, 0, sizeof(s_all_dep_paths));
    memset(s_all_dep_fs, 0, sizeof(s_all_dep_fs));
}

/** 从 file URI 提取本地路径写入 out（简单 file:// 解码，足够 macOS/Linux 开发）。 */
static void lsp_uri_to_fs_path(const char *uri, char *out, size_t cap) {
    size_t k = 0;
    if (!uri || !out || cap == 0) return;
    out[0] = '\0';
    if (strncmp(uri, "file://", 7) != 0) return;
    const char *p = uri + 7;
    while (*p && k + 1 < cap) {
        if (p[0] == '%' && p[1] && p[2]) {
            int hi = p[1], lo = p[2];
            int v = 0;
            if (hi >= '0' && hi <= '9') v = (hi - '0') << 4;
            else if (hi >= 'a' && hi <= 'f') v = (hi - 'a' + 10) << 4;
            else if (hi >= 'A' && hi <= 'F') v = (hi - 'A' + 10) << 4;
            if (lo >= '0' && lo <= '9') v |= (lo - '0');
            else if (lo >= 'a' && lo <= 'f') v |= (lo - 'a' + 10);
            else if (lo >= 'A' && lo <= 'F') v |= (lo - 'A' + 10);
            out[k++] = (char)v;
            p += 3;
            continue;
        }
        out[k++] = *p++;
    }
    out[k] = '\0';
}

/** 本地路径 → file URI（空格转 %20）。 */
static void lsp_fs_path_to_uri(const char *path, char *uri, size_t cap) {
    size_t k = 0;
    if (!path || !uri || cap < 8) return;
    uri[k++] = 'f'; uri[k++] = 'i'; uri[k++] = 'l'; uri[k++] = 'e';
    uri[k++] = ':'; uri[k++] = '/'; uri[k++] = '/';
    for (const char *p = path; *p && k + 4 < cap; p++) {
        if (*p == ' ') { uri[k++] = '%'; uri[k++] = '2'; uri[k++] = '0'; }
        else uri[k++] = *p;
    }
    uri[k] = '\0';
}

/** 根据 entry 文件路径更新 import 解析用的 entry_dir。 */
static void lsp_update_entry_dir(const char *fs_path) {
    if (!fs_path || !fs_path[0]) {
        s_entry_dir[0] = '.';
        s_entry_dir[1] = '\0';
        return;
    }
    (void)snprintf(s_entry_fs_path, sizeof(s_entry_fs_path), "%s", fs_path);
    const char *slash = strrchr(fs_path, '/');
    if (slash) {
        size_t n = (size_t)(slash - fs_path);
        if (n >= sizeof(s_entry_dir)) n = sizeof(s_entry_dir) - 1;
        memcpy(s_entry_dir, fs_path, n);
        s_entry_dir[n] = '\0';
    } else {
        s_entry_dir[0] = '.';
        s_entry_dir[1] = '\0';
    }
}

/** 初始化 libRoots（环境变量 SHULANG_LSP_LIB_ROOTS 优先，否则仓库默认布局）。 */
static void lsp_init_lib_roots_once(void) {
    int i;
    if (s_lib_roots_inited) return;
    s_lib_roots_inited = 1;
    const char *env = getenv("SHULANG_LSP_LIB_ROOTS");
    if (env && env[0]) {
        char buf[1024];
        (void)snprintf(buf, sizeof(buf), "%s", env);
        char *p = buf;
        while (p && s_n_lib_roots < 8) {
            char *col = strchr(p, ':');
            if (col) *col = '\0';
            if (p[0]) {
                int idx = s_n_lib_roots;
                (void)snprintf(s_lib_roots_storage[idx], sizeof(s_lib_roots_storage[0]), "%s", p);
                s_lib_roots[idx] = s_lib_roots_storage[idx];
                s_n_lib_roots++;
            }
            p = col ? col + 1 : NULL;
        }
    }
    if (s_n_lib_roots == 0) {
        const char *defs[] = { ".", "compiler/src", "core", "std" };
        for (i = 0; i < 4; i++) {
            (void)snprintf(s_lib_roots_storage[i], sizeof(s_lib_roots_storage[0]), "%s", defs[i]);
            s_lib_roots[i] = s_lib_roots_storage[i];
        }
        s_n_lib_roots = 4;
    }
}

/** 查找函数 f 所属模块的 .su 文件路径；entry 模块用 s_entry_fs_path。 */
static const char *lsp_fs_path_for_func(struct ASTFunc *f, ASTModule *entry) {
    int i, j;
    if (!f) return NULL;
    if (entry && entry->funcs) {
        for (i = 0; i < entry->num_funcs; i++)
            if (entry->funcs[i] == f)
                return s_entry_fs_path[0] ? s_entry_fs_path : NULL;
    }
    for (j = 0; j < s_n_all_deps; j++) {
        ASTModule *m = s_all_dep_mods[j];
        if (!m || !m->funcs) continue;
        for (i = 0; i < m->num_funcs; i++)
            if (m->funcs[i] == f)
                return s_all_dep_fs[j][0] ? s_all_dep_fs[j] : NULL;
    }
    return NULL;
}

/** 为 .su pipeline LSP 路径配置 PipelineDepCtx（libRoots + entry_dir）。 */
void lsp_diag_prepare_pipeline_ctx(void *ctx_void) {
    if (!ctx_void) return;
    lsp_init_lib_roots_once();
    lsp_diag_pipeline_ctx_fill_paths(ctx_void, s_entry_dir[0] ? s_entry_dir : NULL, s_lib_roots, s_n_lib_roots);
}

int lsp_diag_enabled = 0;

void lsp_diag_clear(void) {
    s_diag_count = 0;
}

/** 文档变更时调用，使模块与诊断缓存失效；避免旧 AST 指向已释放的文档缓冲（与 lsp_io 配合）。 */
void lsp_diag_invalidate_cache(void) {
    lsp_free_import_cache();
    if (s_cached_mod) {
        ast_module_free(s_cached_mod);
        s_cached_mod = NULL;
    }
    s_cached_source_len = -1;
    s_cached_source_hash = 0;
    if (s_last_diag_json) {
        free(s_last_diag_json);
        s_last_diag_json = NULL;
        s_last_diag_json_cap = 0;
    }
    s_last_diag_len = 0;
    s_line_index_n = 0;
    s_typeck_full = 0;
}

void lsp_diag_add(int line, int col, int severity, const char *msg) {
    if (s_diag_count >= LSP_DIAG_MAX) return;
    LspDiagEntry *e = &s_diag[s_diag_count++];
    e->line = line;
    e->col = col;
    e->severity = (severity == 2) ? 2 : 1;
    if (msg) {
        size_t n = 0;
        while (n < LSP_MSG_MAX && msg[n] != '\0') {
            e->msg[n] = msg[n];
            n++;
        }
        e->msg[n] = '\0';
    } else {
        e->msg[0] = '\0';
    }
}

void lsp_diag_report_typeck(int line, int col, const char *fmt, ...) {
    char buf[LSP_MSG_MAX + 1];
    va_list ap;
    va_start(ap, fmt);
    (void)vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);
    if (lsp_diag_enabled) {
        lsp_diag_add(line, col, 1, buf);
    } else {
        fprintf(stderr, "typeck error: %s at %d:%d\n", buf, line, col);
    }
}

void lsp_diag_collect_begin(void) {
    lsp_diag_clear();
    lsp_diag_enabled = 1;
}

void lsp_diag_collect_end(void) {
    lsp_diag_enabled = 0;
}

/**
 * 将 s_diag 中已收集条目打印为 CLI 友好行（deno check 风格）。
 * path：诊断前缀文件路径；severity 1→error，2→warning。
 */
int lsp_diag_print_stderr_human(const char *path) {
    int i;
    int n = 0;
    const char *sev;
    if (!path)
        path = "?";
    for (i = 0; i < s_diag_count; i++) {
        sev = (s_diag[i].severity == 2) ? "warning" : "error";
        fprintf(stderr, "%s:%d:%d - %s: %s\n", path, s_diag[i].line, s_diag[i].col, sev, s_diag[i].msg);
        n++;
    }
  if (n > 0)
        fflush(stderr);
    return n;
}

void *lsp_diag_su_arena_ptr(void) {
    static void *p;
    if (!p)
        p = calloc(1, lsp_diag_pipeline_sizeof_arena());
    return p;
}

void *lsp_diag_su_module_ptr(void) {
    static void *p;
    if (!p)
        p = calloc(1, lsp_diag_pipeline_sizeof_module());
    return p;
}

void *lsp_diag_su_ctx_ptr(void) {
    static void *p;
    if (!p)
        p = calloc(1, lsp_diag_pipeline_sizeof_dep_ctx());
    return p;
}

void lsp_diag_su_reset_parse_buffers(void) {
    void *a = lsp_diag_su_arena_ptr();
    void *m = lsp_diag_su_module_ptr();
    void *c = lsp_diag_su_ctx_ptr();
    if (a)
        memset(a, 0, lsp_diag_pipeline_sizeof_arena());
    if (m)
        memset(m, 0, lsp_diag_pipeline_sizeof_module());
    if (c)
        memset(c, 0, lsp_diag_pipeline_sizeof_dep_ctx());
}

/** 将 msg 按 JSON 字符串转义写入 out，返回写入长度；out_cap 为 out 的容量。 */
static int json_escape_str(const char *msg, char *out, int out_cap) {
    int k = 0;
    if (!msg || !out || out_cap <= 0) return 0;
    for (; *msg != '\0' && k < out_cap - 1; msg++) {
        if (*msg == '"' || *msg == '\\') {
            if (k + 2 > out_cap - 1) break;
            out[k++] = '\\';
            out[k++] = *msg;
        } else if (*msg == '\n') {
            if (k + 2 > out_cap - 1) break;
            out[k++] = '\\';
            out[k++] = 'n';
        } else if (*msg == '\r') {
            if (k + 2 > out_cap - 1) break;
            out[k++] = '\\';
            out[k++] = 'r';
        } else if (*msg == '\t') {
            if (k + 2 > out_cap - 1) break;
            out[k++] = '\\';
            out[k++] = 't';
        } else {
            out[k++] = *msg;
        }
    }
    out[k] = '\0';
    return k;
}

/** 快速 32 位哈希：64 位状态 + 8 字节块 mix，折叠为 32 位；大文档缓存校验比 djb2 更快。 */
static unsigned lsp_hash_source(const uint8_t *src, int len) {
    uint64_t h = (uint64_t)(unsigned)len;
    int i = 0;
    for (; i + 8 <= len; i += 8) {
        uint64_t x;
        memcpy(&x, src + i, 8);
        h = (h * 0x9e3779b97f4a7c15ULL) + x;
    }
    for (; i < len; i++)
        h = (h * 0x9e3779b97f4a7c15ULL) + (uint64_t)(unsigned)src[i];
    return (unsigned)(h ^ (h >> 32));
}

/** 加载 import 依赖并对 entry 模块做 typeck（含跨模块符号解析）。 */
static void lsp_typeck_entry_module(ASTModule *mod, int only_func_index) {
    lsp_init_lib_roots_once();
    lsp_free_import_cache();
    s_ndirect_deps = 0;
    s_n_all_deps = 0;
    if (mod && mod->num_imports > 0) {
        (void)shu_lsp_resolve_and_load_imports(mod, s_lib_roots, s_n_lib_roots, s_entry_dir,
                                             s_direct_deps, &s_ndirect_deps,
                                             s_all_dep_mods, s_all_dep_paths, s_all_dep_fs,
                                             &s_n_all_deps, LSP_MAX_IMPORTS);
    }
    if (only_func_index >= 0)
        (void)typeck_one_function(mod, s_direct_deps, s_ndirect_deps, s_all_dep_mods, s_n_all_deps, only_func_index);
    else
        (void)typeck_module(mod, s_direct_deps, s_ndirect_deps, s_all_dep_mods, s_n_all_deps);
}

/**
 * 返回当前文档对应的已解析+类型检查模块；文档未变则直接返回缓存，否则重新 parse+typeck 并更新缓存与诊断 JSON。
 * cursor_line_1 < 0 表示需要全量 typeck（diagnostics/references）；>= 0 时仅 typeck 该行所在函数（definition/hover 懒 typeck）。
 * 调用方不得 free 返回值；仅在同一文档上多次请求时复用，避免重复解析。
 */
static ASTModule *lsp_ensure_module(const uint8_t *source, int source_len, int cursor_line_1) {
    if (!source || source_len < 0) return NULL;
    /* 先比长度，不等则必未命中，可避免哈希计算（大文档时省时）。 */
    if (source_len == s_cached_source_len) {
        unsigned h = lsp_hash_source(source, source_len);
        if (h == s_cached_source_hash && s_cached_mod != NULL) {
            if (cursor_line_1 < 0 && !s_typeck_full) {
                lsp_typeck_entry_module(s_cached_mod, -1);
                s_typeck_full = 1;
            }
            return s_cached_mod;
        }
    }
    /* 缓存未命中：释放旧模块与诊断缓存，重新解析。 */
    if (s_cached_mod) {
        ast_module_free(s_cached_mod);
        s_cached_mod = NULL;
    }
    if (s_last_diag_json) {
        free(s_last_diag_json);
        s_last_diag_json = NULL;
        s_last_diag_json_cap = 0;
    }
    s_last_diag_len = 0;
    s_cached_source_len = -1;
    s_cached_source_hash = 0;
    /* 零拷贝解析：source 为当前文档缓冲时（至少 source_len+1 字节可写），就地临时 NUL 后交给 lexer，省去整份 memcpy。source_len==0 时不能写 source[0]，走小缓冲。 */
    char *parse_src = NULL;
    char saved = 0;
    int in_place = (source_len > 0 && source_len < (1 << 28));
    if (in_place) {
        parse_src = (char *)(uintptr_t)source;
        saved = parse_src[source_len];
        parse_src[source_len] = '\0';
    } else {
        size_t alloc_len = (source_len > 0) ? (size_t)source_len + 1 : 1;
        parse_src = (char *)malloc(alloc_len);
        if (!parse_src) return NULL;
        if (source_len > 0) {
            memcpy(parse_src, source, (size_t)source_len);
            parse_src[source_len] = '\0';
        } else
            parse_src[0] = '\0';
    }
    Lexer *lex = lexer_new(parse_src);
    if (!lex) {
        if (in_place)
            parse_src[source_len] = saved;
        else if (parse_src)
            free(parse_src);
        return NULL;
    }
    lsp_diag_clear();
    lsp_diag_enabled = 1;
    ASTModule *mod = NULL;
    (void)parse(lex, &mod);
    lsp_diag_enabled = 0;
    lexer_free(lex);
    /* 解析结束后再恢复末尾字节（零拷贝）或释放拷贝缓冲，避免解析期间缓冲区被改/释放。 */
    if (in_place)
        parse_src[source_len] = saved;
    else if (parse_src)
        free(parse_src);
    s_last_source_len = source_len;
    s_last_source_hash = lsp_hash_source(source, source_len);
    /* 仅当解析失败时在此处写诊断缓存；成功则等 typeck 后只写一次。 */
    if (!mod) {
        int cap = LSP_CACHE_DIAG_JSON_INIT;
        char *tmp = (char *)malloc((size_t)cap);
        int diag_len = 0;
        if (tmp) {
            for (;;) {
                diag_len = lsp_diag_format_diagnostics_json(tmp, cap);
                if (diag_len <= 0) diag_len = 1;
                if (tmp[0] != '[') { tmp[0] = '['; tmp[1] = ']'; tmp[2] = '\0'; diag_len = 2; }
                if (diag_len < cap || (size_t)cap >= (size_t)LSP_CACHE_DIAG_JSON_MAX_CAP) break;
                cap = (int)((size_t)cap * 2);
                if (cap > LSP_CACHE_DIAG_JSON_MAX_CAP) cap = LSP_CACHE_DIAG_JSON_MAX_CAP;
                char *t2 = (char *)realloc(tmp, (size_t)cap);
                if (!t2) break;
                tmp = t2;
            }
        }
        if (tmp && diag_len > 0) {
            size_t need = (size_t)diag_len + 1;
            if (need > (size_t)s_last_diag_json_cap) {
                char *p = (char *)realloc(s_last_diag_json, need);
                if (p) { s_last_diag_json = p; s_last_diag_json_cap = (int)need; }
            }
            if (s_last_diag_json)
                memcpy(s_last_diag_json, tmp, need);
            s_last_diag_len = diag_len;
            free(tmp);
        } else if (tmp) free(tmp);
        return NULL;
    }
    build_line_index(mod);
    build_refs_index(mod);
    if (cursor_line_1 >= 0) {
        struct ASTFunc *at_line = get_function_at_line(mod, cursor_line_1);
        int only_func_index = -1;
        if (at_line && mod->funcs) {
            for (int i = 0; i < mod->num_funcs; i++)
                if (mod->funcs[i] == at_line) { only_func_index = i; break; }
        }
        lsp_typeck_entry_module(mod, only_func_index);
        s_typeck_full = (only_func_index < 0) ? 1 : 0;
    } else {
        lsp_typeck_entry_module(mod, -1);
        s_typeck_full = 1;
    }
    s_cached_mod = mod;
    s_cached_source_len = source_len;
    s_cached_source_hash = s_last_source_hash;
    /* 解析成功后再写一次诊断 JSON（typeck 可能新增错误）；同样动态扩容。 */
    {
        int cap = LSP_CACHE_DIAG_JSON_INIT;
        char *tmp = (char *)malloc((size_t)cap);
        int diag_len = 0;
        if (tmp) {
            for (;;) {
                diag_len = lsp_diag_format_diagnostics_json(tmp, cap);
                if (diag_len <= 0) diag_len = 1;
                if (tmp[0] != '[') {
                    tmp[0] = '['; tmp[1] = ']'; tmp[2] = '\0';
                    diag_len = 2;
                }
                if (diag_len < cap || (size_t)cap >= (size_t)LSP_CACHE_DIAG_JSON_MAX_CAP) break;
                cap = (int)((size_t)cap * 2);
                if (cap > LSP_CACHE_DIAG_JSON_MAX_CAP) cap = LSP_CACHE_DIAG_JSON_MAX_CAP;
                char *t2 = (char *)realloc(tmp, (size_t)cap);
                if (!t2) break;
                tmp = t2;
            }
        }
        if (tmp && diag_len > 0) {
            size_t need = (size_t)diag_len + 1;
            if (need > (size_t)s_last_diag_json_cap) {
                char *p = (char *)realloc(s_last_diag_json, need);
                if (p) { s_last_diag_json = p; s_last_diag_json_cap = (int)need; }
            }
            if (s_last_diag_json)
                memcpy(s_last_diag_json, tmp, need);
            s_last_diag_len = diag_len;
            free(tmp);
        } else if (tmp) free(tmp);
    }
    return mod;
}

/** 判断 (line_1,col_1) 是否落在标识符 name 从 start_col 开始的列区间内（1-based，含首列）。 */
static int col_in_ident_span(int line_1, int col_1, int start_line, int start_col, const char *name) {
    if (!name || start_line != line_1 || start_col <= 0) return 0;
    int len = (int)strlen(name);
    if (len <= 0) return 0;
    return col_1 >= start_col && col_1 < start_col + len;
}

/** 判断 (line_1, col_1) 是否与表达式起点一致（1-based）；VAR 按标识符宽度匹配。 */
static int expr_at(const struct ASTExpr *e, int line_1, int col_1) {
    if (!e || e->line != line_1) return 0;
    if (e->kind == AST_EXPR_VAR && e->value.var.name)
        return col_in_ident_span(line_1, col_1, e->line, e->col, e->value.var.name);
    return e->col == col_1;
}

/** 函数名是否覆盖光标（支持点击长标识符中间字符）。 */
static int func_name_covers(const struct ASTFunc *f, int line_1, int col_1) {
    return f && f->name && col_in_ident_span(line_1, col_1, f->line, f->col, f->name);
}

/** 在 entry 与已加载 import 模块中按名称查找函数（含 extern 声明）。 */
static struct ASTFunc *find_func_in_module_by_name(const struct ASTModule *mod, const char *name) {
    int i, j;
    if (!name) return NULL;
    if (mod) {
        for (i = 0; i < mod->num_funcs; i++) {
            struct ASTFunc *f = mod->funcs[i];
            if (f && f->name && strcmp(f->name, name) == 0) return f;
        }
    }
    for (j = 0; j < s_n_all_deps; j++) {
        ASTModule *m = s_all_dep_mods[j];
        if (!m) continue;
        for (i = 0; i < m->num_funcs; i++) {
            struct ASTFunc *f = m->funcs[i];
            if (f && f->name && strcmp(f->name, name) == 0) return f;
        }
    }
    return NULL;
}

/* ---------- 行/区间索引：按行快速定位所在函数，减少 definition/references/hover 的全 AST 遍历 ---------- */

/** 求表达式中出现的最大行号（递归）。 */
static int expr_max_line(const struct ASTExpr *e) {
    if (!e) return 0;
    int m = e->line;
    switch (e->kind) {
        case AST_EXPR_CALL:
            if (e->value.call.callee) { int t = expr_max_line(e->value.call.callee); if (t > m) m = t; }
            for (int i = 0; i < e->value.call.num_args; i++)
                if (e->value.call.args[i]) { int t = expr_max_line(e->value.call.args[i]); if (t > m) m = t; }
            break;
        case AST_EXPR_METHOD_CALL:
            if (e->value.method_call.base) { int t = expr_max_line(e->value.method_call.base); if (t > m) m = t; }
            for (int i = 0; i < e->value.method_call.num_args; i++)
                if (e->value.method_call.args[i]) { int t = expr_max_line(e->value.method_call.args[i]); if (t > m) m = t; }
            break;
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
        case AST_EXPR_ASSIGN:
            if (e->value.binop.left) { int t = expr_max_line(e->value.binop.left); if (t > m) m = t; }
            if (e->value.binop.right) { int t = expr_max_line(e->value.binop.right); if (t > m) m = t; }
            break;
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT: case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF:
        case AST_EXPR_RETURN: case AST_EXPR_PANIC:
            if (e->value.unary.operand) { int t = expr_max_line(e->value.unary.operand); if (t > m) m = t; }
            break;
        case AST_EXPR_IF: case AST_EXPR_TERNARY:
            if (e->value.if_expr.cond) { int t = expr_max_line(e->value.if_expr.cond); if (t > m) m = t; }
            if (e->value.if_expr.then_expr) { int t = expr_max_line(e->value.if_expr.then_expr); if (t > m) m = t; }
            if (e->value.if_expr.else_expr) { int t = expr_max_line(e->value.if_expr.else_expr); if (t > m) m = t; }
            break;
        case AST_EXPR_BLOCK:
            /* 块内行号由 block_max_line 覆盖，此处仅取本节点 */
            break;
        case AST_EXPR_MATCH:
            if (e->value.match_expr.matched_expr) { int t = expr_max_line(e->value.match_expr.matched_expr); if (t > m) m = t; }
            for (int i = 0; i < e->value.match_expr.num_arms; i++)
                if (e->value.match_expr.arms[i].result) { int t = expr_max_line(e->value.match_expr.arms[i].result); if (t > m) m = t; }
            break;
        case AST_EXPR_FIELD_ACCESS:
            if (e->value.field_access.base) { int t = expr_max_line(e->value.field_access.base); if (t > m) m = t; }
            break;
        case AST_EXPR_STRUCT_LIT:
            for (int i = 0; i < e->value.struct_lit.num_fields; i++)
                if (e->value.struct_lit.inits[i]) { int t = expr_max_line(e->value.struct_lit.inits[i]); if (t > m) m = t; }
            break;
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++)
                if (e->value.array_lit.elems[i]) { int t = expr_max_line(e->value.array_lit.elems[i]); if (t > m) m = t; }
            break;
        case AST_EXPR_INDEX:
            if (e->value.index.base) { int t = expr_max_line(e->value.index.base); if (t > m) m = t; }
            if (e->value.index.index_expr) { int t = expr_max_line(e->value.index.index_expr); if (t > m) m = t; }
            break;
        case AST_EXPR_AS:
            if (e->value.as_type.operand) { int t = expr_max_line(e->value.as_type.operand); if (t > m) m = t; }
            break;
        default:
            break;
    }
    return m;
}

/** 求块内出现的最大行号。 */
static int block_max_line(const struct ASTBlock *b) {
    if (!b) return 0;
    int m = 0;
    int i;
    for (i = 0; i < b->num_consts; i++)
        if (b->const_decls[i].init) { int t = expr_max_line(b->const_decls[i].init); if (t > m) m = t; }
    for (i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].init) { int t = expr_max_line(b->let_decls[i].init); if (t > m) m = t; }
    for (i = 0; i < b->num_loops; i++) {
        if (b->loops[i].cond) { int t = expr_max_line(b->loops[i].cond); if (t > m) m = t; }
        if (b->loops[i].body) { int t = block_max_line(b->loops[i].body); if (t > m) m = t; }
    }
    for (i = 0; i < b->num_for_loops; i++) {
        struct ASTForLoop *fl = &b->for_loops[i];
        if (fl->init) { int t = expr_max_line(fl->init); if (t > m) m = t; }
        if (fl->cond) { int t = expr_max_line(fl->cond); if (t > m) m = t; }
        if (fl->step) { int t = expr_max_line(fl->step); if (t > m) m = t; }
        if (fl->body) { int t = block_max_line(fl->body); if (t > m) m = t; }
    }
    for (i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr)
            { int t = expr_max_line(b->labeled_stmts[i].u.return_expr); if (t > m) m = t; }
    for (i = 0; i < b->num_expr_stmts; i++)
        if (b->expr_stmts[i]) { int t = expr_max_line(b->expr_stmts[i]); if (t > m) m = t; }
    if (b->final_expr) { int t = expr_max_line(b->final_expr); if (t > m) m = t; }
    return m;
}

/** 根据模块构建行→函数索引（每个函数的 [start_line, end_line]），供 get_function_at_line 使用。 */
static void build_line_index(const struct ASTModule *mod) {
    s_line_index_n = 0;
    if (!mod || !mod->funcs) return;
    for (int i = 0; i < mod->num_funcs && s_line_index_n < LSP_LINE_INDEX_MAX; i++) {
        struct ASTFunc *f = mod->funcs[i];
        if (!f) continue;
        int start = f->line > 0 ? f->line : 1;
        int end = start;
        if (f->body) {
            int be = block_max_line(f->body);
            if (be > end) end = be;
        }
        s_line_index[s_line_index_n].start_line = start;
        s_line_index[s_line_index_n].end_line = end;
        s_line_index[s_line_index_n].func = f;
        s_line_index_n++;
    }
}

/** 返回 func 在 s_line_index 中的下标，未找到返回 -1。 */
static int line_index_of_func(const struct ASTFunc *func) {
    for (int i = 0; i < s_line_index_n; i++)
        if (s_line_index[i].func == func) return i;
    return -1;
}

/** 向 func 对应的引用表追加 (line, col)；用于构建引用索引。 */
static void add_ref_for_func(const struct ASTFunc *func, int line, int col) {
    int j = line_index_of_func(func);
    if (j < 0 || s_refs_count[j] >= LSP_REFS_PER_FUNC_MAX) return;
    for (int i = 0; i < s_refs_count[j]; i++)
        if (s_refs_lines[j][i] == line && s_refs_cols[j][i] == col) return;
    s_refs_lines[j][s_refs_count[j]] = line;
    s_refs_cols[j][s_refs_count[j]] = col;
    s_refs_count[j]++;
}

/** 遍历表达式，将 resolved_callee_func / resolved_impl_func 的调用点加入引用索引。 */
static void collect_refs_index_in_expr(const struct ASTExpr *e) {
    if (!e) return;
    if (e->kind == AST_EXPR_CALL && e->value.call.resolved_callee_func) {
        const struct ASTExpr *callee = e->value.call.callee;
        if (callee) add_ref_for_func(e->value.call.resolved_callee_func, callee->line, callee->col);
    } else if (e->kind == AST_EXPR_METHOD_CALL && e->value.method_call.resolved_impl_func)
        add_ref_for_func(e->value.method_call.resolved_impl_func, e->line, e->col);
    switch (e->kind) {
        case AST_EXPR_CALL:
            if (e->value.call.callee) collect_refs_index_in_expr(e->value.call.callee);
            for (int i = 0; i < e->value.call.num_args; i++)
                if (e->value.call.args[i]) collect_refs_index_in_expr(e->value.call.args[i]);
            break;
        case AST_EXPR_METHOD_CALL:
            collect_refs_index_in_expr(e->value.method_call.base);
            for (int i = 0; i < e->value.method_call.num_args; i++)
                if (e->value.method_call.args[i]) collect_refs_index_in_expr(e->value.method_call.args[i]);
            break;
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
            collect_refs_index_in_expr(e->value.binop.left);
            collect_refs_index_in_expr(e->value.binop.right);
            break;
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT: case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF:
        case AST_EXPR_RETURN: case AST_EXPR_PANIC:
            collect_refs_index_in_expr(e->value.unary.operand);
            break;
        case AST_EXPR_IF: case AST_EXPR_TERNARY:
            collect_refs_index_in_expr(e->value.if_expr.cond);
            collect_refs_index_in_expr(e->value.if_expr.then_expr);
            collect_refs_index_in_expr(e->value.if_expr.else_expr);
            break;
        case AST_EXPR_ASSIGN:
            collect_refs_index_in_expr(e->value.binop.left);
            collect_refs_index_in_expr(e->value.binop.right);
            break;
        case AST_EXPR_MATCH:
            collect_refs_index_in_expr(e->value.match_expr.matched_expr);
            for (int i = 0; i < e->value.match_expr.num_arms; i++)
                collect_refs_index_in_expr(e->value.match_expr.arms[i].result);
            break;
        case AST_EXPR_FIELD_ACCESS:
            collect_refs_index_in_expr(e->value.field_access.base);
            break;
        case AST_EXPR_STRUCT_LIT:
            for (int i = 0; i < e->value.struct_lit.num_fields; i++)
                collect_refs_index_in_expr(e->value.struct_lit.inits[i]);
            break;
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++)
                collect_refs_index_in_expr(e->value.array_lit.elems[i]);
            break;
        case AST_EXPR_INDEX:
            collect_refs_index_in_expr(e->value.index.base);
            collect_refs_index_in_expr(e->value.index.index_expr);
            break;
        case AST_EXPR_AS:
            collect_refs_index_in_expr(e->value.as_type.operand);
            break;
        default:
            break;
    }
}

static void collect_refs_index_in_block(const struct ASTBlock *b) {
    if (!b) return;
    int i;
    for (i = 0; i < b->num_consts; i++)
        if (b->const_decls[i].init) collect_refs_index_in_expr(b->const_decls[i].init);
    for (i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].init) collect_refs_index_in_expr(b->let_decls[i].init);
    for (i = 0; i < b->num_loops; i++) {
        if (b->loops[i].cond) collect_refs_index_in_expr(b->loops[i].cond);
        if (b->loops[i].body) collect_refs_index_in_block(b->loops[i].body);
    }
    for (i = 0; i < b->num_for_loops; i++) {
        struct ASTForLoop *fl = &b->for_loops[i];
        if (fl->init) collect_refs_index_in_expr(fl->init);
        if (fl->cond) collect_refs_index_in_expr(fl->cond);
        if (fl->step) collect_refs_index_in_expr(fl->step);
        if (fl->body) collect_refs_index_in_block(fl->body);
    }
    for (i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr)
            collect_refs_index_in_expr(b->labeled_stmts[i].u.return_expr);
    for (i = 0; i < b->num_expr_stmts; i++)
        if (b->expr_stmts[i]) collect_refs_index_in_expr(b->expr_stmts[i]);
    if (b->final_expr) collect_refs_index_in_expr(b->final_expr);
}

/** 在 build_line_index 之后调用：一次遍历全模块，为每个函数填好引用索引。 */
static void build_refs_index(const struct ASTModule *mod) {
    for (int i = 0; i < s_line_index_n; i++) {
        s_refs_count[i] = 0;
        add_ref_for_func(s_line_index[i].func, s_line_index[i].func->line, s_line_index[i].func->col);
    }
    if (!mod || !mod->funcs) return;
    for (int i = 0; i < mod->num_funcs; i++)
        if (mod->funcs[i]->body) collect_refs_index_in_block(mod->funcs[i]->body);
}

/** 返回包含行 line_1（1-based）的函数；若多函数包含该行则取区间最小的（最内层）。无则返回 NULL。 */
static struct ASTFunc *get_function_at_line(const struct ASTModule *mod, int line_1) {
    (void)mod;
    struct ASTFunc *best = NULL;
    int best_span = 0;
    for (int i = 0; i < s_line_index_n; i++) {
        if (line_1 >= s_line_index[i].start_line && line_1 <= s_line_index[i].end_line) {
            int span = s_line_index[i].end_line - s_line_index[i].start_line;
            if (!best || span < best_span) {
                best = s_line_index[i].func;
                best_span = span;
            }
        }
    }
    return best;
}

/**
 * 在表达式 e 中查找位置 (line_1, col_1) 对应的“定义”：
 * 若该位置在函数调用上（call 或 callee），且已解析到 resolved_callee_func / resolved_impl_func，则写出定义行列并返回 1。
 * 先递归子表达式，以便命中“调用内的标识符”；否则再检查本节点是否为 CALL/METHOD_CALL 且位置匹配。
 */
static int find_def_in_expr(const struct ASTModule *mod, const struct ASTExpr *e, int line_1, int col_1, int *out_line, int *out_col) {
    if (!mod || !e || !out_line || !out_col) return 0;
    switch (e->kind) {
        case AST_EXPR_CALL: {
            const struct ASTExpr *callee = e->value.call.callee;
            if (callee && find_def_in_expr(mod, callee, line_1, col_1, out_line, out_col)) return 1;
            for (int i = 0; i < e->value.call.num_args; i++)
                if (e->value.call.args[i] && find_def_in_expr(mod, e->value.call.args[i], line_1, col_1, out_line, out_col)) return 1;
            if ((expr_at(e, line_1, col_1) || (callee && expr_at(callee, line_1, col_1))) && e->value.call.resolved_callee_func) {
                struct ASTFunc *f = e->value.call.resolved_callee_func;
                s_def_target_func = f;
                *out_line = f->line;
                *out_col = f->col;
                return 1;
            }
            return 0;
        }
        case AST_EXPR_METHOD_CALL: {
            if (e->value.method_call.base && find_def_in_expr(mod, e->value.method_call.base, line_1, col_1, out_line, out_col)) return 1;
            for (int i = 0; i < e->value.method_call.num_args; i++)
                if (e->value.method_call.args[i] && find_def_in_expr(mod, e->value.method_call.args[i], line_1, col_1, out_line, out_col)) return 1;
            if (expr_at(e, line_1, col_1) && e->value.method_call.resolved_impl_func) {
                struct ASTFunc *f = e->value.method_call.resolved_impl_func;
                s_def_target_func = f;
                *out_line = f->line;
                *out_col = f->col;
                return 1;
            }
            return 0;
        }
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
            if (e->value.binop.left && find_def_in_expr(mod, e->value.binop.left, line_1, col_1, out_line, out_col)) return 1;
            if (e->value.binop.right && find_def_in_expr(mod, e->value.binop.right, line_1, col_1, out_line, out_col)) return 1;
            return 0;
        case AST_EXPR_NEG:
        case AST_EXPR_BITNOT:
        case AST_EXPR_LOGNOT:
        case AST_EXPR_ADDR_OF:
        case AST_EXPR_DEREF:
            return e->value.unary.operand ? find_def_in_expr(mod, e->value.unary.operand, line_1, col_1, out_line, out_col) : 0;
        case AST_EXPR_IF:
            if (e->value.if_expr.cond && find_def_in_expr(mod, e->value.if_expr.cond, line_1, col_1, out_line, out_col)) return 1;
            if (e->value.if_expr.then_expr && find_def_in_expr(mod, e->value.if_expr.then_expr, line_1, col_1, out_line, out_col)) return 1;
            if (e->value.if_expr.else_expr && find_def_in_expr(mod, e->value.if_expr.else_expr, line_1, col_1, out_line, out_col)) return 1;
            return 0;
        case AST_EXPR_BLOCK:
            return e->value.block ? find_def_in_block(mod, e->value.block, line_1, col_1, out_line, out_col) : 0;
        case AST_EXPR_TERNARY:
            if (e->value.if_expr.cond && find_def_in_expr(mod, e->value.if_expr.cond, line_1, col_1, out_line, out_col)) return 1;
            if (e->value.if_expr.then_expr && find_def_in_expr(mod, e->value.if_expr.then_expr, line_1, col_1, out_line, out_col)) return 1;
            if (e->value.if_expr.else_expr && find_def_in_expr(mod, e->value.if_expr.else_expr, line_1, col_1, out_line, out_col)) return 1;
            return 0;
        case AST_EXPR_ASSIGN:
            if (e->value.binop.left && find_def_in_expr(mod, e->value.binop.left, line_1, col_1, out_line, out_col)) return 1;
            if (e->value.binop.right && find_def_in_expr(mod, e->value.binop.right, line_1, col_1, out_line, out_col)) return 1;
            return 0;
        case AST_EXPR_RETURN:
            return e->value.unary.operand ? find_def_in_expr(mod, e->value.unary.operand, line_1, col_1, out_line, out_col) : 0;
        case AST_EXPR_PANIC:
            return e->value.unary.operand ? find_def_in_expr(mod, e->value.unary.operand, line_1, col_1, out_line, out_col) : 0;
        case AST_EXPR_MATCH:
            if (e->value.match_expr.matched_expr && find_def_in_expr(mod, e->value.match_expr.matched_expr, line_1, col_1, out_line, out_col)) return 1;
            for (int i = 0; i < e->value.match_expr.num_arms; i++)
                if (e->value.match_expr.arms[i].result && find_def_in_expr(mod, e->value.match_expr.arms[i].result, line_1, col_1, out_line, out_col)) return 1;
            return 0;
        case AST_EXPR_FIELD_ACCESS:
            return e->value.field_access.base ? find_def_in_expr(mod, e->value.field_access.base, line_1, col_1, out_line, out_col) : 0;
        case AST_EXPR_STRUCT_LIT:
            for (int i = 0; i < e->value.struct_lit.num_fields; i++)
                if (e->value.struct_lit.inits[i] && find_def_in_expr(mod, e->value.struct_lit.inits[i], line_1, col_1, out_line, out_col)) return 1;
            return 0;
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++)
                if (e->value.array_lit.elems[i] && find_def_in_expr(mod, e->value.array_lit.elems[i], line_1, col_1, out_line, out_col)) return 1;
            return 0;
        case AST_EXPR_INDEX:
            if (e->value.index.base && find_def_in_expr(mod, e->value.index.base, line_1, col_1, out_line, out_col)) return 1;
            if (e->value.index.index_expr && find_def_in_expr(mod, e->value.index.index_expr, line_1, col_1, out_line, out_col)) return 1;
            return 0;
        case AST_EXPR_AS:
            return e->value.as_type.operand ? find_def_in_expr(mod, e->value.as_type.operand, line_1, col_1, out_line, out_col) : 0;
        case AST_EXPR_VAR: {
            if (!expr_at(e, line_1, col_1)) return 0;
            struct ASTFunc *f = find_func_in_module_by_name(mod, e->value.var.name);
            if (f) {
                s_def_target_func = f;
                *out_line = f->line;
                *out_col = f->col;
                return 1;
            }
            return 0;
        }
        default:
            return 0;
    }
}

/** 在块 b 内所有表达式（const/let init、循环、expr_stmts、final_expr）中查找定义。 */
static int find_def_in_block(const struct ASTModule *mod, const struct ASTBlock *b, int line_1, int col_1, int *out_line, int *out_col) {
    if (!mod || !b || !out_line || !out_col) return 0;
    int i;
    for (i = 0; i < b->num_consts; i++)
        if (b->const_decls[i].init && find_def_in_expr(mod, b->const_decls[i].init, line_1, col_1, out_line, out_col)) return 1;
    for (i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].init && find_def_in_expr(mod, b->let_decls[i].init, line_1, col_1, out_line, out_col)) return 1;
    for (i = 0; i < b->num_loops; i++) {
        if (b->loops[i].cond && find_def_in_expr(mod, b->loops[i].cond, line_1, col_1, out_line, out_col)) return 1;
        if (b->loops[i].body && find_def_in_block(mod, b->loops[i].body, line_1, col_1, out_line, out_col)) return 1;
    }
    for (i = 0; i < b->num_for_loops; i++) {
        struct ASTForLoop *fl = &b->for_loops[i];
        if (fl->init && find_def_in_expr(mod, fl->init, line_1, col_1, out_line, out_col)) return 1;
        if (fl->cond && find_def_in_expr(mod, fl->cond, line_1, col_1, out_line, out_col)) return 1;
        if (fl->step && find_def_in_expr(mod, fl->step, line_1, col_1, out_line, out_col)) return 1;
        if (fl->body && find_def_in_block(mod, fl->body, line_1, col_1, out_line, out_col)) return 1;
    }
    for (i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr &&
            find_def_in_expr(mod, b->labeled_stmts[i].u.return_expr, line_1, col_1, out_line, out_col)) return 1;
    for (i = 0; i < b->num_expr_stmts; i++)
        if (b->expr_stmts[i] && find_def_in_expr(mod, b->expr_stmts[i], line_1, col_1, out_line, out_col)) return 1;
    if (b->final_expr && find_def_in_expr(mod, b->final_expr, line_1, col_1, out_line, out_col)) return 1;
    return 0;
}

/** 在模块中查找位置对应的定义；先按行索引定位到包含该行的函数，只遍历该函数 body，减少大文件下的全 AST 遍历。 */
static int find_def_in_module(const struct ASTModule *mod, int line_1, int col_1, int *out_line, int *out_col) {
    if (!mod || !out_line || !out_col) return 0;
    /* 若光标在函数名上（含长标识符中间字符），定义即该函数（含 extern 声明）。 */
    for (int i = 0; i < mod->num_funcs; i++) {
        struct ASTFunc *f = mod->funcs[i];
        if (func_name_covers(f, line_1, col_1)) {
            s_def_target_func = f;
            *out_line = f->line;
            *out_col = f->col;
            return 1;
        }
    }
    struct ASTFunc *containing = get_function_at_line(mod, line_1);
    if (containing && containing->body)
        return find_def_in_block(mod, containing->body, line_1, col_1, out_line, out_col);
    return 0;
}

/* ---------- References：目标函数 + 收集引用 ---------- */

/** 在表达式 e 中查找位置 (line_1, col_1) 对应的“被调用函数”（CALL 的 resolved_callee_func 或 METHOD_CALL 的 resolved_impl_func）。 */
static struct ASTFunc *find_callee_func_in_expr(const struct ASTExpr *e, int line_1, int col_1) {
    if (!e) return NULL;
    if (e->kind == AST_EXPR_CALL) {
        const struct ASTExpr *callee = e->value.call.callee;
        if ((expr_at(e, line_1, col_1) || (callee && expr_at(callee, line_1, col_1))) && e->value.call.resolved_callee_func)
            return e->value.call.resolved_callee_func;
        if (callee) {
            struct ASTFunc *f = find_callee_func_in_expr(callee, line_1, col_1);
            if (f) return f;
        }
        for (int i = 0; i < e->value.call.num_args; i++)
            if (e->value.call.args[i]) {
                struct ASTFunc *f = find_callee_func_in_expr(e->value.call.args[i], line_1, col_1);
                if (f) return f;
            }
        return NULL;
    }
    if (e->kind == AST_EXPR_METHOD_CALL) {
        if (expr_at(e, line_1, col_1) && e->value.method_call.resolved_impl_func)
            return e->value.method_call.resolved_impl_func;
        if (e->value.method_call.base) {
            struct ASTFunc *f = find_callee_func_in_expr(e->value.method_call.base, line_1, col_1);
            if (f) return f;
        }
        for (int i = 0; i < e->value.method_call.num_args; i++)
            if (e->value.method_call.args[i]) {
                struct ASTFunc *f = find_callee_func_in_expr(e->value.method_call.args[i], line_1, col_1);
                if (f) return f;
            }
        return NULL;
    }
    /* 其余种类仅递归子节点 */
    switch (e->kind) {
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
            if (e->value.binop.left) { struct ASTFunc *f = find_callee_func_in_expr(e->value.binop.left, line_1, col_1); if (f) return f; }
            if (e->value.binop.right) { struct ASTFunc *f = find_callee_func_in_expr(e->value.binop.right, line_1, col_1); if (f) return f; }
            break;
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT: case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF:
        case AST_EXPR_RETURN: case AST_EXPR_PANIC:
            if (e->value.unary.operand) return find_callee_func_in_expr(e->value.unary.operand, line_1, col_1);
            break;
        case AST_EXPR_IF: case AST_EXPR_TERNARY:
            if (e->value.if_expr.cond) { struct ASTFunc *f = find_callee_func_in_expr(e->value.if_expr.cond, line_1, col_1); if (f) return f; }
            if (e->value.if_expr.then_expr) { struct ASTFunc *f = find_callee_func_in_expr(e->value.if_expr.then_expr, line_1, col_1); if (f) return f; }
            if (e->value.if_expr.else_expr) { struct ASTFunc *f = find_callee_func_in_expr(e->value.if_expr.else_expr, line_1, col_1); if (f) return f; }
            break;
        case AST_EXPR_BLOCK:
            break; /* 块内由 find_callee_func_in_block 遍历 */
        case AST_EXPR_ASSIGN:
            if (e->value.binop.left) { struct ASTFunc *f = find_callee_func_in_expr(e->value.binop.left, line_1, col_1); if (f) return f; }
            if (e->value.binop.right) { struct ASTFunc *f = find_callee_func_in_expr(e->value.binop.right, line_1, col_1); if (f) return f; }
            break;
        case AST_EXPR_MATCH:
            if (e->value.match_expr.matched_expr) { struct ASTFunc *f = find_callee_func_in_expr(e->value.match_expr.matched_expr, line_1, col_1); if (f) return f; }
            for (int i = 0; i < e->value.match_expr.num_arms; i++)
                if (e->value.match_expr.arms[i].result) { struct ASTFunc *f = find_callee_func_in_expr(e->value.match_expr.arms[i].result, line_1, col_1); if (f) return f; }
            break;
        case AST_EXPR_FIELD_ACCESS:
            if (e->value.field_access.base) return find_callee_func_in_expr(e->value.field_access.base, line_1, col_1);
            break;
        case AST_EXPR_STRUCT_LIT:
            for (int i = 0; i < e->value.struct_lit.num_fields; i++)
                if (e->value.struct_lit.inits[i]) { struct ASTFunc *f = find_callee_func_in_expr(e->value.struct_lit.inits[i], line_1, col_1); if (f) return f; }
            break;
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++)
                if (e->value.array_lit.elems[i]) { struct ASTFunc *f = find_callee_func_in_expr(e->value.array_lit.elems[i], line_1, col_1); if (f) return f; }
            break;
        case AST_EXPR_INDEX:
            if (e->value.index.base) { struct ASTFunc *f = find_callee_func_in_expr(e->value.index.base, line_1, col_1); if (f) return f; }
            if (e->value.index.index_expr) { struct ASTFunc *f = find_callee_func_in_expr(e->value.index.index_expr, line_1, col_1); if (f) return f; }
            break;
        case AST_EXPR_AS:
            if (e->value.as_type.operand) return find_callee_func_in_expr(e->value.as_type.operand, line_1, col_1);
            break;
        default:
            break;
    }
    return NULL;
}

static struct ASTFunc *find_callee_func_in_block(const struct ASTBlock *b, int line_1, int col_1) {
    if (!b) return NULL;
    int i;
    for (i = 0; i < b->num_consts; i++)
        if (b->const_decls[i].init) { struct ASTFunc *f = find_callee_func_in_expr(b->const_decls[i].init, line_1, col_1); if (f) return f; }
    for (i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].init) { struct ASTFunc *f = find_callee_func_in_expr(b->let_decls[i].init, line_1, col_1); if (f) return f; }
    for (i = 0; i < b->num_loops; i++) {
        if (b->loops[i].cond) { struct ASTFunc *f = find_callee_func_in_expr(b->loops[i].cond, line_1, col_1); if (f) return f; }
        if (b->loops[i].body) { struct ASTFunc *f = find_callee_func_in_block(b->loops[i].body, line_1, col_1); if (f) return f; }
    }
    for (i = 0; i < b->num_for_loops; i++) {
        struct ASTForLoop *fl = &b->for_loops[i];
        if (fl->init) { struct ASTFunc *f = find_callee_func_in_expr(fl->init, line_1, col_1); if (f) return f; }
        if (fl->cond) { struct ASTFunc *f = find_callee_func_in_expr(fl->cond, line_1, col_1); if (f) return f; }
        if (fl->step) { struct ASTFunc *f = find_callee_func_in_expr(fl->step, line_1, col_1); if (f) return f; }
        if (fl->body) { struct ASTFunc *f = find_callee_func_in_block(fl->body, line_1, col_1); if (f) return f; }
    }
    for (i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr)
            { struct ASTFunc *f = find_callee_func_in_expr(b->labeled_stmts[i].u.return_expr, line_1, col_1); if (f) return f; }
    for (i = 0; i < b->num_expr_stmts; i++)
        if (b->expr_stmts[i]) { struct ASTFunc *f = find_callee_func_in_expr(b->expr_stmts[i], line_1, col_1); if (f) return f; }
    if (b->final_expr) { struct ASTFunc *f = find_callee_func_in_expr(b->final_expr, line_1, col_1); if (f) return f; }
    return NULL;
}

/** 确定位置 (line_1, col_1) 处的“目标函数”：若在函数名定义上则返回该函数，若在调用处则返回被调函数。用行索引只搜包含该行的函数。 */
static struct ASTFunc *find_target_function_at(const struct ASTModule *mod, int line_1, int col_1) {
    if (!mod) return NULL;
    for (int i = 0; i < mod->num_funcs; i++) {
        struct ASTFunc *f = mod->funcs[i];
        if (func_name_covers(f, line_1, col_1)) return f;
    }
    struct ASTFunc *containing = get_function_at_line(mod, line_1);
    if (containing && containing->body) {
        struct ASTFunc *f = find_callee_func_in_block(containing->body, line_1, col_1);
        if (f) return f;
    }
    return NULL;
}

/** 收集对 func 的所有引用位置（定义 + 各调用点），写入 out_lines/out_cols，返回个数，最多 max_refs。 */
static int collect_refs_add(int line, int col, int *out_lines, int *out_cols, int *count, int max_refs) {
    if (*count >= max_refs) return 0;
    for (int i = 0; i < *count; i++)
        if (out_lines[i] == line && out_cols[i] == col) return 0; /* 去重 */
    out_lines[*count] = line;
    out_cols[*count] = col;
    (*count)++;
    return 1;
}

static void collect_refs_in_expr(const struct ASTExpr *e, const struct ASTFunc *func, int *out_lines, int *out_cols, int *count, int max_refs) {
    if (!e || *count >= max_refs) return;
    if (e->kind == AST_EXPR_CALL && e->value.call.resolved_callee_func == func) {
        const struct ASTExpr *callee = e->value.call.callee;
        if (callee) collect_refs_add(callee->line, callee->col, out_lines, out_cols, count, max_refs);
    } else if (e->kind == AST_EXPR_METHOD_CALL && e->value.method_call.resolved_impl_func == func)
        collect_refs_add(e->line, e->col, out_lines, out_cols, count, max_refs);
    switch (e->kind) {
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
            collect_refs_in_expr(e->value.binop.left, func, out_lines, out_cols, count, max_refs);
            collect_refs_in_expr(e->value.binop.right, func, out_lines, out_cols, count, max_refs);
            break;
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT: case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF:
        case AST_EXPR_RETURN: case AST_EXPR_PANIC:
            collect_refs_in_expr(e->value.unary.operand, func, out_lines, out_cols, count, max_refs);
            break;
        case AST_EXPR_IF: case AST_EXPR_TERNARY:
            collect_refs_in_expr(e->value.if_expr.cond, func, out_lines, out_cols, count, max_refs);
            collect_refs_in_expr(e->value.if_expr.then_expr, func, out_lines, out_cols, count, max_refs);
            collect_refs_in_expr(e->value.if_expr.else_expr, func, out_lines, out_cols, count, max_refs);
            break;
        case AST_EXPR_BLOCK:
            break;
        case AST_EXPR_ASSIGN:
            collect_refs_in_expr(e->value.binop.left, func, out_lines, out_cols, count, max_refs);
            collect_refs_in_expr(e->value.binop.right, func, out_lines, out_cols, count, max_refs);
            break;
        case AST_EXPR_MATCH:
            collect_refs_in_expr(e->value.match_expr.matched_expr, func, out_lines, out_cols, count, max_refs);
            for (int i = 0; i < e->value.match_expr.num_arms; i++)
                collect_refs_in_expr(e->value.match_expr.arms[i].result, func, out_lines, out_cols, count, max_refs);
            break;
        case AST_EXPR_FIELD_ACCESS:
            collect_refs_in_expr(e->value.field_access.base, func, out_lines, out_cols, count, max_refs);
            break;
        case AST_EXPR_STRUCT_LIT:
            for (int i = 0; i < e->value.struct_lit.num_fields; i++)
                collect_refs_in_expr(e->value.struct_lit.inits[i], func, out_lines, out_cols, count, max_refs);
            break;
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++)
                collect_refs_in_expr(e->value.array_lit.elems[i], func, out_lines, out_cols, count, max_refs);
            break;
        case AST_EXPR_INDEX:
            collect_refs_in_expr(e->value.index.base, func, out_lines, out_cols, count, max_refs);
            collect_refs_in_expr(e->value.index.index_expr, func, out_lines, out_cols, count, max_refs);
            break;
        case AST_EXPR_CALL:
            if (e->value.call.callee) collect_refs_in_expr(e->value.call.callee, func, out_lines, out_cols, count, max_refs);
            for (int i = 0; i < e->value.call.num_args; i++)
                collect_refs_in_expr(e->value.call.args[i], func, out_lines, out_cols, count, max_refs);
            break;
        case AST_EXPR_METHOD_CALL:
            collect_refs_in_expr(e->value.method_call.base, func, out_lines, out_cols, count, max_refs);
            for (int i = 0; i < e->value.method_call.num_args; i++)
                collect_refs_in_expr(e->value.method_call.args[i], func, out_lines, out_cols, count, max_refs);
            break;
        case AST_EXPR_AS:
            collect_refs_in_expr(e->value.as_type.operand, func, out_lines, out_cols, count, max_refs);
            break;
        default:
            break;
    }
}

static void collect_refs_in_block(const struct ASTBlock *b, const struct ASTFunc *func, int *out_lines, int *out_cols, int *count, int max_refs) {
    if (!b) return;
    int i;
    for (i = 0; i < b->num_consts; i++)
        if (b->const_decls[i].init) collect_refs_in_expr(b->const_decls[i].init, func, out_lines, out_cols, count, max_refs);
    for (i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].init) collect_refs_in_expr(b->let_decls[i].init, func, out_lines, out_cols, count, max_refs);
    for (i = 0; i < b->num_loops; i++) {
        if (b->loops[i].cond) collect_refs_in_expr(b->loops[i].cond, func, out_lines, out_cols, count, max_refs);
        if (b->loops[i].body) collect_refs_in_block(b->loops[i].body, func, out_lines, out_cols, count, max_refs);
    }
    for (i = 0; i < b->num_for_loops; i++) {
        struct ASTForLoop *fl = &b->for_loops[i];
        if (fl->init) collect_refs_in_expr(fl->init, func, out_lines, out_cols, count, max_refs);
        if (fl->cond) collect_refs_in_expr(fl->cond, func, out_lines, out_cols, count, max_refs);
        if (fl->step) collect_refs_in_expr(fl->step, func, out_lines, out_cols, count, max_refs);
        if (fl->body) collect_refs_in_block(fl->body, func, out_lines, out_cols, count, max_refs);
    }
    for (i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr)
            collect_refs_in_expr(b->labeled_stmts[i].u.return_expr, func, out_lines, out_cols, count, max_refs);
    for (i = 0; i < b->num_expr_stmts; i++)
        if (b->expr_stmts[i]) collect_refs_in_expr(b->expr_stmts[i], func, out_lines, out_cols, count, max_refs);
    if (b->final_expr) collect_refs_in_expr(b->final_expr, func, out_lines, out_cols, count, max_refs);
}

static int collect_refs_to_func(const struct ASTModule *mod, const struct ASTFunc *func, int *out_lines, int *out_cols, int max_refs) {
    int count = 0;
    collect_refs_add(func->line, func->col, out_lines, out_cols, &count, max_refs);
    for (int i = 0; i < mod->num_funcs; i++)
        if (mod->funcs[i]->body) collect_refs_in_block(mod->funcs[i]->body, func, out_lines, out_cols, &count, max_refs);
    return count;
}

/* ---------- Hover：按位置找表达式 + 类型转字符串 ---------- */

/** 递归找包含 (line_1, col_1) 的最内层表达式；先查子节点，再判断本节点。 */
static struct ASTExpr *get_innermost_expr_at(struct ASTExpr *e, int line_1, int col_1) {
    if (!e) return NULL;
    struct ASTExpr *child = NULL;
    switch (e->kind) {
        case AST_EXPR_CALL:
            if (e->value.call.callee) { child = get_innermost_expr_at(e->value.call.callee, line_1, col_1); if (child) return child; }
            for (int i = 0; i < e->value.call.num_args; i++)
                if (e->value.call.args[i]) { child = get_innermost_expr_at(e->value.call.args[i], line_1, col_1); if (child) return child; }
            break;
        case AST_EXPR_METHOD_CALL:
            if (e->value.method_call.base) { child = get_innermost_expr_at(e->value.method_call.base, line_1, col_1); if (child) return child; }
            for (int i = 0; i < e->value.method_call.num_args; i++)
                if (e->value.method_call.args[i]) { child = get_innermost_expr_at(e->value.method_call.args[i], line_1, col_1); if (child) return child; }
            break;
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
            if (e->value.binop.left) { child = get_innermost_expr_at(e->value.binop.left, line_1, col_1); if (child) return child; }
            if (e->value.binop.right) { child = get_innermost_expr_at(e->value.binop.right, line_1, col_1); if (child) return child; }
            break;
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT: case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF:
        case AST_EXPR_RETURN: case AST_EXPR_PANIC:
            if (e->value.unary.operand) return get_innermost_expr_at(e->value.unary.operand, line_1, col_1);
            break;
        case AST_EXPR_IF: case AST_EXPR_TERNARY:
            if (e->value.if_expr.cond) { child = get_innermost_expr_at(e->value.if_expr.cond, line_1, col_1); if (child) return child; }
            if (e->value.if_expr.then_expr) { child = get_innermost_expr_at(e->value.if_expr.then_expr, line_1, col_1); if (child) return child; }
            if (e->value.if_expr.else_expr) { child = get_innermost_expr_at(e->value.if_expr.else_expr, line_1, col_1); if (child) return child; }
            break;
        case AST_EXPR_BLOCK:
            break;
        case AST_EXPR_ASSIGN:
            if (e->value.binop.left) { child = get_innermost_expr_at(e->value.binop.left, line_1, col_1); if (child) return child; }
            if (e->value.binop.right) { child = get_innermost_expr_at(e->value.binop.right, line_1, col_1); if (child) return child; }
            break;
        case AST_EXPR_MATCH:
            if (e->value.match_expr.matched_expr) { child = get_innermost_expr_at(e->value.match_expr.matched_expr, line_1, col_1); if (child) return child; }
            for (int i = 0; i < e->value.match_expr.num_arms; i++)
                if (e->value.match_expr.arms[i].result) { child = get_innermost_expr_at(e->value.match_expr.arms[i].result, line_1, col_1); if (child) return child; }
            break;
        case AST_EXPR_FIELD_ACCESS:
            if (e->value.field_access.base) return get_innermost_expr_at(e->value.field_access.base, line_1, col_1);
            break;
        case AST_EXPR_STRUCT_LIT:
            for (int i = 0; i < e->value.struct_lit.num_fields; i++)
                if (e->value.struct_lit.inits[i]) { child = get_innermost_expr_at(e->value.struct_lit.inits[i], line_1, col_1); if (child) return child; }
            break;
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++)
                if (e->value.array_lit.elems[i]) { child = get_innermost_expr_at(e->value.array_lit.elems[i], line_1, col_1); if (child) return child; }
            break;
        case AST_EXPR_INDEX:
            if (e->value.index.base) { child = get_innermost_expr_at(e->value.index.base, line_1, col_1); if (child) return child; }
            if (e->value.index.index_expr) { child = get_innermost_expr_at(e->value.index.index_expr, line_1, col_1); if (child) return child; }
            break;
        case AST_EXPR_AS:
            if (e->value.as_type.operand) return get_innermost_expr_at(e->value.as_type.operand, line_1, col_1);
            break;
        default:
            break;
    }
    if (expr_at(e, line_1, col_1)) return e;
    return NULL;
}

static struct ASTExpr *get_expr_at_in_block(const struct ASTBlock *b, int line_1, int col_1) {
    if (!b) return NULL;
    int i;
    struct ASTExpr *e;
    for (i = 0; i < b->num_consts; i++)
        if (b->const_decls[i].init && (e = get_innermost_expr_at(b->const_decls[i].init, line_1, col_1))) return e;
    for (i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].init && (e = get_innermost_expr_at(b->let_decls[i].init, line_1, col_1))) return e;
    for (i = 0; i < b->num_loops; i++) {
        if (b->loops[i].cond && (e = get_innermost_expr_at(b->loops[i].cond, line_1, col_1))) return e;
        if (b->loops[i].body && (e = get_expr_at_in_block(b->loops[i].body, line_1, col_1))) return e;
    }
    for (i = 0; i < b->num_for_loops; i++) {
        struct ASTForLoop *fl = &b->for_loops[i];
        if (fl->init && (e = get_innermost_expr_at(fl->init, line_1, col_1))) return e;
        if (fl->cond && (e = get_innermost_expr_at(fl->cond, line_1, col_1))) return e;
        if (fl->step && (e = get_innermost_expr_at(fl->step, line_1, col_1))) return e;
        if (fl->body && (e = get_expr_at_in_block(fl->body, line_1, col_1))) return e;
    }
    for (i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr &&
            (e = get_innermost_expr_at(b->labeled_stmts[i].u.return_expr, line_1, col_1))) return e;
    for (i = 0; i < b->num_expr_stmts; i++)
        if (b->expr_stmts[i] && (e = get_innermost_expr_at(b->expr_stmts[i], line_1, col_1))) return e;
    if (b->final_expr && (e = get_innermost_expr_at(b->final_expr, line_1, col_1))) return e;
    return NULL;
}

/** 按位置取表达式；先按行索引只搜包含该行的函数，再搜顶层 let/const 的 init。 */
static struct ASTExpr *get_expr_at_in_module(const struct ASTModule *mod, int line_1, int col_1) {
    if (!mod) return NULL;
    struct ASTFunc *containing = get_function_at_line(mod, line_1);
    if (containing && containing->body) {
        struct ASTExpr *e = get_expr_at_in_block(containing->body, line_1, col_1);
        if (e) return e;
    }
    for (int i = 0; i < mod->num_top_level_lets; i++)
        if (mod->top_level_lets[i].init) {
            struct ASTExpr *e = get_innermost_expr_at(mod->top_level_lets[i].init, line_1, col_1);
            if (e) return e;
        }
    return NULL;
}

/** 将 ASTType 格式化为字符串写入 buf，返回长度；cap 为 buf 容量。 */
static int type_to_string(const struct ASTType *ty, char *buf, int cap) {
    if (!ty || !buf || cap <= 0) return 0;
    switch (ty->kind) {
        case AST_TYPE_I32: return snprintf(buf, (size_t)cap, "i32");
        case AST_TYPE_BOOL: return snprintf(buf, (size_t)cap, "bool");
        case AST_TYPE_U8: return snprintf(buf, (size_t)cap, "u8");
        case AST_TYPE_U32: return snprintf(buf, (size_t)cap, "u32");
        case AST_TYPE_U64: return snprintf(buf, (size_t)cap, "u64");
        case AST_TYPE_I64: return snprintf(buf, (size_t)cap, "i64");
        case AST_TYPE_USIZE: return snprintf(buf, (size_t)cap, "usize");
        case AST_TYPE_ISIZE: return snprintf(buf, (size_t)cap, "isize");
        case AST_TYPE_F32: return snprintf(buf, (size_t)cap, "f32");
        case AST_TYPE_F64: return snprintf(buf, (size_t)cap, "f64");
        case AST_TYPE_VOID: return snprintf(buf, (size_t)cap, "void");
        case AST_TYPE_NAMED: return snprintf(buf, (size_t)cap, "%s", ty->name ? ty->name : "?");
        case AST_TYPE_PTR: {
            char inner[64];
            int n = ty->elem_type ? type_to_string(ty->elem_type, inner, (int)sizeof(inner)) : 0;
            if (n <= 0) return snprintf(buf, (size_t)cap, "*?");
            return snprintf(buf, (size_t)cap, "*%s", inner);
        }
        case AST_TYPE_ARRAY: {
            char inner[64];
            int n = ty->elem_type ? type_to_string(ty->elem_type, inner, (int)sizeof(inner)) : 0;
            if (n <= 0) return snprintf(buf, (size_t)cap, "[%d]?", ty->array_size);
            return snprintf(buf, (size_t)cap, "[%d]%s", ty->array_size, inner);
        }
        case AST_TYPE_SLICE: {
            char inner[64];
            int n = ty->elem_type ? type_to_string(ty->elem_type, inner, (int)sizeof(inner)) : 0;
            if (n <= 0) return snprintf(buf, (size_t)cap, "[]?");
            return snprintf(buf, (size_t)cap, "[]%s", inner);
        }
        case AST_TYPE_VECTOR: {
            char inner[64];
            int n = ty->elem_type ? type_to_string(ty->elem_type, inner, (int)sizeof(inner)) : 0;
            if (n <= 0) return snprintf(buf, (size_t)cap, "?x%d", ty->array_size);
            return snprintf(buf, (size_t)cap, "%sx%d", inner, ty->array_size);
        }
        default: return snprintf(buf, (size_t)cap, "?");
    }
}

/**
 * 将诊断列表写成 LSP Diagnostic[] JSON 写入 out，返回长度；out_cap 为 out 的容量。
 * 供 lsp_diag.c 缓存路径与 lsp_diag.su（-E 生成）共用。
 */
int lsp_diag_format_diagnostics_json(char *out, int out_cap) {
    int k = 0;
    if (!out || out_cap <= 0) return 0;
    if (out_cap < 3) return 0;
    out[k++] = '[';
    for (int i = 0; i < s_diag_count && k < out_cap - 2; i++) {
        LspDiagEntry *e = &s_diag[i];
        int line0 = e->line > 0 ? e->line - 1 : 0;
        int col0 = e->col > 0 ? e->col - 1 : 0;
        char esc_buf[LSP_MSG_MAX * 2 + 16];
        json_escape_str(e->msg, esc_buf, (int)sizeof(esc_buf));
        int n = snprintf(out + k, (size_t)(out_cap - k),
            "%s{\"range\":{\"start\":{\"line\":%d,\"character\":%d},\"end\":{\"line\":%d,\"character\":%d}},\"message\":\"%s\",\"severity\":%d}",
            i > 0 ? "," : "", line0, col0, line0, col0 + 1, esc_buf, e->severity);
        if (n <= 0 || n >= out_cap - k) break;
        k += n;
    }
    if (k < out_cap) out[k++] = ']';
    out[k] = '\0';
    return k;
}

/* hover / references 由 .su pipeline 提供（arena 全量扫描，不依赖 C parser 缓存）。 */
extern int32_t lsp_diag_hover_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                  uint8_t *out_buf, int32_t out_cap);
extern int32_t lsp_diag_references_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                       int32_t *out_lines, int32_t *out_cols, int32_t max_refs);
extern int32_t lsp_diag_definition_at(uint8_t *source, int32_t source_len, int32_t line_0, int32_t col_0,
                                       int32_t *out_line, int32_t *out_col);

/**
 * 在 (line_0, col_0)（LSP 0-based）处查找"定义"；C 前端路径（shu-c）。bootstrap driver 由 lsp_diag_su_alias.c 强符号覆盖为 .su pipeline。
 */
__attribute__((weak)) int lsp_definition_at(const uint8_t *source, int source_len, int line_0, int col_0, int *out_line, int *out_col) {
    if (!source || !out_line || !out_col || source_len < 0) return 0;
    s_def_target_func = NULL;
    ASTModule *mod = lsp_ensure_module(source, source_len, line_0 + 1);
    if (!mod) return 0;
    int line_1 = line_0 + 1;
    int col_1 = col_0 + 1;
    return find_def_in_module(mod, line_1, col_1, out_line, out_col);
}

#define LSP_REFs_MAX 128

/**
 * 在 (line_0, col_0) 处确定目标函数并收集引用位置；C 前端路径（shu-c）。bootstrap driver 由 lsp_diag_su_alias.c 强符号覆盖为 .su pipeline。
 */
__attribute__((weak)) int lsp_references_at(const uint8_t *source, int source_len, int line_0, int col_0,
                      int *out_lines, int *out_cols, int max_refs) {
    if (!source || !out_lines || !out_cols || source_len < 0 || max_refs <= 0) return 0;
    ASTModule *mod = lsp_ensure_module(source, source_len, -1);
    if (!mod) return 0;
    int line_1 = line_0 + 1;
    int col_1 = col_0 + 1;
    struct ASTFunc *target = find_target_function_at(mod, line_1, col_1);
    if (!target) return 0;
    int j = line_index_of_func(target);
    if (j >= 0 && s_refs_count[j] > 0) {
        int n = s_refs_count[j];
        if (n > max_refs) n = max_refs;
        for (int i = 0; i < n; i++) {
            out_lines[i] = s_refs_lines[j][i];
            out_cols[i] = s_refs_cols[j][i];
        }
        return n;
    }
    return collect_refs_to_func(mod, target, out_lines, out_cols, max_refs);
}

#define LSP_HOVER_BUF_MAX 128

/**
 * 在 (line_0, col_0) 处找表达式类型；C 前端路径（shu-c）。bootstrap driver 由 lsp_diag_su_alias.c 强符号覆盖为 .su pipeline。
 */
__attribute__((weak)) int lsp_hover_at(const uint8_t *source, int source_len, int line_0, int col_0, char *out_buf, int out_cap) {
    if (!source || !out_buf || out_cap <= 0 || source_len < 0) return 0;
    ASTModule *mod = lsp_ensure_module(source, source_len, line_0 + 1);
    if (!mod) return 0;
    int line_1 = line_0 + 1;
    int col_1 = col_0 + 1;
    struct ASTExpr *e = get_expr_at_in_module(mod, line_1, col_1);
    int len = 0;
    if (e && e->resolved_type) len = type_to_string(e->resolved_type, out_buf, out_cap);
    return len > 0 ? len : 0;
}

/* ---------- 原 lsp_io.c：文档缓冲、contentChanges、JSON 响应构建（lsp_extract_document_text 在 lsp_io.su） ---------- */
#define LSP_BODY_SAFETY_CAP (64 * 1024 * 1024)

static int lsp_find_text_value(const uint8_t *body, int len, uint8_t *out_buf, int out_cap);
static int lsp_find_key_after(const uint8_t *body, int len, int start, const char *key);
static int lsp_parse_int(const uint8_t *body, int len, int offset, int *out);
static int line_char_to_offset(const uint8_t *doc, int len, int line, int character);
static int parse_first_content_change(const uint8_t *body, int len,
    int *out_start_line, int *out_start_char, int *out_end_line, int *out_end_char,
    uint8_t *out_text, int out_text_cap, int *out_text_len);

static uint8_t *s_doc_ptr = NULL;
static int s_doc_len = 0;

/** lsp_alloc/lsp_free/lsp_is_null、read_message、extract_document_text 已迁至 lsp_io.su；不再提供 lsp_peek_u8/lsp_poke_u8/lsp_ptr_add。 */

/** 若 body 含 contentChanges 且当前有文档，则解析并应用第一项 range 替换，成功返回 1，否则 0。 */
static int try_apply_content_changes(const uint8_t *body, int body_len) {
    if (!s_doc_ptr || s_doc_len < 0) return 0;
    uint8_t text_buf[256 * 1024];
    int text_len = 0;
    int start_line = 0, start_char = 0, end_line = 0, end_char = 0;
    if (!parse_first_content_change(body, body_len, &start_line, &start_char, &end_line, &end_char,
                                    text_buf, (int)sizeof(text_buf), &text_len))
        return 0;
    int start_off = line_char_to_offset(s_doc_ptr, s_doc_len, start_line, start_char);
    int end_off = line_char_to_offset(s_doc_ptr, s_doc_len, end_line, end_char);
    if (start_off < 0 || end_off < 0 || end_off < start_off) return 0;
    size_t new_len = (size_t)start_off + (size_t)text_len + (size_t)(s_doc_len - end_off);
    if (new_len > (size_t)LSP_BODY_SAFETY_CAP) return 0;
    uint8_t *new_ptr = (uint8_t *)malloc(new_len + 1);
    if (!new_ptr) return 0;
    memcpy(new_ptr, s_doc_ptr, (size_t)start_off);
    memcpy(new_ptr + start_off, text_buf, (size_t)text_len);
    memcpy(new_ptr + start_off + text_len, s_doc_ptr + end_off, (size_t)(s_doc_len - end_off));
    new_ptr[new_len] = '\0';
    free(s_doc_ptr);
    s_doc_ptr = new_ptr;
    s_doc_len = (int)new_len;
    return 1;
}

/** 从 didOpen/didChange 的 body 中提取文档内容，存入内部缓冲（替换旧文档）。若有 contentChanges 且当前有文档则做增量 range 替换，否则整份替换。先使 LSP 模块缓存失效，再释放旧缓冲，避免旧 AST 指向已释放内存。 */
void lsp_set_document_from_body(const uint8_t *body, int body_len) {
    if (!body || body_len <= 0) return;
    /* didOpen/didChange 携带 textDocument.uri 时更新 entry 路径，供 import 解析与跨文件跳转。 */
    {
        uint8_t uri_buf[512];
        int uri_len = lsp_extract_uri_from_params(body, body_len, uri_buf, (int)sizeof(uri_buf));
        if (uri_len > 0) {
            uri_buf[uri_len] = '\0';
            (void)snprintf(s_doc_uri, sizeof(s_doc_uri), "%s", (const char *)uri_buf);
            char fs_path[512];
            lsp_uri_to_fs_path((const char *)uri_buf, fs_path, sizeof(fs_path));
            lsp_update_entry_dir(fs_path);
        }
    }
    if (s_doc_ptr && try_apply_content_changes(body, body_len)) {
        lsp_diag_invalidate_cache();
        return;
    }
    lsp_diag_invalidate_cache();
    if (s_doc_ptr) { free(s_doc_ptr); s_doc_ptr = NULL; s_doc_len = 0; }
    s_doc_ptr = (uint8_t *)malloc((size_t)body_len + 1);
    if (!s_doc_ptr) return;
    int n = lsp_find_text_value(body, body_len, s_doc_ptr, body_len + 1);
    if (n >= 0) {
        s_doc_ptr[n] = '\0';
        s_doc_len = n;
    } else {
        free(s_doc_ptr);
        s_doc_ptr = NULL;
        s_doc_len = 0;
    }
}

uint8_t *lsp_get_document_ptr(void) {
    return s_doc_ptr;
}

int lsp_get_document_len(void) {
    return s_doc_len;
}

/** lsp_read_c、lsp_read_at、lsp_read_message、lsp_write_c 已迁至 lsp_io.su（std.io）。 */

/** 将 (line, character) 转为文档中的字节偏移；line/character 为 0-based。 */
static int line_char_to_offset(const uint8_t *doc, int len, int line, int character) {
    int cur_line = 0;
    int i = 0;
    while (i < len && cur_line < line) {
        if (doc[i] == '\n') cur_line++;
        i++;
    }
    if (cur_line != line) return -1;
    int col = 0;
    while (col < character && i < len && doc[i] != '\n') {
        col++;
        i++;
    }
    if (col != character) return -1;
    return i;
}

/** 从 body 中解析 contentChanges[0]：range.start.line/character、range.end.line/character、text；成功返回 1 并写入 *out_*，否则 0。 */
static int parse_first_content_change(const uint8_t *body, int len,
    int *out_start_line, int *out_start_char, int *out_end_line, int *out_end_char,
    uint8_t *out_text, int out_text_cap, int *out_text_len) {
    const char *key_cc = "\"contentChanges\":[";
    int key_cc_len = 16;
    int i = 0;
    for (; i + key_cc_len <= len; i++)
        if (memcmp(body + i, key_cc, (size_t)key_cc_len) == 0) break;
    if (i + key_cc_len > len) return 0;
    i += key_cc_len;
    while (i < len && (body[i] == ' ' || body[i] == '\n' || body[i] == '\r')) i++;
    if (i >= len || body[i] != '{') return 0;
    int pos = i + 1;
    int line_start = lsp_find_key_after(body, len, pos, "\"range\":");
    if (line_start < 0) return 0;
    int start_line_start = lsp_find_key_after(body, len, line_start, "\"start\":");
    if (start_line_start < 0) return 0;
    int sl = lsp_find_key_after(body, len, start_line_start, "\"line\":");
    if (sl < 0) return 0;
    int sc = lsp_find_key_after(body, len, start_line_start, "\"character\":");
    if (sc < 0) return 0;
    int el = lsp_find_key_after(body, len, line_start, "\"end\":");
    if (el < 0) return 0;
    int elv = lsp_find_key_after(body, len, el, "\"line\":");
    if (elv < 0) return 0;
    int ec = lsp_find_key_after(body, len, el, "\"character\":");
    if (ec < 0) return 0;
    int tl = lsp_find_key_after(body, len, pos, "\"text\":\"");
    if (tl < 0) return 0;
    int line1 = 0, char1 = 0, line2 = 0, char2 = 0;
    if (lsp_parse_int(body, len, sl, &line1) < 0) return 0;
    if (lsp_parse_int(body, len, sc, &char1) < 0) return 0;
    if (lsp_parse_int(body, len, elv, &line2) < 0) return 0;
    if (lsp_parse_int(body, len, ec, &char2) < 0) return 0;
    int text_len = 0;
    while (tl < len && text_len < out_text_cap - 1) {
        uint8_t c = body[tl];
        if (c == '"' && (tl == 0 || body[tl - 1] != '\\')) break;
        if (c == '\\' && tl + 1 < len) {
            tl++;
            if (body[tl] == 'n') { out_text[text_len++] = '\n'; tl++; continue; }
            if (body[tl] == 'r') { out_text[text_len++] = '\r'; tl++; continue; }
            if (body[tl] == 't') { out_text[text_len++] = '\t'; tl++; continue; }
            if (body[tl] == '"' || body[tl] == '\\') { out_text[text_len++] = body[tl]; tl++; continue; }
            out_text[text_len++] = body[tl];
            tl++;
            continue;
        }
        out_text[text_len++] = c;
        tl++;
    }
    out_text[text_len] = '\0';
    *out_start_line = line1;
    *out_start_char = char1;
    *out_end_line = line2;
    *out_end_char = char2;
    *out_text_len = text_len;
    return 1;
}

/** 在 body[search_start..len) 中找 "text" 键（支持 "text":"、"text": "、"text" : " 等），取 JSON 字符串值到 out_buf，做 unescape；返回 out 长度，未找到或出错 -1。 */
static int lsp_find_text_value_from(const uint8_t *body, int len, int search_start, uint8_t *out_buf, int out_cap) {
    const int key6_len = 6;  /* "\"text\"" */
    int i = search_start;
    while (i + key6_len <= len) {
        if (body[i] != (uint8_t)'"' || body[i+1] != (uint8_t)'t' || body[i+2] != (uint8_t)'e' ||
            body[i+3] != (uint8_t)'x' || body[i+4] != (uint8_t)'t' || body[i+5] != (uint8_t)'"')
            { i++; continue; }
        int s = i + key6_len;
        while (s < len && (body[s] == ' ' || body[s] == '\t' || body[s] == '\n' || body[s] == '\r')) s++;
        if (s >= len || body[s] != ':') { i++; continue; }
        s++;
        while (s < len && (body[s] == ' ' || body[s] == '\t' || body[s] == '\n' || body[s] == '\r')) s++;
        if (s >= len || body[s] != '"') { i++; continue; }
        int value_start = s + 1;
        int start = value_start;
        int out_len = 0;
        while (start < len && out_len < out_cap - 1) {
            uint8_t c = body[start];
            if (c == '"' && (start == 0 || body[start-1] != '\\'))
                break;
            if (c == '\\' && start + 1 < len) {
                start++;
                if (body[start] == 'n') { out_buf[out_len++] = '\n'; start++; continue; }
                if (body[start] == 'r') { out_buf[out_len++] = '\r'; start++; continue; }
                if (body[start] == 't') { out_buf[out_len++] = '\t'; start++; continue; }
                if (body[start] == '"' || body[start] == '\\') { out_buf[out_len++] = body[start]; start++; continue; }
                out_buf[out_len++] = body[start];
                start++;
                continue;
            }
            out_buf[out_len++] = c;
            start++;
        }
        out_buf[out_len] = '\0';
        return (int)out_len;
    }
    return -1;
}

/** 在 body[0..len) 中找 didOpen 的 text：先定位到 "textDocument" 对象内再找 "text" 键，取 JSON 字符串值到 out_buf；返回 out 长度，未找到 -1。 */
static int lsp_find_text_value(const uint8_t *body, int len, uint8_t *out_buf, int out_cap) {
    const char *td = "\"textDocument\"";
    const int td_len = 14;
    int i = 0;
    for (; i + td_len <= len; i++) {
        if (memcmp(body + i, td, (size_t)td_len) != 0) continue;
        /* 在 "textDocument" 之后查找 "text" 键，避免误匹配 method 等处的 text */
        int n = lsp_find_text_value_from(body, len, i + td_len, out_buf, out_cap);
        if (n >= 0) return n;
    }
    /* 未找到 textDocument 时回退：整段 body 中找第一个 "text" 键（兼容旧或简化的请求） */
    return lsp_find_text_value_from(body, len, 0, out_buf, out_cap);
}

/**
 * 构建 InitializeResult JSON，含 capabilities（同步、定义、引用、悬停、格式化、补全、文档符号、签名帮助）与 serverInfo。
 * 写入 out_buf，返回写入长度，失败返回 -1。
 */
int lsp_build_initialize_result(uint8_t *out_buf, int out_cap) {
    const char *json = "{\"jsonrpc\":\"2.0\",\"id\":1,\"result\":{"
        "\"capabilities\":{"
        "\"textDocumentSync\":1,"
        "\"definitionProvider\":true,"
        "\"referencesProvider\":true,"
        "\"hoverProvider\":true,"
        "\"documentFormattingProvider\":true,"
        "\"completionProvider\":{\"triggerCharacters\":[\".\",\":\",\"(\"]},"
        "\"documentSymbolProvider\":true,"
        "\"semanticTokensProvider\":{\"legend\":{\"tokenTypes\":[\"namespace\",\"type\",\"class\",\"enum\",\"interface\",\"struct\",\"typeParameter\",\"parameter\",\"variable\",\"property\",\"enumMember\",\"event\",\"function\",\"method\",\"macro\",\"keyword\",\"modifier\",\"comment\",\"string\",\"number\",\"regexp\",\"operator\"],\"tokenModifiers\":[\"declaration\",\"definition\",\"readonly\",\"static\",\"deprecated\",\"abstract\",\"async\",\"modification\",\"documentation\",\"defaultLibrary\"]},\"full\":true,\"range\":false},"
        "\"signatureHelpProvider\":{\"triggerCharacters\":[\"(\",\",\"]},\""
        "\"renameProvider\":true,"
        "\"diagnosticProvider\":{\"identifier\":\"shulang\",\"interFileDependencies\":false,\"workspaceDiagnostics\":false}"
        "},"
        "\"serverInfo\":{\"name\":\"shulang\",\"version\":\"0.1.0\"}"
        "}}";
    int len = 0;
    while (json[len] != '\0') len++;
    if (len >= out_cap) return -1;
    for (int i = 0; i < len; i++) out_buf[i] = (uint8_t)json[i];
    return len;
}

/**
 * 构建 JSON-RPC 响应正文：{"jsonrpc":"2.0","id":<id>,"result":<result>}。
 * 供 lsp.su 与 lsp_io.c 内 build_definition/references/hover/formatting 共用。
 */
int lsp_build_response_with_result(int id_val, const uint8_t *result_ptr, int result_len,
                                   uint8_t *out_buf, int out_cap) {
    const char *prefix = "{\"jsonrpc\":\"2.0\",\"id\":";
    const char *mid = ",\"result\":";
    const char *suffix = "}";
    int i = 0, k = 0;
    if (!out_buf || out_cap <= 0) return -1;
    for (; prefix[i] && k < out_cap - 1; i++, k++) out_buf[k] = (uint8_t)prefix[i];
    if (k >= out_cap - 12) return -1;
    char id_buf[16];
    int id_len = 0;
    int n = id_val;
    if (n < 0) n = -n;
    if (n == 0) {
        id_buf[id_len++] = '0';
    } else {
        while (n > 0 && id_len < 15) { id_buf[id_len++] = (char)('0' + n % 10); n /= 10; }
    }
    int j = id_len - 1;
    while (j >= 0 && k < out_cap - 1) { out_buf[k++] = (uint8_t)id_buf[j--]; }
    for (i = 0; mid[i] && k < out_cap - 1; i++, k++) out_buf[k] = (uint8_t)mid[i];
    for (i = 0; i < result_len && k < out_cap - 1; i++, k++) out_buf[k] = result_ptr[i];
    for (i = 0; suffix[i] && k < out_cap - 1; i++, k++) out_buf[k] = (uint8_t)suffix[i];
    return k;
}

/** 在 body[0..len) 中从 start 起找 key（如 "\"line\":\"），返回 key 结束后的偏移，未找到返回 -1。 */
static int lsp_find_key_after(const uint8_t *body, int len, int start, const char *key) {
    int key_len = 0;
    while (key[key_len] != '\0') key_len++;
    while (start + key_len <= len) {
        int match = 1;
        for (int j = 0; j < key_len; j++)
            if (body[start + j] != (uint8_t)key[j]) { match = 0; break; }
        if (match) return start + key_len;
        start++;
    }
    return -1;
}

/** 从 offset 起解析一个非负整数，写入 *out，返回解析结束后的偏移；非法返回 -1。 */
static int lsp_parse_int(const uint8_t *body, int len, int offset, int *out) {
    if (offset >= len || !out) return -1;
    *out = 0;
    while (offset < len && body[offset] >= '0' && body[offset] <= '9') {
        *out = *out * 10 + (body[offset] - '0');
        offset++;
    }
    return offset;
}

/**
 * 从 definition/hover 等请求的 body 中提取 params.position：line 与 character（0-based）。
 * 写入 *out_line、*out_character，成功返回 0，失败返回 -1。
 */
int lsp_extract_position_from_params(const uint8_t *body, int len, int *out_line, int *out_character) {
    if (!body || len <= 0 || !out_line || !out_character) return -1;
    int pos = lsp_find_key_after(body, len, 0, "\"position\":");
    if (pos < 0) return -1;
    int line_start = lsp_find_key_after(body, len, pos, "\"line\":");
    if (line_start < 0) return -1;
    int char_start = lsp_find_key_after(body, len, pos, "\"character\":");
    if (char_start < 0) return -1;
    int line_end = lsp_parse_int(body, len, line_start, out_line);
    if (line_end < 0) return -1;
    int char_end = lsp_parse_int(body, len, char_start, out_character);
    if (char_end < 0) return -1;
    return 0;
}

/**
 * 从 definition/hover 等请求的 body 中提取 params.textDocument.uri（JSON 字符串）。
 * 写入 uri_buf，做简单 unescape；返回写入长度，失败返回 -1。
 */
int lsp_extract_uri_from_params(const uint8_t *body, int len, uint8_t *uri_buf, int uri_cap) {
    if (!body || !uri_buf || uri_cap <= 0) return -1;
    int start = lsp_find_key_after(body, len, 0, "\"uri\":\"");
    if (start < 0) return -1;
    int out_len = 0;
    while (start < len && out_len < uri_cap - 1) {
        uint8_t c = body[start];
        if (c == '"' && (start == 0 || body[start - 1] != '\\')) break;
        if (c == '\\' && start + 1 < len) {
            start++;
            if (body[start] == '"' || body[start] == '\\') { uri_buf[out_len++] = body[start]; start++; continue; }
        }
        uri_buf[out_len++] = c;
        start++;
    }
    uri_buf[out_len] = '\0';
    return out_len;
}

#define LSP_DEFINITION_RESULT_MAX 2048

/**
 * 构建 textDocument/definition 的完整 JSON-RPC 响应正文。
 * 从 body 解析 position 与 uri，用 doc_buf/doc_len 跑 lsp_definition_at；找到则 result 为 Location，否则为 null。
 * 写入 out_buf，返回长度，失败返回 -1。
 */
int lsp_build_definition_response(int id_val, const uint8_t *body, int body_len,
                                  const uint8_t *doc_buf, int doc_len,
                                  uint8_t *out_buf, int out_cap) {
    if (!body || !out_buf || out_cap <= 0) return -1;
    int line0 = 0, char0 = 0;
    if (lsp_extract_position_from_params(body, body_len, &line0, &char0) != 0)
        return lsp_build_response_with_result(id_val, (const uint8_t *)"null", 4, out_buf, out_cap);
    int def_line = 0, def_col = 0;
    if (!lsp_definition_at(doc_buf, doc_len, line0, char0, &def_line, &def_col))
        return lsp_build_response_with_result(id_val, (const uint8_t *)"null", 4, out_buf, out_cap);
    uint8_t uri_buf[512];
    int uri_len = lsp_extract_uri_from_params(body, body_len, uri_buf, (int)sizeof(uri_buf));
    if (uri_len < 0) uri_len = 0;
    uri_buf[uri_len] = '\0';
    const char *def_uri = (const char *)uri_buf;
    char def_uri_buf[512];
    if (s_def_target_func && s_cached_mod) {
        const char *fs = lsp_fs_path_for_func(s_def_target_func, s_cached_mod);
        if (fs && fs[0]) {
            lsp_fs_path_to_uri(fs, def_uri_buf, sizeof(def_uri_buf));
            def_uri = def_uri_buf;
            uri_len = (int)strlen(def_uri);
        }
    }
    /* LSP Location: {"uri":"...","range":{...}}；行列 0-based。跨 import 模块时使用目标 .su 的 file URI。 */
    int line0_def = def_line > 0 ? def_line - 1 : 0;
    int col0_def = def_col > 0 ? def_col - 1 : 0;
    char result_buf[LSP_DEFINITION_RESULT_MAX];
    int r = snprintf(result_buf, sizeof(result_buf),
        "{\"uri\":\"%.*s\",\"range\":{\"start\":{\"line\":%d,\"character\":%d},\"end\":{\"line\":%d,\"character\":%d}}}",
        uri_len, def_uri, line0_def, col0_def, line0_def, col0_def + 1);
    if (r <= 0 || r >= (int)sizeof(result_buf)) return lsp_build_response_with_result(id_val, (const uint8_t *)"null", 4, out_buf, out_cap);
    return lsp_build_response_with_result(id_val, (const uint8_t *)result_buf, r, out_buf, out_cap);
}

#define LSP_REFS_MAX 128
#define LSP_REFERENCES_RESULT_MAX 8192

/**
 * 构建 textDocument/references 的完整 JSON-RPC 响应正文。
 * 从 body 解析 position 与 uri，用 doc_buf 跑 lsp_references_at，result 为 Location[]。
 */
int lsp_build_references_response(int id_val, const uint8_t *body, int body_len,
                                  const uint8_t *doc_buf, int doc_len,
                                  uint8_t *out_buf, int out_cap) {
    if (!body || !out_buf || out_cap <= 0) return -1;
    int line0 = 0, char0 = 0;
    if (lsp_extract_position_from_params(body, body_len, &line0, &char0) != 0)
        return lsp_build_response_with_result(id_val, (const uint8_t *)"[]", 2, out_buf, out_cap);
    int ref_lines[LSP_REFS_MAX];
    int ref_cols[LSP_REFS_MAX];
    int n = lsp_references_at(doc_buf, doc_len, line0, char0, ref_lines, ref_cols, LSP_REFS_MAX);
    uint8_t uri_buf[512];
    int uri_len = lsp_extract_uri_from_params(body, body_len, uri_buf, (int)sizeof(uri_buf));
    if (uri_len < 0) uri_len = 0;
    uri_buf[uri_len] = '\0';
    char result_buf[LSP_REFERENCES_RESULT_MAX];
    int k = 0;
    k += snprintf(result_buf + k, sizeof(result_buf) - k, "[");
    for (int i = 0; i < n && k < (int)sizeof(result_buf) - 80; i++) {
        int l0 = ref_lines[i] > 0 ? ref_lines[i] - 1 : 0;
        int c0 = ref_cols[i] > 0 ? ref_cols[i] - 1 : 0;
        if (i > 0) result_buf[k++] = ',';
        k += snprintf(result_buf + k, sizeof(result_buf) - k,
            "{\"uri\":\"%.*s\",\"range\":{\"start\":{\"line\":%d,\"character\":%d},\"end\":{\"line\":%d,\"character\":%d}}}",
            uri_len, (const char *)uri_buf, l0, c0, l0, c0 + 1);
    }
    k += snprintf(result_buf + k, sizeof(result_buf) - k, "]");
    return lsp_build_response_with_result(id_val, (const uint8_t *)result_buf, k, out_buf, out_cap);
}

#define LSP_HOVER_VALUE_MAX 256
#define LSP_HOVER_RESULT_MAX 512

/**
 * 构建 textDocument/hover 的完整 JSON-RPC 响应正文。
 * 从 body 解析 position，用 doc_buf 跑 lsp_hover_at 取类型字符串，result 为 {"contents":{"kind":"markdown","value":"..."}} 或 null。
 */
int lsp_build_hover_response(int id_val, const uint8_t *body, int body_len,
                              const uint8_t *doc_buf, int doc_len,
                              uint8_t *out_buf, int out_cap) {
    if (!body || !out_buf || out_cap <= 0) return -1;
    int line0 = 0, char0 = 0;
    if (lsp_extract_position_from_params(body, body_len, &line0, &char0) != 0)
        return lsp_build_response_with_result(id_val, (const uint8_t *)"null", 4, out_buf, out_cap);
    char type_buf[LSP_HOVER_VALUE_MAX];
    int type_len = lsp_hover_at(doc_buf, doc_len, line0, char0, type_buf, (int)sizeof(type_buf));
    if (type_len <= 0)
        return lsp_build_response_with_result(id_val, (const uint8_t *)"null", 4, out_buf, out_cap);
    /* 对 value 做 JSON 转义（仅 " 与 \） */
    char esc[LSP_HOVER_VALUE_MAX * 2 + 16];
    int e = 0;
    for (int i = 0; type_buf[i] != '\0' && e < (int)sizeof(esc) - 4; i++) {
        if (type_buf[i] == '"' || type_buf[i] == '\\') esc[e++] = '\\';
        esc[e++] = type_buf[i];
    }
    esc[e] = '\0';
    char result_buf[LSP_HOVER_RESULT_MAX];
    int r = snprintf(result_buf, sizeof(result_buf),
        "{\"contents\":{\"kind\":\"markdown\",\"value\":\"%s\"}}", esc);
    if (r <= 0 || r >= (int)sizeof(result_buf))
        return lsp_build_response_with_result(id_val, (const uint8_t *)"null", 4, out_buf, out_cap);
    return lsp_build_response_with_result(id_val, (const uint8_t *)result_buf, r, out_buf, out_cap);
}

/** completion / documentSymbol 共用：与格式化响应同量级缓冲上限。 */
#define LSP_SEMANTIC_RESULT_MAX 262144

/**
 * 将标识符写入 esc，转义 JSON 中的 " 与 \\；返回写入长度（esc 以 NUL 结尾）。
 */
static int lsp_json_escape_ident(const char *s, char *esc, int esc_cap) {
    int e = 0;
    if (!s || !esc || esc_cap < 4)
        return 0;
    for (int i = 0; s[i] != '\0' && e < esc_cap - 3; i++) {
        if (s[i] == '"' || s[i] == '\\') {
            esc[e++] = '\\';
            if (e >= esc_cap - 1)
                break;
        }
        esc[e++] = s[i];
    }
    esc[e] = '\0';
    return e;
}

/**
 * 构建 textDocument/completion：解析 position，确保模块缓存后收集顶层符号、import、struct/enum、关键字与内建类型，result 为 CompletionItem[]。
 */
int lsp_build_completion_response(int id_val, const uint8_t *body, int body_len,
                                  const uint8_t *doc_buf, int doc_len,
                                  uint8_t *out_buf, int out_cap) {
    if (!out_buf || out_cap <= 0)
        return -1;
    int line0 = 0, char0 = 0;
    if (lsp_extract_position_from_params(body, body_len, &line0, &char0) != 0) {
        line0 = 0;
        char0 = 0;
    }
    struct ASTModule *mod = lsp_ensure_module(doc_buf, doc_len, line0 + 1);
    if (!mod)
        return lsp_build_response_with_result(id_val, (const uint8_t *)"[]", 2, out_buf, out_cap);

    static const char *const KW[] = {
        "function", "let", "const", "struct", "enum", "trait", "impl", "extern", "import",
        "if", "else", "while", "for", "loop", "match", "return", "break", "continue", "defer",
        "goto", "panic", "as"
    };
    static const int n_kw = (int)(sizeof(KW) / sizeof(KW[0]));
    static const char *const TYS[] = {
        "i32", "i64", "u8", "u32", "u64", "usize", "isize", "f32", "f64", "bool", "void"
    };
    static const int n_ty = (int)(sizeof(TYS) / sizeof(TYS[0]));

    char result[LSP_SEMANTIC_RESULT_MAX];
    int k = 0;
    if (k < (int)sizeof(result))
        result[k++] = '[';
    int need_comma = 0;
    char esc[320];

    for (int i = 0; i < mod->num_funcs; i++) {
        if (!mod->funcs[i] || !mod->funcs[i]->name)
            continue;
        if (lsp_json_escape_ident(mod->funcs[i]->name, esc, (int)sizeof(esc)) <= 0)
            continue;
        int room = (int)sizeof(result) - k;
        if (room < 64)
            return -1;
        int n = snprintf(result + k, (size_t)room, "%s{\"label\":\"%s\",\"kind\":3}", need_comma ? "," : "", esc);
        if (n <= 0 || n >= room)
            return -1;
        k += n;
        need_comma = 1;
    }
    for (int i = 0; i < mod->num_imports; i++) {
        if (!mod->import_paths || !mod->import_paths[i])
            continue;
        if (lsp_json_escape_ident(mod->import_paths[i], esc, (int)sizeof(esc)) <= 0)
            continue;
        int room = (int)sizeof(result) - k;
        if (room < 64)
            return -1;
        int n = snprintf(result + k, (size_t)room, "%s{\"label\":\"%s\",\"kind\":9}", need_comma ? "," : "", esc);
        if (n <= 0 || n >= room)
            return -1;
        k += n;
        need_comma = 1;
    }
    for (int i = 0; i < mod->num_structs; i++) {
        if (!mod->struct_defs || !mod->struct_defs[i] || !mod->struct_defs[i]->name)
            continue;
        if (lsp_json_escape_ident(mod->struct_defs[i]->name, esc, (int)sizeof(esc)) <= 0)
            continue;
        int room = (int)sizeof(result) - k;
        if (room < 64)
            return -1;
        int n = snprintf(result + k, (size_t)room, "%s{\"label\":\"%s\",\"kind\":7}", need_comma ? "," : "", esc);
        if (n <= 0 || n >= room)
            return -1;
        k += n;
        need_comma = 1;
    }
    for (int i = 0; i < mod->num_enums; i++) {
        if (!mod->enum_defs || !mod->enum_defs[i] || !mod->enum_defs[i]->name)
            continue;
        if (lsp_json_escape_ident(mod->enum_defs[i]->name, esc, (int)sizeof(esc)) <= 0)
            continue;
        int room = (int)sizeof(result) - k;
        if (room < 64)
            return -1;
        int n = snprintf(result + k, (size_t)room, "%s{\"label\":\"%s\",\"kind\":13}", need_comma ? "," : "", esc);
        if (n <= 0 || n >= room)
            return -1;
        k += n;
        need_comma = 1;
    }
    for (int i = 0; i < n_kw; i++) {
        if (lsp_json_escape_ident(KW[i], esc, (int)sizeof(esc)) <= 0)
            continue;
        int room = (int)sizeof(result) - k;
        if (room < 64)
            return -1;
        int n = snprintf(result + k, (size_t)room, "%s{\"label\":\"%s\",\"kind\":14}", need_comma ? "," : "", esc);
        if (n <= 0 || n >= room)
            return -1;
        k += n;
        need_comma = 1;
    }
    for (int i = 0; i < n_ty; i++) {
        if (lsp_json_escape_ident(TYS[i], esc, (int)sizeof(esc)) <= 0)
            continue;
        int room = (int)sizeof(result) - k;
        if (room < 64)
            return -1;
        int n = snprintf(result + k, (size_t)room, "%s{\"label\":\"%s\",\"kind\":25}", need_comma ? "," : "", esc);
        if (n <= 0 || n >= room)
            return -1;
        k += n;
        need_comma = 1;
    }
    if (k + 2 > (int)sizeof(result))
        return -1;
    result[k++] = ']';
    result[k] = '\0';
    return lsp_build_response_with_result(id_val, (const uint8_t *)result, k, out_buf, out_cap);
}

/** 文档符号 JSON 片段：占位 range/selectionRange（全 0）。 */
static const char *const LSP_DOC_SYM_RANGE_TAIL =
    ",\"range\":{\"start\":{\"line\":0,\"character\":0},\"end\":{\"line\":0,\"character\":0}},"
    "\"selectionRange\":{\"start\":{\"line\":0,\"character\":0},\"end\":{\"line\":0,\"character\":0}}}";

/**
 * 构建 textDocument/documentSymbol：列出顶层函数、struct、enum；无模块时 result 为 []。
 */
int lsp_build_document_symbol_response(int id_val, const uint8_t *body, int body_len,
                                    const uint8_t *doc_buf, int doc_len,
                                    uint8_t *out_buf, int out_cap) {
    (void)body;
    (void)body_len;
    if (!out_buf || out_cap <= 0)
        return -1;
    struct ASTModule *mod = lsp_ensure_module(doc_buf, doc_len, -1);
    if (!mod)
        return lsp_build_response_with_result(id_val, (const uint8_t *)"[]", 2, out_buf, out_cap);

    char result[LSP_SEMANTIC_RESULT_MAX];
    int k = 0;
    if (k < (int)sizeof(result))
        result[k++] = '[';
    int need_comma = 0;
    char esc[320];

    for (int i = 0; i < mod->num_funcs; i++) {
        if (!mod->funcs[i] || !mod->funcs[i]->name)
            continue;
        if (lsp_json_escape_ident(mod->funcs[i]->name, esc, (int)sizeof(esc)) <= 0)
            continue;
        int room = (int)sizeof(result) - k;
        if (room < 128)
            return -1;
        int n = snprintf(result + k, (size_t)room, "%s{\"name\":\"%s\",\"kind\":12%s",
                         need_comma ? "," : "", esc, LSP_DOC_SYM_RANGE_TAIL);
        if (n <= 0 || n >= room)
            return -1;
        k += n;
        need_comma = 1;
    }
    for (int i = 0; i < mod->num_structs; i++) {
        if (!mod->struct_defs || !mod->struct_defs[i] || !mod->struct_defs[i]->name)
            continue;
        if (lsp_json_escape_ident(mod->struct_defs[i]->name, esc, (int)sizeof(esc)) <= 0)
            continue;
        int room = (int)sizeof(result) - k;
        if (room < 128)
            return -1;
        int n = snprintf(result + k, (size_t)room, "%s{\"name\":\"%s\",\"kind\":23%s",
                         need_comma ? "," : "", esc, LSP_DOC_SYM_RANGE_TAIL);
        if (n <= 0 || n >= room)
            return -1;
        k += n;
        need_comma = 1;
    }
    for (int i = 0; i < mod->num_enums; i++) {
        if (!mod->enum_defs || !mod->enum_defs[i] || !mod->enum_defs[i]->name)
            continue;
        if (lsp_json_escape_ident(mod->enum_defs[i]->name, esc, (int)sizeof(esc)) <= 0)
            continue;
        int room = (int)sizeof(result) - k;
        if (room < 128)
            return -1;
        int n = snprintf(result + k, (size_t)room, "%s{\"name\":\"%s\",\"kind\":13%s",
                         need_comma ? "," : "", esc, LSP_DOC_SYM_RANGE_TAIL);
        if (n <= 0 || n >= room)
            return -1;
        k += n;
        need_comma = 1;
    }
    if (k + 2 > (int)sizeof(result))
        return -1;
    result[k++] = ']';
    result[k] = '\0';
    return lsp_build_response_with_result(id_val, (const uint8_t *)result, k, out_buf, out_cap);
}

/* ---------- textDocument/formatting ---------- */

/** 在 body[start..] 中解析 key 对应的布尔值；1=true，0=false，未找到或无效返回 -1。 */
static int lsp_parse_bool_after(const uint8_t *body, int len, int start, const char *key, int *out_val) {
    int k = lsp_find_key_after(body, len, start, key);
    if (k < 0 || !out_val) return -1;
    if (k + 4 <= len && body[k] == 't' && body[k+1] == 'r' && body[k+2] == 'u' && body[k+3] == 'e') {
        *out_val = 1;
        return 0;
    }
    if (k + 5 <= len && body[k] == 'f' && body[k+1] == 'a' && body[k+2] == 'l' && body[k+3] == 's' && body[k+4] == 'e') {
        *out_val = 0;
        return 0;
    }
    return -1;
}

/** 从 params.options 提取格式化选项（见下方默认值）；成功返回 0。 */
static int lsp_extract_formatting_options(const uint8_t *body, int len,
    int *out_tab_size, int *out_insert_spaces, int *out_max_line_length,
    int *out_insert_final_newline, int *out_trim_trailing_whitespace, int *out_trim_final_newlines) {
    if (!body || len <= 0 || !out_tab_size || !out_insert_spaces || !out_max_line_length) return -1;
    *out_tab_size = 2;
    *out_insert_spaces = 1;
    *out_max_line_length = 100;
    *out_insert_final_newline = 1;
    *out_trim_trailing_whitespace = 1;
    *out_trim_final_newlines = 1;
    int opt = lsp_find_key_after(body, len, 0, "\"options\":");
    if (opt < 0) return 0;
    int ts = lsp_find_key_after(body, len, opt, "\"tabSize\":");
    if (ts >= 0) {
        int val = 0;
        int end = lsp_parse_int(body, len, ts, &val);
        if (end > ts && val >= 1 && val <= 16) *out_tab_size = val;
    }
    lsp_parse_bool_after(body, len, opt, "\"insertSpaces\":", out_insert_spaces);
    int ml = lsp_find_key_after(body, len, opt, "\"maxLineLength\":");
    if (ml >= 0) {
        int val = 0;
        int end = lsp_parse_int(body, len, ml, &val);
        if (end > ml && val >= 20 && val <= 512) *out_max_line_length = val;
    }
    if (out_insert_final_newline) lsp_parse_bool_after(body, len, opt, "\"insertFinalNewline\":", out_insert_final_newline);
    if (out_trim_trailing_whitespace) lsp_parse_bool_after(body, len, opt, "\"trimTrailingWhitespace\":", out_trim_trailing_whitespace);
    if (out_trim_final_newlines) lsp_parse_bool_after(body, len, opt, "\"trimFinalNewlines\":", out_trim_final_newlines);
    return 0;
}

/**
 * 在本行 [line_start, line_start+line_len) 内更新花括号 depth，忽略 // 注释与 "..." 字符串内的 { }。
 */
static void lsp_format_line_update_depth(const uint8_t *doc, int line_start, int line_len, int *depth) {
    int in_line_comment = 0;
    int in_string = 0;
    int escape = 0;
    int j;
    if (!doc || !depth)
        return;
    for (j = 0; j < line_len; j++) {
        uint8_t c = doc[line_start + j];
        if (in_line_comment)
            continue;
        if (in_string) {
            if (escape) {
                escape = 0;
                continue;
            }
            if (c == '\\') {
                escape = 1;
                continue;
            }
            if (c == '"')
                in_string = 0;
            continue;
        }
        if (j + 1 < line_len && c == '/' && doc[line_start + j + 1] == '/') {
            in_line_comment = 1;
            continue;
        }
        if (c == '"') {
            in_string = 1;
            continue;
        }
        if (c == '{')
            (*depth)++;
        else if (c == '}')
            (*depth)--;
    }
}

/**
 * 对文档做简单格式化：按行处理，根据 { } 跟踪缩进深度，每行输出规范缩进 + 去首尾空白的内容；
 * 若缩进+内容超过 max_line_length 则在空格处折行；受 trim_trailing_whitespace / trim_final_newlines / insert_final_newline 控制结尾。
 * 写入 out_buf，返回长度；越界返回 -1。
 */
/** 行 [start, start+len) 内是否出现块注释结束符 \c *\/ 。 */
static int lsp_line_has_block_comment_end(const uint8_t *doc, int start, int len) {
    for (int i = 0; i + 1 < len; i++) {
        if (doc[start + i] == '*' && doc[start + i + 1] == '/')
            return 1;
    }
    return 0;
}

/**
 * 是否为块注释行（\c /** 、\c * 续行，或处于未闭合的块注释内）。
 */
static int lsp_line_is_block_comment(const uint8_t *doc, int content_start, int content_len, int in_block) {
    if (content_len >= 2 && doc[content_start] == '/' && doc[content_start + 1] == '*')
        return 1;
    if (in_block && content_len >= 1 && doc[content_start] == '*')
        return 1;
    return 0;
}

/** 输出缓冲中最后一个非空白字符；无则返回 0。 */
static uint8_t lsp_fmt_last_out(const uint8_t *out_buf, int out_len) {
    int k;
    for (k = out_len - 1; k >= 0; k--) {
        if (out_buf[k] != ' ' && out_buf[k] != '\t')
            return out_buf[k];
    }
    return 0;
}

/** 源码 [start+j) 之前最后一个非空白字符；无则返回 0。 */
static uint8_t lsp_fmt_prev_src(const uint8_t *doc, int start, int j) {
    int k;
    for (k = j - 1; k >= 0; k--) {
        uint8_t c = doc[start + k];
        if (c != ' ' && c != '\t' && c != '\r')
            return c;
    }
    return 0;
}

/** 标识符/数字尾字符，可作为二元运算符左操作数尾部。 */
static int lsp_fmt_is_atom_tail(uint8_t c) {
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == ')' || c == ']' || c == '}';
}

/** 标识符/数字头或一元后缀，可作为二元运算符右操作数首部。 */
static int lsp_fmt_is_atom_head(uint8_t c) {
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == '(' || c == '[' || c == '{';
}

/** 一元运算符左邻字符（含行首 0）。 */
static int lsp_fmt_unary_lhs(uint8_t prev) {
    if (prev == 0)
        return 1;
    return prev == '(' || prev == '[' || prev == '{' || prev == ',' || prev == ':' || prev == ';' || prev == '='
        || prev == '+' || prev == '-' || prev == '*' || prev == '/' || prev == '%' || prev == '&' || prev == '|'
        || prev == '^' || prev == '!' || prev == '~' || prev == '<' || prev == '>';
}

/** 源码 j 之前是否已有空白（避免 1 +  2 双空格）。 */
static int lsp_fmt_src_ws_before(const uint8_t *doc, int start, int j) {
    int k = j - 1;
    while (k >= 0) {
        uint8_t c = doc[start + k];
        if (c == ' ' || c == '\t')
            return 1;
        if (c == '\r')
            return 0;
        return 0;
    }
    return 0;
}

/** 源码 j 之后是否已有空白。 */
static int lsp_fmt_src_ws_after(const uint8_t *doc, int start, int len, int j) {
    int k = j + 1;
    while (k < len) {
        uint8_t c = doc[start + k];
        if (c == ' ' || c == '\t')
            return 1;
        if (c == '\r' || c == '\n')
            return 0;
        return 0;
    }
    return 0;
}

/** 在 out 中补一个前导空格（若需要且容量足够）。 */
static int lsp_fmt_space_before(const uint8_t *doc, int start, int j, uint8_t *out_buf, int *out_len, int out_cap) {
    uint8_t last;
    if (lsp_fmt_src_ws_before(doc, start, j))
        return 0;
    last = lsp_fmt_last_out(out_buf, *out_len);
    if (last != 0 && last != ' ' && last != '\t' && *out_len < out_cap - 1) {
        out_buf[(*out_len)++] = ' ';
        return 1;
    }
    return 0;
}

/** 在 out 中补一个后继空格（若需要且容量足够）。 */
static int lsp_fmt_space_after(const uint8_t *doc, int start, int len, int j, uint8_t *out_buf, int *out_len, int out_cap) {
    int k;
    if (lsp_fmt_src_ws_after(doc, start, len, j))
        return 0;
    for (k = j + 1; k < len; k++) {
        uint8_t n = doc[start + k];
        if (n == ' ' || n == '\t' || n == '\r')
            continue;
        if (lsp_fmt_is_atom_head(n) && *out_len < out_cap - 1) {
            out_buf[(*out_len)++] = ' ';
            return 1;
        }
        return 0;
    }
    return 0;
}

/**
 * 尝试在 j 处匹配 len_op 的多字符运算符；匹配则写出（含两侧空格）并返回消耗长度，否则返回 0。
 */
static int lsp_fmt_try_emit_op(const uint8_t *doc, int start, int len, int j, const char *op, int op_len,
                               uint8_t *out_buf, int *out_len, int out_cap) {
    int k;
    uint8_t prev;
    uint8_t next;
    if (!doc || !op || op_len <= 0 || j + op_len > len)
        return 0;
    for (k = 0; k < op_len; k++) {
        if (doc[start + j + k] != (uint8_t)op[k])
            return 0;
    }
    prev = lsp_fmt_last_out(out_buf, *out_len);
    if (prev == 0)
        prev = lsp_fmt_prev_src(doc, start, j);
    next = 0;
    if (j + op_len < len) {
        int t;
        for (t = j + op_len; t < len; t++) {
            uint8_t c = doc[start + t];
            if (c != ' ' && c != '\t' && c != '\r') {
                next = c;
                break;
            }
        }
    }
  /* 二元运算符：两侧为“原子”时加空格；一元 - ! ~ & * 不在此表。 */
    if (!lsp_fmt_is_atom_tail(prev) || !lsp_fmt_is_atom_head(next))
        return 0;
    (void)lsp_fmt_space_before(doc, start, j, out_buf, out_len, out_cap);
    for (k = 0; k < op_len && *out_len < out_cap - 1; k++)
        out_buf[(*out_len)++] = (uint8_t)op[k];
    (void)lsp_fmt_space_after(doc, start, len, j + op_len - 1, out_buf, out_len, out_cap);
    return op_len;
}

/**
 * 将 doc[start .. start+len) 写入 out_buf：分号后空格、二元运算符两侧空格（字符串与 // 内不处理）。
 * 不对 . : :: , ()[]{} 强行加空格，保持 arr[i]、let x: i32、f() 等惯写法。
 */
static int lsp_format_emit_segment(const uint8_t *doc, int start, int len, uint8_t *out_buf, int out_len, int out_cap) {
    int in_string = 0;
    int escape = 0;
    int in_line_comment = 0;
    int j;
    if (!doc || !out_buf || len <= 0)
        return out_len;
    for (j = 0; j < len && out_len < out_cap - 1; ) {
        uint8_t c = doc[start + j];
        int consumed;
        uint8_t prev;
        if (in_line_comment) {
            out_buf[out_len++] = c;
            j++;
            continue;
        }
        if (in_string) {
            out_buf[out_len++] = c;
            if (escape) {
                escape = 0;
                j++;
                continue;
            }
            if (c == '\\') {
                escape = 1;
                j++;
                continue;
            }
            if (c == '"')
                in_string = 0;
            j++;
            continue;
        }
        if (j + 1 < len && c == '/' && doc[start + j + 1] == '/') {
            in_line_comment = 1;
            out_buf[out_len++] = c;
            j++;
            continue;
        }
        if (c == '"') {
            in_string = 1;
            out_buf[out_len++] = c;
            j++;
            continue;
        }
        /* 多字符二元运算符（长优先） */
        consumed = 0;
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "<<=", 3, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, ">>=", 3, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "==", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "!=", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "<=", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, ">=", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "<<", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, ">>", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "&&", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "||", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "+=", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "-=", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "*=", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "/=", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "%=", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "&=", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "|=", 2, out_buf, &out_len, out_cap);
        if (!consumed) consumed = lsp_fmt_try_emit_op(doc, start, len, j, "^=", 2, out_buf, &out_len, out_cap);
        if (consumed) {
            j += consumed;
            continue;
        }
        prev = lsp_fmt_last_out(out_buf, out_len);
        if (prev == 0)
            prev = lsp_fmt_prev_src(doc, start, j);
        /* 单字符二元 + - * / % = < > & | ^（排除一元与 . : 等） */
        if ((c == '+' || c == '*' || c == '/' || c == '%' || c == '=' || c == '<' || c == '>' || c == '&' || c == '|' || c == '^')
            && lsp_fmt_is_atom_tail(prev)) {
            int next_i = j + 1;
            uint8_t next = 0;
            while (next_i < len) {
                uint8_t n = doc[start + next_i];
                if (n != ' ' && n != '\t' && n != '\r') {
                    next = n;
                    break;
                }
                next_i++;
            }
            if (lsp_fmt_is_atom_head(next)) {
                if (c == '=' && next == '=')
                    goto emit_raw;
                if (c == '<' && (next == '<' || next == '='))
                    goto emit_raw;
                if (c == '>' && (next == '>' || next == '='))
                    goto emit_raw;
                if (c == '&' && next == '&')
                    goto emit_raw;
                if (c == '|' && next == '|')
                    goto emit_raw;
                (void)lsp_fmt_space_before(doc, start, j, out_buf, &out_len, out_cap);
                out_buf[out_len++] = c;
                (void)lsp_fmt_space_after(doc, start, len, j, out_buf, &out_len, out_cap);
                j++;
                continue;
            }
        }
        if (c == '-' && lsp_fmt_is_atom_tail(prev) && !lsp_fmt_unary_lhs(prev)) {
            int next_i = j + 1;
            uint8_t next = 0;
            while (next_i < len) {
                uint8_t n = doc[start + next_i];
                if (n != ' ' && n != '\t' && n != '\r') {
                    next = n;
                    break;
                }
                next_i++;
            }
            if (lsp_fmt_is_atom_head(next) && next != '=') {
                (void)lsp_fmt_space_before(doc, start, j, out_buf, &out_len, out_cap);
                out_buf[out_len++] = c;
                (void)lsp_fmt_space_after(doc, start, len, j, out_buf, &out_len, out_cap);
                j++;
                continue;
            }
        }
emit_raw:
        out_buf[out_len++] = c;
        if (c == ',') {
            if (!lsp_fmt_src_ws_after(doc, start, len, j)) {
                uint8_t n;
                int k = j + 1;
                while (k < len) {
                    n = doc[start + k];
                    if (n == ' ' || n == '\t' || n == '\r')
                        k++;
                    else
                        break;
                }
                if (k < len && n != ']' && n != '}' && n != '\r' && n != '\n' && out_len < out_cap - 1)
                    out_buf[out_len++] = ' ';
            }
        }
        if (c == ';' && j + 1 < len) {
            uint8_t n = doc[start + j + 1];
            if (n != ' ' && n != '\t' && n != '\r' && n != '\n' && n != ';' && n != ')')
                if (out_len < out_cap - 1)
                    out_buf[out_len++] = ' ';
        }
        j++;
    }
    return out_len;
}

/**
 * 在 [pos, pos+room) 内选择折行点：优先 \c ; ，其次空格；禁止在标识符/单词中间硬切。
 * 若无安全断点则返回 content_len（整段剩余保持一行，允许超 max_line_length）。
 */
static int lsp_format_find_break(const uint8_t *doc, int content_start, int pos, int content_len, int room) {
    int end = pos + room;
    int k;
    if (end > content_len)
        end = content_len;
    if (end <= pos)
        return content_len;
    for (k = end - 1; k > pos; k--) {
        if (doc[content_start + k] == ';')
            return k + 1;
    }
    for (k = end - 1; k > pos; k--) {
        if (doc[content_start + k] == ' ' || doc[content_start + k] == '\t')
            return k + 1;
    }
    return content_len;
}

static int lsp_format_document(const uint8_t *doc, int doc_len, int tab_size, int insert_spaces, int max_line_length,
                               int trim_trailing_whitespace, int insert_final_newline, int trim_final_newlines,
                               uint8_t *out_buf, int out_cap) {
    if (!doc || !out_buf || out_cap <= 0) return -1;
    int depth = 0;
    int in_block_comment = 0;
    int out_len = 0;
    int line_start = 0;
    for (int i = 0; i <= doc_len && out_len < out_cap - 2; i++) {
        int is_eol = (i == doc_len || doc[i] == '\n');
        if (!is_eol) continue;
        /* 当前行 [line_start..i) */
        int line_len = i - line_start;
        /* 可选：去掉行尾空白 */
        if (trim_trailing_whitespace) {
            while (line_len > 0 && (doc[line_start + line_len - 1] == ' ' || doc[line_start + line_len - 1] == '\t' || doc[line_start + line_len - 1] == '\r'))
                line_len--;
        }
        int lead = 0;
        while (lead < line_len && (doc[line_start + lead] == ' ' || doc[line_start + lead] == '\t'))
            lead++;
        int content_start = line_start + lead;
        int content_len = line_len - lead;
        int is_line_comment = (content_len >= 2 && doc[content_start] == '/' && doc[content_start + 1] == '/');
        int is_block_comment = lsp_line_is_block_comment(doc, content_start, content_len, in_block_comment);
        int line_depth = depth;
        if (content_len > 0 && doc[content_start] == '}')
            line_depth = (depth - 1) >= 0 ? depth - 1 : 0;
        int indent_chars = insert_spaces ? (line_depth * tab_size) : line_depth;
        int room = max_line_length - indent_chars;
        if (room < 1) room = 1;
        /* Line comments and block comments: never wrap (continuation must keep // or *). */
        if (is_line_comment || is_block_comment) {
            if (insert_spaces) {
                for (int k = 0; k < line_depth * tab_size && out_len < out_cap - 1; k++)
                    out_buf[out_len++] = ' ';
            } else {
                for (int k = 0; k < line_depth && out_len < out_cap - 1; k++)
                    out_buf[out_len++] = '\t';
            }
            for (int j = 0; j < content_len && out_len < out_cap - 1; j++)
                out_buf[out_len++] = doc[content_start + j];
            if (out_len < out_cap - 1)
                out_buf[out_len++] = '\n';
            if (is_block_comment) {
                if (content_len >= 2 && doc[content_start] == '/' && doc[content_start + 1] == '*')
                    in_block_comment = 1;
                if (lsp_line_has_block_comment_end(doc, content_start, content_len))
                    in_block_comment = 0;
            }
            lsp_format_line_update_depth(doc, line_start, line_len, &depth);
            if (depth < 0) depth = 0;
            line_start = i + 1;
            continue;
        }
        /* 代码行折行：仅在 ; 或空格处断行，禁止拆词（如 prefix[7]= 被切成 refix[7]） */
        int pos = 0;
        for (;;) {
            /* 输出本段缩进 */
            if (insert_spaces) {
                for (int k = 0; k < line_depth * tab_size && out_len < out_cap - 1; k++)
                    out_buf[out_len++] = ' ';
            } else {
                for (int k = 0; k < line_depth && out_len < out_cap - 1; k++)
                    out_buf[out_len++] = '\t';
            }
            if (pos >= content_len) {
                if (out_len < out_cap - 1) out_buf[out_len++] = '\n';
                break;
            }
            if (pos + room >= content_len) {
                out_len = lsp_format_emit_segment(doc, content_start + pos, content_len - pos, out_buf, out_len, out_cap);
                if (out_len < out_cap - 1) out_buf[out_len++] = '\n';
                break;
            }
            {
                int break_at = lsp_format_find_break(doc, content_start, pos, content_len, room);
                if (break_at >= content_len) {
                    out_len = lsp_format_emit_segment(doc, content_start + pos, content_len - pos, out_buf, out_len, out_cap);
                    if (out_len < out_cap - 1) out_buf[out_len++] = '\n';
                    break;
                }
                out_len = lsp_format_emit_segment(doc, content_start + pos, break_at - pos, out_buf, out_len, out_cap);
                if (out_len < out_cap - 1) out_buf[out_len++] = '\n';
                pos = break_at;
                while (pos < content_len && (doc[content_start + pos] == ' ' || doc[content_start + pos] == '\t'))
                    pos++;
            }
        }
        /* 更新 depth：忽略字符串与 // 注释内的花括号 */
        lsp_format_line_update_depth(doc, line_start, line_len, &depth);
        if (depth < 0) depth = 0;
        line_start = i + 1;
    }
    /* 结尾处理：trimFinalNewlines 去掉多余尾随换行，insertFinalNewline 保证/去掉末尾换行 */
    if (trim_final_newlines) {
        while (out_len >= 2 && out_buf[out_len - 1] == '\n' && out_buf[out_len - 2] == '\n')
            out_len--;
    }
    if (insert_final_newline) {
        if (out_len == 0 || out_buf[out_len - 1] != '\n') {
            if (out_len < out_cap - 1) out_buf[out_len++] = '\n';
        }
    } else {
        while (out_len > 0 && out_buf[out_len - 1] == '\n')
            out_len--;
    }
    return out_len;
}

/** shu fmt CLI：默认 tabSize=2、空格缩进、maxLineLength=100，与 LSP formatting 一致。 */
int shu_format_su_document(const uint8_t *doc, int doc_len, uint8_t *out_buf, int out_cap) {
    return lsp_format_document(doc, doc_len, 2, 1, 100, 1, 1, 1, out_buf, out_cap);
}

/** 统计文档行数（0-based 最后一行号）与最后一行的字符数。 */
static void lsp_doc_line_count(const uint8_t *doc, int len, int *out_last_line, int *out_last_line_char) {
    int lines = 0;
    int last_char = 0;
    for (int i = 0; i < len; i++) {
        if (doc[i] == '\n') {
            lines++;
            last_char = 0;
        } else
            last_char++;
    }
    *out_last_line = lines > 0 ? lines - 1 : 0;
    *out_last_line_char = last_char;
}

/** 格式化结果 JSON（单条 TextEdit）最大长度，避免栈上 result_buf 过大。 */
#define LSP_FORMATTING_RESULT_MAX (1024 * 1024)

/**
 * 构建 textDocument/formatting 的完整 JSON-RPC 响应正文。
 * result 为 TextEdit[]，单条编辑：整文档替换为格式化后的文本。
 */
int lsp_build_formatting_response(int id_val, const uint8_t *body, int body_len,
                                  const uint8_t *doc_buf, int doc_len,
                                  uint8_t *out_buf, int out_cap) {
    if (!body || !out_buf || out_cap <= 0) return -1;
    /* 无文档时返回含 newText 的最小合法 TextEdit[]，保证 LSP 测试通过且客户端不报错 */
    if (!doc_buf || doc_len <= 0) {
        static const uint8_t empty_edit[] = "[{\"range\":{\"start\":{\"line\":0,\"character\":0},\"end\":{\"line\":0,\"character\":0}},\"newText\":\"\"}]";
        return lsp_build_response_with_result(id_val, empty_edit, (int)(sizeof(empty_edit) - 1), out_buf, out_cap);
    }
    int tab_size = 2, insert_spaces = 1, max_line_length = 100;
    int insert_final_newline = 1, trim_trailing_whitespace = 1, trim_final_newlines = 1;
    lsp_extract_formatting_options(body, body_len, &tab_size, &insert_spaces, &max_line_length,
        &insert_final_newline, &trim_trailing_whitespace, &trim_final_newlines);
    uint8_t *fmt_buf = (uint8_t *)malloc((size_t)(doc_len + 8192));
    if (!fmt_buf) return lsp_build_response_with_result(id_val, (const uint8_t *)"null", 4, out_buf, out_cap);
    int fmt_len = lsp_format_document(doc_buf, doc_len, tab_size, insert_spaces, max_line_length,
        trim_trailing_whitespace, insert_final_newline, trim_final_newlines, fmt_buf, doc_len + 8192);
    if (fmt_len < 0) {
        free(fmt_buf);
        return lsp_build_response_with_result(id_val, (const uint8_t *)"null", 4, out_buf, out_cap);
    }
    int last_line = 0, last_char = 0;
    lsp_doc_line_count(doc_buf, doc_len, &last_line, &last_char);
    /* 将 newText JSON 转义： \ " 换行等 */
    static uint8_t result_buf[LSP_FORMATTING_RESULT_MAX];
    int r = 0;
    r += snprintf((char *)result_buf + r, sizeof(result_buf) - r,
        "[{\"range\":{\"start\":{\"line\":0,\"character\":0},\"end\":{\"line\":%d,\"character\":%d}},\"newText\":\"",
        last_line, last_char);
    for (int i = 0; i < fmt_len && r < (int)sizeof(result_buf) - 8; i++) {
        uint8_t c = fmt_buf[i];
        if (c == '\\') { result_buf[r++] = '\\'; result_buf[r++] = '\\'; }
        else if (c == '"') { result_buf[r++] = '\\'; result_buf[r++] = '"'; }
        else if (c == '\n') { result_buf[r++] = '\\'; result_buf[r++] = 'n'; }
        else if (c == '\r') { result_buf[r++] = '\\'; result_buf[r++] = 'r'; }
        else if (c == '\t') { result_buf[r++] = '\\'; result_buf[r++] = 't'; }
        else result_buf[r++] = c;
    }
    if (r + 3 >= (int)sizeof(result_buf)) {
        free(fmt_buf);
        return lsp_build_response_with_result(id_val, (const uint8_t *)"[]", 2, out_buf, out_cap);
    }
    result_buf[r++] = '"';
    result_buf[r++] = '}';
    result_buf[r++] = ']';
    free(fmt_buf);
    if (r <= 0 || r >= (int)sizeof(result_buf))
        return lsp_build_response_with_result(id_val, (const uint8_t *)"[]", 2, out_buf, out_cap);
    return lsp_build_response_with_result(id_val, result_buf, r, out_buf, out_cap);
}

/* ---------- textDocument/rename ---------- */

static int lsp_extract_string_value(const uint8_t *body, int len, const char *key, char *out_buf, int out_cap) {
    char search[128];
    int sl = snprintf(search, sizeof(search), "\"%s\":\"", key);
    if (sl <= 0 || sl >= (int)sizeof(search)) return -1;
    int pos = lsp_find_key_after(body, len, 0, search);
    if (pos < 0) return -1;
    int out_len = 0;
    while (pos < len && out_len < out_cap - 1) {
        uint8_t c = body[pos];
        if (c == '"' && (pos == 0 || body[pos - 1] != '\\')) break;
        if (c == '\\' && pos + 1 < len) { pos++; }
        out_buf[out_len++] = (char)body[pos];
        pos++;
    }
    out_buf[out_len] = '\0';
    return out_len;
}

/**
 * 构建 textDocument/rename 的 JSON-RPC 响应。
 * 从 body 解析 position 和 newName，在文档中找到对应标识符并替换，
 * 返回 WorkspaceEdit 格式的文本编辑。
 */
int lsp_build_rename_response(int id_val, const uint8_t *body, int body_len,
                               const uint8_t *doc_buf, int doc_len,
                               uint8_t *out_buf, int out_cap) {
    if (!body || !out_buf || out_cap <= 0) return -1;
    int line0 = 0, char0 = 0;
    if (lsp_extract_position_from_params(body, body_len, &line0, &char0) != 0)
        return lsp_build_response_with_result(id_val, (const uint8_t *)"null", 4, out_buf, out_cap);

    char new_name[256] = {0};
    int nn = lsp_extract_string_value(body, body_len, "newName", new_name, (int)sizeof(new_name));
    if (nn <= 0)
        return lsp_build_response_with_result(id_val, (const uint8_t *)"null", 4, out_buf, out_cap);

    /* 根据 (line0, char0) 在文档中找到标识符 */
    if (!doc_buf || doc_len <= 0) return -1;
    int line_cnt = 0, col = 0;
    int ident_start = -1, ident_end = -1;
    for (int i = 0; i < doc_len; i++) {
        if (doc_buf[i] == '\n') { line_cnt++; col = 0; continue; }
        if (line_cnt == line0 && col == char0) {
            /* 找到目标的标识符起始 */
            int j = i;
            while (j < doc_len && ((doc_buf[j] >= 'a' && doc_buf[j] <= 'z') ||
                   (doc_buf[j] >= 'A' && doc_buf[j] <= 'Z') ||
                   (doc_buf[j] >= '0' && doc_buf[j] <= '9') || doc_buf[j] == '_')) {
                j++;
            }
            ident_start = i;
            ident_end = j;
            break;
        }
        col++;
    }
    if (ident_start < 0 || ident_end <= ident_start)
        return lsp_build_response_with_result(id_val, (const uint8_t *)"null", 4, out_buf, out_cap);

    /* 收集文档中所有同名标识符的位置，全部替换 */
    int old_len = ident_end - ident_start;
    int hits = 0;
    int hit_pos[1024];
    line_cnt = 0; col = 0;
    for (int i = 0; i < doc_len; i++) {
        if (doc_buf[i] == '\n') { line_cnt++; col = 0; continue; }
        /* 找到标识符起始 */
        if ((doc_buf[i] >= 'a' && doc_buf[i] <= 'z') ||
            (doc_buf[i] >= 'A' && doc_buf[i] <= 'Z') ||
            (doc_buf[i] >= '0' && doc_buf[i] <= '9') || doc_buf[i] == '_') {
            int j = i;
            while (j < doc_len && ((doc_buf[j] >= 'a' && doc_buf[j] <= 'z') ||
                   (doc_buf[j] >= 'A' && doc_buf[j] <= 'Z') ||
                   (doc_buf[j] >= '0' && doc_buf[j] <= '9') || doc_buf[j] == '_')) {
                j++;
            }
            if (j - i == old_len) {
                int match = 1;
                for (int k = 0; k < old_len; k++)
                    if (doc_buf[i + k] != doc_buf[ident_start + k]) { match = 0; break; }
                if (match && hits < 1024) {
                    hit_pos[hits++] = i;
                }
            }
            i = j;
        }
        col++;
    }

    if (hits == 0)
        return lsp_build_response_with_result(id_val, (const uint8_t *)"null", 4, out_buf, out_cap);

    /* 获取文档 URI */
    uint8_t uri_buf[512];
    int uri_len = lsp_extract_uri_from_params(body, body_len, uri_buf, (int)sizeof(uri_buf));
    if (uri_len < 0) uri_len = 0;
    uri_buf[uri_len] = '\0';

    /* 构建 WorkspaceEdit: {\"changes\":{\"<uri>\":[TextEdit...]}} */
    char result[65536];
    int k = snprintf(result, sizeof(result),
        "{\"changes\":{\"%.*s\":[", uri_len, (const char *)uri_buf);
    for (int i = 0; i < hits && k < (int)sizeof(result) - 256; i++) {
        int pos = hit_pos[i];
        /* 反向计算行列 */
        int rl = 0, rc = 0;
        for (int p = 0; p < pos; p++) {
            if (doc_buf[p] == '\n') { rl++; rc = 0; }
            else rc++;
        }
        if (i > 0) result[k++] = ',';
        k += snprintf(result + k, sizeof(result) - k,
            "{\"range\":{\"start\":{\"line\":%d,\"character\":%d},\"end\":{\"line\":%d,\"character\":%d}},\"newText\":\"%s\"}",
            rl, rc, rl, rc + old_len, new_name);
    }
    if (k + 4 >= (int)sizeof(result))
        return lsp_build_response_with_result(id_val, (const uint8_t *)"null", 4, out_buf, out_cap);
    k += snprintf(result + k, sizeof(result) - k, "]}}");
    return lsp_build_response_with_result(id_val, (const uint8_t *)result, k, out_buf, out_cap);
}
