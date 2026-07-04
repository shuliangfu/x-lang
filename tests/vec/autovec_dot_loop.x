// VEC-V1：loop autovec f32 点积烟测；codegen 替换 for 为 shux_autovec_dot_f32。
/** 双指针 f32 点积（BCE + autovec 受限模式）。 */
function dot_f32(n: i32, ap: *f32, bp: *f32): f32 {
  let s: f32 = 0.0;
  for (let i: i32 = 0; i < n; i = i + 1) {
    s = s + ap[i] * bp[i];
  }
  return s;
}

function main(): i32 {
  let x: f32[4] = [1.0, 2.0, 3.0, 4.0];
  let y: f32[4] = [1.0, 1.0, 1.0, 1.0];
  let d: f32 = dot_f32(4, &x[0], &y[0]);
  /* 1+2+3+4 = 10 */
  if (d < 9.99 || d > 10.01) {
    return 1;
  }
  return 0;
}
