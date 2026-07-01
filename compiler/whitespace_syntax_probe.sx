function callee(): i32 {
  return 7;
}

function callee_spaced (): i32 {
  return callee();
}

function main (): i32 {
  if (1 != 0) {
    return callee_spaced();
  }
  return callee();
}
