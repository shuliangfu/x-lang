let GI: i32 = 7;
let GF: f32 = 0.75;
let GP: i32 = 3;
function setall(): void { GI = 9; GF = 0.25; GP = 11; }
function main(): i32 {
  if (GI != 7) { return 1; }
  if (GF != 0.75) { return 2; }
  if (GP != 3) { return 3; }
  setall();
  if (GI != 9) { return 4; }
  if (GF != 0.25) { return 5; }
  if (GP != 11) { return 6; }
  return 0;
}
