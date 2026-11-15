/* Host-gcc twin of driver_compile_parse_argv_impl_c (rt_compile.x).
 * typool first-wins T 0x140215288 (fromsrc_s79) compiles field reads and
 * the store `state.target_arch = ...` as shallow lea through &state (the
 * local pointer slot at [rbp-0x20]), not through the heap pointer:
 *   lea rax,[rbp-0x20]; add rax,OFF; mov eax,[rax] / mov [rbx],eax
 * Live this turn after host-cc driver_compile_state_alloc_c: GDB
 * ENTER_RESOLVE_ARCH rcx=nil rdx=nil because typool read target_arch and
 * parse_saw_target from stack; writer store RIP typool 0x140215400
 * (&state+0x40c) smashes the caller frame. Caller return RIP typool
 * driver_run_compiler_full_x_impl_c after parse_argv call. Same-class as
 * typool driver_compile_state_alloc_c shallow-lea through &state.
 * Host-gcc twin indexes through the heap pointer. docs-only .x, do not
 * idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

extern void driver_compile_parse_argv_init_c(void *state);
extern void driver_compile_parse_argv_scan_c(int32_t argc, uint8_t **argv, void *state);
extern void driver_compile_resolve_target_cpu_c(void *state);
extern int32_t driver_resolve_target_arch(int32_t parsed_target, int32_t saw_target_flag);
extern void cfg_sync_compile_target_from_state_c(void *state);
extern void driver_compile_ensure_default_lib_c(void *state);

enum { OFF_PATH_LEN = 0x200 };
enum { OFF_TARGET_ARCH = 0x40c };
enum { OFF_PARSE_SAW_TARGET = 0x62c };
enum { OFF_PRINT_TARGET_CPU = 0x6b8 };

int32_t driver_compile_parse_argv_impl_c(int32_t argc, uint8_t **argv, void *state) {
  uint8_t *p;
  int32_t path_len;
  int32_t print_cpu;
  int32_t target_arch;
  int32_t saw_target;

  if (argc < 2)
    return 1;
  if (state == 0)
    return 1;
  p = (uint8_t *)state;
  driver_compile_parse_argv_init_c(state);
  driver_compile_parse_argv_scan_c(argc, argv, state);
  driver_compile_resolve_target_cpu_c(state);
  print_cpu = *(int32_t *)(p + OFF_PRINT_TARGET_CPU);
  if (print_cpu != 0)
    return 0;
  path_len = *(int32_t *)(p + OFF_PATH_LEN);
  if (path_len <= 0)
    return 1;
  target_arch = *(int32_t *)(p + OFF_TARGET_ARCH);
  saw_target = *(int32_t *)(p + OFF_PARSE_SAW_TARGET);
  target_arch = driver_resolve_target_arch(target_arch, saw_target);
  *(int32_t *)(p + OFF_TARGET_ARCH) = target_arch;
  cfg_sync_compile_target_from_state_c(state);
  driver_compile_ensure_default_lib_c(state);
  return 0;
}
