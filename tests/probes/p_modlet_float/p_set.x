let GF: f32 = 1.5;
function setf(): void { GF = 2.5; }
function main(): i32 {
  if (GF != 1.5) { return 1; }
  setf();
  if (GF != 2.5) { return 2; }
  return 0;
}
