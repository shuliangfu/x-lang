/**
 * tar_import_alias.c — import binding `-o` 链接桩
 *
 * tar.sx 现已直接导出 tar_*_c；本 TU 仅保留 asm import-binding 所需的 std_tar_* 转发符号。
 */
#include <stdint.h>

extern int32_t tar_path_max_c(void);
extern int32_t tar_read_header_c(uint8_t *buf, int32_t len, uint8_t *name_out, int32_t name_cap, int32_t *size_out);
extern int32_t tar_write_header_c(uint8_t *buf, int32_t buf_cap, uint8_t *name, int32_t name_len, int32_t file_size);
extern int32_t tar_append_entry_c(uint8_t *buf, int32_t buf_cap, int32_t *off_io, uint8_t *name, int32_t name_len,
                                  uint8_t *data, int32_t data_len, int32_t is_dir);
extern int32_t tar_next_entry_c(uint8_t *buf, int32_t buf_len, int32_t *pos_io, uint8_t *name_out, int32_t name_cap,
                                int32_t *size_out, int32_t *type_out);
extern int32_t tar_read_entry_data_c(uint8_t *buf, int32_t buf_len, int32_t entry_off, uint8_t *out, int32_t out_cap);

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
