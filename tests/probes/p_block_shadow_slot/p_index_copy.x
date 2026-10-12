// w2057: the else loop indexes two arrays with its own `k` (subscript path).
function f(n: i32): i32 {
  let s: i32 = 0;
  let si: i32 = 0;
  while (si < 1) {
    let a: u8[8] = [];
    a[0] = 1; a[1] = 2; a[2] = 3;
    let b: u8[8] = [];
    if (n > 100) {
      let k: i32 = 0;
      while (k < n) { b[k] = a[k]; k = k + 1; }
    } else {
      let k: i32 = 0;
      while (k < n) { b[k] = a[k]; k = k + 1; }
    }
    s = (b[0] as i32) + (b[1] as i32) * 10 + (b[2] as i32) * 100;
    si = si + 1;
  }
  return s;
}
function main(): i32 { return f(3) - 321; }
