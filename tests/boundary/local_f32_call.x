// Local same-module CALL with scalar f32 formal (GP-in on AAPCS64).
// Param home holds native f32 bits when XLANG_ABI_F32_XMM is default-on;
// load must be a 4B lane, not cvtsd2ss of those bits as f64.
// PLATFORM: SHARED — Ubuntu gold; Darwin AAPCS64 is the red face (s2 fill4).

/**
 * Identity: return the f32 formal unchanged.
 * @param x f32 — incoming formal
 * @return f32 — x
 */
function idf(x: f32): f32 {
  return x;
}

/**
 * Add a stamped FLOAT_LIT to the f32 formal (body uses the param slot).
 * @param x f32 — incoming formal
 * @return f32 — x + 1.0
 */
function add1(x: f32): f32 {
  return x + 1.0;
}

/**
 * Local f32 CALL ABI: lit / VAR pass / param-body add / identity.
 * @return i32 — 0 on success; 1..3 name the failed assertion
 */
function main(): i32 {
  let a: f32 = idf(1.0);
  if (a != 1.0) { return 1; }
  let b: f32 = 2.0;
  let c: f32 = idf(b);
  if (c != 2.0) { return 2; }
  let d: f32 = add1(2.0);
  if (d != 3.0) { return 3; }
  return 0;
}
