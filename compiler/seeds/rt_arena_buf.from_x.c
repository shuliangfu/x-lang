/* seeds/rt_arena_buf.from_x.c — G-02f-309 P2 runtime rest (static arena/module buf)
 * Logic source: src/runtime/rt_arena_buf.x
 * Hybrid: SHUX_RT_ARENA_BUF_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * Scope: driver_arena_buf / driver_module_buf + 静态 BSS（避免 emit 栈上超大数组）。
 * 🔒 大静态缓冲留 seed/slice；num_types 清零依赖 pipeline_arena_offset_num_types。
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

/** arena 对应 .x codegen `struct ast_ASTArena`，须 ≥ pipeline_sizeof_arena()；
 * 池扩大后宿主约 ~90MiB，预留 128MiB 避免静默越界。 */
#define DRIVER_ARENA_STATIC_SIZE (128 * 1024 * 1024)
#define DRIVER_MODULE_STATIC_SIZE (2 * 1024 * 1024)

static uint8_t driver_arena_static[DRIVER_ARENA_STATIC_SIZE];
static uint8_t driver_module_static[DRIVER_MODULE_STATIC_SIZE];

extern size_t pipeline_arena_offset_num_types(void);

uint8_t *driver_arena_buf(void) {
  memset(driver_arena_static, 0, DRIVER_ARENA_STATIC_SIZE);
  /* 强制 num_types=0，避免与 .x 生成 struct 布局/对齐不一致时 type_alloc 读到未清零值 */
  size_t off = pipeline_arena_offset_num_types();
  if (off + sizeof(int32_t) <= DRIVER_ARENA_STATIC_SIZE) {
    *(int32_t *)(driver_arena_static + off) = 0;
    (void)off;
  }
  return driver_arena_static;
}

uint8_t *driver_module_buf(void) {
  memset(driver_module_static, 0, DRIVER_MODULE_STATIC_SIZE);
  return driver_module_static;
}

int labi_rt_arena_buf_slice_marker(void) {
  return 1;
}
