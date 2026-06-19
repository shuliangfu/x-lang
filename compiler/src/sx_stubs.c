/**
 * sx_stubs.c — SU 管线链接桩
 *
 * 职责：为 SU 自举编译器提供缺失符号（ASM 后端 / IO 批处理 / LSP 等尚未在 SU 路径实现的模块），
 * 以及处理 SU 生成代码中模块前缀命名不一致的桥接。
 */
#include <stdint.h>
#include <stddef.h>

/* ASM 后端 — 仅在 -backend asm 时使用，SU 路径走 C codegen 不需要 */
int asm_asm_codegen_ast(void *a, void *b, void *c, void *d) { return -1; }
int asm_asm_codegen_elf_o(void *a, void *b, void *c, void *d, void *e) { return -1; }

/* IO 批处理 — 未在 SU 路径实现 */
int io_read_batch_buf(void) { return -1; }
int io_write_batch_buf(void) { return -1; }

/* LSP — 未在 SU 路径实现 */
int typeck_lsp_main(void) { return -1; }

/* preprocess.preprocess_sx_buf 桥接：
 * SU 生成的 preprocess_su.o 导出 _typeck_preprocess_sx_buf，
 * 但 pipeline.sx 和 driver.sx 引用它为 preprocess.preprocess_sx_buf → _preprocess_sx_buf。
 * 此桥接将调用转给实际实现。 */
extern int32_t typeck_preprocess_sx_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf, int32_t out_cap);
int32_t preprocess_sx_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf, int32_t out_cap) {
    return typeck_preprocess_sx_buf(src, src_len, out_buf, out_cap);
}

/* ast_module_free — runtime_driver 的某些路径会调用 */
__attribute__((weak)) void ast_module_free(void *m) {}
