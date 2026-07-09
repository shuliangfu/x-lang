// UB 收窄：切片语义越界访问应 panic
// 注：array→slice 字面量 C emit 当前有 codegen 债；用指针下标等价覆盖越界 panic 路径。
function main(): i32 {
  let a: i32[2] = [10, 20];
  let p: *i32 = &a[0];
  return p[2];
}
