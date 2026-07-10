// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-265 / P2 R3：preamble ABI 内联写盘（write_io_net / write_fs_path_map_error）。
// 大块字符串表以 seeds/rt_preamble.from_x.c 为产品实现；本文件为逻辑锚点。
// Hybrid：SHUX_RT_PREAMBLE_FROM_X + ld -r → runtime_driver_no_c.o。
// 依赖：codegen_get_preamble_skip_mask（strict_glue / pipeline stubs）。

// 符号面（与 seed 一致）：
//   write_io_net_abi_inline(FILE*)
//   write_fs_path_map_error_abi_inline(FILE*)
// 完整 C 字符串表不在此展开（避免 -E 体积/挂起）；改表时同步 seeds/rt_preamble.from_x.c。
