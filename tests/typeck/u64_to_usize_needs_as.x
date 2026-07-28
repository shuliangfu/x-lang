/* Positive: u64 field + int lit → usize return (wave312 integer widen).
 * Filename is historical (pre-wave312 required `as`); product now allows
 * u64↔usize (LP64 same-width store / intentional first-class widen).
 * PLATFORM: SHARED typeck.
 */
allow(padding) struct Entry { off: u64; }
allow(padding) struct Store { mt: Entry[4]; }

/**
 * Return a usize from a u64 field plus a literal (implicit widen).
 * @param s *Store — store with Entry[4] table
 * @param i u32 — table index
 * @return usize — off + 24 after u64→usize widen
 */
function bad_offset(s: *Store, i: u32): usize {
  return s.mt[i].off + 24;
}

/**
 * Program/test entry point.
 * @return i32 — 0
 */
function main(): i32 { return 0; }
