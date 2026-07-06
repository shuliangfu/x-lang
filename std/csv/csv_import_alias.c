/**
 * csv_import_alias.c — import binding `-o` 链接桩
 *
 * csv.x 已导出 std_csv_next_field / std_csv_unescape；
 * mod.x 的 escape 被 co-emit 为强符号 std_csv_escape；
 * 本 TU 的 std_csv_escape 为 weak fallback，仅当 co-emit 未发生时生效。
 */
#include <stdint.h>

/**
 * 将字段转义为带引号的 CSV 单元；返回写入长度，失败 -1。
 * 【Why】mod.x 的 escape 已被 co-emit 为强符号 std_csv_escape；本 weak 定义仅当
 *        co-emit 未发生（csv.o 脱离入口模块单独使用）时作为 fallback 生效。
 * 【Invariant】与 mod.x escape 实现保持一致（简化版，无引号双写）。
 */
__attribute__((weak)) int32_t std_csv_escape(uint8_t *ptr, int32_t len, uint8_t *buf, int32_t buf_cap) {
  int32_t i = 0;
  int32_t j = 0;
  if (!buf || buf_cap < 2)
    return -1;
  buf[i] = 34;
  i++;
  if (i + len + 1 >= buf_cap)
    return -1;
  while (j < len) {
    buf[i] = ptr[j];
    i++;
    j++;
  }
  if (i >= buf_cap - 1)
    return -1;
  buf[i] = 34;
  i++;
  return i;
}
