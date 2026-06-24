// SYN-01：let 初值支持 foo()[0] postfix 链
function foo(): u8[4] {
  return [1, 2, 3, 4];
}

function main(): i32 {
  let e: u8 = foo()[0];
  let f: u8 = foo()[1];
  if (e != 1 || f != 2) {
    return 1;
  }
  return 0;
}
