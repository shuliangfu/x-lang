/** usize 算术/比较：无类型整数字面量可省略 as（左操作数 usize 时 1/0 默认 i32 即可参与 ±&!=）。 */
function mask_of(align_bytes: usize): usize {
  let mask: usize = align_bytes - 1;
  if ((align_bytes & mask) != 0) { return 0; }
  return mask;
}

function main(): i32 {
  if (mask_of(8) != 7) { return 1; }
  if (mask_of(7) != 0) { return 2; }
  return 0;
}
