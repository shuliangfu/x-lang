// Isolated green: 1-layer body const already parsed (shallow INT walk).
// Neighborhood for the is_let-gate removal — must stay green, no INDEX.
// Expected: compile = 0, run = 42.
// PLATFORM: SHARED — Ubuntu gold parser.

function main(): i32 {
  const x: []i32 = [10, 32];
  return 42;
}
