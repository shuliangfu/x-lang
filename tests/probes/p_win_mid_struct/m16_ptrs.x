struct S { ptr: *u8, n: i64 }
function mk(p: *u8, n: i64): S { return { ptr: p, n: n }; }
function first(s: S): i32 { return s.ptr[0] as i32; }
function main(): i32 {
  let s: S = mk("ABC", 3);
  if (s.n != 3) { return 1; }
  if (s.ptr[1] != 66) { return 2; }
  if (first(s) != 65) { return 3; }
  return 0;
}
