// MOD-02：#[repr(compatible)] 允许同布局不同名 struct 指针实参互认
#[repr(compatible)]
allow(padding) struct PairA { a: i32; b: i32; }

#[repr(compatible)]
allow(padding) struct PairB { a: i32; b: i32; }

function take_b(_p: *PairB): i32 {
  return 0;
}

function main(): i32 {
  let x: PairA = PairA { a: 3, b: 4 };
  take_b(&x);
  return 0;
}
