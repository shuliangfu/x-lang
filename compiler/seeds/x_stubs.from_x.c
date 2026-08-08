/* seeds/x_stubs.from_x.c — G-02f-79 product cold-start TU
 * Promoted from compiler/src/x_stubs.inc (alias/stub; retired .inc).
 * Compile: cc -c seeds/x_stubs.from_x.c  (or cc_inc_tu wrap).
 *
 * wave294 B′ G.7: single authority for cold X-pipeline stubs.
 * Host duals retired: compiler/_stubs.c + compiler/xlang_x_stubs.c (present−2).
 * Experimental build_and_test_x.sh links this seed only (not host leaves).
 * PLATFORM: SHARED — seed-only .o; product g05 does not need this TU today.
 */
/**
 * X pipeline link stubs (ASM backend / IO batch / LSP not on X path yet)
 * and name-bridge faces (preprocess_x_buf → typeck_preprocess_x_buf).
 */
#include <xlang_weak.h>
#include <stdint.h>
#include <stddef.h>

/* wave249/wave294 G.7: shell via public pure thin link_abi_system
 * (wave224 → _impl host system); not raw libc system.
 * Cap residual host system stays only link_abi_system_impl.
 * PLATFORM: SHARED — early/bootstrap stub face; host residual via single face. */
extern int link_abi_system(const char *cmd);

/* ASM backend — only for -backend asm; X path uses C codegen */
int asm_asm_codegen_ast(void *a, void *b, void *c, void *d) {
  (void)a;
  (void)b;
  (void)c;
  (void)d;
  return -1;
}
int asm_asm_codegen_elf_o(void *a, void *b, void *c, void *d, void *e) {
  (void)a;
  (void)b;
  (void)c;
  (void)d;
  (void)e;
  return -1;
}

/* IO batch — not implemented on X path */
int io_read_batch_buf(void) { return -1; }
int io_write_batch_buf(void) { return -1; }

/* LSP — not implemented on X path */
int typeck_lsp_main(void) { return -1; }

/* driver_exec_cmd — wave249 face (was xlang_x_stubs host only); experimental
 * build_and_test_x may need it. G.7: public pure thin link_abi_system. */
int32_t driver_exec_cmd(uint8_t *cmd) {
  return (int32_t)link_abi_system((const char *)cmd);
}

/* preprocess.preprocess_x_buf bridge:
 * X-generated preprocess_x.o exports typeck_preprocess_x_buf, but pipeline.x /
 * driver.x reference preprocess.preprocess_x_buf → preprocess_x_buf. */
extern int32_t typeck_preprocess_x_buf(const uint8_t *src, ptrdiff_t src_len,
                                       uint8_t *out_buf, int32_t out_cap);
int32_t preprocess_x_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf,
                         int32_t out_cap) {
  return typeck_preprocess_x_buf(src, src_len, out_buf, out_cap);
}

/* ast_module_free — some runtime_driver paths may call */
XLANG_WEAK void ast_module_free(void *m) { (void)m; }
