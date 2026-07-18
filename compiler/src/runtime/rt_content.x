// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-261/306 / P2 R2: content_has_* pure string scanners + path wrappers.
// R2 full: path rest also owned by .x; FROM_X rest business H=0 (marker only).
// Note: some usize-index/subtraction patterns trigger "parse no functions";
// prefer i32 indices then cast. Product PREFER_X_O hybrid: thin full .x + empty rest.
// PLATFORM: SHARED — surface short names are the link-name contract (Track L).
// Comment rule: never put star-slash sequences inside /** block comments */ (truncates body).

/** Return 1 iff content[p..p+2) equals the two payload bytes a0,a1.
 * Requires p+2 <= n. Used by compound-assign and keyword scanners.
 * Track-L: #[no_mangle] keeps surface short name (not rt_content_rt_eq2).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_eq2(c: *u8, n: i32, p: i32, a0: u8, a1: u8): i32 {
  if (p + 2 > n) {
    return 0;
  }
  if (c[p as usize] != a0) {
    return 0;
  }
  if (c[(p + 1) as usize] != a1) {
    return 0;
  }
  return 1;
}

/** Return 1 iff content[p..p+3) equals a0,a1,a2. Bounds: p+3 <= n.
 * Track-L: #[no_mangle] keeps surface short name (not module-prefixed mangle).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_eq3(c: *u8, n: i32, p: i32, a0: u8, a1: u8, a2: u8): i32 {
  if (p + 3 > n) {
    return 0;
  }
  if (c[p as usize] != a0) {
    return 0;
  }
  if (c[(p + 1) as usize] != a1) {
    return 0;
  }
  if (c[(p + 2) as usize] != a2) {
    return 0;
  }
  return 1;
}

/** Return 1 iff content[p..p+4) equals a0..a3. Bounds: p+4 <= n.
 * Track-L: #[no_mangle] keeps surface short name (not module-prefixed mangle).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_eq4(c: *u8, n: i32, p: i32, a0: u8, a1: u8, a2: u8, a3: u8): i32 {
  if (p + 4 > n) {
    return 0;
  }
  if (c[p as usize] != a0) {
    return 0;
  }
  if (c[(p + 1) as usize] != a1) {
    return 0;
  }
  if (c[(p + 2) as usize] != a2) {
    return 0;
  }
  if (c[(p + 3) as usize] != a3) {
    return 0;
  }
  return 1;
}

/** Return 1 iff content[p..p+5) equals a0..a4. Bounds: p+5 <= n.
 * Track-L: #[no_mangle] keeps surface short name (not module-prefixed mangle).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_eq5(c: *u8, n: i32, p: i32, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8): i32 {
  if (p + 5 > n) {
    return 0;
  }
  if (c[p as usize] != a0) {
    return 0;
  }
  if (c[(p + 1) as usize] != a1) {
    return 0;
  }
  if (c[(p + 2) as usize] != a2) {
    return 0;
  }
  if (c[(p + 3) as usize] != a3) {
    return 0;
  }
  if (c[(p + 4) as usize] != a4) {
    return 0;
  }
  return 1;
}

/** Return 1 iff content[p..p+6) equals a0..a5. Bounds: p+6 <= n.
 * Track-L: #[no_mangle] keeps surface short name (not module-prefixed mangle).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_eq6(c: *u8, n: i32, p: i32, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8, a5: u8): i32 {
  if (p + 6 > n) {
    return 0;
  }
  if (c[p as usize] != a0) {
    return 0;
  }
  if (c[(p + 1) as usize] != a1) {
    return 0;
  }
  if (c[(p + 2) as usize] != a2) {
    return 0;
  }
  if (c[(p + 3) as usize] != a3) {
    return 0;
  }
  if (c[(p + 4) as usize] != a4) {
    return 0;
  }
  if (c[(p + 5) as usize] != a5) {
    return 0;
  }
  return 1;
}

/** Return 1 if a generic-syntax token starts at content[p].
 * Accepts angle-open then T forms or known primitive angles (i32, bool, …).
 * Rejects close-bracket then angle-open so array/slice compares stay out.
 * Track-L: #[no_mangle] keeps surface short name (not rt_content_rt_is_generic_at).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_is_generic_at(content: *u8, n: i32, p: i32): i32 {
  let prev: i32 = 0;
  let q: i32 = 0;
  if (p >= n) {
    return 0;
  }
  if (content[p as usize] != 60) {
    return 0;
  }
  if (p + 1 >= n) {
    return 0;
  }
  // Skip close-bracket + angle-open (not a generic open after array/slice).
  if (p > 0) {
    prev = p - 1;
    if (content[prev as usize] == 93) {
      return 0;
    }
  }
  // angle-open + 'T' then end / angle-close / comma
  if (content[(p + 1) as usize] == 84) {
    q = p + 2;
    if (q >= n) {
      return 1;
    }
    if (content[q as usize] == 62) {
      return 1;
    }
    if (content[q as usize] == 44) {
      return 1;
    }
  }
  // Primitive angle forms used in selfhost sources (byte tables, not string lits).
  if (rt_eq4(content, n, p, 60, 105, 56, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 105, 49, 54, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 105, 51, 50, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 105, 54, 52, 62) != 0) {
    return 1;
  }
  if (rt_eq4(content, n, p, 60, 117, 56, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 117, 49, 54, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 117, 51, 50, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 117, 54, 52, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 102, 51, 50, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 102, 54, 52, 62) != 0) {
    return 1;
  }
  if (rt_eq6(content, n, p, 60, 98, 111, 111, 108, 62) != 0) {
    return 1;
  }
  return 0;
}

/** Scan buffer for generic syntax or "trait " / " impl " keywords.
 * Returns 1 on first hit, 0 if content is null/empty or no match.
 * Indices use i32 (ni) to avoid usize-sub patterns that break -E parse.
 * Track-L: #[no_mangle] keeps surface short name for public scanner.
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function content_has_generic_syntax(content: *u8, n: usize): i32 {
  let p: i32 = 0;
  let i: i32 = 0;
  let ni: i32 = 0;
  if (content == 0 as *u8) {
    return 0;
  }
  if (n == 0) {
    return 0;
  }
  ni = n as i32;
  if (ni < 0) {
    ni = 2147483647;
  }
  p = 0;
  while (p < ni) {
    if (rt_is_generic_at(content, ni, p) != 0) {
      return 1;
    }
    p = p + 1;
  }
  if (ni >= 6) {
    i = 0;
    while (i <= ni - 6) {
      // "trait " and " impl " as byte sequences.
      if (rt_eq6(content, ni, i, 116, 114, 97, 105, 116, 32) != 0) {
        return 1;
      }
      if (rt_eq6(content, ni, i, 32, 105, 109, 112, 108, 32) != 0) {
        return 1;
      }
      i = i + 1;
    }
  }
  return 0;
}

/** Return 1 if a compound-assignment operator starts at content[at].
 * Covers shift-assign and two-byte op-assign forms (plus/minus/star/slash/etc).
 * Track-L: #[no_mangle] keeps surface short name (not rt_content_rt_is_compound_at).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_is_compound_at(content: *u8, n: i32, at: i32): i32 {
  if (rt_eq3(content, n, at, 60, 60, 61) != 0) {
    return 1;
  }
  if (rt_eq3(content, n, at, 62, 62, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 43, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 45, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 42, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 47, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 37, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 38, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 124, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 94, 61) != 0) {
    return 1;
  }
  return 0;
}

// G-02f-436: flatten and-chains into small helpers (avoids -E analysis blow-up).

/** Return 1 iff content[at..] starts a block-comment end (star then slash).
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_is_block_comment_end(c: *u8, n: i32, at: i32): i32 {
  if (at + 1 >= n) { return 0; }
  if (c[at as usize] != 42) { return 0; }
  if (c[(at + 1) as usize] != 47) { return 0; }
  return 1;
}

/** Return 1 iff content[at] is backslash and a next byte exists (string escape).
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_is_string_escape(c: *u8, n: i32, at: i32): i32 {
  if (c[at as usize] != 92) { return 0; }
  if (at + 1 >= n) { return 0; }
  return 1;
}

/** Return 1 iff content[at..] starts a line comment (slash slash).
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_is_line_comment_start(c: *u8, n: i32, at: i32): i32 {
  if (at + 1 >= n) { return 0; }
  if (c[at as usize] != 47) { return 0; }
  if (c[(at + 1) as usize] != 47) { return 0; }
  return 1;
}

/** Return 1 iff content[at..] starts a block comment (slash then star).
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_is_block_comment_start(c: *u8, n: i32, at: i32): i32 {
  if (at + 1 >= n) { return 0; }
  if (c[at as usize] != 47) { return 0; }
  if (c[(at + 1) as usize] != 42) { return 0; }
  return 1;
}

/** Scan buffer for compound-assign operators outside comments and strings.
 * State machine: 0=code, 1=line-comment, 2=block-comment, 3=string.
 * Returns 1 on first match outside those regions; 0 if null or n < 3.
 * Track-L: #[no_mangle] keeps surface short name for public scanner.
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function content_has_compound_assign_syntax(content: *u8, n: usize): i32 {
  let at: i32 = 0;
  let ni: i32 = 0;
  let state: i32 = 0;
  if (content == 0 as *u8) {
    return 0;
  }
  if (n < 3) {
    return 0;
  }
  ni = n as i32;
  if (ni < 0) {
    ni = 2147483647;
  }
  while (at < ni) {
    if (state == 0) {
      if (rt_is_line_comment_start(content, ni, at) != 0) {
        state = 1;
        at = at + 2;
      } else {
        if (rt_is_block_comment_start(content, ni, at) != 0) {
          state = 2;
          at = at + 2;
        } else {
          if (content[at as usize] == 34) {
            state = 3;
            at = at + 1;
          } else {
            if (rt_is_compound_at(content, ni, at) != 0) {
              return 1;
            }
            at = at + 1;
          }
        }
      }
    } else {
      if (state == 1) {
        if (content[at as usize] == 10) {
          state = 0;
        }
        at = at + 1;
      } else {
        if (state == 2) {
          if (rt_is_block_comment_end(content, ni, at) != 0) {
            state = 0;
            at = at + 2;
          } else {
            at = at + 1;
          }
        } else {
          if (rt_is_string_escape(content, ni, at) != 0) {
            at = at + 2;
          } else {
            if (content[at as usize] == 34) {
              state = 0;
            }
            at = at + 1;
          }
        }
      }
    }
  }
  return 0;
}

// G-02f-436 / R2 path rest: driver_source_has_* true-migrated to .x.
// Peek via extern; content uses u8[65536] stack buffer (-E verified);
// path is copied into u8[512] with trailing NUL.

export extern "C" function driver_peek_source_file(path: *u8, content: *u8, cap: i64): i32;

/** Copy path[0..path_len) into path_buf and write a trailing NUL.
 * Returns 1 on success, 0 if path_len <= 0 or path_len >= 512.
 * Track-L: #[no_mangle] keeps surface short name (not rt_content_rt_path_copy_nul).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_path_copy_nul(path: *u8, path_len: i32, path_buf: *u8): i32 {
  let i: i32 = 0;
  if (path_len <= 0) {
    return 0;
  }
  if (path_len >= 512) {
    return 0;
  }
  while (i < path_len) {
    path_buf[i as usize] = path[i as usize];
    i = i + 1;
  }
  path_buf[path_len as usize] = 0;
  return 1;
}

/** Peek source at path and return content_has_generic_syntax result.
 * path_len is the length of the path bytes (not including a required NUL).
 * Returns 0 on path copy failure, peek error, or no generic syntax.
 * Track-L: #[no_mangle] keeps surface short name for driver entry.
 * PLATFORM: SHARED — uses driver_peek_source_file FFI. */
