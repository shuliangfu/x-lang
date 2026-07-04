// tests/exc/layer_c_recoverable.x — EXC-002：Layer C 可恢复错误（fs 失败 + last_error，不 panic）
const fs = import("std.fs");

function main(): i32 {
  /** tests/exc/.no_such_fs_path_xxx（NUL 结尾）；main 栈帧内使用，不逃逸指针。 */
  let path: u8[36] =
    [116, 101, 115, 116, 115, 47, 101, 120, 99, 47, 46, 110, 111, 95, 115, 117, 99, 104, 95, 102, 115, 95, 112, 97, 116, 104, 95, 120, 120, 120, 0, 0, 0, 0, 0, 0];
  let fd: i32 = fs.open(&path[0]);
  if (fd >= 0) {
    fs.close(fd);
    return 1;
  }
  let err: i32 = fs.last_error();
  if (err == 0) { return 2; }
  return 0;
}
