// tests/io/fallback_matrix.x — STD-026：非 Linux 回退路径烟测（read_fd/write_fd typeck）
//
// 【文件职责】确认 std.io fd 便捷 API 可 typeck；运行时平台路径见 analysis/std-io-fallback-v1.md。
const io = import("std.io");

function main(): i32 {
  let buf: u8[8] = [];
  let _r: i32 = io.read_fd(0, &buf[0], 8);
  let _w: i32 = io.write_fd(1, &buf[0], 0);
  return 0;
}
