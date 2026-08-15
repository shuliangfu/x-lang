// Isolated green: 20-layer Named unused formal must stay a complete
// host-C companion fat (nest>19 soft next layer; type_to_c_repr 256 still holds).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 105.
// PLATFORM: SHARED — Ubuntu gold host-C.

struct Cell { v: i32 }
function take(x: [][][][][][][][][][][][][][][][][][][][]Cell): i32 { return 105; }
function main(): i32 {
  return 105;
}
