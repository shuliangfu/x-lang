// M-3 负例：实参域与形参域不一致
function slice_src(): i32[] {
  let buf: i32[1] = [0];
  return buf;
}
function take_rb(x: i32[]<rb>): i32 { return 0; }

function main(): i32 {
  region ra {
    let s: i32[] = slice_src();
    take_rb(s);
  }
  return 0;
}
