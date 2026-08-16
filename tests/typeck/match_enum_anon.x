// Official gate: dest-typed match patterns `.Variant =>`.
// Type comes from the match subject. Named `Type.Variant =>`
// still accepted (same tag lookup).
// PLATFORM: SHARED — Ubuntu gold.

enum Color {
  Red,
  Green,
  Blue,
}

/**
 * Dest-typed enum arms + named neighborhood.
 * @param c Color — match subject
 * @return i32 — 1 Green, 0 Red, else -1
 */
function classify(c: Color): i32 {
  return match c {
    .Green => 1;
    .Red => 0;
    _ => -1;
  };
}

/**
 * Named pattern still works (same tag authority).
 * @param c Color — match subject
 * @return i32 — 1 Green, else 0
 */
function named_green(c: Color): i32 {
  return match c {
    Color.Green => 1;
    _ => 0;
  };
}

/**
 * Official entry: dest-typed `.Green` / `.Red` / `_` + named neighborhood.
 * @return i32 — 0 on success
 */
function main(): i32 {
  if (classify(Color.Green) != 1) {
    return 1;
  }
  if (classify(Color.Red) != 0) {
    return 2;
  }
  if (classify(Color.Blue) != -1) {
    return 3;
  }
  if (named_green(Color.Green) != 1) {
    return 4;
  }
  if (named_green(Color.Red) != 0) {
    return 5;
  }
  return 0;
}
