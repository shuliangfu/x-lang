/* seeds/async_asm_pool.from_x.c — G-02f-80 product cold-start TU
 * G-02f-104 helper gates.
 * Promoted from compiler/src/async/async_asm_pool.inc (stub/bridge; retired .inc).
 * Compile: cc -c seeds/async_asm_pool.from_x.c → src/async/async_asm_pool.o
 *
 * R2 full（2026-07-21）：公共业务由 full .x 提供（helpers + build_layout）：
 *   asm_pool_expr_is_await / has_await / is_var_named / refs_name / block_rest_refs_name
 *   + type_size_bytes + live_add + fn_id_from_name + func_needs_cps + build_layout
 * FROM_X 下本文件业务 H=0（仅 slice marker）。
 * Cap residual：无（build_layout 已 pure 真迁）。
 * Unbundle（2026-07-21）：不再 #include 进 pipeline_glue.c；独立 TU 入
 *   DRIVER_SEED_SUPPORT_EXTRA / g05_relink_env（所有模式）。
 * 冷启动/无 PREFER：完整 C 体 → src/async/async_asm_pool.o。
 * PREFER：src/asm/async_asm_pool.x + 本 rest (-DXLANG_ASYNC_ASM_POOL_FROM_X) ld -r。
 * PLATFORM: SHARED — pool API 跨平台一致。
 */
/**
 * async_asm_pool.c — pool AST async CPS 帧 layout 分析（WPO-S3 / asm 后端）
 *
 * 文件职责：线性扫描 stmt_order，在 await 边界收集 continuation 仍引用的 let；
 *           估算 frame data 区字段偏移，供 pipeline_glue emit save/restore。
 */
#include "async_asm_pool.h"
#include <string.h>

struct ast_ASTArena;
struct ast_Module;

extern int32_t pipeline_module_func_is_async_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t fi);
extern int32_t pipeline_module_func_name_len_at(struct ast_Module *m, int32_t fi);
extern void pipeline_module_func_name_copy64(struct ast_Module *m, int32_t fi, uint8_t *dst);
extern int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_as_target_type_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_binop_left_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_binop_right_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);
extern int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t block_ref);
extern int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *a, int32_t block_ref);
extern int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *a, int32_t block_ref);
extern uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena *a, int32_t block_ref, int32_t si);
extern int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena *a, int32_t block_ref, int32_t si);
extern int32_t pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
extern int32_t pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
extern void pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
extern int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
extern int32_t pipeline_asm_block_final_expr_ref_at(struct ast_ASTArena *a, int32_t br);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *a, int32_t type_ref);
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena *a, int32_t type_ref, uint8_t *out);
extern int32_t typeck_x_type_size_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t layout_idx, int32_t depth);
extern int32_t pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx);
extern uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t bi);
extern int32_t pipeline_module_num_struct_layouts_at(struct ast_Module *m);

/** C AST_EXPR_AWAIT(54) 与 X EXPR_AS(54) 碰撞；X EXPR_AWAIT=55。 */
#define ASM_POOL_KIND_ORD54 54
#define ASM_POOL_KIND_X_AWAIT 55

/* R2 full：FROM_X 时全部业务体省略（由 src/asm/async_asm_pool.x 提供）；
 * 冷启动无宏时本文件提供完整 C 体（含 build_layout）。
 * 宏边界：XLANG_ASYNC_ASM_POOL_FROM_X
 */
#ifndef XLANG_ASYNC_ASM_POOL_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_ASYNC_ASM_POOL_FROM_X removed */
#else
/* FROM_X rest：业务 H=0；.x 提供全部公共符号 */
#endif /* XLANG_ASYNC_ASM_POOL_FROM_X */

/** Slice marker for hybrid/PREFER ld -r prove (always present). */
void async_asm_pool_slice_marker(void) {}
