/** M-5 负例：read_ptr_slice 域与声明域不一致 */
function read_ptr_slice(): u8[] {
  let buf: u8[1] = [0];
  return buf;
}

function main(): i32 {
  let s: u8[]<other> = read_ptr_slice();
  return 0;
}
