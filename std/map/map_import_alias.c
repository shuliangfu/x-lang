/**
 * map_import_alias.c — import binding `-o` 链接桩
 *
 * asm co-emit 对 `const map = import("std.map")` 生成 std_map_* 符号；
 * mod.x 在自举 slice 下暂不能稳定 emit 为 .o。本 TU 提供 std_map_* 转发。
 */
#include <stdint.h>

/** empty_size 烟测锚点；与 mod.x 一致恒返回 0。 */
int32_t std_map_empty_size(void) {
  return 0;
}
