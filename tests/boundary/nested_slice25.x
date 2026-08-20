// Isolated green: 25-layer scalar unused formal must stay a complete
// host-C fat type (nest>24 soft first layer; type_to_c_repr scratch
// is 384 so nest 25 i32 tag=314 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 150.
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 150; }
function main(): i32 {
  return 150;
}
