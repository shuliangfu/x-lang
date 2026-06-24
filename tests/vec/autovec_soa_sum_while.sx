// VEC-V3：SoA f32 字段列 while 归约烟测；codegen 替换为 shux_autovec_sum_f32_strided。
struct Particle soa {
  x: f32
  y: f32
  z: f32
}

function main(): i32 {
  let arr: Particle[4] = [];
  let k: i32 = 0;
  while (k < 4) {
    arr[k].x = (k + 1) as f32;
    k = k + 1;
  }
  let s: f32 = 0.0;
  let i: i32 = 0;
  while (i < 4) {
    s = s + arr[i].x;
    i = i + 1;
  }
  /* 1+2+3+4 = 10 */
  if (s < 9.99 || s > 10.01) {
    return 1;
  }
  return 0;
}
