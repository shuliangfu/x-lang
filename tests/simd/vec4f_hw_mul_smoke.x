// SIMD-S3 烟测：Vec4f local VAR+VAR mul 应走 mulps（非 4 次标量 mul）。
function main(): i32 {
  let a: Vec4f = [2.0, 2.0, 2.0, 2.0];
  let b: Vec4f = [3.0, 3.0, 3.0, 3.0];
  let c: Vec4f = a * b;
  let z: Vec4f = c - c;
  return 0;
}
