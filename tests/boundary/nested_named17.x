// Isolated green: 17-layer Named unused formal must stay a complete
// host-C companion fat (nest>16 soft first layer past the 4.2.3 16-layer cap).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 75.
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][][]Cell): i32 { return 75; }
function main(): i32 {
  return 75;
}
