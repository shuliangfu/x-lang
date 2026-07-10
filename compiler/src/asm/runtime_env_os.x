// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-19：runtime_env_os 产品源迁 seeds/runtime_env_os.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_env_os.from_x.c → runtime_env_os.o
// G-02f-103：+ env_build_key 薄门闩。

extern "C" function env_build_key_impl(key: *u8, key_len: i32, key_buf: *u8): i32;

function runtime_env_os_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-103：env key build 门闩 ---- */

#[no_mangle]
function env_build_key(key: *u8, key_len: i32, key_buf: *u8): i32 {
  unsafe {
    return env_build_key_impl(key, key_len, key_buf);
  }
  return 0 - 1;
}
