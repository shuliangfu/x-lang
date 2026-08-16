// Isolated green: 32-layer Named unused formal must stay a complete
// host-C companion fat (nest>31 first layer; type_to_c_repr
// scratch is 512 so nest 32 named tags fit).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 225.
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]Cell): i32 { return 225; }
function main(): i32 {
  return 225;
}
