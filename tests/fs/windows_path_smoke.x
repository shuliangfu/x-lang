// tests/fs/windows_path_smoke.x — STD-022：Windows 反斜杠路径 fs 句柄烟测
// 路径 "tests\fs\.win_xplat_tmp"；仅 Windows CI 须 runnable（见 std-fs-crossplatform.tsv）。
const fs = import("std.fs");

/** 写入反斜杠路径文件；成功返回 0。 */
function wp_write(path: *u8, payload: *u8, len: usize): i32 {
  let fd: i32 = fs.create(path);
  if (fd < 0) { return 1; }
  let nw: isize = fs.write(fd, payload, len);
  if (fs.sync(fd) != 0) {
    fs.close(fd);
    return 2;
  }
  if (fs.close(fd) != 0) { return 3; }
  if (nw != (len as isize)) { return 4; }
  return 0;
}

function main(): i32 {
  /** "tests\fs\.win_xplat_tmp" */
  let path: u8[24] =
  [116, 101, 115, 116, 115, 92, 102, 115, 92, 46, 119, 105, 110, 95, 120, 112, 108, 97, 116,
  95, 116, 109, 112, 0];
  let payload: u8[16] =
  [83, 84, 68, 45, 48, 50, 50, 32, 119, 105, 110, 10, 0, 0, 0, 0];
  let pay_len: usize = 12 as usize;
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  let fd: i32 = 0;

  if (wp_write(&path[0], &payload[0], pay_len) != 0) { return 10; }
  if (fs.path_readable(&path[0]) != 1) { return 11; }

  fd = fs.open(&path[0]);
  if (fd < 0) { return 12; }
  let nr: isize = fs.read(fd, &buf[0], pay_len);
  if (fs.close(fd) != 0) { return 13; }
  if (nr != (pay_len as isize)) { return 14; }
  if (buf[0] != 83 || buf[1] != 84 || buf[2] != 68) { return 15; }
  return 0;
}
