/**
 * async_liveness.h — async 函数跨 await 存活变量分析（A3）
 *
 * 文件职责：对 async function 体做静态分析，求协程帧字段布局并 emit C struct typedef。
 * 所属模块：compiler 前端；供 codegen 输出帧类型与 SHU_ASYNC_FRAME 注释。
 */
#ifndef ASYNC_LIVENESS_H
#define ASYNC_LIVENESS_H

#include "ast.h"
#include <stdio.h>

/** 单函数帧内最多记录的存活符号数（形参 + let）。 */
#define ASYNC_LIVE_MAX_VARS 64

/** 跨 await 须保留的变量名列表（字典序稳定输出）。 */
typedef struct AsyncFrameLive {
    char names[ASYNC_LIVE_MAX_VARS][64];
    int n;
} AsyncFrameLive;

/** async 函数帧布局摘要（liveness + await 点数 + 估算字节数）。 */
typedef struct AsyncFrameLayout {
    AsyncFrameLive live;
    int num_awaits;
    int frame_bytes;
    char frame_tag[80];
    /** IO-A5 v2：帧内保存 submit 返回的 read/write async slot。 */
    int has_io_rd_slot;
    int has_io_wr_slot;
} AsyncFrameLayout;

/** 函数体是否含 await（用于决定是否 emit 帧类型）。 */
int async_liveness_func_has_await(const struct ASTFunc *f);

/** 表达式是否含 await（供 CPS codegen 判定分段点）。 */
int async_liveness_expr_has_await(const struct ASTExpr *e);

/** 在函数体/形参中查找变量类型。 */
const struct ASTType *async_liveness_lookup_var_type(const struct ASTFunc *f, const char *name);

/** AST 类型 → C 类型字符串（写入 buf）。 */
void async_liveness_type_to_c_buf(const struct ASTType *ty, char *buf, size_t n);

/**
 * 分析 async 函数帧布局：live 集、await 点数、估算 frame_bytes、frame_tag。
 * 返回值：0 成功；非 async 或无 await 时 live.n=0； -1 参数非法。
 */
int async_liveness_layout_func(const struct ASTFunc *f, AsyncFrameLayout *out);

/** 带 module 的布局分析：struct 字段大小取自 typeck struct_size（WPO-S3）。 */
int async_liveness_layout_func_module(const struct ASTFunc *f, const struct ASTModule *m,
    AsyncFrameLayout *out);

/** 估算类型字节数；module 非 NULL 时 NAMED struct 用 layout pass 的 struct_size。 */
int async_liveness_type_size_bytes_module(const struct ASTType *ty, const struct ASTModule *m);

/** 结构体是否被某 async 协程帧 live 集引用（codegen DCE 豁免）。 */
int async_liveness_module_struct_in_frame(const struct ASTModule *m, const char *struct_name);

/** 兼容旧接口：仅填充 live 集。 */
int async_liveness_analyze_func(const struct ASTFunc *f, AsyncFrameLive *out);

/** 在函数定义之前 emit `typedef struct __shu_async_frame_* { ... }`（无 await 时不输出）。 */
void async_liveness_emit_frame_typedef(const struct ASTFunc *f,
    const AsyncFrameLayout *layout, FILE *out);

/** 函数体开头 emit 帧局部变量占位（sync stub；CPS 后续读写 __shu_frame）。 */
void async_liveness_emit_frame_local(const struct ASTFunc *f,
    const AsyncFrameLayout *layout, FILE *out);

/** 向生成的 C 源写入帧布局注释（grep 门禁用）。 */
void async_liveness_emit_codegen_comment(const struct ASTFunc *f,
    const AsyncFrameLayout *layout, FILE *out);

#endif
