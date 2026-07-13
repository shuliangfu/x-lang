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

// abi.x — X ABI / C ABI 调用约定
//
// 模块：ir
// 层级：共享（SMIR 内联决策 / VMIR isel / Target MIR codegen 均需 ABI 信息）
// Phase：Phase 2（SMIR X ABI 跨模块内联）+ Phase 5（VMIR c_abi_call 不内联）
// 职责：
//   - 定义 ABIKind（XABI(InlinePolicy) / CABI）
//   - 定义 InlinePolicy（Always / Never + 热度阈值）
//   - 提供 X ABI 语义契约查询（参数类型受限集 / 8 字节对齐无 padding / pure 默认 / 禁异常传播）
//   - C ABI FFI 边界标记（永不内联，Target MIR 直接 codegen）
// 依赖：inst（ABIKind 复用）
// 设计约束：
//   - X ABI 是 SHUX 唯一调用约定，安全（extern function，无需 unsafe）
//   - C ABI 需 unsafe（extern "C"，调用 C 库/系统调用）
//   - X ABI 参数类型受限：i32 / 枚举 / struct / 切片 / Arena 指针，禁止 *void / 裸函数指针
//   - 允许跨 ABI 内联（LTO / WPO）
//
// 参考文档：analysis/IR核心设计.md §8（调用约定与 ABI）/ analysis/X-ABI-设计分析.md
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 2 填充
