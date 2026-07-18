// helper_os: see function docblock below.
#[cfg(target_os = "macos")]
/** Internal function `helper_os`.
 * Implements `helper_os`.
 * @return i32
 */
function helper_os(): i32 {
  return 5;
}

#[cfg(target_os = "linux")]
/** Internal function `helper_os`.
 * Implements `helper_os`.
 * @return i32
 */
function helper_os(): i32 {
  return 7;
}

#[cfg(target_os = "freebsd")]
/** Internal function `helper_os`.
 * Implements `helper_os`.
 * @return i32
 */
function helper_os(): i32 {
  return 9;
}

#[cfg(target_arch = "aarch64")]
/** Internal function `helper_arch`.
 * Implements `helper_arch`.
 * @return i32
 */
function helper_arch(): i32 {
  return 11;
}

#[cfg(target_arch = "x86_64")]
/** Internal function `helper_arch`.
 * Implements `helper_arch`.
 * @return i32
 */
function helper_arch(): i32 {
  return 22;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return helper_os() + helper_arch();
}
