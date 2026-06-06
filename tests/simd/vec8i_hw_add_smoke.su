// SIMD-S3 烟测：Vec8i local VAR+VAR add 应走 vpaddd/paddd（非 8 次标量 add）。
function main(): i32 {
  let a: Vec8i = [1, 1, 1, 1, 1, 1, 1, 1];
  let b: Vec8i = [2, 2, 2, 2, 2, 2, 2, 2];
  let c: Vec8i = a + b;
  let z: Vec8i = c - c;
  let w: Vec8i = z + z;
  let v: Vec8i = w - w;
  return 0;
}
