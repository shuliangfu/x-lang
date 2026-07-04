// MEM-B0：多 return 出口 + defer（触发 goto cleanup 路径）。
function pick(v: i32): i32 {
  let acc: i32 = 0;
  defer { acc = acc + 1; }
  if (v == 1) {
    return 10;
  }
  if (v == 2) {
    return 20;
  }
  return acc;
}

function main(): i32 {
  let a: i32 = pick(1);
  let b: i32 = pick(2);
  return a + b;
}
