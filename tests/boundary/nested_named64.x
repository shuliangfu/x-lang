// Isolated green: 64-layer Named unused formal must stay a complete
// host-C companion fat (nest>52 jump to product freeze; type_to_c_repr
// scratch is 896 so nest 64 named tags fit).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 74 (stay in 0..255; nest*10+15 would be 655).
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]Cell): i32 { return 74; }
function main(): i32 {
  return 74;
}
