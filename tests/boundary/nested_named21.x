// Isolated green: 21-layer Named unused formal must stay a complete
// host-C companion fat (nest>20 soft first layer; type_to_c_repr
// scratch is 384 so nest 21 named tags fit).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 115.
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][][][][][][]Cell): i32 { return 115; }
function main(): i32 {
  return 115;
}
