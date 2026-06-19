/**
 * lexer.h — 词法分析器接口
 *
 * 文件职责：声明 Lexer 类型及创建/取 Token/释放接口，供 Parser 与 Driver 将 .sx 源码转为 Token 流。
 * 所属模块：编译器前端 lexer，compiler/src/lexer/；被 src/parser、src/main 引用。
 * 与其它文件的关系：依赖 include/token.h 的 Token/TokenKind；实现位于 lexer.c，不暴露内部结构体布局。
 * 重要约定：源码字符串 source 在 lexer 使用期间不得被修改或释放；Token 的 value.ident 指向 source 内片段，调用方在消费 Token 前不得 free source。
 */

#ifndef SHUX_LEXER_H
#define SHUX_LEXER_H

#include "token.h"

/**
 * B-01：求值 #[cfg(...)] 括号内表达式（target_os/target_arch、all/not）。
 * B-02：若已通过 cfg_apply_compile_target_from_triple 设置 -target，则按 triple 而非 host 求值。
 * 参数：start 为 cfg( 后首字符；len 为表达式字节数（不含外层闭合 ')'）。
 * 返回值：非 0 表示当前 effective target 匹配，应保留下一顶层项；0 表示剪枝跳过。
 */
int cfg_eval_expr_c(const char *start, int len);

/**
 * B-02：从 `-target` triple 字符串解析 os/arch 并覆盖 #[cfg] 求值上下文。
 * 参数：triple 如 x86_64-unknown-linux-gnu；len 为字节数。
 */
void cfg_apply_compile_target_from_triple(const char *triple, int len);

/** B-02：清除 triple 覆盖，#[cfg] 回退为 host OS/arch。 */
void cfg_reset_compile_target(void);

/**
 * B-02：按 DriverCompileState 的 target_buf 同步 #[cfg] 上下文（有 -target 则应用，否则 reset）。
 * 参数：state 可为 NULL（等价 reset）。
 */
void cfg_sync_compile_target_from_state_c(void *state);

/** Lexer 状态（不透明，在 .c 中定义） */
typedef struct Lexer Lexer;

/**
 * 从以 NUL 结尾的源码创建 Lexer。
 * 功能说明：初始化内部指针与行号列号，供后续 lexer_next 逐 Token 扫描。
 * 参数：source 源码字符串，须以 NUL 结尾；生命周期由调用方保持，在 lexer_free 之前不得修改或释放。
 * 返回值：成功返回新建 Lexer*，失败（如 malloc 失败）返回 NULL；调用方须用 lexer_free 释放。
 * 错误与边界：source 为 NULL 时行为未定义；空字符串合法，首次 lexer_next 即得 TOKEN_EOF。
 * 副作用与约定：分配一块 Lexer 结构体内存；不修改 source。
 */
Lexer *lexer_new(const char *source);

/**
 * 取下一个 Token 并写入 out。
 * 功能说明：跳过空白与行注释，识别关键字/标识符/整数字面量/符号，填充 out；到达源码末尾时 out->kind 为 TOKEN_EOF。
 * 参数：l Lexer 实例，不可为 NULL；out 输出缓冲区，不可为 NULL，写入的 value.ident 指向 l 对应源码，须在 source 有效期内使用。
 * 返回值：无。
 * 错误与边界：l 或 out 为 NULL 时行为未定义；TOKEN_INT 时 out->value.int_val 有效，IDENT/I32 时 out->value.ident 与 ident_len 有效。
 * 副作用与约定：推进 l 内部指针；可能修改 l->line/l->col；不分配内存（除 Lexer 内部状态）。
 */
void lexer_next(Lexer *l, Token *out);

/**
 * 释放 Lexer 实例。
 * 功能说明：回收 lexer_new 分配的内存；调用后 l 不可再使用。
 * 参数：l 由 lexer_new 返回的指针；可为 NULL（此时无操作）。
 * 返回值：无。
 * 错误与边界：同一指针不得重复 free；释放后不得再调用 lexer_next。
 * 副作用与约定：仅释放 Lexer 结构体，不释放 source。
 */
void lexer_free(Lexer *l);

#endif /* SHUX_LEXER_H */
