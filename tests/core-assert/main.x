// 烟测：core.assert（原 core.debug 能力迁移）
const assert_mod = import("core.assert");

function main(): i32 {
  let a: i32 = assert_mod.assert(true);
  let b: i32 = assert_mod.assert_eq_i32(1, 1);
  return if (a == 0 && b == 0) { 0 } else { 1 };
}
