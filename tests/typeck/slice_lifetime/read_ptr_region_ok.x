/** M-5 正例：read_ptr_slice 自动绑 io_read_ptr 域，赋给同域变量 OK */
extern function read_ptr_slice(): u8[];

function main(): i32 {
  let s: u8[]<io_read_ptr> = unsafe { read_ptr_slice() };
  return 0;
}
