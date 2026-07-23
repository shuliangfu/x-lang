// Probe: C-style empty-fraction floats (`1.`, `1.e2`) must be TOKEN_FLOAT (wave275).
// Prior residual: required digit after `.` so `1.e2` became INT+DOT+IDENT and codegen
// leaked host C text `1.e2` (accidental float) / `1.e` host "exponent has no digits".
//
// This file accepts valid empty-frac + exponent and returns 100.
// Incomplete empty-frac exp is covered by incomplete_exp-style probes (L005).
// PLATFORM: SHARED.

export function main(): i32 {
  return (1.e2) as i32;
}
