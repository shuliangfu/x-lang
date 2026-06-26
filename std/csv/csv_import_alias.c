/**
 * csv_import_alias.c — import binding `-o` 链接桩
 *
 * csv.sx 已导出 std_csv_next_field 等；mod.sx 的 escape 未 co-emit，本 TU 提供 std_csv_escape。
 * next_field / unescape 在 shux-c 编译 csv.sx 产物中引号字段与输出参数有缺陷，此处 C 直实现。
 */
#include <stdint.h>

/** 从 offset 起找下一 CSV 字段（RFC 4180）；语义对齐 csv.sx csv_next_field_c。 */
int32_t std_csv_next_field(uint8_t *ptr, int32_t len, int32_t offset, int32_t *out_start, int32_t *out_len) {
  int32_t start;
  int32_t pos;
  if (!ptr || len < 0 || offset < 0 || !out_start || !out_len) {
    if (offset >= 0 && offset <= len)
      return offset;
    return len;
  }
  if (offset >= len) {
    *out_start = len;
    *out_len = 0;
    return len;
  }
  /** 引号字段 */
  if (ptr[offset] == 34) {
    start = offset + 1;
    pos = start;
    while (pos < len) {
      if (ptr[pos] == 34) {
        if (pos + 1 < len && ptr[pos + 1] == 34)
          pos += 2;
        else
          break;
      } else {
        pos++;
      }
    }
    *out_start = start;
    *out_len = pos - start;
    offset = pos + 1;
    if (offset < len && (ptr[offset] == 44 || ptr[offset] == 10 || ptr[offset] == 13)) {
      if (ptr[offset] == 44) {
        offset++;
      } else if (ptr[offset] == 13) {
        offset++;
        if (offset < len && ptr[offset] == 10)
          offset++;
      } else {
        offset++;
      }
    }
    return offset;
  }
  *out_start = offset;
  while (offset < len && ptr[offset] != 44 && ptr[offset] != 10 && ptr[offset] != 13)
    offset++;
  *out_len = offset - *out_start;
  if (offset < len) {
    if (ptr[offset] == 44) {
      offset++;
    } else if (ptr[offset] == 13) {
      offset++;
      if (offset < len && ptr[offset] == 10)
        offset++;
    } else if (ptr[offset] == 10) {
      offset++;
    }
  }
  return offset;
}

/** 引号字段 raw 内容 unescape（"" → "）；语义对齐 csv.sx std_csv_unescape。 */
int32_t std_csv_unescape(uint8_t *ptr, int32_t len, uint8_t *buf, int32_t buf_cap) {
  int32_t i = 0;
  int32_t j = 0;
  if (!ptr || !buf || buf_cap < 0)
    return -1;
  while (j < len) {
    if (ptr[j] == 34 && j + 1 < len && ptr[j + 1] == 34) {
      if (i >= buf_cap)
        return -1;
      buf[i] = 34;
      i++;
      j += 2;
    } else {
      if (i >= buf_cap)
        return -1;
      buf[i] = ptr[j];
      i++;
      j++;
    }
  }
  return i;
}

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
