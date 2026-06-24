/**
 * autovec.h — loop autovec 受限模式（VEC-V1/V2/V3）。
 * V1：for f32 点积；V2：while + f32 sum/dot；V3：SoA arr[i].field 列归约。
 */
#ifndef SHUX_AUTovec_H
#define SHUX_AUTovec_H

#include <stdio.h>
#include <stdint.h>

struct ASTBlock;
struct ASTForLoop;
struct ASTWhileLoop;
struct ASTExpr;

/** 归约 autovec 种类。 */
typedef enum AutovecReductionKind {
    AUTovec_REDUCTION_DOT = 0,
    AUTovec_REDUCTION_SUM = 1
} AutovecReductionKind;

/** codegen 侧 emit 回调（contig 指针 / SoA 列首 / stride）。 */
typedef struct AutovecCodegenHooks {
    /** 连续 f32 列或 *f32 / slice.data 指针。 */
    int (*emit_contig_ptr)(FILE *out, const struct ASTExpr *base);
    /** SoA/AoS struct 数组：&arr[0].field 列首指针。 */
    int (*emit_soa_f32_col0)(FILE *out, const struct ASTExpr *field_access);
    /** arr[i].field 相邻同字段步长（以 f32 个数计）。 */
    int (*soa_stride_floats)(const struct ASTExpr *field_access);
} AutovecCodegenHooks;

/** 点积/求和 autovec 匹配结果。 */
typedef struct AutovecReductionMatch {
    AutovecReductionKind kind;
    const char *acc_name;   /**< 累加变量名（f32），如 s */
    const char *idx_name;   /**< 循环下标变量名，如 i */
    const char *bound_name; /**< 上界变量名（cond 右操作数为 var 时） */
    int bound_is_lit;       /**< 1 表示 bound_lit 有效（cond 右为整型常量） */
    int32_t bound_lit;      /**< 上界字面量，如 4 */
    const struct ASTExpr *arr_a; /**< 左数组/指针（或 slice）；求和 contig 时用 */
    const struct ASTExpr *arr_b; /**< 点积右操作数；求和时为 NULL */
    int sum_strided;        /**< 1 表示 SoA f32 字段列归约（VEC-V3） */
    const struct ASTExpr *soa_field_expr; /**< arr[i].field 完整表达式 */
} AutovecReductionMatch;

/** 兼容 V1 别名。 */
typedef AutovecReductionMatch AutovecDotMatch;

/** 是否启用 loop autovec（SHUX_NO_AUTovec=1 时关闭）。 */
int autovec_enabled(void);

/** 新 TU emit 前重置（避免跨模块复用旧状态）。 */
void autovec_reset_emit_state(void);

/** 向 TU 输出 shux_autovec_* static inline 前置（仅一次）。 */
int autovec_emit_preamble(FILE *out);

/** 匹配 for 循环 f32 点积；成功返回 1。 */
int autovec_match_dot_for(const struct ASTForLoop *fl, const struct ASTBlock *parent,
    AutovecReductionMatch *m);

/** 匹配 while 循环 f32 点积或求和；成功返回 1。 */
int autovec_match_reduction_while(const struct ASTWhileLoop *wl, const struct ASTBlock *parent,
    AutovecReductionMatch *m);

/** 发射 for 点积 autovec；1=已替换，0=未匹配，-1=错误。 */
int autovec_try_emit_dot_for(FILE *out, const char *pad, const struct ASTBlock *parent,
    const struct ASTForLoop *fl, const AutovecCodegenHooks *hooks);

/** 发射 while 归约 autovec（dot/sum）；1=已替换，0=未匹配，-1=错误。 */
int autovec_try_emit_reduction_while(FILE *out, const char *pad, const struct ASTBlock *parent,
    const struct ASTWhileLoop *wl, const AutovecCodegenHooks *hooks);

#endif /* SHUX_AUTovec_H */
