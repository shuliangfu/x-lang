function main(): i32 {
  let line: u8[8] = [0, 0, 0, 10, 0, 0, 0, 0];
  let ptr: *u8 = &line[0];
  let off: i32 = 3;
  let v: i32 = 0;
  v = ptr[off];
  return v;
}
