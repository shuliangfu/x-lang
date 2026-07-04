// SIMD-S3 烟测：while i<N { dst[i]=a[i]*b[i]; i+=1 } 应剥离为 vpmulld/pmulld。
function main(): i32 {
  let a: i32[8] = [2, 2, 2, 2, 2, 2, 2, 2];
  let b: i32[8] = [3, 3, 3, 3, 3, 3, 3, 3];
  let dst: i32[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let i: i32 = 0;
  while (i < 8) {
    dst[i] = a[i] * b[i];
    i += 1;
  }
  return dst[0] + dst[7];
}
