// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-264：产品路径 pure flags（R5-lite；RFC R4 DCE 不进 SHUX_USE_X_DRIVER 产品 .o）。
// hybrid → seeds/rt_emit_flags.from_x.c；默认仍在 runtime.from_x.c。

extern "C" function strcmp(a: *u8, b: *u8): i32;

/** argv 是否含 -E / -E-extern（逻辑锚点；完整实现见 seed slice）。 */
#[no_mangle]
function driver_argv_has_emit_c_flag(argc: i32, argv: **u8): i32 {
  let i: i32 = 1;
  if (argc < 2 || argv == 0 as **u8) {
    return 0;
  }
  while (i < argc) {
    unsafe {
      let a: *u8 = argv[i as usize];
      if (strcmp(a, "-E" as *u8) == 0) {
        return 1;
      }
      if (strcmp(a, "-E-extern" as *u8) == 0) {
        return 1;
      }
    }
    i = i + 1;
  }
  return 0;
}
