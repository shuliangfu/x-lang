let GN: f32 = -2.5;
function main(): i32 {
  if (GN != -2.5) { return 1; }
  GN = GN * 2.0;
  if (GN != -5.0) { return 2; }
  return 0;
}
