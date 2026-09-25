// Thin overlay: Cap residual named_builtin size/align → 4 (wave1007).
// G.7 twin of typeck_x_named_builtin_{align,size} for tip first-wins when
// typeck_x.o still has 1/2. PLATFORM: WINDOWS overlay · SHARED semantics.

/**
 * Align of a named builtin spelling. Cap residual i8/i16/u16 use 4-byte
 * cells (same as INDEX esz-4). True 1/2 pack waits on sext load encoders.
 * @param nm *u8 — type name bytes
 * @param nlen i32 — name length
 * @return i32 — 1, 2, 4, or 8; 0 if unknown
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_x_named_builtin_align(nm: *u8, nlen: i32): i32 {
  if (nm == 0 as *u8 || nlen <= 0) {
    return 0;
  }
  if (nlen == 2 && nm[0] == 105 && nm[1] == 56) { return 4; }
  if (nlen == 3 && nm[0] == 105 && nm[1] == 49 && nm[2] == 54) { return 4; }
  if (nlen == 3 && nm[0] == 117 && nm[1] == 49 && nm[2] == 54) { return 4; }
  if (nlen == 3 && nm[0] == 105 && nm[1] == 51 && nm[2] == 50) { return 4; }
  if (nlen == 3 && nm[0] == 117 && nm[1] == 51 && nm[2] == 50) { return 4; }
  if (nlen == 4 && nm[0] == 98 && nm[1] == 111 && nm[2] == 111 && nm[3] == 108) { return 4; }
  if (nlen == 2 && nm[0] == 117 && nm[1] == 56) { return 1; }
  if (nlen == 3 && nm[0] == 105 && nm[1] == 54 && nm[2] == 52) { return 8; }
  if (nlen == 3 && nm[0] == 117 && nm[1] == 54 && nm[2] == 52) { return 8; }
  if (nlen == 5 && nm[0] == 117 && nm[1] == 115 && nm[2] == 105 && nm[3] == 122 && nm[4] == 101) {
    return 8;
  }
  if (nlen == 5 && nm[0] == 105 && nm[1] == 115 && nm[2] == 105 && nm[3] == 122 && nm[4] == 101) {
    return 8;
  }
  if (nlen == 3 && nm[0] == 102 && nm[1] == 51 && nm[2] == 50) { return 4; }
  if (nlen == 3 && nm[0] == 102 && nm[1] == 54 && nm[2] == 52) { return 8; }
  return 0;
}

/**
 * Size of a named builtin spelling. Align equals size for these scalars.
 * @param nm *u8 — type name bytes
 * @param nlen i32 — name length
 * @return i32 — 1, 2, 4, or 8; 0 if unknown
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function typeck_x_named_builtin_size(nm: *u8, nlen: i32): i32 {
  let a: i32 = typeck_x_named_builtin_align(nm, nlen);
  if (a == 1 || a == 2 || a == 4 || a == 8) {
    return a;
  }
  return 0;
}
