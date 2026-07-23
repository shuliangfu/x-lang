// Probe: binary `0b`/`0B` and octal `0o`/`0O` integer literals (wave276 Cap residual pure).
// Valid: 0b101010 == 42, 0o52 == 42, 0B1111 == 15, 0O10 == 8.
// PLATFORM: SHARED.

export function main(): i32 {
  return 0b101010;
}
