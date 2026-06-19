/**
 * std/csv/csv.c — CSV 按行解析与写回（P4 可选）
 *
 * 【文件职责】next_field：在 ptr[0..len] 内找下一字段（逗号或换行分隔），写回 start 与 field_len；escape：引号包裹并转义。
 *
 * 【所属模块/组件】标准库 std.csv；依赖 std.string、std.io；与 std/csv/mod.sx 同属一模块。
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/**
 * 从 offset 起找下一字段（RFC 4180）。
 * - 若以 " 开头：字段到下一个未转义的 " 结束，内部 "" 表示一个 "，可含逗号与换行。
 * - 否则：到逗号或 \\n 或 \\r\\n 结束。
 * *out_start=字段内容起始，*out_len=内容长度（引号内为 raw，含 "" 两字节）；返回下一 offset。
 */
int32_t csv_next_field_c(const uint8_t *ptr, int32_t len, int32_t offset, int32_t *out_start, int32_t *out_len) {
  if (!ptr || len < 0 || offset < 0 || !out_start || !out_len) return offset >= 0 && offset <= len ? offset : len;
  if (offset >= len) { *out_start = len; *out_len = 0; return len; }

  /* RFC 4180 引号字段：以 " 开始，到未转义 " 结束，"" 为转义引号 */
  if (ptr[offset] == '"') {
    int32_t start = offset + 1;
    int32_t pos = start;
    while (pos < len) {
      if (ptr[pos] == '"') {
        if (pos + 1 < len && ptr[pos + 1] == '"') { pos += 2; continue; }
        break;
      }
      pos++;
    }
    *out_start = start;
    *out_len = pos - start;
    offset = pos + 1;
    if (offset < len && (ptr[offset] == ',' || ptr[offset] == '\n' || ptr[offset] == '\r')) {
      if (ptr[offset] == ',') offset++;
      else if (ptr[offset] == '\r') { offset++; if (offset < len && ptr[offset] == '\n') offset++; }
      else offset++;
    }
    return offset;
  }

  *out_start = offset;
  while (offset < len && ptr[offset] != ',' && ptr[offset] != '\n' && ptr[offset] != '\r') offset++;
  *out_len = offset - *out_start;
  if (offset < len) {
    if (ptr[offset] == ',') offset++;
    else if (ptr[offset] == '\r') { offset++; if (offset < len && ptr[offset] == '\n') offset++; }
    else if (ptr[offset] == '\n') offset++;
  }
  return offset;
}

/**
 * Shux std.csv.next_field（_std_csv_next_field）：由 csv.o 提供实现。
 * seed asm 对同模块五实参 bl 会错传 out_len；.sx 侧仅 extern 声明，链接本符号。
 */
int32_t std_csv_next_field(const uint8_t *ptr, int32_t len, int32_t offset, int32_t *out_start,
                           int32_t *out_len) {
  return csv_next_field_c(ptr, len, offset, out_start, out_len);
}

/** tests/csv 引号字段探针（C 栈上缓冲，规避 seed asm 第三段定长数组 &quoted[0] 错址）。 */
int32_t std_csv_csv_test_quoted_first(int32_t *out_start, int32_t *out_len) {
  const uint8_t q[] = {34, 97, 44, 98, 34, 44, 99, 0};
  return csv_next_field_c(q, 8, 0, out_start, out_len);
}

int32_t std_csv_csv_test_quoted_second(int32_t offset, int32_t *out_start, int32_t *out_len) {
  const uint8_t q[] = {34, 97, 44, 98, 34, 44, 99, 0};
  return csv_next_field_c(q, 8, offset, out_start, out_len);
}

/** 将 ptr[0..len] 转义写入 buf（含引号、内部 " 双写）；最多写 buf_cap 字节。返回写入长度，不足返回 -1。 */
int32_t csv_escape_c(const uint8_t *ptr, int32_t len, uint8_t *buf, int32_t buf_cap) {
  if (!ptr || !buf || buf_cap < 2) return -1;
  int32_t i = 0;
  buf[i++] = '"';
  for (int32_t j = 0; j < len && i < buf_cap - 1; j++) {
    if (ptr[j] == '"') { if (i + 2 > buf_cap) return -1; buf[i++] = '"'; buf[i++] = '"'; }
    else buf[i++] = ptr[j];
  }
  if (i >= buf_cap - 1) return -1;
  buf[i++] = '"';
  return i;
}

