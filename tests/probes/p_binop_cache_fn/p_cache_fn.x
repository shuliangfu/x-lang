// w1504: the binop VAR slot cache must not leak across functions.
// add2 leaves rbx = [rbp-0x18] (b); mul2 has b in the same slot and used to
// skip the load, multiplying by a stale rbx (x86_64). Exit 0 = pass.
function add2(a: i64, b: i64): i64 { return a + b; }
function mul2(a: i64, b: i64): i64 { return a * b; }
function sub2(a: i32, b: i32): i32 { return a - b; }
function main(): i32 {
  let e: i64 = mul2(100000, 100000);
  if (e / 1000 != 10000000) { return 1; }
  if (add2(1, 2) != 3) { return 2; }
  if (mul2(7, 6) != 42) { return 3; }
  if (sub2(50, 8) != 42) { return 4; }
  return 0;
}
