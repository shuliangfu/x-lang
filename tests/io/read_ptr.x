// 测试 std.io 零拷贝读：read_stdin_ptr_slice（与 read_stdin_ptr/read_ptr_len 等价语义）
// 需用管道喂入数据运行，例如：echo -n "AB" | ./run_read_ptr。
// 注：shux_asm 未 relink 前 read_stdin_ptr 返回值 + read_ptr_len 分两次 CALL 易 hoist 错乱，用 slice 一次取用。
const io = import("std.io");

function main(): i32 {
  let s: u8[]<io_read_ptr> = io.stdin_ptr_slice();
  if (s.length <= 0) {
    return 1;
  }
  if (s.data[0] != 65) {
    return 2;
  }
  return 0;
}
