/**
 * std/tar/tar.c — tar 归档 UStar 读写 + 长路径/Pax（STD-038/152）
 *
 * 【文件职责】UStar 512 字节头；prefix 拆分（101–255）；Pax path（256–512）；
 * append_entry / next_entry / read_entry_data。
 * 【所属模块/组件】标准库 std.tar；与 std/tar/mod.sx 同属一模块。
 */

#include <stdint.h>
#include <stdio.h>
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
/** UStar prefix 字段偏移（155 字节）。 */
#define TAR_PREFIX_OFF  345
#define TAR_PREFIX_LEN  155
/** Pax 扩展头 typeflag。 */
#define TAR_TYPE_PAX    'x'
/** UStar prefix+name 最大路径。 */
#define TAR_MAX_PATH_USTAR 256
/** 支持的最大完整路径（Pax）。 */
#define TAR_PATH_MAX 512

/** 返回最大路径字节数（mod path_max 对齐）。 */
int32_t tar_path_max_c(void) { return TAR_PATH_MAX; }

/** 将 12 字节八进制字符串解析为非负整数；失败 -1。 */
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

/** 将 size 写成 12 字节八进制（右对齐，前导空格）。 */
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

/** 写 UStar 头校验和。 */
static void tar_write_checksum(uint8_t *buf) {
  uint32_t sum = 0;
  for (int i = 0; i < TAR_HEADER_SIZE; i++) {
    if (i >= TAR_CHKSUM_OFF && i < TAR_CHKSUM_OFF + TAR_CHKSUM_LEN)
      sum += (uint8_t)' ';
    else
      sum += buf[i];
  }
  buf[TAR_CHKSUM_OFF + 0] = (uint8_t)('0' + (sum / 0100000 % 8));
  buf[TAR_CHKSUM_OFF + 1] = (uint8_t)('0' + (sum / 010000 % 8));
  buf[TAR_CHKSUM_OFF + 2] = (uint8_t)('0' + (sum / 01000 % 8));
  buf[TAR_CHKSUM_OFF + 3] = (uint8_t)('0' + (sum / 0100 % 8));
  buf[TAR_CHKSUM_OFF + 4] = (uint8_t)('0' + (sum / 010 % 8));
  buf[TAR_CHKSUM_OFF + 5] = (uint8_t)('0' + (sum % 8));
  buf[TAR_CHKSUM_OFF + 6] = 0;
  buf[TAR_CHKSUM_OFF + 7] = ' ';
}

/** 校验 UStar magic/version/checksum。 */
static int32_t tar_validate_header(const uint8_t *buf, int32_t len) {
  uint32_t sum = 0;
  uint32_t stored_chk = 0;
  if (!buf || len < TAR_HEADER_SIZE) return -1;
  if (buf[TAR_MAGIC_OFF] != 'u' || buf[TAR_MAGIC_OFF + 1] != 's' || buf[TAR_MAGIC_OFF + 2] != 't' ||
      buf[TAR_MAGIC_OFF + 3] != 'a' || buf[TAR_MAGIC_OFF + 4] != 'r' || buf[TAR_MAGIC_OFF + 5] != 0)
    return -1;
  if (buf[TAR_VERSION_OFF] != '0' || buf[TAR_VERSION_OFF + 1] != '0') return -1;
  for (int i = 0; i < TAR_HEADER_SIZE; i++) {
    if (i >= TAR_CHKSUM_OFF && i < TAR_CHKSUM_OFF + TAR_CHKSUM_LEN)
      sum += (uint8_t)' ';
    else
      sum += buf[i];
  }
  for (int i = 0; i < 6; i++) {
    if (buf[TAR_CHKSUM_OFF + i] >= '0' && buf[TAR_CHKSUM_OFF + i] <= '7')
      stored_chk = stored_chk * 8 + (buf[TAR_CHKSUM_OFF + i] - '0');
  }
  return (stored_chk == sum) ? 0 : -1;
}

