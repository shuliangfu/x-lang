// See implementation.
const path = import("std.path");

/** Internal function `bytes_eq`.
 * Implements `bytes_eq`.
 * @param a *u8
 * @param a_len i32
 * @param b *u8
 * @param b_len i32
 * @return i32
 */
function bytes_eq(a: *u8, a_len: i32, b: *u8, b_len: i32): i32 {
  if (a_len != b_len) { return 0; }
  let i: i32 = 0;
  while (i < a_len) {
    if (a[i] != b[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** Internal function `check_clean`.
 * Implements `check_clean`.
 * @param src_path *u8
 * @param path_len i32
 * @param expect *u8
 * @param expect_len i32
 * @param err i32
 * @return i32
 */
function check_clean(src_path: *u8, path_len: i32, expect: *u8, expect_len: i32, err: i32): i32 {
  let out: u8[128] = [];
  let n: i32 = path.clean(src_path, path_len, &out[0], 128);
  if (n != expect_len) { return err; }
  if (bytes_eq(&out[0], n, expect, expect_len) == 0) { return err + 1; }
  return 0;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let out: u8[128] = [];
  let n: i32 = 0;
  let ec: i32 = 0;

  // See implementation.
  let multi_slash: u8[8] = [47, 47, 97, 47, 47, 47, 98, 0];
  let expect_ab: u8[4] = [47, 97, 47, 98];
  ec = check_clean(&multi_slash[0], 7, &expect_ab[0], 4, 10);
  if (ec != 0) { return ec; }

  // See implementation.
  let trail: u8[9] = [47, 102, 111, 111, 47, 98, 97, 114, 47];
  let expect_foo_bar: u8[8] = [47, 102, 111, 111, 47, 98, 97, 114];
  ec = check_clean(&trail[0], 9, &expect_foo_bar[0], 8, 20);
  if (ec != 0) { return ec; }

  // See implementation.
  let rel_dots: u8[16] = [
    102, 111, 111, 47, 46, 47, 98, 97, 114, 47, 46, 46, 47, 98, 97, 122
  ];
  let expect_foo_baz: u8[8] = [102, 111, 111, 47, 47, 98, 97, 122];
  ec = check_clean(&rel_dots[0], 16, &expect_foo_baz[0], 8, 30);
  if (ec != 0) { return ec; }

  // See implementation.
  let root_up: u8[3] = [47, 46, 46];
  let expect_root: u8[1] = [47];
  ec = check_clean(&root_up[0], 3, &expect_root[0], 1, 40);
  if (ec != 0) { return ec; }

  // See implementation.
  let mixed_sep: u8[4] = [97, 92, 92, 98];
  let expect_mixed: u8[3] = [97, 47, 98];
  ec = check_clean(&mixed_sep[0], 4, &expect_mixed[0], 3, 50);
  if (ec != 0) { return ec; }

  // See implementation.
  let four_dot: u8[8] = [120, 47, 46, 46, 46, 46, 47, 121];
  let expect_four: u8[8] = [120, 47, 46, 46, 46, 46, 47, 121];
  ec = check_clean(&four_dot[0], 8, &expect_four[0], 8, 60);
  if (ec != 0) { return ec; }

  // See implementation.
  let base: u8[4] = [47, 97, 47, 98];
  let abs_ref: u8[5] = [47, 120, 47, 121, 122];
  n = path.resolve(&out[0], 128, &base[0], 4, &abs_ref[0], 5);
  if (n != 5) { return 70; }
  if (out[0] != 47 || out[4] != 122) { return 71; }

  // See implementation.
  let hidden: u8[10] = [46, 103, 105, 116, 105, 103, 110, 111, 114, 101];
  let ext_buf: u8[8] = [];
  n = path.extension(&hidden[0], 10, &ext_buf[0], 8);
  if (n != 0) { return 80; }

  // path_extension_and_stem：file.tar.gz
  let tarball: u8[12] = [102, 105, 108, 101, 46, 116, 97, 114, 46, 103, 122, 0];
  let ext2: u8[8] = [];
  let stem2: u8[8] = [];
  let combo: i32 = path.extension_and_stem(&tarball[0], 11, &ext2[0], 8, &stem2[0], 8);
  if (combo < 0) { return 90; }
  let stem_len: i32 = (combo >> 16) & 65535;
  let ext_len: i32 = combo & 65535;
  if (stem_len != 8 || ext_len != 3) { return 91; }
  if (stem2[7] != 114 || ext2[0] != 46 || ext2[2] != 122) { return 92; }

  // See implementation.
  let win_abs: u8[6] = [67, 58, 92, 85, 115, 101];
  if (path.is_absolute(&win_abs[0], 6) != 1) { return 100; }

  return 0;
}
