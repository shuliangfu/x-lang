// See implementation.
enum Color { RED, GREEN, BLUE }

/** Internal function `pick`.
 * Implements `pick`.
 * @param c Color
 * @return i32
 */
function pick(c: Color): i32 {
  return match (c) {
    RED => 1,
    GREEN => 2,
    BLUE => 3,
  };
}
