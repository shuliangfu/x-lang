// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-275 / P2 link_abi L6：invoke_ld 纯表（brew -L / compress -l* / tail flags）。
// 产品实现：seeds/labi_invoke_ld_list.from_x.c；hybrid 宏 SHUX_LABI_INVOKE_LD_LIST_FROM_X。
//
// 符号：labi_ld_brew_lib_path_* / labi_ld_flag_* / labi_ld_driver_* / labi_ld_compress_flag_*
// spawn/ld 路径仍在 mega shux_asm_invoke_ld_platform（🔒）。
