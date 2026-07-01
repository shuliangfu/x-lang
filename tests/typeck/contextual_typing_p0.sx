// P0 期望类型传播：赋值 / return / 实参 / struct 字段 / const / return struct 简写
allow(padding) struct Pair { a: i16; b: i32; }

extern function callee_u64(n: u64, m: i32): i32;

function ret_i64_neg(): i64 {
  return -1;
}

function ret_ternary_i32(n: i32): i64 {
  return n >= 0 ? n : -1;
}

function ret_struct(): Pair {
  return { a: 1, b: 2 };
}

function main(): i32 {
  let total: isize = 0;
  let nr: u32 = 0;
  let r: i64 = 0;
  const MAX: u32 = 8;
  let ffi_rc: i32 = 0;
  nr = 0;
  total = 0;
  let p: Pair = { a: 0, b: 1 };
  p.a = 1;
  r = ret_ternary_i32(3);
  if (ret_i64_neg() < 0) {
    return 1;
  }
  unsafe {
    ffi_rc = callee_u64(1, -1);
  }
  if (ffi_rc != 0) {
    return 2;
  }
  if (p.b != 1 || nr != 0 || total != 0 || MAX != 8) {
    return 3;
  }
  return 0;
}
