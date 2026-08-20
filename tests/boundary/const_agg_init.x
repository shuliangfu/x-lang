// Isolated: const aggregate emit must write fat / in-place [N]T (not store_rax).
// Reuses glue_emit_slice_from_array_let_init + glue_emit_fixed_array_type_let_init
// (and host-C let finish). Bare and `as` ascription share the same consume.
// Mid-body later consts now land in stmt_order (host-C multi-const decl).
// Expected: compile = 0, run = 42 (asm and host-C).
// PLATFORM: SHARED — Ubuntu gold.

/**
 * Exit 42 when const []T / [N]T array-lit inits emit a live payload.
 * @return i32 — 42 ok, else the failing case
 */
function main(): i32 {
  const s: []i32 = [10, 32];
  if (s.length != 2) { return 2; }
  if (s[0] != 10) { return 3; }
  const t: []i32 = [10, 32] as []i32;
  if (t.length != 2) { return 4; }
  if (t[0] != 10) { return 5; }
  const a: [2]i32 = [10, 32];
  if (a[0] != 10) { return 6; }
  if (a[1] != 32) { return 7; }
  const b: [2]i32 = [10, 32] as [2]i32;
  if (b[0] != 10) { return 8; }
  if (b[1] != 32) { return 9; }
  const e: []i32 = [];
  if (e.length != 0) { return 10; }
  const n: i32 = 5 as i32;
  if (n != 5) { return 1; }
  return 42;
}
