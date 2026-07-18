/** Internal function `mask_of`.
 * Implements `mask_of`.
 * @param align_bytes usize
 * @return usize
 */
function mask_of(align_bytes: usize): usize {
  let mask: usize = align_bytes - 1;
  if ((align_bytes & mask) != 0) { return 0; }
  return mask;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  if (mask_of(8) != 7) { return 1; }
  if (mask_of(7) != 0) { return 2; }
  return 0;
}
