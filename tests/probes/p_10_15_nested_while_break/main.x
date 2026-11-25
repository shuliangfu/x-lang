/**
 * 10.15 repro: nested while; inner exits via j = nlen (not break).
 * Expect: count mismatches then continue outer; return nlayouts*100 + hits.
 * Miscompile: inner exit jumps to function epilogue → wrong return.
 * PLATFORM: SHARED
 */
function name_eq_scan(nlayouts: i32, nlen: i32, bad_at: i32): i32 {
  let k: i32 = 0;
  let hits: i32 = 0;
  let j: i32 = 0;
  let eq: i32 = 0;
  let b: i32 = 0;
  while (k < nlayouts) {
    eq = 1;
    j = 0;
    while (j < nlen) {
      /* pretend layout byte: only index bad_at mismatches when k==0 */
      if (k == 0 && j == bad_at) {
        b = 1;
      } else {
        b = 0;
      }
      if (b != 0) {
        eq = 0;
        j = nlen;
      } else {
        j = j + 1;
      }
    }
    if (eq != 0) {
      hits = hits + 1;
    }
    k = k + 1;
  }
  return nlayouts * 100 + hits;
}

function main(): i32 {
  /* 3 layouts, len 4, mismatch at j=1 on k=0 only → hits should be 2 → 302 */
  let r: i32 = name_eq_scan(3, 4, 1);
  if (r != 302) {
    return r;
  }
  /* no mismatch → hits 3 → 303 */
  r = name_eq_scan(3, 4, 99);
  if (r != 303) {
    return r;
  }
  return 0;
}
