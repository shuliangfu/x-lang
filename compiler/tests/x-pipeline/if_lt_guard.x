/** 探针：if (i < lim) return -1 应仅在 i<lim 时返回 -1 */
function main(): i32 {
  let i: i32 = 1;
  let lim: i32 = 64;
  if (i >= lim - 1) {
    return -1;
  }
  return 0;
}
