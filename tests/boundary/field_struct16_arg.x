// Isolated green: 16B same-module FIELD as by-value CALL arg.
// 8B FIELD-as-arg already greened; 16B used to CG002 on Darwin because
// backend_enc_load_qword_*_arch returned -1 for ta!=0 (x86-only).
// VAR / let-bound 16B arg already greened via glue_load_var_as_value
// (high-first into x1). This probe is the FIELD path (deref_struct16).
// Expected: compile 0, run 42.
// PLATFORM: SHARED — LINUX|x86_64 SysV rax+rdx; MACOS|ARM64 AAPCS64 x0+x1.

allow(padding) struct Al {
  kind: i32;
  p: *u8;
}

allow(padding) struct Holder {
  a: Al;
}

/**
 * Read the i32 half of a 16-byte by-value POD.
 * @param a Al — 16B INTEGER-class formal (dual-GP)
 * @param n i32 — addend
 * @return i32 — a.kind + n
 */
export function take(a: Al, n: i32): i32 {
  return a.kind + n;
}

/**
 * Pass FIELD `h.a` (not a let-bound copy) as the 16B formal.
 * @return i32 — 42 on success
 */
export function main(): i32 {
  let h: Holder = Holder { a: Al { kind: 1, p: 0 as *u8 } };
  return take(h.a, 41);
}
