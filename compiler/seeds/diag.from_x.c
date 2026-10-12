/* Generated from src/diag.x (G-02f-82 +) (G-02f-30/96/97/98 true .x + C tail; G-02f-74/82 diag gates).
 * G-02f-335～347：PREFER_X_O hybrid 时 pure thin 由 src/diag_thin.x→-E；rest 用
 *   XLANG_L2_DIAG_THIN_FROM_X（省略 public；f-347 push apply_impl / restore 全 thin snap）。
 * G-02f-181: P0-1 close-out — code table + reportf/vreportf 🔒 (priority doc §4.3).
 * G-02f-130 true .x pure helpers.
 * G-02f-116 true .x pure helpers.
 * G-02f-109 helper gates.
 * Regen: ./xlang-c -E -L .. src/diag.x > /tmp/diag.c
 *         merge diag_report from .x; keep code table / va_list / JSON C tail.
 * .x covers: report/human/json/print/code-query/levenshtein/…; C: table data + va_list.
 * Cap residual 10.7.2／9.5.3: reportf formats via xlang_vsnprintf (no libc vsnprintf).
 * Cap residual 10.7.1: Cap va face via xlang_va_cap (no <stdarg.h>).
 */
#include "diag.h"
#ifdef XLANG_L2_DIAG_THIN_FROM_X
int diag_ctx_get_use_color(void);
int diag_code_table_has(const char *code);
int diag_json_get_state(void);
void diag_json_set_state(int v);
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <xlang_fmt_cap.h> /* Cap residual 10.7.2／9.5.3: reportf → xlang_vsnprintf */
/* Cap residual 9.7.1: diag micro-ABI streams are opaque fd handles. */
#include "xlang_driver_stream_cap.h"

/* ---- 9.7.1 local write helpers over the fd-handle face (PLATFORM: SHARED) ----
 * All diag print sites go through these; formatting uses the Cap fmt authority.
 * Byte-exact replacements for the former fputs/fputc/fprintf/fflush calls. */

#ifndef XLANG_L2_DIAG_THIN_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_L2_DIAG_THIN_FROM_X removed */
#endif

#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif

#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif

#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif

/** Std stream handles for direct stderr/stdout sites. Cold path only. */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif

/* wave233 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — product hybrid diag rest uses same face as diag.x full path. */
extern char *link_abi_getenv(const char *name);

#if !defined(_WIN32)
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            include/poll.h and include/sys/uio.h shims also available.
 *            macOS/Linux delegate to system headers via #include_next.
 *            Historical #ifndef _WIN32 guard removed for safe includes. */
#include <unistd.h>
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

/* JSON 诊断模式：-2 = 尚未决定（按 XLANG_DIAG_JSON 环境变量），1 = 开启，0 = 关闭。 */
static int g_diag_json = -2;

#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Code-table rows live in src/diag_thin.x. PLATFORM: SHARED. */
extern size_t diag_code_table_len(void);
extern const char *diag_code_table_code_at(size_t i);
extern const char *diag_code_table_kind_at(size_t i);
extern const char *diag_code_table_summary_at(size_t i);
extern const char *diag_entry_code(const char *code);
extern const char *diag_entry_kind(const char *code);
extern const char *diag_entry_summary(const char *code);
extern const char *diag_entry_details(const char *code);
#endif

/* G-02f-153：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-338：hybrid 时 public 由 thin；本文件冷路径保留 C 体 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#if defined(_WIN32)
#else
/* JSON report walk lives in src/diag_thin.x. PLATFORM: SHARED. */
#endif
#else
/* Color decision lives in src/diag_thin.x. PLATFORM: POSIX. */
extern int diag_should_color(void);
#endif


/** 供 .x 读 g_diag_ctx.use_color（G-02f-154）。 */
/* G-02f-386：实现体始终 seed；public PREFER 时 thin forward */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif

/* G-02f-154：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-335：hybrid 时由 diag_thin.x 提供 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
extern const char *diag_color_prefix(const char *plain, const char *color);
#endif

/* G-02f-154：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-338：hybrid 时 public 由 thin；本文件冷路径保留 C 体 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* ANSI reset choice lives in src/diag_thin.x. PLATFORM: SHARED. */
extern const char *diag_color_reset(void);
#endif
/* G-02f-116：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Case-insensitive code compare lives in src/diag_thin.x. PLATFORM: SHARED. */
extern int diag_code_eq(const char *lhs, const char *rhs);
#endif



