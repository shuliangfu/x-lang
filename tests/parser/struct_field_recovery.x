// 回归：struct 内部字段级同步恢复——两个坏字段各自报错，好字段与后续 function 不受影响。
struct Bad {
  a: i32;
  : i32;
  : u64;
  d: i32;
}

function good(): i32 {
  return 0;
}
