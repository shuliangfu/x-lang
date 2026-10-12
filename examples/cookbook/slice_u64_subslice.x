/**
 * Cookbook SLICE-02：u64[] subslice / split_at / chunks（CORE-157）。
 */
const slice = import("core.slice");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let w: u64[4] = [100, 200, 300, 400];
  let sw: u64[] = w;
  /* subslice_u64 and split_at_u64 write through an out pointer. */
  let sub: u64[] = { data: 0, length: 0 as usize };
  slice.subslice_u64(sw, 1 as usize, 2 as usize, &sub);
  if (sub.length != 2 as usize || sub[0] != 200) { return 1; }
  let sp: Split_u64 = { left: { data: 0, length: 0 as usize }, right: { data: 0, length: 0 as usize } };
  slice.split_at_u64(sw, 2 as usize, &sp);
  if (sp.left.length != 2 as usize || sp.right[0] != 300) { return 2; }
  if (slice.chunks_len_u64(sw, 3 as usize) != 2 as usize) { return 3; }
  return 0;
}
