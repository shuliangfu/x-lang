/**
 * lexer.c — 词法分析器实现
 *
 * 文件职责：将 .x 源码按字符流切分为 Token 流，识别关键字、标识符、字面量、符号及三种注释：双斜线行注释、块注释、井号行注释。
 * 所属模块：编译器前端 lexer，compiler/src/lexer/；实现 lexer.h 声明的接口。
 * 与其它文件的关系：依赖 include/token.h；被 parser、main 通过 lexer.h 调用；不依赖 parser 或 ast。
 * 重要约定：与 compiler/docs/语法子集-阶段1与2.md 及阶段 5 import 词法一致；Token 的 line/col 为该 Token 在源码中的起始位置；ident 不拷贝，指向 source 内地址。
 */

#include "win32_compat.h"
#include "lexer.h"
#include <limits.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

/* SHUX_WEAK: POSIX 用 weak attribute；Windows/MinGW 不支持 weak 函数符号，改为正常定义，
 * 配合 Makefile 的 -Wl,--allow-multiple-definition 解决重复定义冲突。 */
#ifndef SHUX_WEAK
#if defined(_WIN32) || defined(_WIN64)
#define SHUX_WEAK
#else
#define SHUX_WEAK __attribute__((weak))
#endif
#endif
struct Lexer {
    const char *src;  /**< 当前扫描位置 */
    const char *end;  /**< 源码结尾（不含 NUL） */
    int line;         /**< 当前行号，从 1 开始 */
    int col;          /**< 当前列号，从 1 开始 */
    char str_buf[512]; /**< 最近一次 TOKEN_STRING 解码内容（NUL 结尾） */
};

/**
 * 查看当前字符不消费；到达末尾返回 0。
 * 参数：l 当前 Lexer。返回值：当前字节值（0 表示已到 end）。无副作用。
 */
static int lexer_peek(Lexer *l) {
    return (l->src < l->end) ? (unsigned char)*l->src : 0;
}

/**
 * 消费当前字符并推进指针；若为换行则 line++、col 置 1，否则 col++。
 * 参数：l 当前 Lexer。返回值：被消费的字节值，已到末尾则返回 0。副作用：修改 l->src、l->line、l->col。
 */
static int lexer_advance(Lexer *l) {
    if (l->src >= l->end) return 0;
    int c = (unsigned char)*l->src++;
    if (c == '\n') { l->line++; l->col = 1; } else { l->col++; }
    return c;
}

/**
 * 创建 Lexer；见 lexer.h 中 lexer_new 注释。
 */
Lexer *lexer_new(const char *source) {
    Lexer *l = (Lexer *)malloc(sizeof(Lexer));
    if (!l) return NULL;
    l->src = source;
    l->end = source + strlen(source);
    l->line = 1;
    l->col = 1;
    return l;
}

/**
 * 向 out 写入仅 kind 的 Token，位置取当前 l->line/col；value 与 ident_len 置 0/NULL。
 * 参数：l 提供位置；out 输出；kind 类型。无返回值。副作用：仅写 out。
 */
static void emit_token(Lexer *l, Token *out, TokenKind kind) {
    out->kind = kind;
    out->line = l->line;
    out->col = l->col;
    out->value.int_val = 0;
    out->value.ident = NULL;
    out->ident_len = 0;
}

/**
 * 识别标识符或关键字（function、i32、import）；先按 [a-zA-Z0-9_] 推进，再按内容区分。
 * 参数：l 当前 Lexer；out 输出 Token。返回值：无。副作用：推进 l，写 out；IDENT 时 out->value.ident 指向 start，ident_len 有效。
 */
static void lex_ident_or_keyword(Lexer *l, Token *out) {
    const char *start = l->src;
    int line0 = l->line, col0 = l->col;
    while (l->src < l->end && (isalnum((unsigned char)*l->src) || *l->src == '_'))
        lexer_advance(l);
    size_t len = (size_t)(l->src - start);

    if (len == 8 && memcmp(start, "function", 8) == 0) {
        out->kind = TOKEN_FUNCTION;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 3 && memcmp(start, "let", 3) == 0) {
        out->kind = TOKEN_LET;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "const", 5) == 0) {
        out->kind = TOKEN_CONST;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 2 && memcmp(start, "if", 2) == 0) {
        out->kind = TOKEN_IF;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 2 && memcmp(start, "as", 2) == 0) {
        out->kind = TOKEN_AS;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 4 && memcmp(start, "else", 4) == 0) {
        out->kind = TOKEN_ELSE;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 6 && memcmp(start, "extern", 6) == 0) {
        out->kind = TOKEN_EXTERN;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "async", 5) == 0) {
        out->kind = TOKEN_ASYNC;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "await", 5) == 0) {
        out->kind = TOKEN_AWAIT;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 3 && memcmp(start, "run", 3) == 0) {
        out->kind = TOKEN_RUN;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "spawn", 5) == 0) {
        out->kind = TOKEN_SPAWN;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "while", 5) == 0) {
        out->kind = TOKEN_WHILE;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 4 && memcmp(start, "loop", 4) == 0) {
        out->kind = TOKEN_LOOP;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 3 && memcmp(start, "for", 3) == 0) {
        out->kind = TOKEN_FOR;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "break", 5) == 0) {
        out->kind = TOKEN_BREAK;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 8 && memcmp(start, "continue", 8) == 0) {
        out->kind = TOKEN_CONTINUE;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 6 && memcmp(start, "return", 6) == 0) {
        out->kind = TOKEN_RETURN;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "panic", 5) == 0) {
        out->kind = TOKEN_PANIC;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "defer", 5) == 0) {
        out->kind = TOKEN_DEFER;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 6 && memcmp(start, "region", 6) == 0) {
        out->kind = TOKEN_REGION;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "match", 5) == 0) {
        out->kind = TOKEN_MATCH;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 6 && memcmp(start, "packed", 6) == 0) {
        out->kind = TOKEN_PACKED;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 3 && memcmp(start, "soa", 3) == 0) {
        out->kind = TOKEN_SOA;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "align", 5) == 0) {
        out->kind = TOKEN_ALIGN;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 6 && memcmp(start, "struct", 6) == 0) {
        out->kind = TOKEN_STRUCT;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 4 && memcmp(start, "enum", 4) == 0) {
        out->kind = TOKEN_ENUM;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 4 && memcmp(start, "goto", 4) == 0) {
        out->kind = TOKEN_GOTO;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "trait", 5) == 0) {
        out->kind = TOKEN_TRAIT;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 4 && memcmp(start, "impl", 4) == 0) {
        out->kind = TOKEN_IMPL;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 4 && memcmp(start, "self", 4) == 0) {
        out->kind = TOKEN_SELF;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    /* _ 单独作为 match 通配模式 */
    if (len == 1 && start[0] == '_') {
        out->kind = TOKEN_UNDERSCORE;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "i32x4", 5) == 0) {
        out->kind = TOKEN_I32X4;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "i32x8", 5) == 0) {
        out->kind = TOKEN_I32X8;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "u32x4", 5) == 0) {
        out->kind = TOKEN_U32X4;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "u32x8", 5) == 0) {
        out->kind = TOKEN_U32X8;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    /* 16 车道向量（6 字符），须在 i32/u32 之前匹配 */
    if (len == 6 && memcmp(start, "i32x16", 6) == 0) {
        out->kind = TOKEN_I32X16;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 6 && memcmp(start, "u32x16", 6) == 0) {
        out->kind = TOKEN_U32X16;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "f32x4", 5) == 0) {
        out->kind = TOKEN_F32X4;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 3 && memcmp(start, "i32", 3) == 0) {
        out->kind = TOKEN_I32;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 4 && memcmp(start, "bool", 4) == 0) {
        out->kind = TOKEN_BOOL;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 2 && memcmp(start, "u8", 2) == 0) {
        out->kind = TOKEN_U8;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 3 && memcmp(start, "u32", 3) == 0) {
        out->kind = TOKEN_U32;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 3 && memcmp(start, "u64", 3) == 0) {
        out->kind = TOKEN_U64;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 3 && memcmp(start, "i64", 3) == 0) {
        out->kind = TOKEN_I64;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "usize", 5) == 0) {
        out->kind = TOKEN_USIZE;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "isize", 5) == 0) {
        out->kind = TOKEN_ISIZE;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 4 && memcmp(start, "true", 4) == 0) {
        out->kind = TOKEN_TRUE;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 5 && memcmp(start, "false", 5) == 0) {
        out->kind = TOKEN_FALSE;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 6 && memcmp(start, "import", 6) == 0) {
        out->kind = TOKEN_IMPORT;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 3 && memcmp(start, "f32", 3) == 0) {
        out->kind = TOKEN_F32;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 3 && memcmp(start, "f64", 3) == 0) {
        out->kind = TOKEN_F64;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    if (len == 4 && memcmp(start, "void", 4) == 0) {
        out->kind = TOKEN_VOID;
        out->line = line0;
        out->col = col0;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }

    out->kind = TOKEN_IDENT;
    out->line = line0;
    out->col = col0;
    out->value.ident = start;
    out->ident_len = (int)(len <= (size_t)INT_MAX ? len : 0);
}