#[no_mangle]
export function driver_source_has_generic_syntax(path: *u8, path_len: i32): i32 {
  let content: u8[65536] = [];
  let path_buf: u8[512] = [];
  let rn: i32 = 0;
  if (rt_path_copy_nul(path, path_len, &path_buf[0]) == 0) {
    return 0;
  }
  unsafe {
    rn = driver_peek_source_file(&path_buf[0], &content[0], 65536);
  }
  if (rn < 0) {
    return 0;
  }
  return content_has_generic_syntax(&content[0], rn as usize);
}

/** Peek source at path and return content_has_compound_assign_syntax result.
 * path_len is the length of the path bytes. Returns 0 on copy/peek failure.
 * Track-L: #[no_mangle] keeps surface short name for driver entry.
 * PLATFORM: SHARED — uses driver_peek_source_file FFI. */
#[no_mangle]
export function driver_source_has_compound_assign_syntax(path: *u8, path_len: i32): i32 {
  let content: u8[65536] = [];
  let path_buf: u8[512] = [];
  let rn: i32 = 0;
  if (rt_path_copy_nul(path, path_len, &path_buf[0]) == 0) {
    return 0;
  }
  unsafe {
    rn = driver_peek_source_file(&path_buf[0], &content[0], 65536);
  }
  if (rn < 0) {
    return 0;
  }
  return content_has_compound_assign_syntax(&content[0], rn as usize);
}
