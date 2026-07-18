/** Probe: while body calls a helper to avoid if/else inside the loop. */

/**
 * Escape one character into buf; double '"' if needed.
 * @return new write index or -1 if capacity insufficient
 */
function esc_one(ch: u8, buf: *u8, i: i32, buf_cap: i32): i32 {
  if (ch == 34) {
    if (i + 2 > buf_cap) {
      return -1;
    }
    buf[i] = 34;
    i = i + 1;
    buf[i] = 34;
    i = i + 1;
    return i;
  }
  if (i >= buf_cap - 1) {
    return -1;
  }
  buf[i] = ch;
  i = i + 1;
  return i;
}

/** Internal function `escape`.
 * Purpose: see body; keep contracts (null/cap/PLATFORM) aligned with implementation.
 * Params/returns: as declared in the signature; panics or error codes follow local conventions.
 */
function escape(ptr: *u8, len: i32, buf: *u8, buf_cap: i32): i32 {
  if (buf_cap < 2) {
    return -1;
  }
  let i: i32 = 0;
  buf[i] = 34;
  i = i + 1;
  let j: i32 = 0;
  while (j < len) {
    i = esc_one(ptr[j], buf, i, buf_cap);
    if (i < 0) {
      return -1;
    }
    j = j + 1;
  }
  if (i >= buf_cap - 1) {
    return -1;
  }
  buf[i] = 34;
  i = i + 1;
  return i;
}

/** Internal function `main`.
 * Purpose: see body; keep contracts (null/cap/PLATFORM) aligned with implementation.
 * Params/returns: as declared in the signature; panics or error codes follow local conventions.
 */
function main(): i32 {
  let line: u8[8] = [97, 98, 0, 0, 0, 0, 0, 0];
  let buf: u8[64] = [];
  let n: i32 = escape(&line[0], 2, &buf[0], 64);
  return n;
}
