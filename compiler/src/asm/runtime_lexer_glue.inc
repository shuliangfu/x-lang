/**
 * runtime_lexer_glue.c — Lexer 创建/释放（从 src/lexer/lexer.c 迁移）
 *
 * 【Why 逻辑根源】G-02a：将 LEGACY 前端 C（lexer.c）的运行时支持函数迁移到
 * compiler/src/asm/ 运行时层。lexer.c 的 lexer_next（C ABI）与 lexer.x 的
 * lexer_next（SHUX ABI：Lexer, u8[] -> LexerResult）签名不兼容，无法由 .x 替代。
 * no_c 模式不链 lexer.o，lexer_next 由 lexer_x.o 提供；LEGACY 模式（SHUX_LEGACY_C_FRONTEND=1）
 * 链 lexer.o 但缺 lexer_next 会链接失败 — 这是 G-02a 预期行为（LEGACY 模式已废弃，
 * 见 Makefile "G-02a：C 前端已删；SHUX_LEGACY_C_FRONTEND=1 不再支持"）。
 * cfg_* 3 符号由 cfg_eval_bootstrap_stub.c 提供；lexer_new/lexer_free 由此文件提供。
 *
 * 【Invariant】l 由 lexer_new 分配，调用方须用 lexer_free 释放；l 可为 NULL。
 *
 * 【Asm/Perf】仅 Lexer 创建/销毁时执行，非热路径，无性能影响。
 */

#include "win32_compat.h"
#include "lexer/lexer.h"
#include <stdlib.h>
#include <string.h>

struct Lexer {
    const char *src;  /**< 当前扫描位置 */
    const char *end;  /**< 源码结尾（不含 NUL） */
    int line;         /**< 当前行号，从 1 开始 */
    int col;          /**< 当前列号，从 1 开始 */
    char str_buf[512]; /**< 最近一次 TOKEN_STRING 解码内容（NUL 结尾） */
};

/**
 * 创建 Lexer；功能、参数、返回值、约定见 lexer.h 中 lexer_new 声明处注释。
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
 * 释放 Lexer 实例；功能、参数、约定见 lexer.h 中 lexer_free 声明处注释。
 */
void lexer_free(Lexer *l) {
    free(l);
}
