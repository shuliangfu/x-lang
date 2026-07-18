// See implementation.
#if target_os == "linux"
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 { return 41; }
#elseif target_os == "macos"
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 { return 42; }
#else
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 { return 43; }
#endif
