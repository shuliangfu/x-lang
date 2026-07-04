// SIMD-S3 烟测：Vec8i local VAR+VAR mul 应走 vpmulld/pmulld（非 8 次标量 mul）。
function main(): i32 {
  let a: Vec8i = [2, 2, 2, 2, 2, 2, 2, 2];
  let b: Vec8i = [3, 3, 3, 3, 3, 3, 3, 3];
  let c: Vec8i = a * b;
  let z: Vec8i = c - c;
  let w: Vec8i = z + z;
  return 0;
}
