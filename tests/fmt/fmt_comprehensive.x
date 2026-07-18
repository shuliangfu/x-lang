// See implementation.
// See implementation.

// See implementation.
// Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

/**
* See implementation.
* See implementation.
*/

/* See implementation. */

const option = import("core.option");

// fmt_comp_semicolon_chain: see function docblock below.
/** Internal function `fmt_comp_semicolon_chain`.
 * Implements `fmt_comp_semicolon_chain`.
 * @return i32
 */
function fmt_comp_semicolon_chain(): i32 {
  let prefix: u8[48] = [];
  prefix[0] = 1; prefix[1] = 2; prefix[2] = 3; prefix[3] = 4; prefix[4] = 5; prefix[5] = 6;
  prefix[6] = 7; prefix[7] = 8; prefix[8] = 9; prefix[9] = 10; prefix[10] = 11; prefix[11] = 12;
  prefix[12] = 13; prefix[13] = 14; prefix[14] = 15; prefix[15] = 16;
  return prefix[0] + prefix[15];
}

// fmt_comp_space_chain: see function docblock below.
/** Internal function `fmt_comp_space_chain`.
 * Implements `fmt_comp_space_chain`.
 * @return i32
 */
function fmt_comp_space_chain(): i32 {
  let first_long_name: i32 = 1;
  let second_long_name: i32 = 2;
  let third_long_name: i32 = 3;
  return first_long_name + second_long_name + third_long_name;
}

// fmt_comp_no_break_token: see function docblock below.
/** Internal function `fmt_comp_no_break_token`.
 * Implements `fmt_comp_no_break_token`.
 * @return i32
 */
function fmt_comp_no_break_token(): i32 {
  let verylongidentifierwithoutanyspaces: i32 = 42;
  return verylongidentifierwithoutanyspaces;
}

// fmt_comp_nested: see function docblock below.
/** Internal function `fmt_comp_nested`.
 * Implements `fmt_comp_nested`.
 * @return i32
 */
function fmt_comp_nested(): i32 {
  let acc: i32 = 0;
  if (acc == 0) {
    let inner_a: i32 = 1;
    let inner_b: i32 = 2;
  }
  return acc;
}

// fmt_comp_call_args: see function docblock below.
/** Internal function `fmt_comp_call_args`.
 * Implements `fmt_comp_call_args`.
 * @param a i32
 * @param b i32
 * @param c i32
 * @param d i32
 * @return i32
 */
function fmt_comp_call_args(a: i32, b: i32, c: i32, d: i32): i32 {
  return a + b + c + d;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let x: i32 = fmt_comp_semicolon_chain();
  let y: i32 = fmt_comp_space_chain();
  let z: i32 = fmt_comp_no_break_token();
  let w: i32 = fmt_comp_nested();
  let v: i32 = fmt_comp_call_args(x, y, z, w);
  return v;
}
