// Isolated green: 25-layer Named unused formal must stay a complete
// host-C companion fat (nest>24 soft first layer; type_to_c_repr
// scratch is 384 so nest 25 named tags fit).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 155.
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][]Cell): i32 { return 155; }
function main(): i32 {
  return 155;
}