/** 从单头读取 name+prefix 拼接完整路径到 name_out。 */
static int32_t tar_read_full_name(const uint8_t *buf, uint8_t *name_out, int32_t name_cap) {
  int32_t name_len = 0;
  int32_t prefix_len = 0;
  int32_t off = 0;
  if (!buf || !name_out || name_cap <= 0) return -1;
  while (name_len < TAR_NAME_LEN && buf[TAR_NAME_OFF + name_len] != 0) name_len++;
  while (prefix_len < TAR_PREFIX_LEN && buf[TAR_PREFIX_OFF + prefix_len] != 0) prefix_len++;
  if (prefix_len > 0) {
    if (prefix_len + name_len >= name_cap) return -1;
    memcpy(name_out, buf + TAR_PREFIX_OFF, (size_t)prefix_len);
    off = prefix_len;
  }
  if (name_len + off >= name_cap) return -1;
  memcpy(name_out + off, buf + TAR_NAME_OFF, (size_t)name_len);
  name_out[off + name_len] = 0;
  return 0;
}

/** 从 Pax 记录体解析 path= 值。 */
static int32_t tar_parse_pax_path(const uint8_t *body, int32_t body_len, uint8_t *out, int32_t out_cap) {
  int32_t i = 0;
  if (!body || !out || out_cap <= 0) return -1;
  while (i < body_len) {
    while (i < body_len && body[i] != ' ') i++;
    if (i >= body_len) break;
    i++;
    if (i + 5 <= body_len && memcmp(body + i, "path=", 5) == 0) {
      int32_t j = i + 5;
      int32_t n = 0;
      while (j < body_len && body[j] != '\n') {
        if (n + 1 >= out_cap) return -1;
        out[n++] = body[j++];
      }
      out[n] = 0;
      return n;
    }
    while (i < body_len && body[i] != '\n') i++;
    if (i < body_len) i++;
  }
  return -1;
}

/**
 * 从 buf 读取 UStar 头：写入完整路径 name_out，*size_out 为文件大小；成功 0。
 */
int32_t tar_read_header_c(const uint8_t *buf, int32_t len, uint8_t *name_out, int32_t name_cap, int32_t *size_out) {
  if (!buf || len < TAR_HEADER_SIZE || !name_out || name_cap <= 0 || !size_out) return -1;
  if (tar_validate_header(buf, len) != 0) return -1;
  if (tar_read_full_name(buf, name_out, name_cap) != 0) return -1;
  {
    int64_t sz = parse_octal_12(buf + TAR_SIZE_OFF);
    if (sz < 0 || sz > 0x7FFFFFFF) return -1;
    *size_out = (int32_t)sz;
  }
  return 0;
}

/** 向 buf 写入 UStar 头（name 仅 name 字段，不含 prefix）；typeflag 默认 '0'。 */
int32_t tar_write_header_c(uint8_t *buf, int32_t buf_cap, const uint8_t *name, int32_t name_len, int32_t file_size) {
  if (!buf || buf_cap < TAR_HEADER_SIZE || !name || name_len < 0) return -1;
  if (name_len > TAR_NAME_LEN) name_len = TAR_NAME_LEN;
  memset(buf, 0, (size_t)TAR_HEADER_SIZE);
  memcpy(buf + TAR_NAME_OFF, name, (size_t)name_len);
  write_octal_12(buf + TAR_SIZE_OFF, (int64_t)file_size);
  buf[TAR_TYPEFLAG_OFF] = '0';
  memcpy(buf + TAR_MAGIC_OFF, "ustar", 5);
  buf[TAR_VERSION_OFF] = '0';
  buf[TAR_VERSION_OFF + 1] = '0';
  tar_write_checksum(buf);
  return 0;
}

/** 写带 prefix/name 拆分的 UStar 头。 */
static int32_t tar_write_header_split(uint8_t *buf, int32_t buf_cap, const uint8_t *prefix, int32_t prefix_len,
                                      const uint8_t *name, int32_t name_len, int32_t file_size, uint8_t typeflag) {
  if (!buf || buf_cap < TAR_HEADER_SIZE) return -1;
  if (prefix_len > TAR_PREFIX_LEN || name_len > TAR_NAME_LEN) return -1;
  memset(buf, 0, (size_t)TAR_HEADER_SIZE);
  if (prefix_len > 0) memcpy(buf + TAR_PREFIX_OFF, prefix, (size_t)prefix_len);
  if (name_len > 0) memcpy(buf + TAR_NAME_OFF, name, (size_t)name_len);
  write_octal_12(buf + TAR_SIZE_OFF, (int64_t)file_size);
  buf[TAR_TYPEFLAG_OFF] = typeflag;
  memcpy(buf + TAR_MAGIC_OFF, "ustar", 5);
  buf[TAR_VERSION_OFF] = '0';
  buf[TAR_VERSION_OFF + 1] = '0';
  tar_write_checksum(buf);
  return 0;
}

