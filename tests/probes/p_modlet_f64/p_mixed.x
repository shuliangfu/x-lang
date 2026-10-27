let GI: i32 = 7;
let GF: f64 = 1.5;
function touch(): void { GI = GI + 1; GF = GF + 1.0; }
function main(): i32 {
  touch();
  if (GI != 8) { return 1; }
  if (GF != 2.5) { return 2; }
  return 0;
}
