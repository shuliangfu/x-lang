// 切片 T[]：类型、从数组构造、下标 s[i]（变量类型与类型系统设计 §6.3）
function main(): i32 {
  let a: i32[4] = [10, 20, 30, 40];
  let s: i32[] = a;
  return s[1];
}