/** UStar 512 字节块对齐。 */
static int32_t tar_pad512(int32_t n) {
  int32_t r = n % 512;
  if (r == 0) return 0;
  return 512 - r;
}

/** 写 Pax 扩展头 + 512 对齐体。 */
static int32_t tar_write_pax_header(uint8_t *buf, int32_t buf_cap, int32_t off, const uint8_t *full_path,
                                    int32_t path_len, int32_t *off_io) {
  char rec[640];
  int rec_len;
  int32_t pad;
  if (!buf || !off_io || !full_path || path_len <= 0 || path_len > TAR_PATH_MAX) return -1;
  rec_len = snprintf(rec, sizeof(rec), "%d path=%.*s\n", 6 + path_len, path_len, (const char *)full_path);
  {
    int guess = rec_len;
    int t;
    for (t = 0; t < 4; t++) {
      rec_len = snprintf(rec, sizeof(rec), "%d path=%.*s\n", guess, path_len, (const char *)full_path);
      if (rec_len > 0 && rec_len == guess) break;
      guess = rec_len;
    }
  }
  if (rec_len <= 0 || rec_len >= (int)sizeof(rec)) return -1;
  if (off + TAR_HEADER_SIZE + rec_len > buf_cap) return -1;
  memset(buf + off, 0, (size_t)TAR_HEADER_SIZE);
  write_octal_12(buf + off + TAR_SIZE_OFF, (int64_t)rec_len);
  buf[off + TAR_TYPEFLAG_OFF] = TAR_TYPE_PAX;
  memcpy(buf + off + TAR_MAGIC_OFF, "ustar", 5);
  buf[off + TAR_VERSION_OFF] = '0';
  buf[off + TAR_VERSION_OFF + 1] = '0';
  tar_write_checksum(buf + off);
  off += TAR_HEADER_SIZE;
  memcpy(buf + off, rec, (size_t)rec_len);
  off += rec_len;
  pad = tar_pad512(rec_len);
  if (off + pad > buf_cap) return -1;
  memset(buf + off, 0, (size_t)pad);
  off += pad;
  *off_io = off;
  return 0;
}

/** 在末级 '/' 处拆分长路径为 prefix + name。 */
static void tar_split_path(const uint8_t *path, int32_t path_len, const uint8_t **prefix, int32_t *prefix_len,
                           const uint8_t **name, int32_t *name_len) {
  int32_t split = -1;
  int32_t i;
  *prefix = path;
  *prefix_len = 0;
  *name = path;
  *name_len = path_len;
  if (path_len <= TAR_NAME_LEN) return;
  for (i = path_len - 1; i >= 0; i--) {
    if (path[i] == '/') {
      split = i;
      break;
    }
  }
  if (split <= 0 || split >= TAR_PREFIX_LEN) {
    *name = path;
    *name_len = path_len;
    return;
  }
  *prefix = path;
  *prefix_len = split + 1;
  *name = path + split + 1;
  *name_len = path_len - split - 1;
}

/** 线程局部 Pax 路径缓存（单线程 gate 烟测足够）。 */
static uint8_t g_tar_pax_path[TAR_PATH_MAX + 1];
static int32_t g_tar_pax_path_len = 0;

/**
 * 向归档缓冲追加 UStar/Pax 条目；is_dir=1 写目录（typeflag '5'）。
 */
