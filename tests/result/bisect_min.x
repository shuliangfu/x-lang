const result = import("core.result");

function main(): i32 {
  let ok_r: Result_i32 = result.ok_i32(42);
  return result.unwrap_or_i32(ok_r, 0);
}
