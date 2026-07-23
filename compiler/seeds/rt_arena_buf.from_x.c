/* seeds/rt_arena_buf.from_x.c — G-02f-309 P2 runtime rest (static arena/module buf)
 * Logic source: src/runtime/rt_arena_buf.x
 * Hybrid: XLANG_RT_ARENA_BUF_FROM_X + ld -r into runtime_driver_no_c.o
 *
 * R2 full（2026-07-14）：driver_arena_buf / driver_module_buf 由 .x 提供；
 * FROM_X 下本文件：始终保留 BSS 数据（跨 TU 非 static；Cap-global-bss）+ 前向声明 + marker
 * （产品 rest 业务 T=0）。冷启动/无 PREFER 时仍编译完整 C 体。
 * Cap residual 槽函数在 runtime_driver_abi（平台层，供 .x 访问 BSS）。
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

/* Cap-global-bss residual：大数组必须非 static 跨 TU → 始终在 seed 定义
 * （.x export let 会编成 static，不能替代本块；driver_abi 槽 extern 本符号）。 */
uint8_t driver_arena_static[DRIVER_ARENA_STATIC_SIZE];
uint8_t driver_module_static[DRIVER_MODULE_STATIC_SIZE];

extern size_t pipeline_arena_offset_num_types(void);

#ifndef XLANG_RT_ARENA_BUF_FROM_X

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

#else
uint8_t *driver_arena_buf(void);
uint8_t *driver_module_buf(void);
#endif

int labi_rt_arena_buf_slice_marker(void) {
  return 1;
}
