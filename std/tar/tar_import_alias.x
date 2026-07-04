// tar_import_alias.x — import binding -o 链接桩（从 .c 转换）
extern function tar_path_max_c(): i32;
extern function tar_read_header_c(buf: *u8, len: i32, name_out: *u8, name_cap: i32, size_out: *i32): i32;
extern function tar_write_header_c(buf: *u8, buf_cap: i32, name: *u8, name_len: i32, file_size: i32): i32;
extern function tar_append_entry_c(buf: *u8, buf_cap: i32, off_io: *i32, name: *u8, name_len: i32, data: *u8, data_len: i32, is_dir: i32): i32;
extern function tar_next_entry_c(buf: *u8, buf_len: i32, pos_io: *i32, name_out: *u8, name_cap: i32, size_out: *i32, type_out: *i32): i32;
extern function tar_read_entry_data_c(buf: *u8, buf_len: i32, entry_off: i32, out: *u8, out_cap: i32): i32;

function std_tar_path_max(): i32 { return tar_path_max_c(); }
function std_tar_read_header(buf: *u8, len: i32, name_out: *u8, name_cap: i32, size_out: *i32): i32 {
  return tar_read_header_c(buf, len, name_out, name_cap, size_out);
}
function std_tar_write_header(buf: *u8, buf_cap: i32, name: *u8, name_len: i32, file_size: i32): i32 {
  return tar_write_header_c(buf, buf_cap, name, name_len, file_size);
}
function std_tar_append_entry(buf: *u8, buf_cap: i32, off_io: *i32, name: *u8, name_len: i32, data: *u8, data_len: i32, is_dir: i32): i32 {
  return tar_append_entry_c(buf, buf_cap, off_io, name, name_len, data, data_len, is_dir);
}
function std_tar_next_entry(buf: *u8, buf_len: i32, pos_io: *i32, name_out: *u8, name_cap: i32, size_out: *i32, type_out: *i32): i32 {
  return tar_next_entry_c(buf, buf_len, pos_io, name_out, name_cap, size_out, type_out);
}
function std_tar_read_entry_data(buf: *u8, buf_len: i32, entry_off: i32, out: *u8, out_cap: i32): i32 {
  return tar_read_entry_data_c(buf, buf_len, entry_off, out, out_cap);
}
