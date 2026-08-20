// Same-layer twin: dest-SLICE let `let s: []i32 = mk()` (same-module CALL).
// Let-init must wrap TYPE_ARRAY return, not wave409 reent (`__xlang_sp = mk()`).
// Expected: compile = 0, run = 43.
// PLATFORM: SHARED — Ubuntu gold typeck + host-C / asm emit.

function mk(): [2]i32 {
  return [1, 2];
}

function main(): i32 {
  let s: []i32 = mk();
  return s[0] + s[1] + 40;
}
