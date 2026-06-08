/**
 * async_cps_codegen.c — async CPS switch 状态机 emit 实现（A3）
 *
 * 文件职责：线性 async 函数体生成 switch(__shu_frame.__phase)；await 边界 suspend 或 fallthrough。
 * 约定：帧/let 用 static 持久化；SHU_ASYNC_YIELD=1 时 await 边界 return SHU_ASYNC_SUSPENDED。
 */
#include "async_cps_codegen.h"
#include <stdio.h>
#include <string.h>

static int block_has_run_async_ref(const struct ASTBlock *b, const struct ASTFunc *target);

/** 表达式是否含 run target==async_fn 的调用。 */
static int expr_references_run_async(const struct ASTExpr *e, const struct ASTFunc *target) {
    if (!e || !target)
        return 0;
    if (e->kind == AST_EXPR_RUN) {
        const struct ASTExpr *op = e->value.unary.operand;
        if (op && op->kind == AST_EXPR_CALL && op->value.call.resolved_callee_func == target)
            return 1;
    }
    switch (e->kind) {
    case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
    case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
    case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
    case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
    case AST_EXPR_ASSIGN:
    case AST_EXPR_ADD_ASSIGN: case AST_EXPR_SUB_ASSIGN: case AST_EXPR_MUL_ASSIGN: case AST_EXPR_DIV_ASSIGN:
    case AST_EXPR_MOD_ASSIGN: case AST_EXPR_BITAND_ASSIGN: case AST_EXPR_BITOR_ASSIGN: case AST_EXPR_BITXOR_ASSIGN:
    case AST_EXPR_SHL_ASSIGN: case AST_EXPR_SHR_ASSIGN:
        return expr_references_run_async(e->value.binop.left, target)
            || expr_references_run_async(e->value.binop.right, target);
    case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT: case AST_EXPR_PANIC:
    case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF: case AST_EXPR_RETURN: case AST_EXPR_AWAIT: case AST_EXPR_RUN:
    case AST_EXPR_SPAWN:
    case AST_EXPR_AS:
        return expr_references_run_async(e->value.unary.operand, target);
    case AST_EXPR_IF:
    case AST_EXPR_TERNARY:
        return expr_references_run_async(e->value.if_expr.cond, target)
            || expr_references_run_async(e->value.if_expr.then_expr, target)
            || (e->value.if_expr.else_expr && expr_references_run_async(e->value.if_expr.else_expr, target));
    case AST_EXPR_CALL:
        for (int i = 0; i < e->value.call.num_args; i++)
            if (expr_references_run_async(e->value.call.args[i], target))
                return 1;
        return 0;
    case AST_EXPR_METHOD_CALL:
        if (expr_references_run_async(e->value.method_call.base, target))
            return 1;
        for (int i = 0; i < e->value.method_call.num_args; i++)
            if (expr_references_run_async(e->value.method_call.args[i], target))
                return 1;
        return 0;
    case AST_EXPR_FIELD_ACCESS:
        return expr_references_run_async(e->value.field_access.base, target);
    case AST_EXPR_INDEX:
        return expr_references_run_async(e->value.index.base, target)
            || expr_references_run_async(e->value.index.index_expr, target);
    case AST_EXPR_STRUCT_LIT:
        for (int i = 0; i < e->value.struct_lit.num_fields; i++)
            if (expr_references_run_async(e->value.struct_lit.inits[i], target))
                return 1;
        return 0;
    case AST_EXPR_ARRAY_LIT:
        for (int i = 0; i < e->value.array_lit.num_elems; i++)
            if (expr_references_run_async(e->value.array_lit.elems[i], target))
                return 1;
        return 0;
    case AST_EXPR_MATCH:
        if (expr_references_run_async(e->value.match_expr.matched_expr, target))
            return 1;
        for (int i = 0; i < e->value.match_expr.num_arms; i++)
            if (expr_references_run_async(e->value.match_expr.arms[i].result, target))
                return 1;
        return 0;
    case AST_EXPR_BLOCK:
        return e->value.block && block_has_run_async_ref(e->value.block, target);
    default:
        return 0;
    }
}

/** 块内是否含 run target 调用。 */
static int block_has_run_async_ref(const struct ASTBlock *b, const struct ASTFunc *target) {
    if (!b || !target)
        return 0;
    for (int i = 0; i < b->num_expr_stmts; i++)
        if (expr_references_run_async(b->expr_stmts[i], target))
            return 1;
    if (b->final_expr && expr_references_run_async(b->final_expr, target))
        return 1;
    for (int i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr
            && expr_references_run_async(b->labeled_stmts[i].u.return_expr, target))
            return 1;
    for (int i = 0; i < b->num_loops; i++)
        if (b->loops[i].body && block_has_run_async_ref(b->loops[i].body, target))
            return 1;
    for (int i = 0; i < b->num_for_loops; i++)
        if (b->for_loops[i].body && block_has_run_async_ref(b->for_loops[i].body, target))
            return 1;
    return 0;
}

