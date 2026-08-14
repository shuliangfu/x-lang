// Dep-module callee for dest-SLICE CALL rows.
// Same-layer twin of nested_slice_lit_call: mk lives in this file so
// resolved_dep_index >= 0 and N is on the dep-arena TYPE_ARRAY.
// PLATFORM: SHARED — Ubuntu gold import + dest-SLICE wrap.

/**
 * Return a two-element i32 array. ARRAY return ABI is E*.
 * @return [2]i32 — payload {1, 2}
 */
export function mk(): [2]i32 {
  return [1, 2];
}
