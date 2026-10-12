/**
 * Product cookbook: import("core.iterator") unique UNDEF fire (iter_i32 / next_i32).
 * Designed success score is 10 (sum of [1,2,3,4]); not an error code.
 * PLATFORM: SHARED — product `-o` pulls core/iterator/mod.o via labi g==22.
 */
const iterator = import("core.iterator");
const option = import("core.option");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let data: i32[4] = [1, 2, 3, 4];
  let s: i32[] = data;
  /* iter_i32 and next_i32 write through an out pointer. */
  let it: SliceIter_i32 = { ptr: 0, length: 0 as usize, index: 0 as usize };
  iterator.iter_i32(s, &it);
  let sum: i32 = 0;
  let done: bool = false;
  while (!done) {
    let o: Option_i32 = { is_some: false, value: 0 };
    iterator.next_i32(&it, &o);
    if (option.is_none_i32(o)) {
      done = true;
    } else {
      sum = sum + option.unwrap_or_i32(o, 0);
    }
  }
  return sum;
}
