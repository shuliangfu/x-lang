// wave281 Cap residual: invalid string escape must hard-fail L010 (not silent keep).
// Product escape set: \n \t \r \0 \\ \" \xHH only.
// PLATFORM: SHARED

function main(): i32 {
  let s: *u8 = "\q";
  return 42;
}
