// 7.3：arr[1]=右值 字面量下标 INDEX 赋值应 lea/add→rbx，勿 mov x2 暂存（run-asm-assign-index-lit.sh）。
function main(): i32 {
  let arr: i32[3] = [5, 10, 15];
  arr[1] = 99;
  return arr[1];
}
