// M-3 负例：region 块内 slice 赋给块外不同域变量
function slice_src(): i32[] {
  let buf: i32[1] = [0];
  return buf;
}

function main(): i32 {
  let outer: i32[]<rb> = slice_src();
  region ra {
    let inner: i32[] = slice_src();
    outer = inner;
  }
  return 0;
}
