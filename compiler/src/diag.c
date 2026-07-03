#include "diag.h"

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if !defined(_WIN32)
#ifndef _WIN32
#include <unistd.h>
#endif
#endif

typedef struct DiagContext {
    const char *file_path;
    const char *source;
    size_t source_len;
    int use_color;
} DiagContext;

typedef struct DiagCodeExplain {
    const char *code;
    const char *kind;
    const char *summary;
    const char *details;
} DiagCodeExplain;

static DiagContext g_diag_ctx;

/* JSON 诊断模式：-2 = 尚未决定（按 SHUX_DIAG_JSON 环境变量），1 = 开启，0 = 关闭。 */
static int g_diag_json = -2;

static const DiagCodeExplain g_diag_code_table[] = {
    {"P001", "parse error", "Parser detected invalid syntax or unrecoverable parse failure.",
     "Used for parser-side syntax errors and parser fatal conditions such as out-of-memory. "
     "Typical action: inspect the reported token/statement boundary and surrounding source line."},
    {"T001", "typeck error", "Type checker rejected a construct after successful parse.",
     "Used for regular C-path type checking failures such as mismatched types, invalid assignments, "
     "or non-bool conditions. Typical action: compare inferred and expected types at the caret location."},
    {"ARG001", "usage error", "CLI command or option is missing a required argument.",
     "Used when a command such as `--explain` or another CLI option is present but the required value is "
     "missing. Typical action: re-run with the required operand shown in the usage hint."},
    {"ARG002", "argument error", "CLI argument value is unknown or unsupported.",
     "Used when a user-provided CLI argument cannot be recognized, such as an unknown diagnostic code for "
     "`--explain`. Typical action: inspect the suggested valid values and retry with one of them."},
    {"IO001", "io error", "A file operation failed before the requested compiler step could continue.",
     "Used for common runtime file-operation failures such as open, read, write, rename, or temp-file setup. "
     "Typical action: inspect the path in the diagnostic and verify permissions, existence, and parent directories."},
    {"PRC001", "process error", "A child process or system-level process operation failed.",
     "Used for waitpid, system(), or child-process termination failures in compiler helper paths. "
     "Typical action: inspect the named tool or script and any paired stderr emitted before this summary."},
    {"BLD001", "build error", "An external build or link step failed before producing a usable artifact.",
     "Used for compiler/linker/tool invocations and runtime object build failures summarized at the driver layer. "
     "Typical action: inspect the failing tool name, exit status, and any preceding build stderr."},
    {"PP001", "preprocess error", "Preprocessor found an unclosed conditional directive.",
     "Used when `#if` / `#elseif` / `#else` nesting does not terminate cleanly before end-of-file. "
     "Typical action: inspect nearby conditional compilation directives and ensure every `#if` is closed."},
    {"PP002", "preprocess error", "Preprocessor failed before producing a usable source buffer.",
     "Used for directive errors or generic preprocess failures that are not covered by a more specific code. "
     "Typical action: inspect the reported source file and nearby conditional compilation directives."},
    {"IMP001", "import error", "Import path could not be opened from the resolved candidate path.",
     "Used when an import target cannot be opened after path resolution. Typical action: verify the import name, "
     "library roots, and the resolved on-disk file path shown in the diagnostic."},
    {"IMP002", "preprocess error", "Imported module failed during preprocessing before parse.",
     "Used when an imported file was found but preprocessing of that import failed. Typical action: inspect the "
     "imported file for conditional-compilation errors such as unclosed directives."},
    {"IMP003", "import error", "Imported module failed to parse after preprocessing.",
     "Used when an import file was read and preprocessed successfully but parse still failed. Typical action: "
     "inspect the imported module with the reported parser diagnostics."},
    {"IMP004", "import error", "Import pipeline failed in a later dependency-resolution stage.",
     "Used for import-side failures such as path normalization limits, unresolved dependency closure, or imported "
     "module type-check failure summaries. Typical action: inspect the paired import diagnostics emitted earlier."},
    {"SXP001", "pipeline error", ".sx pipeline parse stage failed before building a usable module.",
     "Used when the .sx pipeline cannot finish parse/module construction. Typical action: inspect the "
     "preceding parse diagnostics and the failing module entry."},
    {"SXP002", "pipeline error", ".sx pipeline parse commit failed while committing a parsed function.",
     "Used for stricter .sx parse/commit failures after a function was tentatively parsed but could not be "
     "committed into the module. Typical action: inspect nearby function boundaries and parse-recovery logs."},
    {"SXP003", "pipeline error", ".sx pipeline terminated with a non-zero runtime status code.",
     "Used for generic .sx pipeline summary failures reported as `pipeline failed rc=...` after a deeper stage "
     "returned an error code. Typical action: inspect preceding parser/typeck/import/codegen diagnostics."},
    {"SXP004", "pipeline error", ".sx pipeline path resolution trace for a failed import or entry lookup.",
     "Used for the follow-up `resolve path tried:` diagnostic that lists the concrete path attempted before "
     "pipeline failure. Typical action: inspect the shown path and verify library roots and import naming."},
    {"SXP005", "pipeline error", ".sx pipeline failed while allocating required runtime structures.",
     "Used for allocation failures covering arena/module buffers, ELF context, or dependency-side arena/module "
     "storage before the pipeline can proceed. Typical action: inspect memory pressure and the specific pipeline stage."},
    {"SXP006", "pipeline error", ".sx pipeline failed while allocating output or dependency context state.",
     "Used when `CodegenOutBuf`, `PipelineDepCtx`, or dependency-local output/context buffers cannot be allocated. "
     "Typical action: inspect memory pressure and whether a large-output path is being exercised."},
    {"SXP007", "pipeline error", ".sx pipeline refused an input buffer that exceeds parser size limits.",
     "Used for `source too large for parser` failures when the source buffer exceeds the current `int32_t` parser "
     "boundary. Typical action: reduce input size or change the parser limit handling."},
    {"SXP008", "pipeline error", ".sx dependency sub-pipeline failed while prerunning an imported module.",
     "Used for `pipeline failed for import` summaries emitted after a dependency prerun returns non-zero. "
     "Typical action: inspect earlier diagnostics for the referenced import path and its transitive dependencies."},
    {"SXT001", "typeck error", ".sx pipeline type checking failed for a specific function.",
     "Used when .sx type checking fails inside a concrete function, often with function index/name attached. "
     "Typical action: inspect the named function body and any accompanying type diagnostics."},
    {"CG001", "codegen error", "Code generation could not emit C output because no main entry was available.",
     "Used when executable-oriented C emission requires a `main` function but the module only contains library "
     "items or no callable entry. Typical action: add a `main` entry or switch to a library/module emission path."},
    {"CG002", "codegen error", "ASM object emission failed before producing a usable .o payload.",
     "Used for `asm_codegen_elf_o failed` summaries where the backend or ELF writer returned a failing status or "
     "produced an empty object buffer. Typical action: inspect paired ELF context notes and earlier backend diagnostics."},
    {"CG003", "codegen error", "Code generator failed while emitting a specific function body.",
     "Used for `failed to emit function` summaries tied to a concrete function name or index. Typical action: "
     "inspect that function body and any preceding backend/type diagnostics for unsupported constructs."},
    {"CG004", "codegen error", "Code generation produced an empty output buffer after a non-failing pipeline.",
     "Used when the C-path `.sx -E` pipeline returns success but the codegen output buffer is empty, indicating a "
     "codegen/pipeline wiring gap rather than a reported typeck/codegen error. Typical action: inspect the CodegenOutBuf "
     "wiring and any earlier typeck/codegen diagnostics."},
    {"CHK001", "check error", "`shux check` failed without a more specific structured diagnostic.",
     "Fallback check-mode code used when compilation/check failed but no detailed parser/typeck/import "
     "diagnostic was emitted. Typical action: inspect prior stderr output and the target file path."},
    {"CHK002", "check error", "`shux check` found no .sx files to inspect.",
     "Used when the provided path set, or the current directory, contains no discoverable .sx sources. "
     "Typical action: verify input paths and whether ignored filters removed all candidates."},
    {"FMT001", "fmt error", "`shux fmt` failed or found no format candidates.",
     "Used for format-mode failures such as missing input files, unreadable files, or no .sx files found. "
     "Typical action: verify the path list, file accessibility, and whether `--check` reported unformatted files."},
    {"SMOKE001", "info", "Parse-stage smoke summary: source parsed successfully.",
     "Emitted as an info-level smoke marker after a successful parse/typeck pass on the no-`-o` smoke path. "
     "Only emitted when structured smoke output is opted in (`--diag-json` or `SHUX_SMOKE_DIAG=1`); the legacy "
     "`parse OK` stdout line remains for grep/golden compatibility. Typical action: none (success marker)."},
    {"SMOKE002", "info", "Typeck-stage smoke summary: type checking passed.",
     "Emitted as an info-level smoke marker after type checking succeeds on the no-`-o` smoke path. "
     "Only emitted when structured smoke output is opted in (`--diag-json` or `SHUX_SMOKE_DIAG=1`); the legacy "
     "`typeck OK` stdout line remains for grep/golden compatibility. Typical action: none (success marker)."},
};
static const size_t g_diag_code_table_count = sizeof(g_diag_code_table) / sizeof(g_diag_code_table[0]);

