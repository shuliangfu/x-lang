// M-3 正例：同域 slice 赋值应通过 typeck
function slice_src(): i32[] {
  let buf: i32[1] = [0];
  return buf;
}

function main(): i32 {
  let x: i32[]<ra> = slice_src();
  let y: i32[]<ra> = slice_src();
  y = x;
  return 0;
}
