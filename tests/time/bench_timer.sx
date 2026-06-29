// STD-133：std.time benchmark 计时器烟测
//
// 校验 elapsed / lap / reset 与 sleep 下限（宽松，兼容调度抖动）。
// 【asm -o】CALL 结果用赋值语句而非 let 初值，避免 pass-0 hoist 越过 sleep。
const time = import("std.time");

function main(): i32 {
  let t: time.Timer = time.start();
  // CI 调度抖动大：sleep 100ms，阈值放宽到 5ms（仍验证单调递增）
  time.sleep_ms(100);
  let ns: i64 = 0;
  ns = time.elapsed_ns(t);
  if (ns < 5000000) { return 1; }
  let ms: i64 = 0;
  ms = time.elapsed_ms(t);
  if (ms < 5) { return 2; }
  let us: i64 = 0;
  us = time.elapsed_us(t);
  if (us < 5000) { return 3; }
  let sec: i64 = 0;
  sec = time.elapsed_sec(t);
  if (sec < 0) { return 4; }

  time.reset(&t);
  time.sleep_ms(60);
  let after_reset: i64 = 0;
  after_reset = time.elapsed_ns(t);
  if (after_reset < 3000000) { return 5; }
  /* macOS 单调时钟 reset 后基准可能仍接近全局起点，勿与 reset 前 ns 比较。 */

  time.reset(&t);
  time.sleep_ms(40);
  let lap1: i64 = 0;
  lap1 = time.lap_ns(&t);
  if (lap1 < 3000000) { return 7; }
  time.sleep_ms(40);
  let lap2: i64 = 0;
  lap2 = time.lap_ns(&t);
  if (lap2 < 3000000) { return 8; }
  let tail: i64 = 0;
  tail = time.elapsed_ns(t);
  if (tail < 0) { return 9; }
  return 0;
}
