// MEM-A3 负例：内层 region 中 &local 赋给外层变量。
function main(): i32 {
  let save: *i32 = 0 as *i32;
  region inner {
    let x: i32 = 7;
    save = &x;
  }
  return 0;
}
