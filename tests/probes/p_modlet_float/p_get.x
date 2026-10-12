let GF: f32 = 1.5;
function getf(): f32 { return GF; }
function main(): i32 {
  let x: f32 = getf();
  if (x != 1.5) { return 1; }
  return 0;
}
