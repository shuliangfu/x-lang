let GZ: f32 = 0.0;
function bump(): void { GZ = GZ + 1.25; }
function main(): i32 {
  if (GZ != 0.0) { return 1; }
  bump(); bump();
  if (GZ != 2.5) { return 2; }
  return 0;
}
