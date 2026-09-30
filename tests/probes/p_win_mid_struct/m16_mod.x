const qm16 = import("qm16");
function main(): i32 {
  let s: *u8 = "ABC";
  let a: OP = qm16.some_p(s);
  if (!qm16.is_some_p(a)) { return 1; }
  if (qm16.get_p(a) != s) { return 2; }
  let b: OP = qm16.map_p(a, s);
  if (!qm16.is_some_p(b)) { return 3; }
  let n: OP = qm16.none_p();
  if (qm16.is_some_p(n)) { return 4; }
  let buf: u8[4] = [1, 2, 3, 4];
  let c: OP = some_p(buf);
  let d: OP = map_p(c, buf);
  let q: *u8 = get_p(d);
  if (q[0] != 1) { return 5; }
  return 0;
}
