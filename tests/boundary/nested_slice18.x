// Isolated green: 18-layer scalar unused formal must stay a complete
// host-C fat type (nest>17 soft next layer; type_to_c_repr 256 still holds).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 80.
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][]i32): i32 { return 80; }
function main(): i32 {
  return 80;
}
