// w1509 (终局待办 10.32): f64, u16, u8 and i8 fields; |=, &=, <<=.
// Before w1509 Darwin and Windows reported CG002 (the field-assign body only
// took plain `=`). Exit 0 when right; a non-zero code names the first wrong check.
struct B { e: f64, d: i32, d2: i32 }
struct U { c: u16, c2: u16 }
struct Q { a: u8, a2: u8, a3: u8, a4: u8 }
struct R { b: i8, b2: i8, b3: i8, b4: i8 }
function main(): i32 {
  let s: B = B { e: 1.25, d: 0, d2: 0 };
  let u: U = U { c: 65530, c2: 0 };
  let q: Q = Q { a: 250, a2: 0, a3: 0, a4: 0 };
  let r: R = R { b: 0 - 100, b2: 0, b3: 0, b4: 0 };
  q.a += 10;
  if (q.a != 4) { return 1; }
  r.b -= 20;
  if (r.b != 0 - 120) { return 2; }
  u.c -= 10;
  if (u.c != 65520) { return 3; }
  s.e *= 4.0;
  if (s.e != 5.0) { return 4; }
  s.d |= 12;
  s.d &= 10;
  if (s.d != 8) { return 5; }
  s.d <<= 2;
  if (s.d != 32) { return 6; }
  // r.b2 is not checked: on Linux x86_64 i8 struct fields are laid out at a
  // 4-byte stride and stored 8 bytes wide, even for plain `r.b = ..`
  // (pre-existing, 终局待办 10.44).
  if (q.a2 != 0 || u.c2 != 0 || s.d2 != 0) { return 7; }
  return 0;
}