/** 将 RFC 4180 引号字段的 raw 内容（"" → "）写入 buf，返回写入长度，不足返回 -1。 */
int32_t csv_unescape_c(const uint8_t *ptr, int32_t len, uint8_t *buf, int32_t buf_cap) {
  if (!ptr || !buf || buf_cap < 0) return -1;
  int32_t i = 0;
  for (int32_t j = 0; j < len; j++) {
    if (ptr[j] == '"' && j + 1 < len && ptr[j + 1] == '"') { if (i >= buf_cap) return -1; buf[i++] = '"'; j++; }
    else { if (i >= buf_cap) return -1; buf[i++] = ptr[j]; }
  }
  return i;
}

/** Shux std.csv.unescape：由 csv.o 提供（seed asm 在 3+ 定长数组函数内 while+else 可能死循环）。 */
int32_t std_csv_unescape(const uint8_t *ptr, int32_t len, uint8_t *buf, int32_t buf_cap) {
  return csv_unescape_c(ptr, len, buf, buf_cap);
}

/** tests/csv：""a 探针，返回写入长度；-1 表示缓冲不足。 */
int32_t std_csv_csv_test_unescape_ok(uint8_t *buf, int32_t buf_cap) {
  const uint8_t raw[] = {34, 34, 97, 0};
  return csv_unescape_c(raw, 3, buf, buf_cap);
}

/** tests/csv：缓冲不足应返回 -1。 */
int32_t std_csv_csv_test_unescape_fail(void) {
  uint8_t tiny[1];
  const uint8_t raw[] = {34, 34, 97, 0};
  return csv_unescape_c(raw, 3, tiny, 1);
}

/**
 * import std.csv 裸名调用与 std_csv_* 的链接别名（codegen 未加模块前缀时由 csv.o 解析）。
 * 与 std/csv/mod.sx 中 extern 名称一致，实现仍由上方 std_csv_* 提供。
 */
int32_t next_field(const uint8_t *ptr, int32_t len, int32_t offset, int32_t *out_start,
                   int32_t *out_len) {
  return std_csv_next_field(ptr, len, offset, out_start, out_len);
}

int32_t csv_test_quoted_first(int32_t *out_start, int32_t *out_len) {
  return std_csv_csv_test_quoted_first(out_start, out_len);
}

int32_t csv_test_quoted_second(int32_t offset, int32_t *out_start, int32_t *out_len) {
  return std_csv_csv_test_quoted_second(offset, out_start, out_len);
}

int32_t csv_test_unescape_ok(uint8_t *buf, int32_t buf_cap) {
  return std_csv_csv_test_unescape_ok(buf, buf_cap);
}

int32_t csv_test_unescape_fail(void) {
  return std_csv_csv_test_unescape_fail();
}

/** 判断字段是否须 RFC 4180 引号包裹。 */
static int32_t csv_field_needs_quote(const uint8_t *ptr, int32_t len) {
  int32_t j;
  if (!ptr) return 0;
  for (j = 0; j < len; j++) {
    uint8_t c = ptr[j];
    if (c == ',' || c == '"' || c == '\n' || c == '\r') return 1;
  }
  return 0;
}

/** 解析一行 CSV；field_starts/lens 为绝对偏移；返回下一 offset 或 -1。 */
int32_t csv_parse_row_c(const uint8_t *ptr, int32_t len, int32_t offset, int32_t *field_starts,
                        int32_t *field_lens, int32_t max_fields, int32_t *out_count) {
  int32_t pos;
  if (!ptr || !field_starts || !field_lens || !out_count || max_fields <= 0) return -1;
  *out_count = 0;
  if (offset < 0 || offset > len) return -1;
  if (offset == len) return len;
  pos = offset;
  while (*out_count < max_fields && pos <= len) {
    int32_t start = 0;
    int32_t flen = 0;
    int32_t next = csv_next_field_c(ptr, len, pos, &start, &flen);
    field_starts[*out_count] = start;
    field_lens[*out_count] = flen;
    (*out_count)++;
    if (next >= len) return len;
    if (next > 0 && ptr[next - 1] == '\n') return next;
    if (next > 1 && ptr[next - 2] == '\r' && ptr[next - 1] == '\n') return next;
    pos = next;
  }
  return pos;
}

