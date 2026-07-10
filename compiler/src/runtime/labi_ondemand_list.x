// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-272 / P2 link_abi L8b：on_demand 符号组 / rel 纯表。
// 产品实现：seeds/labi_ondemand_list.from_x.c；hybrid 宏 SHUX_LABI_ONDEMAND_LIST_FROM_X。
//
// 符号：
//   labi_od_simple_group_*（string/core_types/encoding/base64/csv/schema）
//   labi_od_kv_* / labi_od_arrow_* / labi_od_time_* / labi_od_queue_*
//   labi_od_rel_*（needs_* 分支 rel 常量）
// nm 探针与 push/ensure 仍在 mega append_on_demand_user_objs。
