/** M-5 负例：read_ptr 域与显式不同域不匹配 */
extern function read_ptr_slice(): u8[];

function main(): i32 {
  let s: u8[]<other> = unsafe { read_ptr_slice() };
  return 0;
}
