/**
 * typeck_lsp_io_stub.c — lsp_gen.c 期望的 typeck_* IO 符号桩（seed shux / strict_glue 共用）。
 *
 * lsp_io_gen.c 走 -E-extern 时 read_message 等由 typeck 模块 mangling 提供；
 * asm-only / 空 lsp_io 生成物时本 TU 供链接，完整 LSP 仍用 bootstrap 全量 shux-x。
 */
#include <stddef.h>
#include <stdint.h>

/** lsp.x 经 typeck 模块 mangling 的 read_message；桩返回 -1 表示 EOF/错误。 */
ptrdiff_t typeck_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf) {
  (void)fd;
  (void)body_out;
  (void)body_cap;
  (void)state_buf;
  return -1;
}

/** lsp_io 堆分配桩（勿用于生产 LSP）。 */
uint8_t *typeck_lsp_alloc(size_t size) {
  (void)size;
  return NULL;
}

/** lsp_io 释放桩。 */
void typeck_lsp_free(uint8_t *p) {
  (void)p;
}

/** lsp_io 空指针判断桩。 */
int32_t typeck_lsp_is_null(uint8_t *p) {
  return p == NULL ? 1 : 0;
}
