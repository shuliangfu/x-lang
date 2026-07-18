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

// mod.x — Phase 0 Contract-Annotated C-Emitter 模块入口
//
// 模块：ir/c_emit
// 层级：Phase 0 专用（基于现有 C 后端扩展）
// Phase：Phase 0
// 职责：
//   - Phase 0 Contract-Annotated C-Emitter 入口
//   - 基于现有 codegen/codegen.x 扩展，输出带 Contract 注释的 C 代码
//   - 提前测试契约提取逻辑（在 IR 完整落地前验证契约系统）
//   - 聚合 c_emit/ 子模块导出（contract_annot）
// 依赖：../../codegen / ../contract
// 设计约束：
//   - Phase 0 是路线图第一步（§11）：修改 .x → .c 生成器，输出 Contract 注释
//   - 不影响现有 C 后端功能（增量扩展）
//   - 输出的 Contract 注释用于验证契约提取逻辑正确性
//
// 参考文档：analysis/IR核心设计.md §11（路线图 Phase 0）/ §11.3（Phase 0 Checklist）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 0 填充（Phase 0 是路线图第一步）
