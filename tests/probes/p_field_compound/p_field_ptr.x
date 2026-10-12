// w1509 (终局待办 10.32): fields through a pointer (local pointer and a pointer parameter).
// Before w1509 Darwin and Windows reported CG002 (the field-assign body only
// took plain `=`). Exit 0 when right; a non-zero code names the first wrong check.
struct P { y: i64, x: i32, f: f32 }
function bump(q: *P, k: i32): i32 {
  q.x += k;
  q.y *= 2;
  q.f -= 0.5;
  return q.x;
}
function main(): i32 {
  let p: P = P { y: 21, x: 5, f: 2.0 };
  let r: *P = &p;
  r.x += 10;
  if (p.x != 15) { return 1; }
  if (bump(&p, 3) != 18) { return 2; }
  if (p.y != 42) { return 3; }
  if (p.f != 1.5) { return 4; }
  return 0;
}
