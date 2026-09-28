// w1503 (终局待办 10.27): arm64 binop left-preserve homes must be inside the
// frame (they used to overwrite x19's save slot and the caller's fp/lr).
function f0(): i32 {
  let a: i32 = 1;
  return a * 1 + a * 2 + a * 3 + a * 4 + a * 5 + a * 6;
}
function f6(a1: i32, a2: i32, a3: i32, a4: i32, a5: i32, a6: i32): i32 {
  return a1 * 1 + a2 * 2 + a3 * 3 + a4 * 4 + a5 * 5 + a6 * 6;
}
function f2(a1: i32, a2: i32): i32 {
  return a1 * 1 + a2 * 2 + a1 * 3 + a2 * 4 + a1 * 5 + a2 * 6 + a1 * 7 + a2 * 8 + a1 * 9 + a2 * 10;
}
function g(x: i32): i32 {
  return x * 3 - 1;
}
function m(v: i32): i32 {
  return match v {
    1 => g(v) * 2 + g(v + 1) * 3 + g(v + 2) * 4;
    _ => v * 1 + v * 2 + v * 3;
  };
}
function main(): i32 {
  if (f0() != 21) {
    return 1;
  }
  if (f6(1, 2, 3, 4, 5, 6) != 91) {
    return 2;
  }
  if (f2(1, 2) != 85) {
    return 3;
  }
  if (f6(g(1), g(2), g(3), g(4), g(5), g(6)) * 1 + f2(g(1), g(2)) * 2 != 652) {
    return 4;
  }
  if (m(1) != 4 + 15 + 32) {
    return 5;
  }
  if (m(5) != 30) {
    return 6;
  }
  return 0;
}
