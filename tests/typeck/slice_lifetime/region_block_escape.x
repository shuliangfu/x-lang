// M-3 负例：region 块内 slice 赋给块外不同域变量
extern function slice_src(): i32[];

function main(): i32 {
  let outer: i32[]<rb> = unsafe { slice_src() };
  region ra {
    let inner: i32[]<ra> = unsafe { slice_src() };
    outer = inner;
  }
  return 0;
}
