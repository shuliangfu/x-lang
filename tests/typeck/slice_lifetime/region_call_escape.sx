// M-3 负例：域绑定实参传给未标注域形参（逃逸）
function slice_src(): i32[] {
  let buf: i32[1] = [0];
  return buf;
}
function take_unbound(x: i32[]): i32 { return 0; }

function main(): i32 {
  region ra {
    let s: i32[] = slice_src();
    take_unbound(s);
  }
  return 0;
}
