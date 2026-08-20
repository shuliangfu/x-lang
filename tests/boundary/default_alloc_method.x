// Isolated const-struct-lit field init: METHOD `recv.default_alloc()` and
// CALL `default_alloc()` must both rewrite to the heap factory emit.
// Dummy bodies return kind=99; after rewrite kind is heap (0). Exit 99 means
// the field still ran the dummy (helper/gates missed METHOD or CALL).
// PLATFORM: SHARED — Ubuntu gold; no Wide / no array-lit CALL (typeck T001).

allow(padding) struct Alloc {
  kind: i32
  arena: i64
}

struct Box {
  al: Alloc
}

trait Factory {
  function default_alloc(self): Alloc;
}

/**
 * METHOD zero-extra factory named default_alloc.
 * Body is a dummy (kind=99). The inliner must rewrite the name match to
 * `std_heap_default_alloc` (kind_heap=0), so kind==99 after `let b = mk_m()`
 * means the METHOD gate missed.
 * @param self i32 — unused receiver
 * @return Alloc — dummy {99, 0} if the call actually runs
 */
impl Factory for i32 {
  function default_alloc(self: i32): Alloc {
    return { kind: 99, arena: 0 };
  }
}

/**
 * CALL neighborhood factory with the same name.
 * @return Alloc — dummy {99, 0} if the call actually runs
 */
function default_alloc(): Alloc {
  return { kind: 99, arena: 0 };
}

/**
 * Zero-arg const struct lit whose field init is METHOD default_alloc.
 * @return Box — { recv.default_alloc() }
 */
function mk_m(): Box {
  return { al: 0.default_alloc() };
}

/**
 * Zero-arg const struct lit whose field init is CALL default_alloc.
 * @return Box — { default_alloc() }
 */
function mk_c(): Box {
  return { al: default_alloc() };
}

/**
 * Probe: METHOD + CALL default_alloc field inits rewrite to heap (kind != 99).
 * Exit 0 on success; 1..2 name the miss.
 * @return i32 — 0 ok
 */
function main(): i32 {
  let a: Box = mk_m();
  let b: Box = mk_c();
  /* METHOD field still ran the dummy body. */
  if (a.al.kind == 99) { return 1; }
  /* CALL field still ran the dummy body. */
  if (b.al.kind == 99) { return 2; }
  return 0;
}
