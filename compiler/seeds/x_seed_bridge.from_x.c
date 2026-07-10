/* seeds/x_seed_bridge.from_x.c — G-02f-11 product TU
 * Product object from this seed; logic still C until full .x port.
 */
/**
 * x_seed_bridge.c — bootstrap-driver-seed 分 TU 链接桥：preprocess 名前缀、asm 桩、ast 辅助、heap 桩、io 底层桩。
 *
 * G-02e-9：原 bootstrap_seed_io_stubs.c 并入本 TU。
 *
 * pipeline_x.o / parser_x.o / typeck_x.o / codegen_x.o 经 -E-extern 分模块后，
 * runtime / driver / lsp 仍引用 C 路径或 import 前缀符号；本文件补齐 seed 链缺口。
 */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#ifndef _WIN32
#include <unistd.h>
#endif
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

/** parser.x parse_match 查 enum tag 时的当前 Module（parse_into 入口设置）。 */
static struct ast_Module *g_parser_match_module_x;

void pipeline_parser_set_match_module(struct ast_Module *m) {
  g_parser_match_module_x = m;
}

struct ast_Module *pipeline_parser_get_match_module(void) {
  return g_parser_match_module_x;
}

extern struct ast_Expr ast_arena_expr_get(struct ast_ASTArena *a, int32_t ref);
extern void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);

/** preprocess_x.o 当前导出 preprocess_x_buf；seed 链上补 typeck_ 名兼容覆盖弱桩。 */
extern int32_t preprocess_x_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf, int32_t out_cap);

int32_t typeck_preprocess_x_buf(const uint8_t *src, ptrdiff_t src_len, uint8_t *out_buf, int32_t out_cap) {
  return preprocess_x_buf(src, src_len, out_buf, out_cap);
}

/** asm 入口由 user_asm_seed_bridge.o + build_asm/seed_host 提供；须 make build-seed-asm-host。 */

/** parser.x 生成体引用；初始化 match 相关字段。verify-selfhost-stage2 链 ast_x2.o 时由 ast.x 导出，勿重复定义。 */
#ifndef X_VERIFY_STAGE2
void ast_expr_init_match_enum(struct ast_Expr *e) {
  if (!e)
    return;
  e->match_matched_ref = 0;
  e->match_arm_base = 0;
  e->match_num_arms = 0;
}
#endif

/** typeck/codegen 生成体引用；重置 call resolve 字段。Stage2 由 ast_x2.o 提供。 */
#ifndef X_VERIFY_STAGE2
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

/** parser/lsp 生成体历史上并存 alloc_zero/alloc_zeroed 两个符号名；seed 链统一回到 calloc。 */
void *std_heap_alloc_zeroed(size_t size) {
  return calloc(1, size);
}

void *std_heap_alloc_zero(size_t size) {
  return std_heap_alloc_zeroed(size);
}

void std_heap_free(void *ptr) {
  free(ptr);
}

/** lsp_io_std_heap.x 导出 typeck_*；lsp_diag_x 链接 std_heap_* 裸名。 */
extern uint8_t *typeck_std_heap_alloc(size_t size);
extern void typeck_std_heap_free(uint8_t *ptr);

uint8_t *std_heap_alloc(size_t size) {
  return typeck_std_heap_alloc(size);
}

/** lsp_io.x / pipeline 引用 libc 风格 IO 符号；seed 链 read/write 转发。 */
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

/* ---- G-02e-9：原 bootstrap_seed_io_stubs（lsp_gen / driver io 底层桩）---- */

/** stdin 指针读桩：无缓冲时返回 NULL。 */
uint8_t *io_read_ptr(unsigned handle, unsigned timeout_ms) {
  (void)handle;
  (void)timeout_ms;
  return NULL;
}

/** 与 io_read_ptr 配套的可用长度桩。 */
int32_t io_read_ptr_len(void) {
  return 0;
}

/** lsp_gen / driver 缓冲 ABI：与 runtime.c shu_buffer_abi_t 布局一致。 */
typedef struct {
  uint8_t *ptr;
  size_t len;
  size_t handle;
} shu_buffer_abi_t;

/** std.io.core 注册单缓冲桩。 */
int32_t io_register_buffer(uint8_t *ptr, size_t len) {
  (void)ptr;
  (void)len;
  return 0;
}

