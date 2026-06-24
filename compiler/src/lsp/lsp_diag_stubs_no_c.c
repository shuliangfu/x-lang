/**
 * lsp_diag_stubs_no_c.c — E-02 默认：替代 lsp_diag.c 的 LSP 收集器 / 文档缓冲 / JSON 壳桩
 *
 * bootstrap-driver-seed / build_shux_asm 默认链本 TU（`LSP_DIAG_LINK_O`），不链 lsp_diag.c。
 * 不依赖 parser/lexer/typeck/ast C API；诊断 JSON 由 lsp_diag_sx.o + lsp_diag_sx_alias.c 提供。
 */
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <stdarg.h>

extern size_t lsp_diag_pipeline_sizeof_arena(void);
extern size_t lsp_diag_pipeline_sizeof_module(void);
extern size_t lsp_diag_pipeline_sizeof_dep_ctx(void);

/* ====== SX 管道缓冲 ====== */

void *lsp_diag_sx_arena_ptr(void) {
    static void *p;
    if (!p) p = calloc(1, lsp_diag_pipeline_sizeof_arena());
    return p;
}

void *lsp_diag_sx_module_ptr(void) {
    static void *p;
    if (!p) p = calloc(1, lsp_diag_pipeline_sizeof_module());
    return p;
}

void *lsp_diag_sx_ctx_ptr(void) {
    static void *p;
    if (!p) p = calloc(1, lsp_diag_pipeline_sizeof_dep_ctx());
    return p;
}

void lsp_diag_sx_reset_parse_buffers(void) {
    void *a = lsp_diag_sx_arena_ptr();
    void *m = lsp_diag_sx_module_ptr();
    void *c = lsp_diag_sx_ctx_ptr();
    if (a) memset(a, 0, lsp_diag_pipeline_sizeof_arena());
    if (m) memset(m, 0, lsp_diag_pipeline_sizeof_module());
    if (c) memset(c, 0, lsp_diag_pipeline_sizeof_dep_ctx());
}

/* ====== 诊断收集 ====== */

#ifndef LSP_DIAG_MAX
#define LSP_DIAG_MAX  64
#endif
#ifndef LSP_MSG_MAX
#define LSP_MSG_MAX   240
#endif

typedef struct {
    int line;
    int col;
    int severity;
    char msg[LSP_MSG_MAX + 1];
} LspDiagEntryStub;

static LspDiagEntryStub s_diag[LSP_DIAG_MAX];
static int s_diag_count;

int lsp_diag_enabled = 0;

void lsp_diag_clear(void) {
    s_diag_count = 0;
}

