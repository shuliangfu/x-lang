/* seeds/async_cps_codegen.from_x.c — G-02f-18 product TU
 * G-02f-132 true .x pure helpers.
 * G-02f-120 true .x pure helpers.
 * G-02f-111 helper gates.
 * G-02f-105 helper gates.
 *
 * R2 pure surface + Cap residual pure wave1–5（2026-07-21）：
 *   io/future_wait/sched name gates + thin walk/hoist wrappers +
 *   expr_is_* await classifiers + module/sched resolve + func_uses_void_entry +
 *   walk _impl (expr/block run-async) + FILE* emit end/phase_reset/after_await/
 *   sched_wrapper + begin / emit_param_statics / emit_hoisted_lets_impl
 *   by src/async/async_cps_codegen.x（shared driver_preamble_fputs + type_to_c_buf）；
 *   FROM_X 下 pure helper C 体（含 walk _impl + wave4–5 emit）省略。
 * Cap residual（G.7 单一权威）：driver_preamble_fputs（runtime_driver_abi；opaque FILE*）。
 * 冷启动/无 PREFER：完整 pure C 体 + 原生 FILE* fputs；-c 本文件（无宏）。
 * 产品 PREFER（2026-07-21）：g05/Makefile full .x + rest (-DXLANG_ASYNC_CPS_CODEGEN_FROM_X)
 *   ld -r → src/async/async_cps_codegen.o（独立 TU，非 pipeline_glue #include）。
 * PLATFORM: SHARED — pure helper 面跨平台；Ubuntu 金标 prove。
 */
/**
 * async_cps_codegen.c — async CPS switch 状态机 emit 实现（A3）
 *
 * 文件职责：线性 async 函数体生成 switch(__xlang_frame.__phase)；await 边界 suspend 或 fallthrough。
 * 约定：帧/let 用 static 持久化；XLANG_ASYNC_YIELD=1 时 await 边界 return XLANG_ASYNC_SUSPENDED。
 */
#include "async_cps_codegen.h"
#include <stdio.h>
#include <string.h>
#include <xlang_fmt_cap.h> /* Cap residual 10.7.2: async_cps sched name → Cap snprintf */
/* G.7: single Cap authority for this TU (after stdio). */
#undef snprintf
#define snprintf xlang_snprintf

int block_has_run_async_ref(const struct ASTBlock *b, const struct ASTFunc *target);

/* thin+rest：thin 函数在 rest 模式下由 .x 提供，前向声明供 rest 函数调用 */
void emit_hoisted_lets(const struct ASTFunc *f, FILE *out);
int expr_references_run_async(const struct ASTExpr *e, const struct ASTFunc *target);
int async_cps_callee_is_io(const struct ASTFunc *callee);
int async_cps_callee_is_future_wait_by_name(const char *n);
int async_cps_callee_is_future_wait(const struct ASTFunc *callee);

/** 表达式是否含 run/spawn target==async_fn 的调用。 */
/* Cap residual pure wave3：逻辑源 .x walk _impl；seed 保留同语义 C 供冷路径 */
#ifndef XLANG_ASYNC_CPS_CODEGEN_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_ASYNC_CPS_CODEGEN_FROM_X removed */
#endif /* !XLANG_ASYNC_CPS_CODEGEN_FROM_X */




/** 模块内是否有 run/spawn async_fn() 引用（供 DCE/WPO 保留协程体）。 */
#ifndef XLANG_ASYNC_CPS_CODEGEN_FROM_X
#endif /* !XLANG_ASYNC_CPS_CODEGEN_FROM_X */

/* Cap residual pure wave5：.x 真迁 begin / param_statics / hoist_impl；冷路径仍 seed C */
#ifndef XLANG_ASYNC_CPS_CODEGEN_FROM_X
#endif /* !XLANG_ASYNC_CPS_CODEGEN_FROM_X */

/* Cap residual pure wave4：.x 真迁；冷路径仍 seed C */
#ifndef XLANG_ASYNC_CPS_CODEGEN_FROM_X
#endif

/** callee 是否为 IO-A5 await 目标（std.io 同步 API / xlang_io_* C 入口）。 */
/* G-02f-132：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-20 thin+rest：DIRECT 模式，thin（src/async/async_cps_codegen.x）提供完整实现 */
#ifndef XLANG_ASYNC_CPS_CODEGEN_FROM_X
#endif


#ifndef XLANG_ASYNC_CPS_CODEGEN_FROM_X
#endif /* !XLANG_ASYNC_CPS_CODEGEN_FROM_X */

/** callee 是否为 Future 等待（future_wait / runtime_wait_future / C 符号）。 */
/* G-02f-120：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-20 thin+rest：DIRECT 模式，thin（src/async/async_cps_codegen.x）提供完整实现 */
#ifndef XLANG_ASYNC_CPS_CODEGEN_FROM_X
#endif




/* G-02f-132：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
/* G-02f-20 thin+rest：DIRECT 模式，thin（src/async/async_cps_codegen.x）提供完整实现 */
#ifndef XLANG_ASYNC_CPS_CODEGEN_FROM_X
#endif


/** await future_wait(...)：Pending 时走 suspend_io 循环（STD-041 Future 绑定）。 */
#ifndef XLANG_ASYNC_CPS_CODEGEN_FROM_X
#endif /* !XLANG_ASYNC_CPS_CODEGEN_FROM_X */

/* Cap residual pure wave4：.x 真迁 after_await / phase_reset / sched_wrapper；冷路径仍 seed C */
#ifndef XLANG_ASYNC_CPS_CODEGEN_FROM_X
#endif /* !XLANG_ASYNC_CPS_CODEGEN_FROM_X */

/* G.7 Cap residual：module-local async_cps_fputs removed.
 * .x emit pure calls driver_preamble_fputs (authority in runtime_driver_abi seed).
 * Cold full C path (no FROM_X) uses FILE* fputs/fprintf directly in emit_* above.
 * PLATFORM: SHARED — single opaque FILE* fputs authority. */

/* G-02f-20 thin+rest：DIRECT 模式，thin（.x）提供完整实现 */
#ifndef XLANG_ASYNC_CPS_CODEGEN_FROM_X
#endif

#ifndef XLANG_ASYNC_CPS_CODEGEN_FROM_X
#endif /* !XLANG_ASYNC_CPS_CODEGEN_FROM_X */

#ifdef XLANG_ASYNC_CPS_CODEGEN_FROM_X
/* R2 pure surface + Cap residual pure wave1–5 from .x (walk _impl + FILE* emit
 * end/phase_reset/after_await/sched + begin/param_statics/hoist_impl).
 * Cap residual fputs: G.7 authority = driver_preamble_fputs (not this TU). */
int async_cps_codegen_slice_marker(void) {
    return 0;
}
#endif /* XLANG_ASYNC_CPS_CODEGEN_FROM_X */
