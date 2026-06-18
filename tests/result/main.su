// CORE-003：Result 类型族 + map/and_then/or_else 烟测
const result = import("core.result");

function main(): i32 {
  let ok_r: Result_i32 = result.ok_i32(42);
  let err_r: Result_i32 = result.err_i32(7);
  let a: i32 = result.unwrap_or_i32(ok_r, 0);
  let b: i32 = result.unwrap_or_i32(err_r, 0);
  let c: i32 = result.expect_i32(result.ok_i32(3), 0);
  let d: i32 = result.expect_i32_or_panic(result.ok_i32(5));
  if (!result.is_ok_i32(ok_r) || result.is_err_i32(ok_r)) { return -1; }
  if (result.is_ok_i32(err_r) || !result.is_err_i32(err_r)) { return -2; }
  let o1: Result_i32 = result.or_i32(err_r, result.ok_i32(99));
  let o2: Result_i32 = result.or_i32(ok_r, result.ok_i32(99));
  if (!result.is_ok_i32(o1) || result.expect_i32_or_panic(o1) != 99) { return -3; }
  if (result.expect_i32_or_panic(o2) != 42) { return -4; }
  let a1: Result_i32 = result.and_i32(result.ok_i32(1), result.ok_i32(2));
  let a2: Result_i32 = result.and_i32(result.err_i32(10), result.ok_i32(2));
  if (result.expect_i32_or_panic(a1) != 2) { return -5; }
  if (result.is_ok_i32(a2)) { return -6; }
  // map / and_then / or_else
  let mv: i32 = result.expect_i32_or_panic(map_i32(result.ok_i32(10), 20));
  let cv: i32 = result.expect_i32_or_panic(and_then_i32(result.ok_i32(1), result.ok_i32(2)));
  let ov: i32 = result.expect_i32_or_panic(or_else_i32(result.err_i32(1), result.ok_i32(88)));
  if (mv != 20 || cv != 2 || ov != 88) { return -7; }
  // Result_u8
  let ru: Result_u8 = ok_u8(7);
  let mu: u8 = expect_u8_or_panic(map_u8(ru, 9));
  let ou: u8 = unwrap_or_u8(or_else_u8(err_u8(1), ok_u8(4)), 0);
  if (mu != 9 || ou != 4) { return -8; }
  let extra: i32 = mv + cv + ov + (mu as i32) + (ou as i32);
  return a + b + c + d + extra;
}
