// UB 收窄：越界访问应 panic
// 指针下标 OOB 在 C 后端多平台不保证 trap；用数组动态下标走运行时 bounds 检查。
function main(): i32 {
  let a: i32[2] = [10, 20];
  let i: i32 = 2;
  return a[i];
}
