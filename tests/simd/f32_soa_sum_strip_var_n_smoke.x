/**
 * SIMD f32 SoA 列 reduce 可变 n 条带烟测：let n=12 → 8 向量 + 4 标量 epilogue → exit=12。
 */
struct Particle soa {
  x: f32
  y: f32
  z: f32
}

function main(): i32 {
  let n: i32 = 12;
  let arr: Particle[16] = [];
  let i: i32 = 0;
  while (i < n) {
    arr[i].x = 1.0;
    i = i + 1;
  }
  let s: f32 = 0.0;
  i = 0;
  while (i < n) {
    s = s + arr[i].x;
    i = i + 1;
  }
  return s as i32;
}
