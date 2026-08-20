// Isolated green: 31-layer Named unused formal must stay a complete
// host-C companion fat (nest>30 first layer; type_to_c_repr
// scratch is 512 so nest 31 named tags fit).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 215.
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]Cell): i32 { return 215; }
function main(): i32 {
  return 215;
}
