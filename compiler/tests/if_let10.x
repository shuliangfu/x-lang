/** if-branch let with initial value 10 (avoids block-tail literal path). */

/**
 * Return 10 via true branch with an intermediate let binding.
 * The false branch returns 20 but is dead for this constant condition.
 */
function main(): i32 {
  return if (true) { let t: i32 = 10; t } else { 20 }
}
