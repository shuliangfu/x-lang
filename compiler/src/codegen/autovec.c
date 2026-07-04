/**
 * autovec.c — loop autovec 冷启动桩（G-02a 真实现已迁入 codegen.x；strict 链仍须本 TU 符号）
 *
 * B-strict / relink 脚本会 cc -c 本文件为 seed autovec.o；默认关闭 autovec 匹配。
 */
#include "autovec.h"

#include <stdlib.h>

/** 是否启用 loop autovec（SHUX_NO_AUTovec=1 时关闭）。 */
int autovec_enabled(void) {
    const char *env = getenv("SHUX_NO_AUTovec");
    if (env != NULL && env[0] == '1')
        return 0;
    return 0;
}

/** 新 TU emit 前重置。 */
void autovec_reset_emit_state(void) {
}

/** 向 TU 输出 autovec 前置；桩实现无输出。 */
int autovec_emit_preamble(FILE *out) {
    (void)out;
    return 0;
}

/** 匹配 for 点积；桩始终未匹配。 */
int autovec_match_dot_for(const struct ASTForLoop *fl, const struct ASTBlock *parent,
                          AutovecReductionMatch *m) {
    (void)fl;
    (void)parent;
    (void)m;
    return 0;
}

/** 匹配 while 归约；桩始终未匹配。 */
int autovec_match_reduction_while(const struct ASTWhileLoop *wl, const struct ASTBlock *parent,
                                  AutovecReductionMatch *m) {
    (void)wl;
    (void)parent;
    (void)m;
    return 0;
}

/** 发射 for 点积 autovec；桩始终未匹配。 */
int autovec_try_emit_dot_for(FILE *out, const char *pad, const struct ASTBlock *parent,
                             const struct ASTForLoop *fl, const AutovecCodegenHooks *hooks) {
    (void)out;
    (void)pad;
    (void)parent;
    (void)fl;
    (void)hooks;
    return 0;
}

/** 发射 while 归约 autovec；桩始终未匹配。 */
int autovec_try_emit_reduction_while(FILE *out, const char *pad, const struct ASTBlock *parent,
                                     const struct ASTWhileLoop *wl,
                                     const AutovecCodegenHooks *hooks) {
    (void)out;
    (void)pad;
    (void)parent;
    (void)wl;
    (void)hooks;
    return 0;
}
