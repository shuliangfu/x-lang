/* Positive: lit + u64 field → usize return (wave312 integer widen).
 * Filename is historical (pre-wave312 required `as`); product now allows
 * u64↔usize. Companion to u64_to_usize_needs_as.x with lit on the left.
 * PLATFORM: SHARED typeck.
 */
allow(padding) struct Entry { off: u64; }
allow(padding) struct Store { mt: Entry[4]; }

/**
 * Return a usize from a literal plus a u64 field (implicit widen).
 * @param s *Store — store with Entry[4] table
 * @param i u32 — table index
 * @return usize — 24 + off after u64→usize widen
 */
function bad_offset(s: *Store, i: u32): usize {
  return 24 + s.mt[i].off;
}

/**
 * Program/test entry point.
 * @return i32 — 0
 */
function main(): i32 { return 0; }
