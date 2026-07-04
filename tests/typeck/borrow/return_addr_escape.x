// MEM-A3 负例：return 局部变量地址（scope borrow 逃逸）。
function leak(): *i32 {
  let x: i32 = 42;
  return &x;
}

function main(): i32 {
  return 0;
}
