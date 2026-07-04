// STD-123：目录/元数据 mkdir → stat → readdir → unlink → rmdir 往返
const fs = import("std.fs");

/** 比较 NUL 结尾字符串是否相等。 */
function str_eq(a: *u8, b: *u8): i32 {
  let i: i32 = 0;
  while (a[i] != 0 && b[i] != 0) {
    if (a[i] != b[i]) { return 0; }
    i = i + 1;
  }
  if (a[i] != b[i]) { return 0; }
  return 1;
}

function main(): i32 {
  /** "tests/fs/.dirmeta_tmp\0" */
  let dir_path: u8[24] =
  [116, 101, 115, 116, 115, 47, 102, 115, 47, 46, 100, 105, 114, 109, 101, 116, 97, 95, 116, 109, 112, 0, 0, 0];
  /** "tests/fs/.dirmeta_tmp/inner.txt\0" */
  let file_path: u8[35] =
  [116, 101, 115, 116, 115, 47, 102, 115, 47, 46, 100, 105, 114, 109, 101, 116, 97, 95, 116, 109, 112, 47, 105, 110, 110, 101, 114, 46, 116, 120, 116, 0, 0, 0, 0];
  /** "inner.txt\0" */
  let inner_name: u8[11] = [105, 110, 110, 101, 114, 46, 116, 120, 116, 0, 0];
  let payload: u8[5] = [83, 72, 85, 33, 0];
  let pay_len: usize = 4 as usize;
  let st: FsStatOut = FsStatOut { size: 0, mode: 0, is_dir: 0, is_file: 0, mtime_sec: 0 };
  let fd: i32 = 0;
  let dh: i64 = 0;
  let name_buf: u8[64] = [];
  let is_dir_flag: i32 = 0;
  let found: i32 = 0;
  let rr: i32 = 0;

  fs.remove_file(&file_path[0]);
  fs.remove_dir(&dir_path[0]);

  if (fs.mkdir(&dir_path[0], fs.mode_dir_default()) != 0) { return 1; }
  if (fs.stat(&dir_path[0], &st) != 0) { return 2; }
  if (st.is_dir != 1) { return 3; }

  fd = fs.create(&file_path[0]);
  if (fd < 0) { return 4; }
  if (fs.write(fd, &payload[0], pay_len) != (pay_len as isize)) {
    fs.close(fd);
    return 5;
  }
  if (fs.sync(fd) != 0) {
    fs.close(fd);
    return 6;
  }
  fs.close(fd);

  if (fs.stat(&file_path[0], &st) != 0) { return 7; }
  if (st.is_file != 1) { return 8; }
  if (st.size != 4) { return 9; }

  if (fs.chmod(&file_path[0], fs.mode_file_default()) != 0) { return 10; }

  dh = fs.dir_open(&dir_path[0]);
  if (dh < 0) { return 11; }
  let more: i32 = 1;
  while (more != 0) {
    rr = fs.dir_read(dh, &name_buf[0], 64, &is_dir_flag);
    if (rr < 0) {
      fs.dir_close(dh);
      return 12;
    }
    if (rr == 0) {
      more = 0;
      break;
    }
    if (str_eq(&name_buf[0], &inner_name[0]) != 0) {
      if (is_dir_flag != 0) {
        fs.dir_close(dh);
        return 13;
      }
      found = 1;
    }
  }
  fs.dir_close(dh);
  if (found != 1) { return 14; }

  if (fs.remove_file(&file_path[0]) != 0) { return 15; }
  if (fs.remove_dir(&dir_path[0]) != 0) { return 16; }
  return 0;
}
