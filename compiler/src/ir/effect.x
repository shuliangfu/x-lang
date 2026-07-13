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

// effect.x — Effect 枚举 + EffectPool（独立子系统）
//
// 模块：ir
// 层级：共享（被 Scheduler / Alias Analysis / LICM / DCE / Inline 等 Pass 消费）
// Phase：Phase 2+（SMIR 阶段需要 Effect 区分 Pure / ReadOnly / Write）
// 职责：
//   - 定义 Effect 枚举（Pure / ReadOnly / Write / Call / Atomic / Fence）
//   - 实现 EffectPool：Arena 存储 + HashMap 去重
//   - 提供 effect_id 间接引用接口
// 依赖：abi（ABIKind 用于 Call{kind}）
// 设计约束：
//   - Effect 独立于 Contract：Scheduler 只查 Effect 不查 Ownership（§1.7 Pass 消费关系表）
//   - 同样池化去重：1 万个 Pure 指令共用 EffectId(0)
//   - Effect 不变量：变换前后 Effect 集合不变
//
// 参考文档：analysis/IR核心设计.md §1.7（Effect 独立子系统）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 2 填充
