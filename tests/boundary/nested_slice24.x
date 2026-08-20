// Isolated green: 24-layer scalar unused formal must stay a complete
// host-C fat type (nest>23 soft first layer; type_to_c_repr scratch
// is 384 so nest 24 i32 tag=302 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 140.
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 140; }
function main(): i32 {
  return 140;
}
