// EXC-006：io 语义 Err 经 unwrap_or 落默认
const result = import("core.result");
const err = import("std.error");

function main(): i32 {
  let r: Result_i32 = result.err_i32(io_err_generic());
  if (result.unwrap_or_i32(r, -1) != -1) { return 1; }
  return 0;
}