int async_cps_module_references_run_async(const struct ASTModule *m, const struct ASTFunc *async_fn) {
    if (!m || !async_fn)
        return 0;
    for (int i = 0; i < m->num_funcs && m->funcs; i++) {
        struct ASTFunc *f = m->funcs[i];
        if (!f || f->is_extern || !f->body)
            continue;
        if (block_has_run_async_ref(f->body, async_fn))
            return 1;
    }
    return 0;
}

/** async CPS 协程是否经 void (*)(void) 调度（含 await 帧时 true）。 */
int async_cps_func_uses_void_entry(const struct ASTFunc *f, const struct ASTModule *m) {
    AsyncFrameLayout layout;
    if (!f || !m || !f->is_async || !async_liveness_func_has_await(f))
        return 0;
    return async_liveness_layout_func_module(f, m, &layout) == 0 && layout.num_awaits > 0;
}

/** CPS async 形参 emit 为 static 局部（run seed 注入；勿用 C 形参 ABI）。 */
void async_cps_codegen_emit_param_statics(const struct ASTFunc *f, FILE *out) {
    if (!f || !out)
        return;
    for (int pi = 0; pi < f->num_params; pi++) {
        char cty[96];
        const char *pname = f->params[pi].name;
        const struct ASTType *pty = f->params[pi].type;
        if (!pname || !pname[0] || !pty)
            continue;
        async_liveness_type_to_c_buf(pty, cty, sizeof(cty));
        fprintf(out, "  static %s %s;\n", cty, pname);
    }
}

/** 块内 used let 全部 hoist 到 switch 之前（A3 v0 线性函数）。 */
static void emit_hoisted_lets(const struct ASTFunc *f, FILE *out) {
    const struct ASTBlock *b = f && f->body ? f->body : NULL;
    if (!b || !b->let_decls) return;
    for (int i = 0; i < b->num_lets; i++) {
        const char *name = b->let_decls[i].name;
        if (!name || !name[0]) continue;
        char cty[96];
        async_liveness_type_to_c_buf(b->let_decls[i].type, cty, sizeof(cty));
        fprintf(out, "  static %s %s;\n", cty, name);
    }
}

void async_cps_codegen_begin(AsyncCpsCodegenCtx *ctx, const struct ASTFunc *f,
    const AsyncFrameLayout *layout, FILE *out) {
    if (!ctx || !f || !layout || !out) return;
    ctx->func = f;
    ctx->layout = layout;
    ctx->phase_next = 1;
    ctx->switch_open = 0;
    emit_hoisted_lets(f, out);
    /* run v3/v4：新 run 有 seed 时在 switch 前重置 phase 并注入实参（静态帧跨多次 run）。 */
    {
        int has_seed_param = 0;
        for (int pi = 0; pi < f->num_params; pi++) {
            const struct ASTType *pty = f->params[pi].type;
            if (!f->params[pi].name || !pty)
                continue;
            if (pty->kind == AST_TYPE_I32 || pty->kind == AST_TYPE_U32
                || pty->kind == AST_TYPE_I64 || pty->kind == AST_TYPE_USIZE)
                has_seed_param = 1;
        }
        if (has_seed_param) {
            fprintf(out, "  if (shu_async_run_seed_valid()) {\n");
            fprintf(out, "    __shu_frame.__phase = 0;\n");
            for (int pi = 0; pi < f->num_params; pi++) {
                const char *pname;
                const struct ASTType *pty;
                if (!f->params[pi].name || !f->params[pi].type)
                    continue;
                pname = f->params[pi].name;
                pty = f->params[pi].type;
                if (pty->kind == AST_TYPE_U32)
                    fprintf(out, "    %s = shu_async_run_seed_take_u32();\n", pname);
                else if (pty->kind == AST_TYPE_I64)
                    fprintf(out, "    %s = shu_async_run_seed_take_i64();\n", pname);
                else if (pty->kind == AST_TYPE_USIZE)
                    fprintf(out, "    %s = shu_async_run_seed_take_usize();\n", pname);
                else if (pty->kind == AST_TYPE_I32)
                    fprintf(out, "    %s = shu_async_run_seed_take_i32();\n", pname);
            }
            fprintf(out, "  }\n");
        }
    }
    fprintf(out, "  /* SHU_ASYNC_CPS switch=1 awaits=%d */\n", layout->num_awaits);
    fprintf(out, "  switch (__shu_frame.__phase) {\n");
    fprintf(out, "  default:\n");
    fprintf(out, "  case 0:\n");
    ctx->switch_open = 1;
}