void lsp_diag_add(int line, int col, int severity, const char *msg) {
    if (s_diag_count >= LSP_DIAG_MAX) return;
    LspDiagEntryStub *e = &s_diag[s_diag_count++];
    e->line = line;
    e->col = col;
    e->severity = (severity == 2) ? 2 : ((severity == 3) ? 3 : 1);
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

int lsp_diag_count_severity(int severity) {
    int i, n = 0;
    for (i = 0; i < s_diag_count; i++)
        if (s_diag[i].severity == severity)
            n++;
    return n;
}

void lsp_diag_collect_begin(void) {
    lsp_diag_clear();
    lsp_diag_enabled = 1;
}

void lsp_diag_collect_end(void) {
    lsp_diag_enabled = 0;
}

/* JSON 字符串转义辅助 */
static int json_escape_str(const char *msg, char *out, int out_cap) {
    int k = 0;
    if (!msg || !out || out_cap <= 0) return 0;
    for (int i = 0; msg[i] != '\0' && k < out_cap - 2; i++) {
        char c = msg[i];
        switch (c) {
            case '"': case '\\':
                if (k + 2 >= out_cap) { out[k] = '\0'; return k; }
                out[k++] = '\\'; out[k++] = c; break;
            case '\n': if (k + 2 >= out_cap) { out[k] = '\0'; return k; } out[k++] = '\\'; out[k++] = 'n'; break;
            case '\r': if (k + 2 >= out_cap) { out[k] = '\0'; return k; } out[k++] = '\\'; out[k++] = 'r'; break;
            case '\t': if (k + 2 >= out_cap) { out[k] = '\0'; return k; } out[k++] = '\\'; out[k++] = 't'; break;
            default:
                out[k++] = c;
                break;
        }
    }
    if (k < out_cap) out[k] = '\0';
    return k;
}

int lsp_diag_format_diagnostics_json(char *out, int out_cap) {
    int k = 0;
    if (!out || out_cap <= 0) return 0;
    if (out_cap < 3) return 0;
    out[k++] = '[';
    for (int i = 0; i < s_diag_count && k < out_cap - 2; i++) {
        LspDiagEntryStub *e = &s_diag[i];
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

void lsp_diag_invalidate_cache(void) {
    s_diag_count = 0;
}

/* ====== JSON-RPC 响应构建 ====== */

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
    if (n == 0) { id_buf[id_len++] = '0'; }
    else { while (n > 0 && id_len < 15) { id_buf[id_len++] = (char)('0' + n % 10); n /= 10; } }
    int j = id_len - 1;
    while (j >= 0 && k < out_cap - 1) { out_buf[k++] = (uint8_t)id_buf[j--]; }
    for (i = 0; mid[i] && k < out_cap - 1; i++, k++) out_buf[k] = (uint8_t)mid[i];
    for (i = 0; i < result_len && k < out_cap - 1; i++, k++) out_buf[k] = result_ptr[i];
    for (i = 0; suffix[i] && k < out_cap - 1; i++, k++) out_buf[k] = (uint8_t)suffix[i];
    return k;
}

/* ====== 文档缓冲 ====== */

static uint8_t *s_doc_ptr = NULL;
static int s_doc_len = 0;

void lsp_set_document_from_body(const uint8_t *body, int body_len) {
    if (!body || body_len <= 0) {
        if (s_doc_ptr) { free(s_doc_ptr); s_doc_ptr = NULL; }
        s_doc_len = 0;
        return;
    }
    if (s_doc_ptr) free(s_doc_ptr);
    s_doc_ptr = (uint8_t *)malloc((size_t)body_len + 1);
    if (!s_doc_ptr) { s_doc_len = 0; return; }
    memcpy(s_doc_ptr, body, (size_t)body_len);
    s_doc_ptr[body_len] = '\0';
    s_doc_len = body_len;
}

uint8_t *lsp_get_document_ptr(void) { return s_doc_ptr; }
int lsp_get_document_len(void) { return s_doc_len; }

/* ====== 调试桩 ====== */
void lsp_debug_u32(uint32_t n) { (void)n; }
void lsp_debug_ptr(uint8_t *p) { (void)p; }

/* ====== SHUX_NO_C_FRONTEND 下不可用的高级 LSP 功能桩 ====== */
int lsp_build_definition_response(int id_val, const uint8_t *source, int source_len, int line_0, int col_0, uint8_t *out_buf, int out_cap) {
    (void)id_val; (void)source; (void)source_len; (void)line_0; (void)col_0;
    if (out_buf && out_cap > 2) { out_buf[0] = 'n'; out_buf[1] = 'u'; out_buf[2] = 'l'; out_buf[3] = 'l'; return 4; }
    return -1;
}
int lsp_build_hover_response(int id_val, const uint8_t *source, int source_len, int line_0, int col_0, uint8_t *out_buf, int out_cap) {
    (void)id_val; (void)source; (void)source_len; (void)line_0; (void)col_0;
    if (out_buf && out_cap > 2) { out_buf[0] = 'n'; out_buf[1] = 'u'; out_buf[2] = 'l'; out_buf[3] = 'l'; return 4; }
    return -1;
}
int lsp_build_references_response(int id_val, const uint8_t *source, int source_len, int line_0, int col_0, uint8_t *out_buf, int out_cap) {
    (void)id_val; (void)source; (void)source_len; (void)line_0; (void)col_0;
    if (out_buf && out_cap > 2) { out_buf[0] = '['; out_buf[1] = ']'; return 2; }
    return -1;
}
int lsp_build_formatting_response(int id_val, const uint8_t *source, int source_len, uint8_t *out_buf, int out_cap) {
    (void)id_val; (void)source; (void)source_len;
    if (out_buf && out_cap > 0) { out_buf[0] = '\0'; return 0; }
    return -1;
}
int lsp_build_initialize_result(int id_val, uint8_t *out_buf, int out_cap) {
    (void)id_val; (void)out_buf; (void)out_cap;
    return -1;
}

/**
 * shux fmt 单文件：NO_C seed 无 lsp_diag.c 时透传源码（不做 LSP 规则格式化）。
 * 参数：doc 输入；doc_len 长度；out_buf 输出缓冲；out_cap 容量。
 * 返回值：写入字节数；失败 -1。
 */
int shu_format_sx_document(const uint8_t *doc, int doc_len, uint8_t *out_buf, int out_cap) {
    if (!doc || doc_len <= 0 || !out_buf || out_cap <= doc_len)
        return -1;
    memcpy(out_buf, doc, (size_t)doc_len);
    return doc_len;
}

/** NO_C seed 不链 lsp_diag.c 时的 pipeline ctx 桩。 */
void lsp_diag_prepare_pipeline_ctx(void *ctx_void) {
    (void)ctx_void;
}

/** typeck 诊断上报：NO_C seed 链无 LSP 收集器，须直写 stderr（与 lsp_diag.c 非 collect 分支一致）。 */
void lsp_diag_report_typeck(int line, int col, const char *fmt, ...) {
    char buf[512];
    va_list ap;
    va_start(ap, fmt);
    (void)vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);
    fprintf(stderr, "typeck error: %s at %d:%d\n", buf, line, col);
}

/** shux check 收集诊断后以人类可读格式打印 stderr（与 lsp_diag.c 一致，bootstrap NO_C 链须可用）。 */
int lsp_diag_print_stderr_human(const char *path) {
    int i;
    int n = 0;
    const char *sev;

    if (!path)
        path = "?";
    for (i = 0; i < s_diag_count; i++) {
        if (s_diag[i].severity == 2)
            sev = "warning";
        else if (s_diag[i].severity == 3)
            sev = "info";
        else
            sev = "error";
        fprintf(stderr, "%s:%d:%d - %s: %s\n", path, s_diag[i].line, s_diag[i].col, sev, s_diag[i].msg);
        n++;
    }
    if (n > 0)
        fflush(stderr);
    return n;
}

/** LSP completion / documentSymbol / rename 响应桩（NO_C seed 不启完整 LSP）。 */
int lsp_build_completion_response(int id_val, const uint8_t *body, int body_len,
    const uint8_t *doc_buf, int doc_len, uint8_t *out_buf, int out_cap) {
    (void)id_val; (void)body; (void)body_len; (void)doc_buf; (void)doc_len;
    if (out_buf && out_cap > 4) {
        out_buf[0] = 'n'; out_buf[1] = 'u'; out_buf[2] = 'l'; out_buf[3] = 'l';
        return 4;
    }
    return -1;
}

int lsp_build_document_symbol_response(int id_val, const uint8_t *source, int source_len,
    uint8_t *out_buf, int out_cap) {
    (void)id_val; (void)source; (void)source_len;
    if (out_buf && out_cap > 2) { out_buf[0] = '['; out_buf[1] = ']'; return 2; }
    return -1;
}

int lsp_build_rename_response(int id_val, const uint8_t *source, int source_len,
    int line_0, int col_0, uint8_t *out_buf, int out_cap) {
    (void)id_val; (void)source; (void)source_len; (void)line_0; (void)col_0;
    if (out_buf && out_cap > 4) {
        out_buf[0] = 'n'; out_buf[1] = 'u'; out_buf[2] = 'l'; out_buf[3] = 'l';
        return 4;
    }
    return -1;
}
