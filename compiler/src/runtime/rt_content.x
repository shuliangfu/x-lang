// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-261/306 / P2 R2：content_has_* 纯串 + path 包装 driver_source_has_*。
// R2 full（2026-07-14）：path rest 亦由 .x 提供；FROM_X rest 业务 H=0（仅 marker）。
// 注意：部分 usize 下标/减法写法会触发 parse no functions；索引用 i32 再 cast。
// 产品 PREFER_X_O hybrid：thin full .x + rest 空业务体。

export function rt_eq2(c: *u8, n: i32, p: i32, a0: u8, a1: u8): i32 {
  if (p + 2 > n) {
    return 0;
  }
  if (c[p as usize] != a0) {
    return 0;
  }
  if (c[(p + 1) as usize] != a1) {
    return 0;
  }
  return 1;
}

export function rt_eq3(c: *u8, n: i32, p: i32, a0: u8, a1: u8, a2: u8): i32 {
  if (p + 3 > n) {
    return 0;
  }
  if (c[p as usize] != a0) {
    return 0;
  }
  if (c[(p + 1) as usize] != a1) {
    return 0;
  }
  if (c[(p + 2) as usize] != a2) {
    return 0;
  }
  return 1;
}

export function rt_eq4(c: *u8, n: i32, p: i32, a0: u8, a1: u8, a2: u8, a3: u8): i32 {
  if (p + 4 > n) {
    return 0;
  }
  if (c[p as usize] != a0) {
    return 0;
  }
  if (c[(p + 1) as usize] != a1) {
    return 0;
  }
  if (c[(p + 2) as usize] != a2) {
    return 0;
  }
  if (c[(p + 3) as usize] != a3) {
    return 0;
  }
  return 1;
}

export function rt_eq5(c: *u8, n: i32, p: i32, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8): i32 {
  if (p + 5 > n) {
    return 0;
  }
  if (c[p as usize] != a0) {
    return 0;
  }
  if (c[(p + 1) as usize] != a1) {
    return 0;
  }
  if (c[(p + 2) as usize] != a2) {
    return 0;
  }
  if (c[(p + 3) as usize] != a3) {
    return 0;
  }
  if (c[(p + 4) as usize] != a4) {
    return 0;
  }
  return 1;
}

export function rt_eq6(c: *u8, n: i32, p: i32, a0: u8, a1: u8, a2: u8, a3: u8, a4: u8, a5: u8): i32 {
  if (p + 6 > n) {
    return 0;
  }
  if (c[p as usize] != a0) {
    return 0;
  }
  if (c[(p + 1) as usize] != a1) {
    return 0;
  }
  if (c[(p + 2) as usize] != a2) {
    return 0;
  }
  if (c[(p + 3) as usize] != a3) {
    return 0;
  }
  if (c[(p + 4) as usize] != a4) {
    return 0;
  }
  if (c[(p + 5) as usize] != a5) {
    return 0;
  }
  return 1;
}

export function rt_is_generic_at(content: *u8, n: i32, p: i32): i32 {
  let prev: i32 = 0;
  let q: i32 = 0;
  if (p >= n) {
    return 0;
  }
  if (content[p as usize] != 60) {
    return 0;
  }
  if (p + 1 >= n) {
    return 0;
  }
  if (p > 0) {
    prev = p - 1;
    if (content[prev as usize] == 93) {
      return 0;
    }
  }
  if (content[(p + 1) as usize] == 84) {
    q = p + 2;
    if (q >= n) {
      return 1;
    }
    if (content[q as usize] == 62) {
      return 1;
    }
    if (content[q as usize] == 44) {
      return 1;
    }
  }
  if (rt_eq4(content, n, p, 60, 105, 56, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 105, 49, 54, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 105, 51, 50, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 105, 54, 52, 62) != 0) {
    return 1;
  }
  if (rt_eq4(content, n, p, 60, 117, 56, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 117, 49, 54, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 117, 51, 50, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 117, 54, 52, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 102, 51, 50, 62) != 0) {
    return 1;
  }
  if (rt_eq5(content, n, p, 60, 102, 54, 52, 62) != 0) {
    return 1;
  }
  if (rt_eq6(content, n, p, 60, 98, 111, 111, 108, 62) != 0) {
    return 1;
  }
  return 0;
}

#[no_mangle]
export function content_has_generic_syntax(content: *u8, n: usize): i32 {
  let p: i32 = 0;
  let i: i32 = 0;
  let ni: i32 = 0;
  if (content == 0 as *u8) {
    return 0;
  }
  if (n == 0) {
    return 0;
  }
  ni = n as i32;
  if (ni < 0) {
    ni = 2147483647;
  }
  p = 0;
  while (p < ni) {
    if (rt_is_generic_at(content, ni, p) != 0) {
      return 1;
    }
    p = p + 1;
  }
  if (ni >= 6) {
    i = 0;
    while (i <= ni - 6) {
      if (rt_eq6(content, ni, i, 116, 114, 97, 105, 116, 32) != 0) {
        return 1;
      }
      if (rt_eq6(content, ni, i, 32, 105, 109, 112, 108, 32) != 0) {
        return 1;
      }
      i = i + 1;
    }
  }
  return 0;
}

