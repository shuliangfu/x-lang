let GF: f32 = 3.0;
function scale(): f32 { return GF * GF + 1.0; }
function main(): i32 {
  let g: f32 = GF;
  if (g / 2.0 != 1.5) { return 1; }
  if (scale() != 10.0) { return 2; }
  if (GF < 2.0) { return 3; }
  return 0;
}