/** 将多列字段写入一行 CSV（无尾随换行）；返回写入字节数或 -1。 */
int32_t csv_write_row_c(const uint8_t *blob, const int32_t *starts, const int32_t *lens,
                        int32_t count, uint8_t *out, int32_t out_cap) {
  int32_t o = 0;
  int32_t i;
  if (!blob || !starts || !lens || !out || count < 0) return -1;
  for (i = 0; i < count; i++) {
    const uint8_t *fp = blob + starts[i];
    int32_t fl = lens[i];
    if (i > 0) {
      if (o >= out_cap) return -1;
      out[o++] = ',';
    }
    if (csv_field_needs_quote(fp, fl)) {
      int32_t ew = csv_escape_c(fp, fl, out + o, out_cap - o);
      if (ew < 0) return -1;
      o += ew;
    } else {
      if (o + fl > out_cap) return -1;
      memcpy(out + o, fp, (size_t)fl);
      o += fl;
    }
  }
  return o;
}

/** 链接别名：与 mod.sx / schema.c 裸名一致。 */
int32_t parse_row(const uint8_t *ptr, int32_t len, int32_t offset, int32_t *field_starts,
                  int32_t *field_lens, int32_t max_fields, int32_t *out_count) {
  return csv_parse_row_c(ptr, len, offset, field_starts, field_lens, max_fields, out_count);
}

int32_t write_row(const uint8_t *blob, const int32_t *starts, const int32_t *lens, int32_t count,
                  uint8_t *out, int32_t out_cap) {
  return csv_write_row_c(blob, starts, lens, count, out, out_cap);
}

/* --- STD-128：流式 writer / smoke --- */

/**
 * 向 out[out_len..) 追加一行 CSV 与换行；更新 *out_len。
 * 0 成功；-1 失败。
 */
int32_t csv_stream_writer_append_row_c(uint8_t *out, int32_t out_cap, int32_t *out_len,
                                       const uint8_t *blob, const int32_t *starts,
                                       const int32_t *lens, int32_t count) {
  int32_t n;
  int32_t left;
  if (!out || !out_len || !blob || !starts || !lens) return -1;
  if (*out_len < 0 || *out_len > out_cap) return -1;
  left = out_cap - *out_len;
  if (left <= 1) return -1;
  n = csv_write_row_c(blob, starts, lens, count, out + *out_len, left - 1);
  if (n < 0) return -1;
  *out_len += n;
  out[*out_len] = '\n';
  (*out_len)++;
  return 0;
}

/** 多行 reader/writer 往返烟测；0 通过。 */
int32_t csv_stream_smoke_c(void) {
  static uint8_t blob[16] = {'a', 'l', 'i', 'c', 'e', 'b', 'o', 'b', '1', '2', '3',
                             0, 0, 0, 0, 0};
  static int32_t starts1[] = {0, 5, 8};
  static int32_t lens1[] = {5, 3, 3};
  static int32_t starts2[] = {10, 11, 12};
  static int32_t lens2[] = {1, 0, 1};
  uint8_t out[128];
  int32_t out_len = 0;
  int32_t field_starts[4];
  int32_t field_lens[4];
  int32_t cnt = 0;
  int32_t off = 0;
  int32_t rc;
  if (csv_stream_writer_append_row_c(out, (int32_t)sizeof(out), &out_len, blob, starts1, lens1, 3) != 0)
    return 1;
  if (csv_stream_writer_append_row_c(out, (int32_t)sizeof(out), &out_len, blob, starts2, lens2, 3) != 0)
    return 2;
  if (out_len <= 0) return 3;
  rc = csv_parse_row_c(out, out_len, 0, field_starts, field_lens, 4, &cnt);
  if (rc < 0 || cnt != 3 || field_lens[0] != 5 || field_lens[1] != 3 || field_lens[2] != 3) return 4;
  off = rc;
  cnt = 0;
  rc = csv_parse_row_c(out, out_len, off, field_starts, field_lens, 4, &cnt);
  if (rc < 0 || cnt != 3 || field_lens[1] != 0) return 5;
  off = rc;
  cnt = 0;
  rc = csv_parse_row_c(out, out_len, off, field_starts, field_lens, 4, &cnt);
  if (rc < out_len || cnt != 0) return 6;
  return 0;
}
