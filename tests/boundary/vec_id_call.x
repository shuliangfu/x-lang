// Isolated: TYPE_VECTOR / SIMD named identity CALL (`let c = idv(a)`).
// i32x4 is TYPE_NAMED with no struct layout; size_simple used to miss as 4
// so formal / return / call-arg / retval all took one GP (x0 only).
// Lane 2 leftover was Darwin RUN=13. host-C already 0.
// This gate checks every lane of a 16B identity. Expected exit 0.
// PLATFORM: SHARED — Ubuntu gold; Darwin ARM64 is the live fail without dual-GP.

/**
 * Identity of one i32x4 (not a binop2 fold — forces real CALL).
 * @param a i32x4 — lanes to return
 * @return i32x4 — a unchanged
 */
function idv(a: i32x4): i32x4 {
  return a;
}

/**
 * Exit 0 when identity CALL writes every lane (not only the first 8B).
 * @return i32 — 0 ok; 11..14 fail lane
 */
function main(): i32 {
  let a: i32x4 = [1, 2, 3, 4];
  let c: i32x4 = idv(a);
  if (c[0] != 1) { return 11; }
  if (c[1] != 2) { return 12; }
  if (c[2] != 3) { return 13; }
  if (c[3] != 4) { return 14; }
  return 0;
}
