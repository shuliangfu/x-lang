/* seeds/runtime_process_args_thin.from_x.c — process_args_count_c / process_arg_c
 *
 * PLATFORM: SHARED — process_merge piece (with argv + os_glue + import_alias).
 *
 * Why: product `-x -E` for library modules historically truncated mid-emit
 * after the giant rt_preamble (stdout cut at 16–20KiB page align). process.x is
 * two thin wrappers; this seed is the cold authority for process_args_*_c
 * until full library -E emit is restored (same semantics as process.x 1:1).
 *
 * process.o = this TU + runtime_process_argv.o + runtime_process_os_glue.o
 *           + runtime_process_import_alias.from_x.c (std_process_* product face).
 * Pure-asm import METHOD needs the namespaced face in process.o (no mod.x
 * co-emit). G.7: import_alias is the single product-face vehicle.
 *
 * Invariant: bare symbols process_args_count_c / process_arg_c only forward
 * argv glue (process_xlang_*). Do not add std_process_* here — that is alias.
 */
#include <stdint.h>

extern int32_t process_xlang_argc_get(void);
extern uint8_t *process_xlang_argv_get(int32_t i);

int32_t process_args_count_c(void) {
    return process_xlang_argc_get();
}

uint8_t *process_arg_c(int32_t i) {
    return process_xlang_argv_get(i);
}
