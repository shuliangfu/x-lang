// See implementation.
const iterator = import("core.iterator");
const option = import("core.option");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* Iterators and taken options are written through an out pointer. */
  let a: i32[3] = [10, 20, 30];
  let s: i32[] = a;
  let it: SliceIter_i32 = { ptr: 0, length: 0 as usize, index: 0 as usize };
  iterator.iter_i32(s, &it);
  if (iterator.iter_remaining_i32(&it) != (3 as i64)) { return 1; }

  let o1: Option_i32 = { is_some: false, value: 0 };
  let o2: Option_i32 = { is_some: false, value: 0 };
  let o3: Option_i32 = { is_some: false, value: 0 };
  let o4: Option_i32 = { is_some: false, value: 0 };
  iterator.next_i32(&it, &o1);
  iterator.next_i32(&it, &o2);
  iterator.next_i32(&it, &o3);
  iterator.next_i32(&it, &o4);
  if (!option.is_some_i32(o1) || option.unwrap_or_i32(o1, 0) != 10) { return 2; }
  if (!option.is_some_i32(o2) || option.unwrap_or_i32(o2, 0) != 20) { return 3; }
  if (!option.is_some_i32(o3) || option.unwrap_or_i32(o3, 0) != 30) { return 4; }
  if (!option.is_none_i32(o4)) { return 5; }
  if (iterator.iter_remaining_i32(&it) != (0 as i64)) { return 6; }

  let empty: i32[1] = [0];
  let es: i32[] = empty;
  es.length = 0 as usize;
  let eit: SliceIter_i32 = { ptr: 0, length: 0 as usize, index: 0 as usize };
  iterator.iter_i32(es, &eit);
  let oe: Option_i32 = { is_some: false, value: 0 };
  iterator.next_i32(&eit, &oe);
  if (!option.is_none_i32(oe)) { return 7; }

  let b: u8[2] = [5, 15];
  let x: u8[] = b;
  let uit: SliceIter_u8 = { ptr: 0, length: 0 as usize, index: 0 as usize };
  iterator.iter_u8(x, &uit);
  let ou1: Option_u8 = { is_some: false, value: 0 as u8 };
  let ou2: Option_u8 = { is_some: false, value: 0 as u8 };
  let ou3: Option_u8 = { is_some: false, value: 0 as u8 };
  iterator.next_u8(&uit, &ou1);
  iterator.next_u8(&uit, &ou2);
  iterator.next_u8(&uit, &ou3);
  if (!option.is_some_u8(ou1) || option.unwrap_or_u8(ou1, 0 as u8) != (5 as u8)) { return 8; }
  if (!option.is_some_u8(ou2) || option.unwrap_or_u8(ou2, 0 as u8) != (15 as u8)) { return 9; }
  if (!option.is_none_u8(ou3)) { return 10; }

  return 0;
}
