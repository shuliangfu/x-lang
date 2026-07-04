/** M-5 正例：read_ptr_slice 自动绑 io_read_ptr 域，赋给同域变量 OK */
function read_ptr_slice(): u8[] {
  let buf: u8[1] = [0];
  return buf;
}

function main(): i32 {
  let s: u8[]<io_read_ptr> = read_ptr_slice();
  return 0;
}
