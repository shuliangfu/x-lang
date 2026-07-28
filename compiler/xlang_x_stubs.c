#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

/* wave249 G.7: shell via public pure thin link_abi_system (wave224 → _impl host system);
 * not raw libc system. Cap residual host system stays only link_abi_system_impl.
 * pure thin already gates null/empty cmd → -1 (same as prior stub ternary).
 * PLATFORM: SHARED — early/bootstrap stub face; host residual via single face. */
extern int link_abi_system(const char *cmd);

int32_t asm_asm_codegen_ast(void *mod, void *arena, void *out_buf, void *ctx) { (void)mod;(void)arena;(void)out_buf;(void)ctx; return -1; }
int32_t asm_asm_codegen_elf_o(void *mod, void *arena, void *ctx, void *elf_ctx, void *out_buf) { (void)mod;(void)arena;(void)ctx;(void)elf_ctx;(void)out_buf; return -1; }
int32_t driver_exec_cmd(uint8_t *cmd) {
  /* wave249 G.7: public pure thin link_abi_system (not raw libc system). */
  return (int32_t)link_abi_system((const char *)cmd);
}
ptrdiff_t io_read_batch_buf(void *a, void *b, int n, unsigned timeout_ms) { (void)a;(void)b;(void)n;(void)timeout_ms; return -1; }
ptrdiff_t io_write_batch_buf(void *a, void *b, int n, unsigned timeout_ms) { (void)a;(void)b;(void)n;(void)timeout_ms; return -1; }
int32_t typeck_lsp_main(int32_t mode) { (void)mode; return 0; }
int32_t preprocess_x_buf(uint8_t *src, ptrdiff_t srclen, uint8_t *out, int32_t outcap) {
    if (!src || !out || srclen <= 0 || outcap <= 0) return -1;
    size_t n = (size_t)(srclen < outcap ? srclen : outcap);
    for (size_t i = 0; i < n; i++) out[i] = src[i];
    return (int32_t)n;
}
