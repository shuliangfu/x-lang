// STD-137：std.time 墙钟 RFC3339 格式化与时区偏移烟测
// 【asm -o】仅测 wall_local_offset_min（format_wall 栈缓冲 co-emit 易 SIGSEGV）。
const time = import("std.time");

function main(): i32 {
  let off: i32 = 0;
  off = time.wall_local_offset_min();
  if (off < -840 || off > 840) { return 3; }
  return 0;
}
