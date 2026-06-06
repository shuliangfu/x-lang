/**
 * clangd_glued_preamble.h — IDE 专用：模拟 pipeline_gen.c + pipeline_glue.c 同 TU 前缀。
 *
 * ast_pool.c / ast_pool_bootstrap_glue.c / pipeline_glue.c 由 #include 编入 pipeline_gen.c，
 * 不可单独 cc -c；clangd 打开这些文件时通过 .clangd -include 本头获得完整 ast_* 类型。
 *
 * 类型快照由 scripts/gen_compile_commands.sh 从 typeck_gen_full.c 抽取至 ide/pipeline_glue_types.inc。
 */
#ifndef CLANGD_GLUED_PREAMBLE_H
#define CLANGD_GLUED_PREAMBLE_H

#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/** pipeline_glue.c 中 parser_slice_from_buf 等依赖；真 TU 由 pipeline_gen.c 定义。 */
struct shulang_slice_uint8_t {
  uint8_t *data;
  size_t length;
};

#if __has_include("pipeline_glue_types.inc")
#include "pipeline_glue_types.inc"
#else
#warning "Run: ./compiler/scripts/gen_compile_commands.sh (generates ide/pipeline_glue_types.inc)"
#endif

/**
 * ast_pool_bootstrap_glue.c 单独打开时，下方符号在真 TU 中由 ast_pool.c / pipeline_glue.c 更早定义。
 * IDE 仅作前向声明，消除 implicit declaration / incomplete type 误报。
 */
extern int32_t asm_bump_off_before_struct_local(struct ast_ASTArena *arena, int32_t type_ref, int32_t off);
extern int32_t asm_local_slot_bytes(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t asm_type_is_simd_vector_spelling(struct ast_ASTArena *arena, int32_t type_ref);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *arena, int32_t type_ref);
extern struct ast_Type *pipeline_arena_type_ptr(struct ast_ASTArena *a, int32_t ref);

#endif /* CLANGD_GLUED_PREAMBLE_H */
