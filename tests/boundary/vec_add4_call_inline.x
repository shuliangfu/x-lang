// vec_add4_call_inline.x — let c = vec_add4(a,b) 应逐 lane 内联，_main 无 bl
/** 两形参向量加法，供 CALL 内联 fold。 */
function vec_add4(a: i32x4, b: i32x4): i32x4 {
  return a + b;
}

function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let b: i32x4 = [10, 20, 30, 40];
  let c: i32x4 = vec_add4(a, b);
  let expect: i32x4 = [11, 22, 33, 44];
  let d: i32x4 = c - expect;
  let z: i32x4 = d - d;
  return 0;
}
