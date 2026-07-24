/** Inline escape probe (does not import("std.csv")). */

/**
 * Quote-escape ptr[0..length) into buf with capacity buf_cap.
 * @return written length or -1 on capacity failure
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
    if (ptr[j] == 34) {
      if (i + 2 > buf_cap) {
        return -1;
      }
      buf[i] = 34;
      i = i + 1;
      buf[i] = 34;
      i = i + 1;
    }
    if (ptr[j] != 34) {
      if (i >= buf_cap - 1) {
        return -1;
      }
      buf[i] = ptr[j];
      i = i + 1;
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

/**
 * Escape "ab" and return written length (expect 4).
 */
function main(): i32 {
  let line: u8[8] = [97, 98, 0, 0, 0, 0, 0, 0];
  let buf: u8[64] = [];
  let n: i32 = escape(&line[0], 2, &buf[0], 64);
  return n;
}
