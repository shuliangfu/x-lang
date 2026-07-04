/** 后缀数组/切片类型：u8[N]、u8[]、*u8[N]（C 风格，唯一写法）。 */
function main(): i32 {
  let a: u8[5] = [1, 2, 3, 4, 0];
  let s: u8[] = a;
  if (s.length != 5) {
    return 1;
  }
  let ps: *u8[2] = [0 as *u8, 0 as *u8];
  if (ps[0] != 0) {
    return 2;
  }
  return 0;
}
