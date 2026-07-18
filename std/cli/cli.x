// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// See implementation.
//
// See implementation.
// See implementation.

/* See implementation. */
export const CLI_LIT_HELP: u8[7] = [45, 45, 104, 101, 108, 112, 0];

extern "C" function memcmp(a: *u8, b: *u8, n: usize): i32;
extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;

/* See implementation. */
allow(padding) struct CliResult {
  subcommand_len: i32
  help: i32
  version: i32
  verbose: i32
  unknown: i32
  positional_count: i32
  subcommand: u8[64]
  positional0_len: i32
  positional0: u8[128]
}

/** Exported function `cli_bytes_eq`.
 * Implements `cli_bytes_eq`.
 * @param a *u8
 * @param alen i32
 * @param b *u8
 * @param blen i32
 * @return i32
 */
export function cli_bytes_eq(a: *u8, alen: i32, b: *u8, blen: i32): i32 {
  let i: i32 = 0;
  if (alen != blen) { return 0; }
  while (i < alen) {
    if (a[i] != b[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** Exported function `cli_is_help_c`.
 * Implements `cli_is_help_c`.
 * @param arg *u8
 * @param len i32
 * @return i32
 */
export function cli_is_help_c(arg: *u8, len: i32): i32 {
  if (arg == 0 || len <= 0) { return 0; }
  if (len == 2 && arg[0] == 45 && arg[1] == 104) { return 1; }
  if (len == 6 && arg[0] == 45 && arg[1] == 45 &&
      arg[2] == 104 && arg[3] == 101 && arg[4] == 108 && arg[5] == 112) {
    return 1;
  }
  return 0;
}

/** Exported function `cli_is_version_c`.
 * Implements `cli_is_version_c`.
 * @param arg *u8
 * @param len i32
 * @return i32
 */
export function cli_is_version_c(arg: *u8, len: i32): i32 {
  if (arg == 0 || len <= 0) { return 0; }
  if (len == 9 && arg[0] == 45 && arg[1] == 45 &&
      arg[2] == 118 && arg[3] == 101 && arg[4] == 114 &&
      arg[5] == 115 && arg[6] == 105 && arg[7] == 111 && arg[8] == 110) {
    return 1;
  }
  return 0;
}

/** Exported function `cli_match_long_c`.
 * Implements `cli_match_long_c`.
 * @param arg *u8
 * @param len i32
 * @param name *u8
 * @param name_len i32
 * @return i32
 */
export function cli_match_long_c(arg: *u8, len: i32, name: *u8, name_len: i32): i32 {
  if (arg == 0 || name == 0 || len < 2 + name_len) { return 0; }
  if (arg[0] != 45 || arg[1] != 45) { return 0; }
  return cli_bytes_eq(arg + 2, len - 2, name, name_len);
}

/** Exported function `cli_match_short_c`.
 * Implements `cli_match_short_c`.
 * @param arg *u8
 * @param len i32
 * @param c u8
 * @return i32
 */
export function cli_match_short_c(arg: *u8, len: i32, c: u8): i32 {
  let i: i32 = 0;
  if (arg == 0 || len < 2 || arg[0] != 45) { return 0; }
  if (len == 2 && arg[1] == c) { return 1; }
  i = 1;
  while (i < len) {
    if (arg[i] == c) { return 1; }
    i = i + 1;
  }
  return 0;
}

/** Exported function `cli_copy_lit`.
 * Implements `cli_copy_lit`.
 * @param out *u8
 * @param out_cap i32
 * @param off i32
 * @param lit *u8
 * @param lit_len i32
 * @return i32
 */
export function cli_copy_lit(out: *u8, out_cap: i32, off: i32, lit: *u8, lit_len: i32): i32 {
  let i: i32 = 0;
  if (off + lit_len >= out_cap) { return -1; }
  while (i < lit_len) {
    out[off + i] = lit[i];
    i = i + 1;
  }
  return off + lit_len;
}

/* See implementation. */
export function cli_write_usage_c(prog: *u8, prog_len: i32, desc: *u8, desc_len: i32,
                           out: *u8, out_cap: i32): i32 {
  let n: i32 = 0;
  let u1: u8[7] = [85, 115, 97, 103, 101, 58, 32];
  let u2: u8[24] = [32, 91, 115, 117, 98, 99, 111, 109, 109, 97, 110, 100, 93, 32, 91, 111, 112, 116, 105, 111, 110, 115, 93, 10];
  if (prog == 0 || desc == 0 || out == 0 || out_cap <= 0) { return -1; }
  n = cli_copy_lit(out, out_cap, 0, &u1[0], 7);
  if (n < 0) { return -1; }
  if (n + prog_len >= out_cap) { return -1; }
  unsafe { memcpy(out + n, prog, prog_len); }
  n = n + prog_len;
  n = cli_copy_lit(out, out_cap, n, &u2[0], 24);
  if (n < 0) { return -1; }
  if (n + desc_len + 1 >= out_cap) { return -1; }
  unsafe { memcpy(out + n, desc, desc_len); }
  n = n + desc_len;
  out[n] = 10;
  n = n + 1;
  return n;
}

/* See implementation. */
export function cli_parse_args_c(argv: * *u8, lens: *i32, argc: i32,
                          expect_sub: *u8, expect_sub_len: i32, out: *CliResult): i32 {
  let i: i32 = 0;
  let a: *u8 = 0;
  let al: i32 = 0;
  let verbose_name: u8[7] = [118, 101, 114, 98, 111, 115, 101];
  if (out == 0) { return -1; }
  out.subcommand_len = 0;
  out.help = 0;
  out.version = 0;
  out.verbose = 0;
  out.unknown = 0;
  out.positional_count = 0;
  out.positional0_len = 0;
  if (argc <= 1) { return 0; }
  i = 1;
  while (i < argc) {
    a = argv[i];
    al = lens[i];
    if (a == 0 || al <= 0) {
      i = i + 1;
      continue;
    }
    if (cli_is_help_c(a, al) != 0) {
      out.help = 1;
      return 1;
    }
    if (cli_is_version_c(a, al) != 0) {
      out.version = 1;
      return 0;
    }
    if (cli_match_long_c(a, al, &verbose_name[0], 7) != 0) {
      out.verbose = 1;
      i = i + 1;
      continue;
    }
    if (cli_match_short_c(a, al, 118) != 0) {
      out.verbose = 1;
      i = i + 1;
      continue;
    }
    if (a[0] == 45) {
      out.unknown = 1;
      return -1;
    }
    if (out.subcommand_len == 0 && expect_sub_len > 0 &&
        cli_bytes_eq(a, al, expect_sub, expect_sub_len) != 0) {
      if (al >= 64) { return -1; }
      unsafe { memcpy(&out.subcommand[0], a, al); }
      out.subcommand[al] = 0;
      out.subcommand_len = al;
      i = i + 1;
      continue;
    }
    if (out.positional_count == 0) {
      if (al >= 128) { return -1; }
      unsafe { memcpy(&out.positional0[0], a, al); }
      out.positional0[al] = 0;
      out.positional0_len = al;
      out.positional_count = 1;
      i = i + 1;
      continue;
    }
    out.unknown = 1;
    return -1;
  }
  return 0;
}

/** Exported function `cli_smoke_c`.
 * Implements `cli_smoke_c`.
 * @return i32
 */
export function cli_smoke_c(): i32 {
  let r: CliResult;
  let argv: *u8[5];
  let lens: i32[5];
  let a0: u8[4] = [116, 111, 111, 108];
  let a1: u8[3] = [114, 117, 110];
  let a2: u8[9] = [45, 45, 118, 101, 114, 98, 111, 115, 101];
  let a3: u8[8] = [102, 105, 108, 101, 46, 116, 120, 116];
  let run_sub: u8[3] = [114, 117, 110];
  let demo: u8[4] = [100, 101, 109, 111];
  let usage: u8[128];
  argv[0] = &a0[0]; lens[0] = 4;
  argv[1] = &a1[0]; lens[1] = 3;
  argv[2] = &a2[0]; lens[2] = 9;
  argv[3] = &a3[0]; lens[3] = 8;
  if (cli_parse_args_c(&argv[0], &lens[0], 4, &run_sub[0], 3, &r) != 0) { return 1; }
  if (r.subcommand_len != 3 || r.verbose != 1 || r.positional_count != 1) { return 2; }
  if (cli_is_help_c(&CLI_LIT_HELP[0], 6) != 1) { return 3; }
  if (cli_write_usage_c(&a0[0], 4, &demo[0], 4, &usage[0], 128) <= 0) { return 4; }
  return 0;
}
