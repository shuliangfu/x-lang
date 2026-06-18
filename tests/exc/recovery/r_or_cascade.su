// EXC-006：连续 or_i32 多级回退
const result = import("core.result");

function main(): i32 {
  let a: Result_i32 = result.or_i32(
    result.err_i32(1),
    result.or_i32(result.err_i32(2), result.ok_i32(44)));
  if (!result.is_ok_i32(a) || result.expect_i32_or_panic(a) != 44) { return 1; }
  return 0;
}
