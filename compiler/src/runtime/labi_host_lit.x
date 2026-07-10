// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-269 / P2 link_abi L2：host 字面量探测（编译期 #if，非 uname）。
// 产品实现：seeds/labi_host_lit.from_x.c；hybrid 宏 SHUX_LABI_HOST_LIT_FROM_X。
//
// 符号：
//   shux_host_is_linux()
//   shux_host_is_apple_aarch64()
// .x 侧无法表达 C #if host 表；本文件为锚点，与 cfg host lit 双机制一致（f-182）。
