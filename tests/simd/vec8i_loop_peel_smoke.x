// SIMD-S3 烟测：while i<N { dst[i]=a[i]+b[i]; i=i+1 } 应剥离为 vpaddd/paddd（非 8 次标量 add）。
function main(): i32 {
  let a: i32[8] = [1, 2, 3, 4, 5, 6, 7, 8];
  let b: i32[8] = [10, 20, 30, 40, 50, 60, 70, 80];
  let dst: i32[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let i: i32 = 0;
  while (i < 8) {
    dst[i] = a[i] + b[i];
    i = i + 1;
  }
  return dst[0] + dst[7];
}
