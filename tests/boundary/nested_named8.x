// Isolated green: 8-layer [][][][][][][][]Cell unused formal must stay a
// complete host-C companion fat (4.2.3 loop to 16). take unused so a
// missing body cannot fake the result; -E must still contain take.
// Expected: compile = 0, run = 55.
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][]Cell): i32 { return 55; }
function main(): i32 {
  return 55;
}
