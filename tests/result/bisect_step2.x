// bisect: or_i32 / and_i32
const result = import("core.result");

function main(): i32 {
  let ok_r: Result_i32 = result.ok_i32(42);
  let err_r: Result_i32 = result.err_i32(7);
  let o1: Result_i32 = result.or_i32(err_r, result.ok_i32(99));
  let o2: Result_i32 = result.or_i32(ok_r, result.ok_i32(99));
  if (!result.is_ok_i32(o1) || result.expect_i32_or_panic(o1) != 99) { return -3; }
  if (result.expect_i32_or_panic(o2) != 42) { return -4; }
  let a1: Result_i32 = result.and_i32(result.ok_i32(1), result.ok_i32(2));
  let a2: Result_i32 = result.and_i32(result.err_i32(10), result.ok_i32(2));
  if (result.expect_i32_or_panic(a1) != 2) { return -5; }
  if (result.is_ok_i32(a2)) { return -6; }
  return 0;
}
