// 10.3.1: TYPE_FN host-C repr — `uint8_t *` (Cap opaque ABI) via -E.
// Acceptance: -E succeeds (no CG003). Full Ret(*)(args) + call-cast residual.
// PLATFORM: SHARED host-C.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  let f: function(i32): i32 = helper_add_one;
  return f(41);
}
