// MOD-02 负例：同布局但未标 #[repr(compatible)] 时 *PairC 不可传给 *PairA
#[repr(compatible)]
allow(padding) struct PairA { a: i32; b: i32; }

allow(padding) struct PairC { a: i32; b: i32; }

function take_a(_p: *PairA): i32 {
  return 0;
}

function main(): i32 {
  let c: PairC = PairC { a: 1, b: 2 };
  take_a(&c);
  return 0;
}
