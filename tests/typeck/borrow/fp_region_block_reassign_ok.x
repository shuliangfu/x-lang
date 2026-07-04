// TYPE-003 正例：同域 region 内重新赋值，不应误报 borrow/lifetime 冲突
extern function slice_src(): i32[];

function main(): i32 {
  region ra {
    let s: i32[] = slice_src();
    let t: i32[] = slice_src();
    t = s;
  }
  return 0;
}