static int diag_should_color(void) {
#if defined(_WIN32)
    return 0;
#else
    if (getenv("SHUX_NO_COLOR"))
        return 0;
    return isatty(fileno(stderr)) ? 1 : 0;
#endif
}

static const char *diag_color_prefix(const char *plain, const char *color) {
    return g_diag_ctx.use_color ? color : plain;
}

static const char *diag_color_reset(void) {
    return g_diag_ctx.use_color ? "\x1b[0m" : "";
}

static int diag_code_eq(const char *lhs, const char *rhs) {
    size_t i;
    if (!lhs || !rhs)
        return 0;
    for (i = 0; lhs[i] && rhs[i]; i++) {
        unsigned char a = (unsigned char)lhs[i];
        unsigned char b = (unsigned char)rhs[i];
        if (a >= 'a' && a <= 'z')
            a = (unsigned char)(a - 'a' + 'A');
        if (b >= 'a' && b <= 'z')
            b = (unsigned char)(b - 'a' + 'A');
        if (a != b)
            return 0;
    }
    return lhs[i] == '\0' && rhs[i] == '\0' ? 1 : 0;
}

static const DiagCodeExplain *diag_lookup_code_explain(const char *code) {
    size_t i;
    if (!code || code[0] == '\0')
        return NULL;
    for (i = 0; i < g_diag_code_table_count; i++) {
        if (diag_code_eq(g_diag_code_table[i].code, code))
            return &g_diag_code_table[i];
    }
    return NULL;
}

