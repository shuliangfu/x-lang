let GA: f32 = 1.5;
let GB: f32 = 4.0;
function addb(): void { GA += GB; }
function main(): i32 {
  addb();
  if (GA != 5.5) { return 1; }
  GA -= 0.5;
  if (GA != 5.0) { return 2; }
  return 0;
}
