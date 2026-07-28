// Probe: numeric digit separators `_` (wave277 Cap residual pure).
// 4_2 == 42; also exercises 0x / 0b / 0o / float paths in companion probes.
// PLATFORM: SHARED.

export function main(): i32 {
  return 4_2;
}
