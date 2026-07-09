/** M-5 负例：read_ptr 域 slice 赋给未标注域 */
extern function read_ptr_slice(): u8[];

function main(): i32 {
  let s: u8[] = unsafe { read_ptr_slice() };
  return 0;
}
