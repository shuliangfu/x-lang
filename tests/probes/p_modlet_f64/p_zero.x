let GZ: f64 = 0.0;
function main(): i32 {
  if (GZ != 0.0) { return 1; }
  GZ = 3.0;
  if (GZ != 3.0) { return 2; }
  return 0;
}
