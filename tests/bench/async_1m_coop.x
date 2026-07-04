// async_1m_coop.x — STD-004：1M 双路径 scheduler 压测（import("std.async")）
// coop_pingpong + coop_pingpong_jmp 各 1M 轮 → 共 4M task steps；exit 0 = 无崩溃且计数正确。
const async_mod = import("std.async");

function main(): i32 {
  let rounds: i64 = 1000000;
  let a: i64 = async_mod.coop_pingpong(rounds);
  if (a != 2000000) { return 1; }
  let b: i64 = async_mod.coop_pingpong_jmp(rounds);
  if (b != 2000000) { return 2; }
  return 0;
}
