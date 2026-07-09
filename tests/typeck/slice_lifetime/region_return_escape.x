// M-3 负例：region 内域绑定 slice 作为未标注域返回值逃逸
extern function slice_src(): i32[];

function leak(): i32[] {
  region ra {
    let s: i32[]<ra> = unsafe { slice_src() };
    return s;
  }
  return unsafe { slice_src() };
}

function main(): i32 {
  return 0;
}
