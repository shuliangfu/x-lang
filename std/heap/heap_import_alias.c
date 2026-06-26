/**
 * heap_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const heap = import("std.heap")` 生成 std_heap_* 符号；
 * mod.sx / heap_libc.sx 在自举 slice 下暂不能稳定 emit 为 .o。本 TU 提供
 * std_heap_* 转发（语义对齐 mod.sx / heap_libc.sx），供 run-set/run-heap 等 gate。
 */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/** 分配 count 个 i32；失败返回 null。 */
int32_t *std_heap_alloc_i32(int32_t count) {
  size_t n;
  if (count <= 0) {
    return (int32_t *)0;
  }
  n = (size_t)count;
  return (int32_t *)calloc(n, sizeof(int32_t));
}

/** 分配 count 个 u8；失败返回 null。 */
uint8_t *std_heap_alloc_u8(int32_t count) {
  size_t n;
  if (count <= 0) {
    return (uint8_t *)0;
  }
  n = (size_t)count;
  return (uint8_t *)calloc(n, sizeof(uint8_t));
}

/** 释放 std_heap_alloc_i32 分配的 ptr；ptr 可为 null。 */
void std_heap_free_i32(int32_t *ptr) {
  free((void *)ptr);
}

/** 释放 std_heap_alloc_u8 分配的 ptr；ptr 可为 null。 */
void std_heap_free_u8(uint8_t *ptr) {
  free((void *)ptr);
}

/** alloc_size_zero 烟测锚点；与 mod.sx 一致恒返回 0。 */
int32_t std_heap_alloc_size_zero(void) {
  return 0;
}
