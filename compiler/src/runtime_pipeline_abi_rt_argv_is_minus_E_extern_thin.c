/* Host-gcc twin of rt_argv_is_minus_E_extern (rt_emit_flags.x).
 * typool first-wins T 0x140211094 (fromsrc_s76) compiles
 * `if (s == 0) return 0;` as `cmp rbx, rax` at 0x1402110ac
 * without loading rbx from the arg, so a stale rbx (0x2) skips
 * the early return. Writer RIP typool 0x1402110d0
 * (`movzx eax, BYTE PTR [rax]` on a NULL s). Caller return RIP
 * typool rt_scan_argv_emit + 181 at 0x140211395. GDB: first
 * call had a real rcx and passed; second call rcx=nil, then
 * SIGSEGV. typool rt_argv_is_minus_E in the same TU does load
 * rbx from the arg and is not this typool-wrong; typool
 * rt_scan_argv_emit argv[i] uses scale-8 on **u8 (correct) and
 * is not folded here. Host-gcc twin null-checks s, then compares
 * bytes 45,69,45,101,120,116,101,114,110,0. docs-only .x, do
 * not idx8. Do not JMP typool rec T 0x140087de4. */
#include <stdint.h>

int32_t rt_argv_is_minus_E_extern(uint8_t *s) {
  if (s == 0)
    return 0;
  if (s[0] != 45)
    return 0;
  if (s[1] != 69)
    return 0;
  if (s[2] != 45)
    return 0;
  if (s[3] != 101)
    return 0;
  if (s[4] != 120)
    return 0;
  if (s[5] != 116)
    return 0;
  if (s[6] != 101)
    return 0;
  if (s[7] != 114)
    return 0;
  if (s[8] != 110)
    return 0;
  if (s[9] != 0)
    return 0;
  return 1;
}
