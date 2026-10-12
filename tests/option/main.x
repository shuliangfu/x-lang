// See implementation.
const option = import("core.option");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* none and some write through an out pointer. u8 results stay u8. */
  let none_opt: Option_i32 = { is_some: false, value: 0 };
  let some_opt: Option_i32 = { is_some: false, value: 0 };
  option.none_i32(&none_opt);
  option.some_i32(&some_opt, 42);
  let a: i32 = option.unwrap_or_i32(none_opt, 10);
  let b: i32 = option.unwrap_or_i32(some_opt, 10);
  let s7: Option_i32 = { is_some: false, value: 0 };
  option.some_i32(&s7, 7);
  let c: i32 = option.expect_i32(s7);
  let su3: Option_u8 = { is_some: false, value: 0 as u8 };
  let nu: Option_u8 = { is_some: false, value: 0 as u8 };
  option.some_u8(&su3, 3 as u8);
  option.none_u8(&nu);
  let u1: u8 = option.unwrap_or_u8(su3, 0 as u8);
  let u2: u8 = option.unwrap_or_u8(nu, 5 as u8);
  if (!option.is_some_i32(some_opt) || option.is_none_i32(some_opt)) { return -1; }
  if (option.is_some_i32(none_opt) || !option.is_none_i32(none_opt)) { return -2; }
  let s99: Option_i32 = { is_some: false, value: 0 };
  let s99b: Option_i32 = { is_some: false, value: 0 };
  option.some_i32(&s99, 99);
  option.some_i32(&s99b, 99);
  let o1: Option_i32 = option.or_i32(none_opt, s99);
  let o2: Option_i32 = option.or_i32(some_opt, s99b);
  if (!option.is_some_i32(o1) || option.expect_i32(o1) != 99) { return -3; }
  if (option.expect_i32(o2) != 42) { return -4; }
  let s1: Option_i32 = { is_some: false, value: 0 };
  let s2: Option_i32 = { is_some: false, value: 0 };
  let n2: Option_i32 = { is_some: false, value: 0 };
  let s2b: Option_i32 = { is_some: false, value: 0 };
  option.some_i32(&s1, 1);
  option.some_i32(&s2, 2);
  option.none_i32(&n2);
  option.some_i32(&s2b, 2);
  let a1: Option_i32 = option.and_i32(s1, s2);
  let a2: Option_i32 = option.and_i32(n2, s2b);
  if (option.expect_i32(a1) != 2) { return -5; }
  if (option.is_some_i32(a2)) { return -6; }
  let nu2: Option_u8 = { is_some: false, value: 0 as u8 };
  let su10: Option_u8 = { is_some: false, value: 0 as u8 };
  option.none_u8(&nu2);
  option.some_u8(&su10, 10 as u8);
  let uo: Option_u8 = option.or_u8(nu2, su10);
  if (option.unwrap_or_u8(uo, 0 as u8) != (10 as u8)) { return -7; }
  let su6: Option_u8 = { is_some: false, value: 0 as u8 };
  option.some_u8(&su6, 6 as u8);
  let eu: u8 = option.expect_u8(su6);
  if (eu != (6 as u8)) { return -8; }
  let su1: Option_u8 = { is_some: false, value: 0 as u8 };
  let nu3: Option_u8 = { is_some: false, value: 0 as u8 };
  option.some_u8(&su1, 1 as u8);
  option.none_u8(&nu3);
  if (!option.is_some_u8(su1) || option.is_none_u8(su1)) { return -9; }
  if (option.is_some_u8(nu3) || !option.is_none_u8(nu3)) { return -10; }
  let su1b: Option_u8 = { is_some: false, value: 0 as u8 };
  let su2c: Option_u8 = { is_some: false, value: 0 as u8 };
  let nu4: Option_u8 = { is_some: false, value: 0 as u8 };
  let su2d: Option_u8 = { is_some: false, value: 0 as u8 };
  option.some_u8(&su1b, 1 as u8);
  option.some_u8(&su2c, 2 as u8);
  option.none_u8(&nu4);
  option.some_u8(&su2d, 2 as u8);
  let au1: Option_u8 = option.and_u8(su1b, su2c);
  let au2: Option_u8 = option.and_u8(nu4, su2d);
  if (!option.is_some_u8(au1) || option.expect_u8(au1) != (2 as u8)) { return -11; }
  if (option.is_some_u8(au2)) { return -12; }
  // map / and_then（eager）
  let sm3: Option_i32 = { is_some: false, value: 0 };
  let sm4: Option_u8 = { is_some: false, value: 0 as u8 };
  let at1: Option_i32 = { is_some: false, value: 0 };
  let at9: Option_i32 = { is_some: false, value: 0 };
  option.some_i32(&sm3, 3);
  option.some_u8(&sm4, 4 as u8);
  option.some_i32(&at1, 1);
  option.some_i32(&at9, 9);
  let m1: i32 = option.expect_i32(map_i32(sm3, 6));
  let mapped_u: Option_u8 = map_u8(sm4, 8 as u8);
  let m2: u8 = option.expect_u8(mapped_u);
  let at: i32 = option.expect_i32(and_then_i32(at1, at9));
  if (m1 != 6 || m2 != (8 as u8) || at != 9) { return -13; }
  // See implementation.
  let g: i32 = option.unwrap_or_i32(none_opt, 11);
  if (g != 11) { return -14; }
  // Option_ptr_u8
  let buf: u8[4] = [1, 2, 3, 4];
  let sp: Option_ptr_u8 = some_ptr_u8(buf);
  let mp: Option_ptr_u8 = map_ptr_u8(sp, buf);
  if (!is_some_ptr_u8(mp)) { return -15; }
  let bp: *u8 = expect_ptr_u8(mp);
  if (bp[0] != (1 as u8)) { return -16; }
  let extra: i32 = m1 + (m2 as i32) + at + g + (bp[0] as i32);
  return a + b + c + (u1 as i32) + (u2 as i32) + extra;
}
