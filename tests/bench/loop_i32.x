// loop_i32.x — 性能基线：累加循环（LCG 混合 s，Shu/C 均须真跑循环）
function main(): i32 {
  let n: i32 = 100000000;
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    let t: i32 = i * 1103515245 + 12345;
    s = s ^ t;
    i = i + 1;
  }
  return s;
}
