// Isolated: module dest-SLICE `[][]T` / dest-ARRAY `[N][]T` ARRAY_LIT.
// host-C file-scope must emit nested `{.data=(E[]){ (E){.data=(leaf[]){…},
// .length=n}, … }, .length=N}` — emit_expr statement-expr is illegal C static.
// asm: hoist dest-SLICE into main; durable packs dest-SLICE rows via dest
// elem TYPE_SLICE (module ARRAY_LIT is not check_block-stamped).
// Expected: host-C (`-backend c`) and asm compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold host-C static + asm hoist.

const ns: [][]i32 = [[10, 32], [1, 2]];
const na: [2][]i32 = [[10, 32], [1, 2]];

/**
 * Exit 42 when module `[][]T` / `[N][]T` ARRAY_LIT wrap as typed fat
 * at file scope (host-C). INDEX consumes both rows.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  if (ns.length != 2) { return 14; }
  if (ns[0].length != 2) { return 15; }
  if (ns[0][0] != 10) { return 16; }
  if (ns[0][1] != 32) { return 17; }
  if (ns[1][0] != 1) { return 18; }
  if (ns[1][1] != 2) { return 19; }
  if (na[0].length != 2) { return 20; }
  if (na[0][0] != 10) { return 21; }
  if (na[1][1] != 2) { return 22; }
  return 42;
}
