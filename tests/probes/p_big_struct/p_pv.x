allow(padding) struct V { ptr: *u8; length: i32; gen: u64; }
function mk(p: *u8, n: i32, g: u64): V { return { ptr: p, length: n, gen: g }; }
function wrap(p: *u8): V { return mk(p, 7, 99 as u64); }
function ok(v: V): i32 { if (v.ptr == 0 as *u8) { return 0; } if (v.gen != 99 as u64) { return 0; } return v.length; }
function main(): i32 {
  let s: *u8 = "ABC";
  let v: V = wrap(s);
  if (v.ptr != s) { return 1; }
  if (v.length != 7) { return 2; }
  if (v.gen != 99 as u64) { return 3; }
  if (ok(v) != 7) { return 4; }
  if (v.ptr[0] != 65) { return 5; }
  return 0;
}
