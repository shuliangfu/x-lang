// w1503 (终局待办 10.31): five i64 locals must not share the arm64 x19 save
// slot. Expect exit 0.
function k(x: i64): i64 {
  let a: i64 = x + 1;
  let b: i64 = x + 2;
  let c: i64 = x + 3;
  let d: i64 = x + 4;
  let e: i64 = x + 5;
  return a + b * 2 + c * 3 + d * 4 + e * 5;
}
function main(): i32 {
  let i: i64 = 0;
  let s: i64 = 0;
  while (i < 10) {
    s = s + k(i) * (i + 1);
    i = i + 1;
  }
  if (s != 7975) {
    return 1;
  }
  if (k(100000) * 2 + k(7) * 3 != 3000590) {
    return 2;
  }
  return 0;
}