void async_cps_codegen_end(AsyncCpsCodegenCtx *ctx, FILE *out) {
    if (!ctx || !out || !ctx->switch_open) return;
    fprintf(out, "    break;\n");
    fprintf(out, "  }\n");
    ctx->switch_open = 0;
}

/** callee 是否为 IO-A5 await 目标（std.io 同步 API / shu_io_* C 入口）。 */
static int async_cps_callee_is_io(const struct ASTFunc *callee) {
    const char *name;
    if (!callee || !callee->name || !callee->name[0])
        return 0;
    name = callee->name;
    if (strncmp(name, "shu_io_", 7) == 0)
        return 1;
    if (strcmp(name, "read") == 0 || strcmp(name, "write") == 0)
        return 1;
    if (strcmp(name, "submit_read") == 0 || strcmp(name, "submit_write") == 0)
        return 1;
    if (strcmp(name, "read_fd") == 0 || strcmp(name, "write_fd") == 0)
        return 1;
    if (strcmp(name, "read_ptr") == 0 || strcmp(name, "read_stdin_ptr") == 0)
        return 1;
    if (strcmp(name, "read_into") == 0 || strcmp(name, "write_from") == 0)
        return 1;
    return 0;
}

int async_cps_expr_is_io_await(const struct ASTExpr *await_expr) {
    const struct ASTExpr *op;
    if (!await_expr || await_expr->kind != AST_EXPR_AWAIT)
        return 0;
    op = await_expr->value.unary.operand;
    if (!op)
        return 0;
    if (op->kind == AST_EXPR_CALL && op->value.call.resolved_callee_func)
        return async_cps_callee_is_io(op->value.call.resolved_callee_func);
    return 0;
}

/** await read(handle, ptr, len, ...)：走 submit/complete 非阻塞路径（IO-A5 v1）。 */
int async_cps_expr_is_await_read(const struct ASTExpr *await_expr) {
    const struct ASTExpr *op;
    const struct ASTFunc *callee;
    if (!async_cps_expr_is_io_await(await_expr))
        return 0;
    op = await_expr->value.unary.operand;
    if (!op || op->kind != AST_EXPR_CALL || !op->value.call.resolved_callee_func)
        return 0;
    callee = op->value.call.resolved_callee_func;
    if (!callee->name || strcmp(callee->name, "read") != 0)
        return 0;
    return op->value.call.num_args >= 3;
}

/** await read_fd(fd, ptr, len)：非阻塞 submit + complete（IO-A5 v1）。 */
int async_cps_expr_is_await_read_fd(const struct ASTExpr *await_expr) {
    const struct ASTExpr *op;
    const struct ASTFunc *callee;
    if (!async_cps_expr_is_io_await(await_expr))
        return 0;
    op = await_expr->value.unary.operand;
    if (!op || op->kind != AST_EXPR_CALL || !op->value.call.resolved_callee_func)
        return 0;
    callee = op->value.call.resolved_callee_func;
    if (!callee->name || strcmp(callee->name, "read_fd") != 0)
        return 0;
    return op->value.call.num_args >= 3;
}

/** await write_fd(fd, ptr, len)：非阻塞 submit + complete（IO-A5 v1）。 */
int async_cps_expr_is_await_write_fd(const struct ASTExpr *await_expr) {
    const struct ASTExpr *op;
    const struct ASTFunc *callee;
    if (!async_cps_expr_is_io_await(await_expr))
        return 0;
    op = await_expr->value.unary.operand;
    if (!op || op->kind != AST_EXPR_CALL || !op->value.call.resolved_callee_func)
        return 0;
    callee = op->value.call.resolved_callee_func;
    if (!callee->name || strcmp(callee->name, "write_fd") != 0)
        return 0;
    return op->value.call.num_args >= 3;
}

/** await write(handle, ptr, len, ...)：走 submit/complete 非阻塞路径（IO-A5 v1）。 */
int async_cps_expr_is_await_write(const struct ASTExpr *await_expr) {
    const struct ASTExpr *op;
    const struct ASTFunc *callee;
    if (!async_cps_expr_is_io_await(await_expr))
        return 0;
    op = await_expr->value.unary.operand;
    if (!op || op->kind != AST_EXPR_CALL || !op->value.call.resolved_callee_func)
        return 0;
    callee = op->value.call.resolved_callee_func;
    if (!callee->name || strcmp(callee->name, "write") != 0)
        return 0;
    return op->value.call.num_args >= 3;
}

