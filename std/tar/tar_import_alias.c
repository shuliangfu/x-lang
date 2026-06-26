/**
 * tar_import_alias.c — import binding `-o` 链接桩 + UStar 最小实现
 *
 * asm co-emit 对 `const tar = import("std.tar")` 生成 std_tar_* 符号；
 * tar.sx 仅为锚点桩（返回 -1）。本 TU 提供 std_tar_* 及 tar_*_c 的 C 直实现（UStar 512B 头）。
 */
#include <stdint.h>
#include <string.h>

static int32_t tar_octal_write(uint8_t *dst, int32_t cap, uint32_t val) {
  char tmp[16];
  int32_t i = 0;
  int32_t j;
  int32_t pos;
  if (!dst || cap <= 0)
    return -1;
  for (j = 0; j < cap; j++)
    dst[j] = '0';
  if (val == 0)
    return 0;
  while (val > 0 && i < cap - 1) {
    tmp[i++] = (char)('0' + (val % 8u));
    val /= 8u;
  }
  pos = cap - 2;
  while (i > 0 && pos >= 0) {
    dst[pos] = (uint8_t)tmp[--i];
    pos--;
  }
  return 0;
}

static uint32_t tar_octal_read(const uint8_t *src, int32_t n) {
  uint32_t v = 0;
  int32_t i = 0;
  if (!src || n <= 0)
    return 0;
  while (i < n && src[i] != 0) {
    if (src[i] < '0' || src[i] > '7')
      break;
    v = v * 8u + (uint32_t)(src[i] - '0');
    i++;
  }
  return v;
}

static void tar_header_checksum(uint8_t *hdr) {
  uint32_t sum = 0;
  int32_t i;
  for (i = 0; i < 512; i++)
    sum += hdr[i];
  tar_octal_write(hdr + 148, 8, sum);
}

/** 写 UStar 头；C 直实现。 */
int32_t tar_write_header_c(uint8_t *buf, int32_t buf_cap, uint8_t *name, int32_t name_len,
                           int32_t file_size) {
  int32_t i;
  if (!buf || buf_cap < 512 || !name || name_len < 0)
    return -1;
  memset(buf, 0, 512);
  if (name_len > 100)
    name_len = 100;
  for (i = 0; i < name_len; i++)
    buf[i] = name[i];
  tar_octal_write(buf + 124, 12, (uint32_t)file_size);
  tar_octal_write(buf + 136, 12, 0);
  memset(buf + 148, ' ', 8);
  buf[156] = '0';
  memcpy(buf + 257, "ustar\0", 6);
  memcpy(buf + 263, "00", 2);
  tar_header_checksum(buf);
  return 0;
}

/** 读 UStar 头；C 直实现。 */
int32_t tar_read_header_c(uint8_t *buf, int32_t len, uint8_t *name_out, int32_t name_cap,
                          int32_t *size_out) {
  int32_t i;
  if (!buf || len < 512 || !name_out || name_cap <= 0 || !size_out)
    return -1;
  if (name_cap > 100)
    name_cap = 100;
  for (i = 0; i < name_cap; i++) {
    name_out[i] = buf[i];
    if (buf[i] == 0)
      break;
  }
  if (i < name_cap)
    name_out[i] = 0;
  *size_out = (int32_t)tar_octal_read(buf + 124, 12);
  return 0;
}

int32_t tar_path_max_c(void) { return 512; }

int32_t tar_append_entry_c(uint8_t *buf, int32_t buf_cap, int32_t *off_io, uint8_t *name,
                           int32_t name_len, uint8_t *data, int32_t data_len, int32_t is_dir) {
  (void)buf;
  (void)buf_cap;
  (void)off_io;
  (void)name;
  (void)name_len;
  (void)data;
  (void)data_len;
  (void)is_dir;
  return -1;
}

int32_t tar_next_entry_c(uint8_t *buf, int32_t buf_len, int32_t *pos_io, uint8_t *name_out,
                         int32_t name_cap, int32_t *size_out, int32_t *type_out) {
  (void)buf;
  (void)buf_len;
  (void)pos_io;
  (void)name_out;
  (void)name_cap;
  (void)size_out;
  (void)type_out;
  return -1;
}

int32_t tar_read_entry_data_c(uint8_t *buf, int32_t buf_len, int32_t entry_off, uint8_t *out,
                              int32_t out_cap) {
  (void)buf;
  (void)buf_len;
  (void)entry_off;
  (void)out;
  (void)out_cap;
  return -1;
}

/** UStar 路径最大长度；转发 tar_path_max_c。 */
int32_t std_tar_path_max(void) { return tar_path_max_c(); }

/** 读 UStar 头；转发 tar_read_header_c。 */
int32_t std_tar_read_header(uint8_t *buf, int32_t len, uint8_t *name_out, int32_t name_cap,
                            int32_t *size_out) {
  return tar_read_header_c(buf, len, name_out, name_cap, size_out);
}

/** 写 UStar 头；转发 tar_write_header_c。 */
int32_t std_tar_write_header(uint8_t *buf, int32_t buf_cap, uint8_t *name, int32_t name_len,
                             int32_t file_size) {
  return tar_write_header_c(buf, buf_cap, name, name_len, file_size);
}

int32_t std_tar_append_entry(uint8_t *buf, int32_t buf_cap, int32_t *off_io, uint8_t *name,
                             int32_t name_len, uint8_t *data, int32_t data_len, int32_t is_dir) {
  return tar_append_entry_c(buf, buf_cap, off_io, name, name_len, data, data_len, is_dir);
}

int32_t std_tar_next_entry(uint8_t *buf, int32_t buf_len, int32_t *pos_io, uint8_t *name_out,
                           int32_t name_cap, int32_t *size_out, int32_t *type_out) {
  return tar_next_entry_c(buf, buf_len, pos_io, name_out, name_cap, size_out, type_out);
}

int32_t std_tar_read_entry_data(uint8_t *buf, int32_t buf_len, int32_t entry_off, uint8_t *out,
                                int32_t out_cap) {
  return tar_read_entry_data_c(buf, buf_len, entry_off, out, out_cap);
}
