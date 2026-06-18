/**
 * std/tar/tar.c — tar 归档 UStar 头读写（P4 可选；对标 Zig std.tar、Rust tar crate）
 *
 * 【文件职责】read_header/write_header：512 字节 UStar 头，name/size/typeflag/checksum；不处理长名（prefix）。
 * 【所属模块/组件】标准库 std.tar；与 std/tar/mod.su 同属一模块。
 */

#include <stdint.h>
#include <string.h>

#define TAR_HEADER_SIZE 512
#define TAR_NAME_OFF    0
#define TAR_NAME_LEN    100
#define TAR_SIZE_OFF    124
#define TAR_SIZE_LEN    12
#define TAR_CHKSUM_OFF  148
#define TAR_CHKSUM_LEN  8
#define TAR_TYPEFLAG_OFF 156
#define TAR_MAGIC_OFF   257
#define TAR_VERSION_OFF 263

/** 将 12 字节八进制字符串解析为非负整数（可含前导空格）；失败返回 -1。 */
static int64_t parse_octal_12(const uint8_t *p) {
  int i = 0;
  while (i < TAR_SIZE_LEN && (p[i] == ' ' || p[i] == 0)) i++;
  int64_t v = 0;
  for (; i < TAR_SIZE_LEN; i++) {
    if (p[i] == 0 || p[i] == ' ') break;
    if (p[i] < '0' || p[i] > '7') return -1;
    v = v * 8 + (p[i] - '0');
  }
  return v;
}

/** 将 size 写成 12 字节八进制（右对齐，前导空格），不写 NUL。 */
static void write_octal_12(uint8_t *p, int64_t size) {
  if (size < 0) size = 0;
  int i = TAR_SIZE_LEN - 1;
  for (; i >= 0; i--) {
    p[i] = (uint8_t)('0' + (size % 8));
    size /= 8;
    if (size == 0) break;
  }
  while (i > 0) { i--; p[i] = ' '; }
}

/**
 * 从 buf 读取 UStar 头（至少 512 字节）：写入 name_out（最多 name_cap-1 字节 + NUL），*size_out 为文件大小；返回 0 成功，-1 失败。
 */
int32_t tar_read_header_c(const uint8_t *buf, int32_t len, uint8_t *name_out, int32_t name_cap, int32_t *size_out) {
  if (!buf || len < TAR_HEADER_SIZE || !name_out || name_cap <= 0 || !size_out) return -1;
  if (buf[TAR_MAGIC_OFF] != 'u' || buf[TAR_MAGIC_OFF+1] != 's' || buf[TAR_MAGIC_OFF+2] != 't' ||
      buf[TAR_MAGIC_OFF+3] != 'a' || buf[TAR_MAGIC_OFF+4] != 'r' || buf[TAR_MAGIC_OFF+5] != 0)
    return -1;
  if (buf[TAR_VERSION_OFF] != '0' || buf[TAR_VERSION_OFF+1] != '0') return -1;

  /* 校验和：头 512 字节之和，148-156 按空格算；存的是 6 位八进制 + NUL + 空格 */
  uint32_t sum = 0;
  for (int i = 0; i < TAR_HEADER_SIZE; i++) {
    if (i >= TAR_CHKSUM_OFF && i < TAR_CHKSUM_OFF + TAR_CHKSUM_LEN)
      sum += (uint8_t)' ';
    else
      sum += buf[i];
  }
  uint32_t stored_chk = 0;
  for (int i = 0; i < 6 && TAR_CHKSUM_OFF + i < len; i++) {
    if (buf[TAR_CHKSUM_OFF + i] >= '0' && buf[TAR_CHKSUM_OFF + i] <= '7')
      stored_chk = stored_chk * 8 + (buf[TAR_CHKSUM_OFF + i] - '0');
  }
  if (stored_chk != sum) return -1;

  int32_t name_len = 0;
  while (name_len < TAR_NAME_LEN && buf[TAR_NAME_OFF + name_len] != 0) name_len++;
  if (name_len >= name_cap) name_len = name_cap - 1;
  memcpy(name_out, buf + TAR_NAME_OFF, (size_t)name_len);
  name_out[name_len] = '\0';

  int64_t sz = parse_octal_12(buf + TAR_SIZE_OFF);
  if (sz < 0 || sz > 0x7FFFFFFF) return -1;
  *size_out = (int32_t)sz;
  return 0;
}

/**
 * 向 buf 写入 512 字节 UStar 头：name（最多 100 字节）、file_size；typeflag='0'（普通文件）。返回 0 成功，-1 失败。
 */