typedef struct DiagPalette {
    const char *kind_color;
    const char *caret_color;
} DiagPalette;

static int diag_kind_is_exact(const char *kind, const char *needle) {
    if (!kind || !needle)
        return 0;
    return strcmp(kind, needle) == 0 ? 1 : 0;
}

static int diag_kind_contains(const char *kind, const char *needle) {
    if (!kind || !needle || needle[0] == '\0')
        return 0;
    return strstr(kind, needle) != NULL ? 1 : 0;
}

static DiagPalette diag_palette_for_kind(const char *kind) {
    DiagPalette pal;
    pal.kind_color = diag_color_prefix("", "\x1b[1;37m");
    pal.caret_color = diag_color_prefix("", "\x1b[37m");
    if (!kind || kind[0] == '\0')
        return pal;
    if (diag_kind_contains(kind, "error")) {
        pal.kind_color = diag_color_prefix("", "\x1b[1;31m");
        pal.caret_color = diag_color_prefix("", "\x1b[31m");
        return pal;
    }
    if (diag_kind_contains(kind, "warning")) {
        pal.kind_color = diag_color_prefix("", "\x1b[1;33m");
        pal.caret_color = diag_color_prefix("", "\x1b[33m");
        return pal;
    }
    if (diag_kind_is_exact(kind, "info")) {
        pal.kind_color = diag_color_prefix("", "\x1b[1;36m");
        pal.caret_color = diag_color_prefix("", "\x1b[36m");
        return pal;
    }
    if (diag_kind_is_exact(kind, "note")) {
        pal.kind_color = diag_color_prefix("", "\x1b[1;34m");
        pal.caret_color = diag_color_prefix("", "\x1b[34m");
        return pal;
    }
    if (diag_kind_is_exact(kind, "help") || diag_kind_is_exact(kind, "hint")) {
        pal.kind_color = diag_color_prefix("", "\x1b[1;32m");
        pal.caret_color = diag_color_prefix("", "\x1b[32m");
        return pal;
    }
    return pal;
}

