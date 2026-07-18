// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// mod.x — IR 模块入口（re-export）
//
// 模块：ir
// 层级：共享（跨五层 IR 架构）
// Phase：Phase 0+
// 职责：聚合 ir/ 子模块的公共导出，供 pipeline/codegen 调用；声明 Module 顶层结构。
// 依赖：contract / effect / inst / opcode / abi / verify；shir / smir / slir / vmir / mir / pass / target / verify / c_emit
// 设计约束：
//   - Module 持有 contract_pool / effect_pool / cost_model 三大全局池（§2.4）
//   - IRInst 只存 4 字节 contract_id / effect_id，不内联 Contract / Effect
//   - Architecture Freeze：总架构不再修改，仅实现级调整
//
// 参考文档：analysis/IR核心设计.md §2.4（核心数据结构）/ §1.2（Contract Pool）/ §1.7（Effect Pool）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 0 起逐步填充
