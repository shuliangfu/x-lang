// wave279 Cap residual: type suffix glued to int must hard-fail L009 (not soft XP003).
// Language has no C/Rust-style numeric type suffixes; use `as T` or context coerce.
function main(): i32 {
  return 42u32 as i32;
}
