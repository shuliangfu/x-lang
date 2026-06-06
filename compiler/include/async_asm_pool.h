/**
 * async_asm_pool.h — asm 后端 async CPS 帧布局（pool AST）
 *
 * 文件职责：基于 ast pool / pipeline_* API 分析 async 函数跨 await 存活变量，
 *           供 pipeline_glue asm emit 保存/恢复协程帧（WPO-S3）。
 */
#ifndef ASYNC_ASM_POOL_H
#define ASYNC_ASM_POOL_H

#include <stdint.h>

/** 与 async_liveness.h 一致；勿 #include ast.h（pipeline_glue_standalone TU 与 pipeline_glue_types.inc 冲突）。 */
#ifndef ASYNC_LIVE_MAX_VARS
#define ASYNC_LIVE_MAX_VARS 64
#endif

struct ast_ASTArena;
struct ast_Module;

/** 单帧 live 变量描述（栈槽由 emit 时按名解析）。 */
typedef struct AsyncAsmPoolLiveVar {
    char name[64];
    int32_t name_len;
    int32_t size_bytes;
    int32_t frame_data_off;
} AsyncAsmPoolLiveVar;

/** pool async 函数 CPS 布局摘要。 */
typedef struct AsyncAsmPoolLayout {
    uint32_t fn_id;
    int32_t num_awaits;
    int32_t num_live;
    AsyncAsmPoolLiveVar live[ASYNC_LIVE_MAX_VARS];
    /** 首个 await 所在 stmt_order 下标（let init 含 await 时有效）。 */
    int32_t await_stmt_idx;
} AsyncAsmPoolLayout;

/** 函数名 → 稳定 fn_id（scheduler 帧槽 key）。 */
uint32_t async_asm_pool_fn_id_from_name(const uint8_t *name, int32_t name_len);

/** 是否 async 且体中含 await（C parser kind54）。 */
int32_t async_asm_pool_func_needs_cps(struct ast_ASTArena *arena, struct ast_Module *mod, int32_t func_index);

/** 分析帧 layout；0 成功且 out 有效，1 无需 CPS，-1 参数/分析失败。 */
int32_t async_asm_pool_build_layout(struct ast_ASTArena *arena, struct ast_Module *mod, int32_t func_index,
                                    AsyncAsmPoolLayout *out);

#endif
