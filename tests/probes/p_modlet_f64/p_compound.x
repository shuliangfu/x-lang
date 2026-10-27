let GC: f64 = 1.0;
function bump(): void { GC = GC + 2.0; }
function main(): i32 {
  bump();
  if (GC != 3.0) { return 1; }
  return 0;
}
