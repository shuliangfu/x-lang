// index_ptr_param.x — M8b: *u8 param indexing [i] and while+if parse smoke.

/**
 * Read first byte of pointer p and return as i32.
 */
function probe_index(p: *u8, len: i32): i32 {
  let x: u8 = p[0];
  return x as i32;
}

/**
 * Walk [0,len) checking p[0]==105 ('i'); return 1 if found, else 0.
 */
function probe_while_if(p: *u8, len: i32): i32 {
  let i: i32 = 0;
  let b0: u8 = 0;
  while (i < len) {
    b0 = p[0];
    if (b0 == 105) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}
