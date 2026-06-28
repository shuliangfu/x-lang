// TST-001：std.io 边界烟测（handle / 零长写 / stderr）
//
// 【文件职责】≥8 边界 case；不依赖网络或外部文件。
// 【运行方式】tests/run-tst-001-boundary-gate.sh
const io = import("std.io");

function main(): i32 {
  // case 1：标准 handle 常量
  if (io.stdin() != 0) { return 1; }
  // case 2
  if (io.stdout() != 1) { return 2; }
  // case 3
  if (io.stderr() != 2) { return 3; }
  // case 4：fd → handle 往返
  let h: usize = io.from_fd(7, 0);
  if (h != 7) { return 4; }
  // case 5：零字节 write_stdout
  let empty: u8[1] = [0];
  let z: i32 = io.write_stdout(&empty[0], 0);
  if (z != 0) { return 5; }
  // case 6：write_with_timeout 单字节
  let one: u8[1] = [65];
  if (io.write(&one[0], 1, 1000) != 1) { return 6; }
  // case 7：write_stderr 零长
  if (io.write_stderr(&empty[0], 0) != 0) { return 7; }
  // case 8：print_str 空串
  if (io.print(&empty[0], 0) != 0) { return 8; }
  // case 9：read_into 零长缓冲（应不阻塞失败或返回 0）
  let zr: i32 = io.read(io.stdin(), &empty[0], 0, 0);
  if (zr < 0) { return 9; }
  return 0;
}
