/* seeds/async_liveness.from_x.c — G-02f-18 product TU
 * G-02f-169～171 refs/analyze true .x; G-02f-166～168 await AST true .x; G-02f-132 true .x pure helpers.
 *
 * R2 pure surface + Cap residual pure（2026-07-21）：await walk / live frame / mangle /
 *   frame_build_tag + lookup/type/size/layout/has_await/needs_cps/analyze/module_struct
 *   + FILE* emit_*（typedef/local/codegen_comment via shared driver_preamble_fputs）
 *   由 src/async/async_liveness.x 提供；FROM_X 下 pure C 体省略（仅 slice_marker）。
 * Cap residual（G.7 单一权威）：driver_preamble_fputs（runtime_driver_abi；opaque FILE*）。
 * 冷启动/无 PREFER：完整 pure C 体 + FILE* emit 用原生 fputs；-c 本文件。
 * 产品 PREFER（2026-07-21）：g05/Makefile full .x + rest (-DXLANG_ASYNC_LIVENESS_FROM_X)
 *   ld -r → src/async/async_liveness.o（独立 TU，非 pipeline_glue #include）。
 * PLATFORM: SHARED — pure helper 面跨平台；Ubuntu 金标 prove。
 */
/**
 * async_liveness.c — async 跨 await liveness 分析与协程帧 struct emit（A3）
 *
 * 文件职责：按 stmt_order 线性扫描 async 函数体，求帧存活集并 emit C typedef + 帧局部占位。
 * 所属模块：compiler/src/async/；实现 async_liveness.h。
 */
#include "async_liveness.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <xlang_fmt_cap.h> /* Cap residual 10.7.2: async_liveness type/name format → Cap snprintf */
/* G.7: single Cap authority for this TU (after stdio). */
#undef snprintf
#define snprintf xlang_snprintf

/* thin+rest：thin 函数在 rest 模式下由 .x 提供，前向声明供 rest 函数调用 */
int expr_has_await(const struct ASTExpr *e);
int block_has_await(const struct ASTBlock *b);
int block_has_io_read_await(const struct ASTBlock *b);
int block_has_io_write_await(const struct ASTBlock *b);
int expr_count_await(const struct ASTExpr *e);
int block_count_await(const struct ASTBlock *b);
int expr_refs_var(const struct ASTExpr *e, const char *name);
int block_refs_var(const struct ASTBlock *b, const char *name);
void analyze_block_linear(const struct ASTBlock *b, const char **prefix, int n_prefix, AsyncFrameLive *frame);
void frame_build_tag(const struct ASTFunc *f, char *buf, size_t n);
void frame_mangle_ident(const char *fn, char *out, size_t n);
int live_name_cmp(const void *a, const void *b);

#ifndef XLANG_ASYNC_LIVENESS_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_ASYNC_LIVENESS_FROM_X removed */
#else /* XLANG_ASYNC_LIVENESS_FROM_X — pure helpers + Cap residual pure + emit from .x */
/* R2 pure surface + Cap residual pure + FILE* emit marker：业务 pure 不在此 TU 定义。 */
int async_liveness_slice_marker(void) {
    return 1;
}
#endif /* XLANG_ASYNC_LIVENESS_FROM_X */


#ifndef XLANG_ASYNC_LIVENESS_FROM_X
#endif /* !XLANG_ASYNC_LIVENESS_FROM_X */

/* G.7 Cap residual：module-local async_liveness_fputs removed.
 * .x emit pure calls driver_preamble_fputs (authority in runtime_driver_abi seed).
 * Cold full C path (no FROM_X) uses FILE* fputs directly in emit_* above.
 * PLATFORM: SHARED — single opaque FILE* fputs authority. */
