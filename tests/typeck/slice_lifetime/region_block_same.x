// M-3 正例：region 块内未标注 T[] 继承域标签，同域赋值 OK
function slice_src(): i32[] {
  let buf: i32[1] = [0];
  return buf;
}

function main(): i32 {
  region ra {
    let a: i32[] = slice_src();
    let b: i32[] = slice_src();
    b = a;
  }
  return 0;
}
