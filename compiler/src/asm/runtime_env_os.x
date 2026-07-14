// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-19：runtime_env_os 产品源迁 seeds/runtime_env_os.from_x.c。
// 实现仍在 seed C；本文件为文档锚点。
// 产品：cc seeds/runtime_env_os.from_x.c → runtime_env_os.o
// G-02f-103：+ env_build_key 薄门闩。


export function runtime_env_os_x_doc_anchor(): i32 {
  return 0;
}

/* ---- G-02f-103：env key build 门闩 ---- */

// G-02f-123：env_build_key 真迁 .x

#[no_mangle]
export function env_build_key(key: *u8, key_len: i32, key_buf: *u8): i32 {
  // ENV_KEY_MAX = 256
  if (key == 0) { return 0 - 1; }
  if (key_buf == 0) { return 0 - 1; }
  if (key_len <= 0) { return 0 - 1; }
  if (key_len >= 256) { return 0 - 1; }
  let i: i32 = 0;
  while (i < key_len) {
    key_buf[i] = key[i];
    i = i + 1;
  }
  key_buf[key_len] = 0;
  return 0;
}
