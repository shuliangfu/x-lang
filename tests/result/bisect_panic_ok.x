const result = import("core.result");

function main(): i32 {
  return result.expect_i32_or_panic(result.ok_i32(5));
}
