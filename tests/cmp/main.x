// See implementation.
const cmp = import("core.cmp");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* cmp helpers return Ordering.code in eax as i32. Predicates return 1 or 0. */
  let o_lt: Ordering = { code: cmp.cmp_i32(1, 2) };
  let o_eq: Ordering = { code: cmp.cmp_i32(5, 5) };
  let o_gt: Ordering = { code: cmp.cmp_i32(9, 3) };
  if (cmp.is_lt(o_lt) == 0) { return 1; }
  if (cmp.is_eq(o_eq) == 0) { return 2; }
  if (cmp.is_gt(o_gt) == 0) { return 3; }

  let ou: Ordering = { code: cmp.cmp_u8(255 as u8, 0 as u8) };
  if (cmp.is_gt(ou) == 0) { return 4; }

  let a: u8[3] = [10, 20, 30];
  let p0: *u8 = &a[0];
  let p1: *u8 = &a[1];
  let plt: Ordering = { code: cmp.cmp_ptr(p0, p1) };
  let peq: Ordering = { code: cmp.cmp_ptr(p0, p0) };
  if (cmp.is_lt(plt) == 0) { return 5; }
  if (cmp.is_eq(peq) == 0) { return 6; }

  let eq: Ordering = { code: cmp.ordering_equal() };
  let gt: Ordering = { code: cmp.ordering_greater() };
  let chain: Ordering = { code: cmp.then(eq, gt) };
  if (cmp.is_gt(chain) == 0) { return 7; }
  let less: Ordering = { code: cmp.ordering_less() };
  let rev: Ordering = { code: cmp.reverse(less) };
  if (cmp.is_gt(rev) == 0) { return 8; }

  let from: Ordering = { code: cmp.ordering_from_i32(-1) };
  if (cmp.is_lt(from) == 0) { return 9; }

  return 0;
}
