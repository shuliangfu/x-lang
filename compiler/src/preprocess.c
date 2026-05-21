/**
 * preprocess.c — .su 条件编译预处理实现（#if / #else / #endif）
 *
 * 文件职责：按行扫描源码，识别 #if SYMBOL、#else、#endif；根据 defines 决定保留或跳过块；被跳过行输出换行以保持行号。
 * 约定：一行内 # 后紧跟 if/elseif/else/endif，允许空白；#if 与 #elseif 后跟单标识符 SYMBOL；嵌套深度可 grow（C 本地栈）。
 */

#include "preprocess.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <stdint.h>

#define PREPROCESS_LINE_MAX  4096
#define PREPROCESS_OUT_GROW  65536
#define PREPROCESS_IF_INIT   32

/** C 路径 #if 嵌套栈（grow；SU 路径用 ast_pool preprocess_if_stack_*）。 */
static int32_t *pp_if_stack;
static int pp_if_cap;
static int pp_if_len;

/** 清空 #if 嵌套栈。 */
static void pp_if_reset(void) {
    pp_if_len = 0;
}

/** 当前嵌套深度。 */
static int pp_if_len_get(void) {
    return pp_if_len;
}

/** 追加一层；失败返回 -1。 */
static int pp_if_push(int32_t v) {
    if (pp_if_len >= pp_if_cap) {
        int nc = pp_if_cap ? pp_if_cap * 2 : PREPROCESS_IF_INIT;
        int32_t *n = (int32_t *)realloc(pp_if_stack, (size_t)nc * sizeof(int32_t));
        if (!n)
            return -1;
        pp_if_stack = n;
        pp_if_cap = nc;
    }
    pp_if_stack[pp_if_len++] = v;
    return 0;
}

/** 弹出一层（#endif）。 */
static void pp_if_pop(void) {
    if (pp_if_len > 0)
        pp_if_len--;
}

/** 读 stack[i]；越界返回 0。 */
static int32_t pp_if_at(int i) {
    if (i < 0 || i >= pp_if_len)
        return 0;
    return pp_if_stack[i];
}

/** 写 stack[i]。 */
static void pp_if_set_at(int i, int32_t v) {
    if (i < 0 || i >= pp_if_len)
        return;
    pp_if_stack[i] = v;
}

/** 判断符号是否在 defines 中 */
static int is_defined(const char *sym, const char **defines, int ndefines) {
    for (int i = 0; i < ndefines; i++)
        if (defines[i] && strcmp(defines[i], sym) == 0)
            return 1;
    return 0;
}

/** 从行首跳过空白，返回指向第一个非空白字符的指针 */
static const char *skip_ws(const char *s) {
    while (*s && (*s == ' ' || *s == '\t')) s++;
    return s;
}

/** 是否为行内结束符（空白或行尾），用于 CRLF 下 #endif 等指令识别 */
static int is_ws_or_eol(char c) {
    return c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\0';
}

/**
 * 解析一行是否以 # 开头并是指令；若是则解析指令类型与符号（仅 #if 需要）。
 * 参数：line 当前行（可含结尾 \n）；out_kind 输出 1=#if, 2=#else, 3=#endif, 4=#elseif, 0=非指令；out_sym 仅 #if/#elseif 时输出符号（写入 buf，最多 buf_size 字节）。
 * 返回值：1 表示是指令且已解析，0 表示非指令。
 */
static int parse_directive(const char *line, int *out_kind, char *out_sym, size_t buf_size) {
    const char *p = skip_ws(line);
    if (*p != '#') return 0;
    p++;
    p = skip_ws(p);
    if (!*p || *p == '\n' || *p == '\r') return 0;
    if (strncmp(p, "if", 2) == 0 && is_ws_or_eol(p[2])) {
        p += 2;
        p = skip_ws(p);
        if (!*p || *p == '\n' || *p == '\r') return 0;
        size_t i = 0;
        while (*p && (isalnum((unsigned char)*p) || *p == '_') && i + 1 < buf_size) {
            out_sym[i++] = *p++;
        }
        out_sym[i] = '\0';
        if (i == 0) return 0;
        *out_kind = 1;
        return 1;
    }
    /* 先匹配 elseif 再 else，避免 "else" 吃掉 "elseif" */
    if (strncmp(p, "elseif", 6) == 0 && is_ws_or_eol(p[6])) {
        p += 6;
        p = skip_ws(p);
        if (!*p || *p == '\n' || *p == '\r') return 0;
        size_t i = 0;
        while (*p && (isalnum((unsigned char)*p) || *p == '_') && i + 1 < buf_size) {
            out_sym[i++] = *p++;
        }
        out_sym[i] = '\0';
        if (i == 0) return 0;
        *out_kind = 4;
        return 1;
    }
    if (strncmp(p, "else", 4) == 0 && is_ws_or_eol(p[4])) {
        *out_kind = 2;
        return 1;
    }
    if (strncmp(p, "endif", 5) == 0 && is_ws_or_eol(p[5])) {
        *out_kind = 3;
        return 1;
    }
    return 0;
}

/** 当前是否处于「保留」状态（应输出本行内容）；depth==0 表示不在任何 #if 内，全部保留；3 表示已选过分支需跳过 */
static int is_keeping(void) {
    int depth = pp_if_len_get();
    if (depth == 0) return 1;
    int top = pp_if_at(depth - 1);
    return top == 1 || top == 2;
}

