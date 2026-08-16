// Isolated green: 41-layer Named unused formal must stay a complete
// host-C companion fat (nest>40 first layer; type_to_c_repr
// scratch is 512 so nest 41 named tags fit).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 51 (stay in 0..255; nest*10+15 would be 425).
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]Cell): i32 { return 51; }
function main(): i32 {
  return 51;
}
