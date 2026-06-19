// EXC-006：and_i32 双 Ok 传播
const result = import("core.result");

function main(): i32 {
  let a: Result_i32 = result.and_i32(result.ok_i32(3), result.ok_i32(4));
  if (!result.is_ok_i32(a) || result.expect_i32_or_panic(a) != 4) { return 1; }
  return 0;
}