/**
 * 对已得到的浮点值 fval 解析可选指数部分 e/E (+|-)? digits，并乘到 *fval 上。
 * 若存在指数则推进 l 并修改 *fval，否则不推进。返回值：1 表示解析了指数，0 表示无指数。
 */
static int lex_optional_exponent(Lexer *l, double *fval) {
    if (l->src >= l->end || (*l->src != 'e' && *l->src != 'E')) return 0;
    lexer_advance(l);
    int exp_sign = 1;
    if (l->src < l->end && *l->src == '-') {
        exp_sign = -1;
        lexer_advance(l);
    } else if (l->src < l->end && *l->src == '+') {
        lexer_advance(l);
    }
    int exp = 0;
    while (l->src < l->end && isdigit((unsigned char)*l->src))
        exp = exp * 10 + (lexer_advance(l) - '0');
    exp *= exp_sign;
    double scale = 1.0;
    if (exp > 0) {
        for (int i = 0; i < exp; i++) scale *= 10.0;
    } else if (exp < 0) {
        for (int i = 0; i < -exp; i++) scale /= 10.0;
    }
    *fval *= scale;
    return 1;
}

/**
 * 是否为十六进制数字字符（0-9、a-f、A-F）。
 */
static int is_hex_digit(int c) {
    return isdigit((unsigned char)c)
        || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
}

/**
 * 十六进制数字字符转 0..15。
 */
static int hex_digit_value(int c) {
    if (isdigit((unsigned char)c))
        return c - '0';
    if (c >= 'a' && c <= 'f')
        return c - 'a' + 10;
    if (c >= 'A' && c <= 'F')
        return c - 'A' + 10;
    return 0;
}

/**
 * 识别 0x/0X 前缀十六进制整数字面量；调用前须已消费 leading '0'。
 */
static void lex_hex_number(Lexer *l, Token *out, int line0, int col0) {
    unsigned long val = 0;
    lexer_advance(l); /* x 或 X */
    while (l->src < l->end && is_hex_digit(lexer_peek(l))) {
        val = (val << 4) | (unsigned long)hex_digit_value(lexer_peek(l));
        lexer_advance(l);
    }
    out->kind = TOKEN_INT;
    out->line = line0;
    out->col = col0;
    out->value.int_val = (int64_t)val;
    out->ident_len = 0;
}

/**
 * 识别整数字面量或浮点字面量：支持 42、0x2A、3.14、.5、1e2、1.5e-1 等形式；含小数点或指数则输出 TOKEN_FLOAT。
 * 参数：l 当前 Lexer；out 输出 Token。副作用：推进 l，写 out。
 */
static void lex_number(Lexer *l, Token *out) {
    int line0 = l->line, col0 = l->col;
    /* 0x / 0X 十六进制整数字面量 */
    if (lexer_peek(l) == '0' && l->src + 1 < l->end) {
        int nx = (unsigned char)l->src[1];
        if (nx == 'x' || nx == 'X') {
            lexer_advance(l);
            lex_hex_number(l, out, line0, col0);
            return;
        }
    }
    int64_t ival = 0;
    while (l->src < l->end && isdigit((unsigned char)*l->src))
        ival = ival * 10 + (lexer_advance(l) - '0');
    /* 仅当 '.' 后接数字时才解析为浮点，避免 21.double() 被吞成 FLOAT(21.) */
    if (l->src < l->end && *l->src == '.' && l->src + 1 < l->end && isdigit((unsigned char)l->src[1])) {
        lexer_advance(l);
        double fval = (double)ival;
        double frac = 0.1;
        while (l->src < l->end && isdigit((unsigned char)*l->src)) {
            fval += frac * (lexer_advance(l) - '0');
            frac *= 0.1;
        }
        lex_optional_exponent(l, &fval);
        out->kind = TOKEN_FLOAT;
        out->line = line0;
        out->col = col0;
        out->value.float_val = fval;
        out->ident_len = 0;
        return;
    }
    if (l->src < l->end && (*l->src == 'e' || *l->src == 'E')) {
        double fval = (double)ival;
        lex_optional_exponent(l, &fval);
        out->kind = TOKEN_FLOAT;
        out->line = line0;
        out->col = col0;
        out->value.float_val = fval;
        out->ident_len = 0;
        return;
    }
    out->kind = TOKEN_INT;
    out->line = line0;
    out->col = col0;
    out->value.int_val = ival;
    out->ident_len = 0;
}