static void diag_print_header(const char *kind, const char *code, const char *msg,
                              const char *kind_color, const char *reset) {
    if (!msg)
        msg = "";
    if (!kind)
        kind = "";
    if (kind[0] == '\0') {
        fprintf(stderr, "%s\n", msg);
        return;
    }
    if (code && code[0] != '\0')
        fprintf(stderr, "%s%s[%s]%s: %s\n", kind_color, kind, code, reset, msg);
    else
        fprintf(stderr, "%s%s%s: %s\n", kind_color, kind, reset, msg);
}

static int diag_line_digits(int line) {
    int width = 1;
    while (line >= 10) {
        line /= 10;
        width++;
    }
    return width;
}

static int diag_extract_line(int line_no, const char **line_start_out, size_t *line_len_out) {
    const char *src = g_diag_ctx.source;
    size_t len = g_diag_ctx.source_len;
    int line = 1;
    size_t i;
    size_t start = 0;

    if (!src || !line_start_out || !line_len_out || line_no <= 0)
        return -1;
    for (i = 0; i < len; i++) {
        if (line == line_no)
            break;
        if (src[i] == '\n') {
            line++;
            start = i + 1;
        }
    }
    if (line != line_no)
        return -1;
    for (; i < len && src[i] != '\n' && src[i] != '\r'; i++) {
    }
    *line_start_out = src + start;
    *line_len_out = i - start;
    return 0;
}

void diag_set_file(const char *path, const char *source, size_t source_len) {
    g_diag_ctx.file_path = path;
    g_diag_ctx.source = source;
    g_diag_ctx.source_len = source_len;
    g_diag_ctx.use_color = diag_should_color();
}

void diag_push_file(DiagContextSnapshot *snapshot, const char *path, const char *source, size_t source_len) {
    if (snapshot) {
        snapshot->file_path = g_diag_ctx.file_path;
        snapshot->source = g_diag_ctx.source;
        snapshot->source_len = g_diag_ctx.source_len;
        snapshot->use_color = g_diag_ctx.use_color;
    }
    g_diag_ctx.file_path = path ? path : g_diag_ctx.file_path;
    g_diag_ctx.source = source ? source : g_diag_ctx.source;
    g_diag_ctx.source_len = source ? source_len : g_diag_ctx.source_len;
    g_diag_ctx.use_color = diag_should_color();
}

void diag_restore(const DiagContextSnapshot *snapshot) {
    if (!snapshot)
        return;
    g_diag_ctx.file_path = snapshot->file_path;
    g_diag_ctx.source = snapshot->source;
    g_diag_ctx.source_len = snapshot->source_len;
    g_diag_ctx.use_color = snapshot->use_color;
}

const char *diag_get_file(void) {
    return g_diag_ctx.file_path;
}

const char *diag_get_source(void) {
    return g_diag_ctx.source;
}

size_t diag_get_source_len(void) {
    return g_diag_ctx.source_len;
}

static void diag_report_json(const char *file, int line, int col,
                             const char *kind, const char *code, const char *msg);

