// bisect: 基础 ok/err/unwrap
const result = import("core.result");

function main(): i32 {
  let ok_r: Result_i32 = result.ok_i32(42);
  let err_r: Result_i32 = result.err_i32(7);
  let a: i32 = result.unwrap_or_i32(ok_r, 0);
  let b: i32 = result.unwrap_or_i32(err_r, 0);
  let c: i32 = result.expect_i32(result.ok_i32(3), 0);
  let d: i32 = result.expect_i32_or_panic(result.ok_i32(5));
  return a + b + c + d;
}
