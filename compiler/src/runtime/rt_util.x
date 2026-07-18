// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-262 / P2 R0 util to R2 full: unlink failed outputs + argv0 basename fully in .x.
// Product PREFER_X_O: thin.x (this file) + rest seed is empty under FROM_X (forward decls only).
// unlink via libc extern; basename uses pure index scan ('/' and '\\'), no strrchr/empty-str deps.

export extern "C" function unlink(path: *u8): i32;

/**
 * Unlink a failed output path so partial products do not linger on disk.
 * Params: out_path — NUL-terminated path, or null/empty (no-op).
 * Returns: void. Calls libc unlink under unsafe; ignores errno.
 * Contracts: null or empty path is a silent no-op; does not create paths.
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: SHARED — link-name contract; dual-host prove.
 */
#[no_mangle]
export function driver_unlink_failed_output(out_path: *u8): void {
  if (out_path == 0 as *u8) {
    return;
  }
  if (out_path[0 as usize] == 0 as u8) {
    return;
  }
  unsafe {
    unlink(out_path);
  }
}

/**
 * Return 1 iff the basename of argv0 equals base (supports '/' and Windows '\\').
 * Params:
 *   argv0 — full argv[0] path or null (treated as empty name);
 *   base  — expected basename (must be non-null).
 * Returns: 1 on match, 0 otherwise.
 * Contracts: base null → 0; argv0 null matches only empty base; scans cap 4096/256.
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: SHARED — path seps for both POSIX and Windows.
 */
#[no_mangle]
export function driver_argv0_basename_is(argv0: *u8, base: *u8): i32 {
  if (base == 0 as *u8) {
    return 0;
  }
  if (argv0 != 0 as *u8) {
    let i: i32 = 0;
    let last: i32 = 0 - 1;
    // Scan for last path separator ('/' = 47 or '\\' = 92), cap at 4096 bytes.
    while (i < 4096) {
      let c: u8 = argv0[i];
      if (c == 0) {
        break;
      }
      if (c == 47) {
        last = i;
      }
      if (c == 92) {
        last = i;
      }
      i = i + 1;
    }
    if (last >= 0) {
      // Compare basename after last sep against base (both NUL-terminated).
      let j: i32 = 0;
      while (j < 256) {
        let a: u8 = argv0[last + 1 + j];
        let b: u8 = base[j];
        if (a != b) {
          return 0;
        }
        if (a == 0) {
          return 1;
        }
        j = j + 1;
      }
      return 0;
    }
  }
  // No separator (or argv0 null): compare argv0 (or empty) against base as a whole.
  if (argv0 == 0 as *u8) {
    if (base[0] == 0) {
      return 1;
    }
    return 0;
  }
  let j2: i32 = 0;
  while (j2 < 256) {
    let a2: u8 = argv0[j2];
    let b2: u8 = base[j2];
    if (a2 != b2) {
      return 0;
    }
    if (a2 == 0) {
      return 1;
    }
    j2 = j2 + 1;
  }
  return 0;
}
