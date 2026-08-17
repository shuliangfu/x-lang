// function-body `region label { … }; return` (optional compound ASI).
// `region foo { k = 1 }; return k` used to drop the whole function (P001).
// No-semi `region { k = 1 } return` is already green (isolate fn_reg_nosemi).
// Same optional-semi covers parse_into with_arena / defer (isolates
// fn_wa_semi parse / fn_def_semi). Do not stack those here: onefunc
// region sidecar capacity is another layer.
// Leftover codes stay in 1..255.
// Expected exit 0.
// PLATFORM: SHARED parse_into function-body region compound ASI.

/**
 * Gate function-body `region label { … }; return` optional compound ASI.
 * @return i32 — 0 ok; 70..71 leftover lanes
 */
function main(): i32 {
  let k: i32 = 0;

  // region + trailing semicolon then later stmts
  region foo { k = 1 };
  if (k != 1) { return 70; }

  // no-semi region still a stmt head
  k = 0;
  region bar { k = 1 }
  if (k != 1) { return 71; }

  return 0;
}
