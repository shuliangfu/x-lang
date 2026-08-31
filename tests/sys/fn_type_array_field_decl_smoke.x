// 10.3.1 slice11: [N]function field host-C declarator Ret (*fs[N])(args).
// Expect -E host-cc + run=42. PLATFORM: SHARED.

struct Holder {
  fs: [2]function(i32): i32
}

function main(): i32 {
  /* Declarator-only: no array-lit Cap coerce (typeck residual). */
  return 42;
}
