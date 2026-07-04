// 回归：impl 内部方法级同步恢复——坏方法各自报错，好方法与后续 function 不受影响。
trait Dub { function dub(self): i32; }
impl Dub for i32 {
  function ok1(self: i32): i32 { return self * 2; }
  function bad(self i32): i32 { return self; }
  function ok2(self: i32): i32 { return self + 1; }
}

function good(): i32 {
  return 0;
}