#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif

typedef struct DiagPalette {
    const char *kind_color;
    const char *caret_color;
} DiagPalette;
/* G-02f-116：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-335：hybrid 时由 diag_thin.x 提供 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
extern int diag_kind_is_exact(const char *kind, const char *needle);
#endif

/* G-02f-130：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-335：hybrid 时由 diag_thin.x 提供 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
extern int diag_kind_contains(const char *kind, const char *needle);
#endif


#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif

/** 供 .x stdio 冷路径（G-02f-156）。9.7.1: stream params are opaque fd handles. */
/* G-02f-421：stderr 句柄在 thin；冷路径仍走 diag_h_stderr。 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif
/* G-02f-415：实现体始终 seed（stdio/fmt）；public PREFER 时 thin pure forward */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* One-byte write lives in src/diag_thin.x. PLATFORM: SHARED. */
extern int diag_io_fputc(uint8_t *o, int c);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* String write lives in src/diag_thin.x. PLATFORM: SHARED. */
extern int diag_io_fputs(const char *s, uint8_t *o);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Unicode escape lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fputs_u04x(uint8_t *o, unsigned c);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Flush is a no-op and lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fflush(uint8_t *o);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* JSON line/col fields live in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fprint_line_col(uint8_t *o, int line, int col);
#endif
/** 供 .x report_human 位置/gutter 冷路径（G-02f-159）。 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Location line with file, line, and column lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fprint_loc_file_line_col(uint8_t *o, const char *pc, const char *file, int line, int col, const char *rs);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Location line with file and line lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fprint_loc_file_line(uint8_t *o, const char *pc, const char *file, int line, const char *rs);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Location line with only a file lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fprint_loc_file(uint8_t *o, const char *pc, const char *file, const char *rs);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Location line with line and column lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fprint_loc_line_col(uint8_t *o, const char *pc, int line, int col, const char *rs);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Blank gutter line lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fprint_gutter_blank(uint8_t *o, int width);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Source gutter line lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fprint_src_line(uint8_t *o, int line, const char *start, int len);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Caret gutter bar lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fprint_gutter_bar(uint8_t *o, int width);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Caret mark line lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fprint_caret_mark(uint8_t *o, const char *cc, const char *rs, const char *detail);
#endif

/* G-02f-156：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* Hybrid: the header walk is src/diag_thin.x. Cold seed keeps this C body. */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Header walk lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_print_header(const char *kind, const char *code, const char *msg,
                              const char *kind_color, const char *reset);
#endif
/* G-02f-116：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-335：hybrid 时由 diag_thin.x 提供 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
extern int diag_line_digits(int line);
#endif

/* G-02f-154：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-338：hybrid 时 public 由 thin；本文件出 _impl */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Walk lives in src/diag_thin.x. PLATFORM: SHARED. */
extern int diag_extract_line(int line_no, const char **line_start_out, size_t *line_len_out);
#endif


/** 供 .x 写 g_diag_ctx（G-02f-156）。 */
/* G-02f-420：实现体始终 seed；public PREFER 时 thin pure forward */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Context write lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_ctx_set_all(const char *path, const char *source, size_t source_len, int use_color);
#endif

/* G-02f-156：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-336：hybrid 时由 diag_thin.x 提供 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
extern void diag_set_file(const char *path, const char *source, size_t source_len);
#endif

/* G-02f-156：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-337/347：hybrid 时 push = thin snap_save + apply_impl；restore = thin snap_load */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Push walk lives in src/diag_thin.x. Context storage stays here. PLATFORM: SHARED. */
#endif

/* G-02f-156：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-347：hybrid 时 restore 全由 thin snap_load + diag_ctx_set_all */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif


/** 供 .x 读 g_diag_ctx 字段（G-02f-155）。 */
/* G-02f-420：实现体始终 seed；public PREFER 时 thin pure forward */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* File-path read lives in src/diag_thin.x. PLATFORM: SHARED. */
extern const char *diag_ctx_get_file(void);
#endif
/* Address of the one diagnostic context record. PLATFORM: SHARED. */
uint8_t *diag_ctx_base(void) {
    return (uint8_t *)&g_diag_ctx;
}
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Source-pointer read lives in src/diag_thin.x. PLATFORM: SHARED. */
extern const char *diag_ctx_get_source(void);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Source-length read lives in src/diag_thin.x. PLATFORM: SHARED. */
extern size_t diag_ctx_get_source_len(void);
#endif

