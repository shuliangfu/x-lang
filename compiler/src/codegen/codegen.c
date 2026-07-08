/**
 * codegen.c — 代码生成实现（AST → C）
 *
 * 文件职责：实现 codegen.h 声明的 codegen_module_to_c 与 codegen_library_module_to_c，将 AST 转为 C 源码供系统 cc 编译。
 * 所属模块：编译器后端 codegen，compiler/src/codegen/；实现 codegen.h。
 * 与其它文件的关系：依赖 include/ast.h；被 main 在 typeck 通过后调用；输出到 main 提供的临时文件流。
 * 重要约定：入口模块仅支持 main；生成 Hello World 的 printf，且 return 使用 main 体整数字面量的值（阶段 4 方案 B 扩展）；库模块仅输出注释（阶段 7.3 多文件占位）。
 */

#include "win32_compat.h"
#include "codegen/codegen.h"
#include "ast.h"
#include "diag.h"
#include "runtime_diag_codes.h"
#include "async_liveness.h"
#include "async_cps_codegen.h"
#include "../lsp/lsp_codegen_extern.h"
#include <stdio.h>
#include <stdlib.h>

/** M-6：`-fsanitize=address` 时强制 INDEX 边界检查（由 runtime.c 解析 argv / 环境变量）。 */
extern int32_t driver_sanitize_address_get(void);
#include <string.h>
#include <limits.h>
#include <stdint.h>
/* std.io.driver 的 driver_read_ptr_len/driver_read_ptr 由 codegen 与 .x 无条件跳过，不依赖 runtime 标志。 */
#ifdef SHUX_USE_X_CODEGEN
/** .x 侧整数字面量格式化入口：向 out（FILE* 不透明）逐字节输出 val 的十进制表示；由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_format_int_lit(uint8_t *out, int32_t val);
/** .x 侧布尔字面量输出：向 out 输出 '0' 或 '1'（val 非 0 为 1）；由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_format_bool_lit(uint8_t *out, int32_t val);
/** .x 侧 C 字符串输出：向 out 逐字节输出 ptr[0..len-1]；由 codegen.x 实现，用于 VAR 变量名等。 */
extern int32_t codegen_codegen_x_emit_c_string(uint8_t *out, uint8_t *ptr, int32_t len);
/** .x 侧浮点字面量输出：ptr 指向 double，is_f32 非 0 为 f32；由 codegen.x 转调 C 的 codegen_x_emit_float。 */
extern int32_t codegen_codegen_x_emit_float_lit(uint8_t *out, uint8_t *ptr, int32_t is_f32);
/** .x 侧二元运算输出：左/右子表达式与运算符串；need_l/need_r 非 0 时在对应子表达式外加括号。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_binop(uint8_t *out, uint8_t *left, uint8_t *right, uint8_t *op_ptr, int32_t op_len, int32_t need_l, int32_t need_r);
/** .x 侧一元运算输出：左括号+前缀串、子表达式、右括号。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_unary(uint8_t *out, uint8_t *operand, uint8_t *prefix_ptr, int32_t prefix_len);
/** .x 侧赋值表达式输出：( left = right )。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_assign(uint8_t *out, uint8_t *left, uint8_t *right);
/** .x 侧 DIV 表达式：is_int 非 0 时走整数除零检查，否则为浮点 /。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_div_expr(uint8_t *out, uint8_t *left, uint8_t *right, int32_t is_int);
/** .x 侧 MOD 表达式：is_int 非 0 时走整数取模零检查，否则为浮点 %。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_mod_expr(uint8_t *out, uint8_t *left, uint8_t *right, int32_t is_int);
/** .x 侧三元表达式内层：cond、op_q（" ? "）、then_e、op_c（" : "）、else_e；C 外包括号。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_ternary_inner(uint8_t *out, uint8_t *cond, uint8_t *then_e, uint8_t *else_e, uint8_t *op_q, int32_t len_q, uint8_t *op_c, int32_t len_c);
/** .x 侧字段访问统一入口：枚举变体走 C 的 full，结构体字段走 .x 的 (base).field。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_field_access_expr(uint8_t *out, uint8_t *expr);
/** .x 侧函数调用统一入口：按 dispatch 调 C 的 import/library_same/library_dep/mono full 或 fallback callee(args)。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_call_expr(uint8_t *out, uint8_t *expr);
/** .x 侧 panic 输出：has_operand 非 0 时 shux_panic_(1, operand)，否则 shux_panic_(0, 0)。由 codegen.x 转调 C 的 codegen_x_emit_panic_*。 */
extern int32_t codegen_codegen_x_emit_panic(uint8_t *out, int32_t has_operand, uint8_t *operand);
/** .x 侧下标 fallback：(base)[index] 或 (base).data[index]。is_slice 非 0 为 .data 形式。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_index_fallback(uint8_t *out, uint8_t *base, uint8_t *index, int32_t is_slice);
/** .x 侧块表达式：输出 ({  + block_body +  0; })；C 提供 codegen_x_block_body。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_block_expr(uint8_t *out, uint8_t *block);
/** .x 侧方法调用：c_name(base, arg0, ...)；C 提供 method_call 访问器。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_method_call(uint8_t *out, uint8_t *expr);
/** .x 侧下标完整：按类型/BCE 分发到 fallback 或边界检查；C 提供 index 访问器与 slice/array bounds 输出。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_index(uint8_t *out, uint8_t *expr);
/** .x 侧 match：switch 或三元链；C 提供 match 访问器与 next_id。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_match(uint8_t *out, uint8_t *expr);
/** .x 侧结构体字面量：入口在 .x，转调 C 的 codegen_x_emit_struct_lit_full。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_struct_lit(uint8_t *out, uint8_t *expr);
/** .x 侧数组字面量：入口在 .x，转调 C 的 codegen_x_emit_array_lit_full。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_array_lit(uint8_t *out, uint8_t *expr);
/** .x 侧 if 表达式：语句表达式或三元；入口在 .x，转调 C 的 codegen_x_emit_if_expr_full。由 codegen.x 实现。 */
extern int32_t codegen_codegen_x_emit_if_expr(uint8_t *out, uint8_t *expr);
/** .x 侧单条 while 循环输出：indent + while ( cond ) { body }。 */
extern int32_t codegen_codegen_x_emit_one_while_loop(uint8_t *out, uint8_t *cond, uint8_t *body, int32_t indent, int32_t cast_return);
/** .x 侧单条 for 循环输出：indent + for ( init; cond 或 1; step ) { body }。 */
extern int32_t codegen_codegen_x_emit_one_for_loop(uint8_t *out, uint8_t *init, uint8_t *cond, uint8_t *step, uint8_t *body, int32_t indent, int32_t cast_return);
/** .x 侧语句输出：continue;/break;/return;/return expr;/(void)(expr); */
extern int32_t codegen_codegen_x_emit_continue_stmt(uint8_t *out, int32_t indent);
extern int32_t codegen_codegen_x_emit_break_stmt(uint8_t *out, int32_t indent);
extern int32_t codegen_codegen_x_emit_return_no_val(uint8_t *out, int32_t indent);
extern int32_t codegen_codegen_x_emit_return_expr(uint8_t *out, int32_t indent, uint8_t *expr);
extern int32_t codegen_codegen_x_emit_void_expr_stmt(uint8_t *out, int32_t indent, uint8_t *expr);
/** .x 侧 label 输出：indent + label 字符串（ptr[0..len-1]）+ ":\n"。 */
extern int32_t codegen_codegen_x_emit_label(uint8_t *out, int32_t indent, uint8_t *label_ptr, int32_t label_len);
/** .x 侧 goto 输出：indent + "goto " + target 字符串 + ";\n"。 */
extern int32_t codegen_codegen_x_emit_goto(uint8_t *out, int32_t indent, uint8_t *target_ptr, int32_t target_len);
/** .x 侧 cleanup 相关：goto shux_cleanup; / shux_cleanup: / exit_kind=1; goto cleanup / ret_val=0; exit_kind=1; goto cleanup / if(exit_kind) return ret_val; / 声明 exit_kind / 声明 ret_val。 */
extern int32_t codegen_codegen_x_emit_goto_shux_cleanup(uint8_t *out, int32_t indent);
extern int32_t codegen_codegen_x_emit_shux_cleanup_label(uint8_t *out, int32_t indent);
extern int32_t codegen_codegen_x_emit_exit_kind_goto_cleanup(uint8_t *out, int32_t indent);
extern int32_t codegen_codegen_x_emit_ret_val_zero_exit_goto_cleanup(uint8_t *out, int32_t indent);
extern int32_t codegen_codegen_x_emit_if_exit_kind_return_ret_val(uint8_t *out, int32_t indent);
extern int32_t codegen_codegen_x_emit_cleanup_decl_exit_kind(uint8_t *out, int32_t indent);
extern int32_t codegen_codegen_x_emit_cleanup_decl_ret_val(uint8_t *out, int32_t indent, uint8_t *ret_ctype_ptr, int32_t ret_ctype_len);
/** .x 侧 defer 逆序执行：对 block 的 num_defers 从高到低依次输出各 defer 块体。 */
extern int32_t codegen_codegen_x_run_defers(uint8_t *out, uint8_t *block, int32_t indent);
/** .x 侧块 const/let 声明批量输出：const_decls 全量；let_decls 按 [start,end) 区间。 */
extern int32_t codegen_codegen_x_emit_block_const_decls(uint8_t *out, uint8_t *block, int32_t indent);
extern int32_t codegen_codegen_x_emit_block_let_decls_range(uint8_t *out, uint8_t *block, int32_t indent, int32_t start, int32_t end);
#endif
/** .x 侧通过 extern 调用的写单字节接口；out 为 FILE* 的不透明指针，b 为要输出的字节（0..255）。返回 0 成功，非 0 失败。始终编译进 codegen.o 以便 bootstrap-codegen 链接时解析。 */
int32_t codegen_x_emit_byte(uint8_t *out, int32_t b) {
    int c = (unsigned char)(b & 0xff);
    return (fputc(c, (FILE *)out) == c) ? 0 : -1;
}
/** .x 侧通过 extern 调用的读单字节接口：返回 ptr[i] 的 0..255 值，供 .x 逐字节输出 C 字符串用。 */
int32_t codegen_x_char_at(uint8_t *ptr, int32_t i) {
    return (int32_t)(unsigned char)ptr[i];
}
/** .x 侧通过 extern 调用的浮点字面量输出：ptr 指向 double，is_f32 非 0 时输出 f32 后缀；0.0 输出 "0.0"/"0.0f"，否则 %g/%gf。返回 0 成功。 */
int32_t codegen_x_emit_float(uint8_t *out, uint8_t *ptr, int32_t is_f32) {
    double v;
    memcpy(&v, ptr, sizeof(double));
    if (v == 0.0)
        fprintf((FILE *)out, is_f32 ? "0.0f" : "0.0");
    else if (is_f32)
        fprintf((FILE *)out, "%gf", v);
    else
        fprintf((FILE *)out, "%g", v);
    return 0;
}

static int codegen_expr(const struct ASTExpr *e, FILE *out);
static void codegen_report_expr_error(const struct ASTExpr *e, const char *msg);
static int codegen_block_body(const struct ASTBlock *b, int indent, FILE *out, int cast_return_to_int,
                              int is_void_return_context, const char *final_result_var);

static const struct ASTBlock *codegen_block_expr_value_block(const struct ASTBlock *b) {
    int idx;
    if (!b) return NULL;
    if (b->final_expr) return b;
    if (b->num_stmt_order <= 0) return NULL;
    if (b->stmt_order[b->num_stmt_order - 1].kind != 5) return NULL;
    idx = b->stmt_order[b->num_stmt_order - 1].idx;
    if (idx < 0 || idx >= b->num_regions) return NULL;
    if (!b->regions[idx].is_unsafe) return NULL;
    return codegen_block_expr_value_block(b->regions[idx].body);
}
/** C 路径：表达式语句 emit（赋值直出 `expr;`，其余 `(void)(expr);`）。 */
static int codegen_emit_expr_stmt(FILE *out, const char *pad, const struct ASTExpr *st);
/** 当 else 为单语句块且唯一语句为 __tmp = (struct X){0} 时返回该 struct 的 C 类型串，否则 NULL。前向声明。 */
static const char *struct_type_from_else_block(const struct ASTExpr *else_e);
/** 返回结构体字面量 e 的 C 类型串，与 codegen 发射时一致；前向声明。 */
static const char *struct_lit_c_type_str(const struct ASTExpr *e, char *buf, size_t bufsize);
/** 递归求表达式可能产生的 struct 类型 C 串；前向声明。 */
static const char *expr_struct_type_str(const struct ASTExpr *e, char *buf, size_t bufsize);
static const char *impl_method_c_name(const struct ASTFunc *f);
/** CALL 四条分支的 C 内实现，供 .x 统一入口转调；需在 codegen_expr 之后定义。 */
static int codegen_emit_one_call_arg(FILE *out, const struct ASTExpr *arg);
static int codegen_emit_io_driver_arg0_for_func(FILE *out, const struct ASTFunc *f, const char *import_path,
                                                int arg_index, const struct ASTExpr *arg);
static int codegen_emit_call_import_path_impl(FILE *out, const struct ASTExpr *e);
static int codegen_emit_call_library_same_impl(FILE *out, const struct ASTExpr *e);
static int codegen_emit_call_library_dep_impl(FILE *out, const struct ASTExpr *e);
static int codegen_emit_call_mono_impl(FILE *out, const struct ASTExpr *e);
/** 用于生成唯一 match 临时变量名；需在 codegen_x_match_next_id 前可见。 */
static int codegen_match_id;
static int codegen_try_active;  /* 在 try 体内时置位：? 失败 goto catch 而非 return */
static char codegen_try_r_var[64];
static char codegen_try_catch_label[64];
static int codegen_try_id;

/** .x 侧通过 extern 调用的“输出整棵表达式”接口：递归调用 codegen_expr，供 .x 在二元运算等中输出子表达式。返回 0 成功，-1 失败。 */
int32_t codegen_x_emit_expr(uint8_t *out, uint8_t *expr) {
    return (int32_t)codegen_expr((const struct ASTExpr *)expr, (FILE *)out);
}
/** .x 侧判断子表达式是否需加括号（比较/逻辑运算符作为加减操作数时）：kind 在 [AST_EXPR_EQ, AST_EXPR_LOGOR] 返回 1。 */
int32_t codegen_x_expr_needs_compare_parens(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return (e && e->kind >= AST_EXPR_EQ && e->kind <= AST_EXPR_LOGOR) ? 1 : 0;
}
/** .x 侧判断子表达式是否需加括号（加减作为乘除操作数时）：kind 为 ADD 或 SUB 返回 1。 */
int32_t codegen_x_expr_needs_addsub_parens(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return (e && (e->kind == AST_EXPR_ADD || e->kind == AST_EXPR_SUB)) ? 1 : 0;
}
/** C 路径：加减操作数若含 shift/位运算/比较/逻辑，须加括号（C 中 + - 优先于 <<）。 */
static int codegen_c_need_paren_additive_child(const struct ASTExpr *e) {
    if (!e) return 0;
    switch (e->kind) {
    case AST_EXPR_ADD: case AST_EXPR_SUB:
    case AST_EXPR_SHL: case AST_EXPR_SHR:
    case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        return 1;
    default:
        return (e->kind >= AST_EXPR_EQ && e->kind <= AST_EXPR_LOGOR);
    }
}
/** C 路径：比较/相等运算符的操作数若为位运算/逻辑运算/比较，须加括号（C 中 & | ^ 低于 ==）。
 * 修 VMM bug：(a & 1) == 0 被错编为 a & 1 == 0 = a & (1==0) = a & 0 = 0（恒 false）。 */
static int codegen_c_need_paren_compare_child(const struct ASTExpr *e) {
    if (!e) return 0;
    switch (e->kind) {
    case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        return 1;
    default:
        return (e->kind >= AST_EXPR_EQ && e->kind <= AST_EXPR_LOGOR);
    }
}

/** C 路径：位运算(&|^)的操作数若为更低优先级运算(^|、&&、||)，须加括号。
 *  C 优先级：& > ^ > | > && > ||，故 & 的 ^|&&操作数需括号，^ 的 |&&需括号，| 的 &&需括号。 */
static int codegen_c_need_paren_bitwise_child(int parent_kind, const struct ASTExpr *e) {
    if (!e) return 0;
    /* 位运算子表达式优先级：& (8) > ^ (9) > | (10) > && (11) > || (12)
     * 若 child 优先级数值 > parent 优先级数值 → child 更低 → 需括号 */
    int child_prec = 0, parent_prec = 0;
    switch (parent_kind) {
    case AST_EXPR_BITAND:  parent_prec = 8; break;
    case AST_EXPR_BITXOR:  parent_prec = 9; break;
    case AST_EXPR_BITOR:   parent_prec = 10; break;
    default: return 0;
    }
    switch (e->kind) {
    case AST_EXPR_BITAND:  child_prec = 8; break;
    case AST_EXPR_BITXOR:  child_prec = 9; break;
    case AST_EXPR_BITOR:   child_prec = 10; break;
    case AST_EXPR_LOGAND:  child_prec = 11; break;
    case AST_EXPR_LOGOR:   child_prec = 12; break;
    default: return 0;
    }
    return (child_prec > parent_prec) ? 1 : 0;
}

/** .x 侧 CALL 访问器：返回 callee 子表达式指针。 */
uint8_t *codegen_x_call_callee(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return (e && e->kind == AST_EXPR_CALL && e->value.call.callee) ? (uint8_t *)e->value.call.callee : NULL;
}
/** .x 侧 CALL 访问器：返回实参个数。 */
int32_t codegen_x_call_num_args(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return (e && e->kind == AST_EXPR_CALL) ? (int32_t)e->value.call.num_args : 0;
}
/** .x 侧 CALL 访问器：返回第 i 个实参表达式指针，i 从 0 起。 */
uint8_t *codegen_x_call_arg(uint8_t *expr, int32_t i) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_CALL || !e->value.call.args || i < 0 || i >= e->value.call.num_args) return NULL;
    return (uint8_t *)e->value.call.args[i];
}
/** .x 侧 panic 无参：输出 shux_panic_(0, 0)。 */
int32_t codegen_x_emit_panic_no_arg(uint8_t *out) {
    return fprintf((FILE *)out, "shux_panic_(0, 0)") < 0 ? -1 : 0;
}
/** .x 侧 panic 有参：输出 shux_panic_(1, expr)。 */
int32_t codegen_x_emit_panic_with_arg(uint8_t *out, uint8_t *operand) {
    if (fprintf((FILE *)out, "shux_panic_(1, ") < 0) return -1;
    if (codegen_expr((const struct ASTExpr *)operand, (FILE *)out) != 0) return -1;
    return fprintf((FILE *)out, ")") < 0 ? -1 : 0;
}
/** .x 侧块体输出（无 final_result_var）：块表达式用，传 NULL 给 codegen_block_body。 */
int32_t codegen_x_block_body_no_result(uint8_t *out, uint8_t *block, int32_t indent, int32_t cast_return_to_int) {
    return codegen_block_body((const struct ASTBlock *)block, (int)indent, (FILE *)out, (int)cast_return_to_int, 0, NULL) != 0 ? -1 : 0;
}
/** .x 侧块体输出（带 final_result_var "__tmp"）：供 if 语句表达式 then/else 块用。 */
int32_t codegen_x_block_body_with_result_var(uint8_t *out, uint8_t *block, int32_t indent, int32_t cast_return_to_int) {
    return codegen_block_body((const struct ASTBlock *)block, (int)indent, (FILE *)out, (int)cast_return_to_int, 0, "__tmp") != 0 ? -1 : 0;
}
/** .x 侧块 defer 访问器：块内 defer 数量；供 run_defers 逆序遍历。 */
int32_t codegen_x_block_num_defers(uint8_t *block) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    return (b && b->defer_blocks) ? (int32_t)b->num_defers : 0;
}
/** .x 侧块 defer 访问器：第 i 个 defer 子块（i 从 0 到 num_defers-1）；逆序时从 num_defers-1 到 0。 */
uint8_t *codegen_x_block_defer_block(uint8_t *block, int32_t i) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->defer_blocks || i < 0 || i >= b->num_defers) return NULL;
    return (uint8_t *)b->defer_blocks[i];
}
/** .x 侧块 const/let 访问器：数量与 early_lets 分界，供 .x 循环输出声明。 */
int32_t codegen_x_block_num_consts(uint8_t *block) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    return b ? (int32_t)b->num_consts : 0;
}
int32_t codegen_x_block_num_lets(uint8_t *block) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    return b ? (int32_t)b->num_lets : 0;
}
int32_t codegen_x_block_num_early_lets(uint8_t *block) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || b->num_early_lets <= 0 || b->num_early_lets > b->num_lets) return 0;
    return (int32_t)b->num_early_lets;
}
/** .x 用：stmt_order 条数；>0 时 .x 按序输出 const/let/expr_stmt/loop/for。 */
int32_t codegen_x_block_num_stmt_order(uint8_t *block) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    return b ? (int32_t)b->num_stmt_order : 0;
}
/** .x 用：第 i 条 stmt_order 的 kind：0=const, 1=let, 2=expr_stmt, 3=loop, 4=for。 */
int32_t codegen_x_block_stmt_order_kind(uint8_t *block, int32_t i) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || i < 0 || i >= b->num_stmt_order) return -1;
    return (int32_t)(unsigned char)b->stmt_order[i].kind;
}
/** .x 用：第 i 条 stmt_order 的 idx（对应 const_decls/let_decls/expr_stmts/loops/for_loops 下标）。 */
int32_t codegen_x_block_stmt_order_idx(uint8_t *block, int32_t i) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || i < 0 || i >= b->num_stmt_order) return -1;
    return b->stmt_order[i].idx;
}
/** .x 用：块内第 idx 条表达式语句（expr_stmts[idx]），供 emit_void_expr_stmt 等。 */
uint8_t *codegen_x_block_expr_stmt(uint8_t *block, int32_t idx) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->expr_stmts || idx < 0 || idx >= b->num_expr_stmts) return NULL;
    return (uint8_t *)b->expr_stmts[idx];
}
/** .x 用：块内第 idx 条 while 的 cond/body。 */
uint8_t *codegen_x_block_loop_cond(uint8_t *block, int32_t idx) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->loops || idx < 0 || idx >= b->num_loops) return NULL;
    return (uint8_t *)b->loops[idx].cond;
}
uint8_t *codegen_x_block_loop_body(uint8_t *block, int32_t idx) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->loops || idx < 0 || idx >= b->num_loops) return NULL;
    return (uint8_t *)b->loops[idx].body;
}
/** .x 用：块内第 idx 条 for 的 init/cond/step/body。 */
uint8_t *codegen_x_block_for_init(uint8_t *block, int32_t idx) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->for_loops || idx < 0 || idx >= b->num_for_loops) return NULL;
    return (uint8_t *)b->for_loops[idx].init;
}
uint8_t *codegen_x_block_for_cond(uint8_t *block, int32_t idx) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->for_loops || idx < 0 || idx >= b->num_for_loops) return NULL;
    return (uint8_t *)b->for_loops[idx].cond;
}
uint8_t *codegen_x_block_for_step(uint8_t *block, int32_t idx) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->for_loops || idx < 0 || idx >= b->num_for_loops) return NULL;
    return (uint8_t *)b->for_loops[idx].step;
}
uint8_t *codegen_x_block_for_body(uint8_t *block, int32_t idx) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->for_loops || idx < 0 || idx >= b->num_for_loops) return NULL;
    return (uint8_t *)b->for_loops[idx].body;
}
/** .x 侧 METHOD_CALL：返回 impl 方法的 C 名（Trait_Type_method）指针；非 method_call 或未解析返回 NULL。 */
uint8_t *codegen_x_method_call_c_name_ptr(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_METHOD_CALL || !e->value.method_call.resolved_impl_func) return NULL;
    return (uint8_t *)impl_method_c_name(e->value.method_call.resolved_impl_func);
}
/** .x 侧 METHOD_CALL：返回 C 名长度（strlen）。 */
int32_t codegen_x_method_call_c_name_len(uint8_t *expr) {
    const char *p = (const char *)codegen_x_method_call_c_name_ptr(expr);
    return p ? (int32_t)strlen(p) : 0;
}
/** .x 侧 METHOD_CALL：base、num_args、第 i 个实参。 */
uint8_t *codegen_x_method_call_base(uint8_t *expr) { const struct ASTExpr *e = (const struct ASTExpr *)expr; return (e && e->kind == AST_EXPR_METHOD_CALL && e->value.method_call.base) ? (uint8_t *)e->value.method_call.base : NULL; }
int32_t codegen_x_method_call_num_args(uint8_t *expr) { const struct ASTExpr *e = (const struct ASTExpr *)expr; return (e && e->kind == AST_EXPR_METHOD_CALL) ? (int32_t)e->value.method_call.num_args : 0; }
uint8_t *codegen_x_method_call_arg(uint8_t *expr, int32_t i) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_METHOD_CALL || !e->value.method_call.args || i < 0 || i >= e->value.method_call.num_args) return NULL;
    return (uint8_t *)e->value.method_call.args[i];
}
/** .x 侧 INDEX：base、index、base_is_slice、skip_bounds；base 的 resolved_type kind 与 array_size。 */
uint8_t *codegen_x_index_base(uint8_t *expr) { const struct ASTExpr *e = (const struct ASTExpr *)expr; return (e && e->kind == AST_EXPR_INDEX && e->value.index.base) ? (uint8_t *)e->value.index.base : NULL; }
uint8_t *codegen_x_index_index(uint8_t *expr) { const struct ASTExpr *e = (const struct ASTExpr *)expr; return (e && e->kind == AST_EXPR_INDEX && e->value.index.index_expr) ? (uint8_t *)e->value.index.index_expr : NULL; }
int32_t codegen_x_index_base_is_slice(uint8_t *expr) { const struct ASTExpr *e = (const struct ASTExpr *)expr; return (e && e->kind == AST_EXPR_INDEX && e->value.index.base_is_slice) ? 1 : 0; }
int32_t codegen_x_index_skip_bounds(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (driver_sanitize_address_get() != 0)
        return 0;
    return (e && e->kind == AST_EXPR_INDEX && e->index_proven_in_bounds) ? 1 : 0;
}
/** .x 侧 FIELD_ACCESS：base 表达式、字段名指针、字段名长度（strlen），供 .x 输出 (base).field。 */
uint8_t *codegen_x_field_access_base(uint8_t *expr) { const struct ASTExpr *e = (const struct ASTExpr *)expr; return (e && e->kind == AST_EXPR_FIELD_ACCESS && e->value.field_access.base) ? (uint8_t *)e->value.field_access.base : NULL; }
uint8_t *codegen_x_field_access_field_name(uint8_t *expr) { const struct ASTExpr *e = (const struct ASTExpr *)expr; return (e && e->kind == AST_EXPR_FIELD_ACCESS && e->value.field_access.field_name) ? (uint8_t *)e->value.field_access.field_name : (uint8_t *)""; }
int32_t codegen_x_field_access_field_len(uint8_t *expr) { const struct ASTExpr *e = (const struct ASTExpr *)expr; const char *fn = (e && e->kind == AST_EXPR_FIELD_ACCESS && e->value.field_access.field_name) ? e->value.field_access.field_name : ""; return (int32_t)strlen(fn); }
/** .x 侧 FIELD_ACCESS：base 是否为指针类型，或 slice 形参（按指针传）；局部 slice 值类型用 `.`。 */
int32_t codegen_x_field_access_base_is_pointer(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_FIELD_ACCESS || !e->value.field_access.base) return 0;
    const struct ASTExpr *base = e->value.field_access.base;
    if (!base->resolved_type) return 0;
    if (base->resolved_type->kind == AST_TYPE_PTR) return 1;
    return 0;
}
int32_t codegen_x_expr_type_kind(uint8_t *expr) { const struct ASTExpr *e = (const struct ASTExpr *)expr; return (e && e->resolved_type) ? (int32_t)e->resolved_type->kind : -1; }
int32_t codegen_x_expr_type_array_size(uint8_t *expr) { const struct ASTExpr *e = (const struct ASTExpr *)expr; return (e && e->resolved_type && e->resolved_type->kind == AST_TYPE_ARRAY) ? (int32_t)e->resolved_type->array_size : 0; }
/** .x 侧 INDEX 数组边界检查：((idx)<0||(idx)>=N ? (shux_panic_(1,0),(base)[0]) : (base)[(idx)])。 */
int32_t codegen_x_emit_index_array_bounds_check(uint8_t *out, uint8_t *base, uint8_t *idx, int32_t array_size) {
    FILE *f = (FILE *)out;
    if (fprintf(f, "(") < 0) return -1;
    if (codegen_expr((const struct ASTExpr *)idx, f) != 0) return -1;
    if (fprintf(f, " < 0 || (") < 0) return -1;
    if (codegen_expr((const struct ASTExpr *)idx, f) != 0) return -1;
    if (fprintf(f, ") >= %d ? (shux_panic_(1, 0), (", (int)array_size) < 0) return -1;
    if (codegen_expr((const struct ASTExpr *)base, f) != 0) return -1;
    if (fprintf(f, ")[0]) : (") < 0) return -1;
    if (codegen_expr((const struct ASTExpr *)base, f) != 0) return -1;
    if (fprintf(f, ")[") < 0) return -1;
    if (codegen_expr((const struct ASTExpr *)idx, f) != 0) return -1;
    return fprintf(f, "])") < 0 ? -1 : 0;
}
/** .x 侧 MATCH：matched_expr、num_arms、arm is_wildcard/is_enum_variant/variant_index/lit_val/result；use_switch(expr)、next_id()。 */
uint8_t *codegen_x_match_matched(uint8_t *expr) { const struct ASTExpr *e = (const struct ASTExpr *)expr; return (e && e->kind == AST_EXPR_MATCH && e->value.match_expr.matched_expr) ? (uint8_t *)e->value.match_expr.matched_expr : NULL; }
int32_t codegen_x_match_num_arms(uint8_t *expr) { const struct ASTExpr *e = (const struct ASTExpr *)expr; return (e && e->kind == AST_EXPR_MATCH) ? (int32_t)e->value.match_expr.num_arms : 0; }
int32_t codegen_x_match_arm_is_wildcard(uint8_t *expr, int32_t i) { const struct ASTExpr *e = (const struct ASTExpr *)expr; if (!e || e->kind != AST_EXPR_MATCH || !e->value.match_expr.arms || i < 0 || i >= e->value.match_expr.num_arms) return 0; return e->value.match_expr.arms[i].is_wildcard ? 1 : 0; }
int32_t codegen_x_match_arm_is_enum_variant(uint8_t *expr, int32_t i) { const struct ASTExpr *e = (const struct ASTExpr *)expr; if (!e || e->kind != AST_EXPR_MATCH || !e->value.match_expr.arms || i < 0 || i >= e->value.match_expr.num_arms) return 0; return e->value.match_expr.arms[i].is_enum_variant ? 1 : 0; }
int32_t codegen_x_match_arm_variant_index(uint8_t *expr, int32_t i) { const struct ASTExpr *e = (const struct ASTExpr *)expr; if (!e || e->kind != AST_EXPR_MATCH || !e->value.match_expr.arms || i < 0 || i >= e->value.match_expr.num_arms) return 0; return (int32_t)e->value.match_expr.arms[i].variant_index; }
int32_t codegen_x_match_arm_lit_val(uint8_t *expr, int32_t i) { const struct ASTExpr *e = (const struct ASTExpr *)expr; if (!e || e->kind != AST_EXPR_MATCH || !e->value.match_expr.arms || i < 0 || i >= e->value.match_expr.num_arms) return 0; return (int32_t)e->value.match_expr.arms[i].lit_val; }
uint8_t *codegen_x_match_arm_result(uint8_t *expr, int32_t i) { const struct ASTExpr *e = (const struct ASTExpr *)expr; if (!e || e->kind != AST_EXPR_MATCH || !e->value.match_expr.arms || i < 0 || i >= e->value.match_expr.num_arms) return NULL; return (uint8_t *)e->value.match_expr.arms[i].result; }
int32_t codegen_x_match_use_switch(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_MATCH || !e->value.match_expr.arms) return 0;
    int num_arms = e->value.match_expr.num_arms;
    const struct ASTMatchArm *arms = e->value.match_expr.arms;
    int value_min = INT_MAX, value_max = INT_MIN, lit_count = 0;
    for (int i = 0; i < num_arms; i++) {
        if (arms[i].is_wildcard) continue;
        int v = arms[i].is_enum_variant ? arms[i].variant_index : arms[i].lit_val;
        lit_count++;
        if (v < value_min) value_min = v;
        if (v > value_max) value_max = v;
    }
    int range = (value_max >= value_min) ? (value_max - value_min + 1) : 0;
    double density = (range > 0 && lit_count > 0) ? (double)lit_count / (double)range : 0.0;
    return (density > 0.7 && lit_count > 0) ? 1 : 0;
}
int32_t codegen_x_match_next_id(void) { return (int32_t)codegen_match_id++; }

/** .x 侧整数除法输出（含除零检查）：( r==0 ? (shux_panic_(1,0), l) : (l/r) )，l/r 按需加括号。 */
int32_t codegen_x_emit_int_div(uint8_t *out, uint8_t *left, uint8_t *right) {
    const struct ASTExpr *l = (const struct ASTExpr *)left, *r = (const struct ASTExpr *)right;
    FILE *f = (FILE *)out;
    int need_l = (l && (l->kind == AST_EXPR_ADD || l->kind == AST_EXPR_SUB));
    int need_r = (r && (r->kind == AST_EXPR_ADD || r->kind == AST_EXPR_SUB));
    fprintf(f, "(");
    if (need_r) fprintf(f, "(");
    if (codegen_expr(r, f) != 0) return -1;
    if (need_r) fprintf(f, ")");
    fprintf(f, " == 0 ? (shux_panic_(1, 0), ");
    if (need_l) fprintf(f, "(");
    if (codegen_expr(l, f) != 0) return -1;
    if (need_l) fprintf(f, ")");
    fprintf(f, ") : (");
    if (need_l) fprintf(f, "(");
    if (codegen_expr(l, f) != 0) return -1;
    if (need_l) fprintf(f, ")");
    fprintf(f, " / ");
    if (need_r) fprintf(f, "(");
    if (codegen_expr(r, f) != 0) return -1;
    if (need_r) fprintf(f, ")");
    fprintf(f, "))");
    return 0;
}

/** .x 侧整数取模输出（含取模零检查）：( r==0 ? (shux_panic_(1,0), l) : (l %% r) )。 */
int32_t codegen_x_emit_int_mod(uint8_t *out, uint8_t *left, uint8_t *right) {
    const struct ASTExpr *l = (const struct ASTExpr *)left, *r = (const struct ASTExpr *)right;
    FILE *f = (FILE *)out;
    fprintf(f, "(");
    if (codegen_expr(r, f) != 0) return -1;
    fprintf(f, " == 0 ? (shux_panic_(1, 0), ");
    if (codegen_expr(l, f) != 0) return -1;
    fprintf(f, ") : (");
    if (codegen_expr(l, f) != 0) return -1;
    fprintf(f, " %% ");
    if (codegen_expr(r, f) != 0) return -1;
    fprintf(f, "))");
    return 0;
}

/** 当前生成所在模块（用于 CALL 时解析泛型调用的单态化实例名）；由 codegen_module_to_c 设置。 */
static const struct ASTModule *codegen_current_module;

/** 库模块 C 符号前缀（如 foo_、core_types_）；由 codegen_library_module_to_c 设置，生成时所有类型/函数名加此前缀。 */
static const char *codegen_library_prefix;
/** 库模块代码生成时指向当前模块，用于 NAMED 类型输出 "struct " 前缀（仅当前模块内定义的 struct）。 */
static const struct ASTModule *codegen_library_module;
/** 库模块 import 路径（如 std.process），用于 std.process.exit 等特殊函数体生成。 */
static const char *codegen_library_import_path;

/**
 * import 解构 as：将本地别名映射到依赖模块源符号名；无 as 或未匹配时返回 local_name。
 */
static const char *codegen_import_select_source_name(const char *local_name) {
    const struct ASTModule *m;
    int j, k;
    if (!local_name)
        return local_name;
    m = codegen_current_module;
    if (!m || !m->import_kinds || !m->import_select_names || !m->import_select_counts)
        return local_name;
    for (j = 0; j < m->num_imports; j++) {
        if (m->import_kinds[j] != AST_IMPORT_KIND_SELECT)
            continue;
        for (k = 0; k < m->import_select_counts[j]; k++) {
            const char *loc = m->import_select_names[j][k];
            if (m->import_select_aliases && m->import_select_aliases[j] && m->import_select_aliases[j][k])
                loc = m->import_select_aliases[j][k];
            if (loc && strcmp(loc, local_name) == 0 && m->import_select_names[j][k])
                return m->import_select_names[j][k];
        }
    }
    return local_name;
}

/** A3 CPS：async 函数 switch(__phase) 分段生成状态。 */
static int codegen_async_cps_active;
static AsyncCpsCodegenCtx codegen_async_cps_ctx;

/** async CPS 正常 return 前 reset __phase（suspend return 不经过此处）。 */
static void codegen_async_cps_before_return(FILE *out, const char *pad) {
    if (codegen_async_cps_active)
        async_cps_codegen_emit_phase_reset(out, pad);
}

/**
 * run v4：按形参类型选择 seed push 运行时入口。
 */
static const char *codegen_run_seed_push_fn(const struct ASTType *ty) {
    if (ty && ty->kind == AST_TYPE_U32)
        return "shux_async_run_seed_push_u32";
    if (ty && ty->kind == AST_TYPE_I64)
        return "shux_async_run_seed_push_i64";
    if (ty && ty->kind == AST_TYPE_USIZE)
        return "shux_async_run_seed_push_usize";
    return "shux_async_run_seed_push_i32";
}

/**
 * IO-A5 v1：`let v = await read(h, ptr, len, tm)` → submit_read_async + suspend_io + complete。
 * 非阻塞 submit 在 suspend 前；resume 后 shux_io_complete_read_async 赋值。
 */
static int codegen_async_cps_await_read(AsyncCpsCodegenCtx *ctx, const struct ASTExpr *await_expr,
    const char *var_name, FILE *out, const char *pad) {
    const struct ASTExpr *op;
    struct ASTExpr **args;
    const AsyncFrameLayout *layout;
    const char *p;
    int phase;
    int i;
    if (!ctx || !await_expr || !var_name || !out || !ctx->layout)
        return -1;
    op = await_expr->value.unary.operand;
    if (!op || op->kind != AST_EXPR_CALL || op->value.call.num_args < 3)
        return -1;
    args = op->value.call.args;
    if (!args || !args[0] || !args[1] || !args[2])
        return -1;
    layout = ctx->layout;
    p = pad ? pad : "  ";
    phase = ctx->phase_next++;
    fprintf(out, "%sif ((__shux_frame.__io_rd_slot = shux_io_submit_read_async(", p);
    if (codegen_expr(args[1], out) != 0) return -1;
    fprintf(out, ", ");
    if (codegen_expr(args[2], out) != 0) return -1;
    fprintf(out, ", ");
    if (codegen_expr(args[0], out) != 0) return -1;
    fprintf(out, ")) < 0) {\n");
    fprintf(out, "%s  %s = -1;\n", p, var_name);
    fprintf(out, "%s} else {\n", p);
    for (i = 0; i < layout->live.n; i++) {
        const char *v = layout->live.names[i];
        if (!v || !v[0]) continue;
        fprintf(out, "%s  __shux_frame.%s = %s;\n", p, v, v);
    }
    fprintf(out, "%s  __shux_frame.__phase = %d;\n", p, phase);
    fprintf(out, "%s  if (shux_async_cps_suspend_io(&__shux_frame.__phase, %d)) return (int32_t)SHUX_ASYNC_SUSPENDED;\n",
        p, phase);
    fprintf(out, "%s}\n", p);
    fprintf(out, "%s/* SHUX_ASYNC_CPS io_read fallthrough phase=%d */\n", p, phase);
    fprintf(out, "%scase %d:\n", p, phase);
    for (i = 0; i < layout->live.n; i++) {
        const char *v = layout->live.names[i];
        if (!v || !v[0]) continue;
        fprintf(out, "%s%s = __shux_frame.%s;\n", p, v, v);
    }
    fprintf(out, "%s%s = shux_io_complete_read_async_slot(__shux_frame.__io_rd_slot);\n", p, var_name);
    return 0;
}

/**
 * IO-A5 v1：`let v = await read_fd(fd, ptr, len)` → submit_read_async(ptr, len, fd as handle)。
 */
static int codegen_async_cps_await_read_fd(AsyncCpsCodegenCtx *ctx, const struct ASTExpr *await_expr,
    const char *var_name, FILE *out, const char *pad) {
    const struct ASTExpr *op;
    struct ASTExpr **args;
    const AsyncFrameLayout *layout;
    const char *p;
    int phase;
    int i;
    if (!ctx || !await_expr || !var_name || !out || !ctx->layout)
        return -1;
    op = await_expr->value.unary.operand;
    if (!op || op->kind != AST_EXPR_CALL || op->value.call.num_args < 3)
        return -1;
    args = op->value.call.args;
    if (!args || !args[0] || !args[1] || !args[2])
        return -1;
    layout = ctx->layout;
    p = pad ? pad : "  ";
    phase = ctx->phase_next++;
    fprintf(out, "%sif ((__shux_frame.__io_rd_slot = shux_io_submit_read_async(", p);
    if (codegen_expr(args[1], out) != 0) return -1;
    fprintf(out, ", ");
    if (codegen_expr(args[2], out) != 0) return -1;
    fprintf(out, ", (size_t)(unsigned)(");
    if (codegen_expr(args[0], out) != 0) return -1;
    /* 多一个 ) 闭合 submit_read_async(，再一个 ) 闭合 if (( 赋值分组 */
    fprintf(out, "))) < 0) {\n");
    fprintf(out, "%s  %s = -1;\n", p, var_name);
    fprintf(out, "%s} else {\n", p);
    for (i = 0; i < layout->live.n; i++) {
        const char *v = layout->live.names[i];
        if (!v || !v[0]) continue;
        fprintf(out, "%s  __shux_frame.%s = %s;\n", p, v, v);
    }
    fprintf(out, "%s  __shux_frame.__phase = %d;\n", p, phase);
    fprintf(out, "%s  if (shux_async_cps_suspend_io(&__shux_frame.__phase, %d)) return (int32_t)SHUX_ASYNC_SUSPENDED;\n",
        p, phase);
    fprintf(out, "%s}\n", p);
    fprintf(out, "%s/* SHUX_ASYNC_CPS io_read_fd fallthrough phase=%d */\n", p, phase);
    fprintf(out, "%scase %d:\n", p, phase);
    for (i = 0; i < layout->live.n; i++) {
        const char *v = layout->live.names[i];
        if (!v || !v[0]) continue;
        fprintf(out, "%s%s = __shux_frame.%s;\n", p, v, v);
    }
    fprintf(out, "%s%s = shux_io_complete_read_async_slot(__shux_frame.__io_rd_slot);\n", p, var_name);
    /* IO resume 后 CQE 可能尚未收割；poll + retry（与 io_read_async_multi 烟测对齐）。 */
    fprintf(out, "%sif (%s == (int32_t)SHUX_IO_ASYNC_NOT_READY) {\n", p, var_name);
    fprintf(out, "%s#if defined(__linux__)\n", p);
    fprintf(out, "%s  (void)shux_io_poll_async_completions(500);\n", p);
    fprintf(out, "%s#endif\n", p);
    fprintf(out, "%s  %s = shux_io_complete_read_async_slot(__shux_frame.__io_rd_slot);\n", p, var_name);
    fprintf(out, "%s}\n", p);
    return 0;
}

/**
 * IO-A5 v1：`let v = await write_fd(fd, ptr, len)` → submit_write_async(ptr, len, fd as handle)。
 */
static int codegen_async_cps_await_write_fd(AsyncCpsCodegenCtx *ctx, const struct ASTExpr *await_expr,
    const char *var_name, FILE *out, const char *pad) {
    const struct ASTExpr *op;
    struct ASTExpr **args;
    const AsyncFrameLayout *layout;
    const char *p;
    int phase;
    int i;
    if (!ctx || !await_expr || !var_name || !out || !ctx->layout)
        return -1;
    op = await_expr->value.unary.operand;
    if (!op || op->kind != AST_EXPR_CALL || op->value.call.num_args < 3)
        return -1;
    args = op->value.call.args;
    if (!args || !args[0] || !args[1] || !args[2])
        return -1;
    layout = ctx->layout;
    p = pad ? pad : "  ";
    phase = ctx->phase_next++;
    fprintf(out, "%sif ((__shux_frame.__io_wr_slot = shux_io_submit_write_async(", p);
    if (codegen_expr(args[1], out) != 0) return -1;
    fprintf(out, ", ");
    if (codegen_expr(args[2], out) != 0) return -1;
    fprintf(out, ", (size_t)(unsigned)(");
    if (codegen_expr(args[0], out) != 0) return -1;
    /* 多一个 ) 闭合 submit_write_async(，再一个 ) 闭合 if (( 赋值分组 */
    fprintf(out, "))) < 0) {\n");
    fprintf(out, "%s  %s = -1;\n", p, var_name);
    fprintf(out, "%s} else {\n", p);
    for (i = 0; i < layout->live.n; i++) {
        const char *v = layout->live.names[i];
        if (!v || !v[0]) continue;
        fprintf(out, "%s  __shux_frame.%s = %s;\n", p, v, v);
    }
    fprintf(out, "%s  __shux_frame.__phase = %d;\n", p, phase);
    fprintf(out, "%s  if (shux_async_cps_suspend_io(&__shux_frame.__phase, %d)) return (int32_t)SHUX_ASYNC_SUSPENDED;\n",
        p, phase);
    fprintf(out, "%s}\n", p);
    fprintf(out, "%s/* SHUX_ASYNC_CPS io_write_fd fallthrough phase=%d */\n", p, phase);
    fprintf(out, "%scase %d:\n", p, phase);
    for (i = 0; i < layout->live.n; i++) {
        const char *v = layout->live.names[i];
        if (!v || !v[0]) continue;
        fprintf(out, "%s%s = __shux_frame.%s;\n", p, v, v);
    }
    fprintf(out, "%s%s = shux_io_complete_write_async_slot(__shux_frame.__io_wr_slot);\n", p, var_name);
    return 0;
}

/**
 * IO-A5 v1：`let v = await write(h, ptr, len, tm)` → submit_write_async + suspend_io + complete。
 */
static int codegen_async_cps_await_write(AsyncCpsCodegenCtx *ctx, const struct ASTExpr *await_expr,
    const char *var_name, FILE *out, const char *pad) {
    const struct ASTExpr *op;
    struct ASTExpr **args;
    const AsyncFrameLayout *layout;
    const char *p;
    int phase;
    int i;
    if (!ctx || !await_expr || !var_name || !out || !ctx->layout)
        return -1;
    op = await_expr->value.unary.operand;
    if (!op || op->kind != AST_EXPR_CALL || op->value.call.num_args < 3)
        return -1;
    args = op->value.call.args;
    if (!args || !args[0] || !args[1] || !args[2])
        return -1;
    layout = ctx->layout;
    p = pad ? pad : "  ";
    phase = ctx->phase_next++;
    fprintf(out, "%sif ((__shux_frame.__io_wr_slot = shux_io_submit_write_async(", p);
    if (codegen_expr(args[1], out) != 0) return -1;
    fprintf(out, ", ");
    if (codegen_expr(args[2], out) != 0) return -1;
    fprintf(out, ", ");
    if (codegen_expr(args[0], out) != 0) return -1;
    fprintf(out, ")) < 0) {\n");
    fprintf(out, "%s  %s = -1;\n", p, var_name);
    fprintf(out, "%s} else {\n", p);
    for (i = 0; i < layout->live.n; i++) {
        const char *v = layout->live.names[i];
        if (!v || !v[0]) continue;
        fprintf(out, "%s  __shux_frame.%s = %s;\n", p, v, v);
    }
    fprintf(out, "%s  __shux_frame.__phase = %d;\n", p, phase);
    fprintf(out, "%s  if (shux_async_cps_suspend_io(&__shux_frame.__phase, %d)) return (int32_t)SHUX_ASYNC_SUSPENDED;\n",
        p, phase);
    fprintf(out, "%s}\n", p);
    fprintf(out, "%s/* SHUX_ASYNC_CPS io_write fallthrough phase=%d */\n", p, phase);
    fprintf(out, "%scase %d:\n", p, phase);
    for (i = 0; i < layout->live.n; i++) {
        const char *v = layout->live.names[i];
        if (!v || !v[0]) continue;
        fprintf(out, "%s%s = __shux_frame.%s;\n", p, v, v);
    }
    fprintf(out, "%s%s = shux_io_complete_write_async_slot(__shux_frame.__io_wr_slot);\n", p, var_name);
    return 0;
}

/**
 * STD-041：`let st = await future_wait(&fut, n)` → poll+drain 循环；Pending 时 suspend_io 直至 Ready。
 */
static int codegen_async_cps_await_future_wait(AsyncCpsCodegenCtx *ctx, const struct ASTExpr *await_expr,
    const char *var_name, FILE *out, const char *pad) {
    const struct ASTExpr *op;
    const AsyncFrameLayout *layout;
    const char *p;
    int phase;
    int i;
    if (!ctx || !await_expr || !var_name || !out || !ctx->layout)
        return -1;
    op = await_expr->value.unary.operand;
    if (!op || (op->kind != AST_EXPR_CALL && op->kind != AST_EXPR_METHOD_CALL))
        return -1;
    layout = ctx->layout;
    p = pad ? pad : "  ";
    phase = ctx->phase_next++;
    fprintf(out, "%s/* SHUX_ASYNC_CPS future_wait loop phase=%d */\n", p, phase);
    fprintf(out, "%sfw_await_%d:\n", p, phase);
    fprintf(out, "%s%s = ", p, var_name);
    if (codegen_expr(op, out) != 0) return -1;
    fprintf(out, ";\n");
    fprintf(out, "%sif (%s != 0) goto fw_await_%d_done;\n", p, var_name, phase);
    for (i = 0; i < layout->live.n; i++) {
        const char *v = layout->live.names[i];
        if (!v || !v[0]) continue;
        fprintf(out, "%s__shux_frame.%s = %s;\n", p, v, v);
    }
    fprintf(out, "%s__shux_frame.__phase = %d;\n", p, phase);
    fprintf(out, "%sif (shux_async_cps_suspend_io(&__shux_frame.__phase, %d)) return (int32_t)SHUX_ASYNC_SUSPENDED;\n",
        p, phase);
    fprintf(out, "%scase %d:\n", p, phase);
    for (i = 0; i < layout->live.n; i++) {
        const char *v = layout->live.names[i];
        if (!v || !v[0]) continue;
        fprintf(out, "%s%s = __shux_frame.%s;\n", p, v, v);
    }
    fprintf(out, "%sgoto fw_await_%d;\n", p, phase);
    fprintf(out, "%sfw_await_%d_done:\n", p, phase);
    return 0;
}

/** DCE/WPO 未直连时：模块内有 shux_async_sched_<fn> extern 则保留 async 函数体。 */
static int codegen_async_keep_for_sched(const struct ASTModule *m, const struct ASTFunc *f,
    codegen_is_func_used_fn is_func_used, void *dce_ctx) {
    if (!dce_ctx || !is_func_used || is_func_used(dce_ctx, m, f))
        return 1;
    return async_cps_module_has_sched_extern(m, f) || async_cps_module_references_run_async(m, f);
}

/** pipeline 单文件时 preamble 已输出 Option_i32/Result_i32，库模块生成时跳过二者避免重定义。由 runtime 在调用 pipeline 前置 1。 */
static int codegen_preamble_has_core_option_result = 0;
void codegen_set_preamble_has_core_option_result(int on) { codegen_preamble_has_core_option_result = on ? 1 : 0; }

/** codegen.x emit 与 write_io_net_abi_inline 重叠段时 OR 入；pipeline 完成后 runtime 读此 mask 跳过 preamble 行。 */
static unsigned codegen_preamble_skip_mask = 0;
void codegen_reset_preamble_skip_mask(void) { codegen_preamble_skip_mask = 0; }
void codegen_or_preamble_skip_mask(unsigned mask) { codegen_preamble_skip_mask |= mask; }
unsigned codegen_get_preamble_skip_mask(void) { return codegen_preamble_skip_mask; }

/** 指针宽度有符号类型（ptrdiff_t），用于 std.io.driver 的 register/submit_read/submit_write 首参，避免 64 位下 int32_t 截断。 */
static const struct ASTType codegen_override_isize = { .kind = AST_TYPE_ISIZE, .name = NULL, .elem_type = NULL, .array_size = 0 };

/** uint32_t 覆盖，用于 std.io.driver 的 submit_register_fixed_buffers_buf 第二参 nr、submit_read/submit_write 的 timeout_ms，与 preamble 声明一致。 */
static const struct ASTType codegen_override_u32 = { .kind = AST_TYPE_U32, .name = NULL, .elem_type = NULL, .array_size = 0 };

/** 若 import_path 为 std.io.driver：param_index==0 且 register/submit_read/submit_write 返回 isize（ptrdiff_t）；param_index==1 且 submit_register_fixed_buffers_buf/submit_read/submit_write 返回 u32（uint32_t）。submit_register_fixed_buffers_buf 首参为 struct * 不覆盖。 */
static const struct ASTType *codegen_io_driver_param_override(const char *import_path, const char *func_name, int param_index) {
    if (!import_path || !func_name) return NULL;
    if (strcmp(import_path, "std.io.driver") != 0 && strcmp(import_path, "std/io/driver") != 0)
        return NULL;
    if (param_index == 0
        && (strcmp(func_name, "register") == 0 || strcmp(func_name, "submit_read") == 0 || strcmp(func_name, "submit_write") == 0))
        return &codegen_override_isize;
    if (param_index == 1
        && (strcmp(func_name, "submit_register_fixed_buffers_buf") == 0 || strcmp(func_name, "submit_read") == 0 || strcmp(func_name, "submit_write") == 0))
        return &codegen_override_u32;
    return NULL;
}

/** 入口模块代码生成时的依赖模块与 import 路径，用于 NAMED 类型解析为 "struct prefix_Name"（依赖中的 struct）。 */
static struct ASTModule **codegen_dep_mods;
static const char **codegen_dep_paths;
static int codegen_ndep;

void codegen_set_dep_slots_for_x_pipeline(struct ASTModule **mods, const char **paths, int n) {
    codegen_dep_mods = (n > 0 && mods && paths) ? mods : NULL;
    codegen_dep_paths = (n > 0 && mods && paths) ? paths : NULL;
    codegen_ndep = (n > 0 && mods && paths) ? n : 0;
}

/** .x 侧 FIELD_ACCESS：是否为枚举变体输出路径（Type.Variant 或库模块枚举），非 0 时 .x 转调 emit_field_access_enum_variant_full。需在 codegen_library_prefix 等声明之后。 */
int32_t codegen_x_field_access_is_enum_variant(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_FIELD_ACCESS || !e->value.field_access.base) return 0;
    if (e->value.field_access.is_enum_variant && e->value.field_access.base->kind == AST_EXPR_VAR) return 1;
    if (codegen_library_prefix && *codegen_library_prefix && codegen_library_module && codegen_library_module->enum_defs
        && e->value.field_access.base->kind == AST_EXPR_VAR && e->value.field_access.base->value.var.name) {
        const char *en2 = e->value.field_access.base->value.var.name;
        for (int i = 0; i < codegen_library_module->num_enums; i++)
            if (codegen_library_module->enum_defs[i]->name && strcmp(codegen_library_module->enum_defs[i]->name, en2) == 0)
                return 1;
    }
    return 0;
}

/** 单文件模式时已输出类型名集合（与 codegen_module_to_c/codegen_library_module_to_c 参数一致），供 ensure_slice_struct 去重 slice 结构体。 */
static char (*codegen_emitted_type_names)[CODEGEN_EMITTED_TYPE_NAME_MAX];
static int *codegen_n_emitted_inout;
static int codegen_max_emitted;

/** 单文件多模块去重：判断 c_name 是否已在已输出类型名列表中。 */
static int emitted_type_contains(const char *c_name, char (*emitted_type_names)[CODEGEN_EMITTED_TYPE_NAME_MAX], int n) {
    if (!emitted_type_names || !c_name) return 0;
    for (int i = 0; i < n; i++)
        if (strcmp(emitted_type_names[i], c_name) == 0) return 1;
    return 0;
}
/** 单文件多模块去重：将 c_name 加入已输出列表。 */
static void emitted_type_add(const char *c_name, char (*emitted_type_names)[CODEGEN_EMITTED_TYPE_NAME_MAX], int *n_emitted_inout, int max_emitted) {
    if (!emitted_type_names || !n_emitted_inout || *n_emitted_inout >= max_emitted || !c_name) return;
    snprintf(emitted_type_names[*n_emitted_inout], CODEGEN_EMITTED_TYPE_NAME_MAX, "%s", c_name);
    (*n_emitted_inout)++;
}

/** 若 name 已含 pre 语义则返回非 0：build_* 或 std_<seg>_ 与 <seg>_*（C 库符号无前缀重复）。 */
static int codegen_c_prefix_redundant_with_name_c(const char *pre, const char *name) {
    size_t pl, nl;
    if (!pre || !pre[0] || !name) return 0;
    pl = strlen(pre);
    nl = strlen(name);
    if (pl == 0 || nl == 0) return 0;
    if (strcmp(pre, "build_") == 0 && nl >= pl && strncmp(name, pre, pl) == 0)
        return 1;
    /* name 已含完整 import 前缀（如 std_csv_csv_test_*）；勿仅用 pre+4 段前缀去重（会破坏 std.csv）。 */
    if (nl >= pl && strncmp(name, pre, pl) == 0)
        return 1;
    return 0;
}

/** 将 import 路径对应的 C 前缀 pre 与函数名 name 拼成符号；仅 build_ 前缀时对已含前缀的 name 去重。 */
static void codegen_join_import_prefix_func_name(const char *pre, const char *name, char *buf, size_t buf_size) {
    if (!buf || buf_size == 0) return;
    if (!name) name = "";
    if (!pre || !pre[0]) {
        (void)snprintf(buf, buf_size, "%s", name);
        return;
    }
    if (codegen_c_prefix_redundant_with_name_c(pre, name))
        (void)snprintf(buf, buf_size, "%s", name);
    else
        (void)snprintf(buf, buf_size, "%s%s", pre, name);
}

/** 当 codegen_library_prefix 已设置时，将 name 写成 prefix+name 到 buf；否则只写 name。用于库模块符号不冲突。 */
static void library_prefixed_name(const char *name, char *buf, size_t size) {
    if (!name) name = "";
    if (!codegen_library_prefix || !*codegen_library_prefix) {
        (void)snprintf(buf, size, "%s", name);
        return;
    }
    if (codegen_c_prefix_redundant_with_name_c(codegen_library_prefix, name)) {
        (void)snprintf(buf, size, "%s", name);
        return;
    }
    (void)snprintf(buf, size, "%s%s", codegen_library_prefix, name);
}

/** 泛型单态化生成时的代入上下文（由 codegen_one_mono_instance 设置）；非 NULL 时 const/let 类型用代入后的类型。 */
static char **codegen_subst_gp_names;
static struct ASTType **codegen_subst_type_args;
static int codegen_subst_n;

/** 判断 NAMED 类型名是否为顶层枚举（§7.4）；用于输出 enum 与 struct 区分。 */
static int is_enum_type(const struct ASTModule *m, const char *name) {
    if (!m || !name || !m->enum_defs) return 0;
    for (int i = 0; i < m->num_enums; i++)
        if (m->enum_defs[i] && m->enum_defs[i]->name && strcmp(m->enum_defs[i]->name, name) == 0) return 1;
    return 0;
}

/** 判断两个类型是否相等（用于查找单态化实例）；与 typeck 的 type_equal 逻辑一致。 */
static int type_equal(const struct ASTType *a, const struct ASTType *b) {
    if (!a || !b) return (a == b);
    if (a->kind != b->kind) return 0;
    if (a->kind == AST_TYPE_NAMED)
        return (a->name && b->name && strcmp(a->name, b->name) == 0);
    if (a->kind == AST_TYPE_PTR || a->kind == AST_TYPE_SLICE || a->kind == AST_TYPE_LINEAR || a->kind == AST_TYPE_VECTOR)
        return type_equal(a->elem_type, b->elem_type);
    if (a->kind == AST_TYPE_ARRAY)
        return a->array_size == b->array_size && type_equal(a->elem_type, b->elem_type);
    return 1;
}

/** 泛型代入：若 ty 为 NAMED 且在 gp_names 中则返回对应 type_args[i]，否则返回 ty。用于单态化生成时类型替换。 */
static const struct ASTType *subst_type(const struct ASTType *ty, char **gp_names,
    struct ASTType **type_args, int num_gp) {
    if (!ty || !gp_names || !type_args || num_gp <= 0) return ty;
    if (ty->kind == AST_TYPE_NAMED && ty->name) {
        for (int i = 0; i < num_gp; i++)
            if (gp_names[i] && strcmp(ty->name, gp_names[i]) == 0) return type_args[i];
    }
    return ty;
}

/** 将类型写成 mangle 用后缀（如 i32 -> "i32"，*i32 -> "ptr_i32"）；写入 buf，最多 size 字节。 */
static void type_to_suffix(const struct ASTType *ty, char *buf, size_t size) {
    if (!ty || size == 0) return;
    if (ty->kind == AST_TYPE_PTR && ty->elem_type) {
        type_to_suffix(ty->elem_type, buf, size);
        size_t len = strnlen(buf, size - 1);
        if (len + 6 < size) { snprintf(buf + len, size - len, "_ptr"); }
        return;
    }
    if (ty->kind == AST_TYPE_NAMED && ty->name) { snprintf(buf, size, "%s", ty->name); return; }
    const char *s = "i32";
    switch (ty->kind) {
        case AST_TYPE_I32:   s = "i32"; break;
        case AST_TYPE_F32:   s = "f32"; break;
        case AST_TYPE_F64:   s = "f64"; break;
        case AST_TYPE_BOOL:  s = "bool"; break;
        case AST_TYPE_U8:   s = "u8"; break;
        case AST_TYPE_U32:   s = "u32"; break;
        case AST_TYPE_U64:   s = "u64"; break;
        case AST_TYPE_I64:   s = "i64"; break;
        case AST_TYPE_USIZE: s = "usize"; break;
        case AST_TYPE_ISIZE: s = "isize"; break;
        default: break;
    }
    snprintf(buf, size, "%s", s);
}

/** impl 方法 C 函数名：Trait_Type_method（阶段 7.2）；f 须为 impl 块内函数（impl_for_trait/impl_for_type 非 NULL）。 */
static const char *impl_method_c_name(const struct ASTFunc *f) {
    static char buf[256];
    if (!f || !f->impl_for_trait || !f->impl_for_type || !f->name) return f ? f->name : "";
    snprintf(buf, sizeof(buf), "%s_%s_%s", f->impl_for_trait, f->impl_for_type, f->name);
    return buf;
}

/** 模块内是否存在同名非泛型函数（用于单态化名与具象 API 符号去重）。 */
static int module_has_non_generic_func(const struct ASTModule *mod, const char *name) {
    if (!mod || !name || !mod->funcs) return 0;
    for (int i = 0; i < mod->num_funcs; i++) {
        const struct ASTFunc *fn = mod->funcs[i];
        if (fn && fn->name && fn->num_generic_params == 0 && strcmp(fn->name, name) == 0)
            return 1;
    }
    return 0;
}

/** 单态化实例的 C 函数名：name_t1_t2（如 id_i32）；与具象函数同名时插入 _mono_（unwrap_or_i32 vs unwrap_or<i32>）。 */
static const char *mono_instance_mangled_name_ex(const struct ASTModule *mod,
    const struct ASTFunc *f, struct ASTType **type_args, int num_type_args) {
    static char buf[256];
    if (!f || !f->name || num_type_args <= 0 || !type_args) return f ? f->name : "";
    size_t n = (size_t)snprintf(buf, sizeof(buf), "%s", f->name);
    for (int i = 0; i < num_type_args && n < sizeof(buf) - 2; i++) {
        char suf[64];
        type_to_suffix(type_args[i], suf, sizeof(suf));
        n += (size_t)snprintf(buf + n, sizeof(buf) - n, "_%s", suf);
    }
    if (mod && module_has_non_generic_func(mod, buf)) {
        n = (size_t)snprintf(buf, sizeof(buf), "%s_mono", f->name);
        for (int i = 0; i < num_type_args && n < sizeof(buf) - 2; i++) {
            char suf[64];
            type_to_suffix(type_args[i], suf, sizeof(suf));
            n += (size_t)snprintf(buf + n, sizeof(buf) - n, "_%s", suf);
        }
    }
    return buf;
}

/** 单态化实例 C 名（无模块上下文时不做具象符号去重）。 */
static const char *mono_instance_mangled_name(const struct ASTFunc *f,
    struct ASTType **type_args, int num_type_args) {
    return mono_instance_mangled_name_ex(NULL, f, type_args, num_type_args);
}

/** 统计模块内同名函数个数（>1 时须 mangled C 符号）。 */
static int module_func_overload_count(const struct ASTModule *mod, const char *name) {
    int c = 0;
    if (!mod || !name || !mod->funcs) return 0;
    for (int i = 0; i < mod->num_funcs; i++)
        if (mod->funcs[i] && mod->funcs[i]->name && strcmp(mod->funcs[i]->name, name) == 0) c++;
    return c;
}

static const struct ASTModule *codegen_find_func_module(const struct ASTFunc *f);

/** overload C 函数名：name_t1_t2；实参签名相同时追加 _ret_<T> 避免链接符号冲突。 */
static int func_param_sig_equal(const struct ASTFunc *a, const struct ASTFunc *b) {
    int i;
    if (!a || !b || a->num_params != b->num_params) return 0;
    for (i = 0; i < a->num_params; i++) {
        char sa[64], sb[64];
        type_to_suffix(a->params[i].type, sa, sizeof(sa));
        type_to_suffix(b->params[i].type, sb, sizeof(sb));
        if (strcmp(sa, sb) != 0) return 0;
    }
    return 1;
}

/** 模块内与 f 同名且形参签名相同的 overload 个数。 */
static int module_overload_param_sig_count(const struct ASTModule *mod, const struct ASTFunc *f) {
    int c = 0, i;
    if (!mod || !f || !f->name || !mod->funcs) return 0;
    for (i = 0; i < mod->num_funcs; i++) {
        struct ASTFunc *g = mod->funcs[i];
        if (!g || !g->name || strcmp(g->name, f->name) != 0) continue;
        if (func_param_sig_equal(f, g)) c++;
    }
    return c;
}

static const char *overload_mangled_name(const struct ASTFunc *f) {
    static char buf[256];
    const struct ASTModule *mod;
    if (!f || !f->name) return "";
    mod = codegen_find_func_module(f);
    size_t n = (size_t)snprintf(buf, sizeof(buf), "%s", f->name);
    for (int i = 0; i < f->num_params && n < sizeof(buf) - 2; i++) {
        char suf[64];
        type_to_suffix(f->params[i].type, suf, sizeof(suf));
        n += (size_t)snprintf(buf + n, sizeof(buf) - n, "_%s", suf);
    }
    if (mod && module_overload_param_sig_count(mod, f) > 1 && f->return_type && n < sizeof(buf) - 8) {
        char rs[64];
        type_to_suffix(f->return_type, rs, sizeof(rs));
        n += (size_t)snprintf(buf + n, sizeof(buf) - n, "_ret_%s", rs);
    }
    return buf;
}

/** 判断 f 是否属于模块 mod。 */
static int func_in_module(const struct ASTModule *mod, const struct ASTFunc *f) {
    if (!mod || !f || !mod->funcs) return 0;
    for (int i = 0; i < mod->num_funcs; i++)
        if (mod->funcs[i] == f) return 1;
    return 0;
}

/** 查找函数所在模块（入口 / 依赖 / 库模块）。 */
static const struct ASTModule *codegen_find_func_module(const struct ASTFunc *f) {
    if (!f) return NULL;
    if (codegen_current_module && func_in_module(codegen_current_module, f)) return codegen_current_module;
    if (codegen_library_module && func_in_module(codegen_library_module, f)) return codegen_library_module;
    for (int di = 0; di < codegen_ndep && codegen_dep_mods; di++)
        if (codegen_dep_mods[di] && func_in_module(codegen_dep_mods[di], f)) return codegen_dep_mods[di];
    return codegen_current_module;
}

/** 按 import 路径查找已加载的依赖模块（供 extern / overload 链接名）。 */
static const struct ASTModule *codegen_module_for_import_path(const char *import_path) {
    if (!import_path) return NULL;
    for (int di = 0; di < codegen_ndep && codegen_dep_paths; di++)
        if (codegen_dep_paths[di] && strcmp(codegen_dep_paths[di], import_path) == 0)
            return codegen_dep_mods ? codegen_dep_mods[di] : NULL;
    return NULL;
}

/** 链接用 C 符号：无 overload 时用原名，否则 mangled。 */
static const char *func_link_name(const struct ASTModule *mod, const struct ASTFunc *f) {
    if (!f || !f->name) return "";
    if (f->link_name) return f->link_name;  /* L9：#[link_name] 用指定符号名 */
    if (!mod) {
        /* 【Why 根源】传递依赖模块不在 codegen_dep_paths 中时 mod=NULL（如 std.io 被 std.fmt
         * 传递依赖，但 codegen_dep_paths 只含直接 import）。此时若不遍历全部依赖模块统计
         * 同名函数个数，会漏检 overload，导致 C 链接符号冲突（conflicting types）。
         * 【Invariant】仅当 >1 个依赖模块含同名函数时才 mangle，避免误 mangle 单定义函数。 */
        int total = 0;
        for (int di = 0; di < codegen_ndep && codegen_dep_mods; di++)
            total += module_func_overload_count(codegen_dep_mods[di], f->name);
        if (total <= 1) return f->name;
        return overload_mangled_name(f);
    }
    if (module_func_overload_count(mod, f->name) <= 1) return f->name;
    return overload_mangled_name(f);
}

/** 解析 CALL 的目标 C 符号名（泛型单态 / overload / 普通名）。 */
static const char *call_instance_mangled_name(const struct ASTFunc *f, const struct ASTExpr *e) {
    if (!f || !e || e->kind != AST_EXPR_CALL) return f ? f->name : "";
    if (e->value.call.num_type_args > 0 && e->value.call.type_args)
        return mono_instance_mangled_name_ex(codegen_find_func_module(f), f,
            e->value.call.type_args, e->value.call.num_type_args);
    return func_link_name(codegen_find_func_module(f), f);
}

/** 将 import 路径转为 C 符号前缀（如 "foo" -> "foo_"，"core.types" -> "core_types_"）；用于跨模块调用。 */
static void import_path_to_c_prefix(const char *import_path, char *buf, size_t size) {
    if (!buf || size == 0) return;
    size_t off = 0;
    for (const char *s = import_path; *s && off + 2 < size; s++)
        buf[off++] = (char)(*s == '.' ? '_' : *s);
    if (off + 1 < size) buf[off++] = '_';
    buf[off] = '\0';
}

#define MAX_IMPORT_DECLS 64
/** 泛型 import 调用收集：path、func、type_args、num_type_args；最多 MAX_IMPORT_DECLS 条。 */
#define MAX_GEN_IMPORT_DECLS 32

/** 前向声明：块体生成与块内 import/lib_dep 收集在文件后部定义，供 AST_EXPR_BLOCK 与 AST_EXPR_IF 使用。 */
static void collect_import_calls_from_block(const struct ASTBlock *b, const char **paths, struct ASTFunc **funcs, int *n,
    const char **gen_paths, struct ASTFunc **gen_funcs, struct ASTType ***gen_type_args, int *gen_n, int *gen_count);
static void collect_lib_dep_calls_from_block(const struct ASTBlock *b, struct ASTModule **lib_dep_mods, const char **lib_dep_paths, int n_lib_dep,
    const char **paths_out, struct ASTFunc **funcs_out, int *n_out, int max_out);

/** 从表达式 e 递归收集跨模块 CALL：非泛型追加到 paths/funcs/n，泛型追加到 gen_*（供 emit extern）。 */
static void collect_import_calls_from_expr(const struct ASTExpr *e, const char **paths, struct ASTFunc **funcs, int *n,
    const char **gen_paths, struct ASTFunc **gen_funcs, struct ASTType ***gen_type_args, int *gen_n, int *gen_count) {
    if (!e || !paths || !funcs || !n) return;
    if (e->kind == AST_EXPR_CALL && e->value.call.resolved_import_path && e->value.call.resolved_callee_func
        && !e->value.call.resolved_callee_func->is_extern) {
        if (e->value.call.num_type_args <= 0 || !e->value.call.type_args) {
            if (*n >= MAX_IMPORT_DECLS) return;
            for (int i = 0; i < *n; i++)
                if (paths[i] == e->value.call.resolved_import_path && funcs[i] == e->value.call.resolved_callee_func) return;
            paths[*n] = e->value.call.resolved_import_path;
            funcs[*n] = e->value.call.resolved_callee_func;
            (*n)++;
            return;
        }
        if (gen_paths && gen_funcs && gen_type_args && gen_n && gen_count && *gen_count < MAX_GEN_IMPORT_DECLS) {
            int nt = e->value.call.num_type_args;
            int found = 0;
            for (int i = 0; i < *gen_count; i++) {
                if (gen_paths[i] != e->value.call.resolved_import_path || gen_funcs[i] != e->value.call.resolved_callee_func) continue;
                if (gen_n[i] != nt) continue;
                int eq = 1;
                for (int j = 0; j < nt && eq; j++)
                    if (!type_equal(gen_type_args[i][j], e->value.call.type_args[j])) eq = 0;
                if (eq) { found = 1; break; }
            }
            if (!found) {
                gen_paths[*gen_count] = e->value.call.resolved_import_path;
                gen_funcs[*gen_count] = e->value.call.resolved_callee_func;
                gen_type_args[*gen_count] = e->value.call.type_args;
                gen_n[*gen_count] = nt;
                (*gen_count)++;
            }
        }
    }
    /* module.func 形式的 METHOD_CALL 也需登记，供 -E 生成 extern */
    if (e->kind == AST_EXPR_METHOD_CALL && e->value.method_call.resolved_import_path && e->value.method_call.resolved_impl_func
        && !e->value.method_call.resolved_impl_func->is_extern) {
        if (*n < MAX_IMPORT_DECLS) {
            int found = 0;
            for (int i = 0; i < *n; i++)
                if (paths[i] == e->value.method_call.resolved_import_path && funcs[i] == e->value.method_call.resolved_impl_func) { found = 1; break; }
            if (!found) {
                paths[*n] = e->value.method_call.resolved_import_path;
                funcs[*n] = e->value.method_call.resolved_impl_func;
                (*n)++;
            }
        }
    }
    switch (e->kind) {
        case AST_EXPR_CALL:
            for (int i = 0; i < e->value.call.num_args; i++)
                collect_import_calls_from_expr(e->value.call.args[i], paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
            collect_import_calls_from_expr(e->value.binop.left, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            collect_import_calls_from_expr(e->value.binop.right, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT: case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF:
        case AST_EXPR_AWAIT: case AST_EXPR_RUN: case AST_EXPR_SPAWN: case AST_EXPR_TRY_PROPAGATE:
        case AST_EXPR_RETURN:
            /* 【Why 根源】AST_EXPR_RETURN 的 return expr 存于 value.unary.operand（parser.c:1588）；
             * 若不递归收集，return module.func() 形式的 METHOD_CALL 会被遗漏，导致 -E-extern
             * 生成的 C 缺少 extern 声明、cc 报 implicit function declaration。
             * 【Invariant】operand 可为 NULL（裸 return;），collect_import_calls_from_expr 入口已 null 检查。 */
            collect_import_calls_from_expr(e->value.unary.operand, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        case AST_EXPR_AS:
            collect_import_calls_from_expr(e->value.as_type.operand, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        case AST_EXPR_IF:
        case AST_EXPR_TERNARY:
            collect_import_calls_from_expr(e->value.if_expr.cond, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            collect_import_calls_from_expr(e->value.if_expr.then_expr, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            if (e->value.if_expr.else_expr) collect_import_calls_from_expr(e->value.if_expr.else_expr, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        case AST_EXPR_BLOCK:
            collect_import_calls_from_block(e->value.block, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        case AST_EXPR_ASSIGN:
        case AST_EXPR_ADD_ASSIGN: case AST_EXPR_SUB_ASSIGN: case AST_EXPR_MUL_ASSIGN: case AST_EXPR_DIV_ASSIGN: case AST_EXPR_MOD_ASSIGN:
        case AST_EXPR_BITAND_ASSIGN: case AST_EXPR_BITOR_ASSIGN: case AST_EXPR_BITXOR_ASSIGN: case AST_EXPR_SHL_ASSIGN: case AST_EXPR_SHR_ASSIGN:
            collect_import_calls_from_expr(e->value.binop.left, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            collect_import_calls_from_expr(e->value.binop.right, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        case AST_EXPR_MATCH:
            collect_import_calls_from_expr(e->value.match_expr.matched_expr, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            for (int i = 0; i < e->value.match_expr.num_arms; i++)
                collect_import_calls_from_expr(e->value.match_expr.arms[i].result, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        case AST_EXPR_FIELD_ACCESS:
            collect_import_calls_from_expr(e->value.field_access.base, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        case AST_EXPR_STRUCT_LIT:
            for (int i = 0; i < e->value.struct_lit.num_fields; i++)
                collect_import_calls_from_expr(e->value.struct_lit.inits[i], paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++)
                collect_import_calls_from_expr(e->value.array_lit.elems[i], paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        case AST_EXPR_INDEX:
            collect_import_calls_from_expr(e->value.index.base, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            collect_import_calls_from_expr(e->value.index.index_expr, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        case AST_EXPR_METHOD_CALL:
            collect_import_calls_from_expr(e->value.method_call.base, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            for (int i = 0; i < e->value.method_call.num_args; i++)
                collect_import_calls_from_expr(e->value.method_call.args[i], paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        case AST_EXPR_PANIC:
            if (e->value.unary.operand) collect_import_calls_from_expr(e->value.unary.operand, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
            break;
        default: break;
    }
}
/** 从表达式 e 递归收集「库模块内对 lib_dep 的调用」：callee 为 VAR 且在 lib_dep_mods 中找到则追加 (path, func)，供生成 extern。 */
static void collect_lib_dep_calls_from_expr(const struct ASTExpr *e, struct ASTModule **lib_dep_mods, const char **lib_dep_paths, int n_lib_dep,
    const char **paths_out, struct ASTFunc **funcs_out, int *n_out, int max_out) {
    if (!e || !paths_out || !funcs_out || !n_out || *n_out >= max_out) return;
    if (e->kind == AST_EXPR_CALL && e->value.call.callee->kind == AST_EXPR_VAR && lib_dep_mods && lib_dep_paths && n_lib_dep > 0) {
        const char *callee_name = e->value.call.callee->value.var.name;
        if (callee_name) {
            for (int di = 0; di < n_lib_dep; di++) {
                const struct ASTModule *dm = lib_dep_mods[di];
                if (!dm || !dm->funcs) continue;
                for (int fi = 0; fi < dm->num_funcs; fi++) {
                    if (!dm->funcs[fi]) continue;
                    /* 【Why 根源】extern FFI 函数（如 macOS libSystem write(2)）用裸名链接，不加
                     * lib_prefix。若收集为 lib_dep 调用，会生成带前缀的 extern 声明（如
                     * std_sys_macos_write），与当前模块同名函数（如 std_sys_ + macos_write）碰撞。
                     * extern 函数由 codegen_emit_module_extern_func_proto 用裸名声明，无需此处收集。 */
                    if (dm->funcs[fi]->is_extern) continue;
                    if (dm->funcs[fi]->name && strcmp(dm->funcs[fi]->name, callee_name) == 0) {
                        for (int k = 0; k < *n_out; k++)
                            if (paths_out[k] == lib_dep_paths[di] && funcs_out[k] == dm->funcs[fi]) goto next_call;
                        paths_out[*n_out] = lib_dep_paths[di];
                        funcs_out[*n_out] = (struct ASTFunc *)dm->funcs[fi];
                        (*n_out)++;
                        goto next_call;
                    }
                }
            }
        }
next_call: ;
    }
    switch (e->kind) {
        case AST_EXPR_CALL:
            for (int i = 0; i < e->value.call.num_args; i++)
                collect_lib_dep_calls_from_expr(e->value.call.args[i], lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
            collect_lib_dep_calls_from_expr(e->value.binop.left, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            collect_lib_dep_calls_from_expr(e->value.binop.right, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT: case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF:
        case AST_EXPR_AWAIT: case AST_EXPR_RUN: case AST_EXPR_SPAWN: case AST_EXPR_TRY_PROPAGATE:
            collect_lib_dep_calls_from_expr(e->value.unary.operand, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        case AST_EXPR_AS:
            collect_lib_dep_calls_from_expr(e->value.as_type.operand, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        case AST_EXPR_IF:
        case AST_EXPR_TERNARY:
            collect_lib_dep_calls_from_expr(e->value.if_expr.cond, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            collect_lib_dep_calls_from_expr(e->value.if_expr.then_expr, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            if (e->value.if_expr.else_expr) collect_lib_dep_calls_from_expr(e->value.if_expr.else_expr, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        case AST_EXPR_BLOCK:
            collect_lib_dep_calls_from_block(e->value.block, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        case AST_EXPR_ASSIGN:
        case AST_EXPR_ADD_ASSIGN: case AST_EXPR_SUB_ASSIGN: case AST_EXPR_MUL_ASSIGN: case AST_EXPR_DIV_ASSIGN: case AST_EXPR_MOD_ASSIGN:
        case AST_EXPR_BITAND_ASSIGN: case AST_EXPR_BITOR_ASSIGN: case AST_EXPR_BITXOR_ASSIGN: case AST_EXPR_SHL_ASSIGN: case AST_EXPR_SHR_ASSIGN:
            collect_lib_dep_calls_from_expr(e->value.binop.left, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            collect_lib_dep_calls_from_expr(e->value.binop.right, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        case AST_EXPR_MATCH:
            collect_lib_dep_calls_from_expr(e->value.match_expr.matched_expr, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            for (int i = 0; i < e->value.match_expr.num_arms; i++)
                collect_lib_dep_calls_from_expr(e->value.match_expr.arms[i].result, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        case AST_EXPR_FIELD_ACCESS:
            collect_lib_dep_calls_from_expr(e->value.field_access.base, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        case AST_EXPR_STRUCT_LIT:
            for (int i = 0; i < e->value.struct_lit.num_fields; i++)
                collect_lib_dep_calls_from_expr(e->value.struct_lit.inits[i], lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++)
                collect_lib_dep_calls_from_expr(e->value.array_lit.elems[i], lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        case AST_EXPR_INDEX:
            collect_lib_dep_calls_from_expr(e->value.index.base, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            collect_lib_dep_calls_from_expr(e->value.index.index_expr, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        case AST_EXPR_METHOD_CALL:
            collect_lib_dep_calls_from_expr(e->value.method_call.base, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            for (int i = 0; i < e->value.method_call.num_args; i++)
                collect_lib_dep_calls_from_expr(e->value.method_call.args[i], lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        case AST_EXPR_PANIC:
        case AST_EXPR_RETURN:
            if (e->value.unary.operand) collect_lib_dep_calls_from_expr(e->value.unary.operand, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
            break;
        default: break;
    }
}
static void collect_lib_dep_calls_from_block(const struct ASTBlock *b, struct ASTModule **lib_dep_mods, const char **lib_dep_paths, int n_lib_dep,
    const char **paths_out, struct ASTFunc **funcs_out, int *n_out, int max_out) {
    if (!b) return;
    for (int i = 0; i < b->num_consts; i++)
        if (b->const_decls[i].init) collect_lib_dep_calls_from_expr(b->const_decls[i].init, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
    for (int i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].init) collect_lib_dep_calls_from_expr(b->let_decls[i].init, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
    for (int i = 0; i < b->num_loops; i++)
        collect_lib_dep_calls_from_block(b->loops[i].body, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
    for (int i = 0; i < b->num_for_loops; i++) {
        if (b->for_loops[i].init) collect_lib_dep_calls_from_expr(b->for_loops[i].init, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
        if (b->for_loops[i].cond) collect_lib_dep_calls_from_expr(b->for_loops[i].cond, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
        if (b->for_loops[i].step) collect_lib_dep_calls_from_expr(b->for_loops[i].step, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
        collect_lib_dep_calls_from_block(b->for_loops[i].body, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
    }
    for (int i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr)
            collect_lib_dep_calls_from_expr(b->labeled_stmts[i].u.return_expr, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
    for (int i = 0; i < b->num_expr_stmts; i++)
        collect_lib_dep_calls_from_expr(b->expr_stmts[i], lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
    if (b->final_expr) collect_lib_dep_calls_from_expr(b->final_expr, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
    /* 【Why 根源】同 collect_import_calls_from_block：unsafe/with_arena/try_catch/defer 块内
     * 的 lib_dep CALL 也须收集，否则 -E-extern 缺少 lib_dep extern 声明。 */
    for (int i = 0; i < b->num_regions; i++)
        if (b->regions[i].body) collect_lib_dep_calls_from_block(b->regions[i].body, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
    for (int i = 0; i < b->num_with_arenas; i++)
        if (b->with_arenas[i].body) collect_lib_dep_calls_from_block(b->with_arenas[i].body, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
    for (int i = 0; i < b->num_try_catches; i++) {
        if (b->try_catches[i].try_body) collect_lib_dep_calls_from_block(b->try_catches[i].try_body, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
        if (b->try_catches[i].catch_body) collect_lib_dep_calls_from_block(b->try_catches[i].catch_body, lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
    }
    for (int i = 0; i < b->num_defers; i++)
        if (b->defer_blocks[i]) collect_lib_dep_calls_from_block(b->defer_blocks[i], lib_dep_mods, lib_dep_paths, n_lib_dep, paths_out, funcs_out, n_out, max_out);
}

/** 从块 b 递归收集所有跨模块 CALL（非泛型与泛型）。 */
static void collect_import_calls_from_block(const struct ASTBlock *b, const char **paths, struct ASTFunc **funcs, int *n,
    const char **gen_paths, struct ASTFunc **gen_funcs, struct ASTType ***gen_type_args, int *gen_n, int *gen_count) {
    if (!b) return;
    for (int i = 0; i < b->num_consts; i++)
        if (b->const_decls[i].init) collect_import_calls_from_expr(b->const_decls[i].init, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
    for (int i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].init) collect_import_calls_from_expr(b->let_decls[i].init, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
    for (int i = 0; i < b->num_loops; i++)
        collect_import_calls_from_block(b->loops[i].body, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
    for (int i = 0; i < b->num_for_loops; i++) {
        if (b->for_loops[i].init) collect_import_calls_from_expr(b->for_loops[i].init, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
        if (b->for_loops[i].cond) collect_import_calls_from_expr(b->for_loops[i].cond, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
        if (b->for_loops[i].step) collect_import_calls_from_expr(b->for_loops[i].step, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
        collect_import_calls_from_block(b->for_loops[i].body, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
    }
    for (int i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr)
            collect_import_calls_from_expr(b->labeled_stmts[i].u.return_expr, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
    for (int i = 0; i < b->num_expr_stmts; i++)
        collect_import_calls_from_expr(b->expr_stmts[i], paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
    if (b->final_expr) collect_import_calls_from_expr(b->final_expr, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
    /* 【Why 根源】unsafe { } 块解析为 regions[i].body（is_unsafe=1），with_arena(cap) { }
     * 解析为 with_arenas[i].body，try/catch 解析为 try_catches[i].try_body/catch_body，
     * defer { } 解析为 defer_blocks[i]。若不递归遍历，这些块内的跨模块 CALL 不会被收集，
     * 导致 -E-extern 生成的 C 缺少 extern 声明，cc 报 implicit function declaration。
     * 典型案例：std.net 的 tls_plat/tcp_pool_plat 调用大多在 unsafe { } 内，遗漏导致 19 个
     * undeclared function 错误。
     * 【Invariant】regions/with_arenas/try_catches/defer_blocks 可为 NULL，num_* 为 0 时跳过。 */
    for (int i = 0; i < b->num_regions; i++)
        if (b->regions[i].body) collect_import_calls_from_block(b->regions[i].body, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
    for (int i = 0; i < b->num_with_arenas; i++)
        if (b->with_arenas[i].body) collect_import_calls_from_block(b->with_arenas[i].body, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
    for (int i = 0; i < b->num_try_catches; i++) {
        if (b->try_catches[i].try_body) collect_import_calls_from_block(b->try_catches[i].try_body, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
        if (b->try_catches[i].catch_body) collect_import_calls_from_block(b->try_catches[i].catch_body, paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
    }
    for (int i = 0; i < b->num_defers; i++)
        if (b->defer_blocks[i]) collect_import_calls_from_block(b->defer_blocks[i], paths, funcs, n, gen_paths, gen_funcs, gen_type_args, gen_n, gen_count);
}

/** 若当前处于单态化代入上下文则返回代入后的类型，否则返回 ty；用于 const/let 等类型输出。 */
static const struct ASTType *codegen_emit_type(const struct ASTType *ty) {
    if (!ty) return ty;
    if (codegen_subst_gp_names) return subst_type(ty, codegen_subst_gp_names, codegen_subst_type_args, codegen_subst_n);
    return ty;
}

/** 前向声明：向量类型 C 名（定义在 c_type_to_buf 之后）。 */
static const char *vector_c_type_name(const struct ASTType *ty);

/**
 * 将 AST 类型写入 buf，用于递归拼指针类型（*T、**T 等）。
 * 参数：ty 类型节点；buf 输出缓冲区；size 缓冲区大小。副作用：写入 buf。
 */
static void c_type_to_buf(const struct ASTType *ty, char *buf, size_t size) {
    if (!ty || size == 0) return;
    if (ty->kind == AST_TYPE_PTR && ty->elem_type) {
        /* 【Why 逻辑根源】局部缓冲区（非 static）：递归处理 **T 等多重指针时，每层调用需独立缓冲区。
         *   若用 static inner_buf，外层与内层递归共享同一缓冲区，c_type_to_buf(elem_type, inner_buf)
         *   覆盖外层正在使用的 inner_buf，导致 snprintf(buf, size, "%s *", inner_buf) 读到残缺数据
         *   —— glibc 上表现为双重指针 **u8 生成 " * *" 而非 "uint8_t * *"（UB：同缓冲区既作输出又作源）。
         *   macOS libc 恰好读先于写而掩盖此 bug，Linux glibc 暴露。
         * 【Invariant】每次递归调用在自身栈帧分配 inner_buf[256]，互不干扰；类型树深度 ≤ 8（多重指针/数组嵌套），栈开销 ≤ 2KB。
         * 【Asm/Perf】栈分配 zero-cost（sub rsp），无堆分配；c_type_to_buf 非编译热路径（仅函数签名/声明发射时调用）。 */
        char inner_buf[256];
        c_type_to_buf(ty->elem_type, inner_buf, sizeof(inner_buf));
        if (ty->is_volatile)
            snprintf(buf, size, "volatile %s *", inner_buf);  /* K2: 指向 volatile T 的指针，cc 不消除其读写 */
        else
            snprintf(buf, size, "%s *", inner_buf);
        return;
    }
    /* 数组类型 [N]T：声明时用 elem_type name[N]，此处只写元素类型（文档 §6.2） */
    if (ty->kind == AST_TYPE_ARRAY && ty->elem_type) {
        c_type_to_buf(ty->elem_type, buf, size);
        return;
    }
    /* M-4：Linear(T) 与内层 T 同 C 布局，零 RT 开销 */
    if (ty->kind == AST_TYPE_LINEAR && ty->elem_type) {
        c_type_to_buf(ty->elem_type, buf, size);
        return;
    }
    /* 切片 []T：C 侧为 struct shux_slice_<elem>；elem 为 struct 时含 "struct "，切片名须单标识符故 strip 掉 */
    if (ty->kind == AST_TYPE_SLICE && ty->elem_type) {
        static char elem_buf[128];
        c_type_to_buf(ty->elem_type, elem_buf, sizeof(elem_buf));
        const char *name_part = (strncmp(elem_buf, "struct ", 7) == 0) ? elem_buf + 7 : elem_buf;
        snprintf(buf, size, "struct shux_slice_%s", name_part);
        return;
    }
    /* 向量类型 i32x4/u32x4/i32x8/u32x8（文档 §10）：C 侧为 typedef struct { elem v[lanes]; } *_t */
    if (ty->kind == AST_TYPE_VECTOR && ty->elem_type) {
        snprintf(buf, size, "%s", vector_c_type_name(ty));
        return;
    }
    const char *s = "int";
    switch (ty->kind) {
        case AST_TYPE_VOID:  s = "void"; break;
        case AST_TYPE_I32:   s = "int32_t"; break;
        case AST_TYPE_F32:   s = "float"; break;
        case AST_TYPE_F64:   s = "double"; break;
        case AST_TYPE_BOOL:  s = "int"; break;
        case AST_TYPE_U8:    s = "uint8_t"; break;
        case AST_TYPE_U32:   s = "uint32_t"; break;
        case AST_TYPE_U64:   s = "uint64_t"; break;
        case AST_TYPE_I64:   s = "int64_t"; break;
        case AST_TYPE_USIZE: s = "size_t"; break;
        case AST_TYPE_ISIZE: s = "ptrdiff_t"; break;
        case AST_TYPE_NAMED: {
            const char *n = ty->name ? ty->name : "int";
            if (n && n[0]) {
                const struct ASTType *at = NULL;
                if (codegen_current_module && codegen_current_module->type_aliases)
                    for (int ai = 0; ai < codegen_current_module->num_type_aliases; ai++)
                        if (codegen_current_module->type_aliases[ai].name && strcmp(codegen_current_module->type_aliases[ai].name, n) == 0 && codegen_current_module->type_aliases[ai].target) { at = codegen_current_module->type_aliases[ai].target; break; }
                if (!at && codegen_ndep > 0 && codegen_dep_mods)
                    for (int di = 0; di < codegen_ndep && !at; di++) { const struct ASTModule *dm = codegen_dep_mods[di]; if (!dm || !dm->type_aliases) continue; for (int ai = 0; ai < dm->num_type_aliases; ai++) if (dm->type_aliases[ai].name && strcmp(dm->type_aliases[ai].name, n) == 0 && dm->type_aliases[ai].target) { at = dm->type_aliases[ai].target; break; } }
                if (at) { c_type_to_buf(at, buf, size); return; }
            }
            const char *src_n = codegen_import_select_source_name(n);
            /* CORE-013/CORE-017：i16/u16 为具名标量，映射 stdint 类型供 C 编译与 volatile ABI。 */
            if (strcmp(n, "i16") == 0) {
                snprintf(buf, size, "int16_t");
                return;
            }
            if (strcmp(n, "u16") == 0) {
                snprintf(buf, size, "uint16_t");
                return;
            }
            /* 限定类型名（如 elf.ElfCodegenCtx、heap_libc.Arena64）：
             * 【Why 根源】binding 名（heap_libc，下划线分隔）与 dep_path（std.heap.libc，点号分隔）
             * 分隔符不一致，原匹配逻辑用 strncmp 比较 "heap_libc" 与 "std.heap.libc" 尾部必然失败，
             * 导致 `a as *heap_libc.Arena64` 输出无效 C 标识符 `mod_heap_libc.Arena64`。
             * 【修复】先用 codegen_current_module 的 import_binding_names 把 binding 名解析为
             * import_path（如 "std.heap.libc"），再与 dep_path 精确匹配。
             * 【Invariant】codegen_current_module 在 -E-extern 库模块生成时由 codegen_library_module_to_c 设置。 */
            if (strchr(n, '.') && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
                const char *last_dot = strrchr(n, '.');
                if (last_dot && last_dot[1]) {
                    const char *type_name = last_dot + 1;
                    size_t module_len = (size_t)(last_dot - n);
                    /* 用 import_binding_names 解析 binding 名到 import_path */
                    const char *resolved_dep_path = NULL;
                    if (codegen_current_module && codegen_current_module->import_kinds
                        && codegen_current_module->import_binding_names && codegen_current_module->import_paths) {
                        char binding_buf[128];
                        if (module_len < sizeof(binding_buf)) {
                            memcpy(binding_buf, n, module_len);
                            binding_buf[module_len] = '\0';
                            for (int j = 0; j < codegen_current_module->num_imports; j++) {
                                if (codegen_current_module->import_kinds[j] == AST_IMPORT_KIND_BINDING
                                    && codegen_current_module->import_binding_names[j]
                                    && strcmp(codegen_current_module->import_binding_names[j], binding_buf) == 0) {
                                    resolved_dep_path = codegen_current_module->import_paths[j];
                                    break;
                                }
                            }
                        }
                    }
                    for (int i = 0; i < codegen_ndep; i++) {
                        const struct ASTModule *d = codegen_dep_mods[i];
                        if (!d || !d->struct_defs) continue;
                        for (int j = 0; j < d->num_structs; j++) {
                            if (!d->struct_defs[j]->name || strcmp(d->struct_defs[j]->name, type_name) != 0) continue;
                            const char *dep_path = codegen_dep_paths[i];
                            if (!dep_path) continue;
                            /* 匹配：dep_path 等于 n 的 module 部分，或 dep_path 以 ".module_part" 结尾（如 platform.elf 对 elf） */
                            size_t dlen = strlen(dep_path);
                            int match = 0;
                            /* 优先用 resolved_dep_path 精确匹配（binding 名 → import_path） */
                            if (resolved_dep_path && strcmp(dep_path, resolved_dep_path) == 0) match = 1;
                            /* 兼容原逻辑：dep_path == module_part 或 dep_path 以 ".module_part" 结尾 */
                            if (!match && dlen == module_len && strncmp(dep_path, n, module_len) == 0) match = 1;
                            else if (!match && dlen > module_len + 1 && dep_path[dlen - module_len - 1] == '.' && strncmp(dep_path + dlen - module_len, n, module_len) == 0) match = 1;
                            if (match) {
                                static char dep_pre[256];
                                import_path_to_c_prefix(dep_path, dep_pre, sizeof(dep_pre));
                                snprintf(buf, size, "struct %s%s", dep_pre, type_name);
                                return;
                            }
                        }
                    }
                }
            }
            /* 入口模块：若类型来自依赖模块的 enum，用 "enum prefix_Name" 与库 .c 一致 */
            if (!codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
                for (int i = 0; i < codegen_ndep; i++) {
                    const struct ASTModule *d = codegen_dep_mods[i];
                    if (!d || !d->enum_defs) continue;
                    for (int j = 0; j < d->num_enums; j++)
                        if (d->enum_defs[j]->name && strcmp(d->enum_defs[j]->name, src_n) == 0) {
                            static char dep_pre[256];
                            import_path_to_c_prefix(codegen_dep_paths[i], dep_pre, sizeof(dep_pre));
                            snprintf(buf, size, "enum %s%s", dep_pre, src_n);
                            return;
                        }
                }
            }
            /* 库模块：本模块内的 enum 须用 "enum prefix_Name" 以便与库 .c 中定义一致。
             * 【F 闭合】-lib-name "" 时 codegen_library_prefix 为空串（非 NULL）：仍须识别本模块 enum，
             * 输出 "enum Name"（无前缀），否则 fallback 输出裸名导致 C 编译失败。 */
            if (codegen_library_prefix && codegen_library_module && codegen_library_module->enum_defs) {
                for (int i = 0; i < codegen_library_module->num_enums; i++)
                    if (codegen_library_module->enum_defs[i]->name && strcmp(codegen_library_module->enum_defs[i]->name, n) == 0) {
                        snprintf(buf, size, "enum %s%s", codegen_library_prefix, n);
                        return;
                    }
            }
            int is_struct_in_lib = 0;
            /* 【F 闭合】同上：空串前缀仍须识别本模块 struct，输出 "struct Name"。 */
            if (codegen_library_prefix && codegen_library_module && codegen_library_module->struct_defs) {
                for (int i = 0; i < codegen_library_module->num_structs; i++)
                    if (codegen_library_module->struct_defs[i]->name && strcmp(codegen_library_module->struct_defs[i]->name, n) == 0) {
                        is_struct_in_lib = 1;
                        break;
                    }
            }
            if (is_struct_in_lib) {
                snprintf(buf, size, "struct %s%s", codegen_library_prefix, n);
                return;
            }
            /* 库模块：若类型来自其 import 依赖（如 lexer 中的 Token 来自 token），用依赖的 C 前缀，避免 lexer_Token 导致未定义类型 */
            if (codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
                for (int i = 0; i < codegen_ndep; i++) {
                    const struct ASTModule *d = codegen_dep_mods[i];
                    if (!d || !d->enum_defs) continue;
                    for (int j = 0; j < d->num_enums; j++)
                        if (d->enum_defs[j]->name && strcmp(d->enum_defs[j]->name, n) == 0) {
                            static char dep_pre[256];
                            import_path_to_c_prefix(codegen_dep_paths[i], dep_pre, sizeof(dep_pre));
                            snprintf(buf, size, "enum %s%s", dep_pre, n);
                            return;
                        }
                }
                for (int i = 0; i < codegen_ndep; i++) {
                    const struct ASTModule *d = codegen_dep_mods[i];
                    if (!d || !d->struct_defs) continue;
                    for (int j = 0; j < d->num_structs; j++)
                        if (d->struct_defs[j]->name && strcmp(d->struct_defs[j]->name, src_n) == 0) {
                            static char dep_pre[256];
                            import_path_to_c_prefix(codegen_dep_paths[i], dep_pre, sizeof(dep_pre));
                            snprintf(buf, size, "struct %s%s", dep_pre, src_n);
                            return;
                        }
                }
            }
            /* 入口模块：本模块内定义的 enum 须用 "enum Name"，否则 C 中 Color c 报错（须 enum Color c） */
            if (!codegen_library_prefix && codegen_current_module && codegen_current_module->enum_defs) {
                for (int i = 0; i < codegen_current_module->num_enums; i++)
                    if (codegen_current_module->enum_defs[i]->name && strcmp(codegen_current_module->enum_defs[i]->name, n) == 0) {
                        snprintf(buf, size, "enum %s", n);
                        return;
                    }
            }
            /* 入口模块：若类型来自依赖模块的 struct，用 "struct prefix_Name" 与库 .c 一致（含 import as 别名） */
            if (!codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
                for (int i = 0; i < codegen_ndep; i++) {
                    const struct ASTModule *d = codegen_dep_mods[i];
                    if (!d || !d->struct_defs) continue;
                    for (int j = 0; j < d->num_structs; j++)
                        if (d->struct_defs[j]->name && strcmp(d->struct_defs[j]->name, src_n) == 0) {
                            static char dep_pre[256];
                            import_path_to_c_prefix(codegen_dep_paths[i], dep_pre, sizeof(dep_pre));
                            snprintf(buf, size, "struct %s%s", dep_pre, src_n);
                            return;
                        }
                }
            }
            /* 入口模块：本模块内定义的 struct 须用 "struct Name"；多模块 -E 时须带 C 前缀（如 ast_Type）与生成 C 一致 */
            if (codegen_current_module && codegen_current_module->struct_defs) {
                for (int i = 0; i < codegen_current_module->num_structs; i++)
                    if (codegen_current_module->struct_defs[i]->name && strcmp(codegen_current_module->struct_defs[i]->name, n) == 0) {
                        /* 库模块 -E 时须 "struct prefix_Name" 与生成 C 一致 */
                        if (codegen_library_prefix && *codegen_library_prefix) {
                            snprintf(buf, size, "struct %s%s", codegen_library_prefix, n);
                            return;
                        }
                        if (!codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
                            for (int di = 0; di < codegen_ndep; di++)
                                if (codegen_dep_mods[di] == codegen_current_module) {
                                    char pre[64];
                                    import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                                    snprintf(buf, size, "struct %s%s", pre, n);
                                    return;
                                }
                        }
                        if (!codegen_library_prefix) {
                            snprintf(buf, size, "struct %s", n);
                            return;
                        }
                    }
            }
            if (codegen_library_prefix && *codegen_library_prefix)
                snprintf(buf, size, "%s%s", codegen_library_prefix, n);
            else
                snprintf(buf, size, "%s", n);
            return;
        }
        default: break;
    }
    snprintf(buf, size, "%s", s);
}

/**
 * 将 AST 类型映射为 C 类型字符串；用于 const/let 声明。支持裸指针 *T（文档 §5.1）。
 * 参数：ty 类型节点，不可为 NULL。返回值：C 类型名（静态缓冲区，非线程安全）。
 */
static const char *c_type_str(const struct ASTType *ty) {
    if (!ty) return "int";
    static char buf[256];
    c_type_to_buf(ty, buf, sizeof(buf));
    return buf;
}

/** 表达式 e 的 resolved_type 是否为 struct（用于 if-expr __tmp：当 __tmp 为 struct 而分支产生标量时须赋 (struct X){0} 而非 0）。 */
static int expr_produces_struct_type(const struct ASTExpr *e) {
    if (!e || !e->resolved_type) return 0;
    const char *s = c_type_str(e->resolved_type);
    return (s && strncmp(s, "struct ", 7) == 0);
}

/** 表达式 e 的 resolved_type 是否为可折叠为整数的标量（仅此时 const_folded_val 才有意义；struct/float 等不能当整数字面量输出）。
 * 不含 U8：u8 的 const_folded_val 可能被误用导致 return -1094795586 等错误，故 u8 一律走正常表达式生成。 */
static int expr_type_is_foldable_scalar(const struct ASTExpr *e) {
    if (!e || !e->resolved_type) return 0;
    const struct ASTType *ty = e->resolved_type;
    if (ty->kind == AST_TYPE_LINEAR && ty->elem_type)
        ty = ty->elem_type;
    switch (ty->kind) {
        case AST_TYPE_I32: case AST_TYPE_BOOL: case AST_TYPE_U32:
        case AST_TYPE_I64: case AST_TYPE_USIZE: case AST_TYPE_ISIZE:
            return 1;
        default:
            return 0;
    }
}

/** 当 __tmp 类型为 struct（tmp_ty_str）且 else 分支类型与之不一致时返回 1，此时应输出 (tmp_ty_str){0} 而非 else 表达式，避免 LexerResult __tmp = (Token){0} 等错误。
 * 统一用 expr_struct_type_str 取 else 的 C struct 类型再与 tmp_ty_str 比较，因 c_type_str(NAMED) 可能无 "struct " 前缀。 */
static int else_struct_type_mismatch(const char *tmp_ty_str, const struct ASTExpr *else_e) {
    if (!tmp_ty_str || strncmp(tmp_ty_str, "struct ", 7) != 0 || !else_e) return 0;
    if (!expr_produces_struct_type(else_e)) return 1;
    static char else_ty_buf[128];
    if (!expr_struct_type_str(else_e, else_ty_buf, sizeof(else_ty_buf))) {
        if (else_e->resolved_type) {
            const char *es = c_type_str(else_e->resolved_type);
            if (es && strncmp(es, "struct ", 7) == 0 && strcmp(es, tmp_ty_str) != 0) return 1;
        }
        return 0;
    }
    return (strcmp(else_ty_buf, tmp_ty_str) != 0) ? 1 : 0;
}

/**
 * 输出结构体字段的 C 类型+名（支持多维数组 [N][M]...，自举用：OneFuncResult 等含 [16][32]u8 字段）。
 * 参数：fty 字段类型；fname 字段名；out 输出。副作用：向 out 写入 "elem_type name[N][M]; " 或 "type name; "。
 */
static void emit_struct_field_c_type(const struct ASTType *fty, const char *fname, FILE *out, int bitfield_width) {
    if (!fty) { fprintf(out, "int32_t %s; ", fname); return; }
    if (fty->kind == AST_TYPE_ARRAY && fty->elem_type) {
        const struct ASTType *t = fty;
        char dims[64] = "";
        while (t->kind == AST_TYPE_ARRAY && t->elem_type) {
            char d[16];
            snprintf(d, sizeof(d), "[%d]", t->array_size);
            strncat(dims, d, sizeof(dims) - 1);
            t = t->elem_type;
        }
        fprintf(out, "%s %s%s; ", c_type_str(t), fname, dims);
    } else if (bitfield_width > 0) {
        fprintf(out, "%s %s : %d; ", c_type_str(fty), fname, bitfield_width);
    } else if (bitfield_width > 0) {
        fprintf(out, "%s %s : %d; ", c_type_str(fty), fname, bitfield_width);
    } else {
        fprintf(out, "%s %s; ", c_type_str(fty), fname);
    }
}

/**
 * 输出局部/块内数组变量声明前缀 "elem_type name[N][M] "（支持多维，自举用；不含 "= "）。
 * 参数：ty 数组类型；name 变量名；pad 缩进；out 输出。
 */
static void emit_local_array_decl(const struct ASTType *ty, const char *name, const char *pad, FILE *out) {
    if (!ty || ty->kind != AST_TYPE_ARRAY || !ty->elem_type) return;
    const struct ASTType *t = ty;
    char dims[64] = "";
    while (t->kind == AST_TYPE_ARRAY && t->elem_type) {
        char d[16];
        snprintf(d, sizeof(d), "[%d]", t->array_size);
        strncat(dims, d, sizeof(dims) - 1);
        t = t->elem_type;
    }
    fprintf(out, "%s%s %s%s ", pad, c_type_str(t), name, dims);
}

/**
 * §3.4 内建函数映射框架：将 C 符号名映射为后端 intrinsic（如 core_mem_mem_copy -> __builtin_memcpy）；默认返回原名。
 * 供 core.mem / core.builtin / SIMD 等生成目标平台最优指令时扩展。
 * core.builtin：copy -> __builtin_memcpy，unreachable -> __builtin_unreachable，abort -> __builtin_abort；
 * clz/ctz/popcount -> shux_builtin_*（C 内 __builtin_clz/ctz/popcount，CORE-009）。
 */
static const char *builtin_intrinsic_name(const char *c_name) {
    if (!c_name) return c_name;
    if (strcmp(c_name, "core_mem_mem_copy") == 0) return "__builtin_memcpy";
    if (strcmp(c_name, "core_mem_mem_set") == 0) return "__builtin_memset";
    if (strcmp(c_name, "core_mem_mem_move") == 0) return "__builtin_memmove";
    if (strcmp(c_name, "core_mem_mem_compare") == 0) return "__builtin_memcmp";
    if (strcmp(c_name, "core_builtin_copy") == 0) return "__builtin_memcpy";
    if (strcmp(c_name, "core_builtin_unreachable") == 0) return "__builtin_unreachable";
    if (strcmp(c_name, "core_builtin_abort") == 0) return "__builtin_abort";
    if (strcmp(c_name, "core_builtin_clz_u32") == 0) return "shux_builtin_clz_u32";
    if (strcmp(c_name, "core_builtin_ctz_u32") == 0) return "shux_builtin_ctz_u32";
    if (strcmp(c_name, "core_builtin_popcount_u32") == 0) return "shux_builtin_popcount_u32";
    if (strcmp(c_name, "core_builtin_bswap_u32") == 0) return "shux_builtin_bswap_u32";
    if (strcmp(c_name, "core_builtin_rotl_u32") == 0) return "shux_builtin_rotl_u32";
    if (strcmp(c_name, "core_builtin_rotr_u32") == 0) return "shux_builtin_rotr_u32";
    return c_name;
}

/**
 * §3.4 CORE-009：emit shux_builtin_* static inline 包装器。
 * 【Why 根源】builtin_intrinsic_name 将 core_builtin_clz_u32 等调用点重映射为 shux_builtin_*，
 * 但这些符号在生成 C 中从未声明，导致 cc 报 "call to undeclared function"。
 * 设计意图（analysis/core-builtin-bitops-v1.md）：用 __builtin_clz/ctz/popcount 单指令优化，
 * 但 __builtin_clz(0)/__builtin_ctz(0) 是 UB，须在包装器内显式处理 x==0→32 边界。
 * bswap 用 __builtin_bswap32（全值域合法）；rotl/rotr 无 GCC 直接等价 builtin，用纯 C 旋转表达式。
 * 【Invariant】每个翻译单元自己一份 static inline；未被引用时编译器消除，无符号冲突。
 * 【Asm/Perf】期望 GCC/Clang 把 clz/ctz/popcount 折成单指令（lzcnt/tzcnt/popcnt），
 * bswap 折成 bswap，rotl/rotr 折成 rol/ror（x86 BMI2）。
 */
void codegen_emit_builtin_inline_decls(FILE *out) {
    if (!out) return;
    /* 单文件模式 driver 与 codegen_module_to_c 都会调用本函数；用 include guard 避免重复定义。
     * 【Why】static inline 函数重复定义在 C 中是错误（不像 #include 有 header guard）。 */
    fprintf(out,
        "#ifndef SHUX_BUILTIN_INLINE_DECLS_GUARD\n"
        "#define SHUX_BUILTIN_INLINE_DECLS_GUARD\n"
        "/* CORE-009 shux_builtin_* static inline wrappers (clz/ctz/popcount/bswap/rotl/rotr) */\n"
        "static inline int shux_builtin_clz_u32(uint32_t x) { return x == 0 ? 32 : __builtin_clz(x); }\n"
        "static inline int shux_builtin_ctz_u32(uint32_t x) { return x == 0 ? 32 : __builtin_ctz(x); }\n"
        "static inline int shux_builtin_popcount_u32(uint32_t x) { return __builtin_popcount(x); }\n"
        "static inline uint32_t shux_builtin_bswap_u32(uint32_t x) { return __builtin_bswap32(x); }\n"
        "static inline uint32_t shux_builtin_rotl_u32(uint32_t x, uint32_t c) {\n"
        "  c &= 31; return c == 0 ? x : (x << c) | (x >> (32 - c));\n"
        "}\n"
        "static inline uint32_t shux_builtin_rotr_u32(uint32_t x, uint32_t c) {\n"
        "  c &= 31; return c == 0 ? x : (x >> c) | (x << (32 - c));\n"
        "}\n"
        "#endif\n");
}

/**
 * 向 out 输出单个函数形参的 C 声明；若为指针且 is_restrict 则插入 restrict（noalias 传递）。
 * 数组类型 [N]T 输出为 elem_type name[N]，否则 c_type_str 只出元素类型会导致参数退化为指针（方案 A 自举 pipeline_gen.c 需完整数组声明）。
 * override_ty 非 NULL 时用其替代 p->type（用于单态化），仍用 p->is_restrict。
 * slice 形参按指针传递，避免 16 字节按值传参时 ABI 导致 length 错乱（bar→ba、main→mai）。
 */
static const struct ASTFunc *codegen_current_func;

static int expr_is_slice_ptr_param(const struct ASTExpr *e) {
    if (!e || e->kind != AST_EXPR_VAR || !e->value.var.name || !codegen_current_func) return 0;
    for (int i = 0; i < codegen_current_func->num_params; i++)
        if (codegen_current_func->params[i].name && strcmp(codegen_current_func->params[i].name, e->value.var.name) == 0
            && codegen_current_func->params[i].type && codegen_current_func->params[i].type->kind == AST_TYPE_SLICE)
            return 1;
    return 0;
}

/** 当 e 为形参且类型为 PTR 或 SLICE 时返回 1，用于字段访问输出 ->（C 中指针/slice 按指针传）；弥补 typeck 未填 base->resolved_type 时仍能正确生成）。 */
static int expr_is_ptr_or_slice_param(const struct ASTExpr *e) {
    if (!e || e->kind != AST_EXPR_VAR || !e->value.var.name || !codegen_current_func) return 0;
    for (int i = 0; i < codegen_current_func->num_params; i++)
        if (codegen_current_func->params[i].name && strcmp(codegen_current_func->params[i].name, e->value.var.name) == 0
            && codegen_current_func->params[i].type) {
            enum ASTTypeKind k = codegen_current_func->params[i].type->kind;
            if (k == AST_TYPE_PTR || k == AST_TYPE_SLICE) return 1;
        }
    return 0;
}

/** .x 侧：base 是否为 slice 形参（C 中按指针传，用 ->）；否则为局部/全局 struct 用 .；无当前函数时保守返回 0。 */
int32_t codegen_x_expr_is_slice_ptr_param(uint8_t *expr) {
    return (codegen_current_func && expr_is_slice_ptr_param((const struct ASTExpr *)expr)) ? 1 : 0;
}
/** .x 侧 INDEX 切片边界检查：((idx)<0||(size_t)(idx)>=(base).length 或 (base)->length ? ...）。仅形参用 ->。 */
int32_t codegen_x_emit_index_slice_bounds_check(uint8_t *out, uint8_t *base, uint8_t *idx) {
    FILE *f = (FILE *)out;
    int use_arrow = codegen_x_expr_is_slice_ptr_param(base);
    const char *da = use_arrow ? ")->" : ").";
    if (fprintf(f, "(") < 0) return -1;
    if (codegen_expr((const struct ASTExpr *)idx, f) != 0) return -1;
    if (fprintf(f, " < 0 || (size_t)(") < 0) return -1;
    if (codegen_expr((const struct ASTExpr *)idx, f) != 0) return -1;
    if (fprintf(f, ") >= (") < 0) return -1;
    if (codegen_expr((const struct ASTExpr *)base, f) != 0) return -1;
    if (fprintf(f, "%slength ? (shux_panic_(1, 0), (", da) < 0) return -1;
    if (codegen_expr((const struct ASTExpr *)base, f) != 0) return -1;
    if (fprintf(f, "%sdata[0]) : (", da) < 0) return -1;
    if (codegen_expr((const struct ASTExpr *)base, f) != 0) return -1;
    if (fprintf(f, "%sdata[", da) < 0) return -1;
    if (codegen_expr((const struct ASTExpr *)idx, f) != 0) return -1;
    return fprintf(f, "])") < 0 ? -1 : 0;
}

/** 若 param_index >= 0 且 p->name 为空或首字符为空格，则用 _p0/_p1 等占位符，保证生成合法 C。 */
static void codegen_emit_param(const struct ASTParam *p, FILE *out, const struct ASTType *override_ty, int param_index) {
    if (!p || !out) return;
    const struct ASTType *ty = override_ty ? override_ty : p->type;
    const char *name = p->name && p->name[0] && (unsigned char)p->name[0] > ' ' ? p->name : "";
    char place[32];
    if (!name[0] && param_index >= 0) {
        (void)snprintf(place, sizeof(place), "_p%d", param_index);
        name = place;
    }
    if (ty && ty->kind == AST_TYPE_PTR && p->is_restrict)
        fprintf(out, "%s restrict %s", c_type_str(ty), name);
    else if (ty && ty->kind == AST_TYPE_ARRAY && ty->elem_type && ty->array_size > 0)
        fprintf(out, "%s %s[%d]", c_type_str(ty->elem_type), name, ty->array_size);
    else if (ty && ty->kind == AST_TYPE_SLICE)
        fprintf(out, "%s * %s", c_type_str(ty), name);
    else
        fprintf(out, "%s %s", ty ? c_type_str(ty) : "int32_t", name);
}

/** 已输出的切片结构体 elem 类型 key 的副本，避免重复定义；c_type_str 返回静态缓冲区会被覆盖，故存副本 */
#define MAX_SLICE_STRUCTS 16
#define SLICE_KEY_MAX 64
static char codegen_slice_emitted[MAX_SLICE_STRUCTS][SLICE_KEY_MAX];
static int codegen_slice_emitted_n;

/** 向量 typedef 已输出 key 列表（如 "i32x4","u32x8"），每轮 codegen 开始时清空 */
#define MAX_VECTOR_TYPEDEFS 8
static const char *codegen_vector_emitted[MAX_VECTOR_TYPEDEFS];
static int codegen_vector_emitted_n;

/** 返回向量类型的 C 类型名（如 i32x4_t）；ty 须为 AST_TYPE_VECTOR 且 elem_type/array_size 为支持的组合。 */
static const char *vector_c_type_name(const struct ASTType *ty) {
    if (!ty || ty->kind != AST_TYPE_VECTOR || !ty->elem_type) return "int32_t";
    int lanes = ty->array_size;
    switch (ty->elem_type->kind) {
        case AST_TYPE_I32: if (lanes == 4) return "i32x4_t"; if (lanes == 8) return "i32x8_t"; if (lanes == 16) return "i32x16_t"; break;
        case AST_TYPE_U32: if (lanes == 4) return "u32x4_t"; if (lanes == 8) return "u32x8_t"; if (lanes == 16) return "u32x16_t"; break;
        default: break;
    }
    return "int32_t";
}

/** 若 ty 为支持的向量类型且尚未输出，则输出一次 typedef；无返回值。 */
static void ensure_vector_typedef(const struct ASTType *ty, FILE *out) {
    if (!ty || ty->kind != AST_TYPE_VECTOR || !ty->elem_type || !out) return;
    const char *name = vector_c_type_name(ty);
    const char *key = name;
    for (int i = 0; i < codegen_vector_emitted_n; i++)
        if (codegen_vector_emitted[i] && strcmp(codegen_vector_emitted[i], key) == 0) return;
    if (codegen_vector_emitted_n >= MAX_VECTOR_TYPEDEFS) return;
    codegen_vector_emitted[codegen_vector_emitted_n++] = key;
    const char *elem = (ty->elem_type->kind == AST_TYPE_U32) ? "uint32_t" : "int32_t";
    int lanes = ty->array_size;
    fprintf(out, "typedef struct { %s v[%d]; } %s;\n", elem, lanes, name);
}

/** 递归扫描块内 const/let，为所有用到的向量类型输出 typedef。 */
static void ensure_block_vector_typedefs(const struct ASTBlock *b, FILE *out) {
    if (!b || !out) return;
    for (int i = 0; i < b->num_consts; i++)
        if (b->const_decls[i].type && b->const_decls[i].type->kind == AST_TYPE_VECTOR)
            ensure_vector_typedef(b->const_decls[i].type, out);
    for (int i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].type && b->let_decls[i].type->kind == AST_TYPE_VECTOR)
            ensure_vector_typedef(b->let_decls[i].type, out);
    for (int i = 0; i < b->num_loops; i++)
        if (b->loops[i].body) ensure_block_vector_typedefs(b->loops[i].body, out);
    for (int i = 0; i < b->num_for_loops; i++)
        if (b->for_loops[i].body) ensure_block_vector_typedefs(b->for_loops[i].body, out);
}

/** 函数签名中的向量返回/形参须先于 static inline 前向声明输出 typedef（与 ensure_slice_struct 对称）。 */
static void ensure_func_sig_vector_typedefs(const struct ASTFunc *f, FILE *out) {
    if (!f || !out) return;
    if (f->return_type && f->return_type->kind == AST_TYPE_VECTOR)
        ensure_vector_typedef(f->return_type, out);
    for (int p = 0; p < f->num_params; p++)
        if (f->params[p].type && f->params[p].type->kind == AST_TYPE_VECTOR)
            ensure_vector_typedef(f->params[p].type, out);
}

/**
 * 若 ty 为切片类型，则向 out 输出一次 struct shux_slice_<elem> { elem* data; size_t length; }（文档 §6.3）。
 * 同一 elem 类型只输出一次。单文件多模块时先查 codegen_emitted_type_names，避免跨库重复定义。
 */

/* 函数按值返回定长数组 [N]T：C 不允许按值返回数组，包装为 struct shux_arr_<T>_<N> { <T> data[N]; }。
 * 返回 wrapper struct 名；调用处解包用 .data。ensure_arr_ret_struct 输出 typedef（去重）。 */
static const char *arr_ret_wrapper_name(const struct ASTType *ty) {
    static char name_buf[128];
    if (!ty || ty->kind != AST_TYPE_ARRAY || !ty->elem_type || ty->array_size <= 0) return NULL;
    char elem_buf[64]; c_type_to_buf(ty->elem_type, elem_buf, sizeof elem_buf);
    const char *ep = (strncmp(elem_buf, "struct ", 7) == 0) ? elem_buf + 7 : elem_buf;
    const char *ep2 = (strncmp(ep, "uint8_t", 7) == 0) ? "u8" : (strncmp(ep, "int32_t", 7) == 0) ? "i32" : (strncmp(ep, "int16_t", 7) == 0) ? "i16" : ep;
    snprintf(name_buf, sizeof name_buf, "shux_arr_%s_%d", ep2, ty->array_size);
    return name_buf;
}
static void ensure_arr_ret_struct(const struct ASTType *ty, FILE *out) {
    const char *wn = arr_ret_wrapper_name(ty);
    if (!wn || !out) return;
    for (int i = 0; i < codegen_slice_emitted_n; i++)
        if (strcmp(codegen_slice_emitted[i], wn) == 0) return;
    if (codegen_slice_emitted_n < MAX_SLICE_STRUCTS) {
        snprintf(codegen_slice_emitted[codegen_slice_emitted_n], SLICE_KEY_MAX, "%s", wn);
        codegen_slice_emitted_n++;
    }
    char elem_buf[64]; c_type_to_buf(ty->elem_type, elem_buf, sizeof elem_buf);
    fprintf(out, "struct %s { %s data[%d]; };\n", wn, elem_buf, ty->array_size);
}

static const char *func_ret_c_type(const struct ASTFunc *f, FILE *out) {
    if (!f || !f->return_type) return "int32_t";
    if (f->return_type->kind == AST_TYPE_ARRAY && f->return_type->array_size > 0) {
        if (out) ensure_arr_ret_struct(f->return_type, out);
        const char *wn = arr_ret_wrapper_name(f->return_type);
        if (wn) { fprintf(out, "struct "); return wn; }  /* caller prints "struct " prefix then wn */
    }
    return c_type_str(f->return_type);
}

static void ensure_slice_struct(const struct ASTType *ty, FILE *out) {
    if (!ty || ty->kind != AST_TYPE_SLICE || !ty->elem_type || !out) return;
    const char *key = c_type_str(ty->elem_type);
    const char *name_part = (strncmp(key, "struct ", 7) == 0) ? key + 7 : key;
    char full_slice_name[128];
    (void)snprintf(full_slice_name, sizeof(full_slice_name), "shux_slice_%s", name_part);
    if (codegen_emitted_type_names && codegen_n_emitted_inout &&
        emitted_type_contains(full_slice_name, codegen_emitted_type_names, *codegen_n_emitted_inout))
        return;
    for (int i = 0; i < codegen_slice_emitted_n; i++)
        if (strcmp(codegen_slice_emitted[i], key) == 0) return;
    if (codegen_slice_emitted_n >= MAX_SLICE_STRUCTS) return;
    (void)snprintf(codegen_slice_emitted[codegen_slice_emitted_n], SLICE_KEY_MAX, "%s", key);
    codegen_slice_emitted_n++;
    if (codegen_emitted_type_names && codegen_n_emitted_inout && codegen_max_emitted > 0)
        emitted_type_add(full_slice_name, codegen_emitted_type_names, codegen_n_emitted_inout, codegen_max_emitted);
    fprintf(out, "struct shux_slice_%s { %s *data; size_t length; };\n", name_part, key);
}

/** FIELD_ACCESS 枚举变体完整输出：Type.Variant → prefix_Enum_Variant；依赖/库前缀查找在 C 内完成，供 .x 统一入口转调。 */
static int codegen_emit_field_access_enum_variant_impl(FILE *out, const struct ASTExpr *e) {
    /* 库模块未做 typeck 时 is_enum_variant 可能为 0；若 base 为当前库模块枚举类型名则按枚举变体输出 */
    if (codegen_library_prefix && *codegen_library_prefix && codegen_library_module && codegen_library_module->enum_defs
        && e->value.field_access.base->kind == AST_EXPR_VAR && e->value.field_access.base->value.var.name) {
        const char *en2 = e->value.field_access.base->value.var.name;
        const char *vn2 = e->value.field_access.field_name;
        for (int i = 0; i < codegen_library_module->num_enums; i++)
            if (codegen_library_module->enum_defs[i]->name && strcmp(codegen_library_module->enum_defs[i]->name, en2) == 0) {
                fprintf(out, "%s%s_%s", codegen_library_prefix, en2, vn2 ? vn2 : "");
                return 0;
            }
    }
    const char *en = e->value.field_access.base->value.var.name;
    const char *vn = e->value.field_access.field_name;
    if (!codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths && en) {
        int found = 0;
        for (int di = 0; di < codegen_ndep && !found; di++) {
            const struct ASTModule *d = codegen_dep_mods[di];
            if (!d || !d->enum_defs) continue;
            for (int ej = 0; ej < d->num_enums; ej++)
                if (d->enum_defs[ej]->name && strcmp(d->enum_defs[ej]->name, en) == 0) {
                    char pre[256];
                    import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                    fprintf(out, "%s%s_%s", pre, en, vn ? vn : "");
                    found = 1;
                    break;
                }
        }
        if (found) return 0;
    }
    if (codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths && en) {
        int found = 0;
        for (int di = 0; di < codegen_ndep && !found; di++) {
            const struct ASTModule *d = codegen_dep_mods[di];
            if (!d || !d->enum_defs) continue;
            for (int ej = 0; ej < d->num_enums; ej++)
                if (d->enum_defs[ej]->name && strcmp(d->enum_defs[ej]->name, en) == 0) {
                    char pre[256];
                    import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                    fprintf(out, "%s%s_%s", pre, en, vn ? vn : "");
                    found = 1;
                    break;
                }
        }
        if (found) return 0;
    }
    if (codegen_library_prefix && *codegen_library_prefix && en)
        fprintf(out, "%s%s_%s", codegen_library_prefix, en, vn ? vn : "");
    else
        fprintf(out, "%s_%s", en ? en : "", vn ? vn : "");
    return 0;
}

/** .x 侧 FIELD_ACCESS 枚举变体：仅将「前缀」写入 out，供 .x 自实现时拼 prefix+enum_name+'_'+variant_name。返回 0 成功，-1 失败。 */
int32_t codegen_x_emit_enum_variant_prefix(uint8_t *out, uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_FIELD_ACCESS || !e->value.field_access.base
        || e->value.field_access.base->kind != AST_EXPR_VAR) return -1;
    const char *en = e->value.field_access.base->value.var.name;
    if (!en) return -1;
    if (codegen_library_prefix && *codegen_library_prefix && codegen_library_module && codegen_library_module->enum_defs) {
        for (int i = 0; i < codegen_library_module->num_enums; i++)
            if (codegen_library_module->enum_defs[i]->name && strcmp(codegen_library_module->enum_defs[i]->name, en) == 0) {
                fprintf((FILE *)out, "%s", codegen_library_prefix);
                return 0;
            }
    }
    if (codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
        for (int di = 0; di < codegen_ndep; di++) {
            const struct ASTModule *d = codegen_dep_mods[di];
            if (!d || !d->enum_defs) continue;
            for (int ej = 0; ej < d->num_enums; ej++)
                if (d->enum_defs[ej]->name && strcmp(d->enum_defs[ej]->name, en) == 0) {
                    char pre[256];
                    import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                    fprintf((FILE *)out, "%s", pre);
                    return 0;
                }
        }
    }
    if (codegen_library_prefix && *codegen_library_prefix) {
        fprintf((FILE *)out, "%s", codegen_library_prefix);
        return 0;
    }
    return 0; /* 无前缀 */
}

/** .x 侧 FIELD_ACCESS：base 为 VAR 时返回类型名（枚举名）指针，否则 NULL。 */
uint8_t *codegen_x_field_access_base_var_name(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_FIELD_ACCESS || !e->value.field_access.base
        || e->value.field_access.base->kind != AST_EXPR_VAR) return NULL;
    const char *n = e->value.field_access.base->value.var.name;
    return (uint8_t *)(n ? n : "");
}

/** .x 侧 FIELD_ACCESS：base 为 VAR 时返回类型名（枚举名）长度。 */
int32_t codegen_x_field_access_base_var_name_len(uint8_t *expr) {
    const char *n = (const char *)codegen_x_field_access_base_var_name(expr);
    return (int32_t)(n ? strlen(n) : 0);
}

/** .x 侧 FIELD_ACCESS 枚举变体全量输出：供 codegen.x 的 emit_field_access_expr 转调（fallback）。 */
int32_t codegen_x_emit_field_access_enum_variant_full(uint8_t *out, uint8_t *expr) {
    return codegen_emit_field_access_enum_variant_impl((FILE *)out, (const struct ASTExpr *)expr) != 0 ? -1 : 0;
}

/** 按类型名查找结构体定义（当前模块、依赖模块）；供 CORE-001 layout intrinsic 使用。 */
static const struct ASTStructDef *codegen_find_struct_def_by_name(const char *name) {
    if (!name) return NULL;
    if (codegen_current_module && codegen_current_module->struct_defs) {
        for (int i = 0; i < codegen_current_module->num_structs; i++) {
            const struct ASTStructDef *sd = codegen_current_module->struct_defs[i];
            if (sd && sd->name && strcmp(sd->name, name) == 0) return sd;
        }
    }
    if (codegen_ndep > 0 && codegen_dep_mods) {
        for (int di = 0; di < codegen_ndep; di++) {
            const struct ASTModule *d = codegen_dep_mods[di];
            if (!d || !d->struct_defs) continue;
            for (int j = 0; j < d->num_structs; j++) {
                const struct ASTStructDef *sd = d->struct_defs[j];
                if (sd && sd->name && strcmp(sd->name, name) == 0) return sd;
            }
        }
    }
    return NULL;
}

/**
 * 在依赖模块顶层 const 中按名查找，并写出 prefix+name 到 out_prefixed（供解构 import 等显式绑定）。
 * 返回值：找到返回 ASTLetDecl*，否则 NULL。
 */
static const struct ASTLetDecl *codegen_find_module_const_in_deps(const char *name, char *out_prefixed, size_t out_size) {
    if (!name) return NULL;
    if (codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
        for (int di = 0; di < codegen_ndep; di++) {
            const struct ASTModule *d = codegen_dep_mods[di];
            if (!d || !d->top_level_lets) continue;
            for (int i = 0; i < d->num_top_level_lets; i++) {
                if (!d->top_level_lets[i].is_const || !d->top_level_lets[i].name) continue;
                if (strcmp(d->top_level_lets[i].name, name) != 0) continue;
                if (out_prefixed && out_size > 0) {
                    char pre[256];
                    import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                    codegen_join_import_prefix_func_name(pre, name, out_prefixed, out_size);
                }
                return &d->top_level_lets[i];
            }
        }
    }
    return NULL;
}

/** import binding 名是否匹配第 j 个 import 槽。 */
static int codegen_import_binding_matches(const struct ASTModule *m, int j, const char *name) {
    if (!m || !name || j < 0 || j >= m->num_imports || !m->import_paths || !m->import_paths[j])
        return 0;
    if (strcmp(m->import_paths[j], name) == 0)
        return 1;
    if (m->import_kinds && m->import_kinds[j] == AST_IMPORT_KIND_BINDING
        && m->import_binding_names && m->import_binding_names[j]
        && strcmp(m->import_binding_names[j], name) == 0)
        return 1;
    return 0;
}

/** 在模块顶层 const 中按名查找。 */
static const struct ASTLetDecl *codegen_find_const_in_module(const struct ASTModule *m, const char *name) {
    if (!m || !name || !m->top_level_lets) return NULL;
    for (int i = 0; i < m->num_top_level_lets; i++) {
        if (!m->top_level_lets[i].is_const || !m->top_level_lets[i].name) continue;
        if (strcmp(m->top_level_lets[i].name, name) == 0)
            return &m->top_level_lets[i];
    }
    return NULL;
}

/**
 * binding.CONST 形式：生成 dep 模块 static const 的 C 符号（prefix + const 名）。
 * 返回值：0 已输出，-1 非此类表达式。
 */
static int codegen_try_emit_import_module_const(FILE *out, const struct ASTExpr *e) {
    const char *bind;
    const char *cname;
    if (!e || e->kind != AST_EXPR_FIELD_ACCESS || !e->value.field_access.base
        || e->value.field_access.base->kind != AST_EXPR_VAR || !codegen_current_module)
        return -1;
    bind = e->value.field_access.base->value.var.name;
    cname = e->value.field_access.field_name;
    if (!bind || !cname || codegen_ndep <= 0 || !codegen_dep_mods || !codegen_dep_paths)
        return -1;
    for (int j = 0; j < codegen_current_module->num_imports && j < codegen_ndep; j++) {
        const struct ASTModule *dm;
        if (!codegen_import_binding_matches(codegen_current_module, j, bind)) continue;
        dm = codegen_dep_mods[j];
        if (!codegen_find_const_in_module(dm, cname)) continue;
        {
            char pre[256];
            import_path_to_c_prefix(codegen_dep_paths[j], pre, sizeof(pre));
            fprintf(out, "%s%s", pre, cname);
        }
        return 0;
    }
    return -1;
}

/** .x emit_expr：binding.CONST 常量访问（先于 (base).field 回落）。 */
int32_t codegen_x_try_emit_import_module_const(uint8_t *out, uint8_t *expr) {
    if (!out || !expr) return -1;
    return codegen_try_emit_import_module_const((FILE *)out, (const struct ASTExpr *)expr) == 0 ? 0 : -1;
}

/** CORE-001：与 typeck type_size_of 对齐的 codegen 侧大小查询。 */
static int codegen_type_size_of(const struct ASTType *ty) {
    if (!ty) return 0;
    switch (ty->kind) {
        case AST_TYPE_I32: case AST_TYPE_U32: case AST_TYPE_BOOL: return 4;
        case AST_TYPE_F32: return 4;
        case AST_TYPE_F64: return 8;
        case AST_TYPE_U8: return 1;
        case AST_TYPE_I64: case AST_TYPE_U64: case AST_TYPE_USIZE: case AST_TYPE_ISIZE: return 8;
        case AST_TYPE_PTR: return 8;
        case AST_TYPE_SLICE: return 16;
        case AST_TYPE_ARRAY: {
            int esz = ty->elem_type ? codegen_type_size_of(ty->elem_type) : 0;
            return (ty->array_size > 0 && esz > 0) ? (ty->array_size * esz) : 0;
        }
        case AST_TYPE_VECTOR: {
            int esz = ty->elem_type ? codegen_type_size_of(ty->elem_type) : 0;
            return (ty->array_size > 0 && esz > 0) ? (ty->array_size * esz) : 0;
        }
        case AST_TYPE_NAMED: {
            const struct ASTStructDef *sd = codegen_find_struct_def_by_name(ty->name);
            if (sd && sd->struct_size > 0) return sd->struct_size;
            if (ty->name && strcmp(ty->name, "i32") == 0) return 4;
            if (ty->name && strcmp(ty->name, "u32") == 0) return 4;
            if (ty->name && strcmp(ty->name, "bool") == 0) return 4;
            if (ty->name && strcmp(ty->name, "u8") == 0) return 1;
            if (ty->name && (strcmp(ty->name, "i16") == 0 || strcmp(ty->name, "u16") == 0)) return 2; /* CORE-013 */
            if (ty->name && strcmp(ty->name, "i64") == 0) return 8;
            if (ty->name && strcmp(ty->name, "u64") == 0) return 8;
            if (ty->name && strcmp(ty->name, "f64") == 0) return 8;
            if (ty->name && strcmp(ty->name, "f32") == 0) return 4;
            return 0;
        }
        default: return 0;
    }
}

/** CORE-001：与 typeck type_align_of 对齐的 codegen 侧对齐查询。 */
static int codegen_type_align_of(const struct ASTType *ty) {
    if (!ty) return 0;
    switch (ty->kind) {
        case AST_TYPE_I32: case AST_TYPE_U32: case AST_TYPE_BOOL: case AST_TYPE_F32: return 4;
        case AST_TYPE_F64: case AST_TYPE_I64: case AST_TYPE_U64: case AST_TYPE_USIZE: case AST_TYPE_ISIZE: return 8;
        case AST_TYPE_U8: return 1;
        case AST_TYPE_PTR: case AST_TYPE_SLICE: return 8;
        case AST_TYPE_ARRAY: case AST_TYPE_VECTOR:
            return ty->elem_type ? codegen_type_align_of(ty->elem_type) : 1;
        case AST_TYPE_NAMED: {
            const struct ASTStructDef *sd = codegen_find_struct_def_by_name(ty->name);
            if (sd && sd->struct_align > 0) return sd->struct_align;
            if (ty->name && (strcmp(ty->name, "i32") == 0 || strcmp(ty->name, "u32") == 0 || strcmp(ty->name, "bool") == 0)) return 4;
            if (ty->name && strcmp(ty->name, "u8") == 0) return 1;
            if (ty->name && (strcmp(ty->name, "i16") == 0 || strcmp(ty->name, "u16") == 0)) return 2; /* CORE-013 */
            if (ty->name && (strcmp(ty->name, "i64") == 0 || strcmp(ty->name, "u64") == 0 || strcmp(ty->name, "f64") == 0)) return 8;
            if (ty->name && strcmp(ty->name, "f32") == 0) return 4;
            return 1;
        }
        default: return 1;
    }
}

/**
 * CORE-001：若 e 为 size_of<T>() / align_of<T>()，直接输出整型常量；1=已输出，0=非此类调用，-1=错误。
 */
static int codegen_try_emit_type_layout_intrinsic(FILE *out, const struct ASTExpr *e) {
    const struct ASTFunc *f;
    int val;
    if (!e || !out) return 0;
    f = e->value.call.resolved_callee_func;
    if (!f || !f->name || e->value.call.num_type_args != 1 || e->value.call.num_args != 0
        || !e->value.call.type_args || !e->value.call.type_args[0])
        return 0;
    if (strcmp(f->name, "size_of") == 0)
        val = codegen_type_size_of(e->value.call.type_args[0]);
    else if (strcmp(f->name, "align_of") == 0)
        val = codegen_type_align_of(e->value.call.type_args[0]);
    else
        return 0;
    if (val <= 0) return -1;
    fprintf(out, "%d", val);
    return 1;
}

/** 根据结构体名查找字段类型（当前模块或依赖）；用于结构体字面量判断数组字段。返回 NULL 表示未找到。 */
static const struct ASTType *get_struct_field_type(const char *struct_name, const char *field_name) {
    if (!struct_name || !field_name) return NULL;
    if (codegen_current_module && codegen_current_module->struct_defs) {
        for (int i = 0; i < codegen_current_module->num_structs; i++) {
            const struct ASTStructDef *sd = codegen_current_module->struct_defs[i];
            if (!sd || !sd->name || strcmp(sd->name, struct_name) != 0) continue;
            for (int j = 0; j < sd->num_fields; j++)
                if (sd->fields[j].name && strcmp(sd->fields[j].name, field_name) == 0)
                    return sd->fields[j].type;
            return NULL;
        }
    }
    if (codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
        for (int di = 0; di < codegen_ndep; di++) {
            const struct ASTModule *d = codegen_dep_mods[di];
            if (!d || !d->struct_defs) continue;
            for (int j = 0; j < d->num_structs; j++) {
                if (!d->struct_defs[j]->name || strcmp(d->struct_defs[j]->name, struct_name) != 0) continue;
                const struct ASTStructDef *sd = d->struct_defs[j];
                for (int k = 0; k < sd->num_fields; k++)
                    if (sd->fields[k].name && strcmp(sd->fields[k].name, field_name) == 0)
                        return sd->fields[k].type;
                return NULL;
            }
        }
    }
    return NULL;
}

/** 仅写结构体类型名 "struct X" 或 "struct prefix_X"（不含 "( ){ "），供块形式结构体字面量用。 */
static void codegen_emit_struct_type_name_only(FILE *out, const char *struct_name) {
    if (!struct_name) { fprintf(out, "struct unknown"); return; }
    if (codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
        int found = 0;
        for (int di = 0; di < codegen_ndep && !found; di++) {
            const struct ASTModule *d = codegen_dep_mods[di];
            if (!d || !d->struct_defs) continue;
            for (int sj = 0; sj < d->num_structs; sj++)
                if (d->struct_defs[sj]->name && strcmp(d->struct_defs[sj]->name, struct_name) == 0) {
                    char pre[256];
                    import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                    fprintf(out, "struct %s%s", pre, struct_name);
                    found = 1;
                    break;
                }
        }
        if (!found) { char buf[256]; library_prefixed_name(struct_name, buf, sizeof(buf)); fprintf(out, "struct %s", buf); }
    } else if (codegen_library_prefix && *codegen_library_prefix) {
        char buf[256]; library_prefixed_name(struct_name, buf, sizeof(buf)); fprintf(out, "struct %s", buf);
    } else if (!codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
        int found = 0;
        for (int di = 0; di < codegen_ndep && !found; di++) {
            const struct ASTModule *d = codegen_dep_mods[di];
            if (!d || !d->struct_defs) continue;
            for (int sj = 0; sj < d->num_structs; sj++)
                if (d->struct_defs[sj]->name && strcmp(d->struct_defs[sj]->name, struct_name) == 0) {
                    char pre[256];
                    import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                    fprintf(out, "struct %s%s", pre, struct_name);
                    found = 1;
                    break;
                }
        }
        if (!found) fprintf(out, "struct %s", struct_name);
    } else {
        fprintf(out, "struct %s", struct_name);
    }
}

/**
 * 递归求表达式可能产生的 struct 类型 C 串；用于嵌套 if-expr 的 __tmp 推断（else 为 else if 时 typeck 可能未设 resolved_type）。
 * 返回：若表达式会产生 struct 值则写入 buf 并返回 buf，否则返回 NULL。
 */
static const char *expr_struct_type_str(const struct ASTExpr *e, char *buf, size_t bufsize) {
    if (!e || !buf || bufsize < 16) return NULL;
    if (e->kind == AST_EXPR_STRUCT_LIT) return struct_lit_c_type_str(e, buf, bufsize);
    if (e->kind == AST_EXPR_IF) {
        const struct ASTExpr *ee = e->value.if_expr.else_expr;
        const struct ASTExpr *te = e->value.if_expr.then_expr;
        if (ee && expr_struct_type_str(ee, buf, bufsize)) return buf;
        if (te && expr_struct_type_str(te, buf, bufsize)) return buf;
        if (e->resolved_type) {
            const char *s = c_type_str(e->resolved_type);
            if (s && strncmp(s, "struct ", 7) == 0) { snprintf(buf, bufsize, "%s", s); return buf; }
        }
        return NULL;
    }
    if (e->kind == AST_EXPR_ASSIGN && e->value.binop.right)
        return expr_struct_type_str(e->value.binop.right, buf, bufsize);
    /* 块仅含 return expr 或 if (cond) return 时从操作数/then 推断 struct 类型（如 if (ref<=0) { return Type{...}; } 无 else 时 then 为块） */
    if (e->kind == AST_EXPR_BLOCK && e->value.block) {
        const struct ASTBlock *b = e->value.block;
        const struct ASTExpr *ret_e = NULL;
        if (b->final_expr && b->final_expr->kind == AST_EXPR_RETURN)
            ret_e = b->final_expr->value.unary.operand;
        else if (b->final_expr && b->final_expr->kind == AST_EXPR_IF)
            return expr_struct_type_str(b->final_expr->value.if_expr.then_expr, buf, bufsize);
        else if (b->num_expr_stmts == 1 && b->expr_stmts && b->expr_stmts[0]
                 && b->expr_stmts[0]->kind == AST_EXPR_RETURN)
            ret_e = b->expr_stmts[0]->value.unary.operand;
        else if (b->num_labeled_stmts == 1 && b->labeled_stmts
                 && b->labeled_stmts[0].kind == AST_STMT_RETURN && b->labeled_stmts[0].u.return_expr)
            ret_e = b->labeled_stmts[0].u.return_expr;
        if (ret_e && expr_struct_type_str(ret_e, buf, bufsize)) return buf;
    }
    if (e->resolved_type) {
        const char *s = c_type_str(e->resolved_type);
        if (s && strncmp(s, "struct ", 7) == 0) { snprintf(buf, bufsize, "%s", s); return buf; }
    }
    return NULL;
}

/** 返回结构体字面量 e 的 C 类型串（如 "struct ast_Type"），写入 buf，与 codegen 发射该字面量时用的类型一致。
 * 用于 if-expr 的 __tmp 类型推断：else 为 (Type){0} 时 typeck 可能未设 resolved_type，用此函数得到正确 __tmp 类型。 */
static const char *struct_lit_c_type_str(const struct ASTExpr *e, char *buf, size_t bufsize) {
    if (!e || e->kind != AST_EXPR_STRUCT_LIT || !e->value.struct_lit.struct_name || bufsize < 16) return NULL;
    /* 与局部变量/赋值左侧一致：typeck 已解出完整 C struct 名（如 struct ast_Buffer）时优先用之，
     * 避免 compound literal 仍用 (struct Buffer) 而声明为 struct ast_Buffer 导致 incomplete type。 */
    if (e->resolved_type) {
        const char *s = c_type_str(e->resolved_type);
        if (s && strncmp(s, "struct ", 7) == 0) {
            snprintf(buf, bufsize, "%s", s);
            return buf;
        }
    }
    const char *sname = e->value.struct_lit.struct_name;
    const char *lookup = codegen_import_select_source_name(sname);
    if (codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
        for (int di = 0; di < codegen_ndep; di++) {
            const struct ASTModule *d = codegen_dep_mods[di];
            if (!d || !d->struct_defs) continue;
            for (int sj = 0; sj < d->num_structs; sj++)
                if (d->struct_defs[sj]->name && strcmp(d->struct_defs[sj]->name, lookup) == 0) {
                    char pre[64];
                    import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                    snprintf(buf, bufsize, "struct %s%s", pre, lookup);
                    return buf;
                }
        }
    }
    if (codegen_current_module && codegen_current_module->struct_defs) {
        for (int i = 0; i < codegen_current_module->num_structs; i++)
            if (codegen_current_module->struct_defs[i]->name && strcmp(codegen_current_module->struct_defs[i]->name, sname) == 0) {
                /* 库模块 -E 时用 codegen_library_prefix（如 ast_），与生成 C 中 struct ast_Type 一致，避免 incomplete type */
                if (codegen_library_prefix && *codegen_library_prefix) {
                    snprintf(buf, bufsize, "struct %s%s", codegen_library_prefix, sname);
                    return buf;
                }
                if (codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
                    for (int di = 0; di < codegen_ndep; di++)
                        if (codegen_dep_mods[di] == codegen_current_module) {
                            char pre[64];
                            import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                            snprintf(buf, bufsize, "struct %s%s", pre, sname);
                            return buf;
                        }
                }
                snprintf(buf, bufsize, "struct %s", sname);
                return buf;
            }
    }
    /* 未在 dep/本模块找到时（如 -E 展开时 dep 未设）：按 "mod.Type" → "struct mod_Type" 兜底，与 C 命名一致 */
    if (strchr(sname, '.')) {
        const char *dot = strchr(sname, '.');
        size_t pre_len = (size_t)(dot - sname);
        if (pre_len < bufsize && (pre_len + 2 + strlen(dot + 1)) < bufsize)
            snprintf(buf, bufsize, "struct %.*s_%s", (int)pre_len, sname, dot + 1);
        else
            snprintf(buf, bufsize, "struct %s", sname);
    } else {
        snprintf(buf, bufsize, "struct %s", sname);
    }
    return buf;
}

/** 仅写结构体字面量的 C 名前缀 "(struct X){ "，与 struct_lit_c_type_str 一致，避免标签与声明不一致。 */
static int codegen_emit_struct_lit_name_prefix(FILE *out, const struct ASTExpr *e) {
    char tybuf[256];
    const char *ct = struct_lit_c_type_str(e, tybuf, sizeof(tybuf));
    if (ct)
        fprintf(out, "(%s){ ", ct);
    else
        fprintf(out, "(struct unknown){ ");
    return 0;
}

/** 结构体字面量完整输出（C 路径保留，供非 .x 或 fallback）；字段循环与 .x 自实现一致。
 * 当存在任意数组类型字段时 C 不允许在复合字面量中直接赋数组（含变量或部分字面量），故改用块形式：临时变量 + 逐字段赋值 + memcpy。 */
static int codegen_emit_struct_lit_impl(FILE *out, const struct ASTExpr *e) {
    const char *sname = e->value.struct_lit.struct_name ? e->value.struct_lit.struct_name : "";
    int use_block = 0;
    for (int i = 0; i < e->value.struct_lit.num_fields && !use_block; i++) {
        const char *fname = e->value.struct_lit.field_names[i] ? e->value.struct_lit.field_names[i] : "";
        const struct ASTType *fty = get_struct_field_type(sname, fname);
        if (fty && fty->kind == AST_TYPE_ARRAY) use_block = 1;
    }
    if (use_block) {
        fprintf(out, "({ ");
        static char _lit_ct_buf[256];
        const char *lit_ct = struct_lit_c_type_str(e, _lit_ct_buf, sizeof(_lit_ct_buf));
        if (lit_ct)
            fprintf(out, "%s _t = { 0 }; ", lit_ct);
        else {
            codegen_emit_struct_type_name_only(out, sname);
            fprintf(out, " _t = { 0 }; ");
        }
        /* 先输出所有标量/小字段赋值，再输出 memcpy，避免 memcpy(_t.name, ...) 覆盖栈上相邻变量（如 parser 的 func_name_len_storage）导致 name_len 被破坏。 */
        for (int i = 0; i < e->value.struct_lit.num_fields; i++) {
            const char *fname = e->value.struct_lit.field_names[i] ? e->value.struct_lit.field_names[i] : "";
            const struct ASTType *fty = get_struct_field_type(sname, fname);
            const struct ASTExpr *init = e->value.struct_lit.inits[i];
            if (fty && fty->kind == AST_TYPE_ARRAY && init && init->kind == AST_EXPR_VAR && init->value.var.name) {
                /* 数组用 memcpy，放到后面一轮再输出 */
                continue;
            }
            if (fty && fty->kind == AST_TYPE_ARRAY && init && init->kind == AST_EXPR_FIELD_ACCESS && init->value.field_access.base) {
                /* 数组字段来自另一结构体字段（如 scan.name），用 memcpy，放到后面一轮再输出 */
                continue;
            }
            if (fty && fty->kind == AST_TYPE_ARRAY && init && init->kind == AST_EXPR_ARRAY_LIT && fty->elem_type && fty->elem_type->kind == AST_TYPE_ARRAY) {
                /* 多维数组字面量：C 不能对数组赋值，已由 _t = { 0 } 零初始化，跳过 */
                continue;
            }
            if (fty && fty->kind == AST_TYPE_ARRAY && init && init->kind == AST_EXPR_ARRAY_LIT) {
                /* C 不允许 _t.arr = { ... } 赋值，改为逐元素 _t.arr[j] = expr */
                for (int j = 0; j < init->value.array_lit.num_elems; j++) {
                    fprintf(out, "_t.%s[%d] = ", fname, j);
                    if (codegen_expr(init->value.array_lit.elems[j], out) != 0) return -1;
                    fprintf(out, "; ");
                }
                continue;
            }
            fprintf(out, "_t.%s = ", fname);
            if (init && init->kind == AST_EXPR_ARRAY_LIT) {
                fprintf(out, "{ ");
                for (int j = 0; j < init->value.array_lit.num_elems; j++) {
                    if (j) fprintf(out, ", ");
                    if (codegen_expr(init->value.array_lit.elems[j], out) != 0) return -1;
                }
                fprintf(out, " }; ");
            } else if (codegen_expr(init, out) != 0)
                return -1;
            else
                fprintf(out, "; ");
        }
        for (int i = 0; i < e->value.struct_lit.num_fields; i++) {
            const char *fname = e->value.struct_lit.field_names[i] ? e->value.struct_lit.field_names[i] : "";
            const struct ASTType *fty = get_struct_field_type(sname, fname);
            const struct ASTExpr *init = e->value.struct_lit.inits[i];
            if (fty && fty->kind == AST_TYPE_ARRAY && init && init->kind == AST_EXPR_VAR && init->value.var.name)
                fprintf(out, "memcpy(_t.%s, %s, sizeof(_t.%s)); ", fname, init->value.var.name, fname);
            else if (fty && fty->kind == AST_TYPE_ARRAY && init && init->kind == AST_EXPR_FIELD_ACCESS && init->value.field_access.base) {
                const char *src_field = init->value.field_access.field_name ? init->value.field_access.field_name : "";
                fprintf(out, "memcpy(_t.%s, (", fname);
                if (codegen_expr(init->value.field_access.base, out) != 0) return -1;
                fprintf(out, ").%s, sizeof(_t.%s)); ", src_field, fname);
            }
        }
        fprintf(out, "_t; })");
        return 0;
    }
    if (codegen_emit_struct_lit_name_prefix(out, e) != 0) return -1;
    for (int i = 0; i < e->value.struct_lit.num_fields; i++) {
        if (i) fprintf(out, ", ");
        fprintf(out, ".%s = ", e->value.struct_lit.field_names[i] ? e->value.struct_lit.field_names[i] : "");
        if (e->value.struct_lit.inits[i]->kind == AST_EXPR_ARRAY_LIT) {
            const struct ASTExpr *arr = e->value.struct_lit.inits[i];
            /* 空数组 [] 用 { 0 } 零初始化，避免 (elem[]){} 在部分 C 中与结构体成员类型不匹配 */
            if (arr->value.array_lit.num_elems == 0) {
                fprintf(out, "{ 0 }");
            } else {
                fprintf(out, "{ ");
                for (int j = 0; j < arr->value.array_lit.num_elems; j++) {
                    if (j) fprintf(out, ", ");
                    if (codegen_expr(arr->value.array_lit.elems[j], out) != 0) return -1;
                }
                fprintf(out, " }");
            }
        } else if (codegen_expr(e->value.struct_lit.inits[i], out) != 0)
            return -1;
    }
    fprintf(out, " }");
    return 0;
}

/** .x 侧仅写 "(struct X){ "，供 .x 自己实现 struct_lit 时调用。 */
int32_t codegen_x_emit_struct_lit_c_name_prefix(uint8_t *out, uint8_t *expr) {
    return codegen_emit_struct_lit_name_prefix((FILE *)out, (const struct ASTExpr *)expr) != 0 ? -1 : 0;
}

/** .x 侧 STRUCT_LIT 访问器：字段数、第 i 个字段名（ptr/len）、第 i 个初值表达式。 */
int32_t codegen_x_struct_lit_num_fields(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return (e && e->kind == AST_EXPR_STRUCT_LIT) ? (int32_t)e->value.struct_lit.num_fields : 0;
}
uint8_t *codegen_x_struct_lit_field_name(uint8_t *expr, int32_t i) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_STRUCT_LIT || !e->value.struct_lit.field_names || i < 0 || i >= e->value.struct_lit.num_fields)
        return (uint8_t *)"";
    return (uint8_t *)(e->value.struct_lit.field_names[i] ? e->value.struct_lit.field_names[i] : "");
}
int32_t codegen_x_struct_lit_field_name_len(uint8_t *expr, int32_t i) {
    const char *fn = (const char *)codegen_x_struct_lit_field_name(expr, i);
    return (int32_t)strlen(fn);
}
uint8_t *codegen_x_struct_lit_init(uint8_t *expr, int32_t i) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_STRUCT_LIT || !e->value.struct_lit.inits || i < 0 || i >= e->value.struct_lit.num_fields)
        return NULL;
    return (uint8_t *)e->value.struct_lit.inits[i];
}

/** .x 侧表达式 kind（AST_EXPR_*），用于 .x 判断是否为 ARRAY_LIT 等。 */
int32_t codegen_x_expr_kind(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return e ? (int32_t)e->kind : -1;
}
int32_t codegen_x_expr_kind_array_lit(void) { return (int32_t)AST_EXPR_ARRAY_LIT; }

/** .x 侧 ARRAY_LIT 访问器：元素个数、第 j 个元素表达式。 */
int32_t codegen_x_array_lit_num_elems(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return (e && e->kind == AST_EXPR_ARRAY_LIT) ? (int32_t)e->value.array_lit.num_elems : 0;
}
uint8_t *codegen_x_array_lit_elem(uint8_t *expr, int32_t j) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_ARRAY_LIT || !e->value.array_lit.elems || j < 0 || j >= e->value.array_lit.num_elems)
        return NULL;
    return (uint8_t *)e->value.array_lit.elems[j];
}

/** .x 侧结构体字面量全量输出：供 codegen.x 在未自实现时转调（fallback）。 */
int32_t codegen_x_emit_struct_lit_full(uint8_t *out, uint8_t *expr) {
    return codegen_emit_struct_lit_impl((FILE *)out, (const struct ASTExpr *)expr) != 0 ? -1 : 0;
}

/** 数组字面量完整输出（供 .x 转调）：slice 或 (elem_ty[]){ ... }。 */
static int codegen_emit_array_lit_impl(FILE *out, const struct ASTExpr *e) {
    const struct ASTType *aty = e->resolved_type;
    const struct ASTType *elem_ty = (aty && (aty->kind == AST_TYPE_ARRAY || aty->kind == AST_TYPE_SLICE)) ? aty->elem_type : NULL;
    if (!elem_ty && e->value.array_lit.num_elems > 0) {
        for (int ei = 0; ei < e->value.array_lit.num_elems && !elem_ty; ei++)
            if (e->value.array_lit.elems[ei]->resolved_type)
                elem_ty = e->value.array_lit.elems[ei]->resolved_type;
    }
    int n = e->value.array_lit.num_elems;
    char elem_ty_buf[64];
    snprintf(elem_ty_buf, sizeof(elem_ty_buf), "%s", elem_ty ? c_type_str(elem_ty) : "uint8_t");
    if (aty && aty->kind == AST_TYPE_SLICE && elem_ty) {
        ensure_slice_struct(aty, out);
        fprintf(out, "(%s){ .data = (%s[]){ ", c_type_str(aty), elem_ty_buf);
        for (int i = 0; i < n; i++) {
            if (i) fprintf(out, ", ");
            if (codegen_expr(e->value.array_lit.elems[i], out) != 0) return -1;
        }
        fprintf(out, " }, .length = %d }", n);
        return 0;
    }
    if (aty && aty->kind == AST_TYPE_ARRAY && aty->array_size > 0)
        fprintf(out, "(%s[%d]){ ", elem_ty_buf, aty->array_size);
    else
        fprintf(out, "(%s[]){ ", elem_ty_buf);
    for (int i = 0; i < n; i++) {
        if (i) fprintf(out, ", ");
        if (codegen_expr(e->value.array_lit.elems[i], out) != 0) return -1;
    }
    fprintf(out, " }");
    return 0;
}
/** .x 侧数组字面量全量输出：供 codegen.x 在未自实现时转调（fallback）。 */
int32_t codegen_x_emit_array_lit_full(uint8_t *out, uint8_t *expr) {
    return codegen_emit_array_lit_impl((FILE *)out, (const struct ASTExpr *)expr) != 0 ? -1 : 0;
}

/** .x 侧 ARRAY_LIT 自实现用：是否为 slice 分支（resolved_type 为 SLICE 且有 elem_ty）。 */
int32_t codegen_x_array_lit_is_slice(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_ARRAY_LIT || !e->resolved_type || e->resolved_type->kind != AST_TYPE_SLICE)
        return 0;
    if (e->resolved_type->elem_type) return 1;
    if (e->value.array_lit.num_elems > 0)
        for (int ei = 0; ei < e->value.array_lit.num_elems; ei++)
            if (e->value.array_lit.elems[ei]->resolved_type) return 1;
    return 0;
}

/** .x 侧只写 slice 前缀：ensure_slice_struct + "(slice_ty){ .data = (elem_ty[]){ "。 */
int32_t codegen_x_emit_array_lit_slice_prefix(uint8_t *out, uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    const struct ASTType *aty = e->resolved_type;
    const struct ASTType *elem_ty = (aty && aty->kind == AST_TYPE_SLICE && aty->elem_type) ? aty->elem_type : NULL;
    if (!elem_ty && e->value.array_lit.num_elems > 0)
        for (int ei = 0; ei < e->value.array_lit.num_elems && !elem_ty; ei++)
            if (e->value.array_lit.elems[ei]->resolved_type)
                elem_ty = e->value.array_lit.elems[ei]->resolved_type;
    if (!aty || aty->kind != AST_TYPE_SLICE || !elem_ty) return -1;
    ensure_slice_struct(aty, (FILE *)out);
    char elem_ty_buf[64];
    snprintf(elem_ty_buf, sizeof(elem_ty_buf), "%s", c_type_str(elem_ty));
    fprintf((FILE *)out, "(%s){ .data = (%s[]){ ", c_type_str(aty), elem_ty_buf);
    return 0;
}

/** .x 侧只写 slice 后缀：" }, .length = n }"。 */
int32_t codegen_x_emit_array_lit_slice_suffix(uint8_t *out, int32_t n_elems) {
    fprintf((FILE *)out, " }, .length = %d }", (int)n_elems);
    return 0;
}

/** .x 侧只写数组字面量前缀："(elem_ty[size]){ " 或 "(elem_ty[]){ "。 */
int32_t codegen_x_emit_array_lit_array_prefix(uint8_t *out, uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    const struct ASTType *aty = e->resolved_type;
    const struct ASTType *elem_ty = (aty && (aty->kind == AST_TYPE_ARRAY || aty->kind == AST_TYPE_SLICE)) ? aty->elem_type : NULL;
    if (!elem_ty && e->value.array_lit.num_elems > 0)
        for (int ei = 0; ei < e->value.array_lit.num_elems && !elem_ty; ei++)
            if (e->value.array_lit.elems[ei]->resolved_type)
                elem_ty = e->value.array_lit.elems[ei]->resolved_type;
    char elem_ty_buf[64];
    snprintf(elem_ty_buf, sizeof(elem_ty_buf), "%s", elem_ty ? c_type_str(elem_ty) : "uint8_t");
    if (aty && aty->kind == AST_TYPE_ARRAY && aty->array_size > 0)
        fprintf((FILE *)out, "(%s[%d]){ ", elem_ty_buf, aty->array_size);
    else
        fprintf((FILE *)out, "(%s[]){ ", elem_ty_buf);
    return 0;
}

/** .x 侧只写数组字面量后缀：" }"。 */
int32_t codegen_x_emit_array_lit_array_suffix(uint8_t *out) {
    fprintf((FILE *)out, " }");
    return 0;
}

/** 向量 binop 单 lane：数组字面量取 elems[i]，否则 (.v[i])。 */
static int codegen_vector_lane_expr(const struct ASTExpr *e, int lane, FILE *out) {
    if (e->kind == AST_EXPR_ARRAY_LIT) {
        if (lane < 0 || lane >= e->value.array_lit.num_elems)
            return -1;
        return codegen_expr(e->value.array_lit.elems[lane], out);
    }
    fprintf(out, "(");
    if (codegen_expr(e, out) != 0) return -1;
    fprintf(out, ").v[%d]", lane);
    return 0;
}

/** 若 e 为向量二元运算（resolved_type 为 VECTOR），则生成逐分量 op 的复合字面量并返回 0；否则返回 -1（调用方走标量分支）。 */
static int codegen_vector_binop(const struct ASTExpr *e, const char *op, FILE *out) {
    if (!e || !e->resolved_type || e->resolved_type->kind != AST_TYPE_VECTOR
        || !e->resolved_type->elem_type || e->resolved_type->array_size <= 0)
        return -1;
    int lanes = e->resolved_type->array_size;
    const char *tname = vector_c_type_name(e->resolved_type);
    ensure_vector_typedef(e->resolved_type, out);
    fprintf(out, "(%s){ ", tname);
    for (int i = 0; i < lanes; i++) {
        if (i) fprintf(out, ", ");
        fprintf(out, "(");
        if (codegen_vector_lane_expr(e->value.binop.left, i, out) != 0) return -1;
        fprintf(out, ") %s (", op);
        if (codegen_vector_lane_expr(e->value.binop.right, i, out) != 0) return -1;
        fprintf(out, ")");
    }
    fprintf(out, " }");
    return 0;
}

/**
 * 输出 const/let 的初始化表达式。block 用于“切片从数组”时查数组长度；可为 NULL（则不解析数组→切片）。
 * 当类型为数组且初值为字面量 0 时输出 {0}；当类型为切片且初值为数组变量时输出 { .data = name, .length = N }。
 */
static int codegen_init(const struct ASTType *ty, const struct ASTExpr *init, FILE *out, const struct ASTBlock *block) {
    if (!init) {
        if (ty && ty->kind == AST_TYPE_VECTOR) { fprintf(out, "{0}"); return 0; }
        /* let x: Struct; 无初值：零初始化，后续按字段赋值（std/json object_decode 等）。 */
        if (ty && ty->kind == AST_TYPE_NAMED && ty->name) { fprintf(out, "{0}"); return 0; }
        return -1;
    }
    if (ty && ty->kind == AST_TYPE_ARRAY && init->kind == AST_EXPR_LIT && init->value.int_val == 0) {
        fprintf(out, "{0}");
        return 0;
    }
    if (ty && ty->kind == AST_TYPE_VECTOR && init->kind == AST_EXPR_LIT && init->value.int_val == 0) {
        fprintf(out, "{0}");
        return 0;
    }
    /* f32/f64：整数字面量 0 生成 0.0f / 0.0；浮点字面量按 resolved_type 加 f 后缀（f32） */
    if (ty && (ty->kind == AST_TYPE_F32 || ty->kind == AST_TYPE_F64) && init) {
        if (init->kind == AST_EXPR_LIT && init->value.int_val == 0) {
            fprintf(out, ty->kind == AST_TYPE_F32 ? "0.0f" : "0.0");
            return 0;
        }
        if (init->kind == AST_EXPR_FLOAT_LIT) {
            double v = init->value.float_val;
            if (v == 0.0)
                fprintf(out, init->resolved_type && init->resolved_type->kind == AST_TYPE_F32 ? "0.0f" : "0.0");
            else if (init->resolved_type && init->resolved_type->kind == AST_TYPE_F32)
                fprintf(out, "%gf", v);
            else
                fprintf(out, "%g", v);
            return 0;
        }
    }
    if (ty && ty->kind == AST_TYPE_VECTOR && init->kind == AST_EXPR_ARRAY_LIT) {
        struct ASTExpr **elems = init->value.array_lit.elems;
        int num = init->value.array_lit.num_elems;
        fprintf(out, "{ ");
        for (int i = 0; i < num; i++) {
            if (i) fprintf(out, ", ");
            if (codegen_expr(elems[i], out) != 0) return -1;
        }
        fprintf(out, " }");
        return 0;
    }
    /* 数组变量/常量初始化须用 { e1, e2, ... }，不能用 (type[]){ ... }，否则 GCC 报 "array initialized from non-constant array expression"（Clang 可过） */
    /* 多维数组且初值为数组字面量（如 [empty32, ...]）时 C 不允许用变量名做元素初始化，用 { 0 } 零初始化（自举用） */
    if (ty && ty->kind == AST_TYPE_ARRAY && init->kind == AST_EXPR_ARRAY_LIT) {
        if (ty->elem_type && ty->elem_type->kind == AST_TYPE_ARRAY) {
            fprintf(out, "{ 0 }");
            return 0;
        }
        struct ASTExpr **elems = init->value.array_lit.elems;
        int num = init->value.array_lit.num_elems;
        /* 空字面量 [] 表示按声明长度零初始化，C 用 { 0 } 保证整数组为零且兼容 C99 */
        if (num == 0 && ty->array_size > 0) {
            fprintf(out, "{ 0 }");
            return 0;
        }
        fprintf(out, "{ ");
        for (int i = 0; i < num; i++) {
            if (i) fprintf(out, ", ");
            if (codegen_expr(elems[i], out) != 0) return -1;
        }
        fprintf(out, " }");
        return 0;
    }
    /* 切片从数组变量初始化：先查当前 block 的 const/let；若未找到则用 init->resolved_type（typeck 已填，如外层块的 [64]u8） */
    if (ty && ty->kind == AST_TYPE_SLICE && init && init->kind == AST_EXPR_VAR) {
        const char *name = init->value.var.name;
        if (block) {
            for (int i = 0; i < block->num_consts; i++)
                if (block->const_decls[i].name && name && strcmp(block->const_decls[i].name, name) == 0 &&
                    block->const_decls[i].type && block->const_decls[i].type->kind == AST_TYPE_ARRAY) {
                    fprintf(out, "{ .data = %s, .length = %d }", name ? name : "", block->const_decls[i].type->array_size);
                    return 0;
                }
            for (int i = 0; i < block->num_lets; i++)
                if (block->let_decls[i].name && name && strcmp(block->let_decls[i].name, name) == 0 &&
                    block->let_decls[i].type && block->let_decls[i].type->kind == AST_TYPE_ARRAY) {
                    fprintf(out, "{ .data = %s, .length = %d }", name ? name : "", block->let_decls[i].type->array_size);
                    return 0;
                }
        }
        if (init->resolved_type && init->resolved_type->kind == AST_TYPE_ARRAY && init->resolved_type->array_size > 0) {
            fprintf(out, "{ .data = %s, .length = %d }", name ? name : "", init->resolved_type->array_size);
            return 0;
        }
    }
    return codegen_expr(init, out);
}

/** 返回 1 表示类型为整数（用于除零检查：仅整数 / % 时插入运行时检查），0 表示浮点或其它 */
static int is_integer_type(const struct ASTType *ty) {
    if (!ty) return 0;
    switch (ty->kind) {
        case AST_TYPE_I32: case AST_TYPE_U32: case AST_TYPE_I64: case AST_TYPE_U64:
        case AST_TYPE_USIZE: case AST_TYPE_ISIZE: case AST_TYPE_U8: case AST_TYPE_BOOL:
            return 1;
        default: return 0;
    }
}

/**
 * 赋值左端为 FIELD_ACCESS(INDEX(base, idx), field) 时，生成可赋值的 C；assign_op 为 "=" 或 "+=" 等。
 * 生成 (idx 越界 ? (shux_panic_(1,0), 0) : ((base)[idx].field assign_op right, 0))。成功返回 0，否则 -1。
 */
static int codegen_assign_field_index_lvalue_op(FILE *out, const struct ASTExpr *left, const struct ASTExpr *right, const char *assign_op) {
    if (!left || left->kind != AST_EXPR_FIELD_ACCESS) return -1;
    const struct ASTExpr *base = left->value.field_access.base;
    const char *field = left->value.field_access.field_name;
    if (!base || base->kind != AST_EXPR_INDEX || !field) return -1;
    const struct ASTExpr *arr = base->value.index.base;
    const struct ASTExpr *idx = base->value.index.index_expr;
    const struct ASTType *arr_ty = arr ? arr->resolved_type : NULL;
    if (base->index_proven_in_bounds) return -1;
    if (!arr_ty || arr_ty->kind != AST_TYPE_ARRAY || arr_ty->array_size <= 0) return -1;
    int n = (int)arr_ty->array_size;
    fprintf(out, "(");
    if (codegen_expr(idx, out) != 0) return -1;
    fprintf(out, " < 0 || (");
    if (codegen_expr(idx, out) != 0) return -1;
    fprintf(out, ") >= %d ? (shux_panic_(1, 0), 0) : ((", n);
    if (codegen_expr(arr, out) != 0) return -1;
    fprintf(out, ")[");
    if (codegen_expr(idx, out) != 0) return -1;
    fprintf(out, "].%s %s ", field, assign_op);
    if (codegen_expr(right, out) != 0) return -1;
    fprintf(out, ", 0))");
    return 0;
}
static int codegen_assign_field_index_lvalue(FILE *out, const struct ASTExpr *left, const struct ASTExpr *right) {
    return codegen_assign_field_index_lvalue_op(out, left, right, "=");
}

/**
 * 赋值左端为带边界检查的 INDEX 时，生成可赋值的 C；assign_op 为 "=" 或 "+=" 等。成功返回 0，非 INDEX 或无可做返回 -1。
 */
static int codegen_assign_index_lvalue_op(FILE *out, const struct ASTExpr *left, const struct ASTExpr *right, const char *assign_op) {
    if (!left || left->kind != AST_EXPR_INDEX) return -1;
    const struct ASTExpr *base = left->value.index.base;
    const struct ASTExpr *idx = left->value.index.index_expr;
    const struct ASTType *base_ty = base ? base->resolved_type : NULL;
    if (left->index_proven_in_bounds) return -1;
    if (left->value.index.base_is_slice && base_ty && base_ty->kind == AST_TYPE_SLICE) {
        int use_arrow = expr_is_slice_ptr_param(base);
        const char *da = use_arrow ? ")->" : ").";
        fprintf(out, "(");
        if (codegen_expr(idx, out) != 0) return -1;
        fprintf(out, " < 0 || (size_t)(");
        if (codegen_expr(idx, out) != 0) return -1;
        fprintf(out, ") >= (");
        if (codegen_expr(base, out) != 0) return -1;
        fprintf(out, "%slength ? (shux_panic_(1, 0), 0) : ((", da);
        if (codegen_expr(base, out) != 0) return -1;
        fprintf(out, "%sdata[", da);
        if (codegen_expr(idx, out) != 0) return -1;
        fprintf(out, "] %s ", assign_op);
        if (codegen_expr(right, out) != 0) return -1;
        fprintf(out, ", 0))");
        return 0;
    }
    if (!left->value.index.base_is_slice && base_ty && base_ty->kind == AST_TYPE_ARRAY && base_ty->array_size > 0) {
        int n = (int)base_ty->array_size;
        fprintf(out, "(");
        if (codegen_expr(idx, out) != 0) return -1;
        fprintf(out, " < 0 || (");
        if (codegen_expr(idx, out) != 0) return -1;
        fprintf(out, ") >= %d ? (shux_panic_(1, 0), 0) : ((", n);
        if (codegen_expr(base, out) != 0) return -1;
        fprintf(out, ")[");
        if (codegen_expr(idx, out) != 0) return -1;
        fprintf(out, "] %s ", assign_op);
        if (codegen_expr(right, out) != 0) return -1;
        fprintf(out, ", 0))");
        return 0;
    }
    return -1;
}
static int codegen_assign_index_lvalue(FILE *out, const struct ASTExpr *left, const struct ASTExpr *right) {
    return codegen_assign_index_lvalue_op(out, left, right, "=");
}

/**
 * 将单棵表达式生成 C 表达式写入 out（LIT 输出整数字面量，ADD/SUB 递归输出左 op 右）。
 * 参数：e 表达式根节点，不可为 NULL；out 输出流。返回值：0 成功，-1 不支持的节点类型。副作用：仅写 out。
 */
/** 将 asm! 模板字符串以 C 字符串字面量形式（含两端引号）写入 out；转义 " \ 与常见控制符。K1。 */
static void codegen_emit_asm_c_string(FILE *out, const char *bytes, int len) {
    int i;
    fputc('"', out);
    for (i = 0; i < len && bytes; i++) {
        char c = bytes[i];
        switch (c) {
        case '"':  fputs("\\\"", out); break;
        case '\\': fputs("\\\\", out); break;
        case '\n': fputs("\\n", out); break;
        case '\r': fputs("\\r", out); break;
        case '\t': fputs("\\t", out); break;
        default:
            if ((unsigned char)c < 0x20)
                fprintf(out, "\\x%02x", (unsigned char)c);
            else
                fputc((int)c, out);
        }
    }
    fputc('"', out);
}

/** 发射完整 extended asm：__asm__("tmpl" : outs : ins : clobs)。仅输出到最后一个非空段；无操作数则 __asm__("tmpl")。K1/L8。 */
static void codegen_emit_asm_extended(FILE *out, const struct ASTExpr *e) {
    int last = -1; /* 0=outputs 1=inputs 2=clobbers */
    int i;
    int is_pure = 0;  /* options(pure) → 允许编译器消除/重排；默认 asm! 为 volatile 不可消除（内核 MMIO 安全） */
    int is_nomem = 0;  /* L8: options(nomem) → asm 不访问内存 */
    int is_readonly = 0;  /* L8: options(readonly) → asm 只读内存 */
    if (e->value.asm_tmpl.is_goto && e->value.asm_tmpl.num_labels > 0) last = 4;
    else if (e->value.asm_tmpl.num_clobbers > 0) last = 2;
    else if (e->value.asm_tmpl.num_inputs > 0) last = 1;
    else if (e->value.asm_tmpl.num_outputs > 0) last = 0;
    for (i = 0; i < e->value.asm_tmpl.num_options; i++)
        if (e->value.asm_tmpl.options[i]) {
            if (strcmp(e->value.asm_tmpl.options[i], "pure") == 0) is_pure = 1;
            else if (strcmp(e->value.asm_tmpl.options[i], "nomem") == 0) is_nomem = 1;
            else if (strcmp(e->value.asm_tmpl.options[i], "readonly") == 0) is_readonly = 1;
        }
    if (e->value.asm_tmpl.is_goto) {
        fputs("__asm__ goto(", out);
    } else {
        fputs((is_pure || is_nomem || is_readonly) ? "__asm__(" : "__asm__ __volatile__(", out);
    }
    codegen_emit_asm_c_string(out, e->value.asm_tmpl.bytes, e->value.asm_tmpl.len);
    if (last >= 0) {
        fputs(" : ", out);
        for (i = 0; i < e->value.asm_tmpl.num_outputs; i++) {
            if (i > 0) fputs(", ", out);
            codegen_emit_asm_c_string(out, e->value.asm_tmpl.outputs[i].constraint, (int)strlen(e->value.asm_tmpl.outputs[i].constraint));
            fputc('(', out);
            codegen_expr(e->value.asm_tmpl.outputs[i].expr, out);
            fputc(')', out);
        }
        if (last >= 1) {
            fputs(" : ", out);
            for (i = 0; i < e->value.asm_tmpl.num_inputs; i++) {
                if (i > 0) fputs(", ", out);
                codegen_emit_asm_c_string(out, e->value.asm_tmpl.inputs[i].constraint, (int)strlen(e->value.asm_tmpl.inputs[i].constraint));
                fputc('(', out);
                codegen_expr(e->value.asm_tmpl.inputs[i].expr, out);
                fputc(')', out);
            }
            if (last >= 2) {
                fputs(" : ", out);
                for (i = 0; i < e->value.asm_tmpl.num_clobbers; i++) {
                    if (i > 0) fputs(", ", out);
                    codegen_emit_asm_c_string(out, e->value.asm_tmpl.clobbers[i], (int)strlen(e->value.asm_tmpl.clobbers[i]));
                }
            }
        }
    }
    /* labels section (asm goto! only) */
    if (e->value.asm_tmpl.is_goto && last >= 4) {
        fputs(" : ", out);
        for (i = 0; i < e->value.asm_tmpl.num_labels; i++) {
            if (i > 0) fputs(", ", out);
            if (e->value.asm_tmpl.labels[i]) fputs(e->value.asm_tmpl.labels[i], out);
        }
    }
    fputc(')', out);
}

static int codegen_expr(const struct ASTExpr *e, FILE *out) {
    if (!e || !out) return -1;
    /* CTFE 最小集：仅当表达式类型为标量（整型/布尔/浮点）时才用 const_folded_val；struct 等类型不能当整数输出，否则会生成 return -1094795586 等错误 */
    if (e->const_folded_valid && expr_type_is_foldable_scalar(e)) {
#ifdef SHUX_USE_X_CODEGEN
        if (codegen_codegen_x_format_int_lit((uint8_t *)out, (int32_t)e->const_folded_val) != 0) return -1;
        return 0;
#else
        if (e->resolved_type && (e->resolved_type->kind == AST_TYPE_I64 || e->resolved_type->kind == AST_TYPE_USIZE || e->resolved_type->kind == AST_TYPE_ISIZE || e->resolved_type->kind == AST_TYPE_U64))
            fprintf(out, "%lld", (long long)e->const_folded_val);
        else
            fprintf(out, "%d", (int)e->const_folded_val);
        return 0;
#endif
    }
    switch (e->kind) {
        case AST_EXPR_LIT:
#ifdef SHUX_USE_X_CODEGEN
            /* 整数字面量输出由 .x 侧 codegen_x_format_int_lit 实现（自举 codegen 首块迁入）。 */
            if (codegen_codegen_x_format_int_lit((uint8_t *)out, (int32_t)e->value.int_val) != 0) return -1;
            return 0;
#else
            if (e->resolved_type && (e->resolved_type->kind == AST_TYPE_I64 || e->resolved_type->kind == AST_TYPE_USIZE || e->resolved_type->kind == AST_TYPE_ISIZE || e->resolved_type->kind == AST_TYPE_U64))
                fprintf(out, "%lld", (long long)e->value.int_val);
            else
                fprintf(out, "%d", (int)e->value.int_val);
            return 0;
#endif
        case AST_EXPR_FLOAT_LIT: {
#ifdef SHUX_USE_X_CODEGEN
            int is_f32 = (e->resolved_type && e->resolved_type->kind == AST_TYPE_F32) ? 1 : 0;
            if (codegen_codegen_x_emit_float_lit((uint8_t *)out, (uint8_t *)&e->value.float_val, is_f32) != 0) return -1;
            return 0;
#else
            double v = e->value.float_val;
            if (v == 0.0)
                fprintf(out, e->resolved_type && e->resolved_type->kind == AST_TYPE_F32 ? "0.0f" : "0.0");
            else if (e->resolved_type && e->resolved_type->kind == AST_TYPE_F32)
                fprintf(out, "%gf", v);
            else
                fprintf(out, "%g", v);
            return 0;
#endif
        }
        case AST_EXPR_BOOL_LIT:
#ifdef SHUX_USE_X_CODEGEN
            /* 布尔字面量输出由 .x 侧 codegen_x_format_bool_lit 实现。 */
            if (codegen_codegen_x_format_bool_lit((uint8_t *)out, e->value.int_val ? 1 : 0) != 0) return -1;
            return 0;
#else
            fprintf(out, "%d", e->value.int_val ? 1 : 0);
            return 0;
#endif
        case AST_EXPR_STRING_LIT: {
            /* 字符串字面量：生成 C 字符串 "..."（转义 " \ \n \t 等）；作为 *u8 指针传递 */
            fprintf(out, "\"");
            const char *s = e->value.string_lit.bytes;
            int slen = e->value.string_lit.len;
            for (int i = 0; i < slen; i++) {
                unsigned char c = (unsigned char)s[i];
                switch (c) {
                    case '"': fprintf(out, "\\\""); break;
                    case '\\': fprintf(out, "\\\\"); break;
                    case '\n': fprintf(out, "\\n"); break;
                    case '\r': fprintf(out, "\\r"); break;
                    case '\t': fprintf(out, "\\t"); break;
                    case '\0': fprintf(out, "\\0"); break;
                    default:
                        if (c >= 0x20 && c < 0x7f) fprintf(out, "%c", c);
                        else fprintf(out, "\\x%02x", c);
                }
            }
            fprintf(out, "\"");
            return 0;
        }
        case AST_EXPR_ASM:
            /* asm! 作为值表达式少见；extended asm 形态由 codegen_emit_asm_extended 统一发射。 */
            codegen_emit_asm_extended(out, e);
            return 0;
        case AST_EXPR_VAR: {
            const char *name = e->value.var.name ? e->value.var.name : "";
#ifdef SHUX_USE_X_CODEGEN
            /* 变量名输出由 .x 侧 codegen_x_emit_c_string 逐字节实现。 */
            if (codegen_codegen_x_emit_c_string((uint8_t *)out, (uint8_t *)name, (int32_t)strlen(name)) != 0) return -1;
            return 0;
#else
            /* 库模块 -E 时顶层 let/const 已带前缀输出，此处引用须一致 */
            if (codegen_library_prefix && *codegen_library_prefix && codegen_library_module && codegen_current_module == codegen_library_module
                && codegen_current_module->top_level_lets) {
                for (int i = 0; i < codegen_current_module->num_top_level_lets; i++) {
                    if (codegen_current_module->top_level_lets[i].name && strcmp(codegen_current_module->top_level_lets[i].name, name) == 0) {
                        char buf[256];
                        library_prefixed_name(name, buf, sizeof(buf));
                        fprintf(out, "%s", buf);
                        return 0;
                    }
                }
            }
            /* 无名或首字符为空格时：若当前函数恰有一个无名/空格名形参，用其占位名 _p0/_p1 等，否则用 _0，避免未声明的 _。 */
            if (!name[0] || (unsigned char)name[0] <= ' ') {
                int empty_param_index = -1;
                int empty_param_count = 0;
                if (codegen_current_func && codegen_current_func->params) {
                    for (int i = 0; i < codegen_current_func->num_params; i++) {
                        const char *pn = codegen_current_func->params[i].name;
                        if (!pn || !pn[0] || (unsigned char)pn[0] <= ' ') {
                            empty_param_count++;
                            empty_param_index = i;
                        }
                    }
                }
                if (empty_param_count == 1 && empty_param_index >= 0) {
                    fprintf(out, "_p%d", empty_param_index);
                } else {
                    fprintf(out, "_0");
                }
            } else {
                fprintf(out, "%s", name);
            }
            return 0;
#endif
        }
        case AST_EXPR_ENUM_VARIANT: {
            /* C 中枚举值为 EnumName_VariantName；跨模块或库模块时加 prefix；结果写入 buf 后由 .x emit_c_string 或 fprintf 输出。 */
            const char *en = e->value.enum_variant.enum_name ? e->value.enum_variant.enum_name : "";
            const char *vn = e->value.enum_variant.variant_name ? e->value.enum_variant.variant_name : "";
            char enum_buf[256];
            int n = 0;
            if (!codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths && en[0]) {
                for (int di = 0; di < codegen_ndep; di++) {
                    const struct ASTModule *d = codegen_dep_mods[di];
                    if (!d || !d->enum_defs) continue;
                    for (int ej = 0; ej < d->num_enums; ej++)
                        if (d->enum_defs[ej]->name && strcmp(d->enum_defs[ej]->name, en) == 0) {
                            char pre[256];
                            import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                            n = snprintf(enum_buf, sizeof(enum_buf), "%s%s_%s", pre, en, vn);
                            goto enum_emit;
                        }
                }
            }
            if (codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths && en[0]) {
                for (int di = 0; di < codegen_ndep; di++) {
                    const struct ASTModule *d = codegen_dep_mods[di];
                    if (!d || !d->enum_defs) continue;
                    for (int ej = 0; ej < d->num_enums; ej++)
                        if (d->enum_defs[ej]->name && strcmp(d->enum_defs[ej]->name, en) == 0) {
                            char pre[256];
                            import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                            n = snprintf(enum_buf, sizeof(enum_buf), "%s%s_%s", pre, en, vn);
                            goto enum_emit;
                        }
                }
            }
            if (codegen_library_prefix && *codegen_library_prefix && en[0])
                n = snprintf(enum_buf, sizeof(enum_buf), "%s%s_%s", codegen_library_prefix, en, vn);
            else
                n = snprintf(enum_buf, sizeof(enum_buf), "%s_%s", en, vn);
        enum_emit:
            if (n <= 0 || (size_t)n >= sizeof(enum_buf)) n = 0;
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_c_string((uint8_t *)out, (uint8_t *)enum_buf, (int32_t)n) != 0) return -1;
            return 0;
#else
            fprintf(out, "%s", enum_buf);
            return 0;
#endif
        }
        case AST_EXPR_ADD: {
            if (codegen_vector_binop(e, "+", out) == 0) return 0;
            const struct ASTExpr *l = e->value.binop.left, *r = e->value.binop.right;
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " + "; int nl = codegen_x_expr_needs_compare_parens((uint8_t *)l); int nr = codegen_x_expr_needs_compare_parens((uint8_t *)r); if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)l, (uint8_t *)r, (uint8_t *)op, 3, nl, nr) != 0) return -1; return 0; }
#else
            { int need_l = codegen_c_need_paren_additive_child(l); int need_r = codegen_c_need_paren_additive_child(r); if (need_l) fprintf(out, "("); if (codegen_expr(l, out) != 0) return -1; if (need_l) fprintf(out, ")"); fprintf(out, " + "); if (need_r) fprintf(out, "("); if (codegen_expr(r, out) != 0) return -1; if (need_r) fprintf(out, ")"); return 0; }
#endif
        }
        case AST_EXPR_SUB: {
            if (codegen_vector_binop(e, "-", out) == 0) return 0;
            const struct ASTExpr *l = e->value.binop.left, *r = e->value.binop.right;
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " - "; int nl = codegen_x_expr_needs_compare_parens((uint8_t *)l); int nr = codegen_x_expr_needs_compare_parens((uint8_t *)r); if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)l, (uint8_t *)r, (uint8_t *)op, 3, nl, nr) != 0) return -1; return 0; }
#else
            { int need_l = codegen_c_need_paren_additive_child(l); int need_r = codegen_c_need_paren_additive_child(r); if (need_l) fprintf(out, "("); if (codegen_expr(l, out) != 0) return -1; if (need_l) fprintf(out, ")"); fprintf(out, " - "); if (need_r) fprintf(out, "("); if (codegen_expr(r, out) != 0) return -1; if (need_r) fprintf(out, ")"); return 0; }
#endif
        }
        case AST_EXPR_MUL: {
            if (codegen_vector_binop(e, "*", out) == 0) return 0;
            const struct ASTExpr *l = e->value.binop.left, *r = e->value.binop.right;
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " * "; int nl = codegen_x_expr_needs_addsub_parens((uint8_t *)l); int nr = codegen_x_expr_needs_addsub_parens((uint8_t *)r); if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)l, (uint8_t *)r, (uint8_t *)op, 3, nl, nr) != 0) return -1; return 0; }
#else
            { int need_l = (l->kind == AST_EXPR_ADD || l->kind == AST_EXPR_SUB); int need_r = (r->kind == AST_EXPR_ADD || r->kind == AST_EXPR_SUB); if (need_l) fprintf(out, "("); if (codegen_expr(l, out) != 0) return -1; if (need_l) fprintf(out, ")"); fprintf(out, " * "); if (need_r) fprintf(out, "("); if (codegen_expr(r, out) != 0) return -1; if (need_r) fprintf(out, ")"); return 0; }
#endif
        }
        case AST_EXPR_DIV: {
            if (codegen_vector_binop(e, "/", out) == 0) return 0;
            const struct ASTExpr *l = e->value.binop.left, *r = e->value.binop.right;
#ifdef SHUX_USE_X_CODEGEN
            { int is_int = (e->resolved_type && is_integer_type(e->resolved_type)) ? 1 : 0; if (codegen_codegen_x_emit_div_expr((uint8_t *)out, (uint8_t *)l, (uint8_t *)r, is_int) != 0) return -1; return 0; }
#else
            /* 整数除零：运行时检查，除数为 0 时 panic（UB 收窄为定义行为，见 UB与未定义行为.md） */
            if (e->resolved_type && is_integer_type(e->resolved_type)) {
                int need_l = (l->kind == AST_EXPR_ADD || l->kind == AST_EXPR_SUB);
                int need_r = (r->kind == AST_EXPR_ADD || r->kind == AST_EXPR_SUB);
                fprintf(out, "(");
                if (need_r) fprintf(out, "(");
                if (codegen_expr(r, out) != 0) return -1;
                if (need_r) fprintf(out, ")");
                fprintf(out, " == 0 ? (shux_panic_(1, 0), ");
                if (need_l) fprintf(out, "(");
                if (codegen_expr(l, out) != 0) return -1;
                if (need_l) fprintf(out, ")");
                fprintf(out, ") : (");
                if (need_l) fprintf(out, "(");
                if (codegen_expr(l, out) != 0) return -1;
                if (need_l) fprintf(out, ")");
                fprintf(out, " / ");
                if (need_r) fprintf(out, "(");
                if (codegen_expr(r, out) != 0) return -1;
                if (need_r) fprintf(out, ")");
                fprintf(out, "))");
                return 0;
            }
            int need_l = (l->kind == AST_EXPR_ADD || l->kind == AST_EXPR_SUB);
            int need_r = (r->kind == AST_EXPR_ADD || r->kind == AST_EXPR_SUB);
            if (need_l) fprintf(out, "(");
            if (codegen_expr(l, out) != 0) return -1;
            if (need_l) fprintf(out, ")");
            fprintf(out, " / ");
            if (need_r) fprintf(out, "(");
            if (codegen_expr(r, out) != 0) return -1;
            if (need_r) fprintf(out, ")");
            return 0;
#endif
        }
        case AST_EXPR_MOD: {
            if (codegen_vector_binop(e, "%%", out) == 0) return 0;
            const struct ASTExpr *l = e->value.binop.left, *r = e->value.binop.right;
#ifdef SHUX_USE_X_CODEGEN
            { int is_int = (e->resolved_type && is_integer_type(e->resolved_type)) ? 1 : 0; if (codegen_codegen_x_emit_mod_expr((uint8_t *)out, (uint8_t *)l, (uint8_t *)r, is_int) != 0) return -1; return 0; }
#else
            /* 整数取模零：运行时检查（UB 收窄为定义行为） */
            if (e->resolved_type && is_integer_type(e->resolved_type)) {
                fprintf(out, "(");
                if (codegen_expr(r, out) != 0) return -1;
                fprintf(out, " == 0 ? (shux_panic_(1, 0), ");
                if (codegen_expr(l, out) != 0) return -1;
                fprintf(out, ") : (");
                if (codegen_expr(l, out) != 0) return -1;
                fprintf(out, " %% ");
                if (codegen_expr(r, out) != 0) return -1;
                fprintf(out, "))");
                return 0;
            }
            if (codegen_expr(l, out) != 0) return -1;
            fprintf(out, " %% ");
            if (codegen_expr(r, out) != 0) return -1;
            return 0;
#endif
        }
        case AST_EXPR_SHL:
            if (codegen_vector_binop(e, "<<", out) == 0) return 0;
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " << "; if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right, (uint8_t *)op, 4, 0, 0) != 0) return -1; return 0; }
#else
            if (codegen_expr(e->value.binop.left, out) != 0) return -1;
            fprintf(out, " << ");
            if (codegen_expr(e->value.binop.right, out) != 0) return -1;
            return 0;
#endif
        case AST_EXPR_SHR:
            if (codegen_vector_binop(e, ">>", out) == 0) return 0;
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " >> "; if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right, (uint8_t *)op, 4, 0, 0) != 0) return -1; return 0; }
#else
            if (codegen_expr(e->value.binop.left, out) != 0) return -1;
            fprintf(out, " >> ");
            if (codegen_expr(e->value.binop.right, out) != 0) return -1;
            return 0;
#endif
        case AST_EXPR_BITAND:
            if (codegen_vector_binop(e, "&", out) == 0) return 0;
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " & "; if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right, (uint8_t *)op, 3, 0, 0) != 0) return -1; return 0; }
#else
            { int need_l = codegen_c_need_paren_bitwise_child(AST_EXPR_BITAND, e->value.binop.left); int need_r = codegen_c_need_paren_bitwise_child(AST_EXPR_BITAND, e->value.binop.right); if (need_l) fprintf(out, "("); if (codegen_expr(e->value.binop.left, out) != 0) return -1; if (need_l) fprintf(out, ")"); fprintf(out, " & "); if (need_r) fprintf(out, "("); if (codegen_expr(e->value.binop.right, out) != 0) return -1; if (need_r) fprintf(out, ")"); return 0; }
#endif
        case AST_EXPR_BITOR:
            if (codegen_vector_binop(e, "|", out) == 0) return 0;
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " | "; if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right, (uint8_t *)op, 3, 0, 0) != 0) return -1; return 0; }
#else
            { int need_l = codegen_c_need_paren_bitwise_child(AST_EXPR_BITOR, e->value.binop.left); int need_r = codegen_c_need_paren_bitwise_child(AST_EXPR_BITOR, e->value.binop.right); if (need_l) fprintf(out, "("); if (codegen_expr(e->value.binop.left, out) != 0) return -1; if (need_l) fprintf(out, ")"); fprintf(out, " | "); if (need_r) fprintf(out, "("); if (codegen_expr(e->value.binop.right, out) != 0) return -1; if (need_r) fprintf(out, ")"); return 0; }
#endif
        case AST_EXPR_BITXOR:
            if (codegen_vector_binop(e, "^", out) == 0) return 0;
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " ^ "; if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right, (uint8_t *)op, 3, 0, 0) != 0) return -1; return 0; }
#else
            { int need_l = codegen_c_need_paren_bitwise_child(AST_EXPR_BITXOR, e->value.binop.left); int need_r = codegen_c_need_paren_bitwise_child(AST_EXPR_BITXOR, e->value.binop.right); if (need_l) fprintf(out, "("); if (codegen_expr(e->value.binop.left, out) != 0) return -1; if (need_l) fprintf(out, ")"); fprintf(out, " ^ "); if (need_r) fprintf(out, "("); if (codegen_expr(e->value.binop.right, out) != 0) return -1; if (need_r) fprintf(out, ")"); return 0; }
#endif
        case AST_EXPR_ASSIGN:
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_assign((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right) != 0) return -1;
            return 0;
#else
            /* 赋值表达式：左端为 FIELD_ACCESS(INDEX) 或 INDEX 时生成可赋值的边界检查形式，避免 (ternary)=z 非左值 */
            fprintf(out, "(");
            if (codegen_assign_field_index_lvalue(out, e->value.binop.left, e->value.binop.right) == 0) {
                fprintf(out, ")");
                return 0;
            }
            if (codegen_assign_index_lvalue(out, e->value.binop.left, e->value.binop.right) == 0) {
                fprintf(out, ")");
                return 0;
            }
            if (codegen_expr(e->value.binop.left, out) != 0) return -1;
            fprintf(out, " = (");
            if (codegen_expr(e->value.binop.right, out) != 0) return -1;
            fprintf(out, "))");
            return 0;
#endif
        case AST_EXPR_ADD_ASSIGN: case AST_EXPR_SUB_ASSIGN: case AST_EXPR_MUL_ASSIGN: case AST_EXPR_DIV_ASSIGN: case AST_EXPR_MOD_ASSIGN:
        case AST_EXPR_BITAND_ASSIGN: case AST_EXPR_BITOR_ASSIGN: case AST_EXPR_BITXOR_ASSIGN: case AST_EXPR_SHL_ASSIGN: case AST_EXPR_SHR_ASSIGN: {
            const char *op = "=";
            switch (e->kind) {
                case AST_EXPR_ADD_ASSIGN: op = "+="; break;
                case AST_EXPR_SUB_ASSIGN: op = "-="; break;
                case AST_EXPR_MUL_ASSIGN: op = "*="; break;
                case AST_EXPR_DIV_ASSIGN: op = "/="; break;
                case AST_EXPR_MOD_ASSIGN: op = "%="; break;
                case AST_EXPR_BITAND_ASSIGN: op = "&="; break;
                case AST_EXPR_BITOR_ASSIGN: op = "|="; break;
                case AST_EXPR_BITXOR_ASSIGN: op = "^="; break;
                case AST_EXPR_SHL_ASSIGN: op = "<<="; break;
                case AST_EXPR_SHR_ASSIGN: op = ">>="; break;
                default: break;
            }
            /* 复合赋值：与 ASSIGN 相同可做 field/index 特例时用 op 版本，否则 (left op right) */
            fprintf(out, "(");
            if (codegen_assign_field_index_lvalue_op(out, e->value.binop.left, e->value.binop.right, op) == 0) {
                fprintf(out, ")");
                return 0;
            }
            if (codegen_assign_index_lvalue_op(out, e->value.binop.left, e->value.binop.right, op) == 0) {
                fprintf(out, ")");
                return 0;
            }
            if (codegen_expr(e->value.binop.left, out) != 0) return -1;
            fprintf(out, " %s ", op);
            if (codegen_expr(e->value.binop.right, out) != 0) return -1;
            fprintf(out, ")");
            return 0;
        }
        case AST_EXPR_EQ:
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " == "; if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right, (uint8_t *)op, 4, 0, 0) != 0) return -1; return 0; }
#else
            { int need_l = codegen_c_need_paren_compare_child(e->value.binop.left); int need_r = codegen_c_need_paren_compare_child(e->value.binop.right); if (need_l) fprintf(out, "("); if (codegen_expr(e->value.binop.left, out) != 0) return -1; if (need_l) fprintf(out, ")"); fprintf(out, " == "); if (need_r) fprintf(out, "("); if (codegen_expr(e->value.binop.right, out) != 0) return -1; if (need_r) fprintf(out, ")"); return 0; }
#endif
        case AST_EXPR_NE:
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " != "; if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right, (uint8_t *)op, 4, 0, 0) != 0) return -1; return 0; }
#else
            { int need_l = codegen_c_need_paren_compare_child(e->value.binop.left); int need_r = codegen_c_need_paren_compare_child(e->value.binop.right); if (need_l) fprintf(out, "("); if (codegen_expr(e->value.binop.left, out) != 0) return -1; if (need_l) fprintf(out, ")"); fprintf(out, " != "); if (need_r) fprintf(out, "("); if (codegen_expr(e->value.binop.right, out) != 0) return -1; if (need_r) fprintf(out, ")"); return 0; }
#endif
        case AST_EXPR_LT:
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " < "; if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right, (uint8_t *)op, 3, 0, 0) != 0) return -1; return 0; }
#else
            { int need_l = codegen_c_need_paren_compare_child(e->value.binop.left); int need_r = codegen_c_need_paren_compare_child(e->value.binop.right); if (need_l) fprintf(out, "("); if (codegen_expr(e->value.binop.left, out) != 0) return -1; if (need_l) fprintf(out, ")"); fprintf(out, " < "); if (need_r) fprintf(out, "("); if (codegen_expr(e->value.binop.right, out) != 0) return -1; if (need_r) fprintf(out, ")"); return 0; }
#endif
        case AST_EXPR_LE:
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " <= "; if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right, (uint8_t *)op, 4, 0, 0) != 0) return -1; return 0; }
#else
            { int need_l = codegen_c_need_paren_compare_child(e->value.binop.left); int need_r = codegen_c_need_paren_compare_child(e->value.binop.right); if (need_l) fprintf(out, "("); if (codegen_expr(e->value.binop.left, out) != 0) return -1; if (need_l) fprintf(out, ")"); fprintf(out, " <= "); if (need_r) fprintf(out, "("); if (codegen_expr(e->value.binop.right, out) != 0) return -1; if (need_r) fprintf(out, ")"); return 0; }
#endif
        case AST_EXPR_GT:
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " > "; if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right, (uint8_t *)op, 3, 0, 0) != 0) return -1; return 0; }
#else
            { int need_l = codegen_c_need_paren_compare_child(e->value.binop.left); int need_r = codegen_c_need_paren_compare_child(e->value.binop.right); if (need_l) fprintf(out, "("); if (codegen_expr(e->value.binop.left, out) != 0) return -1; if (need_l) fprintf(out, ")"); fprintf(out, " > "); if (need_r) fprintf(out, "("); if (codegen_expr(e->value.binop.right, out) != 0) return -1; if (need_r) fprintf(out, ")"); return 0; }
#endif
        case AST_EXPR_GE:
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " >= "; if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right, (uint8_t *)op, 4, 0, 0) != 0) return -1; return 0; }
#else
            { int need_l = codegen_c_need_paren_compare_child(e->value.binop.left); int need_r = codegen_c_need_paren_compare_child(e->value.binop.right); if (need_l) fprintf(out, "("); if (codegen_expr(e->value.binop.left, out) != 0) return -1; if (need_l) fprintf(out, ")"); fprintf(out, " >= "); if (need_r) fprintf(out, "("); if (codegen_expr(e->value.binop.right, out) != 0) return -1; if (need_r) fprintf(out, ")"); return 0; }
#endif
        case AST_EXPR_LOGAND:
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " && "; if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right, (uint8_t *)op, 4, 0, 0) != 0) return -1; return 0; }
#else
            if (codegen_expr(e->value.binop.left, out) != 0) return -1;
            fprintf(out, " && ");
            if (codegen_expr(e->value.binop.right, out) != 0) return -1;
            return 0;
#endif
        case AST_EXPR_LOGOR:
#ifdef SHUX_USE_X_CODEGEN
            { static const char op[] = " || "; if (codegen_codegen_x_emit_binop((uint8_t *)out, (uint8_t *)e->value.binop.left, (uint8_t *)e->value.binop.right, (uint8_t *)op, 4, 0, 0) != 0) return -1; return 0; }
#else
            if (codegen_expr(e->value.binop.left, out) != 0) return -1;
            fprintf(out, " || ");
            if (codegen_expr(e->value.binop.right, out) != 0) return -1;
            return 0;
#endif
        case AST_EXPR_NEG:
#ifdef SHUX_USE_X_CODEGEN
            { static const char pre[] = "(-"; if (codegen_codegen_x_emit_unary((uint8_t *)out, (uint8_t *)e->value.unary.operand, (uint8_t *)pre, 2) != 0) return -1; return 0; }
#else
            fprintf(out, "(-");
            if (codegen_expr(e->value.unary.operand, out) != 0) return -1;
            fprintf(out, ")");
            return 0;
#endif
        case AST_EXPR_BITNOT:
#ifdef SHUX_USE_X_CODEGEN
            { static const char pre[] = "(~"; if (codegen_codegen_x_emit_unary((uint8_t *)out, (uint8_t *)e->value.unary.operand, (uint8_t *)pre, 2) != 0) return -1; return 0; }
#else
            fprintf(out, "(~");
            if (codegen_expr(e->value.unary.operand, out) != 0) return -1;
            fprintf(out, ")");
            return 0;
#endif
        case AST_EXPR_LOGNOT:
#ifdef SHUX_USE_X_CODEGEN
            { static const char pre[] = "(!"; if (codegen_codegen_x_emit_unary((uint8_t *)out, (uint8_t *)e->value.unary.operand, (uint8_t *)pre, 2) != 0) return -1; return 0; }
#else
            fprintf(out, "(!");
            if (codegen_expr(e->value.unary.operand, out) != 0) return -1;
            fprintf(out, ")");
            return 0;
#endif
        case AST_EXPR_ADDR_OF: {
            /* &v as *T 解析为 &(v as *T)：AS 已对向量/结构体 lvalue 生成 (T)&v，勿再包一层 &。 */
            const struct ASTExpr *op = e->value.unary.operand;
            if (op && op->kind == AST_EXPR_AS) {
                const struct ASTType *cast_ty = op->value.as_type.type;
                const struct ASTExpr *inner = op->value.as_type.operand;
                if (cast_ty && cast_ty->kind == AST_TYPE_PTR && inner && inner->resolved_type
                    && (inner->resolved_type->kind == AST_TYPE_VECTOR
                        || inner->resolved_type->kind == AST_TYPE_ARRAY
                        || inner->resolved_type->kind == AST_TYPE_NAMED)
                    && inner->kind != AST_EXPR_ADDR_OF) {
                    return codegen_expr(op, out);
                }
            }
            /* 取址操作数为 INDEX 且带边界检查时，避免 &(ternary) 在 C 中非法（三元结果为 rvalue）；改为 越界?panic:&(base)[idx] */
            if (op && op->kind == AST_EXPR_INDEX && !op->index_proven_in_bounds && op->value.index.base) {
                const struct ASTExpr *base = op->value.index.base;
                const struct ASTExpr *idx = op->value.index.index_expr;
                const struct ASTType *base_ty = base ? base->resolved_type : NULL;
                if (base_ty && base_ty->kind == AST_TYPE_ARRAY && base_ty->array_size > 0) {
                    int n = (int)base_ty->array_size;
                    fprintf(out, "(");
                    if (codegen_expr(idx, out) != 0) return -1;
                    fprintf(out, " < 0 || (");
                    if (codegen_expr(idx, out) != 0) return -1;
                    fprintf(out, ") >= %d ? (shux_panic_(1, 0), &(", n);
                    if (codegen_expr(base, out) != 0) return -1;
                    fprintf(out, ")[0]) : &(");
                    if (codegen_expr(base, out) != 0) return -1;
                    fprintf(out, ")[");
                    if (codegen_expr(idx, out) != 0) return -1;
                    fprintf(out, "])");
                    return 0;
                }
            }
            fprintf(out, "(&(");
            if (codegen_expr(e->value.unary.operand, out) != 0) return -1;
            fprintf(out, "))");
            return 0;
        }
        case AST_EXPR_DEREF: {
            /* 解引用 *expr → C 的 (*(expr)) */
            fprintf(out, "(*(");
            if (codegen_expr(e->value.unary.operand, out) != 0) return -1;
            fprintf(out, "))");
            return 0;
        }
        case AST_EXPR_TRY_PROPAGATE: {
            /* Result `?`：({ Result_T tmp = op; if (tmp.err != 0) { return tmp; } tmp.value; }) */
            const struct ASTExpr *op = e->value.unary.operand;
            char op_ty_buf[128];
            if (!op || !op->resolved_type) return -1;
            c_type_to_buf(op->resolved_type, op_ty_buf, sizeof(op_ty_buf));
            fprintf(out, "(({ %s __shux_try_tmp = ", op_ty_buf);
            if (codegen_expr(op, out) != 0) return -1;
            if (codegen_try_active) {
                fprintf(out, "; if ((__shux_try_tmp).err != 0) { %s = __shux_try_tmp; goto %s; } (__shux_try_tmp).value; }))",
                    codegen_try_r_var, codegen_try_catch_label);
            } else {
                fprintf(out, "; if ((__shux_try_tmp).err != 0) { return __shux_try_tmp; } (__shux_try_tmp).value; }))");
            }
            return 0;
        }
        case AST_EXPR_AWAIT:
            /* A3 同步 stub：暂等同 eval operand，无 suspend/resume（CPS 待后续） */
            return codegen_expr(e->value.unary.operand, out);
        case AST_EXPR_RUN: {
            /* A4/run v4：run async_fn(...) → seed 队列 + shux_async_sched_<name>() */
            const struct ASTExpr *op = e->value.unary.operand;
            const struct ASTFunc *af;
            int ai;
            if (!op || op->kind != AST_EXPR_CALL || !op->value.call.resolved_callee_func)
                return -1;
            af = op->value.call.resolved_callee_func;
            if (!af->name || !af->is_async)
                return -1;
            if (op->value.call.num_args > 0) {
                fprintf(out, "(shux_async_run_seed_reset()");
                for (ai = 0; ai < op->value.call.num_args; ai++) {
                    const struct ASTExpr *a = op->value.call.args[ai];
                    const struct ASTType *pty = (ai < af->num_params) ? af->params[ai].type : NULL;
                    if (!a)
                        return -1;
                    fprintf(out, ", %s(", codegen_run_seed_push_fn(pty));
                    if (codegen_expr(a, out) != 0) return -1;
                    fprintf(out, ")");
                }
                fprintf(out, ", shux_async_sched_%s())", af->name);
            } else {
                fprintf(out, "shux_async_sched_%s()", af->name);
            }
            return 0;
        }
        case AST_EXPR_SPAWN: {
            /* IO-A5 v4：spawn async_fn(...) → push seed(s) + task_submit；多 spawn 共享 FIFO，按 submit 顺序取 seed。 */
            const struct ASTExpr *op = e->value.unary.operand;
            const struct ASTFunc *af;
            int ai;
            if (!op || op->kind != AST_EXPR_CALL || !op->value.call.resolved_callee_func)
                return -1;
            af = op->value.call.resolved_callee_func;
            if (!af->name || !af->is_async)
                return -1;
            if (op->value.call.num_args > 0) {
                for (ai = 0; ai < op->value.call.num_args; ai++) {
                    const struct ASTExpr *a = op->value.call.args[ai];
                    const struct ASTType *pty = (ai < af->num_params) ? af->params[ai].type : NULL;
                    if (!a)
                        return -1;
                    if (ai == 0)
                        fprintf(out, "(");
                    else
                        fprintf(out, ", ");
                    fprintf(out, "%s(", codegen_run_seed_push_fn(pty));
                    if (codegen_expr(a, out) != 0) return -1;
                    fprintf(out, ")");
                }
                fprintf(out, ", shux_async_task_submit((int32_t (*)(void))%s))", af->name);
            } else {
                fprintf(out, "shux_async_task_submit((int32_t (*)(void))%s)", af->name);
            }
            return 0;
        }
        case AST_EXPR_AS: {
            /* 类型转换 expr as type → C 的 (target_type)(expr)；向量/结构体 lvalue 转指针须 (T)&v。 */
            const struct ASTType *ty = e->value.as_type.type;
            const struct ASTExpr *op = e->value.as_type.operand;
            static char cast_buf[128];
            c_type_to_buf(ty, cast_buf, sizeof(cast_buf));
            if (ty && ty->kind == AST_TYPE_PTR && op && op->resolved_type
                && (op->resolved_type->kind == AST_TYPE_VECTOR
                    || op->resolved_type->kind == AST_TYPE_ARRAY
                    || op->resolved_type->kind == AST_TYPE_NAMED)
                && op->kind != AST_EXPR_ADDR_OF) {
                fprintf(out, "((%s)&(", cast_buf);
                if (codegen_expr(op, out) != 0) return -1;
                fprintf(out, "))");
                return 0;
            }
            fprintf(out, "((%s)(", cast_buf);
            if (codegen_expr(op, out) != 0) return -1;
            fprintf(out, "))");
            return 0;
        }
        case AST_EXPR_IF: {
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_if_expr((uint8_t *)out, (uint8_t *)e) != 0) return -1;
            return 0;
#else
            const struct ASTExpr *then_e = e->value.if_expr.then_expr;
            const struct ASTExpr *else_e = e->value.if_expr.else_expr;
            int then_is_block = (then_e && then_e->kind == AST_EXPR_BLOCK);
            int else_is_block = (else_e && else_e->kind == AST_EXPR_BLOCK);
            /* continue/break/return 不能作为表达式求值，需当作“块”生成 { continue; } 等 */
            int then_is_control = (then_e && (then_e->kind == AST_EXPR_CONTINUE || then_e->kind == AST_EXPR_BREAK || then_e->kind == AST_EXPR_RETURN));
            int else_is_control = (else_e && (else_e->kind == AST_EXPR_CONTINUE || else_e->kind == AST_EXPR_BREAK || else_e->kind == AST_EXPR_RETURN));
            then_is_block = then_is_block || then_is_control;
            else_is_block = else_is_block || else_is_control;
            /* then/else 任一为块（含 let/return）或控制流时用 GNU C 语句表达式 + 临时变量，否则用三元运算符 */
            if (then_is_block || else_is_block) {
                const struct ASTType *tmp_ty = e->resolved_type;
                /* 任一分支为表达式且类型为 struct 时，用该类型作 __tmp，避免 __tmp=(struct X){0} 赋给 int32_t */
                if (then_e && !then_is_block && then_e->resolved_type) {
                    const char *s = c_type_str(then_e->resolved_type);
                    if (s && strncmp(s, "struct ", 7) == 0) tmp_ty = then_e->resolved_type;
                }
                /* then 为块（如 if (ref<=0) { return Type{...}; }）且块类型为 struct 时也用上，避免 int __tmp；else 为 null 时赋 (struct X){0} */
                if (then_e && then_is_block && then_e->resolved_type) {
                    const char *s = c_type_str(then_e->resolved_type);
                    if (s && strncmp(s, "struct ", 7) == 0) tmp_ty = then_e->resolved_type;
                }
                /* else 为表达式且为 struct 时用 else 类型作 __tmp；但若 then 已为块且产出 struct（如 return LexerResult），则优先用 then 的类型，避免 __tmp=LexerResult 却赋 (Token){0} */
                if (else_e && !else_is_block && else_e->resolved_type) {
                    const char *s = c_type_str(else_e->resolved_type);
                    if (s && strncmp(s, "struct ", 7) == 0) {
                        const char *cur = tmp_ty ? c_type_str(tmp_ty) : NULL;
                        if (!cur || strncmp(cur, "struct ", 7) != 0 || !then_e || !then_is_block)
                            tmp_ty = else_e->resolved_type;
                    }
                }
                /* else 为嵌套 if 表达式（如 typeck 的 else if (!ref_is_null(ty_t)) { ... } else if (!ref_is_null(ty_e)) { ... }）时，取 else 的 resolved_type，否则会打成 int __tmp 却赋 (struct X){0}；同样不覆盖 then 块已给的 struct */
                if (else_e && else_e->kind == AST_EXPR_IF && else_e->resolved_type) {
                    const char *s = c_type_str(else_e->resolved_type);
                    if (s && strncmp(s, "struct ", 7) == 0) {
                        const char *cur = tmp_ty ? c_type_str(tmp_ty) : NULL;
                        if (!cur || strncmp(cur, "struct ", 7) != 0 || !then_e || !then_is_block)
                            tmp_ty = else_e->resolved_type;
                    }
                }
                const char *tmp_ty_str = tmp_ty ? c_type_str(tmp_ty) : "int32_t";
                /* else 为结构体字面量且 __tmp 类型尚非 struct 时，用 struct 名在 dep/本模块中推定 C 类型串。
                 * 但 then 为块且 tmp_ty 已来自 then（如 return LexerResult）时不要用 else（如 Token）覆盖，否则会生成 LexerResult __tmp = (Token){0}。 */
                if (else_e && !else_is_block && else_e->kind == AST_EXPR_STRUCT_LIT && else_e->value.struct_lit.struct_name
                    && strncmp(tmp_ty_str, "struct ", 7) != 0
                    && !(then_e && then_is_block && tmp_ty == then_e->resolved_type)) {
                    const char *sname = else_e->value.struct_lit.struct_name;
                    static char struct_fallback_ty_buf[128];
                    int found = 0;
                    if (codegen_current_module && codegen_current_module->struct_defs) {
                        for (int i = 0; i < codegen_current_module->num_structs; i++)
                            if (codegen_current_module->struct_defs[i]->name && strcmp(codegen_current_module->struct_defs[i]->name, sname) == 0) {
                                snprintf(struct_fallback_ty_buf, sizeof(struct_fallback_ty_buf), "struct %s", sname);
                                tmp_ty_str = struct_fallback_ty_buf;
                                found = 1;
                                break;
                            }
                    }
                    if (!found && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
                        for (int i = 0; i < codegen_ndep; i++) {
                            const struct ASTModule *d = codegen_dep_mods[i];
                            if (!d || !d->struct_defs) continue;
                            for (int j = 0; j < d->num_structs; j++)
                                if (d->struct_defs[j]->name && strcmp(d->struct_defs[j]->name, sname) == 0) {
                                    char pre[64];
                                    import_path_to_c_prefix(codegen_dep_paths[i], pre, sizeof(pre));
                                    snprintf(struct_fallback_ty_buf, sizeof(struct_fallback_ty_buf), "struct %s%s", pre, sname);
                                    tmp_ty_str = struct_fallback_ty_buf;
                                    found = 1;
                                    break;
                                }
                            if (found) break;
                        }
                    }
                    /* 仍未找到时用 else 的 resolved_type（如 (struct ast_Expr){0} / (struct ast_Type){0}），避免 __tmp 打成 int32_t */
                    if (!found && else_e->resolved_type) {
                        const char *s = c_type_str(else_e->resolved_type);
                        if (s && strncmp(s, "struct ", 7) == 0) {
                            snprintf(struct_fallback_ty_buf, sizeof(struct_fallback_ty_buf), "%s", s);
                            tmp_ty_str = struct_fallback_ty_buf;
                        }
                    }
                    /* typeck 可能未对 struct literal 设 resolved_type，用与发射时一致的 C 类型名推断（如 typeck 中 (Type){0} → struct ast_Type） */
                    if (strncmp(tmp_ty_str, "struct ", 7) != 0) {
                        static char struct_lit_ty_buf[128];
                        if (struct_lit_c_type_str(else_e, struct_lit_ty_buf, sizeof(struct_lit_ty_buf)))
                            tmp_ty_str = struct_lit_ty_buf;
                    }
                }
                /* else 为赋值且 RHS 为结构体字面量（如 (__tmp = (struct ast_Type){0})），从 RHS 推断 __tmp 类型 */
                if (else_e && !else_is_block && strncmp(tmp_ty_str, "struct ", 7) != 0
                    && else_e->kind == AST_EXPR_ASSIGN && else_e->value.binop.right
                    && else_e->value.binop.right->kind == AST_EXPR_STRUCT_LIT) {
                    const struct ASTExpr *rhs = else_e->value.binop.right;
                    if (rhs->resolved_type) {
                        const char *s = c_type_str(rhs->resolved_type);
                        if (s && strncmp(s, "struct ", 7) == 0) {
                            static char assign_rhs_ty_buf[128];
                            snprintf(assign_rhs_ty_buf, sizeof(assign_rhs_ty_buf), "%s", s);
                            tmp_ty_str = assign_rhs_ty_buf;
                        }
                    }
                    if (strncmp(tmp_ty_str, "struct ", 7) != 0 && rhs->value.struct_lit.struct_name) {
                        static char assign_struct_lit_buf[128];
                        if (struct_lit_c_type_str(rhs, assign_struct_lit_buf, sizeof(assign_struct_lit_buf)))
                            tmp_ty_str = assign_struct_lit_buf;
                    }
                }
                /* else 为块且块内仅 __tmp = (struct X){0} 时，从块内推断 __tmp 类型（如 backend EXPR_INDEX 路径） */
                if (else_e && else_is_block && strncmp(tmp_ty_str, "struct ", 7) != 0) {
                    const char *block_ty = struct_type_from_else_block(else_e);
                    if (block_ty) {
                        static char main_if_else_block_ty_buf[128];
                        snprintf(main_if_else_block_ty_buf, sizeof(main_if_else_block_ty_buf), "%s", block_ty);
                        tmp_ty_str = main_if_else_block_ty_buf;
                    }
                }
                /* 最后兜底：else 为嵌套 if 等时递归求其产生的 struct 类型（typeck 可能未设 resolved_type）；then 为块且 tmp_ty 已来自 then 时不覆盖 */
                if (else_e && strncmp(tmp_ty_str, "struct ", 7) != 0 && !(then_e && then_is_block && tmp_ty == then_e->resolved_type)) {
                    static char expr_struct_fallback_buf[128];
                    if (expr_struct_type_str(else_e, expr_struct_fallback_buf, sizeof(expr_struct_fallback_buf)))
                        tmp_ty_str = expr_struct_fallback_buf;
                }
                /* 无 else 且 then 为块（如 if (ref<=0) { return Type{...}; }）时从块内 return 操作数推断 __tmp 类型 */
                if (!else_e && then_e && then_is_block && strncmp(tmp_ty_str, "struct ", 7) != 0) {
                    static char then_block_struct_buf[128];
                    if (expr_struct_type_str(then_e, then_block_struct_buf, sizeof(then_block_struct_buf)))
                        tmp_ty_str = then_block_struct_buf;
                }
                /* c_type_str 对库模块 NAMED 可能返回 "prefix_Type" 无 "struct "，此处统一为 "struct prefix_Type" 以便 C 合法声明；若已是 "enum X" 则不要加 struct。 */
                if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) != 0 && strncmp(tmp_ty_str, "enum ", 5) != 0
                    && e->resolved_type && e->resolved_type->kind == AST_TYPE_NAMED) {
                    static char struct_named_buf[128];
                    snprintf(struct_named_buf, sizeof(struct_named_buf), "struct %s", tmp_ty_str);
                    tmp_ty_str = struct_named_buf;
                }
                /* 带初值避免 -Wuninitialized：标量用 0，struct 用 (type){0} */
                if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0)
                    fprintf(out, "({ %s __tmp = (%s){0}; if (", tmp_ty_str, tmp_ty_str);
                else
                    fprintf(out, "({ %s __tmp = 0; if (", tmp_ty_str ? tmp_ty_str : "int32_t");
                if (codegen_expr(e->value.if_expr.cond, out) != 0) return -1;
                fprintf(out, ") ");
                if (then_is_block) {
                    if (then_e->kind == AST_EXPR_BLOCK) {
                        fprintf(out, "{ ");
                        if (codegen_block_body(then_e->value.block, 2, out, 0, 0, "__tmp") != 0) return -1;
                        fprintf(out, " } ");
                    } else if (then_e->kind == AST_EXPR_CONTINUE) {
                        fprintf(out, "{ continue; } ");
                    } else if (then_e->kind == AST_EXPR_BREAK) {
                        fprintf(out, "{ break; } ");
                    } else if (then_e->kind == AST_EXPR_RETURN) {
                        /* return 在语句表达式内：先赋 __tmp 再 return（AST_EXPR_RETURN 用 value.unary.operand）；无操作数时 struct 用 (type){0} */
                        fprintf(out, "{ __tmp = ");
                        if (then_e->value.unary.operand && codegen_expr(then_e->value.unary.operand, out) != 0) return -1;
                        if (!then_e->value.unary.operand) {
                            if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0) fprintf(out, "(%s){0}", tmp_ty_str);
                            else fprintf(out, "0");
                        }
                        fprintf(out, "; return __tmp; } ");
                    } else {
                        fprintf(out, "(__tmp = ");
                        if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0 && !expr_produces_struct_type(then_e))
                            fprintf(out, "(%s){0}", tmp_ty_str);
                        else if (codegen_expr(then_e, out) != 0) return -1;
                        fprintf(out, ") ");
                    }
                } else {
                    fprintf(out, "(__tmp = ");
                    if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0 && !expr_produces_struct_type(then_e))
                        fprintf(out, "(%s){0}", tmp_ty_str);
                    else if (codegen_expr(then_e, out) != 0) return -1;
                    fprintf(out, ") ");
                }
                fprintf(out, "else ");
                if (else_is_block) {
                    if (else_e->kind == AST_EXPR_BLOCK) {
                        fprintf(out, "{ ");
                        if (codegen_block_body(else_e->value.block, 2, out, 0, 0, "__tmp") != 0) return -1;
                        fprintf(out, " } ");
                    } else if (else_e->kind == AST_EXPR_CONTINUE) {
                        fprintf(out, "{ continue; } ");
                    } else if (else_e->kind == AST_EXPR_BREAK) {
                        fprintf(out, "{ break; } ");
                    } else if (else_e->kind == AST_EXPR_RETURN) {
                        fprintf(out, "{ __tmp = ");
                        if (else_e->value.unary.operand && codegen_expr(else_e->value.unary.operand, out) != 0) return -1;
                        if (!else_e->value.unary.operand) {
                            if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0) fprintf(out, "(%s){0}", tmp_ty_str);
                            else fprintf(out, "0");
                        }
                        fprintf(out, "; return __tmp; } ");
                    } else {
                        fprintf(out, "(__tmp = ");
                        /* then 为块时 codegen_block_body 可能已覆盖静态缓冲区，用 then_e 重新推断 __tmp 类型到局部缓冲，保证 else 发射时类型正确（LexerResult vs Token）。优先从 then_e 推断，不依赖 tmp_ty_str。 */
                        char else_emit_ty_buf[128];
                        const char *else_emit_ty = tmp_ty_str;
                        if (then_e && then_is_block) {
                            if (expr_struct_type_str(then_e, else_emit_ty_buf, sizeof(else_emit_ty_buf)))
                                else_emit_ty = else_emit_ty_buf;
                            else if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0) {
                                snprintf(else_emit_ty_buf, sizeof(else_emit_ty_buf), "%s", tmp_ty_str);
                                else_emit_ty = else_emit_ty_buf;
                            }
                        }
                        if (else_e) {
                            /* __tmp 为 struct 时，若 else 类型与 else_emit_ty 不同则输出 (else_emit_ty){0}；先处理结构体字面量（struct_lit_c_type_str 可靠），再统一用 expr_struct_type_str。
                             * LexerResult vs Token：else_emit_ty 可能无 "struct " 前缀（如 lexer_LexerResult），用 strstr 判 LexerResult 且 else 的 C 类型含 Token 则输出 (else_emit_ty){0}；若无前缀则用 "struct "+else_emit_ty。 */
                            if (else_emit_ty && else_e->kind == AST_EXPR_STRUCT_LIT) {
                                static char else_lit_ty[128];
                                const char *else_ctype = struct_lit_c_type_str(else_e, else_lit_ty, sizeof(else_lit_ty));
                                int lexer_result_else_token = (strstr(else_emit_ty, "LexerResult") != NULL && else_ctype && strstr(else_ctype, "Token") != NULL);
                                if (lexer_result_else_token) {
                                    if (strncmp(else_emit_ty, "struct ", 7) == 0) fprintf(out, "(%s){0}", else_emit_ty);
                                    else { static char struct_lex_buf[128]; snprintf(struct_lex_buf, sizeof(struct_lex_buf), "struct %s", else_emit_ty); fprintf(out, "(%s){0}", struct_lex_buf); }
                                } else if (strncmp(else_emit_ty, "struct ", 7) == 0 && else_ctype && strcmp(else_ctype, else_emit_ty) != 0) {
                                    fprintf(out, "(%s){0}", else_emit_ty);
                                } else if (else_struct_type_mismatch(else_emit_ty, else_e))
                                    fprintf(out, "(%s){0}", else_emit_ty);
                                else if (codegen_expr(else_e, out) != 0) return -1;
                            } else {
                                static char else_ty_any[128];
                                const char *else_ty_ptr = expr_struct_type_str(else_e, else_ty_any, sizeof(else_ty_any));
                                if (else_emit_ty && strncmp(else_emit_ty, "struct ", 7) == 0 && else_ty_ptr && strcmp(else_ty_ptr, else_emit_ty) != 0) {
                                    fprintf(out, "(%s){0}", else_emit_ty);
                                } else if (else_emit_ty && else_struct_type_mismatch(else_emit_ty, else_e))
                                    fprintf(out, "(%s){0}", else_emit_ty);
                                else if (codegen_expr(else_e, out) != 0) return -1;
                            }
                        } else {
                            if (else_emit_ty && strncmp(else_emit_ty, "struct ", 7) == 0)
                                fprintf(out, "(%s){0}", else_emit_ty);
                            else if (then_e && then_is_block) {
                                if (else_emit_ty && strstr(else_emit_ty, "LexerResult")) {
                                    static char struct_lex_buf0[128];
                                    snprintf(struct_lex_buf0, sizeof(struct_lex_buf0), "struct %s", else_emit_ty);
                                    fprintf(out, "(%s){0}", struct_lex_buf0);
                                } else if (expr_struct_type_str(then_e, else_emit_ty_buf, sizeof(else_emit_ty_buf)))
                                    fprintf(out, "(%s){0}", else_emit_ty_buf);
                                else
                                    fprintf(out, "0");
                            } else
                                fprintf(out, "0");
                        }
                        fprintf(out, ") ");
                    }
                } else {
                    fprintf(out, "(__tmp = ");
                    /* 同上：then 为块时优先从 then_e 重算类型到局部缓冲 */
                    char else_emit_ty_buf2[128];
                    const char *else_emit_ty2 = tmp_ty_str;
                    if (then_e && then_is_block) {
                        if (expr_struct_type_str(then_e, else_emit_ty_buf2, sizeof(else_emit_ty_buf2)))
                            else_emit_ty2 = else_emit_ty_buf2;
                        else if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0) {
                            snprintf(else_emit_ty_buf2, sizeof(else_emit_ty_buf2), "%s", tmp_ty_str);
                            else_emit_ty2 = else_emit_ty_buf2;
                        }
                    }
                    if (else_e) {
                        if (else_emit_ty2 && else_e->kind == AST_EXPR_STRUCT_LIT) {
                            static char else_lit_ty2[128];
                            const char *else_ctype2 = struct_lit_c_type_str(else_e, else_lit_ty2, sizeof(else_lit_ty2));
                            int lexer_result_else_token2 = (strstr(else_emit_ty2, "LexerResult") != NULL && else_ctype2 && strstr(else_ctype2, "Token") != NULL);
                            if (lexer_result_else_token2) {
                                if (strncmp(else_emit_ty2, "struct ", 7) == 0) fprintf(out, "(%s){0}", else_emit_ty2);
                                else { static char struct_lex_buf2[128]; snprintf(struct_lex_buf2, sizeof(struct_lex_buf2), "struct %s", else_emit_ty2); fprintf(out, "(%s){0}", struct_lex_buf2); }
                            } else if (strncmp(else_emit_ty2, "struct ", 7) == 0 && else_ctype2 && strcmp(else_ctype2, else_emit_ty2) != 0)
                                fprintf(out, "(%s){0}", else_emit_ty2);
                            else if (else_struct_type_mismatch(else_emit_ty2, else_e))
                                fprintf(out, "(%s){0}", else_emit_ty2);
                            else if (codegen_expr(else_e, out) != 0) return -1;
                        } else {
                            static char else_ty_any2[128];
                            const char *else_ty_ptr2 = expr_struct_type_str(else_e, else_ty_any2, sizeof(else_ty_any2));
                            if (else_emit_ty2 && strncmp(else_emit_ty2, "struct ", 7) == 0 && else_ty_ptr2 && strcmp(else_ty_ptr2, else_emit_ty2) != 0)
                                fprintf(out, "(%s){0}", else_emit_ty2);
                            else if (else_emit_ty2 && else_struct_type_mismatch(else_emit_ty2, else_e))
                                fprintf(out, "(%s){0}", else_emit_ty2);
                            else if (codegen_expr(else_e, out) != 0) return -1;
                        }
                    } else {
                        if (else_emit_ty2 && strncmp(else_emit_ty2, "struct ", 7) == 0)
                            fprintf(out, "(%s){0}", else_emit_ty2);
                        else if (then_e && then_is_block) {
                            if (else_emit_ty2 && strstr(else_emit_ty2, "LexerResult")) {
                                static char struct_lex_buf02[128];
                                snprintf(struct_lex_buf02, sizeof(struct_lex_buf02), "struct %s", else_emit_ty2);
                                fprintf(out, "(%s){0}", struct_lex_buf02);
                            } else if (expr_struct_type_str(then_e, else_emit_ty_buf2, sizeof(else_emit_ty_buf2)))
                                fprintf(out, "(%s){0}", else_emit_ty_buf2);
                            else
                                fprintf(out, "0");
                        } else
                            fprintf(out, "0");
                    }
                    fprintf(out, ") ");
                }
                fprintf(out, "; __tmp; })");
                return 0;
            }
            /* 若 then 分支为 panic，条件用 __builtin_expect(!!(cond),0) 包裹，使热点路径线性取指（控制流清单 §8.3） */
            int then_is_panic = (then_e && then_e->kind == AST_EXPR_PANIC);
            fprintf(out, "(");
            if (then_is_panic) {
                fprintf(out, "__builtin_expect(!!(");
                if (codegen_expr(e->value.if_expr.cond, out) != 0) return -1;
                fprintf(out, "), 0) ? ");
            } else {
                if (codegen_expr(e->value.if_expr.cond, out) != 0) return -1;
                fprintf(out, " ? ");
            }
            if (codegen_expr(then_e, out) != 0) return -1;
            fprintf(out, " : ");
            if (else_e) {
                if (codegen_expr(else_e, out) != 0) return -1;
            } else {
                fprintf(out, "0");
            }
            fprintf(out, ")");
            return 0;
#endif
        }
        case AST_EXPR_TERNARY: {
            /* cond ? then : else → C 三元运算符 */
#ifdef SHUX_USE_X_CODEGEN
            { static const char q[] = " ? ", c[] = " : "; fprintf(out, "("); if (codegen_codegen_x_emit_ternary_inner((uint8_t *)out, (uint8_t *)e->value.if_expr.cond, (uint8_t *)e->value.if_expr.then_expr, (uint8_t *)e->value.if_expr.else_expr, (uint8_t *)q, 3, (uint8_t *)c, 3) != 0) return -1; fprintf(out, ")"); return 0; }
#else
            fprintf(out, "(");
            if (codegen_expr(e->value.if_expr.cond, out) != 0) return -1;
            fprintf(out, " ? ");
            if (codegen_expr(e->value.if_expr.then_expr, out) != 0) return -1;
            fprintf(out, " : ");
            if (codegen_expr(e->value.if_expr.else_expr, out) != 0) return -1;
            fprintf(out, ")");
            return 0;
#endif
        }
        case AST_EXPR_PANIC:
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_panic((uint8_t *)out, e->value.unary.operand ? 1 : 0, (uint8_t *)e->value.unary.operand) != 0) return -1;
            return 0;
#else
            /* 冷路径：通过辅助函数标记 noreturn+cold，避免污染 ICache（控制流清单 §8.3、§8.4） */
            if (e->value.unary.operand) {
                fprintf(out, "shux_panic_(1, ");
                if (codegen_expr(e->value.unary.operand, out) != 0) return -1;
                fprintf(out, ")");
            } else {
                fprintf(out, "shux_panic_(0, 0)");
            }
            return 0;
#endif
        case AST_EXPR_FIELD_ACCESS:
            /* binding.CONST：依赖模块顶层 const（如 async_mod.POLL_PENDING） */
            if (codegen_try_emit_import_module_const(out, e) == 0)
                return 0;
            /* 统一由 .x 入口分发：枚举变体转调 C 的 emit_field_access_enum_variant_full，结构体字段由 .x 输出 (base).field */
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_field_access_expr((uint8_t *)out, (uint8_t *)e) != 0) return -1;
            return 0;
#else
            /* Type.Variant 枚举变体（typeck 已设 is_enum_variant）与 base.field 结构体字段（§7.4）；跨模块时用 prefix_Enum_Variant */
            if (e->value.field_access.is_enum_variant && e->value.field_access.base->kind == AST_EXPR_VAR) {
                const char *en = e->value.field_access.base->value.var.name;
                const char *vn = e->value.field_access.field_name;
                if (!codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths && en) {
                    int found = 0;
                    for (int di = 0; di < codegen_ndep && !found; di++) {
                        const struct ASTModule *d = codegen_dep_mods[di];
                        if (!d || !d->enum_defs) continue;
                        for (int ej = 0; ej < d->num_enums; ej++)
                            if (d->enum_defs[ej]->name && strcmp(d->enum_defs[ej]->name, en) == 0) {
                                char pre[256];
                                import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                                fprintf(out, "%s%s_%s", pre, en, vn ? vn : "");
                                found = 1;
                                break;
                            }
                    }
                    if (found) return 0;
                }
                if (codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths && en) {
                    int found = 0;
                    for (int di = 0; di < codegen_ndep && !found; di++) {
                        const struct ASTModule *d = codegen_dep_mods[di];
                        if (!d || !d->enum_defs) continue;
                        for (int ej = 0; ej < d->num_enums; ej++)
                            if (d->enum_defs[ej]->name && strcmp(d->enum_defs[ej]->name, en) == 0) {
                                char pre[256];
                                import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                                fprintf(out, "%s%s_%s", pre, en, vn ? vn : "");
                                found = 1;
                                break;
                            }
                    }
                    if (found) return 0;
                }
                if (codegen_library_prefix && *codegen_library_prefix && en)
                    fprintf(out, "%s%s_%s", codegen_library_prefix, en, vn ? vn : "");
                else
                    fprintf(out, "%s_%s", en ? en : "", vn ? vn : "");
                return 0;
            }
            /* 库模块未做 typeck 时 is_enum_variant 可能为 0；若 base 为当前模块枚举类型名则按枚举变体输出 */
            if (codegen_library_prefix && *codegen_library_prefix && codegen_library_module && codegen_library_module->enum_defs
                && e->value.field_access.base->kind == AST_EXPR_VAR && e->value.field_access.base->value.var.name) {
                const char *en2 = e->value.field_access.base->value.var.name;
                const char *vn2 = e->value.field_access.field_name;
                for (int i = 0; i < codegen_library_module->num_enums; i++)
                    if (codegen_library_module->enum_defs[i]->name && strcmp(codegen_library_module->enum_defs[i]->name, en2) == 0) {
                        fprintf(out, "%s%s_%s", codegen_library_prefix, en2, vn2 ? vn2 : "");
                        return 0;
                    }
            }
            /* 字段访问 base.field；指针或 slice 形参用 ->，局部 slice 值类型与其它用 . */
            fprintf(out, "(");
            if (codegen_expr(e->value.field_access.base, out) != 0) return -1;
            if ((e->value.field_access.base->resolved_type && e->value.field_access.base->resolved_type->kind == AST_TYPE_PTR)
                || expr_is_ptr_or_slice_param(e->value.field_access.base))
                fprintf(out, ")->%s", e->value.field_access.field_name ? e->value.field_access.field_name : "");
            else
                fprintf(out, ").%s", e->value.field_access.field_name ? e->value.field_access.field_name : "");
            return 0;
#endif
        case AST_EXPR_STRUCT_LIT: {
#ifdef SHUX_USE_X_CODEGEN
            /* 直接调 C 的 full 实现，避免 .x 再 extern 回 C；.x 主路径走 emit_expr 占位。 */
            if (codegen_x_emit_struct_lit_full((uint8_t *)out, (uint8_t *)e) != 0) return -1;
            return 0;
#else
            /* 统一走 codegen_emit_struct_lit_impl：含数组字段时用块形式（临时变量 + memcpy），避免 C 复合字面量中数组赋值非法 */
            return codegen_emit_struct_lit_impl(out, e);
#endif
        }
        case AST_EXPR_ARRAY_LIT: {
#ifdef SHUX_USE_X_CODEGEN
            /* 直接调 C 的 full 实现，避免 .x 再 extern 回 C；.x 主路径走 emit_expr 占位。 */
            if (codegen_x_emit_array_lit_full((uint8_t *)out, (uint8_t *)e) != 0) return -1;
            return 0;
#else
            /* 数组字面量 [e1, e2, ...]：实参期望 slice 时生成 (struct shux_slice_X){ .data = (elem[]){ ... }, .length = N }，否则 (elem_ty[]){ ... }（文档 §6.2） */
            const struct ASTType *aty = e->resolved_type;
            const struct ASTType *elem_ty = (aty && (aty->kind == AST_TYPE_ARRAY || aty->kind == AST_TYPE_SLICE)) ? aty->elem_type : NULL;
            /* 未从 resolved_type 得到元素类型时（如结构体字面量字段初值未设），用任一首个有类型的元素兜底，避免误用 uint8_t */
            if (!elem_ty && e->value.array_lit.num_elems > 0) {
                for (int ei = 0; ei < e->value.array_lit.num_elems && !elem_ty; ei++)
                    if (e->value.array_lit.elems[ei]->resolved_type)
                        elem_ty = e->value.array_lit.elems[ei]->resolved_type;
            }
            int n = e->value.array_lit.num_elems;
            /* 元素类型字符串存局部缓冲，避免 c_type_str 静态缓冲被后续 c_type_str(aty) 覆盖 */
            char elem_ty_buf[64];
            snprintf(elem_ty_buf, sizeof(elem_ty_buf), "%s", elem_ty ? c_type_str(elem_ty) : "uint8_t");
            if (aty && aty->kind == AST_TYPE_SLICE && elem_ty) {
                ensure_slice_struct(aty, out);
                fprintf(out, "(%s){ .data = (%s[]){ ", c_type_str(aty), elem_ty_buf);
                for (int i = 0; i < n; i++) {
                    if (i) fprintf(out, ", ");
                    if (codegen_expr(e->value.array_lit.elems[i], out) != 0) return -1;
                }
                fprintf(out, " }, .length = %d }", n);
                return 0;
            }
            if (aty && aty->kind == AST_TYPE_ARRAY && aty->array_size > 0)
                fprintf(out, "(%s[%d]){ ", elem_ty_buf, aty->array_size);
            else
                fprintf(out, "(%s[]){ ", elem_ty_buf);
            /* 空字面量 [] 且固定长度时零初始化，C 用 0 填充剩余元素 */
            if (n == 0 && aty && aty->kind == AST_TYPE_ARRAY && aty->array_size > 0)
                fprintf(out, "0");
            else
                for (int i = 0; i < n; i++) {
                    if (i) fprintf(out, ", ");
                    if (codegen_expr(e->value.array_lit.elems[i], out) != 0) return -1;
                }
            fprintf(out, " }");
            return 0;
#endif
        }
        case AST_EXPR_INDEX: {
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_index((uint8_t *)out, (uint8_t *)e) != 0) return -1;
            return 0;
#else
            /* 数组 base[i] → (base)[i]；切片 base[i] → (base).data[i]；指针 base[i] → (base)[i]（无界检，与 C 一致） */
            const struct ASTExpr *base = e->value.index.base;
            const struct ASTExpr *idx = e->value.index.index_expr;
            const struct ASTType *base_ty = base->resolved_type;
            int skip_bounds_check = e->index_proven_in_bounds && driver_sanitize_address_get() == 0;
            if (base_ty && base_ty->kind == AST_TYPE_PTR && base_ty->elem_type) {
                fprintf(out, "(");
                if (codegen_expr(base, out) != 0) return -1;
                fprintf(out, ")[");
                if (codegen_expr(idx, out) != 0) return -1;
                fprintf(out, "]");
                return 0;
            }
            if (e->value.index.base_is_slice && base_ty && base_ty->kind == AST_TYPE_SLICE) {
                /* 仅形参 slice 在 C 中按指针传用 ->；局部/全局 slice 为 struct 用 .；无当前函数时保守用 . */
                int use_arrow = codegen_current_func && expr_is_slice_ptr_param(base);
                const char *da = use_arrow ? ")->" : ").";
                if (skip_bounds_check) {
                    fprintf(out, "(");
                    if (codegen_expr(base, out) != 0) return -1;
                    fprintf(out, "%sdata[", da);
                    if (codegen_expr(idx, out) != 0) return -1;
                    fprintf(out, "]");
                } else {
                    fprintf(out, "(");
                    if (codegen_expr(idx, out) != 0) return -1;
                    fprintf(out, " < 0 || (size_t)(");
                    if (codegen_expr(idx, out) != 0) return -1;
                    fprintf(out, ") >= (");
                    if (codegen_expr(base, out) != 0) return -1;
                    fprintf(out, "%slength ? (shux_panic_(1, 0), (", da);
                    if (codegen_expr(base, out) != 0) return -1;
                    fprintf(out, "%sdata[0]) : (", da);
                    if (codegen_expr(base, out) != 0) return -1;
                    fprintf(out, "%sdata[", da);
                    if (codegen_expr(idx, out) != 0) return -1;
                    fprintf(out, "])");
                }
                return 0;
            }
            /* foo()[i]：foo() 返回数组是右值，C 不允许直接对函数返回值下标，先存临时变量再取。 */
            if (!e->value.index.base_is_slice && base_ty && base_ty->kind == AST_TYPE_ARRAY && base_ty->array_size > 0
                && (base->kind == AST_EXPR_CALL || base->kind == AST_EXPR_METHOD_CALL)) {
                const char *wn = arr_ret_wrapper_name(base_ty);
                int id = codegen_match_id++;
                int n = base_ty->array_size;
                fprintf(out, "({ struct %s _x_idx%d = (", wn, id);
                if (codegen_expr(base, out) != 0) return -1;
                fprintf(out, "); (");
                if (codegen_expr(idx, out) != 0) return -1;
                fprintf(out, " < 0 || (");
                if (codegen_expr(idx, out) != 0) return -1;
                fprintf(out, ") >= %d ? (shux_panic_(1, 0), _x_idx%d.data[0]) : _x_idx%d.data[", n, id, id);
                if (codegen_expr(idx, out) != 0) return -1;
                fprintf(out, "]); })");
                return 0;
            }
            if (!e->value.index.base_is_slice && base_ty && base_ty->kind == AST_TYPE_ARRAY && base_ty->array_size > 0) {
                if (skip_bounds_check) {
                    fprintf(out, "(");
                    if (codegen_expr(base, out) != 0) return -1;
                    fprintf(out, ")[");
                    if (codegen_expr(idx, out) != 0) return -1;
                    fprintf(out, "]");
                } else {
                    int n = base_ty->array_size;
                    fprintf(out, "(");
                    if (codegen_expr(idx, out) != 0) return -1;
                    fprintf(out, " < 0 || (");
                    if (codegen_expr(idx, out) != 0) return -1;
                    fprintf(out, ") >= %d ? (shux_panic_(1, 0), (", n);
                    if (codegen_expr(base, out) != 0) return -1;
                    fprintf(out, ")[0]) : (");
                    if (codegen_expr(base, out) != 0) return -1;
                    fprintf(out, ")[");
                    if (codegen_expr(idx, out) != 0) return -1;
                    fprintf(out, "])");
                }
                return 0;
            }
            /* 仅形参 slice 在 C 中按指针传用 ->；局部 slice 为 struct 用 . */
            fprintf(out, "(");
            if (codegen_expr(base, out) != 0) return -1;
            if (e->value.index.base_is_slice) {
                int use_arrow = expr_is_slice_ptr_param(base);
                fprintf(out, ")%sdata[", use_arrow ? "->" : ".");
            } else
                fprintf(out, ")[");
            if (codegen_expr(idx, out) != 0) return -1;
            fprintf(out, "]");
            return 0;
#endif
        }
        case AST_EXPR_CALL: {
            /* 统一由 .x 入口 codegen_x_emit_call_expr 分发：import_path / library_same / library_dep / mono 转调 C 的 full，否则 fallback callee(args)。 */
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_call_expr((uint8_t *)out, (uint8_t *)e) != 0) return -1;
            return 0;
#else
            if (e->value.call.resolved_import_path && e->value.call.resolved_callee_func) {
                if (codegen_emit_call_import_path_impl(out, e) != 0) return -1;
                return 0;
            }
            if (codegen_library_prefix && *codegen_library_prefix && codegen_library_module && e->value.call.callee->kind == AST_EXPR_VAR) {
                if (codegen_emit_call_library_same_impl(out, e) == 0) return 0;
            }
            if (codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths && e->value.call.callee->kind == AST_EXPR_VAR) {
                if (codegen_emit_call_library_dep_impl(out, e) == 0) return 0;
            }
            if (e->value.call.num_type_args > 0 && codegen_current_module && e->value.call.callee->kind == AST_EXPR_VAR) {
                if (codegen_emit_call_mono_impl(out, e) == 0) return 0;
            }
            if (e->value.call.resolved_callee_func && e->value.call.callee->kind == AST_EXPR_VAR) {
                const struct ASTFunc *rf = e->value.call.resolved_callee_func;
                const struct ASTModule *fmod = codegen_find_func_module(rf);
                const char *link_name = func_link_name(fmod, rf);
                fprintf(out, "%s(", builtin_intrinsic_name(link_name));
                for (int i = 0; i < e->value.call.num_args; i++) {
                    if (i) fprintf(out, ", ");
                    if (codegen_emit_one_call_arg(out, e->value.call.args[i]) != 0) return -1;
                }
                fprintf(out, ")");
                return 0;
            }
            if (codegen_expr(e->value.call.callee, out) != 0) return -1;
            fprintf(out, "(");
            for (int i = 0; i < e->value.call.num_args; i++) {
                if (i) fprintf(out, ", ");
                if (e->value.call.resolved_callee_func) {
                    int r = codegen_emit_io_driver_arg0_for_func(out, e->value.call.resolved_callee_func,
                        e->value.call.resolved_import_path, i, e->value.call.args[i]);
                    if (r == -1) return -1;
                    if (r == 1) continue;
                }
                if (codegen_emit_one_call_arg(out, e->value.call.args[i]) != 0) return -1;
            }
            fprintf(out, ")");
            return 0;
#endif
        }
        case AST_EXPR_METHOD_CALL: {
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_method_call((uint8_t *)out, (uint8_t *)e) != 0) return -1;
            return 0;
#else
            struct ASTFunc *impl_func = e->value.method_call.resolved_impl_func;
            if (!impl_func) {
                codegen_report_expr_error(e, "method call not resolved");
                return -1;
            }
            /* module.func 形式：resolved_import_path 已由 typeck 填写，仅出 prefix+name(args)，不出 base */
            if (e->value.method_call.resolved_import_path) {
                char pre[256];
                import_path_to_c_prefix(e->value.method_call.resolved_import_path, pre, sizeof(pre));
                char mname[256];
                const struct ASTModule *fmod = codegen_find_func_module(impl_func);
                const char *link = func_link_name(fmod, impl_func);
                if (impl_func->is_extern || !impl_func->body)
                    (void)snprintf(mname, sizeof(mname), "%s", link ? link : (impl_func->name ? impl_func->name : ""));
                else
                    codegen_join_import_prefix_func_name(pre, link ? link : (impl_func->name ? impl_func->name : ""), mname, sizeof(mname));
                fprintf(out, "%s(", builtin_intrinsic_name(mname));
                for (int i = 0; i < e->value.method_call.num_args; i++) {
                    if (i) fprintf(out, ", ");
                    {
                        int r = codegen_emit_io_driver_arg0_for_func(out, impl_func,
                            e->value.method_call.resolved_import_path, i, e->value.method_call.args[i]);
                        if (r == -1) return -1;
                        if (r == 1) continue;
                    }
                    if (codegen_emit_one_call_arg(out, e->value.method_call.args[i]) != 0) return -1;
                }
                fprintf(out, ")");
                return 0;
            }
            fprintf(out, "%s(", impl_method_c_name(impl_func));
            if (codegen_expr(e->value.method_call.base, out) != 0) return -1;
            for (int i = 0; i < e->value.method_call.num_args; i++) {
                fprintf(out, ", ");
                if (codegen_expr(e->value.method_call.args[i], out) != 0) return -1;
            }
            fprintf(out, ")");
            return 0;
#endif
        }
        case AST_EXPR_MATCH: {
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_match((uint8_t *)out, (uint8_t *)e) != 0) return -1;
            return 0;
#else
            /* 按控制流清单 §8.6：密度 > 0.7 时生成 switch，否则三元链；支持整数字面量与枚举变体（§7.4）。
             * match guard（`pat if cond =>`）与或模式（`1|2 =>`）须走三元链：guard 需条件合取，
             * 或模式同 result 多 lit 须合并为 (m==a||m==b)，switch 会重复 case。 */
            const struct ASTExpr *me = e->value.match_expr.matched_expr;
            const struct ASTMatchArm *arms = e->value.match_expr.arms;
            int num_arms = e->value.match_expr.num_arms;
            int value_min = INT_MAX, value_max = INT_MIN, lit_count = 0;
            int has_guard = 0, has_or = 0, has_struct = 0;
            for (int i = 0; i < num_arms; i++) {
                if (arms[i].guard_expr) has_guard = 1;
                if (arms[i].result_shared) has_or = 1;
                if (arms[i].is_struct_pattern) has_struct = 1;
                if (arms[i].is_wildcard) continue;
                int v = arms[i].is_enum_variant ? arms[i].variant_index : arms[i].lit_val;
                lit_count++;
                if (v < value_min) value_min = v;
                if (v > value_max) value_max = v;
            }
            int range = (value_max >= value_min) ? (value_max - value_min + 1) : 0;
            double density = (range > 0 && lit_count > 0) ? (double)lit_count / (double)range : 0.0;
            int use_switch = (density > 0.7 && lit_count > 0) && !has_guard && !has_or && !has_struct;

            if (use_switch) {
                int id = codegen_match_id++;
                fprintf(out, "({ int _x_m%d = (", id);
                if (codegen_expr(me, out) != 0) return -1;
                fprintf(out, "); int _x_r; switch (_x_m%d) { ", id);
                for (int i = 0; i < num_arms; i++) {
                    if (arms[i].is_wildcard) {
                        fprintf(out, "default: _x_r = (");
                        if (codegen_expr(arms[i].result, out) != 0) return -1;
                        fprintf(out, "); break; ");
                        break;
                    }
                    {
                        int case_val = arms[i].is_enum_variant ? arms[i].variant_index : arms[i].lit_val;
                        fprintf(out, "case %d: _x_r = (", case_val);
                    }
                    if (codegen_expr(arms[i].result, out) != 0) return -1;
                    fprintf(out, "); break; ");
                }
                if (num_arms && !arms[num_arms - 1].is_wildcard)
                    fprintf(out, "default: _x_r = 0; break; ");
                fprintf(out, "} _x_r; })");
            } else {
                /* 三元链：或模式合并 (m==a||m==b)，guard 合取 (&& cond)。 */
                fprintf(out, "(");
                int i = 0;
                int first = 1;
                while (i < num_arms) {
                    if (!first) fprintf(out, " : ");
                    first = 0;
                    if (arms[i].is_wildcard) {
                        if (arms[i].guard_expr) {
                            fprintf(out, "(");
                            if (codegen_expr(arms[i].guard_expr, out) != 0) return -1;
                            fprintf(out, ") ? ");
                            if (codegen_expr(arms[i].result, out) != 0) return -1;
                            i++;
                            continue;
                        }
                        if (codegen_expr(arms[i].result, out) != 0) return -1;
                        break;
                    }
                    if (arms[i].is_struct_pattern) {
                        /* Name { f: lit, g: _, x } => r：条件为各 LIT 字段 (me).f==lit 的合取（无 LIT 则恒真）；
                         * BIND 字段在 result 前声明 T x = (me).f; 供 result 使用。 */
                        const struct ASTStructDef *sd = NULL;
                        if (codegen_current_module && codegen_current_module->struct_defs)
                            for (int si=0; si<codegen_current_module->num_structs && !sd; si++)
                                if (codegen_current_module->struct_defs[si]->name && arms[i].struct_pat_name && strcmp(codegen_current_module->struct_defs[si]->name, arms[i].struct_pat_name)==0) sd=codegen_current_module->struct_defs[si];
                        if (!sd && codegen_ndep>0 && codegen_dep_mods)
                            for (int di=0; di<codegen_ndep && !sd; di++) { const struct ASTModule *dm=codegen_dep_mods[di]; if(!dm||!dm->struct_defs) continue; for(int si=0;si<dm->num_structs&&!sd;si++) if(dm->struct_defs[si]->name&&arms[i].struct_pat_name&&strcmp(dm->struct_defs[si]->name,arms[i].struct_pat_name)==0) sd=dm->struct_defs[si]; }
                        int has_bind = 0;
                        for (int fi=0; fi<arms[i].num_struct_pat_fields; fi++) if (arms[i].struct_pat_fields[fi].kind == MATCH_STRUCT_PAT_BIND) has_bind = 1;
                        /* 条件：有 BIND 字段时用 ({ binds; lit_conds && guard; }) 让 guard 能引用绑定变量 */
                        fprintf(out, "(");
                        if (has_bind) fprintf(out, "({ ");
                        for (int fi=0; fi<arms[i].num_struct_pat_fields; fi++) {
                            if (arms[i].struct_pat_fields[fi].kind != MATCH_STRUCT_PAT_BIND) continue;
                            const char *bty = "int32_t";
                            if (sd) { for (int si=0; si<sd->num_fields; si++) if (sd->fields[si].name && strcmp(sd->fields[si].name, arms[i].struct_pat_fields[fi].field_name)==0 && sd->fields[si].type) { bty = c_type_str(sd->fields[si].type); break; } }
                            fprintf(out, "%s %s = (", bty, arms[i].struct_pat_fields[fi].bind_name);
                            if (codegen_expr(me, out) != 0) return -1;
                            fprintf(out, ").%s; ", arms[i].struct_pat_fields[fi].field_name);
                        }
                        int has_lit = 0;
                        for (int fi=0; fi<arms[i].num_struct_pat_fields; fi++) {
                            if (arms[i].struct_pat_fields[fi].kind != MATCH_STRUCT_PAT_LIT) continue;
                            if (has_lit) fprintf(out, " && ");
                            fprintf(out, "(");
                            if (codegen_expr(me, out) != 0) return -1;
                            fprintf(out, ").%s == %lld", arms[i].struct_pat_fields[fi].field_name, (long long)arms[i].struct_pat_fields[fi].lit_val);
                            has_lit = 1;
                        }
                        if (!has_lit) fprintf(out, "1");
                        if (arms[i].guard_expr) { fprintf(out, " && ("); if (codegen_expr(arms[i].guard_expr, out) != 0) return -1; fprintf(out, ")"); }
                        if (has_bind) fprintf(out, "; }))"); else fprintf(out, ")");
                        fprintf(out, " ? ({ ");
                        for (int fi=0; fi<arms[i].num_struct_pat_fields; fi++) {
                            if (arms[i].struct_pat_fields[fi].kind != MATCH_STRUCT_PAT_BIND) continue;
                            const char *bty = "int32_t";
                            if (sd) { for (int si=0; si<sd->num_fields; si++) if (sd->fields[si].name && strcmp(sd->fields[si].name, arms[i].struct_pat_fields[fi].field_name)==0 && sd->fields[si].type) { bty = c_type_str(sd->fields[si].type); break; } }
                            fprintf(out, "%s %s = (", bty, arms[i].struct_pat_fields[fi].bind_name);
                            if (codegen_expr(me, out) != 0) return -1;
                            fprintf(out, ").%s; ", arms[i].struct_pat_fields[fi].field_name);
                        }
                        fprintf(out, "(");
                        if (codegen_expr(arms[i].result, out) != 0) return -1;
                        fprintf(out, "); })");
                        i++;
                        continue;
                    }
                    /* 收集同 result/guard 的连续或模式 lit（result_shared 标记） */
                    fprintf(out, "(");
                    int printed_or = 0;
                    int j = i;
                    while (j < num_arms && !arms[j].is_wildcard
                           && arms[j].result == arms[i].result && arms[j].guard_expr == arms[i].guard_expr) {
                        if (printed_or) fprintf(out, " || ");
                        fprintf(out, "(");
                        if (codegen_expr(me, out) != 0) return -1;
                        int cmp_val = arms[j].is_enum_variant ? arms[j].variant_index : arms[j].lit_val;
                        fprintf(out, ") == %d", cmp_val);
                        printed_or = 1;
                        if (!arms[j].result_shared) { j++; break; }
                        j++;
                    }
                    if (arms[i].guard_expr) {
                        fprintf(out, ") && (");
                        if (codegen_expr(arms[i].guard_expr, out) != 0) return -1;
                        fprintf(out, ")");
                    } else {
                        fprintf(out, ")");
                    }
                    fprintf(out, " ? ");
                    if (codegen_expr(arms[i].result, out) != 0) return -1;
                    i = j;
                }
                if (num_arms && !arms[num_arms - 1].is_wildcard)
                    fprintf(out, " : 0");
                fprintf(out, ")");
            }
            return 0;
#endif
        }
        case AST_EXPR_BLOCK:
            {
                const struct ASTBlock *value_block = codegen_block_expr_value_block(e->value.block);
                if (value_block && e->resolved_type && e->resolved_type->kind != AST_TYPE_VOID
                    && e->resolved_type->kind != AST_TYPE_ARRAY) {
                    const char *tmp_ty = c_type_str(e->resolved_type);
                    fprintf(out, "({ %s __shux_block_result = {0}; ", tmp_ty ? tmp_ty : "int32_t");
                    if (codegen_block_body(value_block, 2, out, 0, 0, "__shux_block_result") != 0) return -1;
                    fprintf(out, " __shux_block_result; })");
                    return 0;
                }
#ifdef SHUX_USE_X_CODEGEN
                if (codegen_codegen_x_emit_block_expr((uint8_t *)out, (uint8_t *)e->value.block) != 0) return -1;
                return 0;
#else
                /* 无法形成值时仍退回 GNU C 语句表达式，保留块内副作用。 */
                fprintf(out, "({ ");
                if (codegen_block_body(e->value.block, 2, out, 0, 0, NULL) != 0) return -1;
                fprintf(out, " 0; })");
                return 0;
#endif
            }
        default:
            {
                char msg[96];
                (void)snprintf(msg, sizeof(msg), "unhandled expression kind %d", (int)e->kind);
                codegen_report_expr_error(e, msg);
            }
            return -1;
    }
}

static void codegen_report_expr_error(const struct ASTExpr *e, const char *msg) {
    int line = e ? e->line : 0;
    int col = e ? e->col : 0;
    diag_report_with_code(NULL, line, col, "codegen error", SHUX_DIAG_CODE_CODEGEN_CG003, msg, msg);
}

/** 输出单次调用的一个实参：slice 值包 &(...)，slice 指针形参不包；arg 为 NULL 时输出 0 占位，避免非法 C。 */
static int codegen_emit_one_call_arg(FILE *out, const struct ASTExpr *arg) {
    if (!arg) {
        fputs("0", out);
        return 0;
    }
    int is_slice_val = (arg->resolved_type && arg->resolved_type->kind == AST_TYPE_SLICE);
    int is_slice_ptr_param = is_slice_val && expr_is_slice_ptr_param(arg);
    if (is_slice_val && !is_slice_ptr_param) {
        fprintf(out, "&(");
        if (codegen_expr(arg, out) != 0) return -1;
        fprintf(out, ")");
    } else if (codegen_expr(arg, out) != 0)
        return -1;
    return 0;
}

/** import 路径是否为 std.io.driver（含 binding import 解析后的完整路径）。 */
static int codegen_is_std_io_driver_import_path(const char *path) {
    if (!path || !path[0]) return 0;
    if (strcmp(path, "std.io.driver") == 0 || strcmp(path, "std/io/driver") == 0) return 1;
    {
        size_t len = strlen(path);
        if (len >= 11 && (strcmp(path + len - 11, ".io.driver") == 0 || strcmp(path + len - 11, "/io/driver") == 0))
            return 1;
    }
    return 0;
}

/** 查找函数 f 所属依赖模块的 import 路径（库模块内跨 dep 调用用）。 */
static const char *codegen_func_dep_import_path(const struct ASTFunc *f) {
    int di;
    if (!f) return NULL;
    for (di = 0; di < codegen_ndep; di++) {
        const struct ASTModule *dm = codegen_dep_mods[di];
        int fi;
        if (!dm || !dm->funcs) continue;
        for (fi = 0; fi < dm->num_funcs; fi++) {
            if (dm->funcs[fi] == f)
                return codegen_dep_paths[di];
        }
    }
    if (codegen_library_module && codegen_library_module->funcs) {
        int fi2;
        for (fi2 = 0; fi2 < codegen_library_module->num_funcs; fi2++) {
            if (codegen_library_module->funcs[fi2] == f)
                return codegen_library_import_path;
        }
    }
    return NULL;
}

/**
 * std.io.driver 的 register/submit_read/submit_write 首参为 Buffer 传指针宽度（ptrdiff_t）；
 * submit_register_fixed_buffers_buf 首参为 *Buffer 直接传指针，不转换。
 * 返回 1 已处理，0 非此类调用，-1 错误。
 */
static int codegen_emit_io_driver_arg0_for_func(FILE *out, const struct ASTFunc *f, const char *import_path,
                                                int arg_index, const struct ASTExpr *arg) {
    if (arg_index != 0 || !f || !arg) return 0;
    if (!import_path)
        import_path = codegen_func_dep_import_path(f);
    if (!codegen_is_std_io_driver_import_path(import_path)) return 0;
    if (!f->name) return 0;
    /* submit_register_fixed_buffers_buf 定义签名为 struct * bufs，调用处直接传指针，不转 ptrdiff_t */
    int need_cast = (strcmp(f->name, "register") == 0 || strcmp(f->name, "submit_read") == 0 || strcmp(f->name, "submit_write") == 0);
    if (!need_cast) return 0;
    if (f->num_params < 1) return 0;
    if (f->params && f->params[0].type && f->params[0].type->kind == AST_TYPE_PTR) {
        fprintf(out, "(ptrdiff_t)(uintptr_t)(");
        if (codegen_emit_one_call_arg(out, arg) != 0) return -1;
        fprintf(out, ")");
    } else {
        fprintf(out, "(ptrdiff_t)(uintptr_t)&(");
        if (codegen_emit_one_call_arg(out, arg) != 0) return -1;
        fprintf(out, ")");
    }
    return 1;
}

/** CALL 节点包装：从 resolved_import_path + resolved_callee_func 发射首参 ptrdiff_t 转换。 */
static int codegen_emit_io_driver_arg0(FILE *out, const struct ASTExpr *e, int arg_index, const struct ASTExpr *arg) {
    if (arg_index != 0 || !e || !e->value.call.resolved_callee_func) return 0;
    return codegen_emit_io_driver_arg0_for_func(out, e->value.call.resolved_callee_func,
                                                e->value.call.resolved_import_path, arg_index, arg);
}

/** CALL 跨模块（import 解析）：prefix + name(args)；经 builtin_intrinsic_name 映射后可变为 __builtin_memcpy 等。
 * extern 函数由 C 提供，C 符号即为 f->name，不加模块前缀（如 parser_slice_from_buf 在 pipeline_glue.c 中定义）。 */
static int codegen_emit_call_import_path_impl(FILE *out, const struct ASTExpr *e) {
    {
        int layout_r = codegen_try_emit_type_layout_intrinsic(out, e);
        if (layout_r == 1) return 0;
        if (layout_r < 0) return -1;
    }
    char pre[256];
    import_path_to_c_prefix(e->value.call.resolved_import_path, pre, sizeof(pre));
    const struct ASTFunc *f = e->value.call.resolved_callee_func;
    char full_name[256];
    /* extern 或无 .x 函数体：C 符号即为 f->name，不加模块前缀 */
    if (f->is_extern || !f->body) {
        if (e->value.call.num_type_args > 0 && e->value.call.type_args)
            (void)snprintf(full_name, sizeof(full_name), "%s", mono_instance_mangled_name_ex(
                codegen_module_for_import_path(e->value.call.resolved_import_path), f,
                e->value.call.type_args, e->value.call.num_type_args));
        else
            (void)snprintf(full_name, sizeof(full_name), "%s", call_instance_mangled_name(f, e));
    } else {
        if (e->value.call.num_type_args > 0 && e->value.call.type_args)
            codegen_join_import_prefix_func_name(pre, mono_instance_mangled_name_ex(
                codegen_module_for_import_path(e->value.call.resolved_import_path), f,
                e->value.call.type_args, e->value.call.num_type_args), full_name, sizeof(full_name));
        else
            codegen_join_import_prefix_func_name(pre, call_instance_mangled_name(f, e), full_name, sizeof(full_name));
    }
    /* 仅按被调函数形参个数输出实参，避免将类型实参占位当作值实参产出（如 core.types.placeholder() 被错误产出 core_types_placeholder(0,0)） */
    int n_emit = e->value.call.num_args;
    int arg_start = 0;
    if (f->num_params >= 0 && n_emit > f->num_params) {
        n_emit = f->num_params;
        /* 单参函数（print_i32/ok_i32/err_i32 等）AST 可能传 (tag, value)，只发射最后一参避免 (0, 42) 导致 too many arguments */
        if (f->num_params == 1 && e->value.call.num_args == 2 && f->name) {
            if ((strcmp(f->name, "print") == 0 && f->num_params == 1) || strcmp(f->name, "print_i32") == 0 || strcmp(f->name, "print_u32") == 0 || strcmp(f->name, "print_i64") == 0
                || strcmp(f->name, "ok_i32") == 0 || strcmp(f->name, "err_i32") == 0)
                arg_start = 1;
        }
    }
    fprintf(out, "%s(", builtin_intrinsic_name(full_name));
    for (int i = 0; i < n_emit; i++) {
        if (i) fprintf(out, ", ");
        const struct ASTExpr *arg_i = (e->value.call.args && (arg_start + i) < e->value.call.num_args) ? e->value.call.args[arg_start + i] : NULL;
        {
            int r = codegen_emit_io_driver_arg0(out, e, i, arg_i);
            if (r == -1) return -1;
            if (r == 1) continue;
        }
        if (codegen_emit_one_call_arg(out, arg_i) != 0) return -1;
    }
    fprintf(out, ")");
    return 0;
}

/** CALL 库模块内同模块：前缀名 + args。 */
static int codegen_emit_call_library_same_impl(FILE *out, const struct ASTExpr *e) {
    const char *callee_name = e->value.call.callee->value.var.name;
    const struct ASTFunc *f = NULL;
    /* 【Why 根源】优先用 typeck 设置的 resolved_callee_func，避免同模块重载函数
     * （如 std.heap 的 alloc 有 7 个重载：alloc(i32)->*u64, alloc(Allocator,usize)->*u8, ...）
     * 按名查找时选中 funcs[] 中第一个同名函数而非参数类型/个数精确匹配的重载。
     * typeck_pick_overload_in_module 已按 num_params+type_assignable_to 选取唯一重载，
     * codegen 必须尊重 typeck 的决议，否则 bump(al,size) 内调 alloc(al,size) 会误绑到
     * alloc(count:i32)->*u64（funcs[] 首个 alloc），生成 mod_alloc_i32_ret_u64_ptr(al,size)
     * 导致 cc 报 "too many arguments, expected 1, have 2"。
     * 【Invariant】resolved_callee_func 仅在 typeck 成功解析时非 NULL；未设置（如部分
     * typeck 未覆盖路径）时回退到按名查找，保持向后兼容。
     * 【Asm/Perf】无运行期开销，编译期决议。 */
    if (e->value.call.resolved_callee_func) {
        f = e->value.call.resolved_callee_func;
    } else {
        for (int i = 0; i < codegen_library_module->num_funcs && codegen_library_module->funcs; i++) {
            if (!codegen_library_module->funcs[i]) continue;
            if (codegen_library_module->funcs[i]->name && callee_name && strcmp(codegen_library_module->funcs[i]->name, callee_name) == 0) {
                f = codegen_library_module->funcs[i];
                break;
            }
        }
    }
    if (!f || f->is_extern) return -1;
    char cname[256];
    /* L9：#[no_mangle] 同模块调用也不加 library_prefix，与定义端一致 */
    if (f->is_no_mangle)
        snprintf(cname, sizeof(cname), "%s", call_instance_mangled_name(f, e));
    else
        library_prefixed_name(call_instance_mangled_name(f, e), cname, sizeof(cname));
    fprintf(out, "%s(", builtin_intrinsic_name(cname));
    for (int i = 0; i < e->value.call.num_args; i++) {
        if (i) fprintf(out, ", ");
        if (codegen_emit_one_call_arg(out, e->value.call.args[i]) != 0) return -1;
    }
    fprintf(out, ")");
    return 0;
}

/** CALL 库模块内跨模块（依赖）：dep_prefix + name(args)。std.io 调 std.io.driver 的 register/submit_* 时首参须转为 (ptrdiff_t)(uintptr_t)&buf 或 (ptrdiff_t)(uintptr_t)ptr，与 codegen_emit_call_import_path_impl 一致。 */
static int codegen_emit_call_library_dep_impl(FILE *out, const struct ASTExpr *e) {
    const char *callee_name = e->value.call.callee->value.var.name;
    const char *dep_fn;
    if (!callee_name) return -1;
    dep_fn = codegen_import_select_source_name(callee_name);
    for (int di = 0; di < codegen_ndep; di++) {
        const struct ASTModule *dm = codegen_dep_mods[di];
        if (!dm || !dm->funcs) continue;
        for (int fi = 0; fi < dm->num_funcs; fi++) {
            if (!dm->funcs[fi]) continue;
            if (dm->funcs[fi]->name && strcmp(dm->funcs[fi]->name, dep_fn) == 0) {
                const struct ASTFunc *f = dm->funcs[fi];
                const char *dep_path = codegen_dep_paths[di];
                char pre[256];
                char full_name[256];
                import_path_to_c_prefix(dep_path, pre, sizeof(pre));
                if (f->is_extern || !f->body)
                    (void)snprintf(full_name, sizeof(full_name), "%s", dep_fn);
                else
                    codegen_join_import_prefix_func_name(pre, dep_fn, full_name, sizeof(full_name));
                fprintf(out, "%s(", builtin_intrinsic_name(full_name));
                /* submit_register_fixed_buffers_buf 首参为 struct *，不转 ptrdiff_t */
                int need_io_driver_cast = (dep_path && (strcmp(dep_path, "std.io.driver") == 0 || strcmp(dep_path, "std/io/driver") == 0)
                    && (strcmp(dep_fn, "register") == 0 || strcmp(dep_fn, "submit_read") == 0 || strcmp(dep_fn, "submit_write") == 0)
                    && f->num_params >= 1 && f->params);
                for (int i = 0; i < e->value.call.num_args; i++) {
                    if (i) fprintf(out, ", ");
                    if (need_io_driver_cast && i == 0) {
                        const struct ASTExpr *arg_i = (e->value.call.args && i < e->value.call.num_args) ? e->value.call.args[i] : NULL;
                        if (arg_i && f->params[0].type && f->params[0].type->kind == AST_TYPE_PTR) {
                            fprintf(out, "(ptrdiff_t)(uintptr_t)(");
                            if (codegen_emit_one_call_arg(out, arg_i) != 0) return -1;
                            fprintf(out, ")");
                        } else if (arg_i) {
                            fprintf(out, "(ptrdiff_t)(uintptr_t)&(");
                            if (codegen_emit_one_call_arg(out, arg_i) != 0) return -1;
                            fprintf(out, ")");
                        } else if (codegen_emit_one_call_arg(out, arg_i) != 0) return -1;
                    } else if (codegen_emit_one_call_arg(out, e->value.call.args[i]) != 0) return -1;
                }
                fprintf(out, ")");
                return 0;
            }
        }
    }
    return -1;
}

/** CALL 入口模块泛型单态化：builtin_intrinsic_name(mono_mangled)(args)。 */
static int codegen_emit_call_mono_impl(FILE *out, const struct ASTExpr *e) {
    {
        int layout_r = codegen_try_emit_type_layout_intrinsic(out, e);
        if (layout_r == 1) return 0;
        if (layout_r < 0) return -1;
    }
    const char *callee_name = e->value.call.callee->value.var.name;
    const struct ASTFunc *func = NULL;
    for (int i = 0; i < codegen_current_module->num_funcs; i++) {
        if (!codegen_current_module->funcs[i]) continue;
        if (codegen_current_module->funcs[i]->name && callee_name
            && strcmp(codegen_current_module->funcs[i]->name, callee_name) == 0) {
            func = codegen_current_module->funcs[i];
            break;
        }
    }
    if (!func || !codegen_current_module->mono_instances) return -1;
    for (int k = 0; k < codegen_current_module->num_mono_instances; k++) {
        if (codegen_current_module->mono_instances[k].template != func) continue;
        if (codegen_current_module->mono_instances[k].num_type_args != e->value.call.num_type_args) continue;
        int eq = 1;
        for (int j = 0; j < e->value.call.num_type_args; j++) {
            if (!type_equal(codegen_current_module->mono_instances[k].type_args[j], e->value.call.type_args[j])) { eq = 0; break; }
        }
        if (eq) {
            fprintf(out, "%s(", builtin_intrinsic_name(mono_instance_mangled_name(func, e->value.call.type_args, e->value.call.num_type_args)));
            for (int i = 0; i < e->value.call.num_args; i++) {
                if (i) fprintf(out, ", ");
                if (codegen_emit_one_call_arg(out, e->value.call.args[i]) != 0) return -1;
            }
            fprintf(out, ")");
            return 0;
        }
    }
    return -1;
}

/** .x 侧 CALL 分发：1=import_path，2=library_same，3=library_dep，4=mono，0=fallback。供 codegen.x 的 emit_call_expr 统一入口。 */
int32_t codegen_x_call_dispatch_kind(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_CALL) return 0;
    if (e->value.call.resolved_import_path && e->value.call.resolved_callee_func) return 1;
    if (codegen_library_prefix && *codegen_library_prefix && codegen_library_module && e->value.call.callee && e->value.call.callee->kind == AST_EXPR_VAR) {
        const char *callee_name = e->value.call.callee->value.var.name;
        for (int i = 0; i < codegen_library_module->num_funcs && codegen_library_module->funcs; i++) {
            if (!codegen_library_module->funcs[i]) continue;
            if (codegen_library_module->funcs[i]->name && callee_name && strcmp(codegen_library_module->funcs[i]->name, callee_name) == 0) {
                if (!codegen_library_module->funcs[i]->is_extern) return 2;
                break;
            }
        }
    }
    if (codegen_library_prefix && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths && e->value.call.callee && e->value.call.callee->kind == AST_EXPR_VAR && e->value.call.callee->value.var.name) {
        const char *callee_name = e->value.call.callee->value.var.name;
        for (int di = 0; di < codegen_ndep; di++) {
            const struct ASTModule *dm = codegen_dep_mods[di];
            if (!dm || !dm->funcs) continue;
            for (int fi = 0; fi < dm->num_funcs; fi++) {
                if (!dm->funcs[fi]) continue;
                if (dm->funcs[fi]->name && strcmp(dm->funcs[fi]->name, callee_name) == 0) return 3;
            }
        }
    }
    if (e->value.call.num_type_args > 0 && codegen_current_module && e->value.call.callee && e->value.call.callee->kind == AST_EXPR_VAR) {
        const char *callee_name = e->value.call.callee->value.var.name;
        const struct ASTFunc *func = NULL;
        for (int i = 0; i < codegen_current_module->num_funcs; i++) {
            if (!codegen_current_module->funcs[i]) continue;
            if (codegen_current_module->funcs[i]->name && callee_name && strcmp(codegen_current_module->funcs[i]->name, callee_name) == 0) {
                func = codegen_current_module->funcs[i];
                break;
            }
        }
        if (func && codegen_current_module->mono_instances) {
            for (int k = 0; k < codegen_current_module->num_mono_instances; k++) {
                if (codegen_current_module->mono_instances[k].template != func) continue;
                if (codegen_current_module->mono_instances[k].num_type_args != e->value.call.num_type_args) continue;
                int eq = 1;
                for (int j = 0; j < e->value.call.num_type_args; j++) {
                    if (!type_equal(codegen_current_module->mono_instances[k].type_args[j], e->value.call.type_args[j])) { eq = 0; break; }
                }
                if (eq) return 4;
            }
        }
    }
    return 0;
}

/** .x 自实现 CALL 用：仅将「调用目标」prefix+name 写入 out，不写 '(' 与实参。返回 0 成功，-1 失败。 */
int32_t codegen_x_emit_call_import_path_target(uint8_t *out, uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_CALL || !e->value.call.resolved_import_path || !e->value.call.resolved_callee_func) return -1;
    char pre[256];
    import_path_to_c_prefix(e->value.call.resolved_import_path, pre, sizeof(pre));
    const struct ASTFunc *f = e->value.call.resolved_callee_func;
    if (f->is_extern) {
        const char *name = (e->value.call.num_type_args > 0 && e->value.call.type_args)
            ? mono_instance_mangled_name_ex(codegen_module_for_import_path(e->value.call.resolved_import_path), f,
                e->value.call.type_args, e->value.call.num_type_args)
            : (f->name ? f->name : "");
        fprintf((FILE *)out, "%s", name);
    } else {
        const char *name = (e->value.call.num_type_args > 0 && e->value.call.type_args)
            ? mono_instance_mangled_name_ex(codegen_module_for_import_path(e->value.call.resolved_import_path), f,
                e->value.call.type_args, e->value.call.num_type_args) : (f->name ? f->name : "");
        fprintf((FILE *)out, "%s%s", pre, name);
    }
    return 0;
}
int32_t codegen_x_emit_call_library_same_target(uint8_t *out, uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_CALL || !codegen_library_prefix || !*codegen_library_prefix || !codegen_library_module
        || !e->value.call.callee || e->value.call.callee->kind != AST_EXPR_VAR) return -1;
    const char *callee_name = e->value.call.callee->value.var.name;
    const struct ASTFunc *f = NULL;
    for (int i = 0; i < codegen_library_module->num_funcs && codegen_library_module->funcs; i++) {
        if (!codegen_library_module->funcs[i]) continue;
        if (codegen_library_module->funcs[i]->name && callee_name && strcmp(codegen_library_module->funcs[i]->name, callee_name) == 0) {
            f = codegen_library_module->funcs[i];
            break;
        }
    }
    if (!f || f->is_extern) return -1;
    char cname[256];
    if (e->value.call.num_type_args > 0 && e->value.call.type_args)
        library_prefixed_name(mono_instance_mangled_name_ex(codegen_library_module, f,
            e->value.call.type_args, e->value.call.num_type_args), cname, sizeof(cname));
    else
        library_prefixed_name(f->name ? f->name : "", cname, sizeof(cname));
    fprintf((FILE *)out, "%s", cname);
    return 0;
}
int32_t codegen_x_emit_call_library_dep_target(uint8_t *out, uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_CALL || !codegen_ndep || !codegen_dep_mods || !codegen_dep_paths
        || !e->value.call.callee || e->value.call.callee->kind != AST_EXPR_VAR) return -1;
    const char *callee_name = e->value.call.callee->value.var.name;
    if (!callee_name) return -1;
    for (int di = 0; di < codegen_ndep; di++) {
        const struct ASTModule *dm = codegen_dep_mods[di];
        if (!dm || !dm->funcs) continue;
        for (int fi = 0; fi < dm->num_funcs; fi++) {
            if (!dm->funcs[fi]) continue;
            if (dm->funcs[fi]->name && strcmp(dm->funcs[fi]->name, callee_name) == 0) {
                const struct ASTFunc *f = dm->funcs[fi];
                if (f->is_extern) {
                    fprintf((FILE *)out, "%s", callee_name);
                } else {
                    char pre[256];
                    import_path_to_c_prefix(codegen_dep_paths[di], pre, sizeof(pre));
                    fprintf((FILE *)out, "%s%s", pre, callee_name);
                }
                return 0;
            }
        }
    }
    return -1;
}
int32_t codegen_x_emit_call_mono_target(uint8_t *out, uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_CALL || !codegen_current_module || !e->value.call.callee || e->value.call.callee->kind != AST_EXPR_VAR) return -1;
    const char *callee_name = e->value.call.callee->value.var.name;
    const struct ASTFunc *func = NULL;
    for (int i = 0; i < codegen_current_module->num_funcs; i++) {
        if (!codegen_current_module->funcs[i]) continue;
        if (codegen_current_module->funcs[i]->name && callee_name && strcmp(codegen_current_module->funcs[i]->name, callee_name) == 0) {
            func = codegen_current_module->funcs[i];
            break;
        }
    }
    if (!func || !codegen_current_module->mono_instances) return -1;
    for (int k = 0; k < codegen_current_module->num_mono_instances; k++) {
        if (codegen_current_module->mono_instances[k].template != func) continue;
        if (codegen_current_module->mono_instances[k].num_type_args != e->value.call.num_type_args) continue;
        int eq = 1;
        for (int j = 0; j < e->value.call.num_type_args; j++) {
            if (!type_equal(codegen_current_module->mono_instances[k].type_args[j], e->value.call.type_args[j])) { eq = 0; break; }
        }
        if (eq) {
            fprintf((FILE *)out, "%s", builtin_intrinsic_name(mono_instance_mangled_name(func, e->value.call.type_args, e->value.call.num_type_args)));
            return 0;
        }
    }
    return -1;
}

int32_t codegen_x_emit_call_import_path_full(uint8_t *out, uint8_t *expr) { return codegen_emit_call_import_path_impl((FILE *)out, (const struct ASTExpr *)expr) != 0 ? -1 : 0; }
int32_t codegen_x_emit_call_library_same_full(uint8_t *out, uint8_t *expr) { return codegen_emit_call_library_same_impl((FILE *)out, (const struct ASTExpr *)expr) != 0 ? -1 : 0; }
int32_t codegen_x_emit_call_library_dep_full(uint8_t *out, uint8_t *expr) { return codegen_emit_call_library_dep_impl((FILE *)out, (const struct ASTExpr *)expr) != 0 ? -1 : 0; }
int32_t codegen_x_emit_call_mono_full(uint8_t *out, uint8_t *expr) { return codegen_emit_call_mono_impl((FILE *)out, (const struct ASTExpr *)expr) != 0 ? -1 : 0; }

/** 阶段 8.1 块内 DCE 前向声明：收集块内被引用变量名、判断是否在 used 集合中。 */
static void collect_var_names_from_block(const struct ASTBlock *b, const char **out, int *n, int max);
static int is_var_used(const char *name, const char **used, int n_used);
static int let_init_has_side_effects(const struct ASTExpr *init);
static int codegen_emit_unused_let_side_effect(FILE *out, const char *pad, const struct ASTExpr *linit);

/**
 * 按逆序生成执行本块所有 defer 块的 C 代码（块退出时执行）。
 * 参数：out 输出流；b 当前块（含 defer_blocks）；indent 缩进（2 或 4）。
 */
static int codegen_run_defers(FILE *out, const struct ASTBlock *b, int indent) {
    if (!b || !out || !b->defer_blocks) return 0;
    for (int i = b->num_defers - 1; i >= 0; i--) {
        if (codegen_block_body(b->defer_blocks[i], indent, out, 0, 0, NULL) != 0) return -1;
    }
    return 0;
}

/**
 * 将块体生成到 out：const/let 声明（带 indent 空格缩进），再 labeled_stmts（label/goto/return）、run_defers，再 final_expr。
 * 若 final_expr 为 break/continue/return/panic 则生成对应语句，否则 (void)(final_expr); 或 final_result_var = (expr);（当 final_result_var 非 NULL 时）。
 * 用于 main 块或 while 体；indent 为每行前空格数（如 2 或 4）。final_result_var 用于 if-expr 的 then/else 块，将块结果赋给该变量（如 "__tmp"）。
 */
#define MAX_BLOCK_USED_VARS 128

/**
 * let 初值为 ast_arena_expr_get / ast_arena_type_get / ast_arena_block_get 调用时，
 * 改为先声明变量再用 memcpy 从 arena 槽位直接拷贝到栈上变量，零外部依赖。
 * @return 1 已生成；-1 子表达式生成失败；0 不匹配，走原有「= codegen_init」路径。
 */
static int try_emit_let_arena_get_into(FILE *out, const char *pad, const struct ASTBlock *b,
    const char *name, const struct ASTType *ty, const struct ASTType *ety,
    const struct ASTExpr *linit) {
    (void)b;
    (void)ty;
    if (!linit || linit->kind != AST_EXPR_CALL) return 0;
    const struct ASTExpr *callee = linit->value.call.callee;
    if (!callee || callee->kind != AST_EXPR_VAR || !callee->value.var.name) return 0;
    const char *fn = callee->value.var.name;
    const char *arena_field = NULL;
    if (strcmp(fn, "ast_arena_expr_get") == 0) arena_field = "exprs";
    else if (strcmp(fn, "ast_arena_type_get") == 0) arena_field = "types";
    else if (strcmp(fn, "ast_arena_block_get") == 0) arena_field = "blocks";
    else return 0;
    if (linit->value.call.num_args < 1) return 0;

    /* 先声明变量（不带初始化） */
    if (ety && ety->kind == AST_TYPE_PTR && ety->elem_type)
        fprintf(out, "%s%s * %s;\n", pad, c_type_str(ety->elem_type), name);
    else if (ety && ety->kind == AST_TYPE_NAMED && ety->name)
        fprintf(out, "%s%s %s;\n", pad, c_type_str(ety), name);
    else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
        fprintf(out, "%s", pad);
        emit_local_array_decl(ety, name, "", out);
        fprintf(out, ";\n");
    } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) {
        ensure_slice_struct(ety, out);
        fprintf(out, "%s%s %s;\n", pad, c_type_str(ety), name);
    } else
        fprintf(out, "%s%s %s;\n", pad, ety ? c_type_str(ety) : "int32_t", name);

    /* C-04 -E-extern 瘦 TU：slim ASTArena 无内联 pool 数组，直接 emit getter 调用（替代 fix_parser_pool perl）。 */
    if (codegen_emitted_type_names) {
        fprintf(out, "%s%s = ", pad, name);
        if (codegen_expr(linit, out) != 0) return -1;
        fprintf(out, ";\n");
        return 1;
    }
    /* 单文件全量 TU：memcpy 读 arena 槽位，零外部 getter 依赖 */
    fprintf(out, "%smemcpy(&%s, &", pad, name);
    if (codegen_expr(linit->value.call.args[0], out) != 0) return -1;
    fprintf(out, "->%s[", arena_field);
    if (codegen_expr(linit->value.call.args[1], out) != 0) return -1;
    fprintf(out, " - 1], sizeof(%s));\n", name);
    return 1;
}

/**
 * 判定表达式语句是否为赋值/复合赋值（可直接 emit `left op= right;`）。
 * 包 (void) 会阻断 cc -O3 对常量循环的折叠（B-CMP struct_param 等 bench）。
 */
static int codegen_expr_is_assign_stmt(const struct ASTExpr *st) {
    if (!st)
        return 0;
    switch (st->kind) {
    case AST_EXPR_ASSIGN:
    case AST_EXPR_ADD_ASSIGN:
    case AST_EXPR_SUB_ASSIGN:
    case AST_EXPR_MUL_ASSIGN:
    case AST_EXPR_DIV_ASSIGN:
    case AST_EXPR_MOD_ASSIGN:
    case AST_EXPR_BITAND_ASSIGN:
    case AST_EXPR_BITOR_ASSIGN:
    case AST_EXPR_BITXOR_ASSIGN:
    case AST_EXPR_SHL_ASSIGN:
    case AST_EXPR_SHR_ASSIGN:
        return 1;
    default:
        return 0;
    }
}

/**
 * 若 st 为 `var = var (+/-) 整数字面量`，emit `++var`/`--var`/`var += n` 并返回 1；否则返回 0。
 * 便于 cc -O3 识别归纳变量（mem_copy 等 B-CMP bench）。
 */
static int codegen_try_emit_var_plus_lit_stmt(FILE *out, const char *pad, const struct ASTExpr *st) {
    const struct ASTExpr *left;
    const struct ASTExpr *right;
    const struct ASTExpr *lhs;
    const struct ASTExpr *rhs;
    const char *vname;

    if (!st || st->kind != AST_EXPR_ASSIGN)
        return 0;
    left = st->value.binop.left;
    right = st->value.binop.right;
    if (!left || left->kind != AST_EXPR_VAR || !left->value.var.name)
        return 0;
    vname = left->value.var.name;
    if (!right || right->kind != AST_EXPR_ADD)
        return 0;
    /* 【Why 根源】仅库模块顶层 let 变量名须加前缀（与声明一致）。
     * 局部变量（函数形参/let）声明不带前缀，引用也不带前缀，否则 C 编译报 undeclared identifier。
     * 与 AST_EXPR_VAR codegen（codegen.c:3039）的判断逻辑保持严格一致。
     * 【Invariant】prefixed_buf 生命周期仅本函数内；vname 仍指向 AST 原名。 */
    char prefixed_buf[256];
    const char *cvname = vname;
    if (codegen_library_prefix && *codegen_library_prefix && codegen_library_module
        && codegen_current_module == codegen_library_module
        && codegen_current_module->top_level_lets) {
        int is_top_let = 0;
        for (int i = 0; i < codegen_current_module->num_top_level_lets; i++) {
            if (codegen_current_module->top_level_lets[i].name
                && strcmp(codegen_current_module->top_level_lets[i].name, vname) == 0) {
                is_top_let = 1;
                break;
            }
        }
        if (is_top_let) {
            library_prefixed_name(vname, prefixed_buf, sizeof(prefixed_buf));
            cvname = prefixed_buf;
        }
    }
    lhs = right->value.binop.left;
    rhs = right->value.binop.right;
    if (lhs && lhs->kind == AST_EXPR_VAR && lhs->value.var.name &&
        strcmp(lhs->value.var.name, vname) == 0 && rhs && rhs->kind == AST_EXPR_LIT) {
        if (rhs->value.int_val == 1) {
            fprintf(out, "%s++%s;\n", pad, cvname);
            return 1;
        }
        if (rhs->value.int_val == -1) {
            fprintf(out, "%s--%s;\n", pad, cvname);
            return 1;
        }
        fprintf(out, "%s%s += ", pad, cvname);
        if (codegen_expr(rhs, out) != 0)
            return -1;
        fprintf(out, ";\n");
        return 1;
    }
    if (rhs && rhs->kind == AST_EXPR_VAR && rhs->value.var.name &&
        strcmp(rhs->value.var.name, vname) == 0 && lhs && lhs->kind == AST_EXPR_LIT) {
        if (lhs->value.int_val == 1) {
            fprintf(out, "%s++%s;\n", pad, cvname);
            return 1;
        }
        if (lhs->value.int_val == -1) {
            fprintf(out, "%s--%s;\n", pad, cvname);
            return 1;
        }
        fprintf(out, "%s%s += ", pad, cvname);
        if (codegen_expr(lhs, out) != 0)
            return -1;
        fprintf(out, ";\n");
        return 1;
    }
    return 0;
}

/* 前向声明：codegen_emit_if_branch_stmt 递归处理 else if 链时调 codegen_emit_if_stmt。 */
static int codegen_emit_if_stmt(FILE *out, const char *pad, const struct ASTExpr *st);

/**
 * IF 分支 statement 形式 emit：BLOCK → `{ ... }`；RETURN/BREAK/CONTINUE 直出；其他 → `{ expr; }`。
 * 【Why 根源治理】statement-if 的 then/else 不需要返回值，直接生成 C 语句形式，
 * 不走 codegen_emit_if_expr_impl 的 `({ __tmp; })` 表达式路径——后者假设需要值。
 * 【Invariant】仅 statement 位置调用；表达式位置仍走 codegen_emit_if_expr_impl。
 * 【Asm/Perf】cc -O2 后直接生成 jcc/jmp，无临时变量、无 (void) 包裹。
 */
static int codegen_emit_if_branch_stmt(FILE *out, const char *pad, const struct ASTExpr *br) {
    if (!br) { fprintf(out, "{}"); return 0; }
    if (br->kind == AST_EXPR_BLOCK) {
        fprintf(out, "{ ");
        /* 【Why 根源治理】is_void_return_context=0：statement-if 的 then/else BLOCK 内
         * return 应正常返回值（return expr;），不应被 (void)(expr); return; 丢弃。
         * 此前传 1 导致 regex_re_from_handle 的 `if (re==0) { return 0; }` 被生成为
         * `if (re==0) { (void)(0); return; }` —— return 无值，cc 报 return-mismatch。 */
        if (codegen_block_body(br->value.block, 2, out, 0, 0, NULL) != 0) return -1;
        fprintf(out, " }");
        return 0;
    }
    if (br->kind == AST_EXPR_RETURN) {
        fprintf(out, "{ ");
        if (br->value.unary.operand) {
            fprintf(out, "return ");
            if (codegen_expr(br->value.unary.operand, out) != 0) return -1;
            fprintf(out, ";");
        } else {
            fprintf(out, "return;");
        }
        fprintf(out, " }");
        return 0;
    }
    if (br->kind == AST_EXPR_CONTINUE) { fprintf(out, "{ continue; }"); return 0; }
    if (br->kind == AST_EXPR_BREAK) { fprintf(out, "{ break; }"); return 0; }
    /* 【Why 根源治理 B 组】else if 链：else 分支本身是另一个 IF（parser 把
     * `if (c1) {...} else if (c2) {...} else if (c3) {...}` 解析为嵌套 IF）。
     * 递归调 codegen_emit_if_stmt 生成 `else if (c2) {...} else ...` statement 形式，
     * 不走 codegen_expr 表达式路径——后者会生成 `({ __tmp; })` 导致类型混乱。 */
    if (br->kind == AST_EXPR_IF) {
        return codegen_emit_if_stmt(out, pad, br);
    }
    /* 普通表达式 → 表达式语句形式 */
    fprintf(out, "{ ");
    if (codegen_expr(br, out) != 0) return -1;
    fprintf(out, "; }");
    return 0;
}

/**
 * IF statement 形式 emit：直接生成 `if (cond) { then } else { else }`，不走表达式路径。
 * 根源治理 B 组：消除 statement-if 被当表达式处理生成的 `({ __tmp; })` 与 (void) 包裹。
 */
static int codegen_emit_if_stmt(FILE *out, const char *pad, const struct ASTExpr *st) {
    const struct ASTExpr *cond = st->value.if_expr.cond;
    const struct ASTExpr *then_e = st->value.if_expr.then_expr;
    const struct ASTExpr *else_e = st->value.if_expr.else_expr;
    fprintf(out, "%sif (", pad);
    if (codegen_expr(cond, out) != 0) return -1;
    fprintf(out, ") ");
    if (codegen_emit_if_branch_stmt(out, pad, then_e) != 0) return -1;
    if (else_e) {
        fprintf(out, " else ");
        if (codegen_emit_if_branch_stmt(out, pad, else_e) != 0) return -1;
    }
    fprintf(out, "\n");
    return 0;
}

/**
 * C 路径输出一条表达式语句：continue/break/return 直出；赋值 emit `expr;`；其余 `(void)(expr);`。
 * 返回 0 成功，-1 失败。
 */
static int codegen_emit_expr_stmt(FILE *out, const char *pad, const struct ASTExpr *st) {
    if (!st)
        return -1;
    if (st->kind == AST_EXPR_CONTINUE) {
        fprintf(out, "%scontinue;\n", pad);
        return 0;
    }
    if (st->kind == AST_EXPR_BREAK) {
        fprintf(out, "%sbreak;\n", pad);
        return 0;
    }
    if (st->kind == AST_EXPR_RETURN) {
        if (st->value.unary.operand) {
            const struct ASTType *rt = (codegen_current_func && codegen_current_func->return_type) ? codegen_current_func->return_type : NULL;
            if (rt && rt->kind == AST_TYPE_ARRAY && rt->array_size > 0) {
                const char *wn = arr_ret_wrapper_name(rt);
                fprintf(out, "%sreturn ((struct %s){ .data = ", pad, wn);
                if (codegen_expr(st->value.unary.operand, out) != 0) return -1;
                fprintf(out, " });\n");
            } else {
            fprintf(out, "%sreturn ", pad);
            if (codegen_expr(st->value.unary.operand, out) != 0)
                return -1;
            fprintf(out, ";\n");
            }
        } else {
            fprintf(out, "%sreturn;\n", pad);
        }
        return 0;
    }
    if (st->kind == AST_EXPR_ASM) {
        fprintf(out, "%s", pad);
        codegen_emit_asm_extended(out, st);
        fprintf(out, ";\n");
        /* asm goto!: emit C labels after the statement so GCC/clang can resolve %l[label] */
        if (st->value.asm_tmpl.is_goto) {
            int li;
            for (li = 0; li < st->value.asm_tmpl.num_labels; li++) {
                if (st->value.asm_tmpl.labels[li])
                    fprintf(out, "%s%s: ;\n", pad, st->value.asm_tmpl.labels[li]);
            }
        }
        return 0;
    }
    /* 【Why 根源治理 B 组】IF 处于 statement 位置时直接生成 C statement-if 形式，
     * 不走 codegen_expr 表达式路径——后者看到 then/else 为 RETURN/BREAK/CONTINUE
     * 就走 `({ __tmp; })` 表达式形式，生成 (void) 包裹的无意义临时变量，
     * 且 resolved_type NULL 时默认 "int32_t" 兜底导致类型不匹配。 */
    if (st->kind == AST_EXPR_IF) {
        return codegen_emit_if_stmt(out, pad, st);
    }
    if (codegen_expr_is_assign_stmt(st)) {
        {
            int inc_r = codegen_try_emit_var_plus_lit_stmt(out, pad, st);
            if (inc_r != 0)
                return inc_r < 0 ? -1 : 0;
        }
        fprintf(out, "%s", pad);
        if (codegen_expr(st, out) != 0)
            return -1;
        fprintf(out, ";\n");
        return 0;
    }
    fprintf(out, "%s(void)(", pad);
    if (codegen_expr(st, out) != 0)
        return -1;
    fprintf(out, ");\n");
    return 0;
}

static int codegen_block_body(const struct ASTBlock *b, int indent, FILE *out, int cast_return_to_int,
                              int is_void_return_context, const char *final_result_var) {
    if (!b || !out) return -1;
    const char *pad = (indent == 2) ? "  " : (indent == 4) ? "    " : "      ";
    /* 阶段 8.1 块内 DCE：仅输出被引用的 const/let */
    const char *used_buf[MAX_BLOCK_USED_VARS];
    int n_used = 0;
    collect_var_names_from_block(b, used_buf, &n_used, MAX_BLOCK_USED_VARS);
    /* 有 stmt_order 时一律按源码顺序输出 const/let/expr/loop/for，保证 skip_whitespace 等「while; continue」与 copy_onefunc_into「let; while; expr」顺序正确。 */
    int use_stmt_order = (b->num_stmt_order > 0) ? 1 : 0;
#ifdef SHUX_USE_X_CODEGEN
    if (b->num_stmt_order > 0 && use_stmt_order) {
        if (codegen_codegen_x_emit_block_stmt_order((uint8_t *)out, (uint8_t *)b, indent, cast_return_to_int) != 0) return -1;
    } else {
#else
    if (b->num_stmt_order > 0 && use_stmt_order) {
        for (int i = 0; i < b->num_stmt_order; i++) {
            int k = (int)b->stmt_order[i].kind;
            int idx = b->stmt_order[i].idx;
            switch (k) {
            case 0: { /* const */
                if (idx >= b->num_consts) break;
                char name_place_c[32];
                const char *name = (b->const_decls[idx].name && b->const_decls[idx].name[0]) ? b->const_decls[idx].name : (snprintf(name_place_c, sizeof(name_place_c), "_c%d", idx), name_place_c);
                if (!is_var_used(name, used_buf, n_used)) break;
                const struct ASTType *ty = b->const_decls[idx].type;
                const struct ASTExpr *cinit = b->const_decls[idx].init;
                const struct ASTType *ety = codegen_emit_type(ty);
                if (ety && ety->kind == AST_TYPE_NAMED && ety->name) fprintf(out, "%sconst %s %s = ", pad, c_type_str(ety), name);
                else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
                    fprintf(out, "%sconst ", pad);
                    emit_local_array_decl(ety, name, "", out);
                    if (cinit && cinit->kind == AST_EXPR_VAR && cinit->value.var.name) {
                        fprintf(out, ";\n%smemcpy(%s, %s, sizeof(%s));\n", pad, name, cinit->value.var.name, name);
                        break;
                    }
                    if (cinit && cinit->kind == AST_EXPR_LIT && cinit->value.int_val == 0) {
                        fprintf(out, ";\n%smemset(%s, 0, sizeof(%s));\n", pad, name, name);
                        break;
                    }
                    if (cinit && cinit->kind != AST_EXPR_ARRAY_LIT) {
                        fprintf(out, ";\n%smemcpy(%s, (", pad, name);
                        if (codegen_expr(cinit, out) != 0) return -1;
                        fprintf(out, "), sizeof(%s));\n", name);
                        break;
                    }
                    fprintf(out, "= ");
                } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) { ensure_slice_struct(ety, out); fprintf(out, "%sconst %s %s = ", pad, c_type_str(ety), name); }
                else fprintf(out, "%sconst %s %s = ", pad, ety ? c_type_str(ety) : "int32_t", name);
                if (codegen_init(ty, cinit, out, b) != 0) return -1;
                fprintf(out, ";\n");
                break;
            }
            case 1: { /* let */
                if (idx >= b->num_lets) break;
                char name_place_l[32];
                const char *name = (b->let_decls[idx].name && b->let_decls[idx].name[0]) ? b->let_decls[idx].name : (snprintf(name_place_l, sizeof(name_place_l), "_l%d", idx), name_place_l);
                if (!is_var_used(name, used_buf, n_used)) {
                    int side = codegen_emit_unused_let_side_effect(out, pad, b->let_decls[idx].init);
                    if (side < 0) return -1;
                    break;
                }
                const struct ASTType *ty = b->let_decls[idx].type;
                const struct ASTExpr *linit = b->let_decls[idx].init;
                const struct ASTType *ety = codegen_emit_type(ty);
                /* A3 CPS：hoist 后的 let 用 assignment；await 边界保存/恢复帧。 */
                if (codegen_async_cps_active && linit) {
                    if (linit->kind == AST_EXPR_AWAIT) {
                        if (async_cps_expr_is_await_read_fd(linit)) {
                            if (codegen_async_cps_await_read_fd(&codegen_async_cps_ctx, linit, name, out, pad) != 0)
                                return -1;
                            break;
                        }
                        if (async_cps_expr_is_await_read(linit)) {
                            if (codegen_async_cps_await_read(&codegen_async_cps_ctx, linit, name, out, pad) != 0)
                                return -1;
                            break;
                        }
                        if (async_cps_expr_is_await_write_fd(linit)) {
                            if (codegen_async_cps_await_write_fd(&codegen_async_cps_ctx, linit, name, out, pad) != 0)
                                return -1;
                            break;
                        }
                        if (async_cps_expr_is_await_write(linit)) {
                            if (codegen_async_cps_await_write(&codegen_async_cps_ctx, linit, name, out, pad) != 0)
                                return -1;
                            break;
                        }
                        if (async_cps_expr_is_await_future_wait(linit)) {
                            if (codegen_async_cps_await_future_wait(&codegen_async_cps_ctx, linit, name, out, pad) != 0)
                                return -1;
                            break;
                        }
                        fprintf(out, "%s%s = ", pad, name);
                        if (codegen_expr(linit->value.unary.operand, out) != 0) return -1;
                        fprintf(out, ";\n");
                        if (async_cps_expr_is_io_await(linit)) {
                            if (async_cps_codegen_after_await_io(&codegen_async_cps_ctx, out, pad) != 0) return -1;
                        } else if (async_cps_codegen_after_await(&codegen_async_cps_ctx, out, pad) != 0) {
                            return -1;
                        }
                        break;
                    }
                    if (ety && ety->kind != AST_TYPE_ARRAY && ety->kind != AST_TYPE_SLICE) {
                        fprintf(out, "%s%s = ", pad, name);
                        if (codegen_init(ty, linit, out, b) != 0) return -1;
                        fprintf(out, ";\n");
                        break;
                    }
                }
                /* 若初值为 extern 调用且返回 slice 而 ty 未正确填为 SLICE，用 callee 返回类型兜底，避免生成 int32_t var = parser_slice_from_buf(...) 导致 run-hello 解析失败 */
                if ((!ety || ety->kind != AST_TYPE_SLICE) && linit && linit->kind == AST_EXPR_CALL && linit->value.call.resolved_callee_func) {
                    const struct ASTFunc *f = linit->value.call.resolved_callee_func;
                    if (f->return_type && f->return_type->kind == AST_TYPE_SLICE && f->return_type->elem_type) {
                        ensure_slice_struct(f->return_type, out);
                        fprintf(out, "%s%s %s = ", pad, c_type_str(f->return_type), name);
                        if (codegen_init(ty, linit, out, b) != 0) return -1;
                        fprintf(out, ";\n");
                        break;
                    }
                }
                { int into_r = try_emit_let_arena_get_into(out, pad, b, name, ty, ety, linit);
                  if (into_r == -1) return -1;
                  if (into_r == 1) break;
                }
                /** let x: T; 无显式初值：C 零初始化（与 asm 栈 prologue 清零一致，同 line 5200）。
                 *  【Why 逻辑根源】stmt_order 路径（case 1）必须与 early/late-let、func_body fallback 对无 init 行为对称，
                 *  否则会 emit `T name = ;`（带等号无值）致 C 语法错误，触发 codegen_one_func 返回 -1。
                 *  【Invariant】数组 emit `T name[64] = {0};`；指针 emit `T * name = 0;`；其它 emit `T name = {0};`。 */
                if (!linit) {
                    if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
                        fprintf(out, "%s", pad);
                        emit_local_array_decl(ety, name, "", out); fprintf(out, "= {0}");
                        fprintf(out, ";\n");
                    } else if (ety && ety->kind == AST_TYPE_PTR && ety->elem_type) {
                        if (ety->is_volatile)
                            fprintf(out, "%svolatile %s * %s = 0;\n", pad, c_type_str(ety->elem_type), name);
                        else
                            fprintf(out, "%s%s * %s = 0;\n", pad, c_type_str(ety->elem_type), name);
                    } else if (ety && ety->kind == AST_TYPE_NAMED && ety->name) {
                        fprintf(out, "%s%s %s = {0};\n", pad, c_type_str(ety), name);
                    } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) {
                        ensure_slice_struct(ety, out);
                        fprintf(out, "%s%s %s = {0};\n", pad, c_type_str(ety), name);
                    } else {
                        fprintf(out, "%s%s %s = {0};\n", pad, ety ? c_type_str(ety) : "int32_t", name);
                    }
                    break;
                }
                if (ety && ety->kind == AST_TYPE_PTR && ety->elem_type) {
                    /* K2：*volatile T 声明发 `volatile <elem> * name`，cc 据此不消除其解引用读写 */
                    if (ety->is_volatile)
                        fprintf(out, "%svolatile %s * %s = ", pad, c_type_str(ety->elem_type), name);
                    else
                        fprintf(out, "%s%s * %s = ", pad, c_type_str(ety->elem_type), name);
                }
                else if (ety && ety->kind == AST_TYPE_NAMED && ety->name) fprintf(out, "%s%s %s = ", pad, c_type_str(ety), name);
                else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
                    fprintf(out, "%s", pad);
                    emit_local_array_decl(ety, name, "", out);
                    if (linit->kind == AST_EXPR_VAR && linit->value.var.name) {
                        fprintf(out, ";\n%smemcpy(%s, %s, sizeof(%s));\n", pad, name, linit->value.var.name, name);
                        break;
                    }
                    if (linit->kind == AST_EXPR_LIT && linit->value.int_val == 0) {
                        fprintf(out, ";\n%smemset(%s, 0, sizeof(%s));\n", pad, name, name);
                        break;
                    }
                    if (linit->kind != AST_EXPR_ARRAY_LIT) {
                        fprintf(out, ";\n%smemcpy(%s, (", pad, name);
                        if (codegen_expr(linit, out) != 0) return -1;
                        fprintf(out, "), sizeof(%s));\n", name);
                        break;
                    }
                    fprintf(out, "= ");
                } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) { ensure_slice_struct(ety, out); fprintf(out, "%s%s %s = ", pad, c_type_str(ety), name); }
                else fprintf(out, "%s%s %s = ", pad, ety ? c_type_str(ety) : "int32_t", name);
                if (codegen_init(ty, linit, out, b) != 0) return -1;
                fprintf(out, ";\n");
                break;
            }
            case 2: { /* expr_stmt */
                if (idx >= b->num_expr_stmts) break;
                const struct ASTExpr *st = b->expr_stmts[idx];
#ifdef SHUX_USE_X_CODEGEN
                if (st->kind == AST_EXPR_CONTINUE) { if (codegen_codegen_x_emit_continue_stmt((uint8_t *)out, 2) != 0) return -1; }
                else if (st->kind == AST_EXPR_BREAK) { if (codegen_codegen_x_emit_break_stmt((uint8_t *)out, 2) != 0) return -1; }
                else if (st->kind == AST_EXPR_RETURN) {
                    if (st->value.unary.operand) {
                        if (is_void_return_context) {
                            fprintf(out, "%s(void)(", pad);
                            if (codegen_expr(st->value.unary.operand, out) != 0) return -1;
                            fprintf(out, ");\n%sreturn;\n", pad);
                        } else {
                            const struct ASTType *rt2 = (codegen_current_func && codegen_current_func->return_type) ? codegen_current_func->return_type : NULL;
                            if (rt2 && rt2->kind == AST_TYPE_ARRAY && rt2->array_size > 0) {
                                const char *wn2 = arr_ret_wrapper_name(rt2);
                                fprintf(out, "%sreturn ((struct %s){ .data = ", pad, wn2);
                                if (codegen_expr(st->value.unary.operand, out) != 0) return -1;
                                fprintf(out, " });\n");
                            } else {
                            fprintf(out, "%sreturn ", pad);
                            if (codegen_expr(st->value.unary.operand, out) != 0) return -1;
                            fprintf(out, ";\n");
                            }
                        }
                    }
                    else fprintf(out, "%sreturn;\n", pad);
                } else { if (codegen_codegen_x_emit_void_expr_stmt((uint8_t *)out, 2, (uint8_t *)st) != 0) return -1; }
#else
                if (codegen_emit_expr_stmt(out, pad, st) != 0) return -1;
#endif
                break;
            }
            case 3: /* loop */
                if (idx < b->num_loops) {
                    fprintf(out, "%swhile (", pad);
                    if (codegen_expr(b->loops[idx].cond, out) != 0) return -1;
                    fprintf(out, ") {\n");
                    if (codegen_block_body(b->loops[idx].body, indent + 2, out, cast_return_to_int, is_void_return_context, NULL) != 0) return -1;
                    fprintf(out, "%s}\n", pad);
                }
                break;
            case 4: /* for */
                if (idx < b->num_for_loops) {
                    fprintf(out, "%sfor (", pad);
                    if (b->for_loops[idx].init) { if (codegen_expr(b->for_loops[idx].init, out) != 0) return -1; }
                    fprintf(out, "; ");
                    if (b->for_loops[idx].cond) { if (codegen_expr(b->for_loops[idx].cond, out) != 0) return -1; }
                    fprintf(out, "; ");
                    if (b->for_loops[idx].step) { if (codegen_expr(b->for_loops[idx].step, out) != 0) return -1; }
                    fprintf(out, ") {\n");
                    if (codegen_block_body(b->for_loops[idx].body, indent + 2, out, cast_return_to_int, is_void_return_context, NULL) != 0) return -1;
                    fprintf(out, "%s}\n", pad);
                }
                break;
            case 5: /* region：编译期域标签，运行时等价嵌套块 */
                if (idx < b->num_regions) {
                    fprintf(out, "%s{\n", pad);
                    if (codegen_block_body(b->regions[idx].body, indent + 2, out, cast_return_to_int, is_void_return_context, NULL) != 0) return -1;
                    fprintf(out, "%s}\n", pad);
                }
                break;
            case 7: { /* try { } catch (r) { }：? 失败 goto catch，r 绑定 Result */
                if (idx >= b->num_try_catches) break;
                const ASTTryCatchBlock *tc = &b->try_catches[idx];
                int tid = codegen_try_id++;
                char r_var[64], catch_label[64], after_label[64];
                const char *rb = (tc->catch_bind && tc->catch_bind[0]) ? tc->catch_bind : NULL;
                if (!rb) { snprintf(r_var, sizeof r_var, "_shux_tc_r_%d", tid); rb = r_var; }
                snprintf(catch_label, sizeof catch_label, "_shux_tc_catch_%d", tid);
                snprintf(after_label, sizeof after_label, "_shux_tc_after_%d", tid);
                fprintf(out, "%s{\n", pad);
                if (tc->result_type) { char rtbuf[128]; c_type_to_buf(tc->result_type, rtbuf, sizeof rtbuf); fprintf(out, "%s%s %s;\n", pad, rtbuf, rb); }
                /* try 体：设置 ? 的 catch 上下文 */
                int prev_active = codegen_try_active; char prev_r[64]; char prev_cl[64];
                memcpy(prev_r, codegen_try_r_var, 64); memcpy(prev_cl, codegen_try_catch_label, 64);
                codegen_try_active = 1; strncpy(codegen_try_r_var, rb, 63); strncpy(codegen_try_catch_label, catch_label, 63);
                if (tc->try_body && codegen_block_body(tc->try_body, indent + 2, out, cast_return_to_int, is_void_return_context, NULL) != 0) return -1;
                codegen_try_active = prev_active; memcpy(codegen_try_r_var, prev_r, 64); memcpy(codegen_try_catch_label, prev_cl, 64);
                fprintf(out, "%sgoto %s;\n%s%s: ;\n", pad, after_label, pad, catch_label);
                if (tc->catch_body && codegen_block_body(tc->catch_body, indent + 2, out, cast_return_to_int, is_void_return_context, NULL) != 0) return -1;
                fprintf(out, "%s%s: ;\n%s}\n", pad, after_label, pad);
            } break;
            }
        }
    } else {
#endif
        /* 无 stmt_order：原逻辑 — const → early lets → expr/loops → late lets */
#ifdef SHUX_USE_X_CODEGEN
        if (codegen_codegen_x_emit_block_const_decls((uint8_t *)out, (uint8_t *)b, indent) != 0) return -1;
        int n_early = (b->num_early_lets > 0 && b->num_early_lets <= b->num_lets) ? b->num_early_lets : b->num_lets;
        if (codegen_codegen_x_emit_block_let_decls_range((uint8_t *)out, (uint8_t *)b, indent, 0, (int32_t)n_early) != 0) return -1;
#else
        for (int i = 0; i < b->num_consts; i++) {
            const char *name = b->const_decls[i].name ? b->const_decls[i].name : "";
            if (!is_var_used(name, used_buf, n_used)) continue;
            const struct ASTType *ty = b->const_decls[i].type;
            const struct ASTExpr *cinit = b->const_decls[i].init;
            const struct ASTType *ety = codegen_emit_type(ty);
            if (ety && ety->kind == AST_TYPE_NAMED && ety->name) fprintf(out, "%sconst %s %s = ", pad, c_type_str(ety), name);
            else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
                fprintf(out, "%sconst ", pad);
                emit_local_array_decl(ety, name, "", out);
                if (cinit && cinit->kind == AST_EXPR_VAR && cinit->value.var.name) {
                    fprintf(out, ";\n%smemcpy(%s, %s, sizeof(%s));\n", pad, name, cinit->value.var.name, name);
                    continue;
                }
                if (cinit && cinit->kind == AST_EXPR_LIT && cinit->value.int_val == 0) {
                    fprintf(out, ";\n%smemset(%s, 0, sizeof(%s));\n", pad, name, name);
                    continue;
                }
                if (cinit && cinit->kind != AST_EXPR_ARRAY_LIT) {
                    fprintf(out, ";\n%smemcpy(%s, (", pad, name);
                    if (codegen_expr(cinit, out) != 0) return -1;
                    fprintf(out, "), sizeof(%s));\n", name);
                    continue;
                }
                fprintf(out, "= ");
            } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) { ensure_slice_struct(ety, out); fprintf(out, "%sconst %s %s = ", pad, c_type_str(ety), name); }
            else { fprintf(out, "%sconst %s %s = ", pad, ety ? c_type_str(ety) : "int32_t", name); }
            if (codegen_init(ty, cinit, out, b) != 0) return -1;
            fprintf(out, ";\n");
        }
        int n_early = (b->num_early_lets > 0 && b->num_early_lets <= b->num_lets) ? b->num_early_lets : b->num_lets;
        for (int i = 0; i < n_early; i++) {
            char let_place_early[32];
            const char *name = (b->let_decls[i].name && b->let_decls[i].name[0] && (unsigned char)b->let_decls[i].name[0] > ' ') ? b->let_decls[i].name : (snprintf(let_place_early, sizeof(let_place_early), "_l%d", i), let_place_early);
            if (!is_var_used(name, used_buf, n_used)) {
                if (codegen_emit_unused_let_side_effect(out, pad, b->let_decls[i].init) < 0) return -1;
                continue;
            }
            const struct ASTType *ty = b->let_decls[i].type;
            const struct ASTExpr *linit = b->let_decls[i].init;
            const struct ASTType *ety = codegen_emit_type(ty);
            { int into_r = try_emit_let_arena_get_into(out, pad, b, name, ty, ety, linit);
              if (into_r == -1) return -1;
              if (into_r == 1) continue;
            }
            /** let x: T; 无显式初值：C 零初始化（与 asm 栈 prologue 清零一致，同 line 5200）。
             *  【Why 逻辑根源】early-let 分支与 late-let 必须对无 init 行为对称，否则会 emit `T name = ;`（带等号无值）致 C 语法错误。
             *  【Invariant】数组 emit `T name[64] = {0};`；指针 emit `T * name = 0;`；其它 emit `T name = {0};`。 */
            if (!linit) {
                if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
                    fprintf(out, "%s", pad);
                    emit_local_array_decl(ety, name, "", out); fprintf(out, "= {0}");
                    fprintf(out, ";\n");
                } else if (ety && ety->kind == AST_TYPE_PTR && ety->elem_type) {
                    fprintf(out, "%s%s * %s = 0;\n", pad, c_type_str(ety->elem_type), name);
                } else {
                    fprintf(out, "%s%s %s = {0};\n", pad, ety ? c_type_str(ety) : "int32_t", name);
                }
                continue;
            }
            if (ety && ety->kind == AST_TYPE_PTR && ety->elem_type) fprintf(out, "%s%s * %s = ", pad, c_type_str(ety->elem_type), name);
            else if (ety && ety->kind == AST_TYPE_NAMED && ety->name) fprintf(out, "%s%s %s = ", pad, c_type_str(ety), name);
            else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
                fprintf(out, "%s", pad);
                emit_local_array_decl(ety, name, "", out);
                if (linit->kind == AST_EXPR_VAR && linit->value.var.name) {
                    fprintf(out, ";\n%smemcpy(%s, %s, sizeof(%s));\n", pad, name, linit->value.var.name, name);
                    continue;
                }
                if (linit->kind != AST_EXPR_ARRAY_LIT) {
                    fprintf(out, ";\n%smemcpy(%s, (", pad, name);
                    if (codegen_expr(linit, out) != 0) return -1;
                    fprintf(out, "), sizeof(%s));\n", name);
                    continue;
                }
                fprintf(out, "= ");
            } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) { ensure_slice_struct(ety, out); fprintf(out, "%s%s %s = ", pad, c_type_str(ety), name); }
            else { fprintf(out, "%s%s %s = ", pad, ety ? c_type_str(ety) : "int32_t", name); }
            if (codegen_init(ty, linit, out, b) != 0) return -1;
            fprintf(out, ";\n");
        }
#endif
        int reorder_safe = (b->num_early_lets > 0 && b->num_early_lets < b->num_lets && b->num_loops == 0 && b->num_for_loops == 0);
        if (reorder_safe) {
            for (int i = 0; i < b->num_expr_stmts; i++) {
                const struct ASTExpr *st = b->expr_stmts[i];
#ifdef SHUX_USE_X_CODEGEN
                if (st->kind == AST_EXPR_CONTINUE) { if (codegen_codegen_x_emit_continue_stmt((uint8_t *)out, indent) != 0) return -1; }
                else if (st->kind == AST_EXPR_BREAK) { if (codegen_codegen_x_emit_break_stmt((uint8_t *)out, indent) != 0) return -1; }
                else if (st->kind == AST_EXPR_RETURN) { if (st->value.unary.operand) { if (codegen_codegen_x_emit_return_expr((uint8_t *)out, indent, (uint8_t *)st->value.unary.operand) != 0) return -1; } else { if (codegen_codegen_x_emit_return_no_val((uint8_t *)out, indent) != 0) return -1; } }
                else { if (codegen_codegen_x_emit_void_expr_stmt((uint8_t *)out, indent, (uint8_t *)st) != 0) return -1; }
#else
                if (st->kind == AST_EXPR_CONTINUE) fprintf(out, "%scontinue;\n", pad);
                else if (st->kind == AST_EXPR_BREAK) fprintf(out, "%sbreak;\n", pad);
                else if (st->kind == AST_EXPR_RETURN) { if (st->value.unary.operand) { fprintf(out, "%sreturn ", pad); if (codegen_expr(st->value.unary.operand, out) != 0) return -1; fprintf(out, ";\n"); } else fprintf(out, "%sreturn;\n", pad); }
                else if (codegen_emit_expr_stmt(out, pad, st) != 0) return -1;
#endif
            }
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_block_let_decls_range((uint8_t *)out, (uint8_t *)b, indent, (int32_t)b->num_early_lets, (int32_t)b->num_lets) != 0) return -1;
#else
            for (int i = b->num_early_lets; i < b->num_lets; i++) {
                char let_place_late[32];
                const char *name = (b->let_decls[i].name && b->let_decls[i].name[0] && (unsigned char)b->let_decls[i].name[0] > ' ') ? b->let_decls[i].name : (snprintf(let_place_late, sizeof(let_place_late), "_l%d", i), let_place_late);
                if (!is_var_used(name, used_buf, n_used)) {
                    if (codegen_emit_unused_let_side_effect(out, pad, b->let_decls[i].init) < 0) return -1;
                    continue;
                }
                const struct ASTType *ty = b->let_decls[i].type;
                const struct ASTExpr *linit_i = b->let_decls[i].init;
                const struct ASTType *ety = codegen_emit_type(ty);
                /** let x: T; 无显式初值：C 零初始化（与 asm 栈 prologue 清零一致）。 */
                if (!linit_i) {
                    if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
                        fprintf(out, "%s", pad);
                        emit_local_array_decl(ety, name, "", out); fprintf(out, "= {0}");
                        fprintf(out, ";\n");
                    } else if (ety && ety->kind == AST_TYPE_PTR && ety->elem_type) {
                        fprintf(out, "%s%s * %s = 0;\n", pad, c_type_str(ety->elem_type), name);
                    } else {
                        fprintf(out, "%s%s %s = {0};\n", pad, ety ? c_type_str(ety) : "int32_t", name);
                    }
                    continue;
                }
                if ((!ety || ety->kind != AST_TYPE_SLICE) && linit_i && linit_i->kind == AST_EXPR_CALL && linit_i->value.call.resolved_callee_func) {
                    const struct ASTFunc *f = linit_i->value.call.resolved_callee_func;
                    if (f->return_type && f->return_type->kind == AST_TYPE_SLICE && f->return_type->elem_type) {
                        ensure_slice_struct(f->return_type, out);
                        fprintf(out, "%s%s %s = ", pad, c_type_str(f->return_type), name);
                        if (codegen_init(ty, linit_i, out, b) != 0) return -1;
                        fprintf(out, ";\n");
                        continue;
                    }
                }
                { int into_r = try_emit_let_arena_get_into(out, pad, b, name, ty, ety, linit_i);
                  if (into_r == -1) return -1;
                  if (into_r == 1) continue;
                }
                if (ety && ety->kind == AST_TYPE_PTR && ety->elem_type) fprintf(out, "%s%s * %s = ", pad, c_type_str(ety->elem_type), name);
                else if (ety && ety->kind == AST_TYPE_NAMED && ety->name) fprintf(out, "%s%s %s = ", pad, c_type_str(ety), name);
                else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
                    fprintf(out, "%s", pad);
                    emit_local_array_decl(ety, name, "", out);
                    if (b->let_decls[i].init && b->let_decls[i].init->kind == AST_EXPR_VAR && b->let_decls[i].init->value.var.name) {
                        fprintf(out, ";\n%smemcpy(%s, %s, sizeof(%s));\n", pad, name, b->let_decls[i].init->value.var.name, name);
                        continue;
                    }
                    if (b->let_decls[i].init && b->let_decls[i].init->kind == AST_EXPR_LIT && b->let_decls[i].init->value.int_val == 0) {
                        fprintf(out, ";\n%smemset(%s, 0, sizeof(%s));\n", pad, name, name);
                        continue;
                    }
                    if (b->let_decls[i].init && b->let_decls[i].init->kind != AST_EXPR_ARRAY_LIT) {
                        fprintf(out, ";\n%smemcpy(%s, (", pad, name);
                        if (codegen_expr(b->let_decls[i].init, out) != 0) return -1;
                        fprintf(out, "), sizeof(%s));\n", name);
                        continue;
                    }
                    fprintf(out, "= ");
                } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) { ensure_slice_struct(ety, out); fprintf(out, "%s%s %s = ", pad, c_type_str(ety), name); }
                else fprintf(out, "%s%s %s = ", pad, ety ? c_type_str(ety) : "int32_t", name);
                if (codegen_init(ty, b->let_decls[i].init, out, b) != 0) return -1;
                fprintf(out, ";\n");
            }
#endif
        } else {
            for (int i = 0; i < b->num_expr_stmts; i++) {
                const struct ASTExpr *st = b->expr_stmts[i];
#ifdef SHUX_USE_X_CODEGEN
                if (st->kind == AST_EXPR_CONTINUE) { if (codegen_codegen_x_emit_continue_stmt((uint8_t *)out, indent) != 0) return -1; }
                else if (st->kind == AST_EXPR_BREAK) { if (codegen_codegen_x_emit_break_stmt((uint8_t *)out, indent) != 0) return -1; }
                else if (st->kind == AST_EXPR_RETURN) { if (st->value.unary.operand) { if (codegen_codegen_x_emit_return_expr((uint8_t *)out, indent, (uint8_t *)st->value.unary.operand) != 0) return -1; } else { if (codegen_codegen_x_emit_return_no_val((uint8_t *)out, indent) != 0) return -1; } }
                else { if (codegen_codegen_x_emit_void_expr_stmt((uint8_t *)out, indent, (uint8_t *)st) != 0) return -1; }
#else
                if (st->kind == AST_EXPR_CONTINUE) fprintf(out, "%scontinue;\n", pad);
                else if (st->kind == AST_EXPR_BREAK) fprintf(out, "%sbreak;\n", pad);
                else if (st->kind == AST_EXPR_RETURN) { if (st->value.unary.operand) { fprintf(out, "%sreturn ", pad); if (codegen_expr(st->value.unary.operand, out) != 0) return -1; fprintf(out, ";\n"); } else fprintf(out, "%sreturn;\n", pad); }
                else if (codegen_emit_expr_stmt(out, pad, st) != 0) return -1;
#endif
            }
            for (int i = 0; i < b->num_loops; i++) {
#ifdef SHUX_USE_X_CODEGEN
                if (codegen_codegen_x_emit_one_while_loop((uint8_t *)out, (uint8_t *)b->loops[i].cond, (uint8_t *)b->loops[i].body, indent, cast_return_to_int) != 0) return -1;
#else
                fprintf(out, "%swhile (", pad);
                if (codegen_expr(b->loops[i].cond, out) != 0) return -1;
                fprintf(out, ") {\n");
                if (codegen_block_body(b->loops[i].body, indent + 2, out, cast_return_to_int, is_void_return_context, NULL) != 0) return -1;
                fprintf(out, "%s}\n", pad);
#endif
            }
            for (int i = 0; i < b->num_for_loops; i++) {
#ifdef SHUX_USE_X_CODEGEN
                if (codegen_codegen_x_emit_one_for_loop((uint8_t *)out,
                    (uint8_t *)b->for_loops[i].init, (uint8_t *)b->for_loops[i].cond, (uint8_t *)b->for_loops[i].step,
                    (uint8_t *)b->for_loops[i].body, indent, cast_return_to_int) != 0) return -1;
#else
                fprintf(out, "%sfor (", pad);
                if (b->for_loops[i].init) { if (codegen_expr(b->for_loops[i].init, out) != 0) return -1; }
                fprintf(out, "; ");
                if (b->for_loops[i].cond) { if (codegen_expr(b->for_loops[i].cond, out) != 0) return -1; }
                fprintf(out, "; ");
                if (b->for_loops[i].step) { if (codegen_expr(b->for_loops[i].step, out) != 0) return -1; }
                fprintf(out, ") {\n");
                if (codegen_block_body(b->for_loops[i].body, indent + 2, out, cast_return_to_int, is_void_return_context, NULL) != 0) return -1;
                fprintf(out, "%s}\n", pad);
#endif
            }
#ifdef SHUX_USE_X_CODEGEN
            if (b->num_early_lets > 0 && b->num_early_lets < b->num_lets)
                if (codegen_codegen_x_emit_block_let_decls_range((uint8_t *)out, (uint8_t *)b, indent, (int32_t)b->num_early_lets, (int32_t)b->num_lets) != 0) return -1;
#else
            if (b->num_early_lets > 0 && b->num_early_lets < b->num_lets) {
                for (int i = b->num_early_lets; i < b->num_lets; i++) {
                    char let_place_alt[32];
                    const char *name = (b->let_decls[i].name && b->let_decls[i].name[0] && (unsigned char)b->let_decls[i].name[0] > ' ') ? b->let_decls[i].name : (snprintf(let_place_alt, sizeof(let_place_alt), "_l%d", i), let_place_alt);
                    if (!is_var_used(name, used_buf, n_used)) {
                        if (codegen_emit_unused_let_side_effect(out, pad, b->let_decls[i].init) < 0) return -1;
                        continue;
                    }
                    const struct ASTType *ty = b->let_decls[i].type;
                    const struct ASTExpr *linit_alt = b->let_decls[i].init;
                    const struct ASTType *ety = codegen_emit_type(ty);
                    if ((!ety || ety->kind != AST_TYPE_SLICE) && linit_alt && linit_alt->kind == AST_EXPR_CALL && linit_alt->value.call.resolved_callee_func) {
                        const struct ASTFunc *f = linit_alt->value.call.resolved_callee_func;
                        if (f->return_type && f->return_type->kind == AST_TYPE_SLICE && f->return_type->elem_type) {
                            ensure_slice_struct(f->return_type, out);
                            fprintf(out, "%s%s %s = ", pad, c_type_str(f->return_type), name);
                            if (codegen_init(ty, linit_alt, out, b) != 0) return -1;
                            fprintf(out, ";\n");
                            continue;
                        }
                    }
                    { int into_r = try_emit_let_arena_get_into(out, pad, b, name, ty, ety, linit_alt);
                      if (into_r == -1) return -1;
                      if (into_r == 1) continue;
                    }
                    if (ety && ety->kind == AST_TYPE_PTR && ety->elem_type) fprintf(out, "%s%s * %s = ", pad, c_type_str(ety->elem_type), name);
                    else if (ety && ety->kind == AST_TYPE_NAMED && ety->name) fprintf(out, "%s%s %s = ", pad, c_type_str(ety), name);
                    else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
                        fprintf(out, "%s", pad);
                        emit_local_array_decl(ety, name, "", out);
                        if (b->let_decls[i].init && b->let_decls[i].init->kind == AST_EXPR_VAR && b->let_decls[i].init->value.var.name) {
                            fprintf(out, ";\n%smemcpy(%s, %s, sizeof(%s));\n", pad, name, b->let_decls[i].init->value.var.name, name);
                            continue;
                        }
                        if (b->let_decls[i].init && b->let_decls[i].init->kind == AST_EXPR_LIT && b->let_decls[i].init->value.int_val == 0) {
                            fprintf(out, ";\n%smemset(%s, 0, sizeof(%s));\n", pad, name, name);
                            continue;
                        }
                        if (b->let_decls[i].init && b->let_decls[i].init->kind != AST_EXPR_ARRAY_LIT) {
                            fprintf(out, ";\n%smemcpy(%s, (", pad, name);
                            if (codegen_expr(b->let_decls[i].init, out) != 0) return -1;
                            fprintf(out, "), sizeof(%s));\n", name);
                            continue;
                        }
                        fprintf(out, "= ");
                    } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) { ensure_slice_struct(ety, out); fprintf(out, "%s%s %s = ", pad, c_type_str(ety), name); }
                    else fprintf(out, "%s%s %s = ", pad, ety ? c_type_str(ety) : "int32_t", name);
                    if (codegen_init(ty, b->let_decls[i].init, out, b) != 0) return -1;
                    fprintf(out, ";\n");
                }
            }
#endif
        }
    }
    for (int i = 0; i < b->num_labeled_stmts; i++) {
        if (b->labeled_stmts[i].label) {
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_label((uint8_t *)out, indent, (uint8_t *)b->labeled_stmts[i].label, (int32_t)strlen(b->labeled_stmts[i].label)) != 0) return -1;
#else
            fprintf(out, "%s%s:\n", pad, b->labeled_stmts[i].label);
#endif
        }
        if (b->labeled_stmts[i].kind == AST_STMT_GOTO) {
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_run_defers((uint8_t *)out, (uint8_t *)b, indent) != 0) return -1;
            if (codegen_codegen_x_emit_goto((uint8_t *)out, indent, (uint8_t *)b->labeled_stmts[i].u.goto_target, (int32_t)strlen(b->labeled_stmts[i].u.goto_target)) != 0) return -1;
#else
            if (codegen_run_defers(out, b, indent) != 0) return -1;
            fprintf(out, "%sgoto %s;\n", pad, b->labeled_stmts[i].u.goto_target);
#endif
        } else {
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_run_defers((uint8_t *)out, (uint8_t *)b, indent) != 0) return -1;
#else
            if (codegen_run_defers(out, b, indent) != 0) return -1;
#endif
            const struct ASTExpr *re = b->labeled_stmts[i].u.return_expr;
            if (!re) {
                codegen_async_cps_before_return(out, pad);
                fprintf(out, "%sreturn;\n", pad);
                continue;
            }
            int if_panic = (re->kind == AST_EXPR_IF && re->value.if_expr.then_expr
                && re->value.if_expr.then_expr->kind == AST_EXPR_PANIC && re->value.if_expr.else_expr);
            if (if_panic) {
                fprintf(out, "%sif (", pad);
                if (codegen_expr(re->value.if_expr.cond, out) != 0) return -1;
                fprintf(out, ") {\n");
                fprintf(out, "%s  ", pad);
                if (codegen_expr(re->value.if_expr.then_expr, out) != 0) return -1;
                fprintf(out, ";\n%s}\n", pad);
                codegen_async_cps_before_return(out, pad);
                if (is_void_return_context) {
                    fprintf(out, "%s(void)(", pad);
                    if (codegen_expr(re->value.if_expr.else_expr, out) != 0) return -1;
                    fprintf(out, ");\n%sreturn;\n", pad);
                } else {
                    if (cast_return_to_int) fprintf(out, "%sreturn (int)(", pad); else fprintf(out, "%sreturn ", pad);
                    if (codegen_expr(re->value.if_expr.else_expr, out) != 0) return -1;
                    fprintf(out, cast_return_to_int ? ");\n" : ";\n");
                }
            } else if (re->kind == AST_EXPR_PANIC) {
                fprintf(out, "%s", pad);
                if (codegen_expr(re, out) != 0) return -1;
                fprintf(out, ";\n");
                codegen_async_cps_before_return(out, pad);
                fprintf(out, is_void_return_context ? "%sreturn;\n" : "%sreturn 0;\n", pad);
            } else {
                codegen_async_cps_before_return(out, pad);
                if (is_void_return_context) {
                    fprintf(out, "%s(void)(", pad);
                    if (codegen_expr(re, out) != 0) return -1;
                    fprintf(out, ");\n%sreturn;\n", pad);
                } else {
                    const struct ASTType *rt = (codegen_current_func && codegen_current_func->return_type) ? codegen_current_func->return_type : NULL;
                    if (rt && rt->kind == AST_TYPE_ARRAY && rt->array_size > 0 && !cast_return_to_int) {
                        const char *wn = arr_ret_wrapper_name(rt);
                        fprintf(out, "%sreturn ((struct %s){ .data = ", pad, wn);
                        if (codegen_expr(re, out) != 0) return -1;
                        fprintf(out, " });\n");
                    } else {
                    if (cast_return_to_int) fprintf(out, "%sreturn (int)(", pad); else fprintf(out, "%sreturn ", pad);
                    if (codegen_expr(re, out) != 0) return -1;
                    fprintf(out, cast_return_to_int ? ");\n" : ";\n");
                    }
                }
            }
        }
    }
#ifdef SHUX_USE_X_CODEGEN
    if (codegen_codegen_x_run_defers((uint8_t *)out, (uint8_t *)b, indent) != 0) return -1;
#else
    if (codegen_run_defers(out, b, indent) != 0) return -1;
#endif
    if (!b->final_expr) return 0;  /* 块以 return/goto 结尾，无需 final_expr */
    if (b->final_expr->kind == AST_EXPR_BREAK) {
#ifdef SHUX_USE_X_CODEGEN
        if (codegen_codegen_x_emit_break_stmt((uint8_t *)out, indent) != 0) return -1;
#else
        fprintf(out, "%sbreak;\n", pad);
#endif
        return 0;
    }
    if (b->final_expr->kind == AST_EXPR_CONTINUE) {
#ifdef SHUX_USE_X_CODEGEN
        if (codegen_codegen_x_emit_continue_stmt((uint8_t *)out, indent) != 0) return -1;
#else
        fprintf(out, "%scontinue;\n", pad);
#endif
        return 0;
    }
    if (b->final_expr->kind == AST_EXPR_RETURN) {
        const struct ASTExpr *op = b->final_expr->value.unary.operand;
        if (!op) {
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_return_no_val((uint8_t *)out, indent) != 0) return -1;
#else
            codegen_async_cps_before_return(out, pad);
            fprintf(out, "%sreturn;\n", pad);
#endif
            return 0;
        }
        if (op->kind == AST_EXPR_PANIC) {
            fprintf(out, "%s", pad);
            if (codegen_expr(op, out) != 0) return -1;
            fprintf(out, ";\n");
            codegen_async_cps_before_return(out, pad);
            fprintf(out, is_void_return_context ? "%sreturn;\n" : "%sreturn 0;\n", pad);
        } else {
            codegen_async_cps_before_return(out, pad);
            if (is_void_return_context) {
                fprintf(out, "%s(void)(", pad);
                if (codegen_expr(op, out) != 0) return -1;
                fprintf(out, ");\n%sreturn;\n", pad);
            } else {
                if (cast_return_to_int) fprintf(out, "%sreturn (int)(", pad); else fprintf(out, "%sreturn ", pad);
                if (codegen_expr(op, out) != 0) return -1;
                fprintf(out, cast_return_to_int ? ");\n" : ";\n");
            }
        }
        return 0;
    }
    if (b->final_expr->kind == AST_EXPR_IF && b->final_expr->value.if_expr.then_expr
        && b->final_expr->value.if_expr.then_expr->kind == AST_EXPR_RETURN
        && b->final_expr->value.if_expr.else_expr
        && b->final_expr->value.if_expr.else_expr->kind == AST_EXPR_RETURN) {
        const struct ASTExpr *iff = b->final_expr;
        const struct ASTExpr *then_ret = iff->value.if_expr.then_expr->value.unary.operand;
        const struct ASTExpr *else_ret = iff->value.if_expr.else_expr->value.unary.operand;
        fprintf(out, "%sif (", pad);
        if (codegen_expr(iff->value.if_expr.cond, out) != 0) return -1;
        fprintf(out, ") {\n");
        if (then_ret && then_ret->kind == AST_EXPR_PANIC) {
            fprintf(out, "%s  ", pad);
            if (codegen_expr(then_ret, out) != 0) return -1;
            fprintf(out, ";\n");
            codegen_async_cps_before_return(out, pad);
            fprintf(out, "%s  return 0;\n", pad);
        } else {
            codegen_async_cps_before_return(out, pad);
            fprintf(out, "%s  return ", pad);
            if (codegen_expr(then_ret, out) != 0) return -1;
            fprintf(out, ";\n");
        }
        fprintf(out, "%s} else {\n", pad);
        if (else_ret && else_ret->kind == AST_EXPR_PANIC) {
            fprintf(out, "%s  ", pad);
            if (codegen_expr(else_ret, out) != 0) return -1;
            fprintf(out, ";\n");
            codegen_async_cps_before_return(out, pad);
            fprintf(out, "%s  return 0;\n", pad);
        } else {
            codegen_async_cps_before_return(out, pad);
            fprintf(out, "%s  return ", pad);
            if (codegen_expr(else_ret, out) != 0) return -1;
            fprintf(out, ";\n");
        }
        fprintf(out, "%s}\n", pad);
        return 0;
    }
    if (b->final_expr->kind == AST_EXPR_PANIC) {
        fprintf(out, "%s", pad);
        if (codegen_expr(b->final_expr, out) != 0) return -1;
        fprintf(out, ";\n");
        return 0;
    }
    /* 【Why 根源治理 B 组】final_expr 为 IF 且无 final_result_var 时，处于 statement 位置，
     * 直接生成 statement-if 形式，不走 codegen_expr 表达式路径——后者会生成
     * (void)({ __tmp; if(...) ... else ...; __tmp; }) 形式，导致临时变量类型混乱。
     * 此前 codegen_block_body 的 final_expr 默认走 (void)(expr); 路径，对 IF 表达式
     * 触发 codegen_emit_if_expr_impl 的 __tmp 生成，是 B 组（regex if-else if 链）
     * 类型不匹配的根因。final_result_var 非 NULL 时（表达式上下文需赋值）仍走原路径。 */
    if (b->final_expr->kind == AST_EXPR_IF && (!final_result_var || !*final_result_var)) {
        return codegen_emit_if_stmt(out, pad, b->final_expr);
    }
    if (final_result_var && *final_result_var) {
        fprintf(out, "%s%s = ", pad, final_result_var);
        if (codegen_expr(b->final_expr, out) != 0) return -1;
        fprintf(out, ";\n");
    } else {
        fprintf(out, "%s(void)(", pad);
        if (codegen_expr(b->final_expr, out) != 0) return -1;
        fprintf(out, ");\n");
    }
    return 0;
}

/** 当 else 分支为单语句块且唯一语句为 __tmp = (struct X){0} 或仅为 (struct X){0} 时，返回该 struct 的 C 类型串，否则返回 NULL。
 * 用于 EXPR_INDEX 等路径避免 __tmp 打成 int32_t；并修复 typeck 中 if(cond){ block } else (Type){0} 产出 int __tmp 却赋 (struct ast_Type){0} 的错型。 */
static const char *struct_type_from_else_block(const struct ASTExpr *else_e) {
    if (!else_e || else_e->kind != AST_EXPR_BLOCK) return NULL;
    const struct ASTBlock *b = else_e->value.block;
    if (!b) return NULL;
    /* 情况 1：块内唯一语句为赋值且 RHS 为结构体字面量（__tmp = (struct X){0}） */
    const struct ASTExpr *assign = NULL;
    if (b->expr_stmts && b->num_expr_stmts == 1)
        assign = b->expr_stmts[0];
    else if (b->num_expr_stmts == 0 && b->final_expr)
        assign = b->final_expr;
    if (assign && assign->kind == AST_EXPR_ASSIGN) {
        const struct ASTExpr *rhs = assign->value.binop.right;
        if (rhs && rhs->kind == AST_EXPR_STRUCT_LIT && rhs->resolved_type) {
            const char *s = c_type_str(rhs->resolved_type);
            if (s && strncmp(s, "struct ", 7) == 0) return s;
        }
    }
    /* 情况 2：块内唯一语句或 final_expr 为结构体字面量（无赋值，如 else { (Type){0} }），codegen 会生成 __tmp = (struct X){0} */
    const struct ASTExpr *struct_lit = NULL;
    if (b->expr_stmts && b->num_expr_stmts == 1 && b->expr_stmts[0]->kind == AST_EXPR_STRUCT_LIT)
        struct_lit = b->expr_stmts[0];
    else if (b->num_expr_stmts == 0 && b->final_expr && b->final_expr->kind == AST_EXPR_STRUCT_LIT)
        struct_lit = b->final_expr;
    if (struct_lit) {
        if (struct_lit->resolved_type) {
            const char *s = c_type_str(struct_lit->resolved_type);
            if (s && strncmp(s, "struct ", 7) == 0) return s;
        }
        /* typeck 可能未对 struct literal 设 resolved_type，用与发射时一致的 C 类型名（需前向声明 struct_lit_c_type_str） */
        if (struct_lit->value.struct_lit.struct_name) {
            static char block_struct_ty_buf[128];
            if (struct_lit_c_type_str(struct_lit, block_struct_ty_buf, sizeof(block_struct_ty_buf)))
                return block_struct_ty_buf;
        }
    }
    return NULL;
}

/** if 表达式完整输出（供 .x 转调）：语句表达式 ({ __tmp; if(cond) ... else ...; __tmp; }) 或三元 cond ? then : else。 */
static int codegen_emit_if_expr_impl(FILE *out, const struct ASTExpr *e) {
    const struct ASTExpr *then_e = e->value.if_expr.then_expr;
    const struct ASTExpr *else_e = e->value.if_expr.else_expr;
    int then_is_block = (then_e && then_e->kind == AST_EXPR_BLOCK);
    int else_is_block = (else_e && else_e->kind == AST_EXPR_BLOCK);
    int then_is_control = (then_e && (then_e->kind == AST_EXPR_CONTINUE || then_e->kind == AST_EXPR_BREAK || then_e->kind == AST_EXPR_RETURN));
    int else_is_control = (else_e && (else_e->kind == AST_EXPR_CONTINUE || else_e->kind == AST_EXPR_BREAK || else_e->kind == AST_EXPR_RETURN));
    then_is_block = then_is_block || then_is_control;
    else_is_block = else_is_block || else_is_control;
    if (then_is_block || else_is_block) {
        const struct ASTType *tmp_ty = e->resolved_type;
        /* 任一分支为 struct 时用该类型作 __tmp（与 AST_EXPR_IF 主路径一致） */
        if (then_e && !then_is_block && then_e->resolved_type) {
            const char *s = c_type_str(then_e->resolved_type);
            if (s && strncmp(s, "struct ", 7) == 0) tmp_ty = then_e->resolved_type;
        }
        /* then 为块且块类型为 struct 时也用上（如 if (ref<=0) { return Type{...}; }） */
        if (then_e && then_is_block && then_e->resolved_type) {
            const char *s = c_type_str(then_e->resolved_type);
            if (s && strncmp(s, "struct ", 7) == 0) tmp_ty = then_e->resolved_type;
        }
        /* else 为 struct 时用 else 类型，但若 then 已为块且产出 struct 则优先 then，避免 LexerResult __tmp 赋 (Token){0} */
        if (else_e && !else_is_block && else_e->resolved_type) {
            const char *s = c_type_str(else_e->resolved_type);
            if (s && strncmp(s, "struct ", 7) == 0) {
                const char *cur = tmp_ty ? c_type_str(tmp_ty) : NULL;
                if (!cur || strncmp(cur, "struct ", 7) != 0 || !then_e || !then_is_block)
                    tmp_ty = else_e->resolved_type;
            }
        }
        /* else 为结构体字面量且 tmp_ty 仍非 struct 时，用 else 的 resolved_type（如 ast_Type/ast_Expr）；then 为块且 tmp_ty 已来自 then 时不覆盖，避免 LexerResult __tmp = (Token){0} */
        const char *tmp_ty_str = tmp_ty ? c_type_str(tmp_ty) : "int32_t";
        if (else_e && !else_is_block && else_e->kind == AST_EXPR_STRUCT_LIT && strncmp(tmp_ty_str, "struct ", 7) != 0
            && !(then_e && then_is_block && tmp_ty == then_e->resolved_type)) {
            if (else_e->resolved_type) {
                const char *s = c_type_str(else_e->resolved_type);
                if (s && strncmp(s, "struct ", 7) == 0) {
                    static char if_impl_ty_buf[64];
                    snprintf(if_impl_ty_buf, sizeof(if_impl_ty_buf), "%s", s);
                    tmp_ty_str = if_impl_ty_buf;
                }
            }
            if (strncmp(tmp_ty_str, "struct ", 7) != 0) {
                static char if_impl_struct_lit_buf[128];
                if (struct_lit_c_type_str(else_e, if_impl_struct_lit_buf, sizeof(if_impl_struct_lit_buf)))
                    tmp_ty_str = if_impl_struct_lit_buf;
            }
        }
        /* else 为块且块内仅 __tmp = (struct X){0} 时，从块内推断 __tmp 类型（如 backend EXPR_INDEX 路径），避免 sed 兜底 */
        if (else_e && else_is_block && strncmp(tmp_ty_str, "struct ", 7) != 0) {
            const char *block_ty = struct_type_from_else_block(else_e);
            if (block_ty) {
                static char if_impl_else_block_ty_buf[64];
                snprintf(if_impl_else_block_ty_buf, sizeof(if_impl_else_block_ty_buf), "%s", block_ty);
                tmp_ty_str = if_impl_else_block_ty_buf;
            }
        }
        /* 无 else 且 then 为块时从块内 return 操作数推断 struct 类型 */
        if (!else_e && then_e && then_is_block && strncmp(tmp_ty_str, "struct ", 7) != 0) {
            static char if_impl_then_block_buf[128];
            if (expr_struct_type_str(then_e, if_impl_then_block_buf, sizeof(if_impl_then_block_buf)))
                tmp_ty_str = if_impl_then_block_buf;
        }
        /* c_type_str 对库模块 NAMED 可能返回 "prefix_Type" 无 "struct "，此处统一为 "struct prefix_Type"；若已是 "enum X" 则不要加 struct。 */
        if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) != 0 && strncmp(tmp_ty_str, "enum ", 5) != 0
            && e->resolved_type && e->resolved_type->kind == AST_TYPE_NAMED) {
            static char if_impl_struct_named_buf[128];
            snprintf(if_impl_struct_named_buf, sizeof(if_impl_struct_named_buf), "struct %s", tmp_ty_str);
            tmp_ty_str = if_impl_struct_named_buf;
        }
        /* 带初值避免 -Wuninitialized：标量用 0，struct 用 (type){0} */
        if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0)
            fprintf(out, "({ %s __tmp = (%s){0}; if (", tmp_ty_str, tmp_ty_str);
        else
            fprintf(out, "({ %s __tmp = 0; if (", tmp_ty_str);
        if (codegen_expr(e->value.if_expr.cond, out) != 0) return -1;
        fprintf(out, ") ");
        if (then_is_block) {
            if (then_e->kind == AST_EXPR_BLOCK) {
                fprintf(out, "{ ");
                if (codegen_block_body(then_e->value.block, 2, out, 0, 0, "__tmp") != 0) return -1;
                fprintf(out, " } ");
            } else if (then_e->kind == AST_EXPR_CONTINUE) {
                fprintf(out, "{ continue; } ");
            } else if (then_e->kind == AST_EXPR_BREAK) {
                fprintf(out, "{ break; } ");
            } else if (then_e->kind == AST_EXPR_RETURN) {
                fprintf(out, "{ __tmp = ");
                if (then_e->value.unary.operand && codegen_expr(then_e->value.unary.operand, out) != 0) return -1;
                if (!then_e->value.unary.operand) {
                    if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0) fprintf(out, "(%s){0}", tmp_ty_str);
                    else fprintf(out, "0");
                }
                fprintf(out, "; return __tmp; } ");
            } else {
                fprintf(out, "(__tmp = ");
                if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0 && !expr_produces_struct_type(then_e))
                    fprintf(out, "(%s){0}", tmp_ty_str);
                else if (codegen_expr(then_e, out) != 0) return -1;
                fprintf(out, ") ");
            }
        } else {
            fprintf(out, "(__tmp = ");
            if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0 && !expr_produces_struct_type(then_e))
                fprintf(out, "(%s){0}", tmp_ty_str);
            else if (codegen_expr(then_e, out) != 0) return -1;
            fprintf(out, ") ");
        }
        fprintf(out, "else ");
        if (else_is_block) {
            if (else_e->kind == AST_EXPR_BLOCK) {
                fprintf(out, "{ ");
                if (codegen_block_body(else_e->value.block, 2, out, 0, 0, "__tmp") != 0) return -1;
                fprintf(out, " } ");
            } else if (else_e->kind == AST_EXPR_CONTINUE) {
                fprintf(out, "{ continue; } ");
            } else if (else_e->kind == AST_EXPR_BREAK) {
                fprintf(out, "{ break; } ");
            } else if (else_e->kind == AST_EXPR_RETURN) {
                fprintf(out, "{ __tmp = ");
                if (else_e->value.unary.operand && codegen_expr(else_e->value.unary.operand, out) != 0) return -1;
                if (!else_e->value.unary.operand) {
                    if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0) fprintf(out, "(%s){0}", tmp_ty_str);
                    else fprintf(out, "0");
                }
                fprintf(out, "; return __tmp; } ");
            } else {
                fprintf(out, "(__tmp = ");
                if (else_e) {
                    static char impl_else_ty[128], impl_else_lit_ty[128];
                    const char *impl_ty_ptr = expr_struct_type_str(else_e, impl_else_ty, sizeof(impl_else_ty));
                    const char *impl_else_ctype = (else_e->kind == AST_EXPR_STRUCT_LIT) ? struct_lit_c_type_str(else_e, impl_else_lit_ty, sizeof(impl_else_lit_ty)) : NULL;
                    int impl_lex_tok = (tmp_ty_str && else_e->kind == AST_EXPR_STRUCT_LIT && impl_else_ctype && strstr(tmp_ty_str, "LexerResult") && strstr(impl_else_ctype, "Token"));
                    if (impl_lex_tok) {
                        if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0) fprintf(out, "(%s){0}", tmp_ty_str);
                        else { static char impl_lex_buf[128]; snprintf(impl_lex_buf, sizeof(impl_lex_buf), "struct %s", tmp_ty_str ? tmp_ty_str : "lexer_LexerResult"); fprintf(out, "(%s){0}", impl_lex_buf); }
                    } else if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0 && impl_ty_ptr && strcmp(impl_ty_ptr, tmp_ty_str) != 0)
                        fprintf(out, "(%s){0}", tmp_ty_str);
                    else if (else_struct_type_mismatch(tmp_ty_str, else_e))
                        fprintf(out, "(%s){0}", tmp_ty_str);
                    else if (codegen_expr(else_e, out) != 0) return -1;
                } else {
                    if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0) fprintf(out, "(%s){0}", tmp_ty_str);
                    else fprintf(out, "0");
                }
                fprintf(out, ") ");
            }
        } else {
            fprintf(out, "(__tmp = ");
            if (else_e) {
                static char impl_else_ty2[128], impl_else_lit_ty2[128];
                const char *impl_ty_ptr2 = expr_struct_type_str(else_e, impl_else_ty2, sizeof(impl_else_ty2));
                const char *impl_else_ctype2 = (else_e->kind == AST_EXPR_STRUCT_LIT) ? struct_lit_c_type_str(else_e, impl_else_lit_ty2, sizeof(impl_else_lit_ty2)) : NULL;
                int impl_lex_tok2 = (tmp_ty_str && else_e->kind == AST_EXPR_STRUCT_LIT && impl_else_ctype2 && strstr(tmp_ty_str, "LexerResult") && strstr(impl_else_ctype2, "Token"));
                if (impl_lex_tok2) {
                    if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0) fprintf(out, "(%s){0}", tmp_ty_str);
                    else { static char impl_lex_buf2[128]; snprintf(impl_lex_buf2, sizeof(impl_lex_buf2), "struct %s", tmp_ty_str); fprintf(out, "(%s){0}", impl_lex_buf2); }
                } else if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0 && impl_ty_ptr2 && strcmp(impl_ty_ptr2, tmp_ty_str) != 0)
                    fprintf(out, "(%s){0}", tmp_ty_str);
                else if (else_struct_type_mismatch(tmp_ty_str, else_e))
                    fprintf(out, "(%s){0}", tmp_ty_str);
                else if (codegen_expr(else_e, out) != 0) return -1;
            } else {
                if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0) fprintf(out, "(%s){0}", tmp_ty_str);
                else fprintf(out, "0");
            }
            fprintf(out, ") ");
        }
        fprintf(out, "; __tmp; })");
        return 0;
    }
    int then_is_panic = (then_e && then_e->kind == AST_EXPR_PANIC);
    fprintf(out, "(");
    if (then_is_panic) {
        fprintf(out, "__builtin_expect(!!(");
        if (codegen_expr(e->value.if_expr.cond, out) != 0) return -1;
        fprintf(out, "), 0) ? ");
    } else {
        if (codegen_expr(e->value.if_expr.cond, out) != 0) return -1;
        fprintf(out, " ? ");
    }
    if (codegen_expr(then_e, out) != 0) return -1;
    fprintf(out, " : ");
    if (else_e) {
        if (codegen_expr(else_e, out) != 0) return -1;
    } else {
        fprintf(out, "0");
    }
    fprintf(out, ")");
    return 0;
}
/** .x 侧 if 表达式全量输出：供 codegen.x 在需要语句表达式时转调。 */
int32_t codegen_x_emit_if_expr_full(uint8_t *out, uint8_t *expr) {
    return codegen_emit_if_expr_impl((FILE *)out, (const struct ASTExpr *)expr) != 0 ? -1 : 0;
}

/** .x 侧 IF 表达式：是否需要语句表达式（then/else 为 BLOCK 或 continue/break/return），非 0 时 .x 转调 full。 */
int32_t codegen_x_if_expr_need_stmt_expr(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_IF) return 0;
    const struct ASTExpr *then_e = e->value.if_expr.then_expr;
    const struct ASTExpr *else_e = e->value.if_expr.else_expr;
    int then_block = (then_e && (then_e->kind == AST_EXPR_BLOCK || then_e->kind == AST_EXPR_CONTINUE || then_e->kind == AST_EXPR_BREAK || then_e->kind == AST_EXPR_RETURN));
    int else_block = (else_e && (else_e->kind == AST_EXPR_BLOCK || else_e->kind == AST_EXPR_CONTINUE || else_e->kind == AST_EXPR_BREAK || else_e->kind == AST_EXPR_RETURN));
    return (then_block || else_block) ? 1 : 0;
}

/** .x 侧 IF 表达式：三元分支时 then 是否为 PANIC（生成 __builtin_expect）。 */
int32_t codegen_x_if_expr_then_is_panic(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_IF || !e->value.if_expr.then_expr) return 0;
    return e->value.if_expr.then_expr->kind == AST_EXPR_PANIC ? 1 : 0;
}

/** .x 侧 IF 表达式访问器：cond、then、else。 */
uint8_t *codegen_x_if_expr_cond(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return (e && e->kind == AST_EXPR_IF && e->value.if_expr.cond) ? (uint8_t *)e->value.if_expr.cond : NULL;
}
uint8_t *codegen_x_if_expr_then(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return (e && e->kind == AST_EXPR_IF) ? (uint8_t *)e->value.if_expr.then_expr : NULL;
}
uint8_t *codegen_x_if_expr_else(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return (e && e->kind == AST_EXPR_IF) ? (uint8_t *)e->value.if_expr.else_expr : NULL;
}

/** .x 自实现 if 语句表达式用：将 __tmp 的 C 类型写入 out（如 int32_t 或 struct X）。 */
int32_t codegen_x_emit_if_expr_tmp_type(uint8_t *out, uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_IF) return -1;
    const struct ASTType *tmp_ty = e->resolved_type;
    const char *s = tmp_ty ? c_type_str(tmp_ty) : "int32_t";
    fprintf((FILE *)out, "%s", s);
    return 0;
}
/** .x 自实现 if 语句表达式用：将默认值写入 out（0 或 (struct X){0}）。 */
int32_t codegen_x_emit_if_expr_default_val(uint8_t *out, uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    if (!e || e->kind != AST_EXPR_IF) return -1;
    const struct ASTType *tmp_ty = e->resolved_type;
    const char *tmp_ty_str = tmp_ty ? c_type_str(tmp_ty) : "int32_t";
    if (tmp_ty_str && strncmp(tmp_ty_str, "struct ", 7) == 0)
        fprintf((FILE *)out, "(%s){0}", tmp_ty_str);
    else
        fprintf((FILE *)out, "0");
    return 0;
}
/** .x 表达式 kind 常量：BLOCK、CONTINUE、BREAK、RETURN，供 if 语句表达式分支判断。 */
int32_t codegen_x_expr_kind_block(void) { return (int32_t)AST_EXPR_BLOCK; }
int32_t codegen_x_expr_kind_continue(void) { return (int32_t)AST_EXPR_CONTINUE; }
int32_t codegen_x_expr_kind_break(void) { return (int32_t)AST_EXPR_BREAK; }
int32_t codegen_x_expr_kind_return(void) { return (int32_t)AST_EXPR_RETURN; }
/** .x 自实现用：expr 为 BLOCK 时返回块指针，否则 NULL。 */
uint8_t *codegen_x_expr_block_ptr(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return (e && e->kind == AST_EXPR_BLOCK && e->value.block) ? (uint8_t *)e->value.block : NULL;
}
/** .x 自实现用：expr 为 RETURN 时返回 return 的操作数表达式，否则 NULL。 */
uint8_t *codegen_x_return_operand(uint8_t *expr) {
    const struct ASTExpr *e = (const struct ASTExpr *)expr;
    return (e && e->kind == AST_EXPR_RETURN) ? (uint8_t *)e->value.unary.operand : NULL;
}

/**
 * 统计块内「会执行 return」的出口个数（用于决定是否用 goto cleanup 减少 defer 重复展开）。
 * 仅计 return 类出口，不含 goto。
 */
static int count_return_exits(const struct ASTBlock *b) {
    if (!b) return 0;
    int n = 0;
    for (int i = 0; i < b->num_labeled_stmts; i++) {
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN) {
            const struct ASTExpr *e = b->labeled_stmts[i].u.return_expr;
            if (e && e->kind == AST_EXPR_IF && e->value.if_expr.then_expr
                && e->value.if_expr.then_expr->kind == AST_EXPR_PANIC && e->value.if_expr.else_expr)
                n += 2; /* then panic + else return */
            else
                n += 1;
        }
    }
    if (b->final_expr) {
        if (b->final_expr->kind == AST_EXPR_RETURN) n += 1;
        else if (b->final_expr->kind == AST_EXPR_PANIC) n += 1;
        else if (b->final_expr->kind == AST_EXPR_IF && b->final_expr->value.if_expr.then_expr
            && b->final_expr->value.if_expr.then_expr->kind == AST_EXPR_RETURN
            && b->final_expr->value.if_expr.else_expr
            && b->final_expr->value.if_expr.else_expr->kind == AST_EXPR_RETURN)
            n += 2;
    }
    return n;
}

/**
 * 生成单个函数体（const/let、while/for、labeled、final_expr return/panic）。
 * 用于多函数时每个函数的函数体；indent 固定为 2（两空格）。
 * f 非 NULL 且为 main 且返回 i64 时，对 return 表达式包 (int) 以适配 C 的 int main()。
 * 当存在多个 return 出口且至少一个 defer 时，使用单一 shux_cleanup 标签，避免每出口重复展开 defer。
 */
/** K3：naked 函数体仅发 asm! 语句（clang 对 __attribute__((naked)) 严格要求体内仅 asm，不接受块/return）。
 * 递归收集块内所有 AST_EXPR_ASM（经 region/unsafe 块、expr_stmt、嵌套 block），逐条发 `__asm__(...);`。 */
static int codegen_emit_naked_asm_in_block(const struct ASTBlock *b, FILE *out) {
    int i;
    if (!b) return 0;
    for (i = 0; i < b->num_regions; i++)
        if (b->regions[i].body && codegen_emit_naked_asm_in_block(b->regions[i].body, out) != 0) return -1;
    for (i = 0; i < b->num_expr_stmts; i++) {
        const struct ASTExpr *st = b->expr_stmts[i];
        if (!st) continue;
        if (st->kind == AST_EXPR_ASM) {
            fputs("  ", out);
            codegen_emit_asm_extended(out, st);
            fputs(";\n", out);
        } else if (st->kind == AST_EXPR_BLOCK && st->value.block) {
            if (codegen_emit_naked_asm_in_block(st->value.block, out) != 0) return -1;
        }
    }
    if (b->final_expr && b->final_expr->kind == AST_EXPR_ASM) {
        fputs("  ", out);
        codegen_emit_asm_extended(out, b->final_expr);
        fputs(";\n", out);
    }
    return 0;
}

static int codegen_func_body(const struct ASTBlock *b, const struct ASTModule *m, FILE *out, const struct ASTFunc *f) {
    if (!b || !m || !out) return -1;
    /* K3：naked 函数体仅 asm! 语句，避免 clang 拒绝块/return（non-ASM statement in naked function） */
    if (f && (f->is_naked || f->is_entry)) return codegen_emit_naked_asm_in_block(b, out);  /* K5：entry 体仅 asm!（设栈/call kmain/hlt） */
    codegen_current_func = f;
    int cast_return_to_int = (f && f->name && strcmp(f->name, "main") == 0
        && f->return_type && f->return_type->kind == AST_TYPE_I64);
    const char *pad = "  ";
    int is_void = (f && f->return_type && f->return_type->kind == AST_TYPE_VOID);
    int use_cleanup = (!is_void && b->num_defers > 0 && count_return_exits(b) >= 2);
    const char *ret_ctype = (f && f->return_type) ? c_type_str(f->return_type) : "int32_t";
    if (cast_return_to_int) ret_ctype = "int";
    /* 阶段 8.1 块内 DCE：仅输出被引用的 const/let */
    const char *used_buf[MAX_BLOCK_USED_VARS];
    int n_used = 0;
    collect_var_names_from_block(b, used_buf, &n_used, MAX_BLOCK_USED_VARS);
    /* 有 stmt_order 时按源码顺序输出函数体，与 codegen_block_body 一致。 */
    int used_block_body_order = 0;
    if (b->num_stmt_order > 0) {
        if (1) {
            used_block_body_order = 1;
            if (codegen_block_body(b, 2, out, cast_return_to_int, is_void, use_cleanup ? "shux_ret_val" : NULL) != 0) return -1;
            if (use_cleanup) fprintf(out, "%sgoto shux_cleanup;\n", pad);
            goto func_body_after_block;
        }
    }
    for (int i = 0; i < b->num_consts; i++) {
        char name_place_c[32];
        const char *name = (b->const_decls[i].name && b->const_decls[i].name[0]) ? b->const_decls[i].name : (snprintf(name_place_c, sizeof(name_place_c), "_c%d", i), name_place_c);
        if (!is_var_used(name, used_buf, n_used)) continue;
        const struct ASTType *ty = b->const_decls[i].type;
        const struct ASTType *ety = codegen_emit_type(ty);
        if (ety && ety->kind == AST_TYPE_NAMED && ety->name) {
            if (is_enum_type(m, ety->name))
                fprintf(out, "%sconst enum %s %s = ", pad, ety->name, name);
            else
                fprintf(out, "%sconst %s %s = ", pad, c_type_str(ety), name);
        }
        else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
            fprintf(out, "%sconst ", pad);
            emit_local_array_decl(ety, name, "", out);
            if (b->const_decls[i].init && b->const_decls[i].init->kind == AST_EXPR_VAR && b->const_decls[i].init->value.var.name) {
                fprintf(out, ";\n%smemcpy(%s, %s, sizeof(%s));\n", pad, name, b->const_decls[i].init->value.var.name, name);
                continue;
            }
            if (b->const_decls[i].init && b->const_decls[i].init->kind == AST_EXPR_LIT && b->const_decls[i].init->value.int_val == 0) {
                fprintf(out, ";\n%smemset(%s, 0, sizeof(%s));\n", pad, name, name);
                continue;
            }
            if (b->const_decls[i].init && b->const_decls[i].init->kind != AST_EXPR_ARRAY_LIT) {
                fprintf(out, ";\n%smemcpy(%s, (", pad, name);
                if (codegen_expr(b->const_decls[i].init, out) != 0) return -1;
                fprintf(out, "), sizeof(%s));\n", name);
                continue;
            }
            fprintf(out, "= ");
        } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) {
            ensure_slice_struct(ety, out);
            fprintf(out, "%sconst %s %s = ", pad, c_type_str(ety), name);
        } else {
            const char *cty = ety ? c_type_str(ety) : "int32_t";
            fprintf(out, "%sconst %s %s = ", pad, cty, name);
        }
        if (codegen_init(ty, b->const_decls[i].init, out, b) != 0) return -1;
        fprintf(out, ";\n");
    }
    for (int i = 0; i < b->num_lets; i++) {
        char name_place_l[32];
        const char *name = (b->let_decls[i].name && b->let_decls[i].name[0]) ? b->let_decls[i].name : (snprintf(name_place_l, sizeof(name_place_l), "_l%d", i), name_place_l);
        if (!is_var_used(name, used_buf, n_used)) {
            if (codegen_emit_unused_let_side_effect(out, pad, b->let_decls[i].init) < 0) return -1;
            continue;
        }
        const struct ASTType *ty = b->let_decls[i].type;
        const struct ASTExpr *linit = b->let_decls[i].init;
        const struct ASTType *ety = codegen_emit_type(ty);
        /** let x: T; 无显式初值：C 零初始化（与 asm 栈 prologue 清零一致，同 line 5200）。
         *  【Why 逻辑根源】func_body fallback 路径（num_stmt_order==0）必须与 block_body early/late-let 对无 init 行为对称，
         *  否则会 emit `T name = ;`（带等号无值）致 C 语法错误，触发 codegen_one_func 返回 -1。
         *  【Invariant】数组 emit `T name[64] = {0};`；指针 emit `T * name = 0;`；其它 emit `T name = {0};`。 */
        if (!linit) {
            if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
                fprintf(out, "%s", pad);
                emit_local_array_decl(ety, name, "", out); fprintf(out, "= {0}");
                fprintf(out, ";\n");
            } else if (ety && ety->kind == AST_TYPE_PTR && ety->elem_type) {
                fprintf(out, "%s%s * %s = 0;\n", pad, c_type_str(ety->elem_type), name);
            } else if (ety && ety->kind == AST_TYPE_NAMED && ety->name) {
                if (is_enum_type(m, ety->name))
                    fprintf(out, "%senum %s %s = {0};\n", pad, ety->name, name);
                else
                    fprintf(out, "%s%s %s = {0};\n", pad, c_type_str(ety), name);
            } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) {
                ensure_slice_struct(ety, out);
                fprintf(out, "%s%s %s = {0};\n", pad, c_type_str(ety), name);
            } else {
                fprintf(out, "%s%s %s = {0};\n", pad, ety ? c_type_str(ety) : "int32_t", name);
            }
            continue;
        }
        if (ety && ety->kind == AST_TYPE_NAMED && ety->name) {
            if (is_enum_type(m, ety->name))
                fprintf(out, "%senum %s %s = ", pad, ety->name, name);
            else
                fprintf(out, "%s%s %s = ", pad, c_type_str(ety), name);
        }
        else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
            fprintf(out, "%s", pad);
            emit_local_array_decl(ety, name, "", out);
            if (linit->kind == AST_EXPR_VAR && linit->value.var.name) {
                fprintf(out, ";\n%smemcpy(%s, %s, sizeof(%s));\n", pad, name, linit->value.var.name, name);
                continue;
            }
            if (linit->kind == AST_EXPR_LIT && linit->value.int_val == 0) {
                fprintf(out, ";\n%smemset(%s, 0, sizeof(%s));\n", pad, name, name);
                continue;
            }
            if (linit->kind != AST_EXPR_ARRAY_LIT) {
                fprintf(out, ";\n%smemcpy(%s, (", pad, name);
                if (codegen_expr(linit, out) != 0) return -1;
                fprintf(out, "), sizeof(%s));\n", name);
                continue;
            }
            fprintf(out, "= ");
        } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) {
            ensure_slice_struct(ety, out);
            fprintf(out, "%s%s %s = ", pad, c_type_str(ety), name);
        } else {
            const char *cty = ety ? c_type_str(ety) : "int32_t";
            fprintf(out, "%s%s %s = ", pad, cty, name);
        }
        if (codegen_init(ty, linit, out, b) != 0) return -1;
        fprintf(out, ";\n");
    }
    if (use_cleanup) {
#ifdef SHUX_USE_X_CODEGEN
        if (codegen_codegen_x_emit_cleanup_decl_exit_kind((uint8_t *)out, 2) != 0) return -1;
        if (codegen_codegen_x_emit_cleanup_decl_ret_val((uint8_t *)out, 2, (uint8_t *)ret_ctype, (int32_t)strlen(ret_ctype)) != 0) return -1;
#else
        fprintf(out, "%sint shux_exit_kind = 0;\n", pad);
        fprintf(out, "%s%s shux_ret_val = 0;\n", pad, ret_ctype);
#endif
    }
    for (int i = 0; i < b->num_loops; i++) {
#ifdef SHUX_USE_X_CODEGEN
        if (codegen_codegen_x_emit_one_while_loop((uint8_t *)out, (uint8_t *)b->loops[i].cond, (uint8_t *)b->loops[i].body, 2, cast_return_to_int) != 0) return -1;
#else
        fprintf(out, "%swhile (", pad);
        if (codegen_expr(b->loops[i].cond, out) != 0) return -1;
        fprintf(out, ") {\n");
        if (codegen_block_body(b->loops[i].body, 4, out, cast_return_to_int, is_void, NULL) != 0) return -1;
        fprintf(out, "%s}\n", pad);
#endif
    }
    for (int i = 0; i < b->num_for_loops; i++) {
#ifdef SHUX_USE_X_CODEGEN
        if (codegen_codegen_x_emit_one_for_loop((uint8_t *)out,
            (uint8_t *)b->for_loops[i].init, (uint8_t *)b->for_loops[i].cond, (uint8_t *)b->for_loops[i].step,
            (uint8_t *)b->for_loops[i].body, 2, cast_return_to_int) != 0) return -1;
#else
        fprintf(out, "%sfor (", pad);
        if (b->for_loops[i].init) {
            if (codegen_expr(b->for_loops[i].init, out) != 0) return -1;
        }
        fprintf(out, "; ");
        if (b->for_loops[i].cond) {
            if (codegen_expr(b->for_loops[i].cond, out) != 0) return -1;
        } else {
            fprintf(out, "1");
        }
        fprintf(out, "; ");
        if (b->for_loops[i].step) {
            if (codegen_expr(b->for_loops[i].step, out) != 0) return -1;
        }
        fprintf(out, ") {\n");
        if (codegen_block_body(b->for_loops[i].body, 4, out, cast_return_to_int, is_void, NULL) != 0) return -1;
        fprintf(out, "%s}\n", pad);
#endif
    }
func_body_after_block:
    for (int i = 0; i < b->num_labeled_stmts; i++) {
        if (b->labeled_stmts[i].label) {
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_label((uint8_t *)out, 2, (uint8_t *)b->labeled_stmts[i].label, (int32_t)strlen(b->labeled_stmts[i].label)) != 0) return -1;
#else
            fprintf(out, "%s%s:\n", pad, b->labeled_stmts[i].label);
#endif
        }
        if (b->labeled_stmts[i].kind == AST_STMT_GOTO) {
            if (codegen_run_defers(out, b, 2) != 0) return -1;
#ifdef SHUX_USE_X_CODEGEN
            if (codegen_codegen_x_emit_goto((uint8_t *)out, 2, (uint8_t *)b->labeled_stmts[i].u.goto_target, (int32_t)strlen(b->labeled_stmts[i].u.goto_target)) != 0) return -1;
#else
            fprintf(out, "%sgoto %s;\n", pad, b->labeled_stmts[i].u.goto_target);
#endif
        } else {
            const struct ASTExpr *ret_e = b->labeled_stmts[i].u.return_expr;
                if (!ret_e) {
                if (use_cleanup) {
#ifdef SHUX_USE_X_CODEGEN
                    if (codegen_codegen_x_emit_exit_kind_goto_cleanup((uint8_t *)out, 2) != 0) return -1;
#else
                    fprintf(out, "%sshux_exit_kind = 1; goto shux_cleanup;\n", pad);
#endif
                } else {
#ifdef SHUX_USE_X_CODEGEN
                    if (codegen_codegen_x_run_defers((uint8_t *)out, (uint8_t *)b, 2) != 0) return -1;
#else
                    if (codegen_run_defers(out, b, 2) != 0) return -1;
#endif
                    fprintf(out, "%sreturn;\n", pad);
                }
                continue;
            }
            int ret_if_panic = (ret_e->kind == AST_EXPR_IF && ret_e->value.if_expr.then_expr
                && ret_e->value.if_expr.then_expr->kind == AST_EXPR_PANIC && ret_e->value.if_expr.else_expr);
            if (use_cleanup) {
                if (ret_if_panic) {
                    fprintf(out, "%sif (", pad);
                    if (codegen_expr(ret_e->value.if_expr.cond, out) != 0) return -1;
                    fprintf(out, ") {\n");
                    fprintf(out, "%s  ", pad);
                    if (codegen_expr(ret_e->value.if_expr.then_expr, out) != 0) return -1;
#ifdef SHUX_USE_X_CODEGEN
                    fprintf(out, ";\n");
                    if (codegen_codegen_x_emit_ret_val_zero_exit_goto_cleanup((uint8_t *)out, 2) != 0) return -1;
                    fprintf(out, "%s} else {\n", pad);
                    if (cast_return_to_int) fprintf(out, "%s  shux_ret_val = (int)(", pad); else fprintf(out, "%s  shux_ret_val = ", pad);
                    if (codegen_expr(ret_e->value.if_expr.else_expr, out) != 0) return -1;
                    fprintf(out, cast_return_to_int ? ");\n" : ";\n");
                    if (codegen_codegen_x_emit_exit_kind_goto_cleanup((uint8_t *)out, 4) != 0) return -1;
                    fprintf(out, "%s}\n", pad);
#else
                    fprintf(out, ";\n%sshux_ret_val = 0; shux_exit_kind = 1; goto shux_cleanup;\n%s} else {\n", pad, pad);
                    if (cast_return_to_int) fprintf(out, "%s  shux_ret_val = (int)(", pad); else fprintf(out, "%s  shux_ret_val = ", pad);
                    if (codegen_expr(ret_e->value.if_expr.else_expr, out) != 0) return -1;
                    fprintf(out, cast_return_to_int ? ");\n" : ";\n");
                    fprintf(out, "%s  shux_exit_kind = 1; goto shux_cleanup;\n%s}\n", pad, pad);
#endif
                } else if (ret_e && ret_e->kind == AST_EXPR_PANIC) {
                    fprintf(out, "%s", pad);
                    if (codegen_expr(ret_e, out) != 0) return -1;
#ifdef SHUX_USE_X_CODEGEN
                    fprintf(out, ";\n");
                    if (codegen_codegen_x_emit_ret_val_zero_exit_goto_cleanup((uint8_t *)out, 2) != 0) return -1;
#else
                    fprintf(out, ";\n%sshux_ret_val = 0; shux_exit_kind = 1; goto shux_cleanup;\n", pad);
#endif
                } else {
                    if (cast_return_to_int) fprintf(out, "%sshux_ret_val = (int)(", pad); else fprintf(out, "%sshux_ret_val = ", pad);
                    if (codegen_expr(ret_e, out) != 0) return -1;
                    fprintf(out, cast_return_to_int ? ");\n" : ";\n");
#ifdef SHUX_USE_X_CODEGEN
                    if (codegen_codegen_x_emit_exit_kind_goto_cleanup((uint8_t *)out, 2) != 0) return -1;
#else
                    fprintf(out, "%sshux_exit_kind = 1; goto shux_cleanup;\n", pad);
#endif
                }
            } else {
#ifdef SHUX_USE_X_CODEGEN
                if (codegen_codegen_x_run_defers((uint8_t *)out, (uint8_t *)b, 2) != 0) return -1;
#else
                if (codegen_run_defers(out, b, 2) != 0) return -1;
#endif
                if (ret_if_panic) {
                    fprintf(out, "%sif (", pad);
                    if (codegen_expr(ret_e->value.if_expr.cond, out) != 0) return -1;
                    fprintf(out, ") {\n");
                    fprintf(out, "%s  ", pad);
                    if (codegen_expr(ret_e->value.if_expr.then_expr, out) != 0) return -1;
                    fprintf(out, ";\n%s}\n", pad);
                    if (cast_return_to_int) fprintf(out, "%sreturn (int)(", pad); else fprintf(out, "%sreturn ", pad);
                    if (codegen_expr(ret_e->value.if_expr.else_expr, out) != 0) return -1;
                    fprintf(out, cast_return_to_int ? ");\n" : ";\n");
                } else if (ret_e && ret_e->kind == AST_EXPR_PANIC) {
                    fprintf(out, "%s", pad);
                    if (codegen_expr(ret_e, out) != 0) return -1;
                    fprintf(out, ";\n%sreturn 0;\n", pad);
                } else {
                    const struct ASTType *rt = (codegen_current_func && codegen_current_func->return_type) ? codegen_current_func->return_type : NULL;
                    if (rt && rt->kind == AST_TYPE_ARRAY && rt->array_size > 0 && !cast_return_to_int) {
                        const char *wn = arr_ret_wrapper_name(rt);
                        fprintf(out, "%sreturn ((struct %s){ .data = ", pad, wn);
                        if (codegen_expr(ret_e, out) != 0) return -1;
                        fprintf(out, " });\n");
                    } else {
                    if (cast_return_to_int) fprintf(out, "%sreturn (int)(", pad); else fprintf(out, "%sreturn ", pad);
                    if (codegen_expr(ret_e, out) != 0) return -1;
                    fprintf(out, cast_return_to_int ? ");\n" : ";\n");
                    }
                }
            }
        }
    }
    /* 表达式语句 (expr;)：continue/break/return 须直接生成语句，不能包在 (void)(...) 中；若已用 codegen_block_body 按 stmt_order 输出则跳过。 */
    if (!used_block_body_order) {
    for (int i = 0; i < b->num_expr_stmts; i++) {
        const struct ASTExpr *st = b->expr_stmts[i];
#ifdef SHUX_USE_X_CODEGEN
        if (st->kind == AST_EXPR_CONTINUE) { if (codegen_codegen_x_emit_continue_stmt((uint8_t *)out, 2) != 0) return -1; }
        else if (st->kind == AST_EXPR_BREAK) { if (codegen_codegen_x_emit_break_stmt((uint8_t *)out, 2) != 0) return -1; }
        else if (st->kind == AST_EXPR_RETURN) {
            if (st->value.unary.operand) {
                if (is_void) {
                    fprintf(out, "%s(void)(", pad);
                    if (codegen_expr(st->value.unary.operand, out) != 0) return -1;
                    fprintf(out, ");\n%sreturn;\n", pad);
                } else if (codegen_codegen_x_emit_return_expr((uint8_t *)out, 2, (uint8_t *)st->value.unary.operand) != 0) return -1;
            } else {
                if (codegen_codegen_x_emit_return_no_val((uint8_t *)out, 2) != 0) return -1;
            }
        }
        else { if (codegen_codegen_x_emit_void_expr_stmt((uint8_t *)out, 2, (uint8_t *)st) != 0) return -1; }
#else
        if (st->kind == AST_EXPR_CONTINUE) {
            fprintf(out, "%scontinue;\n", pad);
        } else if (st->kind == AST_EXPR_BREAK) {
            fprintf(out, "%sbreak;\n", pad);
        } else if (st->kind == AST_EXPR_RETURN) {
            if (st->value.unary.operand) {
                codegen_async_cps_before_return(out, pad);
                const struct ASTType *rt = (f && f->return_type) ? f->return_type : NULL;
                if (rt && rt->kind == AST_TYPE_ARRAY && rt->array_size > 0) {
                    const char *wn = arr_ret_wrapper_name(rt);
                    fprintf(out, "%sreturn ((struct %s){ .data = ", pad, wn);
                    if (codegen_expr(st->value.unary.operand, out) != 0) return -1;
                    fprintf(out, " });\n");
                } else {
                    fprintf(out, "%sreturn ", pad);
                    if (codegen_expr(st->value.unary.operand, out) != 0) return -1;
                    fprintf(out, ";\n");
                }
            } else {
                codegen_async_cps_before_return(out, pad);
                fprintf(out, "%sreturn;\n", pad);
            }
        } else if (codegen_emit_expr_stmt(out, pad, st) != 0) {
            return -1;
        }
#endif
    }
    if (use_cleanup) {
#ifdef SHUX_USE_X_CODEGEN
        if (codegen_codegen_x_emit_goto_shux_cleanup((uint8_t *)out, 2) != 0) return -1;
#else
        fprintf(out, "%sgoto shux_cleanup;\n", pad);
#endif
    } else {
#ifdef SHUX_USE_X_CODEGEN
        if (codegen_codegen_x_run_defers((uint8_t *)out, (uint8_t *)b, 2) != 0) return -1;
#else
        if (codegen_run_defers(out, b, 2) != 0) return -1;
#endif
    }
    }  /* end if (!used_block_body_order): expr_stmts + goto/run_defers */
    if (use_cleanup) {
#ifdef SHUX_USE_X_CODEGEN
        if (codegen_codegen_x_emit_shux_cleanup_label((uint8_t *)out, 2) != 0) return -1;
        if (codegen_codegen_x_run_defers((uint8_t *)out, (uint8_t *)b, 2) != 0) return -1;
        if (codegen_codegen_x_emit_if_exit_kind_return_ret_val((uint8_t *)out, 2) != 0) return -1;
#else
        fprintf(out, "%sshux_cleanup:\n", pad);
        if (codegen_run_defers(out, b, 2) != 0) return -1;
        fprintf(out, "%sif (shux_exit_kind) return shux_ret_val;\n", pad);
#endif
    }
    if (used_block_body_order || !b->final_expr) return 0;
    if (b->final_expr->kind == AST_EXPR_PANIC) {
        fprintf(out, "%s", pad);
        if (codegen_expr(b->final_expr, out) != 0) return -1;
        fprintf(out, ";\n");
        fprintf(out, is_void ? "%sreturn;\n" : "%sreturn 0;\n", pad);
    } else if (b->final_expr->kind == AST_EXPR_IF && b->final_expr->value.if_expr.then_expr
        && b->final_expr->value.if_expr.then_expr->kind == AST_EXPR_RETURN
        && b->final_expr->value.if_expr.else_expr
        && b->final_expr->value.if_expr.else_expr->kind == AST_EXPR_RETURN) {
        const struct ASTExpr *iff = b->final_expr;
        const struct ASTExpr *then_ret = iff->value.if_expr.then_expr->value.unary.operand;
        const struct ASTExpr *else_ret = iff->value.if_expr.else_expr->value.unary.operand;
        fprintf(out, "%sif (", pad);
        if (codegen_expr(iff->value.if_expr.cond, out) != 0) return -1;
        fprintf(out, ") {\n");
        if (then_ret && then_ret->kind == AST_EXPR_PANIC) {
            fprintf(out, "%s  ", pad);
            if (codegen_expr(then_ret, out) != 0) return -1;
            fprintf(out, is_void ? ";\n%s  return;\n" : ";\n%s  return 0;\n", pad);
        } else {
            if (is_void) {
                fprintf(out, "%s  (void)(", pad);
                if (codegen_expr(then_ret, out) != 0) return -1;
                fprintf(out, ");\n%s  return;\n", pad);
            } else {
                if (cast_return_to_int) fprintf(out, "%s  return (int)(", pad); else fprintf(out, "%s  return ", pad);
                if (codegen_expr(then_ret, out) != 0) return -1;
                fprintf(out, cast_return_to_int ? ");\n" : ";\n");
            }
        }
        fprintf(out, "%s} else {\n", pad);
        if (else_ret && else_ret->kind == AST_EXPR_PANIC) {
            fprintf(out, "%s  ", pad);
            if (codegen_expr(else_ret, out) != 0) return -1;
            fprintf(out, is_void ? ";\n%s  return;\n" : ";\n%s  return 0;\n", pad);
        } else {
            if (is_void) {
                fprintf(out, "%s  (void)(", pad);
                if (codegen_expr(else_ret, out) != 0) return -1;
                fprintf(out, ");\n%s  return;\n", pad);
            } else {
                if (cast_return_to_int) fprintf(out, "%s  return (int)(", pad); else fprintf(out, "%s  return ", pad);
                if (codegen_expr(else_ret, out) != 0) return -1;
                fprintf(out, cast_return_to_int ? ");\n" : ";\n");
            }
        }
        fprintf(out, "%s}\n", pad);
    } else {
        if (b->final_expr->kind == AST_EXPR_RETURN && !b->final_expr->value.unary.operand) {
            fprintf(out, "%sreturn;\n", pad);
            return 0;
        }
        /* void 函数：最后表达式只求值不返回，避免 C 报 "void function should not return a value"（如 vec truncate） */
        if (is_void) {
            fprintf(out, "%s(void)(", pad);
            if (codegen_expr(b->final_expr->kind == AST_EXPR_RETURN ? b->final_expr->value.unary.operand : b->final_expr, out) != 0) return -1;
            fprintf(out, ");\n");
            return 0;
        }
        const struct ASTExpr *ret_op = (b->final_expr->kind == AST_EXPR_RETURN) ? b->final_expr->value.unary.operand : b->final_expr;
        int is_return_if_panic = (ret_op && ret_op->kind == AST_EXPR_IF && ret_op->value.if_expr.then_expr
            && ret_op->value.if_expr.then_expr->kind == AST_EXPR_PANIC && ret_op->value.if_expr.else_expr);
        if (is_return_if_panic) {
            fprintf(out, "%sif (", pad);
            if (codegen_expr(ret_op->value.if_expr.cond, out) != 0) return -1;
            fprintf(out, ") {\n");
            fprintf(out, "%s  ", pad);
            if (codegen_expr(ret_op->value.if_expr.then_expr, out) != 0) return -1;
            fprintf(out, ";\n%s}\n", pad);
            if (is_void) {
                fprintf(out, "%s(void)(", pad);
                if (codegen_expr(ret_op->value.if_expr.else_expr, out) != 0) return -1;
                fprintf(out, ");\n%sreturn;\n", pad);
            } else {
                if (cast_return_to_int) fprintf(out, "%sreturn (int)(", pad); else fprintf(out, "%sreturn ", pad);
                if (codegen_expr(ret_op->value.if_expr.else_expr, out) != 0) return -1;
                fprintf(out, cast_return_to_int ? ");\n" : ";\n");
            }
        } else {
            if (is_void) {
                fprintf(out, "%s(void)(", pad);
                if (b->final_expr->kind == AST_EXPR_RETURN) {
                    if (codegen_expr(ret_op, out) != 0) return -1;
                } else {
                    if (codegen_expr(b->final_expr, out) != 0) return -1;
                }
                fprintf(out, ");\n%sreturn;\n", pad);
            } else {
                const struct ASTType *rt = (f && f->return_type) ? f->return_type : NULL;
                if (rt && rt->kind == AST_TYPE_ARRAY && rt->array_size > 0 && !cast_return_to_int) {
                    const char *wn = arr_ret_wrapper_name(rt);
                    /* 数组字面量未设 resolved_type 时用函数返回类型，使 codegen 用正确元素类型 */
                    if (b->final_expr->kind == AST_EXPR_RETURN && ret_op && ret_op->kind == AST_EXPR_ARRAY_LIT && !ret_op->resolved_type)
                        ((struct ASTExpr *)ret_op)->resolved_type = (struct ASTType *)rt;
                    /* C 不允许按值返回数组；用 struct wrapper + memcpy from compound literal */
                    int arr_id = codegen_match_id++;
                    const struct ASTExpr *arr_expr = (b->final_expr->kind == AST_EXPR_RETURN) ? ret_op : b->final_expr;
                    fprintf(out, "{ struct %s _ar%d; memcpy(_ar%d.data, ", wn, arr_id, arr_id);
                    if (codegen_expr(arr_expr, out) != 0) return -1;
                    fprintf(out, ", sizeof(_ar%d.data)); return _ar%d; }\n", arr_id, arr_id);
                } else {
                if (cast_return_to_int) fprintf(out, "%sreturn (int)(", pad); else fprintf(out, "%sreturn ", pad);
                if (b->final_expr->kind == AST_EXPR_RETURN) {
                    if (codegen_expr(ret_op, out) != 0) return -1;
                } else {
                    if (codegen_expr(b->final_expr, out) != 0) return -1;
                }
                fprintf(out, cast_return_to_int ? ");\n" : ";\n");
                }
            }
        }
    }
    return 0;
}

/**
 * 生成单个 C 函数定义：return_type name(params) { body }。
 * 多函数时对 mod->funcs 中每个函数调用；main 放在最后以便其它函数可被 main 调用。
 */
static int codegen_one_func(const struct ASTFunc *f, const struct ASTModule *m, FILE *out) {
    if (!f || !f->body || !m || !out) return -1;
    /* 泛型函数由单态化实例生成，不在此直接输出（阶段 7.1） */
    if (f->num_generic_params > 0) return 0;
    /* 无条件跳过 std.io.driver 的 driver_read_ptr_len/driver_read_ptr，由 io_abi.h 宏解析到 core 的 shux_io_*，避免单文件与多文件编译时重定义。 */
    if (codegen_library_import_path && strcmp(codegen_library_import_path, "std.io.driver") == 0 && f->name
        && (strcmp(f->name, "driver_read_ptr_len") == 0 || strcmp(f->name, "driver_read_ptr") == 0))
        return 0;
    /* std.io.print(ptr,len) 由弱符号提供；print 整数重载走下方 printf 桩。 */
    if (codegen_library_import_path && strcmp(codegen_library_import_path, "std.io") == 0 && f->name
        && strcmp(f->name, "print") == 0 && f->num_params == 2
        && f->params[0].type && f->params[0].type->kind == AST_TYPE_PTR
        && f->params[1].type && f->params[1].type->kind == AST_TYPE_USIZE)
        return 0;
    char fname[256];
    /* L9：#[no_mangle] 不加 library_prefix（函数名不修改），匹配跨模块 extern 声明用原名的调用端。
     * 【Why 根源治理】原 codegen 无条件 library_prefixed_name 给定义加前缀（如 tcp_net_accept_c），
     * 但 extern 声明和 CALL 解析（call_instance_mangled_name line 1119 用 func_link_name，不加前缀）
     * 用原名（net_accept_c），导致跨模块链接 undefined。#[no_mangle] 跳过前缀后定义与调用一致。
     * 【Invariant】is_no_mangle 已在 line 6556/8250/8293 DCE 跳过条件中，used attribute 在 line 6534 添加。 */
    if (f->is_no_mangle) {
        snprintf(fname, sizeof(fname), "%s", func_link_name(m, f));
    } else {
        library_prefixed_name(func_link_name(m, f), fname, sizeof(fname));
    }
    if (f->is_entry) { snprintf(fname, sizeof(fname), "_start"); }  /* K5：入口符号裸名 _start，供 bootloader/linker 识别 */
    if (f->link_name) { snprintf(fname, sizeof(fname), "%s", f->link_name); }  /* L9：#[link_name] 用指定符号名 */
    if (f->export_name) { snprintf(fname, sizeof(fname), "%s", f->export_name); }  /* #[export_name] 用指定导出名 */
    /* C 要求 main 返回 int；若 .x 中 main 返回 i64 则在函数体内对 return 包 (int) */
    /* 函数返回定长数组 [N]T：用 wrapper struct 替代（C 不允许按值返回数组）。 */
    if (f->return_type && f->return_type->kind == AST_TYPE_ARRAY && f->return_type->array_size > 0) {
        ensure_arr_ret_struct(f->return_type, out);
    }
    const char *cret_arr = (f->return_type && f->return_type->kind == AST_TYPE_ARRAY && f->return_type->array_size > 0) ? arr_ret_wrapper_name(f->return_type) : NULL;
    const char *cret = (f->name && strcmp(f->name, "main") == 0) ? "int" : (cret_arr ? cret_arr : c_type_str(f->return_type));
    char cret_full[160];
    if (cret_arr) snprintf(cret_full, sizeof cret_full, "struct %s", cret);
    else { snprintf(cret_full, sizeof cret_full, "%s", cret); }
    /* 入口模块的 main：生成 main(int argc, char **argv) 并保存到 std.process 全局，供 args_count/arg 使用 */
    if (!codegen_library_prefix && f->name && strcmp(f->name, "main") == 0) {
        fprintf(out, "int main(int argc, char **argv) {\n");
        fprintf(out, "  shux_process_argc = argc;\n");
        fprintf(out, "  shux_process_argv = argv;\n");
        if (codegen_current_module && codegen_current_module->num_top_level_lets > 0)
            fprintf(out, "  init_globals();\n");
        if (codegen_func_body(f->body, m, out, f) != 0)
            return -1;
        fprintf(out, "}\n");
        return 0;
    }
    /* A3：async 函数在签名前 emit 协程帧 typedef。 */
    AsyncFrameLayout async_layout;
    AsyncCpsCodegenCtx async_cps_ctx;
    int has_async_frame = 0;
    if (f->is_async && async_liveness_func_needs_cps_frame(f)) {
        if (async_liveness_layout_func_module(f, m, &async_layout) == 0) {
            async_liveness_emit_frame_typedef(f, &async_layout, out);
            has_async_frame = 1;
        }
    }
    /* K4b：#[link_section] 函数段，附在存储类前（__attribute__((section(...))) static ...） */
    if (f->section)
        fprintf(out, "__attribute__((section(\"%s\"))) ", f->section);
    /* K3：#[naked] 函数无 prologue/epilogue，体须仅 asm!（ISR/入口用）；GCC/clang __attribute__((naked)) */
    if (f->is_naked || f->is_entry)  /* K5：#[entry] 隐含 naked（bootloader 裸跳进，须无 prologue） */
        fprintf(out, "__attribute__((naked)) ");
    /* K5：#[entry] 入口不返回（设栈后 call kmain; hlt），noreturn */
    if (f->is_entry)
        fprintf(out, "__attribute__((noreturn)) ");
    /* K10：#[used] 不被 C 编译器消除（ISR/asm! 引用的函数须 used+外部链接） */
    if (f->is_used)
        fprintf(out, "__attribute__((used)) ");
    /* L9：#[no_mangle] 外部链接+不 DCE（C 前端无 mangling，但需外部链接+used 防 DCE） */
    if (f->is_no_mangle)
        fprintf(out, "__attribute__((used)) ");
    /* L4：#[max_stack(N)] 栈用量上限标记（供 -fstack-usage 后处理校验） */
    if (f->max_stack > 0)
        fprintf(out, "/* shux_max_stack:%d */ ", f->max_stack);
    /* A1：#[interrupt] 中断处理函数（C 编译器自动保存/恢复寄存器 + iret；
     * GCC/clang __attribute__((interrupt)) on x86: 自动 pusha/popa + iret；
     * 须外部链接 + 不 DCE（ISR 被 IDT 引用而非直接调用） */
    if (f->is_interrupt)
        fprintf(out, "__attribute__((interrupt)) ");
    if (f->is_global_allocator)
        fprintf(out, "__attribute__((used)) ");
    if (f->is_cold)
        fprintf(out, "__attribute__((cold)) ");
    if (f->is_panic_handler)
        fprintf(out, "__attribute__((used)) __attribute__((noreturn)) ");
    if (f->is_inline_never)
        fprintf(out, "__attribute__((noinline)) ");
    /* 小函数内联提示（§3.4）：入口模块内非 main、非 extern 加 static inline；
     * async CPS 函数仅 static（同 TU 可取址给 shux_async_run_i32）。 */
    if (f->is_inline_always) {
        fprintf(out, "static inline __attribute__((always_inline)) ");
    } else if (!codegen_library_prefix && f->name && strcmp(f->name, "main") != 0 && !f->is_extern && !f->is_entry && !f->is_used && !f->is_no_mangle && !f->is_interrupt && !f->is_global_allocator && !f->is_cold && !f->is_panic_handler && !f->export_name) {
        if (has_async_frame)
            fprintf(out, "static ");
        else
            fprintf(out, "static inline ");
    } else if (codegen_library_prefix && codegen_library_import_path && !f->is_extern
        && (strcmp(codegen_library_import_path, "core.option") == 0 || strcmp(codegen_library_import_path, "core.result") == 0))
        fprintf(out, "static inline ");
    else if (codegen_library_prefix && codegen_library_import_path && !f->is_extern
        && (strcmp(codegen_library_import_path, "std.fs") == 0 || strcmp(codegen_library_import_path, "std.net") == 0))
        fprintf(out, "static inline ");
    else if (codegen_library_prefix && codegen_library_import_path && f->name && !f->is_extern
        && (strcmp(codegen_library_import_path, "core.types") == 0 || strcmp(codegen_library_import_path, "core.mem") == 0)
        && (strncmp(f->name, "size_of_", 8) == 0 || strncmp(f->name, "align_of_", 9) == 0))
        fprintf(out, "SHUX_LIB_WEAK inline ");
    /* 【Why 逻辑根源】库模块有 body 函数被 co-emit 到入口 .o 时生成强符号，
     * 与 std/*.o 同名 co-emit 强符号冲突（duplicate symbol）。
     * 【Invariant】仅库模块（codegen_library_prefix 真）且有 body（!is_extern）且
     * 非 #[no_mangle]（C 桥桩引用须强符号）时加 weak；static inline 分支本 TU 可见不冲突。
     * 【Asm/Perf】weak 不影响代码生成质量，仅链接期允许多份定义选其一；
     * Windows PE 不支持 weak 函数符号，靠 Makefile --allow-multiple-definition 兜底。 */
    else if (codegen_library_prefix && !f->is_extern && !f->is_no_mangle && !f->is_entry)
        fprintf(out, "SHUX_LIB_WEAK ");
    fprintf(out, "%s %s(", cret_full, fname);
    if (has_async_frame)
        fprintf(out, "void");
    else if (f->is_interrupt && f->num_params == 0)
        fprintf(out, "void *__shux_isr_frame");  /* A1：x86 interrupt 属性须有至少一个指针参数 */
    else {
        for (int i = 0; i < f->num_params; i++) {
            if (i) fprintf(out, ", ");
            /* std.io.driver 的 register/submit_read/submit_write 首参 ptrdiff_t、第二参 timeout_ms 与 submit_register_fixed_buffers_buf 第二参 nr 为 uint32_t，与 preamble 一致。 */
            const struct ASTType *param_override = NULL;
            if (f->name) {
                int is_io_driver = (codegen_library_prefix && strcmp(codegen_library_prefix, "std_io_driver_") == 0)
                    || (codegen_library_import_path && (strcmp(codegen_library_import_path, "std.io.driver") == 0
                        || strcmp(codegen_library_import_path, "std/io/driver") == 0));
                if (is_io_driver)
                    param_override = codegen_io_driver_param_override(codegen_library_import_path ? codegen_library_import_path : "std.io.driver", f->name, i);
            }
            codegen_emit_param(&f->params[i], out, param_override, i);
        }
    }
    fprintf(out, ") {\n");
    /* A3：帧布局注释 + 帧局部占位（sync stub；CPS 后续分段读写 __shux_frame）。 */
    if (has_async_frame) {
        async_liveness_emit_codegen_comment(f, &async_layout, out);
        async_liveness_emit_frame_local(f, &async_layout, out);
        if (f->num_params > 0)
            async_cps_codegen_emit_param_statics(f, out);
        async_cps_codegen_begin(&async_cps_ctx, f, &async_layout, out);
        codegen_async_cps_ctx = async_cps_ctx;
        codegen_async_cps_active = 1;
    }
    /* 【Why 逻辑根源】std.io.driver 的 register/submit_read/submit_write 首参经 codegen_io_driver_param_override
     *   被改写为 ptrdiff_t（Buffer 结构体指针的整数表示）。函数体须从该指针还原 Buffer 三字段 (ptr, len, handle)，
     *   再调 std_io_core_shux_io_*（std/io/core.x 中的 SHUX 实现，最终走 write/read syscall）。
     *   绝不能调 preamble 的 shux_io_submit_write_buf → shux_io_submit_write（weak 桩，return 0，无 syscall）——
     *   那是 C ABI 兜底桩，仅用于无 std.io.core 依赖时的链接占位。macOS/Linux 均须走 core 实现才能真正 I/O。
     *   shu_buffer_abi_t 与 std_io_driver_Buffer 同布局（ptr+len+handle 24B），uintptr_t 转换安全。
     * 【Invariant】p0 为非空 Buffer 指针（调用方传 &buf 经 (ptrdiff_t)(uintptr_t) 转换）；shu_buffer_abi_t 已在 preamble 定义。
     * 【Asm/Perf】仅一次内存解引用（3 字段连续），无堆分配；非热路径（每次 I/O 提交一次）。 */
    if (codegen_library_import_path && f->name && f->params
        && (strcmp(codegen_library_import_path, "std.io.driver") == 0 || strcmp(codegen_library_import_path, "std/io/driver") == 0)) {
        const char *p0 = (f->num_params > 0 && f->params[0].name && (unsigned char)f->params[0].name[0] > ' ') ? f->params[0].name : "buf";
        const char *p1 = (f->num_params > 1 && f->params[1].name && (unsigned char)f->params[1].name[0] > ' ') ? f->params[1].name : "timeout_ms";
        /* 调 std_io_core_* SHUX 实现（最终走 syscall），不调 preamble weak 桩 */
        if (strcmp(f->name, "register") == 0 && f->num_params == 1) {
            fprintf(out, "  const shu_buffer_abi_t *_b = (const shu_buffer_abi_t *)(uintptr_t)%s;\n", p0);
            fprintf(out, "  return std_io_core_shux_io_register((uint8_t *)_b->ptr, _b->len, _b->handle);\n");
            fprintf(out, "}\n");
            return 0;
        }
        if (strcmp(f->name, "submit_read") == 0 && f->num_params == 2) {
            fprintf(out, "  const shu_buffer_abi_t *_b = (const shu_buffer_abi_t *)(uintptr_t)%s;\n", p0);
            fprintf(out, "  return std_io_core_shux_io_submit_read((uint8_t *)_b->ptr, _b->len, _b->handle, %s);\n", p1);
            fprintf(out, "}\n");
            return 0;
        }
        if (strcmp(f->name, "submit_write") == 0 && f->num_params == 2) {
            fprintf(out, "  const shu_buffer_abi_t *_b = (const shu_buffer_abi_t *)(uintptr_t)%s;\n", p0);
            fprintf(out, "  return std_io_core_shux_io_submit_write((uint8_t *)_b->ptr, _b->len, _b->handle, %s);\n", p1);
            fprintf(out, "}\n");
            return 0;
        }
        if (strcmp(f->name, "submit_register_fixed_buffers_buf") == 0 && f->num_params == 2) {
            /* 首参为 struct std_io_driver_Buffer *，io_register_buffers_buf_i32 需 intptr_t，显式转换 */
            fprintf(out, "  return io_register_buffers_buf_i32((intptr_t)(void *)%s, (int)%s);\n", p0, p1);
            fprintf(out, "}\n");
            return 0;
        }
    }
    /* std.process.exit(code)：生成对 C exit() 的调用（noreturn） */
    if (codegen_library_import_path && strcmp(codegen_library_import_path, "std.process") == 0
        && f->name && strcmp(f->name, "exit") == 0 && f->num_params == 1
        && f->params[0].type && f->params[0].type->kind == AST_TYPE_I32) {
        const char *pname = f->params[0].name ? f->params[0].name : "code";
        fprintf(out, "  exit(%s);\n  return 0;\n", pname);
    } else if (codegen_library_import_path && strcmp(codegen_library_import_path, "std.io") == 0
        && f->name && strcmp(f->name, "print") == 0 && f->num_params == 1
        && f->params[0].type && f->params[0].type->kind == AST_TYPE_I32) {
        const char *pname = f->params[0].name ? f->params[0].name : "x";
        fprintf(out, "  (void)printf(\"%%d\\n\", (int)%s);\n  return 0;\n", pname);
    } else if (codegen_library_import_path && strcmp(codegen_library_import_path, "std.io") == 0
        && f->name && strcmp(f->name, "print") == 0 && f->num_params == 1
        && f->params[0].type && f->params[0].type->kind == AST_TYPE_U32) {
        const char *pname = f->params[0].name ? f->params[0].name : "x";
        fprintf(out, "  (void)printf(\"%%u\\n\", (unsigned int)%s);\n  return 0;\n", pname);
    } else if (codegen_library_import_path && strcmp(codegen_library_import_path, "std.io") == 0
        && f->name && strcmp(f->name, "print") == 0 && f->num_params == 1
        && f->params[0].type && f->params[0].type->kind == AST_TYPE_I64) {
        const char *pname = f->params[0].name ? f->params[0].name : "x";
        fprintf(out, "  (void)printf(\"%%lld\\n\", (long long)%s);\n  return 0;\n", pname);
    } else if (codegen_func_body(f->body, m, out, f) != 0)
        return -1;
    if (has_async_frame) {
        async_cps_codegen_end(&codegen_async_cps_ctx, out);
        codegen_async_cps_active = 0;
    }
    fprintf(out, "}\n");
    if (has_async_frame)
        async_cps_codegen_emit_sched_wrapper(f, fname, out);
    return 0;
}

/**
 * 为 impl 块内单条方法生成 C 函数（使用 mangle 名 Trait_Type_method）；阶段 7.2。
 */
static int codegen_one_impl_func(const struct ASTFunc *f, const struct ASTModule *m, FILE *out) {
    if (!f || !f->body || !m || !out || !f->impl_for_trait || !f->impl_for_type) return -1;
    char cname_buf[256];
    library_prefixed_name(impl_method_c_name(f), cname_buf, sizeof(cname_buf));
    /* 库模块 impl 方法不加 static 以保持可链接；入口模块可考虑在单文件时加 inline，此处从简 */
    if (f->return_type && f->return_type->kind == AST_TYPE_ARRAY) ensure_arr_ret_struct(f->return_type, out);
    const char *proto_ret = (f->return_type && f->return_type->kind == AST_TYPE_ARRAY && f->return_type->array_size > 0) ? arr_ret_wrapper_name(f->return_type) : c_type_str(f->return_type);
    fprintf(out, "%s%s %s(", (f->return_type && f->return_type->kind == AST_TYPE_ARRAY) ? "struct " : "", proto_ret, cname_buf);
    for (int i = 0; i < f->num_params; i++) {
        if (i) fprintf(out, ", ");
        codegen_emit_param(&f->params[i], out, NULL, i);
    }
    fprintf(out, ") {\n");
    if (codegen_func_body(f->body, m, out, NULL) != 0) return -1;
    fprintf(out, "}\n");
    return 0;
}

/**
 * 为单个泛型单态化实例生成 C 函数：代入类型后的签名 + 模板体（体中类型按代入上下文输出）。
 */
static int codegen_one_mono_instance(const struct ASTFunc *f, struct ASTType **type_args, int num_type_args,
    const struct ASTModule *m, FILE *out) {
    if (!f || !f->body || !m || !out || !type_args || num_type_args <= 0 || !f->generic_param_names) return -1;
    const struct ASTType *ret_ty = subst_type(f->return_type, f->generic_param_names, type_args, num_type_args);
    char mangled_buf[256];
    library_prefixed_name(mono_instance_mangled_name_ex(m, f, type_args, num_type_args), mangled_buf, sizeof(mangled_buf));
    fprintf(out, "%s %s(", c_type_str(ret_ty), mangled_buf);
    for (int i = 0; i < f->num_params; i++) {
        if (i) fprintf(out, ", ");
        const struct ASTType *pty = subst_type(f->params[i].type, f->generic_param_names, type_args, num_type_args);
        codegen_emit_param(&f->params[i], out, pty, i);
    }
    fprintf(out, ") {\n");
    /* CORE-001：size_of/align_of 单态化体折叠为 return 常量。 */
    if (f->name && num_type_args == 1 && type_args && type_args[0]
        && (strcmp(f->name, "size_of") == 0 || strcmp(f->name, "align_of") == 0)) {
        int layout_val = (strcmp(f->name, "size_of") == 0)
            ? codegen_type_size_of(type_args[0]) : codegen_type_align_of(type_args[0]);
        if (layout_val <= 0) return -1;
        fprintf(out, "  return %d;\n}\n", layout_val);
        return 0;
    }
    codegen_subst_gp_names = f->generic_param_names;
    codegen_subst_type_args = type_args;
    codegen_subst_n = num_type_args;
    int r = codegen_func_body(f->body, m, out, NULL);
    codegen_subst_gp_names = NULL;
    codegen_subst_type_args = NULL;
    codegen_subst_n = 0;
    if (r != 0) return -1;
    fprintf(out, "}\n");
    return 0;
}


/** 阶段 8.1 DCE：在模块 m 的 mono_instances 中查找 (template, type_args) 对应的实例下标，未找到返回 -1。 */
static int find_mono_index(const struct ASTModule *m, const struct ASTFunc *template,
    struct ASTType **type_args, int n) {
    if (!m || !m->mono_instances || !template || !type_args) return -1;
    for (int k = 0; k < m->num_mono_instances; k++) {
        const struct ASTMonoInstance *inst = &m->mono_instances[k];
        if (inst->template != template || inst->num_type_args != n) continue;
        int eq = 1;
        for (int j = 0; j < n && eq; j++)
            if (!type_equal(inst->type_args[j], type_args[j])) eq = 0;
        if (eq) return k;
    }
    return -1;
}

/** 返回 func 所在模块在 (entry, dep_mods[0..ndep-1]) 中的下标：0=entry，1+i=dep_mods[i]，未找到返回 -1。 */
static int module_index(const struct ASTModule *entry, struct ASTModule **dep_mods, int ndep, const struct ASTModule *mod) {
    if (mod == entry) return 0;
    for (int i = 0; i < ndep; i++)
        if (dep_mods[i] == mod) return 1 + i;
    return -1;
}

/** 判断 func 是否属于模块 m（顶层函数或 impl 方法）。 */
static int func_belongs_to_module(const struct ASTModule *m, const struct ASTFunc *func) {
    if (!m || !func) return 0;
    for (int i = 0; i < m->num_funcs && m->funcs; i++)
        if (m->funcs[i] == func) return 1;
    for (int k = 0; k < m->num_impl_blocks && m->impl_blocks; k++)
        for (int j = 0; j < m->impl_blocks[k]->num_funcs; j++)
            if (m->impl_blocks[k]->funcs[j] == func) return 1;
    return 0;
}

/** 阶段 8.1 DCE：从表达式递归收集被调函数与单态化，加入 worklist 并标记 used_mono。 */
/* K-fix forward decls: dce_collect_from_expr/expr_references_func now call these (defined later) */
static void dce_collect_from_block(const struct ASTBlock *b, struct ASTModule *entry, struct ASTModule **dep_mods, int ndep, struct ASTFunc **worklist, int *n_wl, int max_wl, int *in_wl, int used_mono[][64], int used_mono_rows);
static int block_references_func(const struct ASTBlock *b, const struct ASTFunc *func);

static void dce_collect_from_expr(const struct ASTExpr *e, struct ASTModule *entry, struct ASTModule **dep_mods, int ndep,
    struct ASTFunc **worklist, int *n_wl, int max_wl, int *in_wl,
    int used_mono[][64], int used_mono_rows) {
    if (!e) return;
    /* return expr 在 parser 中为 AST_EXPR_RETURN(operand)，须先递归 operand 才能看到其中的 CALL 并收集 callee */
    if (e->kind == AST_EXPR_RETURN && e->value.unary.operand) {
        dce_collect_from_expr(e->value.unary.operand, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
        return;
    }
    /* K-fix: unsafe/region 块表达式(AST_EXPR_BLOCK)内的函数调用也须递归收集,否则 unsafe{} 内的 callee 被 DCE 误删 */
    if (e->kind == AST_EXPR_BLOCK && e->value.block) {
        dce_collect_from_block(e->value.block, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
        return;
    }
    if (e->kind == AST_EXPR_CALL && e->value.call.resolved_callee_func) {
        const struct ASTFunc *callee = e->value.call.resolved_callee_func;
        if (e->value.call.num_type_args > 0 && e->value.call.type_args) {
            const struct ASTModule *owner = NULL;
            if (func_belongs_to_module(entry, callee)) owner = entry;
            else
                for (int i = 0; i < ndep && !owner; i++)
                    if (func_belongs_to_module(dep_mods[i], callee)) owner = dep_mods[i];
            if (owner) {
                int mi = module_index(entry, dep_mods, ndep, owner);
                int k = find_mono_index(owner, callee, (struct ASTType **)e->value.call.type_args, e->value.call.num_type_args);
                if (mi >= 0 && mi < used_mono_rows && k >= 0 && k < 64)
                    used_mono[mi][k] = 1;
            }
        }
        for (int i = 0; i < *n_wl && i < max_wl; i++)
            if (worklist[i] == (struct ASTFunc *)callee) goto skip_add;
        if (*n_wl < max_wl) {
            worklist[*n_wl++] = (struct ASTFunc *)callee;
            if (in_wl) in_wl[(size_t)(const char *)callee % (size_t)max_wl] = 1;
        }
        /* A4：extern shux_async_sched_<async_fn> 调用须保留 async 函数体（wrapper 同 TU emit）。 */
        if (callee && callee->name && callee->is_extern) {
            struct ASTFunc *async_target = async_cps_resolve_sched_target(entry, callee->name);
            if (async_target) {
                for (int ai = 0; ai < *n_wl && ai < max_wl; ai++)
                    if (worklist[ai] == async_target) goto skip_async_sched_target;
                if (*n_wl < max_wl) {
                    worklist[*n_wl++] = async_target;
                    if (in_wl) in_wl[(size_t)(const char *)async_target % (size_t)max_wl] = 1;
                }
            skip_async_sched_target: ;
            }
        }
    skip_add: ;
    }
    if (e->kind == AST_EXPR_METHOD_CALL && e->value.method_call.resolved_impl_func) {
        const struct ASTFunc *callee = e->value.method_call.resolved_impl_func;
        for (int i = 0; i < *n_wl && i < max_wl; i++)
            if (worklist[i] == (struct ASTFunc *)callee) goto skip_impl;
        if (*n_wl < max_wl) worklist[*n_wl++] = (struct ASTFunc *)callee;
    skip_impl: ;
    }
    switch (e->kind) {
        case AST_EXPR_CALL:
            for (int i = 0; i < e->value.call.num_args; i++)
                dce_collect_from_expr(e->value.call.args[i], entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            break;
        case AST_EXPR_METHOD_CALL:
            dce_collect_from_expr(e->value.method_call.base, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            for (int i = 0; i < e->value.method_call.num_args; i++)
                dce_collect_from_expr(e->value.method_call.args[i], entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            break;
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR:
        case AST_EXPR_ASSIGN:
        case AST_EXPR_ADD_ASSIGN: case AST_EXPR_SUB_ASSIGN: case AST_EXPR_MUL_ASSIGN: case AST_EXPR_DIV_ASSIGN: case AST_EXPR_MOD_ASSIGN:
        case AST_EXPR_BITAND_ASSIGN: case AST_EXPR_BITOR_ASSIGN: case AST_EXPR_BITXOR_ASSIGN: case AST_EXPR_SHL_ASSIGN: case AST_EXPR_SHR_ASSIGN:
            dce_collect_from_expr(e->value.binop.left, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            dce_collect_from_expr(e->value.binop.right, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            break;
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT: case AST_EXPR_PANIC: case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF:
        case AST_EXPR_AWAIT: case AST_EXPR_RUN: case AST_EXPR_SPAWN: case AST_EXPR_TRY_PROPAGATE:
            dce_collect_from_expr(e->value.unary.operand, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            if (e->kind == AST_EXPR_RUN || e->kind == AST_EXPR_SPAWN) {
                const struct ASTExpr *op = e->value.unary.operand;
                if (op && op->kind == AST_EXPR_CALL && op->value.call.resolved_callee_func) {
                    struct ASTFunc *async_target = op->value.call.resolved_callee_func;
                    if (async_target && async_target->is_async && async_liveness_func_has_await(async_target)) {
                        int ai;
                        for (ai = 0; ai < *n_wl && ai < max_wl; ai++)
                            if (worklist[ai] == async_target) break;
                        if (ai >= *n_wl && *n_wl < max_wl) {
                            worklist[*n_wl++] = async_target;
                            if (in_wl) in_wl[(size_t)(const char *)async_target % (size_t)max_wl] = 1;
                        }
                    }
                }
            }
            break;
        case AST_EXPR_AS:
            dce_collect_from_expr(e->value.as_type.operand, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            break;
        case AST_EXPR_IF:
        case AST_EXPR_TERNARY:
            dce_collect_from_expr(e->value.if_expr.cond, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            dce_collect_from_expr(e->value.if_expr.then_expr, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            if (e->value.if_expr.else_expr) dce_collect_from_expr(e->value.if_expr.else_expr, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            break;
        case AST_EXPR_MATCH:
            dce_collect_from_expr(e->value.match_expr.matched_expr, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            for (int i = 0; i < e->value.match_expr.num_arms; i++)
                dce_collect_from_expr(e->value.match_expr.arms[i].result, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            break;
        case AST_EXPR_FIELD_ACCESS:
            dce_collect_from_expr(e->value.field_access.base, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            break;
        case AST_EXPR_STRUCT_LIT:
            for (int i = 0; i < e->value.struct_lit.num_fields; i++)
                dce_collect_from_expr(e->value.struct_lit.inits[i], entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            break;
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++)
                dce_collect_from_expr(e->value.array_lit.elems[i], entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            break;
        case AST_EXPR_INDEX:
            dce_collect_from_expr(e->value.index.base, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            dce_collect_from_expr(e->value.index.index_expr, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
            break;
        default: break;
    }
}

/** 阶段 8.1 DCE 兜底：判断表达式 e 中是否出现对 func 的调用（CALL/METHOD_CALL），含 AST_EXPR_RETURN 内层。用于 ndep==0 时 used 未收到同模块 callee 仍保留被 main 引用的函数。 */
static int expr_references_func(const struct ASTExpr *e, const struct ASTFunc *func) {
    if (!e || !func) return 0;
    /* K-fix: AST_EXPR_BLOCK (unsafe 块) 递归检查其 block */
    if (e->kind == AST_EXPR_BLOCK && e->value.block)
        return block_references_func(e->value.block, func);
    if (e->kind == AST_EXPR_CALL && e->value.call.resolved_callee_func == func) return 1;
    if (e->kind == AST_EXPR_METHOD_CALL && e->value.method_call.resolved_impl_func == func) return 1;
    if (e->kind == AST_EXPR_RETURN && e->value.unary.operand && expr_references_func(e->value.unary.operand, func)) return 1;
    switch (e->kind) {
        case AST_EXPR_CALL:
            for (int i = 0; i < e->value.call.num_args; i++)
                if (expr_references_func(e->value.call.args[i], func)) return 1;
            break;
        case AST_EXPR_METHOD_CALL:
            if (expr_references_func(e->value.method_call.base, func)) return 1;
            for (int i = 0; i < e->value.method_call.num_args; i++)
                if (expr_references_func(e->value.method_call.args[i], func)) return 1;
            break;
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR: case AST_EXPR_ASSIGN:
        case AST_EXPR_ADD_ASSIGN: case AST_EXPR_SUB_ASSIGN: case AST_EXPR_MUL_ASSIGN: case AST_EXPR_DIV_ASSIGN: case AST_EXPR_MOD_ASSIGN:
        case AST_EXPR_BITAND_ASSIGN: case AST_EXPR_BITOR_ASSIGN: case AST_EXPR_BITXOR_ASSIGN: case AST_EXPR_SHL_ASSIGN: case AST_EXPR_SHR_ASSIGN:
            if (expr_references_func(e->value.binop.left, func) || expr_references_func(e->value.binop.right, func)) return 1;
            break;
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT: case AST_EXPR_PANIC: case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF:
        case AST_EXPR_AWAIT: case AST_EXPR_RUN: case AST_EXPR_SPAWN: case AST_EXPR_TRY_PROPAGATE:
            if (expr_references_func(e->value.unary.operand, func)) return 1;
            break;
        case AST_EXPR_AS:
            if (expr_references_func(e->value.as_type.operand, func)) return 1;
            break;
        case AST_EXPR_IF: case AST_EXPR_TERNARY:
            if (expr_references_func(e->value.if_expr.cond, func) || expr_references_func(e->value.if_expr.then_expr, func)) return 1;
            if (e->value.if_expr.else_expr && expr_references_func(e->value.if_expr.else_expr, func)) return 1;
            break;
        case AST_EXPR_MATCH:
            if (expr_references_func(e->value.match_expr.matched_expr, func)) return 1;
            for (int i = 0; i < e->value.match_expr.num_arms; i++)
                if (expr_references_func(e->value.match_expr.arms[i].result, func)) return 1;
            break;
        case AST_EXPR_FIELD_ACCESS:
            if (expr_references_func(e->value.field_access.base, func)) return 1;
            break;
        case AST_EXPR_STRUCT_LIT:
            for (int i = 0; i < e->value.struct_lit.num_fields; i++)
                if (expr_references_func(e->value.struct_lit.inits[i], func)) return 1;
            break;
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++)
                if (expr_references_func(e->value.array_lit.elems[i], func)) return 1;
            break;
        case AST_EXPR_INDEX:
            if (expr_references_func(e->value.index.base, func) || expr_references_func(e->value.index.index_expr, func)) return 1;
            break;
        default: break;
    }
    return 0;
}

/** 阶段 8.1 块内 DCE：将 name 加入 used 集合（去重），out 为指针数组，n 为当前个数，max 为上限。 */
static void add_used_var_name(const char *name, const char **out, int *n, int max) {
    if (!name || !out || !n || *n >= max) return;
    for (int i = 0; i < *n; i++) if (out[i] && strcmp(out[i], name) == 0) return;
    out[(*n)++] = name;
}

/** 从表达式中收集所有作为 VAR 出现的变量名到 out（用于块内 const/let DCE）。 */
static void collect_var_names_from_expr(const struct ASTExpr *e, const char **out, int *n, int max) {
    if (!e || *n >= max) return;
    if (e->kind == AST_EXPR_VAR && e->value.var.name)
        add_used_var_name(e->value.var.name, out, n, max);
    switch (e->kind) {
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR: case AST_EXPR_ASSIGN:
        case AST_EXPR_ADD_ASSIGN: case AST_EXPR_SUB_ASSIGN: case AST_EXPR_MUL_ASSIGN: case AST_EXPR_DIV_ASSIGN: case AST_EXPR_MOD_ASSIGN:
        case AST_EXPR_BITAND_ASSIGN: case AST_EXPR_BITOR_ASSIGN: case AST_EXPR_BITXOR_ASSIGN: case AST_EXPR_SHL_ASSIGN: case AST_EXPR_SHR_ASSIGN:
            collect_var_names_from_expr(e->value.binop.left, out, n, max);
            collect_var_names_from_expr(e->value.binop.right, out, n, max);
            break;
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT: case AST_EXPR_PANIC: case AST_EXPR_RETURN: case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF:
        case AST_EXPR_AWAIT: case AST_EXPR_RUN: case AST_EXPR_SPAWN: case AST_EXPR_TRY_PROPAGATE:
            if (e->value.unary.operand) collect_var_names_from_expr(e->value.unary.operand, out, n, max);
            break;
        case AST_EXPR_AS:
            if (e->value.as_type.operand) collect_var_names_from_expr(e->value.as_type.operand, out, n, max);
            break;
        case AST_EXPR_IF: case AST_EXPR_TERNARY:
            collect_var_names_from_expr(e->value.if_expr.cond, out, n, max);
            if (e->value.if_expr.then_expr) collect_var_names_from_expr(e->value.if_expr.then_expr, out, n, max);
            if (e->value.if_expr.else_expr) collect_var_names_from_expr(e->value.if_expr.else_expr, out, n, max);
            break;
        case AST_EXPR_BLOCK:
            if (e->value.block) collect_var_names_from_block(e->value.block, out, n, max);
            break;
        case AST_EXPR_MATCH:
            collect_var_names_from_expr(e->value.match_expr.matched_expr, out, n, max);
            for (int i = 0; i < e->value.match_expr.num_arms; i++)
                collect_var_names_from_expr(e->value.match_expr.arms[i].result, out, n, max);
            break;
        case AST_EXPR_FIELD_ACCESS:
            collect_var_names_from_expr(e->value.field_access.base, out, n, max);
            break;
        case AST_EXPR_STRUCT_LIT:
            for (int i = 0; i < e->value.struct_lit.num_fields; i++)
                collect_var_names_from_expr(e->value.struct_lit.inits[i], out, n, max);
            break;
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++)
                collect_var_names_from_expr(e->value.array_lit.elems[i], out, n, max);
            break;
        case AST_EXPR_INDEX:
            collect_var_names_from_expr(e->value.index.base, out, n, max);
            collect_var_names_from_expr(e->value.index.index_expr, out, n, max);
            break;
        case AST_EXPR_CALL:
            for (int i = 0; i < e->value.call.num_args; i++)
                collect_var_names_from_expr(e->value.call.args[i], out, n, max);
            break;
        case AST_EXPR_METHOD_CALL:
            collect_var_names_from_expr(e->value.method_call.base, out, n, max);
            for (int i = 0; i < e->value.method_call.num_args; i++)
                collect_var_names_from_expr(e->value.method_call.args[i], out, n, max);
            break;
        case AST_EXPR_ASM: {
            /* asm! 操作数引用的变量须计入「被使用」，否则块内 DCE 会漏掉它们的 let 声明（K1/L8）。 */
            int ai;
            for (ai = 0; ai < e->value.asm_tmpl.num_outputs; ai++)
                if (e->value.asm_tmpl.outputs[ai].expr) collect_var_names_from_expr(e->value.asm_tmpl.outputs[ai].expr, out, n, max);
            for (ai = 0; ai < e->value.asm_tmpl.num_inputs; ai++)
                if (e->value.asm_tmpl.inputs[ai].expr) collect_var_names_from_expr(e->value.asm_tmpl.inputs[ai].expr, out, n, max);
            break;
        }
        default: break;
    }
}

/** 从块中收集所有被引用的变量名（final_expr、const/let 的 init、循环 cond/body、defer、labeled）；用于仅输出被使用的 const/let。
 * 必须收集 while 的 cond（如 pad 在 while (z < pad) 中），否则 DCE 会漏掉 let pad 导致 -E 产出无 pad 声明的 C。 */
static void collect_var_names_from_block(const struct ASTBlock *b, const char **out, int *n, int max) {
    if (!b || *n >= max) return;
    for (int i = 0; i < b->num_consts; i++) {
        if (b->const_decls[i].init) collect_var_names_from_expr(b->const_decls[i].init, out, n, max);
    }
    for (int i = 0; i < b->num_lets; i++) {
        if (b->let_decls[i].init) collect_var_names_from_expr(b->let_decls[i].init, out, n, max);
    }
    for (int i = 0; i < b->num_loops; i++) {
        if (b->loops[i].cond) collect_var_names_from_expr(b->loops[i].cond, out, n, max);
        collect_var_names_from_block(b->loops[i].body, out, n, max);
    }
    for (int i = 0; i < b->num_for_loops; i++) {
        if (b->for_loops[i].init) collect_var_names_from_expr(b->for_loops[i].init, out, n, max);
        if (b->for_loops[i].cond) collect_var_names_from_expr(b->for_loops[i].cond, out, n, max);
        if (b->for_loops[i].step) collect_var_names_from_expr(b->for_loops[i].step, out, n, max);
        collect_var_names_from_block(b->for_loops[i].body, out, n, max);
    }
    for (int i = 0; i < b->num_defers; i++)
        collect_var_names_from_block(b->defer_blocks[i], out, n, max);
    for (int i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr)
            collect_var_names_from_expr(b->labeled_stmts[i].u.return_expr, out, n, max);
    /* region/unsafe 块体也须递归收集，否则仅在 unsafe{ } 内使用的变量会被 DCE 漏掉（K1 asm! 操作数亦在此） */
    for (int i = 0; i < b->num_regions; i++)
        if (b->regions[i].body) collect_var_names_from_block(b->regions[i].body, out, n, max);
    for (int i = 0; i < b->num_expr_stmts; i++)
        collect_var_names_from_expr(b->expr_stmts[i], out, n, max);
    if (b->final_expr) collect_var_names_from_expr(b->final_expr, out, n, max);
}

/** 判断 name 是否在 used 集合中（用于块内 const/let DCE）。 */
static int is_var_used(const char *name, const char **used, int n_used) {
    if (!name || !used) return 1;
    for (int i = 0; i < n_used; i++) if (used[i] && strcmp(used[i], name) == 0) return 1;
    return 0;
}

/**
 * let 初值是否含须保留的副作用（调用/run/spawn/await 等）。
 * 块内 DCE 跳过未引用 let 时，仍须 emit 为 (void)(init)，否则 async_switch 等烟测丢计数。
 */
static int let_init_has_side_effects(const struct ASTExpr *init) {
    if (!init) return 0;
    /* K2：volatile 指针的解引用（读）有副作用，不可被块内 DCE 消除（MMIO 探测读必须保留） */
    if (init->kind == AST_EXPR_DEREF && init->value.unary.operand) {
        const struct ASTType *ot = init->value.unary.operand->resolved_type;
        if (ot && ot->kind == AST_TYPE_PTR && ot->is_volatile)
            return 1;
    }
    switch (init->kind) {
        case AST_EXPR_CALL:
        case AST_EXPR_METHOD_CALL:
        case AST_EXPR_SPAWN:
        case AST_EXPR_RUN:
        case AST_EXPR_AWAIT:
        case AST_EXPR_TRY_PROPAGATE:
        case AST_EXPR_PANIC:
            return 1;
        default:
            return 0;
    }
}

/**
 * 未引用的 let：init 有副作用时输出 (void)(init);。
 * 返回 1 已处理，0 无副作用可跳过，-1 失败。
 */
static int codegen_emit_unused_let_side_effect(FILE *out, const char *pad, const struct ASTExpr *linit) {
    if (!let_init_has_side_effects(linit)) return 0;
    fprintf(out, "%s(void)(", pad);
    if (codegen_expr(linit, out) != 0) return -1;
    fprintf(out, ");\n");
    return 1;
}

/** .x 用原语：块中第 idx 条 const 是否被引用（1=是 0=否），.x 据此决定是否输出。 */
int32_t codegen_x_block_const_is_used(uint8_t *block, int32_t idx) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->const_decls || idx < 0 || idx >= b->num_consts) return 0;
    const char *used_buf[MAX_BLOCK_USED_VARS];
    int n_used = 0;
    collect_var_names_from_block(b, used_buf, &n_used, MAX_BLOCK_USED_VARS);
    const char *name = b->const_decls[idx].name ? b->const_decls[idx].name : "";
    return is_var_used(name, used_buf, n_used) ? 1 : 0;
}

/** .x 用原语：只写 const 声明前缀（indent + "const " + type + name + " = "），不写初值与分号。 */
int32_t codegen_x_emit_const_decl_prefix(uint8_t *out, uint8_t *block, int32_t idx, int32_t indent) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    FILE *f = (FILE *)out;
    if (!b || !f || !b->const_decls || idx < 0 || idx >= b->num_consts) return -1;
    const char *pad = (indent == 2) ? "  " : (indent == 4) ? "    " : "      ";
    const struct ASTType *ty = b->const_decls[idx].type;
    const struct ASTType *ety = codegen_emit_type(ty);
    if (ety && ety->kind == AST_TYPE_VECTOR) ensure_vector_typedef(ety, f);
    const char *name = b->const_decls[idx].name ? b->const_decls[idx].name : "";
    if (ety && ety->kind == AST_TYPE_NAMED && ety->name) fprintf(f, "%sconst %s %s = ", pad, c_type_str(ety), name);
    else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
        fprintf(f, "%sconst ", pad);
        emit_local_array_decl(ety, name, "", f);
        fprintf(f, "= ");
    } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) { ensure_slice_struct(ety, f); fprintf(f, "%sconst %s %s = ", pad, c_type_str(ety), name); }
    else fprintf(f, "%sconst %s %s = ", pad, ety ? c_type_str(ety) : "int32_t", name);
    return 0;
}

/** .x 用原语：只写 const 声明的初值部分（不写前缀与 ";\n"）。 */
int32_t codegen_x_emit_const_decl_init(uint8_t *out, uint8_t *block, int32_t idx) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    FILE *f = (FILE *)out;
    if (!b || !f || !b->const_decls || idx < 0 || idx >= b->num_consts) return -1;
    return codegen_init(b->const_decls[idx].type, b->const_decls[idx].init, f, b) != 0 ? -1 : 0;
}

/** .x 用原语：块中第 idx 条 let 是否被引用（1=是 0=否）。 */
int32_t codegen_x_block_let_is_used(uint8_t *block, int32_t idx) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    if (!b || !b->let_decls || idx < 0 || idx >= b->num_lets) return 0;
    const char *used_buf[MAX_BLOCK_USED_VARS];
    int n_used = 0;
    collect_var_names_from_block(b, used_buf, &n_used, MAX_BLOCK_USED_VARS);
    char place[32];
    const char *name = (b->let_decls[idx].name && b->let_decls[idx].name[0] && (unsigned char)b->let_decls[idx].name[0] > ' ') ? b->let_decls[idx].name : (snprintf(place, sizeof(place), "_l%d", idx), place);
    return is_var_used(name, used_buf, n_used) ? 1 : 0;
}

/** .x 用原语：只写 let 声明前缀（indent + type + name + " = "）。 */
int32_t codegen_x_emit_let_decl_prefix(uint8_t *out, uint8_t *block, int32_t idx, int32_t indent) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    FILE *f = (FILE *)out;
    if (!b || !f || !b->let_decls || idx < 0 || idx >= b->num_lets) return -1;
    const char *pad = (indent == 2) ? "  " : (indent == 4) ? "    " : "      ";
    const struct ASTType *ty = b->let_decls[idx].type;
    const struct ASTType *ety = codegen_emit_type(ty);
    if (ety && ety->kind == AST_TYPE_VECTOR) ensure_vector_typedef(ety, f);
    char let_place[32];
    const char *name = (b->let_decls[idx].name && b->let_decls[idx].name[0] && (unsigned char)b->let_decls[idx].name[0] > ' ') ? b->let_decls[idx].name : (snprintf(let_place, sizeof(let_place), "_l%d", idx), let_place);
    if (ety && ety->kind == AST_TYPE_PTR && ety->elem_type) fprintf(f, "%s%s * %s = ", pad, c_type_str(ety->elem_type), name);
    else if (ety && ety->kind == AST_TYPE_NAMED && ety->name) fprintf(f, "%s%s %s = ", pad, c_type_str(ety), name);
    else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
        fprintf(f, "%s", pad);
        emit_local_array_decl(ety, name, "", f);
        fprintf(f, "= ");
    } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) { ensure_slice_struct(ety, f); fprintf(f, "%s%s %s = ", pad, c_type_str(ety), name); }
    else fprintf(f, "%s%s %s = ", pad, ety ? c_type_str(ety) : "int32_t", name);
    return 0;
}

/** .x 用原语：只写 let 声明的初值部分。 */
int32_t codegen_x_emit_let_decl_init(uint8_t *out, uint8_t *block, int32_t idx) {
    const struct ASTBlock *b = (const struct ASTBlock *)block;
    FILE *f = (FILE *)out;
    if (!b || !f || !b->let_decls || idx < 0 || idx >= b->num_lets) return -1;
    return codegen_init(b->let_decls[idx].type, b->let_decls[idx].init, f, b) != 0 ? -1 : 0;
}

/** 判断块 b 中是否出现对 func 的调用（遍历 const/let/循环/labeled/final_expr）。 */
static int block_references_func(const struct ASTBlock *b, const struct ASTFunc *func) {
    if (!b || !func) return 0;
    for (int i = 0; i < b->num_consts; i++)
        if (b->const_decls[i].init && expr_references_func(b->const_decls[i].init, func)) return 1;
    for (int i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].init && expr_references_func(b->let_decls[i].init, func)) return 1;
    for (int i = 0; i < b->num_loops; i++)
        if (block_references_func(b->loops[i].body, func)) return 1;
    for (int i = 0; i < b->num_for_loops; i++) {
        if (b->for_loops[i].init && expr_references_func(b->for_loops[i].init, func)) return 1;
        if (b->for_loops[i].cond && expr_references_func(b->for_loops[i].cond, func)) return 1;
        if (b->for_loops[i].step && expr_references_func(b->for_loops[i].step, func)) return 1;
        if (block_references_func(b->for_loops[i].body, func)) return 1;
    }
    /* K-fix: unsafe/region 块内的函数调用也须递归收集,否则 unsafe{} 内调用的 helper 被 DCE 误删 */
    for (int i = 0; i < b->num_regions; i++)
        if (block_references_func(b->regions[i].body, func)) return 1;
    for (int i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr
            && expr_references_func(b->labeled_stmts[i].u.return_expr, func)) return 1;
    for (int i = 0; i < b->num_expr_stmts; i++)
        if (expr_references_func(b->expr_stmts[i], func)) return 1;
    if (b->final_expr && expr_references_func(b->final_expr, func)) return 1;
    return 0;
}

static void dce_collect_from_block(const struct ASTBlock *b, struct ASTModule *entry, struct ASTModule **dep_mods, int ndep,
    struct ASTFunc **worklist, int *n_wl, int max_wl, int *in_wl, int used_mono[][64], int used_mono_rows) {
    if (!b) return;
    for (int i = 0; i < b->num_consts; i++)
        if (b->const_decls[i].init) dce_collect_from_expr(b->const_decls[i].init, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
    for (int i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].init) dce_collect_from_expr(b->let_decls[i].init, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
    for (int i = 0; i < b->num_loops; i++)
        dce_collect_from_block(b->loops[i].body, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
    for (int i = 0; i < b->num_for_loops; i++) {
        if (b->for_loops[i].init) dce_collect_from_expr(b->for_loops[i].init, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
        if (b->for_loops[i].cond) dce_collect_from_expr(b->for_loops[i].cond, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
        if (b->for_loops[i].step) dce_collect_from_expr(b->for_loops[i].step, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
        dce_collect_from_block(b->for_loops[i].body, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
    }
    /* K-fix: unsafe/region 块体也须递归 DCE 收集 */
    for (int i = 0; i < b->num_regions; i++)
        dce_collect_from_block(b->regions[i].body, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
    for (int i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr)
            dce_collect_from_expr(b->labeled_stmts[i].u.return_expr, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
    for (int i = 0; i < b->num_expr_stmts; i++)
        dce_collect_from_expr(b->expr_stmts[i], entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
    if (b->final_expr) dce_collect_from_expr(b->final_expr, entry, dep_mods, ndep, worklist, n_wl, max_wl, in_wl, used_mono, used_mono_rows);
}

/** 入口根函数：main_func，或同模块内名为 entry/main 的顶层函数（main.x 用 entry）。 */
struct ASTFunc *codegen_entry_root_func(struct ASTModule *entry) {
    if (!entry) return NULL;
    if (entry->main_func) return entry->main_func;
    for (int i = 0; i < entry->num_funcs && entry->funcs; i++) {
        struct ASTFunc *f = entry->funcs[i];
        if (!f || !f->name || f->is_extern) continue;
        if (strcmp(f->name, "entry") == 0 || strcmp(f->name, "main") == 0)
            return f;
    }
    return NULL;
}

void codegen_compute_used(struct ASTModule *entry, struct ASTModule **dep_mods, int ndep,
    struct ASTFunc **used_funcs_out, int *n_used_out, int max_used,
    int used_mono[][64]) {
    struct ASTFunc *root = codegen_entry_root_func(entry);
    if (!root || !used_funcs_out || !n_used_out || max_used <= 0) return;
    if (used_mono) {
        for (int r = 0; r <= ndep; r++)
            for (int k = 0; k < 64; k++) used_mono[r][k] = 0;
    }
    int n = 0;
    used_funcs_out[n++] = root;
#define DCE_WORKLIST_MAX 512
    /* worklist 与 n_wl 放在同一 struct 内，避免栈上 n_wl 与 used_mono_rows 相邻导致 &n_wl 被误用为相邻变量地址（ASan 报 offset 52 越界） */
    struct dce_worklist {
        struct ASTFunc *list[DCE_WORKLIST_MAX];
        int n;
    } wl = { .n = 0 };
    wl.list[wl.n++] = root;
    int used_mono_rows = used_mono ? (1 + ndep) : 0;
    /* 种子：先遍历 main 体填满 worklist，再把 worklist 中所有函数加入 used，确保入口引用的 import 符号不被误删 */
    if (root->body)
        dce_collect_from_block(root->body, entry, dep_mods, ndep, wl.list, &wl.n, DCE_WORKLIST_MAX, NULL, used_mono, used_mono_rows);
    for (int i = 0; i < wl.n && n < max_used; i++) {
        struct ASTFunc *f = wl.list[i];
        if (!f) continue;
        int already = 0;
        for (int j = 0; j < n; j++) if (used_funcs_out[j] == f) { already = 1; break; }
        if (!already) used_funcs_out[n++] = f;
    }
    while (wl.n > 0) {
        struct ASTFunc *f = wl.list[--wl.n];
        if (!f || !f->body) continue;
        {
            int already = 0;
            for (int i = 0; i < n; i++) if (used_funcs_out[i] == f) { already = 1; break; }
            if (!already && n < max_used) used_funcs_out[n++] = f;
        }
        dce_collect_from_block(f->body, entry, dep_mods, ndep, wl.list, &wl.n, DCE_WORKLIST_MAX, NULL, used_mono, used_mono_rows);
    }
    *n_used_out = n;
#undef DCE_WORKLIST_MAX
}

/** 若 name 非空且未在 out[0..*n) 中则追加并返回 1，否则返回 0；*n 不超过 max。 */
static int add_used_type_name(const char *name, const char **out, int *n, int max) {
    if (!name || !*name || *n >= max) return 0;
    for (int i = 0; i < *n; i++) if (out[i] && strcmp(out[i], name) == 0) return 0;
    out[(*n)++] = name;
    return 1;
}

/** 从类型中收集 NAMED 类型名并递归 elem_type。 */
static void collect_type_from_type(const struct ASTType *ty, const char **out, int *n, int max) {
    if (!ty || *n >= max) return;
    if (ty->kind == AST_TYPE_NAMED && ty->name) add_used_type_name(ty->name, out, n, max);
    if (ty->elem_type) collect_type_from_type(ty->elem_type, out, n, max);
}

/** 从表达式中收集类型名（resolved_type、struct_lit.struct_name）并递归子表达式。 */
static void collect_type_from_expr(const struct ASTExpr *e, const char **out, int *n, int max) {
    if (!e || *n >= max) return;
    if (e->resolved_type) collect_type_from_type(e->resolved_type, out, n, max);
    if (e->kind == AST_EXPR_STRUCT_LIT && e->value.struct_lit.struct_name)
        add_used_type_name(e->value.struct_lit.struct_name, out, n, max);
    switch (e->kind) {
        case AST_EXPR_CALL:
            for (int i = 0; i < e->value.call.num_args; i++) collect_type_from_expr(e->value.call.args[i], out, n, max);
            break;
        case AST_EXPR_METHOD_CALL:
            collect_type_from_expr(e->value.method_call.base, out, n, max);
            for (int i = 0; i < e->value.method_call.num_args; i++) collect_type_from_expr(e->value.method_call.args[i], out, n, max);
            break;
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR: case AST_EXPR_ASSIGN:
        case AST_EXPR_ADD_ASSIGN: case AST_EXPR_SUB_ASSIGN: case AST_EXPR_MUL_ASSIGN: case AST_EXPR_DIV_ASSIGN: case AST_EXPR_MOD_ASSIGN:
        case AST_EXPR_BITAND_ASSIGN: case AST_EXPR_BITOR_ASSIGN: case AST_EXPR_BITXOR_ASSIGN: case AST_EXPR_SHL_ASSIGN: case AST_EXPR_SHR_ASSIGN:
            collect_type_from_expr(e->value.binop.left, out, n, max);
            collect_type_from_expr(e->value.binop.right, out, n, max);
            break;
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT: case AST_EXPR_PANIC: case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF:
        case AST_EXPR_AWAIT: case AST_EXPR_RUN: case AST_EXPR_SPAWN: case AST_EXPR_TRY_PROPAGATE:
        case AST_EXPR_RETURN:
            collect_type_from_expr(e->value.unary.operand, out, n, max);
            break;
        case AST_EXPR_AS:
            collect_type_from_expr(e->value.as_type.operand, out, n, max);
            break;
        case AST_EXPR_IF: case AST_EXPR_TERNARY:
            collect_type_from_expr(e->value.if_expr.cond, out, n, max);
            collect_type_from_expr(e->value.if_expr.then_expr, out, n, max);
            if (e->value.if_expr.else_expr) collect_type_from_expr(e->value.if_expr.else_expr, out, n, max);
            break;
        case AST_EXPR_MATCH:
            collect_type_from_expr(e->value.match_expr.matched_expr, out, n, max);
            for (int i = 0; i < e->value.match_expr.num_arms; i++) collect_type_from_expr(e->value.match_expr.arms[i].result, out, n, max);
            break;
        case AST_EXPR_FIELD_ACCESS:
            collect_type_from_expr(e->value.field_access.base, out, n, max);
            break;
        case AST_EXPR_STRUCT_LIT:
            for (int i = 0; i < e->value.struct_lit.num_fields; i++) collect_type_from_expr(e->value.struct_lit.inits[i], out, n, max);
            break;
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++) collect_type_from_expr(e->value.array_lit.elems[i], out, n, max);
            break;
        case AST_EXPR_INDEX:
            collect_type_from_expr(e->value.index.base, out, n, max);
            collect_type_from_expr(e->value.index.index_expr, out, n, max);
            break;
        default: break;
    }
}

/** 从块中收集类型名。 */
static void collect_type_from_block(const struct ASTBlock *b, const char **out, int *n, int max) {
    if (!b || *n >= max) return;
    for (int i = 0; i < b->num_consts; i++) {
        if (b->const_decls[i].type) collect_type_from_type(b->const_decls[i].type, out, n, max);
        if (b->const_decls[i].init) collect_type_from_expr(b->const_decls[i].init, out, n, max);
    }
    for (int i = 0; i < b->num_lets; i++) {
        if (b->let_decls[i].type) collect_type_from_type(b->let_decls[i].type, out, n, max);
        if (b->let_decls[i].init) collect_type_from_expr(b->let_decls[i].init, out, n, max);
    }
    for (int i = 0; i < b->num_loops; i++) collect_type_from_block(b->loops[i].body, out, n, max);
    for (int i = 0; i < b->num_for_loops; i++) {
        if (b->for_loops[i].init) collect_type_from_expr(b->for_loops[i].init, out, n, max);
        if (b->for_loops[i].cond) collect_type_from_expr(b->for_loops[i].cond, out, n, max);
        if (b->for_loops[i].step) collect_type_from_expr(b->for_loops[i].step, out, n, max);
        collect_type_from_block(b->for_loops[i].body, out, n, max);
    }
    for (int i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr)
            collect_type_from_expr(b->labeled_stmts[i].u.return_expr, out, n, max);
    for (int i = 0; i < b->num_expr_stmts; i++)
        collect_type_from_expr(b->expr_stmts[i], out, n, max);
    if (b->final_expr) collect_type_from_expr(b->final_expr, out, n, max);
}

/** 对已收集的类型名做结构体字段传递闭包：若某名为本模块或依赖中的 struct，则将其字段类型名加入集合（多轮至不动点）。 */
static void close_struct_types(struct ASTModule *entry, struct ASTModule **dep_mods, int ndep,
    const char **out, int *n, int max) {
    struct ASTModule *mods[33];
    int nmods = 0;
    if (entry) mods[nmods++] = entry;
    for (int i = 0; i < ndep && dep_mods && nmods < 33; i++) if (dep_mods[i]) mods[nmods++] = dep_mods[i];
    for (int round = 0; round < 8; round++) {
        int added = 0;
        for (int i = 0; i < *n; i++) {
            const char *name = out[i];
            if (!name) continue;
            for (int m = 0; m < nmods; m++) {
                struct ASTStructDef **sd = mods[m]->struct_defs;
                int num = mods[m]->num_structs;
                if (!sd) continue;
                for (int j = 0; j < num; j++) {
                    if (!sd[j] || !sd[j]->name || strcmp(sd[j]->name, name) != 0) continue;
                    for (int k = 0; k < sd[j]->num_fields; k++) {
                        const struct ASTType *fty = sd[j]->fields[k].type;
                        if (fty) collect_type_from_type(fty, out, n, max);
                    }
                    added = 1;
                    break;
                }
                if (added) break;
            }
        }
        if (!added) break;
    }
}

void codegen_compute_used_types(struct ASTModule *entry, struct ASTModule **dep_mods, int ndep,
    struct ASTFunc **used_funcs, int n_used, const char **used_type_names_out, int *n_out, int max_types) {
    if (!used_type_names_out || !n_out || max_types <= 0) return;
    *n_out = 0;
    for (int i = 0; i < n_used && used_funcs && used_funcs[i]; i++) {
        const struct ASTFunc *f = used_funcs[i];
        if (f->return_type) collect_type_from_type(f->return_type, used_type_names_out, n_out, max_types);
        for (int j = 0; j < f->num_params; j++)
            if (f->params[j].type) collect_type_from_type(f->params[j].type, used_type_names_out, n_out, max_types);
        if (f->body) collect_type_from_block(f->body, used_type_names_out, n_out, max_types);
    }
    close_struct_types(entry, dep_mods, ndep, used_type_names_out, n_out, max_types);
}

/**
 * C-04 parser/typeck/codegen -E-extern：slim ASTArena grow pool 原型。
 * 原由 fix_slim_arena_gen_c.pl 在 ast_ASTArena 后注入；codegen 产出后 perl 见 marker 则跳过重复注入。
 */
static void codegen_emit_slim_arena_glue_protos(FILE *out);

/** parser -E-extern 专用 hook（定义见 TU 别名区；此处前向声明供 dep/entry struct emit 调用）。 */
static int codegen_emit_path_is_parser_x(const char *path);
static void codegen_parser_eextern_after_dep_struct(FILE *out, const char *prefix, const char *struct_name);

/**
 * 阶段 3.1：仅输出 mods[0..n-1] 的类型定义（enum、struct，带 import_paths 前缀），不输出函数体。
 * 供 -E-extern 生成瘦 pipeline_gen.c 时先输出依赖类型，再输出入口模块（extern + 本体）。
 */
int codegen_emit_dep_types_only(struct ASTModule **mods, const char **import_paths, int n, FILE *out,
    char (*emitted_type_names)[CODEGEN_EMITTED_TYPE_NAME_MAX], int *n_emitted_inout, int max_emitted) {
    if (!mods || !import_paths || n < 0 || !out) return -1;
    /* C-04 v3：与入口模块共享 emitted_type_names，避免 dep 阶段与 entry 阶段重复输出 shux_slice_*。 */
    codegen_emitted_type_names = emitted_type_names;
    codegen_n_emitted_inout = n_emitted_inout;
    codegen_max_emitted = max_emitted;
    codegen_slice_emitted_n = 0;
    static char lib_prefix_buf[256];
    for (int i = 0; i < n; i++) {
        const struct ASTModule *d = mods[i];
        if (!d) continue;
        char pre[256];
        import_path_to_c_prefix(import_paths[i] ? import_paths[i] : "", pre, sizeof(pre));
        (void)snprintf(lib_prefix_buf, sizeof(lib_prefix_buf), "%s", pre);
        /* 设置库前缀与当前模块，使 c_type_str/emit_struct_field_c_type 输出带前缀的类型名（如 ast_Block）。
         * 前面已输出的模块作为当前模块的 dep，便于字段类型跨模块时用正确前缀（如 parser 的 struct 引用 ast_Module）。 */
        codegen_library_prefix = lib_prefix_buf;
        codegen_library_module = (struct ASTModule *)d;
        codegen_dep_mods = i > 0 ? (struct ASTModule **)(mods) : NULL;
        codegen_dep_paths = i > 0 ? (const char **)(import_paths) : NULL;
        codegen_ndep = i > 0 ? i : 0;
        if (d->enum_defs) {
            for (int j = 0; j < d->num_enums; j++) {
                const struct ASTEnumDef *ed = d->enum_defs[j];
                if (!ed || !ed->name) continue;
                fprintf(out, "enum %s%s { ", pre, ed->name);
                for (int k = 0; k < ed->num_variants; k++) {
                    if (k > 0) fprintf(out, ", ");
                    fprintf(out, "%s%s_%s", pre, ed->name, ed->variant_names[k] ? ed->variant_names[k] : "");
                }
                fprintf(out, " };\n");
            }
        }
        if (d->struct_defs) {
            for (int j = 0; j < d->num_structs; j++) {
                const struct ASTStructDef *sd = d->struct_defs[j];
                if (!sd) continue;
                for (int k = 0; k < sd->num_fields; k++)
                    if (sd->fields[k].type) ensure_slice_struct(sd->fields[k].type, out);
            }
            for (int j = 0; j < d->num_structs; j++) {
                const struct ASTStructDef *sd = d->struct_defs[j];
                if (!sd || !sd->name) continue;
                fprintf(out, "struct %s%s { ", pre, sd->name);
                for (int k = 0; k < sd->num_fields; k++) {
                    const struct ASTType *fty = sd->fields[k].type;
                    const char *fname = sd->fields[k].name ? sd->fields[k].name : "";
                    emit_struct_field_c_type(fty, fname, out, sd->fields[k].bitfield_width);
                }
                if (sd->packed)
                    fprintf(out, "} __attribute__((packed));\n");
                else
                    fprintf(out, "};\n");
                if (emitted_type_names)
                    codegen_parser_eextern_after_dep_struct(out, pre, sd->name);
            }
        }
    }
    /* -E-extern 瘦 TU（parser/typeck 等）须 slim arena pool 原型；pipeline 含 glue 时亦无害。 */
    if (emitted_type_names)
        codegen_emit_slim_arena_glue_protos(out);
    return 0;
}

/** C-04：slim arena grow pool glue 原型实现。 */
static void codegen_emit_slim_arena_glue_protos(FILE *out) {
    if (!out) return;
    fprintf(out, "/* slim arena grow pool glue (C-04 codegen; linked from pipeline/runtime) */\n");
    fprintf(out, "extern struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);\n");
    fprintf(out, "extern struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);\n");
    fprintf(out, "extern struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);\n");
    fprintf(out, "extern struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);\n");
    fprintf(out, "extern void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);\n");
    fprintf(out, "extern void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);\n");
    fprintf(out, "extern void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);\n");
    fprintf(out, "extern void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);\n");
    fprintf(out, "\n");
}

/**
 * C-04 v1：-E-extern 时 import 绑定前缀与链接符号前缀不一致则返回链接前缀。
 * 例：lsp.x import("lsp_io") 调用 lsp_io_*，lsp_io.x 产出 typeck_*（entry_lib_name 默认 typeck）。
 */
static void import_path_to_eextern_link_prefix(const char *import_path, char *buf, size_t size) {
    if (!buf || size == 0) return;
    if (import_path && strcmp(import_path, "lsp_io") == 0) {
        snprintf(buf, size, "typeck_");
        return;
    }
    import_path_to_c_prefix(import_path, buf, size);
}

/** C-04 -E-extern TU 别名缓冲（parser/typeck 等；替代 fix_slim_arena 部分 #define 注入）。 */
#define CODEGEN_TU_ALIAS_MAX 512
#define CODEGEN_TU_ALIAS_LINE_MAX 128
static char codegen_tu_alias_lines[CODEGEN_TU_ALIAS_MAX][CODEGEN_TU_ALIAS_LINE_MAX];
static int codegen_tu_alias_n;
/** C-04：-E-extern 入口路径（parser.x 等）；由 runtime 在 emit dep 前设置。 */
static const char *codegen_eextern_entry_path;
/** parser -E-extern：已在 struct ast_Expr 后输出 ast_expr_init_match_enum，import 阶段跳过重复。 */
static int codegen_parser_post_struct_expr_init_emitted;

/** 设置 -E-extern 入口路径；传 NULL 清空 parser 专用状态。 */
void codegen_set_eextern_entry_path(const char *entry_path) {
    codegen_eextern_entry_path = entry_path;
    codegen_parser_post_struct_expr_init_emitted = 0;
}

/** parser import extern 是否跳过 expr_init_match_enum（已在 dep 阶段 struct ast_Expr 后声明）。 */
static int codegen_skip_parser_expr_init_match_enum_import(const char *import_path,
    const struct ASTFunc *f) {
    if (!codegen_eextern_entry_path || !codegen_emit_path_is_parser_x(codegen_eextern_entry_path))
        return 0;
    if (!f || !f->name || strcmp(f->name, "expr_init_match_enum") != 0)
        return 0;
    return import_path && strstr(import_path, "ast") != NULL;
}

/** 清空 TU 别名表（每个 -E-extern 入口模块 emit 前调用）。 */
static void codegen_tu_alias_reset(void) {
    codegen_tu_alias_n = 0;
}

/** 追加一行 #define（去重）。 */
static void codegen_tu_alias_add_line(const char *line) {
    if (!line || !line[0] || codegen_tu_alias_n >= CODEGEN_TU_ALIAS_MAX) return;
    for (int i = 0; i < codegen_tu_alias_n; i++)
        if (strcmp(codegen_tu_alias_lines[i], line) == 0) return;
    (void)snprintf(codegen_tu_alias_lines[codegen_tu_alias_n], CODEGEN_TU_ALIAS_LINE_MAX, "%s", line);
    codegen_tu_alias_n++;
}

/** 根据 extern 链接符号注册 call→link TU 别名（与 fix_slim_arena_gen_c.pl forward 块一致）。 */
static void codegen_tu_alias_register_extern_sym(const char *sym) {
    char line[CODEGEN_TU_ALIAS_LINE_MAX];
    if (!sym || !sym[0]) return;
    if (strncmp(sym, "ast_pipeline_", 13) == 0) {
        (void)snprintf(line, sizeof(line), "#define pipeline_%s ast_pipeline_%s\n", sym + 13, sym + 13);
        codegen_tu_alias_add_line(line);
        return;
    }
    if (strncmp(sym, "ast_ast_arena_", 14) == 0) {
        (void)snprintf(line, sizeof(line), "#define ast_arena_%s ast_ast_arena_%s\n", sym + 14, sym + 14);
        codegen_tu_alias_add_line(line);
        return;
    }
    if (strncmp(sym, "ast_ast_block_", 14) == 0) {
        (void)snprintf(line, sizeof(line), "#define ast_block_%s ast_ast_block_%s\n", sym + 14, sym + 14);
        codegen_tu_alias_add_line(line);
        return;
    }
    if (strncmp(sym, "ast_ast_expr_", 13) == 0 && strncmp(sym + 13, "init_", 5) != 0) {
        (void)snprintf(line, sizeof(line), "#define ast_expr_%s ast_ast_expr_%s\n", sym + 13, sym + 13);
        codegen_tu_alias_add_line(line);
        return;
    }
    if (strncmp(sym, "ast_arena_", 10) == 0 && strncmp(sym, "ast_ast_arena_", 14) != 0) {
        (void)snprintf(line, sizeof(line), "#define %s ast_ast_%s\n", sym, sym);
        codegen_tu_alias_add_line(line);
        return;
    }
    if (strncmp(sym, "ast_block_", 10) == 0 && strncmp(sym, "ast_ast_block_", 14) != 0) {
        (void)snprintf(line, sizeof(line), "#define %s ast_ast_%s\n", sym, sym);
        codegen_tu_alias_add_line(line);
        return;
    }
    if (strncmp(sym, "ast_expr_", 9) == 0 && strncmp(sym, "ast_ast_expr_", 13) != 0 && strncmp(sym + 9, "init_", 5) != 0) {
        (void)snprintf(line, sizeof(line), "#define %s ast_ast_%s\n", sym, sym);
        codegen_tu_alias_add_line(line);
        return;
    }
    if (strncmp(sym, "lexer_lexer_", 12) == 0) {
        (void)snprintf(line, sizeof(line), "#define lexer_%s lexer_lexer_%s\n", sym + 12, sym + 12);
        codegen_tu_alias_add_line(line);
    }
}

/** parser -E-extern：onefunc const 池 API 的 pipeline→ast_pipeline TU 别名（原 fix_parser_pool perl）。 */
static void codegen_tu_alias_flush_parser_onefunc_const(FILE *out) {
    if (!out || !codegen_eextern_entry_path || !codegen_emit_path_is_parser_x(codegen_eextern_entry_path))
        return;
    fprintf(out, "extern int32_t ast_pipeline_onefunc_append_const(uint8_t * restrict out, uint8_t * restrict name, int32_t name_len, int32_t init_val, int32_t init_ref, int32_t type_ref);\n");
    fprintf(out, "extern int32_t ast_pipeline_onefunc_const_init_ref(uint8_t * restrict out, int32_t i);\n");
    fprintf(out, "extern int32_t ast_pipeline_onefunc_const_type_ref(uint8_t * restrict out, int32_t i);\n");
    fprintf(out, "#define pipeline_onefunc_append_const ast_pipeline_onefunc_append_const\n");
    fprintf(out, "#define pipeline_onefunc_const_init_ref ast_pipeline_onefunc_const_init_ref\n");
    fprintf(out, "#define pipeline_onefunc_const_type_ref ast_pipeline_onefunc_const_type_ref\n");
}

/** 输出已收集的 TU 别名块。 */
static void codegen_tu_alias_flush(FILE *out) {
    if (!out || codegen_tu_alias_n <= 0) return;
    fprintf(out, "\n/* C-04 -E-extern TU aliases */\n");
    for (int i = 0; i < codegen_tu_alias_n; i++)
        fputs(codegen_tu_alias_lines[i], out);
    codegen_tu_alias_flush_parser_onefunc_const(out);
    fprintf(out, "\n");
}

/** 判定 entry 是否为 parser.x -E-extern 路径。 */
static int codegen_emit_path_is_parser_x(const char *path) {
    return path && strstr(path, "parser.x") != NULL;
}

/**
 * parser -E-extern dep 类型阶段：struct ast_Expr 定义后立即声明 ast_expr_init_match_enum
 *（Alpine GCC -Wincompatible-pointer-types；原 fix_parser_pool perl 搬迁）。
 */
static void codegen_parser_eextern_after_dep_struct(FILE *out, const char *prefix, const char *struct_name) {
    if (!out || !prefix || !struct_name || !codegen_eextern_entry_path
        || !codegen_emit_path_is_parser_x(codegen_eextern_entry_path))
        return;
    if (strcmp(prefix, "ast_") != 0 || strcmp(struct_name, "Expr") != 0)
        return;
    fprintf(out, "\n/* C-04 parser: ast_expr_init_match_enum after struct ast_Expr */\n");
    fprintf(out, "extern void ast_expr_init_match_enum(struct ast_Expr *e);\n");
    codegen_parser_post_struct_expr_init_emitted = 1;
}

/** 判定参数是否为固定长度 u8 数组（如 parser copy_module_import_path64 的 out: [64]u8）。 */
static int codegen_param_is_u8_array(const struct ASTParam *p, int array_size) {
    const struct ASTType *ty = p ? p->type : NULL;
    return ty && ty->kind == AST_TYPE_ARRAY && ty->elem_type
        && ty->elem_type->kind == AST_TYPE_U8 && ty->array_size == array_size;
}

/**
 * 判定函数名是否属于 C 标准库（<string.h>/<stdlib.h>/<arpa/inet.h>/<stdio.h>）。
 *
 * 【Why 逻辑根源】SHUX 模块中 `extern function memcpy/memset/malloc/free/...` 声明会被
 *   codegen 直译为 `extern uint8_t * memcpy(uint8_t * dst, uint8_t * src, size_t n);`，
 *   与 preamble 已 `#include` 的 <string.h>/<stdlib.h> 中 `void *memcpy(void *, const void *, size_t)`
 *   类型冲突（Darwin secure/_string.h 还会把 memset/memcpy 展开为 __builtin___memset_chk 宏）。
 *   根源治理：识别这些 libc 符号后跳过 extern emit，让 C 编译器使用系统头文件中的正确声明。
 *
 * 【Invariant 状态不变量】纯查询函数，无副作用；不修改任何全局状态；输入 name 可为 NULL。
 *
 * 【Asm/Perf 性能预期】仅在 -E 模式输出库模块 extern 原型时调用，非编译热路径；
 *   线性查找 + 短路 strcmp，64 个符号平均 32 次比较，可忽略。
 */
static int codegen_is_c_stdlib_func_name(const char *name) {
    if (!name || !*name) return 0;
    static const char *const libc_funcs[] = {
        /* <string.h> */
        "memcpy", "memset", "memcmp", "memchr", "memmove", "strlen",
        "strcpy", "strncpy", "strcat", "strncat", "strcmp", "strncmp",
        "strchr", "strrchr", "strstr", "strtok", "strdup", "strndup",
        /* <stdlib.h> */
        "malloc", "free", "calloc", "realloc", "getenv", "posix_memalign",
        "atoi", "atol", "atoll", "strtol", "strtoul", "strtoll", "strtoull", "strtod",
        "exit", "abort", "atexit", "system", "qsort", "rand", "srand", "abs",
        /* <arpa/inet.h> / <machine/endian.h>：ntohl/ntohs/htonl/htons 不在此跳过 ——
         * 它们的 SHUX 签名 (u32→u32 / u16→u16) 与系统签名完全匹配，直接 emit extern 原型即可。
         * 不能 #include <arpa/inet.h>：glibc 上它会间接包含 <sys/socket.h>，与 shux 的
         * extern function bind(...)/setsockopt(...)/sendto(...)/recvfrom(...) 签名冲突。 */
        /* <stdio.h> */
        "printf", "fprintf", "sprintf", "snprintf", "vprintf", "vfprintf", "vsprintf", "vsnprintf",
        "fopen", "fclose", "fread", "fwrite", "fgets", "fputs", "fgetc", "fputc",
        "fseek", "ftell", "feof", "ferror", "fflush", "setbuf", "setvbuf",
        NULL
    };
    for (int i = 0; libc_funcs[i]; i++) {
        if (strcmp(name, libc_funcs[i]) == 0) return 1;
    }
    return 0;
}

/**
 * 输出模块内显式 extern 函数原型（pipeline.x 的 extern function 等）。
 * copy_module_import_path64 第三参强制 out[64]（与 parser.x 实现一致，避免 uint8_t* 与数组形参冲突）。
 *
 * 【Why 逻辑根源】C 标准库函数（memcpy/memset/malloc 等）由 preamble 的 #include 提供正确声明，
 *   这里若再 emit 一份类型不匹配的 extern 会与系统头文件冲突。codegen_is_c_stdlib_func_name 命中即跳过。
 */
static void codegen_emit_module_extern_func_proto(FILE *out, const struct ASTFunc *f) {
    if (!f || !out) return;
    const char *name = f->name ? f->name : "";
    /* C 标准库函数：跳过 extern emit，使用 preamble 中 #include 的系统头文件声明 */
    if (codegen_is_c_stdlib_func_name(name)) return;
    if (strstr(name, "copy_module_import_path64") != NULL && f->num_params == 3) {
        fprintf(out, "extern %s %s(", c_type_str(f->return_type), name);
        codegen_emit_param(&f->params[0], out, NULL, 0);
        fprintf(out, ", ");
        codegen_emit_param(&f->params[1], out, NULL, 1);
        fprintf(out, ", uint8_t out[64]");
        fprintf(out, ");\n");
        codegen_tu_alias_register_extern_sym(name);
        return;
    }
    const char *emit_name = f->link_name ? f->link_name : name;  /* L9：#[link_name] 用指定符号名 */
    fprintf(out, "extern %s %s(", c_type_str(f->return_type), emit_name);
    for (int j = 0; j < f->num_params; j++) {
        if (j) fprintf(out, ", ");
        codegen_emit_param(&f->params[j], out, NULL, j);
    }
    fprintf(out, ");\n");
    codegen_tu_alias_register_extern_sym(emit_name);
}

/** 输出 import 函数 extern 原型。 */
static void codegen_emit_import_func_extern_proto(FILE *out, const char *sym_prefix,
    const struct ASTFunc *f, const char *import_path) {
    if (codegen_skip_parser_expr_init_match_enum_import(import_path, f))
        return;
    const struct ASTModule *imp_mod = codegen_module_for_import_path(import_path);
    const char *link = func_link_name(imp_mod, f);
    const char *fname = link ? link : (f->name ? f->name : "");
    /* C-04 parser：std.heap alloc_zero 链 void* heap_alloc_zeroed_c，与 ast_gen2 inject 一致。 */
    if (import_path && strstr(import_path, "heap") != NULL && f->name && strcmp(f->name, "alloc_zero") == 0) {
        fprintf(out, "extern void *%s%s(", sym_prefix, fname);
        for (int j = 0; j < f->num_params; j++) {
            if (j) fprintf(out, ", ");
            codegen_emit_param(&f->params[j], out, codegen_io_driver_param_override(import_path, f->name, j), j);
        }
        fprintf(out, ");\n");
        {
            char full[320];
            (void)snprintf(full, sizeof(full), "%s%s", sym_prefix, fname);
            codegen_tu_alias_register_extern_sym(full);
        }
        return;
    }
    /* C-04 v3：parser copy_module_import_path64 第三参须 out[64]，勿生成 uint8_t *out（Alpine -Warray-parameter）。 */
    if (f->name && strcmp(f->name, "copy_module_import_path64") == 0 && f->num_params == 3
        && (codegen_param_is_u8_array(&f->params[2], 64)
            || (f->params[2].type && f->params[2].type->kind == AST_TYPE_PTR))) {
        fprintf(out, "extern %s %s%s(", c_type_str(f->return_type), sym_prefix, fname);
        codegen_emit_param(&f->params[0], out, codegen_io_driver_param_override(import_path, f->name, 0), 0);
        fprintf(out, ", ");
        codegen_emit_param(&f->params[1], out, codegen_io_driver_param_override(import_path, f->name, 1), 1);
        fprintf(out, ", uint8_t out[64]");
        fprintf(out, ");\n");
        {
            char full[320];
            (void)snprintf(full, sizeof(full), "%s%s", sym_prefix, fname);
            codegen_tu_alias_register_extern_sym(full);
        }
        return;
    }
    fprintf(out, "extern %s %s%s(", c_type_str(f->return_type), sym_prefix, fname);
    for (int j = 0; j < f->num_params; j++) {
        if (j) fprintf(out, ", ");
        codegen_emit_param(&f->params[j], out, codegen_io_driver_param_override(import_path, f->name, j), j);
    }
    fprintf(out, ");\n");
    {
        char full[320];
        (void)snprintf(full, sizeof(full), "%s%s", sym_prefix, fname);
        codegen_tu_alias_register_extern_sym(full);
    }
}

/** C-04 v1：链接前缀与调用前缀不同时，输出 extern(link) + static inline wrapper(call)。 */
static void codegen_emit_import_extern_with_optional_wrapper(FILE *out, const char *import_path,
    const struct ASTFunc *f) {
    char call_pre[256];
    char link_pre[256];
    import_path_to_c_prefix(import_path, call_pre, sizeof(call_pre));
    import_path_to_eextern_link_prefix(import_path, link_pre, sizeof(link_pre));
    const struct ASTModule *imp_mod = codegen_module_for_import_path(import_path);
    const char *link = func_link_name(imp_mod, f);
    const char *fname = link ? link : (f->name ? f->name : "");
    if (strcmp(call_pre, link_pre) != 0) {
        codegen_emit_import_func_extern_proto(out, link_pre, f, import_path);
        if (f->return_type && f->return_type->kind == AST_TYPE_ARRAY) ensure_arr_ret_struct(f->return_type, out);
        const char *imp_ret = (f->return_type && f->return_type->kind == AST_TYPE_ARRAY && f->return_type->array_size > 0) ? arr_ret_wrapper_name(f->return_type) : c_type_str(f->return_type);
        fprintf(out, "static inline %s%s %s%s(", (f->return_type && f->return_type->kind == AST_TYPE_ARRAY) ? "struct " : "", imp_ret, call_pre, fname);
        for (int j = 0; j < f->num_params; j++) {
            if (j) fprintf(out, ", ");
            codegen_emit_param(&f->params[j], out, codegen_io_driver_param_override(import_path, f->name, j), j);
        }
        fprintf(out, ") {\n  return %s%s(", link_pre, fname);
        for (int j = 0; j < f->num_params; j++) {
            if (j) fprintf(out, ", ");
            if (f->params[j].name && f->params[j].name[0])
                fprintf(out, "%s", f->params[j].name);
            else
                fprintf(out, "_p%d", j);
        }
        fprintf(out, ");\n}\n");
        return;
    }
    codegen_emit_import_func_extern_proto(out, call_pre, f, import_path);
}

/**
 * 收集本模块对 import 的调用并输出 extern 声明（含泛型单态）。
 * force_emit=1：-E-extern 瘦 TU 入口也输出（C-04）；force_emit=0 时单文件 deps 已内联则跳过。
 * skip_paths/skip_n：跳过指定 import 路径（如 std.heap 由 lsp heap 别名块处理）。
 */
static void codegen_emit_module_import_extern_decls(struct ASTModule *m, FILE *out, int force_emit,
    const char **skip_paths, int skip_n) {
    if (!m || !out) return;
    if (!force_emit && codegen_emitted_type_names) return;
    if (force_emit)
        codegen_tu_alias_reset();

    const char *imp_paths[MAX_IMPORT_DECLS];
    struct ASTFunc *imp_funcs[MAX_IMPORT_DECLS];
    int nimp = 0;
    const char *gen_paths[MAX_GEN_IMPORT_DECLS];
    struct ASTFunc *gen_funcs[MAX_GEN_IMPORT_DECLS];
    struct ASTType **gen_type_args[MAX_GEN_IMPORT_DECLS];
    int gen_n[MAX_GEN_IMPORT_DECLS];
    int gen_count = 0;
    for (int i = 0; i < m->num_funcs && m->funcs; i++)
        if (m->funcs[i] && m->funcs[i]->body)
            collect_import_calls_from_block(m->funcs[i]->body, imp_paths, imp_funcs, &nimp,
                gen_paths, gen_funcs, gen_type_args, gen_n, &gen_count);
    for (int i = 0; i < m->num_top_level_lets && m->top_level_lets; i++)
        if (m->top_level_lets[i].init)
            collect_import_calls_from_expr(m->top_level_lets[i].init, imp_paths, imp_funcs, &nimp,
                gen_paths, gen_funcs, gen_type_args, gen_n, &gen_count);
    for (int i = 0; i < nimp; i++) {
        const struct ASTFunc *f = imp_funcs[i];
        if (f->return_type) ensure_slice_struct(f->return_type, out);
        for (int j = 0; j < f->num_params; j++)
            if (f->params[j].type) ensure_slice_struct(f->params[j].type, out);
    }
    for (int i = 0; i < gen_count; i++) {
        const struct ASTFunc *f = gen_funcs[i];
        struct ASTType **ta = gen_type_args[i];
        int nta = gen_n[i];
        const struct ASTType *ret_ty = subst_type(f->return_type, f->generic_param_names, ta, nta);
        if (ret_ty) ensure_slice_struct(ret_ty, out);
        for (int j = 0; j < f->num_params; j++) {
            const struct ASTType *pt = subst_type(f->params[j].type, f->generic_param_names, ta, nta);
            if (pt) ensure_slice_struct(pt, out);
        }
    }
    for (int i = 0; i < nimp; i++) {
        int skip = 0;
        for (int si = 0; si < skip_n && skip_paths; si++)
            if (skip_paths[si] && imp_paths[i] && strcmp(skip_paths[si], imp_paths[i]) == 0) { skip = 1; break; }
        if (skip) continue;
        if (codegen_skip_parser_expr_init_match_enum_import(imp_paths[i], imp_funcs[i]))
            continue;
        if (force_emit)
            codegen_emit_import_extern_with_optional_wrapper(out, imp_paths[i], imp_funcs[i]);
        else {
            char pre[256];
            import_path_to_c_prefix(imp_paths[i], pre, sizeof(pre));
            const struct ASTFunc *f = imp_funcs[i];
            const struct ASTModule *imp_mod = codegen_module_for_import_path(imp_paths[i]);
            const char *link = func_link_name(imp_mod, f);
            if (f->is_extern || !f->body)
                fprintf(out, "extern %s %s(", c_type_str(f->return_type), link ? link : (f->name ? f->name : ""));
            else
                fprintf(out, "extern %s %s%s(", c_type_str(f->return_type), pre, link ? link : (f->name ? f->name : ""));
            for (int j = 0; j < f->num_params; j++) {
                if (j) fprintf(out, ", ");
                codegen_emit_param(&f->params[j], out, codegen_io_driver_param_override(imp_paths[i], f->name, j), j);
            }
            fprintf(out, ");\n");
        }
    }
    for (int i = 0; i < gen_count; i++) {
        int skip = 0;
        for (int si = 0; si < skip_n && skip_paths; si++)
            if (skip_paths[si] && gen_paths[i] && strcmp(skip_paths[si], gen_paths[i]) == 0) { skip = 1; break; }
        if (skip) continue;
        const struct ASTFunc *f = gen_funcs[i];
        struct ASTType **ta = gen_type_args[i];
        int nta = gen_n[i];
        const struct ASTType *ret_ty = subst_type(f->return_type, f->generic_param_names, ta, nta);
        char pre[256];
        import_path_to_c_prefix(gen_paths[i], pre, sizeof(pre));
        fprintf(out, "extern %s %s%s(", c_type_str(ret_ty), pre, mono_instance_mangled_name_ex(
            codegen_module_for_import_path(gen_paths[i]), f, ta, nta));
        for (int j = 0; j < f->num_params; j++) {
            if (j) fprintf(out, ", ");
            const struct ASTType *pt = subst_type(f->params[j].type, f->generic_param_names, ta, nta);
            codegen_emit_param(&f->params[j], out, pt, j);
        }
        fprintf(out, ");\n");
    }
}

/**
 * 将入口模块生成 C；功能、参数、返回值见 codegen.h 声明处注释。
 * 多函数：先生成所有函数的 vector/slice 前置定义，再按「非 main 先、main 最后」生成各函数定义。
 */
int codegen_module_to_c(struct ASTModule *m, FILE *out, struct ASTModule **dep_mods, const char **dep_import_paths, int ndep,
    codegen_is_func_used_fn is_func_used, codegen_is_mono_used_fn is_mono_used, codegen_is_type_used_fn is_type_used, void *dce_ctx,
    char (*emitted_type_names)[CODEGEN_EMITTED_TYPE_NAME_MAX], int *n_emitted_inout, int max_emitted) {
    if (!m || !out) return -1;
    if (!m->main_func || !m->main_func->body) return -1;
    if (strcmp(m->main_func->name, "main") != 0) return -1;
    if (!m->funcs || m->num_funcs <= 0) return -1;

    /* 【Why 根源】codegen_library_prefix 是 static 变量，上次 codegen_library_module_to_c 调用后
     * 可能残留非 NULL 值。若不重置，下方 main 函数生成分支 `!codegen_library_prefix` 为假，
     * main 被当库函数加前缀生成，链接器找不到 _main 符号。 */
    codegen_library_prefix = NULL;
    codegen_library_module = NULL;
    codegen_library_import_path = NULL;

    codegen_current_module = m;
    codegen_dep_mods = dep_mods;
    codegen_dep_paths = dep_import_paths;
    codegen_ndep = dep_mods && dep_import_paths ? ndep : 0;
    codegen_emitted_type_names = emitted_type_names;
    codegen_n_emitted_inout = n_emitted_inout;
    codegen_max_emitted = max_emitted;
    if (!emitted_type_names)
        codegen_slice_emitted_n = 0;
    codegen_vector_emitted_n = 0;
    fprintf(out, "#include <stdio.h>\n");
    fprintf(out, "#include <stdlib.h>\n");
    fprintf(out, "#include <stdint.h>\n");
    fprintf(out, "#include <stddef.h>\n");
    fprintf(out, "#include <string.h>\n"); /* memcpy 用于数组拷贝（自举 parser.x 中 let/const 数组 = 变量） */
    /* macOS <sys/_endian.h> 将 htonl/htons/ntohl/ntohs 定义为宏（__DARWIN_OSSwapInt*），
     * 导致后续 extern uint32_t htonl(uint32_t) 声明被宏展开后语法错误。
     * Linux glibc 上这四个是真正的函数符号，#undef 是 no-op，不影响。
     * 【Why】commit 393f9fd1 移除跳过列表，直接 emit extern 原型（Linux GCC 需要）；
     *   macOS 须先 #undef 宏才能让 extern 声明通过。
     * 【Invariant】#undef 后这四个符号均为函数声明，由 libc 链接器解析。
     * 【Asm/Perf】无运行时开销，仅影响预处理。 */
    fprintf(out, "#undef htonl\n#undef htons\n#undef ntohl\n#undef ntohs\n");
    /* 【Why 根源】PE/COFF 不支持 weak 函数符号：MinGW 编译 __attribute__((weak)) 函数时
     * 生成 .weak.<name>. 实现体 + <name> weak 别名。ld -r 部分链接（合并 tar.o/net.o 等）
     * 会丢弃 weak 别名，导致最终链接报 undefined reference。
     * Windows 下改为强符号，靠 --allow-multiple-definition 选第一个定义（与 ELF weak 语义对齐）。
     * 【Invariant】SHUX_LIB_WEAK 在 Linux/macOS 展开为 __attribute__((weak))，行为不变；
     * Windows 展开为空，函数变强符号。
     * 【Asm/Perf】无运行时开销，仅影响链接期符号解析。 */
    fprintf(out, "#ifdef _WIN32\n#define SHUX_LIB_WEAK\n#else\n#define SHUX_LIB_WEAK __attribute__((weak))\n#endif\n");
    /* CORE-009：clz/ctz/popcount/bswap/rotl/rotr 调用点经 builtin_intrinsic_name 重映射为 shux_builtin_*，
     * 此处 emit static inline 包装器（__builtin_* + x==0 边界），避免 cc 报未声明符号。 */
    codegen_emit_builtin_inline_decls(out);
    /* std.process：入口 main 写 argc/argv；weak 供 minimal 链，process.o 强符号覆盖。
     * 【Why 根源】Windows/MinGW 上 __attribute__((weak)) 变量行为与 ELF 不同：
     * weak 定义生成 .weak.<name>.<module> 符号，main 函数中 shux_process_argc = argc;
     * 写的是 weak 定义（地址 A），而 process_args_count_c() 读的是 runtime_process_argv.o
     * 的强符号（地址 B），地址不同 → args_count() 永远返回 0。
     * Windows 改为 extern 声明，由 runtime_process_argv.o 提供唯一定义。
     * 【Invariant】Windows -o 模式总链 runtime_process_argv.o（ensure_runtime_process_argv_o）；
     * 非 Windows 保留 weak 供 SHUX_MINIMAL_CC_LINK minimal 链（不链 runtime_process_argv.o）。
     * 【Asm/Perf】无运行时开销，仅影响链接期符号解析。 */
    fprintf(out, "#ifdef _WIN32\n");
    fprintf(out, "extern int shux_process_argc;\n");
    fprintf(out, "extern char **shux_process_argv;\n");
    fprintf(out, "#else\n");
    fprintf(out, "__attribute__((weak)) int shux_process_argc = 0;\n");
    fprintf(out, "__attribute__((weak)) char **shux_process_argv = NULL;\n");
    fprintf(out, "#endif\n");
    /* 单文件模式（emitted_type_names 非 NULL）时依赖类型已在前面写出，此处不再重复输出，避免 C 重定义 */
    if (!emitted_type_names && codegen_ndep > 0 && codegen_dep_mods && codegen_dep_paths) {
        /* 依赖模块中的 enum 须在 struct 之前输出，避免 struct 字段 "enum prefix_Name" 引用不完整类型 */
        for (int i = 0; i < codegen_ndep; i++) {
            const struct ASTModule *d = codegen_dep_mods[i];
            if (!d || !d->enum_defs) continue;
            char pre[256];
            import_path_to_c_prefix(codegen_dep_paths[i], pre, sizeof(pre));
            for (int j = 0; j < d->num_enums; j++) {
                const struct ASTEnumDef *ed = d->enum_defs[j];
                if (!ed || !ed->name) continue;
                fprintf(out, "enum %s%s { ", pre, ed->name);
                for (int k = 0; k < ed->num_variants; k++) {
                    if (k > 0) fprintf(out, ", ");
                    fprintf(out, "%s%s_%s", pre, ed->name, ed->variant_names[k] ? ed->variant_names[k] : "");
                }
                fprintf(out, " };\n");
            }
        }
        /* 依赖模块中的 struct 须在 extern 声明之前输出，避免 extern 引用不完整类型（如 std.mem.Buffer） */
        for (int i = 0; i < codegen_ndep; i++) {
            const struct ASTModule *d = codegen_dep_mods[i];
            if (!d || !d->struct_defs) continue;
            for (int j = 0; j < d->num_structs; j++) {
                const struct ASTStructDef *sd = d->struct_defs[j];
                if (!sd) continue;
                for (int k = 0; k < sd->num_fields; k++)
                    if (sd->fields[k].type) ensure_slice_struct(sd->fields[k].type, out);
            }
        }
        for (int i = 0; i < codegen_ndep; i++) {
            const struct ASTModule *d = codegen_dep_mods[i];
            if (!d || !d->struct_defs) continue;
            char pre[256];
            import_path_to_c_prefix(codegen_dep_paths[i], pre, sizeof(pre));
                for (int j = 0; j < d->num_structs; j++) {
                const struct ASTStructDef *sd = d->struct_defs[j];
                if (!sd || !sd->name) continue;
                fprintf(out, "struct %s%s { ", pre, sd->name);
                for (int k = 0; k < sd->num_fields; k++) {
                    const struct ASTType *fty = sd->fields[k].type;
                    const char *fname = sd->fields[k].name ? sd->fields[k].name : "";
                    emit_struct_field_c_type(fty, fname, out, sd->fields[k].bitfield_width);
                }
                fprintf(out, "};\n");
            }
        }
        /* 依赖模块顶层 const：#define prefix_NAME init，供裸名 DB_ROW_OK 等跨模块引用。 */
        for (int i = 0; i < codegen_ndep; i++) {
            const struct ASTModule *d = codegen_dep_mods[i];
            if (!d || !d->top_level_lets) continue;
            char pre[256];
            import_path_to_c_prefix(codegen_dep_paths[i], pre, sizeof(pre));
            for (int j = 0; j < d->num_top_level_lets; j++) {
                const struct ASTLetDecl *lc = &d->top_level_lets[j];
                char cname[256];
                if (!lc->is_const || !lc->name || !lc->init) continue;
                codegen_join_import_prefix_func_name(pre, lc->name, cname, sizeof(cname));
                fprintf(out, "#define %s ", cname);
                if (codegen_expr(lc->init, out) != 0)
                    fprintf(out, "0");
                fprintf(out, "\n");
            }
        }
    }
    /* 跨模块 import 调用 extern（单文件 deps 已内联时跳过，见 codegen_emit_module_import_extern_decls）。 */
    codegen_emit_module_import_extern_decls(m, out, 0, NULL, 0);
    /* 为所有函数体块及泛型单态化实例体生成 vector/slice 前置定义 */
    for (int i = 0; i < m->num_funcs && m->funcs; i++)
        if (m->funcs[i] && m->funcs[i]->body)
            ensure_block_vector_typedefs(m->funcs[i]->body, out);
    for (int k = 0; k < m->num_mono_instances && m->mono_instances; k++)
        if (m->mono_instances[k].template && m->mono_instances[k].template->body)
            ensure_block_vector_typedefs(m->mono_instances[k].template->body, out);
    for (int k = 0; k < m->num_impl_blocks && m->impl_blocks; k++)
        for (int j = 0; j < m->impl_blocks[k]->num_funcs; j++)
            if (m->impl_blocks[k]->funcs[j]->body)
                ensure_block_vector_typedefs(m->impl_blocks[k]->funcs[j]->body, out);
    /* 入口模块自身函数若参数/返回为 []T / 向量，须先输出 slice/typedef，避免 C 不完整类型 */
    for (int i = 0; i < m->num_funcs && m->funcs; i++) {
        const struct ASTFunc *f = m->funcs[i];
        if (!f || strcmp(f->name, "main") == 0 || f->num_generic_params > 0) continue;
        ensure_func_sig_vector_typedefs(f, out);
        if (f->return_type) ensure_slice_struct(f->return_type, out);
        for (int j = 0; j < f->num_params; j++)
            if (f->params[j].type) ensure_slice_struct(f->params[j].type, out);
    }
    for (int k = 0; k < m->num_impl_blocks && m->impl_blocks; k++)
        for (int j = 0; j < m->impl_blocks[k]->num_funcs; j++) {
            const struct ASTFunc *f = m->impl_blocks[k]->funcs[j];
            if (!f) continue;
            ensure_func_sig_vector_typedefs(f, out);
            if (f->return_type) ensure_slice_struct(f->return_type, out);
            for (int p = 0; p < f->num_params; p++)
                if (f->params[p].type) ensure_slice_struct(f->params[p].type, out);
        }
    for (int k = 0; k < m->num_mono_instances && m->mono_instances; k++) {
        const struct ASTMonoInstance *inst = &m->mono_instances[k];
        if (!inst->template || !inst->type_args) continue;
        const struct ASTFunc *f = inst->template;
        ensure_func_sig_vector_typedefs(f, out);
        const struct ASTType *ret_ty = subst_type(f->return_type, f->generic_param_names, inst->type_args, inst->num_type_args);
        if (ret_ty && ret_ty->kind == AST_TYPE_VECTOR) ensure_vector_typedef(ret_ty, out);
        if (ret_ty) ensure_slice_struct(ret_ty, out);
        for (int p = 0; p < f->num_params; p++) {
            const struct ASTType *pt = subst_type(f->params[p].type, f->generic_param_names, inst->type_args, inst->num_type_args);
            if (pt && pt->kind == AST_TYPE_VECTOR) ensure_vector_typedef(pt, out);
            if (pt) ensure_slice_struct(pt, out);
        }
    }
    /* 顶层枚举定义 → C enum；阶段 8.1 DCE 扩展：若 is_type_used 非 NULL 则仅输出被引用枚举；单文件去重时已出现则跳过 */
    for (int i = 0; i < m->num_enums && m->enum_defs; i++) {
        const struct ASTEnumDef *ed = m->enum_defs[i];
        if (!ed || !ed->name) continue;
        if (dce_ctx && is_type_used && !is_type_used(dce_ctx, m, ed->name)) continue;
        if (emitted_type_names && n_emitted_inout && emitted_type_contains(ed->name, emitted_type_names, *n_emitted_inout)) continue;
        fprintf(out, "enum %s { ", ed->name);
        for (int j = 0; j < ed->num_variants; j++) {
            if (j > 0) fprintf(out, ", ");
            fprintf(out, "%s_%s", ed->name, ed->variant_names[j] ? ed->variant_names[j] : "");
        }
        fprintf(out, " };\n");
        if (emitted_type_names && n_emitted_inout) emitted_type_add(ed->name, emitted_type_names, n_emitted_inout, max_emitted);
    }
    /* 顶层结构体定义 → C struct；阶段 8.1 DCE 扩展：若 is_type_used 非 NULL 则仅输出被引用结构体；单文件去重时已出现则跳过。
     * 自举：若某结构体被本模块将输出的函数的返回/参数类型使用（含指针参数 *T），则强制输出，避免 DCE 未收集到导致 incomplete type。 */
    for (int i = 0; i < m->num_structs && m->struct_defs; i++) {
        const struct ASTStructDef *sd = m->struct_defs[i];
        if (!sd || !sd->name) continue;
        /* LANG-009/CORE-016：泛型 struct 模板仅由 typeck 单态化，不直接输出 C struct */
        if (sd->num_generic_params > 0) continue;
        {
            int need_for_sig = 0;
            for (int fi = 0; fi < m->num_funcs && m->funcs && !need_for_sig; fi++) {
                const struct ASTFunc *f = m->funcs[fi];
                if (!f || strcmp(f->name, "main") == 0 || f->num_generic_params > 0 || f->is_extern || !f->body) continue;
                if (f->return_type && f->return_type->kind == AST_TYPE_NAMED && f->return_type->name && strcmp(f->return_type->name, sd->name) == 0) need_for_sig = 1;
                for (int p = 0; p < f->num_params && !need_for_sig; p++) {
                    const struct ASTType *pt = f->params[p].type;
                    if (!pt) continue;
                    if (pt->kind == AST_TYPE_NAMED && pt->name && strcmp(pt->name, sd->name) == 0) need_for_sig = 1;
                    if (!need_for_sig && pt->kind == AST_TYPE_PTR && pt->elem_type && pt->elem_type->kind == AST_TYPE_NAMED && pt->elem_type->name && strcmp(pt->elem_type->name, sd->name) == 0) need_for_sig = 1;
                }
            }
            for (int k = 0; k < m->num_impl_blocks && m->impl_blocks && !need_for_sig; k++)
                for (int j = 0; j < m->impl_blocks[k]->num_funcs && !need_for_sig; j++) {
                    const struct ASTFunc *f = m->impl_blocks[k]->funcs[j];
                    if (!f) continue;
                    if (f->return_type && f->return_type->kind == AST_TYPE_NAMED && f->return_type->name && strcmp(f->return_type->name, sd->name) == 0) need_for_sig = 1;
                    for (int p = 0; p < f->num_params && !need_for_sig; p++) {
                        const struct ASTType *pt = f->params[p].type;
                        if (!pt) continue;
                        if (pt->kind == AST_TYPE_NAMED && pt->name && strcmp(pt->name, sd->name) == 0) need_for_sig = 1;
                        if (!need_for_sig && pt->kind == AST_TYPE_PTR && pt->elem_type && pt->elem_type->kind == AST_TYPE_NAMED && pt->elem_type->name && strcmp(pt->elem_type->name, sd->name) == 0) need_for_sig = 1;
                    }
                }
            if (need_for_sig) { /* 被本模块某函数签名使用，必须输出，不因 DCE 跳过 */ }
            else if (async_liveness_module_struct_in_frame(m, sd->name)) { /* async 帧字段须完整 struct */ }
            else if (dce_ctx && is_type_used && !is_type_used(dce_ctx, m, sd->name)) continue;
        }
        if (emitted_type_names && n_emitted_inout && emitted_type_contains(sd->name, emitted_type_names, *n_emitted_inout)) continue;
        if (sd->is_send || sd->is_sync)
            fprintf(out, "/* shux_thread_safety:%s%s */ ", sd->is_send ? "send" : "", sd->is_sync ? (sd->is_send ? "+sync" : "sync") : "");
        fprintf(out, "struct %s { ", sd->name);
        for (int j = 0; j < sd->num_fields; j++) {
            const struct ASTType *fty = sd->fields[j].type;
            const char *fname = sd->fields[j].name ? sd->fields[j].name : "";
            emit_struct_field_c_type(fty, fname, out, sd->fields[j].bitfield_width);
        }
        if (sd->packed)
            fprintf(out, "} __attribute__((packed));\n");
        else
            fprintf(out, "};\n");
        if (emitted_type_names && n_emitted_inout) emitted_type_add(sd->name, emitted_type_names, n_emitted_inout, max_emitted);
    }
    /* 冷路径辅助：panic 分支标记 noreturn+cold；单文件时已在第一个库块中输出，此处仅多文件时输出；static inline 避免与 runtime_panic.o 重复符号且可被同 TU 内 inline 调用 */
    if (!emitted_type_names) {
        fprintf(out, "extern int getpid(void);\n");
        fprintf(out, "static inline void shux_crash_evidence_collect_inline(int has_msg, int msg_val) {\n");
        fprintf(out, "  const char *_ev = getenv(\"SHUX_CRASH_EVIDENCE\");\n");
        fprintf(out, "  if (!_ev || _ev[0] != '1') return;\n");
        fprintf(out, "  int _pid = (int)getpid();\n");
        fprintf(out, "  fprintf(stderr, \"note: crash evidence: panic=%%d msg=%%d frames=0 pid=%%d\\n\", has_msg, msg_val, _pid);\n");
        fprintf(out, "  const char *_dir = getenv(\"SHUX_CRASH_EVIDENCE_DIR\");\n");
        fprintf(out, "  if (_dir && _dir[0]) { char _p[1024]; snprintf(_p, sizeof _p, \"%%s/shux-crash-%%d.txt\", _dir, _pid);\n");
        fprintf(out, "    FILE *_f = fopen(_p, \"w\"); if (_f) { fprintf(_f, \"panic_has_msg=%%d\\npanic_msg=%%d\\nframes=0\\npid=%%d\\n\", has_msg, msg_val, _pid); fclose(_f);\n");
        fprintf(out, "      fprintf(stderr, \"note: crash evidence: bundle=%%s\\n\", _p); } } }\n");
        fprintf(out, "static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));\n");
        fprintf(out, "static inline void shux_panic_(int has_msg, int msg_val) {\n");
        fprintf(out, "  shux_crash_evidence_collect_inline(has_msg, msg_val);\n");
        fprintf(out, "  if (has_msg) (void)fprintf(stderr, \"%%d\\n\", msg_val);\n");
        fprintf(out, "  abort();\n");
        fprintf(out, "}\n");
    }
    /* 顶层 let/const：let 生成 static 变量 + init_globals() 赋值；const 生成 static const 并带初始化式 */
    if (m->num_top_level_lets > 0 && m->top_level_lets) {
        for (int i = 0; i < m->num_top_level_lets; i++) {
            const char *name = m->top_level_lets[i].name ? m->top_level_lets[i].name : "";
            const struct ASTType *ty = m->top_level_lets[i].type;
            const struct ASTExpr *init = m->top_level_lets[i].init;
            const struct ASTType *ety = codegen_emit_type(ty);
            if (m->top_level_lets[i].is_const) {
                /* K4：#[link_section] → __attribute__((section(...)))，附在 static 声明前（同一行） */
                if (m->top_level_lets[i].is_percpu)
                    fprintf(out, "__attribute__((section(\".percpu\"))) ");
                if (m->top_level_lets[i].section)
                    fprintf(out, "__attribute__((section(\"%s\"))) ", m->top_level_lets[i].section);
                /* const：一行 static const T name = init; */
                if (ety && ety->kind == AST_TYPE_PTR && ety->elem_type)
                    fprintf(out, "static const %s * %s = ", c_type_str(ety->elem_type), name);
                else if (ety && ety->kind == AST_TYPE_NAMED && ety->name)
                    fprintf(out, "static const %s %s = ", c_type_str(ety), name);
                else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
                    fprintf(out, "static const ");
                    emit_local_array_decl(ety, name, "", out);
                    fprintf(out, "= ");
                } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) {
                    ensure_slice_struct(ety, out);
                    fprintf(out, "static const %s %s = ", c_type_str(ety), name);
                } else
                    fprintf(out, "static const %s %s = ", ety ? c_type_str(ety) : "int32_t", name);
                if (codegen_init(ty, init, out, NULL) != 0)
                    (void)codegen_expr(init, out);
                fprintf(out, ";\n");
            } else {
                /* K8: 顶层 let 有初值时 emit `static T name = init;`(落 .data,bootloader 加载即有初值);
                 * 无初值 emit `static T name;`(落 .bss,零初始化)。init_globals() 仍保留(main 调用,对普通程序冗余但无害;
                 * 内核 _start 不调用但 .data 已有初值,故内核 let 全局变量正确初始化)。 */
                if (m->top_level_lets[i].is_thread_local)
                    fprintf(out, "__thread ");
                if (m->top_level_lets[i].is_percpu)
                    fprintf(out, "__attribute__((section(\".percpu\"))) ");
                if (m->top_level_lets[i].section)
                    fprintf(out, "__attribute__((section(\"%s\"))) ", m->top_level_lets[i].section);
                if (ety && ety->kind == AST_TYPE_PTR && ety->elem_type)
                    fprintf(out, "static %s * %s", c_type_str(ety->elem_type), name);
                else if (ety && ety->kind == AST_TYPE_NAMED && ety->name)
                    fprintf(out, "static %s %s", c_type_str(ety), name);
                else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
                    fprintf(out, "static ");
                    emit_local_array_decl(ety, name, "", out);
                } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) {
                    ensure_slice_struct(ety, out);
                    fprintf(out, "static %s %s", c_type_str(ety), name);
                } else
                    fprintf(out, "static %s %s", ety ? c_type_str(ety) : "int32_t", name);
                if (init) {
                    /* K8: 仅当初值为 C 常量表达式(字面量/已折叠常量)时 emit static T name = init;
                     * 否则保留 static T name;(init_globals 赋值,兼容非恒量初值如 let b = a + 2) */
                    int is_c_const = (init->kind == AST_EXPR_LIT || init->kind == AST_EXPR_FLOAT_LIT
                                      || init->kind == AST_EXPR_BOOL_LIT || init->const_folded_valid);
                    if (is_c_const) {
                        fprintf(out, " = ");
                        if (codegen_init(ty, init, out, NULL) != 0)
                            (void)codegen_expr(init, out);
                    }
                }
                fprintf(out, ";\n");
            }
        }
        /* init_globals：main 在 num_top_level_lets>0 时调用，故此处只要有顶层 const/let 即定义（const-only 时为空体），
         * 避免main 调用未定义的 init_globals（K4 顺带修的预存 const-only 模块编译失败） */
        if (m->num_top_level_lets > 0) {
            fprintf(out, "static void init_globals(void) {\n");
            for (int i = 0; i < m->num_top_level_lets; i++) {
                if (m->top_level_lets[i].is_const) continue;
                const char *name = m->top_level_lets[i].name ? m->top_level_lets[i].name : "";
                const struct ASTType *ty = m->top_level_lets[i].type;
                const struct ASTExpr *init = m->top_level_lets[i].init;
                fprintf(out, "  %s = ", name);
                if (codegen_init(ty, init, out, NULL) != 0)
                    (void)codegen_expr(init, out); /* 回退：按普通表达式输出 */
                fprintf(out, ";\n");
            }
            fprintf(out, "}\n");
        }
    }
    /* 入口模块 extern：生成 C extern 声明，供 main 等同模块 CALL 链接 fs.o/net.o 等（库模块在 codegen_library_module_to_c 末尾处理）。 */
    for (int i = 0; i < m->num_funcs && m->funcs; i++) {
        const struct ASTFunc *f = m->funcs[i];
        if (!f || !f->is_extern) continue;
        /* shux_async_sched_* 由 async 函数体末尾 wrapper 定义，勿重复 extern。 */
        if (f->name && async_cps_resolve_sched_target(m, f->name)) continue;
        codegen_emit_module_extern_func_proto(out, f);
    }
    /* 入口模块内函数前向声明：满足 C 任意顺序调用；DCE/WPO 开启时仅声明可达函数。 */
    for (int i = 0; i < m->num_funcs && m->funcs; i++) {
        const struct ASTFunc *f = m->funcs[i];
        if (!f || strcmp(f->name, "main") == 0 || f->num_generic_params > 0 || f->is_extern || !f->body) continue;
        if (dce_ctx && is_func_used && !codegen_async_keep_for_sched(m, f, is_func_used, dce_ctx)) continue;
        if (f->return_type && f->return_type->kind == AST_TYPE_ARRAY) ensure_arr_ret_struct(f->return_type, out);
        const char *mod_ret = (f->return_type && f->return_type->kind == AST_TYPE_ARRAY && f->return_type->array_size > 0) ? arr_ret_wrapper_name(f->return_type) : c_type_str(f->return_type);
        const char *mod_ret_pre = (f->return_type && f->return_type->kind == AST_TYPE_ARRAY) ? "struct " : "";
        if (f->is_no_mangle || f->is_used || f->is_interrupt || f->is_naked || f->is_entry || f->is_global_allocator || f->is_cold || f->is_panic_handler || f->export_name)
            fprintf(out, "%s%s %s(", mod_ret_pre, mod_ret, func_link_name(m, f));
        else
            fprintf(out, "static inline %s%s %s(", mod_ret_pre, mod_ret, func_link_name(m, f));
        if (async_cps_func_uses_void_entry(f, m))
            fprintf(out, "void");
        else {
            for (int j = 0; j < f->num_params; j++) {
                if (j) fprintf(out, ", ");
                codegen_emit_param(&f->params[j], out, NULL, j);
            }
        }
        fprintf(out, ");\n");
    }
    for (int k = 0; k < m->num_impl_blocks && m->impl_blocks; k++)
        for (int j = 0; j < m->impl_blocks[k]->num_funcs; j++) {
            const struct ASTFunc *f = m->impl_blocks[k]->funcs[j];
            if (!f) continue;
            if (f->return_type && f->return_type->kind == AST_TYPE_ARRAY) ensure_arr_ret_struct(f->return_type, out);
            const char *impl_ret = (f->return_type && f->return_type->kind == AST_TYPE_ARRAY && f->return_type->array_size > 0) ? arr_ret_wrapper_name(f->return_type) : c_type_str(f->return_type);
            fprintf(out, "static inline %s%s %s(", (f->return_type && f->return_type->kind == AST_TYPE_ARRAY) ? "struct " : "", impl_ret, impl_method_c_name(f));
            for (int p = 0; p < f->num_params; p++) {
                if (p) fprintf(out, ", ");
                codegen_emit_param(&f->params[p], out, NULL, p);
            }
            fprintf(out, ");\n");
        }
    for (int k = 0; k < m->num_mono_instances && m->mono_instances; k++) {
        const struct ASTMonoInstance *inst = &m->mono_instances[k];
        if (!inst->template || !inst->type_args) continue;
        const struct ASTFunc *f = inst->template;
        const struct ASTType *ret_ty = subst_type(f->return_type, f->generic_param_names, inst->type_args, inst->num_type_args);
        if (ret_ty && ret_ty->kind == AST_TYPE_ARRAY) ensure_arr_ret_struct(ret_ty, out);
        const char *gen_ret = (ret_ty && ret_ty->kind == AST_TYPE_ARRAY && ret_ty->array_size > 0) ? arr_ret_wrapper_name(ret_ty) : (ret_ty ? c_type_str(ret_ty) : "int32_t");
        fprintf(out, "static inline %s%s %s(", (ret_ty && ret_ty->kind == AST_TYPE_ARRAY) ? "struct " : "", gen_ret,
            mono_instance_mangled_name_ex(m, f, inst->type_args, inst->num_type_args));
        for (int p = 0; p < f->num_params; p++) {
            const struct ASTType *pt = subst_type(f->params[p].type, f->generic_param_names, inst->type_args, inst->num_type_args);
            if (p) fprintf(out, ", ");
            codegen_emit_param(&f->params[p], out, pt, p);
        }
        fprintf(out, ");\n");
    }
    /* 先输出非 main 函数，再 impl/mono，最后 main；阶段 8.1 DCE / WPO 时仅输出已引用。 */
    for (int i = 0; i < m->num_funcs && m->funcs; i++) {
        if (!m->funcs[i] || strcmp(m->funcs[i]->name, "main") == 0 || m->funcs[i]->num_generic_params > 0) continue;
        if (m->funcs[i]->is_extern || !m->funcs[i]->body) continue;
        if (dce_ctx && is_func_used && !m->funcs[i]->is_entry && !m->funcs[i]->is_used && !m->funcs[i]->is_no_mangle && !m->funcs[i]->is_interrupt && !m->funcs[i]->is_global_allocator && !m->funcs[i]->is_cold && !m->funcs[i]->is_panic_handler && !codegen_async_keep_for_sched(m, m->funcs[i], is_func_used, dce_ctx)) continue;  /* K5/K10：#[entry]/#[used] 不被 DCE */
        if (codegen_one_func(m->funcs[i], m, out) != 0) {
            char msg[192];
            (void)snprintf(msg, sizeof(msg), "failed to emit function '%s'",
                           m->funcs[i]->name ? m->funcs[i]->name : "?");
            diag_report_with_code(NULL, m->funcs[i]->line, m->funcs[i]->col, "codegen error",
                                  SHUX_DIAG_CODE_CODEGEN_CG003, msg, msg);
            return -1;
        }
    }
    for (int k = 0; k < m->num_impl_blocks && m->impl_blocks; k++)
        for (int j = 0; j < m->impl_blocks[k]->num_funcs; j++) {
            if (dce_ctx && is_func_used && !is_func_used(dce_ctx, m, m->impl_blocks[k]->funcs[j])) {
                if (!m->main_func || !m->main_func->body || !block_references_func(m->main_func->body, m->impl_blocks[k]->funcs[j])) continue;
            }
            if (codegen_one_impl_func(m->impl_blocks[k]->funcs[j], m, out) != 0) return -1;
        }
    for (int k = 0; k < m->num_mono_instances && m->mono_instances; k++) {
        const struct ASTMonoInstance *inst = &m->mono_instances[k];
        if (!inst->template || !inst->type_args) continue;
        if (dce_ctx && is_mono_used && !is_mono_used(dce_ctx, m, k)) continue;
        if (codegen_one_mono_instance(inst->template, inst->type_args, inst->num_type_args, m, out) != 0) return -1;
    }
    for (int i = 0; i < m->num_funcs && m->funcs; i++) {
        if (!m->funcs[i] || strcmp(m->funcs[i]->name, "main") != 0 || m->funcs[i]->num_generic_params > 0) continue;
        if (dce_ctx && is_func_used && !is_func_used(dce_ctx, m, m->funcs[i])) continue;
        if (codegen_one_func(m->funcs[i], m, out) != 0) return -1;
        break;
    }
    return 0;
}

/**
 * 是否为 lsp_io.x 的 -E-extern 入口路径（生成 lsp_io_gen.c）。
 */
static int codegen_emit_path_is_lsp_io_x(const char *p) {
    return lsp_codegen_emit_path_is_lsp_io_x(p);
}

/**
 * 将库模块生成 C（类型与函数带 import 前缀，避免与入口模块符号冲突）；功能见 codegen.h。阶段 8.1 DCE 时仅输出已引用。
 * lib_dep_mods/lib_dep_paths/n_lib_dep 为该库的 import 依赖，用于生成跨模块调用前缀（库内调用其他 import 时）。
 */
int codegen_library_module_to_c(struct ASTModule *m, const char *import_path,
    struct ASTModule **lib_dep_mods, const char **lib_dep_paths, int n_lib_dep,
    FILE *out,
    codegen_is_func_used_fn is_func_used, codegen_is_mono_used_fn is_mono_used, codegen_is_type_used_fn is_type_used, void *dce_ctx,
    char (*emitted_type_names)[CODEGEN_EMITTED_TYPE_NAME_MAX], int *n_emitted_inout, int max_emitted,
    const char *emit_entry_path) {
    if (!m || !out) return -1;
    static char lib_prefix_buf[256];
    size_t off = 0;
    if (import_path) {
        for (const char *s = import_path; *s && off + 2 < sizeof(lib_prefix_buf); s++)
            lib_prefix_buf[off++] = (*s == '.') ? '_' : *s;
    }
    /* F 闭合：-lib-name "" 时 off==0，不加尾随 _，使函数符号为裸名（匹配 mod.x 的 extern 调用）。 */
    if (off > 0 && off + 1 < sizeof(lib_prefix_buf)) lib_prefix_buf[off++] = '_';
    lib_prefix_buf[off] = '\0';
    codegen_library_prefix = lib_prefix_buf;
    codegen_library_module = m;
    codegen_current_module = m;  /* 供 get_struct_field_type 解析本库内结构体（如 parser 的 OneFuncResult），以便结构体字面量走块形式 */
    codegen_library_import_path = import_path;
    codegen_dep_mods = lib_dep_mods;
    codegen_dep_paths = lib_dep_paths;
    codegen_ndep = (lib_dep_mods && lib_dep_paths) ? n_lib_dep : 0;
    codegen_emitted_type_names = emitted_type_names;
    codegen_n_emitted_inout = n_emitted_inout;
    codegen_max_emitted = max_emitted;
    /* 单文件 -E-extern：dep 阶段已写入 slice/struct 名时保留 codegen_slice_emitted，避免 entry 重复定义。 */
    if (!emitted_type_names)
        codegen_slice_emitted_n = 0;

    /* C-04 v0/v1：-E-extern 入口；lsp_io 保留 heap 别名，lsp_gen 桥接改 import extern 自动生成。 */
    if (emitted_type_names && emit_entry_path && codegen_emit_path_is_lsp_io_x(emit_entry_path))
        lsp_codegen_emit_heap_alias_block(out);

    /* 单文件模式时 include 与 panic 已由 driver 在写库前统一输出，此处不再输出；仅多文件（无 emitted_type_names）时每个库自己输出 include */
    if (!emitted_type_names) {
        fprintf(out, "/* generated from %s */\n", import_path ? import_path : "");
        fprintf(out, "#include <stdint.h>\n");
        fprintf(out, "#include <stddef.h>\n");
        fprintf(out, "#include <stdlib.h>\n");
        fprintf(out, "#include <stdio.h>\n");
        fprintf(out, "#include <string.h>\n"); /* memcpy 用于数组拷贝 */
        /* macOS 上 htonl/htons/ntohl/ntohs 是宏，须 #undef 后才能 emit extern 原型（见 codegen_module_to_c 注释）。 */
        fprintf(out, "#undef htonl\n#undef htons\n#undef ntohl\n#undef ntohs\n");
        /* PE weak 函数在 ld -r 部分链接时丢失别名；Windows 改强符号靠 --allow-multiple-definition（见 codegen_module_to_c 注释）。 */
        fprintf(out, "#ifdef _WIN32\n#define SHUX_LIB_WEAK\n#else\n#define SHUX_LIB_WEAK __attribute__((weak))\n#endif\n");
        /* CORE-009：库模块自身也可能 emit 跨模块 builtin 调用，需自带 static inline 包装器。 */
        codegen_emit_builtin_inline_decls(out);
    }

    /* 库模块顶层 let/const：带前缀的 static [const] T name = init;，供单文件 -E 时引用（如 lsp.x 的 LSP_BODY_CAP） */
    if (m->num_top_level_lets > 0 && m->top_level_lets) {
        for (int i = 0; i < m->num_top_level_lets; i++) {
            char pname[256];
            library_prefixed_name(m->top_level_lets[i].name ? m->top_level_lets[i].name : "", pname, sizeof(pname));
            const struct ASTType *ty = m->top_level_lets[i].type;
            const struct ASTExpr *init = m->top_level_lets[i].init;
            const struct ASTType *ety = codegen_emit_type(ty);
            const char *qual = m->top_level_lets[i].is_const ? "static const " : "static ";
            if (ety && ety->kind == AST_TYPE_PTR && ety->elem_type)
                fprintf(out, "%s%s * %s = ", qual, c_type_str(ety->elem_type), pname);
            else if (ety && ety->kind == AST_TYPE_NAMED && ety->name)
                fprintf(out, "%s%s %s = ", qual, c_type_str(ety), pname);
            else if (ety && ety->kind == AST_TYPE_ARRAY && ety->elem_type) {
                fprintf(out, "%s", qual);
                emit_local_array_decl(ety, pname, "", out);
                fprintf(out, "= ");
            } else if (ety && ety->kind == AST_TYPE_SLICE && ety->elem_type) {
                ensure_slice_struct(ety, out);
                fprintf(out, "%s%s %s = ", qual, c_type_str(ety), pname);
            } else
                fprintf(out, "%s%s %s = ", qual, ety ? c_type_str(ety) : "int32_t", pname);
            if (codegen_init(ty, init, out, NULL) != 0)
                (void)codegen_expr(init, out);
            fprintf(out, ";\n");
        }
    }

    /* 本库函数签名若含 []T / 向量，须最先输出 slice/typedef，否则后续 extern/前向声明为不完整类型 */
    for (int i = 0; i < m->num_funcs && m->funcs; i++) {
        const struct ASTFunc *f = m->funcs[i];
        if (!f || strcmp(f->name, "main") == 0 || f->num_generic_params > 0) continue;
        ensure_func_sig_vector_typedefs(f, out);
        if (f->return_type) ensure_slice_struct(f->return_type, out);
        for (int j = 0; j < f->num_params; j++)
            if (f->params[j].type) ensure_slice_struct(f->params[j].type, out);
    }
    for (int k = 0; k < m->num_impl_blocks && m->impl_blocks; k++)
        for (int j = 0; j < m->impl_blocks[k]->num_funcs; j++) {
            const struct ASTFunc *f = m->impl_blocks[k]->funcs[j];
            if (!f) continue;
            ensure_func_sig_vector_typedefs(f, out);
            if (f->return_type) ensure_slice_struct(f->return_type, out);
            for (int p = 0; p < f->num_params; p++)
                if (f->params[p].type) ensure_slice_struct(f->params[p].type, out);
        }
    for (int k = 0; k < m->num_mono_instances && m->mono_instances; k++) {
        const struct ASTMonoInstance *inst = &m->mono_instances[k];
        if (!inst->template || !inst->type_args) continue;
        const struct ASTFunc *f = inst->template;
        ensure_func_sig_vector_typedefs(f, out);
        const struct ASTType *ret_ty = subst_type(f->return_type, f->generic_param_names, inst->type_args, inst->num_type_args);
        if (ret_ty && ret_ty->kind == AST_TYPE_VECTOR) ensure_vector_typedef(ret_ty, out);
        if (ret_ty) ensure_slice_struct(ret_ty, out);
        for (int p = 0; p < f->num_params; p++) {
            const struct ASTType *pt = subst_type(f->params[p].type, f->generic_param_names, inst->type_args, inst->num_type_args);
            if (pt && pt->kind == AST_TYPE_VECTOR) ensure_vector_typedef(pt, out);
            if (pt) ensure_slice_struct(pt, out);
        }
    }

    /* C-04 v0：-E-extern 入口模块对 import（std.io 等）的 extern 声明 */
    if (emitted_type_names && emit_entry_path) {
        static const char *skip_std_heap[] = { "std.heap" };
        int skip_n = codegen_emit_path_is_lsp_io_x(emit_entry_path) ? 1 : 0;
        codegen_emit_module_import_extern_decls(m, out, 1, skip_std_heap, skip_n);
    }

    /* 本库对 lib_dep 的调用：收集后生成 extern，避免 C 编译 undeclared */
    if (codegen_ndep > 0 && lib_dep_mods && lib_dep_paths
        && !(emitted_type_names && emit_entry_path && codegen_emit_path_is_lsp_io_x(emit_entry_path))) {
        const char *ext_paths[MAX_IMPORT_DECLS];
        struct ASTFunc *ext_funcs[MAX_IMPORT_DECLS];
        int n_ext = 0;
        for (int i = 0; i < m->num_funcs && m->funcs; i++)
            if (m->funcs[i] && m->funcs[i]->body)
                collect_lib_dep_calls_from_block(m->funcs[i]->body, lib_dep_mods, lib_dep_paths, n_lib_dep, ext_paths, ext_funcs, &n_ext, MAX_IMPORT_DECLS);
        for (int k = 0; k < n_ext && ext_paths[k] && ext_funcs[k]; k++) {
            char pre[256];
            import_path_to_c_prefix(ext_paths[k], pre, sizeof(pre));
            const struct ASTFunc *f = ext_funcs[k];
            fprintf(out, "extern %s %s%s(", c_type_str(f->return_type), pre, f->name ? f->name : "");
            for (int p = 0; p < f->num_params; p++) {
                if (p) fprintf(out, ", ");
                codegen_emit_param(&f->params[p], out, codegen_io_driver_param_override(ext_paths[k], f->name, p), p);
            }
            fprintf(out, ");\n");
        }
    }

    for (int i = 0; i < m->num_funcs && m->funcs; i++)
        if (m->funcs[i] && m->funcs[i]->body)
            ensure_block_vector_typedefs(m->funcs[i]->body, out);
    for (int k = 0; k < m->num_mono_instances && m->mono_instances; k++)
        if (m->mono_instances[k].template && m->mono_instances[k].template->body)
            ensure_block_vector_typedefs(m->mono_instances[k].template->body, out);
    for (int k = 0; k < m->num_impl_blocks && m->impl_blocks; k++)
        for (int j = 0; j < m->impl_blocks[k]->num_funcs; j++)
            if (m->impl_blocks[k]->funcs[j]->body)
                ensure_block_vector_typedefs(m->impl_blocks[k]->funcs[j]->body, out);

    for (int i = 0; i < m->num_enums && m->enum_defs; i++) {
        const struct ASTEnumDef *ed = m->enum_defs[i];
        if (!ed || !ed->name) continue;
        if (dce_ctx && is_type_used && !is_type_used(dce_ctx, m, ed->name)) continue;
        char ename[256];
        library_prefixed_name(ed->name, ename, sizeof(ename));
        if (emitted_type_names && n_emitted_inout && emitted_type_contains(ename, emitted_type_names, *n_emitted_inout)) continue;
        fprintf(out, "enum %s { ", ename);
        for (int j = 0; j < ed->num_variants; j++) {
            if (j > 0) fprintf(out, ", ");
            fprintf(out, "%s_%s", ename, ed->variant_names[j] ? ed->variant_names[j] : "");
        }
        fprintf(out, " };\n");
        if (emitted_type_names && n_emitted_inout) emitted_type_add(ename, emitted_type_names, n_emitted_inout, max_emitted);
    }
    /* 结构体字段若为 []T，须先输出 slice 结构体定义，避免 C 侧不完整类型 */
    for (int i = 0; i < m->num_structs && m->struct_defs; i++) {
        const struct ASTStructDef *sd = m->struct_defs[i];
        if (!sd || sd->num_generic_params > 0) continue;
        if (dce_ctx && is_type_used && !is_type_used(dce_ctx, m, sd->name)) continue;
        for (int j = 0; j < sd->num_fields; j++)
            if (sd->fields[j].type) ensure_slice_struct(sd->fields[j].type, out);
    }
    for (int i = 0; i < m->num_structs && m->struct_defs; i++) {
        const struct ASTStructDef *sd = m->struct_defs[i];
        if (!sd || !sd->name) continue;
        /* LANG-009/CORE-016：泛型 struct 模板仅由 typeck 单态化，不直接输出 C struct */
        if (sd->num_generic_params > 0) continue;
        {
            int need_for_sig = 0;
            for (int fi = 0; fi < m->num_funcs && m->funcs && !need_for_sig; fi++) {
                const struct ASTFunc *f = m->funcs[fi];
                if (!f || f->num_generic_params > 0 || f->is_extern || !f->body) continue;
                if (f->return_type && f->return_type->kind == AST_TYPE_NAMED && f->return_type->name && strcmp(f->return_type->name, sd->name) == 0) need_for_sig = 1;
                for (int p = 0; p < f->num_params && !need_for_sig; p++) {
                    const struct ASTType *pt = f->params[p].type;
                    if (!pt) continue;
                    if (pt->kind == AST_TYPE_NAMED && pt->name && strcmp(pt->name, sd->name) == 0) need_for_sig = 1;
                    if (!need_for_sig && pt->kind == AST_TYPE_PTR && pt->elem_type && pt->elem_type->kind == AST_TYPE_NAMED && pt->elem_type->name && strcmp(pt->elem_type->name, sd->name) == 0) need_for_sig = 1;
                }
            }
            if (!need_for_sig && dce_ctx && is_type_used && !is_type_used(dce_ctx, m, sd->name)
                && !async_liveness_module_struct_in_frame(m, sd->name)) continue;
        }
        char sname[256];
        library_prefixed_name(sd->name, sname, sizeof(sname));
        if (emitted_type_names && n_emitted_inout && emitted_type_contains(sname, emitted_type_names, *n_emitted_inout)) continue;
        if (codegen_preamble_has_core_option_result && codegen_library_import_path && sd->name &&
            ((strcmp(codegen_library_import_path, "core.option") == 0 && strcmp(sd->name, "Option_i32") == 0) ||
             (strcmp(codegen_library_import_path, "core.result") == 0 && strcmp(sd->name, "Result_i32") == 0))) continue;
        fprintf(out, "struct %s { ", sname);
        for (int j = 0; j < sd->num_fields; j++) {
            const struct ASTType *fty = sd->fields[j].type;
            const char *fname = sd->fields[j].name ? sd->fields[j].name : "";
            emit_struct_field_c_type(fty, fname, out, sd->fields[j].bitfield_width);
        }
        if (sd->packed)
            fprintf(out, "} __attribute__((packed));\n");
        else
            fprintf(out, "};\n");
        if (emitted_type_names && n_emitted_inout) emitted_type_add(sname, emitted_type_names, n_emitted_inout, max_emitted);
    }
    /* 单文件时 panic 已在第一个库的 include 块中输出；仅多文件（无 emitted_type_names）时每库各自输出 panic */
    if (!emitted_type_names) {
        fprintf(out, "extern int getpid(void);\n");
        fprintf(out, "static inline void shux_crash_evidence_collect_inline(int has_msg, int msg_val) {\n");
        fprintf(out, "  const char *_ev = getenv(\"SHUX_CRASH_EVIDENCE\");\n");
        fprintf(out, "  if (!_ev || _ev[0] != '1') return;\n");
        fprintf(out, "  int _pid = (int)getpid();\n");
        fprintf(out, "  fprintf(stderr, \"note: crash evidence: panic=%%d msg=%%d frames=0 pid=%%d\\n\", has_msg, msg_val, _pid);\n");
        fprintf(out, "  const char *_dir = getenv(\"SHUX_CRASH_EVIDENCE_DIR\");\n");
        fprintf(out, "  if (_dir && _dir[0]) { char _p[1024]; snprintf(_p, sizeof _p, \"%%s/shux-crash-%%d.txt\", _dir, _pid);\n");
        fprintf(out, "    FILE *_f = fopen(_p, \"w\"); if (_f) { fprintf(_f, \"panic_has_msg=%%d\\npanic_msg=%%d\\nframes=0\\npid=%%d\\n\", has_msg, msg_val, _pid); fclose(_f);\n");
        fprintf(out, "      fprintf(stderr, \"note: crash evidence: bundle=%%s\\n\", _p); } } }\n");
        fprintf(out, "static inline void shux_panic_(int has_msg, int msg_val) __attribute__((noreturn, cold));\n");
        fprintf(out, "static inline void shux_panic_(int has_msg, int msg_val) {\n");
        fprintf(out, "  shux_crash_evidence_collect_inline(has_msg, msg_val);\n");
        fprintf(out, "  if (has_msg) (void)fprintf(stderr, \"%%d\\n\", msg_val);\n");
        fprintf(out, "  abort();\n");
        fprintf(out, "}\n");
    }

    /* extern 函数：仅生成 C 的 extern 声明，符号名为 .x 中的函数名（与 C 一致），无定义 */
    for (int i = 0; i < m->num_funcs && m->funcs; i++) {
        const struct ASTFunc *f = m->funcs[i];
        if (!f || !f->is_extern) continue;
        /* io_read_batch_buf/io_write_batch_buf 由 runtime 单文件 preamble 提供与 io.o 一致的 extern，此处跳过避免签名冲突 */
        if (codegen_library_import_path && f->name && (strcmp(f->name, "io_read_batch_buf") == 0 || strcmp(f->name, "io_write_batch_buf") == 0) && strstr(codegen_library_import_path, "io")) continue;
        codegen_emit_module_extern_func_proto(out, f);
    }
    /* C-04：import + 模块 extern 收集完毕后输出 TU 别名（parser 等 -E-extern 瘦 TU）。 */
    if (emitted_type_names && emit_entry_path)
        codegen_tu_alias_flush(out);

    /* 库模块内函数前向声明：满足 C 要求（递归或任意顺序调用时须先声明后定义）；无 static 以便符号可被入口模块链接 */
    for (int i = 0; i < m->num_funcs && m->funcs; i++) {
        const struct ASTFunc *f = m->funcs[i];
        if (!f || strcmp(f->name, "main") == 0 || f->num_generic_params > 0 || f->is_extern || !f->body) continue;
        /* std.io.driver 的 submit_read/write_batch_buf 由 runtime 单文件 preamble 提供正确签名实现，此处跳过避免 C 桩签名冲突 */
        if (codegen_library_import_path && f->name && (strcmp(f->name, "submit_read_batch_buf") == 0 || strcmp(f->name, "submit_write_batch_buf") == 0) && strstr(codegen_library_import_path, "io")) continue;
        if (dce_ctx && is_func_used && !codegen_async_keep_for_sched(m, f, is_func_used, dce_ctx)) continue;
        char fwd_name[256];
        /* L9：#[no_mangle] 前向声明也不加 library_prefix，与定义端一致 */
        if (f->is_no_mangle)
            snprintf(fwd_name, sizeof(fwd_name), "%s", func_link_name(m, f));
        else
            library_prefixed_name(func_link_name(m, f), fwd_name, sizeof(fwd_name));
        if (codegen_library_import_path && !f->is_extern && (strcmp(codegen_library_import_path, "core.option") == 0 || strcmp(codegen_library_import_path, "core.result") == 0))
            fprintf(out, "static inline ");
        if (codegen_library_import_path && !f->is_extern && (strcmp(codegen_library_import_path, "std.fs") == 0 || strcmp(codegen_library_import_path, "std.net") == 0))
            fprintf(out, "static inline ");
        fprintf(out, "%s %s(", c_type_str(f->return_type), fwd_name);
        for (int j = 0; j < f->num_params; j++) {
            if (j) fprintf(out, ", ");
            codegen_emit_param(&f->params[j], out, codegen_io_driver_param_override(codegen_library_import_path, f->name, j), j);
        }
        fprintf(out, ");\n");
    }
    for (int k = 0; k < m->num_impl_blocks && m->impl_blocks; k++)
        for (int j = 0; j < m->impl_blocks[k]->num_funcs; j++) {
            const struct ASTFunc *f = m->impl_blocks[k]->funcs[j];
            if (!f || (dce_ctx && is_func_used && !is_func_used(dce_ctx, m, f))) continue;
            char fwd_name[256];
            library_prefixed_name(impl_method_c_name(f), fwd_name, sizeof(fwd_name));
            fprintf(out, "%s %s(", c_type_str(f->return_type), fwd_name);
            for (int p = 0; p < f->num_params; p++) {
                if (p) fprintf(out, ", ");
                codegen_emit_param(&f->params[p], out, NULL, p);
            }
            fprintf(out, ");\n");
        }
    for (int k = 0; k < m->num_mono_instances && m->mono_instances; k++) {
        const struct ASTMonoInstance *inst = &m->mono_instances[k];
        if (!inst->template || !inst->type_args || (dce_ctx && is_mono_used && !is_mono_used(dce_ctx, m, k))) continue;
        const struct ASTFunc *f = inst->template;
        const struct ASTType *ret_ty = subst_type(f->return_type, f->generic_param_names, inst->type_args, inst->num_type_args);
        char fwd_name[256];
        library_prefixed_name(mono_instance_mangled_name_ex(m, f, inst->type_args, inst->num_type_args), fwd_name, sizeof(fwd_name));
        fprintf(out, "%s %s(", ret_ty ? c_type_str(ret_ty) : "int32_t", fwd_name);
        for (int p = 0; p < f->num_params; p++) {
            const struct ASTType *pt = subst_type(f->params[p].type, f->generic_param_names, inst->type_args, inst->num_type_args);
            if (p) fprintf(out, ", ");
            codegen_emit_param(&f->params[p], out, pt, p);
        }
        fprintf(out, ");\n");
    }

    for (int i = 0; i < m->num_funcs && m->funcs; i++) {
        if (!m->funcs[i] || strcmp(m->funcs[i]->name, "main") == 0 || m->funcs[i]->num_generic_params > 0) continue;
        if (m->funcs[i]->is_extern || !m->funcs[i]->body) continue; /* extern 无体，不生成定义 */
        /* std.io.driver 的 submit_read/write_batch_buf 由 runtime 单文件 preamble 提供，此处跳过 */
        if (codegen_library_import_path && m->funcs[i]->name && (strcmp(m->funcs[i]->name, "submit_read_batch_buf") == 0 || strcmp(m->funcs[i]->name, "submit_write_batch_buf") == 0) && strstr(codegen_library_import_path, "io")) continue;
        if (dce_ctx && is_func_used && !is_func_used(dce_ctx, m, m->funcs[i])) continue;
        if (codegen_one_func(m->funcs[i], m, out) != 0) { codegen_library_prefix = NULL; codegen_library_module = NULL; codegen_library_import_path = NULL; codegen_dep_mods = NULL; codegen_dep_paths = NULL; codegen_ndep = 0; return -1; }
    }
    for (int k = 0; k < m->num_impl_blocks && m->impl_blocks; k++)
        for (int j = 0; j < m->impl_blocks[k]->num_funcs; j++) {
            if (dce_ctx && is_func_used && !is_func_used(dce_ctx, m, m->impl_blocks[k]->funcs[j])) continue;
            if (codegen_one_impl_func(m->impl_blocks[k]->funcs[j], m, out) != 0) { codegen_library_prefix = NULL; codegen_library_module = NULL; codegen_library_import_path = NULL; codegen_dep_mods = NULL; codegen_dep_paths = NULL; codegen_ndep = 0; return -1; }
        }
    for (int k = 0; k < m->num_mono_instances && m->mono_instances; k++) {
        const struct ASTMonoInstance *inst = &m->mono_instances[k];
        if (!inst->template || !inst->type_args) continue;
        if (dce_ctx && is_mono_used && !is_mono_used(dce_ctx, m, k)) continue;
        if (codegen_one_mono_instance(inst->template, inst->type_args, inst->num_type_args, m, out) != 0) {
            codegen_library_prefix = NULL;
            codegen_library_module = NULL;
            codegen_library_import_path = NULL;
            codegen_dep_mods = NULL;
            codegen_dep_paths = NULL;
            codegen_ndep = 0;
            return -1;
        }
    }
    codegen_library_prefix = NULL;
    codegen_library_module = NULL;
    codegen_library_import_path = NULL;
    codegen_dep_mods = NULL;
    codegen_dep_paths = NULL;
    codegen_ndep = 0;
    return 0;
}

/* ── WPO-S1：跨模块 call graph JSON（NEXT §4.1 WPO-S1） ── */

/** WPO 图内函数节点上限（compiler self 足够；超出时截断并仍输出可达子图）。 */
#define WPO_MAX_FUNCS 4096
/** WPO 边上限（静态 CALL/METHOD_CALL 去重后）。 */
#define WPO_MAX_EDGES 16384
/** WPO call site 上限（含同 from→to 不同实参的多条边；WPO-S2 特化分析用）。 */
#define WPO_MAX_CALL_SITES 4096
/** 单 call site 记录的整型常量实参个数上限。 */
#define WPO_MAX_CALL_SITE_ARGS 8
/** WPO 模块槽上限（entry + 传递依赖）。 */
#define WPO_MAX_MODS 128

/** WPO-S2：单个静态 call site 的 from/to 与全常量实参 profile（args[i]=-1 表示非常量）。 */
typedef struct WpoCallSite {
    int from;
    int to;
    int nargs;
    int args[WPO_MAX_CALL_SITE_ARGS];
    unsigned char all_const;
} WpoCallSite;

/** WPO 图构建上下文：函数表、边表、call site 表、模块路径。 */
typedef struct WpoGraph {
    struct ASTModule *entry;
    const char *entry_path;
    struct ASTModule *mods[WPO_MAX_MODS];
    const char *paths[WPO_MAX_MODS];
    int nmods;
    struct ASTFunc *funcs[WPO_MAX_FUNCS];
    int mod_of[WPO_MAX_FUNCS];
    int nfuncs;
    int root_id;
    struct { int from; int to; } edges[WPO_MAX_EDGES];
    int nedges;
    WpoCallSite call_sites[WPO_MAX_CALL_SITES];
    int ncall_sites;
    unsigned char reachable[WPO_MAX_FUNCS];
} WpoGraph;

/** JSON 字符串转义输出（不含外围引号）。 */
static void wpo_json_escape(FILE *out, const char *s) {
    if (!s) return;
    for (const char *p = s; *p; p++) {
        if (*p == '"' || *p == '\\') fputc('\\', out);
        if (*p == '\n') { fputs("\\n", out); continue; }
        if (*p == '\r') { fputs("\\r", out); continue; }
        if (*p == '\t') { fputs("\\t", out); continue; }
        fputc(*p, out);
    }
}

/** 将字符串以 JSON 字符串字面量写入 out。 */
static void wpo_json_string(FILE *out, const char *s) {
    fputc('"', out);
    wpo_json_escape(out, s ? s : "");
    fputc('"', out);
}

/** 在 g 中查找 func 指针对应的节点 id，未注册返回 -1。 */
static int wpo_func_id(const WpoGraph *g, const struct ASTFunc *f) {
    if (!f || !g) return -1;
    for (int i = 0; i < g->nfuncs; i++)
        if (g->funcs[i] == f) return i;
    return -1;
}

/** 选定 WPO 根：main_func → 入口模块内 main/entry 函数名。 */
static void wpo_pick_root(WpoGraph *g) {
    if (!g || !g->entry) return;
    if (g->entry->main_func) {
        int rid = wpo_func_id(g, g->entry->main_func);
        if (rid >= 0) { g->root_id = rid; return; }
    }
    for (int i = 0; i < g->nfuncs; i++) {
        if (g->mod_of[i] != 0) continue;
        struct ASTFunc *f = g->funcs[i];
        if (!f || !f->name || f->is_extern) continue;
        if (strcmp(f->name, "entry") == 0 || strcmp(f->name, "main") == 0) {
            g->root_id = i;
            return;
        }
    }
}

/** 注册单个函数节点（去重）；main_func 优先作为 root（wpo_pick_root 补 entry 名）。 */
static void wpo_register_one(WpoGraph *g, struct ASTFunc *f, int mod_idx) {
    if (!g || !f || g->nfuncs >= WPO_MAX_FUNCS) return;
    if (wpo_func_id(g, f) >= 0) return;
    g->funcs[g->nfuncs] = f;
    g->mod_of[g->nfuncs] = mod_idx;
    if (g->entry && f == g->entry->main_func) g->root_id = g->nfuncs;
    g->nfuncs++;
}

/** 注册模块内顶层函数与 impl 方法到 g；mod_idx 为 mods[] 下标。 */
static void wpo_register_module(WpoGraph *g, struct ASTModule *m, int mod_idx) {
    if (!g || !m || mod_idx < 0) return;
    if (m->main_func) wpo_register_one(g, m->main_func, mod_idx);
    for (int i = 0; i < m->num_funcs && m->funcs; i++)
        wpo_register_one(g, m->funcs[i], mod_idx);
    for (int k = 0; k < m->num_impl_blocks && m->impl_blocks; k++)
        for (int j = 0; j < m->impl_blocks[k]->num_funcs; j++)
            wpo_register_one(g, m->impl_blocks[k]->funcs[j], mod_idx);
}

/** 追加有向边 from→to（去重）；成功返回 1。 */
static int wpo_add_edge(WpoGraph *g, int from, int to) {
    if (!g || from < 0 || to < 0 || from >= g->nfuncs || to >= g->nfuncs) return 0;
    for (int i = 0; i < g->nedges; i++)
        if (g->edges[i].from == from && g->edges[i].to == to) return 0;
    if (g->nedges >= WPO_MAX_EDGES) return 0;
    g->edges[g->nedges].from = from;
    g->edges[g->nedges].to = to;
    g->nedges++;
    return 1;
}

/** 若 e 为整型常量（字面量 / CTFE fold），写入 *out 并返回 1。 */
static int wpo_expr_const_i32(const struct ASTExpr *e, int *out) {
    if (!e || !out) return 0;
    if (e->kind == AST_EXPR_LIT) {
        *out = e->value.int_val;
        return 1;
    }
    if (e->kind == AST_EXPR_BOOL_LIT) {
        *out = e->value.int_val;
        return 1;
    }
    if (e->const_folded_valid) {
        *out = e->const_folded_val;
        return 1;
    }
    return 0;
}

/**
 * WPO-S2：记录 call site 的 from/to 与实参 profile；全为整型常量时 all_const=1。
 * 同 from→to 不同实参保留多条（与 edges 去重不同），供后续 monomorphize 分析。
 */
static void wpo_record_call_site(WpoGraph *g, int from, int to, struct ASTExpr **args, int nargs) {
    WpoCallSite *cs;
    int i;
    if (!g || from < 0 || to < 0 || from >= g->nfuncs || to >= g->nfuncs) return;
    if (g->ncall_sites >= WPO_MAX_CALL_SITES) return;
    if (nargs < 0) nargs = 0;
    if (nargs > WPO_MAX_CALL_SITE_ARGS) nargs = WPO_MAX_CALL_SITE_ARGS;
    cs = &g->call_sites[g->ncall_sites];
    cs->from = from;
    cs->to = to;
    cs->nargs = nargs;
    cs->all_const = (unsigned char)(nargs > 0);
    for (i = 0; i < WPO_MAX_CALL_SITE_ARGS; i++)
        cs->args[i] = -1;
    for (i = 0; i < nargs; i++) {
        int v = 0;
        if (!wpo_expr_const_i32(args[i], &v)) {
            cs->all_const = 0;
            cs->args[i] = -1;
        } else {
            cs->args[i] = v;
        }
    }
    if (nargs == 0)
        cs->all_const = 0;
    g->ncall_sites++;
}

/** 在 g 中按 VAR callee 名称解析函数 id；未命中返回 -1。 */
static int wpo_func_id_by_name(const WpoGraph *g, const char *name) {
    if (!g || !name)
        return -1;
    for (int i = 0; i < g->nfuncs; i++) {
        struct ASTFunc *f = g->funcs[i];
        if (f && f->name && strcmp(f->name, name) == 0)
            return i;
    }
    return -1;
}

/** CALL 的 callee 解析为图节点 id：优先 resolved_callee_func，否则 VAR 名匹配。 */
static int wpo_call_callee_id(const struct ASTExpr *e, const WpoGraph *g) {
    int cid;
    if (!e || e->kind != AST_EXPR_CALL || !g)
        return -1;
    if (e->value.call.resolved_callee_func) {
        cid = wpo_func_id(g, e->value.call.resolved_callee_func);
        if (cid >= 0)
            return cid;
    }
    if (e->value.call.callee && e->value.call.callee->kind == AST_EXPR_VAR &&
        e->value.call.callee->value.var.name)
        return wpo_func_id_by_name(g, e->value.call.callee->value.var.name);
    return -1;
}

/** 从块递归收集 call 边（前向声明，供 AST_EXPR_BLOCK 分支调用）。 */
static void wpo_collect_edges_from_block(const struct ASTBlock *b, int caller_id, WpoGraph *g);

/** 从表达式递归收集静态 call 边（caller_id 为当前函数节点）。 */
static void wpo_collect_edges_from_expr(const struct ASTExpr *e, int caller_id, WpoGraph *g) {
    if (!e || !g || caller_id < 0) return;
    if (e->kind == AST_EXPR_RETURN && e->value.unary.operand) {
        wpo_collect_edges_from_expr(e->value.unary.operand, caller_id, g);
        return;
    }
    if (e->kind == AST_EXPR_CALL) {
        int cid = wpo_call_callee_id(e, g);
        if (cid >= 0) {
            (void)wpo_add_edge(g, caller_id, cid);
            wpo_record_call_site(g, caller_id, cid, e->value.call.args, e->value.call.num_args);
        }
    }
    if (e->kind == AST_EXPR_METHOD_CALL && e->value.method_call.resolved_impl_func) {
        int cid = wpo_func_id(g, e->value.method_call.resolved_impl_func);
        if (cid >= 0) {
            (void)wpo_add_edge(g, caller_id, cid);
            wpo_record_call_site(g, caller_id, cid, e->value.method_call.args, e->value.method_call.num_args);
        }
    }
    switch (e->kind) {
        case AST_EXPR_CALL:
            for (int i = 0; i < e->value.call.num_args; i++)
                wpo_collect_edges_from_expr(e->value.call.args[i], caller_id, g);
            break;
        case AST_EXPR_METHOD_CALL:
            wpo_collect_edges_from_expr(e->value.method_call.base, caller_id, g);
            for (int i = 0; i < e->value.method_call.num_args; i++)
                wpo_collect_edges_from_expr(e->value.method_call.args[i], caller_id, g);
            break;
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
        case AST_EXPR_SHL: case AST_EXPR_SHR: case AST_EXPR_BITAND: case AST_EXPR_BITOR: case AST_EXPR_BITXOR:
        case AST_EXPR_EQ: case AST_EXPR_NE: case AST_EXPR_LT: case AST_EXPR_LE: case AST_EXPR_GT: case AST_EXPR_GE:
        case AST_EXPR_LOGAND: case AST_EXPR_LOGOR: case AST_EXPR_ASSIGN:
        case AST_EXPR_ADD_ASSIGN: case AST_EXPR_SUB_ASSIGN: case AST_EXPR_MUL_ASSIGN: case AST_EXPR_DIV_ASSIGN: case AST_EXPR_MOD_ASSIGN:
        case AST_EXPR_BITAND_ASSIGN: case AST_EXPR_BITOR_ASSIGN: case AST_EXPR_BITXOR_ASSIGN: case AST_EXPR_SHL_ASSIGN: case AST_EXPR_SHR_ASSIGN:
            wpo_collect_edges_from_expr(e->value.binop.left, caller_id, g);
            wpo_collect_edges_from_expr(e->value.binop.right, caller_id, g);
            break;
        case AST_EXPR_NEG: case AST_EXPR_BITNOT: case AST_EXPR_LOGNOT: case AST_EXPR_PANIC:
        case AST_EXPR_ADDR_OF: case AST_EXPR_DEREF: case AST_EXPR_RETURN: case AST_EXPR_AWAIT: case AST_EXPR_RUN:
        case AST_EXPR_TRY_PROPAGATE:
            wpo_collect_edges_from_expr(e->value.unary.operand, caller_id, g);
            break;
        case AST_EXPR_AS:
            wpo_collect_edges_from_expr(e->value.as_type.operand, caller_id, g);
            break;
        case AST_EXPR_IF: case AST_EXPR_TERNARY:
            wpo_collect_edges_from_expr(e->value.if_expr.cond, caller_id, g);
            wpo_collect_edges_from_expr(e->value.if_expr.then_expr, caller_id, g);
            if (e->value.if_expr.else_expr) wpo_collect_edges_from_expr(e->value.if_expr.else_expr, caller_id, g);
            break;
        case AST_EXPR_MATCH:
            wpo_collect_edges_from_expr(e->value.match_expr.matched_expr, caller_id, g);
            for (int i = 0; i < e->value.match_expr.num_arms; i++)
                wpo_collect_edges_from_expr(e->value.match_expr.arms[i].result, caller_id, g);
            break;
        case AST_EXPR_FIELD_ACCESS:
            wpo_collect_edges_from_expr(e->value.field_access.base, caller_id, g);
            break;
        case AST_EXPR_STRUCT_LIT:
            for (int i = 0; i < e->value.struct_lit.num_fields; i++)
                wpo_collect_edges_from_expr(e->value.struct_lit.inits[i], caller_id, g);
            break;
        case AST_EXPR_ARRAY_LIT:
            for (int i = 0; i < e->value.array_lit.num_elems; i++)
                wpo_collect_edges_from_expr(e->value.array_lit.elems[i], caller_id, g);
            break;
        case AST_EXPR_INDEX:
            wpo_collect_edges_from_expr(e->value.index.base, caller_id, g);
            wpo_collect_edges_from_expr(e->value.index.index_expr, caller_id, g);
            break;
        case AST_EXPR_BLOCK:
            wpo_collect_edges_from_block(e->value.block, caller_id, g);
            break;
        default: break;
    }
}

/** 从块递归收集 call 边。
 * 【Why 逻辑根源】必须覆盖块内所有可能包含 CALL 的子结构，否则被调用函数会被
 * 误判为 unreachable 而 DCE 剔除，导致链接时 undeclared symbol。
 * 与 typeck_block（typeck.c:4031）和 collect_var_names_from_block（codegen.c:7124）
 * 的遍历范围严格对齐：defer_blocks / regions / with_arenas / try_catches 均须递归。
 * 【Invariant】只读遍历，不修改 AST；caller_id 为调用者节点 id，全程不变。
 * 【Asm/Perf】WPO 为编译期静态分析，不影响运行期代码生成质量。 */
static void wpo_collect_edges_from_block(const struct ASTBlock *b, int caller_id, WpoGraph *g) {
    if (!b || !g || caller_id < 0) return;
    for (int i = 0; i < b->num_consts; i++)
        if (b->const_decls[i].init) wpo_collect_edges_from_expr(b->const_decls[i].init, caller_id, g);
    for (int i = 0; i < b->num_lets; i++)
        if (b->let_decls[i].init) wpo_collect_edges_from_expr(b->let_decls[i].init, caller_id, g);
    for (int i = 0; i < b->num_loops; i++)
        wpo_collect_edges_from_block(b->loops[i].body, caller_id, g);
    for (int i = 0; i < b->num_for_loops; i++) {
        if (b->for_loops[i].init) wpo_collect_edges_from_expr(b->for_loops[i].init, caller_id, g);
        if (b->for_loops[i].cond) wpo_collect_edges_from_expr(b->for_loops[i].cond, caller_id, g);
        if (b->for_loops[i].step) wpo_collect_edges_from_expr(b->for_loops[i].step, caller_id, g);
        wpo_collect_edges_from_block(b->for_loops[i].body, caller_id, g);
    }
    /* defer 块体：块退出时执行，可能含 call（如 heap.free） */
    for (int i = 0; i < b->num_defers; i++)
        if (b->defer_blocks && i < b->num_defers && b->defer_blocks[i])
            wpo_collect_edges_from_block(b->defer_blocks[i], caller_id, g);
    /* region/unsafe 块体：unsafe { start = slot(*s, key); } 等含 call；
     * 漏处理会导致 slot 被误判 unreachable 而 DCE 剔除（run-set.sh 回归根因）。 */
    for (int i = 0; i < b->num_regions; i++)
        if (b->regions && b->regions[i].body)
            wpo_collect_edges_from_block(b->regions[i].body, caller_id, g);
    /* with_arena(cap) { body }：cap 表达式与 body 均可能含 call */
    for (int i = 0; i < b->num_with_arenas; i++) {
        if (b->with_arenas && b->with_arenas[i].cap)
            wpo_collect_edges_from_expr(b->with_arenas[i].cap, caller_id, g);
        if (b->with_arenas && b->with_arenas[i].body)
            wpo_collect_edges_from_block(b->with_arenas[i].body, caller_id, g);
    }
    /* try { } catch { }：try_body 与 catch_body 均可能含 call */
    for (int i = 0; i < b->num_try_catches; i++) {
        if (b->try_catches && b->try_catches[i].try_body)
            wpo_collect_edges_from_block(b->try_catches[i].try_body, caller_id, g);
        if (b->try_catches && b->try_catches[i].catch_body)
            wpo_collect_edges_from_block(b->try_catches[i].catch_body, caller_id, g);
    }
    for (int i = 0; i < b->num_labeled_stmts; i++)
        if (b->labeled_stmts[i].kind == AST_STMT_RETURN && b->labeled_stmts[i].u.return_expr)
            wpo_collect_edges_from_expr(b->labeled_stmts[i].u.return_expr, caller_id, g);
    for (int i = 0; i < b->num_expr_stmts; i++)
        wpo_collect_edges_from_expr(b->expr_stmts[i], caller_id, g);
    if (b->final_expr) wpo_collect_edges_from_expr(b->final_expr, caller_id, g);
}

/** 从 root 起 BFS 标记 reachable 并补全边（与 DCE worklist 同语义）。 */
static void wpo_build_edges_and_reach(WpoGraph *g) {
    if (!g || g->root_id < 0 || g->root_id >= g->nfuncs) return;
    int queue[WPO_MAX_FUNCS];
    int qh = 0, qt = 0;
    g->reachable[(size_t)g->root_id] = 1;
    queue[qt++] = g->root_id;
    while (qh < qt && qh < WPO_MAX_FUNCS) {
        int fid = queue[qh++];
        struct ASTFunc *f = g->funcs[fid];
        if (!f || !f->body) continue;
        wpo_collect_edges_from_block(f->body, fid, g);
        for (int ei = 0; ei < g->nedges; ei++) {
            if (g->edges[ei].from != fid) continue;
            int to = g->edges[ei].to;
            if (to < 0 || to >= g->nfuncs) continue;
            if (!g->reachable[(size_t)to]) {
                g->reachable[(size_t)to] = 1;
                if (qt < WPO_MAX_FUNCS) queue[qt++] = to;
            }
        }
    }
}

/** 初始化 WpoGraph：entry 在 mod 0，all_mods 从 1 起。 */
static void wpo_graph_init(WpoGraph *g, struct ASTModule *entry, const char *entry_path,
    struct ASTModule **all_mods, const char **all_paths, int n_all) {
    memset(g, 0, sizeof(*g));
    g->entry = entry;
    g->entry_path = entry_path;
    g->root_id = -1;
    if (entry && g->nmods < WPO_MAX_MODS) {
        g->mods[g->nmods] = entry;
        g->paths[g->nmods] = entry_path ? entry_path : "";
        wpo_register_module(g, entry, g->nmods);
        g->nmods++;
    }
    if (all_mods) {
        for (int i = 0; i < n_all && g->nmods < WPO_MAX_MODS; i++) {
            if (!all_mods[i]) continue;
            if (all_mods[i] == entry) continue;
            g->mods[g->nmods] = all_mods[i];
            g->paths[g->nmods] = (all_paths && all_paths[i]) ? all_paths[i] : "";
            wpo_register_module(g, all_mods[i], g->nmods);
            g->nmods++;
        }
    }
    wpo_pick_root(g);
    wpo_build_edges_and_reach(g);
}

/** WPO v0：填充全程序可达性表，供 codegen DCE 跨模块剔除 dead export。 */
void codegen_wpo_reach_compute(CodegenWpoReach *out,
    struct ASTModule *entry,
    struct ASTModule **all_mods, int n_all) {
    WpoGraph g;
    if (!out) return;
    memset(out, 0, sizeof(*out));
    if (!entry) return;
    wpo_graph_init(&g, entry, NULL, all_mods, NULL, n_all);
    out->nfuncs = g.nfuncs < CODEGEN_WPO_REACH_MAX_FUNCS ? g.nfuncs : CODEGEN_WPO_REACH_MAX_FUNCS;
    out->root_id = g.root_id;
    out->valid = (g.root_id >= 0 && out->nfuncs > 0);
    for (int i = 0; i < out->nfuncs; i++) {
        out->funcs[i] = g.funcs[i];
        out->reachable[i] = g.reachable[i];
        out->mod_of[i] = (g.mod_of[i] >= 0 && g.mod_of[i] < g.nmods) ? g.mods[g.mod_of[i]] : NULL;
    }
}

/** 查询函数在 WPO 图中是否可达；extern 与未注册函数保守保留。 */
int codegen_wpo_reach_is_reachable(const CodegenWpoReach *wpo, const struct ASTModule *mod, const struct ASTFunc *func) {
    if (!wpo || !wpo->valid || !func) return 1;
    if (func->is_extern) return 1;
    for (int i = 0; i < wpo->nfuncs; i++) {
        if (wpo->funcs[i] == func)
            return wpo->reachable[i] ? 1 : 0;
    }
    /* import 库 emit 时 ASTFunc 指针偶发与构图时不一致：按 (mod, name) 兜底。 */
    if (mod && func->name) {
        for (int i = 0; i < wpo->nfuncs; i++) {
            if (wpo->mod_of[i] != mod) continue;
            if (!wpo->funcs[i] || !wpo->funcs[i]->name) continue;
            if (strcmp(wpo->funcs[i]->name, func->name) != 0) continue;
            return wpo->reachable[i] ? 1 : 0;
        }
    }
    /* 模块指针不一致时：全局唯一函数名兜底（compiler self 常见 duplicate 名较少）。 */
    if (func->name) {
        int found = -1;
        for (int i = 0; i < wpo->nfuncs; i++) {
            if (!wpo->funcs[i] || !wpo->funcs[i]->name) continue;
            if (strcmp(wpo->funcs[i]->name, func->name) != 0) continue;
            if (found >= 0) { found = -2; break; }
            found = i;
        }
        if (found >= 0) return wpo->reachable[found] ? 1 : 0;
    }
    return 1;
}

void codegen_dump_wpo_callgraph_json(FILE *out,
    struct ASTModule *entry, const char *entry_path,
    struct ASTModule **all_mods, const char **all_paths, int n_all) {
    WpoGraph g;
    if (!out || !entry) return;
    wpo_graph_init(&g, entry, entry_path, all_mods, all_paths, n_all);
    fputs("{\n  \"version\": 2,\n", out);
    fputs("  \"entry\": ", out);
    wpo_json_string(out, entry_path ? entry_path : "");
    fputs(",\n  \"modules\": [\n", out);
    for (int mi = 0; mi < g.nmods; mi++) {
        if (mi) fputs(",\n", out);
        fprintf(out, "    {\"id\": %d, \"path\": ", mi);
        wpo_json_string(out, g.paths[mi]);
        fputc('}', out);
    }
    fputs("\n  ],\n  \"functions\": [\n", out);
    for (int fi = 0; fi < g.nfuncs; fi++) {
        struct ASTFunc *f = g.funcs[fi];
        if (fi) fputs(",\n", out);
        fprintf(out, "    {\"id\": %d, \"module\": %d, \"name\": ", fi, g.mod_of[fi]);
        wpo_json_string(out, f && f->name ? f->name : "");
        fprintf(out, ", \"extern\": %s, \"reachable\": %s}",
            (f && f->is_extern) ? "true" : "false",
            g.reachable[(size_t)fi] ? "true" : "false");
    }
    fputs("\n  ],\n  \"edges\": [\n", out);
    for (int ei = 0; ei < g.nedges; ei++) {
        if (ei) fputs(",\n", out);
        fprintf(out, "    {\"from\": %d, \"to\": %d}", g.edges[ei].from, g.edges[ei].to);
    }
    fputs("\n  ],\n  \"call_sites\": [\n", out);
    for (int ci = 0; ci < g.ncall_sites; ci++) {
        const WpoCallSite *cs = &g.call_sites[ci];
        if (ci) fputs(",\n", out);
        fprintf(out, "    {\"from\": %d, \"to\": %d, \"all_const\": %s, \"args\": [",
            cs->from, cs->to, cs->all_const ? "true" : "false");
        for (int ai = 0; ai < cs->nargs; ai++) {
            if (ai) fputc(',', out);
            if (cs->args[ai] >= 0)
                fprintf(out, "%d", cs->args[ai]);
            else
                fputs("null", out);
        }
        fputs("]}", out);
    }
    fprintf(out, "\n  ],\n  \"root\": %d\n}\n", g.root_id);
}

/** 函数体唯一 return 操作数（final_expr 或单条 return stmt）。 */
static struct ASTExpr *cg_wpo_func_return_operand(struct ASTFunc *f) {
    struct ASTBlock *b;
    struct ASTExpr *op;
    int found;
    int i;
    if (!f || !f->body)
        return NULL;
    b = f->body;
    if (b->final_expr) {
        if (b->final_expr->kind == AST_EXPR_RETURN && b->final_expr->value.unary.operand)
            return b->final_expr->value.unary.operand;
        return b->final_expr;
    }
    op = NULL;
    found = 0;
    for (i = 0; i < b->num_expr_stmts; i++) {
        struct ASTExpr *er = b->expr_stmts[i];
        if (er && er->kind == AST_EXPR_RETURN && er->value.unary.operand) {
            found++;
            op = er->value.unary.operand;
        }
    }
    return found == 1 ? op : NULL;
}

/** 表达式是否为函数第 param_idx 个形参名。 */
static int cg_wpo_expr_is_func_param(const struct ASTExpr *e, const struct ASTFunc *f, int param_idx) {
    const char *pname;
    if (!e || e->kind != AST_EXPR_VAR || !f || param_idx < 0 || param_idx >= f->num_params || !f->params)
        return 0;
    pname = f->params[param_idx].name;
    return pname && e->value.var.name && strcmp(e->value.var.name, pname) == 0;
}

/** callee 是否为 `return param0 binop param1`（两 i32 形参标量 binop）。 */
static int cg_wpo_func_returns_param01_scalar_binop(const struct ASTFunc *f, ASTExprKind *out_binop) {
    struct ASTExpr *ret;
    struct ASTExpr *left;
    struct ASTExpr *right;
    if (!f || !out_binop || f->num_params != 2 || !f->params)
        return 0;
    ret = cg_wpo_func_return_operand((struct ASTFunc *)f);
    if (!ret)
        return 0;
    switch (ret->kind) {
        case AST_EXPR_ADD: case AST_EXPR_SUB: case AST_EXPR_MUL: case AST_EXPR_DIV: case AST_EXPR_MOD:
            break;
        default:
            return 0;
    }
    left = ret->value.binop.left;
    right = ret->value.binop.right;
    if (!cg_wpo_expr_is_func_param(left, f, 0))
        return 0;
    if (!cg_wpo_expr_is_func_param(right, f, 1))
        return 0;
    *out_binop = ret->kind;
    return 1;
}

/** 编译期 i32 binop 求值（与 asm glue_const_scalar_binop_eval 语义一致）。 */
static int cg_wpo_binop_eval_i32(ASTExprKind kind, int32_t a, int32_t b, int32_t *out) {
    int64_t wide;
    if (!out)
        return 0;
    switch (kind) {
        case AST_EXPR_ADD: wide = (int64_t)a + (int64_t)b; break;
        case AST_EXPR_SUB: wide = (int64_t)a - (int64_t)b; break;
        case AST_EXPR_MUL: wide = (int64_t)a * (int64_t)b; break;
        case AST_EXPR_DIV:
            if (b == 0) return 0;
            wide = (int64_t)a / (int64_t)b;
            break;
        case AST_EXPR_MOD:
            if (b == 0) return 0;
            wide = (int64_t)a % (int64_t)b;
            break;
        default:
            return 0;
    }
    *out = (int32_t)wide;
    return 1;
}

int codegen_wpo_mono_sym_format(const char *base, int nargs, const int *args, char *out, int cap) {
    int pos;
    int i;
    int n;
    if (!base || !out || cap < 16)
        return -1;
    pos = snprintf(out, (size_t)cap, "%s__wpo", base);
    if (pos < 0 || pos >= cap)
        return -1;
    for (i = 0; i < nargs; i++) {
        if (!args)
            return -1;
        if (args[i] < 0)
            n = snprintf(out + pos, (size_t)(cap - pos), "_n%d", -args[i]);
        else
            n = snprintf(out + pos, (size_t)(cap - pos), "_%d", args[i]);
        if (n < 0 || pos + n >= cap)
            return -1;
        pos += n;
    }
    return pos;
}

/** 按 sym 字符串去重；已存在返回 1。 */
static int cg_wpo_mono_thunk_has_sym(const CodegenWpoMonoThunks *bag, const char *sym) {
    int i;
    if (!bag || !sym)
        return 0;
    for (i = 0; i < bag->n; i++)
        if (bag->thunks[i].valid && strcmp(bag->thunks[i].sym, sym) == 0)
            return 1;
    return 0;
}

void codegen_wpo_collect_mono_thunks(CodegenWpoMonoThunks *out,
    struct ASTModule *entry,
    struct ASTModule **dep_mods, int ndep,
    const char *entry_path) {
    static WpoGraph g;
    struct ASTModule *mods[WPO_MAX_MODS];
    const char *paths[WPO_MAX_MODS];
    int n_all;
    int ci;
    if (!out)
        return;
    memset(out, 0, sizeof(*out));
    if (!entry)
        return;
    n_all = 0;
    if (dep_mods && ndep > 0) {
        for (int di = 0; di < ndep && n_all < WPO_MAX_MODS; di++) {
            if (!dep_mods[di])
                continue;
            mods[n_all] = dep_mods[di];
            paths[n_all] = "";
            n_all++;
        }
    }
    memset(&g, 0, sizeof(g));
    wpo_graph_init(&g, entry, entry_path, mods, paths, n_all);
    for (ci = 0; ci < g.ncall_sites; ci++) {
        const WpoCallSite *cs = &g.call_sites[ci];
        struct ASTFunc *callee;
        ASTExprKind binop;
        CodegenWpoMonoThunk *slot;
        char sym[CODEGEN_WPO_MONO_SYM_MAX];
        int sym_len;
        int32_t folded;
        if (!cs->all_const || cs->nargs != 2)
            continue;
        if (cs->from < 0 || cs->from >= g.nfuncs || !g.reachable[(size_t)cs->from])
            continue;
        if (cs->to < 0 || cs->to >= g.nfuncs)
            continue;
        callee = g.funcs[cs->to];
        if (!callee || callee->is_extern || !callee->name)
            continue;
        if (!cg_wpo_func_returns_param01_scalar_binop(callee, &binop))
            continue;
        if (!cg_wpo_binop_eval_i32(binop, cs->args[0], cs->args[1], &folded))
            continue;
        sym_len = codegen_wpo_mono_sym_format(callee->name, cs->nargs, cs->args, sym, (int)sizeof(sym));
        if (sym_len <= 0)
            continue;
        if (cg_wpo_mono_thunk_has_sym(out, sym))
            continue;
        if (out->n >= CODEGEN_WPO_MAX_MONO_THUNKS)
            break;
        slot = &out->thunks[out->n];
        memset(slot, 0, sizeof(*slot));
        memcpy(slot->sym, sym, (size_t)sym_len + 1);
        {
            size_t bn = strlen(callee->name);
            if (bn >= sizeof(slot->base_name))
                bn = sizeof(slot->base_name) - 1;
            memcpy(slot->base_name, callee->name, bn);
            slot->base_name[bn] = '\0';
        }
        slot->nargs = cs->nargs;
        for (int ai = 0; ai < cs->nargs && ai < CODEGEN_WPO_MONO_MAX_ARGS; ai++)
            slot->args[ai] = cs->args[ai];
        slot->result_imm = folded;
        slot->valid = 1;
        out->n++;
    }
}
