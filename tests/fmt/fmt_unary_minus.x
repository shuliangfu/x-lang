// fmt 一元负号回归：return -1 / let x = -1 / neg(-1) 须保持紧贴；
// 二元 a - 1 须两侧空格。一元 - 不可被误判为二元而拆开。

function neg(i: i32): i32 {
  return -i;
}

function main(): i32 {
  let a: i32 = -1;
  let b: i32 = a - 1;
  let c: i32 = neg(-1);
  if (a < 0) {
    return -1;
  }
  return b + c;
}
