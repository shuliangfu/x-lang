// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-268 / P2 link_abi L1：诊断纯映射与 report 薄封装（无 wait/errno/stat）。
// 产品实现：seeds/labi_diag_pure.from_x.c；hybrid 宏 SHUX_LABI_DIAG_PURE_FROM_X。
//
// 符号面：
//   link_diag_code_for_kind
//   link_diag_runtime_obj_resolve_fail / source_missing / source_missing_under / obj_missing
//   link_diag_freestanding_missing / freestanding_unsupported
//   link_diag_ld_debug_push / ld_debug_argv
// 依赖 diag_report*（diag.o）。

// 逻辑源锚点：完整 C 见 seeds/labi_diag_pure.from_x.c（va_list reportf 不宜 -E 全量）。