void diag_report_with_code(const char *file, int line, int col, const char *kind, const char *code, const char *msg, const char *detail) {
    const char *actual_file = file ? file : g_diag_ctx.file_path;
    if (diag_json_enabled()) {
        diag_report_json(actual_file, line, col, kind, code, msg);
        return;
    }
    const char *line_start = NULL;
    size_t line_len = 0;
    int have_line = 0;
    int width = 1;
    int caret_col;
    int i;
    DiagPalette pal = diag_palette_for_kind(kind);
    const char *kind_color = pal.kind_color;
    const char *path_color = diag_color_prefix("", "\x1b[34m");
    const char *caret_color = pal.caret_color;
    const char *reset = diag_color_reset();

    if (line > 0 && diag_extract_line(line, &line_start, &line_len) == 0)
        have_line = 1;

    diag_print_header(kind, code, msg, kind_color, reset);

    if (actual_file && line > 0 && col > 0) {
        fprintf(stderr, "%s --> %s:%d:%d%s\n", path_color, actual_file, line, col, reset);
    } else if (actual_file && line > 0) {
        fprintf(stderr, "%s --> %s:%d%s\n", path_color, actual_file, line, reset);
    } else if (actual_file) {
        fprintf(stderr, "%s --> %s%s\n", path_color, actual_file, reset);
    } else if (line > 0 && col > 0) {
        fprintf(stderr, "%s --> %d:%d%s\n", path_color, line, col, reset);
    }

    if (!have_line || line <= 0 || col <= 0) {
        fflush(stderr);
        return;
    }

    width = diag_line_digits(line);
    fprintf(stderr, "%*s |\n", width, "");
    fprintf(stderr, "%d | %.*s\n", line, (int)line_len, line_start);
    fprintf(stderr, "%*s | ", width, "");

    caret_col = col > 1 ? col - 1 : 0;
    for (i = 0; i < caret_col; i++) {
        if ((size_t)i < line_len && line_start[i] == '\t')
            fputc('\t', stderr);
        else
            fputc(' ', stderr);
    }
    fprintf(stderr, "%s^%s", caret_color, reset);
    if (detail && detail[0] != '\0')
        fprintf(stderr, " %s", detail);
    fputc('\n', stderr);
    fflush(stderr);
}

void diag_report(const char *file, int line, int col, const char *kind, const char *msg, const char *detail) {
    diag_report_with_code(file, line, col, kind, NULL, msg, detail);
}

void diag_vreportf_with_code(const char *file, int line, int col, const char *kind, const char *code, const char *detail, const char *fmt, va_list ap) {
    char buf[1024];

    if (!fmt)
        fmt = "";
    (void)vsnprintf(buf, sizeof(buf), fmt, ap);
    diag_report_with_code(file, line, col, kind, code, buf, detail ? detail : buf);
}

void diag_vreportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt, va_list ap) {
    diag_vreportf_with_code(file, line, col, kind, NULL, detail, fmt, ap);
}

void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code, const char *detail, const char *fmt, ...) {
    va_list ap;

    va_start(ap, fmt);
    diag_vreportf_with_code(file, line, col, kind, code, detail, fmt, ap);
    va_end(ap);
}

void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt, ...) {
    va_list ap;

    va_start(ap, fmt);
    diag_vreportf_with_code(file, line, col, kind, NULL, detail, fmt, ap);
    va_end(ap);
}

int diag_code_is_known(const char *code) {
    return diag_lookup_code_explain(code) ? 1 : 0;
}

const char *diag_code_kind(const char *code) {
    const DiagCodeExplain *entry = diag_lookup_code_explain(code);
    return entry ? entry->kind : NULL;
}

const char *diag_code_summary(const char *code) {
    const DiagCodeExplain *entry = diag_lookup_code_explain(code);
    return entry ? entry->summary : NULL;
}

const char *diag_code_details(const char *code) {
    const DiagCodeExplain *entry = diag_lookup_code_explain(code);
    return entry ? entry->details : NULL;
}

void diag_print_known_codes(FILE *out) {
    size_t i;
    if (!out)
        out = stdout;
    for (i = 0; i < g_diag_code_table_count; i++)
        fprintf(out, "%s%s", i == 0 ? "" : ", ", g_diag_code_table[i].code);
    fputc('\n', out);
}

void diag_print_code_explain(FILE *out, const char *code) {
    const DiagCodeExplain *entry;
    if (!out)
        out = stdout;
    entry = diag_lookup_code_explain(code);
    if (!entry) {
        fprintf(out, "Unknown diagnostic code: %s\n", code ? code : "(null)");
        fprintf(out, "Known codes: ");
        diag_print_known_codes(out);
        return;
    }
    fprintf(out, "%s\n", entry->code);
    fprintf(out, "Kind: %s\n", entry->kind);
    fprintf(out, "Summary: %s\n", entry->summary);
    fprintf(out, "Details: %s\n", entry->details);
}

