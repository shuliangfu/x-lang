// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-274 / P2 link_abi L5：invoke_cc 纯表（harden / skip-native env / needs rel）。
// 产品实现：seeds/labi_invoke_cc_list.from_x.c；hybrid 宏 SHUX_LABI_INVOKE_CC_LIST_FROM_X。
//
// 符号：
//   labi_linux_harden_flag_* / labi_invoke_cc_skip_native_env_*
//   invoke_cc_skip_native_tuning
//   labi_icc_rel_* / labi_icc_needs_rel_*
// fork/exec 仍在 mega shux_invoke_cc_impl（🔒）。
