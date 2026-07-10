// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-270 / P2 link_abi L3：路径探活（stat / realpath）🔒 OS。
// 产品实现：seeds/labi_path_io.from_x.c；hybrid 宏 SHUX_LABI_PATH_IO_FROM_X。
//
// 符号：
//   shux_path_is_nonempty_regular_file_impl / shux_path_is_nonempty_regular_file
//   asm_link_obj_skip_missing
//   shux_runtime_o_realpath_if_exists
// 语言限制：依赖 libc stat/realpath；.x 为锚点，不宜 -E 替代。
