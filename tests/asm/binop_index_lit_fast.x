// 7.3：字面量下标 INDEX binop 用 add_imm，不经 rbx/x2 暂存（run-asm-binop-index-lit.sh）。
function main(): i32 {
  let arr: u8[3] = [10, 20, 30];
  let c: i32 = 5;
  /** arr[1] + c = 25 */
  let f: i32 = arr[1] as i32 + c;
  /** arr[1] + arr[2] = 50 */
  let g: i32 = arr[1] as i32 + arr[2] as i32;
  return f + g;
}
