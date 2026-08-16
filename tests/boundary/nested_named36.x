// Isolated green: 36-layer Named unused formal must stay a complete
// host-C companion fat (nest>35 first layer; type_to_c_repr
// scratch is 512 so nest 36 named tags fit).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 46 (stay in 0..255; nest*10+15 would be 265).
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]Cell): i32 { return 46; }
function main(): i32 {
  return 46;
}
