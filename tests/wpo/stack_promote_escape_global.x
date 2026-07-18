// See implementation.
// See implementation.

/* See implementation. */
struct Pair {
  a: i32
  b: i32
}

/* See implementation. */
struct Slot {
  ptr: *Pair
}

/** Internal function `stash_pair_ptr`.
 * Implements `stash_pair_ptr`.
 * @param slot *Slot
 * @param p *Pair
 * @return void
 */
function stash_pair_ptr(slot: *Slot, p: *Pair): void {
  slot.ptr = p;
}

/** Internal function `fill_and_stash`.
 * Implements `fill_and_stash`.
 * @param slot *Slot
 * @return i32
 */
function fill_and_stash(slot: *Slot): i32 {
  let p: Pair = Pair { a: 3, b: 4 };
  slot.ptr = &p;
  let pp: *Pair = slot.ptr;
  return pp.a + pp.b;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let slot: Slot = Slot { ptr: 0 as *Pair };
  return fill_and_stash(&slot);
}
