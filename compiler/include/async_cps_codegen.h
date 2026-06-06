/**
 * async_cps_codegen.h — async 函数 CPS 状态机 C 代码生成（A3）
 *
 * 文件职责：在协程帧 __shu_frame 上 emit switch(__phase) 分段；await 边界保存/恢复 live 字段。
 * 所属模块：compiler/src/async/；由 codegen.c 在 async 函数体生成前调用。
 */
#ifndef ASYNC_CPS_CODEGEN_H
#define ASYNC_CPS_CODEGEN_H

#include "async_liveness.h"
#include <stdio.h>

/** CPS 代码生成上下文（跨 stmt 维护 phase 计数）。 */
typedef struct AsyncCpsCodegenCtx {
    const struct ASTFunc *func;
    const AsyncFrameLayout *layout;
    int phase_next;
    int switch_open;
} AsyncCpsCodegenCtx;

/**
 * 在 __shu_frame 初始化后调用：hoist 块内 let 声明 + 打开 switch(default/case 0)。
 */
void async_cps_codegen_begin(AsyncCpsCodegenCtx *ctx, const struct ASTFunc *f,
    const AsyncFrameLayout *layout, FILE *out);

/** 函数体结束后关闭 switch。 */
void async_cps_codegen_end(AsyncCpsCodegenCtx *ctx, FILE *out);

/**
 * await 语句完成后调用：保存 live 字段、推进 __phase、emit 下一 case 并恢复 live。
 * 返回值：0 成功。
 */
int async_cps_codegen_after_await(AsyncCpsCodegenCtx *ctx, FILE *out, const char *pad);

/** await 操作数是否为 IO 调用（read、write、submit_read、shu_io_ 前缀等）。 */
int async_cps_expr_is_io_await(const struct ASTExpr *await_expr);

/** await read(...)：非阻塞 submit + complete 路径（IO-A5 v1）。 */
int async_cps_expr_is_await_read(const struct ASTExpr *await_expr);

/** await read_fd(...)：fd 作 handle 的 submit + complete（IO-A5 v1）。 */
int async_cps_expr_is_await_read_fd(const struct ASTExpr *await_expr);

/** await write(...)：非阻塞 submit + complete 路径（IO-A5 v1）。 */
int async_cps_expr_is_await_write(const struct ASTExpr *await_expr);

/** await write_fd(...)：fd 作 handle 的 submit + complete（IO-A5 v1）。 */
int async_cps_expr_is_await_write_fd(const struct ASTExpr *await_expr);

/** IO await 边界：emit shu_async_cps_suspend_io（进 IO 等待队列）。 */
int async_cps_codegen_after_await_io(AsyncCpsCodegenCtx *ctx, FILE *out, const char *pad);

/** 正常 return 前 reset __phase，便于同一 static 帧再次 shu_async_run_i32。 */
void async_cps_codegen_emit_phase_reset(FILE *out, const char *pad);

/** 为 async 函数 emit 全局入口 shu_async_sched_<name>（同 TU 调 shu_async_run_i32）。 */
void async_cps_codegen_emit_sched_wrapper(const struct ASTFunc *f, const char *c_fname, FILE *out);

/** 名称是否为 codegen 生成的 scheduler 包装 shu_async_sched_<async_fn>。 */
int async_cps_is_sched_wrapper_name(const char *name);

/**
 * 若 sched_name 为 shu_async_sched_<async_fn>，返回同模块内对应含 await 的 async 函数；否则 NULL。
 */
struct ASTFunc *async_cps_resolve_sched_target(const struct ASTModule *m, const char *sched_name);

/** 模块是否声明了与 async_fn 配对的 extern shu_async_sched_<name>。 */
int async_cps_module_has_sched_extern(const struct ASTModule *m, const struct ASTFunc *async_fn);

/** 模块内是否有 run async_fn() 引用（供 DCE/WPO 保留协程体）。 */
int async_cps_module_references_run_async(const struct ASTModule *m, const struct ASTFunc *async_fn);

#endif
