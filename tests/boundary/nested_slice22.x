// Isolated green: 22-layer scalar unused formal must stay a complete
// host-C fat type (nest>21 soft first layer; type_to_c_repr scratch
// is 384 so nest 22 i32 tag=278 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 120.
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 120; }
function main(): i32 {
  return 120;
}
