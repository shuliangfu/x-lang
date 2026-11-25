/*
 * Host-gcc twin of call_dispatch_load_ptr_le
 * (language in compiler/src/asm/backend_call_dispatch.x).
 *
 * Root (s57 typool compile of takes_ptr(&nl[0], 1) BUILD_RC=139 after
 *   funcs=2, after typool va_cap host-cc fold): typool first-wins T
 *   call_dispatch_load_ptr_le 0x1403f4604 (frame 0x98) is called from
 *   typool w1521_emit_call_body at 0x140430785 with (ctx, 16) for
 *   AsmFuncCtx.module_ref. typool of `p[off]` does
 *   `lea -0x10(%rbp),%rax` (address of the local that *holds* p) then
 *   `lea (%rax,%rbx,8),%rax` / `mov (%rax),%rax` (scale-8 through that
 *   pointer slot), reconstructing a garbage mod_ref 0x5bfade2d. That
 *   value is stored at typool emit_call_body -0x48(%rbp) and later passed
 *   as `mod` into typool glue_asm_build_call_export_sym_c; typool
 *   pipeline_module_num_funcs → pipe_load_i32_le+89 at 0x14015b251 then
 *   read-AVs (ER C0000005 info0=0 info1=0x5bfade2d). typool one_call_arg /
 *   typool emit_call_args never entered.
 *
 * Intended: load 8 LE bytes from p+off as *u8 (language lo/hi + hi<<32).
 * Actual: scale-8 through the stack slot of p (cousin of typool
 *   skip_generic_angle_list pointer-slot / typool i32_le scale-8).
 * Class: typool scale-8 of call_dispatch_load_ptr_le (own class; not the
 *   `&arr[0]` call-arg lea-of-slot face).
 * Fold allowlist: call_dispatch_load_ptr_le only.
 * Do not fold typool win_fwd_ret_call, typool pipe_load_i32_le, typool
 *   build_call_export_sym, typool emit_call_body, or typool try_emit.
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks including
 *   typool va_cap 0x140425f4c → 0x14a3e3c00 and i32_le 0x14a3e1200/1240.
 */
#include <stdint.h>

uint8_t *call_dispatch_load_ptr_le(uint8_t *p, int32_t off) {
  uint64_t m;
  uint64_t m2;
  uint64_t m3;
  uint64_t lo;
  uint64_t hi;
  if (p == 0) {
    return 0;
  }
  /* knife 254 / 9.2: avoid (m2*m2) wrap on tip pure-asm; host-cc uses the
   * same lo/hi + hi<<32 shape as language. */
  m = 256;
  m2 = 65536;
  m3 = 16777216;
  lo = (uint64_t)p[off];
  lo = lo + (uint64_t)p[off + 1] * m;
  lo = lo + (uint64_t)p[off + 2] * m2;
  lo = lo + (uint64_t)p[off + 3] * m3;
  hi = (uint64_t)p[off + 4];
  hi = hi + (uint64_t)p[off + 5] * m;
  hi = hi + (uint64_t)p[off + 6] * m2;
  hi = hi + (uint64_t)p[off + 7] * m3;
  return (uint8_t *)(lo + (hi << 32));
}
