// user_private_should_fail.x — strict 下访问未 export 应失败
const lib = import("lib_export");

function main(): i32 {
  return lib.private_mul(2, 3);
}