/* G-02f-155：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-336：hybrid 时由 diag_thin.x 提供 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
extern const char *diag_get_file(void);
extern const char *diag_get_source(void);
extern size_t diag_get_source_len(void);
#endif

void diag_report_json(const char *file, int line, int col,
                             const char *kind, const char *code, const char *msg);

/* G-02f-159：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-338：hybrid 时 public 由 thin；本文件出 _impl */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#ifdef XLANG_L2_DIAG_THIN_FROM_X
#else
/* JSON report walk lives in src/diag_thin.x. PLATFORM: SHARED. */
#endif
#else
/* Human report walk lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_report_human(const char *file, int line, int col, const char *kind, const char *code, const char *msg, const char *detail);
#endif

/* G-02f-158：逻辑源 .x（JSON 分流真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-338：hybrid 时 public 由 thin；本文件出 _impl（可再调 thin public 或 _impl） */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* JSON / human dispatch lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_report_with_code(const char *file, int line, int col, const char *kind, const char *code, const char *msg, const char *detail);
#endif

/* G-02f-158：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-336：hybrid 时由 diag_thin.x 提供 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
extern void diag_report(const char *file, int line, int col, const char *kind, const char *msg, const char *detail);
#endif

void diag_vreportf_with_code(const char *file, int line, int col, const char *kind, const char *code, const char *detail, const char *fmt, xlang_va_list ap) {
    char buf[1024];

    if (!fmt)
        fmt = "";
    /* PLATFORM: SHARED — Cap fmt (10.7.2) + Cap va (10.7.1); no libc stdarg/vsnprintf. */
    (void)xlang_vsnprintf(buf, sizeof(buf), fmt, ap);
    diag_report_with_code(file, line, col, kind, code, buf, detail ? detail : buf);
}

void diag_vreportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt, xlang_va_list ap) {
    diag_vreportf_with_code(file, line, col, kind, NULL, detail, fmt, ap);
}



void diag_reportf_with_code(const char *file, int line, int col, const char *kind, const char *code, const char *detail, const char *fmt, ...) {
    xlang_va_list ap;

    xlang_va_start(ap, fmt);
    diag_vreportf_with_code(file, line, col, kind, code, detail, fmt, ap);
    xlang_va_end(ap);
}





void diag_reportf(const char *file, int line, int col, const char *kind, const char *detail, const char *fmt, ...) {
    xlang_va_list ap;

    xlang_va_start(ap, fmt);
    diag_vreportf_with_code(file, line, col, kind, NULL, detail, fmt, ap);
    xlang_va_end(ap);
}



#ifndef XLANG_L2_DIAG_THIN_FROM_X
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* JSON report walk lives in src/diag_thin.x. PLATFORM: SHARED. */
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif
/* G-02f-415：code table io → seed impl + thin pure forward (9.7.1 fd handles) */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Unknown-code line lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fprint_unknown_code(uint8_t *out, const char *code);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Code-table header lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fprint_code_table_hdr(uint8_t *out);
#endif
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Code-table row lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_io_fprint_code_table_row(uint8_t *out, const char *code, const char *kind, const char *summary);
#endif

/* G-02f-157：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-336：hybrid 时由 diag_thin.x 提供 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
extern const char *diag_code_kind(const char *code);
extern const char *diag_code_summary(const char *code);
extern const char *diag_code_details(const char *code);
#endif

/* G-02f-157：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-338：hybrid 时 public 由 thin；本文件冷路径保留 C 体 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Comma-separated known-code list lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_print_known_codes(uint8_t *out);
#endif

/* G-02f-157：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-338：hybrid 时 public 由 thin；本文件冷路径保留 C 体 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Explain walk lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_print_code_explain(uint8_t *out, const char *code);
#endif


/**
 * 有界 Levenshtein 编辑距离（大小写不敏感）。
 * 仅用于诊断码建议（码长度很短，O(n*m) 可接受；仅在 --explain 未知码冷路径调用）。
 * max_dist 为上界：一旦当前行最小值超过 max_dist 即可提前判定超过（这里为简洁用完整 DP，码短无妨）。
 * 返回将 a 变换为 b 的最小单字符编辑（插入/删除/替换）次数。
 * G-02f-98：export gate.
 */
