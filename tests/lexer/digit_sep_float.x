// Probe: float fraction/exponent digit separators (wave277).
// 4.2e1 == 42; separators: 4.2e1 → 4_.2e1 not valid (after . before digit ok: 4.2_0e1)
// Use 0.42e2 with seps: 0.4_2e2 = 42
// PLATFORM: SHARED.
export function main(): i32 {
  return (0.4_2e2) as i32;
}
