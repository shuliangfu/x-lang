/* Host-gcc twin of driver_compile_state_alloc_c (rt_compile.x).
 * typool first-wins T 0x1402153cc (fromsrc_s78) compiles
 * `state.use_asm_backend = 1` / `state.opt_level_buf[0] = 50` /
 * `state.opt_level_len = 1` as shallow lea through &state (the local
 * pointer slot), not through the heap pointer value:
 *   lea rax,[rbp-0x18]; add rax,0x408; mov DWORD PTR [rbx],eax
 * Writer RIP typool 0x14021547a (use_asm_backend); same-class writers
 * typool 0x140215490 (opt_level_buf[0]=50) and typool 0x1402154a6
 * (opt_level_len=1). GDB: malloc returned heap 0x205f3cc0; stores went
 * to stack rbp+0x3f0 / rbp+0x5fc / rbp+0x604 (caller
 * driver_run_compiler_full_x_impl_c frame), smashing its locals.
 * Caller return RIP typool driver_run_compiler_full_x_impl_c + 0x12d
 * at 0x14021a691. Later STATUS_HEAP_CORRUPTION c0000374
 * (ntdll!LdrResSearchResource first-chance). Host-gcc twin writes the
 * three fields through the heap pointer. Layout matches RtCompileState
 * / seeds DriverCompileStateSU (1728B; use_asm_backend@0x408,
 * opt_level_buf@0x614, opt_level_len@0x61c). docs-only .x, do not idx8.
 * Do not JMP typool rec T 0x140087de4. Do not fold typool
 * driver_compile_state_free_c / diag_io_fputc / runtime_read_file_malloc
 * in this thin. */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

enum { XLANG_RT_COMPILE_STATE_SIZE = 1728 };
enum { XLANG_RT_COMPILE_OFF_USE_ASM_BACKEND = 0x408 };
enum { XLANG_RT_COMPILE_OFF_OPT_LEVEL_BUF = 0x614 };
enum { XLANG_RT_COMPILE_OFF_OPT_LEVEL_LEN = 0x61c };

void *driver_compile_state_alloc_c(void) {
  uint8_t *p;
  int32_t *use_asm;
  int32_t *opt_len;

  p = (uint8_t *)malloc((size_t)XLANG_RT_COMPILE_STATE_SIZE);
  if (p == 0)
    return 0;
  memset(p, 0, (size_t)XLANG_RT_COMPILE_STATE_SIZE);
  use_asm = (int32_t *)(p + XLANG_RT_COMPILE_OFF_USE_ASM_BACKEND);
  *use_asm = 1;
  p[XLANG_RT_COMPILE_OFF_OPT_LEVEL_BUF] = 50;
  opt_len = (int32_t *)(p + XLANG_RT_COMPILE_OFF_OPT_LEVEL_LEN);
  *opt_len = 1;
  return (void *)p;
}
