/**
 * CORE-016 烟测：Result<T,i32> 与 Result_i32/Result_u8 类型族互操作（import("core.result")）。
 */
const result = import("core.result");

function take_i32(r: Result_i32): i32 {
  return result.unwrap_or_i32(r, 0);
}

function main(): i32 {
  let g: Result<i32, i32> = result.ok_i32(42);
  let f: Result_i32 = result.err_i32(3);
  let u: Result<u8, i32> = ok_u8(9);
  let mix: Result_i32 = g;

  if (take_i32(mix) != 42) { return 1; }
  if (!result.is_err_i32(f) || take_i32(g) != 42) { return 2; }
  if (!is_ok_u8(u) || expect_u8_or_panic(u) != 9) { return 3; }

  let chained: Result<i32, i32> = map_i32(result.ok_i32(10), 20);
  if (take_i32(chained) != 20) { return 4; }
  return 0;
}
