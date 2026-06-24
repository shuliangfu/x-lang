/** 探针：*u8 指针下标读 u8 与换行跳格（seed asm）。 */
function main(): i32 {
  let line: u8[8] = [99, 100, 101, 10, 0, 0, 0, 0];
  let ptr: *u8 = &line[0];
  let offset: i32 = 3;
  if (ptr[offset] == 10) { return 77; }
  return 33;
}
