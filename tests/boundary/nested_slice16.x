// Isolated green: 16-layer scalar unused formal must stay a complete
// host-C fat type (4.2.3 hard cap). take unused so a missing body cannot
// fake the result; -E must still contain take.
// Expected: compile = 0, run = 60.
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][]i32): i32 { return 60; }
function main(): i32 {
  return 60;
}
