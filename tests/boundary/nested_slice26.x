// Isolated green: 26-layer scalar unused formal must stay a complete
// host-C fat type (nest>25 soft first layer; type_to_c_repr scratch
// is 384 so nest 26 i32 tag=326 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 160.
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 160; }
function main(): i32 {
  return 160;
}
