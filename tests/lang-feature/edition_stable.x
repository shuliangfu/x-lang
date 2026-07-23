/**
 * See implementation.
 */
#if XLANG_EDITION_2025
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return 99;
}
#else
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return 0;
}
#endif
