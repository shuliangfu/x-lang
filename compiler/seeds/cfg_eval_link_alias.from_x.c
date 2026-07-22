/* seeds/cfg_eval_link_alias.from_x.c — G-02f-79 product cold-start TU
 * Promoted from compiler/src/lexer/cfg_eval_link_alias.inc (alias/stub; retired .inc).
 * Compile: cc -c seeds/cfg_eval_link_alias.from_x.c  (or cc_inc_tu wrap).
 */
/**
 * cfg_eval_link_alias.c — G-02-B1：cfg_eval.x -E-extern 符号前缀转发 + host lit residual
 *
 * cfg_eval_gen.c 导出 lexer_cfg_eval_expr_c 等；lexer/preprocess/runtime 仍期望
 * 裸名 cfg_eval_expr_c、cfg_apply_compile_target_from_triple、cfg_reset_compile_target。
 * 本 TU 做链接别名；eval 逻辑在 cfg_eval.x 生成物中。
 *
 * wave98 Cap residual pure: host OS/arch lits live here (C #if), not multi-#[cfg]
 * same-name exports in cfg_eval.x (those dual-emit under -E-extern → illegal C →
 * silent bootstrap-stub pin = dual authority). Aligns with bootstrap stub values.
 * PLATFORM: SHARED — merged into cfg_eval.o with cfg_eval_x.o on product path.
 */
#include <stdint.h>

extern int32_t lexer_cfg_eval_expr_c(uint8_t *start, int32_t len);
extern void lexer_cfg_apply_compile_target_from_triple(uint8_t *triple, int32_t len);
extern void lexer_cfg_reset_compile_target(void);
extern void lexer_cfg_set_freestanding(int32_t v);

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

/** 设置 freestanding 模式标志；C ABI 裸名。 */
void cfg_set_freestanding(int v) {
    lexer_cfg_set_freestanding(v);
}

/**
 * Host target_os literal for cfg_eval.x export-extern cfg_host_os_lit.
 * PLATFORM: SHARED — compile-time host probe (same strings as bootstrap stub).
 * @return NUL-terminated static C string; never null
 */
uint8_t *cfg_host_os_lit(void) {
#if defined(__APPLE__)
  return (uint8_t *)(void *)"macos";
#elif defined(_WIN32) || defined(__CYGWIN__) || defined(__MINGW32__) || defined(__MSYS__)
  return (uint8_t *)(void *)"windows";
#elif defined(__linux__)
  return (uint8_t *)(void *)"linux";
#elif defined(__FreeBSD__)
  return (uint8_t *)(void *)"freebsd";
#else
  return (uint8_t *)(void *)"unknown";
#endif
}

/**
 * Host target_arch literal for cfg_eval.x export-extern cfg_host_arch_lit.
 * PLATFORM: SHARED — compile-time host probe (same strings as bootstrap stub).
 * @return NUL-terminated static C string; never null
 */
uint8_t *cfg_host_arch_lit(void) {
#if defined(__aarch64__) || defined(_M_ARM64)
  return (uint8_t *)(void *)"aarch64";
#elif defined(__x86_64__) || defined(_M_X64) || defined(__amd64__)
  return (uint8_t *)(void *)"x86_64";
#elif defined(__riscv) && (__riscv_xlen == 64)
  return (uint8_t *)(void *)"riscv64";
#else
  return (uint8_t *)(void *)"unknown";
#endif
}
