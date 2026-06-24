/**
 * runtime_fmt_any.h — std.fmt / std.debug 任意类型 JSON 调试输出辅助（inline，随生成 C 一并编译）
 *
 * 由 codegen 在 print/println(复合类型) 时调用；不依赖 std.json 链接。
 */
#ifndef RUNTIME_FMT_ANY_H
#define RUNTIME_FMT_ANY_H

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <math.h>
#include <inttypes.h>

/** 将单字节以 JSON 字符串规则写入 stream（含 \\ \" \\n \\r \\t 与 \\xNN）。 */
static inline void shux_fmt_json_putc(FILE *stream, unsigned char c) {
    if (!stream) return;
    if (c == '\\' || c == '"') {
        fputc('\\', stream);
        fputc((int)c, stream);
    } else if (c == '\n') {
        fputs("\\n", stream);
    } else if (c == '\r') {
        fputs("\\r", stream);
    } else if (c == '\t') {
        fputs("\\t", stream);
    } else if (c < 32) {
        fprintf(stream, "\\x%02x", (unsigned)c);
    } else {
        fputc((int)c, stream);
    }
}

/** 将 C 字符串 s（最多 max_len 字节）格式化为 JSON 字符串字面量内容（不含外围引号）。 */
static inline void shux_fmt_json_cstr_body(FILE *stream, const char *s, size_t max_len) {
    size_t i;
    if (!stream) return;
    if (!s) {
        fputs("null", stream);
        return;
    }
    for (i = 0; i < max_len && s[i] != '\0'; i++)
        shux_fmt_json_putc(stream, (unsigned char)s[i]);
}

/** 将字节序列格式化为 JSON 字符串（u8 切片/数组可读输出）。 */
static inline void shux_fmt_json_bytes_as_string(FILE *stream, const uint8_t *data, size_t len) {
    size_t i;
    if (!stream) return;
    fputc('"', stream);
    if (data) {
        for (i = 0; i < len; i++)
            shux_fmt_json_putc(stream, data[i]);
    }
    fputc('"', stream);
}

/** 将指针格式化为 JSON 字符串 "0x..." 或 null。 */
static inline void shux_fmt_json_ptr(FILE *stream, const void *p) {
    if (!stream) return;
    if (!p) {
        fputs("null", stream);
        return;
    }
    fputc('"', stream);
    fprintf(stream, "0x%zx", (size_t)(uintptr_t)p);
    fputc('"', stream);
}

/** f64 转 JSON number（NaN/Inf 用字符串形式，合法 JSON 扩展）。 */
static inline void shux_fmt_json_f64(FILE *stream, double v) {
    if (!stream) return;
    if (isnan(v)) {
        fputs("\"NaN\"", stream);
    } else if (isinf(v)) {
        if (v < 0.0)
            fputs("\"-Infinity\"", stream);
        else
            fputs("\"Infinity\"", stream);
    } else {
        fprintf(stream, "%.17g", v);
    }
}

/** i32 固定数组或切片：JSON [1,2,3]。 */
static inline void shux_fmt_json_i32_seq(FILE *stream, const int32_t *data, size_t len) {
    size_t i;
    if (!stream) return;
    fputc('[', stream);
    for (i = 0; i < len; i++) {
        if (i) fputc(',', stream);
        fprintf(stream, "%" PRId32, data[i]);
    }
    fputc(']', stream);
}

/** u32 序列 JSON 数组。 */
static inline void shux_fmt_json_u32_seq(FILE *stream, const uint32_t *data, size_t len) {
    size_t i;
    if (!stream) return;
    fputc('[', stream);
    for (i = 0; i < len; i++) {
        if (i) fputc(',', stream);
        fprintf(stream, "%" PRIu32, data[i]);
    }
    fputc(']', stream);
}

/** i64 序列 JSON 数组。 */
static inline void shux_fmt_json_i64_seq(FILE *stream, const int64_t *data, size_t len) {
    size_t i;
    if (!stream) return;
    fputc('[', stream);
    for (i = 0; i < len; i++) {
        if (i) fputc(',', stream);
        fprintf(stream, "%" PRId64, data[i]);
    }
    fputc(']', stream);
}

/** u64 序列 JSON 数组。 */
static inline void shux_fmt_json_u64_seq(FILE *stream, const uint64_t *data, size_t len) {
    size_t i;
    if (!stream) return;
    fputc('[', stream);
    for (i = 0; i < len; i++) {
        if (i) fputc(',', stream);
        fprintf(stream, "%" PRIu64, data[i]);
    }
    fputc(']', stream);
}

/** f64 序列 JSON 数组。 */
static inline void shux_fmt_json_f64_seq(FILE *stream, const double *data, size_t len) {
    size_t i;
    if (!stream) return;
    fputc('[', stream);
    for (i = 0; i < len; i++) {
        if (i) fputc(',', stream);
        shux_fmt_json_f64(stream, data[i]);
    }
    fputc(']', stream);
}

/** bool 序列 JSON 数组（true/false）。 */
static inline void shux_fmt_json_bool_seq(FILE *stream, const int *data, size_t len) {
    size_t i;
    if (!stream) return;
    fputc('[', stream);
    for (i = 0; i < len; i++) {
        if (i) fputc(',', stream);
        fputs(data[i] ? "true" : "false", stream);
    }
    fputc(']', stream);
}

/** u8 序列：优先 JSON 字符串，否则 [1,2,3] 数字数组。 */
static inline void shux_fmt_json_u8_seq(FILE *stream, const uint8_t *data, size_t len) {
    size_t i;
    int all_text = 1;
    if (!stream) return;
    if (data && len > 0) {
        for (i = 0; i < len; i++) {
            unsigned char c = data[i];
            if (c == 0) { len = i; break; }
            if (c < 32 && c != '\n' && c != '\r' && c != '\t') { all_text = 0; break; }
        }
    }
    if (all_text && data) {
        shux_fmt_json_bytes_as_string(stream, data, len);
        return;
    }
    fputc('[', stream);
    for (i = 0; i < len; i++) {
        if (i) fputc(',', stream);
        fprintf(stream, "%u", (unsigned)data[i]);
    }
    fputc(']', stream);
}

/** 未知布局类型：按字节十六进制数组输出（开发者可读的 fallback）。 */
static inline void shux_fmt_json_mem_bytes(FILE *stream, const unsigned char *p, size_t n) {
    size_t i;
    if (!stream) return;
    fputc('[', stream);
    for (i = 0; i < n; i++) {
        if (i) fputc(',', stream);
        fprintf(stream, "%u", (unsigned)p[i]);
    }
    fputc(']', stream);
}

#endif /* RUNTIME_FMT_ANY_H */
