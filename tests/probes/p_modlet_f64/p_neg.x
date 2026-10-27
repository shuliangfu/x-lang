let GN: f64 = -1.5;
function getn(): f64 { return GN; }
function main(): i32 {
  let x: f64 = getn();
  if (x != -1.5) { return 1; }
  return 0;
}
