/**
 * cfg_eval_link_alias.c — G-02-B1：cfg_eval.sx -E-extern 符号前缀转发
 *
 * cfg_eval_gen.c 导出 lexer_cfg_eval_expr_c 等；lexer/preprocess/runtime 仍期望
 * 裸名 cfg_eval_expr_c、cfg_apply_compile_target_from_triple、cfg_reset_compile_target。
 * 本 TU 仅做链接别名，逻辑在 cfg_eval.sx 生成物中。
 */
#include <stdint.h>

extern int32_t lexer_cfg_eval_expr_c(uint8_t *start, int32_t len);
extern void lexer_cfg_apply_compile_target_from_triple(uint8_t *triple, int32_t len);
extern void lexer_cfg_reset_compile_target(void);

/** #[cfg] 表达式求值；C ABI 裸名。 */
int cfg_eval_expr_c(const char *start, int len) {
    return (int)lexer_cfg_eval_expr_c((uint8_t *)start, len);
}

/** 应用 `-target` triple 覆盖。 */
void cfg_apply_compile_target_from_triple(const char *triple, int len) {
    lexer_cfg_apply_compile_target_from_triple((uint8_t *)triple, len);
}

/** 清除 triple 覆盖。 */
void cfg_reset_compile_target(void) {
    lexer_cfg_reset_compile_target();
}
