/**
 * TOOL-007 pkgmgr demo：清单声明 core.mem + core.types，须可 resolve + 编译。
 */
const mem = import("core.mem");
const types = import("core.types");

function main(): i32 {
  let n: i32 = types.size_of_i32();
  if (n != 4) {
    return 1;
  }
  return 0;
}
