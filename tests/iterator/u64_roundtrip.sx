// CORE-020：SliceIter_u64 烟测
const iterator = import("core.iterator");
const option = import("core.option");

function main(): i32 {
  let a: u64[3] = [10, 20, 30];
  let it: SliceIter_u64 = iterator.iter_u64_from_buf(&a[0], 3 as usize);
  let o0: Option_u64 = iterator.next_u64(&it);
  if (o0.is_some == false || o0.value != 10) { return 1; }
  if (iterator.iterator_protocol_version() != 1) { return 2; }
  if (iterator.iter_remaining_u64(&it) != 2 as usize) { return 3; }
  return 0;
}
