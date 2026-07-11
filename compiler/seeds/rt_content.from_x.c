/* seeds/rt_content.from_x.c — G-02f-261/306 P2 R2 content_has_* + path wrappers
 * Logic source: src/runtime/rt_content.x
 * Hybrid: SHUX_RT_CONTENT_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * f-261: content_has_generic / compound_assign（纯串）
 * f-306: driver_source_has_*（path → peek → content_has）
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>

extern int driver_peek_source_file(const char *path, char *content, size_t cap);

/** 检测内存中的源码 content[0..n-1] 是否含泛型或 trait 语法（.x 流水线不支持，需走 C 路径）。 */
/* G-02f-126：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RT_CONTENT_FROM_X
int content_has_generic_syntax(const char *content, size_t n) {
    static const char *generic_type_tokens[] = {
        "<i8>", "<i16>", "<i32>", "<i64>", "<u8>", "<u16>", "<u32>", "<u64>", "<f32>", "<f64>", "<bool>",
    };
    size_t ti;
    if (!content || n == 0) return 0;
    const char *end = content + n;
    const char *p = content;
    /* 泛型：<T>、<i32> 等；勿将 T[]<region_label>（M-3/M-5 域标签）误判为泛型。 */
    while ((p = (const char *)memchr(p, '<', (size_t)(end - p))) != NULL) {
        if (p + 1 >= end) break;
        if (p > content && p[-1] == ']') {
            p++;
            continue;
        }
        if (p[1] == 'T' && (p + 2 >= end || p[2] == '>' || p[2] == ','))
            return 1;
        for (ti = 0; ti < sizeof(generic_type_tokens) / sizeof(generic_type_tokens[0]); ti++) {
            size_t tok_len = strlen(generic_type_tokens[ti]);
            if ((size_t)(end - p) >= tok_len && memcmp(p, generic_type_tokens[ti], tok_len) == 0)
                return 1;
        }
        p++;
    }
    /*
     * trait / 独立 impl 关键字：.x 流水线不解析，走 C 路径。
     * impl 须匹配完整词元 " impl "（前后空白）；勿用 memcmp(..., " impl ", 5)，否则
     * `implicit_*` 等标识符在首字符前有空格时会被误判为泛型，进而关掉 asm 并误走「无 main 链可执行」路径见 driver_run_compiler_full。
     */
    if (n >= 6) {
        size_t i;
        for (i = 0; i <= n - 6; i++)
            if (memcmp(content + i, "trait ", 6) == 0) return 1;
        for (i = 0; i <= n - 6; i++)
            if (memcmp(content + i, " impl ", 6) == 0) return 1;
    }
    return 0;
}
#else
int content_has_generic_syntax(const char *content, size_t n);
#endif




/** 检测 path 指向的源码文件是否含泛型语法（如 <T> 或 <i32>），有则返回 1 否则 0；供 .x driver 在 run_compiler_x_path 中决定是否走 C 流水线。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */

/** 检测内存源码是否含复合赋值（+= 等）；.x 解析器未覆盖时须走 C 流水线（run-compound-assign 等）。
 * 跳过 //、块注释与双引号字符串，避免注释/字面量中的 token 误触发 asm→C 降级。 */
/* G-02f-126：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
#ifndef SHUX_RT_CONTENT_FROM_X
int content_has_compound_assign_syntax(const char *content, size_t n) {
    if (!content || n < 3)
        return 0;
    /* 长 token 优先，避免 `<<=` 被 `+=` 子串误伤。 */
    static const char *tokens[] = {"<<=", ">>=", "+=", "-=", "*=", "/=", "%=", "&=", "|=", "^="};
    size_t pos = 0;
    while (pos < n) {
        if (pos + 1 < n && content[pos] == '/' && content[pos + 1] == '/') {
            pos += 2;
            while (pos < n && content[pos] != '\n')
                pos++;
            continue;
        }
        if (pos + 1 < n && content[pos] == '/' && content[pos + 1] == '*') {
            pos += 2;
            while (pos + 1 < n && !(content[pos] == '*' && content[pos + 1] == '/'))
                pos++;
            pos += (pos + 1 < n) ? 2 : 0;
            continue;
        }
        if (content[pos] == '"') {
            pos++;
            while (pos < n && content[pos] != '"') {
                if (content[pos] == '\\' && pos + 1 < n)
                    pos += 2;
                else
                    pos++;
            }
            if (pos < n)
                pos++;
            continue;
        }
        for (size_t i = 0; i < sizeof(tokens) / sizeof(tokens[0]); i++) {
            size_t tlen = strlen(tokens[i]);
            if (pos + tlen <= n && memcmp(content + pos, tokens[i], tlen) == 0)
                return 1;
        }
        pos++;
    }
    return 0;
}
#else
int content_has_compound_assign_syntax(const char *content, size_t n);
#endif

/** 检测 path 指向的源码是否含泛型语法；peek 后转 content_has_generic_syntax。 */
int driver_source_has_generic_syntax(const uint8_t *path, int path_len) {
    char content[65536];
    int rn;
    size_t n;

    if (!path || path_len <= 0 || path_len >= 512)
        return 0;
    {
        char buf[512];
        memcpy(buf, path, (size_t)path_len);
        buf[path_len] = '\0';
        rn = driver_peek_source_file(buf, content, sizeof(content));
    }
    if (rn < 0)
        return 0;
    n = (size_t)rn;
    return content_has_generic_syntax(content, n);
}

/** 检测 path 指向的源码是否含复合赋值；peek 后转 content_has_compound_assign_syntax。 */
int driver_source_has_compound_assign_syntax(const uint8_t *path, int path_len) {
    char content[65536];
    int rn;
    size_t n;

    if (!path || path_len <= 0 || path_len >= 512)
        return 0;
    {
        char buf[512];
        memcpy(buf, path, (size_t)path_len);
        buf[path_len] = '\0';
        rn = driver_peek_source_file(buf, content, sizeof(content));
    }
    if (rn < 0)
        return 0;
    n = (size_t)rn;
    if (n < sizeof(content))
        content[n] = '\0';
    return content_has_compound_assign_syntax(content, n);
}

int labi_rt_content_slice_marker(void) {
    return 1;
}

/** 供 compile.x：源码含复合赋值则返回 1，默认 asm 应降级为 C。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