int32_t tar_write_header_c(uint8_t *buf, int32_t buf_cap, const uint8_t *name, int32_t name_len, int32_t file_size) {
  if (!buf || buf_cap < TAR_HEADER_SIZE || !name || name_len < 0) return -1;
  if (name_len > TAR_NAME_LEN) name_len = TAR_NAME_LEN;

  memset(buf, 0, (size_t)TAR_HEADER_SIZE);
  memcpy(buf + TAR_NAME_OFF, name, (size_t)name_len);
  write_octal_12(buf + TAR_SIZE_OFF, (int64_t)file_size);
  buf[TAR_TYPEFLAG_OFF] = '0';
  memcpy(buf + TAR_MAGIC_OFF, "ustar", 5);
  buf[TAR_MAGIC_OFF + 5] = 0;
  buf[TAR_VERSION_OFF] = '0';
  buf[TAR_VERSION_OFF + 1] = '0';

  /* mode/uid/gid/mtime 可留 0；checksum 最后写 */
  uint32_t sum = 0;
  for (int i = 0; i < TAR_HEADER_SIZE; i++) {
    if (i >= TAR_CHKSUM_OFF && i < TAR_CHKSUM_OFF + TAR_CHKSUM_LEN)
      sum += (uint8_t)' ';
    else
      sum += buf[i];
  }
  /* 6 位八进制 MSB 先：digit_i = (sum/8^(5-i))%8，即 sum/8^5, sum/8^4, ..., sum/8, sum%8 */
  buf[TAR_CHKSUM_OFF + 0] = (uint8_t)('0' + (sum / 0100000 % 8));  /* 8^5 */
  buf[TAR_CHKSUM_OFF + 1] = (uint8_t)('0' + (sum / 010000 % 8));  /* 8^4 */
  buf[TAR_CHKSUM_OFF + 2] = (uint8_t)('0' + (sum / 01000 % 8));   /* 8^3 */
  buf[TAR_CHKSUM_OFF + 3] = (uint8_t)('0' + (sum / 0100 % 8));    /* 8^2 */
  buf[TAR_CHKSUM_OFF + 4] = (uint8_t)('0' + (sum / 010 % 8));     /* 8^1 */
  buf[TAR_CHKSUM_OFF + 5] = (uint8_t)('0' + (sum % 8));           /* 8^0 */
  buf[TAR_CHKSUM_OFF + 6] = 0;
  buf[TAR_CHKSUM_OFF + 7] = ' ';
  return 0;
}

/** UStar 512 字节块对齐。 */
static int32_t tar_pad512(int32_t n) {
  int32_t r = n % 512;
  if (r == 0) return 0;
  return 512 - r;
}

/**
 * 向归档缓冲追加一条 UStar 条目；is_dir=1 写目录（typeflag '5'），否则普通文件。
 * 更新 *off_io；成功 0，失败 -1。
 */
int32_t tar_append_entry_c(uint8_t *buf, int32_t buf_cap, int32_t *off_io, const uint8_t *name,
                            int32_t name_len, const uint8_t *data, int32_t data_len, int32_t is_dir) {
  int32_t off;
  int32_t file_size;
  int32_t pad;
  if (!buf || !off_io || !name || name_len < 0)
    return -1;
  off = *off_io;
  if (off + 512 > buf_cap)
    return -1;
  file_size = is_dir ? 0 : data_len;
  if (tar_write_header_c(buf + off, buf_cap - off, name, name_len, file_size) != 0)
    return -1;
  if (is_dir)
    buf[off + TAR_TYPEFLAG_OFF] = '5';
  off += 512;
  if (!is_dir && data_len > 0) {
    if (!data || off + data_len > buf_cap)
      return -1;
    memcpy(buf + off, data, (size_t)data_len);
    off += data_len;
    pad = tar_pad512(data_len);
    if (off + pad > buf_cap)
      return -1;
    memset(buf + off, 0, (size_t)pad);
    off += pad;
  }
  *off_io = off;
  return 0;
}

/**
 * 遍历下一条 tar 条目；成功 0，归档结束 1，错误 -1。
 * type_out 为 typeflag 字节值（'0'=48 文件，'5'=53 目录）。
 */
int32_t tar_next_entry_c(const uint8_t *buf, int32_t buf_len, int32_t *pos_io, uint8_t *name_out,
                         int32_t name_cap, int32_t *size_out, int32_t *type_out) {
  int32_t pos;
  int32_t sz;
  int32_t blocks;
  int32_t i;
  int32_t all_zero;
  if (!buf || !pos_io || !name_out || name_cap <= 0)
    return -1;
  pos = *pos_io;
  if (pos + 512 > buf_len)
    return 1;
  all_zero = 1;
  for (i = 0; i < 512; i++) {
    if (buf[pos + i] != 0) {
      all_zero = 0;
      break;
    }
  }
  if (all_zero)
    return 1;
  sz = 0;
  if (tar_read_header_c(buf + pos, buf_len - pos, name_out, name_cap, &sz) != 0)
    return -1;
  if (type_out)
    *type_out = (int32_t)buf[pos + TAR_TYPEFLAG_OFF];
  if (size_out)
    *size_out = sz;
  pos += 512;
  blocks = (sz + 511) / 512;
  pos += blocks * 512;
  *pos_io = pos;
  return 0;
}

/** 从 entry_off（头起始）读取文件数据到 out；返回字节数，失败 -1。 */
int32_t tar_read_entry_data_c(const uint8_t *buf, int32_t buf_len, int32_t entry_off, uint8_t *out,
                              int32_t out_cap) {
  int32_t sz;
  int32_t data_off;
  int32_t n;
  uint8_t nm[4];
  if (!buf || !out || entry_off < 0 || entry_off + 512 > buf_len)
    return -1;
  sz = 0;
  if (tar_read_header_c(buf + entry_off, buf_len - entry_off, nm, 4, &sz) != 0)
    return -1;
  if (sz <= 0)
    return 0;
  data_off = entry_off + 512;
  if (data_off + sz > buf_len)
    return -1;
  n = sz;
  if (n > out_cap)
    n = out_cap;
  memcpy(out, buf + data_off, (size_t)n);
  return n;
}
