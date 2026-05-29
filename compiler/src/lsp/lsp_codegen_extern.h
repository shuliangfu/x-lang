/**
 * lsp_codegen_extern.h — LSP -E-extern 跨 TU 符号声明（io.o / heap.o / lsp_io_su.o 桥接）。
 *
 * 原内嵌于 codegen.c 的 lsp_io_extern / lsp_gen_extern 等价块，集中于此供 C codegen 与 codegen.su 共用。
 */
#ifndef SHU_LSP_CODEGEN_EXTERN_H
#define SHU_LSP_CODEGEN_EXTERN_H

#include <stdio.h>

struct codegen_CodegenOutBuf;

/** 写入 lsp_io_gen.c 所需的 std_io / heap / debug extern 与 #define（原 lsp_io_extern.h 语义）。 */
void lsp_codegen_emit_io_extern_block(FILE *out);

/** 写入 lsp_gen.c 所需的 lsp_io 符号 extern 与 static inline 包装（原 lsp_gen_extern.h 语义）。 */
void lsp_codegen_emit_gen_extern_block(FILE *out);

/** 同上 io 块，写入 SU pipeline 的 CodegenOutBuf（bootstrap codegen.su 调用）。 */
int lsp_codegen_emit_io_extern_to_buf(struct codegen_CodegenOutBuf *out);

/** 同上 gen 块，写入 CodegenOutBuf。 */
int lsp_codegen_emit_gen_extern_to_buf(struct codegen_CodegenOutBuf *out);

/** entry 路径是否 lsp_io.su 的 -E-extern 入口（C/SU 共用判定）。 */
int lsp_codegen_emit_path_is_lsp_io_su(const char *path);

/** entry 路径是否 lsp/lsp.su 的 -E-extern 入口。 */
int lsp_codegen_emit_path_is_lsp_main_su(const char *path);

#endif /* SHU_LSP_CODEGEN_EXTERN_H */
