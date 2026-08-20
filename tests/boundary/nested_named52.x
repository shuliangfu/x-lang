// Isolated green: 52-layer Named unused formal must stay a complete
// host-C companion fat (nest>51 first layer; type_to_c_repr
// scratch is 640 so nest 52 named tags fit).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 62 (stay in 0..255; nest*10+15 would be 535).
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]Cell): i32 { return 62; }
function main(): i32 {
  return 62;
}
