// EXC-006：嵌套 unwrap_or 默认链
const result = import("core.result");

function main(): i32 {
  let inner: Result_i32 = result.err_i32(1);
  let outer: i32 = result.unwrap_or_i32(inner, result.unwrap_or_i32(result.err_i32(2), 55));
  if (outer != 55) { return 1; }
  return 0;
}
