// Isolated green: 44-layer Named unused formal must stay a complete
// host-C companion fat (nest>43 first layer; type_to_c_repr
// scratch is 640 so nest 44 named tags fit).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 54 (stay in 0..255; nest*10+15 would be 455).
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]Cell): i32 { return 54; }
function main(): i32 {
  return 54;
}