/** 四缓冲注册桩。 */
int32_t io_register_buffers_4(uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2,
                              uint8_t *p3, size_t l3, uint32_t nr) {
  (void)p0;
  (void)l0;
  (void)p1;
  (void)l1;
  (void)p2;
  (void)l2;
  (void)p3;
  (void)l3;
  (void)nr;
  return 0;
}

/** 撤销已注册缓冲（桩 no-op）。 */
void io_unregister_buffers(void) {
}

/** 固定缓冲读桩。 */
ptrdiff_t io_read_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, unsigned timeout_ms) {
  (void)buf_index;
  (void)offset;
  return io_read(fd, NULL, len, timeout_ms);
}

/** 固定缓冲写桩。 */
ptrdiff_t io_write_fixed(int32_t fd, uint32_t buf_index, size_t offset, size_t len, unsigned timeout_ms) {
  (void)buf_index;
  (void)offset;
  return io_write(fd, NULL, len, timeout_ms);
}

/** poll/select 可读桩：bootstrap 冷路径返回 0。 */
int32_t io_wait_readable(int32_t *fds, int32_t n, unsigned timeout_ms) {
  (void)fds;
  (void)n;
  (void)timeout_ms;
  return 0;
}

/** 批量读桩：退化为单次 io_read。 */
ptrdiff_t io_read_batch(int32_t fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2,
                        uint8_t *p3, size_t l3, int32_t n, unsigned timeout_ms) {
  (void)p1;
  (void)l1;
  (void)p2;
  (void)l2;
  (void)p3;
  (void)l3;
  (void)n;
  return io_read(fd, p0, l0, timeout_ms);
}

/** 批量写桩：退化为单次 io_write。 */
ptrdiff_t io_write_batch(int32_t fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2,
                         uint8_t *p3, size_t l3, int32_t n, unsigned timeout_ms) {
  (void)p1;
  (void)l1;
  (void)p2;
  (void)l2;
  (void)p3;
  (void)l3;
  (void)n;
  return io_write(fd, p0, l0, timeout_ms);
}

/** driver.Buffer 批注册桩。 */
int32_t io_register_buffers_buf(void *bufs, int32_t nr) {
  (void)bufs;
  (void)nr;
  return 0;
}

/** codegen 生成的 i32 入口名。 */
int32_t io_register_buffers_buf_i32(intptr_t bufs, int nr) {
  return io_register_buffers_buf((void *)(uintptr_t)bufs, nr);
}

/** std.io.core 三参注册。 */
int32_t shux_io_register(uint8_t *ptr, size_t len, size_t handle) {
  (void)handle;
  return io_register_buffer(ptr, len);
}

/** driver 侧 Buffer 描述符注册。 */
int32_t shux_io_register_buf(intptr_t buf) {
  const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf;
  if (!b)
    return -1;
  return shux_io_register(b->ptr, b->len, b->handle);
}

/** 异步读提交桩。 */
int32_t shux_io_submit_read(uint8_t *ptr, size_t len, size_t handle, unsigned timeout_ms) {
  int32_t fd = (int32_t)handle;
  ptrdiff_t r = io_read(fd, ptr, len, timeout_ms);
  if (r < 0)
    return -1;
  return (int32_t)r;
}

int32_t shux_io_submit_read_buf(intptr_t buf, int32_t timeout_ms) {
  const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf;
  if (!b)
    return -1;
  return shux_io_submit_read(b->ptr, b->len, b->handle, (unsigned)timeout_ms);
}

/** 异步写提交桩。 */
int32_t shux_io_submit_write(uint8_t *ptr, size_t len, size_t handle, unsigned timeout_ms) {
  int32_t fd = (int32_t)handle;
  ptrdiff_t r = io_write(fd, ptr, len, timeout_ms);
  if (r < 0)
    return -1;
  return (int32_t)r;
}

int32_t shux_io_submit_write_buf(intptr_t buf, int32_t timeout_ms) {
  const shu_buffer_abi_t *b = (const shu_buffer_abi_t *)(uintptr_t)buf;
  if (!b)
    return -1;
  return shux_io_submit_write(b->ptr, b->len, b->handle, (unsigned)timeout_ms);
}

/** lsp_gen 引用 driver_read_ptr*；真 partial 无 phase1 弱桩时兜底。 */
__attribute__((weak)) uint8_t *std_io_driver_driver_read_ptr(size_t handle, unsigned timeout_ms) {
  (void)handle;
  (void)timeout_ms;
  return NULL;
}

__attribute__((weak)) int32_t std_io_driver_driver_read_ptr_len(void) {
  return 0;
}