/**
 * 有界 Levenshtein 编辑距离（大小写不敏感）。
 * 仅用于诊断码建议（码长度很短，O(n*m) 可接受；仅在 --explain 未知码冷路径调用）。
 * max_dist 为上界：一旦当前行最小值超过 max_dist 即可提前判定超过（这里为简洁用完整 DP，码短无妨）。
 * 返回将 a 变换为 b 的最小单字符编辑（插入/删除/替换）次数。
 */
static int diag_levenshtein_ci(const char *a, const char *b) {
    size_t la = a ? strlen(a) : 0;
    size_t lb = b ? strlen(b) : 0;
    size_t i, j;
    int prev[64];
    int cur[64];

    if (!a || !b)
        return 999;
    if (la >= 64 || lb >= 64)
        return 999;
    if (la == 0)
        return (int)lb;
    if (lb == 0)
        return (int)la;

    for (j = 0; j <= lb; j++)
        prev[j] = (int)j;
    for (i = 1; i <= la; i++) {
        cur[0] = (int)i;
        for (j = 1; j <= lb; j++) {
            unsigned char ca = (unsigned char)a[i - 1];
            unsigned char cb = (unsigned char)b[j - 1];
            int cost;
            if (ca >= 'a' && ca <= 'z')
                ca = (unsigned char)(ca - 'a' + 'A');
            if (cb >= 'a' && cb <= 'z')
                cb = (unsigned char)(cb - 'a' + 'A');
            cost = (ca == cb) ? 0 : 1;
            {
                int del = prev[j] + 1;      /* 删除 */
                int ins = cur[j - 1] + 1;   /* 插入 */
                int sub = prev[j - 1] + cost; /* 替换 */
                int m = del < ins ? del : ins;
                if (sub < m)
                    m = sub;
                cur[j] = m;
            }
        }
        memcpy(prev, cur, (lb + 1) * sizeof(int));
    }
    return prev[lb];
}

/**
 * 为未知诊断码找一个最接近的已知码（did-you-mean 建议）。
 *
 * 参数：
 *   out     - 输出缓冲区，写入建议码（NUL 结尾）；可为 NULL（仅查询是否存在建议）。
 *   out_cap - out 容量（字节）。
 *
 * 返回值：找到合理建议时返回 out 指针；无建议（无已知码或距离过大）时返回 NULL，out 不改写。
 *
 * 阈值说明：诊断码长度通常 3~6 字符，距离 <=3 视为「明显拼写偏差」；同时要求建议码
 * 与查询等长或仅差 1，避免把任意短查询都建议成首个已知码。
 */
const char *diag_code_suggest(const char *code, char *out, size_t out_cap) {
    size_t i;
    int best_dist = 999;
    const char *best_code = NULL;
    int code_len;

    if (!code || !g_diag_code_table_count)
        return NULL;
    code_len = (int)strlen(code);
    if (code_len <= 0)
        return NULL;

    for (i = 0; i < g_diag_code_table_count; i++) {
        const char *cand = g_diag_code_table[i].code;
        int d = diag_levenshtein_ci(code, cand);
        if (d < best_dist) {
            best_dist = d;
            best_code = cand;
        }
    }
    if (!best_code)
        return NULL;
    /* 距离阈值：码短，<=3 视为拼写偏差；并要求不超过「查询长度 + 1」以免误建议。 */
    if (best_dist > 3 || best_dist > code_len + 1)
        return NULL;
    if (out && out_cap > 0) {
        size_t n = strlen(best_code);
        if (n >= out_cap)
            n = out_cap - 1;
        memcpy(out, best_code, n);
        out[n] = '\0';
    }
    return out ? out : best_code;
}

/**
 * 打印完整诊断码表（用户面：`shux explain --list` / `shux --explain --list`）。
 * 格式：列对齐的 CODE / KIND / Summary，便于人工浏览全部已知码。
 */
