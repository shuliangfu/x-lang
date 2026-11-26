/* Host-gcc twin of driver_compile_parse_argv_init_c (rt_compile.x).
 *
 * DIG s238: tipU first-wins T compiles every `state.field = …` as shallow
 * lea through &state (local pointer slot at [rbp-0x10]):
 *   lea rax,[rbp-0x10]; add rax,OFF; mov [rbx],eax
 * Writer offsets include path_len@0x200 / out_path_len@0x404 /
 * use_asm_backend@0x408 / … / print_target_cpu@0x6b8. Those stores smash
 * the caller frame (host-cc parse_argv_impl → full_x -0x28 state ptr →
 * SEGV at state+0x6b8). Host-gcc twin indexes through the heap pointer.
 * Layout matches RtCompileState / seeds DriverCompileStateSU.
 * docs-only .x, do not idx8. PLATFORM: SHARED host-cc.
 */
#include <stdint.h>

extern void cfg_reset_compile_target(void);
extern void driver_freestanding_set(int32_t on);
extern void cfg_set_freestanding(int32_t on);
extern void driver_emit_lib_root_reset(void *state);

enum { OFF_PATH_LEN = 0x200 };
enum { OFF_OUT_PATH_LEN = 0x404 };
enum { OFF_USE_ASM_BACKEND = 0x408 };
enum { OFF_TARGET_ARCH = 0x40c };
enum { OFF_TARGET_LEN = 0x610 };
enum { OFF_OPT_LEVEL_BUF = 0x614 };
enum { OFF_OPT_LEVEL_LEN = 0x61c };
enum { OFF_USE_LTO = 0x620 };
enum { OFF_BACKEND_ASM_EXPLICIT = 0x624 };
enum { OFF_USE_FREESTANDING = 0x628 };
enum { OFF_PARSE_SAW_TARGET = 0x62c };
enum { OFF_TARGET_CPU_LEN = 0x6b0 };
enum { OFF_TARGET_CPU_FEATURES = 0x6b4 };
enum { OFF_PRINT_TARGET_CPU = 0x6b8 };
enum { OFF_PARSE_SAW_TARGET_CPU = 0x6bc };

void driver_compile_parse_argv_init_c(void *state) {
  uint8_t *p;

  if (state == 0)
    return;
  p = (uint8_t *)state;
  cfg_reset_compile_target();
  *(int32_t *)(p + OFF_PATH_LEN) = 0;
  *(int32_t *)(p + OFF_OUT_PATH_LEN) = 0;
  *(int32_t *)(p + OFF_USE_ASM_BACKEND) = 1;
  *(int32_t *)(p + OFF_TARGET_ARCH) = 0;
  *(int32_t *)(p + OFF_TARGET_LEN) = 0;
  *(int32_t *)(p + OFF_OPT_LEVEL_LEN) = 1;
  p[OFF_OPT_LEVEL_BUF] = 50;
  *(int32_t *)(p + OFF_USE_LTO) = 0;
  *(int32_t *)(p + OFF_BACKEND_ASM_EXPLICIT) = 0;
  *(int32_t *)(p + OFF_USE_FREESTANDING) = 0;
  *(int32_t *)(p + OFF_PARSE_SAW_TARGET) = 0;
  *(int32_t *)(p + OFF_TARGET_CPU_LEN) = 0;
  *(int32_t *)(p + OFF_TARGET_CPU_FEATURES) = 0;
  *(int32_t *)(p + OFF_PRINT_TARGET_CPU) = 0;
  *(int32_t *)(p + OFF_PARSE_SAW_TARGET_CPU) = 0;
  driver_freestanding_set(0);
  cfg_set_freestanding(0);
  driver_emit_lib_root_reset(state);
}
