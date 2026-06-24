/**
 * lsp_codegen_extern.c — LSP -E-extern 跨 TU extern / inline 包装（io.o、heap.o、lsp_io_sx.o 桥接）。
 *
 * 自 codegen.c 内嵌块迁出，供 C codegen_library_module_to_c 与 codegen.sx（经 emit_to_buf）共用，
 * 避免在 codegen.c 手维护两份字符串。
 */
#include "lsp_codegen_extern.h"

#include <stddef.h>
#include <stdint.h>
#include <string.h>

/** 与 runtime.c 中 codegen_CodegenOutBuf 布局一致。 */
struct codegen_CodegenOutBuf {
  unsigned char data[9 * 1024 * 1024];
  int32_t len;
};

/** 路径是否 lsp_io.sx 的 -E-extern 入口。 */
int lsp_codegen_emit_path_is_lsp_io_sx(const char *path) {
  return path != NULL && strstr(path, "lsp_io.sx") != NULL;
}

/** 路径是否 lsp/lsp.sx 的 -E-extern 入口（排除 lsp_io 等子路径误匹配）。 */
int lsp_codegen_emit_path_is_lsp_main_sx(const char *path) {
  if (!path)
    return 0;
  if (strstr(path, "/lsp/lsp.sx") != NULL || strstr(path, "\\lsp\\lsp.sx") != NULL)
    return 1;
  if (strstr(path, "lsp/lsp.sx") != NULL && strstr(path, "lsp_io") == NULL)
    return 1;
  return 0;
}

static const char *lsp_heap_alias_block =
    "\n/* lsp_codegen_extern: std.heap typeck 链接别名（C-04 v0；std_io extern 由 codegen 自动生成） */\n"
    "extern uint8_t *typeck_std_heap_alloc(size_t size);\n"
    "extern void typeck_std_heap_free(uint8_t *ptr);\n"
    "#define std_heap_alloc typeck_std_heap_alloc\n"
    "#define std_heap_free typeck_std_heap_free\n";

static const char *lsp_io_extern_block =
    "\n/* lsp_codegen_extern: deprecated full io block — 保留给旧 bootstrap 路径 */\n"
    "extern int32_t std_io_read(size_t handle, uint8_t *ptr, size_t len, uint32_t timeout_ms);\n"
    "extern int32_t std_io_write(size_t handle, uint8_t *ptr, size_t len, uint32_t timeout_ms);\n"
    "extern void lsp_debug_u32(uint32_t n);\n"
    "#define typeck_lsp_debug_u32 lsp_debug_u32\n"
    "extern void lsp_debug_ptr(uint8_t *p);\n"
    "#define typeck_lsp_debug_ptr lsp_debug_ptr\n"
    "extern uint8_t *typeck_std_heap_alloc(size_t size);\n"
    "extern void typeck_std_heap_free(uint8_t *ptr);\n"
    "#define std_heap_alloc typeck_std_heap_alloc\n"
    "#define std_heap_free typeck_std_heap_free\n";

static const char *lsp_gen_extern_block =
    "\n/* lsp_codegen_extern: lsp.sx -E-extern stubs (lsp_io_sx.o 符号桥接) */\n"
    "extern ptrdiff_t typeck_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf);\n"
    "extern ptrdiff_t typeck_write_fd(int32_t fd, uint8_t *ptr, size_t count);\n"
    "extern uint8_t *typeck_lsp_alloc(size_t size);\n"
    "extern void typeck_lsp_free(uint8_t *ptr);\n"
    "extern int32_t typeck_lsp_is_null(uint8_t *ptr);\n"
    "extern int32_t typeck_extract_document_text(uint8_t *body, int32_t body_len, uint8_t *out_buf, int32_t out_cap);\n"
    "static inline ptrdiff_t lsp_io_read_message(int32_t fd, uint8_t *body_out, int32_t body_cap, uint8_t *state_buf) {\n"
    "  return typeck_read_message(fd, body_out, body_cap, state_buf);\n"
    "}\n"
    "static inline ptrdiff_t lsp_io_write_fd(int32_t fd, uint8_t *ptr, size_t count) {\n"
    "  return typeck_write_fd(fd, ptr, count);\n"
    "}\n"
    "static inline uint8_t *lsp_io_lsp_alloc(size_t size) {\n"
    "  return typeck_lsp_alloc(size);\n"
    "}\n"
    "static inline void lsp_io_lsp_free(uint8_t *ptr) {\n"
    "  typeck_lsp_free(ptr);\n"
    "}\n"
    "static inline int32_t lsp_io_lsp_is_null(uint8_t *ptr) {\n"
    "  return typeck_lsp_is_null(ptr);\n"
    "}\n"
    "static inline int32_t lsp_io_extract_document_text(uint8_t *body, int32_t body_len, uint8_t *out_buf, int32_t out_cap) {\n"
    "  return typeck_extract_document_text(body, body_len, out_buf, out_cap);\n"
    "}\n";

/** 追加文本到 CodegenOutBuf；容量不足返回 -1。 */
static int append_text_to_codegen_buf(struct codegen_CodegenOutBuf *out, const char *text) {
  size_t n;
  if (!out || !text)
    return -1;
  n = strlen(text);
  if (out->len < 0 || (size_t)out->len + n >= sizeof(out->data))
    return -1;
  memcpy(out->data + (size_t)out->len, text, n);
  out->len += (int32_t)n;
  return 0;
}

void lsp_codegen_emit_heap_alias_block(FILE *out) {
  if (out)
    fputs(lsp_heap_alias_block, out);
}

void lsp_codegen_emit_io_extern_block(FILE *out) {
  if (out)
    fputs(lsp_io_extern_block, out);
}

void lsp_codegen_emit_gen_extern_block(FILE *out) {
  if (out)
    fputs(lsp_gen_extern_block, out);
}

int lsp_codegen_emit_heap_alias_to_buf(struct codegen_CodegenOutBuf *out) {
  return append_text_to_codegen_buf(out, lsp_heap_alias_block);
}

int lsp_codegen_emit_io_extern_to_buf(struct codegen_CodegenOutBuf *out) {
  return append_text_to_codegen_buf(out, lsp_io_extern_block);
}

int lsp_codegen_emit_gen_extern_to_buf(struct codegen_CodegenOutBuf *out) {
  return append_text_to_codegen_buf(out, lsp_gen_extern_block);
}
