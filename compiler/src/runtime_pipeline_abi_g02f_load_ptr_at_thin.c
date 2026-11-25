/* Source-faithful g02f_load_ptr_at twin
 * (compiler/src/asm/backend_try_inline_dispatch.x).
 * s159 hello-build residual: first-chance 0xC0000005 READ (write=0) at
 * host-cc pipe_load_i32_le+0x59 (0x140167181), fault/rax 0xfffeffee
 * (varies 0xffffffee / 0xffdfffee / 0xfffeffee), rbx=0xe. Caller
 * pipeline_module_num_funcs+0x2d <- typool glue_module_func_index_by_name
 * which correctly forwarded rcx=mod. typool glue_call_lookup stored
 * typool g02f_load_ptr_at(ctx, 16) into [rbp-0x48] as entry_mod and later
 * passed it as mod.
 * Live pin: typool g02f_load_ptr_at 0x1403ec5f4 entered once, rcx=ctx,
 * rdx=0x10, ret typool lookup+0x7a4; epilogue 0x1403ec7d4 returned
 * rax=0xfffeffee. typool glue then entered with rcx=0xfffeffee and the
 * READ AV followed immediately. typool g02f_store_ptr_at thin (already
 * folded) only forwarded that typool-load result and was not the
 * first producer.
 * typool family is the same scale-8 lea-of-local-slot as typool store:
 * source p[off+i] as usize became lea [rbp-0x10]; lea [rax+idx*8];
 * mov rax, [rax]; typool then shift/or the typool-wrong qwords into a
 * garbage pointer. Authority is the shift/or body, no div/mod.
 * typool glue / typool lookup / typool note / typool enc_* were not
 * folded. docs-only .x, do not idx8.
 */
#include <stdint.h>

uint8_t *g02f_load_ptr_at(uint8_t *p, int32_t off) {
  uintptr_t a;
  if (p == 0) {
    return (uint8_t *)0;
  }
  a = (uintptr_t)p[off + 0];
  a = a | (((uintptr_t)p[off + 1]) << 8);
  a = a | (((uintptr_t)p[off + 2]) << 16);
  a = a | (((uintptr_t)p[off + 3]) << 24);
  a = a | (((uintptr_t)p[off + 4]) << 32);
  a = a | (((uintptr_t)p[off + 5]) << 40);
  a = a | (((uintptr_t)p[off + 6]) << 48);
  a = a | (((uintptr_t)p[off + 7]) << 56);
  return (uint8_t *)a;
}
