// EXC-006：and_i32 遇 Err 短路（可恢复，不 panic）
const result = import("core.result");

function main(): i32 {
  let a: Result_i32 = result.and_i32(result.err_i32(9), result.ok_i32(1));
  if (!result.is_err_i32(a) || a.err != 9) { return 1; }
  let v: i32 = result.unwrap_or_i32(a, 100);
  if (v != 100) { return 2; }
  return 0;
}
