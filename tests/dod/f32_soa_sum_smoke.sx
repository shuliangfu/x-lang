/**
 * DOD f32 SoA 列扫描 smoke：arr[i].x 累加须走 SSE addss（非整数 add）。
 * 1+2+3+4=10 → main 返回 10（f32 as i32 + cvttss2si）。
 */
struct Particle soa {
  x: f32
  y: f32
  z: f32
}

function main(): i32 {
  let arr: Particle[4] = [];
  let v0: f32 = 1.0;
  let v1: f32 = 2.0;
  let v2: f32 = 3.0;
  let v3: f32 = 4.0;
  arr[0].x = v0;
  arr[1].x = v1;
  arr[2].x = v2;
  arr[3].x = v3;
  let s: f32 = 0.0;
  let i: i32 = 0;
  while (i < 4) {
    s = s + arr[i].x;
    i = i + 1;
  }
  return s as i32;
}
