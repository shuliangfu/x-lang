// 测试绑定 import：const types = import("core.types");
const types = import("core.types");

function main(): i32 {
  let n: i32 = types.size_of_i32();
  return if (n == 4) { 0 } else { 1 };
}