/**
 * 识别仅小数形式浮点字面量（如 .5、.5e2）：当前字符为 '.'，下一字符为数字。
 * 参数：l 当前 Lexer；out 输出 Token。副作用：推进 l，写 out。
 */
static void lex_float_leading_dot(Lexer *l, Token *out) {
    int line0 = l->line, col0 = l->col;
    lexer_advance(l);  /* 消耗 '.' */
    double fval = 0.0;
    double frac = 0.1;
    while (l->src < l->end && isdigit((unsigned char)*l->src)) {
        fval += frac * (lexer_advance(l) - '0');
        frac *= 0.1;
    }
    lex_optional_exponent(l, &fval);
    out->kind = TOKEN_FLOAT;
    out->line = line0;
    out->col = col0;
    out->value.float_val = fval;
    out->ident_len = 0;
}

/**
 * B-01：返回当前 host 的 target_os 字面量（与 #[cfg(target_os = "...")] 对齐）。
 */
static const char *cfg_host_os_lit(void) {
#if defined(__APPLE__)
    return "macos";
#elif defined(_WIN32) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MSYS__)
    /** MSYS2 MSYS 子系统 gcc 常仅定义 __CYGWIN__，须与 std.sys #[cfg(windows)] 对齐。 */
    return "windows";
#elif defined(__linux__)
    return "linux";
#elif defined(__FreeBSD__)
    return "freebsd";
#else
    return "unknown";
#endif
}

/**
 * B-01：返回当前 host 的 target_arch 字面量。
 */
static const char *cfg_host_arch_lit(void) {
#if defined(__aarch64__) || defined(_M_ARM64)
    return "aarch64";
#elif defined(__x86_64__) || defined(_M_X64) || defined(__amd64__)
    return "x86_64";
#elif defined(__riscv) && __riscv_xlen == 64
    return "riscv64";
#else
    return "unknown";
#endif
}

/** B-02：`-target` triple 覆盖后的 effective os/arch；未设置时与 host 相同。 */
static char g_cfg_os_override[32];
static char g_cfg_arch_override[32];
static int g_cfg_has_target_override;

/**
 * B-02：在 triple[len] 中忽略大小写查找子串 needle。
 * 返回值：找到返回 1，否则 0。
 */
static int cfg_triple_contains_ci(const char *triple, int len, const char *needle) {
    size_t nlen;
    int i;
    if (!triple || len <= 0 || !needle)
        return 0;
    nlen = strlen(needle);
    if (nlen == 0 || (size_t)len < nlen)
        return 0;
    for (i = 0; i + (int)nlen <= len; i++) {
        int j;
        int ok = 1;
        for (j = 0; j < (int)nlen; j++) {
            unsigned char a = (unsigned char)triple[i + j];
            unsigned char b = (unsigned char)needle[j];
            if (a >= 'A' && a <= 'Z')
                a = (unsigned char)(a + 32);
            if (b >= 'A' && b <= 'Z')
                b = (unsigned char)(b + 32);
            if (a != b) {
                ok = 0;
                break;
            }
        }
        if (ok)
            return 1;
    }
    return 0;
}

/**
 * B-02：从 `-target` triple 解析 target_os / target_arch 字面量写入 os_out/arch_out。
 * 解析失败时回退 host 值。
 */
static void cfg_parse_triple_literals(const char *triple, int len, char *os_out, size_t os_sz, char *arch_out,
                                      size_t arch_sz) {
    const char *host_os;
    const char *host_arch;
    if (!os_out || os_sz == 0 || !arch_out || arch_sz == 0)
        return;
    host_os = cfg_host_os_lit();
    host_arch = cfg_host_arch_lit();
    strncpy(os_out, host_os, os_sz - 1);
    os_out[os_sz - 1] = '\0';
    strncpy(arch_out, host_arch, arch_sz - 1);
    arch_out[arch_sz - 1] = '\0';
    if (!triple || len <= 0)
        return;
    if (cfg_triple_contains_ci(triple, len, "linux"))
        strncpy(os_out, "linux", os_sz - 1);
    else if (cfg_triple_contains_ci(triple, len, "darwin") || cfg_triple_contains_ci(triple, len, "macos"))
        strncpy(os_out, "macos", os_sz - 1);
    else if (cfg_triple_contains_ci(triple, len, "freebsd"))
        strncpy(os_out, "freebsd", os_sz - 1);
    else if (cfg_triple_contains_ci(triple, len, "windows") || cfg_triple_contains_ci(triple, len, "win32"))
        strncpy(os_out, "windows", os_sz - 1);
    os_out[os_sz - 1] = '\0';
    if (cfg_triple_contains_ci(triple, len, "aarch64") || cfg_triple_contains_ci(triple, len, "arm64"))
        strncpy(arch_out, "aarch64", arch_sz - 1);
    else if (cfg_triple_contains_ci(triple, len, "x86_64") || cfg_triple_contains_ci(triple, len, "amd64"))
        strncpy(arch_out, "x86_64", arch_sz - 1);
    else if (cfg_triple_contains_ci(triple, len, "riscv64"))
        strncpy(arch_out, "riscv64", arch_sz - 1);
    arch_out[arch_sz - 1] = '\0';
}

/** B-02：#[cfg] 求值使用的 effective target_os（triple 覆盖或 host）。 */
static const char *cfg_effective_os_lit(void) {
    if (g_cfg_has_target_override && g_cfg_os_override[0])
        return g_cfg_os_override;
    return cfg_host_os_lit();
}

/** B-02：#[cfg] 求值使用的 effective target_arch（triple 覆盖或 host）。 */
static const char *cfg_effective_arch_lit(void) {
    if (g_cfg_has_target_override && g_cfg_arch_override[0])
        return g_cfg_arch_override;
    return cfg_host_arch_lit();
}

/**
 * B-02：应用 `-target` triple，使后续 #[cfg] 按 cross 目标剪枝。
 */
SHUX_WEAK void cfg_apply_compile_target_from_triple(const char *triple, int len) {
    cfg_parse_triple_literals(triple, len, g_cfg_os_override, sizeof g_cfg_os_override, g_cfg_arch_override,
                              sizeof g_cfg_arch_override);
    g_cfg_has_target_override = 1;
}

/** B-02：清除 triple 覆盖，#[cfg] 回退 host。 */
SHUX_WEAK void cfg_reset_compile_target(void) {
    g_cfg_has_target_override = 0;
    g_cfg_os_override[0] = '\0';
    g_cfg_arch_override[0] = '\0';
}

