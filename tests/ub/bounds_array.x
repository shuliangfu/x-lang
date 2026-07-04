// UB 收窄：数组越界访问应 panic
function main(): i32 {
  let a: i32[2] = [10, 20];
  return a[3];
}