void diag_print_code_table(FILE *out) {
    size_t i;
    if (!out)
        out = stdout;
    fprintf(out, "%-8s %-18s %s\n", "CODE", "KIND", "SUMMARY");
    fprintf(out, "%-8s %-18s %s\n", "----", "----", "-------");
    for (i = 0; i < g_diag_code_table_count; i++) {
        const DiagCodeExplain *e = &g_diag_code_table[i];
        fprintf(out, "%-8s %-18s %s\n", e->code, e->kind, e->summary);
    }
}

/**
 * JSON 诊断输出模式开关。
 * enable 非 0 时强制开启；0 时强制关闭（覆盖 SHUX_DIAG_JSON 环境变量）。
 * 仅供 driver 在解析 --diag-json 等 CLI 标志后调用；冷路径，零性能影响。
 */
void diag_set_json_mode(int enable) {
    g_diag_json = enable ? 1 : 0;
}

/**
 * 当前是否启用 JSON 诊断输出。首次调用时按 SHUX_DIAG_JSON 环境变量惰性决定，
 * 之后缓存；diag_set_json_mode 的显式设置优先于环境变量。
 */
int diag_json_enabled(void) {
    if (g_diag_json == -2) {
        const char *e = getenv("SHUX_DIAG_JSON");
        g_diag_json = (e && e[0] && e[0] != '0') ? 1 : 0;
    }
    return g_diag_json == 1 ? 1 : 0;
}

/**
 * 将单个字符串以 JSON 字符串字面量形式写入 out（含两端引号）。
 * 转义 "、\ 与控制字符（\\uXXXX）；NULL 视作空串。仅在诊断冷路径调用。
 */
static void diag_json_write_str(FILE *out, const char *s) {
    const unsigned char *p = (const unsigned char *)(s ? s : "");
    fputc('"', out);
    for (; *p; p++) {
        unsigned char c = *p;
        switch (c) {
        case '"':  fputs("\\\"", out); break;
        case '\\': fputs("\\\\", out); break;
        case '\b': fputs("\\b", out); break;
        case '\f': fputs("\\f", out); break;
        case '\n': fputs("\\n", out); break;
        case '\r': fputs("\\r", out); break;
        case '\t': fputs("\\t", out); break;
        default:
            if (c < 0x20)
                fprintf(out, "\\u%04x", c);
            else
                fputc((int)c, out);
        }
    }
    fputc('"', out);
}

/**
 * 由诊断 kind 推导 JSON severity 字段。
 * 含 "warning" → warning；精确 "info"/"note"/"help"/"hint" → 同名；其余（含 error/parse error/...）→ error。
 */
static const char *diag_json_severity(const char *kind) {
    if (!kind || !kind[0])
        return "error";
    if (strstr(kind, "warning"))
        return "warning";
    if (strcmp(kind, "info") == 0)
        return "info";
    if (strcmp(kind, "note") == 0)
        return "note";
    if (strcmp(kind, "help") == 0 || strcmp(kind, "hint") == 0)
        return "help";
    return "error";
}

/**
 * 以 NDJSON（每条诊断一行 JSON 对象）形式输出到 stderr，供 CI / 工具消费。
 * 字段：severity、code（可能为 null）、file（可能为 null）、line、col、message。
 * line/col 为 0 时仍输出（语义：未知）；调用方按需忽略。
 */
static void diag_report_json(const char *file, int line, int col,
                             const char *kind, const char *code, const char *msg) {
    const char *sev = diag_json_severity(kind);
    fputs("{\"severity\":", stderr);
    diag_json_write_str(stderr, sev);
    fputs(",\"code\":", stderr);
    if (code && code[0])
        diag_json_write_str(stderr, code);
    else
        fputs("null", stderr);
    fputs(",\"file\":", stderr);
    if (file && file[0])
        diag_json_write_str(stderr, file);
    else
        fputs("null", stderr);
    fprintf(stderr, ",\"line\":%d,\"col\":%d,\"message\":", line, col);
    diag_json_write_str(stderr, msg ? msg : "");
    fputs("}\n", stderr);
    fflush(stderr);
}
