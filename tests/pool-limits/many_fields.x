// struct layout field grow 池：字段数超过旧 8/64 扫描硬顶；返回末字段 f19。
struct Wide {
  f0: i32
  f1: i32
  f2: i32
  f3: i32
  f4: i32
  f5: i32
  f6: i32
  f7: i32
  f8: i32
  f9: i32
  f10: i32
  f11: i32
  f12: i32
  f13: i32
  f14: i32
  f15: i32
  f16: i32
  f17: i32
  f18: i32
  f19: i32
}

function main(): i32 {
  let w: Wide = Wide {
    f0: 0, f1: 1, f2: 2, f3: 3, f4: 4, f5: 5, f6: 6, f7: 7, f8: 8, f9: 9,
    f10: 10, f11: 11, f12: 12, f13: 13, f14: 14, f15: 15, f16: 16, f17: 17, f18: 18, f19: 19
  };
  return w.f19;
}
