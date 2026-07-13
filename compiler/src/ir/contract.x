// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
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

// contract.x — Contract 结构体 + ContractPool（池化去重）
//
// 模块：ir
// 层级：共享（被五层 IR 共同消费）
// Phase：Phase 0（C-Emitter 提取契约注释）→ Phase 1+（SHIR lowering 自动生成）
// 职责：
//   - 定义 Contract 结构体（pre / post / effect_id / ownership 四字段）
//   - 实现 ContractPool：Arena 紧致存储 + HashMap 去重索引
//   - 提供 contract_id 间接引用接口（IRInst 只持 4 字节 ID）
// 依赖：effect（引用 EffectId）
// 设计约束：
//   - 池化去重：1 万个 load 共用 ContractId(7)，IR 体积从 ~200B/指令降至 ~32B/指令
//   - Pass 比较契约只比 contract_id（整数相等），不深比较结构体
//   - 契约不变量：变换前后 pre ⊆ / post ⊇ / effects 不变（§1.4）
//
// 参考文档：analysis/IR核心设计.md §1.2（Contract Pool + Metadata ID）/ §1.3（契约验证机制）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 0 填充