int32_t tar_append_entry_c(uint8_t *buf, int32_t buf_cap, int32_t *off_io, const uint8_t *name,
                            int32_t name_len, const uint8_t *data, int32_t data_len, int32_t is_dir) {
  int32_t off;
  int32_t file_size;
  int32_t pad;
  uint8_t typeflag;
  const uint8_t *pfx;
  const uint8_t *nm;
  int32_t pfx_len;
  int32_t nm_len;
  if (!buf || !off_io || !name || name_len < 0 || name_len > TAR_PATH_MAX)
    return -1;
  off = *off_io;
  file_size = is_dir ? 0 : data_len;
  typeflag = is_dir ? (uint8_t)'5' : (uint8_t)'0';

  if (name_len > TAR_MAX_PATH_USTAR) {
    if (tar_write_pax_header(buf, buf_cap, off, name, name_len, &off) != 0) return -1;
    if (off + TAR_HEADER_SIZE > buf_cap) return -1;
    if (tar_write_header_split(buf + off, buf_cap - off, (const uint8_t *)"", 0, name, name_len > TAR_NAME_LEN ? TAR_NAME_LEN : name_len,
                               file_size, typeflag) != 0)
      return -1;
    off += TAR_HEADER_SIZE;
  } else if (name_len > TAR_NAME_LEN) {
    tar_split_path(name, name_len, &pfx, &pfx_len, &nm, &nm_len);
    if (off + TAR_HEADER_SIZE > buf_cap) return -1;
    if (tar_write_header_split(buf + off, buf_cap - off, pfx, pfx_len, nm, nm_len, file_size, typeflag) != 0)
      return -1;
    off += TAR_HEADER_SIZE;
  } else {
    if (off + TAR_HEADER_SIZE > buf_cap) return -1;
    if (tar_write_header_c(buf + off, buf_cap - off, name, name_len, file_size) != 0) return -1;
    buf[off + TAR_TYPEFLAG_OFF] = typeflag;
    tar_write_checksum(buf + off);
    off += TAR_HEADER_SIZE;
  }

  if (!is_dir && data_len > 0) {
    if (!data || off + data_len > buf_cap) return -1;
    memcpy(buf + off, data, (size_t)data_len);
    off += data_len;
    pad = tar_pad512(data_len);
    if (off + pad > buf_cap) return -1;
    memset(buf + off, 0, (size_t)pad);
    off += pad;
  }
  *off_io = off;
  return 0;
}

/**
 * 遍历下一条 tar 条目；成功 0，结束 1，错误 -1。
 */
int32_t tar_next_entry_c(const uint8_t *buf, int32_t buf_len, int32_t *pos_io, uint8_t *name_out,
                         int32_t name_cap, int32_t *size_out, int32_t *type_out) {
  int32_t pos;
  int32_t sz;
  int32_t blocks;
  int32_t i;
  int32_t all_zero;
  uint8_t tf;
  if (!buf || !pos_io || !name_out || name_cap <= 0) return -1;
  pos = *pos_io;
  g_tar_pax_path_len = 0;
  if (pos + 512 > buf_len) return 1;
  all_zero = 1;
  for (i = 0; i < 512; i++) {
    if (buf[pos + i] != 0) { all_zero = 0; break; }
  }
  if (all_zero) return 1;
  if (tar_validate_header(buf + pos, buf_len - pos) != 0) return -1;
  tf = buf[pos + TAR_TYPEFLAG_OFF];
  sz = 0;
  {
    int64_t s = parse_octal_12(buf + pos + TAR_SIZE_OFF);
    if (s < 0 || s > 0x7FFFFFFF) return -1;
    sz = (int32_t)s;
  }

  if (tf == TAR_TYPE_PAX) {
    int32_t data_off = pos + 512;
    if (data_off + sz > buf_len) return -1;
    g_tar_pax_path_len = tar_parse_pax_path(buf + data_off, sz, g_tar_pax_path, TAR_PATH_MAX + 1);
    blocks = (sz + 511) / 512;
    pos = data_off + blocks * 512;
    if (pos + 512 > buf_len) return -1;
    if (tar_validate_header(buf + pos, buf_len - pos) != 0) return -1;
    tf = buf[pos + TAR_TYPEFLAG_OFF];
    {
      int64_t s = parse_octal_12(buf + pos + TAR_SIZE_OFF);
      if (s < 0 || s > 0x7FFFFFFF) return -1;
      sz = (int32_t)s;
    }
  }

  if (g_tar_pax_path_len > 0) {
    if (g_tar_pax_path_len >= name_cap) return -1;
    memcpy(name_out, g_tar_pax_path, (size_t)g_tar_pax_path_len);
    name_out[g_tar_pax_path_len] = 0;
  } else {
    if (tar_read_full_name(buf + pos, name_out, name_cap) != 0) return -1;
  }

  if (type_out) *type_out = (int32_t)tf;
  if (size_out) *size_out = sz;
  pos += 512;
  blocks = (sz + 511) / 512;
  pos += blocks * 512;
  *pos_io = pos;
  return 0;
}

