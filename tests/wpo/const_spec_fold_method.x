/**
 * WPO-S2 METHOD neighborhood of const_spec_fold.x.
 * Default path (env unset): wpo_const scalar folds both sites to imm.
 * XLANG_WPO_MONO=1: try_call_wpo_mono_symbol emits zero-arg thunks
 * `fold_add__wpo_10_3` and `fold_add_call__wpo_10_3`.
 */

trait FoldAddable {
  function fold_add(self, other: i32): i32;
}

/**
 * METHOD receiver of the two-const scalar binop fold / mono thunk.
 * @param self i32 — left const at the call site
 * @param other i32 — right const at the call site
 * @return i32 — self + other
 */
impl FoldAddable for i32 {
  function fold_add(self: i32, other: i32): i32 {
    return self + other;
  }
}

/**
 * CALL neighborhood of fold_add (same `return param0 + param1` shape).
 * Named apart so name-scan / overload do not collide with the METHOD.
 * @param x i32 — left const
 * @param y i32 — right const
 * @return i32 — x + y
 */
function fold_add_call(x: i32, y: i32): i32 {
  return x + y;
}

/**
 * Exit 0 when METHOD and CALL both fold or thunk to 13.
 * @return i32 — 0 ok, 1 METHOD miss, 2 CALL miss
 */
function main(): i32 {
  if (10.fold_add(3) != 13) { return 1; }
  if (fold_add_call(10, 3) != 13) { return 2; }
  return 0;
}
