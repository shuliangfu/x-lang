// See implementation.
const iterator = import("core.iterator");
const option = import("core.option");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* The u64 iterator and the taken option are written through an out pointer. */
  let a: u64[3] = [10, 20, 30];
  let it: SliceIter_u64 = { ptr: 0 as *u64, length: 0 as usize, index: 0 as usize };
  iterator.iter_u64_from_buf(&a[0], 3 as usize, &it);
  let o0: Option_u64 = { is_some: false, value: 0 as u64 };
  iterator.next_u64(&it, &o0);
  if (o0.is_some == false || o0.value != (10 as u64)) { return 1; }
  if (iterator.iterator_protocol_version() != 1) { return 2; }
  if (iterator.iter_remaining_u64(&it) != (2 as i64)) { return 3; }
  return 0;
}
