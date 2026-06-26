// 测试 std.time：单调时钟、睡眠、时间差
//
// 【文件职责】本文件为 std.time 的回归测试。
// 【测试目的】确认 sleep 后 monotonic 递增、duration_ns 合理。
// 【覆盖 API】now_monotonic_ns、sleep_ms、duration_ns。
// 【预期结果】退出码 0 表示通过。
// 【运行方式】./tests/run-time.sh
// 【asm -o】CALL 用赋值语句；仅验证 sleep 后 elapsed，避免 hoist/墙钟 flaky。
const time = import("std.time");

function main(): i32 {
  let t0: i64 = 0;
  t0 = time.now_monotonic_ns();
  time.sleep_ms(50);
  let t1: i64 = 0;
  t1 = time.now_monotonic_ns();
  let elapsed_ns: i64 = 0;
  elapsed_ns = time.duration_ns(t0, t1);
  if (elapsed_ns < 10000000) {
    return 2;
  }
  return 0;
}
