const qm = import("qm");
function main(): i32 {
  let v: V = qm.spv();
  if (v.length != 5) { return 1; }
  if (v.gen != 7) { return 2; }
  return 0;
}
