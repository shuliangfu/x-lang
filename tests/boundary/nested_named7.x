// Isolated green: 7-layer [][][][][][][]Cell unused formal must stay a
// complete host-C companion fat (wave698). take unused so a missing body
// cannot fake the result; -E must still contain take.
// Expected: compile = 0, run = 45.
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][]Cell): i32 { return 45; }
function main(): i32 {
  return 45;
}
