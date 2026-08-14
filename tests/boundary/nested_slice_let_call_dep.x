// Same-layer twin: dest-SLICE let `let s: []i32 = dep.mk()`.
// block_inits reuses glue_emit_slice_from_array_let_init / try_emit.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C / asm emit.

const dep = import("nested_slice_mk_dep.x");

function main(): i32 {
  let s: []i32 = dep.mk();
  return s[0] + s[1] + 40;
}