char *preprocess_c_fallback(const char *source, size_t source_len, const char **defines, int ndefines, size_t *out_length) {
    if (out_length) *out_length = 0;
    if (!source) return NULL;
    int use_explicit_len = (source_len > 0);
    if (source_len == 0)
        source_len = strlen(source);
    /* 无 defines 时仍执行分支逻辑，所有 #if SYMBOL 视为未定义，走 #else 或整块跳过 */
    pp_if_reset();
    size_t out_cap = PREPROCESS_OUT_GROW;
    size_t out_len = 0;
    char *out = (char *)malloc(out_cap);
    if (!out) return NULL;
    const char *p = source;
    const char *end = source + source_len;
    char line_buf[PREPROCESS_LINE_MAX];
    int line_buf_len = 0;
    for (;;) {
        if (p >= end)
            break;
        int ch = *p;
        if (ch == '\n' || (ch == '\0' && !use_explicit_len)) {
            line_buf[line_buf_len] = '\0';
            if (line_buf_len > 0 || ch == '\n') {
                int kind = 0;
                char sym[64] = {0};
                int is_dir = parse_directive(line_buf, &kind, sym, sizeof(sym));
                if (is_dir) {
                    int depth = pp_if_len_get();
                    if (kind == 1) {
                        int v;
                        if (depth > 0 && pp_if_at(depth - 1) == 0)
                            v = 0;
                        else
                            v = is_defined(sym, defines, ndefines) ? 1 : 0;
                        if (pp_if_push(v) < 0) {
                            fprintf(stderr, "preprocess: #if nesting too deep\n");
                            free(out);
                            return NULL;
                        }
                    } else if (kind == 2) {
                        if (depth == 0) {
                            fprintf(stderr, "preprocess: #else without #if\n");
                            free(out);
                            return NULL;
                        }
                        int top = pp_if_at(depth - 1);
                        if (top == 1) {
                            pp_if_set_at(depth - 1, 0);
                        } else if (top == 0) {
                            pp_if_set_at(depth - 1, 2);
                        } else if (top == 3) {
                            /* 已选过 then/elseif，保留跳过 */
                            ;
                        } else {
                            fprintf(stderr, "preprocess: duplicate #else\n");
                            free(out);
                            return NULL;
                        }
                    } else if (kind == 4) {
                        /* #elseif SYMBOL：与 #if/#else 同属一块，只改栈顶；若已在 #else 分支则报错 */
                        if (depth == 0) {
                            fprintf(stderr, "preprocess: #elseif without #if\n");
                            free(out);
                            return NULL;
                        }
                        int top = pp_if_at(depth - 1);
                        if (top == 2) {
                            fprintf(stderr, "preprocess: #elseif after #else\n");
                            free(out);
                            return NULL;
                        }
                        if (top == 1) {
                            pp_if_set_at(depth - 1, 3);
                        } else if (top == 0) {
                            pp_if_set_at(depth - 1, is_defined(sym, defines, ndefines) ? 1 : 0);
                        } else {
                            pp_if_set_at(depth - 1, 3);
                        }
                    } else {
                        if (depth == 0) {
                            fprintf(stderr, "preprocess: #endif without #if\n");
                            free(out);
                            return NULL;
                        }
                        pp_if_pop();
                    }
                    /* 指令行也输出换行以保持与源文件行号一致 */
                    if (out_len + 2 > out_cap) {
                        while (out_cap < out_len + 2) out_cap *= 2;
                        char *n = (char *)realloc(out, out_cap);
                        if (!n) { free(out); return NULL; }
                        out = n;
                    }
                    out[out_len++] = '\n';
                    out[out_len] = '\0';
                } else {
                    size_t need = out_len + (is_keeping() ? (size_t)line_buf_len + 2 : 2);
                    if (need > out_cap) {
                        while (out_cap < need) out_cap *= 2;
                        char *n = (char *)realloc(out, out_cap);
                        if (!n) { free(out); return NULL; }
                        out = n;
                    }
                    if (is_keeping()) {
                        memcpy(out + out_len, line_buf, (size_t)line_buf_len + 1);
                        out_len += (size_t)line_buf_len;
                    }
                    out[out_len++] = '\n';
                    out[out_len] = '\0';
                }
            }
            line_buf_len = 0;
            if (ch == '\0' && !use_explicit_len)
                break;
            p++;
            continue;
        }
        if (line_buf_len < PREPROCESS_LINE_MAX - 1)
            line_buf[line_buf_len++] = (char)ch;
        p++;
    }
    if (pp_if_len_get() != 0) {
        fprintf(stderr, "preprocess: unclosed #if\n");
        free(out);
        return NULL;
    }
    if (out_length) *out_length = out_len;
    return out;
}

/** 对外接口：默认构建（仅链 preprocess.o）时由此提供；SU 构建（-DSHU_USE_SU_PREPROCESS）时由 runtime.c 提供。 */
#ifndef SHU_USE_SU_PREPROCESS
char *preprocess(const char *source, size_t source_len, const char **defines, int ndefines, size_t *out_length) {
    return preprocess_c_fallback(source, source_len, defines, ndefines, out_length);
}
#endif
