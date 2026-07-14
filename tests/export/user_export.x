// user_export.x — 跨模块使用 export API
const lib = import("lib_export");

function main(): i32 {
  let s: i32 = lib.public_add(1, 2);
  let t: i32 = lib.public_via_private(3);
  return s + t; // 3 + 6 = 9
}
