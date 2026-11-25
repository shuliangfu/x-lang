let GF: f64 = 1.5;
function getf(): f64 { return GF; }
function main(): i32 {
  let x: f64 = getf();
  if (x != 1.5) { return 1; }
  return 0;
}
