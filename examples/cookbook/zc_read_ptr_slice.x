/**
 * Cookbook ZC-02：read_ptr_view 绝对视图校验（ZC-2/ZC-3 入门）。
 */
const fs = import("std.fs");
const io = import("std.io");

function main(): i32 {
  /** "/tmp/shux_cookbook_zc_view\0" — 26 字节含 NUL */
  let path: u8[26] =
  [47, 116, 109, 112, 47, 115, 104, 117, 95, 99, 111, 111, 107, 98, 111, 111, 107,
  95, 122, 99, 95, 118, 105, 101, 119, 0];
  let payload: u8[3] = [11, 22, 33];
  let fd_w: i32 = fs.create(&path[0]);
  if (fd_w < 0) { return 1; }
  if (fs.write(fd_w, &payload[0], 3) != 3) { fs.close(fd_w); return 2; }
  if (fs.close(fd_w) != 0) { return 3; }
  let fd_r: i32 = fs.open(&path[0]);
  if (fd_r < 0) { return 4; }
  let handle: usize = io.from_fd(fd_r, 0);
  let v: ReadPtrView = io.ptr_view(handle, 0);
  if (v.ptr == 0 as *u8) { fs.close(fd_r); return 5; }
  if (io.ptr_view_valid(v) != 1) { fs.close(fd_r); return 6; }
  if (v.len != 3 || v.ptr[1] != 22) { fs.close(fd_r); return 7; }
  if (fs.close(fd_r) != 0) { return 8; }
  return 0;
}
