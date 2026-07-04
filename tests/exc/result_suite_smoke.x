// tests/exc/result_suite_smoke.x — EXC-002：core.result 轻量回归（main.x -o SIGSEGV 时 fallback）
const result = import("core.result");

function main(): i32 {
  let ok_r: Result_i32 = result.ok_i32(42);
  let err_r: Result_i32 = result.err_i32(7);
  if (result.unwrap_or_i32(ok_r, 0) != 42) { return 1; }
  if (result.unwrap_or_i32(err_r, 99) != 99) { return 2; }
  if (!result.is_ok_i32(ok_r) || result.is_err_i32(ok_r)) { return 3; }
  if (result.is_ok_i32(err_r) || !result.is_err_i32(err_r)) { return 4; }
  if (result.expect_i32_or_panic(result.ok_i32(5)) != 5) { return 5; }
  return 0;
}
