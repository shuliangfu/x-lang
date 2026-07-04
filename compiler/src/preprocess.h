/**
 * preprocess.h — .x 条件编译预处理（#if / #else / #endif）
 *
 * 文件职责：声明预处理接口，供 main 在将源码交给 lexer 前按条件过滤 #if 块，实现标准库按 OS 选实现。
 * 约定：支持 #if COND、#elseif COND、#else、#endif；COND 可为 -D 符号或 target_os/target_arch 表达式（与 #[cfg] 对齐）。
 */

#ifndef SHUX_PREPROCESS_H
#define SHUX_PREPROCESS_H

#include <stddef.h>
#include <stdint.h>

/**
 * 对源码做条件编译预处理，保留「条件成立」分支的代码，被跳过行以空行占位以保持行号一致。
 * 参数：source 为源码指针；source_len 为源码字节数（若为 0 则按 NUL 结尾用 strlen 取长，仅兼容旧调用）；
 *       defines 为已定义符号数组；ndefines 为数组长度；
 *       out_length 若非 NULL，返回输出缓冲区有效字节数（不含结尾 NUL），供 slice 使用。
 * 约定：按 source_len 字节扫描，不依赖 source 内 NUL，避免嵌入 NUL 导致截断（bar→ba、main→mai）。
 * 返回值：成功返回 malloc 的字符串（调用方须 free）；失败返回 NULL 并可能写 stderr。
 */
char *preprocess(const char *source, size_t source_len, const char **defines, int ndefines, size_t *out_length);

/** C 实现：供 runtime.c 在 ndefines>0 或 .x 不可用时调用；6.4 迁 .x 后由 preprocess_x 处理 ndefines==0。 */
char *preprocess_c_fallback(const char *source, size_t source_len, const char **defines, int ndefines, size_t *out_length);

/**
 * 求值 #if / #elseif 条件：纯标识符查 defines；-D 宏；target_os/target_arch 表达式走 #[cfg] 同款 cfg_eval。
 * 参数：cond 以 NUL 结尾；defines/ndefines 为 -D 与 SHUX_OS_* 注入符号。
 * 返回值：非 0 表示条件成立。
 */
int preprocess_eval_condition(const char *cond, const char **defines, int ndefines);

/**
 * 兼容 runtime_pipeline_abi / legacy shux-c 的固定缓冲接口。
 * 参数：source_buf/source_len 为输入源码；out_buf/out_cap 为调用方提供的输出缓冲。
 * 返回值：成功返回输出字节数；失败返回 -1。
 */
int32_t preprocess_x_buf(const uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf, int32_t out_cap);

/** 与 seed/selfhost 链兼容的别名。 */
int32_t typeck_preprocess_x_buf(const uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf, int32_t out_cap);

/** runtime_pipeline_abi 的 -D 注入接口。 */
void preprocess_define_reset(void);
void preprocess_define_add(const char *name);
int32_t preprocess_if_stack_len(void);

#endif /* SHUX_PREPROCESS_H */
