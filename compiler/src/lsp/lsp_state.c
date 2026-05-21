/**
 * lsp_state.c — LSP read_message 的 state 缓冲区，单独编译单元避免被同单元内大数组/栈覆盖。
 * 供 lsp_gen.c 通过 extern 使用（生成代码里 state_buf 被 sed 替换为 g_lsp_state_buf）。
 */
#include <stdint.h>

uint8_t g_lsp_state_buf[16388];

/** 供 lsp.su read_message 使用，避免 lsp_main 栈上再放 16KiB state（与 g_lsp_state_buf 同缓冲）。 */
uint8_t *lsp_state_buf_ptr(void) {
    return g_lsp_state_buf;
}
