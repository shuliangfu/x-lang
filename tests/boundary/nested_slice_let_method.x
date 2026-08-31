// Same-layer twin of nested_slice_let_call: METHOD_CALL returning [N]T.
// Let-init must wrap TYPE_ARRAY return, not wave409 reent (`__xlang_sp = xs(w)`).
// Expected: compile = 0, run = 43.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C / asm emit.

struct W { n: i32 }
impl W {
  /**
   * Return a two-element i32 array. ARRAY return ABI is E*.
   * @param self W — receiver (unused payload)
   * @return [2]i32 — payload {1, 2}
   */
  function xs(self: W): [2]i32 {
    return [1, 2];
  }
}

/**
 * Exit 43 when dest-SLICE let of METHOD_CALL wrap is live.
 * @return i32 — s[0]+s[1]+40
 */
function main(): i32 {
  let w: W = { n: 0 };
  let s: []i32 = w.xs();
  return s[0] + s[1] + 40;
}
