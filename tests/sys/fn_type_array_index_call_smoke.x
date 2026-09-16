// 10.3.1 slice13: TYPE_FN array INDEX load + Cap indirect call.
// Root fix: array-lit elem store/INDEX stride must be 8B for TYPE_FN=18
// (prior 4B trunc → SEGV on blr). Expect run=42.
// PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

/**
 * INDEX a TYPE_FN array slot then Cap-call through the local.
 * @return i32 - 42 on success
 * PLATFORM: SHARED — Ubuntu gold asm path.
 */
function main(): i32 {
  let fs: [2]function(i32): i32 = [helper_add_one, helper_add_one];
  let g: function(i32): i32 = fs[0];
  return g(41);
}
