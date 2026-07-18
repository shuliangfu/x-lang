// See implementation.
#if FOO
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 { return 1; }
#else
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 { return 2; }
#else
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 { return 3; }
#endif