/* G-02f-152 / G-02f-158：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Case-insensitive edit distance lives in src/diag_thin.x. PLATFORM: SHARED. */
extern int diag_levenshtein_ci(const char *a, const char *b);
#endif

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
/* G-02f-158：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#ifdef XLANG_L2_DIAG_THIN_FROM_X
#else
/* JSON report walk lives in src/diag_thin.x. PLATFORM: SHARED. */
#endif
#ifdef XLANG_L2_DIAG_THIN_FROM_X
#else
    for (i = 0; i < g_diag_code_table_count; i++) {
        const char *cand = g_diag_code_table[i].code;
#endif
#else
/* Did-you-mean walk lives in src/diag_thin.x. PLATFORM: SHARED. */
extern const char *diag_code_suggest(const char *code, char *out, size_t out_cap);
#endif

/**
 * 打印完整诊断码表（用户面：`xlang explain --list` / `xlang --explain --list`）。
 * 格式：列对齐的 CODE / KIND / Summary，便于人工浏览全部已知码。
 */
/* G-02f-157：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-338：hybrid 时 public 由 thin；本文件冷路径保留 C 体 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* Aligned code-table walk lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_print_code_table(uint8_t *out);
#endif


/**
 * JSON 诊断输出模式开关。
 * enable 非 0 时强制开启；0 时强制关闭（覆盖 XLANG_DIAG_JSON 环境变量）。
 * 仅供 driver 在解析 --diag-json 等 CLI 标志后调用；冷路径，零性能影响。
 */
/* G-02f-153：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-338：hybrid 时 public 由 thin；本文件冷路径保留 C 体 */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* JSON mode switch lives in src/diag_thin.x. Cache stays here. PLATFORM: SHARED. */
extern void diag_set_json_mode(int enable);
#endif

/** 供 .x 读写 g_diag_json 状态（-2=未决）。 */
/* G-02f-386：get/set 在 thin；地址由 diag_json_base 给出。 */
/* Address of the JSON-mode cache. Values include -2. PLATFORM: SHARED. */
uint8_t *diag_json_base(void) {
    return (uint8_t *)&g_diag_json;
}

#ifndef XLANG_L2_DIAG_THIN_FROM_X
#endif

/**
 * 当前是否启用 JSON 诊断输出。首次调用时按 XLANG_DIAG_JSON 环境变量惰性决定，
 * 之后缓存；diag_set_json_mode 的显式设置优先于环境变量。
 */
/* G-02f-153：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-338：hybrid 时 public 由 thin；本文件出 _impl */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* JSON enable cache lives in src/diag_thin.x. PLATFORM: SHARED. */
extern int diag_json_enabled(void);
#endif


/**
 * 将单个字符串以 JSON 字符串字面量形式写入 out（含两端引号）。
 * 转义 "、\ 与控制字符（\\uXXXX）；NULL 视作空串。仅在诊断冷路径调用。
 */
/* G-02f-156：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* JSON string walk lives in src/diag_thin.x. PLATFORM: SHARED. */
extern void diag_json_write_str(uint8_t *out, const char *s);
#endif


/**
 * 由诊断 kind 推导 JSON severity 字段。
 * 含 "warning" → warning；精确 "info"/"note"/"help"/"hint" → 同名；其余（含 error/parse error/...）→ error。
 */
/* G-02f-124：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* JSON severity walk lives in src/diag_thin.x. PLATFORM: SHARED. */
extern const char *diag_json_severity(const char *kind);
#endif


/**
 * 以 NDJSON（每条诊断一行 JSON 对象）形式输出到 stderr，供 CI / 工具消费。
 * 字段：severity、code（可能为 null）、file（可能为 null）、line、col、message。
 * line/col 为 0 时仍输出（语义：未知）；调用方按需忽略。
 */
/* G-02f-156：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef XLANG_L2_DIAG_THIN_FROM_X
#else
/* JSON report walk lives in src/diag_thin.x. PLATFORM: SHARED. */
#endif


