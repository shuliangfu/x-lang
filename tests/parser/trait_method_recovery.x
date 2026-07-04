// 回归：trait 内部方法级同步恢复——坏方法各自报错，好方法与后续 function 不受影响。
trait Bad {
  function ok1(self): i32;
  function bad(self) i32;
  function ok2(self): u64;
}

function good(): i32 {
  return 0;
}
