struct P { a: i64, b: i64 }
allow(padding) struct T { a: i64, b: i32 }
extern "C" function c_mk(x: i64): P;
extern "C" function c_sum(s: P): i64;
extern "C" function c_mk12(x: i64, y: i32): T;
extern "C" function c_sum12(k1: i64, k2: i64, k3: i64, k4: i64, t: T): i64;
extern "C" function c_calls_x(): i32;
export function x_mk(x: i64): P { return P { a: x, b: x * 2 }; }
export function x_sum(s: P, k: i64): i64 { return s.a * 100 + s.b + k; }
export function x_mk12(x: i64): T { return T { a: x, b: 77 }; }
function main(): i32 {
 unsafe {
  let p: P = c_mk(5);
  if (p.a != 5) { return 1; }
  if (p.b != 6) { return 2; }
  if (c_sum(p) != 56) { return 3; }
  if (c_sum(c_mk(1)) != 12) { return 4; }
  let t: T = c_mk12(8, 9);
  if (t.a != 8) { return 5; }
  if (t.b != 9) { return 6; }
  if (c_sum12(1, 1, 1, 1, t) != 813) { return 7; }
  let r: i32 = c_calls_x();
  if (r != 0) { return 10 + r; }
  return 0;
 }
}
