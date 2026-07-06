/** 指针算术：*T + i32；解引用赋值 *p = v 须 unsafe。 */
function write_back(out_len: *i32): void {
  unsafe { *out_len = 42; }
}

function main(): i32 {
  let buf: u8[8] = [1, 2, 3, 4, 0, 0, 0, 0];
  let out: *u8 = &buf[0];
  let n: i32 = 2;
  let p: *u8 = out + n;
  unsafe {
    if (p[0] != 3) {
      return 1;
    }
  }
  let len: i32 = 0;
  write_back(&len);
  if (len != 42) {
    return 2;
  }
  return 0;
}
