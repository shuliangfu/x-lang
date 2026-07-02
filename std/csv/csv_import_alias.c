/**
 * csv_import_alias.c — import binding `-o` 链接桩
 *
 * csv.sx 已导出 std_csv_next_field / std_csv_unescape；
 * mod.sx 的 escape 仍未 co-emit，本 TU 仅保留 std_csv_escape 补位。
 */
#include <stdint.h>

/** 将字段转义为带引号的 CSV 单元；返回写入长度，失败 -1。 */
int32_t std_csv_escape(uint8_t *ptr, int32_t len, uint8_t *buf, int32_t buf_cap) {
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
