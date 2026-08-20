// Isolated green: 8-layer scalar [][][][][][][][]i32 unused formal must
// stay a complete host-C fat type (wave698). take unused so a missing
// body cannot fake the result; -E must still contain take.
// Expected: compile = 0, run = 40.
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][]i32): i32 { return 40; }
function main(): i32 {
  return 40;
}
