/* Host-gcc twin of cfg_sync_compile_target_from_state_c (rt_compile.x).
 * typool first-wins T 0x140215604 (fromsrc_s81) compiles
 * `cfg_apply_compile_target_from_triple(&st.target_buf[0], st.target_len)`
 * as shallow lea through &st (the local pointer slot at [rbp-0x20]):
 *   lea rax,[rbp-0x20]; add rax,0x410  -> stack addr as "triple"
 *   lea rax,[rbp-0x20]; add rax,0x610; mov eax,[rax] -> stack dword as "len"
 * Writer RIP typool 0x1402156b2 (build &st+0x410) / typool 0x1402156c0
 * (load through &st+0x610); call at typool 0x1402156d6. GDB: entered from
 * thin driver_compile_parse_argv_impl_c + 227 (caller return RIP
 * 0x1400018e3) with real heap state 0x20733c60; REAL heap
 * parse_saw_target=0 target_len=0 (should cfg_reset), but typool read
 * stack garbage and called apply with rcx=0x103fe250 rdx=0x103fe4c0
 * (pointer bit-patterns). Thin lexer_cfg_parse_triple_literals then hung
 * in contains_ci on the huge fake tlen. Host-gcc twin indexes through
 * the heap pointer. Layout matches RtCompileState (target_buf@0x410,
 * target_len@0x610, parse_saw_target@0x62c). docs-only .x, do not idx8.
 * Do not JMP typool rec T 0x140087de4. Do not fold typool cfg_apply /
 * contains_ci / diag_io_fputc / runtime_read_file_malloc in this thin. */
#include <stdint.h>

extern void cfg_apply_compile_target_from_triple(uint8_t *triple, int32_t len);
extern void cfg_reset_compile_target(void);

enum { OFF_TARGET_BUF = 0x410 };
enum { OFF_TARGET_LEN = 0x610 };
enum { OFF_PARSE_SAW_TARGET = 0x62c };

void cfg_sync_compile_target_from_state_c(uint8_t *state) {
  int32_t parse_saw;
  int32_t target_len;

  if (state == 0) {
    cfg_reset_compile_target();
    return;
  }
  parse_saw = *(int32_t *)(state + OFF_PARSE_SAW_TARGET);
  if (parse_saw != 0) {
    target_len = *(int32_t *)(state + OFF_TARGET_LEN);
    if (target_len > 0) {
      cfg_apply_compile_target_from_triple(state + OFF_TARGET_BUF, target_len);
      return;
    }
  }
  cfg_reset_compile_target();
}
