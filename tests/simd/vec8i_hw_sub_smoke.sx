// SIMD-S3 烟测：Vec8i local VAR+VAR sub 应走 vpsubd/psubd（非 8 次标量 sub）。
function main(): i32 {
  let a: Vec8i = [10, 10, 10, 10, 10, 10, 10, 10];
  let b: Vec8i = [1, 2, 3, 4, 5, 6, 7, 8];
  let c: Vec8i = a - b;
  let z: Vec8i = c - c;
  let w: Vec8i = z - z;
  return 0;
}
