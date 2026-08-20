// Isolated green: 46-layer Named unused formal must stay a complete
// host-C companion fat (nest>45 first layer; type_to_c_repr
// scratch is 640 so nest 46 named tags fit).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 56 (stay in 0..255; nest*10+15 would be 475).
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]Cell): i32 { return 56; }
function main(): i32 {
  return 56;
}
