/**
 * sx_seed_bridge.c — bootstrap-driver-seed 分 TU 链接桥：preprocess 名前缀、asm 桩、ast 辅助、heap 桩。
 *
 * pipeline_sx.o / parser_sx.o / typeck_sx.o / codegen_sx.o 经 -E-extern 分模块后，
 * runtime / driver / lsp 仍引用 C 路径或 import 前缀符号；本文件补齐 seed 链缺口。
 */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <stdarg.h>

/** 与 -E-extern 生成体一致的扁平 ASTExpr（勿 include ast.h 的 ASTExpr，布局不同）。 */
struct ast_Expr {
  int32_t kind;
  int32_t resolved_type_ref;
  int32_t line;
  int32_t col;
  int32_t int_val;
  int32_t _expr_pad_before_f64;
  double float_val;
  uint8_t var_name[64];
  int32_t var_name_len;
  int32_t binop_left_ref;
  int32_t binop_right_ref;
  int32_t unary_operand_ref;
  int32_t if_cond_ref;
  int32_t if_then_ref;
  int32_t if_else_ref;
  int32_t block_ref;
  int32_t match_matched_ref;
  int32_t match_arm_base;
  int32_t match_num_arms;
  int32_t field_access_base_ref;
  uint8_t field_access_field_name[64];
  int32_t field_access_field_len;
  int32_t field_access_is_enum_variant;
  int32_t field_access_offset;
  int32_t field_access_soa_stride;
  int32_t index_base_ref;
  int32_t index_index_ref;
  int32_t index_base_is_slice;
  int32_t call_callee_ref;
  int32_t call_arg_base;
  int32_t call_num_args;
  int32_t method_call_base_ref;
  uint8_t method_call_name[64];
  int32_t method_call_name_len;
  int32_t method_call_arg_base;
  int32_t method_call_num_args;
  int32_t const_folded_val;
  int32_t const_folded_valid;
  int32_t index_proven_in_bounds;
  uint8_t struct_lit_struct_name[64];
  int32_t struct_lit_struct_name_len;
  int32_t struct_lit_field_base;
  int32_t struct_lit_num_fields;
  int32_t array_lit_elem_base;
  int32_t array_lit_num_elems;
  int32_t float_bits_lo;
  int32_t float_bits_hi;
  int32_t enum_variant_tag;
  int32_t as_operand_ref;
  int32_t as_target_type_ref;
  int32_t call_resolved_func_index;
  int32_t call_resolved_dep_index;
};

struct ast_ASTArena;

struct ast_Module;

/** parser.sx parse_match 查 enum tag 时的当前 Module（parse_into 入口设置）。 */
static struct ast_Module *g_parser_match_module_sx;

void pipeline_parser_set_match_module(struct ast_Module *m) {
  g_parser_match_module_sx = m;
}

struct ast_Module *pipeline_parser_get_match_module(void) {
  return g_parser_match_module_sx;
}

extern struct ast_Expr ast_arena_expr_get(struct ast_ASTArena *a, int32_t ref);
extern void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);

/** preprocess_sx.o 导出 typeck_preprocess_sx_buf；driver 引用 preprocess_sx_buf。 */
extern int32_t typeck_preprocess_sx_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf, int32_t out_cap);

int32_t preprocess_sx_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf, int32_t out_cap) {
  return typeck_preprocess_sx_buf(src, src_len, out_buf, out_cap);
}

/** asm 入口由 user_asm_seed_bridge.o + build_asm/seed_host 提供；须 make build-seed-asm-host。 */

/** parser.sx 生成体引用；初始化 match 相关字段。verify-selfhost-stage2 链 ast_sx2.o 时由 ast.sx 导出，勿重复定义。 */
#ifndef SX_VERIFY_STAGE2
void ast_expr_init_match_enum(struct ast_Expr *e) {
  if (!e)
    return;
  e->match_matched_ref = 0;
  e->match_arm_base = 0;
  e->match_num_arms = 0;
}
#endif

/** typeck/codegen 生成体引用；重置 call resolve 字段。Stage2 由 ast_sx2.o 提供。 */
#ifndef SX_VERIFY_STAGE2
void ast_expr_init_call_resolve(struct ast_ASTArena *arena, int32_t expr_ref) {
  struct ast_Expr e;
  if (!arena || expr_ref <= 0)
    return;
  e = ast_arena_expr_get(arena, expr_ref);
  e.call_resolved_func_index = -1;
  e.call_resolved_dep_index = -1;
  ast_arena_expr_set(arena, expr_ref, e);
}
#endif

/** parser.sx 经 std.heap 引用；seed 链按需 malloc 清零。 */
void *std_heap_alloc_zeroed(size_t size) {
  return calloc(1, size);
}

void std_heap_free(void *ptr) {
  free(ptr);
}

/** lsp_io_std_heap.sx 导出 typeck_*；lsp_diag_sx 链接 std_heap_* 裸名。 */
extern uint8_t *typeck_std_heap_alloc(size_t size);
extern void typeck_std_heap_free(uint8_t *ptr);

uint8_t *std_heap_alloc(size_t size) {
  return typeck_std_heap_alloc(size);
}

/** lsp_io.sx / pipeline 引用 libc 风格 IO 符号；seed 链 read/write 转发。 */
ptrdiff_t io_read(int fd, uint8_t *buf, size_t count, unsigned timeout_ms) {
  ssize_t n;
  (void)timeout_ms;
  if (!buf || count == 0)
    return 0;
  n = read(fd, buf, count);
  return n >= 0 ? (ptrdiff_t)n : -1;
}

ptrdiff_t io_write(int fd, uint8_t *buf, size_t count, unsigned timeout_ms) {
  ssize_t n;
  (void)timeout_ms;
  if (!buf || count == 0)
    return 0;
  n = write(fd, buf, count);
  return n >= 0 ? (ptrdiff_t)n : -1;
}

ptrdiff_t io_read_batch_buf(int fd, const void *bufs, int n, unsigned timeout_ms) {
  (void)fd;
  (void)bufs;
  (void)n;
  (void)timeout_ms;
  return -1;
}

ptrdiff_t io_write_batch_buf(int fd, const void *bufs, int n, unsigned timeout_ms) {
  (void)fd;
  (void)bufs;
  (void)n;
  (void)timeout_ms;
  return -1;
}