export function rt_is_compound_at(content: *u8, n: i32, at: i32): i32 {
  if (rt_eq3(content, n, at, 60, 60, 61) != 0) {
    return 1;
  }
  if (rt_eq3(content, n, at, 62, 62, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 43, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 45, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 42, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 47, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 37, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 38, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 124, 61) != 0) {
    return 1;
  }
  if (rt_eq2(content, n, at, 94, 61) != 0) {
    return 1;
  }
  return 0;
}

// G-02f-436：消除 && 条件 → flat helper（避免 -E 指数级分析超时）

export function rt_is_block_comment_end(c: *u8, n: i32, at: i32): i32 {
  if (at + 1 >= n) { return 0; }
  if (c[at as usize] != 42) { return 0; }
  if (c[(at + 1) as usize] != 47) { return 0; }
  return 1;
}

export function rt_is_string_escape(c: *u8, n: i32, at: i32): i32 {
  if (c[at as usize] != 92) { return 0; }
  if (at + 1 >= n) { return 0; }
  return 1;
}

export function rt_is_line_comment_start(c: *u8, n: i32, at: i32): i32 {
  if (at + 1 >= n) { return 0; }
  if (c[at as usize] != 47) { return 0; }
  if (c[(at + 1) as usize] != 47) { return 0; }
  return 1;
}

export function rt_is_block_comment_start(c: *u8, n: i32, at: i32): i32 {
  if (at + 1 >= n) { return 0; }
  if (c[at as usize] != 47) { return 0; }
  if (c[(at + 1) as usize] != 42) { return 0; }
  return 1;
}

#[no_mangle]
export function content_has_compound_assign_syntax(content: *u8, n: usize): i32 {
  let at: i32 = 0;
  let ni: i32 = 0;
  let state: i32 = 0;
  if (content == 0 as *u8) {
    return 0;
  }
  if (n < 3) {
    return 0;
  }
  ni = n as i32;
  if (ni < 0) {
    ni = 2147483647;
  }
  while (at < ni) {
    if (state == 0) {
      if (rt_is_line_comment_start(content, ni, at) != 0) {
        state = 1;
        at = at + 2;
      } else {
        if (rt_is_block_comment_start(content, ni, at) != 0) {
          state = 2;
          at = at + 2;
        } else {
          if (content[at as usize] == 34) {
            state = 3;
            at = at + 1;
          } else {
            if (rt_is_compound_at(content, ni, at) != 0) {
              return 1;
            }
            at = at + 1;
          }
        }
      }
    } else {
      if (state == 1) {
        if (content[at as usize] == 10) {
          state = 0;
        }
        at = at + 1;
      } else {
        if (state == 2) {
          if (rt_is_block_comment_end(content, ni, at) != 0) {
            state = 0;
            at = at + 2;
          } else {
            at = at + 1;
          }
        } else {
          if (rt_is_string_escape(content, ni, at) != 0) {
            at = at + 2;
          } else {
            if (content[at as usize] == 34) {
              state = 0;
            }
            at = at + 1;
          }
        }
      }
    }
  }
  return 0;
}

// G-02f-436 / R2 path rest：driver_source_has_* 真迁 .x
// peek 经 extern；content 用 u8[65536] 栈缓冲（-E 已验可发射）；path 拷入 u8[512] 尾 0。

export extern "C" function driver_peek_source_file(path: *u8, content: *u8, cap: i64): i32;

/** path[0..path_len) 拷到 path_buf 并写尾 0；成功 1 / 失败 0。 */
export function rt_path_copy_nul(path: *u8, path_len: i32, path_buf: *u8): i32 {
  let i: i32 = 0;
  if (path_len <= 0) {
    return 0;
  }
  if (path_len >= 512) {
    return 0;
  }
  while (i < path_len) {
    path_buf[i as usize] = path[i as usize];
    i = i + 1;
  }
  path_buf[path_len as usize] = 0;
  return 1;
}

/** 检测 path 指向的源码是否含泛型语法；peek 后转 content_has_generic_syntax。 */
#[no_mangle]
export function driver_source_has_generic_syntax(path: *u8, path_len: i32): i32 {
  let content: u8[65536] = [];
  let path_buf: u8[512] = [];
  let rn: i32 = 0;
  if (rt_path_copy_nul(path, path_len, &path_buf[0]) == 0) {
    return 0;
  }
  unsafe {
    rn = driver_peek_source_file(&path_buf[0], &content[0], 65536);
  }
  if (rn < 0) {
    return 0;
  }
  return content_has_generic_syntax(&content[0], rn as usize);
}

/** 检测 path 指向的源码是否含复合赋值；peek 后转 content_has_compound_assign_syntax。 */
#[no_mangle]
export function driver_source_has_compound_assign_syntax(path: *u8, path_len: i32): i32 {
  let content: u8[65536] = [];
  let path_buf: u8[512] = [];
  let rn: i32 = 0;
  if (rt_path_copy_nul(path, path_len, &path_buf[0]) == 0) {
    return 0;
  }
  unsafe {
    rn = driver_peek_source_file(&path_buf[0], &content[0], 65536);
  }
  if (rn < 0) {
    return 0;
  }
  return content_has_compound_assign_syntax(&content[0], rn as usize);
}

