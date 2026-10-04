// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// C text sink shared by codegen.x and codegen_late.x.
// Callers pass a pointer. One definition keeps both TUs on the same type.
// PLATFORM: SHARED.

export struct CodegenOutBuf {
  data: u8[9437184];
  length: i32;
}
