/**
 * shux_layout_arith.h — typeck/codegen 布局与 size 算术溢出检查（P1-4）
 *
 * 文件职责：为 struct 布局、数组长度等 C 侧 int 累加提供 __builtin_*_overflow 包装，
 *           溢出时返回非 0，调用方须报错而非 silent wrap。
 * 所属模块：compiler/include/；由 typeck.c 等前端 C 代码 include。
 */
#ifndef SHUX_LAYOUT_ARITH_H
#define SHUX_LAYOUT_ARITH_H

#include <stddef.h>

/**
 * int 加法溢出检测：*out = a + b；溢出返回非 0。
 */
static inline int shux_layout_iadd_overflow(int a, int b, int *out) {
    return __builtin_add_overflow(a, b, out);
}

/**
 * int 乘法溢出检测：*out = a * b；溢出返回非 0。
 */
static inline int shux_layout_imul_overflow(int a, int b, int *out) {
    return __builtin_mul_overflow(a, b, out);
}

#endif /* SHUX_LAYOUT_ARITH_H */
