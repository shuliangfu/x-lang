// 10.3.1 slice16: opaque Cap→TYPE_FN assign hard-reject (no provenance).
// Expect typeck fail (build≠0). Escape hatch is `as function(...)`.
// PLATFORM: SHARED.

function main(): i32 {
  let c: *u8 = 0 as *u8;
  let f: function(i32): i32 = c;
  return f(41);
}