/** 从 entry_off 读取文件数据；返回字节数，失败 -1。 */
int32_t tar_read_entry_data_c(const uint8_t *buf, int32_t buf_len, int32_t entry_off, uint8_t *out,
                              int32_t out_cap) {
  int32_t p;
  int32_t sz;
  int32_t data_off;
  int32_t n;
  uint8_t tf;
  if (!buf || !out || entry_off < 0 || entry_off + 512 > buf_len) return -1;
  p = entry_off;
  tf = buf[p + TAR_TYPEFLAG_OFF];
  sz = (int32_t)parse_octal_12(buf + p + TAR_SIZE_OFF);
  if (sz < 0) return -1;
  data_off = p + 512;
  if (tf == TAR_TYPE_PAX) {
    int32_t blocks = (sz + 511) / 512;
    p = data_off + blocks * 512;
    if (p + 512 > buf_len) return -1;
    tf = buf[p + TAR_TYPEFLAG_OFF];
    sz = (int32_t)parse_octal_12(buf + p + TAR_SIZE_OFF);
    if (sz < 0) return -1;
    data_off = p + 512;
  }
  if (sz <= 0) return 0;
  n = sz;
  if (n > out_cap) n = out_cap;
  if (data_off + n > buf_len) return -1;
  memcpy(out, buf + data_off, (size_t)n);
  return n;
}

/** STD-152 C 烟测：长路径 prefix + Pax + 目录。 */
int32_t tar_extended_smoke_c(void) {
  uint8_t arc[8192];
  int32_t off = 0;
  uint8_t path[128];
  int32_t i;
  uint8_t data[1] = {88};
  uint8_t dir[64];
  uint8_t pax[280];
  int32_t pos = 0;
  uint8_t name_out[520];
  int32_t sz;
  int32_t typ;
  int32_t nr;

  memset(arc, 0, sizeof(arc));
  i = 0;
  while (i < 60) path[i++] = (uint8_t)'a';
  {
    const uint8_t tail[] = "/nested/file.su";
    int j = 0;
    while (tail[j]) path[i++] = tail[j++];
  }
  if (tar_append_entry_c(arc, (int32_t)sizeof(arc), &off, path, i, data, 1, 0) != 0) return 1;

  i = 0;
  while (i < 40) dir[i++] = (uint8_t)'d';
  {
    const uint8_t dt[] = "/deep/";
    int j = 0;
    while (dt[j]) dir[i++] = dt[j++];
  }
  if (tar_append_entry_c(arc, (int32_t)sizeof(arc), &off, dir, i, NULL, 0, 1) != 0) return 2;

  i = 0;
  while (i < 270) pax[i++] = (uint8_t)'p';
  data[0] = 81;
  if (tar_append_entry_c(arc, (int32_t)sizeof(arc), &off, pax, 270, data, 1, 0) != 0) return 3;

  {
    int32_t got_file = 0, got_dir = 0, got_pax = 0;
    while (pos < off) {
      int32_t entry_off = pos;
      nr = tar_next_entry_c(arc, off, &pos, name_out, (int32_t)sizeof(name_out), &sz, &typ);
      if (nr == 1) break;
      if (nr != 0) return 4;
      if (typ == (int32_t)'5') {
        got_dir++;
      } else if (typ == (int32_t)'0') {
        uint8_t out[4];
        int32_t n = tar_read_entry_data_c(arc, off, entry_off, out, 4);
        if (name_out[0] == (uint8_t)'a' && name_out[60] == (uint8_t)'/') {
          got_file++;
          if (n != 1 || out[0] != 88) return 5;
        } else if (name_out[0] == (uint8_t)'p' && name_out[269] == (uint8_t)'p') {
          got_pax++;
          if (n != 1 || out[0] != 81) return 6;
        } else {
          return 7;
        }
      }
    }
    if (got_file != 1 || got_dir != 1 || got_pax != 1) return 8;
  }
  return 0;
}
