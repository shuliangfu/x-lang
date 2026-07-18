trait Double { function double(self): i32; }
impl Double for i32 { function double(self: i32): i32 { return self * 2; } }
/** Internal function `main`.
 * Program/test entry point.
 * @param ) i32 { return 21.double(
 * @return void
 */
function main(): i32 { return 21.double(); }
