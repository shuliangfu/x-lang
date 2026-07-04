// dead_multi_user.x — 模拟 compiler self 多 import 库 + 大量 dead export（WPO __text A/B proxy）
const dead_lib = import("dead_lib");
const dead_lib2 = import("dead_lib2");
const dead_lib3 = import("dead_lib3");

function main(): i32 {
  return live_export() + live_export2() + live_export3();
}
