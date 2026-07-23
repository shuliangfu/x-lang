/* seeds/cfg_eval_host_lit.from_x.c — wave98 host OS/arch lit residual
 *
 * PLATFORM: SHARED — C #if host probe (same strings as bootstrap stub /
 * cfg_eval_link_alias). Used when product -E emits bare cfg_* names (no
 * lexer_ prefix) so we must not link the full link_alias (would dual-define
 * cfg_eval_expr_c). Mac -E-extern path still uses full link_alias which
 * includes these lits as well.
 *
 * Compile: cc -c / cc_inc_tu seeds/cfg_eval_host_lit.from_x.c
 */
#include <stdint.h>

/**
 * Host target_os literal for cfg_eval.x export-extern cfg_host_os_lit.
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
