// w1509 (终局待办 10.32): nested struct fields (o.i.a).
// Before w1509 Darwin and Windows reported CG002 (the field-assign body only
// took plain `=`). Exit 0 when right; a non-zero code names the first wrong check.
struct In { a: i32, b: i32 }
struct Out { k: i64, i: In }
function main(): i32 {
  let o: Out = Out { k: 7, i: In { a: 1, b: 2 } };
  o.i.a += 40;
  if (o.i.a != 41) { return 1; }
  o.i.b *= 21;
  if (o.i.b != 42) { return 2; }
  o.k -= 7;
  if (o.k != 0) { return 3; }
  return 0;
}
