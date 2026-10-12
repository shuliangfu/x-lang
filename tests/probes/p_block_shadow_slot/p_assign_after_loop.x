// w2057: `k` in the else branch shadows a same-named `k` in the then branch.
// The inner while body and the `s = k` after it must use the else slot.
function f(n: i32): i32 {
  let s: i32 = 0;
  let si: i32 = 0;
  while (si < 1) {
    if (n > 100) {
      let k: i32 = 0;
      s = k;
    } else {
      let k: i32 = 0;
      while (k < n) { k = k + 1; }
      s = k;
    }
    si = si + 1;
  }
  return s;
}
function main(): i32 { return f(3) - 3; }
