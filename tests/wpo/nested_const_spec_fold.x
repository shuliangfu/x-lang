// nested_const_spec_fold.x — WPO-S2 nested pure call-site CTFE pre-emit
// g(3) (1-param pure) then f(g(3),4) (2-param pure) must fold; main → return 0.

/** 1-param pure: return p0 + lit */
function g(x: i32): i32 {
  return x + 1;
}

/** 2-param pure: return p0 * p1 */
function f(a: i32, b: i32): i32 {
  return a * b;
}

function main(): i32 {
  return f(g(3), 4) - 16;
}
