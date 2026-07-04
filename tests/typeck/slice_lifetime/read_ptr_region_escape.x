/** M-5 负例：read_ptr_slice 域绑定 slice 赋给未标注 u8[] 应逃逸报错 */
function read_ptr_slice(): u8[] {
  let buf: u8[1] = [0];
  return buf;
}

function main(): i32 {
  let s: u8[] = read_ptr_slice();
  return 0;
}
