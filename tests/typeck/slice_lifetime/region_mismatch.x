// M-3 负例：跨域 slice 赋值须 typeck 报错（i32[]<ra> → i32[]<rb>）
function slice_src(): i32[] {
  let buf: i32[1] = [0];
  return buf;
}

function main(): i32 {
  let x: i32[]<ra> = slice_src();
  let y: i32[]<rb> = x;
  return 0;
}
