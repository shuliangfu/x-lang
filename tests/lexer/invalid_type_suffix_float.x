// wave279 Cap residual: type suffix after float literal → sticky L009 hard diag.
function main(): i32 {
  return 1.5f32 as i32;
}
