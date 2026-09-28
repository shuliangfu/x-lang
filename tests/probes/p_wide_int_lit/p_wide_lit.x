// w1504 (10.30): integer literals wider than 32 bits must keep all 64 bits,
// including CTFE call folds (typeck Cap residual). Exit 0 = pass.
function id(x: i64): i64 { return x; }
function add2(a: i64, b: i64): i64 { return a + b; }
function mul2(a: i64, b: i64): i64 { return a * b; }
function take(x: i64): i64 { return x / 1000; }
function big(): i64 { return 10000000000; }
function main(): i32 {
  let a: i64 = 10000000000;
  if (a / 1000000 != 10000) { return 1; }
  let n: i64 = -5000000000;
  if (n / 1000000 + 5000 != 0) { return 2; }
  let u: i64 = 4294967295;
  if (u - 4294967294 != 1) { return 3; }
  let m: i64 = 2147483648;
  if (m - 2147483647 != 1) { return 4; }
  let lo: i64 = -2147483649;
  if (lo + 2147483649 != 0) { return 5; }
  if (take(10000000000) != 10000000) { return 6; }
  if (big() / 1000000 != 10000) { return 7; }
  let c: i64 = id(10000000000);
  if (c / 1000000 != 10000) { return 8; }
  let d: i64 = add2(2000000000, 2000000000);
  if (d != 4000000000) { return 9; }
  let e: i64 = mul2(100000, 100000);
  if (e / 1000 != 10000000) { return 10; }
  let f: i64 = a + 20000000000;
  if (f / 1000000 != 30000) { return 11; }
  let g: i64 = id(-7000000000);
  if (g / 1000000 + 7000 != 0) { return 12; }
  let s: i32 = 2000000000;
  if (s / 1000 != 2000000) { return 13; }
  return 0;
}