/** 忽略大小写比较 [a, a+alen) 与 C 字符串 b。 */
static int cfg_lit_eq_ci(const char *a, size_t alen, const char *b) {
    size_t blen;
    size_t i;

    if (!a || !b)
        return 0;
    blen = strlen(b);
    if (alen != blen)
        return 0;
    for (i = 0; i < alen; i++) {
        unsigned char ca = (unsigned char)a[i];
        unsigned char cb = (unsigned char)b[i];
        if (ca >= 'A' && ca <= 'Z')
            ca = (unsigned char)(ca + 32);
        if (cb >= 'A' && cb <= 'Z')
            cb = (unsigned char)(cb + 32);
        if (ca != cb)
            return 0;
    }
    return 1;
}

/** 递归求值 cfg 表达式；end 不含（指向 cfg 外层 ')' 或子表达式结束）。 */
static int cfg_eval_expr(const char *start, const char *end) {
    const char *p = start;

    while (p < end && (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\r'))
        p++;
    if (p >= end)
        return 0;
    if ((size_t)(end - p) >= 4 && strncmp(p, "all(", 4) == 0) {
        p += 4;
        while (p < end) {
            const char *part;
            int depth;
            while (p < end && (*p == ' ' || *p == '\t' || *p == ',' || *p == '\n' || *p == '\r'))
                p++;
            if (p >= end)
                break;
            if (*p == ')')
                return 1;
            part = p;
            depth = 0;
            while (p < end) {
                if (*p == '(')
                    depth++;
                else if (*p == ')') {
                    if (depth == 0)
                        break;
                    depth--;
                } else if (*p == ',' && depth == 0)
                    break;
                p++;
            }
            if (!cfg_eval_expr(part, p))
                return 0;
            if (p < end && *p == ')')
                return 1;
        }
        return 1;
    }
    if ((size_t)(end - p) >= 4 && strncmp(p, "not(", 4) == 0) {
        const char *inner;
        const char *close;
        int depth;

        inner = p + 4;
        depth = 1;
        close = inner;
        while (close < end && depth > 0) {
            if (*close == '(')
                depth++;
            else if (*close == ')')
                depth--;
            if (depth > 0)
                close++;
        }
        return !cfg_eval_expr(inner, close);
    }
    /* 【Why 逻辑根源】#[cfg] 与 #if 中 target_os == "..." 既允许单 `=`（cfg 风格）也允许双 `==`
     * （C 风格）；与 cfg_eval.x::cfg_eval_expr_range 对齐，否则 #if target_os == "macos" 在
     * macOS 上会被 lexer C 实现误判为 false 走 #else 分支（run-preprocess.sh 根因）。 */
    if ((size_t)(end - p) >= 9 && strncmp(p, "target_os", 9) == 0) {
        const char *lit;
        p += 9;
        while (p < end && (*p == ' ' || *p == '\t'))
            p++;
        if (p >= end || *p != '=')
            return 0;
        p++;
        if (p < end && *p == '=')
            p++;
        while (p < end && (*p == ' ' || *p == '\t'))
            p++;
        if (p >= end || *p != '"')
            return 0;
        p++;
        lit = p;
        while (p < end && *p != '"')
            p++;
        return cfg_lit_eq_ci(lit, (size_t)(p - lit), cfg_effective_os_lit());
    }
    if ((size_t)(end - p) >= 11 && strncmp(p, "target_arch", 11) == 0) {
        const char *lit;
        p += 11;
        while (p < end && (*p == ' ' || *p == '\t'))
            p++;
        if (p >= end || *p != '=')
            return 0;
        p++;
        if (p < end && *p == '=')
            p++;
        while (p < end && (*p == ' ' || *p == '\t'))
            p++;
        if (p >= end || *p != '"')
            return 0;
        p++;
        lit = p;
        while (p < end && *p != '"')
            p++;
        return cfg_lit_eq_ci(lit, (size_t)(p - lit), cfg_effective_arch_lit());
    }
    return 0;
}

SHUX_WEAK int cfg_eval_expr_c(const char *start, int len) {
    if (!start || len <= 0)
        return 0;
    return cfg_eval_expr(start, start + len) ? 1 : 0;
}

/**
 * B-03 v1：若当前位置为 #[repr(C)]，消费整段并写入 TOKEN_ATTR_REPR_C；成功返回 1。
 */
static int lexer_lex_repr_c_attr(Lexer *l, Token *out) {
    int line;
    int col;
    if (!l || !l->src || !out || l->src + 10 > l->end)
        return 0;
    if (l->src[0] != '#' || l->src[1] != '[')
        return 0;
    if (l->src[2] != 'r' || l->src[3] != 'e' || l->src[4] != 'p' || l->src[5] != 'r')
        return 0;
    if (l->src[6] != '(' || l->src[7] != 'C' || l->src[8] != ')' || l->src[9] != ']')
        return 0;
    line = l->line;
    col = l->col;
    for (int i = 0; i < 10; i++)
        lexer_advance(l);
    out->kind = TOKEN_ATTR_REPR_C;
    out->line = line;
    out->col = col;
    out->value.int_val = 0;
    out->ident_len = 0;
    return 1;
}

/**
 * MOD-02：若当前位置为 #[repr(compatible)]，消费整段并写入 TOKEN_ATTR_REPR_COMPATIBLE；成功返回 1。
 */
static int lexer_lex_repr_compatible_attr(Lexer *l, Token *out) {
    int line;
    int col;
    if (!l || !l->src || !out || l->src + 19 > l->end)
        return 0;
    if (l->src[0] != '#' || l->src[1] != '[')
        return 0;
    if (l->src[2] != 'r' || l->src[3] != 'e' || l->src[4] != 'p' || l->src[5] != 'r')
        return 0;
    if (l->src[6] != '(')
        return 0;
    if (l->src[7] != 'c' || l->src[8] != 'o' || l->src[9] != 'm' || l->src[10] != 'p' ||
        l->src[11] != 'a' || l->src[12] != 't' || l->src[13] != 'i' || l->src[14] != 'b' ||
        l->src[15] != 'l' || l->src[16] != 'e')
        return 0;
    if (l->src[17] != ')' || l->src[18] != ']')
        return 0;
    line = l->line;
    col = l->col;
    for (int i = 0; i < 19; i++)
        lexer_advance(l);
    out->kind = TOKEN_ATTR_REPR_COMPATIBLE;
    out->line = line;
    out->col = col;
    out->value.int_val = 0;
    out->ident_len = 0;
    return 1;
}

/**
 * K4：若当前位置为 #[link_section("name")]，消费整段并写入 TOKEN_ATTR_LINK_SECTION；
 * value.ident/ident_len 为段名（解码后存入 l->str_buf，调用方须在使用前 strndup）。成功返回 1。
 */
static int lexer_lex_link_section_attr(Lexer *l, Token *out) {
    static const char prefix[] = "#[link_section(";
    int line, col, off = 0;
    size_t plen = sizeof(prefix) - 1;
    if (!l || !l->src || !out || (size_t)(l->end - l->src) < plen + 4)
        return 0;
    if (memcmp(l->src, prefix, plen) != 0)
        return 0;
    line = l->line; col = l->col;
    for (size_t i = 0; i < plen; i++)
        lexer_advance(l);
    if (l->src >= l->end || lexer_peek(l) != '"')
        return 0;
    lexer_advance(l);  /* opening " */
    while (l->src < l->end && lexer_peek(l) != '"') {
        int ch = lexer_advance(l);
        if (ch == '\\' && l->src < l->end) {
            int esc = lexer_advance(l);
            if (off < (int)sizeof(l->str_buf) - 1)
                l->str_buf[off++] = (char)esc;
            continue;
        }
        if (off < (int)sizeof(l->str_buf) - 1)
            l->str_buf[off++] = (char)ch;
    }
    if (l->src >= l->end || lexer_peek(l) != '"')
        return 0;
    lexer_advance(l);  /* closing " */
    if (l->src >= l->end || lexer_peek(l) != ')')
        return 0;
    lexer_advance(l);  /* ) */
    if (l->src >= l->end || lexer_peek(l) != ']')
        return 0;
    lexer_advance(l);  /* ] */
    l->str_buf[off] = '\0';
    out->kind = TOKEN_ATTR_LINK_SECTION;
    out->line = line; out->col = col;
    out->value.ident = l->str_buf;
    out->ident_len = off;
    return 1;
}

/**
 * #[export_name("name")] — 导出符号名（与 #[link_name] 相同模式）。
 */
static int lexer_lex_export_name_attr(Lexer *l, Token *out) {
    static const char prefix[] = "#[export_name(";
    int line, col, off = 0;
    size_t plen = sizeof(prefix) - 1;
    if (!l || !l->src || !out || (size_t)(l->end - l->src) < plen + 4)
        return 0;
    if (memcmp(l->src, prefix, plen) != 0)
        return 0;
    line = l->line; col = l->col;
    for (size_t i = 0; i < plen; i++)
        lexer_advance(l);
    if (l->src >= l->end || lexer_peek(l) != '"')
        return 0;
    lexer_advance(l);
    while (l->src < l->end && lexer_peek(l) != '"') {
        int ch = lexer_advance(l);
        if (ch == '\\' && l->src < l->end) {
            int esc = lexer_advance(l);
            if (off < (int)sizeof(l->str_buf) - 1)
                l->str_buf[off++] = (char)esc;
            continue;
        }
        if (off < (int)sizeof(l->str_buf) - 1)
            l->str_buf[off++] = (char)ch;
    }
    if (l->src >= l->end || lexer_peek(l) != '"')
        return 0;
    lexer_advance(l);
    if (l->src >= l->end || lexer_peek(l) != ')')
        return 0;
    lexer_advance(l);
    if (l->src >= l->end || lexer_peek(l) != ']')
        return 0;
    lexer_advance(l);
    l->str_buf[off] = '\0';
    out->kind = TOKEN_ATTR_EXPORT_NAME;
    out->line = line; out->col = col;
    out->value.ident = l->str_buf;
    out->ident_len = off;
    return 1;
}

/**
 * L9：若当前位置为 #[link_name("name")]，消费整段并写入 TOKEN_ATTR_LINK_NAME；
 * value.ident/ident_len 为符号名（解码后存入 l->str_buf，调用方须在使用前 strndup）。成功返回 1。
 */
static int lexer_lex_link_name_attr(Lexer *l, Token *out) {
    static const char prefix[] = "#[link_name(";
    int line, col, off = 0;
    size_t plen = sizeof(prefix) - 1;
    if (!l || !l->src || !out || (size_t)(l->end - l->src) < plen + 4)
        return 0;
    if (memcmp(l->src, prefix, plen) != 0)
        return 0;
    line = l->line; col = l->col;
    for (size_t i = 0; i < plen; i++)
        lexer_advance(l);
    if (l->src >= l->end || lexer_peek(l) != '"')
        return 0;
    lexer_advance(l);  /* opening " */
    while (l->src < l->end && lexer_peek(l) != '"') {
        int ch = lexer_advance(l);
        if (ch == '\\' && l->src < l->end) {
            int esc = lexer_advance(l);
            if (off < (int)sizeof(l->str_buf) - 1)
                l->str_buf[off++] = (char)esc;
            continue;
        }
        if (off < (int)sizeof(l->str_buf) - 1)
            l->str_buf[off++] = (char)ch;
    }
    if (l->src >= l->end || lexer_peek(l) != '"')
        return 0;
    lexer_advance(l);  /* closing " */
    if (l->src >= l->end || lexer_peek(l) != ')')
        return 0;
    lexer_advance(l);  /* ) */
    if (l->src >= l->end || lexer_peek(l) != ']')
        return 0;
    lexer_advance(l);  /* ] */
    l->str_buf[off] = '\0';
    out->kind = TOKEN_ATTR_LINK_NAME;
    out->line = line; out->col = col;
    out->value.ident = l->str_buf;
    out->ident_len = off;
    return 1;
}

/**
 * B-01 v1：若当前位置为 #[cfg(...)]，求值 host 匹配并写入 out（TOKEN_ATTR_CFG）；成功返回 1。
 */
static int lexer_lex_cfg_attr(Lexer *l, Token *out) {
    const char *expr_start;
    const char *p;
    int depth;
    int line;
    int col;
    int enabled;

    if (!l || !l->src || !out || l->src + 6 > l->end)
        return 0;
    if (l->src[0] != '#' || l->src[1] != '[')
        return 0;
    if (l->src[2] != 'c' || l->src[3] != 'f' || l->src[4] != 'g')
        return 0;
    if (l->src[5] != '(')
        return 0;
    line = l->line;
    col = l->col;
    expr_start = l->src + 6;
    p = expr_start;
    depth = 1;
    while (p < l->end && depth > 0) {
        if (*p == '(')
            depth++;
        else if (*p == ')')
            depth--;
        p++;
    }
    if (p >= l->end || *p != ']')
        return 0;
    enabled = cfg_eval_expr_c(expr_start, (int)(p - 1 - expr_start));
    p++;
    while (l->src < p)
        lexer_advance(l);
    out->kind = TOKEN_ATTR_CFG;
    out->line = line;
    out->col = col;
    out->value.int_val = enabled ? 1 : 0;
    out->ident_len = 0;
    return 1;
}

/**
 * 取下一个 Token；见 lexer.h 中 lexer_next 注释。
 */
void lexer_next(Lexer *l, Token *out) {
    /* 跳过空白与三种注释：双斜线行注释、块注释、井号行注释 */
    while (l->src < l->end) {
        int c = lexer_peek(l);
        if (c == ' ' || c == '\t' || c == '\n' || c == '\r') {
            lexer_advance(l);
            continue;
        }
        if (c == '/' && l->src + 1 < l->end && l->src[1] == '/') {
            while (l->src < l->end && lexer_peek(l) != '\n') lexer_advance(l);
            continue;
        }
        if (c == '/' && l->src + 1 < l->end && l->src[1] == '*') {
            lexer_advance(l);
            lexer_advance(l);
            while (l->src < l->end) {
                if (lexer_peek(l) == '*' && l->src + 1 < l->end && l->src[1] == '/') break;
                lexer_advance(l);
            }
            if (l->src + 1 < l->end) { lexer_advance(l); lexer_advance(l); }
            continue;
        }
        if (c == '#') {
            if (l->src + 1 < l->end && l->src[1] == '[')
                break;
            while (l->src < l->end && lexer_peek(l) != '\n') lexer_advance(l);
            continue;
        }
        break;
    }

    if (l->src >= l->end) {
        emit_token(l, out, TOKEN_EOF);
        return;
    }

    int c = lexer_peek(l);
    /* B-01 v1：#[cfg(...)] → TOKEN_ATTR_CFG（int_val 表 host 是否保留下一顶层项）。 */
    if (c == '#' && l->src + 1 < l->end && l->src[1] == '[' && lexer_lex_cfg_attr(l, out))
        return;
    /* B-03 v1：#[repr(C)] → TOKEN_ATTR_REPR_C。 */
    if (c == '#' && l->src + 1 < l->end && l->src[1] == '[' && lexer_lex_repr_c_attr(l, out))
        return;
    /* MOD-02：#[repr(compatible)] → TOKEN_ATTR_REPR_COMPATIBLE。 */
    if (c == '#' && l->src + 1 < l->end && l->src[1] == '[' && lexer_lex_repr_compatible_attr(l, out))
        return;
    /* K4：#[link_section("name")] → TOKEN_ATTR_LINK_SECTION。 */
    if (c == '#' && l->src + 1 < l->end && l->src[1] == '[' && lexer_lex_link_section_attr(l, out))
        return;
    /* L9：#[link_name("name")] → TOKEN_ATTR_LINK_NAME。 */
    if (c == '#' && l->src + 1 < l->end && l->src[1] == '[' && lexer_lex_link_name_attr(l, out))
        return;
    /* DOD-S1：#[soa] 属性 token */
    if (c == '#' && l->src + 6 <= l->end && l->src[1] == '[' && l->src[2] == 's' && l->src[3] == 'o'
        && l->src[4] == 'a' && l->src[5] == ']') {
        int line = l->line, col = l->col;
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        out->kind = TOKEN_ATTR_SOA;
        out->line = line;
        out->col = col;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    /* MEM-C1：#[alloc] 属性 token（Allocator 自动注入 API；仅跳过属性，语义由 typeck/codegen 处理）。 */
    if (c == '#' && l->src + 8 <= l->end && l->src[1] == '[' && l->src[2] == 'a' && l->src[3] == 'l'
        && l->src[4] == 'l' && l->src[5] == 'o' && l->src[6] == 'c' && l->src[7] == ']') {
        int line = l->line, col = l->col;
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        out->kind = TOKEN_ATTR_ALLOC;
        out->line = line;
        out->col = col;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    /* K3：#[naked] 属性 token（下一 function 无 prologue/epilogue，体须仅 asm!）。 */
    if (c == '#' && l->src + 8 <= l->end && l->src[1] == '[' && l->src[2] == 'n' && l->src[3] == 'a'
        && l->src[4] == 'k' && l->src[5] == 'e' && l->src[6] == 'd' && l->src[7] == ']') {
        int line = l->line, col = l->col;
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        out->kind = TOKEN_ATTR_NAKED;
        out->line = line;
        out->col = col;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    /* K5：#[entry] 属性 token（下一 function 为内核入口 _start）。 */
    if (c == '#' && l->src + 8 <= l->end && l->src[1] == '[' && l->src[2] == 'e' && l->src[3] == 'n'
        && l->src[4] == 't' && l->src[5] == 'r' && l->src[6] == 'y' && l->src[7] == ']') {
        int line = l->line, col = l->col;
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        out->kind = TOKEN_ATTR_ENTRY;
        out->line = line;
        out->col = col;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    /* K10：#[used] 属性 token（下一 function 不被 C 编译器消除，外部链接；ISR/asm! 引用用）。 */
    if (c == '#' && l->src + 7 <= l->end && l->src[1] == '[' && l->src[2] == 'u' && l->src[3] == 's'
        && l->src[4] == 'e' && l->src[5] == 'd' && l->src[6] == ']') {
        int line = l->line, col = l->col;
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        lexer_advance(l);
        out->kind = TOKEN_ATTR_USED;
        out->line = line;
        out->col = col;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    /* #[export_name("name")] — reuse link_name scanner pattern */
    if (c == '#' && l->src + 1 < l->end && l->src[1] == '[' && lexer_lex_export_name_attr(l, out))
        return;
    /* L9：#[no_mangle] 属性 token（下一 function 外部链接+不 DCE；C 前端名字透传）。 */
    if (c == '#' && l->src + 12 <= l->end && l->src[1] == '[' && l->src[2] == 'n' && l->src[3] == 'o'
        && l->src[4] == '_' && l->src[5] == 'm' && l->src[6] == 'a' && l->src[7] == 'n'
        && l->src[8] == 'g' && l->src[9] == 'l' && l->src[10] == 'e' && l->src[11] == ']') {
        int line = l->line, col = l->col;
        for (int i = 0; i < 12; i++) lexer_advance(l);
        out->kind = TOKEN_ATTR_NO_MANGLE;
        out->line = line;
        out->col = col;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    /* A1：#[interrupt] 属性 token（下一 function 为中断处理，C 编译器自动保存/恢复寄存器+iret）。 */
    if (c == '#' && l->src + 13 <= l->end && l->src[1] == '[' && l->src[2] == 'i' && l->src[3] == 'n'
        && l->src[4] == 't' && l->src[5] == 'e' && l->src[6] == 'r' && l->src[7] == 'r'
        && l->src[8] == 'u' && l->src[9] == 'p' && l->src[10] == 't' && l->src[11] == ']') {
        int line = l->line, col = l->col;
        for (int i = 0; i < 12; i++) lexer_advance(l);
        out->kind = TOKEN_ATTR_INTERRUPT;
        out->line = line;
        out->col = col;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    /* L6：#[send] 属性 token（下一 struct 可安全跨线程传递；设计决策标记）。 */
    if (c == '#' && l->src + 8 <= l->end && l->src[1] == '[' && l->src[2] == 's' && l->src[3] == 'e'
        && l->src[4] == 'n' && l->src[5] == 'd' && l->src[6] == ']') {
        int line = l->line, col = l->col;
        for (int i = 0; i < 7; i++) lexer_advance(l);
        out->kind = TOKEN_ATTR_SEND;
        out->line = line;
        out->col = col;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    /* L6：#[sync] 属性 token（下一 struct 可安全跨线程共享；设计决策标记）。 */
    if (c == '#' && l->src + 8 <= l->end && l->src[1] == '[' && l->src[2] == 's' && l->src[3] == 'y'
        && l->src[4] == 'n' && l->src[5] == 'c' && l->src[6] == ']') {
        int line = l->line, col = l->col;
        for (int i = 0; i < 7; i++) lexer_advance(l);
        out->kind = TOKEN_ATTR_SYNC;
        out->line = line;
        out->col = col;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    /* L1：#[global_allocator] 属性 token（下一 function 为全局分配器入口）。 */
    if (c == '#' && l->src + 20 <= l->end && l->src[1] == '[' && l->src[2] == 'g' && l->src[3] == 'l'
        && l->src[4] == 'o' && l->src[5] == 'b' && l->src[6] == 'a' && l->src[7] == 'l'
        && l->src[8] == '_' && l->src[9] == 'a' && l->src[10] == 'l' && l->src[11] == 'l'
        && l->src[12] == 'o' && l->src[13] == 'c' && l->src[14] == 'a' && l->src[15] == 't'
        && l->src[16] == 'o' && l->src[17] == 'r' && l->src[18] == ']') {
        int line = l->line, col = l->col;
        for (int i = 0; i < 19; i++) lexer_advance(l);
        out->kind = TOKEN_ATTR_GLOBAL_ALLOCATOR;
        out->line = line;
        out->col = col;
        out->value.ident = NULL;
        out->ident_len = 0;
        return;
    }
    /* #[cold] — 冷路径优化提示 */
    if (c == '#' && l->src + 7 <= l->end && l->src[1] == '[' && l->src[2] == 'c' && l->src[3] == 'o'
        && l->src[4] == 'l' && l->src[5] == 'd' && l->src[6] == ']') {
        int line = l->line, col = l->col;
        for (int i = 0; i < 7; i++) lexer_advance(l);
        out->kind = TOKEN_ATTR_COLD; out->line = line; out->col = col;
        out->value.ident = NULL; out->ident_len = 0; return;
    }
    /* #[panic_handler] — panic 处理函数 */
    if (c == '#' && l->src + 16 <= l->end && l->src[1] == '[' && l->src[2] == 'p' && l->src[3] == 'a'
        && l->src[4] == 'n' && l->src[5] == 'i' && l->src[6] == 'c' && l->src[7] == '_'
        && l->src[8] == 'h' && l->src[9] == 'a' && l->src[10] == 'n' && l->src[11] == 'd'
        && l->src[12] == 'l' && l->src[13] == 'e' && l->src[14] == 'r' && l->src[15] == ']') {
        int line = l->line, col = l->col;
        for (int i = 0; i < 16; i++) lexer_advance(l);
        out->kind = TOKEN_ATTR_PANIC_HANDLER; out->line = line; out->col = col;
        out->value.ident = NULL; out->ident_len = 0; return;
    }
    /* #[inline(never)] — 禁止内联 */
    if (c == '#' && l->src + 15 <= l->end && l->src[1] == '[' && l->src[2] == 'i' && l->src[3] == 'n'
        && l->src[4] == 'l' && l->src[5] == 'i' && l->src[6] == 'n' && l->src[7] == 'e'
        && l->src[8] == '(' && l->src[9] == 'n' && l->src[10] == 'e' && l->src[11] == 'v'
        && l->src[12] == 'e' && l->src[13] == 'r' && l->src[14] == ')') {
        int line = l->line, col = l->col;
        for (int i = 0; i < 15; i++) lexer_advance(l);
        if (l->src < l->end && lexer_peek(l) == ']') { lexer_advance(l); }
        out->kind = TOKEN_ATTR_INLINE_NEVER; out->line = line; out->col = col;
        out->value.ident = NULL; out->ident_len = 0; return;
    }
    /* #[inline(always)] — 强制内联 */
    if (c == '#' && l->src + 17 <= l->end && l->src[1] == '[' && l->src[2] == 'i' && l->src[3] == 'n'
        && l->src[4] == 'l' && l->src[5] == 'i' && l->src[6] == 'n' && l->src[7] == 'e'
        && l->src[8] == '(' && l->src[9] == 'a' && l->src[10] == 'l' && l->src[11] == 'w'
        && l->src[12] == 'a' && l->src[13] == 'y' && l->src[14] == 's' && l->src[15] == ')') {
        int line = l->line, col = l->col;
        for (int i = 0; i < 16; i++) lexer_advance(l);
        if (l->src < l->end && lexer_peek(l) == ']') { lexer_advance(l); }
        out->kind = TOKEN_ATTR_INLINE_ALWAYS; out->line = line; out->col = col;
        out->value.ident = NULL; out->ident_len = 0; return;
    }
    /* #[thread_local] — 线程局部存储 */
    if (c == '#' && l->src + 15 <= l->end && l->src[1] == '[' && l->src[2] == 't' && l->src[3] == 'h'
        && l->src[4] == 'r' && l->src[5] == 'e' && l->src[6] == 'a' && l->src[7] == 'd'
        && l->src[8] == '_' && l->src[9] == 'l' && l->src[10] == 'o' && l->src[11] == 'c'
        && l->src[12] == 'a' && l->src[13] == 'l' && l->src[14] == ']') {
        int line = l->line, col = l->col;
        for (int i = 0; i < 15; i++) lexer_advance(l);
        out->kind = TOKEN_ATTR_THREAD_LOCAL; out->line = line; out->col = col;
        out->value.ident = NULL; out->ident_len = 0; return;
    }
    /* #[percpu] — per-CPU 数据段 */
    if (c == '#' && l->src + 10 <= l->end && l->src[1] == '[' && l->src[2] == 'p' && l->src[3] == 'e'
        && l->src[4] == 'r' && l->src[5] == 'c' && l->src[6] == 'p' && l->src[7] == 'u'
        && l->src[8] == ']') {
        int line = l->line, col = l->col;
        for (int i = 0; i < 9; i++) lexer_advance(l);
        out->kind = TOKEN_ATTR_PERCPU; out->line = line; out->col = col;
        out->value.ident = NULL; out->ident_len = 0; return;
    }
    /* L4：#[max_stack(N)] 属性 token（下一 function 栈用量上限；value.int_val 为 N）。 */
    if (c == '#' && l->src + 14 <= l->end && l->src[1] == '[' && l->src[2] == 'm' && l->src[3] == 'a'
        && l->src[4] == 'x' && l->src[5] == '_' && l->src[6] == 's' && l->src[7] == 't'
        && l->src[8] == 'a' && l->src[9] == 'c' && l->src[10] == 'k' && l->src[11] == '(') {
        int line = l->line, col = l->col;
        for (int i = 0; i < 12; i++) lexer_advance(l); /* #[max_stack( */
        int n = 0;
        while (l->src < l->end && lexer_peek(l) >= '0' && lexer_peek(l) <= '9') {
            n = n * 10 + (lexer_advance(l) - '0');
        }
        if (l->src >= l->end || lexer_peek(l) != ')') return; /* parse error */
        lexer_advance(l); /* ) */
        if (l->src >= l->end || lexer_peek(l) != ']') return;
        lexer_advance(l); /* ] */
        out->kind = TOKEN_ATTR_MAX_STACK;
        out->line = line;
        out->col = col;
        out->value.int_val = n;
        out->ident_len = 0;
        return;
    }
    if (c == '"') {
        int line0 = l->line, col0 = l->col;
        lexer_advance(l); /* opening " */
        int off = 0;
        while (l->src < l->end && lexer_peek(l) != '"') {
            int ch = lexer_advance(l);
            if (ch == '\\' && l->src < l->end) {
                int esc = lexer_advance(l);
                if (off + 1 >= (int)sizeof(l->str_buf)) break;
                if (esc == 'n') l->str_buf[off++] = '\n';
                else if (esc == 't') l->str_buf[off++] = '\t';
                else if (esc == '\\' || esc == '"') l->str_buf[off++] = (char)esc;
                else l->str_buf[off++] = (char)esc;
                continue;
            }
            if (off + 1 >= (int)sizeof(l->str_buf)) break;
            l->str_buf[off++] = (char)ch;
        }
        if (l->src >= l->end || lexer_peek(l) != '"') {
            out->kind = TOKEN_EOF;
            out->line = line0;
            out->col = col0;
            out->value.ident = NULL;
            out->ident_len = 0;
            return;
        }
        lexer_advance(l); /* closing " */
        l->str_buf[off] = '\0';
        out->kind = TOKEN_STRING;
        out->line = line0;
        out->col = col0;
        out->value.ident = l->str_buf;
        out->ident_len = off;
        return;
    }
    if (isalpha((unsigned char)c) || c == '_') {
        lex_ident_or_keyword(l, out);
        return;
    }
    if (isdigit((unsigned char)c)) {
        lex_number(l, out);
        return;
    }
    /* 仅小数形式（如 .5、.5e2）：'.' 后接数字则解析为浮点字面量 */
    if (c == '.' && l->src + 1 < l->end && isdigit((unsigned char)l->src[1])) {
        lex_float_leading_dot(l, out);
        return;
    }

    int line = l->line, col = l->col;
    lexer_advance(l);
    out->line = line;
    out->col = col;
    out->value.int_val = 0;
    out->value.ident = NULL;
    out->ident_len = 0;

    switch (c) {
        case '(': out->kind = TOKEN_LPAREN; break;
        case ')': out->kind = TOKEN_RPAREN; break;
        case '{': out->kind = TOKEN_LBRACE; break;
        case '}': out->kind = TOKEN_RBRACE; break;
        case '[': out->kind = TOKEN_LBRACKET; break;
        case ']': out->kind = TOKEN_RBRACKET; break;
        case ',': out->kind = TOKEN_COMMA; break;
        case ':': out->kind = TOKEN_COLON; break;
        case '.': out->kind = TOKEN_DOT; break;
        case ';': out->kind = TOKEN_SEMICOLON; break;
        case '+':
            if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_PLUS_EQ; }
            else { out->kind = TOKEN_PLUS; }
            break;
        case '-':
            if (lexer_peek(l) == '>') { lexer_advance(l); out->kind = TOKEN_ARROW; }
            else if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_MINUS_EQ; }
            else { out->kind = TOKEN_MINUS; } /* 二元减 */
            break;
        case '*':
            if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_STAR_EQ; }
            else { out->kind = TOKEN_STAR; }   /* 二元乘 */
            break;
        case '/':
            if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_SLASH_EQ; }
            else { out->kind = TOKEN_SLASH; }  /* 二元除（// 已在 while 中跳过） */
            break;
        case '%':
            if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_PERCENT_EQ; }
            else { out->kind = TOKEN_PERCENT; } /* 取模 */
            break;
        case '^':
            if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_CARET_EQ; }
            else { out->kind = TOKEN_CARET; }   /* 按位异或 */
            break;
        case '~': out->kind = TOKEN_TILDE; break;   /* 按位取反 */
        case '&':
            if (lexer_peek(l) == '&') { lexer_advance(l); out->kind = TOKEN_AMPAMP; }
            else if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_AMP_EQ; }
            else { out->kind = TOKEN_AMP; }
            break;
        case '|':
            if (lexer_peek(l) == '|') { lexer_advance(l); out->kind = TOKEN_PIPEPIPE; }
            else if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_PIPE_EQ; }
            else { out->kind = TOKEN_PIPE; }
            break;
        case '<':
            if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_LE; }
            else if (lexer_peek(l) == '<') {
                lexer_advance(l);
                if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_LSHIFT_EQ; }
                else { out->kind = TOKEN_LSHIFT; }
            }
            else { out->kind = TOKEN_LT; }
            break;
        case '>':
            if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_GE; }
            else if (lexer_peek(l) == '>') {
                lexer_advance(l);
                if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_RSHIFT_EQ; }
                else { out->kind = TOKEN_RSHIFT; }
            }
            else { out->kind = TOKEN_GT; }
            break;
        case '!':
            if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_NE; }
            else { out->kind = TOKEN_BANG; }
            break;
        case '?': out->kind = TOKEN_QUESTION; break;  /* 三元运算符 cond ? then : else */
        case '@': out->kind = TOKEN_AT; break;       /* SIMD @shuffle / @select */
        case '=':
            if (lexer_peek(l) == '>') { lexer_advance(l); out->kind = TOKEN_FATARROW; }
            else if (lexer_peek(l) == '=') { lexer_advance(l); out->kind = TOKEN_EQ; }
            else { out->kind = TOKEN_ASSIGN; } /* 单 = 用于 let/const 初始化 */
            break;
        default:
            out->kind = TOKEN_EOF; /* 非法字符，用 EOF 表示错误，后续可增加 TOKEN_ERROR */
            break;
    }
}

/**
 * 释放 Lexer；见 lexer.h 中 lexer_free 注释。
 */
void lexer_free(Lexer *l) {
    free(l);
}
