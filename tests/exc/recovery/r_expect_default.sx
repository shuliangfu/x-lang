// EXC-006：expect_i32 在 Err 时落默认（与 unwrap_or 同义）
const result = import("core.result");

function main(): i32 {
  let r: Result_i32 = result.err_i32(5);
  if (result.expect_i32(r, 88) != 88) { return 1; }
  return 0;
}
