// 回归：enum 内部变体级同步恢复——坏变体各自报错，好变体与后续 function 不受影响。
enum Bad {
  A,
  123,
  B,
  @,
  C,
}

function good(): i32 {
  return 0;
}
