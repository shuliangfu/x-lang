// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-267 / P2 link_abi L0：路径纯串（无 stat）。
// 产品默认 seeds/runtime_link_abi.from_x.c；hybrid → seeds/labi_path_pure.from_x.c。
// 符号：shux_path_last_sep / shux_path_has_sep / link_abi_ld_argv_entry_is_obj / shux_output_is_elf_o

#[no_mangle]
function link_abi_ld_argv_entry_is_obj(s: *u8): i32 {
  let n: usize = 0;
  if (s == 0 as *u8) {
    return 0;
  }
  if (s[0] == 0) {
    return 0;
  }
  while (s[n] != 0) {
    n = n + 1;
  }
  if (n >= 2) {
    if (s[n - 2] == 46 && s[n - 1] == 111) {
      return 1;
    }
  }
  if (n >= 4) {
    if (s[n - 4] == 46 && s[n - 3] == 111 && s[n - 2] == 98 && s[n - 1] == 106) {
      return 1;
    }
  }
  return 0;
}

#[no_mangle]
function shux_output_is_elf_o(path: *u8): i32 {
  let n: usize = 0;
  if (path == 0 as *u8) {
    return 0;
  }
  while (path[n] != 0) {
    n = n + 1;
  }
  if (n >= 2) {
    if (path[n - 2] == 46) {
      if (path[n - 1] == 111 || path[n - 1] == 79) {
        return 1;
      }
    }
  }
  if (n >= 4) {
    if (path[n - 4] == 46 && path[n - 3] == 111 && path[n - 2] == 98 && path[n - 1] == 106) {
      return 1;
    }
  }
  return 0;
}
