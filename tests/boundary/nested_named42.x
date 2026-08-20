// Isolated green: 42-layer Named unused formal must stay a complete
// host-C companion fat (nest>41 first layer; type_to_c_repr
// scratch is 640 so nest 42 named tags fit).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 52 (stay in 0..255; nest*10+15 would be 435).
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]Cell): i32 { return 52; }
function main(): i32 {
  return 52;
}
