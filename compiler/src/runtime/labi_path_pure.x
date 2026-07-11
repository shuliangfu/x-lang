// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-267/429 / P2 link_abi L0：路径纯串（无 stat）。
// 产品默认 seeds/runtime_link_abi.from_x.c；hybrid → seeds/labi_path_pure.from_x.c。
// 符号：shux_path_last_sep / shux_path_has_sep / link_abi_ld_argv_entry_is_obj / shux_output_is_elf_o
// G-02f-429：扁平化控制流（消除 &&/||/深层嵌套 if），使全部 4 函数可通过 shux -E。

// G-02f-429：后缀 2 字节匹配（flat early-return，参照 rt_content.x rt_eq2 模式）。
function labi_suffix_eq2(s: *u8, n: usize, a0: u8, a1: u8): i32 {
  if (n < 2) { return 0; }
  if (s[n - 2] != a0) { return 0; }
  if (s[n - 1] != a1) { return 0; }
  return 1;
}

// G-02f-429：后缀 4 字节匹配（flat early-return，参照 rt_content.x rt_eq4 模式）。
function labi_suffix_eq4(s: *u8, n: usize, a0: u8, a1: u8, a2: u8, a3: u8): i32 {
  if (n < 4) { return 0; }
  if (s[n - 4] != a0) { return 0; }
  if (s[n - 3] != a1) { return 0; }
  if (s[n - 2] != a2) { return 0; }
  if (s[n - 1] != a3) { return 0; }
  return 1;
}

#[no_mangle]
function link_abi_ld_argv_entry_is_obj(s: *u8): i32 {
  let n: usize = 0;
  if (s == 0 as *u8) { return 0; }
  if (s[0] == 0) { return 0; }
  while (s[n] != 0) { n = n + 1; }
  if (labi_suffix_eq2(s, n, 46, 111) != 0) { return 1; }
  if (labi_suffix_eq4(s, n, 46, 111, 98, 106) != 0) { return 1; }
  return 0;
}

#[no_mangle]
function shux_output_is_elf_o(path: *u8): i32 {
  let n: usize = 0;
  if (path == 0 as *u8) { return 0; }
  while (path[n] != 0) { n = n + 1; }
  if (labi_suffix_eq2(path, n, 46, 111) != 0) { return 1; }
  if (labi_suffix_eq2(path, n, 46, 79) != 0) { return 1; }
  if (labi_suffix_eq4(path, n, 46, 111, 98, 106) != 0) { return 1; }
  return 0;
}

// G-02f-429：shux_path_has_sep 真迁（POSIX '/' only）。
// 【Why】C 原实现用 strchr(s, '/') + Windows #if strchr(s, '\\')；
//   .x 无法表达 C #if host 分支，POSIX 路径分隔符仅 '/' (47)，故纯串扫描等价。
// 【Invariant】s == NULL → 0；否则扫描至 NUL，遇 '/' 即返回 1。
// 【Perf】单趟线性扫描，首次命中即返回，无 libc strchr 调用开销。
#[no_mangle]
function shux_path_has_sep(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  let i: usize = 0;
  while (s[i] != 0) {
    if (s[i] == 47) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

// G-02f-429：shux_path_last_sep 真迁（POSIX '/' only）。
// 【Why】C 原实现用 strrchr(s, '/') 返回 char*；.x 无 strrchr，手动逆序记录
//   最后一次 '/' 的偏移。指针返回值通过 s as usize + off as *u8 构造
//   （*u8 as usize 见 diag_thin.x:227；usize as *u8 见 lsp_load_ptr_at）。
// 【Invariant】s == NULL → NULL；无 '/' → NULL；否则返回指向最后一个 '/' 的指针。
// 【Perf】单趟正序扫描记录 last_off，无需 strrchr 二次扫描；末尾一次指针加法。
#[no_mangle]
function shux_path_last_sep(s: *u8): *u8 {
  if (s == 0 as *u8) {
    return 0 as *u8;
  }
  let last: usize = 0;
  let found: i32 = 0;
  let i: usize = 0;
  while (s[i] != 0) {
    if (s[i] == 47) {
      last = i;
      found = 1;
    }
    i = i + 1;
  }
  if (found == 0) {
    return 0 as *u8;
  }
  let base: usize = s as usize;
  return (base + last) as *u8;
}
