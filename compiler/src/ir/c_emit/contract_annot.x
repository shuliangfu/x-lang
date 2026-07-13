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

// contract_annot.x — Contract 注释生成器
//
// 模块：ir/c_emit
// 层级：Phase 0 专用
// Phase：Phase 0
// 职责：
//   - 从 .x AST / typeck 信息提取 Contract（Linear / Region / X ABI 语义）
//   - 生成 C 代码注释形式的 Contract 标注：
//     /* @contract: pre=[region_alive(%r), linear_valid(%h)] post=[linear_consumed(%h)] */
//   - 在 C 后端输出时插入到对应函数 / 语句前
//   - 验证契约提取逻辑正确性（与后续 IR 层契约一致）
// 依赖：../../ast / ../../typeck / ../contract
// 设计约束：
//   - Phase 0 的目的是验证契约提取逻辑，不影响 C 代码执行
//   - Contract 注释格式可被后续工具解析（用于差分测试）
//   - 提取必须 100% 确定性（前端 typeck 已验证，IR 层只做物化）
//
// 参考文档：analysis/IR核心设计.md §11.3（Phase 0 Checklist：第一步修改 .x → .c 生成器输出 Contract 注释）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 0 填充（Phase 0 是路线图第一步）
