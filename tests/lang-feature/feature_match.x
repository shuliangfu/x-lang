/**
 * See implementation.
 */
#if XLANG_FEATURE_MATCH_STMT
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return 42;
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
