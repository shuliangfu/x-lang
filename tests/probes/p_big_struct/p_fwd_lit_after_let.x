allow(padding) struct V { ptr: *u8; length: i32; gen: u64; }
function pv(h: usize, t: u32): V {
  let p: *u8 = h as *u8;
  let n: i32 = t as i32;
  let g: u64 = 7;
  return { ptr: p, length: n, gen: g };
}
function spv(): V { return pv(64 as usize, 5 as u32); }
function main(): i32 {
  let v: V = spv();
  if (v.length != 5) { return 1; }
  if (v.gen != 7) { return 2; }
  return 0;
}
