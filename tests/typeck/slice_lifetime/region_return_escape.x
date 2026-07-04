// M-3 负例：region 内域绑定 slice 作为未标注域返回值逃逸
function slice_src(): i32[] {
  let buf: i32[1] = [0];
  return buf;
}

function leak(): i32[] {
  region ra {
    let s: i32[] = slice_src();
    return s;
  }
}

function main(): i32 {
  return 0;
}
