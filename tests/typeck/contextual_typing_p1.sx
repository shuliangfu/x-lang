// P1 期望类型：指针 null、下标 i32、match 多字面量、struct ; 分隔、&buf[0] decay
allow(padding) struct Pair { a: i16; b: i32; }

function ret_null(): *u8 {
  return 0;
}

function match_multi(v: i32): i32 {
  return match v {
    1 | 2 | 3 => 10;
    _ => 0;
  };
}

function main(): i32 {
  let buf: u8[4] = [1, 2, 3, 4];
  let i: i32 = 0;
  let c: u8 = buf[i];
  let p: Pair = { a: 1; b: 2 };
  let q: *u8 = 0;
  let addr: *u8 = &buf[0];
  let off: *u8 = addr + i;
  if (off[0] != 1) {
    return 5;
  }
  if (q == 0) {
    if (addr == 0) {
      return 1;
    }
    if (ret_null() != 0) {
      return 2;
    }
    if (match_multi(2) != 10) {
      return 3;
    }
    if (c != 1 || p.a != 1 || p.b != 2) {
      return 4;
    }
  }
  return 0;
}
