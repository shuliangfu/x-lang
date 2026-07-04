// async_mod_import.x — import("std.async")；runtime 按 nm 未定义符号按需链 scheduler.o
const async_mod = import("std.async");

/** 烟测：coop_pingpong_jmp 经 mod.x 转发至 scheduler.c。 */
function main(): i32 {
  let total: i64 = async_mod.coop_pingpong_jmp(1000);
  if (total != 2000) {
    return 1;
  }
  return 0;
}
