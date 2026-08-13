// Isolated green: body const `[..] as T` uses the same compound reparse
// (token 128). Do not INDEX — 1-layer const INDEX emit is another layer.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold parser.

function main(): i32 {
  const x: []i32 = [10, 32] as []i32;
  return 42;
}