/** await 边界公共 emit：保存 live、推进 phase、开下一 case 并恢复 live。 */
static int async_cps_codegen_after_await_impl(AsyncCpsCodegenCtx *ctx, FILE *out,
    const char *pad, const char *suspend_fn) {
    const AsyncFrameLayout *layout;
    const char *p;
    int phase;
    if (!ctx || !out || !ctx->layout || !ctx->func || !suspend_fn)
        return -1;
    layout = ctx->layout;
    p = pad ? pad : "  ";
    phase = ctx->phase_next++;
    for (int i = 0; i < layout->live.n; i++) {
        const char *v = layout->live.names[i];
        if (!v || !v[0]) continue;
        fprintf(out, "%s__shu_frame.%s = %s;\n", p, v, v);
    }
    fprintf(out, "%s__shu_frame.__phase = %d;\n", p, phase);
    fprintf(out, "%sif (%s(&__shu_frame.__phase, %d)) return (int32_t)SHU_ASYNC_SUSPENDED;\n",
        p, suspend_fn, phase);
    fprintf(out, "%s/* SHU_ASYNC_CPS fallthrough phase=%d */\n", p, phase);
    fprintf(out, "%scase %d:\n", p, phase);
    for (int i = 0; i < layout->live.n; i++) {
        const char *v = layout->live.names[i];
        if (!v || !v[0]) continue;
        fprintf(out, "%s%s = __shu_frame.%s;\n", p, v, v);
    }
    return 0;
}

int async_cps_codegen_after_await(AsyncCpsCodegenCtx *ctx, FILE *out, const char *pad) {
    return async_cps_codegen_after_await_impl(ctx, out, pad, "shu_async_cps_suspend");
}

int async_cps_codegen_after_await_io(AsyncCpsCodegenCtx *ctx, FILE *out, const char *pad) {
    return async_cps_codegen_after_await_impl(ctx, out, pad, "shu_async_cps_suspend_io");
}

void async_cps_codegen_emit_phase_reset(FILE *out, const char *pad) {
    const char *p = pad ? pad : "  ";
    if (!out) return;
    fprintf(out, "%s__shu_frame.__phase = 0;\n", p);
}

void async_cps_codegen_emit_sched_wrapper(const struct ASTFunc *f, const char *c_fname, FILE *out) {
    if (!f || !f->name || !c_fname || !out) return;
    fprintf(out, "/* A4: scheduler entry shu_async_sched_%s */\n", f->name);
    fprintf(out, "#ifndef SHU_ASYNC_SCHED_RT_DECL\n");
    fprintf(out, "#define SHU_ASYNC_SCHED_RT_DECL\n");
    fprintf(out, "extern int32_t shu_async_run_i32(int32_t (*fn)(void));\n");
    fprintf(out, "#endif\n");
    fprintf(out, "int32_t shu_async_sched_%s(void) {\n", f->name);
    fprintf(out, "  return shu_async_run_i32((int32_t (*)(void))%s);\n", c_fname);
    fprintf(out, "}\n");
}

int async_cps_is_sched_wrapper_name(const char *name) {
    return name && strncmp(name, "shu_async_sched_", 16) == 0;
}

struct ASTFunc *async_cps_resolve_sched_target(const struct ASTModule *m, const char *sched_name) {
    const char *async_name;
    if (!m || !sched_name || !async_cps_is_sched_wrapper_name(sched_name))
        return NULL;
    async_name = sched_name + 16;
    if (!async_name[0])
        return NULL;
    for (int i = 0; i < m->num_funcs && m->funcs; i++) {
        struct ASTFunc *f = m->funcs[i];
        if (!f || !f->name || f->is_extern)
            continue;
        if (strcmp(f->name, async_name) == 0 && f->is_async && async_liveness_func_has_await(f))
            return f;
    }
    return NULL;
}

int async_cps_module_has_sched_extern(const struct ASTModule *m, const struct ASTFunc *async_fn) {
    char sched_name[128];
    if (!m || !async_fn || !async_fn->name || !async_fn->is_async || !async_liveness_func_has_await(async_fn))
        return 0;
    snprintf(sched_name, sizeof(sched_name), "shu_async_sched_%s", async_fn->name);
    for (int i = 0; i < m->num_funcs && m->funcs; i++) {
        struct ASTFunc *ef = m->funcs[i];
        if (ef && ef->is_extern && ef->name && strcmp(ef->name, sched_name) == 0)
            return 1;
    }
    return 0;
}
