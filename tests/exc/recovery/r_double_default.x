// EXC-006：双层 unwrap_or 默认
const result = import("core.result");

function main(): i32 {
  let v: i32 = result.unwrap_or_i32(result.err_i32(1), result.unwrap_or_i32(result.err_i32(2), 33));
  if (v != 33) { return 1; }
  return 0;
}
