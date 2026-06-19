// EXC-006：Result or_i32 回退到 Ok 值
const result = import("core.result");

function main(): i32 {
  let a: Result_i32 = result.or_i32(result.err_i32(1), result.ok_i32(88));
  if (!result.is_ok_i32(a) || result.expect_i32_or_panic(a) != 88) { return 1; }
  return 0;
}
