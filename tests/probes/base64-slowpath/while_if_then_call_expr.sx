function tick(x: i32): i32 {
  return x;
}

function while_if_then_call_expr(n: i32): i32 {
  let i: i32 = 0;
  while (i < n) {
    let ok: bool = true;
    if (!ok) {
      return -1;
    }
    tick(i);
    i = i + 1;
  }
  return 0;
}

function main(): i32 {
  return while_if_then_call_expr(8);
}
