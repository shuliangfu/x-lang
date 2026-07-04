// STD-097：Windows 路径烟测占位（运行时见 win_path_smoke.c；POSIX 跳过）
const dynlib = import("std.dynlib");

function main(): i32 {
  // 非 Windows：open_sym_close 已覆盖 POSIX；此处仅 typeck 通过
  let path: u8[4] = [0, 0, 0, 0];
  if (dynlib.open(&path[0]) != 0) {
    return 1;
  }
  return 0;
}
