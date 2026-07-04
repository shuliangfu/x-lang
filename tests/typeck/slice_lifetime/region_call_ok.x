// M-3 正例：实参与形参同域
function slice_src(): i32[] {
  let buf: i32[1] = [0];
  return buf;
}
function take_ra(x: i32[]<ra>): i32 { return 0; }

function main(): i32 {
  region ra {
    let s: i32[] = slice_src();
    take_ra(s);
  }
  return 0;
}
