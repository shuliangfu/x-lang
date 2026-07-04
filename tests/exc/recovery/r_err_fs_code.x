// EXC-006：fs 语义 Err + unwrap_or 恢复
const result = import("core.result");
const err = import("std.error");

function main(): i32 {
  let r: Result_i32 = result.err_i32(fs_err_not_found());
  let v: i32 = result.unwrap_or_i32(r, 404);
  if (v != 404) { return 1; }
  return 0;
}
