// Isolated green: 16-layer Named unused formal must stay a complete
// host-C companion fat (4.2.3 hard cap). take unused so a missing body
// cannot fake the result; -E must still contain take.
// Expected: compile = 0, run = 65.
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][]Cell): i32 { return 65; }
function main(): i32 {
  return 65;
}
